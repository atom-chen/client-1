-- ��ʾrow * column����Ʒ
require("common.BaseUI")
require("config.words")
require("GameDef")
require("ui.utils.ItemView")

BatchGridView = BatchGridView or BaseClass()

local const_scale = VisibleRect:SFGetScale()
local const_scrollViewSize = VisibleRect:getScaleSize(CCSizeMake(380, 380))


function BatchGridView:__init()
	self.grids 	= {}
	self.cellSize 	= CCSizeMake(60, 60)
	self.hSpacing 	= 0
	self.vSpacing 	= 0
	self.row 		= 3
	self.column 	= 4
	self.pageIndex 	= 1
	self.pageCount  = 1
	self.pageCap 	= 12
	self.pageNodeCache = {}		
	self:initUI()
end

function BatchGridView:__delete()
	self.scrollView:release()
	for k, v in pairs(self.pageNodeCache) do
		v:release()
	end
end	

function BatchGridView:setCellSize(size)
	self.cellSize = size
end
function BatchGridView:getCellSize()
	return self.cellSize
end

function BatchGridView:isLegalPage(index)
	return index > 0 and index <= self.pageCount
end
	
--��ʾ����
function BatchGridView:setGrids(grids, bReload)
	if bReload then
		self:update()
	end
	for k, v in pairs(grids) do			
		self:addGrid(k, grid)			
	end
end	

--����һ��node��ָ������
function BatchGridView:addGrid(index, grid)
	local pageIndex, row, column = self:getLayoutInfoByIndex(index)	
	local pageNode = self:getPageNode(pageIndex)
	if pageNode then
		grid:getRootNode():setPosition(ccp(self.hSpacing * column + self.cellSize.width * (column - 1), 
						  self.vSpacing * (self.row - row + 1) + self.cellSize.height * (self.row - row)))
		pageNode:addChild(grid:getRootNode())
		self.grids[index] = grid
	end
end	

--��ȡ����
function BatchGridView:getGrids()
	return self.grids
end

--������ҳ��
function BatchGridView:setPageCount(count)
	self.pageCount = count
end

--���ü�϶
function BatchGridView:setSpacing(hSpacing, vSpacing)
	self.hSpacing = hSpacing
	self.vSpacing = vSpacing
end

--��ȡ��϶
function BatchGridView:getSpacing()
	return self.hSpacing, self.vSpacing
end

-- �����У���
function BatchGridView:setPageOption(row, column)
	self.row = row
	self.column = column	
	self.pageCap = self.row * self.column
end	

--��ȡ�У���
function BatchGridView:getPageOption()
	return self.row, self.column
end

-- ���õ�ǰҳ��: 1-n
function BatchGridView:setPageIndex(index, scrollTo)
	if not self:isLegalPage(index) then
		print("BatchGridView:setPageIndex error: index < 1 or index > self.pageCount")
		return
	end
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
	if self.loadDelegate then
		self.loadDelegate(index)
	end
end

-- ��ȡ��ǰҳ��
function BatchGridView:getPageIndex()
	return self.pageIndex
end

-- ����ҳ���仯�Ļص�����
function BatchGridView:setPageChangedNotify(arg, pageNotifyDelegate)
	self.pageNotifyDelegate = {delegate = pageNotifyDelegate, arg = arg}
end

-- ���õ���¼��Ļص�����
-- �ص���������: itemObj
function BatchGridView:setTouchNotify(aarg, touchDelegate)
	self.touchDelegate = {func = touchDelegate, arg = aarg}
end	

--���ü��ػص�����
function BatchGridView:setLoadDelegate(loadDelegate)
	self.loadDelegate = loadDelegate
end

function BatchGridView:getRootNode()
	return self.scrollView
end

function BatchGridView:getPageNode(index)
	return self.pageNodeCache[index]
end

------------------------------����Ϊ˽�з���--------------------------------
--��ʼ��UI
function BatchGridView:initUI()
	self.scrollView = self:createScrollView(const_scrollViewSize)
	self.scrollView:retain()
	
	self.scrollNode = CCNode:create()	
	self.scrollView:setContainer(self.scrollNode)
end

--���طǵ�ǰҳ��
function BatchGridView:hideNotCurrentPage()
	for k, v in ipairs(self.usingPageNodes) do
		if k ~= self.pageIndex then
			v:setVisible(false)
		else
			v:setVisible(true)
		end
	end
