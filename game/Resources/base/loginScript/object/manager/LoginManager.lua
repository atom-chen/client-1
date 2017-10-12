require("object.manager.HttpDef")
require("gameevent.LoginGameEvent")
require("scene.SceneManager")
require("object.manager.StatisticsMgr")
require("object.manager.ConnectionService")

local MaxReconnectTime = 10

ConnectMode = {
Normal = 0,		-- ��ͨ���ӷ�ʽ
Reconnect = 1,	-- ��Ϸ�ڵĶ�������
}



LoginManager = LoginManager or BaseClass()

function LoginManager:__init()
	self.userName = ""
	self.passWord = ""
	self.loginHeroList = {}

	self.plistTable =
	{
	[1] = "loginUi/ui_login/ui_login_role.plist",
	[2] = "loginUi/ui_login/ui_login_server.plist",
	[3] = "loginUi/ui_login/ui_login_role_modelCreateRole.plist",
	[4] = "loginUi/ui_login/ui_login_role_modelFemanDaoshi.plist",
	[5] = "loginUi/ui_login/ui_login_role_modelFemanMagic.plist",
	[6] = "loginUi/ui_login/ui_login_role_modelFemanWarior.plist",
	[7] = "loginUi/ui_login/ui_login_role_modelManDaoshi.plist",
	[8] = "loginUi/ui_login/ui_login_role_modelManMagic.plist",
	[9] = "loginUi/ui_login/ui_login_role_modelManWarior.plist",
	[10] = "loginUi/login_common_4444.plist",
	[11] = "loginUi/login_common_bg1.plist",
	[12] = "loginUi/login_common8888.plist",
	[13] = "loginUi/login_game_hero.plist",
	[14] = "loginUi/login_game_logo.plist",
	}
	self.gameServerAuthData = {}	-- ��Ϸ����֤����
	self.authData = ""				-- �Žӷ�������֤����
	self:registerLuaCallBack()     	--���õ�¼������lua�Ļص�
	
	self.serverListErrCode = ServerListCode.Waiting		-- ��ȡ�������б�Ĵ�����
	self.serverListErrMsg = ""
	self.isCreateNewRole = false
	self.isRetryBridge = false
	self:initMusic()
	
	-- TCP���ӷ���
	local function handler(bConnect)
		self:tcpEventHandler(bConnect)
	end
	self.connectionService = ConnectionService.New()
	self.connectionService:setCallback(handler)
	
	self.connectMode = ConnectMode.Normal
	self.reconnectSchId = -1
end

function LoginManager:__delete()
	if table.size(self.loginHeroList)>0 then
		for i,v in pairs(self.loginHeroList) do
			v:DeleteMe()
		end
	end
	
	self.connectionService:DeleteMe()
end

-- �Ƿ��ڴ����������
function LoginManager:isReconnect()
	return self.connectMode == ConnectMode.Reconnect
end

-- ������������ӺͶϿ����¼�
function LoginManager:tcpEventHandler(state)
	if SceneManager.Instance:isInLoginScene() then
		-- ��¼����Ĵ���
		self:handleLoginSceneNetworkEvent(state)
	else
		-- ��Ϸ�����Ĵ���
		self:handleGameSceneNetworkEvent(state)
	end
end

function LoginManager:handleLoginSceneNetworkEvent(state)
	if not state then
		return
	end
	
	if state == ConnectState.Connected then
		-- ���ӳɹ�
		self:handleServerConnected()
		--��¼Ϊ�ϴε�½
		local serverMgr = LoginWorld.Instance:getServerMgr()
		local server = serverMgr:getSelectServer()
		serverMgr:saveLastTimeServer(server:getServerIp(), server:getServerPort())
	elseif code == ConnectState.Timeout then
		--��ʾ���ӷ�������ʱ
		local function msgBoxCallback(arg, text, id)
			if id == E_MSG_BT_ID.ID_OK then
				-- ����
				self:connectServer(ip, port, serverId)
			end
		end
		
		local msgBox = showMsgBox(Config.LoginWords[350], E_MSG_BT_ID.ID_CANCELAndOK)
		msgBox:setNotify(msgBoxCallback)
	else
		UIManager.Instance:hideLoadingHUD()
		self:handleLoginDisconnect()
	end
