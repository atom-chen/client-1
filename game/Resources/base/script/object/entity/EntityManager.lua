--[[
EntityObject的管理类
]]--
require("data.npc.npc")
require("common.baseclass")
require("object.entity.SafeRegionObject")
require("object.entity.MonsterDeathHelper")
require("data.monster.monster")
require("data.monster.playerMonster")
require("data.npc.collect")
require("object.entity.NPCObject")
require("object.entity.MonsterObject")
require("object.entity.PlayerMonsterObject")
require("object.entity.LootObject")
require("object.entity.FireWallObject")
require("object.entity.EffectObject")
require("object.actionPlayer.ActionPlayerMgr")
require("object.entity.HeroObject")
require("config.DefaultConfig")
EntityManager = EntityManager or BaseClass()

function EntityManager:__init()
	--初始化列表
	self.monsterList = {}
	self.npcList = {}
	self.playerList = {}
	self.petList = {}
	--self.npcList = {}
	self.effectList = {}
	self.lootList = {}
	self.lootCellList = {}
	self.lootRecord = {} --用于记录所有出现过的掉落物
	self.playerAvatarList = {}
	self.hero = nil
	self.bossId = nil
	self.effectId = 10000
	self.performLoots = {}
	self.monsterDeathHelper = nil -- 辅助管理怪物的死亡流程
end	

function EntityManager:clear()
	if self.hero then
		self.hero:clear()		
	end
	self:clearAll()
end

function EntityManager:getLootRecord()
	return self.lootRecord
end

function EntityManager:getDeathHelper()
	if self.monsterDeathHelper == nil then
		self.monsterDeathHelper = MonsterDeathHelper.New()
	end
	
	return self.monsterDeathHelper
end

function EntityManager:setBossId(id)
	self.bossId = id
end

function EntityManager:getBossId()
	return self.bossId
end

function EntityManager:tick(time)
	if self.hero ~= nil then
		self.hero:tick(time)
	end
	
	for i,v in pairs(self.playerList) do	
		if v and v.tick then
			v:tick(time)
		end
	end
	
	for i,v in pairs(self.monsterList) do
		if v and v.tick then
			v:tick(time)
		end
		
	end
	
	for i,v in pairs(self.petList) do
		if v and v.tick then
			v:tick(time)
		end
	end
	
	for i,v in pairs(self.playerAvatarList) do
		if v and v.tick then
			v:tick(time)
		end
	end
end

function EntityManager:addPlayer(id, player)
	if self.playerList[id] == nil then
		self.playerList[id] = player
	end
end

function EntityManager:addPlayerAvatar(id,playerAvatar)
	if self.playerAvatarList[id] == nil then
		self.playerAvatarList[id] = playerAvatar
	end
end
--todo 等静态数据格式


function EntityManager:getNpcModelId(npcRefId)

	local npcData = GameData.Npc[npcRefId]
	local npcmodelId = 1005
	if npcData then
		local npcPropertyData = npcData["property"]
		npcmodelId = tonumber(npcPropertyData["modelId"])
	end
	return npcmodelId
end
--todo 等静态数据格式


function EntityManager:getMonsterModelId(monsterRefId)
				
	local monsterData = GameData.Monster[monsterRefId]
	local modelId = 3000
	if monsterData then
		modelId = monsterData["property"]["modelId"]
		modelId = tonumber(modelId)
	end
	return modelId
end
--todo 等静态数据格式


function EntityManager:getNPCName(refId)
	
	local npcData = GameData.Npc[refId]
	local name = Config.Words[107]
	if refId then
		name = name .." " .. refId
	end	
	if npcData then
		name = npcData["property"]["name"]
	end
	return name
end
--todo 等静态数据格式

function EntityManager:getPluckName(refId)
	
	local npcData = GameData.Collect[refId]
	local name = Config.Words[107]
	if refId then
		name = name .." " .. refId
	end	
	if npcData then
		name = npcData["property"]["name"]
	end
	return name
end

function EntityManager:getMonsterName(refId)
	
	local monsterData = GameData.Monster[refId]
	local monsterName = Config.Words[108]
	if refId then
		monsterName = monsterName .." " .. refId
	end		
	if monsterData then
		monsterName = PropertyDictionary:get_name(monsterData["property"])
	end
	return monsterName
end

function EntityManager:getMonsterModuleScale(refId)
	
	local monsterData = GameData.Monster[refId]
	local monsterScale = 100
	if monsterData then
		monsterScale = PropertyDictionary:get_moduleScale(monsterData["moduleScale"])
	end
	return monsterScale
end

function EntityManager:getMonsterLevel(refId)
	
	local monsterData = GameData.Monster[refId]
	local monsterName = Config.Words[108]
	if refId then
		monsterName = monsterName .." " .. refId
	end
	if monsterData then
		monsterLevel = PropertyDictionary:get_level(monsterData["property"])
	end
	return monsterLevel
