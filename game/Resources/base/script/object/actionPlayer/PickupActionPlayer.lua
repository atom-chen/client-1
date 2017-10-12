require("common.baseclass")
require("object.actionPlayer.BaseActionPlayer")

PickupActionPlayer = PickupActionPlayer or BaseClass(BaseActionPlayer)

function PickupActionPlayer:__init()
	
end

function PickupActionPlayer:doPlay()
	local pickupMgr = GameWorld.Instance:getPickUpMnanager()
	pickupMgr:pickLootAroundXY()
	self:stopSucceed(0)
end