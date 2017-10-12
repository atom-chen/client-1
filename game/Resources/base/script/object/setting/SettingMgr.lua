--设置的配置管理
require("common.baseclass")
require("object.skillShow.SkillShowManager")

SettingMgr = SettingMgr or BaseClass()

Setting_EquipPickUp = 
{
	overLevel_10 = 10,
	overLevel_30 = 30,
	overLevel_40 = 40,	
	overLevel_50 = 50,
	overLevel_60 = 60,
	overLevel_70 = 70,	
	Level_All = 1000,
}

PickupConfigType = {
	equipLevel = 1,
	quality = 2,
	profession = 3,
}	

local Config_CharacterId = "Config_CharacterId"

local PickUp_EquipLevel = "PickUp_EquipLevel"
local PickUp_EquipQuality = "PickUp_EquipQuality"
local PickUp_Profession = "PickUp_Profession"
local PickUp_InitFlag = "PickUp_InitFlag"

function SettingMgr:__init()
	self.OptionConfig = {}	
	self:readOptionConfig()
	self:readPickUpConfig()
	self:checkVoiceSetting()
	self.PickUpConfig = {}	
	
	self:initSetting()
end
	
function SettingMgr:__delete()
		
end

--根据配置，初始化设置
function SettingMgr:initSetting()
	SkillShowManager:setDisplayEffect(self:isShowEffect())	
end

function SettingMgr:isShowPlayerWing()
	self:readOptionConfig()
	if self.OptionConfig.IsShowPlayerWing == 1 then
		return true
	elseif self.OptionConfig.IsShowPlayerWing == 2 then
		return false
	end
	return true
end

function SettingMgr:showPlayerWing(bShow)
	self:readOptionConfig()
	if bShow then
		self.OptionConfig.IsShowPlayerWing = Setting_checkStatus.TRUE
	else
		self.OptionConfig.IsShowPlayerWing = Setting_checkStatus.FALSE
	end
	self:saveOptionConfig(self.OptionConfig)
	--TODO: 该配置的逻辑实现
	 GameWorld.Instance:getEntityManager():showPlayersWing(bShow)
end

function SettingMgr:clear()
	--设置的数据是本地保存，对于本地存的数据变换角色的时候用resetConfig去改变
end	

--角色请求离开
function SettingMgr:requireLeaveGame(heroId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	--ActionEvents.C2G_Character_Leave
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_LeaveWorld)	
	writer:WriteString(heroId)
	simulator:sendTcpActionEventInLua(writer)	
end

--获取系统配置，第一次调用会读取文件
function SettingMgr:readOptionConfig()
	if table.isEmpty(self.OptionConfig) then			
		local reader = CCUserDefault:sharedUserDefault()	
		local inited = reader:getStringForKey(Config.UserDefaultKey.Option_InitFlag)
		if (inited ~= "1") then	--未写过配置或者配置文件出错，使用默认配置	
			self.OptionConfig = self:getDefaultOptionConfig()
		else			
			self.OptionConfig.voiceValue = reader:getIntegerForKey(Config.UserDefaultKey.Option_MusicValue)
			self.OptionConfig.musicValue = reader:getIntegerForKey(Config.UserDefaultKey.Option_VoiceValue)
			self.OptionConfig.voiceOff = reader:getIntegerForKey(Config.UserDefaultKey.Option_VoiceOff)
			self.OptionConfig.musicOff = reader:getIntegerForKey(Config.UserDefaultKey.Option_MusicOff)
			self.OptionConfig.IsShowOtherPlayer = reader:getIntegerForKey(Config.UserDefaultKey.Option_IsShowOtherPlayer)
			self.OptionConfig.IsShowEffect = reader:getIntegerForKey(Config.UserDefaultKey.Option_IsShowEffect)
			self.OptionConfig.IsShowPlayerName = reader:getIntegerForKey(Config.UserDefaultKey.Option_IsShowPlayerName)									
			self.OptionConfig.IsShowPlayerWing = reader:getIntegerForKey(Config.UserDefaultKey.Option_IsShowPlayerWing)									
		end		
		self.OptionConfig = self:checkOptionConfig(self.OptionConfig)		
	end		
	return self.OptionConfig
