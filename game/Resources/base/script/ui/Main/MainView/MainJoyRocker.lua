require("ui.UIDef")
MainJoyRocker = MainJoyRocker or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function MainJoyRocker:__init()
	self.rootNode = CCLayer:create()	
	self.rootNode:setContentSize(visibleSize)	
	self.scale = VisibleRect:SFGetScale()
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self:showView()
end

function MainJoyRocker:__delete()

end

function MainJoyRocker:getRootNode()
	return self.rootNode
end

function MainJoyRocker:showView()
	local joyRocker = self:createJoyRocker()
	self.rootNode:addChild(joyRocker)
	
end

function MainJoyRocker:createJoyRocker()
	local joyRocker =createJoyRock(50,RES("main_jointedarm2.png"),RES("main_jointedarm1.png"),false)
	joyRocker:setTouchPriority(UIPriority.MainButton)
	joyRocker:setInActiveRadius(10)
	local rockFunction = function (eventType,rocker,dir)
		GameWorld.Instance:getJoyRockerManager():handleJoyRockEvent(eventType,rocker,dir)
	end	
	joyRocker:setDelegateHandler(rockFunction)
	VisibleRect:relativePosition(joyRocker,self.rootNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(80,100))
	return joyRocker
end

function MainJoyRocker:touchHandler(eventType, x, y)
	return 0
end

function MainJoyRocker:setViewHide()
	local deleteMyself = function ()
		self.rootNode:setVisible(false)
	end
	local ccfunc = CCCallFuncN:create(deleteMyself)
	local actionArray = CCArray:create()	
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(-visibleSize.width/3,0))
	actionArray:addObject(moveBy)	
	actionArray:addObject(ccfunc)
	local sequence = CCSequence:create(actionArray)	
	self.rootNode:runAction(sequence)
end

function MainJoyRocker:setViewShow()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(visibleSize.width/3,0))	
	self.rootNode:setVisible(true)
	self.rootNode:runAction(moveBy)	
end