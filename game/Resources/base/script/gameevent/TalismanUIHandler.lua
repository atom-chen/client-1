require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.Talisman.TalismanView"
TalismanUIHandler = TalismanUIHandler or BaseClass(GameEventHandler)
	
function TalismanUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance	
	
	local artiMgr =	GameWorld.Instance:getTalismanManager()
	local onResquestInit = function()
		artiMgr:requestTalismanList()
	end
		
	local eventOpenTalisman = function (showOption, arg)	
		manager:registerUI("TalismanView", TalismanView.create)	
		manager:showUI("TalismanView",showOption, arg)
		artiMgr:requestTalismanGetReward()			
		local view = manager:getMainView()	
		if view then
			view:onStopAction(MainMenu_Btn.Btn_talisman)
		end	
	end	
	
	local eventUpdateTalisman = function(ttype)
		local view = manager:getViewByName("TalismanView")
		if view then
			if ttype == 1 then
				view:updateLeftView()
				view:updateMiddleView()
			elseif ttype == 2 then
				view:updateLeftView()
				view:updateMiddleView()
				view:updateInfoView()
			elseif ttype == 3 then
				view:updateLeftView()
				view:updateMiddleView()
				view:updateInfoView()
			elseif ttype == 4 then
				view:updateAwardView()
			elseif ttype == 5 then
				view:updateLeftView()
				view:updateMiddleView()
				view:updateInfoView()
				view:updateAwardView()
			end
		end
	end	
	
	local eventHandleRet = function(ret,ttype)
		local typeStr	
		local stateStr
		if(ttype == 1) then
			typeStr = Config.Words[7502]
		elseif(ttype == 2) then
			typeStr = Config.Words[7500]
		elseif(ttype == 3) then
			typeStr = Config.Words[7501]
		elseif( ttype == 4) then
			typeStr = Config.Words[7510]
		else
		end
		if(ret == 1) then
			return	
		else
			stateStr = Config.Words[7511]
		end
		UIManager.Instance:showSystemTips(typeStr  .. stateStr)
	end	
	
	local eventErrorHandler = function(msgId, printCode)
		if msgId == ActionEvents.C2G_Talisman_Active then
			if printCode >= 0 then
				GameWorld.Instance:getTalismanManager():requestTalismanList()
			end	
		end
	end			
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventTalismanViewOpen, eventOpenTalisman))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame,onResquestInit))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateTilismanView,eventUpdateTalisman))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRetTilismanView,eventHandleRet))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventErrorCode,eventErrorHandler))			
end	

function TalismanUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end		
