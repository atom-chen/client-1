-- 显示背包的详情
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("object.equip.EquipDef")

BaseItemDetailView = BaseItemDetailView or BaseClass(BaseUI)

--local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(306, 478)
local const_scrollViewSize = CCSizeMake(280, 151)
local const_maxAuctionPrice = 999999
local const_minAuctionPrice = 1

function BaseItemDetailView:create()
	return BaseItemDetailView.New()
end

function BaseItemDetailView:__init()	
	self:initWithBg(const_size, RES("squares_bag_bg.png"), true, false)	
	self.auctionDefaultPriceEventId = nil
	self:initBgNode()	
			
	self.btnArray  = 
	{
		[E_ItemDetailBtnType.eSell]   		=	{text =  "word_button_sell.png", 	onClick = self.sellItem,	obj = nil},	
		[E_ItemDetailBtnType.eShow]			=  	{text =  "word_button_display.png", onClick = self.displayItem, obj = nil},
		[E_ItemDetailBtnType.ePutOn]		= 	{text =  "word_button_puton.png", 	onClick = self.putOnEquip,	obj = nil},
		[E_ItemDetailBtnType.eUse]			= 	{text =  "word_button_use.png", 	onClick = self.useItem,	  	obj = nil},		
		[E_ItemDetailBtnType.eUnload]   	=	{text =  "word_button_unload.png", 	onClick = self.unLoadEquip,	obj = nil},
		[E_ItemDetailBtnType.eBuy]  		=	{text =  "word_button_buy.png", 	onClick = self.BuyEquip,	obj = nil},		
		[E_ItemDetailBtnType.eCancelSell]  	=	{text =  "word_button_cancel.png", 	onClick = self.cancelSell,	obj = nil},		
				
		[E_ItemDetailBtnType.eAuctionSell]  		=	{text =  "word_Sell.png", 	onClick = self.onAuctionSell,	obj = nil},		
		[E_ItemDetailBtnType.eAuctionCancelSell]  	=	{text =  "word_CancelSell.png", 	onClick = self.onAuctionCancelSell,	obj = nil},		
		[E_ItemDetailBtnType.eAuctionBuy]  			=	{text =  "word_Buy.png", 	onClick = self.onAuctionBuy,	obj = nil},		
		[E_ItemDetailBtnType.eGetOut]             	=	{text =	 "word_button_remove.png", onClick = self.onGetOut, obj = nil},
		[E_ItemDetailBtnType.eDetail]				= 	{text =  "word_button_detail.png", onClick = self.onDetail, obj = nil},
	}
	self:initBtn()	
end		

--------------以下为私有接口-------------------
function BaseItemDetailView:__delete()
	if self.itemView then
		self.itemView:DeleteMe()
		self.itemView = nil
	end
end	

function BaseItemDetailView:initBgNode()
	local frame = createScale9SpriteWithFrameNameAndSize(RES("squares_bag_frame.png"), const_size)	
	self.rootNode:addChild(frame)
	VisibleRect:relativePosition(frame, self.rootNode, LAYOUT_CENTER)
end

function BaseItemDetailView:setTitleTips(tips)
	if (type(tips) == "string" and tips ~= "") then
		self.titleTips = createStyleTextLable(tips, "EquipTitle")
		self:setFormTitle(self.titleTips, TitleAlign.Center)
	end
end

function BaseItemDetailView:showIcon(bShowFpTips)
	if bShowFpTips == nil then
		bShowFpTips = true
	end
	if (self.itemView == nil) then
		self.itemView = ItemView.New(CCSizeMake(64, 64))
		self:addChild(self.itemView:getRootNode())
	end	
	if (self.item) then
		self.itemView:setItem(self.item)
		self.itemView:showBindStatus(true)				
		
		if (bShowFpTips and self.item:getType() and self.item:getType() == ItemType.eItemEquip ) then
			G_showTipIcon(self.item,self.itemView)
			self.itemView:showText(true)--tudo
		else
			self.itemView:showTipIcon(nil)
		end
	end		
	VisibleRect:relativePosition(self.itemView:getRootNode(), self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(10, 0))	
end	

