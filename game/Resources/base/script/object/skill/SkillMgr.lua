require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.skill.SkillObject")
require("ui.UIManager")
require "ui.skill.SkillUtils"
require"data.skill.skill"
SkillMgr = SkillMgr or BaseClass()

--��������
SkillType = {
PlusSkill = 0,  --�ӵ㼼��
PassiveSkill = 1, --��������
ActiveSkill = 2, --��������
SwitchSkill = 3, --���ؼ���
}

local const_autoUseSkillCD = 0.1
local switchSkill_banyue = "skill_zs_4"
local switchSkill_cisha = "skill_zs_3"
local switchSkill_gongsha = "skill_zs_2"

local common_cd_attack = 0.6			-- ��ͨ������CD
local common_cd_skill = 1.2				-- ��ʦ�͵�ʿ�Ĺ�����CD
local common_cd_skill_zhanshi = 0.7 	-- սʿ�Ĺ���CD

function SkillMgr:__init()
	SkillUtils.New()
	self.markTable = {}   --�����ݼ���
	self.preMarkTable = {}  --ǰһ����ݼ����б�
	self.updateList = {} --����Ҫ���µļ���
	self.allSkill = {}
	self.cdSkillList = {} -- CD�еļ����б�		
	self.uiIndex = {}		
	self.reConnect = false  --���������ı��
	
	self.commonCD = 0
	self.replaceSkillRefId = "" -- ĳЩ������ʹ���Ժ�, ����һ��ʹ�õļ����滻������������һ��
	self.replaceTime = -1
	self.autoUseSkillCD = 0
	self.attactSkillCount = 0
end

function SkillMgr:__delete()
	if self.allSkill then 
		for _, v in pairs(self.allSkill) do 
			v:DeleteMe()
		end
		self.allSkill = nil
	end		
end

function SkillMgr:clear()
	self:setReconnect(true)  --��������
	
	if self.allSkill then 
		for _, v in pairs(self.allSkill) do 
			v:DeleteMe()
		end
		self.allSkill = nil		
	end
	self.jichuSkill = nil
	
	self.markTable = {}  	--�����ݼ���
	self.updateList = {} 	--����Ҫ���µļ���	@
	self.cdSkillList = {} 	--CD�еļ����б�		
	self.preMarkTable = {}
	self.uiIndex = {}
	
	self.commonCD = 0
	self.replaceSkillRefId = ""
	self.replaceTime = -1
	self.autoUseSkillCD = 0
end

function SkillMgr:setReconnect(bReconnect)
	if bReconnect then
		self.reConnect = bReconnect
	end
end

function SkillMgr:isReconnect()
	return self.reConnect
end

function SkillMgr:setAutoUseSkill(bAuto)
	self.bIsAutoUseSkill = bAuto
	if bAuto then	
--		self.autoUseSkillCD = const_autoUseSkillCD * 10
		self.autoUseSkillCD = 1
--		self:resetAutoUseSkillCD()
	else
		self.autoUseSkillCD = 0
	end
end	

function SkillMgr:resetAutoUseSkillCD()
	self.autoUseSkillCD = const_autoUseSkillCD
end

function SkillMgr:isAutoUseSkill()
	return self.bIsAutoUseSkill
end

function SkillMgr:getReplaceSkillRefId()
	return self.replaceSkillRefId
end

function SkillMgr:isReplaceSkillCDReady()
	return not (self.replaceTime > 0)
end

function SkillMgr:setReplaceSkill(skillRefId, time)
	if self.replaceSkillRefId ~= skillRefId and self:getSkillObjectByRefId(skillRefId) then
		if string.find(skillRefId, "skill_zs_6") then
			-- ����һ����ʾ
			local msg = {}
			table.insert(msg,{word = Config.Words[2026], color = Config.FontColor["ColorRed3"]})
			UIManager.Instance:showSystemTips(msg)
			--UIManager.Instance:showSystemTips(Config.Words[2026])
		end
		self.replaceSkillRefId = skillRefId	
		if time and time > 0 then
			self.replaceTime = time
		end
	end
end	
--��������������б�
function SkillMgr:requestSkillList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GetLearnedSkillList)
	simulator:sendTcpActionEventInLua(writer)
end

