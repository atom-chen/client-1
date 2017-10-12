require("common.baseclass")
require("object.activity.ActivityDef")

PayActivityMgr = PayActivityMgr or BaseClass()

function PayActivityMgr:__init()
	self.payActivityList = {}
	self.firstPayObj = nil
end

function PayActivityMgr:__delete()
	self.payActivityList = {}
	self.firstPayObj = nil	
end

function PayActivityMgr:clear()
	self.payActivityList = {}
	if self.firstPayObj	then
		self.firstPayObj:DeleteMe()
		self.firstPayObj = nil
	end
	if self.everyPayObj then
		self.everyPayObj:DeleteMe()
		self.everyPayObj = nil
	end
	self.beginTime = nil
	self.currentValue = nil
	self.whitchActivity = nil
	self.endTime = nil
	self.canReceiveList = {}
end

--请求tableview资源列表
function PayActivityMgr:requestGiftList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_TotalRechargeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--请求领取礼包
function PayActivityMgr:requestGiftReceiveEvent(stage)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_TotalRechargeGiftReceiveEvent)
	writer:WriteString(stage)
	simulator:sendTcpActionEventInLua(writer)
end
--首充请求首充列表
function PayActivityMgr:requestFirstPayList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_FirstRechargeGiftList)
	simulator:sendTcpActionEventInLua(writer)
end
--首充领取请求
function PayActivityMgr:requestFirstPayReceive()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_FirstRechargeGiftReceive)
	simulator:sendTcpActionEventInLua(writer)
end
--每日充值请求列表
function PayActivityMgr:requestEveryDayPayGiftBagList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_EveryRechargeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--每日充值请求领取
function PayActivityMgr:requestReceiveEveryDayPayGiftBag()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_EveryRechargeGiftReceiveEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--请求那些活动是可以领取的
function PayActivityMgr:requestCanReceiveActivityList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_CanReceiveEvent)
	simulator:sendTcpActionEventInLua(writer)
end

--哪个活动
function PayActivityMgr:setWhichActivity(whichActivity)
	self.whitchActivity = whichActivity
end

function PayActivityMgr:getWhichActivity()
	if self.whitchActivity then
		return self.whitchActivity
	end
end
--剩余时间
function PayActivityMgr:setLeaveTime(leaveTime)
	self.leaveTime = leaveTime
end

function PayActivityMgr:getLeaveTime()
	if self.leaveTime then
		return self.leaveTime
	end
end
--活动开始时间
function PayActivityMgr:setBeginTime(beginTime)
	self.beginTime = beginTime
end

function PayActivityMgr:getBeginTime()
	if self.beginTime then
		return self.beginTime
	end
end
--活动结束时间
function PayActivityMgr:setEndTime(endTime)
	self.endTime = endTime
end

function PayActivityMgr:getEndTime()
	if self.endTime then
		return self.endTime
	end
end
--当前已充值数
function PayActivityMgr:setCurrentValue(currentValue)
	self.currentValue = currentValue
end

function PayActivityMgr:getCurrentValue()
	if self.currentValue then
		return self.currentValue
	end
end

--领奖列表
function PayActivityMgr:setAwardTableList(awardTableItem)
	self.payActivityList = awardTableItem
end

function PayActivityMgr:getAwardTableList()
	return self.payActivityList
end	

function PayActivityMgr:getTableElement(stage)
	return self.payActivityList[stage]
end
--根据stage获取物品列表
function PayActivityMgr:getItemlistByIndex(stage)
	local payList = self.payActivityList[stage]	
	if payList then
		return payList.itemList
	end
end
--根据tableview index 与 itemIndex 获得物品
function PayActivityMgr:getItemByTwoIndex(tIndex, itemIndex)
	local payList = self:getItemlistByIndex(tIndex)	
	local item = payList[itemIndex]
end

--首充物品列表对象
function PayActivityMgr:setFirstPayObj(firstPayObj)
	if firstPayObj then
		if self.firstPayObj then
			self.firstPayObj:DeleteMe()
		end
		self.firstPayObj = firstPayObj
	end
end

function PayActivityMgr:getFirstPayObj()
	return self.firstPayObj
end

--每日充值物品列表对象
function PayActivityMgr:setEveryPayObj(everyPayObj)
	if everyPayObj then
		if self.everyPayObj then
			self.everyPayObj:DeleteMe()
		end
		self.everyPayObj = everyPayObj
	end		
end

function PayActivityMgr:getEveryPayObj()
	return self.everyPayObj
end

--可领取活动列表
function PayActivityMgr:setCanReceiveList(canReceiveList)
	self.canReceiveList = canReceiveList
end

function PayActivityMgr:getCanReceiveList()
	return self.canReceiveList
end
--是否可获取首充奖励
function PayActivityMgr:canReceiveFirstPayAward()
	if self.canReceiveList then
		if self.canReceiveList[1] then
			return true
		else
			return false
		end
	else
		return false
	end
	
end
--是否可获取充值奖励
function PayActivityMgr:canReceivePayAward()
	if self.canReceiveList then
		if self.canReceiveList[2] then
			return true
		else
			return false
		end
	else
		return false
	end
end
--是否可获取每日充值奖励
function PayActivityMgr:canReceiveEveryDayPayAward()
	if self.canReceiveList then
		if self.canReceiveList[3] then
			return true
		else
			return false
		end
	else
		return false
	end
end
--是否可获取每周消费奖励
function PayActivityMgr:canReceiveEveryWeekConsumeAward()
	if self.canReceiveList then
		if self.canReceiveList[4] then
			return true
		else
			return false
		end
	else
		return false
	end
end

--充值礼包领取的index
function PayActivityMgr:setPayReceiveIndex(index)
	self.payReceiveIndex = index
end

function PayActivityMgr:getPayReceiveIndex()
	return self.payReceiveIndex
end	

--每周消费礼包领取index
function PayActivityMgr:setEveryWeekConsumeReceiveIndex(index)
	self.everyWeekConsumeReceiveIndex = index
end

function PayActivityMgr:getEveryWeekConsumeReceiveIndex()
	return self.everyWeekConsumeReceiveIndex
end

