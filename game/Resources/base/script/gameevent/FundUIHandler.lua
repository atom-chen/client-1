require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.activity.FundView"
FundUIHandler = FundUIHandler or BaseClass(GameEventHandler)

--[[
EventUpdateFundView = "EventUpdateFundView",
EventUpdateFundCell = "EventUpdateFundCell",
EventFundShowBuyBt = "EventFundShowBuyBt",
]]

function FundUIHandler:__init()
	local manager =UIManager.Instance	
	
	local eventOpenFundView = function()
		
		manager:registerUI("FundView", FundView.create)
		manager:showUI("FundView",E_ShowOption.eMiddle)
	end
	
	local eventUpdateFundView = function(fundType)
		
		local view = manager:getViewByName("FundView")
		if view then
			view:UpdateFundViewTable(fundType)
		end
	end
	
	local eventUpdateFundCell = function(fundType)
		
		local view = manager:getViewByName("FundView")
		if view then
			view:UpdateFundViewTableCell(fundType)
		end
	end	
	
	local eventShowFundBuyBt = function(state)
		
		local view = manager:getViewByName("FundView")
		if view then
			view:showBuyFundBt(state)
		end
	end
	
	local eventRequestFundState = function()
		local fundMgr = GameWorld.Instance:getFundManager()
		fundMgr:requestFundState()
	end
	
	self:Bind(GameEvent.EventFundShowBuyBt,eventShowFundBuyBt)
	self:Bind(GameEvent.EventUpdateFundCell,eventUpdateFundCell)	
	self:Bind(GameEvent.EventUpdateFundView,eventUpdateFundView)
	self:Bind(GameEvent.EventOpenFundView,eventOpenFundView)
	self:Bind(GameEvent.EventHeroEnterGame,eventRequestFundState)
end	

function FundUIHandler:__delete()
	
end		
