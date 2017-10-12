require("common.baseclass")

LevelAwardMgr = LevelAwardMgr or BaseClass()

function LevelAwardMgr:__init()
	self.rideLevelAwardList = {}		
	self.levelUpAwardList = {}
	self.totalSeconds = 0
	self.getAwardRefId = nil
end		

function LevelAwardMgr:clear()
	if self.rideLevelAwardList then	
		self.rideLevelAwardList = {}
	end		
	
	if self.levelUpAwardList then	
		self.levelUpAwardList = {}
	end
	self.totalSeconds = 0
	self.getAwardRefId = nil
end

function LevelAwardMgr:initRideAwardList(size)
	for i=1,size do
		local refId = "rideReward_" .. i
		self.rideLevelAwardList[refId] = 0
	end	
end

function LevelAwardMgr:initLevelUpAwardList(size)
	for i=1,size do
		local refId = "levelUpReward_" .. i
		self.levelUpAwardList[refId] = 0
	end	
end	

--请求签到列表
function LevelAwardMgr:requestAwardList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Advanced_List)	
	simulator:sendTcpActionEventInLua(writer)
end

function LevelAwardMgr:requestLevelUpAwardList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_LevelUpAward_List)	
	simulator:sendTcpActionEventInLua(writer)
end

function LevelAwardMgr:requestGetReward(refId,ttype)  -- 1  2  3  4
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer
	if ttype ~= 4 then	
		writer = simulator:getBinaryWriter(ActionEvents.C2G_Advanced_GetReward)	
	else
		writer = simulator:getBinaryWriter(ActionEvents.C2G_Get_LevelUpAward)	
	end	
	writer:WriteString(refId)	
	simulator:sendTcpActionEventInLua(writer)		
end	

function LevelAwardMgr:setRideAwardList(list)
	self.rideLevelAwardList = list
end	

function LevelAwardMgr:setLevelUpAwardList(list)
	self.levelUpAwardList = list
end	

function LevelAwardMgr:getRideAwardList()
	return self.rideLevelAwardList
end

function LevelAwardMgr:getLevelUpAwardList()
	return self.levelUpAwardList
end		

function LevelAwardMgr:setRideAwardIndexState(refId,state)
	--local refId = "rideReward_" .. index
	self.rideLevelAwardList[refId] = state
end

function LevelAwardMgr:getIsRideAward()
	for i,v in pairs(self.rideLevelAwardList) do
		if v==2 then
			return true
		end
	end
	return false
end		

function LevelAwardMgr:getRideAwardIndexState(index)
	local refId = "rideReward_" .. index
	return self.rideLevelAwardList[refId]
end

function LevelAwardMgr:getLevelUpAwardIndexState(index)
	local refId = "levelUpReward_" .. index
	return self.levelUpAwardList[refId]
end	

function LevelAwardMgr:setAwardGetRefId(refId)
	self.getAwardRefId = refId	
end

function LevelAwardMgr:getAwardGetRefId()
	return self.getAwardRefId
end

function LevelAwardMgr:setTotalSecond(sec)
	self.totalSeconds = sec
end

function LevelAwardMgr:getTotalSecond()
	return self.totalSeconds
end

function LevelAwardMgr:requestLevelUpAwardCanGet() 
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Activity_CanReceive)	
	writer:WriteChar(6)	
	simulator:sendTcpActionEventInLua(writer)		
end

function LevelAwardMgr:requestUpGradeAwardCanGet() 
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Activity_CanReceive)
	writer:WriteChar(5)		
	simulator:sendTcpActionEventInLua(writer)		
end