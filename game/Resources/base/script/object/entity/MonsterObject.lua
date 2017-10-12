--[[
怪物的仿真类
]]
require("object.entity.FightCharacterObject")
require"data.monster.monster"	
require "config.MonstorConfig"
require("object.actionPlayer.ActionPlayerMgr")
require("object.actionPlayer.FightCharacterActionPlayer")
require("object.actionPlayer.MoveActionPlayer")
require("object.actionPlayer.ActionPlayerMgr")
require("config.MonsterSoundConfig")

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

MonsterObject = MonsterObject or BaseClass(FightCharacterObject)

function MonsterObject:__init()
	self.type = EntityType.EntityType_Monster
	self.moduleScale = 1
	self.ownerId = ""
end

function MonsterObject:__delete()
	self.unionNameLabel = nil
end

function MonsterObject:createModule()
	
end

function MonsterObject:enterStateIdle()
	-- 怪物的idle和玩家的actionId不同
	if self.type == EntityType.EntityType_Monster then
		self:changeAction(EntityAction.eEntityAction_Monster_Idle, true)
	else
		self:changeAction(EntityAction.eEntityAction_Idle, true)
	end
	
	return true
end

function MonsterObject:setModuleScale(scale)
	if scale and scale > 0 then
		self.moduleScale = scale / 100
	end
end


function MonsterObject:loadModule()
	if self.renderSprite ~= nil then
		if type(self.moduleId) == "string" then
			self.renderSprite:load(tonumber(self.moduleId),constMonsterDefaultId)
		else
			self.renderSprite:load(self.moduleId,constMonsterDefaultId)
		end
	end
end

function MonsterObject:enterMap(x,y)
	local sfmap = SFMapService:instance():getShareMap()
	local loadCallBack = function (node,layer)		
		SFMapService:instance():getShareMap():enterMap(self.renderSprite, eRenderLayer_Sprite)
	end		
	if sfmap then
		local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(x , y)
		self.renderSprite = sfmap:enterMap(self.moduleId, mapX, mapY, loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_Monster)
		self.renderSprite:setEnableOpacity(true)
		self.bEnterMap = true
		self.renderSprite:setOpacity(0)
		local fadeIn = CCFadeIn:create(constMonsterFadeInDuration)
		self.renderSprite:runAction(fadeIn)
		self:onEnterMap(x,y)	
		--self.renderSprite
		--SFMapService:instance():getShareMap():enterMap(self.renderSprite, eMapRenderDelMode_Monster)
		GlobalEventSystem:Fire(GameEvent.EventEntityAdded, self)	
	end
	self:addShadow()	
end

function MonsterObject:enterMapAsycn(x,y)
	local sfmap = SFMapService:instance():getShareMap()
	local loadCallBack = function (node,layer)		
		self.renderSprite:setEnableOpacity(true)
		self.bEnterMap = true
		self.renderSprite:setOpacity(0)
		local fadeIn = CCFadeIn:create(constMonsterFadeInDuration)
		self.renderSprite:runAction(fadeIn)
		sfmap:enterMap(self.renderSprite,layer)
		self:onEnterMap(x,y)
		GlobalEventSystem:Fire(GameEvent.EventEntityAdded, self)	
		self:addShadow()
	end		
	if sfmap then
		--local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(x , y)
		self.renderSprite = sfmap:enterMap(self.moduleId, self.x, self.y, loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_Monster)
	
		--self.renderSprite
		--SFMapService:instance():getShareMap():enterMap(self.renderSprite, eMapRenderDelMode_Monster)
		--GlobalEventSystem:Fire(GameEvent.EventEntityAdded, self)	
	end
		
end

