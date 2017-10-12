require("object.entity.EffectObject")

SafeRegionObject = SafeRegionObject or BaseClass(EffectObject)

function SafeRegionObject:__init()
	self.type = EntityType.EntityType_Safe_Region
	self.mapLayer = eRenderLayer_SpriteBackground	--添加到地图的层次
end

function SafeRegionObject:__delete()
	
end

function SafeRegionObject:loadModule()
	if self.showSprite == nil then
		self.showSprite = CCSprite:create("res/scene/safe_area.png")
		self.showSprite:setScaleY(-1)
	end
end

function SafeRegionObject:setMapXY(mapX, mapY)
	if self.showSprite ~= nil then
		self.showSprite:setPosition(mapX, mapY)
	end
end

function SafeRegionObject:getMapXY()
	if self.showSprite then
		return self.showSprite:getPositionX(), self.showSprite:getPositionY()
	else
		print ("error: refId"..self.refId)	
	end		
end	

function SafeRegionObject:enterMap()
	self:loadModule()
	
	local sfmap = SFMapService:instance():getShareMap()	
	if sfmap then	
		sfmap:enterMap(self.showSprite, self.mapLayer)
	end
	self:onEnterMap()
end

function SafeRegionObject:addTitle(title,color)

end

function SafeRegionObject:leaveMap()
	if self.showSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.showSprite)
		end
		self:onLeaveMap()
	end
end

function SafeRegionObject:onLeaveMap()

end

