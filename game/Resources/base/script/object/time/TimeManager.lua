require("common.baseclass")

TimeManager = TimeManager or BaseClass()

local PingLevel = {
	one = 1,
	two = 2,
	three = 3,
}

local heartBeatMaxLag = 25000
local MaxLag = 50000
function  TimeManager:__init()
	self.clientStampSend = 0
	self.serverStamp = 0
	self.clientTime = 0
	self.lag = 0
	self.lastHeartBeatTime = 0
	self.lastUpdate = 0
end

function TimeManager:__delete()
	self:clear()
end

function TimeManager:start()
	self.clientStampSend = 0
	self.serverStamp = 0
	self.clientTime = 0
	self.lag = 0
	self.lastHeartBeatTime = 0
	self.lastUpdate = 0
	self:clear()
	local function timeTick(delay)	
		self.clientTime = self.clientTime + delay*1000		
		self.serverStamp = self.serverStamp + delay*1000
	end
	local function syncTime()	
		self:sendSynTimeRequest()
		--collectgarbage("collect")
		--collectgarbage("collect")
		self:checkPing()
	end
	
	local function heartBeat()
		--self:checkNetwork()
		self:sendHeartBeatRequest()
		--print(tostring(self:getLag()))		
	end
	self.timeTickId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeTick, 0, false)		
	self.syncTimeId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(syncTime, 10, false)
	self.heartBeatId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(heartBeat, 5, false)
end

function TimeManager:clear()
	if self.timeTickId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeTickId)
		self.timeTickId = nil
	end
	
	if self.syncTimeId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.syncTimeId)
		self.syncTimeId = nil
	end
	
	if self.heartBeatId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.heartBeatId)
		self.heartBeatId = nil
	end
end

function TimeManager:getClientTime()
	return self.clientTime
end

function TimeManager:getServerTime()
	return self.serverStamp
end

function TimeManager:sendSynTimeRequest()
	-- 连上了服务器才发送对时
	local simulator = SFGameSimulator:sharedGameSimulator()
	if simulator:isTcpConnect() then	
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Sync_Time)
		writer:WriteLLong(self.clientTime)
		simulator:sendTcpActionEventInLua(writer)
	end
end


function TimeManager:sendHeartBeatRequest()
	-- 连上了服务器才发送对时
	local simulator = SFGameSimulator:sharedGameSimulator()
	if simulator:isTcpConnect() then	
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_Heartbeat)
		local time = os.time()
		writer:WriteLLong(time)		
		simulator:sendTcpActionEventInLua(writer)		
	end
end

function TimeManager:setClientStampSend(stamp)
	self.clientStampSend = stamp
end

function TimeManager:setClientStampGet(stamp)
	self.clientStampGet = stamp
end

function TimeManager:setServetStamp(stamp)
	self.serverStamp = stamp
end

function TimeManager:updateLag()
	local dc = self.serverStamp - (self.clientTime + self.clientStampSend) / 2
	self.lag = self.clientTime - self.serverStamp + dc
	local level = self:getPingLevel()
	GlobalEventSystem:Fire(GameEvent.EventUpdatePing,level) 
	self.lastUpdate = self.clientTime
end

function TimeManager:getLag()
	return self.lag
end

function TimeManager:updateHeartBeat()
	self.lastHeartBeatTime = self.clientTime	
end


function TimeManager:checkNetwork()
	local networkState = SFGameHelper:getCurrentNetWork()

	if networkState == kNotNetwork then
		LoginWorld.Instance:getLoginManager():getConnectionService():disConnect()
	end
end

function TimeManager:checkHeartBeat()

end

function TimeManager:checkPing()
	local check = math.abs(self.lastUpdate - self.clientTime)
	if check >= MaxLag then	
		if self.lag ~= 9999 then
			self.lag = 9999
			--local level = self:getPingLevel()
			--GlobalEventSystem:Fire(GameEvent.EventUpdatePing,level)
			LoginWorld.Instance:getLoginManager():getConnectionService():disConnect() 			
		end
	end
end

function TimeManager:getPingLevel()
	if self.lag < 100 then
		return PingLevel.one
	elseif self.lag < 300 and self.lag > 100 then
		return PingLevel.two
	elseif self.lag > 300 then
		return PingLevel.three
	end
end