require("common.baseclass")

AutoPathListView = AutoPathListView or BaseClass()

function  AutoPathListView:__init()
	self.contentSize = CCSizeMake(275,448)
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(self.contentSize)
	self.rootNode:retain()
	self.background = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),self.contentSize)
	self.rootNode:addChild(self.background)
	VisibleRect:relativePosition(self.background,self.rootNode,LAYOUT_CENTER)
	self.cellSize = CCSizeMake(275,65)
	self.box = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"),self.cellSize)
	self.box:retain()
	self.dataList = {}
	self.listView = nil	
	self:createTableView()
	self:updateView()
	self.selectedIndex = -1
end



function AutoPathListView:updateDataList()
	local mapManager = GameWorld.Instance:getSmallMapManager()
	self.dataList = mapManager:margeData()	
end

function AutoPathListView:updateShowData()
	self.showList = {}	
	for k,v in pairs(self.dataList) do
		table.insert(self.showList,v)
		if v.isOpen then
			for subK,subV in pairs(v.data) do
				table.insert(self.showList,subV)
			end
		end
	end
end

function AutoPathListView:needLayout()
	self:updateShowData()
	self.listView:reloadData()
	self.listView:scroll2Cell(0,false)
	self:shwoTips()
end

function AutoPathListView:shwoTips()
	if table.size(self.dataList)>0 then
		if self.tips then
			self.tips:setVisible(false)
		end
	else
		if not self.tips then
			self.tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[902],"Arial", FSIZE("Size5"), FCOLOR("ColorWhite1"))
			self.rootNode:addChild(self.tips)
			VisibleRect:relativePosition(self.tips,self.rootNode,LAYOUT_CENTER)
			self.tips:setVisible(true)
		else
			self.tips:setVisible(true)
		end			
	end
end

function AutoPathListView:updateView()
	self:updateDataList()
	self:needLayout()	
end

function AutoPathListView:onEnter()
	self.selectedIndex = -1
	self.listView:scroll2Cell(0,false)
	self:updateView()
end

function AutoPathListView:createTableView()
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	local cellSize = self.cellSize
	local tDataHandlerfunc = function(eventType,tableP,index,data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(cellSize)
			return 1
		elseif eventType == kTableCellAtIndex then
			--todo
			local tableCell = SFTableViewCell:create()
			self:createCellWithData(tableCell,cellSize,index)
			data:setCell(tableCell)
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			data:setIndex(table.size(self.showList))
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self:handleTableViewTouchEvent(tableP,cell,x,y)
	end
	self.listView = createTableView(tDataHandlerfunc,self.contentSize)
	self.listView:setTableViewHandler(tableDelegate)
	self.rootNode:addChild(self.listView)
	self.listView:reloadData()
	VisibleRect:relativePosition(self.listView,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER)
end

function AutoPathListView:createCellWithData(cell,cellSize,index)
	if not cell or not cellSize or not index then
		return
	end
	local gameMapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = gameMapManager:getCurrentMapRefId()
	cell:removeAllChildrenWithCleanup(true)
	cell:setContentSize(cellSize)
	cell:setIndex(index)
	
	local showData = self.showList[index+1]
	if showData.isRoot then
		local background = createScale9SpriteWithFrameNameAndSize(RES("faction_labelBg.png"),self.cellSize)
		VisibleRect:relativePosition(background,cell,LAYOUT_CENTER)
		cell:addChild(background)	
		local indicator = createSpriteWithFrameName(RES("map_indicator.png"))		
		if showData.isOpen then
			indicator:setRotation(0)
		else
			indicator:setRotation(180)		
		end
		cell:addChild(indicator)
		VisibleRect:relativePosition(indicator,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-10,0))	
	end
	local name = showData.name
	local label = createLabelWithStringFontSizeColorAndDimension(name,Config.fontName.fontName1,FSIZE("Size5"),showData.color)
	VisibleRect:relativePosition(label,cell,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(20, 0))
	cell:addChild(label)	
	
	if not showData.isRoot then
		if self.selectedIndex == index then
			self:addBoxToCell(cell)
		end
		local flyButton = createButtonWithFramename(RES("map_shoes.png"),RES("map_shoes.png"))
		VisibleRect:relativePosition(flyButton,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-10,0))
		local flyToFunction = function ()
			local ret, reason = gameMapManager:checkCanUseFlyShoes(true)
			if ret then
				if showData.isTransfer then
					gameMapManager:requestTransfer(currentMapRefId, showData.x,showData.y-4,1)
				else
					gameMapManager:requestTransfer(currentMapRefId, showData.x,showData.y,1)
				end
				self.selectedIndex = index
				self.listView:updateCellAtIndex(index)
				G_getHandupMgr():stop()	
			elseif reason == CanNotFlyReason.Other then
				UIManager.Instance:showSystemTips(Config.Words[13022])
			end
					
		end
		flyButton:addTargetWithActionForControlEvents(flyToFunction,CCControlEventTouchDown)
		cell:addChild(flyButton)
	end
		
	local line = createScale9SpriteWithFrameNameAndSize(RES("forge_task_left_line.png"),CCSizeMake(298,2))
	cell:addChild(line)
	VisibleRect:relativePosition(line,cell,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)
	
end

function AutoPathListView:makeItCenter(target,parent)
	if not target or not parent then
		return
	end
	local parentSize = parent:getContentSize()
	local targetSize = target:getContentSize()
	
end

function AutoPathListView:addBoxToCell(cell)
	if not cell then
		return
	end
	if self.box:getParent() == cell then
		return cell
	elseif self.box:getParent() ~= nil then
		self.box:removeFromParentAndCleanup(false)
		cell:addChild(self.box)
		VisibleRect:relativePosition(self.box,cell,LAYOUT_CENTER)
	else
		cell:addChild(self.box)
		VisibleRect:relativePosition(self.box,cell,LAYOUT_CENTER)
	end
end

function AutoPathListView:handleTableViewTouchEvent(tableP,cell,x,y)
	
	local index = cell:getIndex()
	self.selectedIndex = index
	local data = self.showList[index+1]

	if data then
		if data.isRoot then
			data.isOpen = not data.isOpen
			if data.isOpen then			
				for k,v in pairs(self.dataList) do
					if v ~= data then
						v.isOpen = false
					end
				end
			end
			self:needLayout()
		else
			local autoPath = GameWorld.Instance:getAutoPathManager()
			local cellX,cellY = data.x,data.y
			autoPath:moveToPosition(cellX,cellY)
			G_getHandupMgr():stop()			
			self.listView:updateCellAtIndex(index)
		end	
	else
		self.listView:updateCellAtIndex(index)
	end		
	
end

function AutoPathListView:getRootNode()
	return self.rootNode
end

function AutoPathListView:__delete()
	self.rootNode:removeAllChildrenWithCleanup(true)
	self.rootNode:release()
	self.box:release()
	self.dataList = nil
	self.showList = nil
	self.cellSize = nil
	self.listView = nil
	self.rootNode = nil
	self.box = nil
end