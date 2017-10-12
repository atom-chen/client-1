require "ui.UIManager"
require "ui.chat.ChatUtils"

MainChat = MainChat or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local scale = VisibleRect:SFGetScale()
local viewSize = VisibleRect:getScaleSize(CCSizeMake(338, 50))
local cellSize = CCSizeMake(viewSize.width-20, viewSize.height)


function MainChat:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)				
	
	self:initVariable()
	self:createRichLable()
	self:ShowMainChat()	
end

function MainChat:initVariable()
	self.bshowChat = true
	self.chatMgr = GameWorld.Instance:getEntityManager():getHero():getChatMgr()
	self.chatContent = {curMsg = "", preMsg = ""}	
	
	--tableview数据源的类型
	self.eventType = {}	
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
end

function MainChat:__delete()
	if self.richLabel then 
		self.richLabel:release()
		self.richLabel = nil
	end
end

function MainChat:createRichLable()
	if not self.richLabel then
		self.richLabel= createRichLabel(CCSizeMake(viewSize.width-20,0))
		self.richLabel:setGaps(0)
		self.richLabel:setFontSize(FSIZE("Size4"))
		self.richLabel:retain()			
	end
end		

function MainChat:ShowMainChat()
	--背景
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"),viewSize)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(60, 25))
	
	--tableview的数据源
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createItem(index)
				if item ~= nil then
					cell:addChild(item)
					VisibleRect:relativePosition(item, cell, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(20, 0))
				end
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createItem(index)
				if item ~= nil then
					tableCell:addChild(item)
					VisibleRect:relativePosition(item, tableCell, LAYOUT_TOP_INSIDE+LAYOUT_CENTER, ccp(20, 0))
				end
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(1)
			return 1
		end
	end
	
	--创建tableview
	self.chatTable = createTableView(dataHandler,viewSize)
	self.chatTable:reloadData()
	self.chatTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.rootNode:addChild(self.chatTable)
	VisibleRect:relativePosition(self.chatTable, self.bg, LAYOUT_CENTER)	
end		

-------------------------public------------------------
function MainChat:getShowChatState()
	return self.bshowChat
end

function MainChat:setShowChatstate(state)
	self.bshowChat = state
end

function MainChat:getRootNode()
	return self.rootNode
end	

function MainChat:setChatContent(content)
	self.chatContent = content
end

function MainChat:getChatContent()
	return self.chatContent
end
-----------------------privare -------------------
function MainChat:createItem(index)
	if self.chatContent.curMsg and self.chatContent.preMsg then 
		local preMsg = self:removeTime(self.chatContent.preMsg) or ""
		local curMsg = self:removeTime(self.chatContent.curMsg) or ""
		local showMsg = preMsg .. curMsg
		self.richLabel:clearAll()
		self.richLabel:appendFormatText(showMsg)
		local lableSize = self.richLabel:getContentSize()
		print("1:"..lableSize.height.." 2:"..viewSize.height)
		if lableSize.height > 80 then
			showMsg = curMsg
			self.richLabel:clearAll()
			self.richLabel:appendFormatText(showMsg)
		end
	end
	return self.richLabel
end	

function MainChat:showMyself()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,visibleSize.height/3))
	self.rootNode:runAction(moveBy)
end

function MainChat:hideMyself()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,-visibleSize.height/3))
	self.rootNode:runAction(moveBy)
end

function MainChat:removeTime(msg)
	if msg then 
		local len = string.len(msg)
		if len < 22 then 
			return 
		end
		msg = string.reverse(msg)
		local time = string.match(msg, "%d%d:%d%d:%d%d")			
		if time then 
			msg = string.gsub(msg, "%d%d:%d%d:%d%d", "")
		end
		msg = string.reverse(msg)
	end
	return msg
end
