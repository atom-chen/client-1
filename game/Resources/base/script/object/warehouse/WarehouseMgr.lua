require("common.baseclass")
require("object.warehouse.WarehouseDef")

WarehouseMgr = WarehouseMgr or BaseClass()

function WarehouseMgr:__init()
	self.curCap = 0
	self.maxCap = 0
	self.UnlockRemainTime = 0
	self.itemList = {} -- key index, value item
	self.sortList = {} -- key sortId+gridId,  value item
	self.gridList = {} -- key gridId, value item
	self.sortKeyList = {} --key index, value sortId
	self.needInsert = true	
end

function WarehouseMgr:__delete()
	self:clear()
end

function WarehouseMgr:clear()
	for i,v in pairs(self.gridList) do
		v:DeleteMe()
	end				
	self.itemList = {}	
	self.gridList = {}
	self.sortKeyList = {}
	self.sortList = {}				
	self.needInsert = true
	self.curCap = 0
	self.maxCap = 0
	self.UnlockRemainTime = 0
end

function WarehouseMgr:requireWareHouseCapacity()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_WareHouse_Capacity)	
	simulator:sendTcpActionEventInLua(writer)
end

function WarehouseMgr:requireWareHouseItemList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_WareHouse_Item_List)	
	simulator:sendTcpActionEventInLua(writer)
end

function WarehouseMgr:requireWareHouseItemUpdate(eventType, gridId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_WareHouse_Item_Update)
	StreamDataAdapter:WriteChar(writer,eventType)
	StreamDataAdapter:WriteShort(writer, gridId)
	simulator:sendTcpActionEventInLua(writer)
end

function WarehouseMgr:requireWareHouseItemSoltUnLock()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_WareHouse_Item_SoltUnLock)	
	simulator:sendTcpActionEventInLua(writer)
end	

function WarehouseMgr:setMaxCap(maxCap)
	self.maxCap = maxCap
end

function WarehouseMgr:getMaxCap()
	return self.maxCap
end

function WarehouseMgr:setCurCap(curCap)
	self.curCap = curCap
end

function WarehouseMgr:getCurCap()
	return self.curCap
end

function WarehouseMgr:setUnlockRemainTime(time)
	self.UnlockRemainTime = time
end

function WarehouseMgr:getUnlockRemainTime()
	return self.UnlockRemainTime
end

--[[function WarehouseMgr:setItemList(itemList)
	if itemList then
		if table.size(self.itemList)>0 then
			for i,v in pairs(self.itemList) do
				v:DeleteMe()
			end
		end
		self.itemList = itemList	
	else
		return
	end
	local bagMgr = G_getBagMgr()
	local sort = function(a, b)
		return bagMgr.compareItemSortId(a, b, false)
	end
	table.sort(self.itemList, sort)
end--]]

function WarehouseMgr:setSortKeyList(list)
	self.sortKeyList = list
end

function WarehouseMgr:setSortList(sortList)
	self.sortList = sortList
end

function WarehouseMgr:getSortList()
	return self.sortList
end

function WarehouseMgr:setGridList(gridList)
	self.gridList = gridList    
end

function WarehouseMgr:getGridList()
	return self.gridList
end

function WarehouseMgr:addItem(itemObj)
	if not itemObj then
		return
	end
	
	local gridId = itemObj:getGridId()	
	local sortId= PropertyDictionary:get_itemSortId(itemObj:getStaticData().property)	
	if self.sortList[sortId] == nil then
		self.sortList[sortId] = {}
		local keyIndex = self:findKeyIndex(sortId)
		table.insert(self.sortKeyList, keyIndex, sortId)		
	end				
	self.sortList[sortId][gridId] = itemObj	
	self.gridList[gridId] = itemObj
		
end

function WarehouseMgr:findKeyIndex(sortId)
	local low = 1
    local high = #(self.sortKeyList)

    while(low <= high) do	
        local mid = math.floor((low + high)/2)
        local key = self.sortKeyList[mid]
        if (key < sortId) then		
            low = mid + 1
			if self.sortKeyList[low] then
				if self.sortKeyList[low] > sortId then
					return low
				end
			else
				return high+1			
			end
        elseif(key > sortId) then			
            high = mid - 1
			if self.sortKeyList[high] then
				if self.sortKeyList[high] < sortId then
					return mid
				end
			else
				return 1			
			end    
		else			
            return mid
        end			
    end
    return 1
end

function WarehouseMgr:removeItem(itemObj)
	if not itemObj then
		return
	end
	--local sortId = PropertyDictionary:get_itemSortId(itemObj:getStaticData().property)	
	local gridId = itemObj:getGridId()	
	local item = self.gridList[gridId]	
	if item then
		local sortId = PropertyDictionary:get_itemSortId(item:getStaticData().property)		
		self.sortList[sortId][gridId] = nil	
		self.gridList[gridId] = nil
		item:DeleteMe()		
		
		if table.isEmpty(self.sortList[sortId]) then
			self.sortList[sortId] = nil
			local keyIndex = self:findKeyIndex(sortId)
			if self.sortKeyList[keyIndex] then
				table.remove(self.sortKeyList, keyIndex)
			end	
		end
	end				
end

function WarehouseMgr:changeItem(itemObj)
	if not itemObj then
		return
	end
	
	local gridId = itemObj:getGridId()		
	local staticData = itemObj:getStaticData()
	if staticData then
		local pt = staticData.property
		if pt then
			local sortId= PropertyDictionary:get_itemSortId(pt)	
			if self.sortList[sortId] == nil then
				self.sortList[sortId] = {}
			end		
			self.sortList[sortId][gridId] = itemObj
			self.gridList[gridId] = itemObj
		else
			CCLuaLog("gridId=====" .. gridId)
		end			
	end	
