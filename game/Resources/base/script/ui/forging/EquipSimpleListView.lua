require("ui.UIManager")
require("config.words")
require("ui.utils.EquipSimpleView")

EquipSimpleListView = EquipSimpleListView or BaseClass()

local const_cellSize = VisibleRect:getScaleSize(CCSizeMake(276, 89))
local const_size = VisibleRect:getScaleSize(CCSizeMake(276, 418))
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
	
function EquipSimpleListView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()
	
	self:initTableView()
	self.dataList = {}
	self.dataListSize = 0
	
	self.bShowFpTips = true
end

function EquipSimpleListView:__delete()
	self:releaseData()
	self.rootNode:release()	
end

function EquipSimpleListView:setSingleSelect(flag)
	self.singleSelect = flag
end

function EquipSimpleListView:getRootNode()
	return self.rootNode
end

-- 设置点击事件的回调函数
-- 回调函数参数: itemObj
function EquipSimpleListView:setTouchNotify(aarg, touchDelegate)
	self.touchDelegate = {func = touchDelegate, arg = aarg}
end

-- key为1-n, value为equipObj
function EquipSimpleListView:setEquipList(equipList, bShowFpTips)
	self.bShowFpTips = bShowFpTips
	self:releaseData()	--释放资源
	if (equipList == nil) then
		return
	end
	local size = 0
	for i, equip in pairs(equipList) do
		size = size + 1
		
		local tmp = {}
		tmp.view	= nil
		tmp.equip 	= equip
		tmp.needAdded = true
		tmp.isSelected = false
		table.insert(self.dataList, tmp)
	end
	self.dataListSize = size
	self.tabelView:reloadData()
	self.tabelView:scroll2Cell(0, false)
end

function EquipSimpleListView:releaseData()
	if (self.dataList == nil) then
		return
	end
	for i, value in pairs(self.dataList) do
		if value.view then
			value.view:DeleteMe()
			value.view = nil
		end
	end
	self.dataList = {}
end

function EquipSimpleListView:initTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.tabelView = createTableView(dataHandler, const_size)
	self.tabelView:setTableViewHandler(tableDelegate)
	self.tabelView:setClippingToBounds(true)
	self.rootNode:addChild(self.tabelView)
	VisibleRect:relativePosition(self.tabelView, self.rootNode, LAYOUT_CENTER)
	
	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_size.width, 2))
	line:setRotation(90)	
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.tabelView, LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER_Y)
end

function EquipSimpleListView:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kTableCellAtIndex then		
		data:setCell(self:createCell(tableView, index))
		return 1
	elseif eventType == kNumberOfCellsInTableView then
		data:setIndex(self.dataListSize)
		return 1
	end
end

function EquipSimpleListView:createEquipSimpleView(equip, isSelected, bShowFpTips)
	local view = EquipSimpleView.New()	 
	view:setEquip(equip, bShowFpTips)
	view:setSelected(isSelected)
	return view
end

function EquipSimpleListView:createCell(tableView, indexx)
	local cell = tableView:dequeueCell(indexx)	
	local data = self.dataList[indexx + 1]
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_cellSize)
		cell:setIndex(indexx)			
		if (data) then	
			if data.view == nil then
				data.view = self:createEquipSimpleView(data.equip, data.isSelected, self.bShowFpTips)
			end			
			local view = data.view
			data.needAdded = false	
			cell:addChild(view:getRootNode())
			VisibleRect:relativePosition(view:getRootNode(), cell, LAYOUT_CENTER)						
		end
	else
		local data = self.dataList[indexx + 1]
		if (data) then	
			if data.view == nil then
				data.view = self:createEquipSimpleView(data.equip, data.isSelected, self.bShowFpTips)
			end	
			local view = data.view		
			if (data.needAdded == true) then	
				cell:removeAllChildrenWithCleanup(true)		
				data.needAdded = false
				cell:addChild(view:getRootNode())
				VisibleRect:relativePosition(view:getRootNode(), cell, LAYOUT_CENTER)						
			end
		end
	end
	return cell
end

function EquipSimpleListView:tableViewDelegate(tableView, cell, x, y)
	tableView = tolua.cast(tableView, "SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")

	local index = cell:getIndex() + 1	
	local data = self.dataList[index]
	if (data) then
		local view = data.view
		if (self.singleSelect == true) then	
			self:unSelectAll(false)
		end
		if view then
			view:switchSelectedState()			
			if (self.touchDelegate) then				
				local equip = self.dataList[index].equip
				self:doTouchNotify(index, equip, view:getSelected())
			end			
		end
	end
end

function EquipSimpleListView:doTouchNotify(index, equip, selected)
	if (self.touchDelegate) then				
		self.touchDelegate.func(self.touchDelegate.arg, index, equip, selected)
	end
end

--取消所有选中: bNotify表示是否调用回调
function EquipSimpleListView:unSelectAll(bNotify)
	for i, data in pairs(self.dataList) do
		local isSelected
		if data.view then
			isSelected = data.view:getSelected()
			if (bNotify == true and isSelected == true) then		
				self:doTouchNotify(data.index, data.equip, false)
			end
			if (isSelected == true) then
				data.view:setSelected(false)		
			end
		end
		data.isSelected = false
	end
end

--选中所有
function EquipSimpleListView:selectAll()
	for i, data in pairs(self.dataList) do
		if data.view then
			local isSelected = data.view:getSelected()
			if (isSelected ~= true) then
				data.view:setSelected(true)		
			end
		end
		data.isSelected = true
	end
end

function EquipSimpleListView:findEquipById(id)
	for k, v in pairs(self.dataList) do
		if v.equip:getId() == id then
			return k, v
		end
	end
	return nil
end

function EquipSimpleListView:updateEquipAtIndex(index, equipObj)
	local data = self.dataList[index]
	if data and data.view then
		data.view:setEquip(equipObj, data.view:getShowFpTipsFlag())
		self.dataList[index].equip = equipObj
	end
end

--根据装备id选中某个装备
--scrollIt表示是否滑动到装备处
function EquipSimpleListView:selectByEquipId(id, selected, scrollTo, notify)
	if notify == nil then
		notify = true
	end
	
	local index, data = self:findEquipById(id)
	if index then
		if data.view then
			data.view:setSelected(selected)	
			if (scrollTo == true) then
				self.tabelView:scroll2Cell(index - 1, false)				
			end	
			if notify then
				self:doTouchNotify(index, data.equip, selected)	
			end
		end
		data.isSelected = selected		
	end
end	

function EquipSimpleListView:selectAtIndex(index, selected, scrollTo, notify)
	if notify == nil then
		notify = true
	end
	local data = self.dataList[index]
	if (data ~= nil) then
		if (self.singleSelect == true) then	
			self:unSelectAll(false)
		end
		if data.view then
			data.view:setSelected(selected)
		end
		if (scrollTo == true) then
			self.tabelView:scroll2Cell(index - 1, false)
		end			
		if notify then
			self:doTouchNotify(index, data.equip, selected)		
		end
		data.isSelected = selected
	end	
end	