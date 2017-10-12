--[[
处理怪物死亡的问题
]]

require("common.baseclass")

MonsterDeathHelper = MonsterDeathHelper or BaseClass()

function MonsterDeathHelper:__init()
	self.deathMonsterList = {}	-- 标记为死亡状态的怪物列表
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

-- 添加进入死亡状态的怪物
-- 返回新的id
function MonsterDeathHelper:addMonster(monsterId)
	-- 只有willDead状态的怪物才允许
	local entityManager = GameWorld.Instance:getEntityManager()
	local monsterObject = entityManager:getEntityObject(EntityType.EntityType_Monster, monsterId)
	if monsterObject and monsterObject:getState():isState(CharacterState.CharacterStateWillDead) then
		-- 从entityManager里面移除， 单不从场景里面移除
		local monsterList = entityManager:getEntityListByType(EntityType.EntityType_Monster)
		entityManager:remove(monsterList, monsterId)
		
		local newId = self:getWillDeadId()
		-- 为了和普通的怪物作区分，这里修改monster的ID
		self.deathMonsterList[newId] = monsterObject
		monsterObject:setId(newId)
		return newId		
	else
		return monsterId
	end
end

-- 死亡处理结束, 真正去销毁Monster
function MonsterDeathHelper:finishDeath(monsterId)
	if monsterId and self.deathMonsterList[monsterId] then
		-- 调用entityManager的removeObject
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