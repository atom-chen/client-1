require "common.BaseUI"
require "ui.chat.ChatDef"
require "ui.utils.PopupMenu"
require("object.bag.ItemDetailArg")
require("object.bag.ItemObject")
require("data.KeywordFilter")
require ("ui.chat.WhisperView")

ChatView = ChatView or BaseClass(BaseUI)

local editBoxSize = VisibleRect:getScaleSize(CCSizeMake(465, 45))  --编辑框的大小
local objectNodeSize = CCSizeMake(110, 31*5)  --聊对象下拉框的大小
local cellSize = CCSizeMake(objectNodeSize.width, 23)  --tablevi的Cell大小
local scrollBgSize = VisibleRect:getScaleSize(CCSizeMake(830, 360))  --scrollview的大小
local scrollViewSize = CCSizeMake(scrollBgSize.width, scrollBgSize.height-10)
local scale = VisibleRect:SFGetScale()
local textZorder = 10    --文字的Z轴序

local ChatInfo = {
[ChatObjectTypes.World] = {sequence = 2,}, 
[ChatObjectTypes.Current] = {sequence =3,},
[ChatObjectTypes.Society] = {sequence =4,},
[ChatObjectTypes.Private] = {sequence =5,},
[ChatObjectTypes.Horn] = {},
[ChatObjectTypes.GM] = {sequence = 6,},
[ChatObjectTypes.All] = {sequence = 1,},	
}

function ChatView:__init()
	-- 这是为了解决，私聊的时候保存了vip的信息，登录后没有vip的用户在聊天频道说过话
	-- 直接打开了私聊界面， 由于图片信息没有RES过，导致richLabel在崩溃 @叶俊华 2014年8月28日
	RES("goldVipChat.png")
	RES("copperVipChat.png")
	RES("sliverVipChat.png")
	
	self.viewName = "ChatView"	
	self:initFullScreen()	
	
	self:initVariable()	
	self:createTitle()
	self:createSendUI()   --发送栏	
	self:createContentView() --内容	
	self:createChatChannel()   --聊天频道		
	self:loadAllMessage()	
	self:createWhisperView()
	self:createPeerGroup()  --朋友分组
	
	--高亮  聊天频道
	self:showChatInfoByObjectType(self.curObjectType)	
	self:heightLightChatChannel(self.curObjectType)
	
	self.lastChatTime = -1
	self.lastSendingMessage = ""
	self.duplicateCount = 0
	self.timeLimit = 20
	self.duplicateSum = 0	
end

function ChatView:__delete()
	for k, v in pairs(ChatObjectTypes) do
		if ChatInfo[v] and ChatInfo[v].disableSprite then
			ChatInfo[v].disableSprite:removeFromParentAndCleanup(true)
			ChatInfo[v].disableSprite = nil
		end
	end		
end

function ChatView:create()
	return ChatView.New()	
end

function ChatView:createTitle()
	local img = createSpriteWithFrameName(RES("main_char.png"))
	self:setFormImage(img)
	local title = createSpriteWithFrameName(RES("word_window_char.png"))
	self:setFormTitle(title, TitleAlign.Left)
end	

function ChatView:onEnter()
	--检测是否有展示的物品
	local item = self.chatMgr:getShowItemString()
	if item ~= nil then
		self.editBox:setFontColor(FCOLOR("ColorWhite1"))
		local itemName = self:getShowItemName()		
		self.editBox:setText(itemName)
	end
	--标志当前界面正在显示
	self.chatMgr:setChatViewShowing(true)	
	local hornNum = G_getBagMgr():getItemNumByRefId("item_horn")
	self:setHornNum(hornNum)
end

function ChatView:onExit()
	--标志当前界面不显示
	self.chatMgr:setChatViewShowing(false)
	
	--隐藏弹出框
	local uiMgr = UIManager.Instance
	local msgBoxWithEdit = uiMgr:getViewByName("MessageBoxWithEdit")
	if msgBoxWithEdit then 
		uiMgr:hideUI("MessageBoxWithEdit")
	end
	UIManager.Instance:hidePopupMenu()
end	

--第一次创建的时候加载所有消息
function ChatView:loadAllMessage()
	self:showChatInfoByObjectType(ChatObjectTypes.All)
end	

