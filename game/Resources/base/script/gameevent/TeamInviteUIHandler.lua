require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.team.TeamInviteView")

TeamInviteUIHandler = TeamInviteUIHandler or BaseClass(GameEventHandler)

function TeamInviteUIHandler:__init()
	local manager =UIManager.Instance
	
	local handleClient_Open = function ()
		
		manager:registerUI("TeamInviteView", TeamInviteView.New)
		manager:showUI("TeamInviteView")									
	end
	
	local replyJoinTeam = function (invitedPlayerId,replyJoinTeamType,inviteType)
		
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
		if inviteType == 1 then
			teamMgr:requestJoinTeam(invitedPlayerId,replyJoinTeamType)
		else
			teamMgr:replyTeamJoinRequest(invitedPlayerId,replyJoinTeamType)
		end
		teamMgr:removeTeamInvite(invitedPlayerId,inviteType)
		local view = UIManager.Instance:getViewByName("TeamInviteView")
		if view then
			view:updateView()
		end						
	end	
												
	self:Bind(GameEvent.EventOpenTeamInviteView,handleClient_Open)
	self:Bind(GameEvent.EventReplyJoinTeam,replyJoinTeam)	
												
end	

function TeamInviteUIHandler:__delete()

end
