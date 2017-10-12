--[[
����ͷ����������ӣ�������Щҵ��
]]

ConnectState = {
Idle = 0,
Connecting = 1,
Connected = 2,
Disconnect = 3,	-- �Ѿ��Ͽ���
Timeout = 4,	-- ��ʱ
}

local defalutTimeout = 10	-- ���ȴ��¼�

ConnectionService = ConnectionService or BaseClass()

function ConnectionService:__init()
	self.state = ConnectState.Idle
	self.connectSchId = -1
	self.timeoutSchId = -1
	self.callback = nil	-- ���������¼���֪ͨ�ص�
	self.ip = ""	
	self.port = 0
	
	-- ����tcp���ӷ���
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
	-- ������ʱ�ص�
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

-- ���ӷ�����
function ConnectionService:connect(ip, port)
	if self.state == ConnectState.Connecting or self.state == ConnectState.Connected or not ip or not port then
		return false
	end
	
	self.state = ConnectState.Connecting
	
	self:startTimeoutSchedule()
	
	local onScheduleCallback = function()
		-- ����connect��һ�������̣߳�������תһ��
		self:endConnectSchedule()
		self:doConnect(ip, port)
	end
	
	-- Ϊ�˱�����ܵ�Ƶ������connect, ����100ms���ӳ�
	self.connectSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleCallback, 0.1, false)
end

function ConnectionService:endConnectSchedule()
	if self.connectSchId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.connectSchId)
		self.connectSchId = -1
	end
end

-- ������һ�����ӵķ�����
function ConnectionService:reConnect()
	if self.ip ~= "" and self.port ~= 0 then
		self:connect(self.ip, self.port)
	end
end

function ConnectionService:doConnect(ip, port)
	-- ���״̬
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

-- �Ͽ����ӣ���֪ͨ�����Ļص�
function ConnectionService:disConnect()
	if self.state == ConnectState.Connected or self.state == ConnectState.Connecting then
		self:slientDisConnect()
		self:notifyNetworkEvent(ConnectState.Disconnect)
	end
end

-- �Ͽ����ӣ���֪ͨ�����Ļص�
function ConnectionService:slientDisConnect()
	self:endConnectSchedule()
	self:stopTimeoutSchedule()
	local simulator = SFGameSimulator:sharedGameSimulator()
	simulator:tcpDisConnect()
	self.state = ConnectState.Disconnect
end