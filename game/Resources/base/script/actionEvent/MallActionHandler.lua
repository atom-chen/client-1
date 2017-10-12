require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
MallActionHandler = MallActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()


function MallActionHandler:__init()
	
	local handleNet_G2C_Store_VersonResp = function(reader)
		self:handleNet_G2C_Store_VersonResp(reader)
	end				
	local handleNet_G2C_Store_LimitItemResp = function(reader)	
		self:handleNet_G2C_Store_LimitItemResp(reader)
	end
	local handleNet_G2C_Store_ItemListResp =function(reader)
		self:handleNet_G2C_Store_ItemListResp(reader)
	end
	local handleNet_G2C_Shop_BuyItemResp =function(reader)
		self:handleNet_G2C_Shop_BuyItemResp(reader)
	end
	
	local handleNet_G2C_ExchangeCode = function (reader)
		self:handleNet_G2C_ExchangeCode(reader)
	end
	
	self:Bind(ActionEvents.G2C_Store_VersonResp, handleNet_G2C_Store_VersonResp)
	self:Bind(ActionEvents.G2C_Store_LimitItemResp,	handleNet_G2C_Store_LimitItemResp)
	self:Bind(ActionEvents.G2C_Store_ItemListResp,	handleNet_G2C_Store_ItemListResp)
	self:Bind(ActionEvents.G2C_Shop_BuyItemResp,handleNet_G2C_Shop_BuyItemResp)
	self:Bind(ActionEvents.G2C_ExchangeCode, handleNet_G2C_ExchangeCode)
end 

--版本号
function MallActionHandler:handleNet_G2C_Store_VersonResp(reader)
	local mallMgr = GameWorld.Instance:getMallManager()	
	local preVersion = mallMgr:getVersion()	
	reader = tolua.cast(reader,"iBinaryReader")
	local version = StreamDataAdapter:ReadInt(reader)
	mallMgr:saveTempVersion(version)
	if(version ~= preVersion) then	
		mallMgr:requestMallList()	
	else
		mallMgr:requestMallLimitList("mall")	
	end		
end

--限购信息
function MallActionHandler:handleNet_G2C_Store_LimitItemResp(reader)		
	reader = tolua.cast(reader,"iBinaryReader")	
	local shopType = StreamDataAdapter:ReadStr(reader)	
	local mallMgr = GameWorld.Instance:getMallManager()	
	local count = StreamDataAdapter:ReadShort(reader)  --int -->short
	
	local changedCount = 0
	if string.match(shopType,"mall") then	
		for i=1,count do
			local obj = self:dealReader(reader)			
			if obj:getStoreType() == "mall_1"  then
				if self:IsEqueObj("mall_1",obj)	== false  then	
					if mallMgr:getOpenMallType() == 1 then				
						changedCount = changedCount + 1 
					end				
					mallMgr:UpdateMallItemByRefId(1,obj:getRefId(),obj)
					
					local index = mallMgr:getObjectIndex(1,obj:getRefId())
					local arg = {}
					arg.index = index
					arg.ttype = 1
					GlobalEventSystem:Fire(GameEvent.EventUpdateCell,arg)	
				else
					obj:DeleteMe()
				end					
			else
				if	self:IsEqueObj("mall_2",obj) == false    then
					if mallMgr:getOpenMallType() == 2 then				
						changedCount = changedCount + 1 
					end	
					mallMgr:UpdateMallItemByRefId(2,obj:getRefId(),obj)

					local index = mallMgr:getObjectIndex(2,obj:getRefId())
					local arg = {}
					arg.index = index
					arg.ttype = 2
					GlobalEventSystem:Fire(GameEvent.EventUpdateCell,arg)						
				else
					obj:DeleteMe()
				end	
			end	
		end	
	else		
		for i=1,count do
			local obj = self:dealShopReader(reader)										
			mallMgr:UpdateMallItemByRefId(3,obj:getRefId(),obj)
		end	
		if count > 0 then
			GlobalEventSystem:Fire(GameEvent.EventUpdateShop)							
		end
	end	
	mallMgr:setVersion(mallMgr:getTempVersion())	
end

