require("common.LoginBaseUI")
require("ui.utils.PromptBox.BasePromptBox")

ComparePromptBox = ComparePromptBox or BaseClass(BasePromptBox)

local const_scale = VisibleRect:SFGetScale()
local constVIewSize = CCSizeMake(400,290)
local const_TAG_ICON = 10
function ComparePromptBox:create()
	return ComparePromptBox.New()
	
end

function ComparePromptBox:__init()
	self:setViewSize(constVIewSize)
	self:initCompareStaticBg()
end

function ComparePromptBox:initCompareStaticBg()
	self:initStaticBg()
	self.curIconBg = createButtonWithFramename(RES("login_mall_goodsframe.png"),RES("login_mall_goodsframe.png"))
	self.nextIconBg = createButtonWithFramename(RES("login_mall_goodsframe.png"),RES("login_mall_goodsframe.png"))
	self.curIconBg:setZoomOnTouchDown(false)
	self.nextIconBg:setZoomOnTouchDown(false)
	self.arrow = createSpriteWithFrameName(RES("login_knight_arrow.png"))--�滻ͼƬ
	self.curIconWordNode = CCNode:create()
	self.nextIconWordNode = CCNode:create()
	self.curIconWordNode:setContentSize(CCSizeMake(FSIZE("Size2")*6,FSIZE("Size2")))
	self.nextIconWordNode:setContentSize(CCSizeMake(FSIZE("Size2")*6,FSIZE("Size2")))
	self:addChild(self.curIconBg)
	self:addChild(self.nextIconBg)
	self:addChild(self.curIconWordNode)
	self:addChild(self.nextIconWordNode)
	self:addChild(self.arrow)
	self:adjustCompareViewPos()
end

function ComparePromptBox:setIcon(curIconName,nextIconName,curIconNodify,nextIconNodify)
	if curIconName and nextIconName then
		--self.curIconBg:removeAllChildrenWithCleanup(true)
		--self.nextIconBg:removeAllChildrenWithCleanup(true)
		if self.curIconBg:getChildByTag(const_TAG_ICON) then
			self.curIconBg:removeChildByTag(const_TAG_ICON,true)
		end
		if self.nextIconBg:getChildByTag(const_TAG_ICON) then
			self.nextIconBg:removeChildByTag(const_TAG_ICON,true)
		end
		self:adjustCompareViewPos()
		if type(curIconName) == "string" then
			local curIcon = createSpriteWithFileName(ICON(curIconName))
			self.curIconBg:addChild(curIcon)
			curIcon:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(curIcon,self.curIconBg,LAYOUT_CENTER)
		else
			self.curIconBg:addChild(curIconName)
			curIconName:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(curIconName,self.curIconBg,LAYOUT_CENTER)
		end
		if type(nextIconName) == "string" then
			local nextIcon = createSpriteWithFileName(ICON(nextIconName))
			self.nextIconBg:addChild(nextIcon)
			nextIcon:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(nextIcon,self.nextIconBg,LAYOUT_CENTER)
		else
			self.nextIconBg:addChild(nextIconName)
			nextIconName:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(nextIconName,self.nextIconBg,LAYOUT_CENTER)
		end
		if curIconNodify then
			self.curIconBg:setZoomOnTouchDown(true)			
			local curIconFunc = function()
				curIconNodify()
			end
			self.curIconBg:addTargetWithActionForControlEvents(curIconFunc,CCControlEventTouchDown)	
		end
		if nextIconNodify then
			self.nextIconBg:setZoomOnTouchDown(true)
			local nextIconFunc = function()
				nextIconNodify()
			end
			self.nextIconBg:addTargetWithActionForControlEvents(nextIconFunc,CCControlEventTouchDown)	
		end
	end
end

function ComparePromptBox:setIconWord(curIconWord,nextIconWord,curColor,nextColor)
	if curIconWord and nextIconWord then
		if not curColor then
			curColor = FCOLOR("ColorYellow5")
		end
		if not nextColor then
			nextColor = FCOLOR("ColorYellow5")
		end
		self.curIconWordNode:removeAllChildrenWithCleanup(true)
		self.nextIconWordNode:removeAllChildrenWithCleanup(true)
		local curIconWordLb = createLabelWithStringFontSizeColorAndDimension(curIconWord,"Arial",FSIZE("Size2"),curColor)
		local nextIconWordLb = createLabelWithStringFontSizeColorAndDimension(nextIconWord,"Arial",FSIZE("Size2"),nextColor)
		self.curIconWordNode:addChild(curIconWordLb)
		self.nextIconWordNode:addChild(nextIconWordLb)
		VisibleRect:relativePosition(curIconWordLb,self.curIconWordNode,LAYOUT_CENTER)
		VisibleRect:relativePosition(nextIconWordLb,self.nextIconWordNode,LAYOUT_CENTER)
	end
end

function ComparePromptBox:adjustCompareViewPos()
	self:adjustBaseViewPos()
	VisibleRect:relativePosition(self.curIconBg,self.bg,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(33,13))
	VisibleRect:relativePosition(self.arrow,self.curIconBg,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(33,0))
	VisibleRect:relativePosition(self.nextIconBg,self.arrow,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(33,0))
	VisibleRect:relativePosition(self.curIconWordNode,self.curIconBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,5))
	VisibleRect:relativePosition(self.nextIconWordNode,self.nextIconBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,5))
end

function ComparePromptBox:delete()
	
end