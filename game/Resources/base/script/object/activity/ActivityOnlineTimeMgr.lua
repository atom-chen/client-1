--����ʱ��
require("object.activity.OnlineTimeStaticDate")
ActivityOnlineTimeMgr = ActivityOnlineTimeMgr or BaseClass()

function ActivityOnlineTimeMgr:__init()
	self.onlineTimeRefId = nil
	self.onlineTimeSeverTime = nil
	self.theFrist = true
end

function ActivityOnlineTimeMgr:__delete()
	
end

function ActivityOnlineTimeMgr:clear()
	self.onlineTimeRefId = nil
	self.onlineTimeSeverTime = nil
	self.theFrist = true
end

function ActivityOnlineTimeMgr:setTheFrist(bChange)
	self.theFrist = bChange
end	

function ActivityOnlineTimeMgr:getTheFrist()
	return self.theFrist
end	

function ActivityOnlineTimeMgr:setOnlineTimeRefId(id)
	local idSize = string.len(id)
	if idSize==0 then	
		--�����ť����
	end
	self.onlineTimeRefId = id
end

function ActivityOnlineTimeMgr:getOnlineTimeRefId()
	return self.onlineTimeRefId
end

function ActivityOnlineTimeMgr:setOnlineTimeSeverTime(time)
	if time<0 then
		self.onlineTimeSeverTime = 0
	else
		self.onlineTimeSeverTime = time
	end
	
end

function ActivityOnlineTimeMgr:getOnlineTimeSeverTime()
	return self.onlineTimeSeverTime
end

function ActivityOnlineTimeMgr:setOnlineTimeRewardState(state)
	local temState = false
	if state==1 then
		temState = true
	end
	self.onlineTimeRewardState = temState
end

function ActivityOnlineTimeMgr:getOnlineTimeRewardState()
	return self.onlineTimeRewardState
end

function ActivityOnlineTimeMgr:getOnlineTimeTime()
	local time = 0
	if self.onlineTimeRefId then
		time = OnlineTimeStaticDate:getTime(self.onlineTimeRefId)
	end
	return time
end	

--��ʾ����
function ActivityOnlineTimeMgr:showReward()
	--if self.onlineTimeRefId then
		--UIManager.Instance:showSystemTips(Config.Words[13200])
	--end
end	


--��������ʱ����Ϣ
function ActivityOnlineTimeMgr:requestOnlineTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OT_ShowOnLineTimer)	
	simulator:sendTcpActionEventInLua(writer)		
end

--��ȡ������Ϣ
function ActivityOnlineTimeMgr:requestGetReward(ttyp,refId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Activity_GetAward)
	writer:WriteChar(ttyp)	
	writer:WriteString(refId)
	simulator:sendTcpActionEventInLua(writer)		
end