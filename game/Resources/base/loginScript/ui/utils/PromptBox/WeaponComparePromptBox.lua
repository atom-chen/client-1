require("common.LoginBaseUI")
require("ui.utils.PromptBox.ComparePromptBox")

WeaponComparePromptBox = WeaponComparePromptBox or BaseClass(ComparePromptBox)

local const_scale = VisibleRect:SFGetScale()
local const_TAG_ICON = 10
local constViewSize = CCSizeMake(400,550)

function WeaponComparePromptBox:create()
	return WeaponComparePromptBox.New()
end

function WeaponComparePromptBox:__init()
	self:setViewSize(constViewSize)
	self:initWeaponCompareStaticBg()
end

function WeaponComparePromptBox:initWeaponCompareStaticBg()
	--self:initCompareStaticBg()
	self.lowBg = createScale9SpriteWithFrameNameAndSize(RES("login_suqares_goldFrameBg.png"), CCSizeMake(350,177))	
	self:addChild(self.lowBg)
	VisibleRect:relativePosition(self.lowBg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,-233))	
	self.bestLb = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2"),FCOLOR("ColorYellow2"))
	self:addChild(self.bestLb)
	VisibleRect:relativePosition(self.bestLb,self.lowBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,5))
	
	self.bestIconBg = createButtonWithFramename(RES("login_common_seniorFrame.png"),RES("login_common_seniorFrame.png"))
	self.bestIconBg:setZoomOnTouchDown(false)
	self.bestIconWordNode = CCNode:create()
	self.bestIconWordNode:setContentSize(CCSizeMake(FSIZE("Size2")*6,FSIZE("Size2")))
	self:addChild(self.bestIconBg)
	self:addChild(self.bestIconWordNode)
	
	self:adjustWeaponCompareViewPos()
end	

function WeaponComparePromptBox:setBestLabel(des)
	if des == nil then
		self.bestLb:setString("")
		VisibleRect:relativePosition(self.bestLb,self.lowBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,5))
	else
		self.bestLb:setString(des)
		VisibleRect:relativePosition(self.bestLb,self.lowBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,5))
	end
end

function WeaponComparePromptBox:setBestWord(bestIconWord)
	if bestIconWord then
		if not bestColor then
			bestColor = FCOLOR("ColorYellow5")
		end
		self.bestIconWordNode:removeAllChildrenWithCleanup(true)
		local bestIconWordLb = createLabelWithStringFontSizeColorAndDimension(bestIconWord,"Arial",FSIZE("Size2"),bestColor)
		self.bestIconWordNode:addChild(bestIconWordLb)
		VisibleRect:relativePosition(bestIconWordLb,self.bestIconWordNode,LAYOUT_CENTER)
	end
end

function WeaponComparePromptBox:setBestIcon(bestIconName,bestIconNodify,bestColor)
	if bestIconName then
		if self.bestIconBg:getChildByTag(const_TAG_ICON) then
			self.bestIconBg:removeChildByTag(const_TAG_ICON,true)
		end	
		self:adjustWeaponCompareViewPos()
		if type(bestIconName) == "string" then
			local curIcon = createSpriteWithFileName(ICON(bestIconName))
			self.bestIconBg:addChild(curIcon)
			curIcon:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(curIcon,self.bestIconBg,LAYOUT_CENTER)
		else
			self.bestIconBg:addChild(bestIconName)
			bestIconName:setTag(const_TAG_ICON)
			VisibleRect:relativePosition(bestIconName,self.bestIconBg,LAYOUT_CENTER)
		end
		if bestIconNodify then
			self.bestIconBg:setZoomOnTouchDown(true)			
			local bestIconFunc = function()
				bestIconNodify()
			end
			self.bestIconBg:addTargetWithActionForControlEvents(bestIconFunc,CCControlEventTouchDown)	
		end
	end		
end

function WeaponComparePromptBox:setExchangeBtn(btnTitle,nodifyFunc,arg)
	if self.exchangeBtn then
		self.exchangeBtn:removeFromParentAndCleanup(true)
	end
	self.exchangeBtn = createButtonWithFramename(RES("btn_1_select.png"))
	if btnTitle then
		if string.find(btnTitle,".png") then
			local btnTitleImg = createSpriteWithFrameName(RES(btnTitle))
			self.exchangeBtn:setTitleString(btnTitleImg)
		else
			local btnTitleImg = createLabelWithStringFontSizeColorAndDimension(btnTitle,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow5"))
			self.exchangeBtn:setTitleString(btnTitleImg)
		end
	end
	if nodifyFunc then
		local onClick = function()	
			nodifyFunc(arg)
		end			
		self.exchangeBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	end
	self:addChild(self.exchangeBtn)
	VisibleRect:relativePosition(self.exchangeBtn,self.lowBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
end

function WeaponComparePromptBox:adjustWeaponCompareViewPos()
	self:adjustCompareViewPos()
	VisibleRect:relativePosition(self.bestIconBg,self.lowBg,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-22))
	VisibleRect:relativePosition(self.bestIconWordNode,self.bestIconBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE,ccp(0,5))
end

function WeaponComparePromptBox:delete()
	
end