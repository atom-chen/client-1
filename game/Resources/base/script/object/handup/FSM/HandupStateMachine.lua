--挂机状态机

require("common.baseclass")
HandupStateMachine = HandupStateMachine or BaseClass()

HandupStatePriority = 
{
	PickupAndStop = 80,
	FightBack = 50,
	Pickup = 20,
	Normal = 10
}

local const_updateInterval = 0

function HandupStateMachine:__init()
	self.currentState = nil
	self.globalState = nil
	self.countTime = nil
	self.toState = {state = nil, delay = 0, extraData = nil}
end

function HandupStateMachine:__delete()
	self:removeSchId()
end

function HandupStateMachine:setCurrentState(state)
	self.currentState = state
end

function HandupStateMachine:getCurrentState()
	return self.currentState
end

function HandupStateMachine:setGlobalState(state)
	self.globalState = state
end

function HandupStateMachine:getGlobalState()
	return self.globalState
end	

function HandupStateMachine:handleMessage(msg)
    if (self.currentState) then
		if self.currentState:onMessage(msg) then
			return
		end
	end
	if(self.globalState) then
		if self.globalState:onMessage(msg) then
			return
		end
	end
end	

--停止状态机
function HandupStateMachine:stop()
	if(self.globalState) then
		self.globalState:exit()
		self.globalState = nil
	end
	
    if (self.currentState) then
		self.currentState:exit()
		self.globalState = nil
	end	
	self:removeSchId()
	self:clearNextState()
	self.countTime = 0
end

--self.toState = {state = nil, delay = 0, extraData = nil}
function HandupStateMachine:start()
	self:removeSchId()
	self:clearNextState()
	self.countTime = 0
	local onTimeout = function(time)
		if self.toState.state then
			self.countTime = self.countTime + time
			if self.countTime > self.toState.delay then
				local state = self.toState.state
				local extraData = self.toState.extraData
				self:clearNextState()
				self:doChangeState(state, extraData)
			end
		end
	end
	self.delayChangeStateSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, const_updateInterval, false)
end

function HandupStateMachine:saveNextState(newState, priority, delay, extraData)
	self.toState.state = newState	
	self.toState.delay = delay
	self.toState.extraData = extraData
	self.toState.priority = priority
end

function HandupStateMachine:clearNextState()
	self.toState.state = nil
	self.toState.delay = 0
	self.toState.extraData = nil
	self.toState.priority = HandupStatePriority.Normal
end

function HandupStateMachine:removeSchId()
	if self.delayChangeStateSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayChangeStateSchId)
		self.delayChangeStateSchId = nil
	end
end

function HandupStateMachine:changeState(newState, priority, delay, extraData)
	if not newState then
		return
	end
	if type(priority) ~= "number" then
		priority = HandupStatePriority.Normal
	end
	if self.toState.state and (priority < self.toState.priority) then
		print("HandupStateMachine:changeState could not chanage. priority="..priority.." self.toState.priority="..self.toState.priority)
		print("HandupStateMachine:changeState could not chanage. priority="..priority.." self.toState.priority="..self.toState.priority)		
		return
	end
	if type(delay) ~= "number" or delay < 0 then
		delay = 0
	end
	self:saveNextState(newState, priority, delay, extraData)	
	self.countTime = 0	--将计数清0
end

function HandupStateMachine:doChangeState(newState, extraData)
--	print("HandupStateMachine:doChangeState to "..newState:getType())

    --call the exit method of the existing state
	if self.currentState then
		self.currentState:exit()
	end

    --change state to the new state
    self.currentState = newState

    --call the entry method of the new state
    self.currentState:enter(extraData)
end		