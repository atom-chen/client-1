require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.ItemGridView")
require("data.item.unPropsItem")	
OffLineBagView = OffLineBagView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_mainBg_size = CCSizeMake(840, 480)
local const_bagBg_size = CCSizeMake(810, 390)
local const_cell_size = CCSizeMake(840, 37)
local g_scale = VisibleRect:SFGetScale()
local g_boxSize = CCSizeMake(85*g_scale,85*g_scale)
local g_boxTotalCount = 180
local g_boxUseCount = 160

function OffLineBagView:__init()
	self.viewName = "OffLineBagView"
	local offLineBagMgr = GameWorld.Instance:getOffLineBagMgr()
	self.offLineBagObject = offLineBagMgr:getOffLineBagObject()
	self.hadDraw = nil
	
	self:initUI()
end

function OffLineBagView:__delete()
end

function OffLineBagView:create()
	return OffLineBagView.New()
end

function OffLineBagView:onEnter()
	--[[self:updateBagView()
	self:updateLogView()--]]
end

function OffLineBagView:initUI()	
	self:initFullScreen()
	
	--主背景
	self.mainBg = createScale9SpriteWithFrameName(RES("mallCellBg.png"))
	self.mainBg:setContentSize(const_mainBg_size)
	self.rootNode:addChild(self.mainBg)
	VisibleRect:relativePosition(self.mainBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-55))
	
	-- 图标
	local titleSign = createSpriteWithFrameName(RES("sevenLoginIcon.png"))
	self.rootNode:addChild(titleSign)
	VisibleRect:relativePosition(titleSign,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(-15,40))
	
	-- 标题
	local titleName = createSpriteWithFrameName(RES("sevenLoginTitle.png"))
	self.rootNode:addChild(titleName)
	VisibleRect:relativePosition(titleName,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(70,-15))

	-- bag页卡
	local bagFunc = function()
		if self.bagNode then
			self.bagNode:setVisible(true)
		end
		if self.logNode then
			self.logNode:setVisible(false)
		end	
	end
	self.bagTag = createButton(createScale9SpriteWithFrameNameAndSize(RES("tab_2_normal.png"),CCSizeMake(50,100)),createScale9SpriteWithFrameNameAndSize( RES("tab_2_select.png"),CCSizeMake(40,100)))
	
	local bagLabel = createRichLabel(CCSizeMake(40,100))
	bagLabel:clearAll()
	bagLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16200].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	bagLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16201].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	bagLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16209].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	bagLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16210].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	self.bagTag:addTargetWithActionForControlEvents(bagFunc,CCControlEventTouchDown)	
	self.bagTag:addChild(bagLabel)		
	VisibleRect:relativePosition(bagLabel,self.bagTag,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(5,-10))	
	
	-- log页卡
	local logFunc = function()
		if self.bagNode then
			self.bagNode:setVisible(false)
		end
		if self.logNode then
			self.logNode:setVisible(true)
		end	
	end
	self.logTag = createButton(createScale9SpriteWithFrameNameAndSize(RES("tab_2_normal.png"),CCSizeMake(50,100)),createScale9SpriteWithFrameNameAndSize( RES("tab_2_select.png"),CCSizeMake(40,100)))
	
	local logLabel = createRichLabel(CCSizeMake(40,100))
	logLabel:clearAll()
	logLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16200].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	logLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16201].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	logLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16211].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	logLabel:appendFormatText(string.wrapHyperLinkRich(Config.Words[16212].."\n", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
	self.logTag:addTargetWithActionForControlEvents(logFunc,CCControlEventTouchDown)	
	self.logTag:addChild(logLabel)		
	VisibleRect:relativePosition(logLabel,self.logTag,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(5,-10))	
	
	-- 页卡组
	local tabArray = CCArray:create()
	tabArray:addObject(self.logTag)
	tabArray:addObject(self.bagTag)	
	self.tabTitle = createTabView(tabArray, 10, tab_vertical)
	self.mainBg:addChild(self.tabTitle)
	VisibleRect:relativePosition(self.tabTitle, self.mainBg, LAYOUT_LEFT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(0,-20))
	self.tabTitle:setSelIndex(1)	

	self:initBagView()
	self:initLogView()
end

function OffLineBagView:initBagView()
	-- 背包Node
	self.bagNode = CCNode:create()
	self.bagNode:setContentSize(const_mainBg_size)
	self.bagNode:setVisible(true)
	self.mainBg:addChild(self.bagNode)
	VisibleRect:relativePosition(self.bagNode, self.mainBg, LAYOUT_CENTER)
	
	-- 背包背景
	self.bagBg = createScale9SpriteWithFrameName(RES("countDownBg.png"))
	self.bagBg:setContentSize(const_bagBg_size)
	self.bagNode:addChild(self.bagBg)
	VisibleRect:relativePosition(self.bagBg,self.bagNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-15))
	
	-- 背包GridView		
	self.bagGridView = ItemGridView.New()	
	self.bagGridView:setPageOption(4, 9)
	self.bagGridView:setSpacing(3, 3)
	--self.bagGridView:setTouchNotify(self, self.handleTouchItem)	
	local itemList = self.offLineBagObject:getItemList()
	self.bagGridView:setItemList(itemList,g_boxSize,1,180,160)
	self.bagNode:addChild(self.bagGridView:getRootNode())
	VisibleRect:relativePosition(self.bagGridView:getRootNode(), self.bagNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(0, -30))	
	
	-- 背包页数指示器
	self.bagPageIndicate = createPageIndicateView(5, 1) 
	self.bagGridView:setPageChangedNotify(self.bagPageIndicate, self.bagPageIndicate.setIndex)
	self.bagNode:addChild(self.bagPageIndicate:getRootNode())	
	VisibleRect:relativePosition(self.bagPageIndicate:getRootNode(), self.bagNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(0, -335))
	
	-- 获取收益按钮
	local drawAwardFunction = function()
		GlobalEventSystem:Fire(GameEvent.EventDrawOffLineAIReward)
	end
	
	local drawAwardBtn = createButtonWithFramename(RES("btn_1_select_select.png.png"))		
	G_setScale(drawAwardBtn)
	self.bagNode:addChild(drawAwardBtn)
	VisibleRect:relativePosition(drawAwardBtn, self.bagNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(-250, -410))
	local drawAwardLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16205],"Arial",FSIZE("Size6"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
	drawAwardBtn:setTitleString(drawAwardLable)
	VisibleRect:relativePosition(drawAwardLable, drawAwardBtn, LAYOUT_CENTER)
	drawAwardBtn:addTargetWithActionForControlEvents(drawAwardFunction,CCControlEventTouchDown)
	
	-- 补充魔血石按钮
	local addStoneFunction = function()
		
	end
	
	local addStoneBtn = createButtonWithFramename(RES("btn_1_select_select.png.png"))		
	G_setScale(addStoneBtn)
	self.bagNode:addChild(addStoneBtn)
	VisibleRect:relativePosition(addStoneBtn, self.bagNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(250, -410))
	local addStoneLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16206],"Arial",FSIZE("Size6"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
	addStoneBtn:setTitleString(addStoneLable)
	VisibleRect:relativePosition(addStoneLable, addStoneBtn, LAYOUT_CENTER)
	addStoneBtn:addTargetWithActionForControlEvents(addStoneFunction,CCControlEventTouchDown)
	
	-- 金币标签
	self.goldLabel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorYellow1"))
	self.bagNode:addChild(self.goldLabel)		
	VisibleRect:relativePosition(self.goldLabel,self.bagNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(-70, -440))
	
	-- 经验标签
	self.expLabel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorYellow1"))
	self.bagNode:addChild(self.expLabel)		
	VisibleRect:relativePosition(self.expLabel,self.bagNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(70, -440))
end

function OffLineBagView:initLogView()
	-- 日志Node
	self.logNode = CCNode:create()
	self.logNode:setContentSize(const_mainBg_size)
	self.logNode:setVisible(false)
	self.mainBg:addChild(self.logNode)
	VisibleRect:relativePosition(self.logNode, self.mainBg, LAYOUT_CENTER)
	
	-- 日志TableView
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(const_cell_size))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(const_cell_size))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(const_cell_size))
				local item = self:createLogCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(const_cell_size))
				tableCell:setIndex(index)
				local item = self:createLogCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量	
			local tableLen = table.getn(self.offLineBagObject.logs)
			data:setIndex(tableLen)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
			
	end
	
	self.logTableView = createTableView(dataHandler,VisibleRect:getScaleSize(const_mainBg_size))	
	self.logTableView:setTableViewHandler(tableDelegate)
	self.logTableView:reloadData()
	self.logTableView:scroll2Cell(0, true)  --回滚到第一个cell
	self.logNode:addChild(self.logTableView)
	VisibleRect:relativePosition(self.logTableView, self.logNode, LAYOUT_CENTER)
