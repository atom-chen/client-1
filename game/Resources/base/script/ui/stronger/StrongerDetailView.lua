require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.stronger.StrongerDef")
require("ui.stronger.cell.NeedStrongerCell")
require("ui.stronger.cell.MaterialStrongCell")
StrongerDetailView = StrongerDetailView or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local const_cellSize = CCSizeMake(616, 105)
local const_viewSize = CCSizeMake(616, 440)

function StrongerDetailView:__init()	
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_viewSize)
	self.rootNode:retain()
	
	self.cellMap = {}
	self.contentList = {}
	self.isWaitingAllCellsReady = false
	self:initBg()
	self:initTableView()	
end

function StrongerDetailView:__delete()
	self:releaseAllDataCells()
	self.rootNode:release()	
end

function StrongerDetailView:getCell(refId)
	return self.cellMap[refId]
end

function StrongerDetailView:getRootNode()
	return self.rootNode
end

function StrongerDetailView:setContent(list)
	self.tabelView:setVisible(false)
	self.tabelView:scroll2Cell(0, false)
	self:releaseAllDataCells()
	if type(list) ~= "table" then
		return
	end
	self.contentList = list
	self:createAllDataCells()		
	if not self:showIfAllCellsReady() then
		self:waitAllCellsReady()		
	end
end

----------------------内部接口----------------------

--将推荐的置顶
function StrongerDetailView:rearrangeContentList()
	local newList = {}
	for k, v in ipairs(self.contentList) do				--先把推荐的置顶
		local cell = self:getCell(v)
		if cell and cell:isRecommended() then
			table.insert(newList, v)
		end
	end
	for k, v in ipairs(self.contentList) do				
		local cell = self:getCell(v)
		if (not cell) or (not cell:isRecommended()) then
			table.insert(newList, v)
		end
	end
	self.contentList = newList
end
	
--清除所有缓存的cell
function StrongerDetailView:releaseAllDataCells()
	for k, v in pairs(self.cellMap) do
		v:DeleteMe()		
	end
	self.cellMap = {}
end

function StrongerDetailView:initBg()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), const_viewSize)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
	end

function StrongerDetailView:initTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.tabelView = createTableView(dataHandler, const_viewSize)
	self.tabelView:setTableViewHandler(tableDelegate)
	self.tabelView:setClippingToBounds(true)
	self.rootNode:addChild(self.tabelView)
	VisibleRect:relativePosition(self.tabelView, self.rootNode, LAYOUT_CENTER)	
	self.tabelView:reloadData()
end

function StrongerDetailView:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kTableCellAtIndex then		
		data:setCell(self:createTableCell(tableView, index))
		return 1
	elseif eventType == kNumberOfCellsInTableView then
		if table.size(self.contentList) == 0 then
			data:setIndex(4)			
		else
			data:setIndex(table.size(self.contentList))			
		end
		return 1
	end
	return 0
end

function StrongerDetailView:createTableCell(tableView, index)
	local cell = tableView:dequeueCell(index)		
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_cellSize)
		cell:setIndex(index)					
	else
		cell:removeAllChildrenWithCleanup(true)		
	end
	
	if self.contentList[index + 1] then
		local node = self:getAndClearDataCell(self.contentList[index + 1])
		if node then 
			node = node:getRootNode()
		end
		if node then
			cell:addChild(node)	
			VisibleRect:relativePosition(node, cell, LAYOUT_CENTER)
		end
	end
	return cell
end

function StrongerDetailView:tableViewDelegate(tableView, cell, x, y)
	tableView = tolua.cast(tableView, "SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")

	local index = cell:getIndex()
	local refId = self.contentList[index + 1]
	if not refId then
		return
	end
	
	local dataCell = self.cellMap[refId]
	if (dataCell) then	
		dataCell:onClick()
	end
end

--根据途径refId获取cell
function StrongerDetailView:getAndClearDataCell(refId)	
	if not refId then
		return nil
	end 
	local cell = self.cellMap[refId]
	if cell then
		cell:getRootNode():removeFromParentAndCleanup(true)
	end
	return cell
end

--创建所有的cell
function StrongerDetailView:createAllDataCells()
	if type(self.contentList) ~= "table" then
		return
	end
	
	--一个cell的ready回调
	local onCellReady = function(cellRefId, bReady)
		if self.isWaitingAllCellsReady then
			self:showIfAllCellsReady()
		end
	end
	for k, v in pairs(self.contentList) do
		local cell = self:createDataCell(v)
		self.cellMap[v] = cell
		cell:setReadyNotify(onCellReady)
	end
end

--创建具体的cell。比如boss/副本等
function StrongerDetailView:createDataCell(refId)
	if not refId then
		return nil
	end
	local cell 
	if string.find(refId,"strong") then --变强
		cell = NeedStrongerCell.New(const_cellSize, refId)
	else
		cell = MaterialStrongCell.New(const_cellSize, refId)
	end		
	return cell
end

function StrongerDetailView:waitAllCellsReady()
	self:removeWaitingSchId()
	self.isWaitingAllCellsReady = true
	local onTimeout = function()
		CCLuaLog("StrongerDetailView:waitAllCellsReady timeout. now force show")
		UIManager.Instance:showSystemTips(Config.Words[26000])		
		GameWorld.Instance:getStrongerMgr():clearReadyCallBack()
		self:removeWaitingSchId()
		self:reload()
	end
	self.waitingSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 3, false)
	UIManager.Instance:showLoadingHUD(6)	
end

function StrongerDetailView:removeWaitingSchId()
	if self.waitingSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.waitingSchId)
		self.waitingSchId = nil
	end
end

--重新加载数据
function StrongerDetailView:reload()
	self.tabelView:setVisible(true)
	UIManager.Instance:hideLoadingHUD()	
	self:rearrangeContentList()
	self.tabelView:reloadData()
	self.tabelView:scroll2Cell(0, false)
	self.isWaitingAllCellsReady = false
end
	
function StrongerDetailView:showIfAllCellsReady()
	local allReady = self:isAllCellsReady()	
	if allReady then
		self:removeWaitingSchId()
		self:reload()
	end
	return allReady
end
	
function StrongerDetailView:isAllCellsReady()
	for k, v in pairs(self.cellMap) do
		if not v:isReady() then
			--print("StrongerDetailView:isAllCellsReady "..v:getRefId().." not ready")
			return false
		end
	end
	return true
end