--[[
��ɫ��״̬��
]]

require("common.baseclass")
require("object.entity.CharacterState")
GameStateMachine = GameStateMachine or BaseClass()

function GameStateMachine:__init()
	GameStateMachine.Instance = self
	
	self.mutexStateList = {}	-- ����״̬
	
	
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
	-- ����willDeath��entity��׼�������������ݵ�, ֻ��������״̬ת��
	self:addMutexState(CharacterState.CharacterStateWillDead, CharacterState.CharacterStateMove, CharacterState.CharacterStateHit,CharacterState.CharacterStateUseSkill,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHitBack, CharacterState.CharacterStateIdle)
	
	-- ʹ�ü��ܵ����ȼ���
	self:addMutexState(CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
	self:addMutexState(CharacterState.CharacterStateMove, CharacterState.CharacterStateHit)
	self:addMutexState(CharacterState.CharacterStateDead, CharacterState.CharacterStateMove, CharacterState.CharacterStateHit,CharacterState.CharacterStateUseSkill,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHitBack, CharacterState.CharacterStateWillDead)
	
	-- ���˺ͻ��ɹ�����ʲô��������
	self:addMutexState(CharacterState.CharacterStateHitFly, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideMove, CharacterState.CharacterStateUseSkill)
	self:addMutexState(CharacterState.CharacterStateHitBack, CharacterState.CharacterStateHit, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideMove, CharacterState.CharacterStateUseSkill)
	
	-- �������ϲ������ܻ�
	self:addMutexState(CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateHit)
	self:addMutexState(CharacterState.CharacterStateRideMove, CharacterState.CharacterStateHit)
	
	-- ս��״̬��action״̬��Ӱ��
	self:addMutexState(CharacterFightState.Slient, CharacterState.CharacterStateUseSkill)
	self:addMutexState(CharacterFightState.Dizzy, CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
	self:addMutexState(CharacterFightState.Paresis, CharacterState.CharacterStateUseSkill, CharacterState.CharacterStateMove, CharacterState.CharacterStateCollect,
	CharacterState.CharacterStateRideIdle, CharacterState.CharacterStateRideMove)
end