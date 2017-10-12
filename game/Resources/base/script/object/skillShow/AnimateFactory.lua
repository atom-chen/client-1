--[[
常用的动画组合
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

--[[创建一个加载在角色身上的动画
effectId		-- 动画ID
characterId		-- 角色id
characterType	-- 角色类型
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

--[[创建一个加载在地图上的动画
effectId	-- 动画ID
cellX,cellY	-- 地图的格子位置
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

--[[创建一个播放音效的player
soundName	-- 音乐或者音效的名字
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

--[[创建一个飞行特效
effectId 			-- 特效的id, 如果bIsSingleSprite为true, 就是图片的名字
startPos, endPos	-- 开始和结束的位置
needRotate			-- 是否需要根据施法者的角度旋转
bIsSingleSprite		-- 如果为true, 只是一张静态图片，否则就是一个SFRenderSprite
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


--[[创建一个飘字特效
characterId		-- 角色id
characterType	-- 角色类型
style			-- 闪避、暴击、掉血等等
text			-- 飘字的文字, 如果是闪避，这个字段为空
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

--[[创建一个死亡特效
effectId			-- 特效ID
characterId			-- 角色id
characterType		-- 角色类型
attackX, attackY	-- 攻击着的位置
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