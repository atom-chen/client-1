require("data.npc.npc")
require"data.scene.scene"
require"data.npc.collect"	
function G_GetRecordByRefId(refId)
	
	return GameData.Npc[refId]
end

function G_GetNpcJobTypeByRefId(refId)
	if(string.sub(refId,5,7) == "col")then
		return -1
	end
	
	local jobPt = GameData.Npc[refId].job
	if(jobPt ~= "") then
		return jobPt[1].jobType
	else		
		return -1
	end
end

function G_GetCollectModeIdByRefId(refId)
	local modeId = 2026
	local pt = GameData.Collect[refId].property	
	if pt then
		modeId = PropertyDictionary:get_modelId(pt)
	end
	return modeId
end

function G_GetNpcTransList(refId)
	
	return GameData.Npc[refId].job[1].transList
end

function G_GetNpcShopList(refId)
	if refId then
		return GameData.Npc[refId].job[1].shopList
	end		
end

function G_GetSceneType(sceneId)
	
	
	return GameData.Scene[sceneId].kind
end

function G_GetLimitLevel(sceneId)
	
	return PropertyDictionary:get_openLevel(GameData.Scene[sceneId].property)
end

function G_GetNpcFunctionType(refId)
	
	return GameData.Npc[refId].job[1].link
end

function G_GetCollectSeconds(refId)
	local timePt =  GameData.Collect[refId].property
	return PropertyDictionary:get_pluckTime(timePt)
end

function G_GetNpcHeadIconName(refId)
	
	local headPt =  GameData.Npc[refId].head
	return headPt["head"]
end

function G_GetNpcSignName(refId)
	local Pt =  GameData.Npc[refId]
	return Pt.sight
end