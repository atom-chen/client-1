require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
CastleActionHandler = CastleActionHandler or BaseClass(ActionEventHandler)
local g_simulator = SFGameSimulator:sharedGameSimulator()
	
function CastleActionHandler:__init()	
	--客户端请求加入攻城战返回
	local handleNet_G2C_CastleWar_JoinWar = function(reader)
		self:handleNet_G2C_CastleWar_JoinWar(reader)
	end
	--客户端请求参加攻城战列表返回
	local handleNet_CastleWar_FactionList = function(reader)
		self:handleNet_CastleWar_FactionList(reader)
	end
	--攻城期间，进入皇宫时服务器主动推送
	local handleNet_G2C_CastleWar_Enter = function(reader)
 		self:handleNet_G2C_CastleWar_Enter(reader)	
--		print("handleNet_G2C_CastleWar_Enter")
	end
	--攻城期间，走出皇宫时服务器主动推送
	local handleNet_CastleWarExit = function(reader)
		self:handleNet_CastleWarExit(reader)
--		print("handleNet_CastleWarExit")
	end
	--怪物刷新时服务器主动推送
	local handleNet_CastleWar_MonsterRefresh = function(reader)
		self:handleNet_CastleWar_MonsterRefresh(reader)
--		print("handleNet_CastleWar_MonsterRefresh")
	end
	--客户端请求攻城活动剩余时间返回
	local handleNet_CastleWar_Time = function(reader)
		self:handleNet_CastleWar_Time(reader)
--		print("handleNet_CastleWar_Time")
	end
	--攻城预开始时，服务器全服主动推送
	local handleNet_CastleWar_PreStart = function(reader)
		self:handleNet_CastleWar_PreStart(reader)
--		print("handleNet_CastleWar_PreStart")
	end
	--攻城开始时，服务器全服主动推送
	local handleNet_CastleWar_Start = function(reader)
		self:handleNet_CastleWar_Start(reader)
--		print("handleNet_CastleWar_Start")
	end
	--攻城结束时，服务器全服主动推送
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
	activityManageMgr:setActivityState("activity_manage_8", true)	--预开始时设置为激活	
	G_getCastleWarMgr():requestCastleWarTime()	--申请一次攻城时间
end

function CastleActionHandler:handleNet_CastleWar_Start(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState("activity_manage_8", true)	--攻城战开始，设置激活状态	
	G_getCastleWarMgr():setIsInCastleWarTime(true)	--进入攻城时间
	G_getCastleWarMgr():requestCastleWarTime()		--这里再此申请一次攻城剩余时间，于服务器核对时间
end

function CastleActionHandler:handleNet_CastleWar_End(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState("activity_manage_8", false)	--攻城战结束，设置非激活状态
	G_getCastleWarMgr():setIsInCastleWarTime(false)		--退出攻城时间
	G_getCastleWarMgr():setCastleWarBossUnionName(nil)
end

function CastleActionHandler:handleNet_CastleWar_Time(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local startRemainSec = reader:ReadLLong()
	local endRemainSec = reader:ReadLLong()
	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()			
	activityManageMgr:setRemainSec("activity_manage_8", startRemainSec, endRemainSec)
	
	local isActivated = false		
	if startRemainSec > 0 and startRemainSec < 600 then		--预开始时设置为激活
		isActivated = true			
		G_getCastleWarMgr():setIsInCastleWarTime(false)
	elseif endRemainSec > 0 then --如果结束时间大于0，则表示现在正在进行攻城
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
	local castleWarBossUnionName = StreamDataAdapter:ReadStr(reader) --Juchao@20140506:暂时注释，等待与服务器同步提交代码	
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