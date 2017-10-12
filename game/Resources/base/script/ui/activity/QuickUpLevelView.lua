require("object.activity.ActivityDef")
require("object.activity.LevelAwardMgr")
require("ui.utils.BatchItemView")

QuickUpLevelView = QuickUpLevelView or BaseClass(BaseUI)

visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()
local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"

local grideSize = VisibleRect:getScaleSize(CCSizeMake(830,150))

function QuickUpLevelView:__init()
	self.viewName = "QuickUpLevelView"		
	self:initFullScreen()

	self.eventType = {}	-- tableview的数据类型
	self.itemViewList = {}	
	self:initValue()
	self:initStaticView()
	self:createViewTable()											
end

function QuickUpLevelView:initStaticView()
	--标题	
	self:setFormImage( createSpriteWithFrameName(RES("main_activityLevelUpAward.png")))		
	self:setFormTitle( createSpriteWithFrameName(RES("quick_open_service.png")),TitleAlign.Left)	
	local centelViewBgSprite =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(centelViewBgSprite)	
	VisibleRect:relativePosition(centelViewBgSprite, self:getContentNode(), LAYOUT_CENTER)
	
	
	self.titleText = createLabelWithStringFontSizeColorAndDimension(Config.Words[13404],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.titleText:setAnchorPoint(ccp(0,0.5))
	self:addChild(self.titleText)	
	VisibleRect:relativePosition(self.titleText,self:getContentNode(), LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(22,-9))	
		
	self.timeText = createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.timeText:setAnchorPoint(ccp(0,0.5))
	self:addChild(self.timeText)	
	VisibleRect:relativePosition(self.timeText,self:getContentNode(), LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(150,-29))	
		
	self.countDownText = createLabelWithStringFontSizeColorAndDimension(Config.Words[13405],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.countDownText:setAnchorPoint(ccp(0,0.5))
	self:addChild(self.countDownText)	
	VisibleRect:relativePosition(self.countDownText,self:getContentNode(), LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(22,-29))	
				
end	

function QuickUpLevelView:initValue()
	
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3			
	self.levelNumberBgSpriteList = {}
end

function QuickUpLevelView:createItem(index)
	local item = CCNode:create()
	item:setContentSize(grideSize)	
	
	local batchNode = SFSpriteBatchNode:create(const_pvr, 50)	
	batchNode:setContentSize(grideSize)
	item:addChild(batchNode, 1, 100)
	VisibleRect:relativePosition(batchNode, item, LAYOUT_CENTER)
	--背景		
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(810,103))
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER,ccp(0,-10))			
	item:addChild(cellBg)
	
	--顶部高亮条	
	local textBg = createScale9SpriteWithFrameNameAndSize(RES("levelup_wordline.png"),CCSizeMake(819,28))
	VisibleRect:relativePosition(textBg,item,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE,ccp(0,-5))			
	item:addChild(textBg)
	--名称
	local goodsName = createLabelWithStringFontSizeColorAndDimension(G_GetLevelAwardDescTableByTypeAndIndex(4,index+1),"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
	goodsName:setAnchorPoint(ccp(0,1))						
	item:addChild(goodsName)
	VisibleRect:relativePosition(goodsName,textBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(20,0))	
		
	local itemAward = G_GetLevelAwardTableByTypeAndIndex(4,index+1)
	
	local awardList =  {}	
	local itemIndex = 1	
	for k,v in pairs(itemAward) do		
		local itemBox = G_createItemShowByItemBox(v.refId,v.number,nil,nil,nil,-1)
		awardList[itemIndex] = itemBox		
		itemIndex = itemIndex + 1		
	end		
	
	local count = itemIndex - 1
	local startX = 28
	for i = 1,count do	
		item:addChild(awardList[i])								
		VisibleRect:relativePosition(awardList[i],item, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(startX,-2))		
		startX = startX + 110
	end

	local state = self:getIndexState(index+1)			
	local bt = self:createButtonNode(state,index+1)	
	item:addChild(bt)
	if state == 1 then
		VisibleRect:relativePosition(bt,item,LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER,ccp(-34,-10))
	else
		VisibleRect:relativePosition(bt,item,LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER,ccp(-20,-8))
	end

	local viewLine =  createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(830*viewScale,3*viewScale))
	item:addChild(viewLine)	
	VisibleRect:relativePosition(viewLine,item, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X )			
	
	return item
end	

