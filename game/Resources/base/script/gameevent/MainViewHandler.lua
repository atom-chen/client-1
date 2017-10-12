require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("config.words")
require ("object.skillShow.player.CharacterAnimatePlayer")
require ("object.skillShow.AnimatePlayManager")
require("object.res.ResManager")
require("object.res.DownloadManager")
require ("ui.Main.MainView")
require("object.mainHeroState.HeroStateDef")

local const_level = 40

local const_pkModeTips = 
{
	[E_HeroPKState.statePeace] = {Config.Words[469],Config.Words[457]},
	[E_HeroPKState.stateQueue] = {Config.Words[474],Config.Words[475]},	
	[E_HeroPKState.stateGoodOrEvil] = {Config.Words[470],Config.Words[458]},
	[E_HeroPKState.stateFaction] = {Config.Words[471],Config.Words[459]},
	[E_HeroPKState.stateWhole] = {Config.Words[472],Config.Words[460]},
}

MainViewHandler = MainViewHandler or BaseClass(GameEventHandler)

function MainViewHandler:__init()
	local manager =UIManager.Instance
	self.delayShowViewSchId  = nil
	self.firstLoginGame = true		
	
	local eventMain = function ()	
		manager:showGameRootNode("MainView", MainView.create)
		GlobalEventSystem:Fire(GameEvent.EventMainViewCreated)
		
		local hero = GameWorld.Instance:getEntityManager():getHero()
		self:checkDownloadState(PropertyDictionary:get_level(hero:getPT()))
	end
	
	local onHeroEnterGame = function()
		GameWorld.Instance:getMiningMgr():requestRemainingTime()--请求挖矿剩余时间
	end
	
	--设置单个菜单按钮禁用、启用（按钮设置为灰度图）
	local function setMenuBtnstatus(MenuBtn,bEnable)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:onSetMenuBtnstatus(MenuBtn,bEnable)
		end
	end
	
	--设置所有菜单按钮禁用、启用（按钮设置为灰度图）
	local function setAllBtnStatus(bEnable)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:onSetAllBtnStatus(bEnable)
		end
	end
	
	
	--设置单个菜单功能开启、关闭（按钮设置为灰度图并加锁标志）
	local function setMenuSystemstatus(MenuBtn,bEnable)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:onSetMenuBtnOpenOrclose(MenuBtn,bEnable)
		end
	end
	
	--满足等级条件开启右上角图标接口
	local function heroLevelUp(newLv)
		-- 显示升级特效


		local hero = GameWorld.Instance:getEntityManager():getHero()
		local skillAniPlayer =  CharacterAnimatePlayer.New()
		skillAniPlayer:setPlayData(hero:getId(), hero:getEntityType(), 7420)
		GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", skillAniPlayer)
		--升级系统提示
		local tipMsg = {[1] = {word = Config.Words[15000], color = Config.FontColor["ColorYellow1"]},
						[2] = {word = tostring(newLv), color = Config.FontColor["ColorRed1"]},
						[3] = {word = Config.Words[15001], color = Config.FontColor["ColorYellow1"]},}
		--hero:twinkleTip(tipMsg, 6)
		UIManager.Instance:showSystemTips(tipMsg)
		--local upGradeTips = string.format("%s%d%s",Config.Words[15000],newLv,Config.Words[15001])
		UIManager.Instance:showSystemTips(upGradeTips)
		local soundMgr = GameWorld.Instance:getSoundMgr()
		soundMgr:playEffect("music/levelup.mp3" , false)		
		--下方菜单栏的开启状态的更新
		local mainMgr = hero:getMainMgr()
		local conditionList = mainMgr : getConditonLIst()
		if conditionList then
			for i,v in pairs(conditionList) do
				if newLv >= v.conditionValue then
					mainMgr:addBtnList(v.pos,v.icon,v.callBack)
					mainMgr:removeConditionList(v.pos)
					local manager =UIManager.Instance
					local view = manager:getMainView()
					if view then
						local mainActivity = view:getMainActivities()
						if(mainActivity ~= nil )then
							mainActivity:addOrRemoveIcon(v.pos,false,false)
							mainActivity:runAction(v.icon,v.pos)
						end
					end
				end
			end
		end
		
		self:checkDownloadState(newLv)
	end
	
	--切换主界面
	local function eventMoveView ()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:eventMoveView()
		end
	end
	
	--更新人物属性接口
	local function eventMainHeroPorpertyUpdate(pt)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:eventMainHeroPorpertyUpdate(pt)
		end
		--40级开启副本按钮
		local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
		if gameInstanceMgr:isInstanceOpen() then
			--[[local mapMgr = GameWorld.Instance:getMapManager()
			local kind = mapMgr:getCurrentMapKind()
			if kind ~= MapKind.instanceArea and kind ~= MapKind.ativityArea  then--]]
			if view then
				--if self.instanceOpenFlag ~= true then
				view:setMainOtherBtnVisible(MainOtherType.Instance, true)
					--self.instanceOpenFlag = true																					
			end
		else
			view:setMainOtherBtnVisible(MainOtherType.Instance, false)
				--[[local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()	
				local mailUnreadNum = mailMgr:getMailUnreadNum()
				GlobalEventSystem:Fire(GameEvent.EventMailBtnIsShow,mailUnreadNum)--]]				
		end
	end
	
	--更新Boss属性接口
	local function eventMainBOSSPorpertyUpdate(pt)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:eventMainBOSSPorpertyUpdate(pt)
		end
	end
	
	--显示其他玩家头像
	local function ShowPlayerHead(selectEntityObject, bShow)
		--如果是玩家自己  不应显示玩家头像
		if selectEntityObject then
			if selectEntityObject:getId() == G_getHero():getId() then
				return 
			end
		end
		local manager =UIManager.Instance
		local view = manager:getMainView()		
		if view then
			view:ShowPlayerHead(selectEntityObject, bShow)
		end
	end
	
	local function UpdatePlayerHead()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:UpdatePlayerPropertyData()
		end		
	end
	
	local leaveButton = function (show)
		self:changeLeaveInstanceButtonState(show)
	end
	
	local function eventIsShowBossView(bShow, entityId)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:eventIsShowBossView(bShow, entityId)
		end
	end
	
	local function showInteractionView()
		local view = UIManager.Instance:getMainView()
		if view then
			view:showPlayerInteractionView()
		end
	end
	
	local function changeStateBtn()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:updateHeroState()
		end
		
		local pk = G_getHero():getPKStateID()
		if not pk then
			return
		end
		if const_pkModeTips[pk] then
			local model = const_pkModeTips[pk][1]
			local tips = const_pkModeTips[pk][2]
			if tips and model then
				local msg = {}
				table.insert(msg,{word = Config.Words[473], color = Config.FontColor["ColorWhite1"]})
				table.insert(msg,{word = model, color = Config.FontColor["ColorRed3"]})
				table.insert(msg,{word = tips, color = Config.FontColor["ColorWhite1"]})
				UIManager.Instance:showSystemTips(msg)
			end
		end
		local view = manager:getMainView()
		if view then
			if pk == E_HeroPKState.statePeace or pk == E_HeroPKState.stateGoodOrEvil then--和平	
				view:setCanHandup(true)	
			else
				view:setCanHandup(false)	
			end
		end			
	end
	
	local function eventHandupConfig(config)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:eventHandupConfig(config)
		end
		local view1 = manager:getViewByName("SettingView")
		if view1 then
			view1:updateHandupConfigUI()
		end			
	end
	
