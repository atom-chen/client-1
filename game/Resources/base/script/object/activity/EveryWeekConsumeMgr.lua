require("common.baseclass")
require("object.activity.ActivityDef")

EveryWeekConsumeMgr = EveryWeekConsumeMgr or BaseClass()

function EveryWeekConsumeMgr:__init()
	self:clear()
end

function EveryWeekConsumeMgr:__delete()
	self:clear()
end

function EveryWeekConsumeMgr:clear()
	self.leaveTime = 0
	self.currentWeekValue = 0
	self.endTime = 0
	self.leaveTime = 0
	self.weekStartEndTime = 0
	self.weekConsumeGiftList = {}
end
--����ÿ�����ѽ����б�
function EveryWeekConsumeMgr:requestWeekConsumeGiftList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_WeekConsumeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end

--������ȡ��Ʒ
function EveryWeekConsumeMgr:requestWeekConsumeGiftReceive(stage)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_WeekConsumeGiftReceiveEvent)
	writer:WriteString(stage)
	simulator:sendTcpActionEventInLua(writer)
end
--�ʣ��ʱ��
function EveryWeekConsumeMgr:setLeaveTime(leaveTime)
	self.leaveTime = leaveTime
end

function EveryWeekConsumeMgr:getLeaveTime()
	return self.leaveTime
end

--���ʼʱ��
function EveryWeekConsumeMgr:setBeginTime(beginTime)
	self.beginTime = beginTime
end

function EveryWeekConsumeMgr:getBeginTime()
	return self.beginTime
end

--�����ʱ��
function EveryWeekConsumeMgr:setEndTime(endTime)
	self.endTime = endTime
end

function EveryWeekConsumeMgr:getEndTime()
	return self.endTime
end

--������ʼ����ʱ��
function EveryWeekConsumeMgr:setWeekStartEndTime(weekStartEndTime)
	self.weekStartEndTime = weekStartEndTime
end

function EveryWeekConsumeMgr:getWeekStartEndTime()
	return self.weekStartEndTime
end

--��ǰ�ѳ�ֵ��
function EveryWeekConsumeMgr:setCurrentWeekValue(currentWeekValue)
	self.currentWeekValue = currentWeekValue
end

function EveryWeekConsumeMgr:getCurrentWeekValue()
	return self.currentWeekValue
end

--����б�
function EveryWeekConsumeMgr:setWeekConsumeGiftList(weekConsumegiftList)
	if not table.isEmpty(weekConsumegiftList) then
		self.weekConsumeGiftList = weekConsumegiftList
	end		
end

function EveryWeekConsumeMgr:getWeekConsumeGiftList()
	return self.weekConsumeGiftList
end