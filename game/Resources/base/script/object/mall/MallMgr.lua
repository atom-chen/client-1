require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.mall.MallDef")
require("data.skill.skill")
require("object.skill.SkillObject")
MallMgr = MallMgr or BaseClass()
local allItemList = {}
function MallMgr:__init()
	self.isQuickBuy = false
	self.Version = nil	
	self.bindMallList ={}
	self.unBindMallList = {}
	self.openShopIndexList ={}
	self.ShopList = {}	
	self.zhanshiList = {}	
	self.fashiList = {}	
	self.daoshiList = {}
	self.zhanshiIndexList = {}	
	self.fashiIndexList = {}	
	self.daoshiIndexList = {}
	self.sellTypeList = {}	
	
	self.sellTypeIcon = {	
		[SellType.eUnbindedGold] = {icon = "common_iocnWind.png"},
		[SellType.eBindedGold] = {icon = "common_iocnWind.png"},
		[SellType.eCoin] = {icon = "common_iocnGold.png"},
		[SellType.eGold]= {icon = "item_goldMedal"},
		[SellType.eSilver] = {icon = "item_silverMedal"},
		[SellType.eCopper] = {icon = "item_copperMedal"},
		[SellType.eIron] = {icon = "item_ironMedal"},
	}		
end

function MallMgr:clear()
	self.isQuickBuy = false
	self.Version = nil	
	self.bindMallList ={}
	self.unBindMallList = {}
	self.openShopIndexList ={}
	self.ShopList = {}	
	self.zhanshiList = {}	
	self.fashiList = {}	
	self.daoshiList = {}
	self.zhanshiIndexList = {}	
	self.fashiIndexList = {}	
	self.daoshiIndexList = {}
	self.sellTypeList = {}	
	
end

function MallMgr:initShopList()
	self.ShopList = G_GetShopItemList()
end

--商城商品列表
function MallMgr:requestMallList()
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Store_ItemListReq)
	simulator:sendTcpActionEventInLua(writer)	
end
--商城版本号
function MallMgr:requestMallVerSion()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Store_VersonReq)	
	simulator:sendTcpActionEventInLua(writer)
end
--请求限购列表
function MallMgr:requestMallLimitList(storeType)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Store_LimitItemReq)
	writer:WriteString(storeType)	
	simulator:sendTcpActionEventInLua(writer)
end

function MallMgr:requestBuyItem(storeType ,refId ,count,npcId  )
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Shop_BuyItemReq)	
	self.buyNum = count
	if string.match(storeType,"mall") then
		writer:WriteString("mall")
		writer:WriteString(refId)
		writer:WriteInt(count)
	elseif string.match(storeType,"shop")then
		writer:WriteString(storeType)
		writer:WriteString(npcId)
		writer:WriteString(refId)
		writer:WriteInt(count)	
	elseif string.match(storeType,"discount") then
		writer:WriteString("discount")
		writer:WriteString(refId)
		writer:WriteInt(count)		
	end
	simulator:sendTcpActionEventInLua(writer)
end

function MallMgr:requestGiftExchange(code)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_ExchangeCode)
	writer:WriteString(code)
	simulator:sendTcpActionEventInLua(writer)
end

function MallMgr:setVersion(version)
	self.Version = version
end

function MallMgr:getVersion()
	return self.Version
end


function MallMgr:getBindMallList()
	return self.bindMallList
end 

function MallMgr:getUnBindMallList()
	return self.unBindMallList
end

function MallMgr:setBindMallList(list)
	if table.size(self.bindMallList)>0 then
		for i,v in pairs(self.bindMallList) do
			v:DeleteMe()
			v = nil
		end
	end
	self.bindMallList = list
end 

function MallMgr:setUnBindMallList(list)
	if table.size(self.unBindMallList)>0 then
		for i,v in pairs(self.unBindMallList) do
			v:DeleteMe()
			v = nil
		end
	end		
	self.unBindMallList = list
end

