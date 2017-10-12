SystemTipsWithItem = SystemTipsWithItem or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()


function SystemTipsWithItem:__init(refId,count)
	self.tipsCount = 0	
	self.refId = refId
	self.rootNode = CCLayer:create()
	self.background = CCLayer:create()	
	self.background:setContentSize(visibleSize)
	self.rootNode:setTouchEnabled(true)	
	self.rootNode:setContentSize(CCSizeMake(960,60))
	self.rootNode:retain()	
	self.rootNode:addChild(self.background)
	VisibleRect:relativePosition(self.background, self.rootNode, LAYOUT_CENTER)	
	
	self:initNode(refId,count)
	self:setTipsEffect(1)
	local eventPickLootHandle = function()
		self.tipsCount = self.tipsCount + 1
		if self.tipsCount < 4 then
			local x = self.rootNode:getPositionX()
			local y = self.rootNode:getPositionY()			
			self.rootNode:runAction(CCMoveTo:create(0.2,ccp(x,y + 70)))
		else	
			self:moveItemToHead(self.refId)		
		end
	end
	self.bindId = GlobalEventSystem:Bind(GameEvent.EventPickLootItem,eventPickLootHandle)	
end

function SystemTipsWithItem:moveItemToHead(refId)
	local x = self.rootNode:getPositionX()
	local y = self.rootNode:getPositionY()	
	self.rootNode:stopAllActions()
	
	if self.bindId then
		GlobalEventSystem:UnBind(self.bindId)
		self.bindId = nil
	end

	--local moveTo =  CCMoveTo:create(1,ccp( -x + 90 ,640 - y - 90))
	
	local config = ccBezierConfig()
	config.endPosition = ccp( -x + 90 ,visibleSize.height - y - 90)
	config.controlPoint_1 = ccp( 600 ,visibleSize.height - y - 90)
	config.controlPoint_2 = ccp( 600 ,visibleSize.height - y - 90)
		
	action = CCEaseIn:create(CCBezierTo:create(0.8, config), 4)
	
	local fadeOut = CCFadeOut:create(0.1)
	local releaseCall = function()
		self.rootNode:setVisible(false)
		if self.rootNode then
			self.rootNode:release()	
			self.rootNode = nil
		end
	end			
	local aniArray = CCArray:create()	
	aniArray:addObject(action)
	aniArray:addObject(fadeOut)
	aniArray:addObject(CCCallFunc:create(releaseCall))		
	self.awardItemBox:runAction(CCSequence:create(aniArray))

end

function SystemTipsWithItem:initNode(refId,count)
	require"object.bag.BagDef"
	self.awardItemBox = createSpriteWithFrameName(RES("login_squares_itemBg.png"))
	VisibleRect:relativePosition(self.awardItemBox,self.background,LAYOUT_RIGHT_INSIDE,ccp(-250,-100))
	self.rootNode:addChild(self.awardItemBox)
	
	local itemBox = G_createItemBoxByRefId(refId,true,nil,-1)
	self.awardItemBox:addChild(itemBox)
	VisibleRect:relativePosition(itemBox,self.awardItemBox,LAYOUT_CENTER)	
end	

function SystemTipsWithItem:setTipsEffect(duration)
	local delay = CCDelayTime:create(duration)	
	local fadeOut = CCFadeOut:create(0.1)		
	local function callback()
		self:moveItemToHead(self.refId)
	end
	local callbackAction = CCCallFunc:create(callback)
	local aniArray = CCArray:create()	
	aniArray:addObject(delay)
	aniArray:addObject(fadeOut)
	aniArray:addObject(callbackAction)
	self.rootNode:runAction(CCSequence:create(aniArray))	
end


function SystemTipsWithItem:getRootNode()
	return self.rootNode
end	

function SystemTipsWithItem:__delete()
	if self.rootNode then
		self.rootNode:release()	
		self.rootNode = nil
	end
	
	if self.bindId then
		GlobalEventSystem:UnBind(self.bindId)
		self.bindId = nil
	end
end