--朋友分组页签
function ChatView:createPeerGroup()
	local createContent = {
		[PeerGroupType.BlackList] = Config.Words[437],	
		[PeerGroupType.Enemy] = Config.Words[436],	
		[PeerGroupType.Friend] = Config.Words[435],	
		[PeerGroupType.TemporaryFriend] = Config.Words[434],
	}
	local btnArray = CCArray:create()
	for key,value in ipairs(createContent) do
	--for key = 4,1,-1 do --需要倒序排，暂时这么处理着
		if self.groupButton[key] then
			self.groupButton[key]:removeFromParentAndCleanup(true)
			self.groupButton[key] = nil
		end
		self.groupButton[key] = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))	
		local label = createLabelWithStringFontSizeColorAndDimension(value,"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"),CCSizeMake(30,0))
		self.groupButton[key]:setTitleString(label)
		btnArray:addObject(self.groupButton[key])
		local onTabPress = function()
			self.chatMgr:requestPlayerList(key)
		end
		self.groupButton[key]:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)	
		
		self.groupButton[key].paopao = createSpriteWithFrameName(RES("paopao.png"))
		self.groupButton[key]:addChild(self.groupButton[key].paopao)
		VisibleRect:relativePosition(self.groupButton[key].paopao, self.groupButton[key], LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-8, 5))	
		self.groupButton[key].paopao:setVisible(false)
	end
	self.groupTabView = createTabView(btnArray,5, tab_vertical)
	self.groupTabView:setDefaultSel(false)
	self:addChild(self.groupTabView)
	VisibleRect:relativePosition(self.groupTabView,self.scrollBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_OUTSIDE, ccp(0, 0))
end

function ChatView:createWhisperView()
	self.whisperView = WhisperView.New()
	self:addChild(self.whisperView:getRootNode())
	VisibleRect:relativePosition(self.whisperView:getRootNode(), self.scrollBg, LAYOUT_CENTER)
end

function ChatView:getWhisperView()
	return self.whisperView
end

function ChatView:initVariable()
	self.chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()						
	self.curObjectType = ChatObjectTypes.World --聊天对象类型		
	self.canChatOnWorldChannel = true  --是否可以在世界频道发送消息
	self.groupButton = {}	
end

--发送区域
function ChatView:createSendUI()	
	--编辑框	
	self.editBox = createEditBoxWithSizeAndBackground(editBoxSize, RES("commom_editFrame.png"))
	self.editBox:setMaxLength(20)
	G_setScale(self.editBox)
	self.editBox:setFontSize(FSIZE("Size4"))
	self.editBox:setFontColor(FCOLOR("ColorBlack1"))
	self.editBox:setText(Config.Words[431])	
	self:addChild(self.editBox)
	VisibleRect:relativePosition(self.editBox, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(20, -3))
		
	local editBoxHandler = function (pEventName, editBox)	
		if pEventName == "began" then 		
			if self.editBox:getText() == Config.Words[431] then 
				self.editBox:setText("")
			end
			self.editBox:setFontColor(FCOLOR("ColorWhite1"))
		end
	end		
	self.editBox:registerScriptEditBoxHandler(editBoxHandler)
	
	--喇叭发送按钮
	self.horn = createButtonWithFramename(RES("btn_1_select.png"))
	G_setScale(self.horn)		
	self:addChild(self.horn)
	VisibleRect:relativePosition(self.horn, self.editBox, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(11, 0))
	local hornSprite = createSpriteWithFrameName(RES("chat_horn.png"))
	self.horn:addChild(hornSprite)
	VisibleRect:relativePosition(hornSprite, self.horn, LAYOUT_CENTER)
	self.hornNumLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
	self.horn:addChild(self.hornNumLabel)
	VisibleRect:relativePosition(self.hornNumLabel, self.horn, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-8, 5))
	local hornNum = G_getBagMgr():getItemNumByRefId("item_horn")
	self:setHornNum(hornNum)
	local chatObjectCB = function ()	
		self.curObjectType = ChatObjectTypes.All
		self:handleSendMessage(ChatObjectTypes.Horn)
		self:changeChatChannel(ChatObjectTypes.All)
	end
	self.horn:addTargetWithActionForControlEvents(chatObjectCB, CCControlEventTouchUpInside)
	
	--发送按钮	
	local sendBtn = createButtonWithFramename(RES("btn_1_select.png"))
	G_setScale(sendBtn)
	local sendText = createSpriteWithFrameName(RES("word_button_send.png"))
	sendBtn:setTitleString(sendText)
	VisibleRect:relativePosition(sendText, sendBtn, LAYOUT_CENTER)
	self:addChild(sendBtn)	
	VisibleRect:relativePosition(sendBtn, self.horn, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(22, 0))
	
	local senBtnCB = function()		
		self:handleSendMessage()
	end
	sendBtn:addTargetWithActionForControlEvents(senBtnCB,CCControlEventTouchUpInside)	
