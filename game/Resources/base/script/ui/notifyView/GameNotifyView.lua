require("ui.UIManager")
require("common.BaseUI")

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

NotifyView = NotifyView or BaseClass(BaseUI)

function NotifyView:__init()
	self.viewName = "NotifyView"
	--self:init(CCSizeMake(835, 500))		
	self.titleList = {}
	self.contentList = {}	
	--self.haveRead = {}	
	self:initBg()
	self:createScrollView()	
	self:createTabView()	
end	

function NotifyView:__delete()
	
end

function NotifyView:create()
	return NotifyView.New()
end

function NotifyView:onEnter()
	
end

function NotifyView:initBg()
	local titleNode = createSpriteWithFrameName(RES("gameAnoucement.png"))
	self:createVipFrame(CCSizeMake(946, 579), titleNode)
	self:createVipFrameCloseBtn()
		
	local rightsecondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(813, 479))
	self:addChild(rightsecondBg)
	VisibleRect:relativePosition(rightsecondBg, self:getContentNode(), LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(28,-6))
	
	local leftSecondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(180, 465))
	self:addChild(leftSecondBg)
	VisibleRect:relativePosition(leftSecondBg, rightsecondBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(8, 0))	
	
	self.scrollViewBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(612, 465))
	self:addChild(self.scrollViewBg)
	VisibleRect:relativePosition(self.scrollViewBg, self:getContentNode(), LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-35, -43))
	
	self.titleBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"), CCSizeMake(612, 29))	
	self:addChild(self.titleBg)
	VisibleRect:relativePosition(self.titleBg, rightsecondBg, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-8, -8))
end

function NotifyView:createScrollView()
	local bgSize = self.scrollViewBg:getContentSize()
	self.scrollView = createScrollViewWithSize(CCSizeMake(bgSize.width, bgSize.height-50))
	self.scrollView:setDirection(2)
	self.scrollViewBg:addChild(self.scrollView)	
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(bgSize.width, bgSize.height-20))
	self.scrollView:setContainer(node)
	VisibleRect:relativePosition(self.scrollView, self.scrollViewBg, LAYOUT_CENTER, ccp(0, -10))
end		

function NotifyView:createTabView()
	local notifyMgr = LoginWorld.Instance:getNotifyManager()
	self.notifyList = notifyMgr:getSortByStartTimeNotifyList()	
	if table.isEmpty(self.notifyList) then
		return
	end		
	
	local btnArray = CCArray:create()
	
	local createBtn = function (key, notify)
		local button = createButtonWithFramename(RES("rank_nomal_btn.png"), RES("rank_select_btn.png"))
		local text = createLabelWithStringFontSizeColorAndDimension(notify:getNotifyName(), "Arial", FSIZE("Size4"), FCOLOR("ColorWhite3"))
		--[[local flag = createSpriteWithFrameName(RES("achi_new.png"))
		button:addChild(flag)
		button:setZoomOnTouchDown(false)
		VisibleRect:relativePosition(flag, button, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)--]]
		--self.haveRead[key] = flag
		button:setTitleString(text)					
		btnArray:addObject(button)
		local onTabPress = function()			
			self:showTitleAndContent(key, notify)
		end				
		self:createTitle(key, notify)
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchUpInside)
	end				
	
	for key,notify in pairs(self.notifyList) do
		if string.isLegal(notify:getNotifyName()) and string.isLegal(notify:getNotifyTitle()) and string.isLegal(notify:getNotifyContent()) then				
			createBtn(key, notify)								
		end				
	end				
	self.tagView = createTabView(btnArray,10*g_scale,tab_vertical)
	
	--设定最上面的为默认选中	
	self.tagView:setSelIndex(btnArray:count() - 1)
	if self.notifyList[btnArray:count()] then
		self:showTitleAndContent(btnArray:count(), self.notifyList[btnArray:count()])
	end		
	self:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(41, -46))		
end

function NotifyView:createTitle(key, notify)
	if not self.titleList[key] then
		self.titleList[key] = createLabelWithStringFontSizeColorAndDimension(notify:getNotifyTitle(), "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))
		self:addChild(self.titleList[key])
		VisibleRect:relativePosition(self.titleList[key], self.titleBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
		self.titleList[key]:setVisible(false)
	end		
end

function NotifyView:createContent(key, notify)
	if not self.contentList[key] and notify then
		self.contentList[key] = createLabelWithStringFontSizeColorAndDimension(notify:getNotifyContent(), "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"), CCSizeMake(570, 0))
		self.scrollView:addChild(self.contentList[key])		
		self.contentList[key]:setVisible(false)	
					
		VisibleRect:relativePosition(self.contentList[key], self.scrollView:getContainer(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(15, 0))	
	end
end

function NotifyView:showTitleAndContent(key, notify)
	--[[local a = self.haveRead[key]
	if self.haveRead[key] then
		self.haveRead[key]:removeFromParentAndCleanup(true)
		self.haveRead[key] = nil
	end	--]]
	
	self:createContent(key, notify)
	local viewsize = self.scrollView:getViewSize()
	if not self.contentList[key] then
		return
	end
	local labelSize = self.contentList[key]:getContentSize()		
	if viewsize.height<labelSize.height then
		self.scrollView:setContentSize(CCSizeMake(viewsize.width, labelSize.height))
		local offset = self.scrollView:minContainerOffset()
		self.scrollView:setContentOffset(offset)
	else		
		self.scrollView:setContentSize(viewsize)
		local offset = self.scrollView:minContainerOffset()
		self.scrollView:setContentOffset(offset)
	end	
	VisibleRect:relativePosition(self.contentList[key], self.scrollView:getContainer(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(10, 0))
			
	for key1,title in pairs(self.titleList) do
		if key1 ~= key then
			title:setVisible(false)
			if self.contentList[key1] then
				self.contentList[key1]:setVisible(false)
			end				
		else
			title:setVisible(true)
			if self.contentList[key1] then
				self.contentList[key1]:setVisible(true)
			end	
		end
	end
end

function NotifyView:onCloseBtnClick()
	self:DeleteMe()
end

function NotifyView:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then	
		if self.isSwallowAllTouch then
			return 1
		else
			local parent = self.rootNode:getParent()
			local point = parent:convertToNodeSpace(ccp(x,y))
			local rect = self.rootNode:boundingBox()
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

function NotifyView:setSwallowAllTouch(bSwall)
	self.isSwallowAllTouch = bSwall
end