require("actionEvent.ActionEventDef")
require("common.ActionEventHandler")
require("object.skillShow.SkillShowManager")
require("object.skillShow.SkillEffect")
SkillActionHandler = SkillActionHandler or BaseClass(ActionEventHandler)

function SkillActionHandler:__init()
	local g2c_skilllist_func = function (reader)
		self:hanlde_g2c_skiillList(reader)
		GlobalEventSystem:Fire(GameEvent.EventRefreshView)
	end
	
	local g2c_TriggerSingleTargetSkill_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handle_g2c_TriggerSingleTargetSkill(reader)
	end
	
	local g2c_TriggerMultiTargetSkill_func = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handle_g2c_TriggerMultiTargetSkill(reader)
	end
	
	local g2c_addSkillExp_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handle_g2c_addSkillExp(reader)
	end
	
	self:Bind(ActionEvents.G2C_AddskillExp, g2c_addSkillExp_func)
	self:Bind(ActionEvents.G2C_GetLearnedSkillList, g2c_skilllist_func)
	self:Bind(ActionEvents.G2C_TriggerSingleTargetSkill, g2c_TriggerSingleTargetSkill_func)
	self:Bind(ActionEvents.G2C_TriggerMultiTargetSkill, g2c_TriggerMultiTargetSkill_func)
end      	

function SkillActionHandler:hanlde_g2c_skiillList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local propertyTable = {}
	--技能数量
	local skillCount = reader:ReadChar()  --short->byte
	for i=1, skillCount do
		propertyTable[i] = {}
		propertyTable[i]["skillRefId"] = StreamDataAdapter:ReadStr(reader)
		propertyTable[i]["level"] = reader:ReadChar()  --int->byte
		propertyTable[i]["skillExp"] = reader:ReadShort()  --int->short
		propertyTable[i]["quickSkill"] = reader:ReadChar()
	end
	local skillMgr = GameWorld.Instance:getSkillMgr()
	skillMgr:setTableList(propertyTable, skillCount)	
end

function SkillActionHandler:handle_g2c_TriggerSingleTargetSkill(reader)
	local skillEffect = {}
	
	skillEffect["skillRefId"] = StreamDataAdapter:ReadStr(reader)
	skillEffect["attackType"] = StreamDataAdapter:ReadChar(reader) --string->byte
	skillEffect["attackerId"] = StreamDataAdapter:ReadStr(reader)
	skillEffect["attackX"] = StreamDataAdapter:ReadShort(reader)	--攻击者的坐标
	skillEffect["attackY"] = StreamDataAdapter:ReadShort(reader)
	skillEffect["targetType"] = StreamDataAdapter:ReadChar(reader)--string->byte
	skillEffect["targetId"]   = StreamDataAdapter:ReadStr(reader)
	skillEffect["targetX"] = StreamDataAdapter:ReadShort(reader)	--被攻击者的坐标
	skillEffect["targetY"] = StreamDataAdapter:ReadShort(reader)
	
	local effectCount = reader:ReadChar() --int -->btte
	
	skillEffect["effects"] = {}
	for i=1, effectCount do
		local effect = self:createSkillEffect(reader, skillEffect)
		if effect then
			skillEffect["effects"][i]  = effect
		end
	end
	
	SkillShowManager:handleSkillUse(skillEffect)
end	

function SkillActionHandler:handle_g2c_TriggerMultiTargetSkill(reader)
	local skillEffect = {}
	
	skillEffect["skillRefId"] = StreamDataAdapter:ReadStr(reader)
	skillEffect["attackType"] = StreamDataAdapter:ReadChar(reader)  --string->byte
	skillEffect["attackerId"] = StreamDataAdapter:ReadStr(reader)
	skillEffect["dstType"] = reader:ReadChar()
		
	if skillEffect["dstType"] == 1  then
		skillEffect["cellX"] = reader:ReadShort()  --int->short
		skillEffect["cellY"] = reader:ReadShort() --int->short
	elseif skillEffect["dstType"] == 2 then
		local direction = reader:ReadChar()
		if direction < 6 then
			direction = direction + 8
		end
		
		skillEffect["direction"] = direction - 6
	end
	
	local targetCount = reader:ReadChar()  --int -->char
	skillEffect["effects"] = {}
	for i=1, targetCount do
		skillEffect["targetType"] = StreamDataAdapter:ReadChar(reader)  --string->int
		skillEffect["targetId"]   = StreamDataAdapter:ReadStr(reader)
		
		local effectCount =  reader:ReadChar()  --int-->byte
		for j=1,effectCount do
			local effect = self:createSkillEffect(reader, skillEffect)
			if effect then
				table.insert(skillEffect["effects"], effect)
			end
		end
	end
	
	SkillShowManager:handleSkillUse(skillEffect)
