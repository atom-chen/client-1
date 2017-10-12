require("object.activity.ActivityDef")
require("ui.utils.ItemView")

FundView = FundView or BaseClass(BaseUI)

visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()
local grideSize = VisibleRect:getScaleSize(CCSizeMake(315,115))
local cellSize = VisibleRect:getScaleSize(CCSizeMake(639,115))
local CELL_TAG = 100

function FundView:__init()
	self.viewName = "FundView"		
	self:initFullScreen()
	self.requestGetCellIndex = -1
	self.selectedCell = 1
	self.selectedFundType = 1
	self.eventType = {}	-- tableview的数据类型
	self.tabelList = {}
	self.tableCellList = {}		
	self:initStaticView()										
end	

function FundView:__delete()
	self.cellFrame:release()
	self.tableCellList = {}	
	self.selectFundType = nil		
end

function FundView:initStaticView()
	self:setFormImage( createSpriteWithFrameName(RES("main_activityFund.png")))
	self:setFormTitle( createSpriteWithFrameName(RES("fund_titleText.png")),TitleAlign.Left)		

	--背景
	self.viewBg =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(self.viewBg)	
	VisibleRect:relativePosition(self.viewBg, self:getContentNode(), LAYOUT_CENTER)
		
	--tab 背景
	local tabBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(176, 400))
	self:addChild(tabBg)
	VisibleRect:relativePosition(tabBg,self.viewBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(7,-80))
		
	--table背景
	self.tableBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(639, 400))
	self:addChild(self.tableBg)
	VisibleRect:relativePosition(self.tableBg,self.viewBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-6,-80))
	--广告		
	local fundAdSpr = CCSprite:create("ui/ui_img/activity/game_fund_ad.pvr")
	self:addChild(fundAdSpr)	
	VisibleRect:relativePosition(fundAdSpr,self.viewBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(7,-7))	
	--广告2
	self.adBgSpr = createScale9SpriteWithFrameNameAndSize(RES("common_wordBg.png"),CCSizeMake(630, 50))
	self:addChild(self.adBgSpr)	
	VisibleRect:relativePosition(self.adBgSpr,self.tableBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(3,-13))		
	--广告文字
	self.adText = createLabelWithStringFontSizeColorAndDimension( " " ,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(self.adText)	
	VisibleRect:relativePosition(self.adText,self.adBgSpr,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(10,0))
	
	--广告文字
	self.contentText = createLabelWithStringFontSizeColorAndDimension(" " ,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(self.contentText)	
	VisibleRect:relativePosition(self.contentText,self.adBgSpr,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(10,0))
			
	self:initValue()
	self:createBuyFundBt()
	self:createGetFundAwardBt()
	self:initTabView()
end

function FundView:createBuyFundBt()
	local btText = createSpriteWithFrameName(RES("word_buynow.png"))
	self.buyFundBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.buyFundBt:setTitleString(btText)
	self:addChild(self.buyFundBt)
	VisibleRect:relativePosition(self.buyFundBt,self.tableBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-26,-8))
	local clickFunc = function(arg,text,id)
		if id  == 0 then
			if arg == true then
				local fundMgr = GameWorld.Instance:getFundManager()
				fundMgr:requestBuyFund(self.selectFundType)
			else
				UIManager.Instance:showSystemTips(Config.Words[20018])	
			end
		end
	end
	
	local buyFundFunc = function()
		local priceType , price = G_getFundPrice(self.selectFundType)
		local tipsStr = " "
		local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
		local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
		local bindedGold  = PropertyDictionary:get_bindedGold(g_hero:getPT())
		local gold  = PropertyDictionary:get_gold(g_hero:getPT())	
				
		
		local isEnoughMoney = false	
		if priceType == 2 then
			tipsStr = string.format(Config.Words[20017], price)
			if unbindedGold >= price then
				isEnoughMoney =  true
			end
		elseif priceType == 1 then
			tipsStr = string.format(Config.Words[20016], price)
			if gold >= price then
				isEnoughMoney =  true
			end
		end
		local btns ={
			{text = Config.LoginWords[10045], id = 1},
			{text = Config.LoginWords[10043], id = 0},			
		}				
		local msg = showMsgBox(tipsStr)
		msg:setBtns(btns)
		msg:setNotify(clickFunc,isEnoughMoney)	
	end
	self.buyFundBt:addTargetWithActionForControlEvents(buyFundFunc,CCControlEventTouchDown)	
end 

function FundView:createGetFundAwardBt()
	local btText = createSpriteWithFrameName(RES("word_button_getreword.png"))
	self.getFundAwardBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.getFundAwardBt:setTitleString(btText)	
	self:addChild(self.getFundAwardBt)
	VisibleRect:relativePosition(self.getFundAwardBt,self:getContentNode(),LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(-24,-20))
	local getFundAwardFunc = function()
		local fundMgr = GameWorld.Instance:getFundManager()
		local curDay = fundMgr:getCurrentDay(self.selectFundType)
		fundMgr:requestGetFundReward(self.selectFundType,curDay)			
	end
	self.getFundAwardBt:addTargetWithActionForControlEvents(getFundAwardFunc,CCControlEventTouchDown)	
	self.getFundAwardBt:setVisible(false)
end 

function FundView:TabPress(key)
	local fundMgr = GameWorld.Instance:getFundManager()
	if self.selectFundType then
		if self.selectFundType == key then
			fundMgr:requestFundVersion(self.selectFundType)	
			local curDay = fundMgr:getCurrentDay(self.selectFundType)
			if curDay then
				local index = math.floor(curDay/2)
				if index > 1 then			
					self.tabelList[self.selectFundType]:scroll2Cell(index-1, false)	
				else
					self.tabelList[self.selectFundType]:scroll2Cell(0, false)	
				end
			else
				self.tabelList[self.selectFundType]:scroll2Cell(0, false)	
			end			
			return
		end
		self:setAdText()
		self.tabelList[self.selectFundType]:setVisible(false)		
	end	

	self.selectFundType = key

	local curDay = fundMgr:getCurrentDay(self.selectFundType)
	if curDay then
		local index = math.floor(curDay/2)
		if index > 1 then			
			self.tabelList[self.selectFundType]:scroll2Cell(index-1, false)	
		else
			self.tabelList[self.selectFundType]:scroll2Cell(0, false)		
		end
	else
		self.tabelList[self.selectFundType]:scroll2Cell(0, false)	
	end
	fundMgr:requestFundVersion(self.selectFundType)	
	self.tabelList[key]:setVisible(true)
	self.buyFundBt:setVisible(false)
end	

function FundView:UpdateFundViewTable(ttype)
	self.tableCellList[ttype] = {}
	self.tabelList[ttype]:reloadData()
	
	local fundMgr = GameWorld.Instance:getFundManager()	
	local curDay = fundMgr:getCurrentDay(ttype)
	local index = math.floor(curDay/2)
	if index > 1 then			
		self.tabelList[ttype]:scroll2Cell(index-1, false)		
	end
--[[	local stateList = fundMgr:getFundStateList(ttype)	
	if stateList[curDay]  == 2 then
		self.getFundAwardBt:setVisible(false)
	end		--]]
end

function FundView:UpdateFundViewTableCell(ttype)
	local fundMgr = GameWorld.Instance:getFundManager()	
	local fundStateList = fundMgr:getFundStateList(ttype)
	fundStateList[self.requestGetCellIndex] = 1
	local cellList = self.tableCellList[ttype]	
	local realIndex = math.floor((self.requestGetCellIndex-1)/2)
	cellList[realIndex] = self:createTableCell(realIndex,ttype)
	self.tabelList[ttype]:updateCellAtIndex(realIndex)		
end	

function FundView:showBuyFundBt(state)
	self.buyFundBt:setVisible(state)	
end

function FundView:createFundTypeCell(index)
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(175,53))
	local cellBg
	if self.selectedFundType == index + 1 then
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_btn.png"),CCSizeMake(166,53))
	else
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_nomal_btn.png"),CCSizeMake(166,53))
	end
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_CENTER)

	local cellWord = createSpriteWithFrameName(RES(self.tabList[index + 1]))
	
	cellBg:addChild(cellWord)
	VisibleRect:relativePosition(cellWord,cellBg, LAYOUT_CENTER)
	
	return cellNode
