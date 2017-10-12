--�һ������ù���
require("common.baseclass")
require("data.skill.handUpSkill")

HandupConfigMgr = HandupConfigMgr or BaseClass()

--�س�ʧ����ʾ���ʱ��
local const_moveToCityFailTipsInterval = 30

function HandupConfigMgr:__init()
	self.handupConfig = self:readHandupConfig()		
	
	self:startAutoCheckHeroState()		
	self:handleNewSkillLearned()		--ѧϰ���¼����Ժ� ��Ĭ��ѡ��	
end
	
function HandupConfigMgr:__delete()
	if self.newSkillEventId then
		GlobalEventSystem:UnBind(self.newSkillEventId)
		self.newSkillEventId = nil
	end
	if self.heroProChangedEvent then
		GlobalEventSystem:UnBind(self.heroProChangedEvent)
		self.heroProChangedEvent = nil
	end
	
	self:endAutoCheckHeroState()
end	

function HandupConfigMgr:handleNewSkillLearned()
	local onEventNewSkillLearned = function(newSkillList)	
		if self.handupConfig == nil then
			self.handupConfig = {}
		end
		for k, v in pairs(newSkillList) do
			local refId = v.refId
			if GameData.HandUpSkill[refId] and not self:isSkillExist(refId) then					
				table.insert(self.handupConfig.skillList, refId)				
			end
		end				
		self:saveHandupConfig(self.handupConfig)		
	end
	self.newSkillEventId = GlobalEventSystem:Bind(GameEvent.EventNewSkillLearned, onEventNewSkillLearned)	
end

--�Զ���Ѫ�������Զ��س�
function HandupConfigMgr:startAutoCheckHeroState()
	local onEventHeroProChanged = function()		
		local hero = G_getHero()
		if hero then
			if PropertyDictionary:get_HP(hero:getPT()) <= 0 then		
				return
			end
			local state = hero:getState()		
			if  state:isState(CharacterState.CharacterStateDead) or
			   state:isState(CharacterState.CharacterStateWillDead) then
				return
			end		
		
			self:handleHPChanged()
			self:handleMPChanged()
		end
	end	
	
	self.autoCheckHeroStateSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onEventHeroProChanged, 1, false)	
end

function HandupConfigMgr:endAutoCheckHeroState()
	if self.autoCheckHeroStateSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.autoCheckHeroStateSchId)
		self.autoCheckHeroStateSchId = nil
	end
end

local g_lastShowMove2CityFailTipsTime = nil
function HandupConfigMgr:handleHPChanged()
	local hero = G_getHero()
	local hp = PropertyDictionary:get_HP(hero:getPT())		

	local config = self:readHandupConfig()	
	local maxHp = G_getMaxHp(hero:getPT())
			
	local per = (hp/maxHp)*100
	local ret = HandupCommonAPI:autoMoveToCity(per)	
	HandupCommonAPI:autoAddHP(per)	
	if ret ~= -1 then 		--����Ҫ�س�
		local now = os.time()
		if (not g_lastShowMove2CityFailTipsTime) 	--��һ��ʱ������ʾ(const_moveToCityFailTipsInterval)
			or ((now - g_lastShowMove2CityFailTipsTime) > const_moveToCityFailTipsInterval) then
			local tipsStr
			if ret == 0 then	--�س�ʧ��
				tipsStr = Config.Words[15015]
			else
				showMsgBox(Config.Words[15016])	
				G_getHandupMgr():stop()			--ֹͣ�һ�
			end
			g_lastShowMove2CityFailTipsTime = os.time()
			UIManager.Instance:showSystemTips(tipsStr)				
		end
	end
end

function HandupConfigMgr:handleMPChanged()
	local hero = G_getHero()
	local mp = PropertyDictionary:get_MP(hero:getPT())		

	local config = self:readHandupConfig()	
	local maxMp = G_getMaxMP(hero:getPT())
			
	local per = (mp/maxMp)*100
	HandupCommonAPI:autoAddMP(per)		
end

function HandupConfigMgr:isSkillExist(refId)
	if self.handupConfig == nil then
		return false
	end
	for k, v in pairs(self.handupConfig.skillList) do
		if v == refId then
			return true
		end
	end
	return false
end	
	
function HandupConfigMgr:updateSwitchSkill()	
	--[[if (not G_getHandupMgr():isHandup()) then
		return
	end
	
	if self.handupConfig == nil then
		self:readHandupConfig()
	end
	
	local hasBanyue = false
	local hasCisha = false
	
	for k, v in pairs(self.handupConfig.skillList) do
		if (v == const_switchSkill_banyue) then
			hasBanyue = true
		elseif (v == const_switchSkill_cisha) then
			hasCisha = true
		end
	end
	
	local skillMgr = G_getHero():getSkillMgr()	
	if hasBanyue == true then
--		print("HandupConfigMgr:updateSwitchSkill open banyue")
		skillMgr:updateSwitchSkill(const_switchSkill_banyue, true)
	else
--		print("HandupConfigMgr:updateSwitchSkill close banyue")
		skillMgr:updateSwitchSkill(const_switchSkill_banyue, false)
	end
	
	if hasCisha == true then
--		print("HandupConfigMgr:updateSwitchSkill open cisha")
		skillMgr:updateSwitchSkill(const_switchSkill_cisha, true)		
	else
--		print("HandupConfigMgr:updateSwitchSkill close cisha")
		skillMgr:updateSwitchSkill(const_switchSkill_cisha, false)
	end]]
