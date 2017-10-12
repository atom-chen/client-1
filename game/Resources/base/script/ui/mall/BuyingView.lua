require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("object.mall.MallDef")
require("object.mall.MallObject")

BuyingView = BuyingView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function BuyingView:__init()
	self.viewName = "BuyingView"	
	self:init(CCSizeMake(425,335))	
	self.buyNum = 1	
	self:initItem()
end	

function BuyingView:getGold()
	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
	local bindedGold  = PropertyDictionary:get_bindedGold(g_hero:getPT())
	local gold  = PropertyDictionary:get_gold(g_hero:getPT())		
	return bindedGold, unbindedGold, gold
end

function BuyingView:showUnableBuyTips()
	if self.showTipFlag == true then
		UIManager.Instance:showSystemTips(Config.Words[15019])
		self.showTipFlag = false
	end
end

--0 可以购买   1-道具数量不足（实际可以购买数量） 2- 元宝不足（实际可以购买数量）  3- 绑定元宝不足（实际可以购买数量）  4-金币不足（实际可以购买数量）
function BuyingView:fitTextColor()
	local bindedGold, unbindedGold, gold = self:getGold()

	local textNum = tonumber(string.match(self.buyTextEdit:getText(),"%d+"))
	if textNum == nil then
		textNum = 1
	end
			
	self.buyNum = textNum
	local buyNum = tonumber(self.buyNum)
	if buyNum < 1 then
		buyNum  = 1
	end			
	local needPrice = buyNum*self.singlePrice
	if string.match(self.buyObj:getStoreType(),"mall") then
		if self.buyObj:getStoreType() == "mall_2" then
			local limitType = self.buyObj:getItemLimitType()
			if limitType ~= 0 then	
				if buyNum > self.buyObj:getItemLimitNum()  then	
					self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))
					return 1,self.buyObj:getItemLimitNum()					
				end
			end
			if needPrice > bindedGold  then	
				self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))
				return 3,math.floor(bindedGold/self.singlePrice)					
			end				
		end
		if self.buyObj:getStoreType() == "mall_1" then
			local limitType = self.buyObj:getItemLimitType()
			if limitType ~= 0 then	
				if buyNum > self.buyObj:getItemLimitNum()  then	
					self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))
					return 1,self.buyObj:getItemLimitNum()					
				end
			end
			if needPrice > unbindedGold then	
				self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))				
				return 2,math.floor(unbindedGold/self.singlePrice)				
			end
		end
	elseif string.match(self.buyObj:getStoreType(),"shop")  then			
			local priceTable = self.buyObj:getObjPriceType()
			if priceTable then		
				if  priceTable["gold"] then
					if needPrice > gold then
						self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))						
						return 4,math.floor(gold/self.singlePrice)	
					end	
				else
					local priceItem = nil
					for  k , v in pairs(priceTable) do
						if  v > 0 then
							priceItem = k
							break
						end
					end
					if priceItem then
						local num =  G_getBagMgr():getItemNumByRefId(priceItem)
						if needPrice > num  then
							self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))							
							return 5,math.floor(num/self.singlePrice)
						end		
					end
				end
			end				
	elseif string.match(self.buyObj:getStoreType(),"discount")  then	  
	
		local priceTable = {}
		if table.size(self.buyObj:getObjPriceType()) > 0 then
			if buyNum > self.buyObj:getItemLimitNum()  then	
				self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))
				return 1,self.buyObj:getItemLimitNum()					
			end
			priceTable  = self.buyObj:getObjPriceType()	
			local key,value = self:getpriceTableValue(priceTable)
			if key then
				if key=="unbindedGold" and needPrice > unbindedGold then
					self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))			
					return 2,math.floor(unbindedGold/self.singlePrice)	
				elseif key=="gold" and needPrice > gold then
					self.buyTextEdit:setFontColor(FCOLOR("ColorRed1"))			
					return 4,math.floor(gold/self.singlePrice)	
				end	
			end
		end
	end	
	self.buyTextEdit:setFontColor(FCOLOR("ColorWhite1"))	
	return 0	
end	