end	

function ChatView:setHornNum(num)
	if num then 
		self.hornNumLabel:setString(num)
		VisibleRect:relativePosition(self.hornNumLabel, self.horn, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-8, 5))
	end
end

--聊天内容区域
function ChatView:createContentView()
	self:createChatScrollView()
	self:createChatRichLabel()
	self:setRichLabelHandler()
end

--聊天内容区域，scrollview
function ChatView:createChatScrollView()
	--背景	
	self.scrollBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), scrollBgSize)	
	self:addChild(self.scrollBg)
	VisibleRect:relativePosition(self.scrollBg, self:getContentNode(), LAYOUT_CENTER_X)		
	VisibleRect:relativePosition(self.scrollBg, self.horn, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -6))		
	
	self.nodeContainer = CCNode:create()
	self.nodeContainer:setContentSize(viewSize)
	self:addChild(self.nodeContainer)
	VisibleRect:relativePosition(self.nodeContainer, self.scrollBg, LAYOUT_CENTER)
	
	--ScrollView
	self.scrollView = createScrollViewWithSize(scrollViewSize)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self.nodeContainer:addChild(self.scrollView)		
	VisibleRect:relativePosition(self.scrollView, self.nodeContainer, LAYOUT_CENTER)	
	
	local scrollHandler = function(view, eventType, x, y)
		if (eventType == 4) then  --kScrollViewTouchEnd		
			if self.showingPopupMenu == false then
				UIManager.Instance:hidePopupMenu()
			end
			self.showingPopupMenu = false
		end
		return 1
	end
	self.scrollView:setHandler(scrollHandler)
end

--聊天内容区域，  richLabel
function ChatView:createChatRichLabel()
	self.richLabel = createRichLabel(CCSizeMake(scrollViewSize.width-40,0))
	self.richLabel:setGaps(10)
	self.richLabel:setFontSize(FSIZE("Size4"))			
	self.richLabel:setTouchEnabled(true)	
	
	self.containerNode = CCNode:create()
	self.containerNode:setContentSize(scrollViewSize)
	self.containerNode:addChild(self.richLabel)	
	VisibleRect:relativePosition(self.richLabel,self.containerNode,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(0,0))		

	self.scrollView:setContainer(self.containerNode)
end

--richlabel 点击回调
function ChatView:setRichLabelHandler()
	local chatRichLabelHandler = function(eventStr, pTouch)	
		local touch = tolua.cast(pTouch, "CCTouch")
		local pos = touch:getLocation()			
		local eventType = string.sub(eventStr, 1, 1)
		local id = string.sub(eventStr, 2, -1)	
		if eventType == "p" then  --玩家 
			self:showPopupMenu(id, pos.x, pos.y, "content")
		elseif eventType == "g" then --物品
			local idStr  = string.match(id, ".-id=")
			if idStr then
				local i,idStart = string.find(id,"id=")
				local idEnd,nameStart = string.find(id,"name=")
				if idStart and idEnd and nameStart then
					local itemRefId = string.sub(id,idStart+1,idEnd-1)
					local itemName = string.sub(id,nameStart+1,-1)
					itemRefId = string.gsub(itemRefId,"-","_")
					local itemObj = ItemObject.New()
					itemObj:setRefId(itemRefId)
					local pt = {}	
					pt["fightValue"] = 0
					itemObj:updatePT(pt)						
					local fightValue = G_getEquipFightValue(itemObj:getRefId())
					if fightValue then
						itemObj:updatePT({fightValue = fightValue})	
					end						
					G_clickItemEvent(itemObj)
				end
			else
				self.chatMgr:requestItemDetails(id)
			end				
		elseif eventType == "s" then  --场景
			
		elseif eventType == "m" then  --boss怪物
			
		elseif eventType == "n" then 
			self:showPopupMenu(id, pos.x, pos.y, "player") --n=正常收发发送者显示下划线
		elseif eventType == "v" then
			self:showPopupMenu(id, pos.x, pos.y, "player")
		elseif eventType == "l" then	--界面链接
			self.chatMgr:linkToTargetView(id)
		end
	end
	self.richLabel:setEventHandler(chatRichLabelHandler)
