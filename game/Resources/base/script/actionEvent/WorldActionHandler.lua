require ("common.ActionEventHandler")
require"data.scene.scene"
WorldActionHandler = WorldActionHandler or BaseClass(ActionEventHandler)

function WorldActionHandler:handleSceneAoiData(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local timeManager = GameWorld.Instance:getTimeManager()		
	timeManager:updateHeartBeat()	
	self:readRemoveEntity(reader)		
	self:readPlayer(reader)
	self:readMonster(reader)
	self:readLoot(reader)
	self:readPluck(reader)
	self:readMove(reader)
	self:readStopMove(reader)
	self:readJumpTo(reader)
	self:propertyChg(reader)
	self:readPlayerAvatar(reader)    --读取玩家离线替身		
end

function WorldActionHandler:__init()
	
	local scene_switch_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:switchScene(reader)
	end
	
	local reset_position_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readResetPosition(reader)
	end
	
	local sync_time_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local clientStamp			=	StreamDataAdapter:ReadLLong(reader)
		local serverStamp			=	StreamDataAdapter:ReadLLong(reader)		
		local timeManager = GameWorld.Instance:getTimeManager()
		timeManager:setClientStampSend(clientStamp)
		timeManager:setServetStamp(serverStamp)
		timeManager:updateLag()	
	end
	
	local scene_aoi_data_func = function (reader)
		self:handleSceneAoiData(reader)
	end
	
	local scene_state_change = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleSceneStateChange(reader)
	end

	local sceneReady = function ()
		self:handleSceneReady()
	end
	
	local lootPerformInfo = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleLootPerformInfo(reader)
	end
	
	local function handleHeartBeat(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		local timeManager = GameWorld.Instance:getTimeManager()		
		timeManager:updateHeartBeat()			
	end	
	
	-- 绑定消息和处理函数
	self:Bind(ActionEvents.G2C_Scene_Sync_Time,sync_time_func)
	self:Bind(ActionEvents.G2C_Scene_Switch,scene_switch_func)
	self:Bind(ActionEvents.G2C_Scene_Reset_Position,reset_position_func)
	self:Bind(ActionEvents.G2C_Scene_AOI,scene_aoi_data_func)
	self:Bind(ActionEvents.G2C_Scene_State_Change,scene_state_change)
	self:Bind(ActionEvents.G2C_Scene_Ready,sceneReady)
	self:Bind(ActionEvents.G2C_Scene_LootInfo,lootPerformInfo)
	self:Bind(ActionEvents.G2C_Player_Heartbeat,handleHeartBeat)	
end

function WorldActionHandler:handleLootPerformInfo(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	entityManager:clearPerformList()
	local count = StreamDataAdapter:ReadShort(reader)
	for i=1,count do
		local id = StreamDataAdapter:ReadStr(reader)
		entityManager:addPerformLoot(id)
	end
end


function WorldActionHandler:handleSceneReady()
	UIManager.Instance:hideLoadingSence()
	GlobalEventSystem:Fire(GameEvent.EventHeroMovement)
	GlobalEventSystem:Fire(GameEvent.EventGameSceneReady)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	miningMgr:requestMiningBeOpen()
end

function WorldActionHandler:readRemoveEntity(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local removeCount = StreamDataAdapter:ReadChar(reader)  --short->byte
	--local gameScheduler = GameWorld.Instance:getScheduler()
	local entityManager = GameWorld.Instance:getEntityManager()
	for i=1,removeCount do
		local removeId = StreamDataAdapter:ReadStr(reader) 
		local removeType = StreamDataAdapter:ReadChar(reader) --string->byte
		local entity = entityManager:removeObject(removeType,removeId)		
		if entity then
			entity = nil
		end
	end
end

function WorldActionHandler:readPlayer(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local playerCount = StreamDataAdapter:ReadChar(reader)  --short->byte	
	
	for i=1,playerCount do
		local charId			=	StreamDataAdapter:ReadStr(reader)
		local name			=	StreamDataAdapter:ReadStr(reader)
		local profession		=	StreamDataAdapter:ReadChar(reader)
		local playerLevel			=	StreamDataAdapter:ReadShort(reader) --int->byte
		local playerGender			=	StreamDataAdapter:ReadChar(reader)
		local playerHp				=	StreamDataAdapter:ReadInt(reader)
		local playerHpMax			=	StreamDataAdapter:ReadInt(reader)
		local playerX				=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local playerY				=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local playerSpeed			=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local playerWeaponId		=	StreamDataAdapter:ReadShort(reader) --int ->short
		local playerArmorId			=	StreamDataAdapter:ReadShort(reader) --int ->short
		local playerWingId			=	StreamDataAdapter:ReadShort(reader) --int ->short
		local playerMountId			=	StreamDataAdapter:ReadShort(reader) --int ->short
		local PlayerKnightLevel		=	StreamDataAdapter:ReadChar(reader)
		local PlayerUnionName		=	StreamDataAdapter:ReadStr(reader)
		local PlayerIsKingCity		=	StreamDataAdapter:ReadChar(reader)
		local stateTable = self:readStateTable(reader)
		
		local propertyTable
		local dataLenght = StreamDataAdapter:ReadShort(reader)  --int ->short
		if dataLenght > 0 then
			propertyTable = getPropertyTable(reader)
		end
		
		local player = entityManager:createEntityObject(EntityType.EntityType_Player,charId)
		if player ~= nil then
			player:setCellXY(playerX,playerY)
			PropertyDictionary:set_name(player:getPT(),name)
			PropertyDictionary:set_moveSpeed(player:getPT(),playerSpeed)
			PropertyDictionary:set_level(player:getPT(),playerLevel)
			PropertyDictionary:set_gender(player:getPT(),playerGender)
			PropertyDictionary:set_professionId(player:getPT(),profession)
			PropertyDictionary:set_weaponModleId(player:getPT(),playerWeaponId)
			PropertyDictionary:set_armorModleId(player:getPT(),playerArmorId)
			PropertyDictionary:set_wingModleId(player:getPT(),playerWingId)
			
			PropertyDictionary:set_mountModleId(player:getPT(),playerMountId)
			PropertyDictionary:set_maxHP(player:getPT(),playerHpMax)
			PropertyDictionary:set_knight(player:getPT(),PlayerKnightLevel)
			PropertyDictionary:set_unionName(player:getPT(),PlayerUnionName)
			PropertyDictionary:set_isKingCity(player:getPT(),PlayerIsKingCity)
			if propertyTable then
				PropertyDictionary:set_nameColor(player:getPT(),propertyTable.nameColor)
				PropertyDictionary:set_vipType(player:getPT(),propertyTable.vipType)
				PropertyDictionary:set_monsterInvasionFont(player:getPT(), propertyTable.monsterInvasionFont)
				PropertyDictionary:set_pkModel(player:getPT(), propertyTable.pkModel)
			end
			player:setHP(playerHp)	
			player:setStateTable(stateTable)
			player:enterMap()
			
			local settingMgr = GameWorld.Instance:getSettingMgr()
			player:setVisible(settingMgr:isShowOtherPlayer())
			player:setInfoVisible(settingMgr:isShowPlayerName())
			if settingMgr:isShowPlayerWing() == false then 
				player:getRenderSprite():setVisiblePart(EntityParts.eEntityPart_Wing, settingMgr:isShowPlayerWing())
			end
		else
			player = entityManager:getEntityObject(EntityType.EntityType_Player,charId)
			if player then
				player:setCellXY(playerX,playerY)
				player:getState():updateComboStateList(stateTable)				
			end
		end
		
		-- 已经死亡
		if player and playerHp == 0 then
			player:DoDeath()
		end
	end
end

function WorldActionHandler:readPlayerAvatar(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local otherSpriteCount = StreamDataAdapter:ReadChar(reader) --short->byte
	
	
 	for i=1,otherSpriteCount do
		local charId				=	StreamDataAdapter:ReadStr(reader)
		local otherSpritetype       =   StreamDataAdapter:ReadChar(reader)  --string->byte
		local playerX				=	StreamDataAdapter:ReadUShort(reader)  --int ->ushort
		local playerY				=	StreamDataAdapter:ReadUShort(reader)   --int ->ushort
		local propertyTable
		local dataLenght = StreamDataAdapter:ReadShort(reader)  --int->short
		if dataLenght>0 then
			propertyTable = getPropertyTable(reader)
		end
		local stateTable = self:readStateTable(reader)
		
		if otherSpritetype == EntityType.EntityType_PlayerAvatar then
			--local sumonId = StreamDataAdapter:ReadStr(reader)
			local player = entityManager:createEntityObject(EntityType.EntityType_PlayerAvatar,charId)
			if player ~= nil then
				player:setCellXY(playerX,playerY)
				PropertyDictionary:set_ownerId(player:getPT(), propertyTable.ownerId)
				PropertyDictionary:set_name(player:getPT(),propertyTable.name)
				PropertyDictionary:set_professionId(player:getPT(),propertyTable.professionId)
				PropertyDictionary:set_level(player:getPT(),propertyTable.level)
				PropertyDictionary:set_gender(player:getPT(),propertyTable.gender)
				PropertyDictionary:set_HP(player:getPT(),propertyTable.HP)
				PropertyDictionary:set_maxHP(player:getPT(),propertyTable.maxHP)				
				PropertyDictionary:set_moveSpeed(player:getPT(),propertyTable.moveSpeed)
				PropertyDictionary:set_weaponModleId(player:getPT(),propertyTable.weaponModleId)
				PropertyDictionary:set_armorModleId(player:getPT(),propertyTable.armorModleId)
				PropertyDictionary:set_wingModleId(player:getPT(),propertyTable.wingModleId)				
				PropertyDictionary:set_mountModleId(player:getPT(),propertyTable.mountModleId)
				PropertyDictionary:set_knight(player:getPT(),propertyTable.knight)
				PropertyDictionary:set_unionName(player:getPT(),propertyTable.unionName)
				PropertyDictionary:set_isKingCity(player:getPT(),propertyTable.isKingCity)
				
				player:setStateTable(stateTable)
				player:enterMap()

				local settingMgr = GameWorld.Instance:getSettingMgr()
				player:setVisible(settingMgr:isShowOtherPlayer())
				if settingMgr:isShowPlayerWing() == false then 
					player:getRenderSprite():setVisiblePart(EntityParts.eEntityPart_Wing, settingMgr:isShowPlayerWing())
				end
			end	
		else
			player = entityManager:getEntityObject(EntityType.EntityType_PlayerAvatar,charId)
			if player then
				player:setCellXY(playerX,playerY)
				player:getState():updateComboStateList(stateTable)
				
				-- 已经死亡
				if playerHp == 0 then
					player:DoDeath()
				end
			end
		end	
	end	
end

function WorldActionHandler:readStateTable(reader)
	local stateCount = StreamDataAdapter:ReadChar(reader) --short->byte
	local stateTable = {}
	local stateId = 0
	for i=1,stateCount do
		stateId = StreamDataAdapter:ReadShort(reader)
		table.insert(stateTable,stateId)
	end
	return stateTable
end

function WorldActionHandler:readMonsterData(reader, monsterCount)
	local entityManager = GameWorld.Instance:getEntityManager()
	--print("WorldActionHandler:readMonsterData "..monsterCount)
	for i=1,monsterCount do
		local monsterId		=	StreamDataAdapter:ReadStr(reader)
		local monsterRefId	=	StreamDataAdapter:ReadStr(reader)
		local x				=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local y				=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local hp			=	StreamDataAdapter:ReadInt(reader)
		local hpMax			=	StreamDataAdapter:ReadInt(reader)
		local unionName 	= 	StreamDataAdapter:ReadStr(reader)	--Juchao@20140313: 怪物也可以有公会。比如沙巴克的神兽
		local speed			=	StreamDataAdapter:ReadUShort(reader)   --int ->ushort
		local stateTable = self:readStateTable(reader)
		local ownerId = StreamDataAdapter:ReadStr(reader)

		-- 火墙比较特别
		local monster = nil
		if entityManager:IsPlayerMonster(monsterRefId) then
			monster = entityManager:createPlayerMonsterObject(EntityType.EntityType_Monster, monsterId, monsterRefId)
			if monster then				
				PropertyDictionary:set_moveSpeed(monster:getPT(),speed)
				monster:setCellXY(x,y)
				monster:setRefId(monsterRefId)
				monster:setModuleId(entityManager:getMonsterModelId(monsterRefId))
				monster:setModuleScale(entityManager:getMonsterModuleScale(monsterRefId))
				monster:setMaxHP(hpMax)
				monster:setHP(hp)
				monster:setOwnerId(ownerId)
				monster:updateSpeed()				
				monster:enterMap(x,y)
			end
		
		elseif  monsterRefId ~= "monster_skill_1" then
			--monster = entityManager:createEntityObject(EntityType.EntityType_Monster, monsterId, monsterRefId)
			monster = entityManager:getEntityObject(EntityType.EntityType_Monster, monsterId)
			if monster then			
				PropertyDictionary:set_moveSpeed(monster:getPT(),speed)
				monster:setCellXY(x,y)
				monster:setMaxHP(hpMax)
				monster:setHP(hp)				
				monster:setOwnerId(ownerId)
			else				
				local monster = entityManager:createEntityObject(EntityType.EntityType_Monster, monsterId, monsterRefId)
				PropertyDictionary:set_unionName(monster:getPT(),unionName)
				PropertyDictionary:set_moveSpeed(monster:getPT(),speed)				
				monster:setModuleId(entityManager:getMonsterModelId(monsterRefId))
				monster:setModuleScale(entityManager:getMonsterModuleScale(monsterRefId))
				monster:setMaxHP(hpMax)
				monster:setHP(hp)
				monster:setStateTable(stateTable)
				monster:setOwnerId(ownerId)
				monster:setCellXY(x,y)
				if i > 8 then
					monster:enterMapAsycn(x,y)
				else
					monster:enterMap(x,y)
				end					
			end				
		else
			monster = entityManager:createFireWallObject(monsterId)
			if monster then
				monster:setVisible(SkillShowManager:getDisplayEffect())
				monster:setRefId(monsterRefId)
				monster:setOwnerId(ownerId)
				monster:setCellXY(x,y)
				monster:setStateTable(stateTable)
				monster:enterMap(x,y)
			end
		end	
	end
end

function WorldActionHandler:readMonster(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local monsterCount		=	StreamDataAdapter:ReadChar(reader) --short->byte
	if monsterCount > 0 then
		self:readMonsterData(reader, monsterCount)
	end
end
--掉落物
function WorldActionHandler:readLoot(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local lootCount		=	StreamDataAdapter:ReadChar(reader) --short->byte
	
	--local gameScheduler = GameWorld.Instance:getScheduler()
	for i=1,lootCount do
		local lootId		=	StreamDataAdapter:ReadStr(reader)
		local lootRefId	=	StreamDataAdapter:ReadStr(reader)
		
		local x				=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local y				=	StreamDataAdapter:ReadUShort(reader)  --int ->ushort
		local isMine		=	StreamDataAdapter:ReadChar(reader)
		local leftGuardTime	=	StreamDataAdapter:ReadUShort(reader) --int ->ushort
		local loot = entityManager:createLoot(lootId,x,y,lootRefId)
		if lootRefId ~= "" and lootRefId ~= nil then
			loot:setOwner(isMine)
			loot:setProtectTime(leftGuardTime)
			loot:enterMap()
		end
	end
end
--采集物
function WorldActionHandler:readPluck(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local pluckCount		=	StreamDataAdapter:ReadChar(reader)  --short->byte
	
	for i=1,pluckCount do
		local pluckId		=	StreamDataAdapter:ReadStr(reader)
		local pluckRefId	=	StreamDataAdapter:ReadStr(reader)
		local x				=	StreamDataAdapter:ReadUShort(reader)  --int ->ushort
		local y				=	StreamDataAdapter:ReadUShort(reader)  --int ->ushort
		
		local pluck = entityManager:createEntityObject(EntityType.EntityType_NPC, pluckId, pluckRefId)
		if pluck ~= nil then
			pluck:setRefId(pluckRefId)
			pluck:enterMap(x,y)
		end
	end
end

function WorldActionHandler:readMove(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	-- 服务器控制的移动
	local moveCount			=	StreamDataAdapter:ReadChar(reader)  --short->byte
	for i=1,moveCount do
		local charId		=	StreamDataAdapter:ReadStr(reader)
		local moveType			=	StreamDataAdapter:ReadChar(reader)--strint->byte	--角色类型(Player, Monster, NPC)
		--local serverStamp		=	StreamDataAdapter:ReadLLong(reader) 	-- AOI发送时间，服务端时间，时间戳，毫秒数
		local srcX			=	StreamDataAdapter:ReadUShort(reader)  --int->ushort
		local srcY			=	StreamDataAdapter:ReadUShort(reader)  --int->ushort
		local dstX			=	StreamDataAdapter:ReadUShort(reader) --int->ushort
		local dstY			=	StreamDataAdapter:ReadUShort(reader) --int->ushort
		local moveEntityObject = entityManager:getEntityObject(moveType,charId)
		if moveEntityObject and moveEntityObject.moveTo then
			self:handleLagMove(moveEntityObject,srcX, srcY, dstX, dstY)
		end
	end
end

function WorldActionHandler:handleLagMove(moveEntityObject, srcX, srcY, dstX, dstY)
	moveEntityObject:DoAoiMove(dstX, dstY)
end

function WorldActionHandler:readStopMove(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	-- 服务器控制的移动
	local stopCount			=	StreamDataAdapter:ReadChar(reader) --short->byte
	
	for i=1,stopCount do
		local charId		=	StreamDataAdapter:ReadStr(reader)
		local stopType			=	StreamDataAdapter:ReadChar(reader)--string->byte 	--角色类型(Player, Monster, NPC)
		local aasrcX			=	StreamDataAdapter:ReadUShort(reader) --int->ushort
		local aasrcY			=	StreamDataAdapter:ReadUShort(reader)--int->ushort
		local stopEntityObject = entityManager:getEntityObject(stopType,charId)
		
		if stopEntityObject then
			stopEntityObject:DoAoiMove(aasrcX,aasrcY)
		end
	end
end

function WorldActionHandler:readJumpTo(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local jumpCount			=	StreamDataAdapter:ReadChar(reader)  --short->byte
	
	for i=1,jumpCount do
		local charId		=	StreamDataAdapter:ReadStr(reader)
		local jumpType			=	StreamDataAdapter:ReadChar(reader)--string->byte	--角色类型(Player, Monster, NPC)
		local xx			=	StreamDataAdapter:ReadUShort(reader)  --int->ushort
		local yy			=	StreamDataAdapter:ReadUShort(reader)  --int->ushort
		local jumpEntityObject = entityManager:getEntityObject(jumpType,charId)
		if not jumpEntityObject then
			jumpEntityObject = entityManager:createEntityObject(jumpType,charId)
		end
		
		if jumpEntityObject then
			jumpEntityObject:setCellXY(xx,yy)
		end
	end
end

function WorldActionHandler:propertyChg(reader)
	local entityManager = GameWorld.Instance:getEntityManager()
	local propertyCount			=	StreamDataAdapter:ReadChar(reader) --short->byte
	
	local propertyEntityObject  = nil
	for i=1,propertyCount do
		local charId = StreamDataAdapter:ReadStr(reader)
		local entityType = StreamDataAdapter:ReadChar(reader) --string->byte
		local dataLenght = StreamDataAdapter:ReadShort(reader) --int ->short
		if dataLenght > 0 then
			local propertyTable = getPropertyTable(reader)
			propertyEntityObject = entityManager:getEntityObject(entityType,charId)			
			if propertyEntityObject then						
				if propertyEntityObject and entityType == EntityType.EntityType_Player then			
					propertyEntityObject:updateModuleByPd(propertyTable)	
					if (propertyEntityObject:getState():isState(CharacterState.CharacterStateDead) or propertyEntityObject:getState():isState(CharacterState.CharacterStateWillDead)) and PropertyDictionary:get_HP(propertyEntityObject:getPT()) > 0 then
						-- 已经复活
						propertyEntityObject:DoRevive()
					end						
				end
			end
		end
	end
end

function WorldActionHandler:readResetPosition(reader)
	
	-- 重置entityObject的位置
	local entityManager = GameWorld.Instance:getEntityManager()
	local resetX = StreamDataAdapter:ReadInt(reader)
	local resetY = StreamDataAdapter:ReadInt(reader)
	local objectType =  StreamDataAdapter:ReadChar(reader)
	local characterId = StreamDataAdapter:ReadLLong(reader)
	local object = entityManager:getEntityObject(objectType,characterId)
	if object then
		object:setCellXY(resetX,resetY)
		object:moveStop()
		local hero = entityManager:getHero()
		if object:getId() == hero:getId() then
			local x,y = hero:getMapXY()
			object:moveTo(x+1,y+1)
		end
	end
end


local function loadMap(self,mapRefId,cellX,cellY)
	if not self then
		return
	end
	local entityManager = GameWorld.Instance:getEntityManager()
	local gameMapManager = GameWorld.Instance:getMapManager()
	local mapData = GameData.Scene[mapRefId]	
	if mapData then
		if mapData.kind == 1 or mapData.kind == 2 then	--地宫或活动地图
			local msg = {}
			table.insert(msg,{word = Config.Words[15030], color = Config.FontColor["ColorRed3"]})
			UIManager.Instance:showSystemTips(msg,nil,nil,6)
		end
		
		local hero = entityManager:getHero()
		if hero == nil then
			hero = entityManager:createHero(0)
		end
		if cellX and cellY then
			hero:forceStop()
			hero:setCellXY(cellX, cellY)
			-- 同步hero的位置
			GlobalEventSystem:Fire(GameEvent.EventHeroMovement)
		end
		debugPrint("switchTo "..mapRefId.." x"..cellX.." y"..cellY)		
		local currentMap = gameMapManager:getCurrentMapRefId()
		if currentMap ~= mapRefId then
			self:handleInstanceState(mapData)
			--gameMapManager:setLoadHandler()
			--GlobalEventSystem:Fire(GameEvent.EventSmallMapNeedToUpdate, currentMap, mapRefId)
			--GlobalEventSystem:Fire(GameEvent.EventReleaseMap)			
		end
		
		gameMapManager:loadMap(mapRefId)
		
		-- 转动摄像头
		local mapX, mapY = hero:getMapXY()
		local centerY = hero:getCenterY()
		gameMapManager:setViewCenter(mapX, centerY)
	end
end

function WorldActionHandler:stopLoadMapSchedule()
	if self.loadMapSchedule then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.loadMapSchedule)	
		self.loadMapSchedule = nil
	end
end

function WorldActionHandler:switchScene(reader)
	self:stopLoadMapSchedule()
	local uiManager = UIManager.Instance
	uiManager:showLoadingSence(10)
	uiManager:clearSystemTips()
	-- 场景加载
	local mapRefId = StreamDataAdapter:ReadStr(reader)
	local cellX = StreamDataAdapter:ReadInt(reader)
	local cellY = StreamDataAdapter:ReadInt(reader)
	GameWorld.Instance:getMapManager():setLastSceneId(mapRefId)
	local function load()
		loadMap(self,mapRefId,cellX,cellY)
		self:stopLoadMapSchedule()
	end		
	self.loadMapSchedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(load, 0, false)
end

function WorldActionHandler:handleInstanceState(mapData)
	local kind = PropertyDictionary:get_kind(mapData)	
	if kind == MapKind.instanceArea  then
		GlobalEventSystem:Fire(GameEvent.EventLeaveButtonStateChange,true)
		local msg = {}
		table.insert(msg,{word = Config.Words[15010], color = Config.FontColor["ColorWhite1"]})
		UIManager.Instance:showSystemTips(msg)
	elseif kind == MapKind.ativityArea then
		local sceneRefId = PropertyDictionary:get_sceneRefId(mapData)	
		local activityType = GameWorld.Instance:getMapManager():getMapActivityType(mapData.refId) --临时解决活动地图代码蛋疼的问题
		if activityType == E_mapActivityType.mining or activityType == E_mapActivityType.monsterInvasion or activityType == E_mapActivityType.bossTemple then	--离开活动按钮		
			GlobalEventSystem:Fire(GameEvent.EventLeaveActivityBtnState,true)
			GlobalEventSystem:Fire(GameEvent.EventLeaveButtonStateChange,false)	
		else
			GlobalEventSystem:Fire(GameEvent.EventLeaveActivityBtnState,false)
			GlobalEventSystem:Fire(GameEvent.EventLeaveButtonStateChange,false)			
		end
	else
		GlobalEventSystem:Fire(GameEvent.EventLeaveActivityBtnState,false)
		GlobalEventSystem:Fire(GameEvent.EventLeaveButtonStateChange,false)	
		GlobalEventSystem:Fire(GameEvent.EventExitBossTemple)	
	end
end

function WorldActionHandler:handleSceneStateChange(reader)
	local characterType = StreamDataAdapter:ReadChar(reader)    --string->byte
	local characterId = StreamDataAdapter:ReadStr(reader)
	local count = reader:ReadShort()
	local stateList = {}
	for i=1, count do
		table.insert(stateList, reader:ReadShort())
	end
	
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(characterType, characterId)
	if entityObject and entityObject:isEnterMap() and not entityObject:getState():isState(CharacterState.CharacterStateDead) then
		entityObject:getState():updateComboStateList(stateList)
	end
end
