require ("common.GameEventHandler")
require ("ui.UIManager")
require ("gameevent.GameEvent")
require ("ui.recharge.RechargeView")

RechargeUIHandler = RechargeUIHandler or BaseClass(GameEventHandler)

function RechargeUIHandler:__init()
	local manger = UIManager.Instance
	local onEventOpenRechargeView = function ()
		manger:registerUI("RechargeView", RechargeView.create)
		manger:showUI("RechargeView",E_ShowOption.eMiddle)
	end
	
	local updateView = function ()
		local view = UIManager.Instance:getViewByName("RechargeView")
		if view then
			view:updateWithList()
		end
	end
	self:Bind(GameEvent.EventOpenRechargeView, onEventOpenRechargeView)
	self:Bind(GameEvent.EventUpdateRechargeView,updateView)
end

function RechargeUIHandler:__delete()
	
end