end		

--保存系统配置到本地文件
function SettingMgr:saveOptionConfig(config)
	config = self:checkOptionConfig(config)
	self.OptionConfig = config		
	self:writeOptionConfig(config)	
end	

--检查并修正系统配置
function SettingMgr:checkOptionConfig(config)
	if not (config.voiceValue >= 0 and config.voiceValue <= 100) then
		config.voiceValue = 50
	end	
	if not (config.musicValue >= 0 and config.musicValue <= 100) then
		config.musicValue = 50
	end
	if (config.musicOff ~= Setting_checkStatus.FALSE and config.musicOff ~= Setting_checkStatus.TRUE) then
		config.musicOff = Setting_checkStatus.FALSE
	end
	if (config.voiceOff ~= Setting_checkStatus.FALSE and config.voiceOff ~= Setting_checkStatus.TRUE) then
		config.voiceOff = Setting_checkStatus.TRUE
	end
	if (config.IsShowOtherPlayer ~= Setting_checkStatus.FALSE and config.IsShowOtherPlayer ~= Setting_checkStatus.TRUE) then
		config.IsShowOtherPlayer = Setting_checkStatus.TRUE
	end	
	if (config.IsShowEffect ~= Setting_checkStatus.FALSE and config.IsShowEffect ~= Setting_checkStatus.TRUE) then
		config.IsShowEffect = Setting_checkStatus.TRUE
	end		
	if (config.IsShowPlayerName ~= Setting_checkStatus.FALSE and config.IsShowPlayerName ~= Setting_checkStatus.TRUE) then
		config.IsShowPlayerName = Setting_checkStatus.TRUE
	end
	if (config.IsShowPlayerWing ~= Setting_checkStatus.FALSE and config.IsShowPlayerWing ~= Setting_checkStatus.TRUE) then
		config.IsShowPlayerWing = Setting_checkStatus.TRUE
	end		
	return config
end

function SettingMgr:writeOptionConfig(config)
	local writer = CCUserDefault:sharedUserDefault()
	config = self:checkOptionConfig(config)		
	writer:setStringForKey(Config.UserDefaultKey.Option_InitFlag, "1")	--写入初始化标志
	writer:setIntegerForKey(Config.UserDefaultKey.Option_MusicValue, config.voiceValue)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_VoiceValue, config.musicValue)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_VoiceOff,config.voiceOff)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_MusicOff,config.musicOff)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_IsShowOtherPlayer, config.IsShowOtherPlayer)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_IsShowEffect, config.IsShowEffect)	
	writer:setIntegerForKey(Config.UserDefaultKey.Option_IsShowPlayerName, config.IsShowPlayerName)
	writer:setIntegerForKey(Config.UserDefaultKey.Option_IsShowPlayerWing, config.IsShowPlayerWing)
	writer:flush()	--将缓存写入文件			
end	

--获取默认的系统配置
function SettingMgr:getDefaultOptionConfig()
	local config = {}
	config.voiceValue = 50
	config.musicValue = 50
	config.voiceOff	= Setting_checkStatus.FALSE		--默认不开启
	config.musicOff = Setting_checkStatus.FALSE
	config.IsShowOtherPlayer = Setting_checkStatus.TRUE
	config.IsShowEffect = Setting_checkStatus.TRUE
	config.IsShowPlayerName = Setting_checkStatus.TRUE
	config.IsShowPlayerWing = Setting_checkStatus.TRUE
	return config
end		

function SettingMgr:setVoiceValue(value)
	if value then
		self.OptionConfig.voiceValue = value
	end
end

function SettingMgr:getVoiceValue()
	if self.OptionConfig.voiceValue<0 or self.OptionConfig.voiceValue>100 then
		self.OptionConfig.voiceValue = 50
	end
	return self.OptionConfig.voiceValue
end