end

function WarehouseMgr:updateItemList(eventType, list)
	if not list or list == {} then
		return
	end
	
	if eventType == E_warehouseUpdateType.AddItem then
		for grid, item in pairs(list) do
			self:addItem(item)					
		end
		GlobalEventSystem:Fire(GameEvent.EventUpdateWarehouseItem, eventType, list)
	elseif eventType == E_warehouseUpdateType.DeleteItem then
		for grid, item in pairs(list) do
			local oldItem = self.gridList[item:getGridId()]
			if oldItem then
				item:setId(oldItem:getId()) 
				item:setRefId(oldItem:getRefId())
			end				
			self:removeItem(item)				
		end
		GlobalEventSystem:Fire(GameEvent.EventUpdateWarehouseItem, eventType, list)
	elseif eventType == E_warehouseUpdateType.ModifyItem then
		local addItems = {}	
		local modifiedItems = {}
		local hasModified = false
		local hasAdded = false
		for grid, item in pairs(list) do			--改动的时候，服务端会将Item的完整属性发回来，所以可以直接替换
			local refId = item.refId							
			--local newNum = PropertyDictionary:get_number(item.table)		
			--local sordId = PropertyDictionary:get_itemSortId(item:getStaticData().property)	
			--local index = self:findItem(sordId)	
			local oldItem = self.gridList[item:getGridId()]				
			if oldItem == nil then				--服务器可能将增加物品也以更新物品的形式发过来，这里需要区分
				table.insert(addItems, item)					
				hasAdded = true
				self:addItem(item)	
				self.needInsert = true			
			else
				--oldNum = PropertyDictionary:get_number(oldItem.table)		
				table.insert(modifiedItems, item)
				hasModified = true			
				self:changeItem(item)				
			end					
		end
						
		if hasAdded then
			GlobalEventSystem:Fire(GameEvent.EventUpdateWarehouseItem, E_warehouseUpdateType.AddItem, addItems)
		end				
		if hasModified then
			GlobalEventSystem:Fire(GameEvent.EventUpdateWarehouseItem, E_warehouseUpdateType.ModifyItem, modifiedItems)
		end
	end
	self.needInsert = true	
end

function WarehouseMgr:getItemList()
	if self.needInsert then
		self.itemList = {}
		for k, v in ipairs(self.sortKeyList) do
			local objectList = self.sortList[v]
			if objectList then
				for k1,item in pairs(objectList) do		
					table.insert(self.itemList, item)
				end	
			end						
		end
		self.needInsert = false
	end
	
	return self.itemList
end

--[[function WarehouseMgr:findItem(sortId)
	local low = 1
    local high = #(self.sortKeyList)

    while(low <= high) do	
        local mid = math.floor((low + high)/2);
        local key = self.sortKeyList[mid]
        if (key < sortId) then		
            low = mid + 1;				
        elseif(key > sortId) then			
            high = mid - 1;			  
		else			
            return mid;
        end			
    end
    return -1;	
end	--]]

-- 按type来筛选物品，type对应于BagDef.lua里的ItemType定义
function WarehouseMgr:getItemListByType(ttype)
	local list = {}				
	
	for k, v in ipairs(self.sortKeyList) do
		local objectList = self.sortList[v]
		if objectList then
			for k1,item in pairs(objectList) do		
				if (ttype == item:getType()) then
					table.insert(list, item)
				end
			end	
		end						
	end				
	return list
end

function WarehouseMgr:getItemListByTypeWithFilter(ttype, filterFunc)
	if (ttype == ItemType.eItemAll) then
		return self:getItemList()
	end
	local itemMap = {}			
	
	for k, v in ipairs(self.sortKeyList) do
		local objectList = self.sortList[v]
		if objectList then
			for k1,item in pairs(objectList) do		
				if (ttype == item:getType() and ((not filterFunc) or filterFunc(item))) then						
					table.insert(itemMap, item)			
				end
			end	
		end						
	end	
	return itemMap
end	

function WarehouseMgr:getItemMapExceptTypes(ttype, filterFunc)
	local list = {}			
	
	for k, v in ipairs(self.sortKeyList) do
		local objectList = self.sortList[v]
		if objectList then
			for k1,item in pairs(objectList) do		
				local ok = true		
				for index, value in pairs(ttype) do
					if (value == item:getType()) or (filterFunc and (not filterFunc(item))) then
						ok = false
						break
					end
				end
				if (ok == true) then		
					table.insert(list, item)			
				end
			end	
		end						
	end					
	return list
end

-- 仓库中的物品数量
function WarehouseMgr:getItemCount()
	return table.size(self.gridList)
end

function WarehouseMgr:getItemListByContentType(selectTabView)
	local filterFunc = nil

	local itemList = {}
	if selectTabView == E_warehouseContentType.All then
		itemList = self:getItemList()
	elseif selectTabView == E_warehouseContentType.Equip then
		itemList = self:getItemListByType(ItemType.eItemEquip, filterFunc)	
	elseif selectTabView == E_warehouseContentType.Material then
		itemList = self:getItemListByType(ItemType.eItemMaterial, filterFunc)	
	else
		itemList = self:getItemMapExceptTypes({[1] = ItemType.eItemMaterial, [2] = ItemType.eItemEquip}, filterFunc)	
	end
		
	return itemList
end






