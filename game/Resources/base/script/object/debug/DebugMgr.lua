require("common.baseclass")
require("actionEvent.ActionEventDef")

DebugMgr = DebugMgr or BaseClass()
function DebugMgr:__init()
	DebugMgr.Instance = self
end

function DebugMgr:clear()
	self.command = nil
	self.result = nil
end

function DebugMgr:requestDebugCommand(command)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Debug_Event)
	StreamDataAdapter:WriteStr(writer,command)
	simulator:sendTcpActionEventInLua(writer)	
end

function DebugMgr:setCommand(command)
	self.command = command
end

function DebugMgr:setResult(result)
	self.result = result
end

function DebugMgr:getCommand()
	return self.command
end

function DebugMgr:getResult()
	return self.result
end