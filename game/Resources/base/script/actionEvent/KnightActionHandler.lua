require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("ui.UIManager")
KnightActionHandler = KnightActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()


function KnightActionHandler:__init()
	local handleNet_G2C_GetSalaryEvent  = function(reader)
		self:handleNet_G2C_GetSalaryEvent(reader)
	end
	self:Bind(ActionEvents.G2C_GetSalaryEvent ,handleNet_G2C_GetSalaryEvent)
	local handleNet_G2C_CanGetReward  = function(reader)
		self:handleNet_G2C_CanGetReward(reader)
	end
	self:Bind(ActionEvents.G2C_CanGetReward,handleNet_G2C_CanGetReward)
end	

function KnightActionHandler:handleNet_G2C_GetSalaryEvent(reader)	
	reader = tolua.cast(reader,"iBinaryReader")
	GlobalEventSystem:Fire(GameEvent.EventSalaryGot)
	local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
	knightMgr:setSalaryFlag(true)
	
end
function KnightActionHandler:handleNet_G2C_CanGetReward(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local flag = StreamDataAdapter:ReadChar(reader)
	if flag == 0 then --不可领取
		local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
		knightMgr:setSalaryFlag(true)
	elseif flag == 1 then --可以领取
		local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
		knightMgr:setSalaryFlag(false)
		GlobalEventSystem:Fire(GameEvent.EventRewardReset)
	end
end


function KnightActionHandler:__delete()
	
end	
