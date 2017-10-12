--[[
受击动作、受击动画等玩家的表现效果的表演管理
]]

require("common.baseclass")
require("object.skillShow.SkillShowDef")

CharacterEffectPresenter = CharacterEffectPresenter or BaseClass()

function CharacterEffectPresenter:__init()
	self.currentBeHitCount = 0
	self.currentAnimateCount = 0
	self.currentTextCount = 0
end

function CharacterEffectPresenter:__delete()

end

function CharacterEffectPresenter:showBeHit(characterObject, callback)
	if not characterObject then
		CCLuaLog("Warning!CharacterEffectPresenter:showBeHit wrong params")
		return false
	end
	
	if self.currentBeHitCount > SkillShowDef.MaxBeHitCount then
		return false
	end
	
	local function actionCallback()
		self.currentBeHitCount = self.currentBeHitCount - 1
		if callback then
			callback()
		end
	end
	
	if characterObject:DoShowBeHit(actionCallback) then
		self.currentBeHitCount = self.currentBeHitCount + 1
		return true
	else
		return false
	end
end

function CharacterEffectPresenter:showAttack(characterObject, actionId, callback)
	if not characterObject or not actionId then
		CCLuaLog("Warning!CharacterEffectPresenter:showAttack wrong params")
		return false
	end
	
	local function actionCallback(actionId, movementType)
		if callback then
			callback(actionId, movementType)
		end
	end
	
	return characterObject:DoShowAttackAction(actionId, actionCallback)
end

function CharacterEffectPresenter:canShowAnimate(characterObject, effectId)
	if characterObject and effectId then
		return characterObject:canShowEffect(effectId) and self.currentAnimateCount < SkillShowDef.MaxCharacterAnimateCount
	else
		return false
	end
end

function CharacterEffectPresenter:showAnimate(characterObject, effectObject, effectId)
	if not characterObject or not effectObject or not effectId then
		CCLuaLog("Warning!CharacterEffectPresenter:showBeHitAnimate wrong params")
		return false
	end
	
	if self.currentAnimateCount > SkillShowDef.MaxCharacterAnimateCount then
		return false
	end
	
	self.currentAnimateCount = self.currentAnimateCount + 1		
	return characterObject:addEffect(effectObject, effectId)
end

function CharacterEffectPresenter:removeAnimate(characterObject, effectObject, effectId)
	if characterObject then
		characterObject:removeEffect(effectObject, effectId)
	end
	
	self.currentAnimateCount = self.currentAnimateCount - 1
	if self.currentAnimateCount < 0 then
		self.currentAnimateCount = 0
	end
end

function CharacterEffectPresenter:canShowFightText()
	return self.currentTextCount < SkillShowDef.MaxFightTextCount
end

function CharacterEffectPresenter:showFightText(characterObject, textNode)
	if not characterObject or not textNode then
		return false
	end
	
	if self.currentTextCount >= SkillShowDef.MaxFightTextCount then
		return false
	end
	
	self.currentTextCount = self.currentTextCount + 1
	local ptText = characterObject:getUperPosition(0)
	characterObject:addChild(textNode)
	textNode:setPosition(ccp(0, ptText.y-25))
	return true
end

function CharacterEffectPresenter:removeFightText(textNode)
	if not textNode then
		return
	end
	
	self.currentTextCount = self.currentTextCount - 1
	
	textNode:removeFromParentAndCleanup(true)
end