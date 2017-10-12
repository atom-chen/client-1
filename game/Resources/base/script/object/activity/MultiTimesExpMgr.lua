require("common.baseclass")

MultiTimesExpMgr = MultiTimesExpMgr or BaseClass()

function MultiTimesExpMgr:__init()
	self.timeToStart = 0
	self.timeToEnd = 0
end		

function MultiTimesExpMgr:clear()
	self.timeToStart = 0
	self.timeToEnd = 0	
	if self.scheduleToStartId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToStartId)  	
		self.scheduleToStartId = nil
	end	

	if self.scheduleToEndId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToEndId)  	
		self.scheduleToEndId = nil
	end		
end	

function MultiTimesExpMgr:setTimeToStart(sec)
	self.timeToStart = math.ceil(sec)
	if self.scheduleToStartId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToStartId)  	
		self.scheduleToStartId = nil
	end	
	
	local countDown = function()
		if self.timeToStart > 0 then
			self.timeToStart = self.timeToStart - 1		
		else
			if self.scheduleToStartId then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToStartId)  	
				self.scheduleToStartId = nil
			end				
		end
	end		
	self.scheduleToStartId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countDown, 1, false)	
	
end	

function MultiTimesExpMgr:setTimeToEnd(sec)
	self.timeToEnd =  math.ceil(sec)
	if self.scheduleToEndId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToEndId)  	
		self.scheduleToEndId = nil
	end	
	
	local countDownEnd = function()
		if self.timeToEnd > 0 then
			self.timeToEnd = self.timeToEnd - 1		
		else
			if self.scheduleToEndId then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToEndId)  	
				self.scheduleToEndId = nil
			end				
		end
	end		
	self.scheduleToEndId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countDownEnd, 1, false)		
end		

function MultiTimesExpMgr:getTimeToStart()
	return self.timeToStart
end	

function MultiTimesExpMgr:getTimeToEnd()
	return self.timeToEnd
end			

function MultiTimesExpMgr:requestReaminTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MultiTimesExp_RequestTime)
	simulator:sendTcpActionEventInLua(writer)	
end			

function MultiTimesExpMgr:getTimeStrToStart()
	return self:getRestTimeStr(self.timeToStart)
end

function MultiTimesExpMgr:getTimeStrToEnd()
	return self:getRestTimeStr(self.timeToEnd)
end

function MultiTimesExpMgr:getRestTimeStr(restSec)
	local str = ""
	if restSec > 0 then
		local day = math.floor(restSec/(24*3600))	
		local hour = math.floor(restSec/3600)%24
		local minite = math.floor(restSec/60)%60
		local sec = restSec%60	
		if day > 0 then
			str = day .. Config.Words[13007]..string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
		else
			if hour > 0 then
				str = string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
			else
				if minite > 0 then
					str = string.format("%02d%s%02d%s", minite, Config.Words[13641], sec, Config.Words[13642])
				else
					str = string.format("%02d%s", sec, Config.Words[13642])
				end
			end
		end	
	end
	return str
end