--[[
��Ϊ���Ź���
]]

require("common.baseclass")

ActionPlayerMgr = ActionPlayerMgr or BaseClass()

local const_defaultGroup = "General"

function ActionPlayerMgr:__init()
	self.players = 	--�����б�Ϊ1-n����������
	{
		[const_defaultGroup] = {},
	}	
	ActionPlayerMgr.Instance = self
	
	self.palyerIdCount = 0
end

function ActionPlayerMgr:__delete()
	self:removeAll()
	self.players = nil
end

function ActionPlayerMgr:clear()
	self:removeAll()
end

function ActionPlayerMgr:addPlayer(group, player)
	if type(group) ~= "string" or group == "" then
		group = const_defaultGroup
	end
	if (player == nil or player.play == nil) then
		print("ActionPlayerMgr:addPlayer failed. player == nil or player.play == nil")
		return
	end
	
	self.palyerIdCount = self.palyerIdCount + 1
	player:setId(self.palyerIdCount)	
	
	if self.players[group] == nil then
		self.players[group] = {}
	end
	
	table.insert(self.players[group], player)	
--	print("ActionPlayerMgr:addPlayer group ="..group.." count="..table.size(self.players[group]))
	return self.palyerIdCount
end		

--����һ��player
function ActionPlayerMgr:insertPlayer(group, posPlayer, player)
	if type(group) ~= "string" or group == "" then
		group = const_defaultGroup
	end
	if (player == nil or player.play == nil or posPlayer == nil) then
		print("ActionPlayerMgr:addPlayer failed. player == nil or player.play == nil or posPlayer == nil")
		return nil
	end
		
	if self.players[group] == nil then
		return nil
	end
	
	local index 
	for k, v in pairs(self.players) do
		for kk, vv in pairs(v) do
			if (vv == posPlayer) then
				index = kk
				break
			end
		end
		if index then
			break
		end
	end	
	if index then
		self.palyerIdCount = self.palyerIdCount + 1
		player:setId(self.palyerIdCount)	
		table.insert(self.players[group], index, player)	
--		print("ActionPlayerMgr:insertPlayer group ="..group.." count="..table.size(self.players[group]))	
		return self.palyerIdCount
	end
	return nil
end		

function ActionPlayerMgr:hasPlayer(playerId)
	if not playerId then
		return false
	end
	for k, v in pairs(self.players) do
		for kk, vv in pairs(v) do
			if (vv:getId() == playerId) then
				return true		
			end
		end
	end	
	return false
end

--��ȡ����player
--[[
self.players = 	--�����б�Ϊ1-n����������
{
	[const_defaultGroup] = {},
}	
--]]
function ActionPlayerMgr:getPlayerList()
	return self.players
end	

function ActionPlayerMgr:getPlayersByGroup(group)
	if type(group) ~= "string" or group == "" then
		return nil
	end
	return self.players[group]
end

function ActionPlayerMgr:getPlayerById(playerId)
	local removeIndex = nil
	for k, v in pairs(self.players) do
		for kk, vv in pairs(v) do
			if (vv:getId() == playerId) then
				return vv
			end
		end
	end		
	return nil
end

--ɾ������player
function ActionPlayerMgr:removeAll()
	for k, v in pairs(self.players) do	
		for kk, vv in pairs(v) do	
			vv:DeleteMe()			
		end
	end
	self.players = {[const_defaultGroup] = {},}
	--print("ActionPlayerMgr:removeAll")
end

--ɾ��ĳ����������player
function ActionPlayerMgr:removePlayersByGroup(group)
	if type(group) ~= "string" or group == "" or (self.players[group] == nil) then
		return
	end
--	--print("ActionPlayerMgr:removePlayersByGroup")	
	for k, v in pairs(self.players[group]) do
		v:stop()
		v:DeleteMe()
	end
	self.players[group] = nil
end	

function ActionPlayerMgr:removePlayersExceptGroup(group)
	for k, v in pairs(self.players) do
		if k ~= group then
			for kk, vv in pairs(v) do
				vv:DeleteMe()
			end
			self.players[k] = {}
		end
	end		
end	

--����Id��ɾ��Ψһָ����player
function ActionPlayerMgr:removePlayerById(playerId)
	local removeIndex = nil	
	local group
	local player
	for k, v in pairs(self.players) do
		for kk, vv in pairs(v) do
			if (vv:getId() == playerId) then
				group = k
				removeIndex = kk
				player = vv
				break
			end
		end
		if group ~= nil then
			break
		end
	end		
	if (removeIndex and player and group) then	
		player:DeleteMe()				
		--ʹ��remove����֤self.playersΪ�������顣�˲��������ڱ��������н��С�
		table.remove(self.players[group], removeIndex)	
	end
end
--[[
E_ActionPlayerState = 
{
	Waiting = 0,
	Playing = 1,
	Finished = 2
}
--]]
function ActionPlayerMgr:update(time)
	for k, v in pairs(self.players) do
		local first = v[1] 		--����������һ��player
		if (first) then
			local state = first:getState()
			if (state == E_ActionPlayerState.Waiting) then --��ʼ����
				first:play()
			elseif (state == E_ActionPlayerState.Playing) then	--update���ڲ����е�player
				first:update(time)
			else		--E_ActionPlayerState.Finished	--����״̬��ɾ����
				first:DeleteMe()
				table.remove(v, 1) 	--ʹ��remove����֤self.playersΪ��������
			end
		end
	end
end	