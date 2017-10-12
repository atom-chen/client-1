--挂机状态基类，供各个具体状态继承
require("common.baseclass")
require("object.handup.API.HandupCommonAPI")
require("object.handup.API.HandupConfigMgr")
require("object.handup.API.HandupSkillMgr")
require("object.actionPlayer.SearchTargetActionPlayer")

HandupState = HandupState or BaseClass()

function HandupState:__init()
	self.fsm = G_getHandupFSM()
	self.mgr = G_getHandupMgr()	
	self.fightTargetMgr = GameWorld.Instance:getFightTargetMgr()
	self.pickupMgr = GameWorld.Instance:getPickUpMnanager()
	self.isRunning = false
end

function HandupState:__delete()
	
end

--this will execute when the state is entered
function HandupState:enter(extraData)
	if not self.mgr:isHandup() then
		return
	end
	
	self.isRunning = true
	if self.onEnter then
		self:onEnter(extraData)
	end
end

--this will execute when the state is exited. 
function HandupState:exit()
	self.isRunning = false
	if self.onExit then
		self:onExit()
	end
end

function HandupState:setDes(des)
	self.des = des	
end

function HandupState:getDes()
	return self.des
end

--由继承类根据类型而设置
function HandupState:setType(ttype)
	self.type = ttype	
end

function HandupState:getType()
	return self.type
end

function HandupState:onMessage()
	return false
end			