end
	
function EntityManager:createEntityObject(objectType, serverId, refId)
	local obj 
	if objectType == EntityType.EntityType_Player then
		if self.hero and self.hero:getId() == serverId then
			return
		end
		if not self.playerList[serverId] then		
			local player = PlayerObject.New()
			player:setId(serverId)
			self.playerList[serverId] = player
			obj = player
			GlobalEventSystem:Fire(GameEvent.EventEntityAdded, obj)
		end
	elseif  objectType ==  EntityType.EntityType_Monster then
		--local monster = self.monsterList[serverId]
		--if monster == nil then
			
			obj = MonsterObject.New()
			obj:setId(serverId)
			obj:setRefId(refId)
			self.monsterList[serverId] = obj		
			--obj = monster
			--GlobalEventSystem:Fire(GameEvent.EventMonsterAdded, obj)	
		--end
	elseif objectType ==  EntityType.EntityType_NPC then
		local npc = self.npcList[serverId]
		if npc == nil then
		
			npc = NPCObject.New()
			npc:setId(serverId)
			npc:setRefId(refId)
			self.npcList[serverId] = npc
			obj = npc
			if obj then
				GlobalEventSystem:Fire(GameEvent.EventEntityAdded, obj)	
			end
		end
		
	elseif objectType ==  EntityType.EntityType_Pet then
		
	elseif objectType ==  EntityType.EntityType_Loot then
		local loot = self.lootList[serverId]
		if loot == nil then		
			
			loot = LootObject.New()
			loot:setId(serverId)
			loot:setRefId(refId)
			self.lootList[serverId] = loot
			obj = loot
		end
	elseif objectType == EntityType.EntityType_PlayerAvatar then
		if self.hero and self.hero:getId() == serverId then
			return
		end
		if not self.playerAvatarList[serverId] then		
			local player = PlayerObject.New()
			player:setId(serverId)
			player:setType(EntityType.EntityType_PlayerAvatar)
			self.playerAvatarList[serverId] = player
			obj = player
		end
	end

	return obj
end

function EntityManager:createFireWallObject(serverId)
	local monster = self.monsterList[serverId]
	if monster == nil then	
		
		monster = FireWallObject.New()
		monster:setId(serverId)
		self.monsterList[serverId] = monster
		return monster
	end
	
	return nil
end

-- 创建一个特效
function EntityManager:createEffect()
			
	local effectObject = EffectObject.New()
	effectObject:setId("effect"..self.effectId)
	self.effectId = self.effectId + 1
	return effectObject
end

--[[
创建掉落物
储存到两个list
lootCellList: 用格子做索引
lootList： id做索引
--]]
function EntityManager:createLoot(serverId,x,y,refId)
	
	local mapManager = GameWorld.Instance:getMapManager()
	local aoiCellX, aoiCellY = mapManager:convertToAoiCell(x,y)
	local key = self:createLootCellKey(aoiCellX, aoiCellY)
	loot = LootObject.New()
	loot:setId(serverId)
	loot:setRefId(refId)
	loot:loadModule()
	loot:setCellXY(x,y)
	if self.lootCellList[key] == nil then
		self.lootCellList[key] = {}
	end	
	self.lootCellList[key][serverId] = loot
	self.lootList[serverId] = loot
	return loot
end

function EntityManager:createLootCellKey(x, y)
	return x..","..y
end

function EntityManager:getLoot(x, y)
	return self.lootCellList[self:createLootCellKey(x, y)]
end

function EntityManager:getEntityObject( objectType, serverId )
	if objectType == EntityType.EntityType_Player then
		if self.hero and self.hero:getId() == serverId then
			return self.hero
		elseif self.playerList[serverId] then
			return self.playerList[serverId]
		else
			return nil
		end
	elseif  objectType ==  EntityType.EntityType_Monster then
		return self.monsterList[serverId]
	elseif objectType ==  EntityType.EntityType_NPC then
		return self.npcList[serverId]
	elseif objectType ==  EntityType.EntityType_Pet then
		
	elseif objectType ==  EntityType.EntityType_Loot then		
		return self.lootList[serverId]
	elseif objectType ==  EntityType.EntityType_Effect then
		return self:getEffect(serverId)
	elseif objectType == EntityType.EntityType_Safe_Region then	
		return self:getSafeRegion(serverId)
	elseif objectType == EntityType.EntityType_PlayerAvatar then		
		if self.playerAvatarList[serverId] then
			return self.playerAvatarList[serverId]
		else
			return nil
		end
	end
end

