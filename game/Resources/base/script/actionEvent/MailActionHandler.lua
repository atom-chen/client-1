require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("object.mail.MailObject")
MailActionHandler = MailActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()

function MailActionHandler:__init()
	local handleNet_G2C_RequestMailList  = function(reader)
		self:handleNet_G2C_RequestMailList(reader)
	end
	self:Bind(ActionEvents.G2C_Mail_List ,handleNet_G2C_RequestMailList)
	
	local handleNet_G2C_Mail_Add  = function(reader)
		self:handleNet_G2C_Mail_Add(reader)
	end
	self:Bind(ActionEvents.G2C_Mail_Add,handleNet_G2C_Mail_Add)	
	
	local handleNet_G2C_Mail_Content = function (reader)
		self:handleNet_G2C_Mail_Content(reader)
	end
	self:Bind(ActionEvents.G2C_Mail_Content, handleNet_G2C_Mail_Content)
	
	local handleNet_G2C_Mail_Pickup_LeftTime = function(reader)
		self:handleNet_G2C_Mail_Pickup_LeftTime(reader)
	end
	self:Bind(ActionEvents.G2C_Mail_Pickup_LeftTime, handleNet_G2C_Mail_Pickup_LeftTime)
end

function MailActionHandler:__delete()
	
end

--邮件列表
function MailActionHandler:handleNet_G2C_RequestMailList(reader)
	local MailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	reader = tolua.cast(reader,"iBinaryReader")

	local count = StreamDataAdapter:ReadInt(reader)
	for i=1,count do
		local mailId = StreamDataAdapter:ReadStr(reader)
		local title = StreamDataAdapter:ReadStr(reader)		
		local isRead = StreamDataAdapter:ReadChar(reader)
		local date = StreamDataAdapter:ReadLLong(reader)
		local mailType = StreamDataAdapter:ReadChar(reader)
		local isHaveReward = StreamDataAdapter:ReadChar(reader)
		if MailMgr:isLegalMailType(mailType) then		
			local mailObj = MailObject.New()
			mailObj:setMailId(mailId)
			mailObj:setTitleContent(title)		
			mailObj:setMailState(isRead)
			mailObj:setMailDate(date)
			mailObj:setMailType(mailType)	
			mailObj:setIshHaveReward(isHaveReward)		
			MailMgr:addMail(mailObj)
		end
		
	end
	local mailUnreadNum = MailMgr:getMailUnreadNum()
	GlobalEventSystem:Fire(GameEvent.EventMailBtnIsShow,mailUnreadNum)
end

--新增邮件
function MailActionHandler:handleNet_G2C_Mail_Add(reader)
	if GameWorld.Instance:getEntityManager():getHero() then
		local MailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
		reader = tolua.cast(reader,"iBinaryReader")
		local mailId = StreamDataAdapter:ReadStr(reader)
		local content = StreamDataAdapter:ReadStr(reader)		
		local isRead = StreamDataAdapter:ReadChar(reader)
		local date = StreamDataAdapter:ReadLLong(reader)
		local mailType = StreamDataAdapter:ReadChar(reader)
		local isHaveReward = StreamDataAdapter:ReadChar(reader)
		if MailMgr:isLegalMailType(mailType) then		
			local mailObj = MailObject.New()
			mailObj:setMailId(mailId)			
			mailObj:setTitleContent(content)			
			mailObj:setMailState(isRead)
			mailObj:setMailDate(date)
			mailObj:setMailType(mailType)
			mailObj:setIshHaveReward(isHaveReward)
			MailMgr:addMail(mailObj)
			GlobalEventSystem:Fire(GameEvent.EventAddMial,mailType)
			local soundMgr = GameWorld.Instance:getSoundMgr()
			soundMgr:playEffect("music/msg.mp3" , false)			
		end		
	end
	
end

function MailActionHandler:handleNet_G2C_Mail_Content(reader)
	local MailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	
	local mailId = StreamDataAdapter:ReadStr(reader)
	local content = StreamDataAdapter:ReadStr(reader)
	local yuanbao = StreamDataAdapter:ReadInt(reader)
	local bindyuanbao = StreamDataAdapter:ReadInt(reader)
	local gold = StreamDataAdapter:ReadInt(reader)
	local reward = StreamDataAdapter:ReadStr(reader)
	
	local mailObj = MailMgr:getMailObjById(mailId)
	if not mailObj then
		return
	end
	
	local itemNum = StreamDataAdapter:ReadInt(reader)
	local itemList = {}
	for i = 1, itemNum do	
		local obj = AuctionItemObject.New()
		obj:setId(StreamDataAdapter:ReadStr(reader))		
		obj:setRefId(StreamDataAdapter:ReadStr(reader))
--		obj:setRemainTime(reader:ReadInt())
--		obj:setAuctionPrice(reader:ReadInt())
		
		local pdCount = StreamDataAdapter:ReadChar(reader)		
		for j = 1, pdCount do
			local pdType = StreamDataAdapter:ReadChar(reader)
			local dataLenght = StreamDataAdapter:ReadShort(reader)
			local pd = getPropertyTable(reader)
			if type(pd) == "table" then
				if (pdType == 1) then 				--总属性字典
					obj:setPT(pd)
					obj:setStaticData(G_getStaticDataByRefId(obj:getRefId()))
				elseif (pdType == 2) then 			--洗练属性字典
					obj:setWashPT(pd)
				else
					CCLuaLog("MailActionHandler:handleNet_G2C_Mail_Content unkown pd. pdType="..pdType)
				end					
			end
		end	
		itemList[i] = obj
	end		
	
	mailObj:setItemList(itemList)
	mailObj:setMailContent(content)
	mailObj:setMailYuanBao(yuanbao)
	mailObj:setMailBindYuanBao(bindyuanbao)
	mailObj:setMailGold(gold)
	mailObj:setMailReward(reward)					
	GlobalEventSystem:Fire(GameEvent.EventOpenMailContentView)
end

function MailActionHandler:handleNet_G2C_Mail_Pickup_LeftTime(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local id = StreamDataAdapter:ReadStr(reader)
	local time = StreamDataAdapter:ReadLLong(reader) --毫秒
	
	local view = UIManager.Instance:getViewByName("MailContentView")
	if view then
		view:showPickupRemainSec(true, id, time/1000)		
	end
end