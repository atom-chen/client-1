require("common.baseclass")
require("actionEvent.ActionEventDef")
--require("object.activity.SevenLoginObject")
require("ui.UIManager")
require("data.activity.digs")
AwardMgr = AwardMgr or BaseClass()

function AwardMgr:__init()
	self.displayItemList = {}		--չʾ�б�
	self.houseItemList = {}		--�ֿ��б�
	self.showList = {}
	self.showFlag = false
	self.hasShow = false
	self:updateGiftcard()
end

function AwardMgr:__delete()
	if self.sevenLoginObject then
		self.sevenLoginObject:DeleteMe()
		self.sevenLoginObject = nil
	end
	if table.size(self.displayItemList) > 0 then
		for i,v in pairs(self.displayItemList) do
			v:DeleteMe()
		end
	end
	if table.size(self.houseItemList) > 0 then
		for i,v in pairs(self.houseItemList) do
			v:DeleteMe()
		end
	end
	if self.updateItemId then
		GlobalEventSystem:UnBind(self.updateItemId)
		self.updateItemId = nil
	end
end

function AwardMgr:clear()
								--�ľ�todo
	if self.seventLoginData then
		self.seventLoginData = nil
	end	
	if table.size(self.displayItemList) > 0 then
		for i,v in pairs(self.displayItemList) do
			v:DeleteMe()
		end
		self.displayItemList = {}
	end
	if table.size(self.houseItemList) > 0 then
		for i,v in pairs(self.houseItemList) do
			v:DeleteMe()
		end
		self.houseItemList = {}
	end
end

--������¼

function AwardMgr:setSeventLoginData(data)
	if type(data) == "table" then
		self.seventLoginData = data
	end
end

function AwardMgr:getOpenServiceDate()
	if self.seventLoginData then
		if self.seventLoginData.openServiceDate then
			return self.seventLoginData.openServiceDate
		end
	end	
end

function AwardMgr:getWhichDay()
	if self.seventLoginData then
		if self.seventLoginData.whichDay then
			return self.seventLoginData.whichDay
		end
	end	
end

function AwardMgr:getAwardList(whichDay)
	if type(whichDay) ~= "number" then
		return nil
	end
	if self.seventLoginData then
		if self.seventLoginData.days then
			if self.seventLoginData.days[whichDay] then
				if self.seventLoginData.days[whichDay].award then
					return self.seventLoginData.days[whichDay].award
				end
			end
		end
	end	
	
end

function AwardMgr:getStatus(whichDay)
	if type(whichDay) ~= "number" then
		return nil
	end
	if self.seventLoginData then
		if self.seventLoginData.days then
			if self.seventLoginData.days[whichDay] then
				if self.seventLoginData.days[whichDay].status then
					return self.seventLoginData.days[whichDay].status
				end
			end
		end
	end	
end	

function AwardMgr:setStatus(whichDay,status)
	if type(whichDay) == "number" and type(status) == "number" then		
		if self.seventLoginData then
			if self.seventLoginData.days then
				if self.seventLoginData.days[whichDay] then
					if self.seventLoginData.days[whichDay].status then
						self.seventLoginData.days[whichDay].status = status
					end
				end
			end
		end	
	end	
end

function AwardMgr:getStage(whichDay)
	if type(whichDay) ~= "number" then
		return nil
	end
	if self.seventLoginData then
		if self.seventLoginData.days then
			if self.seventLoginData.days[whichDay] then
				if self.seventLoginData.days[whichDay].stage then
					return self.seventLoginData.days[whichDay].stage
				end
			end
		end
	end	
	
end

function AwardMgr:getSelectDay()
	if self.seventLoginData then
		if self.seventLoginData.whichDay then
			return self.seventLoginData.whichDay
		end
	end
end

function AwardMgr:setSelectDay(whichDay)
	if type(whichDay) == "number" then	
		if self.seventLoginData then
			if self.seventLoginData.whichDay then
				self.seventLoginData.whichDay = whichDay
			end
		end
	end
end

