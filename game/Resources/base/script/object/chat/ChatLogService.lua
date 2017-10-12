--[[
保存和读取聊天记录
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

--[[获取对某位玩家的私聊记录 
targetId: 对方玩家的id
]]
function ChatLogService:getChatData(ownerId, targetId)
	if self.logObjectList[ownerId] and ownerId and targetId then
		return self.logObjectList[ownerId]:getChatData(targetId)
	else
		return nil
	end
end

--[[保存私聊记录, 和一个玩家的私聊最多保存20条
targetId: 	对方玩家的id
text:		聊天内容
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

--删除某个联系人
function ChatLogService:removeContact(ownerId, contactId)
	if self.logObjectList[ownerId] then
		--self.logObjectList[ownerId]:DeleteMe()
		--self.logObjectList[ownerId] = nil
				
		self.logObjectList[ownerId]:removeChatData(contactId)
		self:saveToFile()
	end
end

--获取最近私聊的玩家，最多50个
function ChatLogService:getChatList(ownerId)
	if self.logObjectList[ownerId] then
		return self.logObjectList[ownerId]:getChatList()
	end
end

--[[
不能频繁调用这个方法!!!有IO操作!!!!
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
从文件读取聊天记录
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
添加一个联系人的详细信息
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