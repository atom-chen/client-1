require("object.entity.EntityObject")

EffectObject = EffectObject or BaseClass(EntityObject)

function EffectObject:__init()
	self.type = EntityType.EntityType_Effect
	self.actionId = 0
	self.handler = nil	-- 动画的回调
	self.path = "res/"
	self.scaleX = 1
	self.scaleY = 1
	self.zOrder = 0
	self.mapLayer = eRenderLayer_SpriteBackground	--添加到地图的层次
	self.rotation = 0
	self.cellX = 0
	self.cellY = 0
	self.offset = ccp(0, 0)
	self.animateSpeed = 1
end

function EffectObject:__delete()
	
end

function EffectObject:setActionId(actionId)
	if actionId then
		self.actionId  = actionId
	end
end

function EffectObject:createModule()
	self.renderSprite = nil
end

function EffectObject:setResPath(path)
	self.path = path
end

function EffectObject:setScaleX(scaleX)
	self.scaleX = scaleX
end

function EffectObject:setScaleY(scaleY)
	self.scaleY = scaleY
end

function EffectObject:setMapLayer(mapLayer)
	self.mapLayer = mapLayer
end

function EffectObject:setZOrder(zOrder)
	if zOrder then
		self.zOrder = zOrder
	end
end

function EffectObject:loadModule()
	if self.renderSprite == nil then
		self.renderSprite = SFRenderSprite:createRenderSprite(self.moduleId, self.actionId, self.path)
		self.renderSprite:setScaleX(self.scaleX)
		self.renderSprite:setScaleY(-1*self.scaleY)
		self.renderSprite:setZOrder(self.zOrder)
		self.renderSprite:retain()		
		
		if self.handler then
			self.renderSprite:setScriptHandler(self.handler)			
		end
		
		self.renderSprite:playByIndexLua(0)
		--self.renderSprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureGray"))
	end
end

function EffectObject:onLeaveMap()
	--EntityObject.onLeaveMap(self)
	if self.renderSprite then
		self.renderSprite:release()
		self.renderSprite = nil
	end
end

function EffectObject:enterMap()
	self:loadModule()
	
	local sfmap = SFMapService:instance():getShareMap()	
	if sfmap then
--[[		if self.mapLayer == eRenderLayer_SpriteBackground then
			sfmap:enterMap(self.renderSprite, self.mapLayer,true)
		else
			sfmap:enterMap(self.renderSprite, self.mapLayer)
		end--]]
		sfmap:enterMap(self.renderSprite, self.mapLayer)
	end
	--sfmap:enterMap(self.renderSprite, eRenderLayer_SpriteBackground)	
	--self:changeAction(self.actionId, true)
	self:onEnterMap()
end

function EffectObject:addTitle(title,color)
	local label = createLabelWithStringFontSizeColorAndDimension(title, "Arial", 14,color)
	self.renderSprite:addChild(label)
	local point = self:getUperPosition(size)
	label:setPositionY(110)
end

function EffectObject:setScriptHandler(handler)
	self.handler = handler
end