--[[	local function showStrengthenQuest()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:showMianStrengthenQuest()
		end
	end--]]
	local function showMarquee()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:showMarquee()
		end
	end
	
	local function setFactionInviteBtnStatus(isShow)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:setFactionInviteBtnStatus(isShow)
		end	
	end
	local function setTeamInviteBtnStatus(isShow)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:setTeamInviteBtnStatus(isShow)
		end	
	end
	local function closeMarquee()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:closeMarquee()
		end
	end
	
	-- 刷新技能cd
	local function eventRefeshSkillCD(skillRefId, cdTime)
		self:eventRefeshSkillCD(skillRefId, cdTime)
	end
	
	-- 设置vip图标
	local function setVipIcon(vipLevel)
		local view = UIManager.Instance:getMainView()
		if view then		
			view:setVipIcon(vipLevel)
		end	
		local vipLuckMgr = GameWorld.Instance:getVipLuckManager()
		if vipLuckMgr then
			vipLuckMgr:requestOpenLuckDraw() 
		end
		
		if LoginWorld.Instance:getStatisticsMgr().submitExtendData then
			LoginWorld.Instance:getStatisticsMgr():submitExtendData()
		end
	end
	--设置离开活动按钮显示状态
	local leaveActivityButton = function (show)
		self:changeLeaveActivityButtonState(show)
	end
	--设置任务面板是否可见
	local setQuestVisible = function (bshow)
		self:setQuestVisible(bshow)
	end
	--设置世界boss按钮是否可见
	local changeMonsterBtnState = function (show)
		self:changeMonsterBtnState(show)
	end
	
	-- 开始下载扩展资源包
	local function download(isSlient)
		local view = UIManager.Instance:getMainView()
		self.hasError = nil
		self.hasClose = false		
		if isSlient and view then
			local downloadCallBack = function(eventCode, intValue, stringData, doubleValue)
				if not self.hasError then				
					self:handleDownloadDelegate(eventCode, intValue, stringData, doubleValue)
					GlobalEventSystem:Fire(GameEvent.EventSubPackageLoadViewUpdate,eventCode, intValue, stringData, doubleValue)					
				else
					if self.hasClose == false then
						DownloadManager.Instance:delayStop()
						GlobalEventSystem:Fire(GameEvent.EventCloseSubPackageView)
						self.hasClose = true						
						local view = UIManager.Instance:getMainView()
						if view then
							view:setDownloadState(DownloadState.Prepare)
						end	
					end							
				end									
			end
			GlobalEventSystem:Fire(GameEvent.EventSubPackageLoadViewReset)
			view:setDownloadState(DownloadState.Downloading)
			ResManager.Instance:startDownload(downloadCallBack)
		end
	end
	
	--监听场景切换，场景切换时把boss血条清除	
	local scene_switch_func = function ()	
		local bShow = false
		local entityId = nil
		GlobalEventSystem:Fire(GameEvent.EventMainIsShowBossView, bShow, entityId)
		GlobalEventSystem:Fire(GameEvent.EventShowPlayerHead, entityId, false)
    end	
	--设置挖矿任务面板是否可见
	local setMiningInfoVisible = function (bshow)
		self:setMiningInfoVisible(bshow)
	end
	--刷新挖矿任务面板信息
	local refreshCount = function ()
		self:refreshCount()
	end
	--设置副本按钮是否可见
	local setInstanceBtnVisible = function(bShow)
		self:setInstanceBtnVisible(bShow)
	end
	
	local setInstanceBtnAniamtion = function(bShow)
		self:setInstanceBtnAniamtion(bShow)
	end
	
	--开始挖矿任务面板活动剩余时间倒数
	local refreshMiningLeftTime = function ()
		self:refreshMiningLeftTime()
	end
	local stopMiningTime = function ()
		self:stopMiningTime()
	end		
	
	local refreshNextMineralTime = function()
		self:refreshNextMineralTime()
	end
	
	local onEventSceneChanged = function()
		local navigationMap =  self:getNavigationMap()
		if navigationMap then
			navigationMap:updateScene()
		end
		
		local view = UIManager.Instance:getMainView()
		if view then
			view:clearAllAttackers()
		end	 
	end
	
	local onEntityAdded = function(obj)	
		local navigationMap =  self:getNavigationMap()
		if not navigationMap then
			return
		end
		
		if obj:getEntityType() == EntityType.EntityType_Monster then				
			navigationMap:addMonster(obj)			
			local manager = GameWorld.Instance:getGameInstanceManager()
			manager:setFocusTeFirstMonsterPlayer(obj)
		elseif obj:getEntityType() == EntityType.EntityType_Player then
			local teamMgr = G_getHero():getTeamMgr()
			local teamObj = teamMgr:getTeamMemberById(obj:getId())
			if teamObj then		
				navigationMap:addTeammate(obj)
			end
		end			
	end	
	
	local onEntityRemoved = function(obj)	
		local navigationMap = self:getNavigationMap()
		if not navigationMap then
			return
		end
		
		if obj:getEntityType() == EntityType.EntityType_Monster then				
			navigationMap:removeMonster(obj)			
		elseif obj:getEntityType() == EntityType.EntityType_Player then
			local teamMgr = G_getHero():getTeamMgr()
			local teamObj = teamMgr:getTeamMemberById(obj:getId())
			if teamObj then
				navigationMap:removeTeammate(obj)
			end				
		end	
	end
	
	local eventBossOwnerChange = function (bossId, ownerId)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:bossOwnerChange(bossId, ownerId)
		end
	end
		
	local onShowNotifyView = function ()			
		if self.delayShowViewSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayShowViewSchId)
			self.delayShowViewSchId = nil
		end	
		local notifyMgr = LoginWorld.Instance:getNotifyManager()	
		if not notifyMgr:getFirstRoleLogin() then
			return
		end							
		local showView = function ()
			notifyMgr:removeValidNotifys()			
			if notifyMgr:needShow() then			
				notifyMgr:showNotifyViewInLogin()
			end									
			if self.delayShowViewSchId then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayShowViewSchId)
				self.delayShowViewSchId = nil
			end							
		end	
		
		local relayTime = 0.01
		if notifyMgr:getTotalNumber() ~= notifyMgr:getHaveReceiveNumber() then
			relayTime = 5
			notifyMgr:setReadyShow(true)
		end							
		self.delayShowViewSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(showView, relayTime, false);
	end		
	
	local function changeDownloadButtonState(show)
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			if show == nil then
				show = true
			end
			view:changeDownLoadButtonState(show)
		end
	end
	
	local function enterAutoFightView(state)
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:enterAutoFightView(state)
		end
	end
	
	local function enterShowPKHitView(bEnter)
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:enterShowPKHitView(bEnter)
		end
	end
	
	--[[local function onEventClickMountButtonCallBack()
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:mountButtonCallBack()
		end
	end--]]
	
	local function eventOpenRideControl(state)
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			local mapView = view:getMapView()		
			if not mapView then
				return
			end
				
			if state then
				mapView:showRideControl()
			else
				mapView:hideRideControl()
			end					
		end		
	end
	
	local function updatePing(level)
		local manager = UIManager.Instance
		local view = manager:getMainView()
		if view then
			if level then
				view:updatePing(level)
			end		
		end	
	end
	
	local function setUnionInstanceVisible(bShow)
		local view = manager:getMainView()
		if view then		
			view:showUnionInstanceViewVisible(bShow)				
		end
	end		
	
	local eventExitBossTemple = function()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:setMainOtherBtnVisible(MainOtherType.LeaveActivity,false)
			self:setInstanceBtnVisible(true)
		end
	end
	self:Bind(GameEvent.EventChangeMonsterBtnState, changeMonsterBtnState)

	local eventEnterBossTemple = function()
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:setMainOtherBtnVisible(MainOtherType.LeaveActivity,true)
			self:setInstanceBtnVisible(false)
		end
	end	
	
	local setFinishInstanceArrow = function(setType)
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			local mainQuest = view:getQuest()
			if mainQuest then
				if setType == "show" then
					mainQuest:showFinishInstanceArrow()
				elseif setType == "remove" then
					mainQuest:removeFinishInstanceArrow()
				end
			end
		end
	end		
	
	local function onShowPKInstace()
		local view = UIManager.Instance:getMainView()
		if view then
			view:eventShowPKInstace()
		end
	end
		
	local onEventBeAttacked = function(obj)		
		self:handleAttackerChanged(obj, true)		
	end
	
	local onEventAttackerRemoved = function(obj)
		self:handleAttackerChanged(obj, false)
	end
	
	self:Bind(GameEvent.EventHeroEnterGame,onHeroEnterGame)
	self:Bind(GameEvent.EventEnterBossTemple,eventEnterBossTemple)
	self:Bind(GameEvent.EventExitBossTemple,eventExitBossTemple)
	--self:Bind(GameEvent.EventClickMountButtonCallBack, onEventClickMountButtonCallBack)
	self:Bind(GameEvent.EventEntityAdded, onEntityAdded) 
	self:Bind(GameEvent.EventEntityRemoved, onEntityRemoved)  
	self:Bind(GameEvent.EventSceneChanged, onEventSceneChanged)		
	self:Bind(GameEvent.EventGameSceneReady, scene_switch_func)
	self:Bind(GameEvent.EVENT_MAIN_UI,eventMain)
	self:Bind(GameEvent.EventMainSetMenuBtnStatus, setMenuBtnstatus)
	self:Bind(GameEvent.EventMainSetAllMenuBtnStatus,setAllBtnStatus)
	self:Bind(GameEvent.EventOpenRideControl,eventOpenRideControl)
	self:Bind(GameEvent.EventSetSystemOpenStatus,setMenuSystemstatus)
	self:Bind(GameEvent.EventMoveMianView,eventMoveView)
	self:Bind(GameEvent.EventHeroProChanged, eventMainHeroPorpertyUpdate)
	self:Bind(GameEvent.EventPlayerHeadUpdate,UpdatePlayerHead)
	self:Bind(GameEvent.EventMainBOSSPorpertyUpdate, eventMainBOSSPorpertyUpdate)
	self:Bind(GameEvent.EventHeroLevelChanged,heroLevelUp,newLv)
	self:Bind(GameEvent.EventLeaveButtonStateChange,leaveButton)
	self:Bind(GameEvent.EventShowPlayerHead, ShowPlayerHead)
	self:Bind(GameEvent.EventMainIsShowBossView,eventIsShowBossView)
