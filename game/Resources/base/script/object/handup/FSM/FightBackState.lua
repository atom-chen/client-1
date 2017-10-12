--����״̬
require("common.baseclass")
require("object.handup.FSM.HandupState")

FightBackState = FightBackState or BaseClass(HandupState)

function FightBackState:__init()
	self:setType(E_HandupStateType.FightBack)
end

function FightBackState:__delete()
	
end

--����ʱ��Ŀ���ж�
function FightBackState:isTargetLegal(target)
	if target == nil then
--		print("FightBackState target is nil")
		return false
	end
	local hero = G_getHero()
	if target == hero then
--		print("FightBackState is hero")
		return false
	end
	local ttype = target:getEntityType()	
	
	if ttype ~= EntityType.EntityType_Player then
--		print("FightBackState is not player")
		return false
	end
	--Juchao@20140728: ����Ҫ�ж��Ƿ�Ϊ�����ߡ�һֱ����Ŀ����ʧ
--[[	
	local id = target:getId()
	if not GameWorld.Instance:getFightTargetMgr():isAttacker(id) then		
--		print("FightBackState is not attacter")
		return false
	end		
	--]]
	if target:getState():isState(CharacterState.CharacterStateDead) then
--		print("FightBackState state not illegal")
		return false
	end
			
	--���ֻ�к������߻����Ŵ�
	local nameColor = PropertyDictionary:get_nameColor(target:getPT())
	if not (nameColor == E_HeroNameColorType.Red or nameColor == E_HeroNameColorType.Gray) then
--		print("FightBackState name color not illegal")
		return false
	end
	return true
end	

function FightBackState:doFight()
	local target = self.fightTargetMgr:getMainTargetObj()
	if not self:isTargetLegal(target) then
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Pickup), HandupStatePriority.FightBack, const_handupDelayPickupTime)				
	else
		if not G_getHero():getSkillMgr():isAutoUseSkill() then
			GlobalEventSystem:Fire(GameEvent.EventUpdateHeroActiveState, E_HeroActiveState.AutoKillMonster) 		
			HandupCommonAPI:switchPKMode(const_fightBackPKMode)	--�������ƶ�
			local skillRefId = HandupSkillMgr:getSkillRefIdByTarget(target)
			local ret
			local useSkillAction
			if skillRefId then
				ret, useSkillAction = G_getHero():useSkillWithCheck(skillRefId, true, true, true)
			end

			if (ret and useSkillAction and (type(useSkillAction) == "table")) then	--ʹ�ü��ܳɹ�	
				local onUseActionFinished = function()	--����ʹ�ý����Ļص�
					if self.isRunning then
						self:doFight() 
					end
				end
				useSkillAction:addStopNotify(onUseActionFinished, nil)	
			else	--��һ֡��ս��		
				self.fsm:changeState(self.mgr:getState(E_HandupStateType.FightBack), HandupStatePriority.FightBack)	
			end
		else
			self.fsm:changeState(self.mgr:getState(E_HandupStateType.FightBack), HandupStatePriority.FightBack, 0.2)	
		end
	end
end

--this will execute when the state is entered
function FightBackState:onEnter()
	if self.mgr:getHandupMode() == E_AutoSelectTargetMode.Collect then --�ɼ�ģʽ���ڷ���ģʽʱ��Ҫ������ϲɼ�
		GameWorld.Instance:getNpcManager():cancelCollect()		
	end
	self:doFight()
end

--this will execute when the state is exited. 
function FightBackState:onExit()
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoKillMonster) 
end


function FightBackState:onMessage(msg)
	local msgType = msg:getType()
	if msgType == E_HandupMsgType.BeAttacked then	--���ڷ���ʱ�������������������
--		local attacker = msg:getExtraInfo()
--		print("now is fight back. ignor attact with "..attacker:getId())
		return true
	else
		return false
	end
end