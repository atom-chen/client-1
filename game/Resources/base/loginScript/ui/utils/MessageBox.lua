-- 显示一个物品
require("common.baseclass")
require("common.LoginBaseUI")

MessageBox = MessageBox or BaseClass(LoginBaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_minWidth = 		360	* const_scale
local const_minHeight = 120 * const_scale
local const_maxHeight = (visibleSize.height-207) * const_scale
local const_marginH = 20	* const_scale 	--左右的间隔
local const_marginV	= 30	* const_scale 	--上下的间隔
local const_btnSpacing = 30	* const_scale

local const_btnZ			=	50
local const_btnTextZ 		=	60
local const_scrollViewZ 	=  55

local const_defaultBtns = 
{
	{text = Config.LoginWords[10043],	id = 2},
	{text = Config.LoginWords[10045],	id = 1},
	{text = Config.LoginWords[10046],	id = 3},
}

E_MSG_BT_ID = {
	ID_OKAndCANCEL = 0,
	ID_OK = 2,
	ID_CANCEL = 1,
	ID_CANCELAndOK = 3,
	ID_KNOW = 4,
}

function MessageBox:__init()
	self.viewName = "MessageBox"
	self:init(CCSizeMake(const_minWidth+const_marginH, const_minHeight))	
	self.btns = {}	
	self.btnHeight = 0	
	self.btnWidth = 0	
	self.pressBtn = {text = "", id = -1}	
end		


function MessageBox:close()
	local rootNode = self.rootNode	
	UIManager.Instance:hideDialog(rootNode)
	self:DeleteMe()
	self = nil
end

function MessageBox:clearOnClose()
	self.customSize = nil
	self.btnHeight = 0	
	self.btnWidth = 0
	
	self:doNotify(self.pressBtn.text, self.pressBtn.id)
	self.pressBtn = {text = "", id = -1}
end

function MessageBox:onCloseBtnClick()
	self:clearOnClose()
end

function MessageBox:create()
	return MessageBox.New()
end	

function MessageBox:setSize(size)
	self.customSize = size		
end

function MessageBox:setMsg(text)
	if (text == nil) then
		return
	end
	self.text = text	
end

function MessageBox:getMsg()
	return self.text
end

function MessageBox:deleteBtns()
	if table.size(self.btns) then
		for i, btn in pairs(self.btns) do
			self:getContentNode():removeChild(btn.obj, true)
			self:getContentNode():removeChild(btn.label, true)
			btn.obj = nil
			btn.label = nil
		end
	end
	
	self.btns = {}
	self.btnHeight = 0
	self.btnWidth = 0
end

function MessageBox:setBtns(btns)
	self:deleteBtns()
	
	if (btns == nil) then
		return
	else
		self.btns = btns
	end
	

	for i, btn in ipairs(self.btns) do
		btn.obj, btn.label = self:createBtn(btn.text, btn.id)
		if (btn.obj:getContentSize().height > self.btnHeight) then
			self.btnHeight = btn.obj:getContentSize().height
		end
		self.btnWidth = self.btnWidth + btn.obj:getContentSize().width		
	end		
	
	local btnCount = table.size(self.btns)	
	local previousNode = self:getContentNode()	
	if btnCount == 1 then
		VisibleRect:relativePosition(self.btns[1].obj, previousNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)	
		VisibleRect:relativePosition(self.btns[1].label, self.btns[1].obj, LAYOUT_CENTER)	
	else
		local spacing = (const_minWidth - 2 * const_marginH - self.btnWidth)/(btnCount - 1)	
		
		for i, btn in ipairs(self.btns) do
			if (previousNode == self:getContentNode()) then			
				VisibleRect:relativePosition(btn.obj, previousNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(const_marginH/2, 0))				
			else
				VisibleRect:relativePosition(btn.obj, previousNode, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(spacing, 0))
			end
			VisibleRect:relativePosition(btn.label, btn.obj, LAYOUT_CENTER)
			previousNode = btn.obj
		end
	end
	
	self:updateView()
end

function MessageBox:setNotify(notify,argg)
	self.notify = {func = notify, arg = argg}
end

function MessageBox:calculateViewSize()
	local viewSize = CCSizeMake(const_minWidth,const_minHeight)
	if self.labelNode then
		local labelSize = self.labelNode:getContentSize()
		local tempHeight = labelSize.height
		if const_minHeight > tempHeight+const_marginV then 
			tempHeight = const_minHeight
		end	
		if tempHeight > const_maxHeight then 
			tempHeight = const_maxHeight
		end	
				

		if self.btnHeight then
			tempHeight = tempHeight + self.btnHeight
		end

		
		viewSize = CCSizeMake(const_minWidth,tempHeight+const_marginV*3)
	end
	return viewSize
end

function MessageBox:createTextNode()
	if self.text then	
		local label = createLabelWithStringFontSizeColorAndDimension(self.text, "Arial", FSIZE("Size6"), FCOLOR("ColorWhite1"))			
		local labelSize = label:getContentSize()
		local labelwidth = labelSize.width
		local labelheight = labelSize.height
		local textWidth = const_minWidth-const_marginH
		if labelwidth> textWidth  or labelheight >= 2*FSIZE("Size6") then --文本宽度大于弹窗宽度 或者 文本高度超过2行时需要重设contenSize  
			label:setDimensions(CCSizeMake(textWidth,0))
			label:setContentSize(label:getDimensions())	
			labelSize = label:getContentSize()
		end
	
		if self.labelNode then
			self.labelNode:removeFromParentAndCleanup(true)	
			self.labelNode = nil
		end
		
		self.labelNode = CCNode:create()				
			
		local nodeHeight = labelSize.height
		if nodeHeight<const_minHeight then
			nodeHeight = const_minHeight
		end			
		self.labelNode:addChild(label)
		self.labelNode:setContentSize(CCSizeMake( textWidth, nodeHeight))
		
		if nodeHeight<=const_minHeight then
			VisibleRect:relativePosition(label, self.labelNode, LAYOUT_CENTER)
		else
			VisibleRect:relativePosition(label, self.labelNode, LAYOUT_CENTER+LAYOUT_TOP_INSIDE)
		end
		
	end	
end

function MessageBox:layout()
	self:createTextNode()
	self:createViewBtn()
	self:updateView()
end

function MessageBox:updateView()
	local viewSize = self:calculateViewSize()
	if viewSize then
		self:init(CCSizeMake(const_minWidth+const_marginH, viewSize.height))	
	end		
	self:updateScrollView()
end

function MessageBox:createViewBtn()
	if table.size(self.btns)<=0 then
		if self.btnType then
			local btns = nil
			if self.btnType == E_MSG_BT_ID.ID_OK then
				btns = {const_defaultBtns[1]}
			elseif self.btnType == E_MSG_BT_ID.ID_CANCEL then
				btns = {const_defaultBtns[2]}
			elseif self.btnType == E_MSG_BT_ID.ID_OKAndCANCEL then
				btns = const_defaultBtns
			elseif self.btnType == E_MSG_BT_ID.ID_CANCELAndOK then
				btns = {const_defaultBtns[2], const_defaultBtns[1]}
			elseif self.btnType == E_MSG_BT_ID.ID_KNOW then
				btns = {const_defaultBtns[3]}
			end
			self:setBtns(btns)
		end
	end
end

function MessageBox:setBtnTpye(btnType)
	self.btnType = btnType
	self:deleteBtns()
end

function MessageBox:updateScrollView()
	if self.labelNode then	
		local labelSize = self.labelNode:getContentSize()
			
		local scrollViewHeight = labelSize.height
		if scrollViewHeight>const_maxHeight then
			scrollViewHeight = const_maxHeight			
		end
	
		if (self.scrollView == nil) then	
			self.scrollView =createScrollViewWithSize( CCSizeMake(labelSize.width, scrollViewHeight))
			self.scrollView:setDirection(2) --垂直滑动
			self:addChild(self.scrollView, const_scrollViewZ)
			
			self.scrollBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_formBg2.png"), CCSizeMake(labelSize.width, scrollViewHeight))
			self:addChild(self.scrollBg, const_scrollViewZ - 1)		
			
		else
			self.scrollView:setViewSize(CCSizeMake(labelSize.width, scrollViewHeight))	
			self.scrollView:removeAllChildrenWithCleanup(true)
			self.scrollBg:setPreferredSize( CCSizeMake(labelSize.width, scrollViewHeight))
		end
		
		self.scrollView:setContainer(self.labelNode)		
		self.scrollView:setContentOffset(ccp(0, -(labelSize.height-scrollViewHeight)), false)
	end
		
	VisibleRect:relativePosition(self.scrollBg, self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, 	ccp(0, -5))
	VisibleRect:relativePosition(self.scrollView, self.scrollBg, LAYOUT_CENTER)
end

function MessageBox:createBtn(text, id)
	local label = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))	
			
