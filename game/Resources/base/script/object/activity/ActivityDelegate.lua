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
设置活动回调
传递给回调函数的参数列表为：refId, activityType, event, info
refId: 发生事件的活动的refId
activityType：发生事件的活动的类型
event:发生的具体事件，分别为enable, active, open, time
	enable: 使能状态发生变化
	activite：激活状态发生变化
	open：打开状态发生变		
	time：倒计时发生变化
--]]	
function ActivityDelegate:onActivityNotify(refId, activityType, event, info)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	if event == "time" then
		local obj = activityManageMgr:getActivityByRefId(refId)
		local startRemainSec, endRemainSec
		if obj then
			startRemainSec, endRemainSec = obj:getRemainSec()	--获取该活动的开启剩余时间和结束剩余时间
		end
		if info == 1 or info == 3 then	--开始倒计时发生变化
			if startRemainSec and AdjustRemainTimePoint[startRemainSec] then		
				if refId == "activity_manage_8" then	--沙巴克攻城校验时间
					G_getCastleWarMgr():requestCastleWarTime()
--					print("adjust shabake time")
				elseif refId == "activity_manage_3" then
					self:activityOnlineTimeNotify()		
				elseif refId == "activity_manage_6" then--怪物入侵校验时间
					GameWorld.Instance:getMonstorInvasionMgr():requestRemainingTime()
				elseif refId == "activity_manage_7" then--挖矿校验时间
					GameWorld.Instance:getMiningMgr():requestRemainingTime()
				end
			end
		end
		if info == 2 or info == 3 then	--结束倒计时发生变化
			if endRemainSec and AdjustRemainTimePoint[endRemainSec] then
				if refId == "activity_manage_8" then	--沙巴克攻城校验时间
					G_getCastleWarMgr():requestCastleWarTime()
--					print("adjust shabake time")
				elseif refId == "activity_manage_6" then--怪物入侵校验时间
					GameWorld.Instance:getMonstorInvasionMgr():requestRemainingTime()
				elseif refId == "activity_manage_7" then--挖矿校验时间
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

--处理在线时长
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

--处理7天登录
function ActivityDelegate:doSevenLoginBySever(num, showLable, showIcon)
	self:setActivated("activity_manage_2", showLable)	
	self:setEnable("activity_manage_2", (showIcon ~= false))						
end

--处理天梯
function ActivityDelegate:doArenaBySever(canReceive)
	self:setActivated("activity_manage_5", canReceive > 0)
end

--隐藏首充按钮
function ActivityDelegate:hideFirstPayGiftBagBut()
	self:setEnable("activity_manage_13", false)
end

--进阶奖励
function ActivityDelegate:showEffectInUpGradeButton(bShow)
	self:setActivated("activity_manage_4", bShow)
end

--遮天基金
function ActivityDelegate:showEffectInFundButton(show)
	self:setActivated("activity_manage_12", show)
end

--升级
function ActivityDelegate:showEffectInLevelupButton(show)
	self:setActivated("activity_manage_17", show)
end

--限时冲榜
function ActivityDelegate:showEffectInLimitRankButton(show)
	self:setActivated("activity_manage_18", show)
end

--首充按钮边框特效
function ActivityDelegate:showEffectInFirstPayButton(show)
	self:setActivated("activity_manage_13", show)
end

--充值边框特效
function ActivityDelegate:showEffectInPayAwardButton(show)
	self:setActivated("activity_manage_14", show)	
end

--首充按钮边框特效
function ActivityDelegate:showEffectInFirstPayButton(show)
	self:setActivated("activity_manage_13", show)
end

--累积充值奖励边框特效
function ActivityDelegate:showEffectInPayAwardButton(show)
	self:setActivated("activity_manage_14", show)	
end

--每日充值按钮边框特效
function ActivityDelegate:showEffectInEveryDayPayAwardButton(show)
	self:setActivated("activity_manage_10", show)	
end

--每周消费按钮边框特效
function ActivityDelegate:showEffectInEveryWeekConsumeAwardButton(show)
	self:setActivated("activity_manage_11", show)		
end

--处理打折出售
function ActivityDelegate:doDiscountSellBySever(show)
--	self:setEnable("activity_manage_9", show)	
	self:setActivated("activity_manage_9", show)	
end


--处理采矿开启关闭
function ActivityDelegate:doMiningStatusBySever(bShow)
--	self:setEnable("activity_manage_7", show)		
	self:setActivated("activity_manage_7", show)			
end

--处理公会副本
function ActivityDelegate:doUnionInstance(bShow)
	self:setActivated("activity_manage_19", bShow)
end

--处理VIP
function ActivityDelegate:doMainVip(bShow)
	self:setActivated("activity_manage_25", bShow)
end