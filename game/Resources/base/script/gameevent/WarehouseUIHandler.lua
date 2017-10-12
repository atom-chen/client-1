require ("common.GameEventHandler")
require ("ui.UIManager")
require ("ui.warehouseView.WarehouseView")
require ("ui.bag.BagView")

WarehouseUIHandler = WarehouseUIHandler or BaseClass(GameEventHandler)

function WarehouseUIHandler:__init()
	local manager = UIManager.Instance
	manager:registerUI("WarehouseView", WarehouseView.create)
	
	local onEventOpenWarehouseView = function ()	
		manager:showUI("WarehouseView", E_ShowOption.eMove2Left)
		GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eMove2Right, {contentType = E_BagContentType.All, delayLoadingInterval = 0.05})	
		
		
	end
	
	local onEventCloseWarehouseView = function ()
		local view = manager:getViewByName("WarehouseView")
		if view then
			view:close()
		end
	end
	
	local onEventUpdateWarehouseItem = function (eventType, list)
		local view = manager:getViewByName("WarehouseView")
		if view then
			view:updateItem(eventType, list)
			view:showCapacity()
		end
	end
	
	local onEventUpdateWarehouseView = function ()
		local view = manager:getViewByName("WarehouseView")
		if view then
			view:showCapacity()
			view:updateView()
		end
	end
	
	self:Bind(GameEvent.EventOpenWarehouseView, onEventOpenWarehouseView)
	self:Bind(GameEvent.EventCloseWarehouseView, onEventCloseWarehouseView)
	self:Bind(GameEvent.EventUpdateWarehouseItem, onEventUpdateWarehouseItem)
	self:Bind(GameEvent.EventUpdateWarehouseView, onEventUpdateWarehouseView)
end

function WarehouseUIHandler:__delete()
	
end
