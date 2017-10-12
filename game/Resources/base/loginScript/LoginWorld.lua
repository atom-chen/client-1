--[[
��½�߼�����
]]--
require("common.baseclass")
require("actionEvent.LoginActionHandler")
require("actionEvent.HttpHandler")
require("gameevent.LoginUIHandler")
require("object.manager.LoginManager")
require("object.server.ServerMgr")
require("object.tips.TipsManager")
require("object.manager.NotifyManager")
require("object.manager.StatisticsMgr")


LoginWorld = LoginWorld or BaseClass()

function LoginWorld:__init()
	LoginWorld.Instance = self	
	self.tipsManager = TipsManager.New()
	self.loginManager = LoginManager.New()
	self.serverMgr = ServerMgr.New()  --������
	self.notifyManager = NotifyManager.New()
	self.statisticsMgr = StatisticsMgr.New()  --��̨ͳ��

	self.uiHandler = {}
	self.actionHandler = {}
	-- ��ʼ��handler
	self:initUIHandler()
	self:initActionHandler()	
end

function LoginWorld:__delete()

end

function LoginWorld:getLoginManager()
	return self.loginManager
end

function LoginWorld:getTipsManager()
	return self.tipsManager
end
--������
function LoginWorld:getServerMgr()
	return self.serverMgr	
end

--����
function LoginWorld:getNotifyManager()
	return self.notifyManager
end	

function LoginWorld:getStatisticsMgr()
	return self.statisticsMgr
end

function LoginWorld:addUIHandler(nHandler)
	table.insert(self.uiHandler,nHandler)
end

function LoginWorld:initUIHandler()
	self:addUIHandler(LoginUIHandler.New())
end	

function LoginWorld:addActionHandler(nHandler)
	table.insert(self.actionHandler,nHandler)
end

function LoginWorld:initActionHandler()
	self:addActionHandler(LoginActionHandler.New())
	self:addActionHandler(HttpHandler.New())
end

function LoginWorld:getUIHandlerByName(name)
	for k,v in pairs(self.uiHandler) do
		if v.handleName == name then
			return v
		end
	end
end
