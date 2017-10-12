require("common.baseclass")
require("common.ActionEventHandler")
require("GameDef")

EntityActionHandler = EntityActionHandler or BaseClass(ActionEventHandler)

function EntityActionHandler:__init()
	local handleNet_G2C_Player_Attribute = function(reader) 
		self:handleNet_G2C_Player_Attribute(reader)
	end
	
	local handleNet_G2C_OtherPlayer_Attribute = function(reader) 
		self:handleNet_G2C_OtherPlayer_Attribute(reader)
	end

	local handleNet_G2C_Player_Name_Color = function(reader)
		self:handleNet_G2C_Player_Name_Color(reader)
	end
	
	local handleNet_G2C_Monster_OwnerTransfer = function (reader)
		self:handleNet_G2C_Monster_OwnerTransfer(reader)
	end
	local handleNet_G2C_OtherPlayer_Simple_Attribute = function (reader)
		self:handleNet_G2C_OtherPlayer_Simple_Attribute(reader)
	end
	
	local handleNet_G2C_Player_Revive = function (reader)
		self:handleNet_G2C_Player_Revive()
	end

	local function handleKillerInfo(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		
		local killerCharId = StreamDataAdapter:ReadStr(reader)--击杀者
		local killerName = StreamDataAdapter:ReadStr(reader)--击杀者名称
		local killerType = reader:ReadChar()--击杀者类型 (无类型:0 怪物:1 玩家:2)
		local killerLevel = reader:ReadInt() --击杀者等级
		local killerOccupa = reader:ReadChar()--击杀者职业(1:战士 2:法师 3:道士)
		local killerFightPower = reader:ReadInt() --击杀者战力
		local deadTime = reader:ReadULLong()--死亡时间(击杀时间)
		local count	 = reader:ReadChar()--掉落个数

		local itemList = {}
		for i=1,count do		
			local itemRefId = StreamDataAdapter:ReadStr(reader)--物品refId
			local itemcount = reader:ReadInt()--物品掉落个数			
			local item = {itemRefId = itemRefId,itemcount = itemcount}
			table.insert(itemList,item)
		end	
				
		local info = {
		killerCharId = killerCharId,
		killerName = killerName,
		killerType = killerType,
		killerLevel = killerLevel,
		killerOccupa = killerOccupa,
		killerFightPower = killerFightPower,
		deadTime = deadTime,
		itemList = itemList,
		}
		
		GlobalEventSystem:Fire(GameEvent.EventReviveViewOpen,info)
	end	
	
	local function handleG2C_FindEntity(reader)
		self:handleG2C_FindEntity(reader)
	end
	
	self:Bind(ActionEvents.G2C_Player_KillerInfo,handleKillerInfo)		
	self:Bind(ActionEvents.G2C_Player_Attribute, handleNet_G2C_Player_Attribute)
	self:Bind(ActionEvents.G2C_OtherPlayer_Attribute, handleNet_G2C_OtherPlayer_Attribute)
	self:Bind(ActionEvents.G2C_Name_Color, handleNet_G2C_Player_Name_Color)
	self:Bind(ActionEvents.G2C_Monster_OwnerTransfer, handleNet_G2C_Monster_OwnerTransfer)
	self:Bind(ActionEvents.G2C_OtherPlayer_Simple_Attribute, handleNet_G2C_OtherPlayer_Simple_Attribute)
	self:Bind(ActionEvents.G2C_Player_Revive, handleNet_G2C_Player_Revive)
	self:Bind(ActionEvents.G2C_Scene_FindSprite, handleG2C_FindEntity)
	
	self.oldPD = {}
	self.newPD = {}
	
	local onTimeout = function()			
		if not table.isEmpty(self.newPD) then
			GlobalEventSystem:Fire(GameEvent.EventHeroProChanged, self.newPD, self.oldPD)
			GlobalEventSystem:Fire(GameEvent.EventHeroProMerged, self.newPD)	
			self.oldPD = {}
			self.newPD = {}			
		end
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.2, false)	
end	

function EntityActionHandler:handleNet_G2C_Player_Revive(reader)
	-- 复活确认
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if hero == nil then
		return
	end
	
	hero:DoRevive()
	--Juchao@20140514: 英雄复活时，请求一次沙巴克攻城时间，以更新是否在沙巴克的状态。	
	G_getCastleWarMgr():requestCastleWarTime()
end

