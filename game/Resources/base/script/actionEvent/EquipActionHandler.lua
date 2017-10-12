require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("object.equip.EquipObject")

EquipActionHandler = EquipActionHandler or BaseClass(ActionEventHandler)

local g_equipMgr = nil  

function EquipActionHandler:__init()	
	local handleNet_G2C_EquipList = function(reader)	
		
		self:handleNet_G2C_EquipList(reader)		
	end		
	local handleNet_G2C_EquipUpdate = function(reader)		
		self:handleNet_G2C_EquipUpdate(reader)		
	end
	local handleNet_G2C_OtherPlayerEquipList = function(reader)	
		self:handleNet_G2C_OtherPlayerEquipList(reader)		
	end	
	local chatEquipInfo = function (reader)
		self:handle_chatEquipInfo(reader)
	end
	self:Bind(ActionEvents.G2C_Equip_Info, chatEquipInfo) --用于聊天装备查看@叶俊华 2014.1.27
	self:Bind(ActionEvents.G2C_Equip_List,	handleNet_G2C_EquipList)
	self:Bind(ActionEvents.G2C_Equip_Update,handleNet_G2C_EquipUpdate)
	self:Bind(ActionEvents.G2C_OtherPlayer_EquipList,handleNet_G2C_OtherPlayerEquipList)			
end

function EquipActionHandler:handle_chatEquipInfo(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	
	local id = StreamDataAdapter:ReadStr(reader)
	local boadyId = StreamDataAdapter:ReadChar(reader)
	local posIndex = StreamDataAdapter:ReadChar(reader)
	local refId = StreamDataAdapter:ReadStr(reader)	
	
	if (refId ~= nil and id ~= nil and boadyId ~= nil and posIndex ~= nil) then	
		local pdCount = StreamDataAdapter:ReadChar(reader)
		local equipObj = EquipObject.New()
		
		for j = 1, pdCount do
			local pdType = StreamDataAdapter:ReadChar(reader)
			local dataLenght = StreamDataAdapter:ReadShort(reader)  --int->short
			local pd = getPropertyTable(reader)				
			if (pdType == 1) then 			--总属性字典
				equipObj:setPT(pd)	
				equipObj:setStaticData(G_getStaticDataByRefId(refId))	
			elseif (pdType == 2) then 	--洗练属性字典
				equipObj:setWashPT(pd)	
			else
				print("EquipActionHandler:explainEquipList unkown pd. pdType=")
			end
		end
											
		equipObj:setId(id)							
		equipObj:setBodyAreaId(boadyId)		
		equipObj:setPosId(posIndex)						
		equipObj:setRefId(refId)					
		equipObj:setSource(E_EquipSource.inBody)
		
		GlobalEventSystem:Fire(GameEvent.EventShowItemEquip, equipObj)
		--[[if (equipList[boadyId] == nil) then
			equipList[boadyId] = {}
		end		
		equipList[boadyId][posIndex] = equipObj
		if isEquipList then
			itemRecord[equipObj:getId()] = 1
		end--]]
	end
		
end

function EquipActionHandler:handleNet_G2C_EquipList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	g_equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local tequipList = self:explainEquipList(reader, true)	
	g_equipMgr:setEquipList(tequipList)
	GlobalEventSystem:Fire(GameEvent.EventEquipList)
end		
	        
function EquipActionHandler:handleNet_G2C_EquipUpdate(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local eventType = StreamDataAdapter:ReadChar(reader)
	local equipList = self:explainEquipList(reader)
	g_equipMgr:updateEquipList(eventType, equipList)    
end

function EquipActionHandler:explainEquipList(reader, isEquipList)
	local equipList = {{}};
	local xgcount = StreamDataAdapter:ReadChar(reader) --short->byte
	local bagMgr = G_getBagMgr()
	local itemRecord = bagMgr:getItemRecord()
 	for i = 1, xgcount do
		local id = StreamDataAdapter:ReadStr(reader)
		local boadyId = StreamDataAdapter:ReadChar(reader)
		local posIndex = StreamDataAdapter:ReadChar(reader)
		local refId = StreamDataAdapter:ReadStr(reader)	
		
		if (refId ~= nil and id ~= nil and boadyId ~= nil and posIndex ~= nil) then	
			local pdCount = StreamDataAdapter:ReadChar(reader)
			local equipObj = EquipObject.New()
			
			for j = 1, pdCount do
				local pdType = StreamDataAdapter:ReadChar(reader)
				local dataLenght = StreamDataAdapter:ReadShort(reader) --int ->short
				local pd = getPropertyTable(reader)				
				if (pdType == 1) then 			--总属性字典
					equipObj:setPT(pd)	
					equipObj:setStaticData(G_getStaticDataByRefId(refId))	
				elseif (pdType == 2) then 	--洗练属性字典
					equipObj:setWashPT(pd)	
				else
					print("EquipActionHandler:explainEquipList unkown pd. pdType=")
				end
			end
												
			equipObj:setId(id)							
			equipObj:setBodyAreaId(boadyId)		
			equipObj:setPosId(posIndex)						
			equipObj:setRefId(refId)					
			equipObj:setSource(E_EquipSource.inBody)
			
			if (equipList[boadyId] == nil) then
				equipList[boadyId] = {}
			end		
			equipList[boadyId][posIndex] = equipObj
			if isEquipList then
				itemRecord[equipObj:getId()] = 1
			end
		end
	end  
	return equipList
end		

function EquipActionHandler:handleNet_G2C_OtherPlayerEquipList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	g_equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local playerId = StreamDataAdapter:ReadStr(reader)
	local tequipList = self:explainEquipList(reader,playerId)
	g_equipMgr:setOtherPlayerEquipList(tequipList)
	g_equipMgr:setOtherPlayerId(playerId)
	GlobalEventSystem:Fire(GameEvent.EventOtherPlayerEquipList)
end		