function MallMgr:UpdateMallItemByRefId(ttype,refId,obj)
	if(ttype == 1) then
		if not self.unBindMallList[refId] then
			return 
		end	
		(self.unBindMallList[refId]):DeleteMe()
		self.unBindMallList[refId] = nil 
		self.unBindMallList[refId] = obj
	elseif(ttype == 2) then
		if not self.bindMallList[refId] then
			return 
		end
		(self.bindMallList[refId]):DeleteMe()
		self.bindMallList[refId] = nil 
		self.bindMallList[refId] = obj
	elseif (ttype == 3) then	
		if table.size(self.ShopList)>0 then
			if not self.ShopList[refId] then
				return 
			end			
			(self.ShopList[refId]):DeleteMe() 
			self.ShopList[refId]=nil
			self.ShopList[refId] = obj
		end
	elseif ttype == 4 then
		if table.size(self.exchangeTotalList)>0 then
			if not self.exchangeTotalList[refId] then
				return 
			end					
			(self.exchangeTotalList[refId]):DeleteMe()
			self.exchangeTotalList[refId] = nil 
			self.exchangeTotalList[refId] = obj
		end			
	else
	end	
end	

function MallMgr:saveTempVersion(tempVersion)
	self.tempVersion = tempVersion
end

function MallMgr:getTempVersion()
	return self.tempVersion
end

function MallMgr:setBuyObj(obj)
	self.buyObj = obj
end

function MallMgr:getBuyObj()
	return self.buyObj
end

function MallMgr:setTempBuyObj(obj)
	self.tempbuyObj = obj
end

function MallMgr:getTempBuyObj()
	return self.tempbuyObj
end

function MallMgr:getShopList()
	return  self:getShopItemListByShopId(self.shopId)	
end

--kind  1 战士  2 法师  3道士   4 全部
function MallMgr:getShopItemListByShopId(shopId, kind)
	local shoplist = {}
	self.openShopIndexList = {}
	local index = 0
	for k,idex in pairs(self.shopIndexList) do
		local v = self.ShopList[idex] 
		if(v:getStoreType() == shopId) then
			if kind  == 4 then	
				self.openShopIndexList[index] = v:getRefId()
				shoplist[v:getRefId()] = v
				index = index + 1
			else
				local refId  = v:getItemId()
				local pt = G_getStaticDataByRefId(refId)
				if pt then
					local professionId = PropertyDictionary:get_professionId(pt.property)
					if professionId == kind or professionId == 0 then
						self.openShopIndexList[index] = v:getRefId()
						shoplist[v:getRefId()] = v
						index = index + 1						
					end
				end
			end
		end		
	end
	return shoplist
end

function MallMgr:setSelectShopId(shopId)
	self.shopId = shopId
end

function MallMgr:getOpenShopIndexList()
	return self.openShopIndexList
end

function MallMgr:getWholeShopList()
	return self.ShopList
end

function MallMgr:getShopIndexList()
	return self.shopIndexList	
end

function MallMgr:setShopIndexList(list)
	self.shopIndexList = list	
end
function MallMgr:getExchangeIndexList()
	return self.exchangeIndexList	
end
function MallMgr:setExchangeIndexList(list)
	self.exchangeIndexList = list	
end

function MallMgr:getBuyNum()
	return self.buyNum
end

function MallMgr:setBindMallIndexList(list)
	self.bindIndexList = list
end

function MallMgr:setUnBindMallIndexList(list)
	self.unBindMallIndexList = list
end


function MallMgr:getBindMallIndexList()
	return self.bindIndexList
end

function MallMgr:getUnBindMallIndexList()
	return self.unBindMallIndexList
end

function MallMgr:setIsQuickBuy(state)
	self.isQuickBuy = state	
end

function MallMgr:getIsQuickBuy()
	return self.isQuickBuy
end

function MallMgr:setOpenMallType(typ)
	self.openMallType = typ
end

function MallMgr:getOpenMallType()
	return self.openMallType
end
function MallMgr:setExchangeTotalList(list)
	self.exchangeTotalList = list
end
function MallMgr:getExchangeTotalList()
	return self.exchangeTotalList
end

function MallMgr:sortItemListByProfression(list)
	local itemList = list
	if itemList then
		local sortExchangeIndexListByRefId = function(list)
			function sortLevelNameAsc(a, b)			
				local a1=tonumber(string.sub(a,11))
				local b1=tonumber(string.sub(b,11))
				return  a1 < b1
			end
			table.sort(list, sortLevelNameAsc)
		end
		self.zhanshiIndex = 1
		self.fashiIndex = 1
		self.daoshiIndex = 1
		for i,v in pairs(itemList) do
			local refId = v:getRefId()
			local itemId = v:getItemId()
			if refId and itemId then
				local itemData = G_getStaticDataByRefId(itemId)
				if itemData then
					local professionId = itemData.property.professionId
					if professionId then
						self:setItemListByProfressionId(professionId,i,v)	
					end	
				end
			end 
		end
		sortExchangeIndexListByRefId(self.zhanshiIndexList)
		sortExchangeIndexListByRefId(self.fashiIndexList)
		sortExchangeIndexListByRefId(self.daoshiIndexList)
	end
