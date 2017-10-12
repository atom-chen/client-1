--�һ����ܹ���
require	("common.baseclass")
require("data.skill.handUpSkill")
require("data.d_buff.d_buff")
HandupSkillMgr = HandupSkillMgr or BaseClass()

local const_skillHuoQiang = "monster_skill_1"

function HandupSkillMgr:__init()
	self.singleAttackSkillList = nil
	self.multipleAttackSkillList = nil
end	

function HandupSkillMgr:__delete()
end

--[[
"0=���幥��
1=Ⱥ�幥��
2=��������"
--]]
function HandupSkillMgr:getSkillRefIdByTarget(targetObj)
	local skillRefId
	local professionId = HandupCommonAPI:getProfessionId()
	if professionId == E_ProfessionType.eDaoShi then
		skillRefId = HandupSkillMgr:getDaoshiSkill(targetObj)
	elseif professionId == E_ProfessionType.eFaShi then
		skillRefId = HandupSkillMgr:getFashiSkill(targetObj)
	else	--սʿ
		skillRefId = HandupSkillMgr:getZhanshiSkill(targetObj)
	end
	
	if skillRefId == nil or skillRefId == "" then
		if not self:hasSelectAttackSkill() then	--û��ѡ�񹥻�Ŀ���ʱ�򣬲���Ҫʹ����ͨ
			if G_getHero():getSkillMgr():canUseSkill("skill_0") then
				skillRefId = "skill_0"
			end
		end
	end
	--print("HandupSkillMgr:getSkillRefIdByTarget skillRefId="..skillRefId)	
	return skillRefId		
end		

function HandupSkillMgr:getZhanshiSkill(targetObj)
	if HandupSkillMgr:checkCanUseSkill(const_skill_liehuojianfa) then	--�һ𽣷�
		if G_getHero():getSkillMgr():isReplaceSkillCDReady() then
			return const_skill_liehuojianfa
		end
	end
	return nil
end

local const_fashiSingleAttackSkillList =
{	
	"skill_fs_4",	 
	"skill_fs_6", 	
	"skill_fs_1"
}	

local const_fashiMultipleAttackSkillList= 
{		
	"skill_fs_12",  
	"skill_fs_10",
	"skill_fs_7", 	
}

local const_mofadunBuff = "buff_skill_3"
function HandupSkillMgr:getFashiSkill(targetObj)
	local selectedSkillList = G_getHandupConfigMgr():readHandupConfig().skillList	
	
	--����Ƿ���Ҫ����ħ����
	if HandupSkillMgr:checkCanUseSkill(const_skill_mofadun) then			
		if not G_getHero():getState():isState(CharacterFightState.Mofadun) then		
			return const_skill_mofadun
		end
	end
	
	local bNeedUseMultipleAttackSkill = HandupSkillMgr:needUseMultipleAttack(targetObj)	
	
	if bNeedUseMultipleAttackSkill then	--��Ҫʹ��Ⱥ������Ⱥ������
		for k, v in pairs(const_fashiMultipleAttackSkillList) do
			if HandupSkillMgr:checkCanUseSkill(v) then
				return v
			end
		end
		for k, v in pairs(const_fashiSingleAttackSkillList) do
			if HandupSkillMgr:checkCanUseSkill(v) then
				return v
			end
		end
	else	
		for k, v in pairs(const_fashiSingleAttackSkillList) do
			if HandupSkillMgr:checkCanUseSkill(v) then
				return v
			end
		end
		for k, v in pairs(const_fashiMultipleAttackSkillList) do
			if HandupSkillMgr:checkCanUseSkill(v) then
				return v
			end
		end	
	end		
	return nil
end

