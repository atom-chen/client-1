require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("ui.UIManager")
DebugActionHandler = DebugActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()


function DebugActionHandler:__init()
	local handleNet_G2C_Debug_Event = function(reader)
		self:handleNet_G2C_Debug_Event(reader)
	end		
	self:Bind(ActionEvents.G2C_Debug_Event,handleNet_G2C_Debug_Event)
	
end
	
	
function DebugActionHandler:handleNet_G2C_Debug_Event(reader)
	local debugMgr = GameWorld.Instance:getEntityManager():getHero():getDebugMgr()	
	reader = tolua.cast(reader,"iBinaryReader")
	local command = StreamDataAdapter:ReadStr(reader)
	local result = StreamDataAdapter:ReadStr(reader)
	debugMgr:setCommand(command)
	debugMgr:setResult(result)
	if(command == "help") then
		GlobalEventSystem:Fire(GameEvent.EventRefreshDebugView)
	elseif(result ~= "fail") then
		UIManager.Instance:showSystemTips("Success")
	end
end