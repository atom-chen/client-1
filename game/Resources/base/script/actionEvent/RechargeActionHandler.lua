require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

RechargeActionHandler = RechargeActionHandler or BaseClass(ActionEventHandler)

function RechargeActionHandler:__init()
	local handleList = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleList(reader)
	end
	
	self:Bind(ActionEvents.G2C_QuickRecharge_List,handleList)
end	

function RechargeActionHandler:__delete()
	
end

function RechargeActionHandler:handleList(reader)
	local listCount = StreamDataAdapter:ReadChar(reader)
	local list = {}
	local ref = ""	
	for i = 1, listCount do
		ref = StreamDataAdapter:ReadStr(reader)		
		list[ref] = true
	end
	if listCount > 0 then
		GameWorld.Instance:getRechargeMgr():updateWithList(list)
		GlobalEventSystem:Fire(GameEvent.EventUpdateRechargeView, onEventOpenRechargeView)
	else
		if  not GameWorld.Instance:getRechargeMgr():hasBeenReset() then
			GameWorld.Instance:getRechargeMgr():resetAll()			
			GlobalEventSystem:Fire(GameEvent.EventUpdateRechargeView, onEventOpenRechargeView)		
		end			
	end
end

