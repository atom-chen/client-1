require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

SignActionHandler = SignActionHandler or BaseClass(ActionEventHandler)

function SignActionHandler:__init()	
	local handle_G2C_Sign_AwardCanGet = function(reader)
		self:handle_G2C_Sign_AwardCanGet(reader)
	end
	local handleNet_G2C_Sign_SignIn = function(reader)
		self:handleNet_G2C_Sign_SignIn(reader)
	end
	
	local handleNet_G2C_Sign_SignList = function(reader)
		self:handleNet_G2C_Sign_SignList(reader)
	end
	
	local handle_G2C_Activity_GetAward = function(reader)
		self:handle_G2C_Activity_GetAward(reader)
	end
	
	self:Bind(ActionEvents.G2C_Activity_GetAward,handle_G2C_Activity_GetAward)
	self:Bind(ActionEvents.G2C_Sign_AwardCanGet,handle_G2C_Sign_AwardCanGet)
	self:Bind(ActionEvents.G2C_Sign_SignIn, handleNet_G2C_Sign_SignIn)
	self:Bind(ActionEvents.G2C_Sign_SignList,handleNet_G2C_Sign_SignList)				
end

function SignActionHandler:handle_G2C_Sign_AwardCanGet(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local ttype = StreamDataAdapter:ReadChar(reader)
	local refId = StreamDataAdapter:ReadStr(reader)	
	local rtwMgr = GameWorld.Instance:getLevelAwardManager()	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	
	if ttype == 2 then	--累积签到
		local signMgr = GameWorld.Instance:getSignManager()
		local awardList = signMgr:getAwardList()
		awardList[refId] = 2
		GlobalEventSystem:Fire(GameEvent.EventSignViewAwardUpdate)	
		activityManageMgr:setActivityState("activity_manage_1", true)
	elseif ttype == 5 then	--进阶
		local rideAwardList = rtwMgr:getRideAwardList()	
		rideAwardList[refId] = 2
		activityManageMgr:setActivityState("activity_manage_4",true)	
		GlobalEventSystem:Fire(GameEvent.EventRTWAwardViewUpdate)
		ActivityDelegate:showEffectInUpGradeButton(true)	--mark
	elseif ttype == 6 then	--升级		
		local levelUpAwardList = rtwMgr:getLevelUpAwardList()
		levelUpAwardList[refId] = 2
		activityManageMgr:setActivityState("activity_manage_17",true)
		ActivityDelegate:showEffectInLevelupButton(true)--mark
	elseif ttype == 7 then	--限时冲榜
		activityManageMgr:setActivityState("activity_manage_18",true)
		ActivityDelegate:showEffectInLimitRankButton(true)--mark
	end		
end		

--签到返回
--0正常签到返回；其他数值是补签某一个月的几号
function SignActionHandler:handleNet_G2C_Sign_SignIn(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local signIndex = StreamDataAdapter:ReadChar(reader)	
	local signMgr = GameWorld.Instance:getSignManager()
	if signIndex == 0 then	--普通签到
		signMgr:setCanNormalSign(false)	
		local activityMgr = GameWorld.Instance:getActivityManageMgr()
		activityMgr:setActivityState("activity_manage_1", signMgr:hasSignAward() or signMgr:canNormalSign())
	else
		local list = signMgr:getSignList()
		signMgr:setFillSignState(false)		
		for i= signIndex,signMgr:getCurrentDay()-1 do
			if list[i] == false then
				signMgr:setFillSignState(true)	
			end
		end	
	end
	GlobalEventSystem:Fire(GameEvent.EventSignViewSign, signIndex)					
end
--[[
	crtCalender		= 	string	//当前时间(年月日20140101)
	daysOfMonth		=	byte	//当前月的天数
	canNormalSign	=	byte	//能否可以签到(0:不可以,1:可以)
	canMakeupSign	=	byte	//能否可以补签(0:不可以,1:可以)
	count			=	byte	//签到次数
	{
		day			=	byte	//已经签到的某一天的几号
	}
	number			=	short
	{
		refId		=	奖励refId
		state		=	领取状态(0:未领取,1:已领取 2:可领取而未领取)
	}

]]
function SignActionHandler:handleNet_G2C_Sign_SignList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	local signMgr = GameWorld.Instance:getSignManager()
	local timeStr = StreamDataAdapter:ReadStr(reader)	
	local dayOfMonth = StreamDataAdapter:ReadChar(reader)
	--初始化列表
	signMgr:setDateStr(timeStr)
	signMgr:setDaysOfMonth(dayOfMonth)	
	signMgr:initSignList(dayOfMonth)
	local signState = StreamDataAdapter:ReadChar(reader)			
	local fillSignState = StreamDataAdapter:ReadChar(reader)
	local signCount = StreamDataAdapter:ReadChar(reader)			
	signMgr:setCanNormalSign(signState == 1)	--是否可普通签到
		
	if fillSignState == 1 then	--今日签到是否可以补签
		signMgr:setFillSignState(true)
	else
		signMgr:setFillSignState(false)
	end		
	signMgr:setSignDayCount(signCount)
	--更新列表	
	for i=1,signCount  do
		local index = StreamDataAdapter:ReadChar(reader)		
		signMgr:signIndex(index)
	end
	local awardList = signMgr:getAwardList()
	local awarCount = StreamDataAdapter:ReadChar(reader)  --short->byte
	for i= 1, awarCount do	--累积签到列表
		local awardRefId = StreamDataAdapter:ReadStr(reader)
		local state = StreamDataAdapter:ReadChar(reader)	
		awardList[awardRefId] = state			
	end
	GlobalEventSystem:Fire(GameEvent.EventSignViewUpdate)	
	--可以普通签到或有累计签到奖励时设置活动为激活状态
	activityMgr:setActivityState("activity_manage_1", signMgr:hasSignAward() or signMgr:canNormalSign())	
end

--累计签到领取奖励返回
function SignActionHandler:handle_G2C_Activity_GetAward(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local refId = StreamDataAdapter:ReadStr(reader)	
	local signMgr = GameWorld.Instance:getSignManager()	
	local awardList = signMgr:getAwardList()
	if awardList[refId]	then
		awardList[refId] = 1
	end
	GlobalEventSystem:Fire(GameEvent.EventSignViewAwardUpdate)	
	
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	activityMgr:setActivityState("activity_manage_1", signMgr:hasSignAward() or signMgr:canNormalSign())	
end

