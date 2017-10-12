require("common.baseclass")
require("object.handup.FSM.HandupState")
GlobalState = GlobalState or BaseClass(HandupState)

function GlobalState:__init()
	
end

function GlobalState:__delete()
	
end

--this will execute when the state is entered
function GlobalState:onEnter()
	
end

--this will execute when the state is exited. 
function GlobalState:onExit()
	
end	

function GlobalState:onMessage(msg)
	local ttype = msg:getType()
	if ttype == E_HandupMsgType.BeAttacked then	--±»¹¥»÷£¬Òª·´»÷
		local attacker = msg:getExtraInfo()
		if attacker then
			GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, attacker:getEntityType(), attacker:getId())	
			print("GlobalState:onMessage fight back with player "..attacker:getId())								
			self.fsm:changeState(self.mgr:getState(E_HandupStateType.FightBack), HandupStatePriority.FightBack)
		end
	elseif ttype == E_HandupMsgType.StopWithPickup then	
--		print("stop with pick up")															  
--		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Pickup), HandupStatePriority.PickupAndStop, const_handupDelayPickupTime + 1, true)	
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Pickup), HandupStatePriority.PickupAndStop, const_handupDelayPickupTime, true)	
	end
	return true
end	