--  背包（数据管理）
require("common.baseclass")
require("object.bag.ItemOperator")
BagMgr = BagMgr or BaseClass()

local const_commonCDValue = 0.5
local const_drugCDValue = 5
local const_huichengjuanCDValue = 300

function BagMgr:__init()
	self.operator = ItemOperator.New()
	self.lastTipsTime = 0
	self:clear()
end

function BagMgr:__delete()

end	

function BagMgr:clear()
	self.itemList = {}
	self.itemRecord = {}			--保存所有出现过的物品记录，以id为key，1为value。供自动穿戴提示使用
	self.maxCap = 0
	self.curCap = 0
	self.CDItemList = {} --保存带有CD时间的物品，以id为key, CDTime为value
	self.commonCDValue = 0	
	self.huichengjuanCDValue = 0
	self.lastTipsTime = 0
end		

function BagMgr:getItemRecord()
	return self.itemRecord
end

function BagMgr:hasRecord(id)
	return (self.itemRecord[id] ~= nil)
end

function BagMgr:addRecord(id)
	self.itemRecord[id] = 1
end

function BagMgr:getOperator()
	return self.operator
end

function BagMgr:update(time)
	if self.commonCDValue > 0 then
		self.commonCDValue = self.commonCDValue - time
	end
	if self.huichengjuanCDValue > 0 then
		self.huichengjuanCDValue = self.huichengjuanCDValue - time
	end
	for k,v in pairs(self.CDItemList) do
		if v >= 0 then
			self.CDItemList[k] = v - time
		end			
	end		
end

function BagMgr:resetCommonCD()
	self.commonCDValue = 0.5
end

function BagMgr:resetHuichengjuanCD()
	self.huichengjuanCDValue = const_huichengjuanCDValue
end

function BagMgr:resetDrugCD(item)
	self:setCDTime(item, E_CDItemModifyTime.AddCDTime)	
end

function BagMgr:isDrugCDReady(itemObj)
	local CDTime = self:getCDTimeFromCDItemList(itemObj)	
	if CDTime == nil then
		return true
	end
	return CDTime <= 0
end

function BagMgr:isCommonCDReady()
	return (self.commonCDValue <= 0)
end	

function BagMgr:isHuichengjuanCDReady()
	return (self.huichengjuanCDValue <= 0)
end	

function BagMgr:hasEquipInBodyArea(bodyArea)
	for k, v in pairs(self.itemList) do	
		local bodyAreaId = PropertyDictionary:get_areaOfBody(v:getStaticData().property)
		if bodyAreaId == bodyArea and G_getBagMgr():getOperator():checkCanPutOnEquip(v) then
			return true
		end
	end
	return false
end

--检测是否有某件物品
function BagMgr:hasItem(refId)
	if (self.itemList == nil) then
		return false
	end
	local num = 0
	for gridId, value in pairs(self.itemList) do	
		if (refId == value:getRefId()) then
			return true
		end
 	end
	return false
end

function BagMgr:isFull()
	return (self.curCap == self:getItemCount())
end

--通过refId查找最前的gridId
function BagMgr:getItemIdByRefId(refId)
	if (self.itemList == nil) then
		return false
	end

	for gridId, value in pairs(self.itemList) do	
		if (refId == value:getRefId()) then
			return value:getId()
		end
 	end
	return nil
end

function BagMgr:getItemNumByRefId(refId)
	if (self.itemList == nil) then
		return 0
	end
	local num = 0
	for gridId, value in pairs(self.itemList) do	
		if (refId == value:getRefId()) then
			num = num + PropertyDictionary:get_number(value:getPT())
		end
 	end
	return num
end

function BagMgr:getBindedAndUnbindItemNumByRefId(refId)
	if (self.itemList == nil) then
		return 0
	end
	local bindNum = 0
	local unbindNum = 0
	for gridId, value in pairs(self.itemList) do	
		if (refId == value:getRefId()) then
			if PropertyDictionary:get_bindStatus(value:getPT()) == 1 then
				bindNum = bindNum + PropertyDictionary:get_number(value:getPT())
			else 
				unbindNum = unbindNum + PropertyDictionary:get_number(value:getPT())
			end
		end
 	end
	return bindNum,unbindNum
end