--	self:Bind(GameEvent.EventPlayerTeamStatus,showInteractionView)
	self:Bind(GameEvent.EventChangeStateBtn,changeStateBtn)
	self:Bind(GameEvent.EventHandupConfigChanged,eventHandupConfig)
	--self:Bind(GameEvent.EVENT_Main_StrengthenQuest_UI,showStrengthenQuest)
	self:Bind(GameEvent.EventSetFactionInviteBtnStatus,setFactionInviteBtnStatus)
	self:Bind(GameEvent.EventSetTeamInviteBtnStatus,setTeamInviteBtnStatus)
	self:Bind(GameEvent.EventShowMarquee,showMarquee)
	self:Bind(GameEvent.EventCloseMarquee,closeMarquee)		
	self:Bind(GameEvent.EventRefeshSkillCD,eventRefeshSkillCD)
	self:Bind(GameEvent.EventVipLevelChanged,setVipIcon)
	self:Bind(GameEvent.EventDownload, download)
	self:Bind(GameEvent.EventLeaveActivityBtnState,leaveActivityButton)
	self:Bind(GameEvent.EventSetQuestVisible,setQuestVisible)
	self:Bind(GameEvent.EventSetMiningVisible,setMiningInfoVisible)
	self:Bind(GameEvent.EventRefreshMiningCount,refreshCount)
	self:Bind(GameEvent.EventStartTimer,refreshMiningLeftTime)
	self:Bind(GameEvent.EventStopTimer,stopMiningTime)	
	self:Bind(GameEvent.EventSetInstanceBtnVisible,setInstanceBtnVisible)
	self:Bind(GameEvent.EventSetInstanceBtnAniamtion,setInstanceBtnAniamtion)	
	self:Bind(GameEvent.EventBossOwnerChange, eventBossOwnerChange)
	self:Bind(GameEvent.EventGameSceneReady, onShowNotifyView)
	self:Bind(GameEvent.EventChangeDownloadButtonState, changeDownloadButtonState)		
	self:Bind(GameEvent.EventEnterAutoFightView,enterAutoFightView)
	self:Bind(GameEvent.EventShowPKHitView,enterShowPKHitView)
	self:Bind(GameEvent.EventUpdatePing,updatePing)
	self:Bind(GameEvent.EventSetUnionInstanceVisible, setUnionInstanceVisible)
	self:Bind(GameEvent.EventRefreshNextMineralTime, refreshNextMineralTime)
	self:Bind(GameEvent.Event_SetFinishInstanceArrow,setFinishInstanceArrow)	
	self:Bind(GameEvent.EventBeAttacked, onEventBeAttacked)
	self:Bind(GameEvent.EventAttackerRemoved, onEventAttackerRemoved)	