end

function LoginManager:handleGameSceneNetworkEvent(state)
	if not state then
		return
	end
	
	if state == ConnectState.Connected then
		GlobalEventSystem:Fire(GameEvent.EventReconnect, false)		
		if GameWorld and GameWorld.Instance then
			GameWorld.Instance:clearMgr()
		end
		self:endReconnectSchedule()
		self:handleServerConnected()
	else
		if self.reconnectSchId == -1 then
			self:startReconnectSchedule(MaxReconnectTime)
			GlobalEventSystem:Fire(GameEvent.EventReconnect, true, MaxReconnectTime)
			self.connectMode = ConnectMode.Reconnect
			
			-- ֹͣӢ�۵�Ѱ·���һ���ս��
			local hero = GameWorld.Instance:getEntityManager():getHero()
			if hero then
				GameWorld.Instance:getAutoPathManager():cancel()
				hero:forceStop()
				GameWorld.Instance:getAnimatePlayManager():removeAll()
		
				G_getHandupMgr():stop()
			end
		end
		
		-- �ٷ���һ������
		self.connectionService:reConnect()
	end
end

function LoginManager:startReconnectSchedule(time)
	if time and type(time) == "number" and time > 0 and self.reconnectSchId == -1 then
		local function onScheduleCallback()
			-- �Ѿ���ʱ��, �Ͽ�����, ������ʾ
			self.connectionService:slientDisConnect()
			
			self:endReconnectSchedule()			
			self:handleGameDisconnect()
		end
		
		self.reconnectSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleCallback, time, false)
	end
end

function LoginManager:endReconnectSchedule()
	if self.reconnectSchId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.reconnectSchId)
		self.reconnectSchId = -1
	end
end

function LoginManager:initMusic()
	local OptionConfig = {}
	local reader = CCUserDefault:sharedUserDefault()
	local inited = reader:getStringForKey(Config.UserDefaultKey.Option_InitFlag)
	if (inited ~= "1") then	--δд�����û��������ļ�����ʹ��Ĭ������
		OptionConfig = self:getDefaultOptionConfig()
	else
		OptionConfig.voiceValue = reader:getIntegerForKey(Config.UserDefaultKey.Option_MusicValue)
		OptionConfig.musicValue = reader:getIntegerForKey(Config.UserDefaultKey.Option_VoiceValue)
		OptionConfig.voiceOff = reader:getIntegerForKey(Config.UserDefaultKey.Option_VoiceOff)
		OptionConfig.musicOff = reader:getIntegerForKey(Config.UserDefaultKey.Option_MusicOff)
	end
	if OptionConfig.musicOff == Setting_checkStatus.TRUE then
		SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
	else
		SimpleAudioEngine:sharedEngine():setEffectsVolume(OptionConfig.musicValue)
	end
	
	if OptionConfig.voiceOff == Setting_checkStatus.TRUE then
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
	else
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(OptionConfig.voiceValue)
	end
end

function LoginManager:getConnectionService()
	return self.connectionService
end

function LoginManager:getDefaultOptionConfig()
	local config = {}
	config.voiceValue = 50
	config.musicValue = 50
	config.voiceOff	= Setting_checkStatus.FALSE		--Ĭ�ϲ�����
	config.musicOff = Setting_checkStatus.FALSE
	config.IsShowOtherPlayer = Setting_checkStatus.TRUE
	config.IsShowEffect = Setting_checkStatus.TRUE
	config.IsShowPlayerName = Setting_checkStatus.TRUE
	return config
end

function LoginManager:requestLogin()
	-- ��ͬƽ̨���ò�ͬ��
	SFLoginManager:getInstance():getServerListSuccess(self.serverListJson or "") --ȥsdk��½
	local logoutCallback = function ()
		self:handleLogOut()
	end
	SFLoginManager:getInstance():setLogOutHandler(logoutCallback)
	if SFLoginManager:getInstance():getPlatform() == "win32" then --androidƽ̨����ʾ��½����
		GlobalEventSystem:Fire(GameEvent.EVENT_LOGIN_UI)
	end
end

