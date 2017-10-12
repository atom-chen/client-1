--[[
动画播放的基类
]]--

require "common.baseclass"

AnimatePlayerState = 
{
	AnimatePlayerStateWait = 0,
	AnimatePlayerStatePlaying = 1,
	AnimatePlayerStateFinish = 2
}

AnimatePlayer = AnimatePlayer or BaseClass()

function AnimatePlayer:__init()
	self.state = AnimatePlayerState.AnimatePlayerStateWait
	self.name = "AnimatePlayer"
	self.needRuntimeData = false
	self.time = 0
	self.animateSpeed = 1
	self.maxTime = 1.2
end

function AnimatePlayer:__delete()

end

function AnimatePlayer:setAnimateSpeed(speed)
	self.animateSpeed = speed
end

function AnimatePlayer:setMaxTime(time)
	if time and type(time) == "number" then
		self.maxTime = time
	end
end

function AnimatePlayer:getTime()
	return self.time
end

function AnimatePlayer:isNeedRuntimeData()
	return self.needRuntimeData
end

function AnimatePlayer:setNeedRuntimeData(needRuntimeData)
	self.needRuntimeData = needRuntimeData
end

function AnimatePlayer:getState()
	return self.state
end

-- 开始播放, 最好不要重写这个方法!
function AnimatePlayer:play()
	if self.state == AnimatePlayerState.AnimatePlayerStateWait then
		self.state = AnimatePlayerState.AnimatePlayerStatePlaying
		self:doPlay()
	end
end

-- 停止播放, 最好不要重写这个方法!
function AnimatePlayer:stop()
	if self.state == AnimatePlayerState.AnimatePlayerStatePlaying then
		self.state = AnimatePlayerState.AnimatePlayerStateWait
		self:doStop()
	end
end

-- 播放的具体逻辑, 继承类重写这个方法
function AnimatePlayer:doPlay()

end

-- 停止播放的具体逻辑, 继承类重写这个方法
function AnimatePlayer:doStop()

end

function AnimatePlayer:update(time)
	-- TODO: 临时解决AnimatePlayer缺少回调导致一直没有被设置为完成的BUG		
	if self.state == AnimatePlayerState.AnimatePlayerStatePlaying then
		self.time = self.time + time
		if self.time > self.maxTime then
			self.state = AnimatePlayerState.AnimatePlayerStateFinish
		end
	end
end

function AnimatePlayer:isMutilDir(skillRefId, animateGroup, modelId)
	local animateConfig = Config.Animate[skillRefId][animateGroup][modelId]
	if animateConfig then
		return animateConfig["DirType"] == 1
	else
		return false
	end
end