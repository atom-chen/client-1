--[[
怪物的仿真类
]]
require"data.monster.playerMonster"
require"data.monster.monster"	
require "config.MonstorConfig"
require("object.actionPlayer.ActionPlayerMgr")
require("object.actionPlayer.FightCharacterActionPlayer")
require("object.actionPlayer.MoveActionPlayer")
require("object.actionPlayer.ActionPlayerMgr")

local monsterFaceMask = {}
monsterFaceMask["0,-1"] = 4
monsterFaceMask["-1,-1"] = 5
monsterFaceMask["-1,0"] = 6
monsterFaceMask["-1,1"] = 7
monsterFaceMask["0,1"] = 0
monsterFaceMask["1,1"] = 1
monsterFaceMask["1,0"] = 2
monsterFaceMask["1,-1"] = 3
monsterFaceMask["0,0"] = 4

PlayerMonsterObject = PlayerMonsterObject or BaseClass(MonsterObject)

function PlayerMonsterObject:__init()
	self.type = EntityType.EntityType_Monster
	self.moduleScale = 1
	self.ownerId = ""	
	--self:DoIdle()
end

function PlayerMonsterObject:__delete()
	
end	

function PlayerMonsterObject:enterStateIdle()
	-- 怪物的idle和玩家的actionId不同
	if self.type == EntityType.EntityType_Monster then
		self:changeAction(EntityAction.eEntityAction_Idle, true)
	else
		self:changeAction(EntityAction.eEntityAction_Idle, true)
	end		
	return true
end

function PlayerMonsterObject:setModuleScale(scale)
	if scale and scale > 0 then
		self.moduleScale = scale / 100
	end
end


function PlayerMonsterObject:loadModule()
	if self.renderSprite ~= nil then
		if type(self.moduleId) == "string" then
			self.renderSprite:load(tonumber(self.moduleId),constMonsterDefaultId)
		else
			self.renderSprite:load(self.moduleId)		
		end
		self:updateModule()
	end
end	

function PlayerMonsterObject:updateWeaponModule()
	local playerMonsterData = GameData.PlayerMonster
	local weaponId = playerMonsterData[self.refId].property.weaponId
	self.weaponId = weaponId
	if weaponId ~= 0 and  not self.hasMount then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,true)
		self:changePart(EntityParts.eEntityPart_Weapon,weaponId,constDefaultWeaponId)
	else
		self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,false)
	end
end

function PlayerMonsterObject:changePart(partId,moduleId,defaultId)
	local genderType = 2
	if defaultId then
		if genderType == ModeType.eGenderFemale  and partId == EntityParts.eEntityPart_Weapon then
			self.renderSprite:changePartWithDefault(partId,moduleId,false,defaultId)
		else
			self.renderSprite:changePartWithDefault(partId,moduleId,true,defaultId)
		end
	else
		if genderType == ModeType.eGenderFemale  and partId == EntityParts.eEntityPart_Weapon then
			self.renderSprite:changePart(partId,moduleId,false)
		else
			self.renderSprite:changePart(partId,moduleId,true)
		end
	end
	
end


function PlayerMonsterObject:updateModule()
	if self.renderSprite ~= nil then	
		self:updateWeaponModule()
		self:updateWingModule()
		local entityManager = GameWorld.Instance:getEntityManager()
		local name = entityManager:getMonsterName(self.refId)
		self:setTitleVisible(true)
		self:setTitleName(name)	
	end
end	

function PlayerMonsterObject:updateWingModule()
	local playerMonsterData = GameData.PlayerMonster
	local wingId =  playerMonsterData[self.refId].property.wingId	
	self.wingId = wingId
	if wingId ~= 0 then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,true)
		self:changePart(EntityParts.eEntityPart_Wing,wingId,constDefaultWing)
	else
		self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,false)
	end
end	

-- 武器模型ID
function PlayerMonsterObject:setWeaponId(weaponId)
	self.weaponId = weaponId
	--	CCLuaLog("PlayerMonsterObject:setWeaponId:"..weaponId)
end

function PlayerMonsterObject:getWeaponId()
	return self.weaponId
end

-- 衣服模型ID
function PlayerMonsterObject:setClothId(clothId)
	self.clothId = clothId
end

function PlayerMonsterObject:getClothId()
	return self.clothId
end

-- 翅膀模型ID
function PlayerMonsterObject:setWingId(wingId)
	self.wingId = wingId
end

function PlayerMonsterObject:getWingId()
	return self.wingId
end

function PlayerMonsterObject:setTitleName(text)
	local id = self:getId()
	if not GameWorld.Instance:getTextManager():hasTitle(id) then	
		local x,y = self:getMapXY()
		local offset = ccp(0,-50)	
		local size = GameWorld.Instance:getTextManager():addTitle(id,text,FSIZE("Size1"),x,y,FCOLOR("ColorRed1"),offset)
		self.titleSize = size
	end	
end

function PlayerMonsterObject:onEnterMap()
	self.state:updateComboStateList(self.stateTable)
	self:updateModule()
	local dir = 0
	if Simple_Dir_MonstorConfig[self:getModuleId()] == true then 
		--dir = 0
	else
		dir = math.random(8)
	end
	
	self.renderSprite:setAngle(dir)	
	self:clearEffect()
	FightCharacterObject.onEnterMap(self)
end

-- 死亡状态
function PlayerMonsterObject:enterDeath(effectId)
	local loadCallBack = function ()
	end
	
	-- 显示一个场景的死亡动画
	self:clearEffect()
	
	-- 重置所有的组合状态
	self.state:updateComboStateList(nil)
	local cellX, cellY = self:getCellXY()
	--看需要不要播放
	if SkillShowManager:getDisplayEffect() then
		if effectId == nil then
			effectId = 8011
		end
		local deathPlayer =  MapAnimatePlayer.New()	
		deathPlayer:setPlayData(cellX, cellY, effectId)
		deathPlayer:setResPath("res/scene/")
		GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", deathPlayer)
	end
	
	local sfmap = SFMapService:instance():getShareMap()	
	
	local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(cellX , cellY)
	self.graveImage = createSpriteWithFileName("ui/ui_img/common/gravestone.png")
	if self.graveImage then
		self.graveImage:setScaleY(-1)
		self.sprite = sfmap:enterMap(1, mapX, mapY, loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_NPC)
		self.sprite:addChild(self.graveImage)
	end	
	return true
end
