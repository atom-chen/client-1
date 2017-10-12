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
	--��������
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
	skillEffect["attackX"] = StreamDataAdapter:ReadShort(reader)	--�����ߵ�����
	skillEffect["attackY"] = StreamDataAdapter:ReadShort(reader)
	skillEffect["targetType"] = StreamDataAdapter:ReadChar(reader)--string->byte
	skillEffect["targetId"]   = StreamDataAdapter:ReadStr(reader)
	skillEffect["targetX"] = StreamDataAdapter:ReadShort(reader)	--�������ߵ�����
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
	if 	(0 == owner) then	--����attacker
		effect:setOwner(skillEffect.attackType, skillEffect.attackerId)
	else	--����target
		effect:setOwner(skillEffect.targetType, skillEffect.targetId)
	end
	
	local effectType = reader:ReadChar()--����Ч������
	effect:setType(effectType)
	local effectParam	--����Ч������
	if (effectType == E_SkillEffectType.Keeptime) then	--������ǽ
		effectParam = reader:ReadShort()  --int-->short
	elseif (effectType == E_SkillEffectType.Transport) then
		-- ˲��
		effectParam = {}
		effectParam["startX"] = reader:ReadShort()  --int ->short
		effectParam["startY"] = reader:ReadShort()  --int ->short
		effectParam["endX"] = reader:ReadShort()  --int ->short
		effectParam["endY"] = reader:ReadShort()  --int ->short
	elseif (effectType == E_SkillEffectType.HP or effectType == E_SkillEffectType.Criti or effectType == E_SkillEffectType.Addblood) then
		-- HP,����,��Ѫ
		effectParam = {}
		effectParam["HarmValue"] = reader:ReadInt()
		effectParam["CurrentValue"] = reader:ReadInt()
		effectParam["MaxValue"] = reader:ReadInt()
		
		local heroId = G_getHero():getId()	
		--Juchao@20140505: ������ֻ�Է�Ӣ�۵�Ѫ�����и��£�Ӣ�۵�Ѫ������ͳһ�����Ը���Э��
		if (skillEffect.targetId == heroId) then			
			if effectParam.HarmValue > 0 and skillEffect.attackerId ~= heroId then	--����˺�ֵ����0������Ϊ�Ƕ�Ӣ�۵Ĺ���
				G_getFightTargetMgr():addAttacker(skillEffect.attackType, skillEffect.attackerId) 
			end
		else	
			-- �ȸ���Ѫ��
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
		
		-- ����˺�Ϊ0, ɾ����ε�Ч��
		if effectParam["HarmValue"] == 0 then
			effect:DeleteMe()
			effect = nil
		end

	elseif effectType == E_SkillEffectType.Dead then
		-- ������Լ���������Ϣ, ���Ե��� �Լ������������Ը��µ���Ϣ
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
		-- �ٻ�
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