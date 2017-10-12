require "data.activity.monsterInvasion"
MonstorInvasionUIHandler = MonstorInvasionUIHandler or BaseClass(GameEventHandler)

function MonstorInvasionUIHandler:__init()
	local onEnterMonstorInvasion = function (remainingTime, exp)
		self:handle_enterMonstorInvasion(remainingTime, exp)
	end
	local onExitMonstorInvasion = function ()
		self:handle_exitMonstorInvasion()
	end
	local onRefreshBossTime = function (count, monsterRefId)
		self:handle_refreshBossTime(count, monsterRefId)
	end
	local checkMonstorInvasionStart = function()
		self:handle_checkMonstorInvasionStart()
	end
	local heroLvChange = function (newLv, preLv)
		self:handle_HeroLvChange(newLv, preLv)
	end
	
	local bagItemChange = function (eventType, map)
		self:handle_bagItemChange(map)
	end  
	local updateTitle = function ()
		self:updateTitle()
	end
	self:Bind(GameEvent.EventUpdateHeroTitle, updateTitle)
	self:Bind(GameEvent.EventItemUpdate, bagItemChange)
	self:Bind(GameEvent.EventHeroLevelChanged, heroLvChange)
	self:Bind(GameEvent.EventHeroEnterGame, checkMonstorInvasionStart)
	self:Bind(GameEvent.EventBossRefreshTime, onRefreshBossTime)
	self:Bind(GameEvent.EventEnterMonstorInvasion, onEnterMonstorInvasion)
	self:Bind(GameEvent.EventExitMonstorInvasion, onExitMonstorInvasion)
end

function MonstorInvasionUIHandler:__delete()
	
end

function MonstorInvasionUIHandler:handle_HeroLvChange(newLv, preLv)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
		
	local archiveLv = GameData.MonsterInvasion["monsterInvasion1"].activityData["monsterInvasion1"].property.level	
	if newLv >= archiveLv and monstorInvasionMgr:isStart() then
		activityManageMgr:setActivityState("activity_manage_6", true)
	end
end

function MonstorInvasionUIHandler:handle_checkMonstorInvasionStart()
	local monstroMgr = G_getHero():getMonstorInvasionMgr()
	monstroMgr:requestIsMonstorInvasionStart()
end

function MonstorInvasionUIHandler:handle_enterMonstorInvasion(remainingTime, exp)
	local manager =UIManager.Instance	
	local mainView = manager:getMainView()	
	if mainView then 	
		-- 新手指引完成
		GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_6")	
			
		GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,false)
		mainView:setMainOtherBtnVisible(MainOtherType.LeaveActivity,true)
		mainView:setMonstorInvasionViewVisible(true)  --显示面板		
		local monstorView = mainView:getMonstorInvasionView()
		if monstorView then		
			monstorView:start(remainingTime, exp)		      --开始倒计时
		end
	end
	local activityTips = manager:getViewByName("WorldBossView")	
	if activityTips then
		if manager:isShowing("WorldBossView") then
			activityTips:close()
		end
	end
end

function MonstorInvasionUIHandler:handle_exitMonstorInvasion()
	local manager =UIManager.Instance	
	local mainView = manager:getMainView()
	if mainView then 
		local monstorView = mainView:getMonstorInvasionView()
		if monstorView then		
			monstorView:stop()		      --停止倒计时
		end	
		mainView:setMainOtherBtnVisible(MainOtherType.LeaveActivity, false)
		mainView:setMonstorInvasionViewVisible(false)  --显示面板	
		--mainView:setQuestVisible(true)	
		GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,true)
	end
end

--boss刷新时间
function MonstorInvasionUIHandler:handle_refreshBossTime(count, monsterRefId)
	local manager =UIManager.Instance	
	local mainView = manager:getMainView()
	if mainView then 
		local monstorView = mainView:getMonstorInvasionView()
		if monstorView then				
			monstorView:updateBossInfo(monsterRefId, count)							
		end			
	end
end

function MonstorInvasionUIHandler:handle_bagItemChange(map)
	local mgr = G_getHero():getMonstorInvasionMgr()
	if not mgr:isInActivity() then
		return
	end
	local bUpdate = false
	for grid, item in pairs(map) do
		if item:getRefId() == "item_coupon" or item:getRefId() == "item_coupon_2" then
			bUpdate = true
			break
		end
	end
	if bUpdate then		
		self:updateTitle()
	end
end

function MonstorInvasionUIHandler:updateTitle()
	local heroObj = G_getHero()
	local con1 = G_getBagMgr():getItemNumByRefId("item_coupon")
	local con2 = G_getBagMgr():getItemNumByRefId("item_coupon_2")
	local cnt = con1+con2*20
	local font = 0
	if cnt == 0 then 
		font = 0
	elseif cnt >= 1 and cnt <= 30 then 
		font = 1
	elseif cnt<=200 then 
		font = 2
	else
		font = 3
	end
	PropertyDictionary:set_monsterInvasionFont(heroObj:getPT(), font)
	heroObj:updateMonstorInvasionTitle(heroObj:getPT())	
end