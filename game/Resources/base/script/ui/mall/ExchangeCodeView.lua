require("ui.UIManager")
require("common.BaseUI")

ExchangeCodeView = ExchangeCodeView or BaseClass(BaseUI)

local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function ExchangeCodeView:__init()
	self.viewName = "ExchangeCodeView"
	local title = createSpriteWithFrameName(RES("word_window_activityCode.png"))
	self:createVipFrame(CCSizeMake(800, 500), title)
	self:createVipFrameCloseBtn()
	
	self:initButton()
	self:initEditBox()
end

function ExchangeCodeView:create()
	return ExchangeCodeView.New()
end

function ExchangeCodeView:initButton()
	local exchangeButton = createButtonWithFramename(RES("btn_1_select.png"))
	local buttonText = createSpriteWithFrameName(RES("word_button_exchange.png"))
	exchangeButton:setTitleString(buttonText)
	self:addChild(exchangeButton)
	VisibleRect:relativePosition(exchangeButton, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(180, -60))
	--local mallMgr = GameWorld.Instance:getMallManager()
	local exchangeCodeMgr = GameWorld.Instance:getExchangeCodeMgr()
	local exchangeFun = function ()
		local code = self.codeEditBox:getText()
		if code ~= "" then
			--mallMgr:requestGiftExchange(code)
			exchangeCodeMgr:requireExchange(code)
			UIManager.Instance:showLoadingHUD(20)
		else
			UIManager.Instance:showSystemTips(Config.Words[25003])
		end			
	end
	exchangeButton:addTargetWithActionForControlEvents(exchangeFun, CCControlEventTouchDown)
	
	local cancelButton = createButtonWithFramename(RES("btn_1_select.png"))
	local buttonText = createSpriteWithFrameName(RES("word_button_cancel.png"))
	cancelButton:setTitleString(buttonText)
	self:addChild(cancelButton)
	VisibleRect:relativePosition(cancelButton, self:getContentNode(), LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y, ccp(-180, -60))	
	local exchangeFun = function ()
		self:close()	
	end
	cancelButton:addTargetWithActionForControlEvents(exchangeFun, CCControlEventTouchDown)
end

function ExchangeCodeView:initEditBox()
	self.codeEditBox = createEditBoxWithSizeAndBackground(CCSizeMake(500, 45), RES("commom_editFrame.png"))
	self.codeEditBox:setMaxLength(20)	
	self.codeEditBox:setFontSize(FSIZE("Size4"))
	self.codeEditBox:setFontColor(FCOLOR("ColorYellow10"))
	self.codeEditBox:setText("")		
	
	self:addChild(self.codeEditBox)
	VisibleRect:relativePosition(self.codeEditBox, self:getContentNode(), LAYOUT_CENTER, ccp(0, 50))
	
	local editBoxDes = createLabelWithStringFontSizeColorAndDimension(Config.Words[25001], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow10"))
	self:addChild(editBoxDes)
	VisibleRect:relativePosition(editBoxDes, self.codeEditBox, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE, ccp(0, 50))
end

function ExchangeCodeView:resetEditBox()
	UIManager.Instance:showSystemTips(Config.Words[25002])
	self.codeEditBox:setText("")
	self:close()
end

