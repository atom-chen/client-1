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
	--ȫ��������
	local eventSelectAllServer = function ()
		manager:showUI("AllServerView")
	end
	--�����˺�����
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
			-- �Ǻ�̨���ز�Ҫ��ʾ�������
			manager:showUI("ResourcesUpdateView")
			local view = manager:getViewByName("ResourcesUpdateView")
			if view then
				-- ��ȡ�����б�
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
		-- ������Ϸ, ע�����Լ��Ķ���EventErrorCode�ļ���
		if self.eventErrorCode then
			self:UnBind(self.eventErrorCode)
			self.eventErrorCode = nil
		end
	end
	
	local onHeroLeaveGame = function ()
		-- �˳���Ϸ������ע��ע�����Լ��Ķ���EventErrorCode�ļ���
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
			-- �����ص�����dialog
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
	--  ��¼��ǰ������������ʾ��ص���ʾ��Ϣ
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
	-- ������ڿ�����Դ��ʲô������, �ȿ�����ɺ���ȥ�ı�UI
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
			
		-- ����������б��Ѿ�����, ֱ����ʾ�������б����
		local errCode = LoginWorld.Instance:getLoginManager():getServerListErrCode()
		if errCode ~= ServerListCode.Success then
			-- ����Ƿ��ȡ�������б��Ƿ��д��󷵻�
			if errCode == ServerListCode.Waiting then
				-- ��������
				if view then
					-- ��ʾ��ȡ�������б��������ʾ
					view:startGetServerList()
				end
			else
				self:handle_getServerList(view, errCode)
			end
		else
			-- �Ѿ���ȡ���˷������б�, ȥ����sdk��¼
			self:handle_getServerList(view, errCode)
		end
	end
	
	-- ����Ƿ���Ҫ������Դ
	if ResManager.Instance:needCopy() then
		local copyCallback = function (errCode, param1, param2)
			CCLuaLog("copyCallback:"..errCode)
			if errCode == CopyError.NoSpace then
				-- �ռ䲻��
				local function msgBoxCallback()
					-- �˳�APP
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
			-- ��ʾ��Ϸ��ʼ����������ʾ
			view:startInit()
		end
		
		ResManager.Instance:resourceInit(copyCallback)
	else
		-- ����Ƿ�Ҫ��zpk��Դ
		ResManager.Instance:setInitSuccess()
		if not needReadAppResources() then
			ResManager.Instance:loadZpk()
		else
			ResManager.Instance:releaseZpk()
		end
		
		showGetServerList()
	end
end