end

function SkillActionHandler:createSkillEffect(reader, skillEffect)
	local effect = SkillEffect.New()
	effect:setSkillRefId(skillEffect.skillRefId)
	local owner = reader:ReadChar()
	if 	(0 == owner) then	--属于attacker
		effect:setOwner(skillEffect.attackType, skillEffect.attackerId)
	else	--属于target
		effect:setOwner(skillEffect.targetType, skillEffect.targetId)
	end
	
	local effectType = reader:ReadChar()--技能效果类型
	effect:setType(effectType)
	local effectParam	--技能效果参数
	if (effectType == E_SkillEffectType.Keeptime) then	--持续火墙
		effectParam = reader:ReadShort()  --int-->short
	elseif (effectType == E_SkillEffectType.Transport) then
		-- 瞬移
		effectParam = {}
		effectParam["startX"] = reader:ReadShort()  --int ->short
		effectParam["startY"] = reader:ReadShort()  --int ->short
		effectParam["endX"] = reader:ReadShort()  --int ->short
		effectParam["endY"] = reader:ReadShort()  --int ->short
	elseif (effectType == E_SkillEffectType.HP or effectType == E_SkillEffectType.Criti or effectType == E_SkillEffectType.Addblood) then
		-- HP,暴击,加血
		effectParam = {}
		effectParam["HarmValue"] = reader:ReadInt()
		effectParam["CurrentValue"] = reader:ReadInt()
		effectParam["MaxValue"] = reader:ReadInt()
		
		local heroId = G_getHero():getId()	
		--Juchao@20140505: 在这里只对非英雄的血量进行更新，英雄的血量更新统一走属性更新协议
		if (skillEffect.targetId == heroId) then			
			if effectParam.HarmValue > 0 and skillEffect.attackerId ~= heroId then	--如果伤害值大于0，则认为是对英雄的攻击
				G_getFightTargetMgr():addAttacker(skillEffect.attackType, skillEffect.attackerId) 
			end
		else	
			-- 先更新血量
			local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(effect:getEntityType(), effect:getServerId())
			if characterObject then
				characterObject:setMaxHP(effectParam["MaxValue"])
				local curValue = effectParam["CurrentValue"]
				characterObject:setHP(curValue)
				local bossId = GameWorld.Instance:getEntityManager():getBossId()			
				if bossId == characterObject:getId() then					
					GlobalEventSystem:Fire(GameEvent.EventMainBOSSPorpertyUpdate, curValue)
				else
					GlobalEventSystem:Fire(GameEvent.EventPlayerHeadUpdate, curValue)
				end	
			end
		end
		
		-- 如果伤害为0, 删掉这次的效果
		if effectParam["HarmValue"] == 0 then
			effect:DeleteMe()
			effect = nil
		end

	elseif effectType == E_SkillEffectType.Dead then
		-- 如果是自己的死亡消息, 忽略掉， 自己的死亡走属性更新的消息
		if effect:getServerId() == GameWorld.Instance:getEntityManager():getHero():getId() then
			effect:DeleteMe()
			effect = nil
		else			
			local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(effect:getEntityType(), effect:getServerId())
			if characterObject then
				characterObject:DoWillDeath()
			end
		end
	elseif effectType == E_SkillEffectType.Sumon then
		-- 召唤
		effectParam = {}
		effectParam["targetList"] = {}
		local targetCount = reader:ReadChar()  --int->byte
		for i=1, targetCount do
			local targetId = StreamDataAdapter:ReadStr(reader)
			table.insert(effectParam["targetList"], targetId)
		end
	end
	
	if effect then
		effect:setEffectParam(effectParam)
	end
	
	return effect
end

function SkillActionHandler:handle_g2c_addSkillExp(reader)
	local skillRefId = StreamDataAdapter:ReadStr(reader)
	local skillExp = reader:ReadInt()
	local curLv = reader:ReadInt()
	
	local skillMgr = GameWorld.Instance:getSkillMgr()
	skillMgr:handle_addSkillExp(skillRefId, skillExp, curLv)
end