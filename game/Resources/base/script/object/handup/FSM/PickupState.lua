require("common.baseclass")
require("object.handup.FSM.HandupState")

PickupState = PickupState or BaseClass(HandupState)

--����ʰȡ���룬��λΪС����
local const_maxPickupDis = 80
local const_reHandupPickupInterval = 50

function PickupState:__init()
	self:setType(E_HandupStateType.Pickup)	
	self.isStopWhenPickupFinished = false	
end

function PickupState:__delete()
	
end

--this will execute when the state is entered
--extraData:���ڱ�״̬��������Ϊ�Ƿ���ʰȡ���ֹͣ�һ�
function PickupState:onEnter(extraData)
	local pickupMgr = GameWorld.Instance:getPickUpMnanager()
	pickupMgr:setRePickupInterval(const_reHandupPickupInterval)
	pickupMgr:clearAllLootNextPickTime()
	self.isStopWhenPickupFinished = extraData	
	self:loopPickup()
end

--ʰȡ����
function PickupState:loopPickup()
	local pickupMgr = GameWorld.Instance:getPickUpMnanager()
	local target = pickupMgr:getClosestPickupTarget()
	if (target ~= nil) and (HandupCommonAPI:objDistance(G_getHero(), target) < const_maxPickupDis) then
		local onPickupFinished = function()
			if self.isRunning then
				self:loopPickup()
			end
		end
		pickupMgr:pickupItem(target, onPickupFinished)
	else
		self:finish()
	end
end

function PickupState:finish()
	if not self.isStopWhenPickupFinished then
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Search), HandupStatePriority.Normal)
	else
		self.mgr:stop()
	end
end

--this will execute when the state is exited. 
function PickupState:onExit()
	self.isStopWhenPickupFinished = false	
end	

function PickupState:onMessage(msg)
	return false
end