end

function ChatView:handlerPeer(info, ttype, group)
	if ttype == "player" then 		
		local object = self.chatMgr:getObjectById(tonumber(info))
		if object then 	
			local peerName = object:getSenderName()			
			local groupType, index = self.chatMgr:getGroupTypeAndIndexByName(peerName)
			if groupType == nil or groupType ~= group then
				groupType = group
				self.chatMgr:requestAddOnePlayer(groupType, peerName)
			else
				self:changeChatChannel(ChatObjectTypes.Private,groupType,index)	
			end					
		end		
	else			
		local startPos, endPos = string.find(info, "name=")
		if endPos then
			local name = string.sub(info, endPos+1, -1)
			if name then
				local groupType, index = self.chatMgr:getGroupTypeAndIndexByName(name)
				if groupType == nil or groupType ~= group then
					groupType = group
					self.chatMgr:requestAddOnePlayer(groupType, name)
				else
					self:changeChatChannel(ChatObjectTypes.Private,groupType,index)	
				end				
			end
		end
	end	
end

--显示弹出框
function ChatView:showPopupMenu(info, posX, posY, ttype)
	local size = CCSizeMake(100, 260)
	
	--查看信息
	local handleShowPeerInfo = function (arg)
		if ttype == "player" then 		
			local object = self.chatMgr:getObjectById(tonumber(info))			
			if object then 
				if object:getType()==ChatObjectTypes.Private and true==ChatUtils.Instance:checkChat2Myself(info) then 
					local recvId = object:getReceiverId()	
					self.chatMgr:showPeerInfo(recvId)
				else
					local peerId = object:getSenderId()		
					self.chatMgr:showPeerInfo(peerId)
				end
			end
		else			
			local startPos, endPos = string.find(info, "name=")
			if startPos then
				local id = string.sub(info, 4, startPos-1)				
				if id then
					self.chatMgr:showPeerInfo(id)					
				end
			end	
		end
	end
	--私聊
	local handleWhisper = function (arg)
		self:handlerPeer(info, ttype, PeerGroupType.TemporaryFriend)
	end	
	--关注
	local handleAttention = function(arg)
		self:handlerPeer(info, ttype, PeerGroupType.Friend)		
	end
	--黑名单
	local hangleBackList = function(arg)
		self:handlerPeer(info, ttype, PeerGroupType.BlackList)	
	end
	--复制
	local hangleCopy = function(arg)
		local object = self.chatMgr:getObjectById(tonumber(info))
		if object then 			
			local peerName = object:getSenderName()	
			SFGameHelper:copy2PasteBoard(peerName)
		end	
	end
	
	local items = {
		{lable = Config.Words[425], id = 1, callback = handleShowPeerInfo, arg = "1", disable = false},
		{lable = Config.Words[426], id = 2, callback = handleWhisper, arg = info},
		{lable = Config.Words[427], id = 3, callback = handleAttention, arg = "3", disable = false},
		{lable = Config.Words[428], id = 4, callback = hangleBackList, arg = "4", disable = false},
		{lable = Config.Words[429], id = 5, callback = hangleCopy, arg = "5", disable = false},
	}
	
	local pos = self.rootNode:convertToNodeSpace(ccp(posX, posY))
	local rootNodesize = self.rootNode:getContentSize()
	UIManager.Instance:showPopupMenu(size, items, self:getContentNode(), ccp(pos.x-22, -(rootNodesize.height-pos.y)+150))
	self.showingPopupMenu = true
end	

