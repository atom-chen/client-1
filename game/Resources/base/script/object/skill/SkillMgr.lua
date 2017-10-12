require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.skill.SkillObject")
require("ui.UIManager")
require "ui.skill.SkillUtils"
require"data.skill.skill"
SkillMgr = SkillMgr or BaseClass()

--技能类型
SkillType = {
PlusSkill = 0,  --加点技能
PassiveSkill = 1, --被动技能
ActiveSkill = 2, --主动技能
SwitchSkill = 3, --开关技能
}

local const_autoUseSkillCD = 0.1
local switchSkill_banyue = "skill_zs_4"
local switchSkill_cisha = "skill_zs_3"
local switchSkill_gongsha = "skill_zs_2"

local common_cd_attack = 0.6			-- 普通攻击的CD
local common_cd_skill = 1.2				-- 法师和道士的攻击的CD
local common_cd_skill_zhanshi = 0.7 	-- 战士的公共CD

function SkillMgr:__init()
	SkillUtils.New()
	self.markTable = {}   --保存快捷技能
	self.preMarkTable = {}  --前一个快捷技能列表
	self.updateList = {} --保存要更新的技能
	self.allSkill = {}
	self.cdSkillList = {} -- CD中的技能列表		
	self.uiIndex = {}		
	self.reConnect = false  --断线重连的标记
	
	self.commonCD = 0
	self.replaceSkillRefId = "" -- 某些技能是使用以后, 把下一次使用的技能替换掉，在这里标记一下
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
	self:setReconnect(true)  --断线重连
	
	if self.allSkill then 
		for _, v in pairs(self.allSkill) do 
			v:DeleteMe()
		end
		self.allSkill = nil		
	end
	self.jichuSkill = nil
	
	self.markTable = {}  	--保存快捷技能
	self.updateList = {} 	--保存要更新的技能	@
	self.cdSkillList = {} 	--CD中的技能列表		
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
			-- 给出一个提示
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
--向服务器请求技能列表
function SkillMgr:requestSkillList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GetLearnedSkillList)
	simulator:sendTcpActionEventInLua(writer)
end

--向服务器更新快速技能
function SkillMgr:requestSetPutdownSkills(updateTable)
	if self:isTableEmpty(updateTable) == false then
		if updateTable.delete ~= nil then
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_SetPutdownSkill)
			StreamDataAdapter:WriteStr(writer, updateTable.delete.refId)
			writer:WriteShort(updateTable.delete.index)
			simulator:sendTcpActionEventInLua(writer)
			GlobalEventSystem:Fire(GameEvent.EventRemoveCdSprite, updateTable.delete.index)--删除主界面的cd progresstimer
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

-- 使用技能
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
			-- 转换为服务器的朝向
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
	-- CD会受到攻速的影响
	local cdOffset = 0
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local atkSpeed = PropertyDictionary:get_atkSpeedPer(hero:getPT())
	if atkSpeed > 0 then
		-- 攻速没提高10%, CD缩短30ms
		cdOffset = -0.03*atkSpeed/10
	end
	
	-- 公共CD分职业
	local hero =  GameWorld.Instance:getEntityManager():getHero()
	local heroProId = PropertyDictionary:get_professionId(hero:getPT())
	if heroProId == ModeType.ePlayerProfessionWarior then
		self:refreshSkillCD(common_cd_skill_zhanshi+cdOffset, skillRefId)	
	else
		self:refreshSkillCD(common_cd_skill+cdOffset, skillRefId)	
	end
				
end

--刷skillcd的时候也刷公共cd
function SkillMgr:refreshSkillCD(cdTime, skillRefId)
	if cdTime and skillRefId then
		if skillRefId ~= const_skill_pugong then 
			local skillObject = self:getSkillObjectByRefId(skillRefId)
			if skillObject then
				skillObject:refreshCD()
				self.cdSkillList[skillRefId] = skillObject		
				--发送一个刷新CD的gameEvent
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

--添加技能熟练度
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

--获取技能数量
function SkillMgr:getSkillCount()
	--已显示在ui上面的技能为准
	return table.size(self.uiIndex)
end

--设置技能列表
function SkillMgr:setTableList(tableList, skillCount)
	local reader = CCUserDefault:sharedUserDefault()
	self.attactSkillCount = 0	
	for index, pt in pairs(tableList) do 
		local skill = SkillObject.New()
		skill:setPT(pt)		
		local skillRefId = PropertyDictionary:get_skillRefId(skill:getPT())				
		local status = reader:getIntegerForKey(skillRefId)   --没有refId， 默认是0
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
				
	self:updateQuickSkill() --更新快捷技能	
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

