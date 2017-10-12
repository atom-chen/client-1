-- 显示row * columu个物品
require("common.BaseUI")
require("config.words")
require("GameDef")
require("ui.utils.ItemView")

GridView = GridView or BaseClass()

local const_scale = VisibleRect:SFGetScale()
local const_scrollViewSize = VisibleRect:getScaleSize(CCSizeMake(380, 380))

function GridView:__init()
	self.grids 	= nil
	self.capacity 	= -1	
	self.cellSize 	= nil
	self.hSpacing 	= 0
	self.vSpacing 	= 0
	self.row 		= 3
	self.columu 	= 4
	self.pageIndex 	= 1
	self.pageCount  = 1
	self.pageCap 	= 12
	
	self.pageNodeCache = {}
	self:initUI()
end

function GridView:__delete()
	self.scrollView:release()
	for k, v in pairs(self.pageNodeCache) do
		v:release()
	end
end	

-- 设置显示的物品(以GridId为key，Item为value的map)
function GridView:setGrids(grids, cellSize)
	if not grids or not cellSize then
		print("GridView:setGrids error. not grids or not cellSize")
	end
	self.grids = grids
	self.capacity = #(grids)	
	self.cellSize = cellSize
end

function GridView:getGrids()
	return self.grids
end

function GridView:setSpacing(hSpacing, vSpacing)
	self.hSpacing = hSpacing
	self.vSpacing = vSpacing
end

function GridView:getSpacing()
	return self.hSpacing, self.vSpacing
end

-- 设置行，列
function GridView:setPageOption(row, columu)
	self.row = row
	self.columu = columu	
	self.pageCap = self.row * self.columu
end	

function GridView:getPageOption()
	return self.row, self.columu
end

-- 设置当前页数
function GridView:setPageIndex(index, scrollTo)
	if not scrollTo then
		scrollTo = true
	end
	self.pageIndex = index	
	if scrollTo then
		self.scrollView:setContentOffset(ccp(-self.scrollView:getViewSize().width * (index - 1), 0), false)		
	end
	if self.pageNotifyDelegate then
		self.pageNotifyDelegate.delegate(self.pageNotifyDelegate.arg, index)
	end
	self:hideNotCurrentPage()
end

-- 获取当前页数
function GridView:getPageIndex()
	return self.pageIndex
end

-- 设置页数变化的回调函数
function GridView:setPageChangedNotify(arg, pageNotifyDelegate)
	self.pageNotifyDelegate = {delegate = pageNotifyDelegate, arg = arg}
end

-- 设置点击事件的回调函数
-- 回调函数参数: itemObj
function GridView:setTouchNotify(aarg, touchDelegate)
	self.touchDelegate = {func = touchDelegate, arg = aarg}
end

function GridView:getRootNode()
	return self.scrollView
end

------------------------------以下为私有方法--------------------------------
function GridView:getPageNode(index)
	return self.pageNodeCache[index]
end

function GridView:initUI()
	self.scrollView = self:createScrollView(const_scrollViewSize)
	self.scrollView:retain()
	self.scrollNode = CCNode:create()	
	self.scrollView:setContainer(self.scrollNode)
end

function GridView:hideNotCurrentPage()
	for k, v in ipairs(self.usingPageNodes) do
		if k ~= self.pageIndex then
			v:setVisible(false)
--			print("set "..k.." v")
		else
			v:setVisible(true)
--			print("set "..k.." not v")
		end
	end
end

function GridView:showAllPage()
	for k, v in ipairs(self.usingPageNodes) do	
		v:setVisible(true)		
	end
end

