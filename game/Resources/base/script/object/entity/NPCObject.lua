require "object.entity.CharacterObject"
require "object.npc.NpcDef"
require "data.npc.playerNpc"
NPCObject = NPCObject or BaseClass(CharacterObject)


function NPCObject:__init()
	self.type = EntityType.EntityType_NPC
	
	self.moduleId = 0
end

function NPCObject:createModule()
	
end

function NPCObject:loadModule()
end

function NPCObject:leaveMap()
	if not self:isCollect() then
		self.renderSprite = nil
	else
		local sfmap = SFMapService:instance():getShareMap()
		sfmap:leaveMap(self.renderSprite, eMapRenderDelMode_NPC)
		if self.shadowSprite then
			sfmap:leaveMap(self.shadowSprite)
		end
	end
	self:onLeaveMap()
	self.renderSprite = nil
end

function NPCObject:collectEnterMap(mapX, mapY)
	local modeId = G_GetCollectModeIdByRefId(self.refId)
	self.sprite = CCSprite:create("map/collect/".. modeId ..".pvr")
	if  self.sprite then
		local loadCallBack = function ()		
		end
		self.sprite:setScaleY(-1)
		local sfmap = SFMapService:instance():getShareMap()
		self.renderSprite = sfmap:enterMap(self.moduleId,mapX,mapY,loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_NPC)
		self.renderSprite:addChild(self.sprite)
	end
end

function NPCObject:normalEnterMap(mapX, mapY)
	local sfmap = SFMapService:instance():getShareMap()
	if self.moduleId >= 3000 then
		local loadCallBack = function ()
			sfmap:enterMap(self.renderSprite,eRenderLayer_Sprite)
		end
		self.renderSprite = sfmap:enterMap(self.moduleId,mapX,mapY,loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_Monster)
		self:changeAction(EntityAction.eEntityAction_Monster_Idle, true)
		self.renderSprite:setAngle(Dir_D)
		sfmap:enterMap(self.shadowSprite, eRenderLayer_SpriteBackground,true)
	else
		local loadCallBack = function ()
		end
		self.renderSprite = sfmap:enterMap(self.moduleId,mapX,mapY,loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_NPC)
		self:changeAction(EntityAction.eEntityAction_Npc_Idle, true)
	end
end

function NPCObject:changePart(genderType, partId, moduleId,defaultId)
	local x = 0
	local y = 0
	if partId == EntityParts.eEntityPart_Wing then
		y = 47		
	end
	if defaultId then
		if genderType == ModeType.eGenderFemale  and partId == EntityParts.eEntityPart_Weapon then
			self.renderSprite:changePartWithDefault(partId,moduleId,false,defaultId,x,y)
		else
			self.renderSprite:changePartWithDefault(partId,moduleId,true,defaultId,x,y)
		end
	else		
		CCLuaLog("NPCObject:changePart the defaultid is nil")
	end
	
end

function NPCObject:playerModuleEnterMap(mapX, mapY)
	local refId = self:getRefId()
	if GameData.PlayerNpc[refId] then
		local loadCallBack = function ()		
		end
		
		local sfmap = SFMapService:instance():getShareMap()
		self.renderSprite = sfmap:enterMap(self.moduleId,mapX,mapY,loadCallBack, eRenderLayer_Sprite, eMapRenderDelMode_NPC)
		local genderType = GameData.PlayerNpc[refId].property.gender
		local rideModleId = GameData.PlayerNpc[refId].property.rideModleId
		if rideModleId and rideModleId ~= 0 then
			self:changePart(genderType, EntityParts.eEntityPart_Mount,rideModleId,constDefaultMountId)
			self.renderSprite:changeAction(EntityAction.eEntityAction_RideIdle, 1, true)
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Mount,true)
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,false)
		else
			self.renderSprite:changeAction(EntityAction.eEntityAction_Idle, 1, true)
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Mount,false)
			
			-- 没有坐骑才去解析武器
			local weaponId = GameData.PlayerNpc[refId].property.weaponModleId
			if weaponId and weaponId ~= 0 then
				self:changePart(genderType, EntityParts.eEntityPart_Weapon,weaponId,constDefaultWeaponId)
				self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,true)
			else
				self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,false)
			end
		end
		
		local wingModleId = GameData.PlayerNpc[refId].property.wingModleId
		if wingModleId and wingModleId ~= 0 then
			self:changePart(genderType, EntityParts.eEntityPart_Wing,wingModleId,constDefaultWing)
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,true)
		else
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,false)
		end
		
		local direction = GameData.PlayerNpc[refId].property.standTurn
		self.renderSprite:setAngle(direction)
	end
