require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.mount.MountView"
require "ui.Main.MainView"
require "object.skillShow.player.CharacterAnimatePlayer"
MountUIHandler = MountUIHandler or BaseClass(GameEventHandler)
	
function MountUIHandler:__init()
	local manager =UIManager.Instance	
	
	self.isFirstLogin = true
	self.firstReceive = true
	local mountMgr = GameWorld.Instance:getMountManager()	
	local onResquestInit = function ()						
		mountMgr:requestMountList()	
	end		
	local eventUpdate = function ()				
		local view = manager:getViewByName("MountView")
		refId = mountMgr:getCurrentUseMountId()
		Exp = mountMgr:getCurrentMountExp()
		if(view ~= nil) then
			view:UpdateMountView(refId,Exp)
		end
	end
	
	local eventOpenMount = function (showOption)	
		local mountId = mountMgr:getCurrentUseMountId()
		if(mountId == -1 ) then
			return 
		end
		
		manager:registerUI("MountView", MountView.create)
		manager:showUI("MountView",showOption)			
		local view = manager:getMainView()		
		if view then
			--view:onRemoveAnimateByBtnId(MainMenu_Btn.Btn_mount)
			view:onStopAction(MainMenu_Btn.Btn_mount)
	end			
	end				
	
	local eventChangeItemZuoqiExp = function(refId)
		if refId ~= "item_zuoqiExp" then
			return
		end
		local view = manager:getViewByName("MountView")
		if(view ~= nil) then
			view:changeItemZuoqiExp()
		end	
	end
	local eventStopAnimation = function()
		local view = manager:getViewByName("MountView")
		if(view ~= nil) then
			view:stopAutoUpgrade()
		end		
	end		
	
	local eventShowBaoji = function(times)
		local view = manager:getViewByName("MountView")
		if(view ~= nil) then
			view:showBaoji(times)
		end	
	end
	
	
	local eventUpdateState = function(state)
		local view = manager:getMainView()
		if( view ~= nil) then				
			local mainMap = view:getMapView()		
			if(mainMap ~= nil )then
				if state == 0 then
					mainMap:setMountCD(5)
				else
					mainMap:setMountCD(0)
				end
				mainMap:UpdateRideState(state)		
			end						
		end				
	end	
	
	local eventShowMountEffect = function(bShow)
		local view = manager:getMainView()
		if( view ~= nil) then				
			local mainMap = view:getMapView()		
			if(mainMap ~= nil )then			
				mainMap:showEffectSprite(bShow)		
			end						
		end	
	end
	
	self:Bind(GameEvent.EventMountBaoJi,eventShowBaoji)
	self:Bind(GameEvent.EventSwitchMountState,eventUpdateState)
	self:Bind(GameEvent.EventIsOnMount,eventShowMountEffect)
	self:Bind(GameEvent.EventStopMountAnimation,eventStopAnimation)
	self:Bind(GameEvent.EventBuyItemSucess,eventChangeItemZuoqiExp)					
	self:Bind(GameEvent.EventMountWindowOpen, eventOpenMount)	
	self:Bind(GameEvent.EventMountUpdate,eventUpdate)
	self:Bind(GameEvent.EventHeroEnterGame,onResquestInit)		
end			

function MountUIHandler:__delete()
end		
