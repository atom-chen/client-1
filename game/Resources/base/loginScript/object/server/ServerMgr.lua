require("common.baseclass")
require("object.server.ServerObject")


ServerMgr = ServerMgr or BaseClass()

local defIp = "10.21.210.163"
local defPort = "5555"

function ServerMgr:__init()
	self.serverList = {}	
	self.recommendServerList = {}  --推荐的服务器列表
	
	self.resourceCheckUrl = ""		-- 资源更新url
	self.rechargeChannelUrl = ""	-- 充值通道url
	self.gameNoticeUrl = ""			-- 公告url
	self.gameNoticeListUrl = ""		-- 公告列表url
	self.servicesUrl = ""
end

-- 校验数据的合法性
function ServerMgr:checkData(jsonData)
	return jsonData and type(jsonData) == "table" and jsonData.serversList and type(jsonData.serversList) == "table"
end

function ServerMgr:parseData(jsonData)
	if not self:checkData(jsonData) then
		return false
	end
	
	self:setServerList(jsonData.serversList)
	self:setServerUrl(jsonData)
	
	return true
end

-- 是否获取到了服务器列表
function ServerMgr:isEmpty()
	return _G.next(self.serverList) == nil
end

function ServerMgr:getServerList()
	return self.serverList
end

function ServerMgr:clear()
	if self.serverList then
		for k,v in pairs(self.serverList) do
			v:DeleteMe()
		end
	end
	
	if self.recommendServerList then
		for k,v in pairs(self.recommendServerList) do
			v:DeleteMe()
		end
	end
	
	self.serverList = {}	
	self.recommendServerList = {}
end

function ServerMgr:getResourceCheckUrl()
	return self.resourceCheckUrl
end

function ServerMgr:getRechargeChannelUrl()
	return self.rechargeChannelUrl
end

function ServerMgr:getNoticeUrl()
	return self.gameNoticeUrl
end

function ServerMgr:getNoticeListUrl()
	return self.gameNoticeListUrl
end

function ServerMgr:getServicesUrl()
	return self.servicesUrl
end

-- 解析服务器的信息
function ServerMgr:setServerList(serverList)
	if not serverList then
		return
	end
	
	-- 先排序
	serverList = self:sortServerList(serverList)
	for k, v in pairs(serverList) do 
		local server = ServerObject.New()
		server:setPT(v)	
		if server:getServerRecommend()==1 then 		
			table.insert(self.recommendServerList, server)			
		end
		table.insert(self.serverList, server)
	end
end

-- 解析分区对应的各种url
function ServerMgr:setServerUrl(urlList)
	if urlList then
		self.resourceCheckUrl = urlList["resourceCheckUrl"]
		self.rechargeChannelUrl = urlList["rechargeChannelUrl"]
		self.gameNoticeUrl = urlList["gameNoticeUrl"]
		self.gameNoticeListUrl = urlList["gameNoticeListUrl"]
		self.servicesUrl = urlList["servicesUrl"]		
	end
end

function ServerMgr:getLastTimeLgoinServer()
	--首先读取上次登陆的server
	local reader = CCUserDefault:sharedUserDefault()
	local ip = reader:getStringForKey(Config.UserDefaultKey.Server_LastTimeServerIp)
	local port = reader:getStringForKey(Config.UserDefaultKey.Server_LastTimeServerPort)	
	if ip ~= "" and port ~= "" then
		return self:getServer(ip, port)
	end		
	--没有最近登录从推荐服随机返回
	local server = self:getRecommendLoginServer()
	if server then
		return server
	end
	--最后返回一个可用的服务器
	local server = self:getCanUseServer()	

	return server
end

--返回一个可用的服务器
function ServerMgr:getCanUseServer()
	for k, v in pairs(self.serverList) do 
		local state = v:getServerState()
		if state >= 2 then 
			return v
		end
	end
end

function ServerMgr:getRecommendServerList()
	return self.recommendServerList
end

function ServerMgr:getRecommendLoginServer()
	for k, v in pairs(self.recommendServerList) do 
		return v   --从推荐列表  随便返回一个
	end
end

function ServerMgr:getServer(ip, port)
	for k, v in pairs(self.serverList) do 
		local tmpIp = v:getServerIp()
		local tmpPort = tostring(v:getServerPort())
		if ip==tmpIp and port==tmpPort then 		
			return v
		end
	end		
	return self.serverList[1]   --找不到就返回最新的
end

--保存上次登陆的服务器
function ServerMgr:saveLastTimeServer(ip, port)
	local writer = CCUserDefault:sharedUserDefault()
	local lastTimeIp = writer:getStringForKey(Config.UserDefaultKey.Server_LastTimeServerIp)
	local lastTimePort = writer:getStringForKey(Config.UserDefaultKey.Server_LastTimeServerPort)
	if lastTimeIp ~= ip or lastTimePort ~= port then
		writer:setStringForKey(Config.UserDefaultKey.Server_LastTimeServerIp, ip)
		writer:setStringForKey(Config.UserDefaultKey.Server_LastTimeServerPort, port)		
		writer:flush()
	end
	if UIManager.Instance:isShowing("AllServerView") then 
		GlobalEventSystem:Fire(GameEvent.EventUpdateLastTimeServer)
	end
end

function ServerMgr:getServerByShowOrder(order)
	for k, v in pairs(self.serverList) do 
		if v:getShowOrders() == order then 
			return v
		end
	end
end	

function ServerMgr:getSelectServer()
	return self.selectServer
end

function ServerMgr:setSelectServer(ip, port)
	for k, v in pairs(self.serverList) do 
		if v:getServerIp() == ip and v:getServerPort() == port then 
			self.selectServer = v
			break
		end
	end
end

function ServerMgr:sortServerList(servers)
	local order = {}
	local serverCnt = table.size(servers)
	
	--根据排序规则， 对服务器列表排序
	local sortByStartTime = function (a, b)
		if a.openTime and b.openTime then
			if a.openTime > b.openTime then
				return true
			elseif a.openTime == b.openTime then
				return a.id < b.id
			end
		else
			return a.id>b.id
		end
	end
	table.sort(servers, sortByStartTime)
	
	--添加显示的顺序
	for index, serverTable in pairs(servers) do
		serverTable.showOrders = serverCnt
		serverCnt = serverCnt - 1
	end
	return servers	
end

function ServerMgr:login(server)
	if server then 
		local serverIp = server:getServerIp()
		local serverPort = server:getServerPort()
		local serverId = server:getServerId()			
		LoginWorld.Instance:getLoginManager():connectServer(serverIp, serverPort, serverId)						
	end		
end

function ServerMgr:handleServerLogin(server)
	if server then		
		LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.StartEnterGame)
		local serverId = server:getServerId()	
		local notifyMgr = LoginWorld.Instance:getNotifyManager()
		notifyMgr:requireServerNotifyUrlList(serverId)		
		local state = server:getServerState()	
		
		-- 白名单机制, 方便服务器更新提前进入
		local keyFilePath = SFGameHelper:getExtStoragePath() .. "/newBeeTes.key"
		local ignoreState = CCFileUtils:sharedFileUtils():isFileExist(keyFilePath)
		
		if not ignoreState and ( state==-1 or state==0 or state==1) then	--服务器处于维护状态										
			--UIManager.Instance:showSystemTips(Config.LoginWords[8505]..server:getStartTime())
			notifyMgr:setNeedShowMaintainView(true)
		else
			local serverMgr = LoginWorld.Instance:getServerMgr()
			local loginMgr = LoginWorld.Instance:getLoginManager()			
			self:login(server)
			notifyMgr:setNeedShowMaintainView(false)
		end
	end		
end