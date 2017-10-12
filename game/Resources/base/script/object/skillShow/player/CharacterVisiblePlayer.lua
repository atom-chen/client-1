--[[
设置角色是否可见
]]

require "object.skillShow.player.AnimatePlayer"

CharacterVisiblePlayer = CharacterVisiblePlayer or BaseClass(AnimatePlayer)

function CharacterVisiblePlayer:__init()
	self.characterId = ""
	self.characterType = ""
	self.isVisible = true
	self.name = "CharacterVisiblePlayer"
end

function CharacterVisiblePlayer:__delete()

end

function CharacterVisiblePlayer:setCharacter(characterType, characterId, isVisible)
	if characterType and characterId and isVisible then
		self.characterId = characterId
		self.characterType = characterType
		self.isVisible = isVisible
	end
end

function CharacterVisiblePlayer:doPlay()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject then
		characterObject:getRenderSprite():setRenderSpriteVisible(self.isVisible)
	end
	
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function CharacterVisiblePlayer:doStop()

end