function LoginManager:requestBridgeAuth(serverId)
	if SFLoginManager:getInstance():getPlatform() ~= "win32" then
		self.authData = SFLoginManager:getInstance():getAuthData()
		--�Ž����ݳ������µ�¼sdk
		if self.authData==nil or self.authData=="" then
			SFLoginManager:getInstance():logout()
			self:requestLogin()
			return
		end
	end
	
	self.serverId = serverId
	local sendVal = self.authData.."&serverId="..serverId
	CCLuaLog("sendval = " .. sendVal)
	local httpTools = HttpTools:getInstance()
	local loginMgr = SFLoginManager:getInstance()
	local authUrl = loginMgr:getBridgeUrl().."?"..sendVal
	
	httpTools:send(authUrl, kTypePost, eHttpReqTag.BridgeAuthTag, 0, 0)
end

-- �ǵ�����SDK��¼�õĽӿ�
function LoginManager:login(userName, passWord)
	self.userName = userName
	self.passWord = passWord
	self.authData = "userId="..userName.."&".."userName="..userName.."&".."passWord="..passWord.."&".."sign=".."NEWBEE-PROGRAM-LIJIANYANG".."&".."tstamp=".."0".."&".."gameKey=".."lieyanzhetian"
	GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
end

function LoginManager:requestUserAuth()
	if self.gameServerAuthData then
		-- user auth
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_User_Auth)
		writer:WriteString(self.gameServerAuthData.identityId)--identityId
		writer:WriteString(self.gameServerAuthData.userName)--account
		writer:WriteLLong(self.gameServerAuthData.tstamp)--timeStamp
		writer:WriteString(self.gameServerAuthData.sign)--signStr
		writer:WriteString(self.gameServerAuthData.uuid)--uuid
		writer:WriteInt(self.gameServerAuthData.qdCode1)--qdCode1
		writer:WriteInt(self.gameServerAuthData.qdCode2)--qdCode2
		simulator:sendTcpActionEventInLua(writer)
	end
end

-- ��ȡ��ɫ
function LoginManager:requestCharactorGet()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Charactor_Get)
	simulator:sendTcpActionEventInLua(writer)
end

-- �����ɫ��¼
function LoginManager:requestCharactorLogin(playerId, screenWidth, screenHeight)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Charactor_Login)
	writer:WriteString(playerId)
	writer:WriteShort(screenWidth)
	writer:WriteShort(screenHeight)
	simulator:sendTcpActionEventInLua(writer)
end

-- ������ɫ
function LoginManager:requestCharactoCreate(profession,gender, charactoName)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Charactor_Reg)
	
	writer:WriteChar(gender)
	writer:WriteChar(profession)
	writer:WriteString(charactoName)
	simulator:sendTcpActionEventInLua(writer)
end

--ɾ����ɫ����
function LoginManager:requestCharactoRemoveRole(characterId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Character_Delete)
	StreamDataAdapter:WriteStr(writer,characterId)
	simulator:sendTcpActionEventInLua(writer)
end

--��¼ѡ���ɫ�б�
function LoginManager:setLoginHeroList(obj)
	table.insert(self.loginHeroList,obj)
end

function LoginManager:getLoginHeroList()
	return self.loginHeroList
end

function  LoginManager:getLoginHeroObj(index)
	if self.loginHeroList[index] then
		return self.loginHeroList[index]
	end
end

function LoginManager:removeLoginHeroList()
	if table.size(self.loginHeroList)>0 then
		for i,v in pairs(self.loginHeroList) do
			v:DeleteMe()
		end
	end
	self.loginHeroList = {}
end

function LoginManager:removeLoginHero(id)
	for i,v in pairs(self.loginHeroList) do
		local characterid = v:getCharacterId()
		if characterid==id then
			self.loginHeroList[i] = nil
		end
	end
end

--ɾ����¼��Դ
function LoginManager:deleteLoginRes()
	for i,v in pairs(self.plistTable) do
		local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
		frameCache:removeSpriteFramesFromFile(v)
	end
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	CCDirector:sharedDirector():getTouchDispatcher():removeAllDelegates()
	self:removeUserNameInfo()
	
	-- �ֶ��ͷ�UI����
	UIManager.Instance:releaseUI("LoginView")
	UIManager.Instance:releaseUI("SelectRoleView")
	UIManager.Instance:releaseUI("CreateNewRoleView")
	
	UIManager.Instance:releaseUI("AllServerView")
	UIManager.Instance:releaseUI("ResourcesUpdateView")
	UIManager.Instance:releaseUI("GetServerListHUDView")