function BagMgr:getCDTime(object)
	local staticData = object:getStaticData()
	if staticData then
		local effectData = staticData.effectData
		if effectData then
			return effectData.CDTime
		end
	end
end

function BagMgr:getCDTimeFromCDItemList(item)
	local key = self:getCDItemKey(item)
	return self.CDItemList[key]
end

function BagMgr:getCDItemKey(item)
	local refId = item:getRefId()
	local staticData = item:getStaticData()
	local itemCDGroup = staticData.property.itemCDGroup
	local key = nil
	if itemCDGroup and itemCDGroup ~= -1 then
		key = itemCDGroup
	else
		key = refId
	end
	return key
end

function BagMgr:setCDTime(item, modifyType)
	local CDTime = self:getCDTime(item)	
	if CDTime then
		local key = self:getCDItemKey(item)
		if E_CDItemModifyTime.AddCDTime == modifyType then
			self.CDItemList[key] = CDTime
		else
			if key == refId then
				self.CDItemList[key] = nil
			end				
		end			
	end
end

-- 保存背包列表: gridId为key，ItemObj为value
function BagMgr:setItemMap(map)
	if map then
		if table.size(self.itemList)>0 then
			for i,v in pairs(self.itemList) do
				v:DeleteMe()
			end
		end
		self.itemList = map	
	else
		return
	end
	
	for k,v in pairs(self.itemList) do
		self:setCDTime(v, E_CDItemModifyTime.AddCDTime)
	end
	local sort = function(a, b)
		return self.compareItemSortId(a, b, false)
	end
	table.sort(self.itemList, sort)
end	

function BagMgr:getItemMap(filterFunc)
	if not filterFunc then
		return self.itemList	
	else
		local ret = {}
		for k, v in ipairs(self.itemList) do
			if filterFunc(v) then
				table.insert(ret, v)
			end
		end
		return ret
	end
end	

--根据itemId获取物品
function BagMgr:getItemById(id)
	for k, v in pairs(self.itemList) do	
		if (id == v:getId()) then
			return v
		end	
	end
	return nil
end

function  BagMgr:getItemByRefId(refId)
	for k, v in pairs(self.itemList) do	
		if (refId == v:getRefId()) then
			return v
		end	
	end
	return nil
end

--根据gridId删除一个物品
function BagMgr:removeItem(gridId)
	local index = self:findItem(gridId)
	if index then
		table.remove(self.itemList, index)
	end	
end

function BagMgr:findItem(gridId)
	for k, v in ipairs(self.itemList) do
		if v:getGridId() == gridId then	
			return k, v
		end
	end		
end

--替换一个物品
function BagMgr:replaceItem(itemObj)
	local gridId = itemObj:getGridId()
	local index = self:findItem(gridId)
	if index then
		table.remove(self.itemList, index)
		table.insert(self.itemList, index, itemObj)
	end
end

--替换一个物品
function BagMgr:replaceItemWithIndex(itemObj, index)
	if index then
		table.remove(self.itemList, index)
		table.insert(self.itemList, index, itemObj)
	end
end

--增加一个物品
function BagMgr:addItem(itemObj)
	local index = #(self.itemList)	
	while true do
		if index >= 1 then
			if self.compareItemSortId(itemObj, self.itemList[index], true) then
				table.insert(self.itemList, index + 1, itemObj)
				break
			else
				index = index - 1
			end
		else
			table.insert(self.itemList, 1, itemObj)
			break
		end
	end
end

