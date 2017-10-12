--[[
战斗状态对应的效果
]]

require("common.baseclass")
require("object.entity.CharacterState")

FightStateEffect = FightStateEffect or BaseClass(FightStateEffect)

-- 进入退出函数的key
local kEnterFunc = "enter"
local kExitFunc = "exit"

local instance = nil

local ColorEffect = {
["green"] = {key="green",color = ccc3(13, 170, 39)},
["red"] = {key="red",color = ccc3(250, 65, 49)},
["Grey"] = {key="Grey",color = ccc3(250, 65, 49)},
}

function FightStateEffect:Instance()
	if instance == nil then
		instance = FightStateEffect.New()
	end
	
	return instance
end

function FightStateEffect:__init()
	self.effectList = {}
	self.program = {}
	
	self:bindStateEffects()
end

function FightStateEffect:__delete()
	
end

function FightStateEffect:enterState(state, characterObject)
	if state and self.effectList[state] and self.effectList[state][kEnterFunc] then
		self.effectList[state][kEnterFunc](self, characterObject)
	end
end

function FightStateEffect:exitState(state, characterObject)
	if state and self.effectList[state] and self.effectList[state][kExitFunc] then
		self.effectList[state][kExitFunc](self, characterObject)
	end
	self:checkColorState(characterObject)
end

function FightStateEffect:checkColorState(characterObject)
	if characterObject and characterObject:getState() then
		local stateList = characterObject:getState():getComboStateList()		
		if stateList[CharacterFightState.Paresis] then--石化
			self:applyParesis(characterObject)
		elseif stateList[CharacterFightState.Poison]  then  --中毒
			self:applyPoison(characterObject)
		elseif stateList[CharacterFightState.Burn] then --灼烧
			self:applyBurn(characterObject)			
		end	
	end
end

function FightStateEffect:bindStateEffects()
	self:bindStateEffect(CharacterFightState.Invisible, self.applyInvisibleEffect, self.cancelInvisibleEffect)
	self:bindStateEffect(CharacterFightState.Poison, self.applyPoison, self.cancelMixColorEffect)
	self:bindStateEffect(CharacterFightState.Burn, self.applyBurn, self.cancelMixColorEffect)
	self:bindStateEffect(CharacterFightState.Paresis, self.applyGrayEffect, self.cancelGrayEffect)
	self:bindStateEffect(CharacterFightState.Mofadun,self.applyMofadun,self.cancelMofadun)
	self:bindStateEffect(CharacterFightState.Dizzy,self.applyDizzy,nil)
--	self:bindStateEffect(CharacterFightState.Slow, self.applySlow, self.cancelSlow)
end

function FightStateEffect:bindStateEffect(state, enterFunc, exitFunc)
	if state and (enterFunc or exitFunc) then
		if self.effectList[state] == nil then
			self.effectList[state] = {}
		end
		
		self.effectList[state][kEnterFunc] = enterFunc
		self.effectList[state][kExitFunc] = exitFunc
	end
end

-- 应用中毒效果
function FightStateEffect:applyPoison(characterObject)
	-- 染绿色
	self:applyMixColorEffect(characterObject,ColorEffect.green)
end

function FightStateEffect:applyBurn(characterObject)
	-- 染红色
	self:applyMixColorEffect(characterObject,ColorEffect.red)
end

function FightStateEffect:applyParesis(characterObject)
	--染灰色
	self.applyMixColorEffect(characterObject,ColorEffect.Grey)
end

function FightStateEffect:applyDizzy(characterObject)
	-- 眩晕
	if characterObject then
		characterObject:moveStop()
	end
end
--[[
function FightStateEffect:applySlow(characterObject)
	-- 缓速
	if characterObject then
		local speed = PropertyDictionary:get_moveSpeed(characterObject:getPT())
		PropertyDictionary:set_moveSpeed(characterObject:getPT(),speed*0.7)
	end
end

function FightStateEffect:cancelSlow(characterObject)
	-- 取消缓速
	if characterObject then
		local speed = PropertyDictionary:get_moveSpeed(characterObject:getPT())
		PropertyDictionary:set_moveSpeed(characterObject:getPT(),speed*10/7)
	end
end--]]

-- 应用一个染色的效果
-- characterModel: 角色模型
function FightStateEffect:applyMixColorEffect(characterObject, coloreffect)
	if not characterObject or not coloreffect then
		return
	end
	
	-- 设置shader
	local colorKey = coloreffect.key
	local color = coloreffect.color
	
	if self.program[colorKey]==nil then	
		self.program[colorKey] = CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureMixColor")		
	end
	
	if self.program[colorKey] and  characterObject:setShader(self.program[colorKey]) then
		self.program[colorKey]:use()
		local colorLocation = self.program[colorKey]:getUniformLocationForName("u_mixColor")
		local alpha = characterObject:getRenderSprite():getAlpha()/255
		local originalAlpha = self.program[colorKey]:getUniformLocationForName("u_originalAlpha")
		self.program[colorKey]:setUniformLocationWith3f(colorLocation, color.r/255, color.g/255, color.b/255)
		self.program[colorKey]:setUniformLocationWith1f(originalAlpha,alpha)
	end
end

-- 取消染色效果
function FightStateEffect:cancelMixColorEffect(characterObject)
	if not characterObject then
		return
	end
		
	characterObject:setShader(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))
end

function FightStateEffect:applyGrayEffect(characterObject)
	if not characterObject then
		return
	end
	
	characterObject:setShader(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureGray"))
end

function FightStateEffect:cancelGrayEffect(characterObject)
	if not characterObject then
		return
	end
	
	characterObject:setShader(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))	
end

-- 应用一个隐形的效果
function FightStateEffect:applyInvisibleEffect(characterObject)
	if characterObject:getRenderSprite() and characterObject:isEnterMap() then
		-- 刷新隐身术的cd
		local mofadunRefId = G_getHero():getEquipSkill("skill_ds_6")
		G_getHero():getSkillMgr():handleUseSkill(mofadunRefId)
		
		characterObject:getRenderSprite():setEnableOpacity(true)
		characterObject:getRenderSprite():setAlpha(100)
	end
end

function FightStateEffect:cancelInvisibleEffect(characterObject)
	if characterObject:getRenderSprite() and characterObject:isEnterMap() then
		characterObject:getRenderSprite():setEnableOpacity(true)
		characterObject:getRenderSprite():setAlpha(255)
	end
end

function FightStateEffect:applyMofadun(characterObject)
	if characterObject:getRenderSprite() then
		-- 刷新魔法盾的cd
		local mofadunRefId = G_getHero():getEquipSkill("skill_fs_11")
		G_getHero():getSkillMgr():handleUseSkill(mofadunRefId)
		
		local renderSprite = SFRenderSprite:createRenderSprite(7161, 0, "res/skill/")
		renderSprite:setScaleX(1)
		renderSprite:setScaleY(-1)
		renderSprite:setTag(100)
		characterObject:getRenderSprite():addChild(renderSprite)
		renderSprite:playByIndexLua(0)
	end
end

function FightStateEffect:cancelMofadun(characterObject)
	if characterObject:getRenderSprite() then
		characterObject:getRenderSprite():removeChildByTag(100,true)
		characterObject:getRenderSprite():removeChildByTag(101,true)
	end
end