function EntityActionHandler:handleNet_G2C_Player_Attribute(reader)
	reader = tolua.cast(reader, "iBinaryReader")	
	local dataLenght = StreamDataAdapter:ReadInt(reader)
	local newPD = nil
	
	if (dataLenght > 0) then
		newPD = getPropertyTable(reader)	
	end
	
	if (newPD == nil) then
		return
	end
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if hero == nil then
		return
	end
	
	local oldPD = hero:getPT()
	for k, v in pairs(newPD) do
		local heroOldValue = oldPD[k]		
		if heroOldValue ~= v then
			if not self.oldPD[k] then
				self.oldPD[k] = heroOldValue			
			end
			self.newPD[k] = v	
		end
	end
	
	local newLv = PropertyDictionary:get_level(newPD)
	local curLevel = PropertyDictionary:get_level(hero:getPT())
	
	local oldMoveSpeed = PropertyDictionary:get_moveSpeed(hero:getPT())
	
	if (hero) then
		local oldHp = PropertyDictionary:get_HP(hero:getPT())
		local oldMp = PropertyDictionary:get_MP(hero:getPT())
		
		hero:updateModuleByPd(newPD)		
		-- 如果血量为0, 显示复活界面		
		local newHp = PropertyDictionary:get_HP(hero:getPT())
		if newHp == 0 and not hero:getState():isState(CharacterState.CharacterStateDead) then
			hero:DoDeath()
			GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoKillMonster) 
			GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)
		end
		
		-- 检查特定的属性变化
		if(newLv ~= 0 and newLv ~= curLevel) then
			SFGameAnalyzer:logGameEvent(GameAnalyzeID.HeroLevelChange, "level="..tostring(newLv))       --通知sdk等级发生变化
			GlobalEventSystem:Fire(GameEvent.EventHeroLevelChanged,newLv,curLevel)
		end
		
		local newMoveSpeed = PropertyDictionary:get_moveSpeed(hero:getPT())
		if newMoveSpeed > 0 and newMoveSpeed ~= oldMoveSpeed then
			hero:updateSpeed()
		end
		
		-- 玩家自己的血量和蓝的变化需要特别关注
		if oldHp ~= PropertyDictionary:get_HP(hero:getPT()) then
			GlobalEventSystem:Fire(GameEvent.EventHeroHpChange)
		end
		
		if oldMp ~= PropertyDictionary:get_MP(hero:getPT()) then
			GlobalEventSystem:Fire(GameEvent.EventHeroMpChange)
		end
	end
end

function EntityActionHandler:handleNet_G2C_OtherPlayer_Attribute(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local entityManager = GameWorld.Instance:getEntityManager()	
	local playerId = StreamDataAdapter:ReadStr(reader)
	local dataLenght = StreamDataAdapter:ReadInt(reader)
	local playerPT = nil
	
	if (dataLenght > 0) then
		playerPT = getPropertyTable(reader)	
	end
	
	if (playerPT == nil) then
		return
	end
	
	local player = entityManager:getEntityObject(EntityType.EntityType_Player,playerId)
	if player then
		player:updatePT(playerPT)
		
		if (player:getState():isState(CharacterState.CharacterStateDead) or player:getState():isState(CharacterState.CharacterStateWillDead)) and PropertyDictionary:get_HP(player:getPT()) > 0 then
			-- 已经复活了, 切换状态
			player:DoRevive()
		end
	else
		player = PlayerObject.New()
		player:setId(playerId)
		player:setPT(playerPT)
	end	
	
	local otherPlayer = {playerObj=player,playerType =1}	--1:其他玩家的信息
	GlobalEventSystem:Fire(GameEvent.EventOtherPlayerProChanged, otherPlayer)			
end

function EntityActionHandler:handleNet_G2C_OtherPlayer_Simple_Attribute(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local playerId = StreamDataAdapter:ReadStr(reader)
	local hp = StreamDataAdapter:ReadInt(reader)
	local maxHP = StreamDataAdapter:ReadInt(reader)
	local entityManager = GameWorld.Instance:getEntityManager()	
	local player = entityManager:getEntityObject(EntityType.EntityType_Player,playerId)
	if player then
		if hp and maxHP then		
			PropertyDictionary:set_maxHP(player:getPT(),maxHP)
			player:setHP(hp)	
			GlobalEventSystem:Fire(GameEvent.EventPlayerHeadUpdate, hp)			
		end
	end
end

function EntityActionHandler:handleNet_G2C_Player_Name_Color(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local playerId = StreamDataAdapter:ReadStr(reader)
	local color = StreamDataAdapter:ReadShort(reader)
	local entityManager = GameWorld.Instance:getEntityManager()	
	local player = entityManager:getEntityObject(EntityType.EntityType_Player,playerId)
	if player then
		PropertyDictionary:set_nameColor(player:getPT(),color)
		player:updateTitleName(player.table)
	end
end

function EntityActionHandler:handleNet_G2C_Monster_OwnerTransfer(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local monsterId = StreamDataAdapter:ReadStr(reader)
	local ownerId = StreamDataAdapter:ReadStr(reader)
	local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	if entityFocusManager then
		entityFocusManager:setBossOwner(monsterId, ownerId)
	end
end

function EntityActionHandler:handleG2C_FindEntity(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	
	local entityType = StreamDataAdapter:ReadChar(reader)
	local entityId = StreamDataAdapter:ReadStr(reader)
	local errorCode = StreamDataAdapter:ReadInt(reader)
	errorCode = 0xFFFFFFFF + errorCode + 1
	
	GameWorld.Instance:getEntityManager():removeObject(entityType, entityId)
end
