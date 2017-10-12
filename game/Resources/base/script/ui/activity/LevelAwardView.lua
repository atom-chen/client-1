require("object.activity.ActivityDef")
require("object.activity.LevelAwardMgr")
require("ui.utils.BatchItemView")

LevelAwardView = LevelAwardView or BaseClass(BaseUI)

visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()
local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"

local grideSize = VisibleRect:getScaleSize(CCSizeMake(830,135))
local viewSize = CCSizeMake(700*viewScale,430*viewScale)

function LevelAwardView:__init()
	self.viewName = "LevelAwardView"		
	self:initFullScreen()

	self.eventType = {}	-- tableview的数据类型
	self.itemViewList = {}
	self:initValue()
	self:initStaticView()
	self:initAwardListView()											
end

function LevelAwardView:initStaticView()

	self:setFormImage( createSpriteWithFrameName(RES("main_activityUpGradeAward.png")))			
	self:setFormTitle( createSpriteWithFrameName(RES("advanced_awards.png")),TitleAlign.Left)	
	
	local centelViewBgSprite =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(centelViewBgSprite)	
	VisibleRect:relativePosition(centelViewBgSprite, self:getContentNode(), LAYOUT_CENTER)
		
	self.titleText = createLabelWithStringFontSizeColorAndDimension(Config.Words[13401],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.titleText:setAnchorPoint(ccp(0,0.5))
	self:addChild(self.titleText)	
	VisibleRect:relativePosition(self.titleText,self:getContentNode(), LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(30,-15))			
	
end	

function LevelAwardView:initValue()
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3			
end

function LevelAwardView:__delete()
	self:clearItemView()
end

function LevelAwardView:clearItemView()
	for key,itemList in pairs(self.itemViewList) do
		for key1,v in pairs(itemList) do
			if v then
				itemRootNode = v:getRootNode()
				if itemRootNode then
					itemRootNode:removeFromParentAndCleanup(true)
				end
				v:DeleteMe()
				v = nil
			end
		end			
	end
	self.itemViewList = {}
end

function LevelAwardView:create()
	return LevelAwardView.New()
end

function LevelAwardView:createItem(index)
	local item = CCNode:create()
	item:setContentSize(grideSize)
	
	local batchNode = SFSpriteBatchNode:create(const_pvr, 50)
	batchNode:setContentSize(grideSize)
	item:addChild(batchNode, 1)
	VisibleRect:relativePosition(batchNode, item, LAYOUT_CENTER)
	--背景		
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(819,98))
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER,ccp(0,-10))			
	item:addChild(cellBg)
	
	--顶部高亮条
	local textBg = createScale9SpriteWithFrameNameAndSize(RES("common_wordBg.png"),CCSizeMake(200,28))	
	VisibleRect:relativePosition(textBg,item,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE,ccp(0,-5))			
	item:addChild(textBg)
		
	--名称
	local goodsName = createLabelWithStringFontSizeColorAndDimension(G_GetLevelAwardDescTableByTypeAndIndex(1,index+1),"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
	goodsName:setAnchorPoint(ccp(0,1))						
	item:addChild(goodsName)
	VisibleRect:relativePosition(goodsName,textBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(20,0))		
		
	local itemAward = G_GetLevelAwardTableByTypeAndIndex(1,index+1)
	
	local awardList =  {}	
	local itemIndex = 1	
	for k,v in pairs(itemAward) do
		local itemBox = G_createItemShowByItemBox(v.refId,v.number,nil,nil,nil,-1)		
		awardList[itemIndex] = itemBox				
		itemIndex = itemIndex + 1				
	end

	local count = itemIndex - 1
	local startX = 32
	for i = 1,count do	
		item:addChild(awardList[i])								
		VisibleRect:relativePosition(awardList[i],item, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(startX,-2))		
		startX = startX + 110
	end

	local state = self:getIndexState(index+1)			
	local bt = self:createButtonNode(state,index+1)
	if bt then
		item:addChild(bt)	
		VisibleRect:relativePosition(bt,item,LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER_Y,ccp(-20,-5))
	end		

	local viewLine =  createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(830*viewScale,3*viewScale))
	item:addChild(viewLine)	
	VisibleRect:relativePosition(viewLine,item, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X )			
		
	return item
end	

function LevelAwardView:updateAwardView()
	--顶部	
	self:reloadTableView()
	self.awardTable:scroll2Cell(0, false)	
end


function LevelAwardView:onEnter()
	local levelAwardMgr = GameWorld.Instance:getLevelAwardManager()
	self.awardtypeList = levelAwardMgr:getRideAwardList()
	self.selectedCell = 1					
	self:reloadTableView()
	self.awardTable:scroll2Cell(0, false)	
end

function LevelAwardView:initAwardListView()
		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedCell  = cell:getIndex()+1
		return 0						
		--TODO																												
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createItem(index)				
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																								
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex( table.size(self.awardtypeList))
			return 1
		end
	end			

	--创建tableview

	self.awardTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(835,450)))
	self.awardTable:reloadData()
	self.awardTable:setTableViewHandler(tableDelegate)
	self.awardTable:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.awardTable)		
	VisibleRect:relativePosition(self.awardTable, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(5, -40))		
		
end

function LevelAwardView:createButtonNode(state,index)	
	if  state == SignAwardState.canGet then				
		local getAwardBt = createButtonWithFramename(RES("btn_1_select.png"))
		getAwardBt:setTag(20)
		local textlabel =  createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBt:setTitleString(textlabel)				
		local getAwardBtFunc = function()
			local refId = "rideReward_" .. index		
			local levelAwardMgr = GameWorld.Instance:getLevelAwardManager()
			levelAwardMgr:setAwardGetRefId(refId)
			levelAwardMgr:requestGetReward(refId,1)
		end
		getAwardBt:addTargetWithActionForControlEvents(getAwardBtFunc,CCControlEventTouchDown)								
		return getAwardBt
	elseif state == SignAwardState.hadGet then
		local getAwardBtSprite = createSpriteWithFrameName(RES("hadReceivedLable.png"))
		return getAwardBtSprite	
	else		
		local getAwardBtSprite = createButtonWithFramename(RES("btn_1_disable.png"))
		getAwardBtSprite:setTag(20)
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))
		getAwardBtSprite:setTitleString(textlabel)		
	
		return getAwardBtSprite	
	end			
end

function LevelAwardView:getIndexState(index)
	local levelAwardMgr = GameWorld.Instance:getLevelAwardManager()	
	local state =  levelAwardMgr:getRideAwardIndexState(index)				
	return state
end

function LevelAwardView:changeGetAwardCellState(state)
	local levelAwardMgr = GameWorld.Instance:getLevelAwardManager()	
	local refId = levelAwardMgr:getAwardGetRefId()
	levelAwardMgr:setRideAwardIndexState(refId, state)				
	self:reloadTableView()
end

function LevelAwardView:reloadTableView()
	self:clearItemView()
	self.awardTable:reloadData()
end

function LevelAwardView:onExit()
	local mountview = UIManager.Instance:getViewByName("MountView")
	if mountview then
		mountview:changeItemZuoqiExp()
	end
end


function LevelAwardView:__delete()

end


