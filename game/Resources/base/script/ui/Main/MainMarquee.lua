--跑马灯界面
require("common.baseclass")
require("object.tips.MarqueeMsgObject")
MainMarquee = MainMarquee or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function MainMarquee:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()	
	self.canAction = true	
	self.marqueeObject = MarqueeMsgObject.New()		
end	

function MainMarquee:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
	
	if self.marqueeObject then
		self.marqueeObject:DeleteMe()
		self.marqueeObject = nil	
	end
end

function MainMarquee:create(msg,fontSize,fontColor,length,bgImage,bShowBg)
	if not msg then
		return
	else
		self.marqueeObject:insertMarqueeMessage(msg)
	end
	if not length then
		self.length = 600
	else
		self:setMarqueeLength(length)
	end
	if not fontSize then
		self.fontSize = 20
	else
		self:setFontSize(fontSize)
	end
	if not fontColor then
		self.fontColor = Config.FontColor["ColorYellow1"]	
	else
		self:setFontColor(fontColor)
	end
	self:initBG(bgImage,bShowBg)
end	

function MainMarquee:insertMarqueeMessage(msg)
	if not msg then
		return
	end
	msg = string.gsub(msg, "\n", "")	
	if self.marqueeObject then
		self.marqueeObject:insertMarqueeMessage(msg)
	end
end

function MainMarquee:setFontSize(fontSize)
	self.fontSize = fontSize
end

function MainMarquee:setFontColor(fontColor)
	self.fontColor = fontColor
end

function MainMarquee:setMarqueeLength(length)
	self.length = length
end

function MainMarquee:initBG(bgImage,bShowBg)
	--BG
	if bShowBg == false then
		self.BGSprite = CCSprite:create()
		self.BGSprite:setContentSize(CCSizeMake(self.length,26))
	elseif bShowBg == true or bShowBg == nil then
		if not bgImage then
			self.BGSprite = createScale9SpriteWithFrameNameAndSize(RES("main_messagebg.png"),CCSizeMake(self.length,26))
		else
			self.BGSprite = createScale9SpriteWithFrameNameAndSize(RES(bgImage),CCSizeMake(self.length,26))
		end
	end
	
	local viewSize = self.BGSprite:getContentSize()	
	self.rootNode:addChild(self.BGSprite)		
	--container
	local container = CCNode:create()
	container:setContentSize(CCSizeMake(viewSize.width-60,viewSize.height))
	--ScrollView
	self.scrollView = createScrollViewWithSize(CCSizeMake(viewSize.width-60,viewSize.height))
	self.scrollView:setDirection(kSFScrollViewDirectionHorizontal)	
	self.scrollView:setContainer(container)		
	self.BGSprite:addChild(self.scrollView)	
	--位置设置	
	VisibleRect:relativePosition(self.BGSprite, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -230))
	VisibleRect:relativePosition(self.scrollView, self.BGSprite, LAYOUT_CENTER,ccp(30,0))	
	
end

function MainMarquee:show(msg,fontSize,fontColor,length,bgImage,bShowBg)
	self:create(msg,fontSize,fontColor,length,bgImage,bShowBg)
	self:MoveAction()
end

function MainMarquee:getRootNode()
	return self.rootNode
end

function MainMarquee:MoveAction()
	self.isMove = true
	if self.marqueeObject:IsMarqueeQueenEmpty() then
		return
	end	
	local message = self.marqueeObject:getFirstMarqueeMessage()	
	self.marqueeObject:minusMarqueeCount()			
	local msg = string.wrapRich(message, self.fontColor,self.fontSize)	
	local viewSize = self.BGSprite:getContentSize()	
	local label = createRichLabel(CCSizeMake(0,0))
	label:appendFormatText(msg)			
	label:setTouchEnabled(false)		
	self.scrollView:addChild(label)
	VisibleRect:relativePosition(label, self.scrollView, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(-60,0))	
	
	local firstMoveWidth = label:getContentSize().width + self.scrollView:getViewSize().width/2
	local lastMoveWidth = self.scrollView:getViewSize().width/2
	local deltaTimeFont = math.ceil(firstMoveWidth / 8)*0.1
	local deltaTimeLast = math.ceil(lastMoveWidth / 8)*0.1
	local firstMove = CCMoveBy:create(deltaTimeFont,ccp(-firstMoveWidth,0))
	local lastMove = CCMoveBy:create(deltaTimeLast,ccp(-lastMoveWidth,0))
	local firstCallBack = function()
		self:firstCheck()
	end
	local firstFunc = CCCallFunc:create(firstCallBack) 	
	local lastCallBack = function()
		label:removeFromParentAndCleanup(true)
		self:lastCheck()
	end
	local lastFunc = CCCallFunc:create(lastCallBack) 	
	
	local arrayAction = CCArray:create()
	arrayAction:addObject(firstMove)
	arrayAction:addObject(firstFunc)	
	arrayAction:addObject(lastMove)
	arrayAction:addObject(lastFunc)
		
	local seqAction = CCSequence:create(arrayAction)
	label:runAction(seqAction)
	
end

function MainMarquee:firstCheck()
	if self.marqueeObject:isMarqueeCountZero() then
		self.isMove = false
		return
	else
		self:MoveAction()
	end	
end

function MainMarquee:lastCheck()
	if self.isMove == true then
		return
	else
		if self.marqueeObject:isMarqueeCountZero() then
			self.canAction = true	
			GlobalEventSystem:Fire(GameEvent.EventCloseMarquee)
		else
			self:MoveAction()
		end
	end
end

