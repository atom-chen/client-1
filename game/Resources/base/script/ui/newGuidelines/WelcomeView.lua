WelcomeView = WelcomeView or BaseClass()


function WelcomeView:create()
	return WelcomeView.New()
end

function WelcomeView:__init()
	self.viewName = "WelcomeView"	
	self.bOpenView = false
	self.schedulerId = -1
	
	local function ccTouchHandler(eventType, x,y)
		return 1
	end
	
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()	
	
	self:showView()
end

function WelcomeView:__delete()
	
end

function WelcomeView:getRootNode()
	return self.rootNode
end

function WelcomeView:onEnter()

end	

function WelcomeView:hideNewGuidelinesView()
	UIManager.Instance:hideUI(self.viewName)
end

function WelcomeView:showView()
	--@文军 使用计时器延时1秒，解决I9300显示该界面时无法创建WelcomeBg.pvr图片
	if self.schedulerId ~= -1 then
		return
	end
		
	if self.hideFunction == nil then
		self.hideFunction = function ()		
			self:deleteScheduler()
			self:createBackground()
			self:createButton()
		end
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.hideFunction, 1, false)
	self.bRemove = false	
end

function WelcomeView:deleteScheduler()
	if self.schedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = -1
	end	
end

function WelcomeView:createBackground()
	self.viewBg = CCSprite:create("ui/ui_img/activity/WelcomeBg.pvr")
	if not self.viewBg then
		self:hideNewGuidelinesView()
		return
	end
	self.rootNode:addChild(self.viewBg)
	VisibleRect:relativePosition(self.viewBg,self.rootNode,LAYOUT_CENTER,ccp(-100,46))
end

function WelcomeView:createButton()
	if not self.viewBg then
		return
	end
	self.welcomeBtn = createButtonWithFramename(RES("btn_normal1.png"))
	self.rootNode:addChild(self.welcomeBtn)
	VisibleRect:relativePosition(self.welcomeBtn,self.viewBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, CCPointMake(-30,120))		
	--按钮文字
	local btnWord = createSpriteWithFrameName(RES("word_button_immediatelyEnter.png"))				
	self.welcomeBtn:setTitleString(btnWord)				
	--按键监控
	local welcomeBtnFunction = function ()
		local newGuidelinesMgr = GameWorld.Instance:getNewGuidelinesMgr()
		newGuidelinesMgr:setIsCreateNewRole(false)
		GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesFirstQuest()
		self:hideNewGuidelinesView()
	end
	self.welcomeBtn:addTargetWithActionForControlEvents(welcomeBtnFunction,CCControlEventTouchDown)		
end