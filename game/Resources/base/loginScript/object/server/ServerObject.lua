require("common.baseclass")
require ("common.BaseObj")

ServerObject = ServerObject or BaseClass(BaseObj)

function ServerObject:__init()
	
end	

-------不走属性字典，暂时这样写着-----
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

-- android版本号
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

-- ios的版本号
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

-- 开服时间
function ServerObject:getStartTime()
	return self.table["startTime"]
end

function ServerObject:getServicesUrl()
	return self.table["servicesUrl"]
end

-- 资源版本
function ServerObject:getCurrentResourceVer()
	return self.table["currentResourceVer"]
end

-- 资源主版本
function ServerObject:getCurrentMainVer()
	return self.table["currentMainVer"]
end

-- android的客户端升级地址
function ServerObject:getClientUpdateUrl()
	return self.table["clientUpdateUrl"]
end

-- ios的客户端升级地址
function ServerObject:getIosClentUpdateUrl()
	return self.table["iosUpdateUrl"]
end

function ServerObject:getShowOrders()
	return self.table["showOrders"]
end
