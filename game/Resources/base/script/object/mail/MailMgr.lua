require("actionEvent.ActionEventDef")
--require ("data.Mail.Mail")
MailMgr = MailMgr or BaseClass()

local const_maxMailCount = 200
--邮件类型
MailType = 
{
	Activity = 0,	--活动
	Notice = 1,		--公告
	GM2Client = 2,	
	Client2GM = 3,
	AuctionNormal = 4, --普通拍卖。
	AuctionCancel = 5, --取消拍卖
	AuctionTimeout = 6, --拍卖超时
	AuctionDelay = 7, 	--拍卖延迟拾取邮件
	Max = 8,
}

function MailMgr:__init()
	self.mailList = {}
	self.maxListSize = const_maxMailCount
	--self.needUpdate = false
end

function MailMgr:__delete()
	self:clear()
end

function MailMgr:isLegalMailType(ttype)
	return (ttype >= MailType.Activity) and (ttype < MailType.Max)
end
	
function MailMgr:clear()
	if self.mailList then
		for _,v in pairs(self.mailList) do
			if v then
				v:DeleteMe()
			end
		end
	self.mailList = {}
	end	
	self.mailSum = nil
	--self.needUpdate = true
end

function MailMgr:requestMailList() --登录时请求邮件列表
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mail_List)
	simulator:sendTcpActionEventInLua(writer)	
end

function MailMgr:requestMailPickup(refId) --拾取邮件奖励
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mail_Pickup)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)	
end
	
function MailMgr:requestMailRead(refId) --已读
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mail_Read)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)	
end
--请求邮件内容
function MailMgr:requestMailContent(mailId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mail_Content)
	StreamDataAdapter:WriteStr(writer ,mailId)
	simulator:sendTcpActionEventInLua(writer)
end
	
function MailMgr:requestPickupRemainSec(mailId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Mail_Pickup_LeftTime)
	writer:WriteString(mailId)
	simulator:sendTcpActionEventInLua(writer)	
end

--往列表加入邮件对象
function MailMgr:addMail(mailObj)
	for i,v in pairs(self.mailList) do
		if v:getMailId() == mailObj:getMailId() then
			if self.mailList[i] then
				self.mailList[i]:DeleteMe()
			end
			self.mailList[i] = mailObj			
			return
		end
	end		
		
	table.insert(self.mailList,1,mailObj)		

	local size = table.size(self.mailList)
	if size > self.maxListSize then
		for i = self.maxListSize + 1, size do
			self.mailList[i]:DeleteMe()
			self.mailList[i] = nil
		end
	end		
end

--得到邮件列表
function MailMgr:getMailList()
	self:sortMailList(self.mailList)
	return self.mailList
end

--按邮件类型得到邮件列表
function MailMgr:getMailListByType(mailType)	
	local mailListByType = {}
	for i,v in pairs(self.mailList) do
		if v:getMailType() == mailType then
		    table.insert(mailListByType,1,self.mailList[i])						
		end
	end	
	mailListByType = self:sortMailList(mailListByType)
	if table.size(mailListByType) == 0 then
		return nil
	end
	return mailListByType
end

--获取活动邮件总数
function MailMgr:getActivityMailNum()
	local activityMailList = self:getMailListByType(0)
	if activityMailList then
		return table.size(activityMailList)
	end
	return 0
end

--未读活动邮件数量
function MailMgr:getActivityMailUnreadNum()
	local activityMailList = self:getMailListByType(0)
	local MailUnreadNum = 0
	if activityMailList then
		for i,v in pairs(activityMailList) do
			if v:getMailState() == 0 then
				MailUnreadNum = MailUnreadNum+1
			end
		end	
	end
	return MailUnreadNum
end	

--获取GM邮件总数
function MailMgr:getGMMailNum()
	local activityMailList = self:getMailListByType(2)
	if activityMailList then
		return table.size(activityMailList)
	end
	return 0
end

--未读GM邮件数量
function MailMgr:getGMMailUnreadNum()
	local noticeMailList = self:getMailListByType(2)
	local MailUnreadNum = 0
	if noticeMailList then
		for i,v in pairs(noticeMailList) do
			if v:getMailState() == 0 then
				MailUnreadNum = MailUnreadNum+1
			end
		end	
	end
	return MailUnreadNum
end

--获取公告邮件总数
function MailMgr:getNoticeMailNum()
	local noticeMailList = self:getMailListByType(1)
	if noticeMailList then
		return table.size(noticeMailList)
	end
	return 0
end

--未读公告邮件数量
function MailMgr:getNoticeMailUnreadNum()
	local noticeMailList = self:getMailListByType(1)
	local MailUnreadNum = 0
	if noticeMailList then
		for i,v in pairs(noticeMailList) do
			if v:getMailState() == 0 then
				MailUnreadNum = MailUnreadNum+1
			end
		end	
	end
	return MailUnreadNum
end

--获取邮件
function MailMgr:getMailObjById(mailId)
	if mailId == nil then
		return 
	end
	for i,v in pairs(self.mailList) do
		if v:getMailId() == mailId then
			return self.mailList[i]
		end
	end	
end	

--邮件列表排序
function MailMgr:sortMailList(list)
	function sortMail(a, b)
		if a:getMailState() < b:getMailState() then		--是否已读
			return true
		elseif a:getMailState() == b:getMailState() then
			if a:getMailState() == 1 then		--已读按时间排序
				return a:getMailOrderNum() > b:getMailOrderNum()				
			elseif a:isHaveReward() > b:isHaveReward()	then		--是否有道具
				return true			
			elseif a:isHaveReward() == b:isHaveReward() then--时间排序
				return a:getMailOrderNum() > b:getMailOrderNum() 				
			else
				return false
			end	
		else
			return false
		end
	end	
	
	table.sort(list, sortMail)
	return list
end	

--总数量
function MailMgr:getMailSum()
	self.mailSum = table.size(self.mailList)
	return self.mailSum
end	

--未读数量
function MailMgr:getMailUnreadNum()
	self.MailUnreadNum = 0
	for i,v in pairs(self.mailList) do
		if v:getMailState() == 0 then		
			self.MailUnreadNum = self.MailUnreadNum+1
		end
	end	
	return self.MailUnreadNum
end	

--[[function MailMgr:setNeedUpdate(bUpdate)
	self.needUpdate = bUpdate
end

function MailMgr:getNeedUpdate()
	return self.needUpdate
end--]]