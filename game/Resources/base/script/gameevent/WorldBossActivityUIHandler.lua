require ("common.GameEventHandler")
require ("ui.UIManager")
require "ui.activity.WorldBossActivityView"
require "ui.activity.WorldBossCreateTeamView"

WorldBossActivityUIHandler = WorldBossActivityUIHandler or BaseClass(GameEventHandler)

function WorldBossActivityUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance		
	local handleOpenWorldBossActivityView = function(arg)
		manager:registerUI("WorldBossActivityView", WorldBossActivityView.create)		
		local mgr = GameWorld.Instance:getWorldBossActivityMgr()
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()																
		teamMgr:requestBossTeamList()			
		manager:showUI("WorldBossActivityView",E_ShowOption.eMiddle, arg)			
	end
	
	local eventOpenCreateTeamView  = function(arg)
		manager:registerUI("WorldBossCreateTeamView", WorldBossCreateTeamView.create)
		manager:showUI("WorldBossCreateTeamView",E_ShowOption.eMiddle,arg)			
	end
	
	local eventCreateTeamSuccess = function()
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
		teamMgr:requestBossTeamList()
	end
	
	local eventUpdateTeamListView = function()
		local view = manager:getViewByName("WorldBossActivityView")
		if view then
			view:updateTeamListView()
		end
	end
	
	local eventUpdateTeamActivityIcon = function()
		ActivityDelegate:setEnable("activity_manage_20",false)
		ActivityDelegate:setEnable("activity_manage_21",false)
		ActivityDelegate:setEnable("activity_manage_22",false)
	end
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame,eventUpdateTeamActivityIcon))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateTeamListView,eventUpdateTeamListView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventCreateTeamSuccess,eventCreateTeamSuccess))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenWorldBossActivityView,handleOpenWorldBossActivityView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventCreateTeam,eventOpenCreateTeamView))
end

function WorldBossActivityUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end