function SettingMgr:getMusicValue()
	if self.OptionConfig.musicValue<0 or self.OptionConfig.musicValue>100 then
		self.OptionConfig.musicValue = 50
	end
	return self.OptionConfig.musicValue
end

function SettingMgr:setVoiceOff(isOff)
	self.OptionConfig.voiceOff = isOff
end

function SettingMgr:isVoiceOff()
	return self.OptionConfig.voiceOff == Setting_checkStatus.TRUE
end

--获取拾取配置，第一次调用会读取文件
function SettingMgr:readPickUpConfig()
	if ( table.size(self.PickUpConfig) > 0) then	
		return self:checkPickUpConfig(self.PickUpConfig)
	end		
	self.PickUpConfig = {}
	local reader = CCUserDefault:sharedUserDefault()	
	local inited = reader:getStringForKey(PickUp_InitFlag)
	if (inited ~= "1") then	--未写过配置或者配置文件出错，使用默认配置	
		self.PickUpConfig = self:getDefaultPickUpConfig()
	else			
		self.PickUpConfig.EquipLevel = reader:getIntegerForKey(PickUp_EquipLevel)
		local EquipQualityList = reader:getStringForKey(PickUp_EquipQuality)
		self.PickUpConfig.EquipQualityList = self:switchToTable(EquipQualityList)
		local ProfessionList = reader:getStringForKey(PickUp_Profession)
		self.PickUpConfig.ProfessionList = self:switchToTable(ProfessionList)							
	end					
	return self:checkPickUpConfig(self.PickUpConfig)
end	

function SettingMgr:isSelectNull()
	self:readPickUpConfig()
	local equipQualityListSize = table.size(self.PickUpConfig.EquipQualityList)
	local professionListSize = table.size(self.PickUpConfig.ProfessionList)
	local equipLevel = self.PickUpConfig.EquipLevel
	if equipQualityListSize == 0 and professionListSize == 0 and (equipLevel>=100 or equipLevel <= 0) then
		return true
	else
		return false
	end
end

--保存拾取配置到本地文件
function SettingMgr:savePickUpConfig(config)
	config = self:checkPickUpConfig(config)
	self.PickUpConfig = config	
	local equipQualityList = self.PickUpConfig.EquipQualityList
	local professionList = self.PickUpConfig.ProfessionList
	local equipLevel = self.PickUpConfig.EquipLevel
	self:writePickUpConfig(config)		
end	

--检查并修正拾取配置
function SettingMgr:checkPickUpConfig(config)
	if not config.EquipLevel then
		config.EquipLevel = Setting_EquipPickUp.overLevel_10				
	end
	for i,v in ipairs(Setting_EquipPickUp) do
		if config.EquipLevel == v  then
			return
		end
		config.EquipLevel = Setting_EquipPickUp.overLevel_10
	end		
	if self:checkTable(config.EquipQualityList) == false then
		config.EquipQualityList = {
			[ItemQualtiy.White] = ItemQualtiy.White,
			[ItemQualtiy.Blue] = ItemQualtiy.Blue,
			[ItemQualtiy.Purple] = ItemQualtiy.Purple,			
		}
	end			
	if self:checkTable(config.ProfessionList) == false then
		config.ProfessionList = {
			[ModeType.ePlayerProfessionWarior] = ModeType.ePlayerProfessionWarior,
			[ModeType.ePlayerProfessionMagic] =ModeType.ePlayerProfessionMagic,
			[ModeType.ePlayerProfessionWarlock] =ModeType.ePlayerProfessionWarlock,
		}
	end		
	
	return config
end

function SettingMgr:writePickUpConfig(config)
	local writer = CCUserDefault:sharedUserDefault()
	config = self:checkPickUpConfig(config)
	local EquipQualityList = {}		
	for i,v in pairs(config.EquipQualityList) do	--转换为有序table
		table.insert(EquipQualityList,v)
	end	
		
	local ProfessionList = {}
	for i,v in pairs(config.ProfessionList) do
		table.insert(ProfessionList,v)
	end
	
	EquipQualityList = table.concat(EquipQualityList, "|")
	ProfessionList= table.concat(ProfessionList, "|")		
	writer:setStringForKey(PickUp_InitFlag, "1")	--写入初始化标志
	writer:setIntegerForKey(PickUp_EquipLevel, config.EquipLevel)
	writer:setStringForKey(PickUp_EquipQuality, EquipQualityList)
	writer:setStringForKey(PickUp_Profession, ProfessionList)		
	writer:flush()	--将缓存写入文件			