end

function FundView:initTabView()
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedFundType  = cell:getIndex()+1		
		self:TabPress(self.selectedFundType)
		tableP:reloadData()	
		return 1								
	end
		
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(175,55)))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(175,55)))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(CCSizeMake(175,55)))
				local item = self:createFundTypeCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(CCSizeMake(175,55)))
				local item = self:createFundTypeCell(index)				
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																					
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(table.size(self.tabList))
			return 1
		end
	end			

	--创建tableview
	self.fundTypeTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(175, 400)))
	self.fundTypeTable :reloadData()
	self.fundTypeTable :setTableViewHandler(tableDelegate)
	self.fundTypeTable :scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.fundTypeTable )		
	VisibleRect:relativePosition(self.fundTypeTable , self.viewBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(8,-85))
	
	
end

function FundView:initValue()
	
	local fundMgr = GameWorld.Instance:getFundManager()
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3	
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bg3.png"),CCSizeMake(320,110))
	self.cellFrame:retain()		
	local tableCount = fundMgr:getFundSize()
	
	self.tabList = {		
		[1] = "word_fund_1.png",
		[2] = "word_fund_2.png",
		[3] = "word_fund_3.png",		
	}
	for i = 1, tableCount do
		self.tableCellList[i] = {}
	end
	
	for i=1,tableCount do 
		self.tabelList[i] = self:createFundTable(i)
		self.tabelList[i]:setVisible(false)
	end	