--下方的聊天频道
function ChatView:createChatChannel()
	ChatInfo[ChatObjectTypes.World].channelObj = createButtonWithFramename(RES("btn_1_select.png"))
	ChatInfo[ChatObjectTypes.Current].channelObj = createButtonWithFramename(RES("btn_1_select.png"))
	ChatInfo[ChatObjectTypes.Society].channelObj = createButtonWithFramename(RES("btn_1_select.png"))
	ChatInfo[ChatObjectTypes.Private].channelObj = createButtonWithFramename(RES("btn_1_select.png"))
	ChatInfo[ChatObjectTypes.All].channelObj = createButtonWithFramename(RES("btn_1_select.png"))	
	ChatInfo[ChatObjectTypes.GM].channelObj = createButtonWithFramename(RES("btn_1_select.png"))

	ChatInfo[ChatObjectTypes.All].objSprite = createSpriteWithFrameName(RES("chat_all.png"))
	ChatInfo[ChatObjectTypes.World].objSprite = createSpriteWithFrameName(RES("chat_world.png"))
	ChatInfo[ChatObjectTypes.Current].objSprite = createSpriteWithFrameName(RES("chat_current.png"))
	ChatInfo[ChatObjectTypes.Society].objSprite = createSpriteWithFrameName(RES("chat_guild.png"))
	ChatInfo[ChatObjectTypes.Private].objSprite = createSpriteWithFrameName(RES("chat_private .png"))	
	ChatInfo[ChatObjectTypes.GM].objSprite = createSpriteWithFrameName(RES("chat_gm.png"))
	
	local node = CCNode:create()
	node:setContentSize(VisibleRect:getScaleSize(CCSizeMake(830, 73)))
	self:addChild(node)
	VisibleRect:relativePosition(node, self:getContentNode(), LAYOUT_CENTER_X, ccp(0, 0))
	VisibleRect:relativePosition(node, self.scrollBg, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -3))
		
	for objectType, info in pairs(ChatInfo) do
		if info.channelObj then 
			info.channelObj:addChild(info.objSprite, textZorder)
			node:addChild(info.channelObj)
			VisibleRect:relativePosition(info.objSprite, info.channelObj, LAYOUT_CENTER)	
		end	
	end		
	
	--查看全部信息
	local allChannelCB = function ()	
		self:changeChatChannel(ChatObjectTypes.All)		
	end		
	ChatInfo[ChatObjectTypes.All].channelObj:addTargetWithActionForControlEvents(allChannelCB, CCControlEventTouchUpInside)
	
	--查看当前信息
	local curChannelCB = function ()	
		self:changeChatChannel(ChatObjectTypes.Current)		
	end
	ChatInfo[ChatObjectTypes.Current].channelObj:addTargetWithActionForControlEvents(curChannelCB, CCControlEventTouchUpInside)
	
	--查看世界信息
	local worldChannelCB = function ()	
		self:changeChatChannel(ChatObjectTypes.World)
	end
	ChatInfo[ChatObjectTypes.World].channelObj:addTargetWithActionForControlEvents(worldChannelCB, CCControlEventTouchUpInside)
	
	--查看公会信息
	local societyChannelCB = function ()
		self:changeChatChannel(ChatObjectTypes.Society)
	end
	ChatInfo[ChatObjectTypes.Society].channelObj:addTargetWithActionForControlEvents(societyChannelCB, CCControlEventTouchUpInside)
	
	--查看私聊信息
	local whisperChannelCB = function ()	
		self:changeChatChannel(ChatObjectTypes.Private,PeerGroupType.TemporaryFriend,0)		
	end
	ChatInfo[ChatObjectTypes.Private].channelObj:addTargetWithActionForControlEvents(whisperChannelCB, CCControlEventTouchUpInside)
		
	--查看GM信息
	local gmChannelCB = function ()	
		self:changeChatChannel(ChatObjectTypes.GM)		
	end
	ChatInfo[ChatObjectTypes.GM].channelObj:addTargetWithActionForControlEvents(gmChannelCB, CCControlEventTouchUpInside)			
	
	local sequence = {
	[1] = ChatObjectTypes.All,
	[2] = ChatObjectTypes.World, 
	[3] = ChatObjectTypes.Current,
	[4] = ChatObjectTypes.Society,
	[5] = ChatObjectTypes.Private,
	[6] = ChatObjectTypes.GM,
	}
	local totalSize = node:getContentSize()
	local singleSize = ChatInfo[ChatObjectTypes.Current].channelObj:getContentSize()
	local cnt = table.size(sequence)
	local gaps = (totalSize.width-singleSize.width*cnt)/(cnt-1)
	for k, v in pairs(sequence) do 
		VisibleRect:relativePosition(ChatInfo[v].channelObj, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp((k-1)*(singleSize.width+gaps), 0))		
	end
end