function BuyingView:initItem()
	--商品背景
	self.frameSprBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(380,160))	
	self:addChild(self.frameSprBg)
	VisibleRect:relativePosition(self.frameSprBg,self:getContentNode(),LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE)
	--顶部标题		
	self.topTips  = createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorPurple2"))		
	self:addChild(self.topTips )			
	VisibleRect:relativePosition(self.topTips ,self.frameSprBg,LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE,ccp(0,5))	
		
	self.topTitle  = createSpriteWithFrameName(RES("word_button_buy.png"))		
	self:addChild(self.topTitle )
	VisibleRect:relativePosition(self.topTitle ,self.frameSprBg,LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE,ccp(0,5))
	
	self.goodsBg = createScale9SpriteWithFrameName(RES("mall_goodsframe.png"))		
	self:addChild(self.goodsBg)			
	VisibleRect:relativePosition(self.goodsBg,self.frameSprBg,LAYOUT_CENTER,ccp(0,30))		
	--商品名称
	self.goodsName = createLabelWithStringFontSizeColorAndDimension( " ","Arial",FSIZE("Size3"),FCOLOR("ColorPurple2"))	
	VisibleRect:relativePosition(self.goodsName,self.frameSprBg,LAYOUT_CENTER,ccp(0,-25))								
	self:addChild(self.goodsName)		
				
	self.buyTextEdit = createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(150,36)),RES("faction_editBoxBg.png"))
	self.buyTextEdit:setInputMode(kEditBoxInputModeNumeric)	
	VisibleRect:relativePosition(self.buyTextEdit,self.frameSprBg,LAYOUT_CENTER,ccp(0,-58))
	self:addChild(self.buyTextEdit)
	self.buyTextEdit:setText(self.buyNum)	
		
	local function editboxEventHandler(eventType)	
		if eventType == "began" then			
		elseif eventType == "ended" then			
			self:fitTextColor()							
			if self.buyTextEdit~= nil  then
				self.buyTextEdit:setText(self.buyNum)		
			end
			self.priceLabel:setString(tonumber(self.buyNum)*self.singlePrice)											
		elseif eventType == "changed" then			
			self:fitTextColor()							
			self.priceLabel:setString(tonumber(self.buyNum)*self.singlePrice)				
		elseif eventType == "return" then
		end
	end

	self.buyTextEdit:registerScriptEditBoxHandler(editboxEventHandler)	
	
	local decFunc = function(dt)
		local buyNum = tonumber(string.match(self.buyTextEdit:getText(),"%d+"))
		if buyNum == nil then
			buyNum = 1
		end
		if(buyNum > 1) then
			buyNum = buyNum - 1
		else
			UIManager.Instance:showSystemTips(Config.Words[15020])
		end
		self.priceLabel:setString(buyNum*self.singlePrice)
		self.buyTextEdit:setText(buyNum)
		self:fitTextColor()
	end						
	local btDec =  createLongPressButton(RES("btn_minus.png"),RES("btn_minus.png"),decFunc,decFunc)--createButtonWithFramename(RES("btn_minus.png"),RES("btn_minus.png"))					
	VisibleRect:relativePosition(btDec,self.frameSprBg,LAYOUT_CENTER,ccp(-100,-58))	
	self:addChild(btDec)									

	local addFunc = function()	
		local bindedGold, unbindedGold, gold = self:getGold()				
		local buyNum = tonumber(string.match(self.buyTextEdit:getText(),"%d+"))
		if buyNum == nil then
			buyNum = 1
		end
		local nextNeedPrice = (buyNum + 1)*self.singlePrice
		local storeType = self.buyObj:getStoreType()		
	
		if string.match(storeType,"mall") then	
			if 	self.buyObj:getItemLimitType() ~= 0 then
				local limitNum = self.buyObj:getItemLimitNum()				
				if buyNum < limitNum then
					buyNum = buyNum + 1
				else
					UIManager.Instance:showSystemTips(Config.Words[15021])
				end	
			else
				buyNum = buyNum + 1
			end					
		elseif string.match(storeType,"shop") then	
			local priceTable = self.buyObj:getObjPriceType()
			if priceTable then		
				if  priceTable["gold"] then
					if nextNeedPrice <= gold  then
						buyNum = buyNum + 1
					end
				else
					local priceItem = nil
					for  k , v in pairs(priceTable) do
						if  v > 0 then
							priceItem = k
							break
						end
					end
					if priceItem then
						local num =  G_getBagMgr():getItemNumByRefId(priceItem)
						if nextNeedPrice <= num  then
							buyNum = buyNum + 1
						else
							UIManager.Instance:showSystemTips(Config.Words[15028])
						end		
					end
				end
			end
	
		else --“discount”
			local limitNum = self.buyObj:getItemLimitNum()				
			if buyNum < limitNum then
				buyNum = buyNum + 1
			else
				UIManager.Instance:showSystemTips(Config.Words[15021])
			end	
		end												
		self.priceLabel:setString(buyNum*self.singlePrice)
		self.buyTextEdit:setText(buyNum)
		self:fitTextColor()
	end	

	local btAdd = createLongPressButton(RES("btn_add.png"),RES("btn_add.png"),addFunc,addFunc)					
	VisibleRect:relativePosition(btAdd,self.frameSprBg,LAYOUT_CENTER,ccp(100,-58))	
	self:addChild(btAdd)																	
	
	--价格
	--蓝色条
	local coinBg = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSizeMake(368,33))	
	VisibleRect:relativePosition(coinBg,self.frameSprBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(-10,-100))			
	self:addChild(coinBg)
	
	self.priceLabel = createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.priceLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.priceLabel,self.frameSprBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(80,-100))								
	self:addChild(self.priceLabel)
	
	--底部购买按钮
	self.buyBt = createButtonWithFramename(RES("btn_1_select.png"))
	VisibleRect:relativePosition(self.buyBt,self.frameSprBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-38,-40))	
	self:addChild(self.buyBt)
	
	local buyText =  createSpriteWithFrameName(RES("word_button_buy.png"))
	self.buyBt:setTitleString(buyText)
	local buyFunc = function()
		local erroCode = self:fitTextColor()
		if erroCode == 0 then
			local mallMgr = GameWorld.Instance:getMallManager()
			local npcMgr = GameWorld.Instance:getNpcManager()
			local npcId = npcMgr:getTouchNpcRefId()
			if string.match(self.buyObj:getStoreType(),"mall") then		
				mallMgr:requestBuyItem("mall",self.buyObj:getRefId(),self.buyNum)
			elseif string.match(self.buyObj:getStoreType(),"shop") then	 
				mallMgr:requestBuyItem(self.buyObj:getStoreType(),self.buyObj:getRefId(),self.buyNum,npcId)	
			elseif string.match(self.buyObj:getStoreType(),"discount")  then	  
				--请求购买
				--TODO
				mallMgr:requestBuyItem(self.buyObj:getStoreType(),self.buyObj:getRefId(),self.buyNum)	
			end
			self:close()
		else
			local message = {}
			if erroCode == 2 then
				local chargeFunc = function(arg,text,id)		
					if id == 0 then	
						local pay = function (tag, state)
							if tag == "pay" then 	
								if state == 1 then 
									CCLuaLog("success")			
								else
									CCLuaLog("fail")
								end
							end
						end
						G_getHero():getRechargeMgr():openPay(pay)
					else
						--关闭
					end	
				end
				local btns ={
					{text = Config.Words[5544],	id = 1},
					{text = Config.Words[5018],	id = 0},
				}					
				local msg = showMsgBox(Config.Words[5044],E_MSG_BT_ID.ID_CANCELAndOK)			
				msg:setBtns(btns)
				msg:setNotify(chargeFunc)	
			elseif erroCode == 1 then
				table.insert(message,{word = Config.Words[5051], color = Config.FontColor["ColorRed1"]})
				UIManager.Instance:showSystemTips(message)
			elseif erroCode == 3 then
				table.insert(message,{word = Config.Words[5053], color = Config.FontColor["ColorRed1"]})
				UIManager.Instance:showSystemTips(message)			
			elseif erroCode == 4 then
				table.insert(message,{word = Config.Words[5054], color = Config.FontColor["ColorRed1"]})
				UIManager.Instance:showSystemTips(message)
			elseif erroCode == 5 then
				table.insert(message,{word = Config.Words[5056], color = Config.FontColor["ColorRed1"]})
				UIManager.Instance:showSystemTips(message)
			end
		end	
	end		
	self.buyBt:addTargetWithActionForControlEvents(buyFunc,CCControlEventTouchDown)
	
	local buyCancle = createButtonWithFramename(RES("btn_1_select.png"))
	VisibleRect:relativePosition(buyCancle,self.frameSprBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE ,ccp(38,-40))	
	self:addChild(buyCancle)		
	local cancleText = createSpriteWithFrameName(RES("word_button_cancel.png"))
	buyCancle:setTitleString(cancleText)
	local buyFunc = function()		
		self:close()
	end		
	buyCancle:addTargetWithActionForControlEvents(buyFunc,CCControlEventTouchDown)