end

function MainViewHandler:__delete()
	
end

function MainViewHandler:handleAttackerChanged(obj, bAdded)
	if not obj then
		return
	end						
	local view = UIManager.Instance:getMainView()
	if not view then
		return
	end
	if bAdded then
		view:addAttacker(obj)
	else
		view:removeAttacker(obj)
	end
	obj:showPKFlag(bAdded)
end

local showMessage = false
local lastLevel = 0
function MainViewHandler:checkDownloadState(level)
	-- 检查是否需要需要显示下载扩展包的按钮
	if SFLoginManager:getInstance():getPlatform() == "win32" then
		return
	end
	local view = UIManager.Instance:getMainView()
	local firstLevel = LevelRes[1].level	
	if SFGameHelper:getCurrentNetWork() == kWifi and not DownloadManager.Instance:isDownload() and not ResManager.Instance:hasLevelRes(firstLevel) then
		ResManager.Instance:downloadExtend(true,DownloadKey.extendAndPatch)
		view:setDownloadState(DownloadState.Downloading)
		showMessage = true
		return
	end	
	local manager = UIManager.Instance
	
	if showMessage and level > firstLevel then
		firstLevel = level
	end
	
	if view and level >= FirstLevel and not ResManager.Instance:hasLevelRes(firstLevel) and not DownloadManager.Instance:isDownload() then
		view:setDownloadState(DownloadState.Prepare)
		if not showMessage then
			local downloadfunc = function ()
				ResManager.Instance:downloadExtend(true,DownloadKey.extendAndPatch)
				view:setDownloadState(DownloadState.Downloading)
			end
			ResManager.Instance:showDownloadMessage(Config.Words[341],downloadfunc)			

			lastLevel = firstLevel
			showMessage = true
		end
	end
