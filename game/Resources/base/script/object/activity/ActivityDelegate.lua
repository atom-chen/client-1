ActivityDelegate = ActivityDelegate or BaseClass()

local AdjustRemainTimePoint = 
{
	[15000] = true,
	[60] = true,
	[30] = true,
	[10] = true,
	[0] = true,	
}

function ActivityDelegate:__init()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local onActivityNotify = function(refId, activityType, event, info)
		self:onActivityNotify(refId, activityType, event, info)
	end
	self.activityNotifyId = activityManageMgr:addActivityNotify(onActivityNotify)
end

function ActivityDelegate:__delete()
	if self.activityNotifyId then
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
		activityManageMgr:removeActivityNotify(self.activityNotifyId)
	end
end

--[[
���û�ص�
���ݸ��ص������Ĳ����б�Ϊ��refId, activityType, event, info
refId: �����¼��Ļ��refId
activityType�������¼��Ļ������
event:�����ľ����¼����ֱ�Ϊenable, active, open, time
	enable: ʹ��״̬�����仯
	activite������״̬�����仯
	open����״̬������		
	time������ʱ�����仯
--]]	
function ActivityDelegate:onActivityNotify(refId, activityType, event, info)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	if event == "time" then
		local obj = activityManageMgr:getActivityByRefId(refId)
		local startRemainSec, endRemainSec
		if obj then
			startRemainSec, endRemainSec = obj:getRemainSec()	--��ȡ�û�Ŀ���ʣ��ʱ��ͽ���ʣ��ʱ��
		end
		if info == 1 or info == 3 then	--��ʼ����ʱ�����仯
			if startRemainSec and AdjustRemainTimePoint[startRemainSec] then		
				if refId == "activity_manage_8" then	--ɳ�Ϳ˹���У��ʱ��
					G_getCastleWarMgr():requestCastleWarTime()
--					print("adjust shabake time")
				elseif refId == "activity_manage_3" then
					self:activityOnlineTimeNotify()		
				elseif refId == "activity_manage_6" then--��������У��ʱ��
					GameWorld.Instance:getMonstorInvasionMgr():requestRemainingTime()
				elseif refId == "activity_manage_7" then--�ڿ�У��ʱ��
					GameWorld.Instance:getMiningMgr():requestRemainingTime()
				end
			end
		end
		if info == 2 or info == 3 then	--��������ʱ�����仯
			if endRemainSec and AdjustRemainTimePoint[endRemainSec] then
				if refId == "activity_manage_8" then	--ɳ�Ϳ˹���У��ʱ��
					G_getCastleWarMgr():requestCastleWarTime()
--					print("adjust shabake time")
				elseif refId == "activity_manage_6" then--��������У��ʱ��
					GameWorld.Instance:getMonstorInvasionMgr():requestRemainingTime()
				elseif refId == "activity_manage_7" then--�ڿ�У��ʱ��
					GameWorld.Instance:getMiningMgr():requestRemainingTime()
				end
			end
		end
	end
end

function ActivityDelegate:getMgr()
	return GameWorld.Instance:getActivityManageMgr()	
end

function ActivityDelegate:setEnable(refId, bEnable)
	self:getMgr():setActivityEnable(refId, bEnable)			
end

function ActivityDelegate:setActivated(refId, bActivated)
	self:getMgr():setActivityState(refId, bActivated)			
end

function ActivityDelegate:setRemainSec(refId, startRemainSec, endRemainSec)
	self:getMgr():setRemainSec(refId, startRemainSec, endRemainSec)			
end

function ActivityDelegate:setShowTime(refId,bShow)
	self:getMgr():setShowTime(refId,bShow)			
end

function ActivityDelegate:activityOnlineTimeNotify()
	local activityOnlineTimeMgr = GameWorld.Instance:getActivityOnlineTimeMgr()
	activityOnlineTimeMgr:requestOnlineTime()
end

--��������ʱ��
function ActivityDelegate:doOnlineTimeBySever()	
	local activityOnlineTimeMgr = GameWorld.Instance:getActivityOnlineTimeMgr()
	local inTime = activityOnlineTimeMgr:getOnlineTimeSeverTime()
	local refId = activityOnlineTimeMgr:getOnlineTimeRefId()
	local state = activityOnlineTimeMgr:getOnlineTimeRewardState()
	
	if string.len(refId)==0 and state==false then
		self:setEnable("activity_manage_3", false)			
	else
		if state==false then
			self:setShowTime("activity_manage_3",true)
			self:setRemainSec("activity_manage_3", inTime, inTime)			
		else
			self:setShowTime("activity_manage_3",false)
		end
		self:setEnable("activity_manage_3", true)	
		self:setActivated("activity_manage_3", state)
	end				
end	

--����7���¼
function ActivityDelegate:doSevenLoginBySever(num, showLable, showIcon)
	self:setActivated("activity_manage_2", showLable)	
	self:setEnable("activity_manage_2", (showIcon ~= false))						
end

--��������
function ActivityDelegate:doArenaBySever(canReceive)
	self:setActivated("activity_manage_5", canReceive > 0)
end

--�����׳䰴ť
function ActivityDelegate:hideFirstPayGiftBagBut()
	self:setEnable("activity_manage_13", false)
end

--���׽���
function ActivityDelegate:showEffectInUpGradeButton(bShow)
	self:setActivated("activity_manage_4", bShow)
end

--�������
function ActivityDelegate:showEffectInFundButton(show)
	self:setActivated("activity_manage_12", show)
end

--����
function ActivityDelegate:showEffectInLevelupButton(show)
	self:setActivated("activity_manage_17", show)
end

--��ʱ���
function ActivityDelegate:showEffectInLimitRankButton(show)
	self:setActivated("activity_manage_18", show)
end

--�׳䰴ť�߿���Ч
function ActivityDelegate:showEffectInFirstPayButton(show)
	self:setActivated("activity_manage_13", show)
end

--��ֵ�߿���Ч
function ActivityDelegate:showEffectInPayAwardButton(show)
	self:setActivated("activity_manage_14", show)	
end

--�׳䰴ť�߿���Ч
function ActivityDelegate:showEffectInFirstPayButton(show)
	self:setActivated("activity_manage_13", show)
end

--�ۻ���ֵ�����߿���Ч
function ActivityDelegate:showEffectInPayAwardButton(show)
	self:setActivated("activity_manage_14", show)	
end

--ÿ�ճ�ֵ��ť�߿���Ч
function ActivityDelegate:showEffectInEveryDayPayAwardButton(show)
	self:setActivated("activity_manage_10", show)	
end

--ÿ�����Ѱ�ť�߿���Ч
function ActivityDelegate:showEffectInEveryWeekConsumeAwardButton(show)
	self:setActivated("activity_manage_11", show)		
end

--������۳���
function ActivityDelegate:doDiscountSellBySever(show)
--	self:setEnable("activity_manage_9", show)	
	self:setActivated("activity_manage_9", show)	
end


--����ɿ����ر�
function ActivityDelegate:doMiningStatusBySever(bShow)
--	self:setEnable("activity_manage_7", show)		
	self:setActivated("activity_manage_7", show)			
end

--�����ḱ��
function ActivityDelegate:doUnionInstance(bShow)
	self:setActivated("activity_manage_19", bShow)
end

--����VIP
function ActivityDelegate:doMainVip(bShow)
	self:setActivated("activity_manage_25", bShow)
end