--[[
管理boss的归属权和相关数据
]]

EntityFocusManager = EntityFocusManager or BaseClass()

function EntityFocusManager:__init()
	self.ownerList = {}
	self.focusEntityId = ""
	self.focusEntityType = ""
	self.showBossTips = true
	self.bFocusBoss = false
	self.heroId = ""
	self.scheduleId = 0
	self.playerScheduleId = 0
	local function entityFocus(entityType, entityId)	
		local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(entityType, entityId)
		if entityObject and self.focusEntityId and self.focusEntityId ~= entityId  then
			-- 如果是死亡状态就不给选中
			if self:isEntityDead(entityObject) then
				UIManager.Instance:showSystemTips(Config.Words[200])	
			else
				-- 如果怪物是空血的话，告诉服务器这个怪有问题
				if entityType == EntityType.EntityType_Monster  and PropertyDictionary:get_HP(entityObject:getPT()) == 0 then
					self:sendMonsterError(entityId)
					self:requestFindCharacter(entityType, entityId)
				end
				
				self:onFocusRemove()
				self.showBossTips = true
				self:onEntityFocus(entityObject)
			end
		end
	end
	
	local function entityRemove(entityObj)
		if entityObj and entityObj:getId() == self.focusEntityId and entityObj:getEntityType() == self.focusEntityType then
			-- focus的怪物已经失去焦点
			self:onFocusRemove()
			self:setBossOwner(self.focusEntityId,nil)
			self.showBossTips = true
		end
	end
	
	self.touchEvent = GlobalEventSystem:Bind(GameEvent.EVENT_ENTITY_TOUCH_OBJECT,entityFocus)
	self.entityRemoveEvent = GlobalEventSystem:Bind(GameEvent.EventEntityRemoved,entityRemove)
end

function EntityFocusManager:sendMonsterError(monsterId)
	if monsterId then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Monster_ClearError)
		StreamDataAdapter:WriteStr(writer, monsterId)
		simulator:sendTcpActionEventInLua(writer)	
	end
end

function EntityFocusManager:clearFocus()
	self:onFocusRemove()
end

function EntityFocusManager:isEntityDead(entityObject)
	if entityObject and (entityObject:getEntityType() == EntityType.EntityType_Monster or entityObject:getEntityType() == EntityType.EntityType_Player
		or entityObject:getEntityType() == EntityType.EntityType_PlayerAvatar) and 
		(entityObject:getState():isState(CharacterState.CharacterStateDead) or entityObject:getState():isState(CharacterState.CharacterStateWillDead)) then
		return true
	else
		return false
	end
end

function EntityFocusManager:__delete()
	if self.touchEvent then
		GlobalEventSystem:UnBind(self.touchEvent)
		self.touchEvent = nil
	end
	
	if self.entityRemoveEvent then
		GlobalEventSystem:UnBind(self.entityRemoveEvent)
		self.entityRemoveEvent = nil
	end	
	
	self.ownerList = nil
	self:endBossOwnerSchedule()
	self:endPlayerAttributeSchedule()
end

function EntityFocusManager:clear()
	self.focusEntityId = ""
	self.focusEntityType = ""	
	self:endBossOwnerSchedule()
	self:endPlayerAttributeSchedule()	
end

-- 获取当前的焦点的EntityObject
function EntityFocusManager:getFoucsEntity()
	return self.focusEntityType, self.focusEntityId
end

-- 请求怪物归属权
function EntityFocusManager:requestBossOwner(monsterId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Monster_OwnerTransfer)
	StreamDataAdapter:WriteStr(writer, monsterId)
	simulator:sendTcpActionEventInLua(writer)
end

function EntityFocusManager:setBossOwner(bossId, ownerId)
	local oldOwner = self.ownerList[bossId]
	self.ownerList[bossId] = ownerId
	
	if oldOwner ~= ownerId then
		if self.showBossTips == true then
			self:showBossOwnerTips()	
			self:resetShowTipsCount()		
		end			
		GlobalEventSystem:Fire(GameEvent.EventBossOwnerChange, bossId, ownerId)
	end
end

function EntityFocusManager:getBossOwner(bossId)
	return self.ownerList[bossId]
end

