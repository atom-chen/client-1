require("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

NpcActionHandle = NpcActionHandle or BaseClass(ActionEventHandler)

function NpcActionHandle:__init()
	local handle_G2C_Pluck_BeInteruuptedToClient = function(reader)
		self:handle_G2C_Pluck_BeInteruuptedToClient(reader)
	end		
	
	self:Bind(ActionEvents.G2C_Scene_InterruptPluck,handle_G2C_Pluck_BeInteruuptedToClient)
	
end

--²É¼¯ÖÐ¶Ï
function NpcActionHandle:handle_G2C_Pluck_BeInteruuptedToClient(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	GlobalEventSystem:Fire(GameEvent.EventInteruptCollect)
end