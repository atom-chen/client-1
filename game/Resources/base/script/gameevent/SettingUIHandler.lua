require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.setting.SettingView")

SettingUIHandler = SettingUIHandler or BaseClass(GameEventHandler)

function SettingUIHandler:__init()
	local manager =UIManager.Instance	
		
	local onEventShowSettingView = function(showOption, arg)
	
		manager:registerUI("SettingView", SettingView.create)
		manager:showUI("SettingView",  showOption, arg)
	end 		
	local onEventHideSettingView = function()
		manager:hideUI("SettingView")
	end
	
	local onEventUpdateExtendSkillRefId = function()		
		local view1 = manager:getViewByName("SettingView")
		if view1 then
			view1:updateHandupConfigUI()
		end			
	end
	
	local onEventOptionConfigChanged = function ()
		local view = manager:getViewByName("SettingView")
		if view then
			view:updateOptionView()
		end
	end
	
	local onEventPickUpConfigChanged = function ()
		local view = manager:getViewByName("SettingView")
		if view then
			view:updatePickUpView()
		end
	end
	
	local onEventBackToSelectRoleView = function ()
		local settingMgr = GameWorld.Instance:getSettingMgr()
		if settingMgr then
			settingMgr:backToSelectRoleView()
		end
	end
	
	self:Bind(GameEvent.EventUpdateExtendSkillRefId, onEventUpdateExtendSkillRefId)
	self:Bind(GameEvent.EventHideSettingView, onEventHideSettingView)
	self:Bind(GameEvent.EventShowSettingView, onEventShowSettingView)	
	self:Bind(GameEvent.EventOptionConfigChanged, onEventOptionConfigChanged)
	self:Bind(GameEvent.EventPickUpConfigChanged, onEventPickUpConfigChanged)	
	self:Bind(GameEvent.EventBackToSelectRoleView, onEventBackToSelectRoleView)				
end	

function SettingUIHandler:__delete()
	
end
