require("common.baseclass")

NotifyObj = NotifyObj or BaseClass(BaseObj)

function NotifyObj:__init()
	self.bValid = false
end
--��ʼʱ��
function NotifyObj:setStartTime(startTime)
	if startTime then
		self.beginTime = startTime
	end		
end

function NotifyObj:getStartTime()
	return self.beginTime
end
--����ʱ��
function NotifyObj:setEndTime(endTime)
	if endTime then
		self.endTime = endTime
	end		
end

function NotifyObj:getEndTime()
	return self.endTime
end

--����id
function NotifyObj:setId(id)
	if id then
		self.id = id
	end		
end

function NotifyObj:getId()
	return self.id
end
--��������
function NotifyObj:setType(notifyType)
	if notifyType then
		self.notifyType = notifyType
	end		
end

function NotifyObj:getType()
	return self.notifyType
end

--������
function NotifyObj:setNotifyName(name)
	if name then
		self.name = name
	end		
end

function NotifyObj:getNotifyName()
	return self.name
end

--����汾
function NotifyObj:setNotifyVersion(version)
	if version then
		self.version = version
	end		
end

function NotifyObj:getNotifyVersion()
	return self.version
end

--�������
function NotifyObj:setNotifyTitle(title)
	if title then
		self.title = title
	end		
end

function NotifyObj:getNotifyTitle()
	return self.title
end

--��������
function NotifyObj:setNotifyContent(content)
	if content then
		self.content = content
	end		
end

function NotifyObj:getNotifyContent()
	return self.content
end

--�ж��Ƿ�Ϊ��Ч����
function NotifyObj:setIsValid(bValid)
	self.bValid = bValid
end

function NotifyObj:getIsValid()
	return self.bValid
end