function AwardMgr:requestReceiveState()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_SevenLogin_ReceiveState)
	simulator:sendTcpActionEventInLua(writer)
end

function AwardMgr:requestHadReceive(stage)
	if type(stage) == "string" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_SevenLogin_HadReceive)
		StreamDataAdapter:WriteStr(writer, stage)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function AwardMgr:requestReReceive(stage)
	if type(stage) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_SevenLogin_ReReceive)
		StreamDataAdapter:WriteStr(writer, stage)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function AwardMgr:requestHaveReceive()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_SevenLogin_HaveReceive)
	simulator:sendTcpActionEventInLua(writer)
end



function AwardMgr:getDigTreasureShowList(listCondition)
	local itemInfo = GameData.Digs["digsshow"]
	if itemInfo and itemInfo.configData then
		local data = itemInfo.configData	
		if data then
			local itemData = {}
			for i,v in pairs(data) do
				if listCondition and v.property.professionId == listCondition then
					itemData[i] = v
				end
			end
			return itemData
		end
	end
end
--����ֿ��б�
function AwardMgr:requestWareHouseList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Digs_List)
	simulator:sendTcpActionEventInLua(writer)
end
--�����ڱ�
function AwardMgr:requestDigTreasure(digType)
	if digType == nil then
		CCLuaLog("ArgError:AwardMgr:requestDigTreasure")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Digs_Type)
	StreamDataAdapter:WriteChar(writer, digType)
	simulator:sendTcpActionEventInLua(writer)
end
--����ֿ���Ʒ���뱳��
function AwardMgr:requestRemoveItem(index)
	if index == nil then
		CCLuaLog("ArgError:AwardMgr:requestRemoveItem")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Digs_Switch)
	StreamDataAdapter:WriteShort(writer, index)
	simulator:sendTcpActionEventInLua(writer)
end

--��ǰ������Ʒ��
function AwardMgr:setCapacity(capacity)
	self.capacity = capacity
end

function AwardMgr:getCapacity()
	return self.capacity
end

function AwardMgr:setItemMap(map)
	if table.size(self.houseItemList)>0 then
		for i,v in pairs(self.houseItemList) do
			v:DeleteMe()
		end	
	end
	self.houseItemList = map
end

function AwardMgr:getItemList()
	return self.houseItemList
end

function AwardMgr:setIsShowAllGetTips(bshow)
	self.showFlag = bshow
end
function AwardMgr:getIsShowAllGetTips()
	return self.showFlag
end

function AwardMgr:updateItemMap(eventType, map)
	if not eventType then
		CCLuaLog("Arg'Type'Error:AwardMgr:updateItemMap")
		return
	end
	if type(map)~="table" then
		CCLuaLog("Arg'table'Error:AwardMgr:updateItemMap")
		return
	end
	if (E_UpdataEvent.Add == eventType) then
		for grid, item in pairs(map) do
			self:addItem(item)
		end
		GlobalEventSystem:Fire(GameEvent.EventHouseUpdate, eventType, map)
	elseif (E_UpdataEvent.Delete == eventType) then
		for grid, item in pairs(map) do
			local oldIndex, oldItem = self:findItem(item:getGridId())
			if oldItem then
				item:setId(oldItem:getId()) 	--ɾ����ʱ�򣬷�������û�н�id����������Ҫ�ͻ��˲��ϡ�
				item:setRefId(oldItem:getRefId())				
				table.remove(self.houseItemList, oldIndex)
				local showAllGetFlag  = self:getIsShowAllGetTips()
				if showAllGetFlag == false then
					local name = G_getStaticPropsName(oldItem:getRefId())
					local tipStr = string.format("%s%s%s",Config.Words[13522],name,Config.Words[13523])
					UIManager.Instance:showSystemTips(tipStr)
				elseif showAllGetFlag == true then
					if self.hasShow == false and self:isDigWareHouseEmpty() then
						UIManager.Instance:showSystemTips(Config.Words[13508])	
						self:setIsShowAllGetTips(false)
						self.hasShow = true					
					end							
				end					
			end
		end					
		self.hasShow = false
		GlobalEventSystem:Fire(GameEvent.EventHouseUpdate, eventType, map)
		
	elseif (E_UpdataEvent.Modify == eventType) then
		local addItems = {}
		local itemChangeCountList = {}
		local modifiedItems = {}
		local hasModified = false
		local hasAdded = false
		for grid, item in pairs(map) do			--�Ķ���ʱ�򣬷���˻ὫItem���������Է����������Կ���ֱ���滻
			local refId = item.refId
			local newNum = PropertyDictionary:get_number(item.table)
			local oldIndex, oldItem = self:findItem(item:getGridId())
			local oldNum = 0
			if oldItem == nil then				--���������ܽ�������ƷҲ�Ը�����Ʒ����ʽ��������������Ҫ����
				table.insert(addItems, item)
				hasAdded = true
				self:addItem(item)
			else
				oldNum = PropertyDictionary:get_number(oldItem.table)
				table.insert(modifiedItems, item)
				hasModified = true
				self:replaceItemWithIndex(item, oldIndex)
			end				
		end
		if hasAdded then
			GlobalEventSystem:Fire(GameEvent.EventHouseUpdate, E_UpdataEvent.Add, addItems)
		end
		if hasModified then
			GlobalEventSystem:Fire(GameEvent.EventHouseUpdate, E_UpdataEvent.Modify, modifiedItems)
		end		
	end
