require("common.LoginBaseUI")
require("ui.utils.PromptBox.BasePromptBox")

DescribePromptBox = DescribePromptBox or BaseClass(BasePromptBox)

local const_scale = VisibleRect:SFGetScale()
local constScrollSize = CCSizeMake(16*15+10,140)
local constVIewSize = CCSizeMake(400,290)
local const_TAG_ICON = 10
function DescribePromptBox:create()
	return DescribePromptBox.New()
end

function DescribePromptBox:__init()
	self:setViewSize(constVIewSize)
	self:initStaticBg()
	self.iconBg = createButtonWithFramename(RES("login_squares_itemBg.png"),RES("login_squares_itemBg.png"))	
	self.iconBg:setZoomOnTouchDown(false)
	self:addChild(self.iconBg)
	VisibleRect:relativePosition(self.iconBg,self.bg,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(10,0))
	self.iconWordNode = CCNode:create()
	self.iconWordNode:setContentSize(CCSizeMake(FSIZE("Size2")*4,FSIZE("Size2")*3))
	self:addChild(self.iconWordNode)
	VisibleRect:relativePosition(self.iconWordNode,self.iconBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
	self.scrollNode = CCNode:create()	
	self.scrollNode:retain()--shifang
	self:createScrollView()
end

function DescribePromptBox:setIcon(iconName,iconNodify)
	if iconName then
		--self.iconBg:removeAllChildrenWithCleanup(true)
		if self.iconBg:getChildByTag(const_TAG_ICON) then
			self.iconBg:removeChildByTag(const_TAG_ICON,true)
		end
		if type(iconName) == "string" then
			VisibleRect:relativePosition(self.iconBg,self.bg,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(10,0))
			local icon = createSpriteWithFileName(ICON(iconName))
			self.iconBg:addChild(icon)
			icon:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(icon,self.iconBg,LAYOUT_CENTER)
		else
			self.iconBg:addChild(iconName)
			iconName:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(iconName,self.iconBg,LAYOUT_CENTER)
		end
		if iconNodify then
			self.iconBg:setZoomOnTouchDown(true)
			local iconFunc = function()
				iconNodify()
			end
			self.iconBg:addTargetWithActionForControlEvents(iconFunc,CCControlEventTouchDown)	
		end
	end
end

function DescribePromptBox:setIconWord(iconWord,color)
	if iconWord then
		if not color then
			color = FCOLOR("ColorYellow5")
		end
		self.iconWordNode:removeAllChildrenWithCleanup(true)
		VisibleRect:relativePosition(self.iconWordNode,self.iconBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
		local iconWordLb = createLabelWithStringFontSizeColorAndDimension(iconWord,"Arial",FSIZE("Size2"),color,CCSizeMake(FSIZE("Size2")*4,0))
		self.iconWordNode:addChild(iconWordLb)
		VisibleRect:relativePosition(iconWordLb,self.iconWordNode,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
	end
end

function DescribePromptBox:setDescrition(msg,color)
	if msg then
		self.scrollNode:removeAllChildrenWithCleanup(true)
		if not color then
			color = FCOLOR("ColorWhite2")
		end
		local desLabel = createLabelWithStringFontSizeColorAndDimension(msg,"Arial",FSIZE("Size3"),color,CCSizeMake(FSIZE("Size3")*12,0))
		local size = desLabel:getContentSize()
		if size.height < constScrollSize.height then
			size.height= constScrollSize.height
		end
		self.scrollNode:setContentSize(size)
		self.scrollNode:addChild(desLabel)
		
		self.scrollView:setContainer(self.scrollNode)
		VisibleRect:relativePosition(desLabel,self.scrollNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(15,0))
		VisibleRect:relativePosition(self.scrollView,self.iconBg,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	end
end
----------------------------------------------------------------------------
function DescribePromptBox:createScrollView()
	self.scrollBg = createScale9SpriteWithFrameName(RES("login_talisman_bg.png"))
	self.scrollBg:setContentSize(constScrollSize)
	self:addChild(self.scrollBg)
	VisibleRect:relativePosition(self.scrollBg,self.iconBg,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(10,0))
	self.scrollView  = createScrollViewWithSize(constScrollSize)
	self.scrollView :setDirection(2)
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView,self.scrollBg,LAYOUT_CENTER)
end


function DescribePromptBox:__delete()
	self.scrollNode:release()
end