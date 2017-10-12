require("common.baseclass")
require ("common.BaseObj")

ServerObject = ServerObject or BaseClass(BaseObj)

function ServerObject:__init()
	
end	

-------���������ֵ䣬��ʱ����д��-----
function ServerObject:getServerName()
	return self.table["name"]
end

function ServerObject:getServerIp()
	return self.table["ip"]
end

function ServerObject:getServerState()
	return self.table["state"]
end

function ServerObject:getServerPort()
	return self.table["port"]
end

function ServerObject:getServerOrder()
	return self.table["orders"]
end

function ServerObject:getServerBNewServer()
	local sign = self.table["sign"]
	return (sign==2)
end

function ServerObject:getServerRecommend()
	return self.table["isRecommend"]
end

function ServerObject:getServerId()
	return self.table["id"]
end

-- android�汾��
function ServerObject:getAndroidVer()
	if self.table["clientVer"] then
		return self.table["clientVer"]
	else
		return "0.0.0.0"
	end
end

function ServerObject:getAndroidMiniVer()
	if self.table["clientMiniVer"] then
		return self.table["clientMiniVer"]
	else
		return "0.0.0.0"
	end
end

-- ios�İ汾��
function ServerObject:getIosVer()
	if self.table["iosVer"] then
		return self.table["iosVer"]
	else
		return "0.0.0.0"
	end	
end

function ServerObject:getIosMiniVer()
	if self.table["iosMiniVer"] then
		return self.table["iosMiniVer"]
	else
		return "0.0.0.0"
	end
end

-- ����ʱ��
function ServerObject:getStartTime()
	return self.table["startTime"]
end

function ServerObject:getServicesUrl()
	return self.table["servicesUrl"]
end

-- ��Դ�汾
function ServerObject:getCurrentResourceVer()
	return self.table["currentResourceVer"]
end

-- ��Դ���汾
function ServerObject:getCurrentMainVer()
	return self.table["currentMainVer"]
end

-- android�Ŀͻ���������ַ
function ServerObject:getClientUpdateUrl()
	return self.table["clientUpdateUrl"]
end

-- ios�Ŀͻ���������ַ
function ServerObject:getIosClentUpdateUrl()
	return self.table["iosUpdateUrl"]
end

function ServerObject:getShowOrders()
	return self.table["showOrders"]
end