end

--��ʾ����ҳ��
function BatchGridView:showAllPage()
	for k, v in ipairs(self.usingPageNodes) do	
		v:setVisible(true)		
	end
end

function BatchGridView:showPage(index)
	local page = self.usingPageNodes[index]	
	if page then
		page:setVisible(true)			
--		print("show page="..index)
	end
end

function BatchGridView:hidePage(index)
	local page = self.usingPageNodes[index]	
	if page then
		page:setVisible(false)			
	end		
end

function BatchGridView:createScrollView()
	local scrollView = createScrollViewWithSize(const_scrollViewSize)
	scrollView:setDirection(1)
	scrollView:setPageEnable(true)
	local scrollHandler = function(view, eventType, x, y)
		if not self.viewSize then
			return
		end	
		if eventType == 3 then --kScrollViewTouchMove			
			local offset = self.scrollView:getContentOffset()
			local a = 0
			local b = 0
			a, b = math.modf(math.abs(offset.x) / self.viewSize.width)
			local page1 = a + 1
			local page2 = -1
			if b > 0 then
				page2 = page1 + 1
			end				
			if self:isLegalPage(page1) then	
				if self.loadDelegate then
					self.loadDelegate(page1)
				end
				self:showPage(page1)		
			end
			if self:isLegalPage(page2) then
				if self.loadDelegate then
					self.loadDelegate(page2)
				end
				self:showPage(page2)		
			end					
		elseif (eventType == 4) then  --kScrollViewTouchEnd		
			if not self.scrollView:isTouchMoved() then	
				y = self.viewSize.height - y --�������������½�Ϊԭ��
				local pageIndex = self:getPageIndex()
				local row 		= math.ceil(y / (self.cellSize.height + self.vSpacing))	
				local column 	= math.ceil(x / (self.cellSize.width + self.hSpacing))
				local totalIndex = (pageIndex - 1) * self.pageCap + (row - 1) * self.column  + column
				
				local offsetX = (x - (column - 1) * self.cellSize.width - column * self.hSpacing)
				local offsetY = (y - (row - 1) * self.cellSize.height - row * self.vSpacing)

				if offsetX > self.cellSize.width or offsetY > self.cellSize.height then
					return	--�����϶����Ӧ
				end
				if self.touchDelegate and self.touchDelegate.func then
					self.touchDelegate.func(self.touchDelegate.arg, totalIndex, self.grids[totalIndex])
				end
--				print(string.format("index=%d row=%d column=%d", pageIndex, row, column))
			end
		elseif (eventType == 5) then  --kScrollViewDidAnimateScrollEnd		
			local pageIndex = scrollView:getPage() + 1
			if self.pageIndex ~= pageIndex then
				self:setPageIndex(pageIndex, false)
			end
			self:hideNotCurrentPage()
		end
	end
	scrollView:setHandler(scrollHandler)
	return scrollView
end

--����״̬��ҳ��������viewSize�ȣ�����ҳ���ṹ
function BatchGridView:update()
	self.grids = {}
	self.pageCap = self.row * self.column
	self.viewSize = CCSizeMake(self.cellSize.width * self.column + self.hSpacing * (self.column + 1),
							   self.cellSize.height * self.row + self.vSpacing * (self.row + 1))
	
	local size = #(self.pageNodeCache)
	for i = size + 1, self.pageCount do
		local node = CCNode:create()
		node:retain()
		table.insert(self.pageNodeCache, node)		
	end
	self:buildPages()
end

--����ҳ��
function BatchGridView:buildPages()
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

	G_layoutContainerNode(self.scrollNode, self.usingPageNodes, 0, E_DirectionMode.Horizontal, self.viewSize, false)
	self.scrollNode:retain()
	self.scrollView:setViewSize(self.viewSize)
	self.scrollView:setContainer(self.scrollNode)
	self.scrollView:setPageSize(self.viewSize)
	self.scrollNode:release()
end

function BatchGridView:getLayoutInfoByIndex(index)
	local pageIndex = math.ceil(index / self.pageCap)
	local gridIndex = index - ((pageIndex - 1) * self.pageCap)
	local row 		= math.ceil(gridIndex / self.column)	--�� -
	local column	= math.ceil(gridIndex % self.column)	--�� |
	if column == 0 then
		column = self.column
	end
	return pageIndex, row, column               
end