require ("common.GameEventHandler")
require ("ui.UIManager")
require ("ui.forging.ForgingView")
require ("ui.forging.strengthenScroll.EquipShowView")
require ("ui.forging.strengthenScroll.PutInEquipView")
require ("ui.forging.strengthenScroll.StrengthenScrollPreview")
ForgingUIHandler = ForgingUIHandler or BaseClass(GameEventHandler)

function ForgingUIHandler:__init()
	local manager =UIManager.Instance
	
	local onOpenFrogingView = function (showOption)
		
		manager:registerUI("ForgingView", ForgingView.create)
		manager:showUI("ForgingView",showOption)	
		local view = manager:getMainView()		
		if view then		
			view:onStopAction(MainMenu_Btn.Btn_forge)
		end	
	end

	self:Bind(GameEvent.EventOpenForgingView, onOpenFrogingView)
	
	local onOpenEquipShowView = function (showOption, arg)
		
		manager:registerUI("EquipShowView", EquipShowView.create)
		manager:showUI("EquipShowView", showOption, arg)		
	end
	self:Bind(GameEvent.EventOpenEquipShowView, onOpenEquipShowView)
	
	local onOpenPutInEquipView = function (showOption, arg)
		
		manager:registerUI("PutInEquipView", PutInEquipView.create)
		manager:showUI("PutInEquipView", showOption, arg)		
	end
	self:Bind(GameEvent.EventOpenPutInEquipView, onOpenPutInEquipView)
	
	local onOpenStrengthenScrollPreview = function (showOption, arg)
		
		manager:registerUI("StrengthenScrollPreview", StrengthenScrollPreview.create)
		manager:showUI("StrengthenScrollPreview", showOption, arg)		
	end
	self:Bind(GameEvent.EventOpenStrengthenScrollPreview, onOpenStrengthenScrollPreview)
	
	
	local onHideEquipShowView = function ()
		manager:hideUI("EquipShowView")		
	end
	self:Bind(GameEvent.EventHideEquipShowView, onHideEquipShowView)
	
	local onHidePutInEquipView = function ()
		manager:hideUI("PutInEquipView")		
	end
	self:Bind(GameEvent.EventHidePutInEquipView, onHidePutInEquipView)
	
	local onHideStrengthenScrollPreview = function ()
		manager:hideUI("StrengthenScrollPreview")		
	end
	self:Bind(GameEvent.EventHideStrengthenScrollPreview, onHideStrengthenScrollPreview)
		
	local onEventDecomposeRet = function(ret)	
		local view = manager:getViewByName("ForgingView")
		if view then
			view = view:getNodeByName("DecomposeView")
		end
		if view then
			view:setRet(ret)
		end
	end	
	GlobalEventSystem:Bind(GameEvent.EventDecomposeRet, onEventDecomposeRet)	
					
	local onItemUpdate = function(eventType, map)	
		local view = manager:getViewByName("ForgingView")		
		if view then
			local strengthen = view:getNodeByName("StrengthenView")
			if strengthen then
				strengthen:onItemUpdate(eventType, map)
			end
			local wash = view:getNodeByName("WashView")
			if wash then
				wash:onItemUpdate(eventType, map)
			end
			local decompose = view:getNodeByName("DecomposeView")
			if decompose then
				decompose:onItemUpdate(eventType, map)
			end	
		end
		local show = manager:getViewByName("EquipShowView")			
		if show then
			show:onItemUpdate()
		end
	end	
	GlobalEventSystem:Bind(GameEvent.EventItemUpdate, onItemUpdate)
	
	local onEventHeroProMerged = function(newPD)	
		if newPD and newPD.gold	then
			local view = manager:getViewByName("ForgingView")		
			if view then
				local strengthen = view:getNodeByName("StrengthenView")
				if strengthen then
					strengthen:showGoldNum()
				end
				local wash = view:getNodeByName("WashView")
				if wash then
					wash:showGoldNum()
				end
			end
		end
	end			
	self:Bind(GameEvent.EventHeroProMerged, onEventHeroProMerged)
	
	local onEventEquipUpdate = function(eventType, map)	
		local view = manager:getViewByName("ForgingView")		
		if view then
			local strengthen = view:getNodeByName("StrengthenView")
			if strengthen then
				strengthen:onEquipUpdate(eventType, map)
			end
			local wash = view:getNodeByName("WashView")
			if wash then
				wash:onEquipUpdate(eventType, map)
			end
			local decompose = view:getNodeByName("DecomposeView")
			if decompose then
				decompose:onEquipUpdate(eventType, map)
			end	
		end
		local show = manager:getViewByName("EquipShowView")			
		if show then
			show:onEquipUpdate()
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventEquipUpdate, onEventEquipUpdate)	
		
	local onEventStrengthenRet = function(ret)	
		UIManager.Instance:hideLoadingHUD()
		if (ret == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10116], color = Config.FontColor["ColorBlue2"]})
			UIManager.Instance:showSystemTips(msg)
			GlobalEventSystem:Fire(GameEvent.EventHideAllScrollStrengthenView)
		else
			local msg = {}
			table.insert(msg,{word = Config.Words[10117], color = Config.FontColor["ColorRed3"]})
			UIManager.Instance:showSystemTips(msg)
		end
	end	
	GlobalEventSystem:Bind(GameEvent.EventStrengthenRet, onEventStrengthenRet)	
	
	local onEventHideAllScrollStrengthenView = function(ret)		
		GlobalEventSystem:Fire(GameEvent.EventHideEquipShowView)
		GlobalEventSystem:Fire(GameEvent.EventHidePutInEquipView)
		GlobalEventSystem:Fire(GameEvent.EventHideStrengthenScrollPreview)
	end	
	GlobalEventSystem:Bind(GameEvent.EventHideAllScrollStrengthenView, onEventHideAllScrollStrengthenView)		
	
	local openForgeSystem = function()	
		GlobalEventSystem:Fire(GameEvent.EventSetSystemOpenStatus,MainMenu_Btn.Btn_forge,true) --开启锻造系统	
		local view = manager:getViewByName("ForgingView")		
		if view then
			view:checkOpenState()
		end
	end	
	GlobalEventSystem:Bind(GameEvent.EventForgeSystemOpen, openForgeSystem)
end