require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.instance.InstanceView")
--require ("ui.instance.InstanceQuestView")
require ("ui.instance.InstanceAchieveView")

InstanceUIHandler = InstanceUIHandler or BaseClass(GameEventHandler)

function InstanceUIHandler:__init()
	self.handleName = "InstanceView"
	local manager =UIManager.Instance

	local handleViewOpen = function ()
		
		manager:registerUI("InstanceView", InstanceView.create)
		manager:showUI("InstanceView")
	end
	
	local handleQuestViewOpen = function ()	
		manager:registerUI("InstanceAchieveView", InstanceAchieveView.create)
		manager:showUI("InstanceAchieveView",  E_ShowOption.eMiddle, nil)
	end
	
	local handleUpdateView = function ()
		self:update()
	end		
	
	local refreshTitle = function()
		self:refreshTitle()
	end
	
	local refreshTab = function()
		self:refreshTab()
	end
	self:Bind(GameEvent.EventGameInstanceViewOpen,handleViewOpen)
	self:Bind(GameEvent.EventGameInstanceQuestViewOpen,handleQuestViewOpen)
	self:Bind(GameEvent.EventGameInstanceViewUpdate,handleUpdateView)	
	self:Bind(GameEvent.EventGameInstanceTitleRefresh,refreshTitle)
	self:Bind(GameEvent.EventHeroLevelChanged,refreshTab)
end

function InstanceUIHandler:__delete()

end


function InstanceUIHandler:update()
	local manager =UIManager.Instance
	local view = manager:getViewByName("InstanceView")
	if view then
		view:update()
	end
end	
function InstanceUIHandler:refreshTitle()
	local manager =UIManager.Instance
	local bShowing = manager:isShowing("InstanceView")
	if bShowing == true then
		local view = manager:getViewByName("InstanceView")
		if view then
			view:refreshTitle()
		end
		
	end
end

function InstanceUIHandler:refreshTab()
	local manager =UIManager.Instance
	local view = manager:getViewByName("InstanceView")
	if view then
		view:checkZhenMoTab()
	end
end