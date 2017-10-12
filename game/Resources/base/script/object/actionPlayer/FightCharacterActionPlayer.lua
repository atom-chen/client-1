require("object.actionPlayer.BaseActionPlayer")

FightCharacterActionPlayer = FightCharacterActionPlayer or BaseClass(BaseActionPlayer)

function FightCharacterActionPlayer:__init()
	self.des = "FightCharacterActionPlayer"
	self.characterId = ""	-- fight character��id
	self.characterType = 0	-- fight character�����
	self.actionId = 0		-- fight characterҪ���ŵ�actionId	
	self.actionType = ActionType.ActionTypeNormal
	self.maxPlayingDuration = 2
end

function FightCharacterActionPlayer:setPlayAction(characterId, characterType, actionType, actionId)
	self.characterId = characterId
	self.characterType = characterType
	self.actionId = actionId
	self.actionType = actionType
end

function FightCharacterActionPlayer:doPlay()
	local animateCallback = function (actionId, movementType)
		self:onAnimateCallback(actionId, movementType)
	end
	
	local finishCallback = function ()
		self:onAnimateCallback(EntityAction.eEntityAction_Hit, 2)
	end
	
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if characterObject ~= nil then	
		if self.actionType == ActionType.ActionTypeNormal then
			-- ��ͨ�ĸı�action
			characterObject:changeAction(self.actionId, true, animateCallback)
		elseif self.actionType == ActionType.ActionTypeAttack then 
			if characterObject:DoShowAttackAction(self.actionId, animateCallback) == false then
				-- ����תΪ�ܻ�, ֱ������Ϊ���
				self.state = E_ActionPlayerState.Finished
			else
				--characterObject:getState():setIsLock(true)
			end
		else
			if characterObject:DoShowBeHit(finishCallback) == false then
				-- ����תΪ�ܻ�, ֱ������Ϊ���
				self.state = E_ActionPlayerState.Finished
			end
		end
	else
		-- û���ҵ���Ӧ��character, ���ö���Ϊ���
		self.state = E_ActionPlayerState.Finished
	end
end

function FightCharacterActionPlayer:onAnimateCallback(actionId, movementType)
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
	if CharacterMovement.Finish == movementType or CharacterMovement.LoopFinish == movementType then
		if characterObject ~= nil then
			characterObject:getState():setIsLock(false)
			characterObject:DoIdle()
		end
		
		self.state = E_ActionPlayerState.Finished
	elseif CharacterMovement.Cancel == movementType then
		-- �������Ϊ��ȡ��,  ������ȥ�л�action
		if characterObject ~= nil then
			characterObject:getState():setIsLock(false)
		end
		self.state = E_ActionPlayerState.Finished
	end
end

function FightCharacterActionPlayer:doStop()
	self:onAnimateCallback(EntityAction.eEntityAction_Hit, CharacterMovement.Cancel)
end