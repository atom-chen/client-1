-- 提示框基类
require("common.baseclass")
require("common.LoginBaseUI")
local const_scale = VisibleRect:SFGetScale()
BasePromptBox = BasePromptBox or BaseClass(LoginBaseUI)

function BasePromptBox:__init()
	self.viewName = "BasePromptBox"	
end

function BasePromptBox:create()
	return BasePromptBox.New()
end
function BasePromptBox:delete()
	
end
function BasePromptBox:setBeShowBtn(bShowBtn)
	--Juchao@20140326: 避免不同高度的界面重叠，按钮穿透的问题
--[[	if bShowBtn == false then
		self.background:setPreferredSize(const_Size_noBtn)
		VisibleRect:relativePosition(self.background,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X)
	end--]]
end
function BasePromptBox:setViewName(viewName)
	if viewName then
		self.viewName = viewName
	end
end

function BasePromptBox:getViewName()
	return self.viewName
end

function BasePromptBox:setViewSize(viewSize)
	self:init(viewSize)
end

function BasePromptBox:setTitleWords(titleImageTop,titleImageBottom)
	if titleImageTop then
		self.titleBg:removeAllChildrenWithCleanup(true)
		local title
		if string.find(titleImageTop,".png") then
		title = createSpriteWithFrameName(RES(titleImageTop))
		else
		title = createLabelWithStringFontSizeColorAndDimension(titleImageTop,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow5"))
		end	
		self.titleBg:addChild(title)
		VisibleRect:relativePosition(title,self.titleBg,LAYOUT_CENTER)
	end		
	
	if titleImageBottom then
		local title
		if string.find(titleImageBottom,".png") then
			title = createSpriteWithFrameName(RES(titleImageBottom))
		else
			title = createLabelWithStringFontSizeColorAndDimension(titleImageBottom,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow5"))
		end	
		self:addChild(title)
		VisibleRect:relativePosition(title,self.bg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-80))
	end
end

function BasePromptBox:setBtn(btnTitle,nodifyFunc,arg)
	if self.btn then
		self.btn:removeFromParentAndCleanup(true)
	end
	self.btn = createButtonWithFramename(RES("btn_1_select.png"))
	if btnTitle then
		if string.find(btnTitle,".png") then
			local btnTitleImg = createSpriteWithFrameName(RES(btnTitle))
			self.btn:setTitleString(btnTitleImg)
		else
			local btnTitleImg = createLabelWithStringFontSizeColorAndDimension(btnTitle,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow5"))
			self.btn:setTitleString(btnTitleImg)
		end
	end
	if nodifyFunc then
		local onClick = function()	
			nodifyFunc(arg)
		end			
		self.btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	end
	self:addChild(self.btn)
	VisibleRect:relativePosition(self.btn,self.bg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
end

function BasePromptBox:setCompareLabel(des)
	if des == nil then
		self.compareLb:setString("")
		VisibleRect:relativePosition(self.compareLb,self.bg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,4))
	else
		self.compareLb:setString(des)
		VisibleRect:relativePosition(self.compareLb,self.bg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,4))
	end
end

function BasePromptBox:setCloseNodify(closeNodify,arg)
	if closeNodify then
		self.closeNodify = closeNodify
		self.closeArg = arg
	end
end
-----------------------------------------------
function BasePromptBox:initStaticBg()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("login_suqares_goldFrameBg.png"), CCSizeMake(350,160))	
	self:addChild(self.bg)
	VisibleRect:relativePosition(self.bg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,-5))
	self.compareLb = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorYellow2"))
	self:addChild(self.compareLb)
	VisibleRect:relativePosition(self.compareLb,self.bg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-2))
	
	local contentNode = self:getContentNode()
	--self.titleBg = createScale9SpriteWithFrameNameAndSize(RES("login_common_formTitle1.png"), CCSizeMake(contentNode:getContentSize().width,34))
	self.titleBg = CCSprite:create()
	self.titleBg:setContentSize(CCSizeMake(contentNode:getContentSize().width,34))
	self:addChild(self.titleBg)
	VisibleRect:relativePosition(self.titleBg,self.bg,LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE,ccp(0,10))
end

function BasePromptBox:adjustBaseViewPos()
	VisibleRect:relativePosition(self.bg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.titleBg,self.bg,LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE,ccp(0,2))
end

function BasePromptBox:onCloseBtnClick()
	if self.closeNodify then
		self.closeNodify(self.closeArg)
	end
end

----------------------------------------------------------------------
--新手指引

--显示新手指引箭头
function BasePromptBox:showArrow()
	if self.btn then
		if not self.arrow then
			local function callback()
				self:hideArrow()
			end
			self.arrow = createArrow(direction.left,callback)		
			self.btn:addChild(self.arrow:getRootNode(),20)					
			VisibleRect:relativePosition(self.arrow:getRootNode(),self.btn,LAYOUT_CENTER,ccp(50,0))
		end
	end
end

--隐藏新手指引箭头
function BasePromptBox:hideArrow()
	if self.arrow then
		self.arrow:DeleteMe()
		self.arrow = nil
	end
end

----------------------------------------------------------------------
