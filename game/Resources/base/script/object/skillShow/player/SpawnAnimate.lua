--[[
Author: Liu Rui
同步动画队列
]]--

local maxCount = 3

require "object.skillShow.player.AnimatePlayer"

SpawnAnimate = SpawnAnimate or BaseClass(AnimatePlayer)

function SpawnAnimate:__init()
	self.players = {}
	self.name = "SpawnAnimate"
	self.playCount = 0
end

function SpawnAnimate:__delete()
	for k,v in pairs(self.players) do
		v:DeleteMe()
		self.players[k] = nil
	end
end

function SpawnAnimate:create(animatePlayer)
	local player = SpawnAnimate.New()
	player:addPlayer(animatePlayer)
	return player
end

function SpawnAnimate:createWithList(animatePlayer)
	local player = SpawnAnimate.New()
	if animatePlayer then
		player:addPlayerList(animatePlayer)
	end
	return player
end

function SpawnAnimate:addPlayerList(playerList)
	if playerList then
		for k,v in pairs(playerList) do
			table.insert(self.players, v)
		end
	end
end

function SpawnAnimate:addPlayer(animatePlayer)
	table.insert(self.players, animatePlayer)
end

function SpawnAnimate:update(time)
	local bFinish = true
	
	local count = 0
	for k,v in pairs(self.players) do
		if v then
			local playerState = v:getState()
			if playerState == AnimatePlayerState.AnimatePlayerStatePlaying then
				v:update(time)
			elseif playerState == AnimatePlayerState.AnimatePlayerStateWait then
				-- 每tick最多播放maxCount个player
				if count <= maxCount then	
					v:play()
					count = count + 1
				end
			end
			
			if v:getState() ~= AnimatePlayerState.AnimatePlayerStateFinish then
				-- 移除已经完成的player
				bFinish = false
			end
		end
	end
	
	if bFinish then
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function SpawnAnimate:clear()
	
end

function SpawnAnimate:doPlay()
	local count = 0
	for k,v in pairs(self.players) do
		if count >= maxCount then
			-- 每帧播放的player已经达到最大次数
			break
		end
		if v then
			if v:getState() == AnimatePlayerState.AnimatePlayerStateWait then
				-- 开始播放
				v:play()
				count = count + 1
			end
		end
	end
end

function SpawnAnimate:doStop()
	
end