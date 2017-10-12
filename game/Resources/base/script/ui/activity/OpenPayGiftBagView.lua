require("common.BaseUI")
require("object.bag.BagDef")
require("ui.utils.BatchItemView")

OpenPayGiftBagView = OpenPayGiftBagView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local grideSize = VisibleRect:getScaleSize(CCSizeMake(620*g_scale, 112*g_scale))
local width = 850*g_scale
local height = 374*g_scale

local const_pvr = "ui/ui_game/ui_game_bag.pvr"
local const_plist = "ui/ui_game/ui_game_bag.plist"

function OpenPayGiftBagView:__init()
	self.viewName = "OpenPayGiftBagView"
	self:init(CCSizeMake(width, height))
	self.selectedCell = 0
	--tableView数据源的类型
	self.eventType = {}
	self.eventType.kTablegrideSizeForIndex = 0
	self.eventType.kGrideSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	self.payActivityMgr = GameWorld.Instance:getPayActivityManager()
	self.payActivityList = self.payActivityMgr:getAwardTableList()
	self.tableViewCount = table.size(self.payActivityList)
	self.receiveSucceed = true --是否领取成功
	self.receiveBtn = {} --领取按钮
	self.haveReceive = {} --已领取图标
	self.itemViewList = {}	
			
	self:initStaticView()
	self:createTableView()
	self.background:setVisible(false)	
end

function OpenPayGiftBagView:__delete()
	self:clearItemView()
end

function OpenPayGiftBagView:initStaticView()
	--背景	
	self.payBgRight = CCSprite:create()
	self:addChild(self.payBgRight)
	VisibleRect:relativePosition(self.payBgRight, self:getContentNode(), LAYOUT_CENTER, ccp(268,-20))	
	self.payBgLeft = CCSprite:create()
	self.payBgLeft:setScaleX(-1)
	self:addChild(self.payBgLeft)
	VisibleRect:relativePosition(self.payBgLeft, self:getContentNode(), LAYOUT_CENTER, ccp(-100,-20))
	
