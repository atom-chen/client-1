require "ui.chat.ChatUtils"
require "ui.chat.ChatDef"
require "object.chat.ChatLogService"
require("config.MainMenuConfig")
require("ui.utils.MainMenuOpenCondition")
ChatMgr = ChatMgr or BaseClass()

local maxChatItems = 50 --最大聊天记录数

local WhisperChatInfo = {
peerName = "",
peerId = "",
gender = 1,
ready = false,
}

function ChatMgr:__init()
	self.peerList = {}
	self.curGroupType = 1
	self.curSelectPeer = 1

	ChatUtils.New(self)
	self.content = {}
	self.startIndex = 1
	self.endIndex = 0
	self.bFull = false -- 队列是否满了
	self.ready = false
	self.chatService = nil
	self.onlineList = {}  --玩家是否在线
	self.blackList = {}
	--物品展示
	local setItem = function (itemObj)
		self:handleSetItem(itemObj)
	end
	
	local requestBlackList = function ()
		self:requestPlayerList(PeerGroupType.BlackList)
	end
	self.showItemEvent = GlobalEventSystem:Bind(GameEvent.EventShowItem, setItem)
	self.requestBlackList = GlobalEventSystem:Bind(GameEvent.EventHeroEnterGame,requestBlackList)
end

function ChatMgr:__delete()
	if self.content then
		for _, v in pairs(self.content) do
			v:DeleteMe()
		end
		self.content = nil
	end
	self.blackList = {}
	if self.showItemEvent then
		GlobalEventSystem:UnBind(self.showItemEvent)
		self.showItemEvent = nil
	end
end

function ChatMgr:clear()
	if self.content then
		for _, v in pairs(self.content) do
			v:DeleteMe()
		end
		self.content = {}
	end
	self.startIndex = 1
	self.endIndex = 0
	self.bFull = false
	self.ready = false
	
	self.peerList = {}
	self.blackList = {}
	self.curGroupType = 1
	self.curSelectPeer = 1
end

function ChatMgr:getChatService()
	if self.chatService==nil then
		self.chatService = ChatLogService.New()
	end
	return self.chatService
end

--发送gm邮件
function ChatMgr:requestGmMail(content)
	if content then	
		local url = LoginWorld.Instance:getServerMgr():getServicesUrl()
		if url then		
			url = url .."?action=mail"
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_GMMail_Send)
			writer:WriteChar(1)
			writer:WriteString(content)
			writer:WriteString(url)
			simulator:sendTcpActionEventInLua(writer)
		end
	end
end

--发送世界消息

function ChatMgr:requestWorldMsg(msg)
	if msg then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Chat_World)
		StreamDataAdapter:WriteStr(writer, msg)
		simulator:sendTcpActionEventInLua(writer)
	end
end

--当前消息
function ChatMgr:requestCurrentMsg(msg)
	if msg then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Chat_Current_Scene)
		StreamDataAdapter:WriteStr(writer, msg)
		simulator:sendTcpActionEventInLua(writer)
	end
end

--公会消息
function ChatMgr:requestSocietyMsg(msg)
	if msg then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Chat_Society)
		local name = PropertyDictionary:get_unionName(G_getHero():getPT())
		StreamDataAdapter:WriteStr(writer, name)
		StreamDataAdapter:WriteStr(writer, msg)
		simulator:sendTcpActionEventInLua(writer)
	end
end

--喇叭消息
function ChatMgr:requestHornMsg(msg)
	if msg then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Chat_Bugle)
		StreamDataAdapter:WriteStr(writer, msg)
		simulator:sendTcpActionEventInLua(writer)
	end
end