function MonsterObject:setTitleVisible(show)
	local textMgr = GameWorld.Instance:getTextManager()
	if show == true then
		local refId = self.refId
		--鹰的头衔位置要特殊处理 todo
		if refId == "monster_10" then		
		end
		self.selected = show			
		self:initHPProgressBars()
		local selFlag = self:getSelFlag()
		if selFlag then
			self:setSelectEffect(true)
		end
		textMgr:setTiltleVisible(self:getId(), true)
	else		
		self:setSelFlag(true)
		self:setSelectEffect(false)		
		textMgr:setTiltleVisible(self:getId(), false)
	end
end

function MonsterObject:onEnterMap(x,y)
	self.state:updateComboStateList(self.stateTable)	
	local dir = 0
	if  not Simple_Dir_MonstorConfig[self:getModuleId()] then 	
		dir = math.random(8)
	end
	
	self.renderSprite:setAngle(dir)
	self:setTitleVisible(true)
	if self:isBoss() or (self:isElite() and not self:hasOwner()) or self:isHeroPet() then
		local name = PropertyDictionary:get_name(GameData.Monster[self:getRefId()].property)
		local level = PropertyDictionary:get_level(GameData.Monster[self:getRefId()].property)		
		if name and level then
			if self:hasOwner() then	--如果是召唤兽
				local ownerId = self:getOwnerId()
				local entityManager = GameWorld.Instance:getEntityManager()	
				local player = entityManager:getEntityObject(EntityType.EntityType_Player,ownerId)
				if player then
					local ownerName = PropertyDictionary:get_name(player:getPT())
					self:setTitleName("("..ownerName..")"..name.." lv."..level)
				end
			else
				self:setTitleName(name.." lv."..level)
			end
		end				
	end	
	
	if self.moduleScale then
		self.renderSprite:setScale(self.moduleScale)
	end
	self:clearEffect()
	FightCharacterObject.onEnterMap(self,x,y)
end

function MonsterObject:DoShowAttackAction(actionId, callback)
	-- 如果在移动中,  要先打断目前的移动，表演完工作再继续移动
	local ret = false
	
	if  self.state:isState(CharacterState.CharacterStateMove) then
		local targetX = self.moveTargetX
		local targetY = self.moveTargetY
		self:moveStop()
		
		-- 先移除所有的action
		if ActionPlayerMgr.Instance:getPlayersByGroup(self:getId()) ~= nil then
			ActionPlayerMgr.Instance:removePlayersByGroup(self:getId())
		end
		
		-- 判断是否在48的中心格子
--[[	注释 避免召唤兽特效与朝向不一致
		local cellX, cellY = self:getCellXY()
		local newTargetX, newTargetY = GameWorld.Instance:getMapManager():convertToAoiCell(cellX, cellY)
		if cellX ~= newTargetX or cellY ~= newTargetY then
			-- 不在中心格子，先移动到中心格子再攻击
			--print("1!!!!!"..self.id.." cell:"..cellX..","..cellY.."aoi:"..newTargetX..","..newTargetY)
			local moveAction1 = MoveActionPlayer.New()
			moveAction1:setCellXY(newTargetX, newTargetY)
			moveAction1:setCharacter(self:getId(), self:getEntityType())
			ActionPlayerMgr.Instance:addPlayer(self:getId(), moveAction1)
		end--]]
		
		local fightAction = FightCharacterActionPlayer.New()
		fightAction:setPlayAction(self:getId(), self:getEntityType(), ActionType.ActionTypeAttack, actionId)
		ActionPlayerMgr.Instance:addPlayer(self:getId(), fightAction)
		
		-- 如果target的位置和自己不同，要添加一个moveAction
		--print("2!!!!!!"..self.id.." cell:"..cellX..","..cellY.."target:"..targetX..","..targetY)
		local moveAction2 = MoveActionPlayer.New()
		moveAction2:setCellXY(targetX, targetY)
		moveAction2:setCharacter(self:getId(), self:getEntityType())
		ActionPlayerMgr.Instance:addPlayer(self:getId(), moveAction2)
		
		ret = true
	elseif callback == nil then
		-- 有可能前面已经有了一个fight的action，攻击全部放到队列进行
		local fightAction = FightCharacterActionPlayer.New()
		fightAction:setPlayAction(self:getId(), self:getEntityType(), ActionType.ActionTypeAttack, actionId)
		ActionPlayerMgr.Instance:addPlayer(self:getId(), fightAction)
		ret = true
	else
		if self.state:canChange(CharacterState.CharacterStateUseSkill) == true then
			self.state:changeState(CharacterState.CharacterStateUseSkill, actionId, callback)
			ret = true
		end
	end
	
	return ret
