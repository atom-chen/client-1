require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("data.code")

AwardActionHandler = AwardActionHandler or BaseClass(ActionEventHandler)

function AwardActionHandler:__init()
	local openSevenLoginView = function(reader)
		local awardMgr = GameWorld.Instance:getAwardManager()
		reader = tolua.cast(reader,"iBinaryReader")	
		local data = {}
		data.openServiceDate = StreamDataAdapter:ReadStr(reader)
		data.whichDay = StreamDataAdapter:ReadChar(reader) --int->byte	
		local count = 	StreamDataAdapter:ReadChar(reader)	--short->byte
		data.days = {}
		for i=1,count do
			data.days[i] = {}
			data.days[i].stage = StreamDataAdapter:ReadStr(reader)			
			data.days[i].status = StreamDataAdapter:ReadChar(reader)
			local itemCount = StreamDataAdapter:ReadChar(reader) --short->byte
			data.days[i].award = {}
			for j=1,itemCount do				
				data.days[i].award[j] = {}
				data.days[i].award[j].itemRefId = StreamDataAdapter:ReadStr(reader)
				data.days[i].award[j].number = StreamDataAdapter:ReadInt(reader)
				data.days[i].award[j].bind = StreamDataAdapter:ReadChar(reader)				
			end
		end
		if data.whichDay < 1 or data.whichDay > 7 then
			return
		end
		awardMgr:setSeventLoginData(data)
		GlobalEventSystem:Fire(GameEvent.EventFreshSevenLoginView)
	end

	local popupSevenLoginView = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")	
		local haveReceive = StreamDataAdapter:ReadChar(reader)
		GlobalEventSystem:Fire(GameEvent.EventPopupSevenLoginView,haveReceive)
	end
	self:Bind(ActionEvents.G2C_SevenLogin_ReceiveState,openSevenLoginView)	
	self:Bind(ActionEvents.G2C_SevenLogin_HaveReceive,popupSevenLoginView)
	
	
	
	local handle_G2C_Digs_List = function(reader)
		self:handle_G2C_Digs_List(reader)
	end
	local handleNet_G2C_Digs_Update = function(reader)
		self:handleNet_G2C_Digs_Update(reader)
	end
	local handleNet_G2C_Digs_Result = function(reader)
		self:handleNet_G2C_Digs_Result(reader)
	end
	
	self:Bind(ActionEvents.G2C_Digs_List,handle_G2C_Digs_List)
	self:Bind(ActionEvents.G2C_Digs_Update, handleNet_G2C_Digs_Update)
	self:Bind(ActionEvents.G2C_Digs_Result,handleNet_G2C_Digs_Result)

end	

function AwardActionHandler:__delete()
	
end	

function AwardActionHandler:handle_G2C_Digs_List(reader)
	local awardMgr = GameWorld.Instance:getAwardManager()
	reader = tolua.cast(reader,"iBinaryReader")	
	local capacity = StreamDataAdapter:ReadShort(reader)
	awardMgr:setCapacity(capacity)
	local map = self:explainItemData(reader)
	awardMgr:setItemMap(map)
	UIManager.Instance:hideLoadingHUD()
	GlobalEventSystem:Fire(GameEvent.EventShowDigWareHouse)	
end

function AwardActionHandler:handleNet_G2C_Digs_Update(reader)
	UIManager.Instance:hideLoadingHUD()
	local awardMgr = GameWorld.Instance:getAwardManager()	
	reader = tolua.cast(reader,"iBinaryReader")	
	local capacity = StreamDataAdapter:ReadShort(reader)
	awardMgr:setCapacity(capacity)	
	if capacity == 0 then
		GlobalEventSystem:Fire(GameEvent.EventClearAllHouseItem)
	else
		local updateType = StreamDataAdapter:ReadChar(reader)	
		if (updateType > E_UpdataEvent.Modify or updateType < E_UpdataEvent.Add) then
			return
		end
		local map = self:explainItemData(reader)
		awardMgr:updateItemMap(updateType,map)	
	end
end

function AwardActionHandler:handleNet_G2C_Digs_Result(reader)
	local awardMgr = GameWorld.Instance:getAwardManager()
	awardMgr:clearUpdateShowList()	
	reader = tolua.cast(reader,"iBinaryReader")	
	local count = StreamDataAdapter:ReadShort(reader)
	for i=1,count do
		local refId = StreamDataAdapter:ReadStr(reader)
		local num = StreamDataAdapter:ReadInt(reader)
		awardMgr:setUpdateShowList(refId,num)
	end
	GlobalEventSystem:Fire(GameEvent.EventShowDigAwardList)
end

function AwardActionHandler:explainItemData(reader)
	local map = {}
	local count = StreamDataAdapter:ReadShort(reader)
	for i= 1,count do
		local id = StreamDataAdapter:ReadStr(reader)
		local gridId = StreamDataAdapter:ReadShort(reader)		
		local itemRefId = StreamDataAdapter:ReadStr(reader)
		local number = StreamDataAdapter:ReadShort(reader)--int->short
		local bindStatus =StreamDataAdapter:ReadChar(reader)
		local itemObj = ItemObject.New()
		local pt = {}
		itemObj:setId(id)
		itemObj:setGridId(gridId)		
		pt.number = number
		itemObj:setRefId(itemRefId)
		pt.bindStatus = bindStatus
		itemObj:setPT(pt)
		itemObj:setStaticData(G_getStaticDataByRefId(itemObj:getRefId()))
		table.insert(map, itemObj)		
	end
	return map 
end