function BagMgr:updateItemMap(eventType, map)	
	local countBeforeUpdate = self:getItemCount()
	local hasAdded = false
	if (E_UpdataEvent.Add == eventType) then
		for grid, item in pairs(map) do
			self:addItem(item)			
		end
		GlobalEventSystem:Fire(GameEvent.EventItemUpdate, eventType, map)
	elseif (E_UpdataEvent.Delete == eventType) then
		for grid, item in pairs(map) do
			local oldIndex, oldItem = self:findItem(item:getGridId())
			if oldItem then	
				item:setId(oldItem:getId()) 	--删除的时候，服务器并没有将id发过来。需要客户端补上。
				item:setRefId(oldItem:getRefId())
				table.remove(self.itemList, oldIndex)
				self:setCDTime(item, E_CDItemModifyTime.RemoveCDTime)
			end				
		end
		GlobalEventSystem:Fire(GameEvent.EventItemUpdate, eventType, map)
	elseif (E_UpdataEvent.Modify == eventType) then	
		local addItems = {}
		local itemChangeCountList = {}
		local modifiedItems = {}
		local hasModified = false		
		for grid, item in pairs(map) do			--改动的时候，服务端会将Item的完整属性发回来，所以可以直接替换
			local refId = item.refId							
			local newNum = PropertyDictionary:get_number(item.table)			
			local oldIndex, oldItem = self:findItem(item:getGridId())			
			local oldNum = 0			
			if oldItem == nil then				--服务器可能将增加物品也以更新物品的形式发过来，这里需要区分
				table.insert(addItems, item)					
				hasAdded = true
				self:addItem(item)
				self:setCDTime(item, E_CDItemModifyTime.AddCDTime)
			else
				oldNum = PropertyDictionary:get_number(oldItem.table)		
				table.insert(modifiedItems, item)
				hasModified = true			
				self:replaceItemWithIndex(item, oldIndex)				
			end	
			
			if item:getType() ~= ItemType.eItemEquip  or (not self.itemRecord[item:getId()])  then	
				if not itemChangeCountList[refId] then			
					itemChangeCountList[refId] = 0
				end	
				itemChangeCountList[refId] = itemChangeCountList[refId] + newNum - oldNum				
			end
		end
		local tipsMgr = LoginWorld.Instance:getTipsManager()
		local showFlag = tipsMgr:getTipsShowFlag()	
		
		local warehouseView = UIManager.Instance:getViewByName("WarehouseView")	
		
		local index = 0	
		local viewName = " " 
		local icon = ""				
		for k,v in pairs(itemChangeCountList) do
			if v > 0 then			
				local nameStr = G_getStaticPropsName(k)
				local staticData = G_getStaticDataByRefId(k)
				local quality = PropertyDictionary:get_quality(staticData.property)			
				if showFlag == true then								
					if quality >=3 then  
						if warehouseView and warehouseView:getState() == E_warehouseState.Remove then
							--TODO
						else
							UIManager.Instance:ShowTipsWithItem(k,v)
						end							
					end
					local msg = {[1] = {word = Config.Words[10119], color = Config.FontColor["ColorYellow1"]},
								[2] = {word = "["..nameStr.."]", color = Config.FontColor["ColorRed3"]},
								[3] = {word = "x"..tostring(v), color = Config.FontColor["ColorYellow1"]},}
					if warehouseView and warehouseView:getState() == E_warehouseState.Remove then
						--TODO
					else
						UIManager.Instance:showSystemTips(msg,E_TipsType.emphasize)
					end	
					--UIManager.Instance:showSystemTips(msg,E_TipsType.emphasize)
					--UIManager.Instance:showSystemTips(nameStr)										
				elseif showFlag == false then
					local getStr = string.wrapRich(Config.Words[10119],Config.FontColor["ColorYellow1"],FSIZE("Size5"))
					local name = string.wrapRich("["..nameStr.."]",Config.FontColor["ColorRed3"],FSIZE("Size5"))
					local numStr = string.wrapRich("x"..tostring(v),Config.FontColor["ColorYellow1"],FSIZE("Size5"))
					local msg = getStr..name..numStr
					tipsMgr:insertUnShowTipsList(msg)
				end

				local itemGetTips =  function(arg)						
					local vView = UIManager.Instance:getViewByName(arg.viewName)	
					--ToDo						
					vView:close()							
				end
				if not G_IsEquip(k) then
					if k == "item_shenqiExp" then
						local manager =UIManager.Instance
						local view = manager:getViewByName("TalismanView")
						if view then						
							view:updateDetailsView()
						end
					else
						local talisMgr = GameWorld.Instance:getTalismanManager()
						talisMgr:handleTalismSuipian(k, v)
					end
				end
			end	
		end				
		if hasAdded then
			GlobalEventSystem:Fire(GameEvent.EventItemUpdate, E_UpdataEvent.Add, addItems)
		end				
		if hasModified then
			GlobalEventSystem:Fire(GameEvent.EventItemUpdate, E_UpdataEvent.Modify, modifiedItems)
		end
	end	
	local countAfterUpdate = self:getItemCount()
	if countAfterUpdate > countBeforeUpdate  and (eventType ==  E_UpdataEvent.Add or (eventType ==  E_UpdataEvent.Modify and hasAdded == true)) then
		local freeCount = self:getFreeGridCount()
		local quickSellList = self:getQuickSellItemList()
		if freeCount <= 1 and quickSellList and (not table.isEmpty(quickSellList)) then		
			if os.time() - self.lastTipsTime >= 300 then
				self.lastTipsTime = os.time()
				self:showQuickSellBox(quickSellList)
			end				
		end
	end