end

function AwardMgr:setUpdateShowList(refId,num)
	local showItem = {}
	showItem.refId = refId
	showItem.num = num
	table.insert(self.showList,showItem)
end
function AwardMgr:getUpdateShowList()
	if table.size(self.showList) > 0 then
		return self.showList
	else
		return nil
	end
end

function AwardMgr:clearUpdateShowList()
	self.showList = {}
end
function AwardMgr:replaceItemWithIndex(itemObj, index)
	if index and itemObj then
		table.remove(self.houseItemList, index)
		table.insert(self.houseItemList, index, itemObj)
	end
end

function AwardMgr:findItem(gridId)
	for k, v in ipairs(self.houseItemList) do
		if v:getGridId() == gridId then
			return k, v
		end
	end
end
--����һ����Ʒ
function AwardMgr:addItem(itemObj)
	if not itemObj then
		CCLuaLog("ArgError:AwardMgr:addItem")
		return
	end
	local index = table.maxn(self.houseItemList)
	while true do
		if index >= 1 then				
			if self.compareItem(itemObj, self.houseItemList[index], true) then
				table.insert(self.houseItemList, index + 1, itemObj)
				break
			else
				index = index - 1
			end
		else
			table.insert(self.houseItemList, 1, itemObj)
			break
		end
	end
end

function AwardMgr.compareItem(agg, bgg, bMore)
	if agg == nil or bgg == nil then
		CCLuaLog("ArgError:AwardMgr:compareItem")
		return
	end
	if bMore then
		return PropertyDictionary:get_itemSortId(agg:getStaticData().property) > PropertyDictionary:get_itemSortId(bgg:getStaticData().property)
	else
		return PropertyDictionary:get_itemSortId(agg:getStaticData().property) < PropertyDictionary:get_itemSortId(bgg:getStaticData().property)
	end
end

function AwardMgr:updateGiftcard()
	local updateItems = function(updateTypes,itemMap)
		if itemMap then
			for i,v in pairs(itemMap) do
				if v.refId == "item_giftcard" then
					GlobalEventSystem:Fire(GameEvent.EventGiftCardUpdate)
				end
			end
		end
	end
	self.updateItemId = GlobalEventSystem:Bind(GameEvent.EventItemUpdate, updateItems)
end

function AwardMgr:canGetAllReward()
	local bagNullCount = G_getBagMgr():getCurCap() - G_getBagMgr():getItemCount()
	if bagNullCount < self.capacity then
		return false
	else
		return true
	end
end

function AwardMgr:isDigWareHouseEmpty()
	if self.houseItemList then
		return table.isEmpty(self.houseItemList)
	end
end