end
--ɾ������û�������
function LoginManager:removeUserNameInfo()
	if GameData.familyName ~= nil then
		GameData.familyName = nil
	end
	if GameData.maleName ~= nil then
		GameData.maleName = nil
	end
	if GameData.femaleName ~= nil then
		GameData.femaleName = nil
	end
	package.loaded["data.userName.familyName"] = nil
	package.loaded["data.userName.maleName"] = nil
	package.loaded["data.userName.femaleName"] = nil
end

--�����½��������
function LoginManager:saveUserAndPwd(bSave)
	local writer = CCUserDefault:sharedUserDefault()
	if bSave then
		writer:setStringForKey(Config.UserDefaultKey.Login_UserName, self.userName)
		writer:setStringForKey(Config.UserDefaultKey.Login_Password, self.passWord)
	else
		writer:setStringForKey(Config.UserDefaultKey.Login_UserName, self.userName)
		writer:setStringForKey(Config.UserDefaultKey.Login_Password, "")
	end
	writer:flush()
end

function LoginManager:setSaveUserNameAndPwd(bSave)
	self.bSave = bSave
end

function LoginManager:isSaveUserNameAndPwd()
	return self.bSave
end

function LoginManager:getServerListErrCode()
	return self.serverListErrCode
end

function LoginManager:handleServerList(state, responeData)
	--self.serverListErrCode = state
	
	if self:checkHttpState(state) then
		local cjson = require "cjson.safe"
		local data,errorMsg = cjson.decode(responeData)
		
		if data and LoginWorld.Instance:getServerMgr():parseData(data) and ResManager.Instance:paserVersionData(data.resVer) then
			self.serverListErrCode = ServerListCode.Success
			self.serverListJson = responeData
			
			-- ��Դ��ʼ���ɹ��˲Ž�����һ��
			if ResManager.Instance:isInitSuccess() then
				--GlobalEventSystem:Fire(GameEvent.EventGetServerListState,ServerListCode.Success)
				LoginWorld.Instance:getStatisticsMgr():requestInstallStatistics() --��װͳ��
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.GameStart)  --ͳ����Ϸ��ʼ
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.GetServerListFinish)
			end
		else
			self.serverListErrCode = ServerListCode.FormatError
		end
	else
		self.serverListErrMsg = responeData
		self.serverListErrCode = ServerListCode.FormatError
	end
	
	GlobalEventSystem:Fire(GameEvent.EventGetServerListState, self.serverListErrCode)
end

function LoginManager:handleBridgeAuth(state, responeData)
	if self:checkHttpState(state) then
		local cjson = require "cjson.safe"
		local authData,errorMsg = cjson.decode(responeData)
		if authData and authData.code == 0 then
			--�Ž���֤�ɹ�
			self.isRetryBridge = false
			SFLoginManager:getInstance():bridgeAuthSuccess(responeData)
			SFLoginManager:getInstance():setServerId(authData.serverId)
			SFLoginManager:getInstance():setPlayerId(authData.identityId)
			self:userAuth(authData)
			self:_connectServer()
			--UIManager.Instance:hideLoadingHUD()
		elseif authData then
			if not self.isRetryBridge then
				-- �Žӷ��ش���, ����һ��
				self:requestBridgeAuth(self.serverId)
				self.isRetryBridge =  true
			else
				--��ʾ���ӷ�������ʱ
				local function msgBoxCallback(arg, text, id)
					if id == E_MSG_BT_ID.ID_OK then
						-- �Ѿ������˻��ǳ���, ��������һ��sdk��¼
						SFLoginManager:getInstance():logout()
						self:requestLogin()
						self.isRetryBridge = false
					end
				end
				
				local msgBox = showMsgBox(Config.LoginWords[352], E_MSG_BT_ID.ID_OK)
				msgBox:setNotify(msgBoxCallback)
				UIManager.Instance:hideLoadingHUD()
				self.connectionService:slientDisConnect()
			end
			
			CCLuaLog("handleBridgeAuth error:"..authData.code)
		else
			UIManager.Instance:showSystemTips("Error:  " .. errorMsg)
			CCLuaLog("Decode BridgeAuth Fail:"..errorMsg)
			UIManager.Instance:hideLoadingHUD()
			--TODO
		end
	else
		UIManager.Instance:hideLoadingHUD()
		UIManager.Instance:showSystemTips(Config.LoginWords[337])
	end