--[[	
	local size = CCSizeMake(label:getContentSize().width + 30 * const_scale, label:getContentSize().height + 20 * const_scale)
	local btn = createButtonWithFramename("btn_1_select.png", "btn_1_select.png", size)
	--]]
	local btn = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))
	local onClick = function()	
		self.pressBtn = {["text"] = text, ["id"] = id}
		self:doNotify(self.pressBtn.text, self.pressBtn.id)
		self:close()
	end			
	btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	self:addChild(btn, const_btnZ)
	self:addChild(label, const_btnTextZ)

	VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)	
	
	return btn, label
end

function MessageBox:doNotify(text, id)
	if (self.notify and self.notify.func) then
		self.notify.func(self.notify.arg, text, id)
	end
end

function MessageBox:setSwallowAllTouch(bSwall)
	self.isSwallowAllTouch = bSwall
end

function MessageBox:touchHandler(eventType, x, y)
	if self.rootNode and self.rootNode:isVisible() and self.rootNode:getParent() then	
		if self.isSwallowAllTouch then
			return 1
		else
			local parent = self.rootNode:getParent()
			local point = parent:convertToNodeSpace(ccp(x,y))
			local rect = self.rootNode:boundingBox()
			if rect:containsPoint(point) then
				return 1
			else
				return 0
			end
		end
	else
		return 0
	end
end	

----------------------------------------------------------------------
--新手指引
function MessageBox:showArrow()
	local node = self.btns[1].obj
	if node then
		local parent = node:getParent()
		if not self.arrow then
			local function callback()
				self:hideArrow()
			end
			self.arrow = createArrow(direction.left,callback)		
			parent:addChild(self.arrow:getRootNode(),100)					
			VisibleRect:relativePosition(self.arrow:getRootNode(),node,LAYOUT_CENTER,ccp(50,0))
		end
	end	
end

function MessageBox:hideArrow()
	if self.arrow then
		self.arrow:DeleteMe()
		self.arrow = nil
	end
end
----------------------------------------------------------------------