require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.vip.VipView"
require "ui.vip.VipAwardView"
VipUIHandler = VipUIHandler or BaseClass(GameEventHandler)
	
function VipUIHandler:__init()
	local vipMgr = GameWorld.Instance:getVipManager() 
	local manager =UIManager.Instance	
	
	
			
	local eventOpenVipView = function ()
		vipMgr:requestVipState()
		
		manager:registerUI("VipView", VipView.create)	
		manager:showUI("VipView")						
	end	
	
	local eventOpenVipAwardView = function()
		
		manager:registerUI("VipAwardView", VipAwardView.create)	
		manager:showUI("VipAwardView",E_ShowOption.eLeft)		
		vipMgr:requestVipAwardList()					
	end	
	
	local eventUpdateAwardItem = function(index)
		local view = manager:getViewByName("VipAwardView")
		if view~= nil then
			view:updateCellAtIndex(index)
		end	
	end
		
	local onResquestState = function()
		vipMgr:requestVipState()	
		vipMgr:requestVipAwardList()
	end
	
	local onEventShowVipEffect = function (bShow)
		ActivityDelegate:doMainVip(bShow)--mark
	end
	
	local eventUpdateActivityTipsView = function ()
		local view = UIManager.Instance:getViewByName("ActivityTips")
		if view~= nil then
			view:updateBtns("activity_manage_25")
		end
	end
	
	self:Bind(GameEvent.EventUpdateVipAwardView,eventUpdateAwardItem)
	self:Bind(GameEvent.EventUpdateActivityTipsView,eventUpdateActivityTipsView)
	self:Bind(GameEvent.EventVipAwardViewOpen, eventOpenVipAwardView)						
	self:Bind(GameEvent.EventVipViewOpen, eventOpenVipView)
	self:Bind(GameEvent.EventHeroEnterGame,onResquestState)	
	self:Bind(GameEvent.EventShowVipEffect, onEventShowVipEffect)							
end	

function VipUIHandler:__delete()
	
end		
