
require "object.skillShow.player.AnimatePlayer"

MoveAnimationPlayer = MoveAnimationPlayer or BaseClass(AnimatePlayer)

function MoveAnimationPlayer:create()
	local player = MoveAnimationPlayer.New()	
	return player
end

function MoveAnimationPlayer:init(render,duration,position)
	self.render = render
	self.duration = duration
	self.position = position
end

function MoveAnimationPlayer:__init()
	self.name = "MoveAnimationPlayer"
end

function MoveAnimationPlayer:__delete()
	
end

function MoveAnimationPlayer:setDuration(duration)
	self.duration = duration
end

function MoveAnimationPlayer:setPosition(position)
	self.position = position
end

function MoveAnimationPlayer:setRenderSprite(render)
	self.render = render
end

-- 播放的具体逻辑, 继承类重写这个方法
function MoveAnimationPlayer:doPlay()
	if self.render then
		local finish = function ()
			self.state = AnimatePlayerState.AnimatePlayerStateFinish
		end
		local moveBy = CCMoveBy:create(self.duration,self.position)
		local callback = CCCallFunc:create(finish)
		local sequence = CCSequence:createWithTwoActions(moveBy,callback)
		self.render:runAction(sequence)
	end
end