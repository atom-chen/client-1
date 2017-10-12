require("ui.UIManager")

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local viewSize =  CCSizeMake(800, 480)
local tableSize = CCSizeMake(740, 370)
local cellSize = CCSizeMake(740, 125)
local halfCellSize = CCSizeMake(370, 121)

local kTablegrideSizeForIndex = 0
local kGrideSizeForTable = 1
local kTableCellAtIndex = 2
local kNumberOfCellsInTableView = 3	
local constResetDelay = 2
RechargeView = RechargeView or BaseClass(BaseUI)

function RechargeView:__init()
	self.viewName = "RechargeView"
	self:init(viewSize)
	local titleWords = createSpriteWithFrameName(RES("word_window_pay.png"))
	self:setFormTitle(titleWords, TitleAlign.Center)	
	self.rechargeList = GameWorld.Instance:getRechargeMgr():getRechargeList()	
	self.listSize = table.size(self.rechargeList)
	self.selectItem = -1
	self:initBg()
	--self:initButton()
	self:initTableView()
	
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"), halfCellSize)
	self.cellFrame:retain()
	self.hasRequest = false
end

function RechargeView:__delete()
	self.isShowing = false
	self.cellFrame:release()
	self:unregistResetSchedule()
end

function RechargeView:onEnter()
	self.isShowing = true
	self.selectItem = -1
	GameWorld.Instance:getRechargeMgr():requestFirstTopupList()
	self:updateWithList()
	self:registResetSchedule()
end


function RechargeView:onExit()
	self:unregistResetSchedule()
	self.isShowing = false
end

function RechargeView:create()
	return RechargeView.New()
end

function RechargeView:registResetSchedule()
	local function resetHasRequestState()
		self.hasRequest = false
	end
	self.checkId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(resetHasRequestState, constResetDelay, false)	
end

function RechargeView:unregistResetSchedule()
	if self.checkId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.checkId)	
		self.checkId = nil
	end
end

