--[[
角色状态的封装
]]

require("common.baseclass")
require("object.entity.CharacterState")
require("object.entity.GameStateMachine")

local keyEnterFun = "enterFun"
local keyExitFun = "exitFun"
local keyCondition = "conditionFun"

GameState = GameState or BaseClass()

function GameState:__init()
	self.actionState = CharacterState.CharacterStateNone	-- 互斥的动作状态
	self.isLock = false
	self.stateCallback = {}
	
	self.comboStateList = {}			-- 组合状态
	self.comboStateCallback = nil		-- 组合状态的进入退出函数
end

function GameState:__delete()
	self.stateCallback = nil
end

function GameState:getState()
	return self.actionState
end

-- 设置状态的进入和退出的回调
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

-- 尝试改变状态
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
			-- 旧的状态的退出回调
			self.stateCallback[self.actionState][keyExitFun](newState)
		end
		
		self.actionState = newState
		
		-- 新的状态的进入回调
		if self.stateCallback[newState] and self.stateCallback[newState][keyEnterFun] then		
			self.stateCallback[newState][keyEnterFun](unpack({...}))
		end
		
		return true
	else
		return false
	end
end

-- 强制转换状态, 不检测转换条件
function GameState:forceChangeState(newState, ...)
	if self.stateCallback[self.actionState] and self.stateCallback[self.actionState][keyExitFun] then
		-- 旧的状态的退出回调
		self.stateCallback[self.actionState][keyExitFun]()
	end
	
	-- 如果有enterFun, 还要根据enterFun来决定是否真的可以转变为这个
	if self.stateCallback[newState] and self.stateCallback[newState][keyEnterFun] then
		-- 新的状态的进入回调
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

-- 组合状态的进入和退出的回调
function GameState:setComboStateCallback(comboStateCallback)
	self.comboStateCallback = comboStateCallback
end

-- 组合状态的添加
function GameState:addComoState(stateDef)
	if self.comboStateList[stateDef] == nil then
		self.comboStateList[stateDef] = true
	end
	
	if self.comboStateCallback then
		self.comboStateCallback(stateDef, true)
	end
end

-- 组合状态的删除
function GameState:removeComboState(stateDef)
	self.comboStateList[stateDef] = nil
	
	if self.comboStateCallback then
		self.comboStateCallback(stateDef, false)
	end
end

-- 传入最新的状态列表
function GameState:updateComboStateList(stateList)
	-- 先把所有状态标记为 false
	for k,v in pairs(self.comboStateList) do
		if self.comboStateList[k] == true then
			self.comboStateList[k] = false
		end
	end
	
	if stateList and type(stateList) == "table" then
		for k,v in pairs(stateList) do
			if self.comboStateList[v] == false then
				--  原本就存在的状态
				self.comboStateList[v] = true
			elseif self.comboStateList[v] == nil then
				-- 原本不存在的状态
				self:addComoState(v)
			end
		end
	end
	
	-- 遍历检查有没状态为false的状态, 有的话就是要 remove的状态
	for k,v in pairs(self.comboStateList) do
		if self.comboStateList[k] == false then
			self:removeComboState(k)
		end
	end
end

function GameState:getComboStateList()
	return self.comboStateList
end