--[[
���õĶ������
]]

require "common.baseclass"
require("object.skillShow.player.TextPlayer")
require("object.skillShow.player.CharacterAnimatePlayer")
require("object.skillShow.player.CharacterActionPlayer")
require("object.skillShow.player.MapAnimatePlayer")
require("object.skillShow.player.BulletAnimatePlayer")
require("object.skillShow.player.CharacterAlphaPlayer")
require("object.skillShow.player.CharacterPositionPlayer")
require("object.skillShow.player.BulletAnimatePlayer")
require("object.skillShow.player.CharacterActionFlyPlayer")
require("object.skillShow.player.CharacterActionHitBack")
require("object.skillShow.player.DeathPlayer")
require("object.skillShow.player.SoundPlayer")

AnimateFactory = AnimateFactory or BaseClass()

--[[����һ�������ڽ�ɫ���ϵĶ���
effectId		-- ����ID
characterId		-- ��ɫid
characterType	-- ��ɫ����
]]
function AnimateFactory:getCharacterEffect(effectId, characterId, characterType)
	if effectId and characterId and characterType then
		local player = CharacterAnimatePlayer.New()
		player:setPlayData(characterId, characterType, effectId)
		return player
	else
		return nil
	end
end

--[[����һ�������ڵ�ͼ�ϵĶ���
effectId	-- ����ID
cellX,cellY	-- ��ͼ�ĸ���λ��
]]
function AnimateFactory:getMapEffect(effectId, cellX, cellY)
	if effectId and cellX and cellY then
		local player = MapAnimatePlayer.New()
		player:setPlayData(cellX, cellY, effectId)
		return player
	else
		return nil
	end
end

--[[����һ��������Ч��player
soundName	-- ���ֻ�����Ч������
]]
function AnimateFactory:getSoundPlayer(soundName)
	if soundName then
		local soundPlayer = SoundPlayer.New()
		soundPlayer:setSoundName(soundName)
		return soundPlayer
	else
		return nil
	end
end

--[[����һ��������Ч
effectId 			-- ��Ч��id, ���bIsSingleSpriteΪtrue, ����ͼƬ������
startPos, endPos	-- ��ʼ�ͽ�����λ��
needRotate			-- �Ƿ���Ҫ����ʩ���ߵĽǶ���ת
bIsSingleSprite		-- ���Ϊtrue, ֻ��һ�ž�̬ͼƬ���������һ��SFRenderSprite
]]
function AnimateFactory:getBulletPlayer(effectId, startPos, endPos, needRotate, bIsSingleSprite)
	if effectId and startPos and endPos then
		local bulletPlayer = BulletAnimatePlayer.New()
		bulletPlayer:setPlayAnimate(effectId, startPos, endPos, 900)
		bulletPlayer:setNeedRotate(needRotate)
		bulletPlayer:setIsSingleSprite(bIsSingleSprite)
		return bulletPlayer
	else
		return nil
	end
end


--[[����һ��Ʈ����Ч
characterId		-- ��ɫid
characterType	-- ��ɫ����
style			-- ���ܡ���������Ѫ�ȵ�
text			-- Ʈ�ֵ�����, ��������ܣ�����ֶ�Ϊ��
]]
function AnimateFactory:getTextPlayer(characterId, characterType, style, text)
	if characterId and characterType and style and text then
		local textPlayer = TextPlayer.New()
		textPlayer:setPlayerData(characterId, characterType, style, text)
		return textPlayer
	else
		return nil
	end
end

--[[����һ��������Ч
effectId			-- ��ЧID
characterId			-- ��ɫid
characterType		-- ��ɫ����
attackX, attackY	-- �����ŵ�λ��
]]
function AnimateFactory:getDeathPlayer(effectId, characterId, characterType, attackX, attackY)
	if effectId and characterId and characterType then
		local deathPlayer = DeathPlayer.New()
		deathPlayer:setCharacter(characterType, characterId)
		
		if attackX and attackY  then
			deathPlayer:setAttackPos(attackX, attackY)
		end
		
		deathPlayer:setEffectId(effectId)
		return deathPlayer
	else
		return nil
	end
end