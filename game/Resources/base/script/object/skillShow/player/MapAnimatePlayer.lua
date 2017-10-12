require "object.skillShow.player.AnimatePlayer"
require "object.entity.EffectObject"
require "config.animate"

MapAnimatePlayer = MapAnimatePlayer or BaseClass(AnimatePlayer)

function MapAnimatePlayer:__init()
	self.cellX = 0
	self.cellY = 0
	self.direction = 0	-- 8方向
	self.animateId = 0
	self.effectObject = nil
	self.offset = ccp(0, 0)
	self.mapLayer = eRenderLayer_SpriteBackground
	self.name = "MapAnimatePlayer"
	self.rotation = 0			-- 方向
	self.animateSpeed = 1
	self.scale = 1
	self.zOrder = 0
	self.rootPath = "res/skill/"
end

function MapAnimatePlayer:__delete()
	self:clear()
end

function MapAnimatePlayer:clear()
	if self.effectObject then
		local entityManager = GameWorld.Instance:getEntityManager()
		entityManager:removeObject(self.effectObject:getEntityType(), self.effectObject:getId())
					
		SkillShowManager:getMapEffectPresenter():removeMapEffect(self.animateId, self.effectObject)
		
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		self.effectObject:DeleteMe()
		self.effectObject = nil
	end
end

function MapAnimatePlayer:setZOrder(order)
	if order then
		self.zOrder = order
	end
end

function MapAnimatePlayer:setScale(scale)
	if scale and type(scale) == "number" and scale > 0 then
		self.scale = scale
	end
end

function MapAnimatePlayer:setResPath(path)
	if path then
		self.rootPath = path
	end
end

function MapAnimatePlayer:setAnimateSpeed(speed)
	if speed then
		self.animateSpeed = speed
	end
end

function MapAnimatePlayer:setRotation(rotation)
	self.rotation = rotation
end

function MapAnimatePlayer:setMapLayer(mapLayer)
	self.mapLayer = mapLayer
end

function MapAnimatePlayer:getMapLayer()
	return self.mapLayer
end

function MapAnimatePlayer:setOffset(offset)
	if offset ~= nil then
		self.offset = offset
	end
end

function MapAnimatePlayer:setDirection(direction)
	self.direction = direction
end

function MapAnimatePlayer:setPlayData(cellX, cellY, animateId)
	self.cellX = cellX
	self.cellY = cellY
	self.animateId = animateId
end

function MapAnimatePlayer:doPlay()
	local mapEffectPresenter = SkillShowManager:getMapEffectPresenter()
	if not mapEffectPresenter:canShowEffect(self.animateId) then
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		return
	end
	
	local entityManager = GameWorld.Instance:getEntityManager()
	
	local animateCallback = function (actionId, movementType)
		self:clear()
	end
	
	local scaleX = 1
	local actionId = self.direction
	if actionId > 4 then
		actionId = 8- actionId
		scaleX = -1
	end
	
	self.effectObject = entityManager:createEffect()
	self.effectObject:setModuleId(self.animateId)
	self.effectObject:setActionId(actionId)
	self.effectObject:setScriptHandler(animateCallback)
	self.effectObject:setResPath(self.rootPath)
	self.effectObject:setScaleX(scaleX*self.scale)
	self.effectObject:setScaleY(self.scale)
	self.effectObject:setMapLayer(self.mapLayer)
	self.effectObject:setZOrder(self.zOrder)
	
	-- 提交显示
	if mapEffectPresenter:showMapEffect(self.animateId, self.effectObject) then
		self.effectObject:setCellXY(self.cellX, self.cellY)
		self.effectObject:getRenderSprite():setRotation(self.rotation)
		self.effectObject:getRenderSprite():setAnimationSpeed(self.animateSpeed)
		
		if self.offset then
			local mapX, mapY = self.effectObject:getMapXY()
			self.effectObject:setMapXY(mapX+self.offset.x, mapY+self.offset.y)
		end
	else
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		self.effectObject:DeleteMe()
		self.effectObject = nil
	end
end

function MapAnimatePlayer:doStop()
	
end