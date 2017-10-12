require "data.activity.monsterInvasion"
MonstorInvasionActionHandler = MonstorInvasionActionHandler or BaseClass(ActionEventHandler)

function MonstorInvasionActionHandler:__init()
	local g2c_remainingTime = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handle_RemainingTime(reader)
	end
	
	local g2c_enterActivity = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_enterActivity(reader)
	end
	
	local g2c_exitActivity = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_exitActivity(reader)
	end 
	
	local g2c_activityTitle = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_showActivityTitle(reader)
	end
	
	local g2c_bossRefreshTime = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_refreshBossTime(reader)
	end
	
	local isStart = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		self:handle_isStart(reader)
	end
		
	self:Bind(ActionEvents.G2C_MonsterIntrusion_IsStart, isStart)
	self:Bind(ActionEvents.G2C_MonsterIntrusion_BossTimeRefresh, g2c_bossRefreshTime)
	self:Bind(ActionEvents.G2C_MonsterIntrusion_Font, g2c_activityTitle)
	self:Bind(ActionEvents.G2C_MonsterIntrusion_EnterMap, g2c_enterActivity)
	self:Bind(ActionEvents.G2C_MonsterIntrusion_LeaveMap, g2c_exitActivity)
	self:Bind(ActionEvents.G2C_MonsterIntrusion_ContinuTime, g2c_remainingTime)  --活动剩余时间
end	

function MonstorInvasionActionHandler:handle_isStart(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local bStart = reader:ReadChar()
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
	monstorInvasionMgr:setStartFlag(bStart)	
	if bStart == 1 then   --活动已经开始
		local heroLv = PropertyDictionary:get_level(G_getHero():getPT())
			
		if heroLv >= GameData.MonsterInvasion["monsterInvasion1"].activityData["monsterInvasion1"].property.level then
			activityManageMgr:setActivityState("activity_manage_6", true)
		end
	else
		activityManageMgr:setActivityState("activity_manage_6", false)
	end
end

function MonstorInvasionActionHandler:handle_refreshBossTime(reader)
	local monsterRefId = StreamDataAdapter:ReadStr(reader)
	local sceneRefId = StreamDataAdapter:ReadStr(reader)
	local refreshTime = StreamDataAdapter:ReadLLong(reader)
	local isDeath = reader:ReadChar()
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()	
	if isDeath == 0 then 
		monstorInvasionMgr:setBossDeath(true)  --boss已经被击杀
	else 	
		monstorInvasionMgr:setBossDeath(false)
	end	
	monstorInvasionMgr:setMonsterRefId(monsterRefId)	
	monstorInvasionMgr:setBossSceneRefId(sceneRefId)  --boss所在场景的refId	
	GlobalEventSystem:Fire(GameEvent.EventBossRefreshTime, refreshTime, monsterRefId)
end

function MonstorInvasionActionHandler:handle_RemainingTime(reader)
	local startRemainSec = StreamDataAdapter:ReadLLong(reader)
	local endRemainSec = StreamDataAdapter:ReadLLong(reader)
	--local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
		
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setRemainSec("activity_manage_6", startRemainSec, endRemainSec)	
end

--进入活动
function MonstorInvasionActionHandler:handle_enterActivity(reader)
	UIManager.Instance:hideUI("ActivityManageView")
	local remainingTime = StreamDataAdapter:ReadLLong(reader)
	local exp = reader:ReadDouble()		
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()	
--	monstorInvasionMgr:setisInActivity(true)		
	GlobalEventSystem:Fire(GameEvent.EventEnterMonstorInvasion, remainingTime, exp)
	GlobalEventSystem:Fire(GameEvent.EventUpdateHeroTitle)
end

--离开活动
function MonstorInvasionActionHandler:handle_exitActivity(reader)
	local heroObj = G_getHero()	
	PropertyDictionary:set_monsterInvasionFont(heroObj:getPT(), 0)
	heroObj:updateMonstorInvasionTitle(heroObj:getPT())	
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
--	monstorInvasionMgr:setisInActivity(false)	
	GlobalEventSystem:Fire(GameEvent.EventExitMonstorInvasion)
	--离开活动关闭兑换界面
	local shopView = UIManager.Instance:getViewByName("ShopView")
	if shopView then 
		shopView:close()
	end
end

--显示任务
function MonstorInvasionActionHandler:handle_showActivityTitle(reader)
	local fType = reader:ReadChar()
	G_getHero():setMonstorInvasionTitle(fType)
end