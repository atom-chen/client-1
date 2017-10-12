require("common.baseclass")
require("data.worldBoss.payonPalace")
BossTempleMgr = BossTempleMgr or BaseClass()

function BossTempleMgr:__init()

end

function BossTempleMgr:clear()
	
end

function BossTempleMgr:__delete()
	
end

function BossTempleMgr:requestEnterBossTemple(SceneRefId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_BossTemple_Enter)
	writer:WriteString(SceneRefId)	
	simulator:sendTcpActionEventInLua(writer)
end

function BossTempleMgr:requestExitBossTemple()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_BossTemple_Exit)	
	simulator:sendTcpActionEventInLua(writer)
end	

function BossTempleMgr:getBossTempleCount()
	return  table.size(GameData.PayonPalace)
end

function BossTempleMgr:getNeedItemRefIdAndNum(index)
	local pt = GameData.PayonPalace["payonPalace_" .. index]
	if pt and pt.activityData and pt.activityData[1] then
		local requirePt =  pt.activityData[1].consumeitems
		if requirePt and requirePt[1] then
			return  requirePt[1].itemRefId , tonumber(requirePt[1].number)
		end
	end
end

function BossTempleMgr:getOpenDate(index)
	local pt = GameData.PayonPalace["payonPalace_" .. index]
	if pt and pt.time then
		local duration =  pt.time.duration
		if duration then	
			local str = string.gsub(duration,"|","-")	
			local dataStr = Config.Words[25805]  .. str
			return  dataStr
		end
	end
end

function BossTempleMgr:getTransferScene(index)
	local pt = GameData.PayonPalace["payonPalace_" .. index]
	if pt  then
		local sceneList = string.split(pt.sceneRefId,"|")
		return sceneList[1]
	end
end

function BossTempleMgr:getTempleSceneAward(index)
	local pt = GameData.PayonPalace["payonPalace_" .. index]
	if pt and pt.activityData and pt.activityData[1] then
		local awardPt =  pt.activityData[1].planshow		
		return awardPt
	end
end


function BossTempleMgr:getTempleProperty(index)
	local pt = GameData.PayonPalace["payonPalace_" .. index]
	if pt and pt.activityData and pt.activityData[1] then
		local propertyPt =  pt.activityData[1].property		
		return propertyPt
	end
end