--私聊消息
function ChatMgr:requestwhisperMsg(id, msg)
	if id and msg then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Chat_Private)
		StreamDataAdapter:WriteStr(writer, id)
		StreamDataAdapter:WriteStr(writer, msg)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function ChatMgr:requestAddOnePlayer(groupType, name)
	if groupType and name then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_AddOnePlayer)
		StreamDataAdapter:WriteChar(writer, groupType)
		StreamDataAdapter:WriteStr(writer, name)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function ChatMgr:requestDeleteOnePlayer(groupType, name)
	if groupType and name then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_DeleteOnePlayer)
		StreamDataAdapter:WriteChar(writer, groupType)
		StreamDataAdapter:WriteStr(writer, name)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function ChatMgr:requestPlayerList(groupType)
	if groupType then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_GetPlayerList)
		StreamDataAdapter:WriteChar(writer, groupType)
		simulator:sendTcpActionEventInLua(writer)
	end
end
--
function ChatMgr:requestItemDetails(id)
	if id then
		local obj = self:getObjectById(tonumber(id))
		if obj then
			local goodsId = obj:getGoodsId()
			if goodsId then
				local playerId = string.sub(string.match(goodsId, ".-##"), 1, -3)
				goodsId= string.gsub(goodsId, "-", "_")
				local itemId = string.gsub(goodsId, string.match(goodsId, ".-##"), "")
				itemId = string.gsub(itemId, "_", "-")
				local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
				bagMgr:requestShowItemObject(playerId, itemId)
			end
		end
	end
end

function ChatMgr:isInBlackList(obj)
	local id = obj:getSenderId()
	local inBlackList = self.blackList[id]
	return inBlackList ~= nil
end

function ChatMgr:addContent(object)
	if object then

		if self:isInBlackList(object) then
			return false
		end
		if self.bFull then
			self.startIndex = math.mod(self.startIndex+1, maxChatItems)
			if self.startIndex == 0 then
				self.startIndex = maxChatItems
			end
		end
		self.endIndex = math.mod(self.endIndex+1, maxChatItems)
		if self.endIndex == 0 then
			self.endIndex = maxChatItems
			self.bFull = true
		end
		--如果是私聊消息，打开界面时要显示私聊频道
		if object:getType() == ChatObjectTypes.Private then
			if object:getSenderName() ~= self:getHeroName() then  --接收消息，并不是发送消息

				self:setShowWhisperChatChannel(true, object:getSenderName())
			end
		end
		if self.content[self.endIndex] then
			self.content[self.endIndex]:DeleteMe()
		end
		self.content[self.endIndex] = object
		--通知mainChat更新
		GlobalEventSystem:Fire(GameEvent.EventUpdateMainChatView, self.endIndex)
		return true
	end
	return false
end

--物品展示
function ChatMgr:handleSetItem(itemObject)
	if itemObject ~= nil then
		self.showItemObject = itemObject
		self.itemObject = itemObject
		local staticData = itemObject:getStaticData()
		local itemName = PropertyDictionary:get_name(staticData.property)
		itemName = ChatUtils.Instance:replaceBrackets(itemName)
		
		local itemId = itemObject:getId()
		local playerId = G_getHero():getId()
		local id = playerId .."##".. itemId
		local itemString = "{g="..itemName.."<"..id..">}"
		self:setShowItemString(itemString, id)
		GlobalEventSystem:Fire(GameEvent.EventOpenChatView)
	end
end

--要展示的物品字符串
function ChatMgr:getShowItemString()
	return self.showItem, self.goodsId
end

function ChatMgr:setShowItemString(Item, id)
	self.showItem = Item
	self.goodsId = id	
end

function ChatMgr:getShowItemObject()
	return self.showItemObject
end

function ChatMgr:setShowItemObject(itemObject)
	if itemObject then
		self.showItemObject = itemObject
	end
end

function ChatMgr:resetWisper()
	WhisperChatInfo.ready = false
end

function ChatMgr:isWisperReady()
	return WhisperChatInfo.ready
end

function ChatMgr:setPeerId(id, gender)
	if id and gender then
		WhisperChatInfo.peerName = self.tmpName or ""
		WhisperChatInfo.peerId = id
		WhisperChatInfo.gender = gender
		WhisperChatInfo.ready = true
		GlobalEventSystem:Fire(GameEvent.EventReadyWhisper)
	end
