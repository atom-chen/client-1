require("common.baseclass")

LoadingSence= LoadingSence or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
function LoadingSence:__init ()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()
	self.delay = 3
	self.removeId = -1
	self.rebackId = -1
	self.fadeIn = 0.2
	self.time = 0.05
	
	self.limitLessTime = 1
	self.reBackTime = 0.1
	self.tallyTime = 0
	self.bRemove = false
	
	self:initBlackGround()
	self:initLogo()
	self:playAction1()
end

function LoadingSence:__delete()
	self.bRemove = true
	self:removeLoadingSence()
	self:deleteScheduler()
	self.rootNode = nil
end

function LoadingSence:getRootNode()
	return self.rootNode
end

function LoadingSence:initBlackGround()
	self.loadBg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_formBg2.png"),visibleSize)
	G_setBigScale(self.loadBg)
	self.rootNode:addChild(self.loadBg)
	VisibleRect:relativePosition(self.loadBg,self.rootNode,LAYOUT_CENTER)
end

function LoadingSence:setDelay(nDelay)
	self.delay = nDelay
end

function LoadingSence:setLoadingProgress(num)
	self.progressNum = num
end

function LoadingSence:initLogo()
	--Á£×ÓÏµÍ³
	--local particleSystemQuad = CCParticleSystemQuad:create("particleSystem/loadingFire.plist")
	--particleSystemQuad:setPositionType(kCCPositionTypeRelative)
	--self.loadBg:addChild(particleSystemQuad)
	--VisibleRect:relativePosition(particleSystemQuad,self.loadBg,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,-10))
	
	self.logo = createSpriteWithFrameName(RES("login_loadSence_logo.png"))
	self.loadBg:addChild(self.logo)
	VisibleRect:relativePosition(self.logo,self.loadBg,LAYOUT_CENTER,ccp(0,50))
	
	self.font = createSpriteWithFrameName(RES("login_loadSence_font.png"))
	self.loadBg:addChild(self.font)
	VisibleRect:relativePosition(self.font,self.logo,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(-20,-12))
	
	self.point = {}
	for i=1,3 do
		self.point[i] = createSpriteWithFrameName(RES("login_loadSence_point.png"))
		self.loadBg:addChild(self.point[i])
		self.point[i]:setOpacity(0)
		if i==1 then
			VisibleRect:relativePosition(self.point[i],self.font,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		else
			VisibleRect:relativePosition(self.point[i],self.point[i-1],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		end
	end
end

function LoadingSence:playAction1()
	local fadeIn = CCFadeIn:create(self.fadeIn)
	local dalayTime =  CCDelayTime:create(self.time)
	
	local function finishFogCallback()
		self:playAction2()
	end
	local callbackAction = CCCallFunc:create(finishFogCallback)
	
	local actionArray = CCArray:create()
	actionArray:addObject(fadeIn)
	actionArray:addObject(dalayTime)
	actionArray:addObject(callbackAction)
	self.point[1]:runAction(CCSequence:create(actionArray))
end

function LoadingSence:playAction2()
	local fadeIn = CCFadeIn:create(self.fadeIn)
	local dalayTime =  CCDelayTime:create(self.time)
	
	local function finishFogCallback()
		self:playAction3()
	end
	local callbackAction = CCCallFunc:create(finishFogCallback)
	
	local actionArray = CCArray:create()
	actionArray:addObject(fadeIn)
	actionArray:addObject(dalayTime)
	actionArray:addObject(callbackAction)
	self.point[2]:runAction(CCSequence:create(actionArray))
end

function LoadingSence:playAction3()
	local fadeIn = CCFadeIn:create(self.fadeIn)
	local dalayTime =  CCDelayTime:create(self.time)
	
	local function finishFogCallback()
		for i=1,3 do
			self.point[i]:setOpacity(0)
		end
		self:playAction4()
	end
	local callbackAction = CCCallFunc:create(finishFogCallback)
	
	local actionArray = CCArray:create()
	actionArray:addObject(fadeIn)
	actionArray:addObject(dalayTime)
	actionArray:addObject(callbackAction)
	self.point[3]:runAction(CCSequence:create(actionArray))
end

function LoadingSence:playAction4()
	for i=1,3 do
		local fadeOut = CCFadeOut:create(self.fadeIn)
		
		local function finishFogCallback()
			if i==3 then
				self:playAction1()
			end
		end
		local callbackAction = CCCallFunc:create(finishFogCallback)
		
		local actionArray = CCArray:create()
		actionArray:addObject(fadeOut)
		actionArray:addObject(callbackAction)
		self.point[i]:runAction(CCSequence:create(actionArray))
	end
	
end

function LoadingSence:show()
	if self.removeId ~= -1 then
		return
	end
	
	if self.hideFunction == nil then
		self.hideFunction = function ()
			self.bRemove = true
			self:deleteScheduler()
		end
	end
	self.removeId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.hideFunction, self.delay, false)
	self.bRemove = false
end

function LoadingSence:deleteScheduler()
	if self.removeId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.removeId)
		self.removeId = -1
	end
	self:reBackTimeFun()
end

function LoadingSence:reBackTimeFun()
	if self.rebackId ~= -1 then
		return
	end
	if self.reBackFunction == nil then
		self.reBackFunction = function ()
			self.bRemove = true
			self:removeLoadingSence()
		end
	end
	self.rebackId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackFunction, self.reBackTime, false)
end

function LoadingSence:removeLoadingSence()
	if self.bRemove then
		if self.rootNode then
			self.rootNode:removeFromParentAndCleanup(true)
			if self.rootNode:retainCount() > 0 then
				self.rootNode:release()				
			end		
			self.rootNode = nil		
			if self.removeId ~= -1 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.removeId)
				self.removeId = -1
			end
			if self.rebackId ~= -1 then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackId)
				self.rebackId = -1
			end
		end
	end
end

function LoadingSence:touchHandler(eventType, x, y)
	if self.rootNode then
		if self.rootNode:isVisible() and self.rootNode:getParent() then
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
end