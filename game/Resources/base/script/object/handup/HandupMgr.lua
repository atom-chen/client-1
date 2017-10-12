--挂机总逻辑管理器
require("common.baseclass")
require("object.handup.FSM.HandupStateMachine")
require("object.handup.HandupDef")
require("object.actionPlayer.MoveActionPlayer")
require("object.actionPlayer.UseSkillActionPlayer")
require("object.actionPlayer.SearchTargetActionPlayer")
require("object.handup.HandupMsg")
require("object.handup.API.HandupSkillMgr")
require("object.handup.FSM.PickupState")
require("object.handup.FSM.SearchTargetState")	
require("object.handup.FSM.FightState")
require("object.handup.FSM.CollectState")
require("object.handup.FSM.FightBackState")
require("object.handup.FSM.GlobalState")
HandupMgr = HandupMgr or BaseClass()

local HandupRunningState = 
{
	Stop 	= 1,
	Running = 3
}

function HandupMgr:__init()
	self.configMgr = HandupConfigMgr.New()	
	HandupSkillMgr.New()
	
	self.handupMode = nil
	self.searchMode = E_SearchTargetMode.Random
	self.runningState = HandupRunningState.Stop
	self.stateList 				= {}
	self.stateCreateFuncList 	= {}
	self.targetInfo = {}
	self.stopNotify = {}
	self.fsm = HandupStateMachine.New()			
	self:buildStateCreateFuncList()
end

function HandupMgr:__delete()
	if self.pkTipsLabel then
		self.pkTipsLabel:release()
		self.pkTipsLabel = nil
	end
end
function HandupMgr:clear()
		
end

function HandupMgr:getFSM()
	return self.fsm
end

function HandupMgr:getConfigMgr()
	return self.configMgr
end

function HandupMgr:buildStateCreateFuncList()
	self.stateCreateFuncList[E_HandupStateType.Pickup] = PickupState.New	
	self.stateCreateFuncList[E_HandupStateType.Search] = SearchTargetState.New	
	self.stateCreateFuncList[E_HandupStateType.Fight] = FightState.New	
	self.stateCreateFuncList[E_HandupStateType.Collect] = CollectState.New	
	self.stateCreateFuncList[E_HandupStateType.FightBack] = FightBackState.New	
	self.stateCreateFuncList[E_HandupStateType.Global] = GlobalState.New
end

--mode		: 模式 E_AutoSelectTargetMode.Normal/E_AutoSelectTargetMode.Collect
--{ttype}	: 目标类型：怪物/玩家等，不能为空
--refIdList	: 目标的refIdList，为空或者nil则选择全部目标
--sceneId	：目标所在的场景id
--delay		: 延迟多久，为0或者nil则立即开始
function HandupMgr:start(mode, typeList, refIdList, sceneId, delay, searchMode)
	if not self:canHandup(mode, typeList, refIdList, sceneId, delay, searchMode) then
		return
	end
	HandupCommonAPI:switchPKMode(E_HeroPKState.statePeace)
	self:showPKTips(true)
	ActionPlayerMgr.Instance:removePlayersByGroup(G_getHero():getId())
	local removeStartSchId = function()
		if self.delayStartSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayStartSchId)
			self.delayStartSchId = nil
		end
	end
	removeStartSchId()
	
	if (not delay) or (not (delay >= 0)) then
		self:doStart(mode, typeList, refIdList, sceneId, searchMode)
	else			
		local onStart = function()
			self:doStart(mode, typeList, refIdList, sceneId, searchMode)
			removeStartSchId()
		end
		self.delayStartSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onStart, delay, false);		
	end
	
	
	if GameWorld.Instance:getMapManager():isInGameInstance() then
		if GameWorld.Instance:getGameInstanceManager():getIsInstanceFinished() then		
			local onHandupStop = function()
				showMsgBox(Config.Words[1503])	
			end
			self:stopWithPickup(onHandupStop, nil)
		end
	end
end		

function HandupMgr:canHandup(mode, typeList, refIdList, sceneId, delay, searchMode)
	if (not mode) or (not typeList) or (type(refIdList) ~= "table") or (not searchMode) 
		or (type(typeList) ~= "table") or table.isEmpty(typeList) then
		error("HandupMgr:start arg error")
		return false
	end
	if not self:needStart(mode, typeList, refIdList, sceneId, searchMode) then
