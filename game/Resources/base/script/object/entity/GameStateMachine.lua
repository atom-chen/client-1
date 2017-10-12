--[[
角色的状态机
]]

require("common.baseclass")
require("object.entity.CharacterState")
GameStateMachine = GameStateMachine or BaseClass()

function GameStateMachine:__init()
	GameStateMachine.Instance = self
	
	self.mutexStateList = {}	-- 互斥状态
	
	
	self:initMutexState()
end

function GameStateMachine:__delete()
	
end

function GameStateMachine:addMutexState(state, ...)
	local args = {...}
	if args then
		if self.mutexStateList[state] == nil then
			self.mutexStateList[state] = {}
		end
		
		for k,v in ipairs(args) do
			self.mutexStateList[state][v] = true
		end
	end
end

function GameStateMachine:addComboState()
	
end

function GameStateMachine:canChange(oldState, newState)
	if oldState == newState or (self.mutexStateList[oldState] and self.mutexStateList[oldState][newState] == true) then
		return false
	else
		return true
	end
end

function GameStateMachine:initMutexState()
	-- 进入willDeath的entity是准备进入死亡表演的, 只能向死亡状态转换
	self:addMutexState(CharacterState.CharacterStateWillDead, CharacterState.CharacterStateMove, CharacterState.CharacterStateHit,CharacterState.CharacterStateUseSkill,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHitBack, CharacterState.CharacterStateIdle)
	
	-- 使用技能的优先级高
	self:addMutexState(CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
	self:addMutexState(CharacterState.CharacterStateMove, CharacterState.CharacterStateHit)
	self:addMutexState(CharacterState.CharacterStateDead, CharacterState.CharacterStateMove, CharacterState.CharacterStateHit,CharacterState.CharacterStateUseSkill,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHitBack, CharacterState.CharacterStateWillDead)
	
	-- 击退和击飞过程中什么都不能做
	self:addMutexState(CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideMove, CharacterState.CharacterStateUseSkill)
	self:addMutexState(CharacterState.CharacterStateHitBack, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideMove, CharacterState.CharacterStateUseSkill)
	
	-- 在坐骑上不表演受击
	self:addMutexState(CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateHit)
	self:addMutexState(CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHit)
	
	-- 战斗状态对action状态的影响
	self:addMutexState(CharacterFightState.Slient, CharacterState.CharacterStateUseSkill)
	self:addMutexState(CharacterFightState.Dizzy, CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
	self:addMutexState(CharacterFightState.Paresis, CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
end