require("data.item.propsItem")
require("data.item.equipItem")
require("data.mall.shop")
require("object.mall.MallObject")
require("data.item.unPropsItem")

CurrencyType ={

	eCurrencyType_1 = 1,--绑定元宝
	eCurrencyType_2 = 2,--元宝
	eCurrencyType_3 = 3,--礼券
	eCurrencyType_4 = 4,--Bindingcopper

	eCurrencyType_5 = 5,--copper
	eCurrencyType_6 = 6,--道具

	eCurrencyType_7 = 7,--灵气

	eCurrencyType_8 = 30,--金币
	eCurrencyType_9 = 31,--铜币

	eCuttentTypeNotDefine = 32 --金币
}

MallCurrency ={
	eMallCurrency_0 = 0,--元宝
	eMallCurrency_1 = 1,--绑定元宝
	eMallCurrency_2 = 2--礼券
}

MedalType = {
	eGold = 1,
	eSilver = 2,
	eCopper = 3,
	eIron = 4,
}

ExchangeSubType = {
	all = 4,
	zhanshi = 3,
	fashi = 2,
	daoshi = 1,
}
SellType = {
	eUnbindedGold = 1,
	eBindedGold = 2,
	eCoin = 3,
	eGold = 4,
	eSilver = 5,
	eCopper = 6,
	eIron = 7,
}


PriceIcon = {
["gold"] = {icon = "item_gold" ,scale = 0.4 },
["item_ironMedal"] = {icon = "item_ironMedal" ,scale = 0.5},
["item_silverMedal"] = {icon = "item_silverMedal" ,scale =0.5 },
["item_copperMedal"] = {icon = "item_copperMedal" ,scale =0.5 },
["item_goldMedal"] = {icon = "item_goldMedal" ,scale =0.5 },
["item_coupon"] = {icon = "item_coupon_1" ,scale = 0.5 },
["item_coupon_2"] = {icon = "item_coupon_2" ,scale = 0.5 },
["bindedGold"] = {icon = "item_bindedGold" ,scale = 0.4 },
["unbindedGold"] = {icon = "item_unbindedGold" ,scale = 0.4 },

}


function G_GetItemNameByRefId(refId)
	if GameData.EquipItem[refId] ~= nil  then	
		local tableEquip = GameData.EquipItem[refId].property	
		return PropertyDictionary:get_name(tableEquip)	
	elseif GameData.PropsItem[refId]~=nil then
		local tableItem =  GameData.PropsItem[refId].property
		return PropertyDictionary:get_name(tableItem)
	else
		return " "
	end		
end

function G_GetItemDescByRefId(refId)
	if GameData.EquipItem[refId] ~= nil  then	
		local tableEquip = GameData.EquipItem[refId].property	
		return PropertyDictionary:get_description(tableEquip)	
	elseif GameData.PropsItem[refId]~=nil then
		local tableItem =  GameData.PropsItem[refId].property
		return PropertyDictionary:get_description(tableItem)
	else
		return " "
	end		
end

function G_getQualityByRefId(refId)
	if GameData.EquipItem[refId] ~= nil  then
		local tableEquip = GameData.EquipItem[refId].property	
		return PropertyDictionary:get_quality(tableEquip)	
	elseif GameData.PropsItem[refId]~=nil then
		local tableItem =  GameData.PropsItem[refId].property
		return PropertyDictionary:get_quality(tableItem)
	end		
end

function G_GetItemICONByRefId(refId)
	if GameData.EquipItem[refId] ~= nil  then
		local tableEquip = GameData.EquipItem[refId].property	
		return PropertyDictionary:get_iconId(tableEquip)	
	elseif GameData.PropsItem[refId]~=nil then
		local tableItem =  GameData.PropsItem[refId].property
		return PropertyDictionary:get_iconId(tableItem)
	elseif GameData.UnPropsItem[refId]~= nil then
		local tableItem =  GameData.UnPropsItem[refId].property
		return PropertyDictionary:get_iconId(tableItem)
	end		