--����������¿��ټ���
function SkillMgr:requestSetPutdownSkills(updateTable)
	if self:isTableEmpty(updateTable) == false then
		if updateTable.delete ~= nil then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_SetPutdownSkill)
			StreamDataAdapter:WriteStr(writer, updateTable.delete.refId)
			writer:WriteShort(updateTable.delete.index)
			simulator:sendTcpActionEventInLua(writer)
			GlobalEventSystem:Fire(GameEvent.EventRemoveCdSprite, updateTable.delete.index)--ɾ���������cd progresstimer
		end
		if updateTable.modify ~= nil then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_SetPutdownSkill)
			StreamDataAdapter:WriteStr(writer, updateTable.modify.refId)
			writer:WriteShort(updateTable.modify.index)
			simulator:sendTcpActionEventInLua(writer)
		end
	end
end

-- ʹ�ü���
function SkillMgr:requestUseSkillByCharacter(skillRefId, targetId, targetType)
	if self:getSkillObjectByRefId(skillRefId) ~= nil then
		if targetId and targetType then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_UseSkill)
			writer:WriteString(skillRefId)
			writer:WriteChar(0)
			writer:WriteString(targetType)
			writer:WriteString(targetId)
			simulator:sendTcpActionEventInLua(writer)
		end
	end
end

function SkillMgr:requestUseSkillByPos(skillRefId, targetX, targetY)
	if self:getSkillObjectByRefId(skillRefId) ~= nil then
		if targetX and targetY then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_UseSkill)
			writer:WriteString(skillRefId)
			writer:WriteChar(1)
			writer:WriteInt(targetX)
			writer:WriteInt(targetY)
			simulator:sendTcpActionEventInLua(writer)
		end
	end
end

function SkillMgr:requestUseSkillByDirection(skillRefId, direction)
	if self:getSkillObjectByRefId(skillRefId) ~= nil then
		if direction then
			-- ת��Ϊ�������ĳ���
			direction = direction+6
			direction = direction%8
			
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_UseSkill)
			writer:WriteString(skillRefId)
			writer:WriteChar(2)
			writer:WriteChar(direction)
			simulator:sendTcpActionEventInLua(writer)
		end
	end
end	

function SkillMgr:requestAddSkillExp(skillRefId)
	if self:getSkillObjectByRefId(skillRefId) then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_AddSkillExp)
		writer:WriteString(skillRefId)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function SkillMgr:handleUseSkill(skillRefId)
	if skillRefId == nil then
		return
	end
	skillRefId = self:switchToExtendSkill(skillRefId)
	-- CD���ܵ����ٵ�Ӱ��
	local cdOffset = 0
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local atkSpeed = PropertyDictionary:get_atkSpeedPer(hero:getPT())
	if atkSpeed > 0 then
		-- ����û���10%, CD����30ms
		cdOffset = -0.03*atkSpeed/10
	end
	
	-- ����CD��ְҵ
	local hero =  GameWorld.Instance:getEntityManager():getHero()
	local heroProId = PropertyDictionary:get_professionId(hero:getPT())
	if heroProId == ModeType.ePlayerProfessionWarior then
		self:refreshSkillCD(common_cd_skill_zhanshi+cdOffset, skillRefId)	
	else
		self:refreshSkillCD(common_cd_skill+cdOffset, skillRefId)	
	end
				
end

--ˢskillcd��ʱ��Ҳˢ����cd
function SkillMgr:refreshSkillCD(cdTime, skillRefId)
	if cdTime and skillRefId then
		if skillRefId ~= const_skill_pugong then 
			local skillObject = self:getSkillObjectByRefId(skillRefId)
			if skillObject then
				skillObject:refreshCD()
				self.cdSkillList[skillRefId] = skillObject		
				--����һ��ˢ��CD��gameEvent
				--GlobalEventSystem:Fire(GameEvent.EventRefeshSkillCD, skillRefId, skillObject:getCurrentCD())
			end			
		end
		
		if skillRefId == "skill_0" then
			self.commonCD = 0.6
		else
			self.commonCD = cdTime
		end
		
		GlobalEventSystem:Fire(GameEvent.EventRefeshSkillCD, skillRefId, cdTime)
	end
end

function SkillMgr:isCommonCDReady()
	return self.commonCD == 0
end

