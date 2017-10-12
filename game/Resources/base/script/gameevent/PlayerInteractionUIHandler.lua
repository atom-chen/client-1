require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.playerInteraction.PlayerInteractionView")

PlayerInteractionUIHandler = PlayerInteractionUIHandler or BaseClass(GameEventHandler)

function PlayerInteractionUIHandler:__init()
	local manager =UIManager.Instance	
			
		
	local handleClient_Open = function(playerId)
		
		manager:registerUI("PlayerInteractionView", PlayerInteractionView.New)	
		--manager:showUI("PlayerInteractionView",nil,playerId)
		if not self.interactionView  then
			self.interactionView = PlayerInteractionView.New()
		end
		if playerId then
			self.interactionView:setPlayerId(playerId)
		end
		UIManager.Instance:showDialog(self.interactionView:getRootNode(),E_DialogZOrder.Tips)									
	end	
		
	local updatePlayerInteraction = function()	
		if self.interactionView then
			self.interactionView:updateIteam()
		end
	end	
	
	local requestPlayerInfo = function (playerId)
		local teamMgr =  GameWorld.Instance:getEntityManager():getHero():getTeamMgr() --发送当前选定玩家组队状态的请求
		teamMgr:requestPlayerInfo(playerId)								
	end
		
	local  ShowInteractionByTag = function (tag,playerId)
		local selectEntityObject = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player,playerId)	
		local teamMgr =  GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
		if selectEntityObject then				
			if tag == btnTag.tag_chatPrivate then	--私聊
				local receiveName = PropertyDictionary:get_name(selectEntityObject:getPT())
				if receiveName then
					GlobalEventSystem:Fire(GameEvent.EventWhisperChat,receiveName)
				end
			elseif tag == btnTag.tag_check then	--查看	
				local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
				local entityMgr = GameWorld.Instance:getEntityManager()				
				equipMgr:requestOtherPlayerEquipList(playerId)
				entityMgr:requestOtherPlayer(playerId)
				local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
				equipMgr:setOtherPlayerEquipList(nil)	--清空列表，防止读到其他玩家信息
				local player = {playerObj=selectEntityObject,playerType =1}	--1: 其他玩家的信息
				GlobalEventSystem:Fire(GameEvent.EventHideAllUI)
				GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player) 
				GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
			elseif tag == btnTag.tag_copyName then	--复制名字
				SFGameHelper:copy2PasteBoard(PropertyDictionary:get_name(selectEntityObject:getPT()))
				UIManager.Instance:showSystemTips(Config.Words[4012])
			end	
		elseif  teamMgr:isMyTeamate(playerId)  then
			if tag == btnTag.tag_chatPrivate then
				local teamMate = teamMgr:getTeamMemberById(playerId)
				local chatName = teamMate:getTeamMemberName()
				if chatName then
					GlobalEventSystem:Fire(GameEvent.EventWhisperChat,chatName)
				end
			elseif tag == btnTag.tag_check then
				UIManager.Instance:showSystemTips(Config.Words[9011])
			end
		end
		if tag == btnTag.tag_teamInvite then	--组队邀请
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			if teamMgr:getTeammateNumber() >= 3 then				
				UIManager.Instance:showSystemTips(Config.Words[9021])
				return
			end					
			teamMgr:requestAssembleTeam(playerId)
		elseif tag == btnTag.tag_outTeam then	--踢出队伍
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()				
			teamMgr:requestKickedOutTeam(playerId)
		elseif tag == btnTag.tag_changeHeader then	--转移队长
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()				
			teamMgr:requestHandoverTeamLeader(playerId)
		elseif tag == btnTag.tag_quitTeam then	--退出队伍
			local teamMgr =  GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestLeaveTeam()
		elseif tag == btnTag.tag_disbandTeam then
			local teamMgr =  GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestDisbandTeam()				
		elseif tag == btnTag.tag_FactionInvite then	--公会邀请
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
			if factionMgr:isFullMember()then				
				UIManager.Instance:showSystemTips(Config.Words[9026])
				return
			end				
			local g_hero = GameWorld.Instance:getEntityManager():getHero()	
			local factionName = PropertyDictionary:get_unionName(g_hero:getPT()) 						
			factionMgr:requestAssembleFaction(playerId,factionName)	
		end		
		
	end	
	
	local JoinTeamReturn = function (playerActionType)
		if playerActionType == 1 then
			UIManager.Instance:showSystemTips(Config.Words[9022])
		elseif playerActionType == 3 then
			UIManager.Instance:showSystemTips(Config.Words[9024])
		end
	end			

	--申请入队返回
	local handRequestJoinTeamReturn = function(ret)
		if ret == 1 then --对方长时间未接受申请
			UIManager.Instance:showSystemTips(Config.Words[25518])
		elseif ret == 2 then --通过了申请
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			local requestTeamId = teamMgr:getRequestJoinTeamId()
			if requestTeamId then
				teamMgr:setMyTeamId(requestTeamId)
			end	
			UIManager.Instance:showSystemTips(Config.Words[25519])
			GlobalEventSystem:Fire(GameEvent.EventUpdateTeamListView)	
		else --拒绝了申请
			UIManager.Instance:showSystemTips(Config.Words[25520])	
		end
	end
	
	--修改队伍返回
	local handEventModifyTeamReturn = function(ret)
		if ret == 1 then -- 修改成功
			UIManager.Instance:showSystemTips(Config.Words[25521])
			GlobalEventSystem:Fire(GameEvent.EventUpdateTeamListView)	
		else -- 修改失败
			UIManager.Instance:showSystemTips(Config.Words[25522])
		end
	end
	
	local eventHideInteractionView = function()
		if self.interactionView then
			UIManager.Instance:hideDialog(self.interactionView:getRootNode())
			self.interactionView:DeleteMe()
			self.interactionView = nil 
		end
	end
	
	self:Bind(GameEvent.EventHideInteractionView,eventHideInteractionView)
	self:Bind(GameEvent.EventModifyTeamReturn,handEventModifyTeamReturn)			
	self:Bind(GameEvent.EventRequestJoinTeamReturn,handRequestJoinTeamReturn)				
	self:Bind(GameEvent.EventOpenPlayerInteractionView,handleClient_Open)
	self:Bind(GameEvent.EventPlayerTeamStatus,updatePlayerInteraction)
	self:Bind(GameEvent.EventShowInteractionByTag,ShowInteractionByTag)	
	self:Bind(GameEvent.EventJoinTeamReturn,JoinTeamReturn)		

end

function PlayerInteractionUIHandler:__delete()

end