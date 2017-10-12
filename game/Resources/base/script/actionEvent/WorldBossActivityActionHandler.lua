require("actionEvent.ActionEventDef")
require("common.ActionEventHandler")

WorldBossActivityActionHandler = WorldBossActivityActionHandler or BaseClass(ActionEventHandler)

local teamBossTypeList = {
[1] = "activity_manage_20",
[2] = "activity_manage_21",
[3] = "activity_manage_22",
}


function WorldBossActivityActionHandler:__init()
--[[	
	G2C_PlayerTeamBoss_PreStart    	= Team_Message_Begin + 65,      --�����вμӹ�������Ԥ��ʼ֪ͨ type       =    byte	
G2C_PlayerTeamBoss_End		   	= Team_Message_Begin + 15,      --����ս����֪ͨ���ͻ����Ƴ�״̬ʹ�ã�.....���ض��󣺲�ս������������߳�Ա��type       =    byte	
C2G_PlayerTeamBoss_RequestTime 	= Team_Message_Begin + 66,    	--���󹥳�սʱ�����
G2C_PlayerTeamBoss_RequestTime 	= Team_Message_Begin + 67,    	--����ս���ʱ�䷵�� timeToStart =	long	//������ʼʵ�� timeToEnd 	=	long	//��������ʱ��
G2C_PlayerTeamBoss_Start  		= Team_Message_Begin + 68,   
--]]
	local handleG2C_PlayerTeamBoss_PreStart = function(reader)
		self:handleG2C_PlayerTeamBoss_PreStart(reader)
	end
	local handleG2C_PlayerTeamBoss_End = function(reader)
		self:handleG2C_PlayerTeamBoss_End(reader)
	end
	local handleG2C_PlayerTeamBoss_RequestTime = function(reader)
		self:handleG2C_PlayerTeamBoss_RequestTime(reader)
	end
	local handleG2C_PlayerTeamBoss_Start = function(reader)
		self:handleG2C_PlayerTeamBoss_Start(reader)
	end
	
	local handleG2C_PlayerTeamBoss_Show = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local mgr = GameWorld.Instance:getWorldBossActivityMgr()
		mgr:setNeedShowView(true)
	end
	
	local showFightPowerNotEnoughTips = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local fightPowerRequire = StreamDataAdapter:ReadInt(reader)
		local tipsStr = string.format(Config.Words[25535],fightPowerRequire)
		UIManager.Instance:showSystemTips(tipsStr)
	end
	
	self:Bind(ActionEvents.G2C_Scene_FightPower_NotEnough,showFightPowerNotEnoughTips)
	self:Bind(ActionEvents.G2C_PlayerTeamBoss_Show,handleG2C_PlayerTeamBoss_Show)
	self:Bind(ActionEvents.G2C_PlayerTeamBoss_PreStart,handleG2C_PlayerTeamBoss_PreStart)
	self:Bind(ActionEvents.G2C_PlayerTeamBoss_End,handleG2C_PlayerTeamBoss_End)	
	self:Bind(ActionEvents.G2C_PlayerTeamBoss_RequestTime,handleG2C_PlayerTeamBoss_RequestTime)	
	self:Bind(ActionEvents.G2C_PlayerTeamBoss_Start,handleG2C_PlayerTeamBoss_Start)
end

function WorldBossActivityActionHandler:handleG2C_PlayerTeamBoss_PreStart(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ttype = StreamDataAdapter:ReadChar(reader)  --�Ԥ��ʼ����
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	mgr:setCurrentActivityType(ttype)
	ActivityDelegate:setEnable(teamBossTypeList[ttype], true)
	if mgr:getActivityStep(ttype) ~= 1 then
		mgr:requestReaminTime()
		mgr:setActivityStep(ttype,1)
	end
end	

function WorldBossActivityActionHandler:handleG2C_PlayerTeamBoss_End(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ttype = StreamDataAdapter:ReadChar(reader)  --�����
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	if mgr:getActivityStep(ttype) ~= 3 then
		mgr:requestReaminTime()
		mgr:setActivityStep(ttype,3)
	end
	mgr:setCurrentActivityType(ttype)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState(teamBossTypeList[ttype], false)
	ActivityDelegate:setEnable(teamBossTypeList[ttype], false)		
end	

function WorldBossActivityActionHandler:handleG2C_PlayerTeamBoss_RequestTime(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local timeToStart = StreamDataAdapter:ReadLLong(reader)
	local timeToEnd = StreamDataAdapter:ReadLLong(reader)
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	local ttype  = 	mgr:getCurrentActivityType()
	mgr:setTimeToStart(timeToStart)
	mgr:setTimeToEnd(timeToEnd)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	activityManageMgr:setRemainSec(teamBossTypeList[ttype], timeToStart, timeToEnd)	
	if timeToEnd > 0 then --�������ʱ�����0�����ʾ�������ڽ��й���
		--mgr:setIsInWorldBossActivityTime(true)
	end
end

function WorldBossActivityActionHandler:handleG2C_PlayerTeamBoss_Start(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ttype = StreamDataAdapter:ReadChar(reader)  --�����
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()	
	if mgr:getActivityStep(ttype) ~= 2 then
		mgr:requestReaminTime()
		mgr:setActivityStep(ttype,2)
	end
	mgr:setCurrentActivityType(ttype)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	ActivityDelegate:setEnable(teamBossTypeList[ttype], true)	
	activityManageMgr:setActivityState(teamBossTypeList[ttype], true)			
end

function WorldBossActivityActionHandler:__delete()

end