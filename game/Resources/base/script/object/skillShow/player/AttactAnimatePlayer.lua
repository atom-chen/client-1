
require "object.skillShow.player.AnimatePlayer"

AttactAnimatePlayer = AttactAnimatePlayer or BaseClass(AnimatePlayer)

function AttactAnimatePlayer:create()
	local player = AttactAnimatePlayer.New()		
	return player
end

function AttactAnimatePlayer:__init()
	self.name = "AttactAnimatePlayer"
	self.animateSpeed = 1.5
end

function AttactAnimatePlayer:init(render,attactType)
	self.render = render
	self.actionType = attactType
end

function AttactAnimatePlayer:__delete()
	
end

function AttactAnimatePlayer:setActionType(type)
	self.actionType = type
end

function AttactAnimatePlayer:setRenderSprite(render)
	self.render = render
end

function AttactAnimatePlayer:doPlay()
	local animateCallback = function (actionId, movementType)
		self:onAnimateCallback(actionId, movementType)
	end
	
	if self.render ~= nil then
			local speed = 1.5
			if self.animateSpeed > 0 then
				speed = self.animateSpeed
			end	
		 self.render:changeActionCallback(self.actionType,speed,true, animateCallback)			
	else
		-- 没有找到对应的character, 设置动画为完成
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function AttactAnimatePlayer:onAnimateCallback(actionId, movementType)
	if CharacterMovement.Finish == movementType or CharacterMovement.LoopFinish == movementType then
		if self.render then
			self.render:changeAction(EntityAction.eEntityAction_Idle,1,false)
		end
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	elseif CharacterMovement.Cancel == movementType then

		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end