function BaseItemDetailView:showName()
	if (self.nameLabel) then
		self:getContentNode():removeChild(self.nameLabel, true)
		self.nameLabel = nil
	end
			
	if (self.item and self.item:getStaticData()) then	
		local color = G_getColorByItem(self.item)
		local name = PropertyDictionary:get_name(self.item:getStaticData().property)
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale, color)		
	else
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension("       ", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow7"))	
	end
	self:addChild(self.nameLabel)		
	VisibleRect:relativePosition(self.nameLabel, self.itemView:getRootNode(), LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(15, 5))
end	

function BaseItemDetailView:showBindState()
	if (self.bindStateSprite ~= nil) then
		self:getContentNode():removeChild(self.bindStateSprite, true)
		self.bindStateSprite = nil
	end		
	
	local bind = -1
	local bindType = 0
	if (self.item and self.item:getStaticData()) then
		bind = PropertyDictionary:get_bindStatus(self.item:getPT())
	end
	
	local color 
	if bind >= 0 then
		if (bind == 1) then--绑定
			self.bindStateSprite = createSpriteWithFrameName(RES("bag_binding.png"))
		else 			--未绑定
			if (self.item and self.item:getStaticData()) then
				bindType = PropertyDictionary:get_bindType(self.item:getStaticData().property)
				if bindType == 0 then  --永不绑定
					self.bindStateSprite = createSpriteWithFrameName(RES("bag_neverBinding.png"))		
				elseif bindType == 1 then --拾取绑定
					self.bindStateSprite = createSpriteWithFrameName(RES("bag_pickupBinding.png"))
					self.bindStateSprite:setScale(0.8)
				else --装备绑定
					self.bindStateSprite = createSpriteWithFrameName(RES("bag-equip.png"))
					self.bindStateSprite:setScale(0.8)
				end
			else
				self.bindStateSprite = createSpriteWithFrameName(RES("bag_neverBinding.png"))
			end	
		end			
	end
	if (self.bindStateSprite ~= nil) then	
		self.bindStateSprite:setRotation(-30)
		self:addChild(self.bindStateSprite, 100)			
		VisibleRect:relativePosition(self.bindStateSprite, self.nameLabel, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(86, 11))		
	end
end

function BaseItemDetailView:showLevel()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if type(hero:getPT())== "table" then	
		local heroLevel = PropertyDictionary:get_level(hero:getPT())
		if (self.levelLabel == nil) then
			self.levelLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorOrange1"))		
			self:addChild(self.levelLabel)		
		end		
		
		local name = " " 
		if (self.item ~= nil and self.item:getStaticData()) then
			local level
			if self.item:getType() == ItemType.eItemEquip then
				level = PropertyDictionary:get_equipLevel(self.item:getStaticData().property)
			else
				level = PropertyDictionary:get_useLevel(self.item:getStaticData().property)		
			end
			name = string.format("%d%s",  level, Config.Words[10063])						
			
			if level and heroLevel < level then
				self.levelLabel:setColor(FCOLOR("ColorRed1"))
			else
				self.levelLabel:setColor(FCOLOR("ColorOrange1"))
			end
		end	
		self.levelLabel:setString(name)	
		self.levelLabel:setPosition(ccp(0, 0))	
		VisibleRect:relativePosition(self.levelLabel, self.itemView:getRootNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_OUTSIDE, ccp(15, -5))
	end
end

function BaseItemDetailView:showInputAuctionPrice(bShow, price)
	if bShow then
		if (self.inputAuctionPriceLabel == nil)  then	
			self.inputAuctionPriceLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25320] ,"Arial",FSIZE("Size3"), FCOLOR("ColorYellow1"))				
			self:addChild(self.inputAuctionPriceLabel)
			VisibleRect:relativePosition(self.inputAuctionPriceLabel, self.lineDown, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(20, -35))		
			
			self.inputAuctionPriceEditBox = createEditBoxWithSizeAndBackground(CCSizeMake(130, 30), RES("commom_editFrame.png"))	
			self.inputAuctionPriceEditBox:setMaxLength(20)	
			self.inputAuctionPriceEditBox:setFontSize(FSIZE("Size3"))
			self.inputAuctionPriceEditBox:setFontColor(FCOLOR("ColorYellow1"))
			self.inputAuctionPriceEditBox:setInputMode(kEditBoxInputModeNumeric)	--只支持数字
			self.inputAuctionPriceLabel:addChild(self.inputAuctionPriceEditBox)	
			
			local unbindedGoldIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))	
			self.inputAuctionPriceLabel:addChild(unbindedGoldIcon)
			VisibleRect:relativePosition(self.inputAuctionPriceEditBox, self.inputAuctionPriceLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
			VisibleRect:relativePosition(unbindedGoldIcon, self.inputAuctionPriceEditBox, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(0, 0))			
			
			local function editboxEventHandler(eventType)	
				if eventType == "began" then			
				elseif eventType == "ended" then			
				elseif eventType == "changed" then							
				elseif eventType == "return" or eventType == "changed" then	
					local price = tonumber(self.inputAuctionPriceEditBox:getText())				
--					UIManager.Instance:showSystemTips("price="..price)
					if price and price > const_maxAuctionPrice or price < const_minAuctionPrice then
						UIManager.Instance:showSystemTips(Config.Words[25322])	
						G_getAuctionMgr():requestDefaultPrice(self.item:getId(), self:getSellNumber())	
					end
				end
			end
			self.inputAuctionPriceEditBox:registerScriptEditBoxHandler(editboxEventHandler)
		end		
		if price then	
			self.inputAuctionPriceEditBox:setText(tostring(price))						
		else
			self.inputAuctionPriceEditBox:setText(self:getSellNumber() * PropertyDictionary:get_number(self.item:getPT()))
		end
	end
	if self.inputAuctionPriceLabel then
		self.inputAuctionPriceLabel:setVisible(bShow)
	end	
end

function BaseItemDetailView:getSellNumber()
	local number 
	if self.inputAuctionSellNumberEditBox then
		local sellNum = tonumber(self.inputAuctionSellNumberEditBox:getText())
		if sellNum then
			number = math.ceil(sellNum)
		end
	else
		number = PropertyDictionary:get_number(self.item:getPT())
	end
	if  number == nil then
		number = 0
	end
	return number
end	
	
function BaseItemDetailView:showInputAuctionSellNumber(bShow)		
	if bShow then
		if (self.inputAuctionSellNumberLabel == nil)  then	
			self.inputAuctionSellNumberLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25321] ,"Arial",FSIZE("Size3"), FCOLOR("ColorYellow1"))				
			self:addChild(self.inputAuctionSellNumberLabel)
			VisibleRect:relativePosition(self.inputAuctionSellNumberLabel, self.lineDown, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(20, -5))		
			
			self.inputAuctionSellNumberEditBox = createEditBoxWithSizeAndBackground(CCSizeMake(130, 30), RES("commom_editFrame.png"))	
			self.inputAuctionSellNumberEditBox:setMaxLength(20)	
			self.inputAuctionSellNumberEditBox:setFontSize(FSIZE("Size3"))
			self.inputAuctionSellNumberEditBox:setFontColor(FCOLOR("ColorYellow1"))
			self.inputAuctionSellNumberEditBox:setInputMode(kEditBoxInputModeNumeric)	--只支持数字
			self.inputAuctionSellNumberLabel:addChild(self.inputAuctionSellNumberEditBox)	
		
			VisibleRect:relativePosition(self.inputAuctionSellNumberEditBox, self.inputAuctionSellNumberLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
			local function editboxEventHandler(eventType)	
				if eventType == "began" then			
				elseif eventType == "ended" then			
				elseif eventType == "changed" then							
				elseif eventType == "return" or eventType == "changed" then	
					local num = self:getSellNumber()			
--					UIManager.Instance:showSystemTips("num="..num)
					if num > PropertyDictionary:get_number(self.item:getPT()) or num <= 0 then
						UIManager.Instance:showSystemTips(string.format(Config.Words[25331], PropertyDictionary:get_number(self.item:getPT())))	
						self.inputAuctionSellNumberEditBox:setText(tostring(PropertyDictionary:get_number(self.item:getPT())))
					else
						G_getAuctionMgr():requestDefaultPrice(self.item:getId(), self:getSellNumber())
					end
				end
			end
			self.inputAuctionSellNumberEditBox:registerScriptEditBoxHandler(editboxEventHandler)
		end
		self.inputAuctionSellNumberEditBox:setText(tostring(PropertyDictionary:get_number(self.item:getPT())))		
	end
	if self.inputAuctionSellNumberLabel then
		self.inputAuctionSellNumberLabel:setVisible(bShow)
	end	
end

function BaseItemDetailView:getScrollViewSize()
	return const_scrollViewSize
end

function BaseItemDetailView:getScrollView()
	return self.scrollView
end

function BaseItemDetailView:setScrollNode(node)
	self.scrollView:setContainer(node)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(0, -node:getContentSize().height + const_scrollViewSize.height), false)
