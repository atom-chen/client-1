require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")

PayUIHandler = PayUIHandler or BaseClass(GameEventHandler)

function PayUIHandler:__init()
	local manager =UIManager.Instance
	
	local eventReceivePayGiftBag = function (index)
		local view = manager:getViewByName("OpenPayGiftBagView")
		if view then
			view:receiveGiftBag(index)
		end
	
	end
	
	local eventHaveReceiveFirstPayGiftBag = function ()
		local view = manager:getViewByName("FirstPayGiftBagView")
		if view then
			view:receiveFirstPayGiftBag()
		end
	end
	
	local eventReceiveEveryDayPayBag = function ()
		local view = manager:getViewByName("EveryDayPayGiftBagView")
		if view then
			view:receiveEveryDayPayGiftBag()
		end
	end
	
	local eventReceiveEveryWeekPayGiftBag = function (index)
		local view = manager:getViewByName("EveryWeekPayAwardView")
		if view then
			view:receiveEveryWeekGifg(index)
		end
	end
						
	self:Bind(GameEvent.EventReceivePayGiftBag, eventReceivePayGiftBag)	
	self:Bind(GameEvent.EventHaveReceiveFirstPayGiftBag, eventHaveReceiveFirstPayGiftBag)
	self:Bind(GameEvent.EventReceiveEveryDayPayBag, eventReceiveEveryDayPayBag)
	self:Bind(GameEvent.EventReceiveEveryWeekPayGiftBag, eventReceiveEveryWeekPayGiftBag)						
end	

function PayUIHandler:__delete()

end