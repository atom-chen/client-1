require "object.skillShow.player.AnimatePlayer"
require "config.animate"

CharacterAnimatePlayer = CharacterAnimatePlayer or BaseClass(AnimatePlayer)

function CharacterAnimatePlayer:__init()
	self.characterId = ""	-- fight character的id
	self.characterType = 0	-- fight character的类别
	self.modelId = 0		-- 动画模型id
	self.renderSprite = nil	-- 动画的对象
	self.offset = ccp(0, 0)
	self.rotation = 0
	self.name = "CharacterAnimatePlayer"
	self.direction = 0
	self.animateSpeed = 1
	self.scale = 1
end

function CharacterAnimatePlayer:__delete()
	self:clear()
end

function CharacterAnimatePlayer:clear()
	if self.renderSprite then
		local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
		local presenter = SkillShowManager:getCharacterEffectPresenter()
		presenter:removeAnimate(characterObject, self.renderSprite, self.modelId)
		
		self.renderSprite:release()
		self.renderSprite = nil
	end
end

function CharacterAnimatePlayer:setAnimateSpeed(speed)
	if speed then
		self.animateSpeed = speed
	end
end

function CharacterAnimatePlayer:setOffset(offset)
	self.offset = offset
end

function CharacterAnimatePlayer:setDirection(direction)
	self.direction = direction
end


function CharacterAnimatePlayer:setRotation(rotation)
	self.rotation = rotation
end

function CharacterAnimatePlayer:setScale(scale)
	if scale and type(scale) == "number" and scale > 0 then
		self.scale = scale
	end
end

-- 设置动画必须的数据
function CharacterAnimatePlayer:setPlayData(characterId, characterType, modelId)
	self.characterId = characterId
	self.characterType = characterType
	self.modelId = modelId
end

function CharacterAnimatePlayer:doPlay()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	local presenter = SkillShowManager:getCharacterEffectPresenter()
	if presenter:canShowAnimate(characterObject, self.modelId) then
		local animateCallback = function (actionId, movementType)
			self:onAnimateCallback(actionId, movementType)
		end
		
		if characterObject ~= nil then
			local scaleX = 1
			local actionId = self.direction
			if actionId > 4 then
				actionId = 8- actionId
				scaleX = -1
			end
			
			self.renderSprite = SFRenderSprite:createRenderSprite(self.modelId, actionId, "res/skill/")
			self.renderSprite:setScaleX(scaleX*self.scale)
			self.renderSprite:setScaleY(-1*self.scale)
			self.renderSprite:retain()
			self.renderSprite:setRotation(self.rotation)
			--characterObject:addEffect(self.renderSprite, self.modelId)
			self.renderSprite:setScriptHandler(animateCallback)
			self.renderSprite:playByIndexLua(0)
			
			if self.animateSpeed > 0 then
				self.renderSprite:setAnimationSpeed(self.animateSpeed)
			end
			
			--设置offset
			if self.offset then
				self.renderSprite:setPosition(self.offset)
			end
			
			if not presenter:showAnimate(characterObject, self.renderSprite, self.modelId) then	
				self:clear()
				self.state = AnimatePlayerState.AnimatePlayerStateFinish
			end
		else
			-- 没有找到对应的character, 设置动画为完成
			self.state = AnimatePlayerState.AnimatePlayerStateFinish
		end
	else
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
	
	
end

function CharacterAnimatePlayer:onAnimateCallback(actionId, movementType)
	if CharacterMovement.Finish == movementType or CharacterMovement.LoopFinish == movementType or
		CharacterMovement.Cancel == movementType then
		self:clear()
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function CharacterAnimatePlayer:doStop()
	
end

function CharacterAnimatePlayer:update(time)
	if time == nil then
		return
	end
	-- TODO: 临时解决AnimatePlayer缺少回调导致一直没有被设置为完成的BUG
	if self.state == AnimatePlayerState.AnimatePlayerStatePlaying then
		self.time = self.time + time
		if self.time > self.maxTime then
			self:onAnimateCallback(0, 2)
		end
	end
end