--��Ӽ���������
function SkillMgr:handle_addSkillExp(skillRefId, skillExp, curLv)
	if skillRefId and skillExp and curLv then
		skillRefId = G_getHero():getEquipSkill(skillRefId)
		local skillObject = self:getSkillObjectByRefId(skillRefId)
		if skillObject then
			local pt = skillObject:getPT()
			PropertyDictionary:set_skillExp(pt, skillExp)
			local preLv = PropertyDictionary:get_level(pt)
			if curLv > preLv then
				local name = PropertyDictionary:get_name(skillObject:getStaticData())
				local msg = {}
				table.insert(msg,{word = name, color = Config.FontColor["ColorRed1"]})
				table.insert(msg,{word = Config.Words[2502], color = Config.FontColor["ColorBlue2"]})
				table.insert(msg,{word = tostring(curLv), color = Config.FontColor["ColorRed1"]})
				table.insert(msg,{word = Config.Words[2506], color = Config.FontColor["ColorBlue2"]})
				UIManager.Instance:showSystemTips(msg)
			end			
			PropertyDictionary:set_level(pt, curLv)
			GlobalEventSystem:Fire(GameEvent.EventShowSkillDetailInfo, skillObject)
		end
	end
end

--��ȡ��������
function SkillMgr:getSkillCount()
	--����ʾ��ui����ļ���Ϊ׼
	return table.size(self.uiIndex)
end

--���ü����б�
function SkillMgr:setTableList(tableList, skillCount)
	local reader = CCUserDefault:sharedUserDefault()
	self.attactSkillCount = 0	
	for index, pt in pairs(tableList) do 
		local skill = SkillObject.New()
		skill:setPT(pt)		
		local skillRefId = PropertyDictionary:get_skillRefId(skill:getPT())				
		local status = reader:getIntegerForKey(skillRefId)   --û��refId�� Ĭ����0
		local targetType = PropertyDictionary:get_skillTargetType(skill:getStaticData())
		if targetType == 2 and skillRefId ~= "skill_0" then
			self.attactSkillCount = self.attactSkillCount + 1
		end
		if status == 0 or status == 1 then
			skill:setSwitchStatus(true, true)
			self:resetReplaceSkillSwitch(skillRefId, true)
		else
			skill:setSwitchStatus(false, true)
			self:resetReplaceSkillSwitch(skillRefId, false)
		end
		self:setSkillCD(skill)
		self:replaceSkill(skill)			
	end		
				
	self:updateQuickSkill() --���¿�ݼ���	
end

function SkillMgr:setSkillCD(skillObject)
	if skillObject == nil then
		return
	end
	
	local skillRefId = PropertyDictionary:get_skillRefId(skillObject:getPT())
	local level = PropertyDictionary:get_level(skillObject:getPT())
	local effectData = skillObject:getSkillLevelPropertyTable(level)
	
	local cdTime = 0
	if effectData then
		cdTime = PropertyDictionary:get_skillCDTime(effectData)/1000
	end
	
	if cdTime == 0 then
		cdTime = common_cd_skill
	end
	
	skillObject:setSkillCD(cdTime)
end

function SkillMgr:getMarkList()
	return self.markTable
end

function SkillMgr:getPreMarkList()
	return self.preMarkTable
end

--����id��ȡ���ܶ���
function SkillMgr:getSkillObjectById(id)
	local skillRefId = self.uiIndex[id]
	skillRefId = G_getHero():getEquipSkill(skillRefId)
	if skillRefId then 
		return self:getSkillObjectByRefId(skillRefId)
	end		
end

--����refId��ȡ���ܶ���
function SkillMgr:getSkillObjectByRefId(refId)
	if self.allSkill and refId then 
		return self.allSkill[refId]	
	end
end	

--���¿��ؼ���
--skillRefId: ����refId
--status:   true/false
function SkillMgr:updateSwitchSkill(skillRefId, status)
	local skillObject = self:getSkillObjectByRefId(skillRefId)
	if skillObject then
		if SkillType.SwitchSkill == PropertyDictionary:get_skillType(skillObject:getStaticData()) then
			skillObject:setSwitchStatus(status)
			self:resetReplaceSkillSwitch(skillRefId,status)
			local index = 0
			for refId, v in pairs(self.markTable) do
				if skillRefId == refId then
					index = v.index
				end
			end
			GlobalEventSystem:Fire(GameEvent.EventUpdateSwitchSkill, index)
		end
	end
end

--���ݼ��ܲ۵�������ȡ��ݼ��ܵ�refId
function SkillMgr:getQuickSkillRefIdByIndex(index)
	for _, v in pairs(self.markTable) do
		if v.index == index then
			local refId = self:switchToExtendSkill(v.refId)
			return refId
		end
	end
	return nil
end

function SkillMgr:isTableEmpty(t)
	if next(t)==nil then
		return true
	end
	return false
end