end

function MainViewHandler:changeLeaveInstanceButtonState(show)
	local manager = UIManager.Instance
	local view = manager:getMainView()
	if view then	
		view:setMainOtherBtnVisible(MainOtherType.LeaveInstance, show)	
	end
end

function MainViewHandler:changeLeaveActivityButtonState(show)
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:setMainOtherBtnVisible(MainOtherType.LeaveActivity, show)			
	end
end	

function MainViewHandler:changeMonsterBtnState(show)
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:setMainOtherBtnVisible(MainOtherType.WorldBoss, show)			
	end
end

function MainViewHandler:eventRefeshSkillCD(skillRefId, cdTime)
	if skillRefId and cdTime and type(cdTime) == "number" then
		local view = UIManager.Instance:getMainView()
		if view then
			view:getAttackSkillView():refreshSkillCD(skillRefId, cdTime)
		end
	end
end

function MainViewHandler:handleDownloadDelegate(eventCode, intValue, stringData, doubleValue)
	if eventCode == kOnError then
		self.hasError = true
	elseif eventCode == kOnComplete then
		local moveFileList = {}
		local function finish()
			local view = UIManager.Instance:getMainView()
			if view then
				view:setDownloadState(DownloadState.Finish)
			end
			ResManager.Instance:reloadZpk(moveFileList)
		end
		if self.hasError then
			DownloadManager.Instance:delayStop()
			GlobalEventSystem:Fire(GameEvent.EventCloseSubPackageView)
			finish()			
			return
		end
		local needMove = false
		
		local patchUrlList = ResManager.Instance:getPatchUrlList()
		if patchUrlList then
			for k,v in pairs(patchUrlList) do
				if string.find(v.name, "extend") then
					local reloadName =	tempNameToRealName(v.name)
					if reloadName then
						table.insert(moveFileList,reloadName)
						needMove = true		
					end													
				end
			end	
		end
		if needMove then
			DownloadManager.Instance:moveDownloadedFile(finish)
		else
			DownloadManager.Instance:delayStop()
			finish()
		end
	end
