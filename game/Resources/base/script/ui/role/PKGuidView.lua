require("ui.UIManager")
require("common.BaseUI")

PKGuidView = PKGuidView or BaseClass(BaseUI)
local viewSize = CCSizeMake(823,490)

local PkModeText = {}
PkModeText[1] = Config.Words[22001]
PkModeText[2] = Config.Words[22002]
PkModeText[3] = Config.Words[22003]
PkModeText[4] = Config.Words[22004]
PkModeText[5] = Config.Words[22005]
PkModeText[6] = Config.Words[22006]

function PKGuidView:__init()
	self.viewName = "PKGuidView"
	local title = createSpriteWithFrameName(RES("guid_pk_title.png"))
	local frameSize = CCSizeMake(931, 578)
	self:createVipFrame(frameSize, title)
	self:createVipFrameCloseBtn()
	self:initStaticView()
end	

function PKGuidView:__delete()
	
end	
function PKGuidView:create()
	return PKGuidView.New()
end	

function PKGuidView:initStaticView()
	self.wholeBg = createScale9SpriteWithFrameName(RES("squares_bg2.png"))
	self.wholeBg:setContentSize(CCSizeMake(815, 475))
	self:addChild(self.wholeBg)	
	VisibleRect:relativePosition(self.wholeBg,self:getContentNode(),LAYOUT_CENTER, ccp(0, -5))

	local lineSpr = createScale9SpriteWithFrameNameAndSize(RES("talisman_columnLine.png"),CCSizeMake(2,460))
	self.wholeBg:addChild(lineSpr)	
	VisibleRect:relativePosition(lineSpr,self.wholeBg,LAYOUT_CENTER,ccp(10,0))	
	
	self:initLeft()
	self:initRight()	
end

function PKGuidView:initLeft()
	local textSpr1 = createSpriteWithFrameName(RES("guid_pk_text1.png"))
	self.wholeBg:addChild(textSpr1)	
	VisibleRect:relativePosition(textSpr1,self.wholeBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(27,-25))	
	
	local textSpr2 = createSpriteWithFrameName(RES("guid_pk_text2.png"))
	self.wholeBg:addChild(textSpr2)	
	VisibleRect:relativePosition(textSpr2,textSpr1,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-10))	
	
	local guidSpr = CCSprite:create("ui/ui_img/activity/guid_pk_left.pvr")
	self.wholeBg:addChild(guidSpr)	
	VisibleRect:relativePosition(guidSpr,textSpr2,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-10))		
		
	local bt = createButtonWithFramename(RES("btn_1_select.png"))
	self.wholeBg:addChild(bt)	
	local btText = createSpriteWithFrameName(RES("word_button_iknow.png"))
	bt:setTitleString(btText)
	VisibleRect:relativePosition(bt,guidSpr,LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-10))		
	
	local btFunc = function()
		self:close()			
	end
	bt:addTargetWithActionForControlEvents(btFunc,CCControlEventTouchDown)
end

function PKGuidView:initRight()
	local headSprite = CCSprite:create("ui/ui_img/activity/guid_pk_head.pvr")
	self.wholeBg:addChild(headSprite)	
	VisibleRect:relativePosition(headSprite,self.wholeBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(427,-5))	
	
	local startY = 300
	for i = 1 , 5 do
		local label = createLabelWithStringFontSizeColorAndDimension(PkModeText[i],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
		label:setAnchorPoint(ccp(0,0.5))
		self.wholeBg:addChild(label)	
		VisibleRect:relativePosition(label,self.wholeBg,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(427, startY))	
		
		local lineSpr = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(360,3))
		self.wholeBg:addChild(lineSpr)	
		VisibleRect:relativePosition(lineSpr,label,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(10, -10))	
		startY = startY - 45
	end
	
	local tipsLabel = createLabelWithStringFontSizeColorAndDimension(PkModeText[6],"Arial",FSIZE("Size3"),FCOLOR("ColorRed1"),CCSizeMake(380,0))
	tipsLabel:setAnchorPoint(ccp(0,1))
	self.wholeBg:addChild(tipsLabel)	
	VisibleRect:relativePosition(tipsLabel,self.wholeBg,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(427, startY - 40))		

end