end

function ripairs(t)
	local max = 1
	while t[max] ~= nil do
		max = max + 1
	end
	local function ripairs_it(t, i)
		i = i-1
		local v = t[i]
		if v ~= nil then
			return i,v
		else
			return nil
		end
	end
	return ripairs_it, t, max
end

function MonsterObject:DoAoiMove(cellX, cellY)
	self.moveTargetX = cellX
	self.moveTargetY = cellY
	
	if self.bEnterMap == false then
		self.targetX = cellX
		self.targetY = cellY
	else
		-- 先查找是否有MoveActionPlayer
		local bFind = false
		local monsterActionList = ActionPlayerMgr.Instance:getPlayersByGroup(self:getId())
		if monsterActionList then
			for k,v in ripairs(monsterActionList) do
				if v:getDes() == "MoveActionPlayer" and v:getState() == E_ActionPlayerState.Waiting then
					-- 已经找到了moveAction, 不需要添加新的action， 修改这个action的目标就可以					
					v:setCellXY(cellX, cellY)
					--print("find move action player:"..playerX..", "..playerY..", cell:"..cellX..", "..cellY)
					bFind = true
					break
				end
			end
		end
		
		if not bFind then
			self:moveTo(cellX, cellY)
		end
	end
end

function MonsterObject:moveTo(x, y)
	--print("MonsterObject moveTo:"..self.id..", "..x..", "..y)
	self.moveX = x
	self.moveY = y
	local ret = false
	if self.bEnterMap == false then
		-- 还没enterMap, 先保存坐标, enterMap后再进行移动
		self.targetX = x
		self.targetY = y
		ret = true
	else
		local cellX, cellY = self:getCellXY()
		if (cellX == x and cellY == y) or (self.targetX == x and self.targetY == y) then
			ret = false
		else
			if self.state:isState(CharacterState.CharacterStateMove) then
				-- 已经在移动了, 直接改变寻路坐标				
				ret = self:fightCharacterMoveTo(x,y)
				
				-- 如果怪物不在移动的action, 再改变一次
				if self.renderSprite:getActionId() ~= EntityAction.eEntityAction_Run then
					self:changeAction(EntityAction.eEntityAction_Run, true)
				end
			elseif self.state:isState(CharacterState.CharacterStateUseSkill) then
				-- 如果正在攻击, 等攻击完成了再进行移动,  保证战斗过程的完整性
				local moveAction = MoveActionPlayer.New()
				moveAction:setCellXY(x, y)
				moveAction:setCharacter(self:getId(), self:getEntityType())
				ActionPlayerMgr.Instance:addPlayer(self:getId(), moveAction)
				
			else
				ret = self.state:changeState(CharacterState.CharacterStateMove, x, y)
			end
		end
	end	
	return ret
end

-- 播放击飞
function MonsterObject:DoShowHitFly(cellX, cellY, callback)
	-- 如果在攻击中，强制停止攻击动作
	-- 先移除所有的action
	self:setTitleVisible(false)	
	if ActionPlayerMgr.Instance:getPlayersByGroup(self:getId()) ~= nil then
		ActionPlayerMgr.Instance:removePlayersByGroup(self:getId())
	end
	
	if self.state:isState(CharacterState.CharacterStateUseSkill) then
		self.state:forceChangeState(CharacterState.CharacterStateHitFly, cellX, cellY, callback)
		return true
	elseif self.state:canChange(CharacterState.CharacterStateHitFly) == true then
		-- 如果在移动中，中断移动，直接从当前坐标开始表演击飞
		if self.state:isState(CharacterState.CharacterStateMove) then
			self:fightCharacterMoveStop()
		end
		
		return self.state:changeState(CharacterState.CharacterStateHitFly, cellX, cellY, callback)
	else
		return false
	end
