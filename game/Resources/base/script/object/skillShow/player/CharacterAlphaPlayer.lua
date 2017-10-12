--[[
设置角色的透明度
]]

require "object.skillShow.player.AnimatePlayer"

CharacterAlphaPlayer = CharacterAlphaPlayer or BaseClass(AnimatePlayer)

function CharacterAlphaPlayer:__init()
	self.characterId = ""
	self.characterType = ""
	self.alpha = 255
	self.name = "CharacterAlphaPlayer"
end

function CharacterAlphaPlayer:__delete()

end

function CharacterAlphaPlayer:setCharacter(characterType, characterId)
	if characterType and characterId then
		self.characterId = characterId
		self.characterType = characterType
	end
end

function CharacterAlphaPlayer:setAlpha(alpha)
	self.alpha = alpha
end

function CharacterAlphaPlayer:doPlay()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject then
		characterObject:getRenderSprite():setEnableOpacity(true)
		characterObject:getRenderSprite():setAlpha(self.alpha)
		
		-- 如果是中毒或者灼烧这种染色效果的状态, 要更新shader的alpha值
		if characterObject:getState():isState(CharacterFightState.Burn) or characterObject:getState():isState(CharacterFightState.Poison)  
			or characterObject:getState():isState(CharacterFightState.Paresis) then
			local shader = characterObject:getRenderSprite():getShaderProgram()
			if shader then
				local locateAlpha = shader:getUniformLocationForName("u_originalAlpha")
				local alpha = characterObject:getRenderSprite():getAlpha()/255
				shader:setUniformLocationWith1f(locateAlpha,alpha)
			end
		end
	end
	
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function CharacterAlphaPlayer:doStop()

end