end

function NPCObject:enterMap(x , y)
	local loadCallBack = function ()
	end
	
	local sfmap = SFMapService:instance():getShareMap()
	if sfmap then
		local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(x , y)
		self.shadowSprite:setPosition(mapX,mapY)
		if self:isCollect() then
			self:collectEnterMap(mapX, mapY)
		elseif self:isPlayModule() then
			self:playerModuleEnterMap(mapX, mapY)
		else
			self:normalEnterMap(mapX, mapY)
		end
		self:onEnterMap()
		self:addShadow()
	end
end

function NPCObject:onEnterMap()
	self.bEnterMap = true
	local isCollectFlag = self:isCollect()
	local offset = nil
	if isCollectFlag then
		offset = nil
	else
		offset = ccp(0,-135)
	end
	if not GameWorld.Instance:getTextManager():hasTitle(self.id) then
		local entityManager = GameWorld.Instance:getEntityManager()
		local npcName = " "
		
		if isCollectFlag then
			npcName  = entityManager:getPluckName(self.refId)
		else
			npcName = entityManager:getNPCName(self.refId)
		end
		local size = 16
		local x,y = self:getMapXY()
		if x and y then
			GameWorld.Instance:getTextManager():addTitle(self.id,npcName,size,x,y,ccc3(0,255,255),offset)
		end
	end
	
end

function NPCObject:isCollect()
	local isCollect = false
	if string.find(self.refId,"npc_collect") ~= nil then
		isCollect = true
	end
	return isCollect
end

-- 检测服务器
function NPCObject:isPlayModule()
	local refId = self:getRefId()
	return GameData.PlayerNpc[refId]
end

function NPCObject:onUpdateQuestState(state)
	--清除状态
	local removeSprite = function ()
		if self.sign~=nil then
			self.sign:removeFromParentAndCleanup(true)
			self.sign = nil
		end
	end
	
	--设置状态
	local createSprite = function (sName,state)
		removeSprite()
		
		self.sign = createSpriteWithFrameName(sName)
		if 	self.sign then
			if state == QuestState.eAcceptedQuestState then
				UIControl:SpriteSetGray(self.sign)
			else
				UIControl:SpriteSetColor(self.sign)
			end
			self.sign:setScaleY(-1)
			self.renderSprite:addChild(self.sign)
			self.sign:setPosition(0,-180)
		end
	end
	
	if state == QuestState.eUnvisiableQuestState then--任务不可见
		removeSprite()
	elseif state == QuestState.eVisiableQuestState then--任务可接
		createSprite(RES("quest_state1.png"),state)
	elseif state == QuestState.eAcceptableQuestState then--任务可接
		createSprite(RES("quest_state1.png"),state)
	elseif state == QuestState.eAcceptedQuestState then--任务已接，但未完成
		createSprite(RES("quest_state2.png"),state)
	elseif state == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交
		createSprite(RES("quest_state2.png"),state)
	elseif state == QuestState.eCompletedQuestState then--任务已经完成。已经提交领取奖励
		removeSprite()
	end
end

function NPCObject:setArrow()
	if self.arrow then
		return
	end
	
	local function callback()
		self:hideArrow()
	end
	self.arrow = createArrow(direction.down,callback)
	self.arrow:getRootNode():setScaleY(-1)
	self.renderSprite:addChild(self.arrow:getRootNode())
	self.arrow:getRootNode():setPosition(-45,-130)
end

function NPCObject:hideArrow()
	if self.arrow then
		self.arrow:getRootNode():removeFromParentAndCleanup(true)
		self.arrow:DeleteMe()
		self.arrow = nil
	end
end

function NPCObject:hadArrow()
	if self.arrow then
		return true
	else
		return false
	end
end