function ChatView:disableChatChannel(objectType)
	if ChatInfo[objectType].disableSprite then
		ChatInfo[objectType].disableSprite:removeFromParentAndCleanup(true)
		ChatInfo[objectType].disableSprite = nil		
	end
	
	if ChatInfo[objectType].disableSprite == nil then 
		local disSprite = createSpriteWithFrameName(RES("btn_1_select.png"))	
		UIControl:SpriteSetGray(disSprite)	
		ChatInfo[objectType].disableSprite = disSprite
		ChatInfo[objectType].channelObj:addChild(ChatInfo[objectType].disableSprite, textZorder-1)		
		VisibleRect:relativePosition(ChatInfo[objectType].disableSprite, ChatInfo[objectType].channelObj, LAYOUT_CENTER)
	end
	ChatInfo[objectType].channelObj:setEnable(false)
end

function ChatView:enableChatChannel(objectType)
	if ChatInfo[objectType].disableSprite then 
		ChatInfo[objectType].disableSprite:removeFromParentAndCleanup(true)
		ChatInfo[objectType].disableSprite = nil		
	end		
	ChatInfo[objectType].channelObj:setEnable(true)
end

--下方的聊天频道高亮
function ChatView:heightLightChatChannel(objectType)
	if self.selectedObject ~= nil then
		self.selectedObject:removeFromParentAndCleanup(true)
		self.selectedObject = nil
	end
	if self.selectedObject == nil then
		self.selectedObject = createSpriteWithFrameName(RES("btn_1_normal.png"))
		ChatInfo[objectType].channelObj:addChild(self.selectedObject, textZorder-1)
		VisibleRect:relativePosition(self.selectedObject, ChatInfo[objectType].channelObj, LAYOUT_CENTER)
	end
end

--添加要显示的文本
function ChatView:addText(text)
	self.richLabel:appendFormatText(text)
	local size = self.richLabel:getContentSize()
	
	if scrollViewSize.height > size.height then
		size.height = scrollViewSize.height
		self.richLabel:setContentSize(size)
		self.containerNode:setContentSize(scrollViewSize)
	else
		self.containerNode:setContentSize(CCSizeMake(scrollViewSize.width, size.height+20))	
	end	
	self.scrollView:updateInset()
	VisibleRect:relativePosition(self.richLabel,self.containerNode,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(0,0))		
end

-- id对应的聊天内容是否需要显示在界面
-- 如果当前显示的聊天频道与收到的聊天信息不在同一个频道不显示
function ChatView:isNeedAddText(id)
	local obj = self.chatMgr:getObjectById(id)
	if obj then
		local objType = obj:getType()
		if objType==self.curObjectType or self.curObjectType==ChatObjectTypes.All then 
			return true
		end
	end
	return false
end

--将消息发给服务器
function ChatView:sendMessage(msg, sendType)
	if self.chatMgr:getShowItemString() ~= nil then	
		--如果不是私聊，要清空。私聊的话在本地显示后清空	
		if self.curObjectType ~= ChatObjectTypes.Private then
			self.chatMgr:setShowItemString(nil)
		end
	end		
	if sendType == nil then 
		if self.curObjectType == ChatObjectTypes.World  or self.curObjectType==ChatObjectTypes.All then
			self.chatMgr:requestWorldMsg(msg)  --世界		
		elseif self.curObjectType == ChatObjectTypes.Current then
			self.chatMgr:requestCurrentMsg(msg) --当前	
		elseif self.curObjectType == ChatObjectTypes.Society then		
			self.chatMgr:requestSocietyMsg(msg)  --公会	
		elseif self.curObjectType == ChatObjectTypes.Private then
			local peerId = self:getWhisperId()
			if peerId then 
				self.chatMgr:requestwhisperMsg(peerId, msg) --私聊	
			else
				UIManager.Instance:showSystemTips(Config.Words[408])
			end	
		elseif self.curObjectType == ChatObjectTypes.Horn then 
			self.chatMgr:requestHornMsg(msg)   --喇叭
		elseif  self.curObjectType == ChatObjectTypes.GM then 
			self.chatMgr:requestGmMail(self.editBox:getText())                --gm邮件
		end
	else
		if sendType == ChatObjectTypes.Horn then 
			self.chatMgr:requestHornMsg(msg)
		end
	end
end	


--分类显示聊天信息
function ChatView:showChatInfoByObjectType(objectType)
	self.richLabel:clearAll()
	self.richLabel:setTouchEnabled(true)
	--私聊的记录在专门的界面显示
	if objectType == ChatObjectTypes.Private then 
		self:addText("")
		return
	end
	local chatMap, cnt = self.chatMgr:getChatById(objectType)	
	for i = 1, cnt do
		local index = chatMap[i]
		local str = ChatUtils.Instance:constructRichStringById(index, "true")
		self:addText(str)
	end
