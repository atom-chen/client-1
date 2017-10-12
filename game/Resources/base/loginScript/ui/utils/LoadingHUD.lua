require("common.baseclass")

LoadingHUD= LoadingHUD or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
function LoadingHUD:__init ()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()
	self.loadSprite = createSpriteWithFrameName(RES("login_loading.png"))
	self.rootNode:addChild(self.loadSprite)
	VisibleRect:relativePosition(self.loadSprite,self.rootNode,LAYOUT_CENTER)
	self.delay = 3
	self.removeId = -1
	self.touchArea = nil
	self.hideFunction = nil
end

function LoadingHUD:__delete()
	self:removeLoadingHUD()
	if self.rootNode then	
		self.rootNode:unregisterScriptTouchHandler()
		self.rootNode:release()
	end			
	self.rootNode = nil
end

function LoadingHUD:setDelay(nDelay)
	self.delay = nDelay
	if self.delay < 0.35 then
	
	end
end

function LoadingHUD:setTouchArea(rect)
	self.touchArea = rect
end

function LoadingHUD:setHideOnTouch(bHideOnTouch)
	self.bHideOnTouch = bHideOnTouch
end

function LoadingHUD:setHideFunction(func)
	self.hideFunction = function ()
		if type(func) == "function" then
			func()
		end
		self:removeLoadingHUD()
	end
end

function LoadingHUD:show()
	-- 300ms 以内不显示
	local hideFunc
	if self.hideFunction == nil then
		self.hideFunction = function ()
			self:removeLoadingHUD()
		end
	end		
	local rotate = CCRotateBy:create(0.5,360)
	local repeatForever = CCRepeatForever:create(rotate)
	self.loadSprite:runAction(repeatForever)
	self.removeId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.hideFunction, self.delay, false)
end

function LoadingHUD:touchHandler(eventType, x, y)
	if self.rootNode and self.rootNode:isVisible() and self.rootNode:getParent() then			
		local parent =self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local size = parent:getContentSize()
		local rect = CCRectMake(0,0,size.width,size.height)	
		if self.touchArea and self.touchArea:containsPoint(point)  then
			return 0
		else
			if rect:containsPoint(point) then
				return 1
			else
				return 0
			end
		end			
	else
		return 0
	end		
end

function LoadingHUD:getRootNode()
	return self.rootNode
end

function LoadingHUD:releaseSchedule()
	if self.removeId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.removeId)
		self.removeId = -1
	end	
end

function LoadingHUD:removeLoadingHUD()
	if self.releaseSchedule then
		self:releaseSchedule()		
	end	
	if self then
		if self.rootNode and self.rootNode.getParent then
			local parrent = self.rootNode:getParent()
			if parrent then
				self.rootNode:removeFromParentAndCleanup(true)
			end	
		end	
	end	
end