--��ȡ��ݼ�������
function SkillMgr:getQuickSkillCount()
	return table.size(self.markTable)
end

function SkillMgr:tick(time)
	if self.autoUseSkillCD > 0 then
		self.autoUseSkillCD = self.autoUseSkillCD - time
		if self.autoUseSkillCD <= 0 then
			self.autoUseSkillCD = 0			
			GlobalEventSystem:Fire(GameEvent.EventAutoUseSkillCDReady)
		end
	end
	
	if self.replaceTime > 0 then
		self.replaceTime = self.replaceTime - time
		
		if self.replaceTime < 0 then
			self.replaceSkillRefId = ""
			self.replaceTime = -1			
		end
	end
	
	for k, v in pairs(self.cdSkillList) do
		v:update(time)		
		if v:isReady() then
			self.cdSkillList[k] = nil
		end
	end
	
	if self.commonCD > 0 then
		self.commonCD = self.commonCD - time
		if self.commonCD < 0 then
			self.commonCD = 0
		end
	end
end	

-- ��鼼���Ƿ���Ϊ���������滻
function SkillMgr:checkReplaceSkill(skillRefId)
	if self.replaceSkillRefId ~= "" and self:canUseSkill(self.replaceSkillRefId) then
		skillRefId = self.replaceSkillRefId
		self.replaceSkillRefId = ""
--		self.replaceTime = -1	 --Juchao@20140320�������������Ϊ-1����Ϊ�һ𽣷�����ȴʱ��Ϊ10s��	
	elseif skillRefId == const_skill_pugong then
		-- ����й�ɱ�����ж��Ƿ��ܴ�����ɱ
		if self:canUseSkill(const_skill_gongsha) and math.random() < 0.2 then
			--��ɱ����Ҫ�����
			skillRefId = const_skill_gongsha
		elseif self:canUseSkill(switchSkill_banyue) then
			skillRefId = switchSkill_banyue
		elseif self:canUseSkill(switchSkill_cisha) then
			skillRefId = switchSkill_cisha
		end
	end
	
	return skillRefId
end	
--����滻����CD
function SkillMgr:checkRepalaceSkillCD(skillRefId)
	for k ,v in pairs(self.allSkill) do
		if  string.find(k,skillRefId .. "_") then
			local skillObject = self:getSkillObjectByRefId(k)
			if skillObject ~= nil then			
				if skillObject:isReady() == false then
					return false
				end		
			end
		end
	end
	return true
end
--����滻���ܿ���
function SkillMgr:checkReplaceSkillSwitch(skillRefId)
	for k,v in pairs(self.allSkill) do
		if string.find(k,skillRefId .. "_") then
			local skillObject = self:getSkillObjectByRefId(k)
			if skillObject ~= nil then			
				if skillObject:getSwitchStatus() == false then
					return false
				end		
			end
		end
	end
	return true
end

--����ͬ�ּ��ܿ���״̬
function SkillMgr:resetReplaceSkillSwitch(skillRefId ,state)
	local originRefId = string.match(skillRefId,"(%a+_%a+_%d+)")
	if originRefId then
		for k,v in pairs(self.allSkill) do
			if k == originRefId  or string.find(k,originRefId .. "_")  then
				local skillObject = self:getSkillObjectByRefId(k)
				if skillObject ~= nil then			
					skillObject:setSwitchStatus(state)					
				end
			end
		end
	end
end

--[[
�ж��Ƿ���ʹ���������, �����һ���ж�
1. ����ʱ�����������
2. ��������Ƿ�ѧϰ
3. ��鿪��״̬
4. ����CD
6. �Ƿ���
]]
function SkillMgr:canUseSkill(skillRefId)
	local skillObject = self:getSkillObjectByRefId(skillRefId)
	if skillObject == nil then
		return false
	end			
	local hero = GameWorld.Instance:getEntityManager():getHero()	
	local canUse = (skillObject:isLearn() and skillObject:getSwitchStatus() and skillObject:isReady() and PropertyDictionary:get_MP(hero:getPT()) >= skillObject:getMp() and self:isCommonCDReady() and self:checkRepalaceSkillCD(skillRefId) and self:checkReplaceSkillSwitch(skillRefId) )	
	
	return canUse, skillObject
end	

