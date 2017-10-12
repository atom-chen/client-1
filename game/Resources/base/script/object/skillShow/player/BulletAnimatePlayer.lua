require "object.skillShow.player.AnimatePlayer"

BulletAnimatePlayer = BulletAnimatePlayer or BaseClass(AnimatePlayer)

function BulletAnimatePlayer:__init()
	self.modelId = 0
	self.speed = 0
	self.targetPosition = ccp(1, 0)
	self.startPos = ccp(0, 0)
	self.renderSprite = nil
	self.name = "BulletAnimatePlayer"
	self.isNeedRotate = false
end

function BulletAnimatePlayer:__delete()
	self:clear()
end

function BulletAnimatePlayer:clear()
	local entityManager = GameWorld.Instance:getEntityManager()
	if self.effectObject then
		self.effectObject:leaveMap()
		entityManager:removeObject(self.effectObject:getEntityType(), self.effectObject:getId())
		self.effectObject:DeleteMe()
		self.effectObject = nil
	end
	
	if self.singleSprite then
		self.singleSprite:release()
		local sfmap = SFMapService:instance():getShareMap()
		sfmap:leaveMap(self.singleSprite)
		self.singleSprite = nil
	end
end

function BulletAnimatePlayer:setPlayAnimate(modelId, startPos, targetPos, speed)
	self.modelId = modelId
	self.targetPosition = targetPos
	self.startPos = startPos
	self.speed = speed
end

function BulletAnimatePlayer:setIsSingleSprite(bIsSingleSprite)
	self.bIsSingleSprite = bIsSingleSprite
end

function BulletAnimatePlayer:getFlyTime()
	local time = 0.3
	if self.speed > 0 then
		time = ccpDistance(self.targetPosition, self.startPos)/self.speed
	end
	
	return time
end

function BulletAnimatePlayer:setNeedRotate(isNeedRotate)
	self.isNeedRotate = isNeedRotate
end

function BulletAnimatePlayer:doPlay()
	
	local entityManager = GameWorld.Instance:getEntityManager()
	
	local sfmap = SFMapService:instance():getShareMap()
	
	local finishCallback = function ()
		self:clear()
	end
	
	if self.bIsSingleSprite == false then
		self.effectObject = entityManager:createEffect()
		self.effectObject:setModuleId(self.modelId)
		self.effectObject:setActionId(0)
		self.effectObject:setResPath("res/skill/")
		self.effectObject:enterMap()
		self.effectObject:setMapXY(self.startPos.x, self.startPos.y)
		
		local time = ccpDistance(self.startPos, self.targetPosition)/self.speed
		self.maxTime = time + 0.1
		local actionMove = CCEaseOut:create(CCMoveTo:create(time, self.targetPosition), 2)
		local callbackAction = CCCallFunc:create(finishCallback)
		
		local actionArray = CCArray:create()
		actionArray:addObject(actionMove)
		actionArray:addObject(callbackAction)
		
		-- 图片默认是向右的
		if self.isNeedRotate then
			local angle = math.atan2(self.startPos.x - self.targetPosition.x, self.startPos.y - self.targetPosition.y)
			local dir = angle * (180 / 3.14159265359)
			dir = dir + 90
			if dir < 0 then
				dir = dir + 360
			end
			dir = dir % 360
			
			self.effectObject:getRenderSprite():setRotation(dir)
		end
		
		self.effectObject:getRenderSprite():runAction(CCSequence:create(actionArray))
	else
		self.singleSprite = CCSprite:create("res/skill/" .. self.modelId .. "_00.pvr")
		if not self.singleSprite then	
			if not self.modelId then
				CCLuaLog("Invalide animateId :  NIL")
			else
				CCLuaLog("Invalide animateId :  " .. self.modelId)
			end
			return
		end
		self.singleSprite:retain()
		sfmap:enterMap(self.singleSprite, eRenderLayer_SpriteBackground)
		self.singleSprite:setPosition(self.startPos.x, self.startPos.y)
		
		local time = ccpDistance(self.startPos, self.targetPosition)/self.speed
		local actionMove = CCEaseOut:create(CCMoveTo:create(time, self.targetPosition), 2)
		local callbackAction = CCCallFunc:create(finishCallback)
		
		local actionArray = CCArray:create()
		actionArray:addObject(actionMove)
		actionArray:addObject(callbackAction)
		
		-- 图片默认是向右的
		if self.isNeedRotate then
			local angle = math.atan2(self.startPos.x - self.targetPosition.x, self.startPos.y - self.targetPosition.y)
			local dir = angle * (180 / 3.14159265359)
			dir = dir + 180
			if dir < 0 then
				dir = dir + 360
			end
			dir = dir % 360
			
			self.singleSprite:setRotation(dir)
		end
		self.singleSprite:runAction(CCSequence:create(actionArray))
	end
end

function BulletAnimatePlayer:doStop()
	
end