end


function BagMgr:showQuickSellBox(quickSellList)		
	local icon = createSpriteWithFrameName(RES("main_bag.png"))
	if icon then
		icon:setScaleX(70/90)
		icon:setScaleY(71/92)
		local quickSell = UIManager.Instance:showPromptBox("QuickSell",1,true)				
		local quickSellFunc = function()
			G_getForgingMgr():requestBag_Decompose(quickSellList)
			UIManager.Instance:hideUI("QuickSell")
		end
		quickSell:setBtn(Config.Words[10224],quickSellFunc)
		quickSell:setTitleWords(Config.Words[10223])
		quickSell:setIcon(icon)		
		quickSell:setDescrition(Config.Words[10225])
	end
end

-- 背包中的物品数量
function BagMgr:getItemCount()
	return #(self.itemList)
end

-- 背包的容量
function BagMgr:setMaxCap(maxCap)
	self.maxCap = maxCap
end

function BagMgr:getMaxCap()	
		return self.maxCap
end

function BagMgr:setCurCap(curCap)
	self.curCap = curCap
end

function BagMgr:getCurCap()	
	return self.curCap
end		

--剩余多少空格
function BagMgr:getFreeGridCount()
	return self.curCap - #(self.itemList)
end

function BagMgr.compareItemSortId(a, b, bMore)
	local a_SortId = PropertyDictionary:get_itemSortId(a:getStaticData().property)
	local b_SortId = PropertyDictionary:get_itemSortId(b:getStaticData().property)
	if bMore then
		if a_SortId > b_SortId then
			return true
		elseif a_SortId < b_SortId then
			return false
		elseif a_SortId == b_SortId then
			local a_isHighestEquip = PropertyDictionary:get_isHighestEquipment(a:getPT())
			local b_isHighestEquip = PropertyDictionary:get_isHighestEquipment(b:getPT())
			if b_isHighestEquip == 1 and a_isHighestEquip == 0 then
				return true
			else
				return false
			end
		end
		--return PropertyDictionary:get_itemSortId(a:getStaticData().property) > PropertyDictionary:get_itemSortId(b:getStaticData().property)		
	else
		--return PropertyDictionary:get_itemSortId(a:getStaticData().property) < PropertyDictionary:get_itemSortId(b:getStaticData().property)		
		if a_SortId < b_SortId then
			return true
		elseif a_SortId > b_SortId then
			return false
		elseif a_SortId == b_SortId then
			local a_isHighestEquip = PropertyDictionary:get_isHighestEquipment(a:getPT())
			local b_isHighestEquip = PropertyDictionary:get_isHighestEquipment(b:getPT())
			if b_isHighestEquip == 0 and a_isHighestEquip == 1 then
				return true
			else
				return false
			end
		end
	end
end
		
-- 按type来筛选物品，type对应于BagDef.lua里的ItemType定义
function BagMgr:getItemListByType(ttype)
	local itemList = {}
	for k, v in pairs(self.itemList) do
		if (ttype == v:getType()) then
			table.insert(itemList, v)
		end
	end
	return itemList
end

function BagMgr:getItemMapByType(ttype, filterFunc)
	if (ttype == ItemType.eItemAll or self.itemList == nil) then
		return self.itemList
	end
	local itemMap = {}
	for k, v in ipairs(self.itemList) do	
		if (ttype == v:getType() and ((not filterFunc) or filterFunc(v))) then						
			table.insert(itemMap, v)			
		end
	end
	return itemMap
end	

function BagMgr:getItemMapExceptTypes(ttype, filterFunc)
	if (self.itemList == nil) then
		return self.itemList
	end
	
	local list = {}
	for k, v in ipairs(self.itemList) do	
		local ok = true		
		for index, value in pairs(ttype) do
			if (value == v:getType()) or (filterFunc and (not filterFunc(v))) then
				ok = false
				break
			end
		end
		if (ok == true) then		
			table.insert(list, v)			
		end
	end
	return list
