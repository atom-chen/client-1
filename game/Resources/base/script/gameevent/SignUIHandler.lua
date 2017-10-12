require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.activity.SignView"

SignUIHandler = SignUIHandler or BaseClass(GameEventHandler)
	
function SignUIHandler:__init()
	local signMgr = GameWorld.Instance:getSignManager()
	local manager =UIManager.Instance	
	
		
	local eventOpenSignView = function (showOption, arg)	
		local view = manager:getViewByName("SignView")
		if view == nil then	
			signMgr:requestSignList()	
		end	
		manager:registerUI("SignView", SignView.create)
		manager:showUI("SignView",E_ShowOption.eMiddle, arg)				
			
	end
	
	local onResquestInit = function ()		
		signMgr:requestSignList()	
	end
	
	local eventSignViewUpdate = function()
		local view = manager:getViewByName("SignView")
		if view ~= nil then
			view:updateSignView()
--[[			local year = tonumber(string.sub(signMgr:getDateStr(),1,4))
			local month = tonumber(string.sub(signMgr:getDateStr(),5,6))
			view:setDate(year,month)--]]
			view:setSignCount(signMgr:getSignDayCount())			
		end			
	end	
	
	local eventSignViewSign = function(state)
		local view = manager:getViewByName("SignView")		
		if view~= nil then
			local index	
			if state == 0 then
				signMgr:setCanNormalSign(false)	
				index = signMgr:getCurrentDay()							
			else				
				if state ==  signMgr:getCurrentDay() - 1 then									
					signMgr:setFillSignState(false)
				end
				index = state--signMgr:getFirstFillDay()			
			end
			signMgr:setSignDayCount(signMgr:getSignDayCount() + 1)
			signMgr:signIndex(index)
			view:signGrideByIndex(index)
			view:setSignCount(signMgr:getSignDayCount())			
		end
	end	
	
	local eventUpdateAwardList = function()
		local view = manager:getViewByName("SignView")		
		if view~= nil then
			view:UpdateAwardView()
		end		
	end
	
	self:Bind(GameEvent.EventSignViewAwardUpdate,eventUpdateAwardList)
	self:Bind(GameEvent.EventSignViewSign,eventSignViewSign)
	self:Bind(GameEvent.EventSignViewUpdate,eventSignViewUpdate)						
	self:Bind(GameEvent.EventSignViewOpen, eventOpenSignView)		
	self:Bind(GameEvent.EventHeroEnterGame, onResquestInit)					
end	

function SignUIHandler:__delete()
	
end		
