require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")

UnionInstanceUIHandler = UnionInstanceUIHandler or BaseClass(GameEventHandler)

function UnionInstanceUIHandler:__init()
	local manager =UIManager.Instance
	
	local enterUnionInstance = function ()
		GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,false)
		GlobalEventSystem:Fire(GameEvent.EventSetUnionInstanceVisible, true)
	end
	
	local exitUnionInstance = function ()
		GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible, true)
		GlobalEventSystem:Fire(GameEvent.EventSetUnionInstanceVisible, false)		
		local view = UIManager.Instance:getMainView()
		if view then
			view:changeToFightView()
		end
	end	
	
	local updateUnionInstanceView = function ()
		local mainView = manager:getMainView()
		if mainView then
			local unionInstanceView = mainView:getUnionInstanceView()
			if unionInstanceView then
				unionInstanceView:updateView()
			end
		end
	end
	
	self:Bind(GameEvent.EventEnterUnionInstance, enterUnionInstance)
	self:Bind(GameEvent.EventExitUnionInstance, exitUnionInstance)
	self:Bind(GameEvent.EventUpdateUnionInstanceView, updateUnionInstanceView)
end

function UnionInstanceUIHandler:__delete()
	
end