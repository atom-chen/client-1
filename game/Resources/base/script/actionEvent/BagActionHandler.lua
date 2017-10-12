require("object.bag.ItemObject")
BagActionHandler = BagActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()
local bagMgr = nil

function BagActionHandler:__init()
	
	local handleNet_G2C_Bag_Capacity = function(reader)
		self:handleNet_G2C_Bag_Capacity(reader)
	end
	local handleNet_G2C_ItemList = function(reader)
		self:handleNet_G2C_ItemList(reader)
	end
	local handleNet_G2C_ItemUpdate = function(reader)
		self:handleNet_G2C_ItemUpdate(reader)
	end
	local handleNet_G2C_Item_SoltUnLock = function(reader)
		self:handleNet_G2C_Item_SoltUnLock(reader)
	end
	local getShowItem = function (reader)
		self:handleGetShowItem(reader)
	end
	self:Bind(ActionEvents.G2C_GetShowItem, getShowItem)   --聊天物品展示
	self:Bind(ActionEvents.G2C_Bag_Capacity, handleNet_G2C_Bag_Capacity)
	self:Bind(ActionEvents.G2C_Item_List,	handleNet_G2C_ItemList)
	self:Bind(ActionEvents.G2C_Item_Update,	handleNet_G2C_ItemUpdate)
	self:Bind(ActionEvents.G2C_Item_SoltUnLock,	handleNet_G2C_Item_SoltUnLock)
	
	-- 离线背包
	local handleNet_G2C_ViewOffLineAIReward = function(reader)
		self:handleNet_G2C_ViewOffLineAIReward(reader)
	end
	
	local handleNet_G2C_DrawOffLineAIReward = function()
		self:handleNet_G2C_DrawOffLineAIReward(reader)
	end
	
	self:Bind(ActionEvents.G2C_ViewOffLineAIReward, handleNet_G2C_ViewOffLineAIReward)
	self:Bind(ActionEvents.G2C_DrawOffLineAIReward, handleNet_G2C_DrawOffLineAIReward)
end

