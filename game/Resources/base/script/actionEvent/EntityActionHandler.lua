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
		
		local killerCharId = StreamDataAdapter:ReadStr(reader)--��ɱ��
		local killerName = StreamDataAdapter:ReadStr(reader)--��ɱ������
		local killerType = reader:ReadChar()--��ɱ������ (������:0 ����:1 ���:2)
		local killerLevel = reader:ReadInt() --��ɱ�ߵȼ�
		local killerOccupa = reader:ReadChar()--��ɱ��ְҵ(1:սʿ 2:��ʦ 3:��ʿ)
		local killerFightPower = reader:ReadInt() --��ɱ��ս��
		local deadTime = reader:ReadULLong()--����ʱ��(��ɱʱ��)
		local count	 = reader:ReadChar()--�������

		local itemList = {}
		for i=1,count do		
			local itemRefId = StreamDataAdapter:ReadStr(reader)--��ƷrefId
			local itemcount = reader:ReadInt()--��Ʒ�������			
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
	-- ����ȷ��
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if hero == nil then
		return
	end
	
	hero:DoRevive()
	--Juchao@20140514: Ӣ�۸���ʱ������һ��ɳ�Ϳ˹���ʱ�䣬�Ը����Ƿ���ɳ�Ϳ˵�״̬��	
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
		-- ���Ѫ��Ϊ0, ��ʾ�������		
		local newHp = PropertyDictionary:get_HP(hero:getPT())
		if newHp == 0 and not hero:getState():isState(CharacterState.CharacterStateDead) then
			hero:DoDeath()
			GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoKillMonster) 
			GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)
		end
		
		-- ����ض������Ա仯
		if(newLv ~= 0 and newLv ~= curLevel) then
			SFGameAnalyzer:logGameEvent(GameAnalyzeID.HeroLevelChange, "level="..tostring(newLv))       --֪ͨsdk�ȼ������仯
			GlobalEventSystem:Fire(GameEvent.EventHeroLevelChanged,newLv,curLevel)
		end
		
		local newMoveSpeed = PropertyDictionary:get_moveSpeed(hero:getPT())
		if newMoveSpeed > 0 and newMoveSpeed ~= oldMoveSpeed then
			hero:updateSpeed()
		end
		
		-- ����Լ���Ѫ�������ı仯��Ҫ�ر��ע
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
			-- �Ѿ�������, �л�״̬
			player:DoRevive()
		end
	else
		player = PlayerObject.New()
		player:setId(playerId)
		player:setPT(playerPT)
	end	
	
	local otherPlayer = {playerObj=player,playerType =1}	--1:������ҵ���Ϣ
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
