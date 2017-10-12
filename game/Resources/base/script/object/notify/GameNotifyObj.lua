require("common.baseclass")

NotifyObj = NotifyObj or BaseClass(BaseObj)

function NotifyObj:__init()
	self.bValid = false
end
--开始时间
function NotifyObj:setStartTime(startTime)
	if startTime then
		self.beginTime = startTime
	end		
end

function NotifyObj:getStartTime()
	return self.beginTime
end
--结束时间
function NotifyObj:setEndTime(endTime)
	if endTime then
		self.endTime = endTime
	end		
end

function NotifyObj:getEndTime()
	return self.endTime
end

--公告id
function NotifyObj:setId(id)
	if id then
		self.id = id
	end		
end

function NotifyObj:getId()
	return self.id
end
--公告类型
function NotifyObj:setType(notifyType)
	if notifyType then
		self.notifyType = notifyType
	end		
end

function NotifyObj:getType()
	return self.notifyType
end

--公告名
function NotifyObj:setNotifyName(name)
	if name then
		self.name = name
	end		
end

function NotifyObj:getNotifyName()
	return self.name
end

--公告版本
function NotifyObj:setNotifyVersion(version)
	if version then
		self.version = version
	end		
end

function NotifyObj:getNotifyVersion()
	return self.version
end

--公告标题
function NotifyObj:setNotifyTitle(title)
	if title then
		self.title = title
	end		
end

function NotifyObj:getNotifyTitle()
	return self.title
end

--公告内容
function NotifyObj:setNotifyContent(content)
	if content then
		self.content = content
	end		
end

function NotifyObj:getNotifyContent()
	return self.content
end

--判断是否为有效公告
function NotifyObj:setIsValid(bValid)
	self.bValid = bValid
end

function NotifyObj:getIsValid()
	return self.bValid
end