end	


function BaseItemDetailView:initScrollView()
	local lineUp = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_scrollViewSize.width, 2))
	self:addChild(lineUp)
	VisibleRect:relativePosition(lineUp, self.itemView:getRootNode(), LAYOUT_BOTTOM_OUTSIDE, ccp(0, -20))	
	VisibleRect:relativePosition(lineUp, self:getContentNode(), LAYOUT_CENTER_X)
	
	self.scrollView =createScrollViewWithSize(const_scrollViewSize)
	self.scrollView:setViewSize(const_scrollViewSize)
	self.scrollView:setDirection(2) --垂直滑动
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, lineUp, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))	
	
	self.lineDown = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_scrollViewSize.width, 2))
	self:addChild(self.lineDown)
	VisibleRect:relativePosition(self.lineDown, self.scrollView, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
end		

function BaseItemDetailView:removePrice()
	if self.buyPriceNode then
		self.buyPriceNode:removeFromParentAndCleanup(true)
		self.buyPriceNode = nil
	end	
	if self.auctionPriceNode then
		self.auctionPriceNode:removeFromParentAndCleanup(true)
		self.auctionPriceNode = nil		
	end	
	if self.sellPriceNode then
		self.sellPriceNode:removeFromParentAndCleanup(true)	
		self.sellPriceNode = nil	
	end			
end	

function BaseItemDetailView:showBuyPrice()
	local iconStr
	local secondIconStr
	local price	
	if not self.buyPriceNode then
		self.buyPriceNode = CCNode:create()
		self.buyPriceNode:setContentSize(CCSizeMake(300,30))
		self:addChild(self.buyPriceNode)
		VisibleRect:relativePosition(self.buyPriceNode,self.scrollView, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -85))
	end
	self.buyPriceNode:setVisible(true)
	local mallMgr = GameWorld.Instance:getMallManager()
	local bObj = mallMgr:getBuyObj()
	if(bObj == nil ) then	
		return 
	end
		
	local priceTable = {}
	if table.size(bObj:getObjPriceType()) > 0 then
		priceTable  =bObj:getObjPriceType()	
	end	
	
	local size = table.size(priceTable)	
	
	local iconStr = "item_gold"
	local scale  = 1
	local priceList = {}
	local iconList = {}
	index = 1
	for k ,value in pairs(priceTable) do
		iconStr = PriceIcon[k].icon
		scale = PriceIcon[k].scale
		priceList[index] = value
		iconList[index] = iconStr
		index = index + 1
	end		
	self.singlePrice = priceList[1]
	self.secondPrice = priceList[2]
	
	local coinSprite = createSpriteWithFileName(ICON(iconList[1]))
	coinSprite:setScale(scale)
	VisibleRect:relativePosition(coinSprite,self.buyPriceNode,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(20, 15))			
	self.buyPriceNode:addChild(coinSprite,1,100)			
	local priceLabel = createLabelWithStringFontSizeColorAndDimension(self.singlePrice ,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	priceLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(priceLabel,self.buyPriceNode,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(50, 15))										
	self.buyPriceNode:addChild(priceLabel,1,400)	
	if self.secondPrice then
		local secCoinSprite = createSpriteWithFileName(ICON(iconList[2]))
		VisibleRect:relativePosition(secCoinSprite,self.buyPriceNode,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(15, -27))			
		self.buyPriceNode:addChild(secCoinSprite,1,200)	
		self.secPriceLabel = createLabelWithStringFontSizeColorAndDimension(self.secondPrice ,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
		self.secPriceLabel:setAnchorPoint(ccp(0,0.5))
		VisibleRect:relativePosition(self.secPriceLabel,self.buyPriceNode,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(50, -25))	
		self.buyPriceNode:addChild(self.secPriceLabel,1,500)				
	end								
end		

function BaseItemDetailView:showSellPrice()
	if (self.sellPriceNode == nil)  then	
		self.sellPriceNode = createSpriteWithFrameName(RES("world_label_sellprice.png"))		
		self.sellPriceValue = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow1"))
		self.sellPriceValue:setAnchorPoint(ccp(0,0.5))

		self:addChild(self.sellPriceNode) 
		self.sellPriceNode:addChild(self.sellPriceValue) 	
	end
	if (self.item and self.item:getStaticData()) then
		self.sellPriceValue:setString(PropertyDictionary:get_salePrice(self.item:getStaticData().property))			
	end
	self.sellPriceNode:setVisible(PropertyDictionary:get_isCanSale(self.item:getStaticData().property) == 1) 	
	VisibleRect:relativePosition(self.sellPriceNode, self.scrollView, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(5, -10))		
	VisibleRect:relativePosition(self.sellPriceValue, self.sellPriceNode, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
end		

function BaseItemDetailView:showAuctinPrice()
	if (self.auctionPriceNode == nil)  then	
		self.auctionPriceNode = createSpriteWithFrameName(RES("world_label_sellprice.png"))		
		self.auctionPriceValue = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow1"))				
		self.auctionPriceIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))		
		
		self:addChild(self.auctionPriceNode) 
		self.auctionPriceNode:addChild(self.auctionPriceValue) 	
		self.auctionPriceNode:addChild(self.auctionPriceIcon) 	
	end
	if (self.item and self.item:getStaticData()) then
		self.auctionPriceValue:setString(self.item:getAuctionPrice())			
	end	
	self.auctionPriceNode:setVisible(true)		
	VisibleRect:relativePosition(self.auctionPriceNode, self.scrollView, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(5, -10))		
	VisibleRect:relativePosition(self.auctionPriceValue, self.auctionPriceNode, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
	VisibleRect:relativePosition(self.auctionPriceIcon, self.auctionPriceValue, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
end		

--------------以下为私有接口-------------------
function BaseItemDetailView:onEnter(arg)
	if (not arg:getItem()) or (not arg:getItem():getStaticData()) then
		return
	end
	
	local onEventAuctionDefaultPrice = function(id, price)
		if self.item and self.item:getId() == id then
--			self.item:setAuctionPrice(math.ceil(price / self:getSellNumber()))
			self:showInputAuctionPrice(true, price)	
--			print("BaseItemDetailView:onEnter update AuctionPrice price="..price)		
		end
	end
	self.auctionDefaultPriceEventId = GlobalEventSystem:Bind(GameEvent.EventAuctionDefaultPrice, onEventAuctionDefaultPrice)
	
	--保存这个参数	
	self.itemDetailArg = arg
	
	--获取item
	self.item = arg:getItem()			
	
	--设置标题
	local tips = arg:getTitleTips()
	if (tips ~= nil and tips ~= "") then
		self:setTitleTips(tips)
	else
		self:setTitleTips(" ")
	end
	
	--设置是否显示关闭按钮
	self:setVisiableCloseBtn(not(arg:getIsShowCloseBtn() == false))		
	
	--设置ViewName
	local name = arg:getViewName()
	if (name ~= nil and name ~= "") then
		self:setViewName(name)		
	end
	
	--显示图标
	self:showIcon(arg:getIsShowFpTips())
	
	--显示名字
	self:showName()
	
	--显示绑定
	self:showBindState()
	
	--显示等级
	self:showLevel()	
	if (self.scrollView == nil) then
		self:initScrollView()
	end	
	
	--显示价格
	self:removePrice()
	if arg:getShowPriceType() == E_EquipShowPriceType.buyPrice  then
		self:showBuyPrice()			
	elseif arg:getShowPriceType() == E_EquipShowPriceType.auctionPrice then 
		self:showAuctinPrice()
	elseif arg:getShowPriceType() == E_EquipShowPriceType.sellPrice then  
		self:showSellPrice()
	end				
	
	--显示拍卖价格输入框
	self:showInputAuctionPrice(arg:getIsShowAuctionPrice())			
	
	--显示拍卖出售数量
	self:showInputAuctionSellNumber(arg:getIsShowAuctionNumber())			
			
	--显示按钮
	local btns = arg:getBtnArray()
	self:setActiveBtns(btns)
		
	if (self.onUpdataItem) then
		self:onUpdataItem()
	end
end

function BaseItemDetailView:onExit()
	if self.auctionDefaultPriceEventId then
		GlobalEventSystem:UnBind(self.auctionDefaultPriceEventId)
		self.auctionDefaultPriceEventId = nil
	end
	
	GlobalEventSystem:Fire(GameEvent.EventHidePutOnEquipItemDetailView)
	--GlobalEventSystem:Fire(GameEvent.EventHideEquipItemDetailView)
	GlobalEventSystem:Fire(GameEvent.EventHideNormalItemDetailView)	
	GlobalEventSystem:Fire(GameEvent.EventCloseEquipDetailPropertyView)
	self.singlePrice = nil
	self.secondPrice = nil
	self.curBodyAreaPos = nil
end

-- 显示功能按键
function BaseItemDetailView:initBtn()
	for index, value in ipairs(self.btnArray) do
		value.obj = createButtonWithFramename(RES("btn_1_select.png"))					
		value.label = createSpriteWithFrameName(RES(value.text))
		value.obj:setVisible(false)	
		value.label:setVisible(false)	
				
		self:addChild(value.obj)
		self:addChild(value.label)
		
		local onClick = function()	
			value.onClick(self, self.item)
		end
		value.obj:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)		
	end	
end

local const_marginOffset = -5 --按键左右偏移
function BaseItemDetailView:setActiveBtns(btns)	--显示按键，并居中布局
	for ttype, btn in pairs(self.btnArray) do
		self:setBtn(ttype, false, false)
	end 
	
	local btnCount = table.size(btns)	
	
	if btnCount == 1 then		
		VisibleRect:relativePosition(self.btnArray[btns[1]].obj, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(0, -10))
		self:setBtn(btns[1], true, true)
		VisibleRect:relativePosition(self.btnArray[btns[1]].label, self.btnArray[btns[1]].obj, LAYOUT_CENTER)
	elseif btnCount == 2 then		
		VisibleRect:relativePosition(self.btnArray[btns[1]].obj, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		VisibleRect:relativePosition(self.btnArray[btns[2]].obj, self:getContentNode(), LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		for i,ttype in ipairs(btns) do
			self:setBtn(ttype, true, true)	
			VisibleRect:relativePosition(self.btnArray[ttype].label, self.btnArray[ttype].obj, LAYOUT_CENTER)
		end
	elseif btnCount == 3 then		
		VisibleRect:relativePosition(self.btnArray[btns[1]].obj, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		VisibleRect:relativePosition(self.btnArray[btns[3]].obj, self:getContentNode(), LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		VisibleRect:relativePosition(self.btnArray[btns[2]].obj, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(0, 70))
		for i,ttype in ipairs(btns) do
			self:setBtn(ttype, true, true)	
			VisibleRect:relativePosition(self.btnArray[ttype].label, self.btnArray[ttype].obj, LAYOUT_CENTER)
		end
	elseif btnCount == 4 then
		VisibleRect:relativePosition(self.btnArray[btns[1]].obj, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		VisibleRect:relativePosition(self.btnArray[btns[3]].obj, self:getContentNode(), LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0, -10))
		VisibleRect:relativePosition(self.btnArray[btns[2]].obj, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(0, 70))
		VisibleRect:relativePosition(self.btnArray[btns[4]].obj, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(0, 70))
		for i,ttype in ipairs(btns) do
			self:setBtn(ttype, true, true)	
			VisibleRect:relativePosition(self.btnArray[ttype].label, self.btnArray[ttype].obj, LAYOUT_CENTER)
		end
	end

end

function BaseItemDetailView:setBtn(ttype, enable, visible)
	if (enable ~= nil) then
		self.btnArray[ttype].obj:setEnable(enable)
	end
	if (visible ~= nil) then
		self.btnArray[ttype].obj:setVisible(visible)
		self.btnArray[ttype].label:setVisible(visible)	
	end				
end		

-- 使用物品
function BaseItemDetailView:useItem(itemObj)
	if (itemObj == nil) then
		return
	end	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local ttype = itemObj:getType()
	local manager = UIManager.Instance	
	if ttype == ItemType.eItemSkillDrug then
		local btnOpenStatus = Config.MainMenu[MainMenu_Btn.Btn_skill].condition
		if btnOpenStatus == true then
			GlobalEventSystem:Fire(GameEvent.EventOpenSkillView)
		else
			UIManager.Instance:showSystemTips(Config.Words[603])
		end						
	elseif ttype == ItemType.eItemQianghuashi then
		local btnOpenStatus = Config.MainMenu[MainMenu_Btn.Btn_forge].condition
		if btnOpenStatus == true then
			GlobalEventSystem:Fire(GameEvent.EventOpenForgingView)
		else
			UIManager.Instance:showSystemTips(Config.Words[604])
		end							
	elseif ttype == ItemType.eItemJingYanDan then		
		local btnOpenStatus = Config.MainMenu[MainMenu_Btn.Btn_mount].condition
		if btnOpenStatus == true then
			GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen)
		else
			UIManager.Instance:showSystemTips(Config.Words[600])
		end
	elseif ttype == ItemType.eItemFeather then
		local btnOpenStatus = Config.MainMenu[MainMenu_Btn.Btn_wing].condition
		if btnOpenStatus == true then
			GlobalEventSystem:Fire(GameEvent.EventOpenWingView)
		else
			UIManager.Instance:showSystemTips(Config.Words[601])	
		end		
	elseif ttype == ItemType.eItemFabaoSuipian then					
		local btnOpenStatus = Config.MainMenu[MainMenu_Btn.Btn_talisman].condition
		if btnOpenStatus == true then
			GlobalEventSystem:Fire(GameEvent.EventTalismanViewOpen)
		else
			UIManager.Instance:showSystemTips(Config.Words[602])
		end			
	elseif ttype == ItemType.eItemQianghuajuan then
		GlobalEventSystem:Fire(GameEvent.EventHideBag)
		GlobalEventSystem:Fire(GameEvent.EventOpenPutInEquipView, E_ShowOption.eMove2Left, {itemObj = nil, qianghuajuan = itemObj})
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipShowView, E_ShowOption.eMove2Right, itemObj)
	elseif ttype == ItemType.eItemChuansongshi then
		local operator = G_getBagMgr():getOperator()
		local ret = operator:checkCanUseNormalItem(itemObj) 
		if ret == false then
			return
		end
		local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
		questMgr:setNpcTalkViewInfo("npc_3", nil) 
		GlobalEventSystem:Fire(GameEvent.EventOpenTransfer,itemObj) 		
	elseif ttype == ItemType.eItemHuichengjuan or  ttype == ItemType.eItemSuijijuan then
		local operator = G_getBagMgr():getOperator()
		local ret = operator:checkCanUseNormalItem(itemObj) 
		if ret == false then
			return
		end
		operator:operateItem(E_OperateType.Use, itemObj)
		GameWorld.Instance:getNpcManager():cancelCollect()
		G_getHandupMgr():stop()						
	else
		local operator = G_getBagMgr():getOperator()
		if itemObj:getRefId() == "item_luck" or itemObj:getRefId() == "item_superluck" then	
			self:operateLuckUse(itemObj)			
		else
			operator:operateItem(E_OperateType.Use, itemObj)
		end			
	end
	self:close()
end

function BaseItemDetailView:operateLuckUse(itemObj)
	local operator = G_getBagMgr():getOperator()
	local equipList = G_getEquipMgr():getEquipList()
	if equipList then
		if equipList[E_BodyAreaId.eWeapon] and equipList[E_BodyAreaId.eWeapon][0]  then
			local tips = ""
			local equipWeaponBindStatus = PropertyDictionary:get_bindStatus(equipList[E_BodyAreaId.eWeapon][0]:getPT())
			local itemLuckBindStatus = PropertyDictionary:get_bindStatus(itemObj:getPT())
			if equipWeaponBindStatus == E_State_Bind and itemLuckBindStatus == E_State_UnBind then
				tips = Config.Words[10222]		
				self:showBindStatusMsgBoxByTips(tips,itemObj)		
			elseif equipWeaponBindStatus == E_State_UnBind and itemLuckBindStatus == E_State_Bind then
				tips = Config.Words[10219]	
				self:showBindStatusMsgBoxByTips(tips,itemObj)		
			else
				operator:operateItem(E_OperateType.Use, itemObj)
			end		
		else
			operator:operateItem(E_OperateType.Use, itemObj)
		end
	end
end



function BaseItemDetailView:showBindStatusMsgBoxByTips(tips,itemObj)
	local isUseBindFirst = function(arg,text,id)
		if id == 1 then
			return
		elseif id == 2 then
			local operator = G_getBagMgr():getOperator()
			operator:operateItem(E_OperateType.Use, itemObj)
		end
	end			
	if tips ~= "" then								
		local msgBox = showMsgBox(tips,3)		
		msgBox:setNotify(isUseBindFirst)
	end
end

--展示物品
function BaseItemDetailView:displayItem(itemObj)
	if (itemObj == nil) then
		return
	end
 	UIManager.Instance:showSystemTips(Config.Words[10151])
	GlobalEventSystem:Fire(GameEvent.EventShowItem, itemObj)
	self:close()
end	

--出卖物品
function BaseItemDetailView:sellItem(itemObj)
	if (itemObj == nil) then
		return
	end
	local operator = G_getBagMgr():getOperator()			
	operator:operateItem(E_OperateType.Sell, itemObj)
	self:close()
end

-- 穿戴装备
function BaseItemDetailView:putOnEquip(equipObj)
	if (equipObj == nil) then
		return
	end	
	self:close()

	local putonPos = G_getEquipMgr():getPutonPos()
	local operator = G_getBagMgr():getOperator()				
	if type(putonPos) == "number" then
		operator:putOnEquip(equipObj, putonPos)	
		G_getEquipMgr():setPutonPos(nil)	
	else
		operator:operateItem(E_OperateType.PutOn, equipObj)
	end
end		
	
--卸下装别
function BaseItemDetailView:unLoadEquip(equipObj)
	if (equipObj == nil) then
		return
	end
	self:close()
	local operator = G_getBagMgr():getOperator()			
	operator:operateItem(E_OperateType.UnLoad, equipObj)
end		
	
--购买装备
function BaseItemDetailView:BuyEquip()
	self:close()		
	local mallMgr = GameWorld.Instance:getMallManager()
	local npcMgr = GameWorld.Instance:getNpcManager()
	local npcId = npcMgr:getTouchNpcRefId()
	local obj = mallMgr:getTempBuyObj()
	if(obj) then	
		mallMgr:requestBuyItem(obj:getStoreType(),obj:getRefId(),1,npcId)
	end
end

--撤销快速购买
function BaseItemDetailView:cancelSell()
	local view = UIManager.Instance:getViewByName("BatchSellView")
	if view then
		view:removeItem(self.item)
	end
	
	local bag = UIManager.Instance:getViewByName("BagView")
	if bag then
		bag:moveItemBackFromSale(self.item)
	end
	self:close()
end

function BaseItemDetailView:onAuctionSell()
	if self.item and self.inputAuctionPriceEditBox then
		G_getAuctionMgr():requestDoSell(self.item:getId(), self:getSellNumber(), tonumber(self.inputAuctionPriceEditBox:getText()))
	end
	self:close()
end

function BaseItemDetailView:onAuctionCancelSell()
	if self.item then
		G_getAuctionMgr():requestCancelSell(self.item:getId())
	end
	self:close()
end

function BaseItemDetailView:onGetOut()
	if self.item then
		local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
		warehouseMgr:requireWareHouseItemUpdate(E_warehouseItemTouchHandleType.DeleteItemFromWarehouse, self.item:getGridId())			
	end
	self:close()
end

function BaseItemDetailView:onAuctionBuy()
	if self.item then
		G_getAuctionMgr():requestBuyOneItem(self.item:getId())
	end
	self:close()
end	

function BaseItemDetailView:onDetail()
	if self.item then
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipDetailPropertyView, self.item)
	end		
end