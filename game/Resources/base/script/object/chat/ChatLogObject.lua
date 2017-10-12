--[[
˽�������¼�Ķ���ģ
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
	-- У��data�ĺϷ���
	if not data or type(data) ~= "table" then
		return
	end

	for k,v in pairs(data) do
		if type(k) == "string" and v and self:checkChatEntry(v) then
 			self.chatLog[k] = v
		end
	end
end

--������������Ƿ�Ϸ�
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
���������¼, ���20��
]]
function ChatLogObject:addChatData(contactId, text)
	if text and contactId then
		local chatLog = self:getContact(contactId)		
		local size =  table.getn(chatLog)
		
		-- ɾ��������������ļ�¼
		if size >= maxLogCount then
			for i = 20, size do
				chatLog[i] = nil
			end				
		end
		
		table.insert(chatLog, 1, text)
	end
end

--[[
��ȡһ����ϵ�˵���Ϣ�������¼
]]
function ChatLogObject:getContact(contactId)
	if not self.chatLog[contactId] then
		self.chatLog[contactId] = {}
	end
	
	return self.chatLog[contactId]
end

--��ȡ���е���ϵ��
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
��ϵ�˵���ϸ��Ϣ
]]
function ChatLogObject:addContactInfo(contactId)
	if contactId then
		local chatLog = self:getContact(contactId)
		return true
	else
		return false
	end
end
