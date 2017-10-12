require "ui.chat.ChatUtils"

ChatObjectNode = ChatObjectNode or BaseClass()

local chatObjectPng = {
[1] = "chat_worldObj.png",
[2] = "chat_currentObj.png",
[3] = "chat_sociatyObj.png",
[4] = "chat_privateObj.png",
[5] = "char_HornObj.png",
[6] = "GM邮件",   --gm邮件
}

local rootNodeSize = CCSizeMake(110, 31*(table.size(chatObjectPng)+1)) 
local cellSize = CCSizeMake(rootNodeSize.width, 23) 

function ChatObjectNode:__init()
	self:initVariable()
	self:createRootNode()
	self:createObjectTable()
end

function ChatObjectNode:initVariable()
	self.chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	--tableview数据源的类型
	self.eventType = {}
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
end

function ChatObjectNode:createRootNode()
	--rootNode
	self.rootNode = CCLayer:create()
	self.rootNode:setVisible(false)
	self.rootNode:setContentSize(rootNodeSize)
	self.rootNode:setTouchEnabled(true)
	--背景
	local bg = createScale9SpriteWithFrameNameAndSize(RES("commom_editFrame.png"), rootNodeSize)
	self.rootNode:addChild(bg)	
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)		
end

function ChatObjectNode:getRootNode()
	return self.rootNode
end

function ChatObjectNode:createObjectTable()
	local dataHandler = function(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(CCSizeMake(cellSize.width, cellSize.height+10))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell = self:createCellContent(cell, index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell = self:createCellContent(tableCell, index)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(table.size(chatObjectPng))
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		local index = cell:getIndex()
		self:handleCellClick(index)
	end
	
	--创建tableview
	self.chatTable = createTableView(dataHandler,VisibleRect:getScaleSize(rootNodeSize))
	self.chatTable:reloadData()
	self.chatTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.chatTable:setTableViewHandler(tableDelegate)
	self.rootNode:addChild(self.chatTable)
	VisibleRect:relativePosition(self.chatTable, self.rootNode, LAYOUT_CENTER, ccp(0, -6))
end


function ChatObjectNode:createCellContent(cell, index)
	cell:setContentSize(cellSize)
	local item = self:createItem(index)
	cell:addChild(item)
	VisibleRect:relativePosition(item, cell, LAYOUT_CENTER)
	cell:setIndex(index)	
	return cell
end

function ChatObjectNode:createItem(index)
	local png = chatObjectPng[index+1]
	if png then 
		local sprite
		if string.match(png, "png") then
			sprite = createSpriteWithFrameName(RES(png))
		else
			sprite = createLabelWithStringFontSizeColorAndDimension(png, "Arial", FSIZE("Size4"), FCOLOR("ColorYellow1"))		
		end
		return sprite		
	end
end


function ChatObjectNode:handleCellClick(index)
	if self.rootNode:isVisible() == false then
		return
	end		
	local objectType = ChatObjectTypes.None
	if index == 0 then  --世界
		objectType = ChatObjectTypes.World
	elseif index == 1 then  --当前
		objectType = ChatObjectTypes.Current
	elseif index == 2 then  --公会		
		if ChatUtils.Instance:isJoinSociety(true) == false then 
			self:setVisible(false)
			return
		end
		objectType = ChatObjectTypes.Society
	elseif index == 3 then  --私聊		
		self:getWhisperName()
		self:setVisible(false)
		return
	elseif index == 4 then  --喇叭
		objectType = ChatObjectTypes.Horn
	elseif index == 5 then  --gm邮件
		objectType = ChatObjectTypes.GM
	end		
	GlobalEventSystem:Fire(GameEvent.EventChangeChatObject, objectType)  --聊天对象改变
	
	self:setVisible(false)	
end

function ChatObjectNode:setVisible(bShow)
	self.rootNode:setVisible(bShow)
end

function ChatObjectNode:isVisible()
	return self.rootNode:isVisible()
end

--弹出对话框 获取要私聊的name
function ChatObjectNode:getWhisperName()
	local getName = function (arg,text,id)
		if id == 2 then   --确定		
			if text ~= self.chatMgr:getHeroName() then 
				self.chatMgr:requestPeerId(text)
			else	
				UIManager.Instance:showSystemTips(Config.Words[453])
			end
		end
	end
	UIManager.Instance:showMsgBoxWithEdit(Config.Words[430], self, getName)		
end
