require "object.entity.EntityObject"

CharacterObject = CharacterObject or BaseClass(EntityObject)

function CharacterObject:__init()
	self.shadowSprite = CCSprite:create("ui/ui_img/common/entity_shadow.png")
	self.shadowSprite:retain()
	--self.shadowSprite:setScale(2);
end

function CharacterObject:__delete()
	if self.shadowSprite then
		self.shadowSprite:release()
		self.shadowSprite = nil
	end
end

function CharacterObject:getShadow()
	return self.shadowSprite
end

function CharacterObject:addShadow()
	--if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then		
			sfmap:enterMap(self.shadowSprite, eRenderLayer_SpriteBackground)			
			--local fadeIn = CCFadeIn:create(1)
			--self.shadowSprite:runAction(fadeIn)
		end
	--end
end

function CharacterObject:enterMap()
	EntityObject.enterMap(self)
	self:addShadow()
end

function CharacterObject:setShadowScale(scale)
	if self.shadowSprite then
		self.shadowSprite:setScale(scale)
	end
end