end

function FundView:onExit()
	
end	

function FundView:create()
	return FundView.New()
end

function FundView:createItem(index,key)
	local fundType = "fund_" ..key
	local fundRewardList = 	G_GetFundRewardList(fundType)
	local fundMgr = GameWorld.Instance:getFundManager()
	local item = CCNode:create()
	item:setContentSize(grideSize)	
	
	local stateList = fundMgr:getFundStateList(key)	
	local reward = {}	
	if fundRewardList["day"..index] then
		reward = fundRewardList["day"..index]
	end
	--背景		
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(305,110))	
	item:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER)			
	--名称
	local dayStr = string.format(Config.Words[20010],index)
	local daysLabel = createLabelWithStringFontSizeColorAndDimension(dayStr,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow4"))
	VisibleRect:relativePosition(daysLabel,cellBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-30,-10))
	item:addChild(daysLabel)	
	--奖励
	local itemBox = G_createItemShowByItemBox(reward.refId,reward.number,nil,nil,nil,-1 )
	VisibleRect:relativePosition(itemBox,cellBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(30,0))
	item:addChild(itemBox)	

	--状态
	local btSprite = createScale9SpriteWithFrameName(RES("btn_1_disable.png"))
	local btText = createSpriteWithFrameName(RES("word_button_receive.png"))

	local state = stateList[index]
	if state >=0 then
		if state == 1 then
			--hadReceivedLable			
			btSprite = createScale9SpriteWithFrameName(RES("hadReceivedLable.png"))
			btText = nil
		elseif state == 0 then	
			btSprite = createScale9SpriteWithFrameName(RES("btn_1_select.png"))
		elseif state == 2 then
--			btText = createSpriteWithFrameName(RES("word_button_receive.png"))
		end			
	end	

	local getBt = createButton(btSprite)
	if btText then
		getBt:setTitleString(btText)
	end	
	VisibleRect:relativePosition(getBt,cellBg,LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-20,-10))
	item:addChild(getBt)	
		
	local getFundRewardFunc = function()
		local fundMgr = GameWorld.Instance:getFundManager()			
		self.requestGetCellIndex = index
		fundMgr:requestGetFundReward(self.selectFundType,index)			
	end
	getBt:addTargetWithActionForControlEvents(getFundRewardFunc,CCControlEventTouchDown)		

	return item
end	

function FundView:createTableCell(index,fundType)
	local tableCell = SFTableViewCell:create()
	tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
	local item = self:createFundCell(index,fundType)
	tableCell:addChild(item)
	tableCell:setIndex(index)
	return tableCell
