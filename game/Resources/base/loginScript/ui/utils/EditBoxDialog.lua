require("common.baseclass")
require("common.LoginBaseUI")

EditBoxDialog = EditBoxDialog or BaseClass(LoginBaseUI)

local const_scale = VisibleRect:SFGetScale()
local const_size = VisibleRect:getScaleSize(CCSizeMake(380, 230))

function EditBoxDialog:__init()
	self.viewName = "EditBoxDialog"
	self.pressOk = false
	self:init(CCSizeMake(380, 190))
	self:initBg()
	self:initEditBox()
	self:initBtn()
	
end		

function EditBoxDialog:create()
	return EditBoxDialog.New()
end	

function EditBoxDialog:setTitleText(text)
	if (text == nil) then
		return
	end
	self.titleText = text
	if (self.titleLabel == nil) then
		self.titleLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", 25, FCOLOR("ColorWhite3"))
		self:setFormTitle(self.titleLabel, TitleAlign.Center)
		--self:addChild(self.titleLabel)
	else 
		self.titleLabel:setString(text)
	end
	--VisibleRect:relativePosition(self.titleLabel, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -20))
end

--[[
titleText:	标题文字
num:		初始数量
notify: 	回调函数。回调函数的参数说明：
			eventType： 1为数字变化事件，2为确定事件，2为取消事件
			num 	 ：	当前数字
			titleText： 标题文字;
--]]
function EditBoxDialog:setNotify(argg, gnotify)
	self.notify = {func = gnotify, arg = argg}
end

function EditBoxDialog:setNum(num)
	self.editBox:setText(string.format("%d", num))
end

function EditBoxDialog:getNum()
	return tonumber(self.editBox:getText())
end

function EditBoxDialog:setRange(min, max)
	if (min) then
		self.min = min
	end
	if (max) then
		self.max = max
	end
end
-----------------以下为私有方法------------------------

function EditBoxDialog:onEnter()
	self.pressOk = false
	end

function EditBoxDialog:onExit()
	if (self.pressOk) then
		self:doNotify(2)
	else
		self:doNotify(3)
	end
end

function EditBoxDialog:doNotify(eventType)
	if (self.notify) then
		self.notify.func(self.notify.arg, eventType, self:getNum(), self.titleText)
	end
end

function EditBoxDialog:initBg()
--[[	self.background:setVisible(false)
	
	self.background = createScale9SpriteWithFrameNameAndSize(RES("squares_bg1.png"), const_size)
	self:addChild(self.background, -10)
	VisibleRect:relativePosition(self.background, self.rootNode, LAYOUT_CENTER)--]]
end

--[[
titleText:	标题文字
num:		初始数量
notify: 	回调函数。回调函数的参数说明：
			eventType： 1为数字变化事件，2为确定事件，3为取消事件
			num 	 ：	当前数字
			titleText： 标题文字;
--]]
function EditBoxDialog:initBtn()
	local okBtn = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))
	local okText = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[10043], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
	self:addChild(okBtn)
	self:addChild(okText)
	VisibleRect:relativePosition(okBtn, self.editBox, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(90, -10))
	VisibleRect:relativePosition(okText, okBtn, LAYOUT_CENTER)
	local okClick = function()
		self.pressOk = true
		self:close()
	end
	okBtn:addTargetWithActionForControlEvents(okClick, CCControlEventTouchDown)
	
	local cancelBtn = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))
	local canceltext = createLabelWithStringFontSizeColorAndDimension(Config.LoginWords[10045], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
	self:addChild(cancelBtn)
	self:addChild(canceltext)
	VisibleRect:relativePosition(cancelBtn, self.editBox, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(-90, -10))
	VisibleRect:relativePosition(canceltext, cancelBtn, LAYOUT_CENTER)
	local cancelClick = function()
		self.pressOk = false
		self:close()
	end
	cancelBtn:addTargetWithActionForControlEvents(cancelClick, CCControlEventTouchDown)	
end

function EditBoxDialog:initEditBox()
	
	local subTouchEnd = function()
		self:sub(1)		
	end
	local subBtn = createLongPressButton("login_btn_minus.png", "login_btn_minus.png",subTouchEnd,subTouchEnd)		
	self:addChild(subBtn)
	
	local addTouchEnd = function()
		self:add(1)
	end				
	local addBtn = createLongPressButton("login_btn_add.png", "login_btn_add.png",addTouchEnd,addTouchEnd)		
	local addTouchEnd = function()
		self:add(1)		
	end
	
	self:addChild(addBtn)		
	self.editBox = createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(200, 40)), RES("login_editBox_bg.png"))	
	self.editBox:setInputMode(kEditBoxInputModeNumeric)	--只支持数字
	self:addChild(self.editBox)
	
	local function editboxEventHandler(eventType)		
		if eventType == "began" then			
		elseif eventType == "ended" then	
			self:checkNum()																
		elseif eventType == "changed" then					
			self:checkNum()
		elseif eventType == "return" then				
		end
	end
	self.editBox:registerScriptEditBoxHandler(editboxEventHandler)	
	
	VisibleRect:relativePosition(self.editBox, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -8))
	VisibleRect:relativePosition(addBtn, self.editBox, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	VisibleRect:relativePosition(subBtn, self.editBox, LAYOUT_CENTER_Y + LAYOUT_LEFT_OUTSIDE, ccp(-10, 0))	
end

function EditBoxDialog:add(step)
	local num = self:getNum()
	if num == nil then
		return
	end	
	local check
	if (self.max) then
		if (num + step > self.max) then
			return
		end
	end
	num = num + step
	self:setNum(num)
	self:doNotify(1)
end

function EditBoxDialog:sub(step)
	local num = self:getNum()
	if num == nil then
		return
	end
	local check
	if (self.min) then
		check = self.min
	else
		check = 1
	end
	if (num - step >= check) then
		num = num - 1
		self:setNum(num)
		self:doNotify(1)
	end
end	

function EditBoxDialog:checkNum()
	local min
	if (self.min) then
		min = self.min
	else
		min = 1
	end		
	
	local num = self:getNum()
	if num == nil then
		return
	end
	if num < min then
		self:setNum(min)
	elseif self.max and (num > self.max) then
		self:setNum(self.max)
	end
end