end	

--获取默认的拾取配置
function SettingMgr:getDefaultPickUpConfig()
	local config = {}
	config.EquipLevel = Setting_EquipPickUp.overLevel_10
	config.EquipQualityList = {
		[ItemQualtiy.White] = ItemQualtiy.White,
		[ItemQualtiy.Blue] = ItemQualtiy.Blue,
		[ItemQualtiy.Purple] = ItemQualtiy.Purple,	
	}
	config.ProfessionList = {
		[ModeType.ePlayerProfessionWarior] = ModeType.ePlayerProfessionWarior,
		[ModeType.ePlayerProfessionMagic] =ModeType.ePlayerProfessionMagic,
		[ModeType.ePlayerProfessionWarlock] =ModeType.ePlayerProfessionWarlock,
	}	
	return config
end

function SettingMgr:checkTable(Table)
	if type(Table) ~= "table" or table.size(Table) < 0 then
		return false
	end		
	
	for i,v in pairs(Table) do
		if type(v) ~= "number" then
			return false
		end
	end
	return true
end

function SettingMgr:switchToTable(str)
	local Table = string.split(str, "|")
	for i,v in ipairs(Table) do
		Table[i] = tonumber(v)
	end
	
	local configTable = {}	
	for j,v in ipairs(Table) do		--转换为数值和key值一样的table
		configTable[v] = v 
	end
	return configTable
end	

--是否显示其他玩家
function SettingMgr:isShowOtherPlayer()
	self:readOptionConfig()
	if self.OptionConfig.IsShowOtherPlayer == 1 then
		return true
	elseif self.OptionConfig.IsShowOtherPlayer == 2 then
		return false
	end
	return true
end

--是否显示特效
function SettingMgr:isShowEffect()
	self:readOptionConfig()
	if self.OptionConfig.IsShowEffect == 1 then
		return true
	elseif self.OptionConfig.IsShowEffect == 2 then
		return false
	else
		return true
	end
end

--是否显示玩家姓名
function SettingMgr:isShowPlayerName()
	self:readOptionConfig()
	if self.OptionConfig.IsShowPlayerName == 1 then
		return true
	elseif self.OptionConfig.IsShowPlayerName == 2 then
		return false
	else
		return true
	end
end

--得到配置文件中保存的角色ＩＤ
function SettingMgr:getConfigCharacterId()
	local reader = CCUserDefault:sharedUserDefault()
	local characterId = reader:getStringForKey(Config_CharacterId)
	return characterId
end	

--重设所有需要改变的配置
function SettingMgr:resetConfig(characterId)
	local DefaultPickUpConfig = self:getDefaultPickUpConfig()	
	
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_wing), 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_mount), 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_talisman), 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(MainMenu_Btn.Btn_forge), 0)
	
	local writer = CCUserDefault:sharedUserDefault()
	config = self:checkPickUpConfig(DefaultPickUpConfig)	
	local EquipQualityList = table.concat(DefaultPickUpConfig.EquipQualityList, "|")
	local ProfessionList = table.concat(DefaultPickUpConfig.ProfessionList, "|")
	writer:setStringForKey(Config_CharacterId, characterId)	--写入角色ID	
	writer:setStringForKey(PickUp_InitFlag, "1")	--写入初始化标志
	writer:setIntegerForKey(PickUp_EquipLevel, DefaultPickUpConfig.EquipLevel)
	writer:setStringForKey(PickUp_EquipQuality, EquipQualityList)
	writer:setStringForKey(PickUp_Profession, ProfessionList)	
			
	self:savePickUpConfig(DefaultPickUpConfig)
	local optionConfig = self:getDefaultOptionConfig()
	self:saveOptionConfig(optionConfig)	
	writer:flush()	--将缓存写入文件	
	self:resetMusicValue()
	GlobalEventSystem:Fire(GameEvent.EventOptionConfigChanged)	
	GlobalEventSystem:Fire(GameEvent.EventPickUpConfigChanged)	
