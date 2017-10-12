require ("common.GameEventHandler")
require ("gameevent.GameEvent")

MainTeammateHeadUIHandler = MainTeammateHeadUIHandler or BaseClass(GameEventHandler)

function MainTeammateHeadUIHandler:__init()
	local manager =UIManager.Instance	
		
	local TeamAction = function ()
		local view = UIManager.Instance:getMainView()
		if view then
			view:UpdateTeammateHead()		
		end
		--更新组队面板，聊天频道发送消息
	end	
	
	local HandoverTeamAction = function ()
		--更新组队面板，聊天频道发送消息
		
		local view = UIManager.Instance:getMainView()
		if view then
			view:UpdateTeammateHead()
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestBossTeamList()	
		end
	end	
	
	local TeamLeaderQuitTeamAction = function ()
		--更新组队面板，聊天频道发送消息
		local view = UIManager.Instance:getMainView()
		if view then
			view:UpdateTeammateHead()
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestBossTeamList()	
		end
	end
	
	local DisbandTeamAction = function ()
		--更新组队面板，聊天频道发送消息
		local view = UIManager.Instance:getMainView()
		if view then
			view:UpdateTeammateHead()
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestBossTeamList()	
		end
	end	
	
	local TeamLeaderKickedOutAction = function ()
		--更新组队面板，聊天频道发送消息
		local view = UIManager.Instance:getMainView()
		if view then
			view:UpdateTeammateHead()
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestBossTeamList()	
		end
	end
		
	self:Bind(GameEvent.EventTeamAction,TeamAction)
	self:Bind(GameEvent.EventHandoverTeamAction,HandoverTeamAction)
	self:Bind(GameEvent.EventTeamLeaderQuitTeamAction,TeamLeaderQuitTeamAction)
	self:Bind(GameEvent.EventDisbandTeamAction,DisbandTeamAction)
	self:Bind(GameEvent.EventTeamLeaderKickedOutAction,TeamLeaderKickedOutAction)
								
end

function MainTeammateHeadUIHandler:__delete()

end