--商品列表
function MallActionHandler:handleNet_G2C_Store_ItemListResp(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local mallMgr = GameWorld.Instance:getMallManager()	
	local bindList = {}
	local unbindList = {}
	local bindIndexList = {}
	local unbindIndexList = {}
	local bindIndex = 1
	local unbindIndex = 1
	local count = StreamDataAdapter:ReadShort(reader)	 --int ->short
	for i=1,count do
		local obj = self:dealReader(reader)			
		if( obj:getStoreType()	 == "mall_1") then
			unbindIndexList[unbindIndex] = obj:getRefId()
			unbindList[obj:getRefId()] = obj		
			unbindIndex = unbindIndex + 1
		elseif( obj:getStoreType() == "mall_2") then
			bindIndexList[bindIndex] = obj:getRefId()
			bindList[obj:getRefId()] = obj
			bindIndex = bindIndex + 1			
		else
		end		
	end	
	mallMgr:setBindMallIndexList(bindIndexList)	
	mallMgr:setUnBindMallIndexList(unbindIndexList)
	mallMgr:setBindMallList(bindList)
	mallMgr:setUnBindMallList(unbindList)
	GlobalEventSystem:Fire(GameEvent.EventUpdateMall)	
	mallMgr:requestMallLimitList("mall")
end

--购买返回
function MallActionHandler:handleNet_G2C_Shop_BuyItemResp(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local ret = StreamDataAdapter:ReadChar(reader)
	local mallMgr = GameWorld.Instance:getMallManager()
	if(ret == 1) then--购买成功
		local obj = mallMgr:getTempBuyObj()
		obj:setItemLimitNum(obj:getItemLimitNum()-mallMgr:getBuyNum())
		local ttype = obj:getStoreType()	
		
		--如果是VIP卡，则提示使用
		if 	string.match(obj:getItemId(),"item_vip_") then
			local refId = obj:getItemId()
			local itemData = G_getStaticDataByRefId(refId)
			if itemData then			
				local vipLevel = itemData.effectData.vipType
				local vipMgr = GameWorld.Instance:getVipManager()
				if vipMgr:getVipLevel() < vipLevel then
					local UseVip = UIManager.Instance:showPromptBox("UseVipCard",1,true)				
					local onUseVip = function(refId)
						local item = G_getBagMgr():getItemByRefId(refId)	
						if item and G_getBagMgr():getOperator():checkCanUseNormalItem(item) then		
							G_getBagMgr():requestUseItem(item, 1)		
						end	
						UIManager.Instance:hideUI("UseVipCard")
					end
					UseVip:setBtn("word_button_use.png",onUseVip, refId)
					UseVip:setTitleWords(Config.Words[13017])
					UseVip:setIcon(refId)
					UseVip:setIconWord(itemData.name)
					UseVip:setDescrition(itemData.property.description)
					
					local view = UIManager.Instance:getViewByName("VipView")
					if view~= nil then
						view:close()
					end
				end						
			end	
		end
		
		if(ttype=="mall_1")then
			mallMgr:UpdateMallItemByRefId(1,obj:getRefId(),obj)
			local index = mallMgr:getObjectIndex(1,obj:getRefId())
			local arg = {}
			arg.index = index
			arg.ttype = 1
			GlobalEventSystem:Fire(GameEvent.EventUpdateCell,arg)			
		elseif(ttype == "mall_2") then
			mallMgr:UpdateMallItemByRefId(2,obj:getRefId(),obj)
			local index = mallMgr:getObjectIndex(2,obj:getRefId())
			local arg = {}
			arg.index = index
			arg.ttype = 2
			GlobalEventSystem:Fire(GameEvent.EventUpdateCell,arg)		
		elseif(ttype == "shop_equip") then
			mallMgr:UpdateMallItemByRefId(4,obj:getRefId(),obj)
			local index = mallMgr:getObjectIndex(3,obj:getRefId())
			local arg = {}
			arg.index = index
			arg.ttype = 3
			GlobalEventSystem:Fire(GameEvent.EventUpdateCell,arg)	
		elseif(ttype == "discount") then			
			local view = UIManager.Instance:getViewByName("DiscountSellView")
			if view then
				view:doBuySuccessBySever(obj:getRefId(),mallMgr:getBuyNum())
			end	
		else
			mallMgr:UpdateMallItemByRefId(3,obj:getRefId(),obj)
			GlobalEventSystem:Fire(GameEvent.EventUpdateShopCell)
		end
	elseif(ret == 2) then--商品已售完
		local obj = mallMgr:getTempBuyObj()
		local ttype = obj:getStoreType()
		if(ttype == "discount") then
			GameWorld.Instance:getDiscountSellMgr():requestGetDiscountSellList()--请求打折出售列表		
		end
	elseif(ret == 0) then--购买失败
		local obj = mallMgr:getTempBuyObj()
		local ttype = obj:getStoreType()
		if(ttype == "discount") then
			GameWorld.Instance:getDiscountSellMgr():requestGetDiscountSellList()--请求打折出售列表		
		end
	end
	GlobalEventSystem:Fire(GameEvent.EventBuyReult,ret)
end	

function MallActionHandler:dealReader(reader)
	local refId = StreamDataAdapter:ReadStr(reader)
	local storeType = StreamDataAdapter:ReadStr(reader)  --
	local itemId = StreamDataAdapter:ReadStr(reader)
	local itemSellType = StreamDataAdapter:ReadChar(reader)
	local unbindedGold = StreamDataAdapter:ReadInt(reader)
	local bindedGold = StreamDataAdapter:ReadInt(reader)
	local unbindOriginalPrice = StreamDataAdapter:ReadInt(reader)
	local bindOriginalPrice = StreamDataAdapter:ReadInt(reader)
	local itemLimitType = StreamDataAdapter:ReadChar(reader)
	local itemLimitNum = StreamDataAdapter:ReadShort(reader) --int ->short
	local number = StreamDataAdapter:ReadShort(reader) --int ->short
	local storeLimitTime = StreamDataAdapter:ReadStr(reader)
			
	local obj = MallObject.New()			
	obj:setRefId(refId)
	obj:setStoreType(storeType)		
	obj:setItemId(itemId)
	obj:setItemSellType(itemSellType)
	obj:setUnBindedGold(unbindedGold)
	obj:setBindedGold(bindedGold)
	obj:setUnBindOriginalPrice(unbindOriginalPrice)
	obj:setBindOriginalPrice(bindOriginalPrice)
	obj:setItemLimitType(itemLimitType)
	obj:setItemLimitNum(itemLimitNum)
	obj:setNumber(number)
	obj:setStoreLimitTime(storeLimitTime)
	return obj
end	

function MallActionHandler:dealShopReader(reader)
	local refId = StreamDataAdapter:ReadStr(reader)
	local storeType = StreamDataAdapter:ReadStr(reader)
	local itemId = StreamDataAdapter:ReadStr(reader)
	local itemSellType = StreamDataAdapter:ReadChar(reader)
	local unbindedGold = StreamDataAdapter:ReadInt(reader)
	local bindedGold = StreamDataAdapter:ReadInt(reader)
	local gold = StreamDataAdapter:ReadInt(reader)	
	local itemLimitType = StreamDataAdapter:ReadChar(reader)
	local itemLimitNum = StreamDataAdapter:ReadInt(reader)
	local number = StreamDataAdapter:ReadInt(reader)
	local storeLimitTime = StreamDataAdapter:ReadStr(reader)
			
	local obj = MallObject.New()			
	obj:setRefId(refId)
	obj:setStoreType(storeType)		
	obj:setItemId(itemId)
	obj:setItemSellType(itemSellType)
	obj:setUnBindedGold(unbindedGold)
	obj:setBindedGold(bindedGold)
	obj:setCoinPrice(gold)	
	obj:setItemLimitType(itemLimitType)
	obj:setItemLimitNum(itemLimitNum)
	obj:setNumber(number)
	obj:setStoreLimitTime(storeLimitTime)
	return obj
end

function MallActionHandler:IsEqueObj(mallType,obj)
	local mallMgr = GameWorld.Instance:getMallManager()
	local bindList		= 	mallMgr:getBindMallList()
	local unBindList	= 	mallMgr:getUnBindMallList()
	if mallType == "mall_1"  then
		if not unBindList[obj:getRefId()] then
			return false
		end
		if	unBindList[obj:getRefId()]:getUnBindedGold() ~= obj:getUnBindedGold() or				
			unBindList[obj:getRefId()]:getUnBindOriginalPrice() ~= obj:getUnBindOriginalPrice() or				
			unBindList[obj:getRefId()]:getItemLimitType() ~= obj:getItemLimitType() or
			unBindList[obj:getRefId()]:getItemLimitNum() ~= obj:getItemLimitNum() or
			unBindList[obj:getRefId()]:getNumber() ~= obj:getNumber() or			
			unBindList[obj:getRefId()]:getItemId() ~= obj:getItemId() or
			unBindList[obj:getRefId()]:getItemSellType() ~= obj:getItemSellType() or
			unBindList[obj:getRefId()]:getStoreLimitTime() ~= obj:getStoreLimitTime()   then				
			return false
		else
			return true
		end
	else
		if not bindList[obj:getRefId()] then
			return false
		end
		if	bindList[obj:getRefId()]:getUnBindedGold() ~= obj:getUnBindedGold() or				
			bindList[obj:getRefId()]:getUnBindOriginalPrice() ~= obj:getUnBindOriginalPrice() or				
			bindList[obj:getRefId()]:getItemLimitType() ~= obj:getItemLimitType() or
			bindList[obj:getRefId()]:getItemLimitNum() ~= obj:getItemLimitNum() or
			bindList[obj:getRefId()]:getNumber() ~= obj:getNumber() or			
			bindList[obj:getRefId()]:getItemId() ~= obj:getItemId() or
			bindList[obj:getRefId()]:getItemSellType() ~= obj:getItemSellType() or
			bindList[obj:getRefId()]:getStoreLimitTime() ~= obj:getStoreLimitTime()   then				
			return false
		else
			return true
		end
	end	
end

function MallActionHandler:handleNet_G2C_ExchangeCode(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local state = StreamDataAdapter:ReadChar(reader)
	if state == 1 then
		GlobalEventSystem:Fire(GameEvent.EventResetEditeBox)
	else
		--激活不成功
	end
end