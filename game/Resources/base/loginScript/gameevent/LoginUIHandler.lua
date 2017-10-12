require "common.GameEventHandler"
require "common.baseclass"
require "gameevent.LoginGameEvent"
require("ui.UIManager")
require("ui.login.LoginView")
require("ui.login.ReconnectView")
require("ui.login.SelectRoleView.SelectRoleView")
require("ui.login.CreateNewRoleView.CreateNewRoleView")
require("ui.login.SelectServer.AllServerView")
require("ui.login.ResourcesUpdateView")
require "ui.utils.EditBoxDialog"
require "ui.utils.MessageBox"
require "ui.utils.MessageBoxWithEdit"
require("ui.login.GetServerListHUDView")
require("ZpkUtils")

LoginUIHandler = LoginUIHandler or BaseClass(GameEventHandler)
local userData = nil

function LoginUIHandler:__init()
	local manager =UIManager.Instance
	manager:registerUI("LoginView",LoginView.create)
	manager:registerUI("SelectRoleView",SelectRoleView.create)
	manager:registerUI("CreateNewRoleView",CreateNewRoleView.create)
		
	manager:registerUI("AllServerView", AllServerView.create)	
	manager:registerUI("ResourcesUpdateView", ResourcesUpdateView.create)
	manager:registerUI("EditBoxDialog", EditBoxDialog.create)
	manager:registerUI("MessageBox", MessageBox.create)
	manager:registerUI("MessageBoxWithEdit", MessageBoxWithEdit.create)
	manager:registerUI("GetServerListHUDView",GetServerListHUDView.create)
	--manager:registerUI("PlayerPropertyView",PlayerPropertyView)
	local eventResoursesUpdate = function ()
		manager:showUI("ResourcesUpdateView")
	end
	local eventLogin = function ()
		manager:showUI("LoginView")
	end
	local eventSelectRole = function ()
		manager:showUI("SelectRoleView")
	end
	local eventCreateNewRole = function ()
		manager:showUI("CreateNewRoleView")
	end		
	--全部服务器
	local eventSelectAllServer = function ()
		manager:showUI("AllServerView")
	end
	--保存账号密码
	local eventSaveNameAndPwd = function ()
		local loginView = manager:getViewByName("LoginView")
		local loginMgr = LoginWorld.Instance:getLoginManager()
		if loginMgr:isSaveUserNameAndPwd() then
			loginMgr:saveUserAndPwd(true)
		else
			loginMgr:saveUserAndPwd(false)
		end
	end		
	
	local EventDeleteRolefunc = function(heroId)
		local View = manager:getViewByName("SelectRoleView")
		if View then
			View:EventDeleteRolefunc(heroId)
		end
	end				
	
	local eventCreateRole = function ()
		local View = manager:getViewByName("SelectRoleView")
		if View then
			View:EventCreateRole()
		end
	end
	
	local hideInit = function ()
		self:hideInitView()
	end
	
	local download = function (isSilent)
		if not isSilent then
			-- 非后台下载才要显示这个界面
			manager:showUI("ResourcesUpdateView")
			local view = manager:getViewByName("ResourcesUpdateView")
			if view then
				-- 获取下载列表
				local list = ResManager.Instance:getPatchUrlList()
				local callback = ResManager.Instance:getDownloadCallBack()
				view:startDownload(list,callback)
			end
		end
	end
	
	local patch = function (patchList, callback)
		manager:showUI("ResourcesUpdateView")
		local View = manager:getViewByName("ResourcesUpdateView")
		if View then
			View:startPatch(patchList, callback)
		end
	end
	
	local eventShowGetServerListHUD = function()
		self:handleShowGetServerListView()
	end
	
	local eventGetServerListState = function(errorCode)
		local view = manager:getViewByName("GetServerListHUDView")
		self:handle_getServerList(view, errorCode)
	end
	
	local updateLastTimeServer = function ()
		local view = manager:getViewByName("AllServerView")
		if view then  
			view:updateLastTimeServer()
		end
	end
	
	local onErrorFunc = function (msgId, errCode)
		self:onError(msgId, errCode)
	end
	
	local onHeroEnterGame = function ()
		-- 进入游戏, 注销掉自己的对于EventErrorCode的监听
		if self.eventErrorCode then
			self:UnBind(self.eventErrorCode)
			self.eventErrorCode = nil
		end
	end
	
	local onHeroLeaveGame = function ()
		-- 退出游戏，重新注册注销掉自己的对于EventErrorCode的监听
		self:registerErrorCodeEvent(onErrorFunc)
	end
	
	local onEventUpdateHeroName = function ()
		local view = manager:getViewByName("CreateNewRoleView")
		if view then
			view:setHeroName()
		end
	end
	
	local onEventReconnect = function (bShow, time)
		if bShow and time then
			-- 先隐藏掉所有dialog
			UIManager.Instance:hideAllUI()
			UIManager.Instance:hideAllDialog()
			
			if not self.reconnectView then
				self.reconnectView = ReconnectView.New()
			end
			
			UIManager.Instance:showDialog(self.reconnectView:getRootNode(), E_DialogZOrder.ReviveDlg)
			self.reconnectView:startCountDown(time)
		elseif self.reconnectView then
			UIManager.Instance:hideDialog(self.reconnectView:getRootNode())
			self.reconnectView:DeleteMe()
			self.reconnectView = nil
		end
	end
	
	self:Bind(GameEvent.EventUpdateLastTimeServer, updateLastTimeServer)
	self:Bind(GameEvent.EventGetServerListState,eventGetServerListState)
	self:Bind(GameEvent.EventShowGetServerListHUD,eventShowGetServerListHUD)
	self:Bind(GameEvent.EventResoursesUpdate, eventResoursesUpdate)	
	self:Bind(GameEvent.EVENT_LOGIN_UI,eventLogin)
	self:Bind(GameEvent.EVENT_SELECT_ROLE_UI,eventSelectRole)
	self:Bind(GameEvent.EVENT_CREATE_ROLE_UI,eventCreateNewRole)	
	self:Bind(GameEvent.EVENT_SELECTALLSERVER_UI, eventSelectAllServer)
	self:Bind(GameEvent.EventSaveUserNameAndPwd, eventSaveNameAndPwd)	
	self:Bind(GameEvent.EventDeleteRole, EventDeleteRolefunc)		
	self:Bind(GameEvent.EventCreateRole,eventCreateRole )
	self:Bind(GameEvent.EventCloseInit,hideInit)
	self:Bind(GameEvent.EventDownload,download)
	self:Bind(GameEvent.EventPatch,patch)	
	self:registerErrorCodeEvent(onErrorFunc)
	
	self:Bind(GameEvent.EventHeroEnterGame,onHeroEnterGame)
	self:Bind(GameEvent.EventHeroLeaveGame,onHeroLeaveGame)
	self:Bind(GameEvent.EventUpdateHeroName, onEventUpdateHeroName)
	self:Bind(GameEvent.EventReconnect, onEventReconnect)
