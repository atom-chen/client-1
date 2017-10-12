require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("object.bag.ItemObject")

WarehouseActionHandler = WarehouseActionHandler or BaseClass(ActionEventHandler)

function WarehouseActionHandler:__init()
		
	local handNet_G2C_WareHouse_Capacity = function (reader)
		self:handNet_G2C_WareHouse_Capacity(reader)
	end
	
	local handNet_G2C_WareHouse_Item_List = function (reader)
		self:handNet_G2C_WareHouse_Item_List(reader)
	end
	
	local handNet_G2C_WareHouse_Item_Update = function (reader)
		self:handNet_G2C_WareHouse_Item_Update(reader)
	end
	
	local handNet_G2C_WareHouse_Item_SoltUnLock = function (reader)
		self:handNet_G2C_WareHouse_Item_SoltUnLock(reader)
	end
	
	self:Bind(ActionEvents.G2C_WareHouse_Capacity, handNet_G2C_WareHouse_Capacity)
	self:Bind(ActionEvents.G2C_WareHouse_Item_List, handNet_G2C_WareHouse_Item_List)
	self:Bind(ActionEvents.G2C_WareHouse_Item_Update, handNet_G2C_WareHouse_Item_Update)
	self:Bind(ActionEvents.G2C_WareHouse_Item_SoltUnLock, handNet_G2C_WareHouse_Item_SoltUnLock)
	
	--[[self:Bind(ActionEvents.G2C_Bag_Capacity, handNet_G2C_WareHouse_Capacity)
	self:Bind(ActionEvents.G2C_Item_List,	handNet_G2C_WareHouse_Item_List)
	self:Bind(ActionEvents.G2C_Item_Update,	handNet_G2C_WareHouse_Item_Update)
	self:Bind(ActionEvents.G2C_Item_SoltUnLock,	handNet_G2C_WareHouse_Item_SoltUnLock)--]]
	
end

function WarehouseActionHandler:__delete()

end

function WarehouseActionHandler:handNet_G2C_WareHouse_Capacity(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
	local maxCap = StreamDataAdapter:ReadShort(reader)
	local curCap = StreamDataAdapter:ReadShort(reader)
	warehouseMgr:setMaxCap(maxCap)
	warehouseMgr:setCurCap(curCap)
end

function WarehouseActionHandler:handNet_G2C_WareHouse_Item_List(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
	local curCap = StreamDataAdapter:ReadShort(reader)
	warehouseMgr:setCurCap(curCap)	
	local list, keyList, sortList, gridList = self:parseItems(reader, true)
	warehouseMgr:setSortList(sortList)	
	warehouseMgr:setSortKeyList(keyList)	
	warehouseMgr:setGridList(gridList)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateWarehouseView)
	UIManager.Instance:hideLoadingHUD()
end

function WarehouseActionHandler:handNet_G2C_WareHouse_Item_Update(reader)
	reader = tolua.cast(reader, "iBinaryReader")	
	local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
	local eventType = StreamDataAdapter:ReadChar(reader)
	local list = self:parseItems(reader)
	warehouseMgr:updateItemList(eventType, list)
end

function WarehouseActionHandler:handNet_G2C_WareHouse_Item_SoltUnLock(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
	local remainTime = StreamDataAdapter:ReadInt(reader)
	warehouseMgr:setUnlockRemainTime(remainTime)
	UIManager.Instance:showSystemTips(string.format(Config.Words[25705], remainTime))
end

function WarehouseActionHandler:parseItems(reader, isReturnSortList)	
	local sortList = {}	
	local gridList = {}
	local list = {}
	local keyList = {}
	local count = StreamDataAdapter:ReadShort(reader)
	for i = 1, count do
		local id = StreamDataAdapter:ReadStr(reader)
		local gridId = StreamDataAdapter:ReadShort(reader)
		local refId = StreamDataAdapter:ReadStr(reader)
								
		local obj = ItemObject.New()
		obj:setId(id)		
		obj:setRefId(refId)		
		obj:setGridId(gridId)
		local pdCount = StreamDataAdapter:ReadChar(reader)
		for j = 1, pdCount do
			local pdType = StreamDataAdapter:ReadChar(reader)
			local dataLenght = StreamDataAdapter:ReadShort(reader)
			local pd = getPropertyTable(reader)
			if type(pd) == "table" then
				if (pdType == 1) then 				--×ÜÊôÐÔ×Öµä
					obj:setPT(pd)
					obj:setStaticData(G_getStaticDataByRefId(obj:getRefId()))
				elseif (pdType == 2) then 			--Ï´Á·ÊôÐÔ×Öµä
					obj:setWashPT(pd)
				else
					CCLuaLog("AuctionActionHandler:parseItems unkown pd. pdType="..pdType)
				end					
			end
		end				
	
		if isReturnSortList then
			local sortId = PropertyDictionary:get_itemSortId(obj:getStaticData().property)			
			key = tonumber(sortId)		
			local sortObjectList = sortList[key] 
			if sortObjectList == nil then
				sortList[key] = {}
				table.insert(keyList,sortId)
			end
			sortList[key][gridId] = obj
			
			gridList[gridId] = obj	
		end		
			
		list[i] = obj
	end
	
	if isReturnSortList then
		local sortFunc = function (a,b)
			return a < b
		end
		table.sort(keyList,sortFunc)		
	end
	
	return list, keyList, sortList, gridList
end	