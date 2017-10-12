--[[
���ݵĲ��Ź�������
]]

require("common.baseclass")
require("object.skillShow.SkillShowDef")

AnimatePlayManager = AnimatePlayManager or BaseClass()

function AnimatePlayManager:__init()
	self.players = {}	--�����б�	
end

-- ����attacker��skillRef��������player������
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
			-- ��ʼ����
			if count <= SkillShowDef.MaxSpawnPlayCount then
				player:play()
				count = count + 1
			end
		elseif player:getState() == AnimatePlayerState.AnimatePlayerStateFinish then
			-- �Ƴ��Ѿ���ɵ�player
			player:DeleteMe()
			self.players[k] = nil
		else
			player:update(time)
		end
	end
end