end	

--处理消息的发送
function ChatView:handleSendMessage(sendType)
	--消息为空，本地提示不能发送
	if self:isMessageEmpty() then 
		local chatObject = ChatObject.New()		
		chatObject:setContent(Config.Words[454])
		chatObject:setType(ChatObjectTypes.System)
		self.chatMgr:addContent(chatObject)
		GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, self.chatMgr:getEndIndex())
		return
	end		
	
	local msg = self:getSendMessage()	
	-- 过滤关键字
	for k,v in pairs(GameData.Keyword) do
		local s1, e1 = string.find(msg, v)
		if s1 then
			msg = string.gsub(msg, v, "****")
		end
	end
	
	if sendType ~= ChatObjectTypes.Horn then 
		-- 限制世界聊天
		local level = PropertyDictionary:get_level(G_getHero():getPT())	
		if ChatCode.Error == self:limitWorldChat(level, msg) then 
			return
		end
	end
	
	--向服务器发送消息	
	self:sendMessage(msg, sendType)

	----------gm------------------
	if self.curObjectType == ChatObjectTypes.GM then 	
		self.editBox:setText("")
		return
	end
	----------gm------------------					
end

	
function ChatView:createFakeMessage(msg)
	local vipMgr = GameWorld.Instance:getVipManager()   
	local vipLv = vipMgr:getVipLevel()
	local chatObject = ChatObject.New()						
	local time = ChatUtils.Instance:getFormatTime(os.time()*1000)	
	chatObject:setContent(msg..time)				
	chatObject:setType(ChatObjectTypes.World)
	local heroObj = G_getHero()				
	local heroName = PropertyDictionary:get_name(heroObj:getPT())
	local heroId = heroObj:getId()
	local gender = PropertyDictionary:get_gender(heroObj:getPT())
	chatObject:setSenderName(heroName)
	chatObject:setSenderId(heroId)
	chatObject:setGender(gender)
	chatObject:setVipLevel(vipLv)
	self.chatMgr:addContent(chatObject)				
	GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, self.chatMgr:getEndIndex())
	self:resetMessage()
end	

function ChatView:handlerSimilarMessage(msg)
	self.duplicateCount = self.duplicateCount + 1
	if self.duplicateCount >= 3 then
		self:createFakeMessage(msg)
		return ChatCode.Error
	end
end
--todo 调整这些常量的位置
local limitLevel = 45
local similarityRate = 0.8	
--限制世界聊天
function ChatView:limitWorldChat(level, msg)
	if ChatObjectTypes.World == self.curObjectType or self.curObjectType==ChatObjectTypes.All then
		-- 不满45级，不能在世界频道聊天
		if level < limitLevel then 
			local tips = string.gsub(Config.Words[477],"x",tostring(limitLevel))
			UIManager.Instance:showSystemTips(tips)
			return ChatCode.Error
		end						
		-- 发送时间限制
		local now = os.time()
		local offset = now - self.lastChatTime		
		if offset < self.timeLimit  then
			if self.timeLimit <= 20 then
				local tipsWord = string.gsub(Config.Words[478], "xx", tostring(self.timeLimit))
				UIManager.Instance:showSystemTips(tipsWord)
			end
			return ChatCode.Error
		end			
		self.lastChatTime = os.time()	
		
		-- 同一句话发送多次，被认为是广告
		-- 不会通过协议发给服务器，直接本地显示
		if self.lastSendingMessage == msg and self.chatMgr:getShowItemString()==nil then
			return self:handlerSimilarMessage(msg)
		elseif ChatUtils.Instance:getSimilarity(msg,self.lastSendingMessage) > similarityRate and self.chatMgr:getShowItemString()==nil then
			return self:handlerSimilarMessage(msg)
		else
			self.duplicateCount = 0		
		end
		self.lastSendingMessage = msg		
	end	
	return ChatCode.Success
end

function ChatView:resetMessage()
	self.editBox:setText("")
end	

function ChatView:getShowItemName()
	local itemString = self.chatMgr:getShowItemString()	
	local name = string.match(itemString, "{.-<")
	name = string.sub(name, 2, -2)	
	return name
end	