end

function HandupConfigMgr:writeConfig(config)
	local skillStr = table.concat(config.skillList, "|")
	local writer = CCUserDefault:sharedUserDefault()		
	writer:setStringForKey(self:getInitFlagKey(), "1")	--д���ʼ����־
	writer:setIntegerForKey(self:getMPKey(), config.MP_AutoAdd)
	writer:setIntegerForKey(self:getHPKey(), config.HP_AutoAdd)	
	writer:setIntegerForKey(self:getMoveToCityKey(), config.autoMoveToCityValue)
	writer:setStringForKey(self:getSkillListKey(), skillStr)
	writer:flush()	--������д���ļ�			
end	

--��ȡ�һ�����
function HandupConfigMgr:readHandupConfig()
	if (self.handupConfig ~= nil) then
		return self.handupConfig
	end
	
	self.handupConfig = {}
	local reader = CCUserDefault:sharedUserDefault()	
	local inited = reader:getStringForKey(self:getInitFlagKey())
	if (inited ~= "1") then	--δд�����û��������ļ�����ʹ��Ĭ������
--		print("HandupConfigMgr:readHandupConfig inited ~= 1. use default config")
		self.handupConfig = self:getDefaultHandupConfig()
	else			
		self.handupConfig.MP_AutoAdd = reader:getIntegerForKey(self:getMPKey())
		self.handupConfig.HP_AutoAdd = reader:getIntegerForKey(self:getHPKey())
		self.handupConfig.autoMoveToCityValue = reader:getIntegerForKey(self:getMoveToCityKey())			
		local skillStr = reader:getStringForKey(self:getSkillListKey())
		self.handupConfig.skillList = string.split(skillStr, "|")
		self.handupConfig = self:checkHandupConfig(self.handupConfig)
	end			
	return self.handupConfig
end	

--����һ����õ������ļ���һ����ɫ������ְҵ����������������
function HandupConfigMgr:saveHandupConfig(config)
	config = self:checkHandupConfig(config)	
	self:writeConfig(config)
	self.handupConfig = config
	GlobalEventSystem:Fire(GameEvent.EventHandupConfigChanged, config)	
	self:updateSwitchSkill()
end	

--��鲢�����һ�����
function HandupConfigMgr:checkHandupConfig(config)
	if not (config.MP_AutoAdd >= 0 and config.MP_AutoAdd <= 100) then
		config.MP_AutoAdd = 50
	end	
	if not (config.HP_AutoAdd >= 0 and config.HP_AutoAdd <= 100) then
		config.HP_AutoAdd = 50
	end

	if not (config.autoMoveToCityValue >= 0 and config.autoMoveToCityValue <= 100) then
		config.autoMoveToCityValue = 0
	end			
	
	local professionId = PropertyDictionary:get_professionId(G_getHero():getPT())	
	if (type(config.skillList) ~= "table") then
		config.skillList = self:getDefaultSkillList()
	end	
	return config
end

function HandupConfigMgr:getInitFlagKey()
--	return const_hasInitConfigFlagKey..HandupCommonAPI:getProfessionId()
	return Config.UserDefaultKey.Handup_ConfigInited
end

function HandupConfigMgr:getMPKey()
--	return const_MPKey..HandupCommonAPI:getProfessionId()
return Config.UserDefaultKey.Handup_MP_AutoAdd
end

function HandupConfigMgr:getHPKey()
--	return const_HPKey..HandupCommonAPI:getProfessionId()
	return Config.UserDefaultKey.Handup_HP_AutoAdd
end

function HandupConfigMgr:getMoveToCityKey()
	return Config.UserDefaultKey.Option_autoMoveToCity
end
	
function HandupConfigMgr:getSkillListKey()		
--	return const_SkillListKey..HandupCommonAPI:getProfessionId()
	return Config.UserDefaultKey.Handup_SkillList
end

function HandupConfigMgr:getProfessionId()
	return PropertyDictionary:get_professionId(G_getHero():getPT())	
end

function HandupConfigMgr:getAutoMoveToCityValue()
	self:readHandupConfig()
	return self.handupConfig.autoMoveToCityValue
end

--�ָ���Ĭ����������
function HandupConfigMgr:resetConfig()
	self.handupConfig = self:getDefaultHandupConfig()
	self:saveHandupConfig(self.handupConfig)
end

--��ȡĬ�ϵĹһ�����
function HandupConfigMgr:getDefaultHandupConfig()
	local config = {}
	config.HP_AutoAdd = 50
	config.MP_AutoAdd = 50
	config.autoMoveToCityValue = 0	
	config.skillList = self:getDefaultSkillList()
	return config
end

--��ȡĬ�ϵĹһ������б�
function HandupConfigMgr:getDefaultSkillList()
	local skillList = {}
	local professionId = self:getProfessionId()
	for k, v in pairs(GameData.HandUpSkill	) do
		local id = PropertyDictionary:get_professionId(v.property)
		if (id == 0 or id == professionId) then
			table.insert(skillList, k)			
		end
	end
	return skillList
end		