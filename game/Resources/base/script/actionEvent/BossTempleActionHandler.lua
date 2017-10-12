require "data.activity.monsterInvasion"
BossTempleActionHandler = BossTempleActionHandler or BaseClass(ActionEventHandler)

function BossTempleActionHandler:__init()
	
	local handNetG2C_EventEnterBossTemple = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")
		GlobalEventSystem:Fire(GameEvent.EventEnterBossTemple)	
	end
	
	local handNetG2C_EventExitBossTemple = function (reader)
		reader = tolua.cast(reader, "iBinaryReader")	
		GlobalEventSystem:Fire(GameEvent.EventExitBossTemple)		
	end 			

	self:Bind(ActionEvents.G2C_BossTemple_Enter, handNetG2C_EventEnterBossTemple)
	self:Bind(ActionEvents.G2C_BossTemple_Exit, handNetG2C_EventExitBossTemple)	
end		