end

function MallMgr:setItemListByProfressionId(professionId,refId,mallObj)
	if professionId == 1 then
		self.zhanshiList[refId] = mallObj
		self.zhanshiIndexList[self.zhanshiIndex] = refId
		self.zhanshiIndex = self.zhanshiIndex + 1
	elseif professionId == 2 then
		self.fashiList[refId] = mallObj
		self.fashiIndexList[self.fashiIndex] = refId
		self.fashiIndex = self.fashiIndex + 1
	elseif professionId == 3 then
		self.daoshiList[refId] = mallObj
		self.daoshiIndexList[self.daoshiIndex] = refId
		self.daoshiIndex = self.daoshiIndex + 1
	end		
end

function MallMgr:getSubItemListAndIndexListByTag(tag)
	if tag == 4 then
		return self.exchangeTotalList,self.exchangeIndexList
	elseif tag == 3 then
		return self.zhanshiList,self.zhanshiIndexList		
	elseif tag == 2 then
		return self.fashiList,self.fashiIndexList	
	elseif tag == 1 then
		return self.daoshiList,self.daoshiIndexList	
	end
end

function MallMgr:getProfessionAndLevel(itemId)
	local itemData = G_getStaticDataByRefId(itemId)
	if itemData then
		local professionId = itemData.property.professionId		
		local level = itemData.property.equipLevel
		return professionId,level
	end
end

function MallMgr:checkSellType(mallObj)
	self.sellTypeList = {}
	local count = 0	
	local unbindedGold = mallObj:getUnBindedGold()
	local bindedGold = mallObj:getBindedGold()
	local coinPrice = mallObj:getCoinPrice()
	local goldMedal = mallObj:getGoldMedal()
	local sliverMedal = mallObj:getSliverMedal()
	local copperMedal = mallObj:getCopperMedal()
	local ironMedal = mallObj:getIronMedal()
	if unbindedGold ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eUnbindedGold,unbindedGold)
	end
	if bindedGold ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eBindedGold,bindedGold)
	end
	if coinPrice ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eCoin,coinPrice)
	end
	if goldMedal ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eGold,goldMedal)
	end
	if sliverMedal ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eSilver,sliverMedal)
	end
	if copperMedal ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eCopper,copperMedal)
	end
	if ironMedal ~= 0 then
		count = count+1
		self:setSellTypeList(count,SellType.eIron,ironMedal)
	end
	return self.sellTypeList
end
function MallMgr:setSellTypeList(key,sType,num)
	self.sellType = {}
	self.sellType.type = sType
	self.sellType.num = num
	if not self.sellTypeList[key] then
		self.sellTypeList[key]	= self.sellType
	end
end

function MallMgr:getSellTypeIconByType(sType)
	return self.sellTypeIcon[sType].icon
end

function MallMgr:getObjectIndex(ttype,refId)
	local list = {}
	if ttype == 1 then
		list = self.unBindMallIndexList
	elseif ttype == 2 then
		list = self.bindIndexList
	else
		list = self.exchangeIndexList		
	end
	for k,v in pairs(list) do
		if v == refId then
			return k
		end
	end	
end
function MallMgr:getDescription(itemId)
	local itemData = G_getStaticDataByRefId(itemId)
	if itemData then
		local skillRefId = itemData.skillRefId	
		if skillRefId and string.match(skillRefId,"skill") then		
			local skillDescStr = itemData.property.tips
			local name = GameData.Skill[skillRefId].property.name
			if skillDescStr and name then
				return name,skillDescStr
			end	
		else
			local skillDescStr = itemData.property.description
			local name = itemData.property.name
			if skillDescStr and name then
				return name,skillDescStr
			end	
		end
	end
end

function MallMgr:getGoodsBindStatus(goodsRefId)
	if GameData.Shop[goodsRefId] then	
		return PropertyDictionary:get_bindStatus(GameData.Shop[goodsRefId].property)
	end
	return nil
end