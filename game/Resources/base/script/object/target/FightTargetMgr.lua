--[[
ս���Ĺ���Ŀ��/�����߹�����
����Լ����
	Hero: 			���
	MainTarget: 	��ҹ�����������
	Attacker: 		������ҵĶ���
--]]
require("common.baseclass")
require ("object.target.FightTargetDef")

FightTargetMgr = FightTargetMgr or BaseClass()

--����ʹ�ü���N�δ���󣬻��л�Ŀ��
MAX_USE_SKILL_ERROR_COUNT = 3

local const_autoRemoveAttackerInterval = 10 --xx ���Զ�ɾ��������

function FightTargetMgr:__init()
	self.attackers = {}								--�����ߣ���Ӣ�۽��й����ĵ�λ�����������ң�
	self.targetIgnoreList = {}						--����ս��ʱ���ų���Ŀ��
	self.useSkillErrorCount = 0
	self:bindEntityRemoveEvent()
end	

function FightTargetMgr:__delete()
	self:clear()
	if self.removeEventId then
		GlobalEventSystem:UnBind(self.removeEventId)
		self.removeEventId = nil
	end
end

function FightTargetMgr:clear()
	self:clearTargetIgnoreList()
	self.attackers = {}							--�����ߣ���Ӣ�۽��й����ĵ�λ�����������ң�
	self.targetIgnoreList = {}					--����ս��ʱ���ų���Ŀ��
	self.useSkillErrorCount = 0
	self:stopUpdateAttackers()
end

function FightTargetMgr:bindEntityRemoveEvent()
	local onEntityRemoved = function(obj)	
		if obj and obj.getId then
			self:removeAttacker(obj:getId())
			self.targetIgnoreList[obj:getId()] = nil
		end
	end
	self.removeEventId = GlobalEventSystem:Bind(GameEvent.EventEntityRemoved, onEntityRemoved)  
end

--��ȡĿ��
function FightTargetMgr:getMainTargetObj()
	local mainTargetObj = nil
	local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	if entityFocusManager then
		local focusEntityType, focusEntityId = entityFocusManager:getFoucsEntity()
		local focusEntityObj = GameWorld.Instance:getEntityManager():getEntityObject(focusEntityType, focusEntityId)
		
		-- ���Ŀ���ǲ��ǺϷ��Ĺ���Ŀ��
		if focusEntityObj and self:checkGlobalTargetFilter(focusEntityObj) then
			mainTargetObj = focusEntityObj
		else
			--Juchao@20140805: Ŀ�겻�Ϸ����������
			entityFocusManager:clear() 
		end
	end
	
	return mainTargetObj
end		

function FightTargetMgr:getRealAttacker(obj)
	if not obj then
		return nil
	end
	if obj:getEntityType() == EntityType.EntityType_Player then
		return obj
	end
	if obj:getEntityType() == EntityType.EntityType_Monster and obj:hasOwner() then
		--��ȡ��������
		obj = obj:getOwnerObj()
		return obj
	end
	return nil
end

--�����Ŀ�겻���ڣ�������
--������ˢ��cd����ʱ��Ϊ0
function FightTargetMgr:addAttacker(ttype, id)
	local obj = GameWorld.Instance:getEntityManager():getEntityObject(ttype, id)
	obj = self:getRealAttacker(obj)
	if not obj then
		return
	end
	local attacker = self.attackers[obj:getId()]	
	if attacker then
		GlobalEventSystem:Fire(GameEvent.EventBeAttacked, obj, false)  --obj�����߶���isNew �������Ƿ����µ�
	else
		GlobalEventSystem:Fire(GameEvent.EventBeAttacked, obj, true)
	end		
	self.attackers[obj:getId()] = {obj = obj, duration = 0}
	if not self.updateAttackerSchId then
		self:startUpdateAttackers()
	end
end	

--ɾ��������
function FightTargetMgr:removeAttacker(serverId)
	local attacker = self.attackers[serverId]
	if attacker then
		GlobalEventSystem:Fire(GameEvent.EventAttackerRemoved, attacker.obj)
		self.attackers[serverId] = nil		
	end
	if table.isEmpty(self.attackers) then
		self:stopUpdateAttackers()
	end
end

function FightTargetMgr:startUpdateAttackers()
	self:stopUpdateAttackers()
	local onTimeout = function()
		for k, v in pairs(self.attackers) do
			v.duration = v.duration + 1
			if v.duration > const_autoRemoveAttackerInterval then
				self:removeAttacker(k)
--				print("remove attacker "..k)
			end
		end
	end
	self.updateAttackerSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)
end

function FightTargetMgr:stopUpdateAttackers()
	if self.updateAttackerSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateAttackerSchId)
		self.updateAttackerSchId = nil
	end
end


--����ʹ�ü��ܴ��������������ѡ��Ŀ��֮�������
function FightTargetMgr:addUseSkillErrorCount()
	self.useSkillErrorCount  = self.useSkillErrorCount + 1
end

--������ѡ��Ŀ��֮�����
function FightTargetMgr:clearUseSkillErrorCount()
	self.useSkillErrorCount = 0
end	

--��ȡ����ʹ�ü��ܳ������
function FightTargetMgr:getUseSkillErrorCount()
	return self.useSkillErrorCount 
end

