--  生成装备锻造的相关属性：强化，强化激活，洗练
require("common.baseclass")
require("object.forging.ForgingDef")
require("data.item.equipStrengthening")
require ("data.item.equipWashProperty")
ForgingPropertyGenerator = ForgingPropertyGenerator or BaseClass()

function ForgingPropertyGenerator:create()
	return ForgingPropertyGenerator.New()
end

function ForgingPropertyGenerator:__init()
end	

function ForgingPropertyGenerator:__delete()
end

function ForgingPropertyGenerator:getStrengthenScrollPD(refId)
	local configData = GameData.EquipStrengthening.equip_strengthening_scroll.configData
	if (configData) then
		configData = configData[refId]
	end
	if (configData) then
		configData = configData.property
	end
	return configData
end	

function ForgingPropertyGenerator:getStrengthenPD(bodyArea, professionId, strengtheningLevel)
	local configData = GameData.EquipStrengthening.equip_strengthening_base.configData
	local strengthenPropertyId = self:calculateStrengthenPropertyId(bodyArea, professionId, strengtheningLevel)
	if (strengthenPropertyId == -1) then
		return nil
	end
	local tmp = configData[strengthenPropertyId]
	if (tmp) then
		return tmp.property
	else
		return nil
	end
end	

function ForgingPropertyGenerator:getWashPD(refId)
	
	local data = GameData.EquipWashProperty[refId]
	if (data) then
		data = data.property		
	end
	return data
end	

function ForgingPropertyGenerator:getStrengthenActivePD(refId, strengtheningLevel)
	if (strengtheningLevel > const_maxStrengthenLevel ) then
		strengtheningLevel = const_maxStrengthenLevel 
	end
	
--	refId = "equip_10_9000"
	if (refId == nil) then
		return
	end
	
	local data = GameData.EquipStrengthening
	data = data.equip_strengthening_expand	
	data = data.configData		
	if (data == nil) then
		return nil	
	end
	
	local ret = {}
	for i = 1, strengtheningLevel do
		local key = refId.."_"..i
		local propertys = data[key]
		if (propertys) then
			propertys = propertys.property
		end
		if (propertys) then	
			local level = PropertyDictionary:get_strengtheningLevel(propertys)			
			if (level)	then	
				ret[level] = propertys		
			end
		end
	end
	return ret
end	

function ForgingPropertyGenerator:calculateStrengthenPropertyId(bodyArea, professionId, strengtheningLevel)
	if (bodyArea == nil or professionId == nil or strengtheningLevel == nil) then
		return -1
	end
	local strengthenPropertyId =  professionId * 65536 + bodyArea * 256 + strengtheningLevel
--	CCLuaLog("ForgingPropertyGenerator:calculateStrengthenPropertyId strengthenPropertyId="..strengthenPropertyId)
	return strengthenPropertyId
end	