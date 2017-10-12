require ("ui.UIManager")
require ("ui.activity.DiscountSellView")
DiscountSellUIHandler = DiscountSellUIHandler or BaseClass(GameEventHandler)

function DiscountSellUIHandler:__init()
	local manager =UIManager.Instance
	

	local function openDiscountSellView()
		
		manager:registerUI("DiscountSellView", DiscountSellView.create)
		manager:showUI("DiscountSellView",E_ShowOption.eMiddle)		
	end			
	self:Bind(GameEvent.EventOpenDiscountSellView,openDiscountSellView)	
	
	local onEventHeroProMerged = function(newPD)
		local view = manager:getViewByName("DiscountSellView")
		if view and (newPD.unbindedGold or newPD.gold) then		
			if manager:isShowing("DiscountSellView")==true then
				view:updateMyGold()			
			end
		end	
	end	
	self:Bind(GameEvent.EventHeroProMerged, onEventHeroProMerged)
end

function DiscountSellUIHandler:__delete()
	
end	