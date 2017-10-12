require("ui.UIManager")
require("common.BaseUI")
require("data.item.unPropsItem")	
require("ui.utils.ItemView")	
SevenLoginAwardView = SevenLoginAwardView or BaseClass(BaseUI)

awardGetStateType = {
	["forbidDraw"] = 0,
	["hadDraw"] = 1,
	["canDraw"] = 2,
	["replacementDraw"] = 3,
}	

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size = CCSizeMake(876, 549)
local g_scale = VisibleRect:SFGetScale()


local mainIconPic = {
	[1] = "firstDayIcon.pvr",
	[2] = "secondDayIcon.pvr",
	[3] = "thirdDayIcon.pvr",
	[4] = "fourthDayIcon.pvr",
	[5] = "fifthDayIcon.pvr",
	[6] = "sixthDayIcon.pvr",
	[7] = "seventhDayIcon.pvr",
}

function SevenLoginAwardView:__init()
	self.viewName = "SevenLoginAwardView"
	self.eachDay = {}
	self.nodes = {}	
	self.itemView = {}
	self:initStaticUI()
end

function SevenLoginAwardView:__delete()
	local itemViewRootNode
	for key,v in pairs(self.itemView) do
		if v then
			itemViewRootNode = v:getRootNode()
			if itemViewRootNode then
				itemViewRootNode:removeFromParentAndCleanup()
			end
			v:DeleteMe()
		end
	end
end

function SevenLoginAwardView:create()
	return SevenLoginAwardView.New()
end

function SevenLoginAwardView:onEnter()

end

function SevenLoginAwardView:onExit()

end

function SevenLoginAwardView:initStaticUI()
	self:initFullScreen()		

	self.bodyBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), self:getContentNode():getContentSize())	
	self:addChild(self.bodyBg)
	VisibleRect:relativePosition(self.bodyBg,self:getContentNode(),LAYOUT_CENTER,ccp(0,0))	
	
	local titleSign = createSpriteWithFrameName(RES("sevenLoginIcon.png"))
	self:setFormImage(titleSign)
	
	local titleName = createSpriteWithFrameName(RES("sevenLoginIcon_word.png"))
	self:setFormTitle(titleName, TitleAlign.Left)
	
	--上部背景
	self.topBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(819*g_scale,278*g_scale))	
	self.bodyBg:addChild(self.topBg)	
	VisibleRect:relativePosition(self.topBg,self.bodyBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-50))
	
	--七天主图标
	for k = 1,7 do		
		local node = self:createMainIcon(k)
		if node then
			self.nodes[k] = node
		end
	end

	local height = self.nodes[1]:getContentSize().height
	local g_cellWidth = self.nodes[1]:getContentSize().width
	local width = g_cellWidth * 7
	local viewSize = CCSizeMake(width, height)
	
	local container = CCNode:create()
	container:setContentSize(viewSize)
	G_layoutContainerNode(container, self.nodes, 7, E_DirectionMode.Horizontal, viewSize, true)	
	
	self.iconScrollView = createScrollViewWithSize(CCSizeMake(810, height))
	self.iconScrollView:setContainer(container)
	self.iconScrollView:setDirection(1)
	local scrollHandler = function(view, eventType, x, y)	
		if (eventType == 4) then  --kScrollViewTouchEnd	
			local isClick = self.iconScrollView:isTouchMoved()
			if isClick == false then		
				local offect = self.iconScrollView:getContentOffset().x		
				local index = math.ceil((x - offect)/ g_cellWidth)
				local awardMgr = GameWorld.Instance:getAwardManager()
				awardMgr:setSelectDay(index)
				--刷新
				local whichDay = awardMgr:getSelectDay()
				self:updateOpenServiceSelect(whichDay)				
				local status = awardMgr:getStatus(index)
				self:updateOpenServiceBtn(status)
				local awardList = awardMgr:getAwardList(whichDay)
				self:updateOpenServiceAward(awardList)
			end
		end
	end
	self.iconScrollView:setHandler(scrollHandler)
	self.topBg:addChild(self.iconScrollView)
	VisibleRect:relativePosition(self.iconScrollView, self.topBg, LAYOUT_CENTER)
	
	--下部标题
	self.awardListTopBg = createScale9SpriteWithFrameName(RES("sevenLoginTipFrame.png"))
	self.awardListTopBg : setContentSize(CCSizeMake(165*g_scale,35*g_scale))
	self.topBg : addChild(self.awardListTopBg)
	VisibleRect:relativePosition(self.awardListTopBg,self.topBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER,ccp(0,-14))
	
	local awardListTopLeftLine = createScale9SpriteWithFrameName(RES("sevenLoginLine.png"))	
	self.awardListTopBg : addChild(awardListTopLeftLine)
	VisibleRect:relativePosition(awardListTopLeftLine,self.awardListTopBg,LAYOUT_LEFT_OUTSIDE + LAYOUT_CENTER)
	
	local awardListTopRightLine = createScale9SpriteWithFrameName(RES("sevenLoginLine.png"))
	awardListTopRightLine:setScaleX(-1)	
	self.awardListTopBg : addChild(awardListTopRightLine)
	VisibleRect:relativePosition(awardListTopRightLine,self.awardListTopBg,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER)		

	self.awardListTopWord = createScale9SpriteWithFrameName(RES("sevenLoginTip.png"))
	self.awardListTopBg : addChild(self.awardListTopWord)
	VisibleRect:relativePosition(self.awardListTopWord,self.awardListTopBg,LAYOUT_CENTER)
