require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.role.RoleView")
require("ui.role.ReviveView")

RoleUIHandler = RoleUIHandler or BaseClass(GameEventHandler)

function RoleUIHandler:__init()
	self.reviveView = nil
	
	local manager =UIManager.Instance	
	
	
	local onEventOpenRoleView = function (showOption, arg)
		
		manager:registerUI("RoleView", RoleView.create)	
		manager:showUI("RoleView", showOption, arg)
	end
	local onEventHideRoleView = function (showOption, arg)	
		manager:hideUI("RoleView")
	end
	
	local showReviveView = function (bShow)
		if bShow then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:requestReviveInfo()
		else
			if self.reviveView then
				manager:hideDialog(self.reviveView:getRootNode())
				self.reviveView:DeleteMe()
				self.reviveView = nil
			end
		end
	end
	
	local openReviveView = function (info)
		--玩家如果已经复活了，就无视这次的消息
		local hero = GameWorld.Instance:getEntityManager():getHero()
		if not hero:getState():isState(CharacterState.CharacterStateDead) and not hero:getState():isState(CharacterState.CharacterStateWillDead) then
			return
		end
		
		if  manager:isShowing("FightingView") then
			return
		end
				
		if self.reviveView == nil then			
			self.reviveView = ReviveView.New()
			self.reviveView:setInfo(info, (not G_getCastleWarMgr():isInCastleWar() and  not GameWorld.Instance:getMapManager():isInGameInstance() )) --攻城战  和 副本  不允许原地复活
		end
		--UIManager.Instance:showSystemTips(Config.Words[1201])
		manager:showDialog(self.reviveView:getRootNode(), E_DialogZOrder.ReviveDlg)	
	end
		
	local onEventEquipUpdate = function(eventType, map)
		local view2 = UIManager.Instance:getViewByName("RoleView")
		if view2 then
			view2 = view2:getNodeByName("RoleSubPropertyView");
		end
		if view2 and view2:isHero() then
			view2:updateEquipList(eventType, map)	
		end
	end
	
	local onEventHeroProMerged = function()	
		local view = UIManager.Instance:getViewByName("RoleView")
		if view then	
			local view1 = view:getNodeByName("RoleSubPropertyView");
			if view1 then
				view1:updatePlayerInfo()
			end		
		end
		
		local view2 = UIManager.Instance:getViewByName("DetailPropertyView")
		if view2 and view2:isHero() then
			view2:updateDetails()
			view2:updateProgressBar()						
		end
	end	
	
	local onEventHeroProChanged = function(newPD)	
		local view = UIManager.Instance:getViewByName("RoleView")
		if view then
			view:updateKnight(newPD)			
		end
		local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()
		knightMgr:checkKnightGet(newPD)
	end	
	
	local hadGetSalary = function()
		local view = manager:getViewByName("RoleView")					
		if(view) then
			view:setKnightSalary()	
		end
	end		
		
	local rewardReset = function()
		local view = manager:getViewByName("RoleView")					
		if(view) then
			view = view:getNodeByName("RoleSubKnightView");
			if view then
				view:rewardReset()	
			end
		end				
	end		
	local updateOtherPlayerEquipList = function()			
		local view2 = UIManager.Instance:getViewByName("RoleView")
		if view2 then
			view2 = view2:getNodeByName("RoleSubPropertyView");
		end
		if view2 and (not view2:isHero()) then	--其他玩家
			view2:updateEquipList()										
		end
	end		
	local onResquestInit = function()
		local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
		knightMgr:requestSalaryFlag()
	end
	local updateOtherPlayerPro = function(otherPlayer)			
		local view = UIManager.Instance:getViewByName("DetailPropertyView")
		if view then
			view = view:onEnter(otherPlayer)
		end	
		local view1 = UIManager.Instance:getViewByName("HisDetailPropertyView")
		if view1 then
			view1 = view1:onEnter(otherPlayer)
		end
		local view2 = UIManager.Instance:getViewByName("RoleView")
		if view2 then
			view2 = view2:getNodeByName("RoleSubPropertyView");
		end
		if view2 and (not view2:isHero()) then	--其他玩家
			view2:onEnter(otherPlayer)
		end
	end	
	
	local eventKnight = function (showOption, arg)	
		manager:registerUI("RoleView", RoleView.create)	
		manager:showUI("RoleView", showOption, arg)
		local view = manager:getViewByName("RoleView")					
		if(view) then
			view:showSubView(1)
			view:setSelIndex(0)
		end
	end
	
	local WingUpGrade = function (showOption, arg)	
		local view2 = UIManager.Instance:getViewByName("RoleView")
		if view2 then		
			view2 = view2:getNodeByName("RoleSubPropertyView")
			if view2 and view2:isHero() then	--玩家自己
				view2:updateWing()				
			end
		end
	end
		
	
	self:Bind(GameEvent.EventEquipUpdate, onEventEquipUpdate)	
	self:Bind(GameEvent.EventOpenRoleView, onEventOpenRoleView)	
	self:Bind(GameEvent.EventHideRoleView, onEventHideRoleView)	
	self:Bind(GameEvent.EventReviveViewShow, showReviveView)
	self:Bind(GameEvent.EventReviveViewOpen, openReviveView)	
	self:Bind(GameEvent.EventHeroProMerged, onEventHeroProMerged)
	self:Bind(GameEvent.EventHeroProChanged, onEventHeroProChanged)
	self:Bind(GameEvent.EventSalaryGot,hadGetSalary)
	self:Bind(GameEvent.EventRewardReset,rewardReset)
	self:Bind(GameEvent.EventOtherPlayerEquipList,updateOtherPlayerEquipList)
	self:Bind(GameEvent.EventOtherPlayerProChanged,updateOtherPlayerPro)
	self:Bind(GameEvent.EventHeroEnterGame, onResquestInit)
	self:Bind(GameEvent.EventOpenKnightView, eventKnight)
	self:Bind(GameEvent.EventWingUpGrade, WingUpGrade)
	self:Bind(GameEvent.EventGetNowWing, WingUpGrade)		
end

function RoleUIHandler:__delete()
	
end	