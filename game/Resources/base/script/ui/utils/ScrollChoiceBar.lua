-- 显示背包的详情
require("common.baseclass")
require("GameDef")

ScrollChoiceBar = ScrollChoiceBar or BaseClass()

local constDefaultSize = VisibleRect:getScaleSize(CCSizeMake(240, 40))
local constTouchOffset = 10

function ScrollChoiceBar:__init()
	self.list = {}
	self.fcolor = FCOLOR("ColorBlack1")
	self.fsize =  FSIZE("Size3")
	self.viewSize = constDefaultSize
	self.mode = E_DirectionMode.Vertical
	self.curIndex = -1
	
	self:init()
end		

function ScrollChoiceBar:init()
	self.rootNode = createScrollViewWithSize(constDefaultSize)
	self.rootNode:setDirection(E_DirectionMode.Vertical)
	self.rootNode:setPageEnable(true)	
	self.rootNode:retain()	
	
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(constDefaultSize)
	self.scrollNode:retain()
						
						
	self.lastTouchPoint = nil 
	local scrollHandler = function(view, eventType, x, y)
		if eventType == 4 then  		--kScrollViewTouchEnd
			local touchMoved = self.rootNode:isTouchMoved()
			if not touchMoved then		
				self:doNotify(1)											
			end	
		elseif (eventType == 5) then  --kScrollViewDidAnimateScrollEnd
			local index = self.rootNode:getPage()	
			if (index ~= self.curIndex) then	
				self.curIndex = index
				self:doNotify(2)	--index变化事件				
			end								
		end
	end
	self.rootNode:setHandler(scrollHandler)
end			

function ScrollChoiceBar:__delete()
	self.rootNode:release()
	self.scrollNode:release()
end

function ScrollChoiceBar:getRootNode()
	return self.rootNode
end

function ScrollChoiceBar:setDataList(list, fcolor, fsize)
	self.list = list
	if (fcolor ~= nil) then
		self.fcolor = fcolor
	end
	if (fsize ~= nil) then
		self.fsize = fsize
	end
end	

function ScrollChoiceBar:setViewSize(size)
	self.viewSize = size	
end

function ScrollChoiceBar:getViewSize()
	return self.viewSize
end

function ScrollChoiceBar:setMode(mode)
	if (self.mode == mode) then
		return
	end
	self.mode = mode
	self.rootNode:setDirection(mode)
--	self:reload()
end

--回调函数参数：
-- arg:自定义参数， evnetType：1为点击事件，2为滑动事件，index:当前的索引
function ScrollChoiceBar:setNotify(argg, notify)
	self.notify = {func = notify, arg = argg}
end

function ScrollChoiceBar:reload()
	self.scrollNode:removeAllChildrenWithCleanup(true)	
	if (self.list == nil) then
		return
	end
	
	self.curIndex = 0
	self.rootNode:setViewSize(self.viewSize)				
	
	if not self.pageSize then
		self:setPageSize(self.viewSize)
	end
	
	local nodes = {}
	for index, value in ipairs(self.list) do
		local label = createLabelWithStringFontSizeColorAndDimension(value, "Arial", self.fsize, self.fcolor--[[, CCSizeMake(self.viewSize.width, 0)--]])									
		local node = CCNode:create()
		node:setContentSize(self.pageSize)
		node:addChild(label)		
		VisibleRect:relativePosition(label, node, LAYOUT_CENTER)		
		table.insert(nodes, node)
	end
	G_layoutContainerNode(self.scrollNode, nodes, 0, self.mode)
	self.rootNode:setContainer(self.scrollNode)
	self:setIndex(0)
end	

function ScrollChoiceBar:getIndex()
	return self.curIndex
end

function ScrollChoiceBar:setIndex(index)
	self.curIndex = index
	self.rootNode:updateInset()
	if (self.mode == E_DirectionMode.Vertical) then
		self.rootNode:setContentOffset(ccp(0, -self.scrollNode:getContentSize().height + self.pageSize.height + self.pageSize.height * index), false)
	else
		self.rootNode:setContentOffset(ccp(-self.pageSize.width * index, 0), false)
	end
end

function ScrollChoiceBar:doNotify(eventType)
	if (self.notify) then
		self.notify.func(eventType, self.curIndex, self.notify.arg)
	end
end

function ScrollChoiceBar:setPageSize(pageSize)
	self.pageSize = pageSize
	self.rootNode:setPageSize(pageSize)		
end