end

function SevenLoginAwardView:createMainIcon(whichDay)
	local eachDayNode = CCNode:create()
	eachDayNode:setAnchorPoint(ccp(0.5,0.5))
	eachDayNode:setContentSize(VisibleRect:getScaleSize(CCSizeMake(176, 254)))
	
	self.eachDay[whichDay] = {}
	self.eachDay[whichDay].bg = createScale9SpriteWithFrameName(RES("sevenLoginFrame.png"))
	self.eachDay[whichDay].bg:setAnchorPoint(ccp(0.5,0.5))
	self.eachDay[whichDay].bg:setContentSize(CCSizeMake(168,248))
	eachDayNode:addChild(self.eachDay[whichDay].bg)
	VisibleRect:relativePosition(self.eachDay[whichDay].bg,eachDayNode, LAYOUT_CENTER)
	
	local iconName = mainIconPic[whichDay]
	self.eachDay[whichDay].icon = CCSprite:create("ui/ui_img/activity/"..iconName)
	
	self.eachDay[whichDay].icon:setAnchorPoint(ccp(0.5,0.5))	
	self.eachDay[whichDay].bg:addChild(self.eachDay[whichDay].icon)
	VisibleRect:relativePosition(self.eachDay[whichDay].icon,self.eachDay[whichDay].bg, LAYOUT_CENTER)

	self.eachDay[whichDay].selectFrame = createScale9SpriteWithFrameName(RES("squares_serverSelectedFrame.png"))
	self.eachDay[whichDay].selectFrame:setAnchorPoint(ccp(0.5,0.5))
	self.eachDay[whichDay].selectFrame:setContentSize(CCSizeMake(176,254))	
	self.eachDay[whichDay].selectFrame:setVisible(false)
	eachDayNode:addChild(self.eachDay[whichDay].selectFrame)
	VisibleRect:relativePosition(self.eachDay[whichDay].selectFrame,eachDayNode, LAYOUT_CENTER)
	
	return eachDayNode
end	

--刷新开服时间
function SevenLoginAwardView:updateOpenServiceDate(openServiceDate)
	if self.openServiceDateTip == nil then
		self.openServiceDateTip =  createLabelWithStringFontSizeColorAndDimension(Config.Words[17001]..openServiceDate,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"),CCSizeMake(0,0))
		self.openServiceDateTip:setAnchorPoint(ccp(0,0.5))
		self.bodyBg:addChild(self.openServiceDateTip)
		VisibleRect:relativePosition(self.openServiceDateTip,self.bodyBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,-20))
	else
		self.openServiceDateTip:setString(Config.Words[17001]..openServiceDate)
	end
end

--刷新开服奖励
function SevenLoginAwardView:updateOpenServiceAward(awardList)
	if self.awardScrollView then
		self.awardScrollView:removeFromParentAndCleanup(true)	
	end	
	if type(awardList) ~= "table" then
		return
	end
	local nodes = {}
	for k, v in pairs(awardList) do		
		local node = self:createItem(v)
		if node then
			nodes[k] = node
		end
	end
	
	local height = nodes[1]:getContentSize().height
	local g_cellWidth = nodes[1]:getContentSize().width
	local width = g_cellWidth * table.getn(nodes)
	local viewSize = CCSizeMake(width, height)
	
	local container = CCNode:create()
	container:setContentSize(viewSize)
	G_layoutContainerNode(container, nodes, 0, E_DirectionMode.Horizontal, viewSize, true)	
	
	self.awardScrollView = createScrollViewWithSize(viewSize)
	self.awardScrollView:setContainer(container)
	self.awardScrollView:setDirection(1)	
	self.topBg:addChild(self.awardScrollView)
	VisibleRect:relativePosition(self.awardScrollView, self.topBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-25))		
end

function SevenLoginAwardView:createItem(v)
	local eachAwardNode = CCNode:create()
	eachAwardNode:setContentSize(VisibleRect:getScaleSize(CCSizeMake(130, 150)))
		
	local itemBoxShow = G_createItemShowByItemBox(v.itemRefId,v.number,nil,nil,nil,-1)
	eachAwardNode:addChild(itemBoxShow)
	VisibleRect:relativePosition(itemBoxShow,eachAwardNode, LAYOUT_CENTER)

	return eachAwardNode
end

