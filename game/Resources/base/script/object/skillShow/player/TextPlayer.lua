--[[
飘字效果
]]

require "object.skillShow.player.AnimatePlayer"
require "config.color"
require "config.words"

TextPlayer = TextPlayer or BaseClass(AnimatePlayer)

TextStyle =
{
TextStyleNone = -1,
TextStyleMiss = 0,	-- 闪躲
TextStyleHit = 1,   -- 普通攻击
TextStyleCriti = 2,	-- 暴击
TextStyleHeal = 3,	-- 恢复
TextStyleBuff = 4,	-- buff
TextStyleDebuff = 5,	-- debuff
}

function TextPlayer:__init()
	self.text = ""
	self.style = 0
	self.characterId = ""
	self.characterType = 0
	self.bmfontLabel = nil	
	self.name = "TextPlayer"
	self.attackId = ""
	self.attackType = ""
	self.textNode = nil
	self.maxTime = 0.45
end

function TextPlayer:__delete()
	self:clean()
end

--设置飘字动画的目标
function TextPlayer:setPlayerData(characterId, characterType, style, text)
	self.text = text
	self.style = style
	self.characterId = characterId
	self.characterType = characterType
end

function TextPlayer:setAttackData(attackId, attackType)
	if attackId and attackType then
		self.attackId = attackId
		self.attackType = attackType
	end
end

function TextPlayer:clean()
	if self.textNode ~= nil then
		local characterPresenter = SkillShowManager:getCharacterEffectPresenter()
		characterPresenter:removeFightText(self.textNode)
		self.textNode:release()
		self.textNode = nil
	end			
	if self.bmfontLabel ~= nil then
		self.bmfontLabel:removeFromParentAndCleanup(true)
		self.bmfontLabel:release()
		self.bmfontLabel = nil
	end	
	if self.buffLabel ~= nil then
		self.buffLabel:removeFromParentAndCleanup(true)
		self.buffLabel:release()
		self.buffLabel = nil
	end
	if self.debuffLabel ~= nil then
		self.debuffLabel:removeFromParentAndCleanup(true)
		self.debuffLabel:release()
		self.debuffLabel = nil
	end
	if self.pictureTip ~= nil then
		self.pictureTip:removeFromParentAndCleanup(true)
		self.pictureTip:release()
		self.pictureTip = nil
	end
	self.state = AnimatePlayerState.AnimatePlayerStateFinish
end

