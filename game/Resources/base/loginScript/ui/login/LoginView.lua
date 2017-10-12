require("actionEvent.LoginActionHandler")
require("object.manager.LoginManager")
require("ui.UIFactory")
require("common.LoginBaseUI")
require("ui.UIManager")
require("config.UserDefaultKey")
LoginView = LoginView or BaseClass(LoginBaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local itemNodeSize = CCSizeMake(436, 68)
local viewSize = visibleSize--VisibleRect:getScaleSize(CCSizeMake(681, 484))
	
function LoginView:__init()
	self.viewName = "LoginView"	
		
	self:createRootNode()
	self:createUserNameAndPwd()
	self:createLoginBtn()		
	self:registerAccount()
	--self:accountSecurity()
	--self:showVersion()
	
	self:setOptionConfig()	
--[[	local BackgroundMusicValue = self.OptionConfig.musicValue	
	local voiceValue = self.OptionConfig.voiceValue
	local path = "music/music_1.mp3"
	SimpleAudioEngine:sharedEngine():preloadBackgroundMusic(path)
	if self.OptionConfig.musicOff == Setting_checkStatus.TRUE then
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)	
	elseif self.OptionConfig.musicOff == Setting_checkStatus.TRUE
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(BackgroundMusicValue/100)
	end
	if self.OptionConfig.voiceOff == Setting_checkStatus.TRUE then
		SimpleAudioEngine:sharedEngine():setEffectsVolume(0)	
	elseif self.OptionConfig.voiceOff == Setting_checkStatus.TRUE
		SimpleAudioEngine:sharedEngine():setEffectsVolume(voiceValue/100)
	end		
	SimpleAudioEngine:sharedEngine():playBackgroundMusic(path, true)	--]]
	
	--是否显示单机按钮
	--[[
	require ("test.TestEntry")
	local test = TestEntry.New()
	self.rootNode:addChild(test:getRootNode())
	VisibleRect:relativePosition(test:getRootNode(), self.rootNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-50, 50))
	--]]
end	

function LoginView:__delete()
--	debugPrint ("delete LoginView")
end

function LoginView:createRootNode()
	-- 背景
	self.rootNode:setContentSize(viewSize)
	self:makeMeCenter()	
	
	local bg = CCSprite:create("loginUi/login/selectRoleBg.jpg")
	G_setBigScale(bg)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)	
end

function LoginView:createUserNameAndPwd()
	--logo
	local loginLogo = createSpriteWithFrameName(RES("login_loadSence_logo.png"))	
	self.rootNode:addChild(loginLogo)
	VisibleRect:relativePosition(loginLogo, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, 10))
	
	self.node1 = CCNode:create()
	self.node1:setContentSize(itemNodeSize)
	self.rootNode:addChild(self.node1)
	self.node2 = CCNode:create()
	self.node2:setContentSize(itemNodeSize)
	self.rootNode:addChild(self.node2)
	
	--账号	
	local labelAccount = createSpriteWithFrameName(RES("login_count.png"))	
	self.node1:addChild(labelAccount)
	VisibleRect:relativePosition(labelAccount, self.node1, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))	
	
	--密码	
	local labelPassword = createSpriteWithFrameName(RES("login_password.png"))	
	self.node2:addChild(labelPassword)
	VisibleRect:relativePosition(labelPassword, self.node2, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	
	--账号输入框	
	self.editAccount = createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(258,44)),RES("login_squares_roleNameBg.png"))
	self.node1:addChild(self.editAccount)
	VisibleRect:relativePosition(self.editAccount, labelAccount, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(20, 0))
	
	--密码输入框	
	self.editPwd = createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(258,44)),RES("login_squares_roleNameBg.png"))
	self.node2:addChild(self.editPwd)
	self.editPwd:setInputFlag(kEditBoxInputFlagPassword)
	VisibleRect:relativePosition(self.editPwd, labelPassword, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(20, 0))	
	
	VisibleRect:relativePosition(self.node1, loginLogo, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
	VisibleRect:relativePosition(self.node1, self.rootNode, LAYOUT_CENTER_X)
	VisibleRect:relativePosition(self.node2, self.node1, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -30))
	
	--记录密码
	local fun = function (checkBox)
		--checkBox = tolua.cast(checkBox,"SFCheckBox")
		--if checkBox:getSelect() then 
			
		--end			
	end
	self.checkBoxPwd = createCheckButton(RES("login_common_selectBox.png"), RES("login_common_selectIcon.png"), nil, fun)
	self.checkBoxPwd:setSelect(true)
	self:addChild(self.checkBoxPwd)
	VisibleRect:relativePosition(self.checkBoxPwd, self.node2, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(0, 0))
	
	local userName, pwd = self:getLastTimeUserNameAndPwd()
	if userName then 
		self.editAccount:setText(userName)		
	end
	if pwd then 
		self.editPwd:setText(pwd)
	end
end

function LoginView:createLoginBtn()
	--登录按钮
	self.btnEnterGame = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))	
	self.btnEnterGame:setScale(g_scale)
	self:addChild(self.btnEnterGame)
	VisibleRect:relativePosition(self.btnEnterGame, self.rootNode, LAYOUT_CENTER_X, ccp(0, 0))
	VisibleRect:relativePosition(self.btnEnterGame, self.node2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -35))	
	
	--登录文字	
	local labelBtnEnterGame = createSpriteWithFrameName(RES("login_game.png"))
	self.btnEnterGame:addChild(labelBtnEnterGame)
	VisibleRect:relativePosition(labelBtnEnterGame, self.btnEnterGame)
	
	local LoginConnect = function ()
		local account = self.editAccount:getText()
		local pwd = self.editPwd:getText()

		if string.len(account)~=0 and string.len(pwd) ~=0 then
			LoginWorld.Instance:getLoginManager():login(account, pwd)
		else
			showMsgBox(Config.LoginWords[104])
		end
		
		local loginMgr = LoginWorld.Instance:getLoginManager()
		loginMgr:setSaveUserNameAndPwd(self.checkBoxPwd:getSelect())
	end

	self.btnEnterGame:addTargetWithActionForControlEvents(LoginConnect,CCControlEventTouchDown)	
