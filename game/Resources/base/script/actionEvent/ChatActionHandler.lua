require ("common.ActionEventHandler")
require "object.chat.ChatObject"
require "ui.chat.ChatDef"
require "ui.chat.ChatUtils"
ChatActionHandler = ChatActionHandler or BaseClass(ActionEventHandler)

function ChatActionHandler:__init()
	--接收世界信息
	local g2c_chatWorld_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleChatWorld(reader)
	end
	--公会消息
	local g2c_chatSociety_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleChatSociety(reader)
	end
	--私聊消息
	local g2c_chatPrivate_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleChatPrivate(reader)
	end
	
	--私聊前， 首先要获取对方的Id
	local g2c_getRecvId_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader") 
		self:handleChatRecvId(reader)
	end
	
	--当前消息
	local g2c_chatcurrent_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleChatCurrent(reader)
	end
	--公告消息
	local g2c_announcement_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleAnnouncement(reader)
	end
	--系统消息
	local g2c_marquee_func = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleMarquee(reader)
	end
	--喇叭消息
	local g2c_bugle_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleBugle(reader)
	end
	--玩家是否在线
	local g2c_onLine_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handlePlayersOnline(reader)
	end
	
	--获取伙伴分组列表
	local g2c_getPlayerList_func = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleGetPlayerList(reader)
	end
	--添加玩家信息
	local g2c_addPlayerInfo_func = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleAddPlayerInfo(reader)
	end
	--删除一个伙伴
	local g2c_deletePlayerInfo_func = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleDeletePlayerInfo(reader)
	end

	self:Bind(ActionEvents.G2C_AddOnePlayer, g2c_addPlayerInfo_func)
	self:Bind(ActionEvents.G2C_DeleteOnePlayer, g2c_deletePlayerInfo_func)
	self:Bind(ActionEvents.G2C_FreshOnlineState, g2c_onLine_func)
	self:Bind(ActionEvents.G2C_Chat_Bugle, g2c_bugle_func)
	self:Bind(ActionEvents.G2C_Chat_World, g2c_chatWorld_func)
	self:Bind(ActionEvents.G2C_Chat_Society, g2c_chatSociety_func)
	self:Bind(ActionEvents.G2C_Chat_Private, g2c_chatPrivate_func)
	self:Bind(ActionEvents.G2C_Chat_Get_ReceiverId, g2c_getRecvId_func)  --unused
	self:Bind(ActionEvents.G2C_Chat_Current_Scene, g2c_chatcurrent_func)
	self:Bind(ActionEvents.G2C_Announcement_World, g2c_announcement_func)
	self:Bind(ActionEvents.G2C_System_Prompt, g2c_marquee_func)
	self:Bind(ActionEvents.G2C_GetPlayerList, g2c_getPlayerList_func)
end

function ChatActionHandler:handleBugle(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local senderName = StreamDataAdapter:ReadStr(reader)
	local senderId = StreamDataAdapter:ReadStr(reader)
	local content = StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
	local vipLevel = reader:ReadChar()	
	local time = reader:ReadLLong()
	local formatTime = ChatUtils.Instance:getFormatTime(time)	
	
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.Horn)
	chatObject:setSenderName(senderName)
	chatObject:setSenderId(senderId)
	if ChatUtils.Instance:isContainMark(content) then 
		content = ChatUtils.Instance:getRealContent(content)
		content = ChatUtils.Instance:msgParser(chatObject, content)
	end
	if formatTime then
		content = content .. formatTime
	end	
	chatObject:setContent(content)	
	chatObject:setGender(gender)
	chatObject:setVipLevel(vipLevel)	
	chatMgr:addContent(chatObject)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())
	
	--收到聊天消息在走马灯上显示
	local msg = ChatUtils.Instance:constructRichStringById(chatMgr:getEndIndex(), "false")
	msg = string.sub(msg, 1, -46) --去掉显示时间
	self:showMarqueeInfo(msg, 0)
end

function ChatActionHandler:handleChatWorld(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local senderName = StreamDataAdapter:ReadStr(reader)
	local senderId = StreamDataAdapter:ReadStr(reader)
	local content = StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
	local vipLevel = reader:ReadChar()	
	local time = reader:ReadLLong()
	local formatTime = ChatUtils.Instance:getFormatTime(time)	
		
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.World)
	chatObject:setSenderName(senderName)
	chatObject:setSenderId(senderId)
	if ChatUtils.Instance:isContainMark(content) then 
		content = ChatUtils.Instance:getRealContent(content)
		content = ChatUtils.Instance:msgParser(chatObject, content)
	end
	if formatTime then
		content = content .. formatTime
	end	
	chatObject:setContent(content)	
	chatObject:setGender(gender)
	chatObject:setVipLevel(vipLevel)		
	if chatMgr:addContent(chatObject) then
		GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())
	end		
end

