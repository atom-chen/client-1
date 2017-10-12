--[[
�����������������
]]

require("common.baseclass")

MonsterDeathHelper = MonsterDeathHelper or BaseClass()

function MonsterDeathHelper:__init()
	self.deathMonsterList = {}	-- ���Ϊ����״̬�Ĺ����б�
	self.willDeadId = 20000
end

function MonsterDeathHelper:__delete()
	self:clear()
end

function MonsterDeathHelper:clear()
	for k,v in pairs(self.deathMonsterList) do
		if v then
			v:leaveMap()
			v:DeleteMe()
			v = nil
		end
	end
end

-- ��ӽ�������״̬�Ĺ���
-- �����µ�id
function MonsterDeathHelper:addMonster(monsterId)
	-- ֻ��willDead״̬�Ĺ��������
	local entityManager = GameWorld.Instance:getEntityManager()
	local monsterObject = entityManager:getEntityObject(EntityType.EntityType_Monster, monsterId)
	if monsterObject and monsterObject:getState():isState(CharacterState.CharacterStateWillDead) then
		-- ��entityManager�����Ƴ��� �����ӳ��������Ƴ�
		local monsterList = entityManager:getEntityListByType(EntityType.EntityType_Monster)
		entityManager:remove(monsterList, monsterId)
		
		local newId = self:getWillDeadId()
		-- Ϊ�˺���ͨ�Ĺ��������֣������޸�monster��ID
		self.deathMonsterList[newId] = monsterObject
		monsterObject:setId(newId)
		return newId		
	else
		return monsterId
	end
end

-- �����������, ����ȥ����Monster
function MonsterDeathHelper:finishDeath(monsterId)
	if monsterId and self.deathMonsterList[monsterId] then
		-- ����entityManager��removeObject
		local hero = G_getHero()
		if  self.deathMonsterList[monsterId]:hasOwner() and  self.deathMonsterList[monsterId]:getOwnerId() == hero:getId() then
			hero:setPet(nil)
		end
		self.deathMonsterList[monsterId]:leaveMap()
		self.deathMonsterList[monsterId]:DeleteMe()
		self.deathMonsterList[monsterId] = nil
	end
end

-- 
function MonsterDeathHelper:getMonster(monsterId)
	return self.deathMonsterList[monsterId]
end

function MonsterDeathHelper:getWillDeadId()
	local id = "dead_monster_"..self.willDeadId
	self.willDeadId = self.willDeadId + 1
	return id
end