--刷新开服按钮
function SevenLoginAwardView:updateOpenServiceBtn(state)
	if state == awardGetStateType.forbidDraw or state == awardGetStateType.hadDraw or state == awardGetStateType.canDraw or state == awardGetStateType.replacementDraw then
		if self.btn then
			self.btn:removeFromParentAndCleanup(true)
			self.btn = nil		
		end
		
		if state == awardGetStateType.forbidDraw then
			self.btn = createButtonWithFramename(RES("btn_1_disable.png"))
			self.topBg:addChild(self.btn)
			VisibleRect:relativePosition(self.btn, self.topBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-20, -75))
			local btnText = createSpriteWithFrameName(RES("word_button_getreword.png"))
			self.btn:addChild(btnText)
			VisibleRect:relativePosition(btnText, self.btn, LAYOUT_CENTER)
		elseif state == awardGetStateType.hadDraw then
			self.btn = createSpriteWithFrameName(RES("hadReceivedLable.png"))
			self.btn:setRotation(-30)
			self.topBg:addChild(self.btn)
			VisibleRect:relativePosition(self.btn, self.topBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-20, -55))
		elseif state == awardGetStateType.canDraw then
			local btnFunc =  function ()
				local awardMgr = GameWorld.Instance:getAwardManager()
				local whichDay = awardMgr:getSelectDay()
				local stage = awardMgr:getStage(whichDay)
				awardMgr:requestHadReceive(stage)
				GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"SevenLoginAwardView","activity_manage_2")
			end
			self.btn = createButtonWithFramename(RES("btn_1_select.png"))
			self.btn:addTargetWithActionForControlEvents(btnFunc,CCControlEventTouchDown)
			
			self.topBg:addChild(self.btn)
			VisibleRect:relativePosition(self.btn, self.topBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-20, -75))
			local btnText = createSpriteWithFrameName(RES("word_button_getreword.png"))
			self.btn:addChild(btnText)
			VisibleRect:relativePosition(btnText, self.btn, LAYOUT_CENTER)
		elseif state == awardGetStateType.replacementDraw then
			local btnFunc = function()
				if SFLoginManager:getInstance():getPlatform() == "win32" then
					UIManager.Instance:showSystemTips(Config.Words[17022])
					return
				end
				local shareCallback = function (tag, state)	
					--转换按钮状态
					if state == 1 then
						local awardMgr = GameWorld.Instance:getAwardManager()
						local whichDay = awardMgr:getSelectDay()
						awardMgr:setStatus(whichDay,awardGetStateType.canDraw)
						view:updateOpenServiceBtn(awardGetStateType.canDraw)
					end
					--通知服务端
					local awardMgr = GameWorld.Instance:getAwardManager()
					local whichDay = awardMgr:getSelectDay()
					local stage = awardMgr:getStage(whichDay)
					awardMgr:requestReReceive(stage)
				end				
				SFGameHelper:startPush()
				SFGameHelper:showMenu(Config.Words[17020],Config.Words[17021],"http://www.gzyouai.com/","loadSence_logo.png",shareCallback)	
			end
		
			self.btn = createButtonWithFramename(RES("btn_1_select.png"))
			self.btn:addTargetWithActionForControlEvents(btnFunc,CCControlEventTouchDown)
			self.topBg:addChild(self.btn)
			VisibleRect:relativePosition(self.btn, self.topBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-20, -75))
			local btnText = createLabelWithStringFontSizeColorAndDimension(Config.Words[17003],"Arial",FSIZE("Size6"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
			self.btn:addChild(btnText)
			VisibleRect:relativePosition(btnText, self.btn, LAYOUT_CENTER)
		end
	end
end

--刷新7天主图标
function SevenLoginAwardView:updateOpenServiceIcon(stateList)
	for k,v in pairs(stateList) do
		if self.eachDay[k].icon  then
			if stateList[k] == awardGetStateType.hadDraw then
				UIControl:SpriteSetGray(self.eachDay[k].icon)
			else
				UIControl:SpriteSetColor(self.eachDay[k].icon)
			end
		end
	end
end

--滑动到开服当天
function SevenLoginAwardView:scrollOpenServiceIcon(whichDay)
	if whichDay > 4 then
		local g_cellWidth = self.nodes[1]:getContentSize().width
		local space = 7
		local width = g_cellWidth*7 + space*6 - 810
		self.iconScrollView:setContentOffset(ccp(-width,0), false)
	end
end

--刷新选择
function SevenLoginAwardView:updateOpenServiceSelect(whichDay)
	--选择框
	for k = 1,7 do
		if k == whichDay then
			self.eachDay[k].selectFrame:setVisible(true)
		else
			self.eachDay[k].selectFrame:setVisible(false)
		end
	end
	--选择日
	if self.selectDay == nil then
		self.selectDay = createAtlasNumber(Config.AtlasImg.SevenLoginNumber,whichDay)
		if self.selectDay then
			self.awardListTopWord:addChild(self.selectDay)
			VisibleRect:relativePosition(self.selectDay,self.awardListTopWord,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(25,0))
		end
	else
		self.selectDay:setString(tostring(whichDay))
	end	
end

function SevenLoginAwardView:getOpenServiceBtn()
	if self.btn == nil then
		self.btn = createButtonWithFramename(RES("btn_1_disable.png"))
		self.topBg:addChild(self.btn)
		VisibleRect:relativePosition(self.btn, self.topBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(-20, -75))
	end
	return self.btn
end
