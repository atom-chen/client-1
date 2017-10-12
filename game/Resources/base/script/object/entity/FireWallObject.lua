--[[
��ǽ�������Թ���ķ�ʽģ��, ����Ҫ���⴦��һ�� 
]]

require("object.entity.MonsterObject")
FireWallObject = FireWallObject or BaseClass(MonsterObject)

function FireWallObject:__init()
	--self.mapLayer = eRenderLayer_SpriteBackground
end

function FireWallObject:__delete()
	
end

function FireWallObject:createModule()
	self.renderSprite = SFRenderSprite:createRenderSprite(7130, 0, "res/skill/")
	self.renderSprite:setScaleY(-1)
	self.renderSprite:retain()
	self.renderSprite:playByIndexLua(0)
end

function FireWallObject:loadModule()

end

-- ��ǽ����changeAction
function FireWallObject:changeAction(actionId, bLoop,callBack)

end

function FireWallObject:onEnterMap()	
	-- Ϊ����ͬһ���ڻ�ǽ�ܸ�ס����, �ѻ�ǽ��λ�����õĿ�ǰһ��
	local mapX, mapY = self:getMapXY()
	self:setMapXY(mapX, mapY+1)
end

function FireWallObject:faceToCell(cellX, cellY)

end

-- ��ǽ�����ڷ���
function FireWallObject:getAngle()
	return 0
end

function FireWallObject:enterMap()
	if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		local loadCallBack = function (node,layer)
			self:loadModule()
			self.bEnterMap = true
			sfmap:enterMap(self.renderSprite,layer)
			self:onEnterMap()
		end
		if sfmap then
			sfmap:enterMapAsyn(self.renderSprite,loadCallBack, self.mapLayer)
		end
	end
end

function FireWallObject:leaveMap()
	if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		sfmap:leaveMap(self.renderSprite)
		self:onLeaveMap()
	end		
end

function FireWallObject:onLeaveMap()
	if self.shadowSprite then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.shadowSprite)
		end
	end
end