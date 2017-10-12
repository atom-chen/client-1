require("config.words")
require "data.activity.mining"
require("data.scene.scene")
MiningMgr = MiningMgr or BaseClass()

function MiningMgr:__init()
	self.schedulerId = -1
	local onErrorCodeReturn = function(msgId,errorCode)
		self:onErrorCodeReturn(msgId,errorCode)
	end		
	self.errCodeBind = GlobalEventSystem:Bind(GameEvent.EventErrorCode,onErrorCodeReturn)
	self.miningOpenState = false
end

function MiningMgr:__delete()
	if self.errCodeBind then
		GlobalEventSystem:UnBind(self.errCodeBind)
		self.errCodeBind = nil
	end
end

function MiningMgr:clear()
	if self.schedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
	end
	self.schedulerId = -1
	self.currentCount = 0
	self.leaveTime = 0
	self.pluckInfo = {}
	self.pluckInfo = nil
	self.miningOpenState = false
end

function MiningMgr:enterMining()
	UIManager.Instance:hideUI("ActivityManageView")
	local hasEnterMining =  function()		
		UIManager.Instance:showSystemTips(Config.Words[19000])
		GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,false)
		GlobalEventSystem:Fire(GameEvent.EventSetMiningVisible,true)
		GlobalEventSystem:Fire(GameEvent.EventRefreshMiningCount)
		GlobalEventSystem:Fire(GameEvent.EventSetInstanceBtnVisible,false)
		GlobalEventSystem:Fire(GameEvent.EventLeaveActivityBtnState,true)
		GlobalEventSystem:Fire(GameEvent.EventStartTimer)
		self:setHandupState(true)
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = -1
	end
	if self.schedulerId == -1 then
		self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(hasEnterMining,0.8, false)
	else
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(hasEnterMining,0.8, false)
	end	
end

function MiningMgr:exitMining()
	GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,true)
	GlobalEventSystem:Fire(GameEvent.EventSetMiningVisible,false)
	UIManager.Instance:showSystemTips(Config.Words[19001])
	GlobalEventSystem:Fire(GameEvent.EventStopTimer)
	GlobalEventSystem:Fire(GameEvent.EventSetInstanceBtnVisible,true)
	GlobalEventSystem:Fire(GameEvent.EventLeaveActivityBtnState,false)
	self:setHandupState(false)
end

function MiningMgr:isInMiningMap()
	local mapMgr = GameWorld.Instance:getMapManager()
	local mapId = mapMgr:getCurrentMapRefId()
	if mapId == "S217"	then
		return true
	else
		return false
	end
end

function MiningMgr:requestRemainingTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mining_ContinuTime)	
	simulator:sendTcpActionEventInLua(writer)
end

function MiningMgr:requestEnterMining()
	local x,y = self:getMiningSceneStartPoint()
	if x and y then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mining_EnterEvent)		
		StreamDataAdapter:WriteStr(writer,"S217")
		StreamDataAdapter:WriteInt(writer,x)
		StreamDataAdapter:WriteInt(writer,y)
		simulator:sendTcpActionEventInLua(writer)
	end	
end

function MiningMgr:getMiningSceneStartPoint()
	local mapData  = GameData.Scene["S217"]
	if mapData then
		if mapData["tranferIn"] then
			local x = mapData["tranferIn"][1].x
			local y = mapData["tranferIn"][1].y
			return x,y
		end
	end
end
function MiningMgr:requestExitMining()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mining_ExitEvent)
	simulator:sendTcpActionEventInLua(writer)
end
function MiningMgr:requestMiningBeOpen()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mining_Open)	
	simulator:sendTcpActionEventInLua(writer)
end

function MiningMgr:setCurrentCount(count)
	self.currentCount = count
end
function MiningMgr:getCurrentCount()
	if self.currentCount == 20 then
		self:setHandupState(false)		
	end
	return self.currentCount
end

function MiningMgr:setLeaveTime(leaveTime)
	self.leaveTime = leaveTime
end

function MiningMgr:getLeaveTime()
	return self.leaveTime
end

function MiningMgr:setHandupState(state)
	if state == true then
		if self.currentCount and self.currentCount < 20 then
			G_getHandupMgr():start(E_AutoSelectTargetMode.Collect, {EntityType.EntityType_NPC}, {"npc_collect_4","npc_collect_5","npc_collect_6"}, nil, nil, E_SearchTargetMode.Random)
		end
	elseif state == false then
		GameWorld.Instance:getNpcManager():cancelCollect()
		G_getHandupMgr():stop()
	end
end


function MiningMgr:onErrorCodeReturn(msgId,errorCode)	
	if msgId == 385 and errorCode == 2147487450 then
		self:setHandupState(false)
	elseif msgId == 3364 and errorCode == 2147487454 then
		UIManager.Instance:showSystemTips(Config.Words[19015])
	--elseif msgId == 385 and errorCode == 2147487449 then
		--UIManager.Instance:showSystemTips(Config.Words[19016])
	end
end

function MiningMgr:canCollect()
	if self.currentCount and self.currentCount < 20 then
		return true
	else
		return false
	end
end
function MiningMgr:setNextMineralTime(nextMineralTime)
	self.nextMineralTime = nextMineralTime
end
function MiningMgr:getNextMineralTime()
	if self.nextMineralTime then
		return self.nextMineralTime
	else
		return 0
	end
end

function MiningMgr:requestNextMineralTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mining_RemainRrfreshTime)	
	StreamDataAdapter:WriteChar(writer,"3")			--1=低级矿 2=中级矿 3=高级矿
	simulator:sendTcpActionEventInLua(writer)	
end

function MiningMgr:setPluckInfo(pluckType,collectedCount)
	if pluckType == 1 then
		pluckType = 3
	elseif pluckType == 3 then
		pluckType = 1
	end
	if self.pluckInfo then
		self.pluckInfo[pluckType] = collectedCount
	else
		self.pluckInfo = {}
		self.pluckInfo[pluckType] = collectedCount
	end
end

function MiningMgr:getPluckInfo()
	return self.pluckInfo
end

function MiningMgr:getMiningOpenState()
	return self.miningOpenState
end	

function MiningMgr:setMiningOpenState(state)
	self.miningOpenState = state
end	

function MiningMgr:getMingOpenTime()
	local time = GameData.Mining["sa_1"]["time"]["duration"]
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

function MiningMgr:getOpenLevel()
	local data = GameData.Mining["sa_1"]
	if not data then
		return
	end
	
	data = data["activityData"]
	if not data then
		return
	end
	
	data = data[1]
	if not data then
		return
	end
	
	return data.limitLevel
end	