end	



function BuyingView:create()
	return BuyingView.New()
end

function BuyingView:setItem()
	--商品背景	
	local mallMgr = GameWorld.Instance:getMallManager()				
	--顶部标题			
	if mallMgr:getIsQuickBuy() then	
		self.topTitle:setVisible(false)
		self.topTips:setVisible(true)		
		self.topTips:setString( G_GetItemNameByRefId( self.buyObj:getItemId() ) .. Config.Words[5025])													
	else
		self.topTips:setVisible(false)				
		self.topTitle:setVisible(true)
	end
	
	local iconName = G_GetItemICONByRefId( self.buyObj:getItemId() )
	if iconName then	
		if self.goodsIcon == nil then
			self.goodsIcon = createSpriteWithFileName(ICON(iconName))
			self:addChild(self.goodsIcon)
		else		
			local sprite = createSpriteWithFileName(ICON(iconName))
			self.goodsIcon:setTexture(sprite:getTexture())
		end	
		VisibleRect:relativePosition(self.goodsIcon,self.goodsBg,LAYOUT_CENTER)
	else
		if self.goodsIcon then
			self.goodsIcon:setTexture(nil)
		end
	end
	--商品名称
	if self.goodsName ~= nil then
		self.goodsName:setString(G_GetItemNameByRefId( self.buyObj:getItemId() ))
	else	
		self.goodsName = createLabelWithStringFontSizeColorAndDimension( G_GetItemNameByRefId( self.buyObj:getItemId() ),"Arial",FSIZE("Size3"),FCOLOR("ColorPurple2"))	
		VisibleRect:relativePosition(self.goodsName,self.frameSprBg,LAYOUT_CENTER,ccp(0,-10))								
		self:addChild(self.goodsName)		
	end	
	
	local itemObj = ItemObject.New()
	itemObj:setRefId(self.buyObj:getItemId())
	local color = G_getColorByItem(itemObj)
	itemObj:DeleteMe()	
	if color then
		self.goodsName:setColor(color)
	end		
	if self.buyTextEdit~= nil  then
		self.buyTextEdit:setText(self.buyNum)		
	end
	--价格
	--蓝色条
	local priceTable = {}
	if table.size(self.buyObj:getObjPriceType()) > 0 then
		priceTable  = self.buyObj:getObjPriceType()	
	end		
	
	local iconStr = "item_unbindedGold"
	local scale  = 0.3
	self.singlePrice = 0
	local key,value = self:getpriceTableValue(priceTable)
	if key and value then
		iconStr = PriceIcon[key].icon		
		self.singlePrice = value
		scale = PriceIcon[key].scale
	end
	
	if self.coinSprite then
		self.coinSprite:removeFromParentAndCleanup(true)
		self.coinSprite = nil
	end		

	self.coinSprite = createSpriteWithFileName(ICON(iconStr))
	self.coinSprite:setScale(scale)
	VisibleRect:relativePosition(self.coinSprite,self.frameSprBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(50,-100))			
	self:addChild(self.coinSprite)
			
	local state,num = self:fitTextColor()
	if state == 0 then
		self.buyTextEdit:setFontColor(FCOLOR("ColorWhite1"))
	else
		if num > 0 then
			self.buyTextEdit:setText(num)
			self.buyNum = num
			self.buyTextEdit:setFontColor(FCOLOR("ColorWhite1"))
		else
			self.buyTextEdit:setText(1)
			self.buyNum = 1
		end
	end
	self.priceLabel:setString(self.singlePrice*tonumber(self.buyNum))

	--元宝不足提示	
	if self.buyBt then
		local word = self:getUnGoldLabelWord(state, num)
		if word then
			if not self.unGoldLabel then
				self.unGoldLabel = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
				self:addChild(self.unGoldLabel)
			else
				self.unGoldLabel:setString(word)
			end
			VisibleRect:relativePosition(self.unGoldLabel,self.buyBt,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE,ccp(0,10))
		end
	end
	
end	

function BuyingView:getUnGoldLabelWord(state, num)
	local word = nil
	if state == 0 or num >= 1 then
		word = " "
	elseif state == 2 then--元宝不足
		word = Config.Words[5052]
	elseif state == 3 then--绑定元宝不足
		word = Config.Words[5053]
	elseif state == 4 then--金币不足
		word = Config.Words[5054]
	end
	return word
end

function BuyingView:getpriceTableValue(ttable)
	if ttable then
		for k ,v in pairs(ttable) do
			if PriceIcon[k] and v > 0 then
				return k,v
			end
		end	
	end
end

function BuyingView:onEnter(arg)
	self.showTipFlag = true
	self.buyNum = arg
	local mallMgr = GameWorld.Instance:getMallManager()		
	self.buyObj = mallMgr:getBuyObj()
	self:setItem()
end

function BuyingView:onExit()
	local mallMgr = GameWorld.Instance:getMallManager()	
	mallMgr:setBuyObj(nil)
end