function GridView:createScrollView()
	local scrollView = createScrollViewWithSize(const_scrollViewSize)
	scrollView:setDirection(1)
	scrollView:setPageEnable(true)
	local scrollHandler = function(view, eventType, x, y)	
		if eventType == 2 then --kScrollViewTouchBegin
			self:showAllPage()
		elseif (eventType == 5) then  --kScrollViewDidAnimateScrollEnd		
			local pageIndex = scrollView:getPage() + 1
			if self.pageIndex ~= pageIndex then
				self:setPageIndex(pageIndex, false)
			end
			self:hideNotCurrentPage()
		elseif (eventType == 4) then  --kScrollViewTouchEnd		
			if not self.viewSize then
				return
			end
			local touchMoved = self.scrollView:isTouchMoved()
			if not touchMoved then	
				y = self.viewSize.height - y --本地坐标以左下角为原点
				local pageIndex = self:getPageIndex()
							
				local row 		= math.ceil(y / (self.cellSize.height + self.vSpacing))	
				local columu 	= math.ceil(x / (self.cellSize.width + self.hSpacing))
				local totalIndex = (pageIndex - 1) * self.pageCap + (row - 1) * self.columu  + columu
				
				local offsetX = (x - (columu - 1) * self.cellSize.width - columu * self.hSpacing)
				local offsetY = (y - (row - 1) * self.cellSize.height - row * self.vSpacing)
				if offsetX > self.cellSize.width or offsetY > self.cellSize.height then
					return	--点击间隙不响应
				end
				
				if self.touchDelegate then
					self.touchDelegate.func(self.touchDelegate.arg, totalIndex, self.grids[totalIndex])
				end
			end
		end
	end
	scrollView:setHandler(scrollHandler)
	return scrollView
end

function GridView:isInSpacing(x, y)
	
end
	
function GridView:update()
	self.pageCap = self.row * self.columu
	self.viewSize = CCSizeMake(self.cellSize.width * self.columu + self.hSpacing * (self.columu + 1),
							   self.cellSize.height * self.row + self.vSpacing * (self.row + 1))
	self.pageCount = math.ceil(self.capacity / self.pageCap)	
	
	local size = #(self.pageNodeCache)
	for i = size + 1, self.pageCount do
		local node = CCNode:create()
		node:retain()
		table.insert(self.pageNodeCache, node)		
	end
end
--[[
function GridView:addPage()
end
--]]
function GridView:reloadAll()
	self:update()
		
	self.scrollNode:removeAllChildrenWithCleanup(true)
	for k, v in pairs(self.pageNodeCache) do
		v:removeAllChildrenWithCleanup(true)		
	end
	
	self.usingPageNodes = {}
	for i = 1, self.pageCount do
		local node = self.pageNodeCache[i]
		table.insert(self.usingPageNodes, node)
		node:setContentSize(self.viewSize)		
	end
	for k, v in pairs(self.grids) do	--注意: k 不能大于 self.capacity	
		local pageIndex, row, columu = self:getLayoutInfoByIndex(k)		
		local pageNode = self:getPageNode(pageIndex)		
		if not v:getRootNode():getParent() then		
			pageNode:addChild(v:getRootNode())			
			VisibleRect:relativePosition(v:getRootNode(), pageNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,
										ccp((columu - 1) * self.cellSize.width + columu * self.hSpacing, -((row - 1) * self.cellSize.height + row * self.vSpacing)))				
		end
	end
	G_layoutContainerNode(self.scrollNode, self.usingPageNodes, 0, E_DirectionMode.Horizontal, self.viewSize, false)
	self.scrollNode:retain()
	self.scrollView:setViewSize(self.viewSize)
	self.scrollView:setContainer(self.scrollNode)
	self.scrollView:setPageSize(self.viewSize)
--	self.scrollView:updateInset()
	self.scrollNode:release()
end

function GridView:reloadWithPageIndex(pageList, itemMap)
	self.grids = itemMap
	for k, v in pairs(pageList) do	
		
	end
end

function GridView:getLayoutInfoByIndex(index)
	local pageIndex = math.ceil(index / self.pageCap)
	local gridIndex = index - ((pageIndex - 1) * self.pageCap)
	local row 		= math.ceil(gridIndex / self.columu)
	local columu	= math.ceil(gridIndex % self.columu)
	if columu == 0 then
		columu = self.columu
	end
	return pageIndex, row, columu               
end