--�Զ�ѡ��Ŀ��
--refIdList: ֻѡ���ڸ��б��ڵ�refId��Ŀ��
--selectType: E_SelectTargetType.Closest/E_SelectTargetType.Random
function FightTargetMgr:autoSelectTarget(refIdList, selectType)
	if selectType == nil then
		selectType = E_SelectTargetType.Closest
	end
	local mode
	local target
	
	local isInCastleWar = G_getCastleWarMgr():isInCastleWar()
	if isInCastleWar then
		mode = E_AutoSelectTargetMode.CastleWar
	else	
		mode = E_AutoSelectTargetMode.Normal
	end
	
	local filter = self:getTargetFilter(mode)
	if mode == E_AutoSelectTargetMode.Normal then	--��ͨģʽ�£�ѡ������Ĺ�
		target = HandupCommonAPI:getObj(EntityType.EntityType_Monster, filter, refIdList, selectType)	
	elseif mode == E_AutoSelectTargetMode.CastleWar then	--ɳ�Ϳ�ģʽ		--ɳ�Ϳ˹������ȴ�֣��ٴ������������
		target = HandupCommonAPI:getObj(EntityType.EntityType_Monster, filter, refIdList, selectType)	
		if not target then
			target = HandupCommonAPI:getObj(EntityType.EntityType_Player, filter, refIdList, selectType)
		end		
	end
	if target then
		GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, target:getEntityType(), target:getId())
	end
	self:clearTargetIgnoreList() --��պ����б�
	self:clearUseSkillErrorCount()
	return target
end	

--��entity���ӵ������б���
function FightTargetMgr:addToTargetIgnoreList(serverId)
	self.targetIgnoreList[serverId] = true
end	

--����һ�������б�
function FightTargetMgr:setTargetIgnoreList(list)
	self.targetIgnoreList = list
end

--��������б�
function FightTargetMgr:clearTargetIgnoreList()
	self.targetIgnoreList = {}
end

--�ж�һ�������Ƿ�Ϊ����
function FightTargetMgr:isIgnored(serverId)
	return self.targetIgnoreList[serverId]
end

--ȫ�ֵĶ���Ϸ��Լ��(�����Զ�ѡ��Ŀ��/ʹ�ü���ǰ��Ŀ����)
local const_monster_skill_1 = "monster_skill_1" 	--��ǽ
function FightTargetMgr:checkGlobalTargetFilter(obj)
	if type(obj) ~= "table" then --����һ��table���Ͳ��Ϸ�
		return false
	end
	if not obj.getRefId then --���û��getRefId����������Ϸ�
		return false
	end
	
	if (obj.isHeroPet and obj:isHeroPet())then --����Ӣ���Լ��ĳ���(ע�⣬���ﲻ���ų������˵ĳ���)
		return false
	end
	
	if const_monster_skill_1 == obj:getRefId() then	--�����ǽ
		return false
	end
			
	if not obj.getState then --û�и÷������Ϸ�
		return false
	end
	
	local state = obj:getState()	
	if not state then --û��״̬���Ϸ�
		return false
	end
	
	if state:isState(CharacterState.CharacterStateDead) or --�����򼴽����Ϸ�
	   state:isState(CharacterState.CharacterStateWillDead) then
		return false
	end				

	return true
end

--����ģʽ��ȡĿ����˺���
function FightTargetMgr:getTargetFilter(mode)
	local searchFilter		
	if mode == E_AutoSelectTargetMode.Normal then				--��ͨģʽ
		searchFilter = function(obj, refIdList)
			if type(refIdList) ~= "table" then
				refIdList = {}
			end
			if (obj:getEntityType() ~= EntityType.EntityType_Player
				and (not G_getFightTargetMgr():isIgnored(obj:getId())))
				and self:checkGlobalTargetFilter(obj)
				and ((not obj.hasOwner) or (not obj:hasOwner()))then
				if table.isEmpty(refIdList) then
					return true
				else
					return table.has(refIdList, obj:getRefId())
				end
			end
		end
	elseif mode == E_AutoSelectTargetMode.Collect then			--�ɼ�ģʽ
		searchFilter = function(obj, refIdList)
			if type(refIdList) ~= "table" then
				refIdList = {}
			end
			local mgr = GameWorld.Instance:getNpcManager()
			local canCollect, target = mgr:canCollect(obj:getId(), false)
			if (canCollect) and (not G_getFightTargetMgr():isIgnored(obj:getId())) then
				if table.isEmpty(refIdList) then
					return true
				else
					return table.has(refIdList, obj:getRefId())
				end
			end
		end			
	elseif mode == E_AutoSelectTargetMode.CastleWar then			--ɳ�Ϳ˹���
		searchFilter = function(obj, refIdList)
			if (not G_getFightTargetMgr():isIgnored(obj:getId())) 	--�ж��Ƿ��ں��Զ�����
				and self:checkGlobalTargetFilter(obj)
				and ((not obj.hasOwner) or (not obj:hasOwner()))
				and ((not obj:getPT()) or PropertyDictionary:get_unionName(G_getHero():getPT()) ~= PropertyDictionary:get_unionName(obj:getPT())) then		--�ж����ڹ����Ƿ�һ��
				if table.isEmpty(refIdList) then
					return true
				else
					return table.has(refIdList, obj:getRefId())
				end
			end
		end		
	end
	return searchFilter
end	

--�ж�һ�������Ƿ�Ϊ������
function FightTargetMgr:isAttacker(serverId)
	local is = (self.attackers[serverId] ~= nil)	
	if is then
		return true
	else	--Juchao@20140728: �ǵġ���Ҫ�ж�Ӣ���Ƿ��г����ǹ�����
		local obj = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player, serverId)
		if (not obj) or (not obj:hasPet()) then
			return false
		end
		return (self.attackers[obj:getPet()] ~= nil)
	end
end

function FightTargetMgr:getAttackers() 
	return self.attackers
end