function EntityFocusManager:onEntityFocus(entityObject)
	if entityObject then
		local ret = true
		if entityObject:getEntityType() == EntityType.EntityType_Monster then	
			--entityObject:setTitleVisible(true)
			ret = self:onFocusMonster(entityObject)
		elseif entityObject:getId() ~= self.heroId and (entityObject:getEntityType() == EntityType.EntityType_PlayerAvatar or entityObject:getEntityType() == EntityType.EntityType_Player) then
			ret = self:onFocusPlayer(entityObject)
		end
		
		if ret then
			self.focusEntityId = entityObject:getId()
			self.focusEntityType = entityObject:getEntityType()
			--entityObject:setSelectEffect(true)
			-- 分发获取焦点的事件
			GlobalEventSystem:Fire(GameEvent.Event_Entity_Get_Focus, self.focusEntityType, self.focusEntityId)
		end
	end
end

function EntityFocusManager:onFocusMonster(entityObject)
	
	if entityObject then
		local targetRefId = entityObject:getRefId()
		if not GameData.Monster[targetRefId] then
			return false
		end
		
		local entityManager = GameWorld.Instance:getEntityManager()
		local name = entityManager:getMonsterName(targetRefId)
		local level = entityManager:getMonsterLevel(targetRefId)
		if  not entityManager:IsPlayerMonster(entityObject:getRefId()) then	
			if name and level then
				if entityObject:hasOwner() then	--如果是召唤兽
					local ownerId = entityObject:getOwnerId()
					local entityManager = GameWorld.Instance:getEntityManager()	
					local player = entityManager:getEntityObject(EntityType.EntityType_Player,ownerId)
					if player then
						local ownerName = PropertyDictionary:get_name(player:getPT())
						entityObject:setTitleName("("..ownerName..")"..name.." lv."..level)
					end
				else
					entityObject:setTitleName(name.." lv."..level)
				end
				
				local pt = entityObject:getPT()
				local unionName = PropertyDictionary:get_unionName(pt)	
				if unionName then
					entityObject:setUnionName(unionName)
				end
			end
		end
		
		entityObject:compareHP()	
		entityObject:setSelectEffect(true)
		
		local quantity = PropertyDictionary:get_quality(GameData.Monster[targetRefId].property)
		local isBoss = (quantity == EntityMonsterType.EntityMonster_Boss)
		
		local entityId = entityObject:getId()
		if isBoss then
			GlobalEventSystem:Fire(GameEvent.EventMainIsShowBossView, true, entityId)
			entityManager:setBossId(entityId)
		elseif self.bFocusBoss then
			GlobalEventSystem:Fire(GameEvent.EventMainIsShowBossView, false, entityId)
		end
		
		self.focusEntityId = entityId
		self.focusEntityType = entityObject:getEntityType()
		self.bFocusBoss = (quantity == EntityMonsterType.EntityMonster_Boss)
		
		if self.bFocusBoss then
			self:requestBossOwner(self.focusEntityId)
			self:startBossOwnerSchedule()
		end
		
		return true
	else
		return false
	end
end

function EntityFocusManager:onFocusPlayer(entityObject)
	entityObject:setHPEffect(true)
	if entityObject then
		local playerHP = PropertyDictionary:get_HP(entityObject:getPT())
		local playerId = entityObject:getId()
		
		if not playerId then
			return false
		end
		self:startPlayerAttributeSchedule(playerId)	
		GlobalEventSystem:Fire(GameEvent.EventShowPlayerHead, entityObject, true)
		
		return true
	else
		return false
	end
end

