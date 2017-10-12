
--使用技能的行为播放器
require("common.baseclass")
require("object.actionPlayer.BaseActionPlayer")

local const_maxDuration = 1

UseSkillActionPlayer = UseSkillActionPlayer or BaseClass(BaseActionPlayer)

function UseSkillActionPlayer:__init()
	self.skillRefId = ""	
	self.des = "UseSkillActionPlayer"
end

function UseSkillActionPlayer:__delete()
end

function UseSkillActionPlayer:setSkillRefId(refId)
	self.skillRefId = refId
end

function UseSkillActionPlayer:getSkillRefId()
	return self.skillRefId
end

--重写
function UseSkillActionPlayer:doPlay()
	if (self.skillRefId == "" or self.skillRefId == nil) then
		error("UseSkillActionPlayer:doPlay failed. self.skillRefId is empty")
		return
	end
		
	local hero = G_getHero()
	local canUse, skillObject = hero:canUseSkill(self.skillRefId)
	if (not canUse) or (skillObject == nil) then
		self:stopFailed(0)
		return
	end	
		
	if skillObject:needFightTarget() then
		local target = GameWorld.Instance:getFightTargetMgr():getMainTargetObj()
		if not target then
			self:stopFailed(0)
			return
		end
		
		local skillRange = PropertyDictionary:get_skillRange(skillObject:getStaticData())
		if not hero:isInAttackRange(skillRange, target) then
			self:stopFailed(0)
			return
		end
		if hero:isOverlap(target) then
			local x, y = hero:getOneCellAround()
			if x and y then
				self:insertMoveAction(x, y)
				self:clear()
--				print("UseSkillActionPlayer:doPlay  restart succeed. ")	
				return
			else
				self:stopFailed(0)
				return
			end
		end
	end
			
	hero:useSkill(self.skillRefId)			

	local funcStateCallback = function (stateName, bEnter)
		if stateName == CharacterState.CharacterStateUseSkill then						
			if bEnter then
				self:setMaxPlayingDuration(const_maxDuration)
			else
				self:stopSucceed(0)
				G_getHero():removeStateChangeCallback(funcStateCallback)
			end
		end		
	end	
	self:setMaxPlayingDuration(const_maxDuration)
	G_getHero():addStateChangeCallback(funcStateCallback)	
end	

function UseSkillActionPlayer:clear()
	self:setState(E_ActionPlayerState.Waiting)
	self:setMaxPlayingDuration(const_maxDuration)
end

function UseSkillActionPlayer:insertMoveAction(cellX, cellY)
	local action = MoveActionPlayer.New()
	action:setCellXY(cellX, cellY)
	action:setCharacter(G_getHero():getId(), G_getHero():getEntityType())
	ActionPlayerMgr.Instance:insertPlayer(G_getHero():getId(), self, action)
end