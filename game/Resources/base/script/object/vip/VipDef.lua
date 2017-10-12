require "data.vip.vip"

function G_GetVipDescriptionByLevel(level)
	local pt = GameData.Vip["vip_"..level].description
	return PropertyDictionary:get_description(pt)
end

function G_GetVipDescriptionByTimesADay(level)
	local value = 0
	if level>0 then
		local data = GameData.Vip["vip_"..level]
		if data and data["property"] then
			value = data["property"]["timesADay"]
		end
	end
	return value
end

function G_GetVipWeaponAward(professionId)
	local data = GameData.Vip["vip_3"]
	local value
	if data and data["property"] then
		value = data.weaponData
	end			
	local equipTable = {}	
	for  k , v in pairs(value) do
		if  v.profession == tostring(professionId) then
			table.insert(equipTable,v.itemRefId)
		end
	end
	
	local sortFunc = function(a ,b)
		local levelA = tonumber(string.match(a,"_(%d+)_"))
		local levelB = tonumber(string.match(b,"_(%d+)_"))
				
		if levelA > levelB then
			return false
		else
			return true
		end
	end
		
	table.sort(equipTable ,sortFunc)
	return equipTable
end