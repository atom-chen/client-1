-- 显示详细属性
-- 显示详细属性
require("common.BaseUI")

TestMemInfoView = TestMemInfoView or BaseClass(BaseUI)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size_no_scale = CCSizeMake(480, 320)
local g_size
local const_scale = VisibleRect:SFGetScale()

function TestMemInfoView:create()
	return TestMemInfoView.New()
end

function TestMemInfoView:__init()
	self.viewName = "TestMemInfoView"
	g_size = self:initFullScreen()
	
	UIManager.Instance:startUITest("InstanceView", 4)
	
--	self:testLabel();
	self:testScrollView()
end				

function TestMemInfoView:__delete()
	if self.scrollNode then
		self.scrollNode:release()
	end
end		

--没问题
function TestMemAnalyzeMgr:testLabel()
	local label = createLabelWithStringFontSizeColorAndDimension("LabelTesting", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))								
	self.rootNode:addChild(label)
	VisibleRect:relativePosition(label, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(50, -50))
end

--没问题
function TestMemInfoView:testScrollView()
	local const_scrollViewSize = CCSizeMake(g_size.width - 50, g_size.height - 100)
	
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(const_scrollViewSize)
	self.scrollNode:retain()
	
	self.scrollView = self:createScrollView(const_scrollViewSize)
	self.rootNode:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)	
	
	
	local nodes = {}
	for i = 1, 15 do
		local node = createSpriteWithFileName(ICON("equip_16_3000"))
		local n = CCNode:create()
		n:addChild(node)	
		n:setContentSize(CCSizeMake(const_scrollViewSize.width, node:getContentSize().height))
		VisibleRect:relativePosition(node, n, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y)
		table.insert(nodes, n)
	end
	G_layoutContainerNode(self.scrollNode, nodes, 5, E_DirectionMode.Vertical, const_scrollViewSize, true)	
	self.scrollView:setContainer(self.scrollNode)
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_CENTER_Y)
end

function TestMemInfoView:createScrollView(viewSize)
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	return scrollView
end		