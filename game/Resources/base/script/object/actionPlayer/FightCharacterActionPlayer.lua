require("object.actionPlayer.BaseActionPlayer")

FightCharacterActionPlayer = FightCharacterActionPlayer or BaseClass(BaseActionPlayer)

function FightCharacterActionPlayer:__init()
	self.des = "FightCharacterActionPlayer"
	self.characterId = ""	-- fight character的id
	self.characterType = 0	-- fight character的类别
	self.actionId = 0		-- fight character要播放的actionId	
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
			-- 普通的改变action
			characterObject:changeAction(self.actionId, true, animateCallback)
		elseif self.actionType == ActionType.ActionTypeAttack then 
			if characterObject:DoShowAttackAction(self.actionId, animateCallback) == false then
				-- 不能转为受击, 直接设置为完成
				self.state = E_ActionPlayerState.Finished
			else
				--characterObject:getState():setIsLock(true)
			end
		else
			if characterObject:DoShowBeHit(finishCallback) == false then
				-- 不能转为受击, 直接设置为完成
				self.state = E_ActionPlayerState.Finished
			end
		end
	else
		-- 没有找到对应的character, 设置动画为完成
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
		-- 如果是行为被取消,  不主动去切换action
		if characterObject ~= nil then
			characterObject:getState():setIsLock(false)
		end
		self.state = E_ActionPlayerState.Finished
	end
end

function FightCharacterActionPlayer:doStop()
	self:onAnimateCallback(EntityAction.eEntityAction_Hit, CharacterMovement.Cancel)
end