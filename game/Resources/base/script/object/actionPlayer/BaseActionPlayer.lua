--[[
��Ϊ���ŵĲ���
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

--��Ϊֹͣ��ԭ��
E_ActionStopReason = 
{
	Normal = "Normal",				--�������н���
	Timeout = "Timeout",			--��ʱ����
	Delete = "Delete",				--��ɾ����
	Fail = "Fail",					--����ʧ��
	Cancel = "Cancel",				--����ȡ��
}

BaseActionPlayer = BaseActionPlayer or BaseClass()

function BaseActionPlayer:__init()
	self.des = "BaseActionPlayer"
	self.maxPlayingDuration = -1 	--���ų��������ʱ�����Ӳ��ſ�ʼ���ʱ�����������ʱ�仹û��ֹͣ�����Զ�ֹͣ��
									--Ϊ-1�����ų���ʱ�䲻��
									
	self.playingDuration = 0 	 	--�Ѿ�����ʱ��
	self.stopReason = Normal		--ֹͣ��ԭ��
	self.state = E_ActionPlayerState.Waiting	--��ǰ״̬
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

--��ȡ���Ĳ��ų���ʱ��
function BaseActionPlayer:getMaxPlayingDuration()
	return self.maxPlayingDuration
end

--�������Ĳ��ų���ʱ��
function BaseActionPlayer:setMaxPlayingDuration(maxPlayingDuration)
	self.maxPlayingDuration = maxPlayingDuration
	self.playingDuration = 0
end	

--��ȡ�Ѿ����ŵĳ���ʱ��
function BaseActionPlayer:getPlayingDuration()
	return self.playingDuration
end	

--��ȡ����
function BaseActionPlayer:getDes()
	return self.des
end

--��������
function BaseActionPlayer:setDes(des)
	self.des = des
end	

--����״̬
function BaseActionPlayer:getState()
	return self.state
end

--����״̬
function BaseActionPlayer:setState(state)
	self.state = state
end

-- ���ŵľ����߼�, �̳������д�������
function BaseActionPlayer:doPlay()

end

-- ֹͣ���ŵľ����߼�, �̳����ؿ�д�������
function BaseActionPlayer:doStop()

end

-- ÿ֡���£��̳������д�������
function BaseActionPlayer:doUpdate(time)
	
end	

-- ���ÿ�ʼ����ʱ�Ļص�����
function BaseActionPlayer:setPlayingNotify(ffunc, aarg)
	self.playingNotify = {func = ffunc, arg = aarg}
end

-- ����ֹͣ����ʱ�Ļص�����
function BaseActionPlayer:addStopNotify(func, arg)
	table.insert(self.stopNotifyList, {func = func, arg = arg})
end	

-- ��ʼ����, ��Ҫ���ش˺���
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

-- ֹͣ����, ��Ҫ���ش˺���
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

-- ��Ҫ���ش˺������ڲ��Ź����У�ÿ֡����
function BaseActionPlayer:update(time)
	if (self.state == E_ActionPlayerState.Playing) then	
		self.playingDuration = self.playingDuration + time
		if (self.maxPlayingDuration >= 0 and self.playingDuration > self.maxPlayingDuration) then	--��ʱ����
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