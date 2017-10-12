--[[
设置角色的位置
]]

require "object.skillShow.player.AnimatePlayer"

CharacterPositionPlayer = CharacterPositionPlayer or BaseClass(AnimatePlayer)

function CharacterPositionPlayer:__init()
	self.characterId = ""
	self.characterType = ""
	self.position = ccp(0, 0)
	self.time = 0
	self.name = "CharacterPositionPlayer"
end

function CharacterPositionPlayer:__delete()

end

function CharacterPositionPlayer:setCharacter(characterType, characterId)
	if characterType and characterId then
		self.characterId = characterId
		self.characterType = characterType
	end
end

function CharacterPositionPlayer:setTime(time)
	self.time = time
end

function CharacterPositionPlayer:setPosition(position)
	self.position = position
end

function CharacterPositionPlayer:doPlay()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject then
		characterObject:getRenderSprite():setPosition(self.position)
		
		local hero = GameWorld.Instance:getEntityManager():getHero()
		if hero:getId() == self.characterId then
			GlobalEventSystem:Fire(GameEvent.EventHeroMovement)	
			SFMapService:instance():getShareMap():setViewCenter(self.position.x, hero:getCenterY())
		end
	end
	
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function CharacterPositionPlayer:doStop()

end