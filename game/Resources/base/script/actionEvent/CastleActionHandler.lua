require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
CastleActionHandler = CastleActionHandler or BaseClass(ActionEventHandler)
local g_simulator = SFGameSimulator:sharedGameSimulator()
	
function CastleActionHandler:__init()	
	--�ͻ���������빥��ս����
	local handleNet_G2C_CastleWar_JoinWar = function(reader)
		self:handleNet_G2C_CastleWar_JoinWar(reader)
	end
	--�ͻ�������μӹ���ս�б���
	local handleNet_CastleWar_FactionList = function(reader)
		self:handleNet_CastleWar_FactionList(reader)
	end
	--�����ڼ䣬����ʹ�ʱ��������������
	local handleNet_G2C_CastleWar_Enter = function(reader)
 		self:handleNet_G2C_CastleWar_Enter(reader)	
--		print("handleNet_G2C_CastleWar_Enter")
	end
	--�����ڼ䣬�߳��ʹ�ʱ��������������
	local handleNet_CastleWarExit = function(reader)
		self:handleNet_CastleWarExit(reader)
--		print("handleNet_CastleWarExit")
	end
	--����ˢ��ʱ��������������
	local handleNet_CastleWar_MonsterRefresh = function(reader)
		self:handleNet_CastleWar_MonsterRefresh(reader)
--		print("handleNet_CastleWar_MonsterRefresh")
	end
	--�ͻ������󹥳ǻʣ��ʱ�䷵��
	local handleNet_CastleWar_Time = function(reader)
		self:handleNet_CastleWar_Time(reader)
--		print("handleNet_CastleWar_Time")
	end
	--����Ԥ��ʼʱ��������ȫ����������
	local handleNet_CastleWar_PreStart = function(reader)
		self:handleNet_CastleWar_PreStart(reader)
--		print("handleNet_CastleWar_PreStart")
	end
	--���ǿ�ʼʱ��������ȫ����������
	local handleNet_CastleWar_Start = function(reader)
		self:handleNet_CastleWar_Start(reader)
--		print("handleNet_CastleWar_Start")
	end
	--���ǽ���ʱ��������ȫ����������
	local handleNet_CastleWar_End = function(reader)
		self:handleNet_CastleWar_End(reader)
--		print("handleNet_CastleWar_End")
	end
	
	local handleNet_G2C_CastleWar_OpenServerTime = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local time = reader:ReadLLong()
		G_getCastleWarMgr():setOpenServerTime(time)
	end
		
	self:Bind(ActionEvents.G2C_CastleWar_JoinWar,	handleNet_G2C_CastleWar_JoinWar)
	self:Bind(ActionEvents.G2C_CastleWar_FactionList,	handleNet_CastleWar_FactionList)
	self:Bind(ActionEvents.G2C_CastleWar_Enter,	handleNet_G2C_CastleWar_Enter)
	self:Bind(ActionEvents.G2C_CastleWar_Exit,	handleNet_CastleWarExit)	
	self:Bind(ActionEvents.G2C_CastleWar_MonsterRefresh, handleNet_CastleWar_MonsterRefresh)	
	self:Bind(ActionEvents.G2C_CastleWar_PreStart, handleNet_CastleWar_PreStart)		
	self:Bind(ActionEvents.G2C_CastleWar_End, handleNet_CastleWar_End)	
	self:Bind(ActionEvents.G2C_CastleWar_RequestTime, handleNet_CastleWar_Time)	
	self:Bind(ActionEvents.G2C_CastleWar_Start, handleNet_CastleWar_Start)	
	self:Bind(ActionEvents.G2C_CastleWar_OpenServerTime, handleNet_G2C_CastleWar_OpenServerTime)	
end

function CastleActionHandler:handleNet_CastleWar_PreStart(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	activityManageMgr:setActivityState("activity_manage_8", true)	--Ԥ��ʼʱ����Ϊ����	
	G_getCastleWarMgr():requestCastleWarTime()	--����һ�ι���ʱ��
end

function CastleActionHandler:handleNet_CastleWar_Start(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState("activity_manage_8", true)	--����ս��ʼ�����ü���״̬	
	G_getCastleWarMgr():setIsInCastleWarTime(true)	--���빥��ʱ��
	G_getCastleWarMgr():requestCastleWarTime()		--�����ٴ�����һ�ι���ʣ��ʱ�䣬�ڷ������˶�ʱ��
end

function CastleActionHandler:handleNet_CastleWar_End(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState("activity_manage_8", false)	--����ս���������÷Ǽ���״̬
	G_getCastleWarMgr():setIsInCastleWarTime(false)		--�˳�����ʱ��
	G_getCastleWarMgr():setCastleWarBossUnionName(nil)
end

function CastleActionHandler:handleNet_CastleWar_Time(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local startRemainSec = reader:ReadLLong()
	local endRemainSec = reader:ReadLLong()
	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()			
	activityManageMgr:setRemainSec("activity_manage_8", startRemainSec, endRemainSec)
	
	local isActivated = false		
	if startRemainSec > 0 and startRemainSec < 600 then		--Ԥ��ʼʱ����Ϊ����
		isActivated = true			
		G_getCastleWarMgr():setIsInCastleWarTime(false)
	elseif endRemainSec > 0 then --�������ʱ�����0�����ʾ�������ڽ��й���
		isActivated = true
		G_getCastleWarMgr():setIsInCastleWarTime(true)
	end
	activityManageMgr:setActivityState("activity_manage_8", isActivated)
end


	
function CastleActionHandler:handleNet_CastleWar_MonsterRefresh(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local castleWarBossUnionName = StreamDataAdapter:ReadStr(reader)	
	G_getCastleWarMgr():setCastleWarBossUnionName(castleWarBossUnionName)
	GlobalEventSystem:Fire(GameEvent.EventCastleWarBossUnionName, castleWarBossUnionName, true)
end

function CastleActionHandler:handleNet_G2C_CastleWar_Enter(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local castleWarBossUnionName = StreamDataAdapter:ReadStr(reader) --Juchao@20140506:��ʱע�ͣ��ȴ��������ͬ���ύ����	
	G_getCastleWarMgr():setIsInCastleWarTime(true)	
	G_getCastleWarMgr():setCastleWarBossUnionName(castleWarBossUnionName)	
	GlobalEventSystem:Fire(GameEvent.EventCastleWarBossUnionName, castleWarBossUnionName)
end
	
function CastleActionHandler:handleNet_CastleWarExit(reader)
	G_getCastleWarMgr():setIsInCastleWarTime(false)
end

function CastleActionHandler:handleNet_G2C_CastleWar_JoinWar(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ret = reader:ReadChar()
	if ret == 1 then
		UIManager.Instance:showSystemTips(Config.Words[18008])
	end
end

function CastleActionHandler:handleNet_CastleWar_FactionList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local count = reader:ReadShort()
	local list = {}
	for i = 1, count do 
		local name = StreamDataAdapter:ReadStr(reader)
		table.insert(list, {name = name})
	end
	G_getCastleWarMgr():setCastleWarFactionList(list)
	GlobalEventSystem:Fire(GameEvent.EventCastleWarFactionList, list)
end		