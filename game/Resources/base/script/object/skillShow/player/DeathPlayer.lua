--[[
死亡表演
]]

require("object.skillShow.player.AnimatePlayer")

DeathPlayer = DeathPlayer or BaseClass(AnimatePlayer)

function DeathPlayer:__init()
	self.effectId = 8011
	self.characterId = ""
	self.characterType = ""
	self.attackCellX = 0
	self.attackCellY = 0
end

function DeathPlayer:_delete()
	self:finish()
end

function DeathPlayer:finish()
	-- 通知entityManager真正的remove monster
	if self.characterType == EntityType.EntityType_Monster then
		local entityManager = GameWorld.Instance:getEntityManager()
		entityManager:getDeathHelper():finishDeath(self.characterId)		
	end
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function DeathPlayer:setEffectId(effectId)
	if effectId and type(effectId) == "number" then
		self.effectId = effectId
	end
end

function DeathPlayer:setCharacter(characterType, characterId)
	if characterId and characterType then
		self.characterId = characterId
		self.characterType = characterType
		
		-- 只有怪物有死亡表演
		if self.characterType == EntityType.EntityType_Monster then
			local entityManager = GameWorld.Instance:getEntityManager()
			self.characterId = entityManager:getDeathHelper():addMonster(self.characterId)
		end
	end
end

function DeathPlayer:setAttackPos(cellX, cellY)
	if cellX and cellY then
		self.attackCellX = cellX
		self.attackCellY = cellY
	end
end

function DeathPlayer:doPlay()
	local entityManager = GameWorld.Instance:getEntityManager()
	if self.characterType == EntityType.EntityType_Monster then
		local characterObject = entityManager:getDeathHelper():getMonster(self.characterId)
		if characterObject then
			local flyCallback = function ()
				characterObject:DoDeath(self.effectId)
				self:finish()
			end
			
			-- 根据攻击者的坐标计算弹开的坐标
			local attackMapX, attackMapY = GameWorld.Instance:getMapManager():cellToMap(self.attackCellX, self.attackCellY)
			local srcMapX, srcMapY = characterObject:getMapXY()
			
			local attackPos = ccp(attackMapX, attackMapY)
			local srcPos = ccp(srcMapX, srcMapY)
			
			local normalizePos = ccpNormalize(ccpSub(srcPos, attackPos))
			local destPos = ccpAdd(srcPos, ccpMult(normalizePos, 100))
			
			characterObject:showHitFly(destPos.x, destPos.y, 0.5, flyCallback)
		else
			self:finish()
		end
	else
		local characterObject = entityManager:getEntityObject(self.characterType, self.characterId)
		
		-- 有可能玩家已经复活了，要检查是否在willDeath状态
		if characterObject and characterObject:getState():isState(CharacterState.CharacterStateWillDead) then
			characterObject:DoDeath(self.effectId)
		end
		
		self:finish()
	end
end