--是否可以私聊
function ChatView:checkPeerReady()
	local chatService = self.chatMgr:getChatService()
	local chatList = chatService:getChatList(G_getHero():getId())
	local whisperIndex = self.whisperView:getCurSel()
	if chatList and type(chatList)=="table" then
		local contractId = ""
		if chatList[whisperIndex+1] then 		
			contractId = chatList[whisperIndex+1]
		elseif chatList[1] then 
			contractId = chatList[1]
		end
		if self.chatMgr:isPlayerOnline(contractId) == true then 
			return true
		else
			UIManager.Instance:showSystemTips(Config.Words[408])
			return false
		end
		
	end		
end

function ChatView:getWhisperId()
	local groupType = G_getHero():getChatMgr():getCurrentGroup()
	local currentPeer = G_getHero():getChatMgr():getCurrentPeer()
	local player = G_getHero():getChatMgr():getOnePeer(groupType, currentPeer)
	if player then
		return player.playerId
	else
		return nil
	end
end

function ChatView:getSendMessage()
	local msg = self.editBox:getText()	
	if self:isMsgIllegal(msg) then 
		if ChatUtils.Instance:isContainMark(msg) then 
			msg = msg .. " "  --不允许存在{__{.....}__}结构，在后面加空格破坏该结构，收到消息不进行解析，直接显示
		end
		--local time = ChatUtils.Instance:getFormatTime()
		local itemString = self.chatMgr:getShowItemString()
		if itemString then --有物品展示
			local itemName = self:getShowItemName()
			if string.match(msg, itemName) then 
				msg = string.gsub(msg, itemName, itemString)
				msg = msg or ""  --为了保证不崩溃
				--msg = msg .. time
				msg = ChatUtils.Instance:addHyperLinkMark(msg)--添加标志，解析时需要用到
				return msg
			end
		end				
		return msg--..time
	end
end

--发送的消息是否合法
function ChatView:isMsgIllegal(msg)
	if msg == Config.Words[431] or msg == "" then 
		return false		
	end
	return true
end

function ChatView:refreshChatChannel()
	--没有加入公会， 禁用公会聊天查看	
	if ChatUtils.Instance:isJoinSociety(false) == false then 
		self:disableChatChannel(ChatObjectTypes.Society)
	else
		self:enableChatChannel(ChatObjectTypes.Society)
	end
end	

function ChatView:updatePeerGroupTabs(groupType)
	if groupType then
		if self.whisperView.unReadMsgTips[groupType] then
			if self.whisperView.unReadMsgTips[groupType]["hadUnReadMsgTips"] then
				self.groupButton[groupType].paopao:setVisible(true)
				self.whisperView:updatePeerPaopaoList(groupType)
			end
		end	
	end			
end	

function ChatView:changeChatChannel(channel, groupType, index)
	self.editBox:setText(" ")
	if channel == ChatObjectTypes.GM then
		self.editBox:setMaxLength(100)
	else
		self.editBox:setMaxLength(20)
	end
	
	if channel == ChatObjectTypes.Private then 	
		self.richLabel:setVisible(false)
		if groupType == nil then
			groupType = G_getHero():getChatMgr():getCurrentGroup()
		end
		if index == nil then
			index = 1
		end
		self.whisperView:changePeerGroup(groupType, index)
		self.groupTabView:setSelIndex(groupType-1)
		self.groupButton[groupType].paopao:setVisible(false)
		self.whisperView:setVisible(true)
	else
		self.richLabel:setVisible(true)
		self.groupTabView:setAllUnSel()
		self.whisperView:setVisible(false)
	end
	if channel > ChatObjectTypes.None and channel < ChatObjectTypes.Max then 
		self.curObjectType = channel
		self:showChatInfoByObjectType(self.curObjectType)	
		self:heightLightChatChannel(self.curObjectType)		
	end
end	

function ChatView:isMessageEmpty()
	local msg = self.editBox:getText()
	if ChatUtils.Instance:trim(msg) == "" or self:isMsgIllegal(msg)==false then 
		return true
	end
	return false
end

function ChatView:gmMailSuccess()
	local chatObject = ChatObject.New()		
	chatObject:setContent(Config.Words[456])
	chatObject:setType(ChatObjectTypes.System)
	self.chatMgr:addContent(chatObject)
	GlobalEventSystem:Fire(GameEvent.EventUpdateChatView, self.chatMgr:getEndIndex())
end