end

function FundView:createFundCell(index,key)
	local item = CCNode:create()
	item:setContentSize(cellSize)	
	
	local node1 = self:createItem(2*index+1,key)
	node1:setTag(1)
	item:addChild(node1)
	VisibleRect:relativePosition(node1, item, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(5,0))

	local node2 = self:createItem(2*(index +1),key)
	item:addChild(node2)
	node2:setTag(2)
	VisibleRect:relativePosition(node2, item, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-5,0))	
	item:setTag(CELL_TAG)
	return item		
end

function FundView:onEnter()
	self.selectedFundType = 1
	self:setAdText()
	self:TabPress(self.selectedFundType)
	if self.fundTypeTable then
		self.fundTypeTable :reloadData()
	end
end

function FundView:createFundTable(key)
		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedCell  = cell:getIndex()+1
		local item = cell:getChildByTag(CELL_TAG)	
		local count = item:getChildren():count()
		local touchPoint = ccp(x,y)		
		local childItem, rect
			
		for i = 1, count do 
			childItem = item:getChildByTag(i)		
			rect = childItem:boundingBox()
			if rect:containsPoint(touchPoint) then 	
				--选中框
				if(self.cellFrame:getParent() == nil) then
					childItem:addChild(self.cellFrame)				
					VisibleRect:relativePosition(self.cellFrame, childItem, LAYOUT_CENTER)
				else 
					self.cellFrame:removeFromParentAndCleanup(true)				
					childItem:addChild(self.cellFrame)					
					VisibleRect:relativePosition(self.cellFrame, childItem, LAYOUT_CENTER)
				end							
				self.curIndex = cell:getIndex()*2 + i
			end
		end			
		return 1								
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
			local cellList = self.tableCellList[key]
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createFundCell(index,key)
				tableCell:addChild(item)
				data:setCell(tableCell)
				tableCell:setIndex(index)
				cellList[index] = tableCell
			else
				if 	cellList[index] then
					data:setCell(cellList[index])
				else
					tableCell:removeAllChildrenWithCleanup(true)
					tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
					local item = self:createFundCell(index,key)
					tableCell:addChild(item)					
					tableCell:setIndex(index)					
					data:setCell(tableCell)	
					if not cellList then
						cellList = {}
					end
					cellList[index] = tableCell
				end	
			end																				
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(15)
			return 1
		end
	end			

	--创建tableview
	local fundTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(639, 320)))
	fundTable:reloadData()
	fundTable:setTableViewHandler(tableDelegate)
	fundTable:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(fundTable)		
	VisibleRect:relativePosition(fundTable, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-6, 25))
	return fundTable	
end

function FundView:getIndexState(index)
	local state = 1
	return state
end

function FundView:changeGetAwardCellState(state)
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local refId = rtwMgr:getAwardGetRefId()
	for k,v in pairs(self.awardList) do
		if v[refId] then
			v[refId] = state
		end
	end
end

function FundView:setAdText()		
	local priceType , price,worthPrice = G_getFundPrice(self.selectedFundType)
	local tipsStr = " "	
	if priceType == 2 then
		tipsStr = string.format(Config.Words[20015], price ,worthPrice)		
	elseif priceType == 1 then
		tipsStr = string.format(Config.Words[20019], price ,worthPrice)	
	end
	self.adText:setString(tipsStr)	
	VisibleRect:relativePosition(self.adText,self.adBgSpr,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(10,0))		
	local content = self:getFundContentDesc(self.selectedFundType)
	self.contentText:setString(content)
	VisibleRect:relativePosition(self.contentText,self.adBgSpr,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(10,0))		
end

function FundView:getFundContentDesc(fundType)
	if not fundType then
		fundType = 1
	end
	local refId = "item_gift_fund_" .. fundType
	local staticData = G_getStaticDataByRefId(refId)
	if  staticData and staticData.property then
		local descStr = PropertyDictionary:get_description(staticData.property)		
		local nameStr = PropertyDictionary:get_name(staticData.property)		
		local contentDescStr = string.format(Config.Words[20020],nameStr , descStr)
		return contentDescStr
	else
		return ""
	end	
end