--[[	local blackBg = createScale9SpriteWithFrameName(RES("payTableCellBg.png"))
	blackBg:setContentSize(CCSizeMake(546,99))
	self:addChild(blackBg)
	VisibleRect:relativePosition(blackBg, self:getContentNode(), LAYOUT_CENTER, ccp(10, 0))--]]
	-- 妹子
	self.girlPicture = CCSprite:create()
	self:addChild(self.girlPicture,50)
	VisibleRect:relativePosition(self.girlPicture, self:getContentNode(), LAYOUT_CENTER, ccp(-270,-5))
	-- 标题
	local titleText = createSpriteWithFrameName(RES("giftPayTitle.png"))
	self:addChild(titleText)
	VisibleRect:relativePosition(titleText, self:getContentNode(), LAYOUT_CENTER, ccp(60,180))
	
	--充值按钮	
	local payButton = createButtonWithFramename(RES("btn_normal1.png"), RES("btn_select1.png"))
	local payText = createSpriteWithFrameName(RES("payNowText.png"))
	self:addChild(payButton)
	payButton:setTitleString(payText)
	VisibleRect:relativePosition(payButton, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(85, -70))
	--充值回调
	local payFun = function ()
		local pay = function (tag, state)
			if tag == "pay" then 	
				if state == 1 then 
					CCLuaLog("success")			
				else
					CCLuaLog("fail")
				end
			end
		end
		local rechargeMgr = GameWorld.Instance:getRechargeMgr()
		rechargeMgr:openPay(pay)
	end
	payButton:addTargetWithActionForControlEvents(payFun,CCControlEventTouchDown)
	
	--注释Text
	self.noteText = createLabelWithStringFontSizeColorAndDimension(Config.Words[13738], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	self:addChild(self.noteText)
	VisibleRect:relativePosition(self.noteText, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-80, -35))
	
	self.payValue = createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self:addChild(self.payValue)
	VisibleRect:relativePosition(self.payValue, self.noteText, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE)
	
	self.yuanBao = createLabelWithStringFontSizeColorAndDimension(Config.Words[13737], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	self:addChild(self.yuanBao)
	VisibleRect:relativePosition(self.yuanBao, self.payValue, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	
	--半透明黑影图片
	local halfBackColor = CCLayerColor:create(ccc4(0, 0, 0, 200))
	halfBackColor:setContentSize(visibleSize)
	self:addChild(halfBackColor, -1)
	VisibleRect:relativePosition(halfBackColor, self:getContentNode(), LAYOUT_CENTER, ccp(0, 15))
end

function OpenPayGiftBagView:onEnter()
	self.tableView:scroll2Cell(0,false)
	local texture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/everyDayRechargeBg.pvr") 
	local pixelWidth = texture:getContentSizeInPixels().width
	local pixelHeight = texture:getContentSizeInPixels().height
	local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
	if self.payBgRight then
		self.payBgRight:setTexture(texture)
		self.payBgRight:setTextureRect(textRect)
	end
	if self.payBgLeft then
		self.payBgLeft:setTexture(texture)
		self.payBgLeft:setTextureRect(textRect)
	end
	local girlTexture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/giftGirl2.pvr")
	if self.girlPicture then
		self.girlPicture:setTexture(girlTexture)
		local pixelWidth = girlTexture:getContentSizeInPixels().width
		local pixelHeight = girlTexture:getContentSizeInPixels().height
		local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
		self.girlPicture:setTextureRect(textRect)
	end
end

function OpenPayGiftBagView:onExit()
	local texture = self.payBgRight:getTexture()
	if texture then
		self.payBgRight:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(texture)
	end
	local girlTexture = self.girlPicture:getTexture()
	if girlTexture then
		self.girlPicture:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(girlTexture)
	end	
	self:clearItemView()
end

function OpenPayGiftBagView:create()
	return OpenPayGiftBagView.New()
end

function OpenPayGiftBagView:createTableCell(index)
	local itemCell = CCNode:create()
	itemCell:setContentSize(grideSize)	
	
	local batchNode = SFSpriteBatchNode:create(const_pvr, 100)
	batchNode:setContentSize(grideSize)
	itemCell:addChild(batchNode, 1)
	VisibleRect:relativePosition(batchNode, itemCell, LAYOUT_CENTER)
	--BG
	local cellBg = createScale9SpriteWithFrameName(RES("payTableCellBg.png")--[[, CCRectMake(0,0,10,99)--]])
	cellBg:setContentSize(grideSize)
	VisibleRect:relativePosition(cellBg, itemCell, LAYOUT_CENTER, ccp(10, 0))			
	itemCell:addChild(cellBg)	
	--文字描写TODO 	
	local tableObj = self.payActivityList[tostring(index+1)]
	local needPay = tableObj.condValue	
	local numberText = createLabelWithStringFontSizeColorAndDimension(needPay, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	local staticTextFirst = createLabelWithStringFontSizeColorAndDimension(Config.Words[13702], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	local staticTextSecond = createLabelWithStringFontSizeColorAndDimension(Config.Words[13703], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	cellBg:addChild(staticTextFirst)
	staticTextFirst:addChild(numberText)
	numberText:addChild(staticTextSecond)
	VisibleRect:relativePosition(staticTextFirst, cellBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(60, -5))
	VisibleRect:relativePosition(numberText, staticTextFirst, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)
	VisibleRect:relativePosition(staticTextSecond, numberText, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)	
	--所有物品
	local itemList = tableObj.itemList
	--领取物品品质背景，物品，数量
	local itemRefId, qualityBg	
	--local itemIcon, itemNumLabel, bindSprite	
	local key = 0
	local itemTable = {}
	for i, item in pairs(itemList) do
		itemRefId = item["refId"]	
		--[[if G_getIsUnPropsItem(itemRefId) then
			qualityBg =G_createUnPropsItemBox(itemRefId)
		else			
			qualityBg = G_createItemBoxByRefId(itemRefId)
		end			
		cellBg:addChild(qualityBg)		
		VisibleRect:relativePosition(qualityBg, cellBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp((key - 1)*90+110, 10))--]]
		
		--ItemView 
		local itemObj = ItemObject.New()
		itemObj:setRefId(itemRefId)	
		PropertyDictionary:set_bindStatus(itemObj:getPT(),item.bind)	
		PropertyDictionary:set_number(itemObj:getPT(), item.number)	
		local itemView = BatchItemView.New()
		itemView:setItem(itemObj)	
		itemView:showNum(item.number)	
		--[[itemView:showTextWithNum(true, item.number)		
		if item.bind == 1 then
			itemView:showBindIcon(true)
		end--]]	

		itemView:setParent(batchNode, batchNode)	
		itemView:layoutNormalRootNode(batchNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp((key - 1)*90+160, -4))	
		itemView:layoutBatchRootNode(batchNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp((key - 1)*90+160, -4))
										
		table.insert(itemTable, itemView)
		itemObj:DeleteMe()
		key = key + 1
	end	
	
	self.itemViewList[index] = itemTable	
	--按钮			
	self.receiveBtn[index+1] = createButtonWithFramename(RES("btn_3_select.png"))
	self.haveReceive[index+1] = createSpriteWithFrameName(RES("hadReceivedLable.png"))
	self.haveReceive[index+1]:setRotation(-30)	
	itemCell:addChild(self.receiveBtn[index+1])
	itemCell:addChild(self.haveReceive[index+1])	
	VisibleRect:relativePosition(self.receiveBtn[index+1], itemCell, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-30, 0))
	VisibleRect:relativePosition(self.haveReceive[index+1], itemCell,LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-18, 0))
	local getText = createSpriteWithFrameName(RES("receiveGiftText.png"))	
	self.receiveBtn[index+1]:setTitleString(getText)		
	self.haveReceive[index+1]:setVisible(false)
	--领取按钮回调
	local receiveFun = function ()						
		local stage = tableObj["stage"]		
		self.payActivityMgr:requestGiftReceiveEvent(stage)
		self.payActivityMgr:setPayReceiveIndex(index+1)													
	end		
	self.receiveBtn[index+1]:addTargetWithActionForControlEvents(receiveFun, CCControlEventTouchDown)
			
	local status = tableObj.status						
	if status == 0 then --不能领取	
		self.receiveBtn[index+1]:setVisible(false)		
	elseif status == 1 then --已领取
		if self.receiveBtn[index+1] then
			self.receiveBtn[index+1]:removeFromParentAndCleanup(true)
		end					
		self.haveReceive[index+1]:setVisible(true)	
	elseif status == 2 then --可领取,未领取
		self.receiveBtn[index+1]:setVisible(true)						
	end		
	
	return itemCell
end

function OpenPayGiftBagView:receiveGiftBag(index)
	local tableObj = self.payActivityList[tostring(index)]
	local stage = tableObj["stage"]		
	self.payActivityMgr:requestGiftReceiveEvent(stage)
	self.payActivityMgr:requestCanReceiveActivityList()		
	self.payActivityMgr:requestCanReceiveActivityList()	
			
	self.receiveBtn[index]:setVisible(false)		
	self.haveReceive[index]:setVisible(true)
	tableObj.status = 1		
end

function OpenPayGiftBagView:createTableView()
	local dataHandler = function(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")					
		if eventType == self.eventType.kTablegrideSizeForIndex then
			data:setSize(grideSize)
			return 1
		elseif eventType == self.eventType.kGrideSizeForTable then
			data:setSize(grideSize)
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then	
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(grideSize)
				local item = self:createTableCell(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(grideSize)
				tableCell:setIndex(index+1)
				local item = self:createTableCell(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			if(self.tableViewCount) > 0 then
				data:setIndex(self.tableViewCount)
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
	
	local tableSize = VisibleRect:getScaleSize(CCSizeMake(620, 98*3))
	self.tableView = createTableView(dataHandler, tableSize)
	self.tableView:setTableViewHandler(tableDelegate)
	self:addChild(self.tableView)
	self.tableView:reloadData()
	self.tableView:scroll2Cell(0, false)
	VisibleRect:relativePosition(self.tableView, self:getContentNode(), LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE, ccp(-20, -5))
end

function OpenPayGiftBagView:tableDelegate(tableP, cell, x, y)
	cell = tolua.cast(cell, "SFTableViewCell")
	local cellIndex = cell:getIndex()
	self.selectedCell = cellIndex -1	
	local point = ccp(x, y)
	if type(self.itemViewList[self.selectedCell]) ~= "table" then
		return 0
	end
	for key,item in pairs(self.itemViewList[self.selectedCell]) do
		local itemNode = item:getRootNode()
		if itemNode then
			if itemNode:boundingBox():containsPoint(point) then				
				local itemObj = item:getItem()
				local refId = itemObj:getRefId()
				if itemObj and not G_getIsUnPropsItem(refId) then
					G_clickItemEvent(itemObj)
				end
				return 1
			end
		end
	end
	return 0	
end

function OpenPayGiftBagView:updateCell()
	self.tableView:updateCellAtIndex(self.selectedCell)
end


function OpenPayGiftBagView:updateView()
	self.payActivityList = self.payActivityMgr:getAwardTableList()
	self.tableViewCount = table.size(self.payActivityList)
	
	self:clearItemView()
	self.tableView:reloadData()
	local currentValue = self.payActivityMgr:getCurrentValue()
	if currentValue then
		self.payValue:setString(currentValue)
		VisibleRect:relativePosition(self.payValue, self.noteText, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE)
		VisibleRect:relativePosition(self.yuanBao, self.payValue, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	end	
end

function OpenPayGiftBagView:clearItemView()
	local ItemViewRootNode
	for key,itemList in pairs(self.itemViewList) do
		for key1, item in pairs(itemList) do
			ItemViewRootNode = item:getRootNode()
			if ItemViewRootNode and ItemViewRootNode:getParent() then
				ItemViewRootNode:removeFromParentAndCleanup(true)
			end
			item:DeleteMe()
		end			
	end
	self.itemViewList = {}
end