end	
--[[
	["shop_item_056"] = { refId = "shop_item_056", property = { storeType = "shop_3", itemId = "equip_15_7100", itemLimitType = 0, itemLimitNum = 0, number = 0,}, 
	 priceData = {
			 priceData = { { number = 16000, refId = "gold", },}, }, },
]]--
function G_GetShopItemList()
	local list = {}
	local shopIndexList = {}
	local mallMgr = GameWorld.Instance:getMallManager()
	--index = 0

	for k,v in pairs(GameData.Shop) do	
		local obj = LoadShopItem(v)
		list[k] = obj
		local index = tonumber(string.sub(v.refId,11))
		shopIndexList[index] = k
		--index = index + 1							
	end
	mallMgr:setShopIndexList(shopIndexList)
	return list
end

function LoadShopItem(shopItem)
	local obj = MallObject.New()
	if shopItem then
		obj:setRefId(shopItem.refId)				
		obj:setStoreType(PropertyDictionary:get_storeType(shopItem.property))	
		obj:setItemId(PropertyDictionary:get_itemId(shopItem.property))
		obj:setItemLimitType(PropertyDictionary:get_itemLimitType(shopItem.property))
		obj:setItemLimitNum(PropertyDictionary:get_itemLimitNum(shopItem.property))
		obj:setNumber(PropertyDictionary:get_number(shopItem.property))
		obj:setPrice(shopItem.priceData.priceData)
	end	
	return obj
end


function G_setExchangeItemList()
	local list = {}
	local exchangeIndexList = {}
	local mallMgr = GameWorld.Instance:getMallManager()
	local index = 1
	local sortExchangeIndexListByRefId = function(exchangeIndexList)
		function sortLevelNameAsc(a, b)			
			local a1=tonumber(string.sub(a,11))
			local b1=tonumber(string.sub(b,11))
			return  a1 < b1
		end
		table.sort(exchangeIndexList, sortLevelNameAsc)
	end
	for k,v in pairs(GameData.Shop) do	
		local storeType = PropertyDictionary:get_storeType(v.property)
		if storeType == "shop_equip" then
			local obj = LoadShopItem(v)
			list[k] = obj			
			exchangeIndexList[index] = k	
			index = index + 1				
		end
	end
	sortExchangeIndexListByRefId(exchangeIndexList)
	mallMgr:setExchangeIndexList(exchangeIndexList)
	mallMgr:sortItemListByProfression(list)
	mallMgr:setExchangeTotalList(list)
end



function G_IsCanBuyInShop(itemRefId)
	local mgr = GameWorld.Instance:getMallManager()
	local bindList = mgr:getBindMallList()
	local unbindList = mgr:getUnBindMallList()
	
	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
	local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 
	--如果道具存在于商城  且 玩家对应的钱币大于物品单价则返回对应的Obj
	--优先判断绑定元宝商城
	local bindObj
	local unbindObj
	for k,v in pairs(bindList) do
		if(v:getItemId() == itemRefId  and v:getItemLimitNum() > 0) then
			bindObj = v
		end
	end			
	for k,v in pairs(unbindList) do
		if(v:getItemId() == itemRefId ) then
			if v:getItemLimitType() == 0 then
			--玩家元宝数量
				unbindObj = v
			else
				if v:getItemLimitNum()>0 then
					--if(unbindedGold > v:getUnBindedGold() )then
					unbindObj = v
					--else
					--	break
					--end
				end
			end
		end
	end
	--玩家绑定元宝数量

	if unbindObj and unbindedGold >= unbindObj:getUnBindedGold() then
		return unbindObj
	elseif bindObj and bindedGold >= bindObj:getBindedGold()then
		return  bindObj		
	else
		if unbindObj then
			return unbindObj
		end
		if  bindObj then
			return bindObj
		end
	end	
end


-----------------------------------新API------------------------------------------
