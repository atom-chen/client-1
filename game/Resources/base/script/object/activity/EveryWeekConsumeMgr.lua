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
--请求每周消费奖励列表
function EveryWeekConsumeMgr:requestWeekConsumeGiftList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_WeekConsumeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end

--请求领取物品
function EveryWeekConsumeMgr:requestWeekConsumeGiftReceive(stage)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_WeekConsumeGiftReceiveEvent)
	writer:WriteString(stage)
	simulator:sendTcpActionEventInLua(writer)
end
--活动剩余时间
function EveryWeekConsumeMgr:setLeaveTime(leaveTime)
	self.leaveTime = leaveTime
end

function EveryWeekConsumeMgr:getLeaveTime()
	return self.leaveTime
end

--活动开始时间
function EveryWeekConsumeMgr:setBeginTime(beginTime)
	self.beginTime = beginTime
end

function EveryWeekConsumeMgr:getBeginTime()
	return self.beginTime
end

--活动结束时间
function EveryWeekConsumeMgr:setEndTime(endTime)
	self.endTime = endTime
end

function EveryWeekConsumeMgr:getEndTime()
	return self.endTime
end

--本周起始结束时间
function EveryWeekConsumeMgr:setWeekStartEndTime(weekStartEndTime)
	self.weekStartEndTime = weekStartEndTime
end

function EveryWeekConsumeMgr:getWeekStartEndTime()
	return self.weekStartEndTime
end

--当前已充值数
function EveryWeekConsumeMgr:setCurrentWeekValue(currentWeekValue)
	self.currentWeekValue = currentWeekValue
end

function EveryWeekConsumeMgr:getCurrentWeekValue()
	return self.currentWeekValue
end

--礼包列表
function EveryWeekConsumeMgr:setWeekConsumeGiftList(weekConsumegiftList)
	if not table.isEmpty(weekConsumegiftList) then
		self.weekConsumeGiftList = weekConsumegiftList
	end		
end

function EveryWeekConsumeMgr:getWeekConsumeGiftList()
	return self.weekConsumeGiftList
end