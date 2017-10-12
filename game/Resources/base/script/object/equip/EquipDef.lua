local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size = VisibleRect:getScaleSize(CCSizeMake(450, 400)) 
local const_scale = VisibleRect:SFGetScale()

-- 装备的穿戴部位id
E_BodyAreaId = 
{
	eWeapon 		= 1,
	eCloth 			= 2,
	eHelmet 		= 3,
	eBelt 			= 4,
	eShoe 			= 5,
	eNecklace	 	= 6,
	eBracelet 		= 7,
	eRing 			= 8,
	eMedal 			= 9,
	eWing 			= 10,
}	
	
function G_getBindName(bind) 
	if (bind == 1) then
		return "已绑定"
	else
		return "未绑定"
	end
end

function G_getBodyAreaName(bodyAreaId)
	return G_getEquipMgr():getHeroEquipInfo()[bodyAreaId].name
end	

function G_getBodyAreaId(equipObj)
	local data = equipObj:getStaticData()
	if (data) then
		return PropertyDictionary:get_areaOfBody(data.property)
	end
	return nil
end

function G_GetEquipStrenthenPD(equipObj)
	local bodyArea
	local  professionId
	
	local data = equipObj:getStaticData()
	if (data) then
		bodyArea = PropertyDictionary:get_areaOfBody(data.property)
		professionId = PropertyDictionary:get_professionId(data.property)
	end
	local  strengtheningLevel = PropertyDictionary:get_strengtheningLevel(equipObj:getPT())
	return G_getForgingMgr():getPropertyGenerator():getStrengthenPD(bodyArea, professionId, strengtheningLevel)
end	
--计算装备强化战斗力
function G_caculateEquipStrenthenFightValue(equipObj)
	local strenthenPD = G_GetEquipStrenthenPD(equipObj)
	local strengtheningLevel = PropertyDictionary:get_strengtheningLevel(equipObj:getPT())
	local strenthenActivatePDList = G_getForgingMgr():getPropertyGenerator():getStrengthenActivePD(equipObj:getRefId(),strengtheningLevel)
	if type(strenthenPD) ~= "table" then
		return 0
	end
	local strenthenFightValue = G_getFightValue(strenthenPD)	
	local activateFightValue = 0
	if strenthenActivatePDList and type(strenthenActivatePDList) == "table" then		
		for k , v  in pairs(strenthenActivatePDList) do
			activateFightValue = activateFightValue + G_getFightValue(v)	
		end
	end
	
	if strenthenFightValue then
		return strenthenFightValue + activateFightValue
	else
		return 0
	end
end
--计算装备基础战斗力
function G_caculateEquipBaseFightValue(equipObj)
	local basePD = equipObj:getStaticData().effectData
	if type(basePD) ~= "table" then
		return 0
	end
	local fightValue = G_getFightValue(basePD)
	if fightValue then
		return fightValue
	else
		return 0
	end
end

--计算装备洗练战斗力
function G_caculateEquipWashFightValue(equipObj)
	local wash = equipObj.washPT
	if type(wash) ~= "table" then
		return 0
	end
	local fightValue = G_getFightValue(wash)
	if fightValue then
		return fightValue
	else
		return 0
	end
end