--[[
延时的player
]]

require "object.skillShow.player.AnimatePlayer"

DelayPlayer = DelayPlayer or BaseClass(AnimatePlayer)

function DelayPlayer:create(time)
	local player = DelayPlayer.New()
	player:setDelayTime(time)
	return player
end

function DelayPlayer:__init()
	self.delayTime = 0
	self.schedulerId = 0
	self.name = "DelayPlayer"
end

function DelayPlayer:__delete()
	
end

function DelayPlayer:setDelayTime(time)
	self.delayTime = time
end

-- 播放的具体逻辑, 继承类重写这个方法
function AnimatePlayer:doPlay()
	local timeFunc = function (dt)
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
	
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeFunc, self.delayTime, false)
end