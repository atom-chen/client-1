require("common.baseclass")
require("common.LoginBaseUI")


MessageBoxWithEdit = MessageBoxWithEdit or BaseClass(LoginBaseUI)

local const_scale = VisibleRect:SFGetScale()

local const_btnZ		=	50
local const_btnTextZ 	=	60
local const_marginH = 10
local defaultSize = CCSizeMake(305, 180)

local const_defaultBtns = 
{
	{text = Config.LoginWords[10045],	id = 1, pic = "login_word_button_cancel.png"},
	{text = Config.LoginWords[10043],	id = 2, pic = "login_word_button_sure.png"}
}

function MessageBoxWithEdit:__init()
	self.viewName = "MessageBoxWithEdit"	
	self:initWithBg(defaultSize, RES("login_squares_bg1.png"), false)	
	
	self.btns = const_defaultBtns
	self.btnHeight = 0	
	self.btnWidth = 0
	
	self.pressBtn = {text = "", id = -1}
	self:setBtns(const_defaultBtns)
	self:registerScriptTouchHandler()
end		


function MessageBoxWithEdit:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.Control, true)
end

function MessageBoxWithEdit:touchHandler(eventType, x, y)
	if self:getContentNode():isVisible() and self:getContentNode():getParent() then	
		local parent = self:getContentNode():getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self:getContentNode():boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

function MessageBoxWithEdit:initView(text)
	if self.title == nil then		
		self.labelFrame = createSpriteWithFrameName(RES("login_chat_light.png"))			
		self.title = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorYellow4"))
		self.editBoxSize = CCSizeMake(defaultSize.width-50, 36)
		self.editBox = createEditBoxWithSizeAndBackground(self.editBoxSize, RES("login_commom_editFrame.png"))
				
		self.labelFrame:addChild(self.title)
		self:setFormTitle(self.labelFrame,TitleAlign.Center)
			
		self:addChild(self.editBox)
				
		VisibleRect:relativePosition(self.title, self.labelFrame, LAYOUT_CENTER)	
		VisibleRect:relativePosition(self.editBox, self.labelFrame, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -30))
		VisibleRect:relativePosition(self.editBox, self:getContentNode(), LAYOUT_CENTER_X)
	end
	
	text = string.gsub(text, "^%s*(.-)%s*$", "%1")
	if text == "" then 
		self.labelFrame:setVisible(false)
	else	
		self.labelFrame:setVisible(true)
	end
	self.title:setString(text)
end
	
function MessageBoxWithEdit:getText()
	local text = self.editBox:getText()
	return text
end

function MessageBoxWithEdit:setEditWord(word,size)
	self.editBox:setFontName("Arial")
	self.editBox:setText(word)
	self.editBox:setFontSize(size)		
end

function MessageBoxWithEdit:reset()
	self.editBox:setText("")
end

function MessageBoxWithEdit:onExit()
	self.customSize = nil
	self.btnHeight = 0	
	self.btnWidth = 0
	
	self:doNotify(self:getText(), self.pressBtn.id)
	self.pressBtn = {text = "", id = -1}
end

function MessageBoxWithEdit:create()
	return MessageBoxWithEdit.New()
end				

function MessageBoxWithEdit:setBtns(btns)
	for i, btn in pairs(self.btns) do
		self:getContentNode():removeChild(btn.obj, true)
		self:getContentNode():removeChild(btn.label, true)
		btn.obj = nil
		btn.label = nil
	end
	if (btns == nil) then
		self.btns = const_defaultBtns
	else
		self.btns = btns
	end
	self.btnHeight = 0
	self.btnWidth = 0
	for i, btn in pairs(self.btns) do
		if btn.text == const_defaultBtns[i].text and btn.id == const_defaultBtns[i].id then 
			btn.obj, btn.label = self:createBtn(btn.text, btn.id, btn.pic)
		else
			btn.obj, btn.label = self:createBtn(btn.text, btn.id)
		end
		
		if (btn.obj:getContentSize().height > self.btnHeight) then
			self.btnHeight = btn.obj:getContentSize().height
		end
		self.btnWidth = self.btnWidth + btn.obj:getContentSize().width
	end	
	self.btnHeight = self.btnHeight + 10	
end

function MessageBoxWithEdit:setNotify(argg, gnotify)
	self.notify = {func = gnotify, arg = argg}
end


function MessageBoxWithEdit:createBtn(text, id, pic)
	local label = nil 
	if pic then 
		label = createSpriteWithFrameName(RES(pic))
	else
		label = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow7"))	
	end 		
				
	local btn = createButtonWithFramename(RES("login_btn_1_select.png"), RES("login_btn_1_select.png"))
	local onClick = function()	
		self.pressBtn = {["text"] = text, ["id"] = id}
		self:close()
	end			
	btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	self:addChild(btn, const_btnZ)
	self:addChild(label, const_btnTextZ)

	VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)	
	
	return btn, label
end

function MessageBoxWithEdit:doNotify(text, id)
	if (self.notify and self.notify.func) then
		self.notify.func(self.notify.arg, text, id)
	end
end

function MessageBoxWithEdit:layout()
	local previousNode = self.editBox
	local cnt = table.size(self.btns)
	local space = (self.editBoxSize.width - self.btnWidth)/(cnt-1)
	if space < 0 then 
		space = 0
	end
	for i, btn in ipairs(self.btns) do
		if (previousNode == self.editBox) then
			VisibleRect:relativePosition(btn.obj, previousNode, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(0, -8))			
		else
			VisibleRect:relativePosition(btn.obj, previousNode, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(space, 0))
		end
		VisibleRect:relativePosition(btn.label, btn.obj, LAYOUT_CENTER)
		previousNode = btn.obj
	end
end