end

-- ��������֤ͨ��
function LoginManager:handleUseAuthSuccess()
	local findHero = false
	if GameWorld and GameWorld.Instance and GameWorld.Instance:getEntityManager():getHero() then
		findHero = true
	end
	
	if self.connectMode == ConnectMode.Normal or not findHero then
		self:requestCharactorGet()
		GlobalEventSystem:Fire(GameEvent.EventSaveUserNameAndPwd)
	else
		-- ����Ϸ�ڶ���������
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local size = CCDirector:sharedDirector():getVisibleSize()
		self:requestCharactorLogin(hero:getId(), size.width, size.height)
	end
end

function LoginManager:connectServer(ip, port, serverId)
	if (not ip) or (not port) or (not serverId) then
		return
	end
	self.connectionService:slientDisConnect()
	self.connectMode = ConnectMode.Normal
	--����ѡ��ķ�����
	local serverMgr = LoginWorld.Instance:getServerMgr()
	serverMgr:setSelectServer(ip, port)
	local selectServer = serverMgr:getSelectServer()
	
	--���apk����
	if (self:checkUpdateVersion()) == true then
		self:updateClient(selectServer)
		return
	end
	
	UIManager.Instance:showLoadingHUD(10)
	if ResManager.Instance:checkResVersion() then
		local notifyMgr = LoginWorld.Instance:getNotifyManager()
		notifyMgr:setBagUpdate(true)		
		ResManager.Instance:requestUpdateRes(serverId, nil, nil, eHttpReqTag.ResUpdateTag)
		return
	end
	-- Ҫ������bridge����֤
	ResManager.Instance:loadScript()
	self:requestBridgeAuth(serverId)
end

-- ���ӷ������ɹ�
function LoginManager:handleServerConnected()
	if GameWorld and GameWorld.Instance and not GameWorld.Instance:getSchedulerId() then
		GameWorld.Instance:startScheduler()
	end
	self:requestUserAuth()
end

function LoginManager:handleLogOut()
	self:getConnectionService():slientDisConnect()	
		
	if GameWorld and GameWorld.Instance then
			-- ���������Ĵ���
			GameWorld.Instance:getAutoPathManager():cancel()
			GameWorld.Instance:getEntityManager():getHero():forceStop()
			GameWorld.Instance:getAnimatePlayManager():removeAll()			
			G_getHandupMgr():stop()			
			GameWorld.Instance:deleteScheduler()			
	end
				
	LoginWorld.Instance:getLoginManager():clearAndReturnLogin()
end

function LoginManager:clearAndReturnLogin()
	if GameWorld and GameWorld.Instance then
		GameWorld.Instance:clearMgr()
		local mapManager = GameWorld.Instance:getMapManager()
		mapManager:reset()
	end
	if SceneManager.Instance:getCurrentGameSceneName() ~= SceneIdentify.LoginScene then
		SceneManager:switchTo(SceneIdentify.LoginScene)
	end
	
	local serverMgr = LoginWorld.Instance:getServerMgr()
	serverMgr:clear()
	self:requestServerList()
	GlobalEventSystem:Fire(GameEvent.EventShowGetServerListHUD)
end

-- �ڵ�¼�����Ͽ�����
function LoginManager:handleLoginDisconnect()
	self.connectionService:slientDisConnect()
	
	-- ���ص�¼����
	local returnToLoginView = function(arg,text,id)
		self:clearAndReturnLogin()
	end
	
	if GameWorld and GameWorld.Instance then
		-- ���������Ĵ���
		GameWorld.Instance:getAutoPathManager():cancel()
		GameWorld.Instance:getEntityManager():getHero():forceStop()
		GameWorld.Instance:getAnimatePlayManager():removeAll()
		
		G_getHandupMgr():stop()
		GameWorld.Instance:deleteScheduler()
	end
	
	local manager = UIManager.Instance
	if manager:isShowing("AllServerView") then
		UIManager.Instance:showSystemTips(Config.LoginWords[348])
	else
		local msg = showMsgBox(self:constructDisconectMsg())
		msg:setNotify(returnToLoginView)
	end
	g_lastErrorInfo = {} --������ϴεĴ�����Ϣ
