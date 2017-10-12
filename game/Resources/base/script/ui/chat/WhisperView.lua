--[[
----私聊界面
--]]

WhisperView = WhisperView or BaseClass(BaseUI)

local scale = VisibleRect:SFGetScale()
local rootNodeSize = VisibleRect:getScaleSize(CCSizeMake(830, 360))
local whisperListViewSize = VisibleRect:getScaleSize(CCSizeMake(204, 273))
local leftBgSize = CCSizeMake(whisperListViewSize.width, 342*scale)
local rightBgSize = CCSizeMake(593*scale, leftBgSize.height)
local cellSize = CCSizeMake(whisperListViewSize.width, whisperListViewSize.height/3)
local logChatContentSize = VisibleRect:getScaleSize(CCSizeMake(593, 111))

local ProfessionGender_Table_otherPlayer =
{
[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "main_headManWarior.png", tOffset = ccp(0,3)},
[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "main_headFemanWarior.png", tOffset = ccp(1,9)},
[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "main_headManMagic.png", tOffset = ccp(1,4)},
[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "main_headFemanMagic.png", tOffset = ccp(0,5)},
[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "main_headManDaoshi.png", tOffset = ccp(0,12)},
[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "main_headFemanDaoshi.png", tOffset = ccp(-1,11)}
}

function WhisperView:__init()
	self.infoTag = {
	name = 100,
	online = 101,
	head = 102,
	headBg = 103,
	}
	
	self.unReadMsgTips = {}  --未读消息有泡泡
	self.peerPaopaoList	= {}
	self.selectFrame = createScale9SpriteWithFrameNameAndSize(RES("squares_serverSelectedFrame.png"), CCSizeMake(whisperListViewSize.width, whisperListViewSize.height/3))
	self.selectFrame:retain()
	
	self.curSel = 0
	
	self:createRootNode()
	self:createWhisperListView()
	self:createTargetInfo()
	self:createChatLogView()
end

function WhisperView:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
	if self.selectFrame then
		self.selectFrame:release()
		self.selectFrame = nil
	end
	for k,v in pairs(self.peerPaopaoList) do
		v:removeFromParentAndCleanup(true)
		v = nil
	end
	self.peerPaopaoList	= {}
end

function WhisperView:getRootNode()
	return self.rootNode
end

function WhisperView:createRootNode()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(rootNodeSize)
	self.rootNode:setVisible(false)
	
	self.leftBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), leftBgSize)
	self.rootNode:addChild(self.leftBg)
	VisibleRect:relativePosition(self.leftBg, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(9, -10))
	
	self.rightBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), rightBgSize)
	self.rootNode:addChild(self.rightBg)
	VisibleRect:relativePosition(self.rightBg, self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE, ccp(8, 0))
end

function WhisperView:createWhisperList()
	local dataHandler = function(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == kTableCellSizeForIndex then
			data:setSize(CCSizeMake(whisperListViewSize.width, whisperListViewSize.height/3))
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(CCSizeMake(whisperListViewSize.width, whisperListViewSize.height/3))
			return 1
		elseif eventType == kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(cellSize)
				cell:setIndex(index)
				local node = self:createCell(index)
				if node then
					cell:addChild(node)					
				end
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(cellSize)
				tableCell:setIndex(index)
				local node = self:createCell(index)
				if node then
					tableCell:addChild(node)					
				end
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			local groupType = G_getHero():getChatMgr():getCurrentGroup()
			local peerGroupList = G_getHero():getChatMgr():getOneGroup(groupType)
			local cnt = 0
			if peerGroupList then
				cnt = table.size(peerGroupList)
			end
			data:setIndex(cnt)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		local index = cell:getIndex()
		self:handleCellClick(index+1)
		return 1
	end
	
	--创建tableview
	self.chatTable = createTableView(dataHandler,VisibleRect:getScaleSize(whisperListViewSize))
	self.chatTable:reloadData()
	self.chatTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.chatTable:setTableViewHandler(tableDelegate)
	self.leftBg:addChild(self.chatTable)
	VisibleRect:relativePosition(self.chatTable, self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, -3))
end

function WhisperView:changePeerGroup(groupType, index)
	if groupType == PeerGroupType.Enemy then
		self.addBtn:setVisible(false)
	else
		self.addBtn:setVisible(true)
	end
	
	G_getHero():getChatMgr():setCurrentGroup(groupType)
	self:updatePeerList()
	if index then
		self:handleCellClick(index)
	end			