function HandupSkillMgr:getDaoshiSkill(targetObj)	
	local skillRefId
	
	if not G_getHero():hasPet() then
		--�ٻ�����
		skillRefId = "skill_ds_11"
		if HandupSkillMgr:checkCanUseSkill(skillRefId) then		
			return skillRefId
		end
		--�ٻ�����	
		skillRefId = "skill_ds_5"
		if HandupSkillMgr:checkCanUseSkill(skillRefId) then		
			return skillRefId
		end
	end
	
	--ħ����	
	skillRefId = "skill_ds_7"
	if HandupSkillMgr:checkCanUseSkill(skillRefId) then				
		if not HandupSkillMgr:checkBuffExist("buff_skill_7") then
			return skillRefId
		end
	end
	--�ּ���	
	skillRefId = "skill_ds_8"
	if HandupSkillMgr:checkCanUseSkill(skillRefId) then		
		if not HandupSkillMgr:checkBuffExist("buff_skill_8") then
			return skillRefId
		end
	end
	
	--������	
	skillRefId = "skill_ds_1"
	if HandupSkillMgr:checkCanUseSkill(skillRefId) then		
		if (not HandupSkillMgr:checkBuffExist("buff_skill_4")
			and (PropertyDictionary:get_HP(G_getHero():getPT()) < PropertyDictionary:get_maxHP(G_getHero():getPT()))) then
			return skillRefId
		end
	end
	
	--ʩ����
	skillRefId = "skill_ds_3"
	if HandupSkillMgr:checkCanUseSkill(skillRefId) and targetObj then		
		if not	targetObj:getState():isState(CharacterFightState.Poison)	then
			return skillRefId
		end
	end
	
	--�����
	skillRefId = "skill_ds_4"
	if HandupSkillMgr:checkCanUseSkill(skillRefId) then	
		return skillRefId
	end
	return nil
end	

function HandupSkillMgr:checkBuffExist(buffName)
	if GameWorld.Instance:getBuffMgr():checkBuffExist(buffName, G_getHero():getId()) then
		return true
	end
	local i = 1
	local extralBuffName = buffName.."_"..i	--��չbuff
	
	while (GameData.D_buff[extralBuffName]) do
		if GameWorld.Instance:getBuffMgr():checkBuffExist(extralBuffName, G_getHero():getId()) then
			return true
		end
		i = i + 1
		extralBuffName = buffName.."_"..i
	end
	return false
end

--�ж��Ƿ�ѡ�˹�������
function HandupSkillMgr:hasSelectAttackSkill()
	local selectedSkillList = G_getHandupConfigMgr():readHandupConfig().skillList	
	local has = false
	for k, v in pairs(selectedSkillList) do	
		local data = GameData.HandUpSkill[v]
		if data and (data.property.targetNum == 0 or data.property.targetNum == 1) then			
			local skillObject = G_getHero():getSkillMgr():getSkillObjectByRefId(v)
			if skillObject and skillObject:isLearn() then
				return true
			end
		end
	end
	
	return false
end

function HandupSkillMgr:checkCanUseSkill(refId)
	local selectedSkillList = G_getHandupConfigMgr():readHandupConfig().skillList	
	local has = false
	for k, v in pairs(selectedSkillList) do
		if v == refId then
			has = true
			break
		end
	end
	if has then
		if G_getHero():getSkillMgr():getReplaceSkillRefId() == refId then		
			return false
		end
		return G_getHero():getSkillMgr():canUseSkill(refId)
	else
		return false
	end
end	

--�Ƿ���Ҫʹ��Ⱥ��
function HandupSkillMgr:needUseMultipleAttack(targetObj)
	if not targetObj then
		return false
	end
	
	local cellX, cellY = targetObj:getCellXY()
	return self:monsterCountInRange(const_multipleAttackCheckRadius, cellX, cellY)	
end	

--��ĳ����Χ��monster������
function HandupSkillMgr:monsterCountInRange(radius, cellX, cellY)
	local list = GameWorld.Instance:getEntityManager():getMonsterList()

	local count = 0
	for k, v in pairs(list) do
		if v:getRefId() ~= const_skillHuoQiang then
			local x, y = v:getCellXY()
			local distance = HandupCommonAPI:calculateDistance(cellX, cellY, x, y)
			if distance <= radius then
				count = count + 1
				if count >= const_multipleAttackCheckCount then
					return true
				end
			end
		end
	end
	return false
end	