--根据id获取技能对象
function SkillMgr:getSkillObjectById(id)
	local skillRefId = self.uiIndex[id]
	skillRefId = G_getHero():getEquipSkill(skillRefId)
	if skillRefId then 
		return self:getSkillObjectByRefId(skillRefId)
	end		
end

--根据refId获取技能对象
function SkillMgr:getSkillObjectByRefId(refId)
	if self.allSkill and refId then 
		return self.allSkill[refId]	
	end
end	

--更新开关技能
--skillRefId: 技能refId
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

--根据技能槽的索引获取快捷技能的refId
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

--获取快捷技能数量
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

-- 检查技能是否能为其他技能替换
function SkillMgr:checkReplaceSkill(skillRefId)
	if self.replaceSkillRefId ~= "" and self:canUseSkill(self.replaceSkillRefId) then
		skillRefId = self.replaceSkillRefId
		self.replaceSkillRefId = ""
--		self.replaceTime = -1	 --Juchao@20140320：不能在这里改为-1。因为烈火剑法的冷却时间为10s。	
	elseif skillRefId == const_skill_pugong then
		-- 如果有攻杀，先判断是否能触发攻杀
		if self:canUseSkill(const_skill_gongsha) and math.random() < 0.2 then
			--攻杀剑法要算概率
			skillRefId = const_skill_gongsha
		elseif self:canUseSkill(switchSkill_banyue) then
			skillRefId = switchSkill_banyue
		elseif self:canUseSkill(switchSkill_cisha) then
			skillRefId = switchSkill_cisha
		end
	end
	
	return skillRefId
end	
--检查替换技能CD
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
--检查替换技能开关
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

--重置同种技能开关状态
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
判断是否能使用这个技能, 会进行一下判定
1. 身上时候有这个技能
2. 这个技能是否学习
3. 检查开关状态
4. 技能CD
6. 是否够蓝
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
	--保存上一次的快捷技能
	for k, v in pairs(self.markTable) do 
		self.preMarkTable[k] = {}
		self.preMarkTable[k].refId = v.refId
		self.preMarkTable[k].index = v.index
	end
	self.markTable = {}
	--获取快捷技能
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
		-- 按照技能的类型，发送不同的协议
		local skillAimType = PropertyDictionary:get_skillAimType(skillObject:getStaticData())
		
		-- 对目标和对格子的技能必须有攻击目标才能施放
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

--把静态数据表的所有该职业的技能都读出来， 除了refId和开关技能状态 其他数据都是假了
function SkillMgr:loadAllSkill()
	self.allSkill = {}
	self.jichuSkill = {}
	local reader = CCUserDefault:sharedUserDefault()
	local heroProId = PropertyDictionary:get_professionId(G_getHero():getPT())
	for k, v in pairs(GameData.Skill) do			
		local professionId = v.property.professionId
		if professionId == 0 or professionId == heroProId then
			-- 只有基础技能才显示在UI里面			
			local obj = SkillObject.New()			
			local pt = {}
			pt.skillRefId = v.refId			
			pt.level = 1
			pt.skillExp = -10
			pt.quickSkill = -1
			obj:setPT(pt)
			--设置开关状态
			local status = reader:getIntegerForKey(v.refId)   --没有refId， 默认是0
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
	--分配技能的UI索引
	self:allocateUiIndex()	
end	

--根据学习等级分配索引，第一个显示在技能界面的技能索引是1，以此类推
function SkillMgr:allocateUiIndex()
	local index = 1
	local tmpTable = {}
	--这里对tmpTable进行排序是因为self.jichuSkill是用refId作为索引的，不能对它进行排序
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

--用已经学会的技能替代
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

--返回所有技能，包括学会和未学会
function SkillMgr:getAllSkill()
	return self.allSkill
end	

--保存需要更新的技能，每次打开界面，只reload里面的技能
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


--根据玩家身上的带有技能装备，更新界面
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
				self:addSkillNeedUpdate(refId)   --用于更新技能界面	
			end 
		else
			if refId ~= equipSkillRefId then 
				bUpdate = true		
				local obj = self:getSkillObjectByRefId(equipSkillRefId)
				self:setSkillCD(obj)			
				self:addSkillNeedUpdate(refId)   --用于更新技能界面	
			end
		end			
	end
	if bUpdate then 
		GlobalEventSystem:Fire(GameEvent.EventUpdateExtendSkillRefId)
	end
end	

--检测该技能是否是扩展技能，如果是返回相应扩展技能的refId
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

--返回原始的refId
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

--普攻、加点、被动不能设置成快捷技能 
--没有达到学会等级也不能设置成快捷技能
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

--自动装备技能
function SkillMgr:setAutoSkillList(list)
	self.autoSkill = list
end

function SkillMgr:getAutoSkillList()
	return self.autoSkill
end

function SkillMgr:hasAttactSkill()
	return self.attactSkillCount > 0
end