end

function LoginView:create()
	return LoginView.New()
end
function LoginView:getRootNode()
	return self.rootNode
end

function LoginView:onEnter()
	self:hideLoadingHUD()
end

--注册账号
function LoginView:registerAccount()	
	--注册按钮
	self.btnRegister = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))	
	self.btnRegister:setScale(g_scale)
	self:addChild(self.btnRegister)
	VisibleRect:relativePosition(self.btnRegister, self.rootNode, LAYOUT_LEFT_INSIDE, ccp(50, 0))
	VisibleRect:relativePosition(self.btnRegister, self.btnEnterGame, LAYOUT_CENTER_Y)
	
	--注册文字	
	local registerLabel = createSpriteWithFrameName(RES("login_register.png"))
	self.btnRegister:addChild(registerLabel)
	VisibleRect:relativePosition(registerLabel, self.btnRegister, LAYOUT_CENTER)
	
	--点击事件
	local registerAccountCallBack = function()
		GlobalEventSystem:Fire(GameEvent.EVENT_REGISTERACCOUNT_UI)
	end
	self.btnRegister:addTargetWithActionForControlEvents(registerAccountCallBack,CCControlEventTouchDown)	
end

--账号安全
function LoginView:accountSecurity()
	--按钮
	local btnSecurity = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	btnSecurity:setScale(g_scale)
	self:addChild(btnSecurity)
	VisibleRect:relativePosition(btnSecurity, self.btnRegister, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, -20))	
	
	--文字	
	local securityLabel = createSpriteWithFrameName(RES("login_safety.png"))
	btnSecurity:addChild(securityLabel)
	VisibleRect:relativePosition(securityLabel, btnSecurity, LAYOUT_CENTER)
	
	--点击事件
	local accountSecurityCallBack = function()
		GlobalEventSystem:Fire(GameEvent.EVENT_ACCOUNTSECURITY_UI)
	end
	btnSecurity:addTargetWithActionForControlEvents(accountSecurityCallBack,CCControlEventTouchDown)
end


function LoginView:getLastTimeUserNameAndPwd()
	local reader = CCUserDefault:sharedUserDefault()
	local userName = reader:getStringForKey(Config.UserDefaultKey.Login_UserName)
	local pwd = reader:getStringForKey(Config.UserDefaultKey.Login_Password)
	return userName, pwd
end

--[[function LoginView:showVersion()
	local clientLb = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[332],"Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))	
	local verLb = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[333],"Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))	
	local clientVer = SFGameHelper:getClientVersion()	
	local resVer = "0.0.0"
	local baseVersion = ResManager.Instance:getPackVersion("base.zpk")	
	if baseVersion ~= "0.0.0" then
		local extendVersion = ResManager.Instance:getPackVersion("extend.zpk")
		if extendVersion ~= "0.0.0" then
			if ResManager.Instance:compareVersion(baseVersion, extendVersion)==true then
				resVer = extendVersion
			else
				resVer = baseVersion
			end
		end
	end		
	self.clientVerLb = createLabelWithStringFontSizeColorAndDimension(clientVer,"Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))	
	self.resVerLb = createLabelWithStringFontSizeColorAndDimension(resVer,"Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))
	self.rootNode:addChild(clientLb)
	self.rootNode:addChild(verLb)	
	self.rootNode:addChild(self.clientVerLb)
	self.rootNode:addChild(self.resVerLb)
	VisibleRect:relativePosition(clientLb,self.rootNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-80,20))
	VisibleRect:relativePosition(verLb,clientLb,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_RIGHT_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.clientVerLb,clientLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.resVerLb,verLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
end
--]]
--获取系统配置，第一次调用会读取文件
function LoginView:setOptionConfig()
	if (self.OptionConfig ~= nil) then	
		return self:checkOptionConfig(self.OptionConfig)
	end		
	self.OptionConfig = {}
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
	end					
	return self:checkOptionConfig(self.OptionConfig)
end	

--保存系统配置到本地文件
function LoginView:saveOptionConfig(config)
	config = self:checkOptionConfig(config)
	self.OptionConfig = config	
	self:writeOptionConfig(config)
	--GlobalEventSystem:Fire(GameEvent.EventOptionConfigChanged, config)
end	

--检查并修正系统配置
function LoginView:checkOptionConfig(config)
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
	
	return config
end

function LoginView:writeOptionConfig(config)
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
	writer:flush()	--将缓存写入文件			
end	

--获取默认的系统配置
function LoginView:getDefaultOptionConfig()
	local config = {}
	config.voiceValue = 50
	config.musicValue = 50
	config.voiceOff	= Setting_checkStatus.FALSE		--默认不开启
	config.musicOff = Setting_checkStatus.FALSE
	Config.IsShowOtherPlayer = Setting_checkStatus.TRUE
	Config.IsShowEffect = Setting_checkStatus.TRUE
	Config.IsShowPlayerName = Setting_checkStatus.TRUE
	return config
end	