function QuickUpLevelView:createButtonNode(state,index)
	local getAwardBtSprite
	if  state == SignAwardState.canGet then	
		getAwardBtSprite = createButtonWithFramename(RES("btn_1_select.png"))
		getAwardBtSprite:setTag(20)
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBtSprite:setTitleString(textlabel)		

		local getAwardBtFunc = function()
			local rtwMgr = GameWorld.Instance:getLevelAwardManager()			
			local refId = "levelUpReward_" ..  index
			rtwMgr:setAwardGetRefId(refId)
			rtwMgr:requestGetReward(refId,4)
			self:clickRewardNode()			
		end
		getAwardBtSprite:addTargetWithActionForControlEvents(getAwardBtFunc,CCControlEventTouchDown)
	elseif state == SignAwardState.hadGet then
		getAwardBtSprite = createSpriteWithFrameName(RES("hadReceivedLable.png"))
		getAwardBtSprite:setRotation(-30)
	else
		getAwardBtSprite = createButtonWithFramename(RES("btn_1_disable.png"))
		getAwardBtSprite:setTag(20)
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBtSprite:setTitleString(textlabel)		
	end	
	getAwardBtSprite:setAnchorPoint(ccp(0.5,0.5))
	return 	getAwardBtSprite
end	

function QuickUpLevelView:createViewTable()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")		
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER,ccp(-4,0))
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				tableCell:setIndex(index)
				local item = self:createItem(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER,ccp(-4,0))
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量
			local rtwMgr = GameWorld.Instance:getLevelAwardManager()		
			self.awardtypeList = rtwMgr:getLevelUpAwardList()	
			local count = table.size(self.awardtypeList)	
			data:setIndex(count)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)	
		cell = tolua.cast(cell,"SFTableViewCell")
		local selectIndex = cell:getIndex()							
		self:clickRewardNode()
		return 0
	end

	self.tableView = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(835,440)))	
	self.tableView:setTableViewHandler(tableDelegate)
	self.tableView:reloadData()
	self.tableView:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.tableView)
	VisibleRect:relativePosition(self.tableView, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(5, -50))		
end	

function QuickUpLevelView:updateAwardView()
	--顶部	
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()		
	local countDown = function()
		rtwMgr:setTotalSecond(rtwMgr:getTotalSecond()-1)
		self:showCountDown()
	end		
	if rtwMgr:getTotalSecond() > 0 then
		if not self.schedulerId then
			self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countDown,1, false)		
		end	
	else
		self.timeText:setString(Config.Words[13410])	
	end
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()		
	self.awardtypeList = rtwMgr:getLevelUpAwardList()	
	self:reloadTabelView()
end


function QuickUpLevelView:hideCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end	
end

function QuickUpLevelView:showCountDown()
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local totalSeconds = rtwMgr:getTotalSecond()
	local day = math.floor(totalSeconds/(24*3600))	
	local hour = math.floor(totalSeconds/3600)%24
	local minite = math.floor(totalSeconds/60)%60
	local sec = totalSeconds%60	
	local str
	if day > 0 then
		str = day .. Config.Words[13007]..string.format("%d:%02d:%02d",hour,minite,sec)
	else
		if hour > 0 then
			str = string.format("%d:%02d:%02d",hour,minite,sec)
		else
			if minite > 0 then
				str = string.format("%02d:%02d",minite,sec)	
			else
				str = string.format("%02d",sec)	
			end
		end
	end
	
	self.timeText:setString(str)	
end

local percentList = {
[1] = 10,
[2] = 30,
[3] = 50,
[4] = 70,	
}

function QuickUpLevelView:getIndexState(index)
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local state = rtwMgr:getLevelUpAwardIndexState(index)	
	return state
end

function QuickUpLevelView:changeGetAwardCellState(state)
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local refId = rtwMgr:getAwardGetRefId()
	self.awardtypeList[refId] = state
	self:reloadTabelView()
end

function QuickUpLevelView:reloadTabelView()
	self:clearItemView()	
	self.tableView:reloadData()
end

function QuickUpLevelView:onEnter()
	self.selectedCell = 1
	self.timeText:setString(" ")	
end

function QuickUpLevelView:onExit()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

function QuickUpLevelView:__delete()
	self:clearItemView()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end	

function QuickUpLevelView:clearItemView()
	for key,itemList in pairs(self.itemViewList) do
		for key1,v in pairs(itemList) do
			if v then
				local itemViewNode = v:getRootNode()
				if itemViewNode and itemViewNode:getParent() then
					itemViewNode:removeFromParentAndCleanup(true)				
				end	
				v:DeleteMe()			
			end
		end			
	end
	self.itemViewList = {}
end

function QuickUpLevelView:create()
	return QuickUpLevelView.New()
end

-----------------------------------------------新手引导----------------------------------------------------
function QuickUpLevelView:getRewardNode()
	return self.tableView
end

function QuickUpLevelView:clickRewardNode()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"QuickUpLevelView")
end