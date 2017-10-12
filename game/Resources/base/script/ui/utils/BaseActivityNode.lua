
BaseActivityNode = BaseActivityNode or BaseClass()

local titleNodeHeight = 50

function BaseActivityNode:__init(size)
	self.visible = true
	self:createRootNode(size)
	self:createTitle()
	self:createContentNode()
	self:registerScriptTouchHandler()
end

function BaseActivityNode:__delete()
	if self.rootNode then 
		self.rootNode:release()
		self.rootNode = nil
	end
end

function BaseActivityNode:createRootNode(size)
	self.contentNodeSize = size
	self.rootNode = CCLayer:create()	
	self.rootNode:setTouchEnabled(true)
	self.rootNode:retain()
	self.rootNode:setContentSize(CCSizeMake(size.width, size.height+titleNodeHeight))	
end

function BaseActivityNode:createTitle()
	self.titleNode = CCNode:create()
	self.titleNode:setContentSize(CCSizeMake(self.contentNodeSize.width, titleNodeHeight))
	self.rootNode:addChild(self.titleNode)
	VisibleRect:relativePosition(self.titleNode, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X)
	
	local titleHeight = 30
	self.titleBg = createScale9SpriteWithFrameNameAndSize(RES("main_questCurrentBackground.png"), CCSizeMake(self.contentNodeSize.width-40, titleHeight))
	self.titleNode:addChild(self.titleBg)
	VisibleRect:relativePosition(self.titleBg, self.titleNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y, ccp(0, -3))
		
	local arrowLeft = createButtonWithFramename(RES("main_questcontraction.png"))
	self.rootNode:addChild(arrowLeft)
	VisibleRect:relativePosition(arrowLeft, self.titleNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(0, -3))	
	
	local visibleCB = function ()
		self.visible = not self.visible
		self:setVisibleWithAction(self.visible)		
		if self.visible then 
			arrowLeft:setRotation(0)
		else
			arrowLeft:setRotation(180)
		end	
	end
	arrowLeft:addTargetWithActionForControlEvents(visibleCB, CCControlEventTouchUpInside)
end

function BaseActivityNode:createContentNode()
	self.contentNode = CCNode:create()
	self.contentNode:setContentSize(self.contentNodeSize)
	self.rootNode:addChild(self.contentNode)
	VisibleRect:relativePosition(self.contentNode, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X)
	--±³¾°
	local bg = createScale9SpriteWithFrameNameAndSize(RES("main_questListBackground.png"), self.contentNodeSize)
	self.contentNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.contentNode, LAYOUT_CENTER)
end

function BaseActivityNode:getVisible()
	return self.visible
end

function BaseActivityNode:setVisibleWithAction(bVisible)
	local moveWidth = self.rootNode:getContentSize().width
	local moveBy1, moveBy2
	if bVisible then
		moveBy1 = CCMoveBy:create(0.5,ccp(moveWidth, 0))	
		moveBy2 = CCMoveBy:create(0.5,ccp(moveWidth, 0))		
	else
		moveBy1 = CCMoveBy:create(0.5,ccp(-moveWidth, 0))
		moveBy2 = CCMoveBy:create(0.5,ccp(-moveWidth, 0))	
	end
	self.contentNode:runAction(moveBy1)
	self.titleNode:runAction(moveBy2)
end

function BaseActivityNode:getRootNode()
	return self.rootNode
end

function BaseActivityNode:getContentNode()
	return self.contentNode
end

function BaseActivityNode:addChild(node)
	if not node then 	
		return
	end
	self.contentNode:addChild(node)
end

function BaseActivityNode:setTitle(title)
	if not title then 
		return
	end
	self.titleBg:addChild(title)
	VisibleRect:relativePosition(title, self.titleBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(5, 0))
end

function BaseActivityNode:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function BaseActivityNode:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end