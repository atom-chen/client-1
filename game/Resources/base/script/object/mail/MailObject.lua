require("common.BaseObj")

MailObject = MailObject or BaseClass(BaseObj)

function MailObject:__init()	
	self.MailBindYuanBao = 0
	self.MailGold = 0
	self.MailYuanBao = 0
	self.itemList = {}
end

function MailObject:__delete()

end

--邮件id
function MailObject:setMailId(id)
	if id then
		self.MailId = id
	end		
end

function MailObject:getMailId()
	return self.MailId
end

--邮件类型（0--活动，1--公告）
function MailObject:setMailType(MailType)
	if MailType then
		self.MailType = MailType
	end		
end

function MailObject:getMailType()
	return self.MailType
end

--邮件状态(0--未读，1--已读)
function MailObject:setMailState(MailState)
	if MailState then
		self.MailState = MailState
	end		
end

function MailObject:getMailState()
	return self.MailState
end	

--标题内容
function MailObject:setTitleContent(content)
	--取正文的前十个文字
	if content then
		self.TitleContent = string.sub(content,1,30)
	end		
end

function MailObject:getTitleContent()
	return self.TitleContent
end	

--正文
function MailObject:setMailContent(Content)
	if Content then
		self.MailContent = Content
	end		
end

function MailObject:getMailContent()
	return self.MailContent
end	

--日期
function MailObject:setMailDate(MailDate)
	if MailDate > 0 then	
		self.orderNum = MailDate		
		MailDate = math.floor(MailDate/1000)
		local year = os.date("%Y",MailDate)
		local month = os.date("%m",MailDate) 
		local day = os.date("%d",MailDate)
		if year and month and day then
			self.MailDate = year .. "-" .. month .. "-" .. day 
		end
	end
end

function MailObject:getMailDate()
	return self.MailDate
end	

--时间
function MailObject:setMailOrderNum(orderNum)
	if orderNum > 0 then
		self.orderNum = orderNum
	end
end

function MailObject:getMailOrderNum()
	return self.orderNum
end

--附件
function MailObject:setMailReward(Reward)
	if Reward == "" or Reward == nil then
		return nil
	end
	--json转数据
	local cjson = require "cjson.safe"		
	local data,erroMsg = cjson.decode(Reward)	
	if data then
		self.MailReward = data
	else
		UIManager.Instance:showSystemTips("Error:  " .. erroMsg)
	end
end

function MailObject:getMailReward()
	return self.MailReward
end	

--元宝
function MailObject:setMailYuanBao(MailYuanBao)
	if MailYuanBao then
		self.MailYuanBao = MailYuanBao	
	end				
end

function MailObject:getMailYuanBao()
	return self.MailYuanBao
end	

--绑定元宝
function MailObject:setMailBindYuanBao(MailBindYuanBao)
	if MailBindYuanBao then
		self.MailBindYuanBao = MailBindYuanBao		
	end				
end

function MailObject:getMailBindYuanBao()
	return self.MailBindYuanBao
end	

--金币
function MailObject:setMailGold(MailGold)
	if MailGold then
		self.MailGold = MailGold
	end		
end

function MailObject:getMailGold()
	return self.MailGold
end	

--是否有道具
function MailObject:setIshHaveReward(bHaveReward)
	self.bIsHaveReward = bHaveReward
end

function MailObject:isHaveReward()
	return self.bIsHaveReward
end

function MailObject:setItemList(list)
	if type(list) == "table" then
		self.itemList = list
	end		
end

function MailObject:getItemList()
	return self.itemList
end