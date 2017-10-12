require("common.baseclass")
require("object.handup.FSM.HandupState")

PickupState = PickupState or BaseClass(HandupState)

--最大的拾取距离，单位为小格子
local const_maxPickupDis = 80
local const_reHandupPickupInterval = 50

function PickupState:__init()
	self:setType(E_HandupStateType.Pickup)	
	self.isStopWhenPickupFinished = false	
end

function PickupState:__delete()
	
end

--this will execute when the state is entered
--extraData:对于本状态，该数据为是否在拾取完后停止挂机
function PickupState:onEnter(extraData)
	local pickupMgr = GameWorld.Instance:getPickUpMnanager()
	pickupMgr:setRePickupInterval(const_reHandupPickupInterval)
	pickupMgr:clearAllLootNextPickTime()
	self.isStopWhenPickupFinished = extraData	
	self:loopPickup()
end

--拾取道具
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