end

function MonsterObject:DoShowHitBack(cellX, cellY, callback)
	-- 先移除所有的action
	if ActionPlayerMgr.Instance:getPlayersByGroup(self:getId()) ~= nil then
		ActionPlayerMgr.Instance:removePlayersByGroup(self:getId())
	end		
	
	if self.state:canChange(CharacterState.CharacterStateHitBack) == true then
		-- 如果在移动中，中断移动，直接从当前坐标开始表演击退
		if self.state:isState(CharacterState.CharacterStateMove) then
			self:fightCharacterMoveStop()			
		end

		
		return self.state:changeState(CharacterState.CharacterStateHitBack, cellX, cellY, callback)
	else
		return false
	end
end

function MonsterObject:leaveMap()
	if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		sfmap:leaveMap(self.renderSprite,eMapRenderDelMode_Monster)
	end
	self:onLeaveMap()
end

function MonsterObject:onLeaveMap()
	if self.shadowSprite then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.shadowSprite)
		end
	end
	GameWorld.Instance:getTextManager():removeTilte(self:getId())	
	self.renderSprite = nil
	self.bEnterMap = false
end

function MonsterObject:setOwnerId(ownerId)
	self.ownerId = ownerId	
	if self:hasOwner() then
		if ownerId == G_getHero():getId() then
			G_getHero():setPet(self.id)
		else
			local obj = self:getOwnerObj()
			if obj then
				obj:setPet(self.id)
			end
		end
	end
end

function MonsterObject:getOwnerObj()
	return GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player, self:getOwnerId())
end

function MonsterObject:getOwnerId()
	return self.ownerId
end

function MonsterObject:hasOwner()
	return (self.ownerId and self.ownerId ~= "")
end

function MonsterObject:updateNameColor()
	
	if G_getCastleWarMgr():isInCastleWar() then
		GameWorld.Instance:getTextManager():updateColor(self.id,FCOLOR("ColorBlue2"))
	else
		local quantity = PropertyDictionary:get_quality(GameData.Monster[self:getRefId()].property)
		local level = PropertyDictionary:get_level(GameData.Monster[self:getRefId()].property)
		if self:hasOwner() then
			if level >=1 and level <=7 then	
				GameWorld.Instance:getTextManager():updateColor(self.id,FCOLOR("ColorBlue"..tostring(level)))
			end
		elseif quantity == EntityMonsterType.EntityMonster_Boss then
			GameWorld.Instance:getTextManager():updateColor(self.id,FCOLOR("ColorRed1"))	
		elseif quantity == EntityMonsterType.EntityMonster_Elite then
			GameWorld.Instance:getTextManager():updateColor(self.id,FCOLOR("ColorOrange3"))		
		else
			FightCharacterObject.updateNameColor(self)
		end
	end
		
end				

function MonsterObject:enterWillDeath()
	self:moveStop()
	if Config.Sound[self:getRefId()] then
		local soundData = Config.Sound[self:getRefId()]
		if soundData.death then
			local soundMgr = GameWorld.Instance:getSoundMgr()
			soundMgr:playEffect(soundData.death, false)		
		end
	end	
	-- 清楚actionPlayerManager对应的action
	GameWorld.Instance:getTextManager():removeTilte(self.id)
	ActionPlayerMgr.Instance:removePlayersByGroup(self.id)
	return true
end	

