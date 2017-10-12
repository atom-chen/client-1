--[[
战斗的攻击目标/攻击者管理器
命名约定：
	Hero: 			玩家
	MainTarget: 	玩家攻击的主对象
	Attacker: 		攻击玩家的对象
--]]
require("common.baseclass")
require ("object.target.FightTargetDef")

FightTargetMgr = FightTargetMgr or BaseClass()

--连续使用技能N次错误后，会切换目标
MAX_USE_SKILL_ERROR_COUNT = 3

local const_autoRemoveAttackerInterval = 10 --xx 秒自动删除攻击者

function FightTargetMgr:__init()
	self.attackers = {}								--攻击者（对英雄进行攻击的单位：怪物，其他玩家）
	self.targetIgnoreList = {}						--保存战斗时被排除的目标
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
	self.attackers = {}							--攻击者（对英雄进行攻击的单位：怪物，其他玩家）
	self.targetIgnoreList = {}					--保存战斗时被排除的目标
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

--获取目标
function FightTargetMgr:getMainTargetObj()
	local mainTargetObj = nil
	local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	if entityFocusManager then
		local focusEntityType, focusEntityId = entityFocusManager:getFoucsEntity()
		local focusEntityObj = GameWorld.Instance:getEntityManager():getEntityObject(focusEntityType, focusEntityId)
		
		-- 检查目标是不是合法的攻击目标
		if focusEntityObj and self:checkGlobalTargetFilter(focusEntityObj) then
			mainTargetObj = focusEntityObj
		else
			--Juchao@20140805: 目标不合法，清理掉。
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
		--获取它的主人
		obj = obj:getOwnerObj()
		return obj
	end
	return nil
end

--如果该目标不存在，则增加
--存在则刷新cd存在时间为0
function FightTargetMgr:addAttacker(ttype, id)
	local obj = GameWorld.Instance:getEntityManager():getEntityObject(ttype, id)
	obj = self:getRealAttacker(obj)
	if not obj then
		return
	end
	local attacker = self.attackers[obj:getId()]	
	if attacker then
		GlobalEventSystem:Fire(GameEvent.EventBeAttacked, obj, false)  --obj攻击者对象，isNew 攻击者是否是新的
	else
		GlobalEventSystem:Fire(GameEvent.EventBeAttacked, obj, true)
	end		
	self.attackers[obj:getId()] = {obj = obj, duration = 0}
	if not self.updateAttackerSchId then
		self:startUpdateAttackers()
	end
end	

--删除攻击者
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


--增加使用技能错误计数。在重新选择目标之后会重置
function FightTargetMgr:addUseSkillErrorCount()
	self.useSkillErrorCount  = self.useSkillErrorCount + 1
end

--在重新选择目标之后调用
function FightTargetMgr:clearUseSkillErrorCount()
	self.useSkillErrorCount = 0
end	

--获取连续使用技能出错次数
function FightTargetMgr:getUseSkillErrorCount()
	return self.useSkillErrorCount 
end

--自动选择目标
--refIdList: 只选择在该列表内的refId的目标
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
	if mode == E_AutoSelectTargetMode.Normal then	--普通模式下，选择最近的怪
		target = HandupCommonAPI:getObj(EntityType.EntityType_Monster, filter, refIdList, selectType)	
	elseif mode == E_AutoSelectTargetMode.CastleWar then	--沙巴克模式		--沙巴克攻城优先打怪，再打其他公会玩家
		target = HandupCommonAPI:getObj(EntityType.EntityType_Monster, filter, refIdList, selectType)	
		if not target then
			target = HandupCommonAPI:getObj(EntityType.EntityType_Player, filter, refIdList, selectType)
		end		
	end
	if target then
		GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, target:getEntityType(), target:getId())
	end
	self:clearTargetIgnoreList() --清空忽略列表
	self:clearUseSkillErrorCount()
	return target
end	

--将entity增加到忽略列表里
function FightTargetMgr:addToTargetIgnoreList(serverId)
	self.targetIgnoreList[serverId] = true
end	

--设置一个忽略列表
function FightTargetMgr:setTargetIgnoreList(list)
	self.targetIgnoreList = list
end

--清楚忽略列表
function FightTargetMgr:clearTargetIgnoreList()
	self.targetIgnoreList = {}
end

--判断一个对象是否为忽略
function FightTargetMgr:isIgnored(serverId)
	return self.targetIgnoreList[serverId]
end

--全局的对象合法性检查(包括自动选择目标/使用技能前的目标检查)
local const_monster_skill_1 = "monster_skill_1" 	--火墙
function FightTargetMgr:checkGlobalTargetFilter(obj)
	if type(obj) ~= "table" then --不是一个table类型不合法
		return false
	end
	if not obj.getRefId then --如果没有getRefId这个函数不合法
		return false
	end
	
	if (obj.isHeroPet and obj:isHeroPet())then --不打英雄自己的宠物(注意，这里不能排除其他人的宠物)
		return false
	end
	
	if const_monster_skill_1 == obj:getRefId() then	--不打火墙
		return false
	end
			
	if not obj.getState then --没有该方法不合法
		return false
	end
	
	local state = obj:getState()	
	if not state then --没有状态不合法
		return false
	end
	
	if state:isState(CharacterState.CharacterStateDead) or --死亡或即将不合法
	   state:isState(CharacterState.CharacterStateWillDead) then
		return false
	end				

	return true
end

--根据模式获取目标过滤函数
function FightTargetMgr:getTargetFilter(mode)
	local searchFilter		
	if mode == E_AutoSelectTargetMode.Normal then				--普通模式
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
	elseif mode == E_AutoSelectTargetMode.Collect then			--采集模式
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
	elseif mode == E_AutoSelectTargetMode.CastleWar then			--沙巴克攻城
		searchFilter = function(obj, refIdList)
			if (not G_getFightTargetMgr():isIgnored(obj:getId())) 	--判断是否在忽略队列里
				and self:checkGlobalTargetFilter(obj)
				and ((not obj.hasOwner) or (not obj:hasOwner()))
				and ((not obj:getPT()) or PropertyDictionary:get_unionName(G_getHero():getPT()) ~= PropertyDictionary:get_unionName(obj:getPT())) then		--判断所在公会是否不一致
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

--判断一个对象是否为攻击者
function FightTargetMgr:isAttacker(serverId)
	local is = (self.attackers[serverId] ~= nil)	
	if is then
		return true
	else	--Juchao@20140728: 是的。还要判断英雄是否有宠物是攻击者
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