end

function ChatMgr:getWhisperPeerInfo()
	return WhisperChatInfo
end

function ChatMgr:getObjectById(id)
	if id then
		return self.content[id]
	end
end

function ChatMgr:getEndIndex()
	return self.endIndex
end

function ChatMgr:getHeroName()
	local hero = G_getHero()
	local nameValue = PropertyDictionary:get_name(hero:getPT())
	return nameValue
end	

--ChatView是否正在显示， 如果是的话主界面的聊天按钮不应该提示
function ChatMgr:isChatViewShowing()
	if self.chatViewShowing == nil then
		self.chatViewShowing = false
	end
	return self.chatViewShowing
end

function ChatMgr:setChatViewShowing(bShow)
	if bShow then
		self.chatViewShowing = bShow
	end
end

function ChatMgr:getChatById(id)
	if id then
		local chatMap = {}
		local count = 0
		local startIndex = self.startIndex
		local endIndex = self.endIndex
		if self.startIndex > self.endIndex and self.endIndex ~= 0 then
			endIndex = self.endIndex+maxChatItems
		end
		
		if id ~= ChatObjectTypes.All then
			for i = startIndex, endIndex do
				local index = math.mod(i, maxChatItems)
				if index == 0 then
					index = maxChatItems
				end
				
				local object = self.content[index]
				if object:getType() == id then
					count = count + 1
					chatMap[count] = index
				end
			end
		else   --区分获取全部，因为这里获取要有顺序问题

			for i = startIndex, endIndex do
				local index = math.mod(i, maxChatItems)
				if index == 0 then
					index = maxChatItems
				end
				count = count + 1
				chatMap[count] = index
			end
		end
		return chatMap, count
	end
end

function ChatMgr:showPeerInfo(playerId)
	local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
	if playerId ~= heroId then
		local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
		local entityMgr = GameWorld.Instance:getEntityManager()
		equipMgr:requestOtherPlayerEquipList(playerId)
		entityMgr:requestOtherPlayer(playerId)
		equipMgr:setOtherPlayerEquipList(nil)	--清空列表，防止读到其他玩家信息

		self.playerObj = PlayerObject.New()
		self.playerObj:setId(playerId)
		local player = {playerObj=self.playerObj,playerType =1}	--1: 玩家的信息	
		if playerId == heroId then
			player.playerType = 0
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player)
		GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
	else
		UIManager.Instance:showSystemTips(Config.Words[479])
	end
end


function ChatMgr:setShowWhisperChatChannel(bWhisper, name)
	if bWhisper and name then
		self.bWhisperChat = bWhisper
		self.tmpName = name
	end
end

function ChatMgr:getShowWisperChatChannel()
	return self.bWhisperChat, self.tmpName
end

function ChatMgr:setOnlineList(onlineList)
	if onlineList and type(onlineList) =="table" then
		for k, v in pairs(onlineList) do
			self.onlineList[k] = v
		end
	end
end

function ChatMgr:isPlayerOnline(contractId)
	if contractId then
		return self.onlineList[contractId]
	end
end


--------------------------新私聊接口-----------------------
--增加一个伙伴
function ChatMgr:addOnePeer(groupType, onePeer)
	if type(groupType) == "number" and type(onePeer) == "table" then
		if self.peerList[groupType] == nil then
			self.peerList[groupType] = {}
		end
		table.insert(self.peerList[groupType],onePeer)
	end
end

--删除一个伙伴
function ChatMgr:deleteOnePeer(groupType, playerId)
	if type(groupType) ~= "number" and type(playerId) ~= "string" then
		return
	end
	if self.peerList then
		if self.peerList[groupType] then
			for k,v in pairs(self.peerList[groupType]) do
				if v.playerId == playerId then
					table.remove(self.peerList[groupType], k)
					break
				end
			end
		end
	end
end

--获取一个分组
function ChatMgr:getOneGroup(groupType)
	if type(groupType) == "number" then
		return self.peerList[groupType]
	end
