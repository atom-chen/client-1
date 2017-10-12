require "object.skillShow.player.AnimatePlayer"
require "object.entity.CharacterState"

CharacterActionPlayer = CharacterActionPlayer or BaseClass(AnimatePlayer)

function CharacterActionPlayer:__init()
	self.characterId = ""	-- fight character��id
	self.characterType = 0	-- fight character�����
	self.actionId = 0		-- fight characterҪ���ŵ�actionId	
	self.actionType = ActionType.ActionTypeNormal
	self.name = "CharacterActionPlayer"
	self.maxTime = 0.8
end

function CharacterActionPlayer:setPlayAction(characterId, characterType, actionType, actionId)
	self.characterId = characterId
	self.characterType = characterType
	self.actionId = actionId
	self.actionType = actionType
end

function CharacterActionPlayer:doPlay()
	local animateCallback = function (actionId, movementType)
		self:onAnimateCallback(actionId, movementType)
	end
	
	local finishCallback = function ()
		self:onAnimateCallback(EntityAction.eEntityAction_Hit, 2)
	end
	
	local presenter = SkillShowManager:getCharacterEffectPresenter()
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject ~= nil then	
		if self.actionType == ActionType.ActionTypeNormal then
			-- ��ͨ�ĸı�action
			characterObject:changeAction(self.actionId, true, animateCallback)
		elseif self.actionType == ActionType.ActionTypeAttack then
			if presenter:showAttack(characterObject, self.actionId, animateCallback) == false then
				self.state = AnimatePlayerState.AnimatePlayerStateFinish
			end
		else
			self.maxTime = 0.3
			if presenter:showBeHit(characterObject, finishCallback) == false then
				-- ����תΪ�ܻ�, ֱ������Ϊ���
				self.state = AnimatePlayerState.AnimatePlayerStateFinish
			end
		end
	else
		-- û���ҵ���Ӧ��character, ���ö���Ϊ���
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function CharacterActionPlayer:onAnimateCallback(actionId, movementType)
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if CharacterMovement.Finish == movementType or CharacterMovement.LoopFinish == movementType then
		if characterObject ~= nil then
			characterObject:getState():setIsLock(false)
			characterObject:DoIdle()
		end
		
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	elseif CharacterMovement.Cancel == movementType then
		-- �������Ϊ��ȡ��,  ������ȥ�л�action
		if characterObject ~= nil then
			characterObject:getState():setIsLock(false)
		end
		self.state = AnimatePlayerState.AnimatePlayerStateFinish
	end
end

function CharacterActionPlayer:doStop()
	
end

function CharacterActionPlayer:update(time)
	if time == nil then
		return
	end
	-- TODO: ��ʱ���AnimatePlayerȱ�ٻص�����һֱû�б�����Ϊ��ɵ�BUG
	if self.state == AnimatePlayerState.AnimatePlayerStatePlaying then
		self.time = self.time + time
		if self.time > self.maxTime then
			self:onAnimateCallback(self.actionId, CharacterMovement.Finish)
		end
	end
end