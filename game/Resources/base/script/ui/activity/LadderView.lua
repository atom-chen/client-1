require("ui.UIManager")
require("common.BaseUI")

local viewScale = VisibleRect:SFGetScale()

LadderView = LadderView or BaseClass(BaseUI)

local rankListLable = {
	[1] = Config.Words[16028],
	[2] = Config.Words[16029],
	[3] = Config.Words[16030],
	[4] = Config.Words[16031],
	[5] = Config.Words[16032],
	[6] = Config.Words[16033],
	[7] = Config.Words[16034],
}

local rankListField = {
	[1] = "",
	[2] = "nickName",
	[3] = "profesion",
	[4] = "level",
	[5] = "fighting",
	[6] = "guild",
	[7] = "trend",
}

function LadderView:__init()
	self.viewName = "LadderView"	
	
	local ArenaMgr = GameWorld.Instance:getArenaMgr()
	self.arenaObject = ArenaMgr:getArenaObject()
	self:initWindow()	
end

function LadderView:__delete()
end

function LadderView:onEnter()
	self:updateTableView()
end

function LadderView:create()
	return LadderView.New()
end

function LadderView:initWindow()
	self:initFullScreen()
	
	local titleSign = createSpriteWithFrameName(RES("main_activityHonor.png"))
	self:setFormImage(titleSign)
	local titleName = createSpriteWithFrameName(RES("main_activityHonor_word.png"))
	self:setFormTitle(titleName, TitleAlign.Left)
	
	self.windowBg = createScale9SpriteWithFrameName(RES("squares_bg2.png"))
	self.windowBg:setContentSize(self:getContentNode():getContentSize())--CCSizeMake(833,483))
	self:addChild(self.windowBg)
	VisibleRect:relativePosition(self.windowBg,self:getContentNode(),LAYOUT_CENTER,ccp(0,0))
	
	local topTitleBg = createScale9SpriteWithFrameName(RES("talisman_bg.png"))
	topTitleBg:setContentSize(CCSizeMake(833,30))
	self.windowBg:addChild(topTitleBg)
	VisibleRect:relativePosition(topTitleBg,self.windowBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER)	
	
	for i=1,7 do
		local rankListLableNode = CCNode:create()
		rankListLableNode:setContentSize(CCSizeMake(119,30))
		local rankListLableName = createLabelWithStringFontSizeColorAndDimension(rankListLable[i],"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))
		rankListLableNode:addChild(rankListLableName)
		VisibleRect:relativePosition(rankListLableName,rankListLableNode, LAYOUT_CENTER,ccp(0,0))
		self.windowBg:addChild(rankListLableNode)
		VisibleRect:relativePosition(rankListLableNode,self.windowBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(6+(i-1)*119,0))
		if i ~= 7 then
			local dividLine = createSpriteWithFrameName(RES("verticalDivideLine.png"))
			rankListLableNode:addChild(dividLine)
			VisibleRect:relativePosition(dividLine,rankListLableNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER)	
		end
	end
	
	self:initTableView()
end

function LadderView:initTableView()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local cellSize = VisibleRect:getScaleSize(CCSizeMake(833,50))
			
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createRankListCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createRankListCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量	
			data:setIndex(table.getn(self.arenaObject.ladderRankList))
			return 1
		end
	end
		
	local tableDelegate = function (tableP,cell,x,y)
	end
		
	self.rankList = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(833, 453)))	
	self.rankList:setTableViewHandler(tableDelegate)
	self.rankList:reloadData()
	self.rankList:scroll2Cell(0, false)  --回滚到第一个cell
	self.windowBg:addChild(self.rankList)
	VisibleRect:relativePosition(self.rankList, self.windowBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-30))
end

function LadderView:createRankListCell(index)
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(833,50))
	cellNode:setContentSize(cellSize)
	
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("left_line.png"),CCSizeMake(833,2))
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)

	for i = 1,7 do
		local textNode = CCNode:create()
		textNode:setContentSize(CCSizeMake(119,50))
		local text
		if i == 1 then			-- 名次特殊处理	
			if index < 3 then
				text = createSpriteWithFrameName(RES("no"..(index+1)..".png"))
			else
				text = createLabelWithStringFontSizeColorAndDimension(tostring(index+1),"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
			end
		elseif i == 2 then		-- 名字特殊处理
			if self.arenaObject.ladderRankList[index+1]["gender"] == ModeType.eGenderMale then
				text = createLabelWithStringFontSizeColorAndDimension(self.arenaObject.ladderRankList[index+1][rankListField[i]],"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorBlue1"),CCSizeMake(0,0))
			elseif self.arenaObject.ladderRankList[index+1]["gender"] == ModeType.eGenderFemale then
				text = createLabelWithStringFontSizeColorAndDimension(self.arenaObject.ladderRankList[index+1][rankListField[i]],"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorPink1"),CCSizeMake(0,0))
			end
		elseif i == 3 then		-- 职业特殊处理
			local word = self.arenaObject.ladderRankList[index+1][rankListField[i]]
			local professionName
			if word == ModeType.ePlayerProfessionWarior then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarior)
				text = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))
			elseif word == ModeType.ePlayerProfessionMagic then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionMagic)
				text = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorRed1"),CCSizeMake(0,0))
			elseif word == ModeType.ePlayerProfessionWarlock then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarlock)
				text = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorBlue1"),CCSizeMake(0,0))	
			end
		elseif i == 4 then		-- 等级特殊处理
			text = createLabelWithStringFontSizeColorAndDimension("Lv."..self.arenaObject.ladderRankList[index+1][rankListField[i]],"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
		elseif i == 7 then		-- 上升下降持平特殊处理	
			if self.arenaObject.ladderRankList[index+1][rankListField[i]] == 0 then
				text = createLabelWithStringFontSizeColorAndDimension("-","Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))
			elseif self.arenaObject.ladderRankList[index+1][rankListField[i]] == 1 then
				text = createSpriteWithFrameName(RES("bagBatch_up_tip.png"))
			else
				text = createSpriteWithFrameName(RES("bagBatch_down_tip.png"))
			end
		else
			text = createLabelWithStringFontSizeColorAndDimension(self.arenaObject.ladderRankList[index+1][rankListField[i]],"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
		end
		textNode:addChild(text)
		VisibleRect:relativePosition(text, textNode, LAYOUT_CENTER)
		cellNode:addChild(textNode)
		VisibleRect:relativePosition(textNode, cellNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp((6+(i-1)*119),0))
	end
		
	return cellNode
end	

function LadderView:updateTableView()
	self.rankList:reloadData()
end