end

function WhisperView:handleCellClick(index)
	local groupType = G_getHero():getChatMgr():getCurrentGroup()
	local onePeer = G_getHero():getChatMgr():getOnePeer(groupType, index)	
	if onePeer then
		G_getHero():getChatMgr():setCurrentPeer(index)
		--添加选中框
		if self.selectFrame and self.selectFrame:getParent() then
			self.selectFrame:removeFromParentAndCleanup(true)
		end
		local cell = self.chatTable:cellAtIndex(index-1)
		if cell then
			cell = tolua.cast(cell,"SFTableViewCell")
			--self.chatTable:scroll2Cell(index-1, false)
			cell:addChild(self.selectFrame)
			VisibleRect:relativePosition(self.selectFrame, cell, LAYOUT_CENTER)
		end
		
		--取消未读消息提示
		local groupType, peerIndex = G_getHero():getChatMgr():getGroupTypeAndIndexById(onePeer.playerId)		
		if self.unReadMsgTips[groupType] then
			self.unReadMsgTips[groupType][onePeer.playerId] = nil
			if self.peerPaopaoList[onePeer.playerId] then
				self.peerPaopaoList[onePeer.playerId]:setVisible(false)
			end
		end	
	end
	--更新头像信息
	self:updatePeerInfo(onePeer)
	--更新聊天记录
	if onePeer and onePeer.playerId then
		local chatData = G_getHero():getChatMgr():getChatService():getChatData(G_getHero():getId(), onePeer.playerId)
		if chatData then
			self:updateText(chatData)
		else
			self:updateText()
		end	
	else
		self:updateText()	
	end
end

--私聊列表框
function WhisperView:createWhisperListView()
	self:createWhisperList()
	
	--添加按钮
	self.addBtn = createButtonWithFramename(RES("chat_nomal_btn.png"), RES("chat_select_btn.png"))
	self.leftBg:addChild(self.addBtn)
	VisibleRect:relativePosition(self.addBtn, self.chatTable, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
	local addLabel = createSpriteWithFrameName(RES("chat_add_label.png"))
	self.addBtn:addChild(addLabel)
	VisibleRect:relativePosition(addLabel, self.addBtn, LAYOUT_CENTER)
	local onClick = function()
		local getName = function (arg,text,id)
			if id == 2 then   --确定
				local chatMgr = G_getHero():getChatMgr()
				if text ~= chatMgr:getHeroName() then
					GlobalEventSystem:Fire(GameEvent.EventUpdateWhisperView)
					local groupType = G_getHero():getChatMgr():getCurrentGroup()
					chatMgr:requestAddOnePlayer(groupType, text)
				else
					UIManager.Instance:showSystemTips(Config.Words[440])
				end
			end
		end
		UIManager.Instance:showMsgBoxWithEdit(Config.Words[430], self, getName)
	end
	self.addBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
end

function WhisperView:createCell(index)
	local groupType = G_getHero():getChatMgr():getCurrentGroup()
	local onePeer = G_getHero():getChatMgr():getOnePeer(groupType, index+1)
	if onePeer then
		local node = self:createWhisperInfoNode(onePeer)
		--选中框
		local curSel = G_getHero():getChatMgr():getCurrentPeer()
		if curSel == index then
			if self.selectFrame and self.selectFrame:getParent() then
				self.selectFrame:removeFromParentAndCleanup(true)
			end
			node:addChild(self.selectFrame)
			VisibleRect:relativePosition(self.selectFrame, node, LAYOUT_CENTER)
		end
	
		local paopao = createSpriteWithFrameName(RES("paopao.png"))
		paopao:setVisible(false)
		node:addChild(paopao)
		VisibleRect:relativePosition(paopao, node, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-8, 5))
		self.peerPaopaoList[onePeer.playerId] = paopao
		return node
	end
end

