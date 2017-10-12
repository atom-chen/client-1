require "data.activity.monsterInvasion"	
MonstorInvasionMgr = MonstorInvasionMgr or BaseClass()

function MonstorInvasionMgr:__init()
	self.bInActivity = false
	self.bDeath = false
	self.remainingTime = 0
	self.bossRefreshTime = 0
	self.exp = 1
end

function MonstorInvasionMgr:__delete()
	
end

function MonstorInvasionMgr:requestEnterMonstorInvasionActivity()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MonsterIntrusion_EnterMap)
	local sceneId = GameData.Scene[self:getSceneId()].refId
	local x = GameData.Scene[self:getSceneId()].tranferIn[1].x
	local y = GameData.Scene[self:getSceneId()].tranferIn[1].y
	writer:WriteString(sceneId)	
	writer:WriteInt(x)
	writer:WriteInt(y)
	simulator:sendTcpActionEventInLua(writer)
end

function MonstorInvasionMgr:requestExitMonstorInvasionActivity()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MonsterIntrusion_LeaveMap)	
	simulator:sendTcpActionEventInLua(writer)
end

function MonstorInvasionMgr:requestIsMonstorInvasionStart()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MonsterIntrusion_IsStart)	
	simulator:sendTcpActionEventInLua(writer)
end

--请求活动剩余时间
function MonstorInvasionMgr:requestRemainingTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MonsterIntrusion_ContinuTime)	
	simulator:sendTcpActionEventInLua(writer)
end	

function MonstorInvasionMgr:setMonsterRefId(refId)
	self.monsterRefId = refId
end	

function MonstorInvasionMgr:getMonstorRefId()
	return self.monsterRefId
end

function MonstorInvasionMgr:setBossSceneRefId(sceneRefId)
	self.sceneRefId = sceneRefId
end	

function MonstorInvasionMgr:getBossSceneRefId()
	return self.sceneRefId
end	

function MonstorInvasionMgr:getSceneId()
	return GameData.MonsterInvasion["monsterInvasion1"]["sceneRefId"]
end

function MonstorInvasionMgr:setStartFlag(bStart)
	self.bStart = bStart
end

function MonstorInvasionMgr:isStart()
	return (self.bStart==1)
end

function MonstorInvasionMgr:setisInActivity(bActivity)
	self.bInActivity = bActivity
end

function MonstorInvasionMgr:isInActivity()
	local mapRefId = GameWorld.Instance:getMapManager():getCurrentMapRefId()	
	--local activityType = GameWorld.Instance:getMapManager():getMapActivityType(mapRefId)
	if  mapRefId == "S218" or  mapRefId == "S219" then
		return true
	else
		return false
	end
end

function MonstorInvasionMgr:setBossDeath(bDeath)
	self.bDeath = bDeath
end

function MonstorInvasionMgr:isBossDeath()
	return self.bDeath
end

function MonstorInvasionMgr:getMonsterInvasionOpenTime()
	local time = GameData.MonsterInvasion["monsterInvasion1"]["time"]["duration"]
	time = string.split(time, "&")
	local timeStr = ""
	if time and time[1] then 
		local tmpTime = string.split(time[1], "|")
		if tmpTime then 
			timeStr = string.sub(tmpTime[1],1,5) .. " - " .. string.sub(tmpTime[2],1,5)
		end
	end
	if time and time[2] then 
		local tmpTime = string.split(time[2], "|")
		if tmpTime then 
			timeStr = timeStr .. "," ..  string.sub(tmpTime[1],1,5) .. " - " .. string.sub(tmpTime[2],1,5)
		end
	end
	return timeStr
end

function MonstorInvasionMgr:getOpenLevel()
	local data = GameData.MonsterInvasion["monsterInvasion1"]
	if not data then
		return
	end
	
	data = data["activityData"]
	if not data then
		return
	end
	
	data = data["monsterInvasion1"]
	if not data then
		return
	end
	
	data = data["property"]
	if not data then
		return
	end
	
	return data.level
end