--		print("HandupMgr:start not need start")
		return false
	end
	if not self:isHeroOk() then
		return false
	end
	if table.isEmpty(refIdList) then
		local pk = GameWorld.Instance:getEntityManager():getHero():getPKStateID()
		if (not (pk == E_HeroPKState.statePeace)) and (not (pk == E_HeroPKState.stateGoodOrEvil)) then
			local msg = {}
			table.insert(msg,{word = Config.Words[461], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
			return false
		end
	end		
	return true
end


local const_pkTips = 
{
	[E_HeroPKState.statePeace] = Config.Words[463],
	[E_HeroPKState.stateQueue] = Config.Words[466],
	[E_HeroPKState.stateFaction] = Config.Words[465],
	[E_HeroPKState.stateGoodOrEvil] = Config.Words[464],
	[E_HeroPKState.stateWhole] = Config.Words[467],
}
function HandupMgr:getPKTipsStr()
	local pk = G_getHero():getPKStateID()
	local pkStr = const_pkTips[pk]	
	if pkStr then
		return string.format(Config.Words[462], pkStr)					
	else
		return nil
	end			
end
	
function HandupMgr:showPKTips(bShow)	
	if bShow then
		if not self.pkChangedId then	
			local onPkChanged = function()
				if self:isHandup() then
					self:doShowPKTips(true, self:getPKTipsStr())
				end 
			end
			self.pkChangedId = GlobalEventSystem:Bind(GameEvent.EventChangeStateBtn, onPkChanged)
		end
		self:doShowPKTips(true, self:getPKTipsStr())
	else
		self:doShowPKTips(false, nil)
		if self.pkChangedId then
			GlobalEventSystem:UnBind(self.pkChangedId)
			self.pkChangedId = nil
		end
	end
end

function HandupMgr:doShowPKTips(bShow, str)
	if not self.pkTipsLabel then
		self.pkTipsLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorGreen1"))								
		self.pkTipsLabel:retain()
	end
	if not self.pkTipsLabel:getParent() then
		UIManager.Instance:getGameRootNode():addChild(self.pkTipsLabel)
	end
	if bShow and type(str) == "string" then
		self.pkTipsLabel:setString(str)
		VisibleRect:relativePosition(self.pkTipsLabel, UIManager.Instance:getGameRootNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 120))	
	end
	self.pkTipsLabel:setVisible(bShow)
end

--判断英雄是否健在。不健在则不能挂机
function HandupMgr:isHeroOk()
	local hero = G_getHero()
	if PropertyDictionary:get_HP(G_getHero():getPT()) <= 0 then
		print("hp <= 0. handup failed")
		return false
	end
	local state = hero:getState()		
	if  state:isState(CharacterState.CharacterStateDead) or
	   state:isState(CharacterState.CharacterStateWillDead) then
		return false
	end		
	return true		
end

--拾取完掉落之后再停止
function HandupMgr:stopWithPickup(callBack, arg)
	if self:isHandup() then
		self.stopNotify = {func = callBack, arg = arg}
		local msg = HandupMsg.New()
		msg:setType(E_HandupMsgType.StopWithPickup)
		self:dispatchMsg(msg)			
	end	
end	

function HandupMgr:doStart(mode, ttype, refIdList, sceneId, searchMode)
	self:stop()
	self:setTargetInfo(ttype, refIdList, sceneId)	
	self.searchMode = searchMode
	self.handupMode = mode
	self.runningState = HandupRunningState.Running
	
	self.configMgr:updateSwitchSkill()
	self.fsm:start()	--Juchao@20140424: 要先start，changeState等
	self.fsm:setGlobalState(self:getState(E_HandupStateType.Global))
	self.fsm:changeState(self:getState(E_HandupStateType.Pickup))
	self:bindBeAttackedEvent()
	self:bindHeroMoveExceptionEvent()
	GlobalEventSystem:Fire(GameEvent.EventHandupStateChanged, true)
end

--停止挂机
function HandupMgr:stop(synFlag)
	if not self:isHandup() then
		return
	end		
--	print("HandupMgr:stop")
	self.targetInfo = {}
	local pickupMgr = GameWorld.Instance:getPickUpMnanager()
	pickupMgr:setRePickupInterval(0)		--非挂机状态设置掉落可重复拾取的时间为0
	pickupMgr:clearAllLootNextPickTime()	
	
	self.fsm:stop()
	if G_getHero():isMoving()  and synFlag == nil then
		G_getHero():sysHeroLocation()
	end
	G_getHero():forceStop()					--TODO: 需要向服务器发送停止消息？
	G_getHero():removeLastSkill()			--清除英雄使用技能的队列
	self.runningState = HandupRunningState.Stop	
	
	GameWorld.Instance:getNpcManager():cancelCollect()
	self:showPKTips(false)
	self:unbindBeAttackedEvent()	
	self:unbindHeroMoveExceptionEvent()
	GlobalEventSystem:Fire(GameEvent.EventHandupStateChanged, false) 	
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoKillMonster) 
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad) 
	
	local func = self.stopNotify.func
	local arg = self.stopNotify.arg
	if func then
		self.stopNotify = {}
		func(arg)
	end		