function EntityFocusManager:onFocusRemove()
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.focusEntityType, self.focusEntityId)
	if entityObject then
		if entityObject:getEntityType() == EntityType.EntityType_Monster then
			if not entityObject:isBoss() and 
				not (entityObject:isElite() and not entityObject:hasOwner()) and
				not entityObject:isHeroPet() then
				-- TODO: 封装成API
				local entityManager = GameWorld.Instance:getEntityManager()
				if not entityManager:IsPlayerMonster(entityObject:getRefId()) then
					GameWorld.Instance:getTextManager():removeTilte(entityObject:getId())	
				end
			end
			entityObject:setSelectEffect(false)
			entityObject:compareHP()	
		elseif self.focusEntityId ~= self.heroId and (self.focusEntityType == EntityType.EntityType_PlayerAvatar or self.focusEntityType == EntityType.EntityType_Player) then
			entityObject:setHPEffect(false)
		end
	end
	
	if self.bFocusBoss then
		self:endBossOwnerSchedule()
		GlobalEventSystem:Fire(GameEvent.EventMainIsShowBossView, false, self.focusEntityId)
	end
	if entityObject and entityObject:getEntityType() == EntityType.EntityType_Player then
		GlobalEventSystem:Fire(GameEvent.EventShowPlayerHead, entityObject, false)
	end
	
	-- 分发失去焦点的协议
	if self.focusEntityId ~= "" and self.focusEntityType ~= "" then
		GlobalEventSystem:Fire(GameEvent.Event_Entity_Lost_Focus, self.focusEntityType, self.focusEntityId)
	end
	
	self.focusEntityId = ""
	self.focusEntityType = ""
	self.bFocusBoss = false	
	self:endPlayerAttributeSchedule()
end

function EntityFocusManager:startPlayerAttributeSchedule(playerId)
	self:endPlayerAttributeSchedule()
	if 0 == self.playerScheduleId then
		local function onScheduleCallback()
			if playerId then
				--请求选中玩家的属性
				local focusPlayer = GameWorld.Instance:getEntityManager():getEntityObject( EntityType.EntityType_Player, playerId)
				
				--death和willDeath状态都不再去更新玩家的血量
				if focusPlayer and not focusPlayer:getState():isState(CharacterState.CharacterStateDead) 
					and not focusPlayer:getState():isState(CharacterState.CharacterStateWillDead)  then
					self:requestPlayerHP(playerId)
				end	
			end
		end
		
		self.playerScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleCallback, 2, false)	
	end
	
end

function EntityFocusManager:requestPlayerHP(playerId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OtherPlayer_Simple_Attribute)
	StreamDataAdapter:WriteStr(writer, playerId)
	simulator:sendTcpActionEventInLua(writer)
end
function EntityFocusManager:endPlayerAttributeSchedule()
	if 0 ~= self.playerScheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.playerScheduleId)
		self.playerScheduleId = 0
		CCLuaLog("playerScheduleId"..self.playerScheduleId)
	end
end

function EntityFocusManager:startBossOwnerSchedule()
	if 0 == self.scheduleId then
		self.count = 0
		local function onScheduleCallback()
			if self.bFocusBoss then
				-- 只有boss才请求归属权
				self:requestBossOwner(self.focusEntityId)
				self.count = self.count+1
				if self.count%4 == 0 then	--8s播报一次			
					self:showBossOwnerTips()
					self.count = 0
				end
			end
		end
		
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleCallback, 2, false)	
	end
end

function EntityFocusManager:resetShowTipsCount()
	if self.count then
		self.count = 0
	end
end
function EntityFocusManager:endBossOwnerSchedule()
	if 0 ~= self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 0		
	end
end

function EntityFocusManager:showBossOwnerTips()
	local ownerId = self:getBossOwner(self.focusEntityId)
	local entityManager = GameWorld.Instance:getEntityManager()	
	local bossObj = entityManager:getEntityObject(EntityType.EntityType_Monster,self.focusEntityId)
	if bossObj == nil then 
		return
	end
	
	local bossName = entityManager:getMonsterName(bossObj:getRefId())
	if ownerId then
		local ownerObj = entityManager:getEntityObject(EntityType.EntityType_Player,ownerId)
		if ownerObj then
			local ownerName = PropertyDictionary:get_name(ownerObj:getPT())							
			if ownerName then
				local tips = string.format("[%s]%s[%s]",bossName,Config.Words[15023],ownerName)
				UIManager.Instance:showSystemTips(tips)										
			end
		else
			local tips = string.format("[%s]%s",bossName,Config.Words[15024])
			UIManager.Instance:showSystemTips(tips)
		end
	else
		local tips = string.format("[%s]%s",bossName,Config.Words[15024])
		UIManager.Instance:showSystemTips(tips)
	end		
end

-- 这个协议找不到地方存，先放这里
function EntityFocusManager:requestFindCharacter(characterType, characterId)
	if characterType and characterId then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_FindSprite)
		StreamDataAdapter:WriteChar(writer, characterType)
		StreamDataAdapter:WriteStr(writer, characterId)
		simulator:sendTcpActionEventInLua(writer)
	end
end