function ChatActionHandler:handleChatSociety(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local ttype = reader:ReadChar()   --1：公会的系统消息， 其他：公会正常消息
	local senderName = StreamDataAdapter:ReadStr(reader)
	local senderId = StreamDataAdapter:ReadStr(reader)
	local content = StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
	local vipLevel = reader:ReadChar()
	local time = reader:ReadLLong()
	local formatTime = ChatUtils.Instance:getFormatTime(time)
		
		
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.Society)
	if ttype == 1 then 	
		content = ChatUtils.Instance:msgParser(chatObject, content)
		if formatTime then
			content = content .. formatTime
		end	
		chatObject:setContent(content)
		chatObject:setType(ChatObjectTypes.Society)
		chatObject:setSubType(ChatObjectTypes.SytSociety)
		
		chatObject:setSocietySystemMsg(true)		
		chatMgr:addContent(chatObject)
		GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())		
	else
		chatObject:setSocietySystemMsg(false)
		chatObject:setSenderName(senderName)
		chatObject:setSenderId(senderId)
		if ChatUtils.Instance:isContainMark(content) then 
			content = ChatUtils.Instance:getRealContent(content)
			content = ChatUtils.Instance:msgParser(chatObject, content)			
		end
		if formatTime then
			content = content .. formatTime
		end	
		chatObject:setContent(content)		
		chatObject:setGender(gender)
		chatObject:setVipLevel(vipLevel)
		
		if chatMgr:addContent(chatObject) then
			GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())
		end
	end
	
	
end

function ChatActionHandler:handleChatRecvId(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local peerId = StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
	chatMgr:setPeerId(peerId, gender)
end

function ChatActionHandler:handleChatPrivate(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local peerName = StreamDataAdapter:ReadStr(reader)
	local peerId = StreamDataAdapter:ReadStr(reader)	
	local proId = reader:ReadChar()
	local receiverName = StreamDataAdapter:ReadStr(reader)
	local receiverId = StreamDataAdapter:ReadStr(reader)
	local recvProId = reader:ReadChar()
	local message =  StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
	local recvGender  = reader:ReadChar()
	local vipLevel = reader:ReadChar()
	local recvVipLevel = reader:ReadChar()
	local time = reader:ReadLLong()	
	local formatTime = ChatUtils.Instance:getFormatTime(time)				
			
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.Private)
	chatObject:setSenderName(peerName)
	chatObject:setSenderId(peerId)
	chatObject:setReceiverName(receiverName)
	chatObject:setReceiverId(receiverId)
	
	if ChatUtils.Instance:isContainMark(message) then 
		message = ChatUtils.Instance:getRealContent(message)
		message = ChatUtils.Instance:msgParser(chatObject, message)
	end
	if formatTime then
		message = message .. formatTime
	end	
	chatObject:setContent(message)	
	chatObject:setGender(gender)
	chatObject:setReceiverGender(recvGender)
	chatObject:setVipLevel(vipLevel)
	chatObject:setReceiverVipLevel(recvVipLevel)	
	
	chatMgr:addContent(chatObject)
	if receiverId ==  G_getHero():getId() then
		local soundMgr = GameWorld.Instance:getSoundMgr()
		soundMgr:playEffect("music/msg.mp3" , false)	
	end
	--保存私聊的聊天记录
	local text = ChatUtils.Instance:constructRichStringById(chatMgr:getEndIndex())
	local opposite = self:whoIsOpposite(peerId, receiverId) 
	if opposite == peerId then 	
		self:updateWhisperData(G_getHero():getId(), peerId, text)			
		GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView, WhisperOperateType.privateChat, peerId)		
	else
		self:updateWhisperData(G_getHero():getId(), receiverId, text)		
		GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView, WhisperOperateType.privateChat, peerId)		
	end				
end

function ChatActionHandler:updateWhisperData(ownId, contractId, text)
	local onlineList = {}
	onlineList[contractId] = true
	G_getHero():getChatMgr():setOnlineList(onlineList)
	self:saveData(ownId, contractId, text)	
end

function ChatActionHandler:saveData(ownId, contractId, text)
	local chatService = G_getHero():getChatMgr():getChatService()
	if nil == chatService:getChatData(ownId, contractId) then  --原来不存在该联系人
		chatService:addContactInfo(ownId, contractId)		
	end
	chatService:saveChatData(ownId, contractId, text)			
end

--谁是跟我聊天的人
function ChatActionHandler:whoIsOpposite(peerId, receiverId)
	local heroId = G_getHero():getId()
	if heroId == peerId then 
		return receiverId
	else
		return peerId
	end
end

function ChatActionHandler:handleChatCurrent(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local peerName = StreamDataAdapter:ReadStr(reader)
	local peerId = StreamDataAdapter:ReadStr(reader)
	local message =  StreamDataAdapter:ReadStr(reader)
	local sceneId = StreamDataAdapter:ReadStr(reader)
	local gender = reader:ReadChar()
		
	local vipLevel = reader:ReadChar()
	local time = reader:ReadLLong()
	local formatTime = ChatUtils.Instance:getFormatTime(time)	
		
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.Current)
	chatObject:setSenderName(peerName)
	chatObject:setSenderId(peerId)
	if ChatUtils.Instance:isContainMark(message) then 
		message = ChatUtils.Instance:getRealContent(message)
		message = ChatUtils.Instance:msgParser(chatObject, message)
	end		
	if formatTime then
		message = message .. formatTime
	end		
	chatObject:setContent(message)	
	chatObject:setSceneId(sceneId)
	chatObject:setGender(gender)
	chatObject:setVipLevel(vipLevel)	
	
	if chatMgr:addContent(chatObject) then
		GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())
	end