function WhisperView:createWhisperInfoNode(onePeer)
	local infoNode = CCNode:create()
	infoNode:setContentSize(cellSize)
	--头像背景
	local headBg = createSpriteWithFrameName(RES("common_circle_bg.png"))
	headBg:setTag(self.infoTag.headBg)
	infoNode:addChild(headBg)
	VisibleRect:relativePosition(headBg, infoNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(15, -5))
	
	local name, online, head = "", "", ""
	if onePeer then	
		--头像信息
		for k, v in pairs(ProfessionGender_Table_otherPlayer) do
			if v.tProfession==onePeer.proId and v.tGender==onePeer.gender then
				head = createSpriteWithFrameName(RES(v.tImage))
				head:setScale(0.7)
				head:setTag(self.infoTag.head)
				infoNode:addChild(head)
				VisibleRect:relativePosition(head, headBg, LAYOUT_CENTER, v.tOffset)
				break
			end
		end
		local chatMgr = G_getHero():getChatMgr()
		--名字, 是否在线
		if onePeer.online == 1 then
			online = createLabelWithStringFontSizeColorAndDimension(Config.Words[432], "Arial", FSIZE("Size3"), FCOLOR("ColorOrange3"))
			name = createLabelWithStringFontSizeColorAndDimension(onePeer.playerName, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		else
			online = createLabelWithStringFontSizeColorAndDimension(Config.Words[433], "Arial", FSIZE("Size3"), FCOLOR("ColorBlack4"))
			name = createLabelWithStringFontSizeColorAndDimension(onePeer.playerName, "Arial", FSIZE("Size3"), FCOLOR("ColorBlack4"))
		end
	else
		online = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorOrange3"))
		name = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	end
	if name~="" and online ~="" then
		name:setTag(self.infoTag.name)
		online:setTag(self.infoTag.online)
		infoNode:addChild(name)
		infoNode:addChild(online)
		VisibleRect:relativePosition(name, headBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(10, 13))
		VisibleRect:relativePosition(online, name, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -3))
	end
	
	return infoNode
end	

function WhisperView:setUnReadMsgTips(lastContractId)
	if lastContractId  then
		local groupType, peerIndex = G_getHero():getChatMgr():getGroupTypeAndIndexById(lastContractId)
		if groupType and peerIndex then
			if self.unReadMsgTips[groupType] == nil then
				self.unReadMsgTips[groupType] = {}				
			end	
			self.unReadMsgTips[groupType][lastContractId] = true
			self.unReadMsgTips[groupType]["hadUnReadMsgTips"] = true
		end
	end
end

--更新左边内容
function WhisperView:updatePeerList()
	self.chatTable:reloadData()
end	

function WhisperView:updatePeerListCell(index)
	self.chatTable:updateCellAtIndex(index)
end

--更新伙伴信息
function WhisperView:updatePeerInfo(onePeer)
	if self.heroNode then
		local name = self.heroNode:getChildByTag(self.infoTag.name)
		local online = self.heroNode:getChildByTag(self.infoTag.online)
		local headBg = self.heroNode:getChildByTag(self.infoTag.headBg)
		self.heroNode:removeChildByTag(self.infoTag.head, true)		
		if name and online then
			name = tolua.cast(name, "SFLabel")
			online = tolua.cast(online, "SFLabel")
			if onePeer == nil then
				name:setString(" ")
				online:setString(" ")
				self.targetInfoNode:setVisible(false)
			else				
				name:setString(onePeer.playerName)		
				--是否在线
				if onePeer.online==1 then
					online:setString(Config.Words[432])
				else
					online:setString(Config.Words[433])
				end
				for k, v in pairs(ProfessionGender_Table_otherPlayer) do
					if v.tProfession==onePeer.proId and v.tGender==onePeer.gender then
						head = createSpriteWithFrameName(RES(v.tImage))
						head:setScale(0.7)
						head:setTag(self.infoTag.head)
						self.heroNode:addChild(head)
						VisibleRect:relativePosition(head, headBg, LAYOUT_CENTER, v.tOffset)
						break
					end
				end
				self.targetInfoNode:setVisible(true)
			end
			VisibleRect:relativePosition(name, headBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(10, 13))
			VisibleRect:relativePosition(online, name, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -3))
		end				
	end
end

function WhisperView:updateText(text)
	local formatText = ""
	if text and type(text)=="table" then
		local size = table.size(text)
		for i=size, 1, -1 do
			if text[i] then
				formatText = formatText .. text[i]
			end
		end
	end
	self.richLabel:clearAll()
	self.richLabel:appendFormatText(formatText)
	
	local size = self.richLabel:getContentSize()
	local scrollViewSize = self.scrollView:getViewSize()
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