end


function MainViewHandler:setQuestVisible(bshow)
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:setQuestVisible(bshow)
	end
end

function MainViewHandler:setMiningInfoVisible(bShow)
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:setMiningInfoVisible(bShow)
	end
end
function MainViewHandler:refreshCount()
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:refreshCount()
	end
end
function MainViewHandler:refreshMiningLeftTime()
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:refreshMiningLeftTime()
	end
end
function MainViewHandler:stopMiningTime()
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:stopMiningTime()
	end
end
function MainViewHandler:setInstanceBtnVisible(bShow)
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		local hero = G_getHero()
		local pt = hero:getPT()
		local level = PropertyDictionary:get_level(pt)
		if level >= const_level then
			view:setMainOtherBtnVisible(MainOtherType.Instance,bShow)
		end			
	end
end

function MainViewHandler:setInstanceBtnAniamtion(bShow)
	local mainView =UIManager.Instance:getMainView()
	local mainOtherView = mainView:getMainOtherMenu()
	mainOtherView:addAnimation(MainOtherType.LeaveInstance)
end

function MainViewHandler:getNavigationMap()
	local mainview = UIManager.Instance:getMainView()
	if mainview then
		local navigationMap = mainview:getNavigationMap()
		if navigationMap then
			return navigationMap
		else
			return nil
		end
	else
		return nil
	end
end

function MainViewHandler:refreshNextMineralTime()
	local manager =UIManager.Instance
	local view = manager:getMainView()
	if view then
		view:refreshNextMineralTime()
	end
end
