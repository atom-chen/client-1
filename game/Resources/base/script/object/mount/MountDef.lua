
--坐骑状态枚举
eMountPositionInBag =0
eMountPositionOffBag=1
 
eEquip = 1
eNotEquip = 0
eEquipStateDisEquip = 0
eEquipStateEquip = 1

eEquipStateRideOff = 0
eEquipStateRideOn = 1

eMountCommandEquip = 1
eMountCommandDisEquip =0

eMountCommandRideOff = 0
eMountCommandRideOn = 1

eMountOpResultFaild =0
eMountOpResultSuccess =1
--阶对应的最高级坐骑RefId
minLevelMountIdList = {"ride_1","ride_5","ride_9","ride_13","ride_17","ride_21","ride_25","ride_29","ride_33","ride_37"}
require "data.mount.mount"

--获取当前显示的RefId列表
function G_GetCurrentList(refId)
	if( refId == -1 ) then
		return minLevelMountIdList
	end
		
	local currentlist = minLevelMountIdList
	local index = tonumber(string.sub(refId,6))
	
	
	local pos = (index - index%4)/4
	if( index - 4*pos > 0 ) then
		pos = pos + 1
	end	
		
	for i = 1 , 10 do
		if(i< pos) then
			currentlist[i] = "ride_"..i*4
		elseif(i> pos) then
			currentlist[i] = "ride_" ..(i*4 -3) 
		else
			currentlist[i] = "ride_"  .. index
		end
	end			
	return currentlist
end

function G_GetMountRecordByRefId( refId )
	
	return GameData.Mount[refId]
end

function G_GetNeedItemNum(refId)
	
	return GameData.Mount[refId].property["rideMedicineMaxConsume"]
end

function G_GetMountIcon(refId)
	
	return PropertyDictionary:get_iconId(GameData.Mount[refId].property)
end