end

function ChatActionHandler:handleAnnouncement(reader)
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	local msg = StreamDataAdapter:ReadStr(reader)
		
	local chatObject = ChatObject.New()
	chatObject:setType(ChatObjectTypes.System)
	msg = ChatUtils.Instance:msgParser(chatObject, msg)
	chatObject:setContent(msg)	
	chatMgr:addContent(chatObject)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, chatMgr:getEndIndex())
end

function ChatActionHandler:handleMarquee(reader)
	local tipsMgr = LoginWorld.Instance:getTipsManager()		
	local msg = StreamDataAdapter:ReadStr(reader)
	local position = StreamDataAdapter:ReadChar(reader)
	local specialEffectsType = StreamDataAdapter:ReadChar(reader)	
	if position == 1 then	
		self:showMarqueeInfo(msg, specialEffectsType)
	elseif position == 2 then
		local color = tipsMgr:getFontColorByType(specialEffectsType)
		UIManager.Instance:showSystemTips(msg)		
	elseif position == 3 then
		local color = tipsMgr:getFontColorByType(specialEffectsType)
		UIManager.Instance:showSystemTips(msg)
	end
end	

function ChatActionHandler:handlePlayersOnline(reader)
	local peerId = StreamDataAdapter:ReadStr(reader)
	local online = StreamDataAdapter:ReadChar(reader)
	local chatMgr = G_getHero():getChatMgr()
	chatMgr:resetPeerOnlineState(playerId,onlineState)

	GlobalEventSystem:Fire(GameEvent.EventFreshPlayerOnline,playerId)
end

function ChatActionHandler:handleAddPlayerInfo(reader)
	local onePeer = {}
	onePeer.groupType = StreamDataAdapter:ReadChar(reader)
	onePeer.playerName = StreamDataAdapter:ReadStr(reader)
	onePeer.playerId = StreamDataAdapter:ReadStr(reader)	
	onePeer.gender = StreamDataAdapter:ReadChar(reader)
	onePeer.online = StreamDataAdapter:ReadChar(reader)
	onePeer.proId = StreamDataAdapter:ReadChar(reader)
	onePeer.level = 1

	local chatMgr = G_getHero():getChatMgr()
	if onePeer.groupType == PeerGroupType.BlackList then
		chatMgr:addToBlackList(onePeer.playerId )
	end
	chatMgr:addOnePeer(onePeer.groupType, onePeer)
	chatMgr:sortPeerList(onePeer.groupType)
	GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView, WhisperOperateType.addOnePeer,onePeer.playerId)
end

function ChatActionHandler:handleDeletePlayerInfo(reader)
	local chatMgr = G_getHero():getChatMgr()
	local groupType = StreamDataAdapter:ReadChar(reader)
	local playerId = StreamDataAdapter:ReadStr(reader)
	chatMgr:deleteOnePeer(groupType, playerId)
	if groupType == PeerGroupType.BlackList then
		chatMgr:removeFormBlackList(playerId)
	end
	chatMgr:sortPeerList(groupType)
	GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView,WhisperOperateType.deleteOnePeer)
end

function ChatActionHandler:handleGetPlayerList(reader)
	local chatMgr = G_getHero():getChatMgr()
	local groupType = StreamDataAdapter:ReadChar(reader)
	
	local count	= StreamDataAdapter:ReadChar(reader)
	chatMgr:clearOneGroup(groupType)
	for i = 1, count do
		local onePeer = {}
		onePeer.playerName = StreamDataAdapter:ReadStr(reader)
		onePeer.playerId = StreamDataAdapter:ReadStr(reader)
		onePeer.gender = StreamDataAdapter:ReadChar(reader)
		onePeer.online = StreamDataAdapter:ReadChar(reader)
		onePeer.proId = StreamDataAdapter:ReadChar(reader)
		onePeer.level = 1
		if groupType == PeerGroupType.BlackList then
			chatMgr:addToBlackList(onePeer.playerId)
		end
		chatMgr:addOnePeer(groupType, onePeer)
	end
	chatMgr:sortPeerList(groupType)
	--刷新左边列表
	GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView,WhisperOperateType.getPeerList,groupType)
end

function ChatActionHandler:showMarqueeInfo(msg, specialEffectsType)
	local tipsMgr = LoginWorld.Instance:getTipsManager()	
	local fontColor = tipsMgr:getFontColorByTypeForRichLabel(specialEffectsType)
	tipsMgr:setSystemMarqueeMessage(msg)
	tipsMgr:setSystemMarqueeFontColor(fontColor)
	GlobalEventSystem:Fire(GameEvent.EventShowMarquee)
end