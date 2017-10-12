require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.forging.ForgingDef")
	
WashPreview = WashPreview or BaseClass()

local const_scale = VisibleRect:SFGetScale()
local const_size = const_forgingPreviewSize
local const_scrollViewSize = CCSizeMake(const_size.width, const_forgingPreviewSize.height - 46 *const_scale)

function WashPreview:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()
	
	self:initBg()
	self:initScrollView()
	self.curPropertys = 
	{
--		name = {translateName = "", value = -1, maxValue = -1, isLock = false, isUp = nil}
	}
end

function WashPreview:__delete()
	self.rootNode:release()	
	self.scrollNode:release()
end

function WashPreview:getRootNode()
	return self.rootNode
end

function WashPreview:initBg()
end	

function WashPreview:setLockNotify(argg, gnotify)
	self.notify = {func = gnotify, arg = argg}
end
function WashPreview:initScrollView()
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(const_size)
	self.scrollNode:retain()
				
	self.scrollView = self:createScrollView(const_scrollViewSize)
	self.rootNode:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -50))	
end

function WashPreview:setEquip(equip, locks)
	self.equip = equip
	
	if (equip ~= nil) then		
		self.curPropertys = G_buildWashPropertys(equip, locks)
		self:displayPropertys(self.curPropertys)
	else
		self.scrollNode:removeAllChildrenWithCleanup(true)
	end
end			

local const_spacing = 15	
function WashPreview:displayPropertys(propertys)
	self.scrollNode:removeAllChildrenWithCleanup(true)
	
	if (propertys == nil) then	
		return
	end
	
	local nodes	 = {} 
	for i, property in pairs(propertys) do		
		if (self.notify) then	
			table.insert(nodes, self:createWashProperty(property, true, const_scrollViewSize, self.notify.func))
		else
			table.insert(nodes, self:createWashProperty(property, true, const_scrollViewSize, nil))
		end
	end	
	G_layoutContainerNode(self.scrollNode, nodes, const_spacing, E_DirectionMode.Vertical, const_scrollViewSize, true)	
	nodes = nil

	self.scrollView:setContainer(self.scrollNode)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(0, -self.scrollNode:getContentSize().height + const_scrollViewSize.height), false)
end	


function WashPreview:createWashProperty(property, bShowSelectBox, viewSize, notify)
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(property.translateName, "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow2"))	
	local value1Label 
	if (property.value == property.maxValue) then
		value1Label = createLabelWithStringFontSizeColorAndDimension(property.value, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow5"))		
	else
		value1Label = createLabelWithStringFontSizeColorAndDimension(property.value, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))		
	end
	
	--local pointer = createSpriteWithFrameName(RES("forging_rightArrow.png"))	
	
	local value2Text = string.format(Config.Words[576],property.maxValue)
	local value2Label = createLabelWithStringFontSizeColorAndDimension(value2Text, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))	
	local selectBox = nil
	if (bShowSelectBox == true) then
		selectBox = G_createWashSelectBox(property, notify)
	end
			
	local node = CCNode:create()
	node:addChild(keyLabel)
	node:addChild(value1Label)
	node:addChild(value2Label)
	--node:addChild(pointer)
		
	node:setContentSize(CCSizeMake(viewSize.width, keyLabel:getContentSize().height  + 6))	
		
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(80, 0))
	VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(180, 0))	
	--VisibleRect:relativePosition(pointer, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(230, 0))	
	VisibleRect:relativePosition(value2Label, value1Label, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y)		
		
	if (selectBox ~= nil) then
		node:addChild(selectBox)
	VisibleRect:relativePosition(selectBox, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(335, 0))
	end
	
	return node
end

function WashPreview:clearLockPropertys()
	if (self.curPropertys == nil) then
		return nil
	end
	for k, v in pairs(self.curPropertys) do
		v.isLock = false
	end
end

function WashPreview:getLockPropertys()
	if (self.curPropertys == nil) then
		return nil
	end
	local lock = {}
	for k, v in pairs(self.curPropertys) do
		if (v.isLock == true) then
			table.insert(lock, k)
		end
	end
	return lock
end

function WashPreview:createScrollView(viewSize)
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	return scrollView
end		