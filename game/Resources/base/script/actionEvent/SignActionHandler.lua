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
	
	if ttype == 2 then	--�ۻ�ǩ��
		local signMgr = GameWorld.Instance:getSignManager()
		local awardList = signMgr:getAwardList()
		awardList[refId] = 2
		GlobalEventSystem:Fire(GameEvent.EventSignViewAwardUpdate)	
		activityManageMgr:setActivityState("activity_manage_1", true)
	elseif ttype == 5 then	--����
		local rideAwardList = rtwMgr:getRideAwardList()	
		rideAwardList[refId] = 2
		activityManageMgr:setActivityState("activity_manage_4",true)	
		GlobalEventSystem:Fire(GameEvent.EventRTWAwardViewUpdate)
		ActivityDelegate:showEffectInUpGradeButton(true)	--mark
	elseif ttype == 6 then	--����		
		local levelUpAwardList = rtwMgr:getLevelUpAwardList()
		levelUpAwardList[refId] = 2
		activityManageMgr:setActivityState("activity_manage_17",true)
		ActivityDelegate:showEffectInLevelupButton(true)--mark
	elseif ttype == 7 then	--��ʱ���
		activityManageMgr:setActivityState("activity_manage_18",true)
		ActivityDelegate:showEffectInLimitRankButton(true)--mark
	end		
end		

--ǩ������
--0����ǩ�����أ�������ֵ�ǲ�ǩĳһ���µļ���
function SignActionHandler:handleNet_G2C_Sign_SignIn(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local signIndex = StreamDataAdapter:ReadChar(reader)	
	local signMgr = GameWorld.Instance:getSignManager()
	if signIndex == 0 then	--��ͨǩ��
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
	crtCalender		= 	string	//��ǰʱ��(������20140101)
	daysOfMonth		=	byte	//��ǰ�µ�����
	canNormalSign	=	byte	//�ܷ����ǩ��(0:������,1:����)
	canMakeupSign	=	byte	//�ܷ���Բ�ǩ(0:������,1:����)
	count			=	byte	//ǩ������
	{
		day			=	byte	//�Ѿ�ǩ����ĳһ��ļ���
	}
	number			=	short
	{
		refId		=	����refId
		state		=	��ȡ״̬(0:δ��ȡ,1:����ȡ 2:����ȡ��δ��ȡ)
	}

]]
function SignActionHandler:handleNet_G2C_Sign_SignList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	local signMgr = GameWorld.Instance:getSignManager()
	local timeStr = StreamDataAdapter:ReadStr(reader)	
	local dayOfMonth = StreamDataAdapter:ReadChar(reader)
	--��ʼ���б�
	signMgr:setDateStr(timeStr)
	signMgr:setDaysOfMonth(dayOfMonth)	
	signMgr:initSignList(dayOfMonth)
	local signState = StreamDataAdapter:ReadChar(reader)			
	local fillSignState = StreamDataAdapter:ReadChar(reader)
	local signCount = StreamDataAdapter:ReadChar(reader)			
	signMgr:setCanNormalSign(signState == 1)	--�Ƿ����ͨǩ��
		
	if fillSignState == 1 then	--����ǩ���Ƿ���Բ�ǩ
		signMgr:setFillSignState(true)
	else
		signMgr:setFillSignState(false)
	end		
	signMgr:setSignDayCount(signCount)
	--�����б�	
	for i=1,signCount  do
		local index = StreamDataAdapter:ReadChar(reader)		
		signMgr:signIndex(index)
	end
	local awardList = signMgr:getAwardList()
	local awarCount = StreamDataAdapter:ReadChar(reader)  --short->byte
	for i= 1, awarCount do	--�ۻ�ǩ���б�
		local awardRefId = StreamDataAdapter:ReadStr(reader)
		local state = StreamDataAdapter:ReadChar(reader)	
		awardList[awardRefId] = state			
	end
	GlobalEventSystem:Fire(GameEvent.EventSignViewUpdate)	
	--������ͨǩ�������ۼ�ǩ������ʱ���ûΪ����״̬
	activityMgr:setActivityState("activity_manage_1", signMgr:hasSignAward() or signMgr:canNormalSign())	
end

--�ۼ�ǩ����ȡ��������
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

