require("common.baseclass")
require ("data.skill.skill")
require ("common.BaseObj")
require ("utils.PropertyDictionary")
require"data.skill.skill"	
local SwithSkillType = {
open = 1,
close = 2,
}

SkillObject = SkillObject or BaseClass(BaseObj)

function SkillObject:__init()
	self.skillCD = 0		--默认是0.5秒的公共CD
	self.currentCD = 0		--当前CD时间
	self.maxLevel = -1	
end	

function SkillObject:getStaticData()
	if not self.staticData then
		local refId = PropertyDictionary:get_skillRefId(self:getPT())
		self.staticData = GameData.Skill[refId]["property"]
	end
	return self.staticData
end	

function SkillObject:getSkillLevelTable()
	
	local refId = PropertyDictionary:get_skillRefId(self:getPT())
	return GameData.Skill[refId]["skillLevel"]
end

function SkillObject:getSkillLevelPropertyTable(level)
	if level then 
		local refId = PropertyDictionary:get_skillRefId(self:getPT())
		if GameData.Skill[refId]["skillLevel"] and GameData.Skill[refId]["skillLevel"][level] then
			return GameData.Skill[refId]["skillLevel"][level]["property"]
		end
	end
	return nil
end

function SkillObject:getSkillEffectDataTableByLevel(level)
		
	local refId = PropertyDictionary:get_skillRefId(self:getPT())
	return GameData.Skill[refId]["skillLevel"][level]["effectData"]
end

function SkillObject:setSkillCD(skillCD)
	self.skillCD = skillCD
end

function SkillObject:getSkillCD()
	return self.skillCD
end

function SkillObject:getCurrentCD()
	return self.currentCD
end

-- 重置CD
function SkillObject:refreshCD()
	self.currentCD = self.skillCD
end

function SkillObject:isReady()
	return self.currentCD <= 0
end

function SkillObject:update(time)
	if self.currentCD > 0 then
		self.currentCD = self.currentCD - time
		if self.currentCD < 0 then
			self.currentCD = 0
		end
	end
end

--开关技能
function SkillObject:setSwitchStatus(status, bLoad)
	--获取技能时统一读取开关技能的状态，因此不用写进文件
	if bLoad ~= true then
		local refId = PropertyDictionary:get_skillRefId(self:getPT())
		local writer = CCUserDefault:sharedUserDefault()
		--因为CCUserDefault没有导出有默认值的接口。bool类型的默认是false，所以只能用
		--Integer替代，1代表打开， 2,代表关闭，     蛋疼
		if status == false then 
			writer:setIntegerForKey(refId, SwithSkillType.close)
		else
			writer:setIntegerForKey(refId, SwithSkillType.open)
		end
		writer:flush()
	end 
	self.status = status		
end

function SkillObject:getSwitchStatus()
	return self.status
end

--获取技能消耗的MP
function SkillObject:getMp()
	local levelProperty = self:getSkillLevelTable()
	--local skillLevel = PropertyDictionary:get_skillLevel(GameWorld.Instance:getEntityManager():getHero():getPT())
	local skillLevel = PropertyDictionary:get_level(self:getPT())
	if levelProperty and levelProperty[skillLevel] then
		return levelProperty[skillLevel]["property"]["MP"]
	else
		return 0
	end
end

-- 技能是否已经学习
function SkillObject:isLearn()
	local property = self:getStaticData()	
	if property and property["skillLearnLevel"] then
		return property["skillLearnLevel"] <= PropertyDictionary:get_level(GameWorld.Instance:getEntityManager():getHero():getPT())
	else
		return false
	end		
end


--根据等级获取技能描述
function SkillObject:getDescByLevel(level)
	local retVal = nil
	if "skill_0"==PropertyDictionary:get_skillRefId(self:getPT()) then
		retVal = PropertyDictionary:get_description(self:getStaticData())
	else
		local baseDesc = PropertyDictionary:get_description(self:getStaticData())
		local effectDataTable = self:getSkillEffectDataTableByLevel(level)
		
		local tmp = {}
		local cnt = 0
		for key, value in pairs(effectDataTable) do 
			cnt = cnt + 1
			tmp[cnt] = {}
			tmp[cnt].key = key
			tmp[cnt].value = value
			tmp[cnt].keyLen = string.len(key)
		end
		local sortByLen = function (a, b)
			local lvA = a.keyLen
			local lvB = b.keyLen
			return lvA > lvB
		end
		table.sort(tmp, sortByLen)
	
		retVal = baseDesc
		if effectDataTable then
			for key, value in pairs(tmp) do
				retVal = string.gsub(retVal, value.key, value.value)
			end
		end			
	end
	
	return retVal
end

--获取当前等级和最大等级
function SkillObject:geCurAndMaxLevel()
	local lvTable = self:getPT()
	if lvTable ~= nil then
		local curLevel = PropertyDictionary:get_level(lvTable)
		
		if self.maxLevel == -1 then
			self.maxLevel = table.size(self:getSkillLevelTable())			
		end
		local maxLevel = self.maxLevel
		local refId = PropertyDictionary:get_skillRefId(self:getPT())
		if refId == const_skill_pugong then 
			maxLevel = 1
		end
		return curLevel, maxLevel
	end
end	

function SkillObject:isMaxLevel()
	local cur,max = self:geCurAndMaxLevel()
	return cur == max
end

--是否需要战斗目标
--非朝向技能&&目标类型为敌方的技能，需要有合法的战斗目标才能使用
function SkillObject:needFightTarget()
	if 2 == PropertyDictionary:get_skillTargetType(self:getStaticData()) 
		and	PropertyDictionary:get_skillAimType(self:getStaticData()) ~= 2 then		
		return true		
	end
	return false
end

function SkillObject:isSwitchSkill()
	local data = self:getStaticData()
	if data then
		return PropertyDictionary:get_skillType(data) == SkillType.SwitchSkill	
	else
		return false
	end
end

function SkillObject:isMaxExp()
	local currentExp = PropertyDictionary:get_skillExp(self:getPT())
	local curLevel =  self:geCurAndMaxLevel()
	local data = self:getSkillLevelPropertyTable(curLevel)
	if data then
		local upperExp = PropertyDictionary:get_skillUpperExp(data)
		return upperExp == currentExp
	end
	return false
end