--[[
��ɫ״̬�ķ�װ
]]

require("common.baseclass")
require("object.entity.CharacterState")
require("object.entity.GameStateMachine")

local keyEnterFun = "enterFun"
local keyExitFun = "exitFun"
local keyCondition = "conditionFun"

GameState = GameState or BaseClass()

function GameState:__init()
	self.actionState = CharacterState.CharacterStateNone	-- ����Ķ���״̬
	self.isLock = false
	self.stateCallback = {}
	
	self.comboStateList = {}			-- ���״̬
	self.comboStateCallback = nil		-- ���״̬�Ľ����˳�����
end

function GameState:__delete()
	self.stateCallback = nil
end

function GameState:getState()
	return self.actionState
end

-- ����״̬�Ľ�����˳��Ļص�
function GameState:setStateCallback(state, stateEnterFunc, stateExitFunc, stateConditionFunc)
	if state and self.stateCallback[state] == nil and (stateEnterFunc or stateExitFunc )then
		self.stateCallback[state] = {}
		
		if stateEnterFunc then
			self.stateCallback[state][keyEnterFun] = stateEnterFunc
		end
		
		if stateExitFunc then
			self.stateCallback[state][keyExitFun] = stateExitFunc
		end
		
		if stateConditionFunc then
			self.stateCallback[state][keyCondition] = stateConditionFunc
		end
	end
end

-- ���Ըı�״̬
function GameState:canChange(newState)	
	local checkCombo = true
	for k,v in pairs(self.comboStateList) do
		if v == true and GameStateMachine.Instance:canChange(k, newState) == false then
			checkCombo = false
			break
		end
	end
	
	return GameStateMachine.Instance:canChange(self.actionState, newState) and self.isLock == false and checkCombo
end

function GameState:changeState(newState, ...)
	if newState and newState ~= self.actionState and self:canChange(newState) and 
		(self.stateCallback[newState] == nil or self.stateCallback[newState][keyCondition] == nil or self.stateCallback[newState][keyCondition](unpack({...})) == true) then
		if self.stateCallback[self.actionState] and self.stateCallback[self.actionState][keyExitFun] then
			-- �ɵ�״̬���˳��ص�
			self.stateCallback[self.actionState][keyExitFun](newState)
		end
		
		self.actionState = newState
		
		-- �µ�״̬�Ľ���ص�
		if self.stateCallback[newState] and self.stateCallback[newState][keyEnterFun] then		
			self.stateCallback[newState][keyEnterFun](unpack({...}))
		end
		
		return true
	else
		return false
	end
end

-- ǿ��ת��״̬, �����ת������
function GameState:forceChangeState(newState, ...)
	if self.stateCallback[self.actionState] and self.stateCallback[self.actionState][keyExitFun] then
		-- �ɵ�״̬���˳��ص�
		self.stateCallback[self.actionState][keyExitFun]()
	end
	
	-- �����enterFun, ��Ҫ����enterFun�������Ƿ���Ŀ���ת��Ϊ���
	if self.stateCallback[newState] and self.stateCallback[newState][keyEnterFun] then
		-- �µ�״̬�Ľ���ص�
		if self.stateCallback[newState][keyEnterFun](unpack({...})) == true then
			self.actionState = newState
			self.isLock = false
			return true
		else
			return false
		end
	else
		self.actionState = newState
		return true
	end
end

function GameState:isState(state)
	return self.actionState == state or self.comboStateList[state] == true
end

function GameState:setIsLock(isLock)
	self.isLock = isLock
end

function GameState:getIsLock()
	return self.isLock
end

-- ���״̬�Ľ�����˳��Ļص�
function GameState:setComboStateCallback(comboStateCallback)
	self.comboStateCallback = comboStateCallback
end

-- ���״̬�����
function GameState:addComoState(stateDef)
	if self.comboStateList[stateDef] == nil then
		self.comboStateList[stateDef] = true
	end
	
	if self.comboStateCallback then
		self.comboStateCallback(stateDef, true)
	end
end

-- ���״̬��ɾ��
function GameState:removeComboState(stateDef)
	self.comboStateList[stateDef] = nil
	
	if self.comboStateCallback then
		self.comboStateCallback(stateDef, false)
	end
end

-- �������µ�״̬�б�
function GameState:updateComboStateList(stateList)
	-- �Ȱ�����״̬���Ϊ false
	for k,v in pairs(self.comboStateList) do
		if self.comboStateList[k] == true then
			self.comboStateList[k] = false
		end
	end
	
	if stateList and type(stateList) == "table" then
		for k,v in pairs(stateList) do
			if self.comboStateList[v] == false then
				--  ԭ���ʹ��ڵ�״̬
				self.comboStateList[v] = true
			elseif self.comboStateList[v] == nil then
				-- ԭ�������ڵ�״̬
				self:addComoState(v)
			end
		end
	end
	
	-- ���������û״̬Ϊfalse��״̬, �еĻ�����Ҫ remove��״̬
	for k,v in pairs(self.comboStateList) do
		if self.comboStateList[k] == false then
			self:removeComboState(k)
		end
	end
end

function GameState:getComboStateList()
	return self.comboStateList
end