require "gameevent.GameEvent"
require "common.baseclass"
require "ui.smallMap.SmallMapView"
require "ui.smallMap.WorldMapTipsView"
SmallMapUIHandler = SmallMapUIHandler or BaseClass(GameEventHandler)

function SmallMapUIHandler:__init()
	local manager =UIManager.Instance
	self.moveEventId = nil
	
	local handleMapOpen = function ()
		
		manager:registerUI("SmallMapView", SmallMapView.create)
		manager:showUI("SmallMapView")
	end
	
	local handleUpdateCurrentMap = function ()
		self:currentMapNeedToUpdate()
	end

	local heroOnMove = function ()
		self:updateMovePath()
	end
	
	local handleClearMovePath = function()
		self:clearMovePath()
	end
	
	function updateData()
		local mapManager = GameWorld.Instance:getSmallMapManager()
		mapManager:updateData()
	end
	
	local handleRealeaseMap = function()
		local view = manager:getViewByName("SmallMapView")
		if view then
			view:releaseMap()
		end
	end
	
	local hideSmallMap = function()
		self:hideSmallMapView()
	end
	
	local updateTeammatePosition = function ()
		local view = manager:getViewByName("SmallMapView")
		if view and view:isShowing() then
			view:showTeammate()
		end
	end
	
	local openWorldMapTipsView = function (layout, sceneId)
		manager:registerUI("WorldMapTipsView", WorldMapTipsView.create)
		manager:showUI("WorldMapTipsView", layout, sceneId)
	end
	
	local closeWorldMapTipsView = function ()
		manager:hideUI("WorldMapTipsView")
	end
	
	local removeTeammate = function (TeamObject)	
		local navigationMap =  self:getNavigationMap()	
		if navigationMap and TeamObject then
			navigationMap:removeTeammate(TeamObject)
		end
	end
	
	local removeAllTeamate = function ()		
		local navigationMap =  self:getNavigationMap()	
		if navigationMap then
			navigationMap:removeAllTeammate()
		end
	end
	
	local addTeammate = function (TeamObject)
		local navigationMap =  self:getNavigationMap()	
		if navigationMap and TeamObject then
			navigationMap:addTeammate(TeamObject)
		end
	end
	
	self:Bind(GameEvent.EventReleaseMap,handleRealeaseMap)
	self:Bind(GameEvent.EventSmallMapOpen,handleMapOpen)
	self:Bind(GameEvent.EventSmallMapNeedToUpdate,handleUpdateCurrentMap)
	self:Bind(GameEvent.EventHeroStartMove,heroOnMove)
	self:Bind(GameEvent.EventClearMovePath,handleClearMovePath)
	self:Bind(GameEvent.EventGameSceneReady,updateData)
	self:Bind(GameEvent.EventHideSmallMapView,hideSmallMap)
	self:Bind(GameEvent.EventUpdateSceneMapViewTeammatePosition, updateTeammatePosition)
	self:Bind(GameEvent.EventOpenWorldMapTipsView, openWorldMapTipsView)
	self:Bind(GameEvent.EventCloseWorldMapTipsView, closeWorldMapTipsView)
	self:Bind(GameEvent.EventRemoveTeammate, removeTeammate)
	self:Bind(GameEvent.EventRemoveAllTeamate, removeAllTeamate)
	self:Bind(GameEvent.EventAddTeammate, addTeammate)
end

function SmallMapUIHandler:currentMapNeedToUpdate()
	local manager =UIManager.Instance
	local view = manager:getViewByName("SmallMapView")
	if view then
		if view:isShowing() then
			view:updateCurrentMapView()
		end			
	end
end	

function SmallMapUIHandler:updateMovePath()
	local manager =UIManager.Instance
	local view = manager:getViewByName("SmallMapView")
	if view then
		if view:isShowing() then
			view:updateMovePath()
		end			
	end
end

function SmallMapUIHandler:hideSmallMapView()
	local manager =UIManager.Instance
	local view = manager:getViewByName("SmallMapView")
	if view then
		if view:isShowing() then
			view:close()
		end			
	end
end

function SmallMapUIHandler:clearMovePath()
	local manager =UIManager.Instance
	local view = manager:getViewByName("SmallMapView")
	if view then
		if view:isShowing() then
			view:removeMovePath()
		end			
	end
end

function SmallMapUIHandler:getNavigationMap()
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