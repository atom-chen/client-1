require "gameevent.GameEvent"
require "ui.activity.ArenaView"
require "ui.activity.LadderView"
require "ui.activity.FightingView"
ArenaUIHandler = ArenaUIHandler or BaseClass(GameEventHandler)

function ArenaUIHandler:__init()
	local manager =UIManager.Instance
	self.eventObjTable = {}
	local eventRequireCanReceive = function()
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestCanReceive()
	end
	
	local eventHandleCanReceive = function(canReceive)
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
		ActivityDelegate:doArenaBySever(canReceive)--mark
	end
	
	local eventOpenArenaView = function()
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestShowArenaView()	
		manager:registerUI("ArenaView", ArenaView.create)
		--manager:showUI("ArenaView",E_ShowOption.eMiddle)	
	end
	
	local eventShowArenaView = function()
		manager:showUI("ArenaView",E_ShowOption.eMiddle)	
		local arenaView = manager:getViewByName("ArenaView")		
		if arenaView then
			arenaView:updateHeroInfoArea()
			arenaView:updatePrizeArea()
			arenaView:updateNoticeBoardArea()
			arenaView:updateChallengeTargetArea()
			arenaView:updateReceiveRewardTime()
			arenaView:updateChallengeCDTime()
			arenaView:updateFightingRecordArea()
		end
	end
	
	local eventOpenLadderView = function()
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestSeeLadder()
		manager:registerUI("LadderView", LadderView.create)
		manager:showUI("LadderView",E_ShowOption.eMiddle)
	end
	
	local eventShowLadderView = function()
		manager:showUI("LadderView",E_ShowOption.eMiddle)
	end
	
	local eventUpdateNoticeBoardArea = function()
		
		local arenaView = manager:getViewByName("ArenaView")		
		if arenaView then
			arenaView:updateNoticeBoardArea()
		end
	end
	
	local eventUpdateChallengeTargetArea = function()

		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updateChallengeTargetArea()
		end
	end
	
	local eventUpdateFightingRecordArea = function()
		
		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updateFightingRecordArea()
		end
	end
	
	local eventUpdateHeroInfoArea = function()
		
		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updateHeroInfoArea()
			GlobalEventSystem:Fire(GameEvent.EventUpdatePrizeArea)
		end
	end
	
	local eventUpdatePrizeArea = function()
		
		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updatePrizeArea()
		end
	end
	
	local eventUpdateReceiveRewardTime = function()
		
		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updateReceiveRewardTime()
		end
	end
	
	local eventUpdateChallengeCDTime = function()
		
		local arenaView = manager:getViewByName("ArenaView")
		if arenaView then
			arenaView:updateChallengeCDTime()
		end
	end
	
	local eventReceiveReward = function()
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestReceiveReward()
	end

	local eventChallenge = function(rank)
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestChallenge(rank)
	end
	
	local eventFighting = function(fightArg)
		
		manager:registerUI("FightingView", FightingView.create)
		manager:showUI("FightingView",E_ShowOption.eMiddle)
		local fightingView = manager:getViewByName("FightingView")
		if fightingView then
			fightingView:createRole(fightArg)
			fightingView:initMapAndUI()
			fightingView:playAnimate()
			fightingView:updateEndWindow(fightArg)
		end
	end
	
	local eventFightingOver = function()
		local hero = G_getHero()
		local hp = PropertyDictionary:get_HP(hero:getPT())
		if hp<= 0 then
			GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, true)
		end
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestChallengeResult()
	end
	
	local eventClearCDTime = function()
		local arenaMgr = GameWorld.Instance:getArenaMgr()
		arenaMgr:requestClearCDTime()
	end
	
	local eventForceEndAreanAni = function()
		local fightingView = manager:getViewByName("FightingView")
		if fightingView then
			if  manager:isShowing("FightingView") then
				fightingView:forceFinishAni()
			end
		end		
	end
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRequireCanReceive,eventRequireCanReceive))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame,eventRequireCanReceive))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHandleCanReceive,eventHandleCanReceive))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenArenaView,eventOpenArenaView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventForceEndAreanAni,eventForceEndAreanAni))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowArenaView,eventShowArenaView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenLadderView,eventOpenLadderView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowLadderView,eventShowLadderView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateNoticeBoardArea,eventUpdateNoticeBoardArea))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateChallengeTargetArea,eventUpdateChallengeTargetArea))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateFightingRecordArea,eventUpdateFightingRecordArea))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateHeroInfoArea,eventUpdateHeroInfoArea))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdatePrizeArea,eventUpdatePrizeArea))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateReceiveRewardTime,eventUpdateReceiveRewardTime))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateChallengeCDTime,eventUpdateChallengeCDTime))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventReceiveReward,eventReceiveReward))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventChallenge,eventChallenge))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventFighting,eventFighting))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventFightingOver,eventFightingOver))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventClearCDTime,eventClearCDTime))
end	

function ArenaUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end
