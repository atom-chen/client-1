require "ui.chat.ChatView"
ChatUIHandler = ChatUIHandler or BaseClass(GameEventHandler)

function ChatUIHandler:__init()
	local manager =UIManager.Instance
	self.eventObjTable = {}
	
	local handleClient_Open = function ()
		manager:registerUI("ChatView", ChatView.create)
		manager:showUI("ChatView")
		local manager =UIManager.Instance
		local chatView = manager:getViewByName("ChatView")
		if chatView ~= nil then
			chatView:refreshChatChannel()
		end
	end
	
	local readyWhisper = function ()
		self:handleReadyWhisper()
	end
	
	local updateChatView = function(id)
		self:handleUpdateChatView(id)
	end
	
	--对方Id不存在或不在线
	local peerIdNotExit = function ()
		self:handlePeerIdNotExit()
	end
	
	local eventMoveView = function  ()
		self:handleMoveView()
	end
	
	local updateMainChat = function (id, idd)
		self:handleUpdateMainChatView(id, idd)
	end
	
	local updateIcon = function(index)
		self:handleUpdateIcon(index)
	end
	
	local whisperChat = function (peerName)
		self:handleWhisperChat(peerName)
	end
	
	local showItemInfo = function (itemObject)
		self:handleShowItem(itemObject)
	end
	
	local showEquipItemInfo = function (equipObj)
		self:handleShowEquipItemInfo(equipObj)
	end
	
	local changeChatObject = function (objectType)
		self:handleChangeChatObject(objectType)
	end
	
	local emailSuccess = function ()
		local manager =UIManager.Instance
		local chatView = manager:getViewByName("ChatView")
		if chatView ~= nil then
			chatView:gmMailSuccess()
		end
	end
	
	local updateWhisperView = function(operate, arg)
		local manager =UIManager.Instance
		local chatView = manager:getViewByName("ChatView")
		if chatView ~= nil then	
			if operate == WhisperOperateType.getPeerList then	
				chatView:changeChatChannel(ChatObjectTypes.Private,arg,1)				
			elseif operate == WhisperOperateType.deleteOnePeer then
				chatView:changeChatChannel(ChatObjectTypes.Private)
			elseif operate == WhisperOperateType.addOnePeer then
				local groupType, index = G_getHero():getChatMgr():getGroupTypeAndIndexById(arg)
				chatView:changeChatChannel(ChatObjectTypes.Private,groupType,index)
			elseif operate == WhisperOperateType.privateChat then
				if arg then
					local groupType, index = G_getHero():getChatMgr():getGroupTypeAndIndexById(arg)	
					local whisperView = chatView:getWhisperView()
					if whisperView and whisperView:isVisible() then
						whisperView:setUnReadMsgTips(arg)
					end
					chatView:updatePeerGroupTabs(groupType)	
					chatView:changeChatChannel(ChatObjectTypes.Private,groupType,index)
				end
									
			end
		end
	end
	
	local onHornChange = function (eventType, items)
		for k, item in pairs(items) do
			if "item_horn" == item:getRefId() then
				local chatView = UIManager.Instance:getViewByName("ChatView")
				if chatView then
					local hornNum = G_getBagMgr():getItemNumByRefId("item_horn")
					chatView:setHornNum(hornNum)
				end
				break
			end
		end
	end
	
	local onResultEvent = function(msgId,printCode)
		if msgId == C2G_AddOnePlayer or msgId == C2G_DeleteOnePlayer then
			if GameData and GameData.Code[printCode] then
				UIManager.Instance:showSystemTips(GameData.Code[printCode])
			end			
		end
	end
	
	local freshPlayerOnline = function(playerId)
		self:freshPlayerOnline(playerId)
	end
	
	local resetMessage = function (bReset)
		local view = manager:getViewByName("ChatView")
		if view  and bReset then
			view:resetMessage()
		end
	end
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventResetMessage, resetMessage))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateWhisperView, updateWhisperView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventErrorCode,onResultEvent))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventFreshPlayerOnline,freshPlayerOnline))
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventItemUpdate, onHornChange))   --检测喇叭变化	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventSendGmMailSucc, emailSuccess))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventChangeChatObject, changeChatObject))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowItemEquip, showEquipItemInfo))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventShowItemInfo, showItemInfo))--物品展示
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventWhisperChat, whisperChat))    --给外部调用，用于私聊
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateMainChatView, updateIcon))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateMainChatView, updateMainChat))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventMoveMianView,eventMoveView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateChatView, updateChatView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventPeerIdNotExit, peerIdNotExit))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenChatView,handleClient_Open))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventReadyWhisper, readyWhisper))
end

function ChatUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end

function ChatUIHandler:handleChangeChatObject(objectType)
	local manager =UIManager.Instance
	local chatView = manager:getViewByName("ChatView")
	if chatView ~= nil then
		--chatView:changeChatObject(objectType, true)
	end
end

function ChatUIHandler:handleShowEquipItemInfo(equipObj)
	ChatUtils.Instance:showEquipItemDetails(equipObj)
end

function ChatUIHandler:handleShowItem(itemObject)
	ChatUtils.Instance:showItemDetails(itemObject)
end

function ChatUIHandler:handleUpdateChatView(id)
	local manager =UIManager.Instance
	local chatView = manager:getViewByName("ChatView")
	if chatView ~= nil then
		if chatView:isNeedAddText(id) then 
			local str = ChatUtils.Instance:constructRichStringById(id, "true")  --当前消息
			chatView:addText(str)
		end
	end
end

function ChatUIHandler:handlePeerIdNotExit()
	local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	chatMgr:resetWisper()  --设置标志，不能发送
end

function ChatUIHandler:handleWhisperChat(peerName)
	local manager =UIManager.Instance
	local chatMgr = G_getHero():getChatMgr()
	
	manager:registerUI("ChatView", ChatView.create)
	manager:showUI("ChatView")
	
	local groupType, index = chatMgr:getGroupTypeAndIndexByName(peerName)
	if groupType == nil then
		groupType = PeerGroupType.TemporaryFriend
		chatMgr:requestAddOnePlayer(groupType, peerName)
	end
	local chatView = manager:getViewByName("ChatView")
	if chatView then 
		chatView:changeChatChannel(ChatObjectTypes.Private,groupType)
	end
end

function ChatUIHandler:handleReadyWhisper()
	GlobalEventSystem:Fire(GameEvent.EventChangeChatObject, ChatObjectTypes.Private)  --聊天对象改变
end

function ChatUIHandler:handleMoveView()
	local manager =UIManager.Instance
	local mainView = manager:getMainView()
	if mainView == nil then
		return
	end
	local mainChatView = mainView:getMainChatView()
	if mainChatView then
		if mainChatView:getShowChatState()==true then
			--mainChatView:hideMyself() --换到mainView中
			mainChatView:setShowChatstate(false)
		else
			mainChatView:setShowChatstate(true)
			--mainChatView:showMyself()
		end
	end
end

function ChatUIHandler:handleUpdateMainChatView(id)
	local manager =UIManager.Instance
	local mainView = manager:getMainView()
	if mainView == nil then
		return
	end
	local mainChatView = mainView:getMainChatView()
	if mainChatView then
		local chatContent = mainChatView:getChatContent()
		if type(chatContent) == "table" then
			local preMsg = chatContent.curMsg
			local curMsg = ChatUtils.Instance:constructRichStringById(id, "false")
			chatContent.curMsg = curMsg
			chatContent.preMsg = preMsg
			mainChatView:setChatContent(chatContent)
			mainChatView.chatTable:reloadData()
		end
	end
end

function ChatUIHandler:handleUpdateIcon(index)
	local manager =UIManager.Instance
	local mainView = manager:getMainView()
	if mainView == nil then
		return
	end
	local chatBtn = mainView:getChatBtn()
	
	if chatBtn then
		local chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
		local chatObj = chatMgr:getObjectById(index)
		if chatObj then
			local ttype = chatObj:getType()
			local isOk = ((ttype==ChatObjectTypes.Private) or (ttype==ChatObjectTypes.Society))
			if chatMgr:isChatViewShowing() == false and isOk then
				chatBtn:replaceIcon(ICON_MESSAGE)
			end
		end
	end
end

function ChatUIHandler:freshPlayerOnline(playerId)
	local manager =UIManager.Instance
	local chatView = manager:getViewByName("ChatView")
	if chatView ~= nil then	
		local whisperView = chatView:getWhisperView()
		if whisperView and whisperView:isVisible() then
			local groupType, index = G_getHero():getChatMgr():getGroupTypeAndIndexById(playerId)
			
			-- getGroupTypeAndIndexById的返回值可能为空
			if groupType and index then
				whisperView:updatePeerListCell(index-1)	
				local onePeer = G_getHero():getChatMgr():getOnePeer(groupType, index)
				whisperView:updatePeerInfo(onePeer)
			end
		end
	end
end