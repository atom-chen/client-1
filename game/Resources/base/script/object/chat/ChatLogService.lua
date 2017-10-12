--[[
����Ͷ�ȡ�����¼
]]

require("common.baseclass")
require("object.chat.ChatLogObject")

local logfileName = "chatLog.lg"

ChatLogService = ChatLogService or BaseClass()

function ChatLogService:__init()
	self.logObjectList = {}
	self.addCount = 0
	
	self:loadFile()
end

function ChatLogService:__delete()
	self:saveToFile()
end

function ChatLogService:clear()
	for k,v in pairs(self.logObjectList) do
		v:DeleteMe()
	end
	
	self.logObjectList = {}
end

--[[��ȡ��ĳλ��ҵ�˽�ļ�¼ 
targetId: �Է���ҵ�id
]]
function ChatLogService:getChatData(ownerId, targetId)
	if self.logObjectList[ownerId] and ownerId and targetId then
		return self.logObjectList[ownerId]:getChatData(targetId)
	else
		return nil
	end
end

--[[����˽�ļ�¼, ��һ����ҵ�˽����ౣ��20��
targetId: 	�Է���ҵ�id
text:		��������
]]
function ChatLogService:saveChatData(ownerId, contactId, text)
	if not ownerId or not contactId or not text then
		return
	end
	
	local needSave = false
	if not self.logObjectList[ownerId] then
		self.logObjectList[ownerId] = ChatLogObject.New(ownerId)
		needSave = true
	end
		
	self.addCount = self.addCount + 1
	if self.addCount >= 3 then
		needSave = true
	end
	
	self.logObjectList[ownerId]:addChatData(contactId, text)
	
	if needSave then
		self:saveToFile()
	end
end

--ɾ��ĳ����ϵ��
function ChatLogService:removeContact(ownerId, contactId)
	if self.logObjectList[ownerId] then
		--self.logObjectList[ownerId]:DeleteMe()
		--self.logObjectList[ownerId] = nil
				
		self.logObjectList[ownerId]:removeChatData(contactId)
		self:saveToFile()
	end
end

--��ȡ���˽�ĵ���ң����50��
function ChatLogService:getChatList(ownerId)
	if self.logObjectList[ownerId] then
		return self.logObjectList[ownerId]:getChatList()
	end
end

--[[
����Ƶ�������������!!!��IO����!!!!
]]
function ChatLogService:saveToFile()
	local jsonData = {}
	for k,v in pairs(self.logObjectList) do
		jsonData[k] = v:getAllData()
	end
	
	local cjson = require "cjson.safe"		
	local chatLog = cjson.encode(jsonData)
	if chatLog then
		local filePath = SFGameHelper:getExtStoragePath() .. "/"..logfileName
		local handler = io.open(filePath, "w")
		if handler then
			handler:write(chatLog)
			handler:close()
		end
	end
end

--[[
���ļ���ȡ�����¼
]]
function ChatLogService:loadFile()
	self:clear()
	
	local filePath = SFGameHelper:getExtStoragePath() .. "/"..logfileName
	local handler = io.open(filePath, "r")
	if handler then
		local json =  handler:read("*all")
		local cjson = require "cjson.safe"	
		local chatData = cjson.decode(json)
		if chatData then
			for k,v in pairs(chatData) do
				local object = ChatLogObject.New(k)
				object:setChatData(v)
				self.logObjectList[k] = object
			end
		end
		
		handler:close()
	end
end

--[[
���һ����ϵ�˵���ϸ��Ϣ
]]
function ChatLogService:addContactInfo(ownerId, contactId)
	local chatObject = self:getContactObject(ownerId)
	if chatObject then
		chatObject:addContactInfo(contactId)
	end
end

function ChatLogService:getContactObject(ownerId)
	if ownerId then
		if not self.logObjectList[ownerId] then
			self.logObjectList[ownerId] = ChatLogObject.New(ownerId)
			self:saveToFile()
		end
		
		return self.logObjectList[ownerId]
	else
		return nil
	end
end