function EntityManager:getSafeRegion(serverId)
	local region = self.effectList[serverId]
	if  region == nil then
		region = SafeRegionObject.New()
		self.effectList[serverId] = region
	end		
	return region
end

function EntityManager:getEffect(serverId)
	local effect = self.effectList[serverId]
	if  effect == nil then
		effect = EffectObject.New()
		self.effectList[serverId] = effect
	end		
	return effect	
end

function EntityManager:removeObject( objectType, serverId )
	if objectType ==  EntityType.EntityType_Player then
		self:removeAndCleanUp(self.playerList,serverId)
	elseif  objectType ==  EntityType.EntityType_Monster then
		local entity = self.monsterList[serverId]	--删除怪物时，需要更新英雄的宝宝状态
		if entity then
			local hero = self:getHero()
			if entity:hasOwner() and entity:getOwnerId() == hero:getId() then
				hero:setPet(nil)
			end	
			--清除stateTable 防止重用
			local stateTable = {}
			entity:getState():updateComboStateList(stateTable)						
			self:removeAndCleanUp(self.monsterList, serverId)
			-- 清除actionPlayerManager对应的action
			ActionPlayerMgr.Instance:removePlayersByGroup(serverId)				
		end
		
	elseif objectType ==  EntityType.EntityType_NPC or objectType == EntityType.EntityType_Pluck then
		self:removeAndCleanUp(self.npcList,serverId)	
	elseif objectType ==  EntityType.EntityType_Pet then	
		--GlobalEventSystem:Fire(GameEvent.EventEntityRemoved, loot) 如果添加代码，记得要考虑是否加上这句话
	elseif objectType ==  EntityType.EntityType_Loot then
		local loot = self.lootList[serverId]
		if loot then
			GlobalEventSystem:Fire(GameEvent.EventEntityRemoved, loot)
			local mapManager = GameWorld.Instance:getMapManager()			
			local x,y = loot:getCellXY()
			local aoiCellX,aoiCellY = mapManager:convertToAoiCell(x,y)
			local code = aoiCellX..","..aoiCellY
--[[			loot:leaveMap()
			loot:DeleteMe()--]]
			loot:leaveMap()
			if self.lootCellList[code] then
				self.lootCellList[code][serverId] = nil
				if table.size(self.lootCellList[code]) == 0 then
					self.lootCellList[code] = nil
				end	
			end
			self.lootList[serverId] = nil
		end	
	elseif objectType ==  EntityType.EntityType_Effect then
		self:removeAndCleanUp(self.effectList,serverId)
	elseif objectType == EntityType.EntityType_PlayerAvatar then
		self:removeAndCleanUp(self.playerAvatarList,serverId)
	end
end

function EntityManager:remove(list,serverId)
	local entity = list[serverId]
	if entity then
		GlobalEventSystem:Fire(GameEvent.EventEntityRemoved, entity)
		list[serverId] = nil
	end
end

function EntityManager:removeAndCleanUp(list,serverId)
	local entity = list[serverId]
	if entity then	
		GlobalEventSystem:Fire(GameEvent.EventEntityRemoved, entity)
		entity:leaveMap()
		entity:DeleteMe()
		list[serverId] = nil
	end
end

function EntityManager:getEntityListByType(objectType)
	if objectType ==  EntityType.EntityType_Player then
		return self.playerList
	elseif  objectType ==  EntityType.EntityType_Monster then
		return self.monsterList
	elseif objectType ==  EntityType.EntityType_NPC or objectType == EntityType.EntityType_Pluck then
		return self.npcList
	elseif objectType ==  EntityType.EntityType_Pet then			
	elseif objectType ==  EntityType.EntityType_Loot then
		return self.lootList
	elseif objectType ==  EntityType.EntityType_Effect then
		return self.effectList
	elseif objectType == EntityType.EntityType_PlayerAvatar then
		return self.playerAvatarList
	end
end

function EntityManager:getNPCList()
	return self.npcList
end

function EntityManager:getMonsterList()
	return self.monsterList
end

function EntityManager:getPlayerList()
	return self.playerList
end

function EntityManager:getPlayerAvatarList()
	return self.playerAvatarList
end

function EntityManager:getLootList()
	return self.lootList
end

function EntityManager:clearAll()
	self:clearServerEntity()
	self:clearLocalEntity()
	
	self.lootRecord = {}
	--Juchao@20140319: 不能在这里将队列清空！因为挂机时可能会跨场景，如果清空队列，将会使挂机卡死。
--	ActionPlayerMgr.Instance:removePlayersExceptGroup(G_getHero():getId())
	if G_getHero() then
		ActionPlayerMgr.Instance:removePlayersExceptGroup(G_getHero():getId())
	else
		ActionPlayerMgr.Instance:removeAll()
	end
	
	-- 调用一次不一定会触发垃圾回收
	collectgarbage("collect")
	collectgarbage("collect")	
