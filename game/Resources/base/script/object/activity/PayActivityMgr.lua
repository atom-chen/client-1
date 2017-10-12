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

--����tableview��Դ�б�
function PayActivityMgr:requestGiftList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_TotalRechargeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--������ȡ���
function PayActivityMgr:requestGiftReceiveEvent(stage)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_TotalRechargeGiftReceiveEvent)
	writer:WriteString(stage)
	simulator:sendTcpActionEventInLua(writer)
end
--�׳������׳��б�
function PayActivityMgr:requestFirstPayList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_FirstRechargeGiftList)
	simulator:sendTcpActionEventInLua(writer)
end
--�׳���ȡ����
function PayActivityMgr:requestFirstPayReceive()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_FirstRechargeGiftReceive)
	simulator:sendTcpActionEventInLua(writer)
end
--ÿ�ճ�ֵ�����б�
function PayActivityMgr:requestEveryDayPayGiftBagList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_EveryRechargeGiftListEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--ÿ�ճ�ֵ������ȡ
function PayActivityMgr:requestReceiveEveryDayPayGiftBag()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_EveryRechargeGiftReceiveEvent)
	simulator:sendTcpActionEventInLua(writer)
end
--������Щ��ǿ�����ȡ��
function PayActivityMgr:requestCanReceiveActivityList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OA_CanReceiveEvent)
	simulator:sendTcpActionEventInLua(writer)
end

--�ĸ��
function PayActivityMgr:setWhichActivity(whichActivity)
	self.whitchActivity = whichActivity
end

function PayActivityMgr:getWhichActivity()
	if self.whitchActivity then
		return self.whitchActivity
	end
end
--ʣ��ʱ��
function PayActivityMgr:setLeaveTime(leaveTime)
	self.leaveTime = leaveTime
end

function PayActivityMgr:getLeaveTime()
	if self.leaveTime then
		return self.leaveTime
	end
end
--���ʼʱ��
function PayActivityMgr:setBeginTime(beginTime)
	self.beginTime = beginTime
end

function PayActivityMgr:getBeginTime()
	if self.beginTime then
		return self.beginTime
	end
end
--�����ʱ��
function PayActivityMgr:setEndTime(endTime)
	self.endTime = endTime
end

function PayActivityMgr:getEndTime()
	if self.endTime then
		return self.endTime
	end
end
--��ǰ�ѳ�ֵ��
function PayActivityMgr:setCurrentValue(currentValue)
	self.currentValue = currentValue
end

function PayActivityMgr:getCurrentValue()
	if self.currentValue then
		return self.currentValue
	end
end

--�콱�б�
function PayActivityMgr:setAwardTableList(awardTableItem)
	self.payActivityList = awardTableItem
end

function PayActivityMgr:getAwardTableList()
	return self.payActivityList
end	

function PayActivityMgr:getTableElement(stage)
	return self.payActivityList[stage]
end
--����stage��ȡ��Ʒ�б�
function PayActivityMgr:getItemlistByIndex(stage)
	local payList = self.payActivityList[stage]	
	if payList then
		return payList.itemList
	end
end
--����tableview index �� itemIndex �����Ʒ
function PayActivityMgr:getItemByTwoIndex(tIndex, itemIndex)
	local payList = self:getItemlistByIndex(tIndex)	
	local item = payList[itemIndex]
end

--�׳���Ʒ�б����
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

--ÿ�ճ�ֵ��Ʒ�б����
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

--����ȡ��б�
function PayActivityMgr:setCanReceiveList(canReceiveList)
	self.canReceiveList = canReceiveList
end

function PayActivityMgr:getCanReceiveList()
	return self.canReceiveList
end
--�Ƿ�ɻ�ȡ�׳佱��
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
--�Ƿ�ɻ�ȡ��ֵ����
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
--�Ƿ�ɻ�ȡÿ�ճ�ֵ����
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
--�Ƿ�ɻ�ȡÿ�����ѽ���
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

--��ֵ�����ȡ��index
function PayActivityMgr:setPayReceiveIndex(index)
	self.payReceiveIndex = index
end

function PayActivityMgr:getPayReceiveIndex()
	return self.payReceiveIndex
end	

--ÿ�����������ȡindex
function PayActivityMgr:setEveryWeekConsumeReceiveIndex(index)
	self.everyWeekConsumeReceiveIndex = index
end

function PayActivityMgr:getEveryWeekConsumeReceiveIndex()
	return self.everyWeekConsumeReceiveIndex
end

