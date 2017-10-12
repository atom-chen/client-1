--[[
击退
]]

require "object.skillShow.player.AnimatePlayer"

CharacterActionHitBackPlayer = CharacterActionHitBackPlayer or BaseClass(AnimatePlayer)

function CharacterActionHitBackPlayer:__init()
	self.characterId = ""	-- fight character的id
	self.characterType = 0	-- fight character的类别
	self.actionId = EntityAction.eEntityAction_Hit	-- 播放的动作
	self.targetCellX = 0	-- 击飞的目标格子
	self.targetCellY = 0
	self.maxTime = 0.7			-- 击飞的时间
	self.isHero = false
	self.name = "CharacterActionHitBackPlayer"
end

function CharacterActionHitBackPlayer:__delete()
	
end

function CharacterActionHitBackPlayer:setCharacter(characterType, characterId)
	if characterType and characterId then
		self.characterId = characterId
		self.characterType = characterType
	end
end

function CharacterActionHitBackPlayer:setTargetCell(cellX, cellY)
	self.targetCellX = cellX
	self.targetCellY = cellY
end

function CharacterActionHitBackPlayer:setTime(time)
	self.time = time
end

function CharacterActionHitBackPlayer:setActionId(actionId)
	self.actionId = actionId
end

function CharacterActionHitBackPlayer:doPlay()
	local finishCallback = function ()
		self:onAnimateFinish()
	end
	
	local entityManager = GameWorld.Instance:getEntityManager()
	local characterObject = entityManager:getEntityObject(self.characterType, self.characterId)
	if not (characterObject and characterObject:DoShowHitBack(self.targetCellX, self.targetCellY, finishCallback) == true) then
		--[[characterObject:changeAction(self.actionId, true)
		
		local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(self.targetCellX, self.targetCellY)
		
		local actionArray = CCArray:create()
		actionArray:addObject(CCMoveTo:create(self.time, ccp(mapX, mapY)))
		actionArray:addObject(CCCallFunc:create(finishCallback))
		
		-- 移动模型
		characterObject:getRenderSprite():runAction(CCSequence:create(actionArray))
		
		-- 移动阴影
		characterObject:getShadow():runAction(CCMoveTo:create(self.time, ccp(mapX, mapY)))]]
		
		-- 没有找到对应的character, 设置动画为完成
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
	
	self.isHero = (self.characterId == entityManager:getHero():getId())
end

function CharacterActionHitBackPlayer:doStop()
	
end

function CharacterActionHitBackPlayer:onAnimateFinish()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject ~= nil then
		if self.characterType == EntityType.EntityType_Player then
			if characterObject:getHasMount() then
				characterObject:DoMountIdle()
			else
				characterObject:DoIdle()
			end
		else
			-- 怪物的idle和人物不同
			characterObject:DoIdle()
		end
		--[[if self.characterType == EntityType.EntityType_Monster then
			characterObject:changeAction(EntityAction.eEntityAction_Monster_Idle)
		else
			characterObject:changeAction(EntityAction.eEntityAction_Idle)
		end]]
	end
	
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function CharacterActionHitBackPlayer:update(time)
	if time == nil then
		return
	end
	if self.isHero then
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local mapX, mapY = hero:getMapXY()
		local centerY = hero:getCenterY()
		SFMapService:instance():getShareMap():setViewCenter(mapX, centerY)
		GlobalEventSystem:Fire(GameEvent.EventHeroMovement)
	end
end

