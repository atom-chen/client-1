require("ui.stronger.StrongerView")

StrongerUIHandler = StrongerUIHandler or BaseClass(GameEventHandler)

function StrongerUIHandler:__init()
	local manager = UIManager.Instance
	manager:registerUI("StrongerView", StrongerView.New)	
	
	local onEventOpenStrongerView = function (showOption, arg)		
		manager:showUI("StrongerView",  showOption, arg)		
	end
	
	local onEventShowStrongerOptionView = function(refId)
		local view = manager:getViewByName("StrongerView")
		if view then
			view:showOptionDetailByRefId(refId)
		end
	end
	
	local onEventHeroProMerged = function()	
		local view = manager:getViewByName("StrongerView")
		if view and manager:isShowing("StrongerView") then
			view:showFightPower()
		end
	end
	
	local onEventCloseStrongerView = function()	
		local view = manager:getViewByName("StrongerView")
		if view and manager:isShowing("StrongerView") then
			view:close()
		end
	end
	
	self:Bind(GameEvent.EventShowStrongerOptionView,onEventShowStrongerOptionView)
	self:Bind(GameEvent.EventOpenStrongerView, onEventOpenStrongerView)
	self:Bind(GameEvent.EventHeroProMerged, onEventHeroProMerged)
	self:Bind(GameEvent.EventCloseStrongerView, onEventCloseStrongerView)	
end

function StrongerUIHandler:__delete()
	
end	
