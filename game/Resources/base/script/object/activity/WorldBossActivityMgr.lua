require("common.baseclass")

WorldBossActivityManager = WorldBossActivityManager or BaseClass()

function WorldBossActivityManager:__init()
	self.timeToStart = 0
	self.timeToEnd = 0
	self.currentType = 1
	self.activityStep = {}
	self.isInWorldBossActivity  = false
end	

function WorldBossActivityManager:clear()
	self.timeToStart = 0
	self.timeToEnd = 0
	self.currentType = 1
	self.activityStep = {}
	self.isInWorldBossActivity  = false
	if self.scheduleToStartId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToStartId)  	
		self.scheduleToStartId = nil
	end
	
	if self.scheduleToEndId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleToEndId)  	
		self.scheduleToEndId = nil
	end	
end	

function WorldBossActivityManager:setTimeToStart(sec)
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

function WorldBossActivityManager:setTimeToEnd(sec)
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


function WorldBossActivityManager:setActivityStep(ttype,step)
	self.activityStep[ttype] = step
end	

function WorldBossActivityManager:getActivityStep(ttype)
	return self.activityStep[ttype]
end	

function WorldBossActivityManager:setIsInWorldBossActivityTime(state)
	self.isInWorldBossActivity = state
end	

function WorldBossActivityManager:getIsInWorldBossActivityTime()
	return self.isInWorldBossActivity
end	

function WorldBossActivityManager:getTimeToStart()
	return self.timeToStart
end	

function WorldBossActivityManager:getTimeToEnd()
	return self.timeToEnd
end	

function WorldBossActivityManager:setCurrentActivityType(ttype)
	if  self.currentType ~= ttype then
		self.activityStep = {}
		self.currentType = ttype
	end
end	

function WorldBossActivityManager:getCurrentActivityType()
	return self.currentType
end	

function WorldBossActivityManager:IsAtWorldBossScene(sceneRefId)
	--local mapMgr = GameWorld.Instance:getMapManager()
	--local currentSceneRefId =  mapMgr:getCurrentMapRefId()
	local scene  = self.sceneRefId
	if sceneRefId then
		scene = sceneRefId
	end
	local activitySceneList = G_getTeamBossActivitySceneListByType(self.currentType)
	for k ,v in pairs(activitySceneList) do
		if scene  == v then
			return true
		end
	end
	return false
end

function WorldBossActivityManager:getCurrentActivitySceneAndBossList()
	local linkList = G_getTeamBossActivityLinkListByType(self.currentType)	
	local sortFunc  = function(a,b)
		local sceneIndexA = string.match(a.transfer.targetScene,"%d+")	
		local sceneIndexB = string.match(b.transfer.targetScene,"%d+")
		if sceneIndexA > sceneIndexB then
			return false
		else
			return true
		end
	end	
	
	table.sort(linkList,sortFunc)
	return linkList
end

function WorldBossActivityManager:requestReaminTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeamBoss_RequestTime)
	writer:WriteChar(self.currentType)
	simulator:sendTcpActionEventInLua(writer)	
end	

function WorldBossActivityManager:setCurrentSceneRefId(sceneRefId)
	if not self:IsAtWorldBossScene(self.sceneRefId) and  self:IsAtWorldBossScene(sceneRefId) and  self.bNeedShow then
		self.sceneRefId = sceneRefId
		if PropertyDictionary:get_level(G_getHero():getPT()) >= 40 then
			GlobalEventSystem:Fire(GameEvent.EventOpenWorldBossActivityView,1)
		end
		self.bNeedShow = false
	else
		self.sceneRefId = sceneRefId
	end
		
end	

function WorldBossActivityManager:getCurrentSceneRefId()
	return self.sceneRefId
end	

function WorldBossActivityManager:setNeedShowView(bNeedShow)
	self.bNeedShow = bNeedShow
		
end	

function WorldBossActivityManager:getNeedShowView()
	return self.bNeedShow
end

function WorldBossActivityManager:getTimeStrToStart()
	return self:getRestTimeStr(self.timeToStart)
end

function WorldBossActivityManager:getTimeStrToEnd()
	return self:getRestTimeStr(self.timeToEnd)
end

function WorldBossActivityManager:getRestTimeStr(restSec)
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