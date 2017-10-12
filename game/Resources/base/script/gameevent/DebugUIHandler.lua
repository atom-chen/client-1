require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.debug.DebugView")

DebugUIHandler = DebugUIHandler or BaseClass(GameEventHandler)

function DebugUIHandler:__init()
	local manager =UIManager.Instance
	
	
	local handleClient_Open = function ()
		
		manager:registerUI("DebugView", DebugView.create)
		manager:showUI("DebugView")		
		local debugMgr = GameWorld.Instance:getEntityManager():getHero():getDebugMgr()		
		debugMgr:requestDebugCommand("help")
	end
	
	local refreshDebug = function()
		local view = manager:getViewByName("DebugView")
		if view then
			view:refreshView()
		end
	end
	self:Bind(GameEvent.EventRefreshDebugView,refreshDebug)
	
	self:Bind(GameEvent.EventOpenDebugView,handleClient_Open)
end