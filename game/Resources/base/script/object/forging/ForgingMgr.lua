--  背包（数据管理）
require("common.baseclass")
require("object.forging.ForgingPropertyGenerator")
require("utils.PDOperator")

ForgingMgr = ForgingMgr or BaseClass()

function ForgingMgr:__init()
	self.openFlag = {}	
end		

function ForgingMgr:getPropertyGenerator()
	if (self.propertyGenerator == nil) then
		self.propertyGenerator =  ForgingPropertyGenerator.New()		
	end
	return self.propertyGenerator
end

function ForgingMgr:__delete()
	if (self.propertyGenerator ~= nil) then
		self.propertyGenerator:DeleteMe()
		self.propertyGenerator = nil
	end	
end

function ForgingMgr:clear()
	if (self.propertyGenerator ~= nil) then
		self.propertyGenerator:DeleteMe()
		self.propertyGenerator = nil
	end	
end	


--强化背包里的装备
function ForgingMgr:requestBag_Streng(equipObj, yuanbao,isUseBindFirst) 
	if (equipObj == nil) or (type(yuanbao) ~= "number") or (type(isUseBindFirst) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Bag_Streng)	
	writer:WriteShort(equipObj:getGridId())
	writer:WriteInt(yuanbao)
	writer:WriteChar(PropertyDictionary:get_strengtheningLevel(equipObj:getPT()))
	writer:WriteChar(isUseBindFirst)
	simulator:sendTcpActionEventInLua(writer)	
end


--强化身上装备
function ForgingMgr:requestBody_Streng(equipObj, yuanbao, isUseBindFirst)
	if (equipObj == nil) or (type(yuanbao) ~= "number") or (type(isUseBindFirst) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Body_Streng)	
	writer:WriteChar(equipObj:getBodyAreaId())
	writer:WriteChar(equipObj:getPosId())
	writer:WriteInt(yuanbao)
	writer:WriteChar(PropertyDictionary:get_strengtheningLevel(equipObj:getPT()))
	writer:WriteChar(isUseBindFirst)
	simulator:sendTcpActionEventInLua(writer)	
end

--强化卷强化背包装备
function ForgingMgr:requestBag_StrengScroll(equipObj, strengScrollGridId)
	if (equipObj == nil) or (type(strengScrollGridId) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Bag_StrengScroll)	
	writer:WriteShort(strengScrollGridId)
	writer:WriteShort(equipObj:getGridId())
	simulator:sendTcpActionEventInLua(writer)
end	

--强化卷强化身上装备
function ForgingMgr:requestBody_StrengScroll(equipObj, strengScrollGridId)
	if (equipObj == nil) or (type(strengScrollGridId) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Body_StrengScroll)	
	writer:WriteShort(strengScrollGridId)
	writer:WriteChar(equipObj:getBodyAreaId())
	writer:WriteChar(equipObj:getPosId())
	simulator:sendTcpActionEventInLua(writer)
end

--洗练背包装备
function ForgingMgr:requestBag_Wash(equipObj, lockSymbolIdList, isUseBindFirst)
	if (equipObj == nil) or (type(lockSymbolIdList) ~= "table") or (type(isUseBindFirst) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Bag_Wash)	
	writer:WriteShort(equipObj:getGridId())
	writer:WriteChar(isUseBindFirst)
	local count = table.size(lockSymbolIdList)
	writer:WriteShort(count)
	
	for key, value in pairs(lockSymbolIdList) do
		StreamDataAdapter:WriteStr(writer, value)
	end
	
	simulator:sendTcpActionEventInLua(writer)
end

--洗练身上装备
function ForgingMgr:requestBody_Wash(equipObj, lockSymbolIdList,isUseBindFirst)
	if (equipObj == nil) or (type(lockSymbolIdList) ~= "table") or (type(isUseBindFirst) ~= "number") then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Body_Wash)	
	writer:WriteChar(equipObj:getBodyAreaId())
	writer:WriteChar(equipObj:getPosId())
	writer:WriteChar(isUseBindFirst)
	local count
	if lockSymbolIdList == nil then
		count = 0
	else
		count = table.size(lockSymbolIdList)
	end
	writer:WriteShort(count)
	
	for key, value in pairs(lockSymbolIdList) do
		StreamDataAdapter:WriteStr(writer, value)
	end
	
	simulator:sendTcpActionEventInLua(writer)
end

--分解背包装备
function ForgingMgr:requestBag_Decompose(equipList)
	local count = table.size(equipList)
	if count < 1 then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Bag_Decompose)	
	writer:WriteShort(count)
	for key, equipObj in pairs(equipList) do
		writer:WriteShort(equipObj:getGridId())
	end
	simulator:sendTcpActionEventInLua(writer)
end

--分解身上装备
function ForgingMgr:requestBody_Decompose(equipList)
	if (equipList == nil or table.size(equipList) == 0) then
		return
	end		
	local simulator = SFGameSimulator:sharedGameSimulator()	
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Body_Decompose)	
	local count = table.size(equipList)
	writer:WriteShort(count)
	for key, equipObj in pairs(equipList) do
		writer:WriteChar(equipObj:getBodyAreaId())
		writer:WriteChar(equipObj:getPosId())
	end
	simulator:sendTcpActionEventInLua(writer)
end

function ForgingMgr:setOpenFlag(key,openFlag)
	if openFlag == 1 then
		self.openFlag[key] = true
	else
		self.openFlag[key] = false
	end
end	

function ForgingMgr:getOpenFlag(key)
	if self.openFlag[key] then
		return self.openFlag[key]
	end
end