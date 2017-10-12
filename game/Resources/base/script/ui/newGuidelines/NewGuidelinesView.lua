require("ui.utils.ClippingSprite")

NewGuidelinesView = NewGuidelinesView or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

direction = {
up = 270,
left = 180,
down = 90,
right = 0,
}

function NewGuidelinesView:create()
	return NewGuidelinesView.New()
end

function NewGuidelinesView:__init()
	self.viewName = "NewGuidelinesView"
	self.bOpenView = false
	self.mainQuestId = nil
	self.actionIndex = nil	
	self.manager = UIManager.Instance
	
	self.countdownSchedulerId = -1

	self.rootNode = CCNode:create()

	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()	
		
	--self:createScheduler()
end

function NewGuidelinesView:__delete()
	self:clearScheduler()
	
	if self.arrow then
		self.arrow:removeFromParentAndCleanup(true)
		self.arrow = nil
	end
	
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
	
	if self.forever then
		self.forever:release()
		self.forever = nil
	end
end

function NewGuidelinesView:getRootNode()
	return self.rootNode
end	

function NewGuidelinesView:setDirection(dir)
	if dir then
		self:createAnimation(dir)
	end
end	

function NewGuidelinesView:setCallBlackFunc(func)
	if func then
		self.func = func
	end	
end

function NewGuidelinesView:doCallBlackFunc()
	if self.func then
		self.func()
	end
end	

--播放指引动画
function NewGuidelinesView:playAnimation()
	self:createAnimation(direction.up)
	self:createAnimation(direction.left)
	self:createAnimation(direction.down)
	self:createAnimation(direction.right)	
end

function NewGuidelinesView:createAnimation(dir)
	local moveSpeed = 0.3
	local moveOffset = 50
	local array = CCArray:create()
	local moveLeft = CCMoveBy:create(moveSpeed, ccp(moveOffset,0))
	local moveRight = CCMoveBy:create(moveSpeed, ccp(-moveOffset,0))
	local moveUp = CCMoveBy:create(moveSpeed, ccp(0,moveOffset))
	local moveDown = CCMoveBy:create(moveSpeed, ccp(0,-moveOffset))
			
	self.arrow = createSpriteWithFrameName(RES("newGuidelines_Arrow.png"))
	local arrowSize = self.arrow:getContentSize()
	self.arrow:setAnchorPoint(ccp(1,0.5))
	self.arrow:setRotation(dir)
	self.rootNode:addChild(self.arrow)
	
	self.rootNode:setContentSize(arrowSize)
	
	if dir == direction.left then
		array:addObject(moveLeft)
		array:addObject(moveRight)
		VisibleRect:relativePosition(self.arrow, self.rootNode, LAYOUT_CENTER,ccp(-arrowSize.width/4-arrowSize.height/2-3,0))
	elseif dir == direction.right then
		array:addObject(moveRight)
		array:addObject(moveLeft)		
		VisibleRect:relativePosition(self.arrow, self.rootNode, LAYOUT_CENTER,ccp(-arrowSize.width/4-arrowSize.height/2-3,0))
	elseif dir == direction.up then
		array:addObject(moveDown)
		array:addObject(moveUp)
		VisibleRect:relativePosition(self.arrow, self.rootNode, LAYOUT_CENTER,ccp(-arrowSize.width/4+3,0))
	elseif dir == direction.down then		
		array:addObject(moveUp)
		array:addObject(moveDown)
		VisibleRect:relativePosition(self.arrow, self.rootNode, LAYOUT_CENTER,ccp(-arrowSize.width/4+3,0))
	end
	
	local seqAction = CCSequence:create(array)
	self.forever = CCRepeatForever:create(seqAction)
	self.forever:retain()
	self.arrow:runAction(self.forever)
end

function NewGuidelinesView:gorunAction()
	if self.forever and self.arrow then
		self.arrow:stopAllActions()
		self.arrow:runAction(self.forever)
	end
end

function NewGuidelinesView:setHideArrow()
	if self.arrow then
		self.arrow:setVisible(false)
	end
end

function NewGuidelinesView:createScheduler()
	if self.countdownSchedulerId == -1 then
		if self.countdownFunction == nil then
			self.countdownFunction = function ()
				self:doCallBlackFunc()
				self:setHideArrow()
				self:clearScheduler()
			end
		end				
		self.countdownSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.countdownFunction, 10, false)
	end	
end

function NewGuidelinesView:clearScheduler()
	if self.countdownSchedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.countdownSchedulerId)
		self.countdownSchedulerId = -1	
	end
end