function RechargeView:initBg()
	local contentSize = self:getContentNode():getContentSize()
	local secondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(contentSize.width, contentSize.height-20))
	self:addChild(secondBg)
	VisibleRect:relativePosition(secondBg, self:getContentNode(), LAYOUT_CENTER)
	
	local noteText = createLabelWithStringFontSizeColorAndDimension(Config.Words[25606], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self:addChild(noteText)
	VisibleRect:relativePosition(noteText, self:getContentNode(), LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_OUTSIDE, ccp(-60, -10))
end

--[[function RechargeView:initButton()
	local payButton = createButtonWithFramename(RES("btn_1_select.png"))
	local buttonText = createSpriteWithFrameName(RES("word_button_recharge.png"))
	payButton:setTitleString(buttonText)
	self:addChild(payButton)
	VisibleRect:relativePosition(payButton, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(100, 0))
	
	payButton:addTargetWithActionForControlEvents(chargeFunc,CCControlEventTouchDown)
end--]]

function RechargeView:isSingle(index)
	if self.listSize%2 == 0 then
		return false
	end
	if (index+1)*2 > self.listSize then
		return true
	else
		return false
	end
end

function RechargeView:createNode(index)
	local data = self:getDataByIndex(index)
	local node = CCNode:create()
	node:setContentSize(halfCellSize)
	
	local nodeBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), halfCellSize)
	node:addChild(nodeBg)
	VisibleRect:relativePosition(nodeBg, node, LAYOUT_CENTER)
	
	local textBg = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"), CCSizeMake(halfCellSize.width-2, 30), ccp(1, 0))
	node:addChild(textBg)
	VisibleRect:relativePosition(textBg, node, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -12))
	
	--local itemIcon = string.sub(itemRefId, 6)	
	local itemBox = G_createItemShowByItemBox(data:getItemRefId(), nil,nil,nil,nil,-1)
	node:addChild(itemBox)
	VisibleRect:relativePosition(itemBox, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
		
	--[[local levelText = string.format(Config.Words[25605], level)
	local levelLabel = createLabelWithStringFontSizeColorAndDimension(levelText, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	node:addChild(levelLabel)
	VisibleRect:relativePosition(levelLabel, itemBox, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)--]]
	
	local yuanBaoIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))	
	node:addChild(yuanBaoIcon)
	VisibleRect:relativePosition(yuanBaoIcon, itemBox, LAYOUT_RIGHT_OUTSIDE,ccp(15, 0))
	VisibleRect:relativePosition(yuanBaoIcon, textBg, LAYOUT_CENTER_Y)
	
	local yuanbaoText = (data:getYuanBao()).. Config.Words[25602]
	local yuanbaoLabel = createLabelWithStringFontSizeColorAndDimension(yuanbaoText, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	node:addChild(yuanbaoLabel)
	VisibleRect:relativePosition(yuanbaoLabel, yuanBaoIcon, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(5, 0))	
	
	local moneyText = (data:getMoney()) .. Config.Words[25603]
	local moneyLabel = createLabelWithStringFontSizeColorAndDimension(moneyText, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	node:addChild(moneyLabel)
	VisibleRect:relativePosition(moneyLabel, textBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-25, 0))
	local showingReward,showType = data:getShowingReward()
	if showingReward > 0 then
		local firstWord = Config.Words[25604]
		if data:isFirstTopup() then
			firstWord = Config.Words[25607]
		end
				
		local rewardTextLabel = createLabelWithStringFontSizeColorAndDimension(firstWord, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		node:addChild(rewardTextLabel)
		VisibleRect:relativePosition(rewardTextLabel, node, LAYOUT_CENTER_Y, ccp(0, -10))
		VisibleRect:relativePosition(rewardTextLabel, itemBox, LAYOUT_RIGHT_OUTSIDE, ccp(15, 0))
		
		local rewardLabel = createLabelWithStringFontSizeColorAndDimension(showingReward, "Arial", FSIZE("Size3"), FCOLOR("ColorBlue1"))
		node:addChild(rewardLabel)
		VisibleRect:relativePosition(rewardLabel, rewardTextLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(2, 0))
		
		local rewardTips = Config.Words[25602]
		if showType == RewardType.bind then
			rewardTips = Config.Words[25608]
		end
		local yuanBaoLabel = createLabelWithStringFontSizeColorAndDimension(rewardTips, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		node:addChild(yuanBaoLabel)
		VisibleRect:relativePosition(yuanBaoLabel, rewardLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(2, 0))
	end
		
	return node
end

function RechargeView:getDataByIndex(index)
	return GameWorld.Instance:getRechargeMgr():getRechargeList()[index]
end

function RechargeView:createTableCell(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)	
	local node1 = self:createNode(index*2+1)
	item:addChild(node1)
	VisibleRect:relativePosition(node1, item, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
	
	if self:isSingle(index) == false then
		local node2 = self:createNode((index+1)*2)
		item:addChild(node2)
		VisibleRect:relativePosition(node2, item, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE)
	end	
	
	return item	
end

function RechargeView:initTableView()
	local dataHandler = function (eventType, tableP, index, data)	
		data = tolua.cast(data, "SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		if eventType == kTablegrideSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == kGrideSizeForTable then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == kTableCellAtIndex then	
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createTableCell(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index+1)
				local item = self:createTableCell(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
				if math.ceil(self.selectItem/2) == index+1 then
					self:setCellFrame(item, self.selectItem%2)
				end
			end
			return 1
		elseif eventType == kNumberOfCellsInTableView then	
			local listSize = self.listSize
			if(listSize) > 0 then
				data:setIndex(math.ceil(listSize/2))
				return 1
			else
				data:setIndex(0)
				return 1
			end
		end
	end
	
	local tableDelegate = function (tableP, cell, x, y)
		self:tableDelegate(tableP, cell, x, y)
	end
	
	self.tableView = createTableView(dataHandler, tableSize)
	self.tableView:setTableViewHandler(tableDelegate)
	self:addChild(self.tableView)
	self.tableView:reloadData()
	self.tableView:scroll2Cell(0, false)
	VisibleRect:relativePosition(self.tableView, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 18))	
end

function RechargeView:tableDelegate(tableP, cell, x, y)
	if self.hasRequest == true then
		return
	end		
	cell = tolua.cast(cell,"SFTableViewCell")				
	local cellIndex = cell:getIndex()	
	local index = 1
	if x < halfCellSize.width then
		index = 1
	else
		index = 2
	end		
	
	local rechargeObj = self:getDataByIndex((cellIndex-1)*2+index)
	if rechargeObj then
		local refid = rechargeObj:getRefId()
		local money  = rechargeObj:getMoney()	
		local productName = rechargeObj:getProductName()
		GameWorld.Instance:getRechargeMgr():openPayView(refid,productName,money, rechargeObj:getYuanBao(), rechargeObj:getReward())	
		self.hasRequest = true
		--Ñ¡ÖÐ¿ò
		local select_index = (cellIndex-1)*2+index
		if self.selectItem ~= select_index then
			self.selectItem = select_index
			self:setCellFrame(cell, index)
		end	
	end							
end

function RechargeView:setCellFrame(cell,index)
	if self.cellFrame:getParent() then
		self.cellFrame:removeFromParentAndCleanup(true)	
	end		
	cell:addChild(self.cellFrame)	
	if index==1 then
		VisibleRect:relativePosition(self.cellFrame, cell, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
	else
		VisibleRect:relativePosition(self.cellFrame, cell, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE)
	end	
end

function RechargeView:updateWithList()
	if GameWorld.Instance:getRechargeMgr():needToUpdateView() then	
		self.tableView:reloadData()
		GameWorld.Instance:getRechargeMgr():setNeedUpdate(false)
	end
end

function RechargeView:isShowingView()
	return self.isShowing
end