end

-- ����Ϸ�����Ͽ�����
function LoginManager:handleGameDisconnect()
	local function clickCallback(arg,text,id)
		if id ==  1 then
			-- ����			
			self:startReconnectSchedule(MaxReconnectTime)
			GlobalEventSystem:Fire(GameEvent.EventReconnect, true, MaxReconnectTime)
			self.connectMode = ConnectMode.Reconnect			
		
			-- �ٷ���һ������
			self.connectionService:reConnect()
		else
			-- �˳���Ϸ
			os.exit(0)
		end
	end
	
	local btns ={
		{text = Config.Words[344], id = 0},
		{text = Config.Words[340], id = 1},
	}
	
	local msg = showMsgBox(Config.Words[352])
	msg:setBtns(btns)
	msg:setNotify(clickCallback)
end

--1042] = [[�����룺%x(%sǰ)]],
function LoginManager:constructDisconectMsg()
	local str = Config.LoginWords[330]
	if type(g_lastErrorInfo) == "table" then
		local id = g_lastErrorInfo.id
		local time = g_lastErrorInfo.time
		if (type(id) == "number") and (type(time) == "number") and (time > 0) and (id ~= 4294967297) then
			local elapse = os.time() - time
			local info = string.format(Config.LoginWords[1042], "0x", id, self:sec2str(elapse))
			str = str.."\n"..info
		end
	end
	return str
end


function LoginManager:sec2str(sec)
	if (type(sec) ~= "number") or sec < 0  then
		sec = 0
	end
	if sec < 0 then
		return " "
	end
	if type(sec) ~= "number" then
		return " "
	end
	
	local day = math.floor(sec/8640--[[(24*3600)--]])
	local hour = math.floor(sec/3600)%24
	local minute = math.floor(sec/60)%60
	local sec = sec%60
	local str = " "
	if day > 0 then
		str = day..Config.Words[13007]
	else
		if hour > 0 then
			str = string.format("%d%s", hour, Config.Words[13640])
		elseif minute > 0 then
			str = string.format("%02d%s%02d", minute, ":", sec)
		else
			str = string.format("%02d%s", sec, Config.Words[13642])
		end
	end
	return str
end


function LoginManager:_connectServer()
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local server = serverMgr:getSelectServer()
	
	if not server then
		CCLuaLog("Warning!!Can't find the server to connect")
		
		-- TODO: ѡ��һ��Ĭ�Ϸ�����
	end
	
	-- Ϊ�˷�ֹ������û�жϿ��������ȶϿ�һ�η�����
	self.connectionService:slientDisConnect()
	self.connectionService:connect(server:getServerIp(), server:getServerPort())
end

function LoginManager:userAuth(authData)
	-- ����������Ϸ����֤������
	if authData then
		local loginMgr = SFLoginManager:getInstance()
		self.gameServerAuthData = authData
		self.gameServerAuthData.identityName = SFGameHelper:urlDecode(self.gameServerAuthData.identityName)
		self.gameServerAuthData.userName = SFGameHelper:urlDecode(self.gameServerAuthData.userName)
		self.gameServerAuthData.uuid = loginMgr:getUUid()
		--self.gameServerAuthData.uuid = "NewBeeRobot"
		self.gameServerAuthData.qdCode1 = loginMgr:getQDCode1()
		self.gameServerAuthData.qdCode2 = loginMgr:getQDCode2()
	end
end

--����������б�
function LoginManager:requestServerList()
	local loginMgr = SFLoginManager:getInstance()
	local httpTools = HttpTools:getInstance()
	self.serverListErrCode = ServerListCode.Waiting
	--CCLuaLog("-------------------requestServerList--------------, from lua print")
	if httpTools then
		local loginSettingUrl = loginMgr:getLoginSettingUrl()
		
		-- ����Ƿ��а������ļ�		
		local keyFilePath = SFGameHelper:getExtStoragePath() .. "/newBeeTestServer.key"
		local isExist = CCFileUtils:sharedFileUtils():isFileExist(keyFilePath)
		if isExist then
			local fileHandle = io.open(keyFilePath)
			if fileHandle then
				local urlFunction = fileHandle:lines()
								
				if urlFunction then
					loginSettingUrl = urlFunction()
					CCLuaLog("use test enviorment:"..loginSettingUrl)
				end
				
				io.close(fileHandle)
			end
		end
		
		httpTools:send(loginSettingUrl, kTypeGet, eHttpReqTag.ServerListTag, nil, 0)
	end