function BagActionHandler:handleGetShowItem(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local id = StreamDataAdapter:ReadStr(reader)
	local gridIdg = StreamDataAdapter:ReadShort(reader)
	local refIdg = StreamDataAdapter:ReadStr(reader)
	local pdCount = StreamDataAdapter:ReadChar(reader)
	
	
	if (refIdg ~= nil and gridIdg ~= nil and id ~= nil and pdCount > 0) then
		local itemObj = ItemObject.New()
		itemObj:setId(id)
		itemObj:setGridId(gridIdg)
		itemObj:setRefId(refIdg)
		itemObj:setSource(E_EquipSource.inBag)
		itemObj:setStaticData(G_getStaticDataByRefId(itemObj:getRefId()))
		for j = 1, pdCount do
			local pdType = StreamDataAdapter:ReadChar(reader)
			local dataLenght = StreamDataAdapter:ReadShort(reader)  --int->short
			local pd1 = getPropertyTable(reader)
			if (pd1 ~= {} and pd1 ~= nil) then
				if (pdType == 1) then 				--总属性字典			
					itemObj:setPT(pd1)					
				elseif (pdType == 2) then 		--洗练属性字典
					itemObj:setWashPT(pd1)
				else
					CCLuaLog("BagActionHandler:explainItemData unkown pd. pdType="..pdType)
				end
--				CCLuaLog("Bag Item data gridIdg="..gridIdg)
			else
--				CCLuaLog("Bag Item data error !(pd1 ~= {} and pd1 ~= nil)")
			end
		end
		GlobalEventSystem:Fire(GameEvent.EventShowItemInfo, itemObj)
	end
end

function BagActionHandler:handleNet_G2C_ItemUpdate(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local eventType = reader:ReadChar()
	if (eventType > E_UpdataEvent.Modify or eventType < E_UpdataEvent.Add) then
		return
	end
	local gmap = self:explainItemData(reader)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	bagMgr:updateItemMap(eventType, gmap)
end

function BagActionHandler:handleNet_G2C_ItemList(reader)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local bagCapacity = StreamDataAdapter:ReadShort(reader);
	local gmapg = self:explainItemData(reader, true)
	bagMgr:setItemMap(gmapg)
	bagMgr:setCurCap(bagCapacity)
	GlobalEventSystem:Fire(GameEvent.EventItemList)	
end

function BagActionHandler:handleNet_G2C_Bag_Capacity(reader)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	
	local maxCap = reader:ReadShort()
	local curCap = reader:ReadShort()	
	local oldCurCap = bagMgr:getCurCap()
	local oldMaxCap = bagMgr:getMaxCap()
	bagMgr:setCurCap(curCap)	
	bagMgr:setMaxCap(maxCap)
	GlobalEventSystem:Fire(GameEvent.EventBagCapacity, curCap, oldCurCap, maxCap, oldMaxCap)
end

function BagActionHandler:handleNet_G2C_Item_SoltUnLock(reader)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local remainMins = reader:ReadInt()
	GlobalEventSystem:Fire(GameEvent.EventItemUnLockRemain, remainMins)
end

-- 解析物品数据，返回itemMap(以gridId为key，itemObj为值的值对)
function BagActionHandler:explainItemData(reader, bAddToRecord)
	local map = {};
	local bagMgr = G_getBagMgr()
	local itemRecord = bagMgr:getItemRecord()
	local itemCountgg = StreamDataAdapter:ReadShort(reader)
	for i = 1, itemCountgg do
		local id = StreamDataAdapter:ReadStr(reader)
		local gridIdg = StreamDataAdapter:ReadShort(reader)
		local refId = StreamDataAdapter:ReadStr(reader)
		local pdCount = StreamDataAdapter:ReadChar(reader)
		
		if (refId ~= nil and gridIdg ~= nil and id ~= nil and pdCount > 0) then
		
			local itemObj = ItemObject.New()
			itemObj:setId(id)
			itemObj:setGridId(gridIdg)
			itemObj:setRefId(refId)
			itemObj:setSource(E_EquipSource.inBag)
			for j = 1, pdCount do
				local pdType = StreamDataAdapter:ReadChar(reader)
				local dataLenght = StreamDataAdapter:ReadShort(reader)
				local pd1 = getPropertyTable(reader)
				if (pd1 ~= {} and pd1 ~= nil) then
					if (pdType == 1) then 				--总属性字典
						itemObj:setPT(pd1)
						itemObj:setStaticData(G_getStaticDataByRefId(refId))
					elseif (pdType == 2) then 		--洗练属性字典
						itemObj:setWashPT(pd1)
					else
						CCLuaLog("BagActionHandler:explainItemData unkown pd. pdType="..pdType)
					end
--					CCLuaLog("Bag Item data gridIdg="..gridIdg)
				else
--					CCLuaLog("Bag Item data error !(pd1 ~= {} and pd1 ~= nil)")
				end
			end
			if bAddToRecord then
				itemRecord[id] = 1	--将所有出现过的物品存放到这里
			end
			table.insert(map, itemObj)
		else
--			CCLuaLog("Bag Item data error !(refIdg ~= nil and gridIdg ~= nil and id ~= nil and pdCount > 0)")
		end
	end
	return map
end

function BagActionHandler:handleNet_G2C_ViewOffLineAIReward(reader)
	local offLineBagMgr = GameWorld.Instance:getOffLineBagMgr()
	local offLineBagObject = offLineBagMgr:getOffLineBagObject()
	reader = tolua.cast(reader,"iBinaryReader")
	local itemSize = StreamDataAdapter:ReadShort(reader)
	for i = 1,itemSize do
		if offLineBagObject.items[i] == nil then
			offLineBagObject.items[i] = {}
		end	
		offLineBagObject.items[i].itemRefId = StreamDataAdapter:ReadStr(reader)
		offLineBagObject.items[i].itemNum = StreamDataAdapter:ReadInt(reader)
	end
	offLineBagObject.exp = StreamDataAdapter:ReadInt(reader)
	offLineBagObject.money = StreamDataAdapter:ReadInt(reader)
	local aiLogModelListSize = StreamDataAdapter:ReadShort(reader)
	for j = 1,aiLogModelListSize do
		if offLineBagObject.logs[j] == nil then
			offLineBagObject.logs[j] = {}
		end
		offLineBagObject.logs[j].logType = StreamDataAdapter:ReadChar(reader)
		if offLineBagObject.logs[j].log == nil then
			offLineBagObject.logs[j].log = {}
		end
		if offLineBagObject.logs[j].logType == 1 then
			offLineBagObject.logs[j].log.aiGameSceneRefId = StreamDataAdapter:ReadStr(reader)
		elseif offLineBagObject.logs[j].logType == 2 then
			offLineBagObject.logs[j].log.playerId = StreamDataAdapter:ReadStr(reader)
			offLineBagObject.logs[j].log.playerName = StreamDataAdapter:ReadStr(reader)
			if offLineBagObject.logs[j].log.dorpItem == nil then
				offLineBagObject.logs[j].log.dorpItem = {}
			end
			local dorpItemSize = StreamDataAdapter:ReadShort(reader)
			for k = 1,dorpItemSize do
				if offLineBagObject.logs[j].log.dorpItem[k] == nil then
					offLineBagObject.logs[j].log.dorpItem[k] = {}
				end
				offLineBagObject.logs[j].log.dorpItem[k].itemRefId =StreamDataAdapter:ReadStr(reader)
				offLineBagObject.logs[j].log.dorpItem[k].itemNum = StreamDataAdapter:ReadInt(reader)
			end
		end
	end	
	GlobalEventSystem:Fire(GameEvent.EventUpdateOffLineBag)
end

function BagActionHandler:handleNet_G2C_DrawOffLineAIReward()
	GlobalEventSystem:Fire(GameEvent.EventGetOffLineAIReward)
end




