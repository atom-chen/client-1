require("common.baseclass")
require("object.handup.FSM.HandupState")

FightState = FightState or BaseClass(HandupState)


function FightState:__init()
	self:setType(E_HandupStateType.Fight)
	self.targetInfo = {}
	self.preTargetRefId = nil
end

function FightState:__delete()
	
end

--this will execute when the state is entered
function FightState:onEnter()
	self.preTargetRefId = nil
	self.targetInfo = self.mgr:getTargetInfo()
	self:doFight()
end	

function FightState:isTargetLegal(target)
	local filter = self.fightTargetMgr:getTargetFilter(self.mgr:getHandupMode())
	if target and ((not filter) or filter(target, self.targetInfo.refIdList)) then
		return true
	else
		return false
	end
end

function FightState:doFight()
	local target = self.fightTargetMgr:getMainTargetObj()
	if not self:isTargetLegal(target) then 	 --TODO
		local delayTime = const_handupDelayPickupTime
		--如果是boss延长切换到拾取状态的时间
		if self:isBoss(self.preTargetRefId) == true then 
			delayTime = delayTime*2
		end
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Pickup), HandupStatePriority.Pickup, delayTime)				
	else
		if target then 
			self.preTargetRefId = target:getRefId()
		end
		if not G_getHero():getSkillMgr():isAutoUseSkill() then
			GlobalEventSystem:Fire(GameEvent.EventUpdateHeroActiveState, E_HeroActiveState.AutoKillMonster) 		
			HandupCommonAPI:switchPKMode(HandupPKModeMap[self.mgr:getHandupMode()])
			local skillRefId = HandupSkillMgr:getSkillRefIdByTarget(target)
			local ret
			local useSkillAction
			if skillRefId then
				ret, useSkillAction = G_getHero():useSkillWithCheck(skillRefId, true, true, true)
			end
			if (ret and useSkillAction) then	--使用技能成功	
				local onUseActionFinished = function()	--技能使用结束的回调
					if self.isRunning then
						self:doFight()
					end
				end
				useSkillAction:addStopNotify(onUseActionFinished, nil)	
			else	--下一帧再战斗		
				self.fsm:changeState(self.mgr:getState(E_HandupStateType.Fight), HandupStatePriority.Normal)	
			end
		else
			self.fsm:changeState(self.mgr:getState(E_HandupStateType.Fight), HandupStatePriority.Normal, 0.1)	
		end
	end
end

--this will execute when the state is exited. 
function FightState:onExit()
	self.preTargetRefId = nil
	self.targetInfo = {}
end

function FightState:onMessage(msg)
	return false
end	

function FightState:isBoss(refId)
	if refId then 
		if GameData.Monster[refId] then 
			local monsterproperty = GameData.Monster[refId].property		
			if monsterproperty then
				local quantity = PropertyDictionary:get_quality(monsterproperty)			
				if quantity and quantity == EntityMonsterType.EntityMonster_Boss then
					return true
				end
			end
		end
	end
end