end

function BagMgr:requestBagCapacity()
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Bag_Capacity)
	simulator:sendTcpActionEventInLua(writer)		
end 

function BagMgr:requestItemList()
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_List)
	simulator:sendTcpActionEventInLua(writer)
end	

function BagMgr:requestUseItem(itemObj, count)
	if (itemObj == nil) or type(count) ~= "number" then
		return
	end
		
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Use)
	writer:WriteShort(itemObj:getGridId())	
	writer:WriteShort(count)
	simulator:sendTcpActionEventInLua(writer)
end		

function BagMgr:requestUnLockSlot(gridId)
	if type(gridId) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_SoltUnLock)
	writer:WriteShort(gridId)	
	simulator:sendTcpActionEventInLua(writer)
end

function BagMgr:requestBatchSellItem(list)
	local size = table.size(list)
	if size < 1 then
		return
	end
	
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Batch_Sell)
	writer:WriteShort(size)
	for k, v in pairs(list) do
		writer:WriteShort(v:getGridId())
		writer:WriteShort(PropertyDictionary:get_number(v:getPT()))	
	end
	simulator:sendTcpActionEventInLua(writer)	
end

function BagMgr:requestSellItem(itemObj, count)
	if (itemObj == nil) or type(count) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Sell)
	writer:WriteShort(itemObj:getGridId())
	writer:WriteShort(count)
	simulator:sendTcpActionEventInLua(writer)
end	

function BagMgr:requestDropItem(itemObj)
	if (itemObj == nil) then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Drop)
	writer:WriteShort(itemObj:getGridId())
	simulator:sendTcpActionEventInLua(writer)	
end

function BagMgr:requestAddItem(itemObj, count)
	if (itemObj == nil) or type(count) ~= "number" then
		return
	end
	local refId
	local count	
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Add)
	StreamDataAdapter:WriteStr(writer, refId)
	writer:WriteShort(count)
	simulator:sendTcpActionEventInLua(writer)
end

function BagMgr:requestShowItemObject(playerId, itemId)
	if type(playerId) ~= "string" or type(itemId) ~= "string" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Item_Info)
	writer:WriteString(playerId)
	writer:WriteString(itemId)	
	simulator:sendTcpActionEventInLua(writer)
end	

function BagMgr:requestUseTransferStone(gridId,targetScene,transferInId)
	if type(gridId) ~= "number" or type(targetScene) ~= "string" or type(transferInId) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Use_TransferStone)
	writer:WriteShort(gridId)
	writer:WriteString(targetScene)	
	writer:WriteInt(transferInId)	
	simulator:sendTcpActionEventInLua(writer)
end

function BagMgr:quickSellFilterFunc(itemObj)
	if not itemObj then
		return false
	end						
	local refId = itemObj:getRefId()					
	local itemType = G_getItemTypeByRefId(refId)
	local property = itemObj:getStaticData().property
	local isCanSell = PropertyDictionary:get_isCanSale(property)
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local equipMgr = hero:getEquipMgr()
	
	if isCanSell == 0 then
		return false
	end
	if itemType == ItemType.eItemEquip and property then
		local professionId = 	PropertyDictionary:get_professionId(property)
		local gender = PropertyDictionary:get_gender(property)
		local heroProId = PropertyDictionary:get_professionId(hero:getPT())
		local heroGender = PropertyDictionary:get_gender(hero:getPT())	
		local compareFp = equipMgr:compareFp(itemObj)	
		 
		local quality = PropertyDictionary:get_quality(property)
		if quality==ItemQualtiy.White or quality==ItemQualtiy.Blue then
			if professionId~=heroProId and professionId~=0 then
				return true
			end	
			if gender~=0 and gender~= heroGender then
				return true
			end					
			if compareFp~=E_CompareRet.Greater then
				return true
			end 			
		else
			return false
		end
	else
		return false
	end												
end

function BagMgr:getQuickSellItemList()
	local ret = {}
	if table.isEmpty(self.itemList) then
		return
	end
	for k, v in ipairs(self.itemList) do
		if self:quickSellFilterFunc(v) then
			table.insert(ret, v)
		end
	end
	return ret
end