end

function SettingMgr:resetMusicValue()
	local OptionConfig = {}	
	OptionConfig = self:getDefaultOptionConfig()	
	local soundMgr = GameWorld.Instance:getSoundMgr()	
	if OptionConfig.musicOff == Setting_checkStatus.TRUE then	
		soundMgr:setEffectsVolume(0)
	else		
		soundMgr:setEffectsVolume(OptionConfig.musicValue)
	end 
	
	if OptionConfig.voiceOff == Setting_checkStatus.TRUE then	
		soundMgr:setBackgroundMusicVolume(0)
	else
		soundMgr:setBackgroundMusicVolume(OptionConfig.voiceValue)
	end
end

function SettingMgr:requestOffLineAISeting(pickupConfig)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OffLineAISeting)
	local handupConfig =  G_getHandupConfigMgr():readHandupConfig()
	StreamDataAdapter:WriteInt(writer, handupConfig.HP_AutoAdd)
	StreamDataAdapter:WriteInt(writer, handupConfig.MP_AutoAdd)
	
	-- 等级设置选项
	StreamDataAdapter:WriteInt(writer, pickupConfig.EquipLevel)
	
	-- 质量设置选项
	local equipQualityNum = 0
	for k,v in pairs(pickupConfig.EquipQualityList) do
		if v>0 and v<4 then
			equipQualityNum = equipQualityNum +1
		end	
	end
	StreamDataAdapter:WriteInt(writer, equipQualityNum)
	for k,v in pairs(pickupConfig.EquipQualityList) do
		if v>0 and v<4 then
			StreamDataAdapter:WriteChar(writer, v)
		end	
	end
	-- 职业设置选项
	local professionNum = 0
	for k,v in pairs(pickupConfig.ProfessionList) do
		if v>0 and v<4 then
			professionNum = professionNum +1
		end	
	end
	StreamDataAdapter:WriteInt(writer, professionNum)
	for k,v in pairs(pickupConfig.ProfessionList) do
		if v>0 and v<4 then	
			StreamDataAdapter:WriteChar(writer, v)
		end
	end
	
	simulator:sendTcpActionEventInLua(writer)
end

function SettingMgr:backToSelectRoleView()
	GameWorld.Instance:getAutoPathManager():cancel()
	GameWorld.Instance:getEntityManager():getHero():forceStop()	
	GameWorld.Instance:getAnimatePlayManager():removeAll()							
	G_getHandupMgr():stop()	
	--GameWorld.Instance:deleteScheduler()
	
	GameWorld.Instance:clearMgr()	
	local mapManager = GameWorld.Instance:getMapManager()
	mapManager:reset()	
	local notifyMgr = LoginWorld.Instance:getNotifyManager()
	notifyMgr:setFirstRoleLogin(true)
	LoginWorld.Instance:getLoginManager():requestCharactorGet()
end

function SettingMgr:checkVoiceSetting()
	local backgroundMusicValue = self.OptionConfig.musicValue	
	local voiceValue = self.OptionConfig.voiceValue	
	local soundMgr = GameWorld.Instance:getSoundMgr()
	if self.OptionConfig.musicOff == Setting_checkStatus.TRUE then		
		soundMgr:setBackgroundMusicVolume(0)	
	elseif self.OptionConfig.musicOff == Setting_checkStatus.FALSE then
		soundMgr:setBackgroundMusicVolume(backgroundMusicValue/100)
	end
	if self.OptionConfig.voiceOff == Setting_checkStatus.TRUE then
		soundMgr:setEffectsVolume(0)	
	elseif self.OptionConfig.voiceOff == Setting_checkStatus.FALSE then
		soundMgr:setEffectsVolume(voiceValue/100)
	end	
end


