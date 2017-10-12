require "object.skillShow.player.AnimatePlayer"

ArenaBulletAnimatePlayer = ArenaBulletAnimatePlayer or BaseClass(AnimatePlayer)

function ArenaBulletAnimatePlayer:create()
	local player = ArenaBulletAnimatePlayer.New()
	return player
end

function ArenaBulletAnimatePlayer:__init(root,modelId, startPos, distance, speed)
	self.name = "ArenaBulletAnimatePlayer"
	self.modelId = modelId
	self.startPos = startPos
	self.distance = distance
	self.speed = speed
	self.root = root
	self.isNeedRotate = true
end

function ArenaBulletAnimatePlayer:__delete()
	self:clear()
end

function ArenaBulletAnimatePlayer:clear()
	if self.effectObject then
		if self.root then
			self.root:removeChild(self.effectObject.renderSprite,true)
		end
		self.effectObject:DeleteMe()
		self.effectObject = nil
		self.root = nil
	end
end

function ArenaBulletAnimatePlayer:doPlay()
	local entityManager = GameWorld.Instance:getEntityManager()
	
	local finishCallback = function ()
		self:clear()
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
	self.effectObject = entityManager:createEffect()
	self.effectObject:setModuleId(self.modelId)
	self.effectObject:setActionId(0)
	self.effectObject:setResPath("res/skill/")
	self.effectObject:loadModule()
	self.effectObject:setMapXY(self.startPos.x, self.startPos.y+50)
	
	local actionMove = CCMoveBy:create(self.speed,ccp(self.distance,0))
	local callbackAction = CCCallFunc:create(finishCallback)
	
	local actionArray = CCArray:create()
	actionArray:addObject(actionMove)
	actionArray:addObject(callbackAction)
	
	-- 图片默认是向右的
	if self.distance < 0 then
		self.effectObject:getRenderSprite():setRotation(180)
	end
	if self.root then
		self.root:addChild(self.effectObject.renderSprite)
	end
	self.effectObject:getRenderSprite():runAction(CCSequence:create(actionArray))
end