--[[function MonsterObject:tick(time)
if self.renderSprite == nil then
	return
end

FightCharacterObject.tick(self, time)

local cellX, cellY = self:getCellXY()
local targetX = self.moveTargetX
local targetY = self.moveTargetY
if not self.state:isState(CharacterState.CharacterStateMove) and  targetX ~=0 and targetY ~= 0 and (cellX ~= targetX or cellY ~= targetY) then
	--debugPrint("MonsterObject:tick"..self.id)
	self.renderSprite:setScale(2)
elseif self.renderSprite:getScaleX() > 1 and self.renderSprite:getScaleY() > 1 then
	self.renderSprite:setScale(1)
end
end]]
--zhanxianbo 怪物面向玩家


function MonsterObject:faceToHero()
	if self:getId() == GameWorld.Instance:getEntityManager():getHero():getPet()  then
		return
	end
	local data = GameData.Monster[self:getRefId()]
	if data then
		local attactType = PropertyDictionary:get_attackType(data.property)
		if attactType == 1 then
			local x,y = GameWorld.Instance:getEntityManager():getHero():getCellXY()
			local selfX,selfY = self:getCellXY()
			local dx = x - selfX
			local dy = selfY - y
			local dxFlag = dx
			if dxFlag ~= 0 then
				dxFlag = dx / math.abs(dx)
			end
			
			local dyFlag = dy
			if dyFlag ~= 0 then
				dyFlag = dy / math.abs(dy)
			end

			local key = dxFlag..","..dyFlag
			local dir = monsterFaceMask[key]
			
				self.renderSprite:setAngle(dir)
		end
	end
	
end

--设置名字，已有则改字符串，没有则新建
function MonsterObject:setTitleName(text)
	local id = self:getId()
	if not GameWorld.Instance:getTextManager():hasTitle(id) then	
		local x,y = self:getMapXY()
		local offset = ccp(0,-130)
		if refId == "monster_10" then
			offset = ccp(0,-150)		
		end			
		local size = GameWorld.Instance:getTextManager():addTitle(id,text,FSIZE("Size1"),x,y,nil,offset)
		self.titleSize = size
		self:updateNameColor()	
	end	
end	

function MonsterObject:setUnionName(name)
--[[	if not self.unionNameLabel then
		self.unionNameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size1"), FCOLOR("ColorWhite1"))
		self.renderSprite:addChild(self.unionNameLabel)
		VisibleRect:relativePosition(self.unionNameLabel, self.nameTextLabel, LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE, ccp(0, 10))
		self.unionNameLabel:setColor(self.nameTextLabel:getColor())
		self.unionNameLabel:setAnchorPoint(ccp(0.5, 0))	
	end
	self.unionNameLabel:setString(name)	--]]	
	if name ~= "" then
		if not self.unionNameLabel then
			local offset = self:getTitleOffset()
			self.unionNameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size1"), FCOLOR("ColorBlue2"))
			self.renderSprite:addChild(self.unionNameLabel)			
			self.unionNameLabel:setScaleY(-1)
			self.unionNameLabel:setAnchorPoint(ccp(0.5, 0))
			self.unionNameLabel:setPosition(ccp(0,-130+35))	
		end
		self.unionNameLabel:setString(name)	
	end
	
end

function MonsterObject:exitDeath()
	self:updateNameColor()
	return true
end

--是否为boss
function MonsterObject:isBoss()
	local staticData = GameData.Monster[self:getRefId()]
	if  not staticData or  not staticData.property then
		return false
	end 
	local quantity = PropertyDictionary:get_quality(staticData.property)	
			
	if quantity == EntityMonsterType.EntityMonster_Boss then
		return true
	else
		return false
	end
end

--是否为精英怪
function MonsterObject:isElite()
	local staticData = GameData.Monster[self:getRefId()]
	if  not staticData or  not staticData.property then
		return false
	end 
	local quantity = PropertyDictionary:get_quality(staticData.property)
	
	if quantity == EntityMonsterType.EntityMonster_Elite then
		return true
	else
		return false
	end
end

--是否为英雄宝宝
function MonsterObject:isHeroPet()
	local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
	
	if self:hasOwner() and self:getOwnerId() == heroId then
		return true
	else
		return false
	end
end