end

function LoginUIHandler:registerErrorCodeEvent(func)
	if not self.eventErrorCode then
		self.eventErrorCode = self:Bind(GameEvent.EventErrorCode,func)
	end
end

function LoginUIHandler:__delete()
	
end

function LoginUIHandler:onError(msgId, errCode)
	--  登录以前都是在这里显示相关的提示信息
	local data = GameData.Code[errCode]
	if data then
		CCLuaLog (msgId.." : ".. data)
		UIManager.Instance:showSystemTips(data)
	end
end

function LoginUIHandler:hideInitView()
	local view = UIManager.Instance:getViewByName("GameInitView")
	if view then
		view:close()
	end
end	

function LoginUIHandler:handle_getServerList(view, errCode)
	-- 如果正在拷贝资源，什么都不做, 等拷贝完成后再去改变UI
	if not ResManager.Instance:isCopying() then
		if view then
			view:getServerList(errCode)
		end
	end
end

function LoginUIHandler:handleShowGetServerListView()
	local manager =UIManager.Instance
	manager:showUI("GetServerListHUDView")
	local view = manager:getViewByName("GetServerListHUDView")
	
	local showGetServerList = function ()
		local currentVersion = SFGameHelper:getClientVersion()		
		local machineVersion = CCUserDefault:sharedUserDefault():getStringForKey("version")
		--currentVersion = currentVersion..machineVersion
		if machineVersion then
			if  machineVersion ~= currentVersion then
				local notifyMgr = LoginWorld.Instance:getNotifyManager()
				notifyMgr:setAppUpdate(true)
			end				
		end		
	
		CCUserDefault:sharedUserDefault():setStringForKey("version",currentVersion)
		CCUserDefault:sharedUserDefault():flush()
		CCLuaLog("write version:"..currentVersion)
			
		-- 如果服务器列表已经返回, 直接显示服务器列表界面
		local errCode = LoginWorld.Instance:getLoginManager():getServerListErrCode()
		if errCode ~= ServerListCode.Success then
			-- 检查是否获取服务器列表是否有错误返回
			if errCode == ServerListCode.Waiting then
				-- 正在请求
				if view then
					-- 显示获取服务器列表的文字提示
					view:startGetServerList()
				end
			else
				self:handle_getServerList(view, errCode)
			end
		else
			-- 已经获取到了服务器列表, 去请求sdk登录
			self:handle_getServerList(view, errCode)
		end
	end
	
	-- 检查是否需要拷贝资源
	if ResManager.Instance:needCopy() then
		local copyCallback = function (errCode, param1, param2)
			CCLuaLog("copyCallback:"..errCode)
			if errCode == CopyError.NoSpace then
				-- 空间不足
				local function msgBoxCallback()
					-- 退出APP
					os.exit(0)
				end
				
				local errorMsg = string.format(Config.LoginWords[353]..Config.LoginWords[355], param1/(1024*1024), param2/(1024*1024))
				local msgBox = showMsgBox(errorMsg)
				msgBox:setNotify(msgBoxCallback)
			else
				ResManager.Instance:loadZpk()
				showGetServerList()	
			end
		end
		
		if view then
			-- 显示游戏初始化的文字提示
			view:startInit()
		end
		
		ResManager.Instance:resourceInit(copyCallback)
	else
		-- 检查是否要读zpk资源
		ResManager.Instance:setInitSuccess()
		if not needReadAppResources() then
			ResManager.Instance:loadZpk()
		else
			ResManager.Instance:releaseZpk()
		end
		
		showGetServerList()
	end
end