function TextPlayer:doPlay()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject == nil then
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		return
	end
	
	--如果是自己的暴击的，屏幕抖一下, 还要显示一个特别的暴击动画效果
	if GameWorld.Instance:getEntityManager():getHero():getId() == self.attackId and self.style == TextStyle.TextStyleCriti then
		GameWorld.Instance:getMapManager():shakeMap()
		self:createCritAction(self.text)
		return
	end
	
	local characterPresenter = SkillShowManager:getCharacterEffectPresenter()
	if not characterPresenter:canShowFightText() then
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
		return
	end
	
	
	local textFinishCallback = function ()
		self:clean()
	end
	
	self.textNode = CCNode:create()
	self.textNode:retain()
	self.textNode:setContentSize(CCSizeMake(200, 90))
	
	if GameWorld.Instance:getEntityManager():getHero():getId() == self.characterId or GameWorld.Instance:getEntityManager():getHero():getPet() == self.characterId then
		if self.style == TextStyle.TextStyleMiss then
			-- 闪避
			self.pictureTip = createSpriteWithFrameName(RES("common_dodge.png"))
			self:createTextPic(self.pictureTip, self.textNode)		
		elseif self.style == TextStyle.TextStyleCriti then
			-- 暴击
			return
		elseif self.style == TextStyle.TextStyleBuff then
			-- buff
			self.buffLabel = createLabelWithStringFontSizeColorAndDimension(self.text, "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
			self:createTextLable(self.buffLabel,self.textNode)
		elseif self.style == TextStyle.TextStyleDebuff then
			-- debuff
			self.debuffLabel = createLabelWithStringFontSizeColorAndDimension(self.text, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
			self:createTextLable(self.debuffLabel,self.textNode)
		elseif self.style == TextStyle.TextStyleHeal then
			-- 治疗
			local atlasName = Config.AtlasImg.FightHpGreen
			self.bmfontLabel = createAtlasNumber(atlasName, self.text)
			self:createTextLable(self.bmfontLabel,self.textNode)
		else
			local atlasName = Config.AtlasImg.FightHpYellow	
			self.bmfontLabel = createAtlasNumber(atlasName, self.text)
			self:createTextLable(self.bmfontLabel,self.textNode)
		end	
	else
		if self.style == TextStyle.TextStyleMiss then
			-- 闪避			
			self.pictureTip = createSpriteWithFrameName(RES("common_dodge_red.png"))
			self:createTextPic(self.pictureTip, self.textNode)
		elseif self.style == TextStyle.TextStyleCriti then
			-- 暴击
			return
		elseif self.style == TextStyle.TextStyleBuff then
			-- buff
			self.buffLabel = createLabelWithStringFontSizeColorAndDimension(self.text, "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
			self:createTextLable(self.buffLabel,self.textNode)
		elseif self.style == TextStyle.TextStyleDebuff then
			-- debuff
			self.debuffLabel = createLabelWithStringFontSizeColorAndDimension(self.text, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
			self:createTextLable(self.debuffLabel,self.textNode)
		elseif self.style == TextStyle.TextStyleHeal then
			-- 治疗
			local atlasName = Config.AtlasImg.FightHpGreen
			self.bmfontLabel = createAtlasNumber(atlasName, self.text)
			self:createTextLable(self.bmfontLabel,self.textNode)
		else
			local atlasName = Config.AtlasImg.FightHpRed	
			self.bmfontLabel = createAtlasNumber(atlasName, self.text)
			self:createTextLable(self.bmfontLabel,self.textNode)
		end
	end	

	-- 创建飘字的action
	local action = self:createActions()	
	local actionArray = CCArray:create()
	actionArray:addObject(action)
	actionArray:addObject(CCCallFunc:create(textFinishCallback))	
	self.textNode:runAction(CCSequence:create(actionArray))
		
	characterPresenter:showFightText(characterObject, self.textNode)			
end

function TextPlayer:doStop()
	
end

function TextPlayer:getPoints()
	local points = {}
	local rand = math.random(100)
	local configX1 = 2
	local configX2 = 10
	local configX3 = 15
	local configY1 = 40
	local configY2 = 20
	local configY3 = -10

	if rand > 50 then
		table.insert(points, ccp(configX1+math.random(5), -configY1-math.random(5)))
		table.insert(points, ccp(configX2+math.random(5), -configY2-math.random(5)))
		table.insert(points, ccp(configX3+math.random(5), -configY3-math.random(5)))
	else
		table.insert(points, ccp(-configX1-math.random(5),-configY1-math.random(5)))
		table.insert(points, ccp(-configX2-math.random(5), -configY2-math.random(5)))
		table.insert(points, ccp(-configX3-math.random(5), -configY3-math.random(5)))
	end				
			
	return points
end

function TextPlayer:createActions()
	local retAction = nil
	local actionArray = CCArray:create()	
	
	--[[if GameWorld.Instance:getEntityManager():getHero():getId() == self.characterId then
		local moveAction = CCMoveBy:create(0.2, ccp(0, -40))
		local scaleAction = CCScaleBy:create(0.2, 1.2)
		actionArray:addObject(scaleAction)
		actionArray:addObject(moveAction)
		retAction = CCSequence:create(actionArray)
	else--]]		
		local points = self:getPoints()		
		local bezier = ccBezierConfig()
		bezier.controlPoint_1 = points[1]
		bezier.controlPoint_2 = points[2]
		bezier.endPosition = points[3]
		local rand = math.random(40)/100
		local bezierForward = CCBezierBy:create(0.4+rand, bezier)
		local upscaleAction = CCScaleTo:create(0.2, 2)
		local downscaleAction = CCScaleTo:create(0.2,1.5)
		
		local spawnArray = CCArray:create()
		
		actionArray:addObject(upscaleAction)	
		actionArray:addObject(CCDelayTime:create(rand))	
		actionArray:addObject(downscaleAction)
		
		local sequence = CCSequence:create(actionArray)
		spawnArray:addObject(sequence)
		spawnArray:addObject(bezierForward)
		--retAction = bezierForward	
		retAction = CCSpawn:create(spawnArray) 			
		
		return retAction			
end


function TextPlayer:createTextPic(child, parent)
	child:retain()
	child:setScaleY(-1)
	child:setPosition(ccp(0, -10))
	parent:addChild(child)
end

function TextPlayer:createTextLable(child, parent)
	child:retain()		
	child:setAnchorPoint(ccp(0.5, 0.5))	
	child:setScaleY(-1)		
	parent:addChild(child)
end

function TextPlayer:createCritAction(number)
	if number then
		local critiNode = CCNodeRGBA:new()
		critiNode:init()
		critiNode:autorelease()
		critiNode:setCascadeOpacityEnabled(true)
		
		critiNode:retain()
		local bg = createSpriteWithFrameName(RES("fight_blood.png"))
		critiNode:addChild(bg)
		local critiText = createSpriteWithFrameName(RES("common_Crit.png"))
		bg:addChild(critiText)
		VisibleRect:relativePosition(critiText, bg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(20, 15))
		local critiNumber = createAtlasNumber(Config.AtlasImg.FightHpCriti, number)
		critiNumber:setAnchorPoint(ccp(0.5, 0.5))
		bg:addChild(critiNumber)
		VisibleRect:relativePosition(critiNumber, critiText, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
		
		local finishCallback = function ()
			critiNode:release()
			critiNode:removeFromParentAndCleanup(true)
		end
	
		-- 创建action
		local actionArray = CCArray:create()
		actionArray:addObject(CCFadeIn:create(0.3))
		actionArray:addObject(CCDelayTime:create(0.5))
		actionArray:addObject(CCFadeOut:create(0.3))
		actionArray:addObject(CCCallFunc:create(finishCallback))
		critiNode:runAction(CCSequence:create(actionArray))
		
		--[[local actionArray2 = CCArray:create()
		actionArray2:addObject(CCFadeIn:create(0.3))
		actionArray2:addObject(CCDelayTime:create(0.5))
		actionArray2:addObject(CCFadeOut:create(0.3))		
		critiText:runAction(CCSequence:create(actionArray2))]]
		
		-- 暴击文字要一个单独的缩放
		critiText:setScale(0.1)
		local actionArray2 = CCArray:create()
		actionArray2:addObject(CCScaleTo:create(0.1, 1.2))
		actionArray2:addObject(CCScaleTo:create(0.1, 1.0))
		critiText:runAction(CCSequence:create(actionArray2))
		local sfmap = SFMapService:instance():getShareMap()
		UIManager.Instance:getGameRootNode():addChild(critiNode)
		critiNode:setPosition(ccp(200, 320))
	end
end
