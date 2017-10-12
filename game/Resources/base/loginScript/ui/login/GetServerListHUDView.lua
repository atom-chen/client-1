require("ui.UIManager")
require("common.LoginBaseUI")

GetServerListHUDView = GetServerListHUDView or BaseClass(LoginBaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

function GetServerListHUDView:__init()
	self.viewName = "GetServerListHUDView"
	self:createRootNode()
	self:showVersion()
end	

function GetServerListHUDView:create()
	return GetServerListHUDView.New()
end

function GetServerListHUDView:onEnter()	
	
end

function GetServerListHUDView:createRootNode()
	self:makeMeCenter()
	--����Logo	
	local Logo =  CCScale9Sprite:create("loginUi/login/enterGameBg.jpg")
	self.rootNode:addChild(Logo)
	--G_setScale(Logo)
	G_setBigScale(Logo)
	
	self.loadingNode = CCNode:create()
	self.loadingNode:setContentSize(self.rootNode:getContentSize())
	VisibleRect:relativePosition(self.loadingNode,self.rootNode,LAYOUT_CENTER)
	self.rootNode:addChild(self.loadingNode)
	--����Label
	self.textTips = CCLabelTTF:create("", "Arial", 30)
	self.loadingNode:addChild(self.textTips)
	--G_setScale(self.textTips)
	--תȦ��������
	local CircleSprite = createSpriteWithFrameName(RES("login_loading.png"))
	self.loadingNode:addChild(CircleSprite)
	G_setScale(CircleSprite)
	--ת������
	local Rotate = CCRotateBy:create(1.0, 360)
	local RotateForever = CCRepeatForever:create(Rotate)
	CircleSprite:runAction(RotateForever)
	SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
	SimpleAudioEngine:sharedEngine():playBackgroundMusic("music/login.mp3")		
	VisibleRect:relativePosition(Logo, self.rootNode, LAYOUT_CENTER)
	VisibleRect:relativePosition(self.textTips, self.rootNode, LAYOUT_CENTER,ccp(0,-50))
	VisibleRect:relativePosition(CircleSprite, self.rootNode, LAYOUT_CENTER, ccp(0, -150))
end

-- ��ʾ��Ϸ��ʼ������ʾ��Ϣ
function GetServerListHUDView:startInit()
	self.textTips:setString(Config.LoginWords[345])
	VisibleRect:relativePosition(textTips, self.rootNode, LAYOUT_CENTER,ccp(0,-50))
	self.loadingNode:setVisible(true)
	if self.btnEnterGame then
		self.btnEnterGame:setVisible(false)
	end
end

-- ʵ�ֻ�ȡ�������б����ʾ��Ϣ
function GetServerListHUDView:startGetServerList()
	self.textTips:setString(Config.LoginWords[334])
	VisibleRect:relativePosition(textTips, self.rootNode, LAYOUT_CENTER,ccp(0,-50))
	self.loadingNode:setVisible(true)
	if self.btnEnterGame then
		self.btnEnterGame:setVisible(false)
	end
end

--��ȡ
function GetServerListHUDView:getServerList(errCode)
	if errCode == ServerListCode.Success then
		-- ֹͣתȦ
		self.loadingNode:setVisible(false)

		-- ��ʾ��¼��ť		
		if not self.btnEnterGame then
			self.btnEnterGame = createButtonWithFramename(RES("role_loginBtn.png"), RES("role_loginBtn.png"))
			self:addChild(self.btnEnterGame)
			VisibleRect:relativePosition(self.btnEnterGame, self:getContentNode(), LAYOUT_CENTER,ccp(0,-170))	
			
			local LoginConnect = function ()
				LoginWorld.Instance:getLoginManager():requestLogin()
			end

			self.btnEnterGame:addTargetWithActionForControlEvents(LoginConnect,CCControlEventTouchDown)	
		else
			self.btnEnterGame:setVisible(true)
		end
		
		-- Ϊ�˱����sdk�������˸, ������0.3Sȥ�����¼
		local schedulerId = 0
			
		local function scheduleCallback(time)
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedulerId)
			LoginWorld.Instance:getLoginManager():requestLogin()
		end
			
		schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 0.3, false)
	else
		self.loadingNode:setVisible(state)
		
		if errCode == ServerListCode.NetworkError then
			self:showGetServerListFail()
		else
			self:showServerListDataError()
		end
	end
end

function GetServerListHUDView:reGetServerList()
	self.loadingNode:setVisible(true)
	LoginWorld.Instance:getLoginManager():requestServerList()--����������б�		
end

function GetServerListHUDView:showServerListDataError()
	local reGetFunc = function(arg,text,id)		
		if id == 0 then	
			self:reGetServerList()
		else
			os.exit(0)
		end	
	end
	local btns ={
		{text = Config.LoginWords[344],	id = 1},
		{text = Config.LoginWords[340],	id = 0},
	}

	local msg = showMsgBox(Config.LoginWords[358])
	msg:setBtns(btns)
	msg:setNotify(reGetFunc)
end

function GetServerListHUDView:showGetServerListFail()
	local reGetFunc = function(arg,text,id)		
		if id == 0 then	
			self:reGetServerList()
		else
			os.exit(0)
		end	
	end
	local btns ={
		{text = Config.LoginWords[344],	id = 1},
		{text = Config.LoginWords[340],	id = 0},
	}

	local msg = showMsgBox(Config.LoginWords[339])
	msg:setBtns(btns)
	msg:setNotify(reGetFunc)
end

function GetServerListHUDView:showVersion()
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
	
	if needReadAppResources() then
		ResManager.Instance:releaseZpk()
	end
end