end

function LoginManager:registerLuaCallBack()
	local loginMgr = SFLoginManager:getInstance()
	
	--��ȡ�Ž���֤���ݣ������Ž�
	local setBridgeAuthData = function ()
		--self.authData = authData
		--����ĳЩƽ̨(��:��棩��sdk���ص�ʱ�����ֱ��������
		--�Դ˼���schedule��תһ��
		local schedulerId = 0
		
		local function scheduleCallback(time)
			local needShowServerView = true
			if SceneManager.Instance:getCurrentGameSceneName() ~= SceneIdentify.LoginScene then
				needShowServerView = false
				self:handleLogOut()
			end
			LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.LoginSDKSuccess) --sdk��½�ɹ�
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedulerId)
			if needShowServerView then
				GlobalEventSystem:Fire(GameEvent.EVENT_SELECTALLSERVER_UI)
			end				
		end
		schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 0, false)
	end
	loginMgr:setLuaBridgeAuthCB(setBridgeAuthData)
	
	--�ȴ���תȦȦ
	local showOrHideWaitView = function (opt, sec)
		if opt == "show" then
			UIManager.Instance:showLoadingHUD(sec)
		else
			UIManager.Instance:hideLoadingHUD()
		end
	end
	loginMgr:setLuaWaitViewCB(showOrHideWaitView)
	
	local appUpdteTypeCallback = function (tag, state)
		if tag == "appStatistics" then  --�Զ����¡��ֶ�����
			if state ==1 or state ==2 then
				LoginWorld.Instance:getStatisticsMgr():requestAppVersionTypeStatistics(state)
			end
		elseif tag == "appDownloadState" then  --����״̬(��ʼ���������쳣��
			if state ==1 then --��ʼ
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.AppDownloadStart)
			elseif state ==2 then --����
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.AppDownloadFinish)
			else  --�쳣
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.AppDownloadException)
			end
		end
	end
	SFGameHelper:setAppCallback(appUpdteTypeCallback)
end

function LoginManager:getPackageUpdateUrl(updateUrl)
	--http://xxx/{gameKey}/{platform}/{gameKey}_{qdKey}_{version}.{suffix}
	local matchKey = {}
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local selectServer = serverMgr:getSelectServer()
	local sfLoginMgr = SFLoginManager:getInstance()
	local gameKey = sfLoginMgr:getGameKey()
	local platform = sfLoginMgr:getPlatform()
	local qdKey = sfLoginMgr:getQDKey()
	local version = self:getServerClientVer(selectServer)
	local suffix = sfLoginMgr:getSuffix()
	
	
	local matchKey = {}
	matchKey["gameKey"] = gameKey or ""
	matchKey["platform"] = platform or ""
	matchKey["qdKey"] = qdKey or ""
	matchKey["version"] = version or ""
	matchKey["suffix"] = suffix or ""
	
	local key = ""
	repeat
		key = string.match(updateUrl, "{.-}")
		if key then
			key = string.sub(key, 2, -2)
			local value = matchKey[key]
			if value then
				updateUrl = string.gsub(updateUrl, "{"..key.."}", value)
			end
		end
	until string.match(updateUrl,"{.-}") == nil
	
	return updateUrl
end


--�汾�Ա�
function LoginManager:checkUpdateVersion()
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local selectServer = serverMgr:getSelectServer()
	local bUpdate = false
	local bForceUpdate = false  --�Ƿ���Ҫǿ�Ƹ���
	if selectServer then
		local clientVer, clientMinVer = self:getServerClientVer(selectServer)
		local curVer = SFGameHelper:getClientVersion()
		CCLuaLog("clientVersion = ".. clientVer)
		CCLuaLog("miniVersion = " .. clientMinVer)
		CCLuaLog("curClient version = ".. curVer)
		
		bForceUpdate = ResManager.Instance:compareVersion(clientMinVer, curVer)
		if bForceUpdate == true then
			bUpdate = true
		else
			local cmpVal = ResManager.Instance:compareVersion(clientVer, curVer)
			if cmpVal == true then
				bUpdate = true
			end
		end
		return bUpdate, bForceUpdate, clientVer
	end