end			
		
--判断是否需要启动
--如果正在挂机，以及refId和sceneId一致，则不需要重新启动
function HandupMgr:needStart(mode, typeList, refIdList, sceneId, searchMode)
	if (self:isHandup() 
		and (self.handupMode == mode)
		and (table.isEqual(self.targetInfo.typeList, typeList)) 
		and (table.isEqual(self.targetInfo.refIdList, refIdList))
		and (self.searchMode == searchMode)
		and (self.targetInfo.sceneId == sceneId)) then
		return false
	else
		return true
	end
end		

--是否正在挂机
function HandupMgr:isHandup()
	return self.runningState ~= HandupRunningState.Stop 
end

--JUCHAO@20140212: 当移动卡死的时候，调用该函数。重新选择目标
function HandupMgr:reselectTarget()
	G_getHero():switchTarget()
end

function HandupMgr:getSearchMode()
	return self.searchMode
end

--设置挂机目标信息，包括目标的refId以及sceneId
function HandupMgr:setTargetInfo(typeList, refIdList, sceneId)
	self.targetInfo.refIdList 	= refIdList	
	self.targetInfo.sceneId 	= sceneId	
	self.targetInfo.typeList 	= typeList	
end		

--获取挂机目标信息
function HandupMgr:getTargetInfo()
	return self.targetInfo
end	

function HandupMgr:getState(stateType)
	local state = self.stateList[stateType]
	if not state then
		state = self.stateCreateFuncList[stateType]()
		self.stateList[stateType] = state
	end
	return state
end

function HandupMgr:getHandupMode()
	return self.handupMode
end

function HandupMgr:dispatchMsg(msg)
	if self:isHandup() then
		self.fsm:handleMessage(msg)
	end
end

function HandupMgr:bindHeroMoveExceptionEvent()
	self:unbindHeroMoveExceptionEvent()
	local onHeroMoveException = function()		
		self:reselectTarget()  --Juchao@20140513: 在英雄移动异常时，不再重新选择目标
	end
	self.heroMoveExceptionEventId = GlobalEventSystem:Bind(GameEvent.EventHeroMoveException, onHeroMoveException)
end

function HandupMgr:unbindHeroMoveExceptionEvent()
	if self.heroMoveExceptionEventId then
		GlobalEventSystem:UnBind(self.heroMoveExceptionEventId)
		self.heroMoveExceptionEventId = nil
	end
end

function HandupMgr:bindBeAttackedEvent()
	self:unbindBeAttackedEvent()
	local onBeAttacked = function(obj, isNew)
		if obj then
			local msg = HandupMsg.New()
			msg:setType(E_HandupMsgType.BeAttacked)
			msg:setExtraInfo(obj)
			self:dispatchMsg(msg)
		end
	end
	self.beAttackedEventId = GlobalEventSystem:Bind(GameEvent.EventBeAttacked, onBeAttacked)
end

function HandupMgr:unbindBeAttackedEvent()
	if self.beAttackedEventId then
		GlobalEventSystem:UnBind(self.beAttackedEventId)
		self.beAttackedEventId = nil
	end
end