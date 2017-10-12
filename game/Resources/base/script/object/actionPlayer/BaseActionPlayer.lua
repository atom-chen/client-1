--[[
行为播放的播放
]]--

require "common.baseclass"

ActionType = {
	ActionTypeNormal = 0,
	ActionTypeAttack = 1,
	ActionTypeBeHit = 2
}

E_ActionPlayerState = 
{
	Waiting = 0,
	Playing = 1,
	Finished = 2
}

--行为停止的原因
E_ActionStopReason = 
{
	Normal = "Normal",				--正常运行结束
	Timeout = "Timeout",			--超时结束
	Delete = "Delete",				--被删除掉
	Fail = "Fail",					--运行失败
	Cancel = "Cancel",				--运行取消
}

BaseActionPlayer = BaseActionPlayer or BaseClass()

function BaseActionPlayer:__init()
	self.des = "BaseActionPlayer"
	self.maxPlayingDuration = -1 	--播放持续的最大时长。从播放开始后计时，如果超过该时间还没有停止，则自动停止。
									--为-1代表播放持续时间不限
									
	self.playingDuration = 0 	 	--已经播放时间
	self.stopReason = Normal		--停止的原因
	self.state = E_ActionPlayerState.Waiting	--当前状态
	self.isDelayStop = false
	
	self.stopNotifyList = {}
end

function BaseActionPlayer:__delete()
	self.state = E_ActionPlayerState.Finished
	self:stop(E_ActionStopReason.Delete)	
	self.id = -1
end

function BaseActionPlayer:setId(id)
	self.id = id
end

function BaseActionPlayer:getId()
	return self.id
end

function BaseActionPlayer:isPlaying()
	return self.state == E_ActionPlayerState.Playing
end

function BaseActionPlayer:setStopReason(reason)
	self.stopReason = reason
end

function BaseActionPlayer:getStopReason()
	return self.stopReason
end

--获取最大的播放持续时间
function BaseActionPlayer:getMaxPlayingDuration()
	return self.maxPlayingDuration
end

--设置最大的播放持续时间
function BaseActionPlayer:setMaxPlayingDuration(maxPlayingDuration)
	self.maxPlayingDuration = maxPlayingDuration
	self.playingDuration = 0
end	

--获取已经播放的持续时间
function BaseActionPlayer:getPlayingDuration()
	return self.playingDuration
end	

--获取描述
function BaseActionPlayer:getDes()
	return self.des
end

--设置描述
function BaseActionPlayer:setDes(des)
	self.des = des
end	

--设置状态
function BaseActionPlayer:getState()
	return self.state
end

--设置状态
function BaseActionPlayer:setState(state)
	self.state = state
end

-- 播放的具体逻辑, 继承类可重写这个方法
function BaseActionPlayer:doPlay()

end

-- 停止播放的具体逻辑, 继承类重可写这个方法
function BaseActionPlayer:doStop()

end

-- 每帧更新，继承类可重写这个方法
function BaseActionPlayer:doUpdate(time)
	
end	

-- 设置开始播放时的回调函数
function BaseActionPlayer:setPlayingNotify(ffunc, aarg)
	self.playingNotify = {func = ffunc, arg = aarg}
end

-- 设置停止播放时的回调函数
function BaseActionPlayer:addStopNotify(func, arg)
	table.insert(self.stopNotifyList, {func = func, arg = arg})
end	

-- 开始播放, 不要重载此函数
function BaseActionPlayer:play()
	if self.state == E_ActionPlayerState.Waiting then
		self.state = E_ActionPlayerState.Playing
		self:doPlay()
		self.playingDuration = 0
		if (self.playingNotify) then
			self.playingNotify.func(self, arg)
		end
	end
end

-- 停止播放, 不要重载此函数
function BaseActionPlayer:stop(stopReason)
	if stopReason then
		self.stopReason = stopReason		
	end
	
	if self.state == E_ActionPlayerState.Playing then
		self.playingDuration = 0
		self.state = E_ActionPlayerState.Finished
		for k, v in pairs(self.stopNotifyList) do
			v.func(self, v.arg)
		end
		self:doStop()
	end	
	self.state = E_ActionPlayerState.Finished
end	

-- 不要重载此函数。在播放过程中，每帧调用
function BaseActionPlayer:update(time)
	if (self.state == E_ActionPlayerState.Playing) then	
		self.playingDuration = self.playingDuration + time
		if (self.maxPlayingDuration >= 0 and self.playingDuration > self.maxPlayingDuration) then	--超时结束
			if self.isDelayStop then
				self:stop()
			else
				self:stop(E_ActionStopReason.Timeout)
			end
		end
	end
	self:doUpdate(time)
end		

function BaseActionPlayer:stopSucceed(delay)
	
	if delay == nil then
		delay = 0
	end
	if delay < 0 then
		self:stop(E_ActionStopReason.Normal)
	else
		self:setStopReason(E_ActionStopReason.Normal)
		self:setMaxPlayingDuration(delay)
		self.isDelayStop = true
	end
end

function BaseActionPlayer:stopCanceled(delay)
	
	if delay == nil then
		delay = 0
	end
	if delay < 0 then
		self:stop(E_ActionStopReason.Cancel)
	else
		self:setStopReason(E_ActionStopReason.Cancel)
		self:setMaxPlayingDuration(delay)
		self.isDelayStop = true
	end		
end

function BaseActionPlayer:stopFailed(delay)
	
	if delay == nil then
		delay = 0
	end
	if delay < 0 then
		self:stop(E_ActionStopReason.Fail)
	else
		self:setStopReason(E_ActionStopReason.Fail)
		self:setMaxPlayingDuration(delay)
		self.isDelayStop = true
	end		
end