function SkillMgr:updateQuickSkill()
	self.preMarkTable = {}
	--������һ�εĿ�ݼ���
	for k, v in pairs(self.markTable) do 
		self.preMarkTable[k] = {}
		self.preMarkTable[k].refId = v.refId
		self.preMarkTable[k].index = v.index
	end
	self.markTable = {}
	--��ȡ��ݼ���
	for refId, skillObj in pairs(self.allSkill) do 
		local quickSkill = PropertyDictionary:get_quickSkill(skillObj:getPT())		
		if quickSkill ~= -1 then
			if quickSkill >= 1 and quickSkill <= 8 then			
				self.markTable[refId] = {}
				self.markTable[refId].refId = refId
				self.markTable[refId].index = quickSkill				
			end
		end
	end
end

function SkillMgr:requestUseSkill(skillRefId, attacker, target)
	local skillObject = self:getSkillObjectByRefId(skillRefId)
	if skillObject and attacker then
		-- ���ռ��ܵ����ͣ����Ͳ�ͬ��Э��
		local skillAimType = PropertyDictionary:get_skillAimType(skillObject:getStaticData())
		
		-- ��Ŀ��ͶԸ��ӵļ��ܱ����й���Ŀ�����ʩ��
		if (1 == skillAimType or 3 == skillAimType) and target then
			if 1 == skillAimType then
				self:requestUseSkillByCharacter(skillRefId, target:getId(), target:getEntityType())
			else
				local x, y = target:getCellXY()
				self:requestUseSkillByPos(skillRefId, x, y)
			end
		elseif 2 == skillAimType then
			local direction = attacker:getAngle()
			self:requestUseSkillByDirection(skillRefId, direction)
		end
	end
end

--�Ѿ�̬���ݱ�����и�ְҵ�ļ��ܶ��������� ����refId�Ϳ��ؼ���״̬ �������ݶ��Ǽ���
function SkillMgr:loadAllSkill()
	self.allSkill = {}
	self.jichuSkill = {}
	local reader = CCUserDefault:sharedUserDefault()
	local heroProId = PropertyDictionary:get_professionId(G_getHero():getPT())
	for k, v in pairs(GameData.Skill) do			
		local professionId = v.property.professionId
		if professionId == 0 or professionId == heroProId then
			-- ֻ�л������ܲ���ʾ��UI����			
			local obj = SkillObject.New()			
			local pt = {}
			pt.skillRefId = v.refId			
			pt.level = 1
			pt.skillExp = -10
			pt.quickSkill = -1
			obj:setPT(pt)
			--���ÿ���״̬
			local status = reader:getIntegerForKey(v.refId)   --û��refId�� Ĭ����0
			if status == 0 or status == 1 then
				obj:setSwitchStatus(true, true)
				self:resetReplaceSkillSwitch(v.refId,true)
			else
				obj:setSwitchStatus(false, true)
				self:resetReplaceSkillSwitch(v.refId,true)
			end
			self.allSkill[v.refId] = obj					
			if PropertyDictionary:get_skillGroupId(v.property) == 0 then
				self.jichuSkill[v.refId] = obj
			end
		end
	end		
	--���似�ܵ�UI����
	self:allocateUiIndex()	
end	

--����ѧϰ�ȼ�������������һ����ʾ�ڼ��ܽ���ļ���������1���Դ�����
function SkillMgr:allocateUiIndex()
	local index = 1
	local tmpTable = {}
	--�����tmpTable������������Ϊself.jichuSkill����refId��Ϊ�����ģ����ܶ�����������
	for _, skillObj in pairs(self.jichuSkill) do 			
		tmpTable[index] = skillObj	
		index = index + 1
	end		
	
	local sortByLevel = function (a, b)
		local lvA = PropertyDictionary:get_skillLearnLevel(a:getStaticData())
		local lvB = PropertyDictionary:get_skillLearnLevel(b:getStaticData())
		return lvA < lvB
	end
	table.sort(tmpTable, sortByLevel)
	
	index = 1
	for _, skillObj in pairs(tmpTable) do
		self.uiIndex[index] = PropertyDictionary:get_skillRefId(skillObj:getPT())
		index = index + 1
	end		
end

--���Ѿ�ѧ��ļ������
function SkillMgr:replaceSkill(skillObj)
	if skillObj then 
		local refId = PropertyDictionary:get_skillRefId(skillObj:getPT())
		if self.allSkill[refId] then 
			local preObj = self.allSkill[refId]
			local curLv = PropertyDictionary:get_level(skillObj:getPT())
			local preLv = PropertyDictionary:get_level(preObj:getPT())			
			local curExp = PropertyDictionary:get_skillExp(skillObj:getPT())
			local preExp = PropertyDictionary:get_skillExp(preObj:getPT())
			local curQuickIndex = PropertyDictionary:get_quickSkill(skillObj:getPT())
			local preQuickIndex = PropertyDictionary:get_quickSkill(preObj:getPT())
			if curLv~=preLv or curExp~=preExp or curQuickIndex~=preQuickIndex then 
				self:addSkillNeedUpdate(refId)
			end
			self.allSkill[refId]:DeleteMe()	
			self.allSkill[refId] = skillObj
		end
		
	end
