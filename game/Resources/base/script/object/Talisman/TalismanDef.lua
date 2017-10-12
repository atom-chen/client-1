require "data.talisman.talisman"
require "data.talisman.citta"

Talisman_State = {
	NotAchieve = 0,
	NotActivate = 1,
	Activate = 2,
}

Talisman_Operate_Type = {
	Achieve = 1,
	Activate = 2,
	CancelActivate = 3,
}  

function GetPtByRefId(refId)
	local record = GameData.Talisman["talisMan_base"].configData[refId]
	return record.property
end

function GetRecordByRefId(refId)
	local data = GameData.Talisman
	local record = data["talisMan_base"].configData[refId]	
	return record
end

function GetCittaRecordByLevel(level)
	local record = GameData.Citta["citta_"..tostring(level)]
	return record
end

function GetRequestItemAndNum(refId)
	local questData = GameData.Talisman["talisMan_base"].configData[refId].questData
	return questData.itemRefId,questData.number
end

function GetLessSuipianTalisListByNum(number)
	local list = {}	
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local suipianRefId
	local needNum
	local refId
	local currentNum  
	for index = 1, 10  do 	
		refId = "title_" .. index .. "_0"				
		suipianRefId , needNum = GetRequestItemAndNum(refId)
		currentNum =  bgmgr:getItemNumByRefId(suipianRefId) + bgmgr:getItemNumByRefId("item_suipian")			
		if ( needNum - currentNum ) <= number  then
			list[suipianRefId] = index
		end
	end
	return list
end


function GetTalisNameByIndex(refId)
	local record = GameData.Talisman["talisMan_base"].configData[refId.."_"..tostring(0)]
	local name  = " "	
	if record then
		name = PropertyDictionary:get_name(record.property)
	end
	return name
end

function GetAttributeDetailsByRefId(refId)
	local record = GameData.Citta[refId]
	return record
end

function GetDescriptionByRefId(refId)
	local record = GetRecordByRefId(refId) 
	if record then
		local pt = record.property		
		local str = PropertyDictionary:get_description(pt)	
		return str
	end	
end

function GetUseMaterialCountByRefId(level)
	if level < 1 then
		level = 1
	end
	local record = GetCittaRecordByLevel(level)
	if 	record then
		local pt = record.property		
		local cnt = PropertyDictionary:get_useMaterialCount(pt)	
		return cnt
	end	
end

