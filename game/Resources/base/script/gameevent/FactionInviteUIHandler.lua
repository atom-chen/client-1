require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require("ui.faction.FactionInviteView")

FactionInviteUIHandler = FactionInviteUIHandler or BaseClass(GameEventHandler)

function FactionInviteUIHandler:__init()
	local manager =UIManager.Instance
	
	local handleClient_Open = function ()
		
		manager:registerUI("FactionInviteView", FactionInviteView.New)	
		manager:showUI("FactionInviteView")									
	end
	
	local replyJoinFaction = function (invitedPlayerId,factionName,replyJoinFactionType)
		local FactionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		FactionMgr:JoinFactionreply(invitedPlayerId,factionName,replyJoinFactionType)
		FactionMgr:removeFactionInvite(invitedPlayerId)
		--GlobalEventSystem:Fire(GameEvent.EventUpdateInviteView)
		
		
		local view = UIManager.Instance:getViewByName("FactionInviteView")
		if view then
			view:updateView()
		end
	end	
	
	local updateFactionInviteView = function ()		
		local view = UIManager.Instance:getViewByName("FactionInviteView")
		if view then
			view:updateView()
		end
	end	
	
	local FactionInviteReply = function (playerName,replyStatus)
		if playerName and replyStatus then
			if replyStatus == 1 then
				UIManager.Instance:showSystemTips(playerName .. " " .. Config.Words[5564])
			elseif replyStatus == 2 then
				UIManager.Instance:showSystemTips(playerName .. " " .. Config.Words[5565])
			elseif replyStatus == 3 then
				UIManager.Instance:showSystemTips(playerName .. " " .. Config.Words[5566])
			else
		
			end
		end	
	end	
												
	self:Bind(GameEvent.EventOpenFactionInviteView,handleClient_Open)
	self:Bind(GameEvent.EventReplyJoinFaction,replyJoinFaction)
	self:Bind(GameEvent.EventupdateFactionInviteView,updateFactionInviteView)
	self:Bind(GameEvent.EventFactionInviteReply,FactionInviteReply)	
												
end	

function FactionInviteUIHandler:__delete()

end
