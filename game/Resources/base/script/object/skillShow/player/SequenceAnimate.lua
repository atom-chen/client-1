--[[
Author: Liu Rui
顺序动画队列
]]--

require "object.skillShow.player.AnimatePlayer"

SequenceAnimate = SequenceAnimate or BaseClass(AnimatePlayer)

function SequenceAnimate:__init()
	self.players = {}
	self.name = "SequenceAnimate"
end

function SequenceAnimate:__delete()
	for k,v in pairs(self.players) do
		v:DeleteMe()
		self.players[k] = nil
	end
end

function SequenceAnimate:create(animatePlayer)
	local player = SequenceAnimate.New()
	player:addPlayer(animatePlayer)
	return player
end

function SequenceAnimate:createWithList(animatePlayer)
	if animatePlayer then
		local player = SequenceAnimate.New()
		player:addPlayerList(animatePlayer)
		return player
	end
end

function SequenceAnimate:addPlayerList(playerList)
	if playerList then
		for k,v in pairs(playerList) do
			table.insert(self.players, v)
		end	
	end
end

function SequenceAnimate:addPlayer(animatePlayer)
	table.insert(self.players, animatePlayer)	
end

function SequenceAnimate:update(time)
	local bPlayNext = false
	local bAllFinish = true	
	if self.state == AnimatePlayerState.AnimatePlayerStatePlaying then
		for k,v in pairs(self.players) do
			if v:getState() == AnimatePlayerState.AnimatePlayerStateWait then
				v:play()
				break
			end
			
			if v ~= nil and v:getState() == AnimatePlayerState.AnimatePlayerStateFinish then			
				bPlayNext = true
				v:DeleteMe()
				self.players[k] = nil
			elseif v ~= nil then
				bAllFinish = false
				v:update(time)
				break
			end
		end
		
		if bPlayNext == false and bAllFinish == true then
			self.state = AnimatePlayerState.AnimatePlayerStateFinish
		end
	end
end

function SequenceAnimate:clear()

end

function SequenceAnimate:doPlay()
	-- 开始播放第一个player
	for k,v in pairs(self.players) do
		v:play()
		break
	end
end

function SequenceAnimate:doStop()

end