function WhisperView:updatePeerPaopaoList(groupType)
	if self.unReadMsgTips[groupType] then
		for k,v in pairs(self.unReadMsgTips[groupType]) do
			if self.peerPaopaoList[k] then
				self.peerPaopaoList[k]:setVisible(true)	
				local chatData = G_getHero():getChatMgr():getChatService():getChatData(G_getHero():getId(), k)
				if chatData then
					self:updateText(chatData)
				else
					self:updateText()
				end
			end
		end	
	end				
end

--私聊的聊天记录
function WhisperView:createTargetInfo()
	self.targetInfoNode = CCNode:create()
	local size = VisibleRect:getScaleSize(CCSizeMake(593, 111))
	self.targetInfoNode:setContentSize(size)
	self.rightBg:addChild(self.targetInfoNode)
	VisibleRect:relativePosition(self.targetInfoNode, self.rightBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X)
	
	local bg = createScale9SpriteWithFrameNameAndSize(RES("faction_contentBg.png"), CCSizeMake(size.width-18, size.height-18))
	self.targetInfoNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.targetInfoNode, LAYOUT_CENTER)
	
	self.heroNode = self:createWhisperInfoNode()
	self.targetInfoNode:addChild(self.heroNode)
	VisibleRect:relativePosition(self.heroNode, self.targetInfoNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(15, 0))
	
	--删除按钮
	local delBtn = createButtonWithFramename(RES("chat_nomal_btn.png"), RES("chat_select_btn.png"))
	self.targetInfoNode:addChild(delBtn)
	VisibleRect:relativePosition(delBtn, self.targetInfoNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y, ccp(-20, 0))
	local delLabel = createSpriteWithFrameName(RES("chat_delete_label.png"))
	delBtn:addChild(delLabel)
	VisibleRect:relativePosition(delLabel, delBtn, LAYOUT_CENTER)
	local onClickDel = function()
		local groupType = G_getHero():getChatMgr():getCurrentGroup()
		local curSel = G_getHero():getChatMgr():getCurrentPeer()
		local onePeer = G_getHero():getChatMgr():getOnePeer(groupType, curSel)
		if onePeer then	
			G_getHero():getChatMgr():requestDeleteOnePlayer(groupType, onePeer.playerName)
		end
	end
	delBtn:addTargetWithActionForControlEvents(onClickDel, CCControlEventTouchDown)
	
	--查看按钮
	local lookBtn = createButtonWithFramename(RES("chat_nomal_btn.png"), RES("chat_select_btn.png"))
	self.targetInfoNode:addChild(lookBtn)
	VisibleRect:relativePosition(lookBtn, delBtn, LAYOUT_LEFT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(-20, 0))
	local lookLabel = createSpriteWithFrameName(RES("chat_look_label.png"))
	lookBtn:addChild(lookLabel)
	VisibleRect:relativePosition(lookLabel, lookBtn, LAYOUT_CENTER)
	local onClickLook = function()	
		local groupType = G_getHero():getChatMgr():getCurrentGroup()
		local curSel = G_getHero():getChatMgr():getCurrentPeer()
		local onePeer = G_getHero():getChatMgr():getOnePeer(groupType, curSel)
		if onePeer then
			G_getHero():getChatMgr():showPeerInfo(onePeer.playerId)			
		end
	end
	lookBtn:addTargetWithActionForControlEvents(onClickLook, CCControlEventTouchDown)
end

function WhisperView:createChatLogView()
	local size = self.targetInfoNode:getContentSize()
	size = CCSizeMake(size.width, 215*scale)
	self.scrollView = createScrollViewWithSize(size)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self.rightBg:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self.rightBg, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 2))
	
	self.richLabel = createRichLabel(CCSizeMake(size.width-20,0))
	self.richLabel:setFontSize(FSIZE("Size3"))
	self.richLabel:setTouchEnabled(true)
	--self.richLabel:setEventHandler(G_chatRichLabelHandler)
	
	self.containerNode = CCNode:create()
	self.containerNode:setContentSize(size)
	self.containerNode:addChild(self.richLabel)
	VisibleRect:relativePosition(self.richLabel,self.containerNode,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(0,0))
	
	self.scrollView:setContainer(self.containerNode)
end

function WhisperView:setVisible(bVisible)
	self.rootNode:setVisible(bVisible)
end

function WhisperView:isVisible()
	return self.rootNode:isVisible()
end

function WhisperView:getCurSel()
	return self.curSel
end