end

--清空一个分组
function ChatMgr:clearOneGroup(groupType)
	if type(groupType) == "number" then
		self.peerList[groupType] = nil
	end
end

--获取一个伙伴
function ChatMgr:getOnePeer(groupType, index)
	if type(groupType) == "number" and type(index) == "number" then
		if self.peerList[groupType] then
			return self.peerList[groupType][index]
		end
	end
end

--根据Id获取组号和序号
function ChatMgr:getGroupTypeAndIndexById(playerId)
	if type(playerId) ~= "string" then
		return
	end
	for groupType, group in pairs(self.peerList) do
		for peerIndex, peer in pairs(group) do
			if peer.playerId == playerId then
				return groupType, peerIndex
			end
		end
	end
end

--根据名字获取组号和序号
function ChatMgr:getGroupTypeAndIndexByName(playerName)
	if type(playerName) ~= "string" then
		return
	end
	for groupType, group in pairs(self.peerList) do
		for peerIndex, peer in pairs(group) do
			if peer.playerName == playerName then
				return groupType, peerIndex
			end
		end
	end
end

--设置当前选择分组
function ChatMgr:setCurrentGroup(groupType)
	if type(groupType) == "number" then
		self.curGroupType = groupType
	end
end

--获取当前选择分组
function ChatMgr:getCurrentGroup()
	return self.curGroupType
end

--设置当前选择伙伴
function ChatMgr:setCurrentPeer(selectPeer)
	if type(selectPeer) == "number" then
		self.curSelectPeer = selectPeer
	end
end

--获取当前选择伙伴
function ChatMgr:getCurrentPeer()
	return self.curSelectPeer
end	

--排序伙伴列表
function ChatMgr:sortPeerList(groupType)
	if type(groupType) == "number" then
		local sortIsOffline = function(player1,player2)		
			if player1.online == player2.online then
				return player1.level > player2.level
			else
				return player1.online > player2.online
			end
		end
		
		if self.peerList[groupType] then
			table.sort(self.peerList[groupType],sortIsOffline)
		end
	end
end

--重置伙伴在线状态
function ChatMgr:resetPeerOnlineState(playerId,onlineState)
	if type(playerId) == "string" and type(onlineState) == "number" then
		local groupType,peerIndex = self:getGroupTypeAndIndexById(playerId)
		if groupType and peerIndex then
			if self.peerList[groupType][peerIndex] then
				self.peerList[groupType][peerIndex].online = onlineState
			end
		end
	end
end

function ChatMgr:linkToTargetView(id)
	if type(id) == "string" then
		local i,idStart = string.find(id,"id=")
		local idEnd,nameStart = string.find(id,"name=")
		if idStart and idEnd then
			local targetViewType = string.sub(id,idStart+1,idEnd-1)
			if targetViewType == "vip" then
				GlobalEventSystem:Fire(GameEvent.EventVipViewOpen)	
			elseif targetViewType == "mount" then
				if (Config.MainMenu[MainMenu_Btn.Btn_mount].condition == false) then	
					UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_mount].tips )	
					return
				end
				GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen)
			elseif targetViewType == "wing" then
				if (Config.MainMenu[MainMenu_Btn.Btn_wing].condition == false) then		
					UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_wing].tips )	
					return
				end
				GlobalEventSystem:Fire(GameEvent.EventOpenWingView)	
			elseif targetViewType == "talisman" then
				if (Config.MainMenu[MainMenu_Btn.Btn_talisman].condition == false) then		
					UIManager.Instance:showSystemTips(Config.MainMenu[MainMenu_Btn.Btn_talisman].tips)
					return
				end
				GlobalEventSystem:Fire(GameEvent.EventTalismanViewOpen)
			end
		end
	end
end

function ChatMgr:addToBlackList(id)
	if self.blackList then
		self.blackList[id] = true
	end		
end

function ChatMgr:removeFormBlackList(id)
	if self.blackList then
		self.blackList[id] = nil
	end
end