end

function LoginManager:getIOSPackageUpdateUrl(updateUrl,selectServer)
	local matchKey = {}
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local selectServer = serverMgr:getSelectServer()
	local sfLoginMgr = SFLoginManager:getInstance()
	local gameKey = sfLoginMgr:getGameKey()
	local qdKey = sfLoginMgr:getQDKey()
	local version = self:getServerClientVer(selectServer)
	
	
	local matchKey = {}
	matchKey["gameKey"] = gameKey or ""
	matchKey["qdKey"] = qdKey or ""
	matchKey["version"] = version or ""
	
	local key = ""
	repeat
		key = string.match(updateUrl, "{.-}")
		if key then
			key = string.sub(key, 2, -2)
			local value = matchKey[key]
			if value then
				updateUrl = string.gsub(updateUrl, "{"..key.."}", value)
			end
		end
	until string.match(updateUrl,"{.-}") == nil
	
	key = "version"
	updateUrl = string.gsub(updateUrl, "{"..key.."}", version)
	return updateUrl
end

function LoginManager:updateClientNotice(func)
	local callback = function(arg,text,id)
		if id == 0 then
			func()
		end
	end
	if func then
		callback = func
	end
	local btns ={
	{text = Config.LoginWords[10043], id = 0},
	{text = Config.LoginWords[10045], id = 1},
	}
	local notic = Config.LoginWords[14010]
	
	local msg = showMsgBox(notic)
	msg:setBtns(btns)
	msg:setNotify(callback)
end

--�ͻ�������
function LoginManager:updateClient(selectServer)
	local canUpdate, forceUpdate, newVersion = self:checkUpdateVersion()
	if canUpdate == true and selectServer then
		local updateUrl = selectServer:getClientUpdateUrl()
		if SFLoginManager:getInstance():getPlatform() == "ios" then
			updateUrl = selectServer:getIosClentUpdateUrl()
			updateUrl = self:getIOSPackageUpdateUrl(updateUrl,selectServer)--��url�϶�Ӧ���ֶλ��ɸ���ƽ̨��
		else
			updateUrl = self:getPackageUpdateUrl(updateUrl)--��url�϶�Ӧ���ֶλ��ɸ���ƽ̨��
		end
		if type(updateUrl) == "string" then
			CCLuaLog("updateUrl============"..updateUrl)
			print("updateUrl============"..updateUrl)
		end
		
		local updateFunc = function ()
			SFGameHelper:updateClient(updateUrl, newVersion, forceUpdate)
		end
		
		if SFGameHelper:getCurrentNetWork() ~= kWifi then
			self:updateClientNotice(updateFunc)
		else
			updateFunc()
		end
		
		return true
	else
		return false
	end
end

function LoginManager:setIsCreateNewRole(bCreated)
	self.isCreateNewRole = bCreated
end

function LoginManager:getIsCreateNewRole()
	return self.isCreateNewRole
end

--��ȡuserid�� ����ͳ��
function LoginManager:getUserId()
	if self.gameServerAuthData and self.gameServerAuthData.userId then
		return self.gameServerAuthData.userId
	end
end

--��ȡidentityName�����������
function LoginManager:getIdentityName()
	if self.gameServerAuthData and self.gameServerAuthData.identityName then
		return self.gameServerAuthData.identityName
	end
end

function LoginManager:checkHttpState(state)
	return state == 200
end

-- ��ȡ��������Ӧ��ƽ̨�İ汾�ź���С�汾��
function LoginManager:getServerClientVer(serverObject)
	if not serverObject then
		return "0.0.0.0", "0.0.0.0"
	end
	
	if SFLoginManager:getInstance():getPlatform() == "ios" then
		return serverObject:getIosVer(),serverObject:getIosMiniVer()
	else
		-- windows��android����һ���汾��
		return serverObject:getAndroidVer(), serverObject:getAndroidMiniVer()
	end
end