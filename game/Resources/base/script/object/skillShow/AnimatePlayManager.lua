--[[
表演的播放管理中心
]]

require("common.baseclass")
require("object.skillShow.SkillShowDef")

AnimatePlayManager = AnimatePlayManager or BaseClass()

function AnimatePlayManager:__init()
	self.players = {}	--播放列表	
end

-- 保存attacker和skillRef是用来做player的索引
function AnimatePlayManager:addPlayer(attacker, skillRef, player)
	local playerInfo = {}
	playerInfo["attacker"] = attacker
	playerInfo["skillRef"] = skillRef
	playerInfo["player"] = player
	table.insert(self.players, playerInfo)
end

function AnimatePlayManager:stopPlayer(player)
	
end

function AnimatePlayManager:removePlayer(player)

end

function AnimatePlayManager:getPlayer(attacker, skillRef)
	local player = nil 
	for k,v in pairs(self.players) do
		if v["attacker"] == attacker and v["skillRef"] == skillRef then
			player = v["player"]
			break
		end
	end
	
	return player
end

function AnimatePlayManager:stopAll()
	for k,v in pairs(self.players) do
		v:stop()
	end
end

function AnimatePlayManager:removeAll()
	for k,v in pairs(self.players) do
		if v and v["player"] then
			v["player"]:stop()
			v["player"]:DeleteMe()
			self.players[k] = nil
		end
	end
end

function AnimatePlayManager:update(time)
	local count = 0
	for k,v in pairs(self.players) do
		local player = v["player"]
		
		if player:getState() == AnimatePlayerState.AnimatePlayerStateWait then
			-- 开始播放
			if count <= SkillShowDef.MaxSpawnPlayCount then
				player:play()
				count = count + 1
			end
		elseif player:getState() == AnimatePlayerState.AnimatePlayerStateFinish then
			-- 移除已经完成的player
			player:DeleteMe()
			self.players[k] = nil
		else
			player:update(time)
		end
	end
end