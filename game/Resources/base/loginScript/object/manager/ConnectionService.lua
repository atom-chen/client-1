--[[
处理和服务器的连接，断线这些业务
]]

ConnectState = {
Idle = 0,
Connecting = 1,
Connected = 2,
Disconnect = 3,	-- 已经断开了
Timeout = 4,	-- 超时
}

local defalutTimeout = 10	-- 最大等待事件

ConnectionService = ConnectionService or BaseClass()

function ConnectionService:__init()
	self.state = ConnectState.Idle
	self.connectSchId = -1
	self.timeoutSchId = -1
	self.callback = nil	-- 网络连接事件的通知回调
	self.ip = ""	
	self.port = 0
	
	-- 激活tcp连接服务
	local simulator = SFGameSimulator:sharedGameSimulator()
	simulator:enableTcpCommService()
end

function ConnectionService:__delete()
	
end

function ConnectionService:setCallback(callback)
	self.callback = callback
end

function ConnectionService:getState()
	return self.state
end

function ConnectionService:notifyNetworkEvent(code)
	if self.callback and code ~= nil and type(code) == "number" then
		self.callback(code)
	end
end

function ConnectionService:startTimeoutSchedule()
	-- 启动超时回调
	if self.timeoutSchId ~= -1 then
		return
	end
	
	local timeoutCallback = function ()
		self:stopTimeoutSchedule()
		self:slientDisConnect()
		self:notifyNetworkEvent(ConnectState.Timeout)
	end
	self.timeoutSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeoutCallback, defalutTimeout, false)
end

function ConnectionService:stopTimeoutSchedule()
	if self.timeoutSchId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeoutSchId)
		self.timeoutSchId = -1
	end
end

-- 连接服务器
function ConnectionService:connect(ip, port)
	if self.state == ConnectState.Connecting or self.state == ConnectState.Connected or not ip or not port then
		return false
	end
	
	self.state = ConnectState.Connecting
	
	self:startTimeoutSchedule()
	
	local onScheduleCallback = function()
		-- 调用connect不一定在主线程，这里中转一下
		self:endConnectSchedule()
		self:doConnect(ip, port)
	end
	
	-- 为了避免可能的频繁调用connect, 给个100ms的延迟
	self.connectSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleCallback, 0.1, false)
end

function ConnectionService:endConnectSchedule()
	if self.connectSchId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.connectSchId)
		self.connectSchId = -1
	end
end

-- 重连上一次连接的服务器
function ConnectionService:reConnect()
	if self.ip ~= "" and self.port ~= 0 then
		self:connect(self.ip, self.port)
	end
end

function ConnectionService:doConnect(ip, port)
	-- 检查状态
	if self.state ~= ConnectState.Connecting then
		return
	end
	
	self.ip = ip
	self.port = port
	
	local function tcpHandler(eventCode)
		self:stopTimeoutSchedule()
		if eventCode == 0 and self.state ~= ConnectState.Connected then
			self.state = ConnectState.Connected
			self:notifyNetworkEvent(ConnectState.Connected)
		elseif eventCode ~= 0 and self.state ~= ConnectState.Disconnect then
			self.state = ConnectState.Disconnect
			self:notifyNetworkEvent(ConnectState.Disconnect)
		end
	end
	
	local simulator = SFGameSimulator:sharedGameSimulator()
	simulator:tcpConnect(ip, port, tcpHandler)
end

-- 断开连接，会通知监听的回调
function ConnectionService:disConnect()
	if self.state == ConnectState.Connected or self.state == ConnectState.Connecting then
		self:slientDisConnect()
		self:notifyNetworkEvent(ConnectState.Disconnect)
	end
end

-- 断开连接，不通知监听的回调
function ConnectionService:slientDisConnect()
	self:endConnectSchedule()
	self:stopTimeoutSchedule()
	local simulator = SFGameSimulator:sharedGameSimulator()
	simulator:tcpDisConnect()
	self.state = ConnectState.Disconnect
end