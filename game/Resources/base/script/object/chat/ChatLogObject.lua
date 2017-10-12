--[[
私聊聊天记录的对象建模
]]

require("common.baseclass")
ChatLogObject = ChatLogObject or BaseClass()

local maxLogCount = 20

function ChatLogObject:create(ownerId)
	if ownerId and targetId then
		return ChatLogObject.New(ownerId)
	end
end

function ChatLogObject:__init(ownerId)
	self.ownerId = ownerId
	
	self.chatLog = {}
end

function ChatLogObject:__delete()
	self.chatLog = nil
end

function ChatLogObject:setChatData(data)
	-- 校验data的合法性
	if not data or type(data) ~= "table" then
		return
	end

	for k,v in pairs(data) do
		if type(k) == "string" and v and self:checkChatEntry(v) then
 			self.chatLog[k] = v
		end
	end
end

--检查聊天数据是否合法
function ChatLogObject:checkChatEntry(entry)
	if not entry or type(entry) ~= "table" then
		return false
	end
	
	local ret = true
	for k,v in pairs(entry) do
		if not v or type(v) ~= "string" then
			ret = false
			break
		end
	end
	
	return ret
end

--[[
保存聊天记录, 最多20条
]]
function ChatLogObject:addChatData(contactId, text)
	if text and contactId then
		local chatLog = self:getContact(contactId)		
		local size =  table.getn(chatLog)
		
		-- 删除超过最大数量的记录
		if size >= maxLogCount then
			for i = 20, size do
				chatLog[i] = nil
			end				
		end
		
		table.insert(chatLog, 1, text)
	end
end

--[[
获取一个联系人的信息和聊天记录
]]
function ChatLogObject:getContact(contactId)
	if not self.chatLog[contactId] then
		self.chatLog[contactId] = {}
	end
	
	return self.chatLog[contactId]
end

--获取所有的联系人
function ChatLogObject:getChatList()
	local playerList = {}
	
	for k,v in pairs(self.chatLog) do
		table.insert(playerList, k)
	end
	
	return playerList
end

function ChatLogObject:getAllData()
	return self.chatLog
end

function ChatLogObject:getChatData(contactId)
	return self.chatLog[contactId]
end

function ChatLogObject:removeChatData(contactId)
	if self.chatLog[contactId] then 
		self.chatLog[contactId] = nil
	end
end

function ChatLogObject:getOwnerId()
	return self.ownerId
end

--[[
联系人的详细信息
]]
function ChatLogObject:addContactInfo(contactId)
	if contactId then
		local chatLog = self:getContact(contactId)
		return true
	else
		return false
	end
end