end

function EntityManager:clearLootList()
	for k,v in pairs(self.lootList) do
		local id = v:getId()
		local x,y = loot:getCellXY()
		local mapManager = GameWorld.Instance:getMapManager()
		local aoiCellX,aoiCellY = mapManager:convertToAoiCell(x,y)
		local code = aoiCellX..","..aoiCellY	
		v:forceLeaveMap()			
		if self.lootCellList[code] then
			self.lootCellList[code][id] = nil
			if table.isEmpty(self.lootCellList[code])then
				self.lootCellList[code] = nil
			end	
		end			
		self.lootList[k] = nil
	end
	self.lootList = {}
	self.lootCellList = {}
end

-- 清理服务器下发的entityObject
function EntityManager:clearServerEntity()
	self:clearList(self.monsterList)
	self.monsterList = {}
	
	self:clearList(self.petList)
	self.petList = {}
	
	self:clearList(self.playerList)
	self.playerList = {}
	
	self:clearLootList()
	
	self:clearList(self.playerAvatarList)
	self.playerAvatarList = {}
	
	if self.monsterDeathHelper then
		self.monsterDeathHelper:clear()
	end
end

-- 清理客户端本地加载的entityObject
function EntityManager:clearLocalEntity()
	self:clearList(self.npcList)
	self.npcList = {}
	
	self:clearList(self.effectList)
	self.effectList = {}
end

function EntityManager:clearList(list)
	local hero = self:getHero()		
	for k,v in pairs(list) do
		if v:getEntityType() == EntityType.EntityType_Monster then
 			if v:hasOwner() and v:getOwnerId() == hero:getId() then
				hero:setPet(nil)
			end		
		end
		v:leaveMap()	
		v:DeleteMe()
		list[k] = nil
	end
end

function EntityManager:createHero(id)
	if self.hero == nil then
		
		self.hero = HeroObject.New()
	end
	self.hero:setId(id)
	return self.hero
end

function EntityManager:getHero()
	return self.hero
end	

--获取其他玩家属性信息
function EntityManager:requestOtherPlayer(playerId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OtherPlayer_Attribute)
	StreamDataAdapter:WriteStr(writer,playerId)	
	simulator:sendTcpActionEventInLua(writer)	
end	

function EntityManager:requestNameColor()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Name_Color)
	simulator:sendTcpActionEventInLua(writer)	
end

function EntityManager:showPlayers(show)
	for k,v in pairs(self.playerList) do
		if self.hero:getId() ~= k then
			v:setVisible(show)
		end
	end
	
	for k,v in pairs(self.playerAvatarList) do
		if self.hero:getId() ~= k then
			v:setVisible(show)
		end
	end
end

--显示玩家姓名title
function EntityManager:showPlayersName(show)
	for key, player in pairs(self.playerList) do
		if self.hero:getId() ~=key then
			player:setInfoVisible(show)
		end
	end
	GameWorld.Instance:getTextManager():setTextVisible(show)
end

--显示玩家姓名翅膀
function EntityManager:showPlayersWing(show)
	for k, v in pairs(self.playerList) do
		if self.hero:getId() ~= k then
			if show == false then
				v:getRenderSprite():setVisiblePart(EntityParts.eEntityPart_Wing, show)
			else
				v:updateWingModule()
			end
		end
	end
	
	for k,v in pairs(self.playerAvatarList) do
		if self.hero:getId() ~= k then
			if show == false then
				v:getRenderSprite():setVisiblePart(EntityParts.eEntityPart_Wing, show)
			else
				v:updateWingModule()
			end
		end
	end
end

function EntityManager:addPerformLoot(serverId)
	self.performLoots[serverId] = true
end

function EntityManager:willPerform(serverId)
	return self.performLoots[serverId]
end

function EntityManager:clearPerformList()
	self.performLoots = {}
end

function EntityManager:createPlayerMonsterObject(entityType,serverId, refId)
	local obj = nil
	local monster = self.monsterList[serverId]
	if monster == nil then
		monster = PlayerMonsterObject.New()
		monster:setId(serverId)
		monster:setRefId(refId)
		self.monsterList[serverId] = monster		
		obj = monster			
	end	
	return obj
end

function EntityManager:IsPlayerMonster(refId)	
	if GameData.PlayerMonster[refId] then
		return true
	else		
		return false
	end
	
end

function EntityManager:showFireWall(isShow)
	for k,v in pairs(self.monsterList) do
		if v:getRefId() == "monster_skill_1" then
			v:setVisible(isShow)
		end
	end
end

function EntityManager:isHero(id)
	if self.hero and id then
		return	self.hero:getId() == id
	end
	return false
end