end	

--�������м��ܣ�����ѧ���δѧ��
function SkillMgr:getAllSkill()
	return self.allSkill
end	

--������Ҫ���µļ��ܣ�ÿ�δ򿪽��棬ֻreload����ļ���
function SkillMgr:addSkillNeedUpdate(skillRefId)
	local skillObject = self:getSkillObjectByRefId(skillRefId)
	self:setSkillCD(skillObject)	
	self:removeSkillNeedUpdate(skillRefId)
	table.insert(self.updateList, skillRefId)	
end

function SkillMgr:removeSkillNeedUpdate(skillRefId)
	for index, refId in pairs(self.updateList) do 
		if refId == skillRefId then 
			table.remove(self.updateList, index)
		end
	end
end	

function SkillMgr:getUpdateList()
	return self.updateList
end	

function SkillMgr:getIndexByRefId(skillRefId) 
	for index, refId in pairs(self.uiIndex) do 
		if refId == skillRefId then 
			return index
		end
	end
end

function SkillMgr:getDefSel()
	return self.defSel	
end

function SkillMgr:setDefSel(curSel)
	self.defSel = curSel
end


--����������ϵĴ��м���װ�������½���
function SkillMgr:resetSkillRefId(updateEquipList, eventType)	
	local bUpdate = false
	local hero = GameWorld.Instance:getEntityManager():getHero()
	for index, refId in pairs(self.uiIndex) do 	
		local equipSkillRefId = hero:getEquipSkill(refId, updateEquipList)	
		if E_UpdataEvent.Delete == eventType then 
			local orgRefId = string.sub(equipSkillRefId, 1, -3)
			if orgRefId == refId then			 
				bUpdate = true				
				local obj = self:getSkillObjectByRefId(equipSkillRefId)
				self:setSkillCD(obj)
				self:addSkillNeedUpdate(refId)   --���ڸ��¼��ܽ���	
			end 
		else
			if refId ~= equipSkillRefId then 
				bUpdate = true		
				local obj = self:getSkillObjectByRefId(equipSkillRefId)
				self:setSkillCD(obj)			
				self:addSkillNeedUpdate(refId)   --���ڸ��¼��ܽ���	
			end
		end			
	end
	if bUpdate then 
		GlobalEventSystem:Fire(GameEvent.EventUpdateExtendSkillRefId)
	end
end	

--���ü����Ƿ�����չ���ܣ�����Ƿ�����Ӧ��չ���ܵ�refId
function SkillMgr:switchToExtendSkill(skillRefId)
	if skillRefId == nil then 
		return 
	end
	local result = G_getHero():getEquipSkill(skillRefId)
	return result
end

function SkillMgr:getUiIndex()
	return self.uiIndex
end

--����ԭʼ��refId
function SkillMgr:getOrginalRefId(extendRefId)
	for _, orgRefId in pairs(self.uiIndex) do 
		if orgRefId == extendRefId then 
			return orgRefId			
		end
	end
	extendRefId = string.sub(extendRefId, 1, -3)
	for _, orgRefId in pairs(self.uiIndex) do 
		if extendRefId == orgRefId then 
			return orgRefId
		end
	end
	return extendRefId
end

--�չ����ӵ㡢�����������óɿ�ݼ��� 
--û�дﵽѧ��ȼ�Ҳ�������óɿ�ݼ���
function SkillMgr:canSetQuickSkill(skillObj)
	if skillObj then 
		local curSkillRefId = PropertyDictionary:get_skillRefId(skillObj:getPT())
		local skillType = PropertyDictionary:get_skillType(skillObj:getStaticData())
		if curSkillRefId == const_skill_pugong or skillType == 0 or skillType == 1 then
			return false
		end
		return true
	end
end

--�Զ�װ������
function SkillMgr:setAutoSkillList(list)
	self.autoSkill = list
end

function SkillMgr:getAutoSkillList()
	return self.autoSkill
end

function SkillMgr:hasAttactSkill()
	return self.attactSkillCount > 0
end