end

function OffLineBagView:createLogCell(index)
	local cellNode = CCNode:create()
	cellNode:setContentSize(const_cell_size)
	
	-- cell背景
	cellBg = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"),CCSizeMake(840,2))
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)
	
	-- cell内容
	local richText = self:createText(index)
	cellNode:addChild(richText)
	VisibleRect:relativePosition(richText,cellNode,LAYOUT_CENTER)
	return cellNode
end

function OffLineBagView:createText(index)
	local sceneRichLabelHandler = function(eventStr, pTouch)
		local touch = tolua.cast(pTouch, "CCTouch")
		
		if string.sub(eventStr, 1, 1) == "S" then --场景
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:startFindTargetPaths(eventStr)
			G_getHandupMgr():stop()	
			UIManager.Instance:hideAllUI()
		else
			local itemObj = ItemObject.New()
			itemObj:setRefId(eventStr)
			itemObj:setStaticData(G_getStaticDataByRefId(itemObj:getRefId()))	
			if itemObj:getType()==ItemType.eItemEquip then
				itemObj:setPT(G_getStaticDataByRefId(itemObj:getRefId()).effectData)
				if not itemObj:getPT().fightValue then
						local fightValue = G_getEquipFightValue(eventStr)
					if fightValue then
						itemObj:updatePT({fightValue = fightValue})	
					end	
				end				
			else
				itemObj:setPT({bindStatus = 0})--写死初始绑定状态为非绑定状态
			end
			G_clickItemEvent(itemObj)
		end	
	end
	
	local text = createRichLabel(CCSizeMake(0,0))
	text:setTouchEnabled(true)	
	text:clearAll()
	text:setEventHandler(sceneRichLabelHandler)	

	local data = self.offLineBagObject:getLogData(index+1)
	if data.logType == 1 then	
		local logData = data.log
		text:appendFormatText(Config.Words[16202])
		local sceneName = GameData.Scene[logData.aiGameSceneRefId].property.name
		local sceneText = string.wrapHyperLinkRich(sceneName, Config.FontColor["ColorGreen1"], FSIZE("Size3"), tostring(logData.aiGameSceneRefId), "true")
		text:appendFormatText(sceneText)
	elseif data.logType == 2 then
		local logData = data.log
		text:appendFormatText(Config.Words[16203])
		local playerText = string.wrapHyperLinkRich(logData.playerName, Config.FontColor["ColorGreen1"], FSIZE("Size3"), tostring(logData.playerName), "true")
		text:appendFormatText(playerText)
		text:appendFormatText(Config.Words[16204])
		local itemsData = logData.dorpItem
		for i = 1,table.getn(itemsData) do
			local itemName
			if self:isUnPropsItem(itemsData[i].itemRefId) then
				itemName = G_getStaticUnPropsName(itemsData[i].itemRefId)
			else
				itemName = G_getStaticPropsName(itemsData[i].itemRefId)	
			end
			local itemText = string.wrapHyperLinkRich(itemName.."X"..itemsData[i].itemNum..",", Config.FontColor["ColorGreen1"], FSIZE("Size3"), tostring(itemsData[i].itemRefId), "true")
			text:appendFormatText(itemText)
		end
	end

	text:appendFormatText(sceneName2)
	
	return text
end

function OffLineBagView:updateBagView()
	local itemList = self.offLineBagObject:getItemList()
	self.bagGridView:setItemList(itemList,g_boxSize,1,g_boxTotalCount,g_boxUseCount)

	local goldText = Config.Words[16207]..self.offLineBagObject:getMoney()
	self.goldLabel:setString(goldText)
	
	local expText = Config.Words[16208]..self.offLineBagObject:getExp()
	self.expLabel:setString(expText)
end

function OffLineBagView:updateLogView()
	self.logTableView:reloadData()
	self.logTableView:scroll2Cell(0, true)  --回滚到第一个cell
end

------------------------私有接口-----------------------
function OffLineBagView:isUnPropsItem(itemRefId)
	
	for k,v in pairs(GameData.UnPropsItem) do
		if v.refId == itemRefId then
			return true
		end
	end
	return false
end