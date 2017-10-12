--Vip抽奖界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")

VipLuckDraw = VipLuckDraw or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function VipLuckDraw:__init()
	self.viewName = "VipLuckDraw"
	self.viewSize = CCSizeMake(960,640)
	self.rootNode:setContentSize(self.viewSize)
	self:createCloseBtn(ccp(-55,-190))
	self.itemBgList = {}	
	self.itemNumLb = {}
	self.itemView = {}
	self.allReward = {}
	self.relativePos = {	--“37”为按钮半径
		[1] = {x = 0-2,y = 120-1.1,angel = 0,arrowX= 0,arrowY = 40},
		[2] = {x = (120-1.8)*math.cos(math.rad(45)) ,y = (120-2.2)*math.cos(math.rad(45)),angel = 45,arrowX=40*math.cos(math.rad(45)) ,arrowY = 40*math.cos(math.rad(45))},
		[3] = {x = 120-0.5,y = 0-2.5,angel = 90,arrowX= 40,arrowY = 0},
		[4] = {x = (120-1.5)*math.cos(math.rad(45)),y = -(120+2.2)*math.cos(math.rad(45)),angel = 135,arrowX= 40*math.cos(math.rad(45)),arrowY = -40*math.cos(math.rad(45))},
		[5] = {x = 0-2,y = -120-4,angel = 180,arrowX= 0,arrowY = -40},
		[6] = {x = -(120+3.5)*math.cos(math.rad(45)),y = -(120+2.2)*math.cos(math.rad(45)),angel = 225,arrowX= -40*math.cos(math.rad(45)),arrowY = -40*math.cos(math.rad(45))},
		[7] = {x = -120-3,y = 0-3,angel = 270,arrowX= -40,arrowY = 0},
		[8] = {x = -(120+4)*math.cos(math.rad(45)),y = (120-3)*math.cos(math.rad(45)),angel = 315,arrowX= -40*math.cos(math.rad(45)),arrowY = 40*math.cos(math.rad(45))},
	}	
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()
	self.itemPos = {}	
	self.lableInfo = {	--右侧说明信息
		[1] = {num = 8 ,fontWords = Config.Words[13304],lastWords = Config.Words[13305],
		numColor = Config.FontColor["ColorWhite2"],numSize = FSIZE("Size3"),
		stringColor = Config.FontColor["ColorWhite2"],stringSize = FSIZE("Size3")},
		[2] = {num = vipLuckMgr:getBuyVipTipsCountByIdentityId(1),fontWords = Config.Words[13306],lastWords = Config.Words[13309],
		numColor = Config.FontColor["ColorWhite2"],numSize = FSIZE("Size3"),
		stringColor = Config.FontColor["ColorWhite2"],stringSize = FSIZE("Size3")},
		--[[[3] = {num = vipLuckMgr:getBuyVipTipsCountByIdentityId(2),fontWords = Config.Words[13307],lastWords = Config.Words[13309],
		numColor = Config.FontColor["ColorRed2"],numSize = FSIZE("Size1"),
		stringColor = Config.FontColor["ColorYellow5"],stringSize = FSIZE("Size1")},--]]
		[3] = {num = vipLuckMgr:getBuyVipTipsCountByIdentityId(3),fontWords = Config.Words[13308],lastWords = Config.Words[13309],
		numColor = Config.FontColor["ColorWhite2"],numSize = FSIZE("Size3"),
		stringColor = Config.FontColor["ColorWhite2"],stringSize = FSIZE("Size3")},
	}
	self.ifShowMarquee = false		
	self:initStaticView()
	self:refreshItemIcon()	
	self:setBoardLabel()
	
end


function VipLuckDraw:onEnter()
	local tex = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/activity/giftGirl3.pvr")
	if self.bg then	
		self.bg:setTexture(tex)
		local pixelWidth = tex:getContentSizeInPixels().width
		local pixelHeight = tex:getContentSizeInPixels().height
		local texRect = CCRectMake(0,0,pixelWidth,pixelHeight)
		self.bg:setTextureRect(texRect)
	end
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	local itemList = vipLuckMgr:getItemList()
	if itemList and self.itemList  then
		local refreshFlag = self:compareList(itemList,self.itemList)
		if refreshFlag == false then
			self:resetReward()
		end
	end		
	self:setBtnAble()
	self:refreshLabelNum()	
end

function VipLuckDraw:onExit()
	local tex = self.bg:getTexture()
	if tex then
		self.bg:setTexture(nil)
		CCTextureCache:sharedTextureCache():removeTexture(tex)
		--CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()		--打log查看是否删除
	end			
	if self.rewardNode then
		self.rewardNode:removeFromParentAndCleanup(true)
		self.rewardNode = nil
	end		
	self:closeBottomMarquee()
	self:clearItemView()
	
	local tipsMgr = LoginWorld.Instance:getTipsManager()  
	tipsMgr:setTipsShowFlag(true)
end

function VipLuckDraw:clearItemView()
	local itemViewNode 
	for key,v in pairs(self.itemView) do	
		if self.itemView[i] then
			itemViewNode = self.itemView[key]:getRootNode()
			if itemViewNode then
				itemViewNode:removeFromParentAndCleanup(true)
			end				
			self.itemView[i]:DeleteMe()
		end
	end
	self.itemView = {}
	if table.size(self.allReward) > 0 then
		for i,v in pairs(self.allReward) do
			v:DeleteMe()
		end
	end
	self.allReward = {}
end

function VipLuckDraw:__delete()
	
end

function VipLuckDraw:create()
	return VipLuckDraw.New()
end

function VipLuckDraw:compareList(listA,listB)
	for i,v in ipairs(listA) do
		if v ~= listB[i] then
			return false
		end
	end
	return true
end

function VipLuckDraw:resetReward()
	self.curPosKey = 1
	self.selBox:setVisible(false)
	VisibleRect:relativePosition(self.selBox,self.itemBgList[1],LAYOUT_CENTER)
	self.arrow:setRotation(0)
	VisibleRect:relativePosition(self.arrow,self.drawBtn,LAYOUT_CENTER,ccp(self.relativePos[1].arrowX,self.relativePos[1].arrowY))
	self.drawBtn:setEnable(true)	
	self:removeOldIcon()
	self:refreshItemIcon()	
	self:clearRewardNode()
	self:closeBottomMarquee()
end
function VipLuckDraw:clearRewardNode()
	if self.reward then	
		self.reward:removeFromParentAndCleanup(true)					
		self.reward = nil
	end
	if self.rewardNode then
		self.rewardNode:removeFromParentAndCleanup(true)
		self.rewardNode = nil
	end
end
function VipLuckDraw:initStaticView()
	self.blockNode = CCLayer:create()
	self.blockNode:setContentSize(visibleSize)
	self.blockNode:setTouchEnabled(true)
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.blockNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rootNode:addChild(self.blockNode,999)	
	VisibleRect:relativePosition(self.blockNode,self.rootNode,LAYOUT_CENTER)
	self.blockNode:setVisible(false)
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager() 
	local tipsMgr = LoginWorld.Instance:getTipsManager() 
	 	
	self.backShadow = CCLayerColor:create(ccc4(0,0,0,200))
	self.backShadow:setTouchEnabled(true)	

	self.viewTopBg = createScale9SpriteWithFrameName(RES("instanceAcheieveBg.png"))
	self.viewTopBg:setScaleX(4)
	self.rootNode:addChild(self.viewTopBg)
	VisibleRect:relativePosition(self.viewTopBg, self.rootNode, LAYOUT_CENTER, ccp(200,30))	
	self.viewBottomBg = createScale9SpriteWithFrameName(RES("instanceAcheieveBg.png"))
	self.viewBottomBg:setScaleY(-1)
	self.viewBottomBg:setScaleX(4)
	self.rootNode:addChild(self.viewBottomBg)
	VisibleRect:relativePosition(self.viewBottomBg, self.rootNode, LAYOUT_CENTER, ccp(200,-140))
	
	self.bg = CCSprite:create()
	self.backShadow:setContentSize(visibleSize)						
	self.rootNode:addChild(self.backShadow,-1)
	VisibleRect:relativePosition(self.backShadow,self.rootNode,LAYOUT_CENTER)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg,self.rootNode,LAYOUT_CENTER,ccp(-180,0))
	--标题
	self.viewTopTitle = createScale9SpriteWithFrameName(RES("activity_vipLuckTitle.png"))
	self.rootNode:addChild(self.viewTopTitle)
	VisibleRect:relativePosition(self.viewTopTitle, self.rootNode, LAYOUT_CENTER,ccp(200,125))		
	--抽奖按钮
	self.drawBtn = createButtonWithFramename(RES("activity_vipLuckStartBtn.png"))	
	self.rootNode:addChild(self.drawBtn,15)
	VisibleRect:relativePosition(self.drawBtn,self.bg,LAYOUT_CENTER,ccp(-80+180,-50-2))		
	--抽奖按钮功能
	local luckDrawFunc = function()	
		local curCount = vipLuckMgr:getCurrentCount()
		if curCount and curCount > 0 then
			tipsMgr:setTipsShowFlag(false)
			self.blockNode:setVisible(true)
			vipLuckMgr:requestLuckDraw(0)			
		else
			--抽奖次数不足
			self:showBuyVipView()			
		end
	end
	self.drawBtn:addTargetWithActionForControlEvents(luckDrawFunc,CCControlEventTouchDown)	
	--选中框
	self.selBox = createScale9SpriteWithFrameNameAndSize(RES("activity_vipLuckCilckDown.png"),CCSizeMake(99,99))	
	--奖品图标底框	
	for i = 1,8 do
		self.itemBgList[i] = createButtonWithFramename(RES("bagBatch_itemBg.png"))
		--self.itemBgList[i]:setContentSize(CCSizeMake(60,60))		
		self.itemNumLb[i] = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"),FCOLOR("ColorGreen1"))		
		self.rootNode:addChild(self.itemBgList[i])
		self.rootNode:addChild(self.itemNumLb[i])
		VisibleRect:relativePosition(self.itemBgList[i],self.drawBtn,LAYOUT_CENTER,ccp(self.relativePos[i].x,self.relativePos[i].y))
		VisibleRect:relativePosition(self.itemNumLb[i],self.itemBgList[i],LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-5,8))	
		self:setItemPosition(i)		
	end
	
	
	--旋转箭头
	self.arrow = createScale9SpriteWithFrameName(RES("activity_vipLuckPointer.png"))		
	G_setScale(self.arrow)	
	self.arrow:setAnchorPoint(ccp(0.5,-0.1))
	self.rootNode:addChild(self.selBox)
	self.rootNode:addChild(self.arrow,10)
	VisibleRect:relativePosition(self.selBox,self.itemBgList[1],LAYOUT_CENTER)
	VisibleRect:relativePosition(self.arrow,self.drawBtn,LAYOUT_CENTER,ccp(self.relativePos[1].arrowX,self.relativePos[1].arrowY))
	self.selBox:setVisible(false)
	--右边抽奖说明	
	self.boardTopLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13303],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self.rootNode:addChild(self.boardTopLb)
	VisibleRect:relativePosition(self.boardTopLb,self.bg,LAYOUT_CENTER,ccp(152+180, 7))		
	--VIP抽取全部按钮
	self.getAllBtn = createButtonWithFramename(RES("btn_1_select.png"))
	local getAllBtnWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[13301],"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
	self.getAllBtn:setTitleString(getAllBtnWord)
	self.rootNode:addChild(self.getAllBtn)
	VisibleRect:relativePosition(self.getAllBtn,self.boardTopLb,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(10,-145))		
	local getAllFunc = function()	
			
		local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
		local identityId = vipLuckMgr:getIdentityId()
		if identityId == 0 then
			local btns =
		{		
			{text = Config.Words[13317],	id = 0},
			{text = Config.Words[13302],	id = 1},	
		}										
		local buyVipFunc = function(arg,text,id)
			if id == 1 then
				--购买Vip
				local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
				vipLuckMgr:openVipView()
			end
		end		
		local msg = showMsgBox(Config.Words[13319])
		msg:setBtns(btns)
		msg:setNotify(buyVipFunc)									
		else
			local curCount = vipLuckMgr:getCurrentCount()
			if curCount and curCount >= 8 then		
				vipLuckMgr:requestLuckDraw(1)	
				self.getAllBtn:setEnable(false)
			else
				UIManager.Instance:showSystemTips(Config.Words[13318])		
			end
		end
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"VipLuckDraw")	
		
	end
	self.getAllBtn:addTargetWithActionForControlEvents(getAllFunc,CCControlEventTouchDown)	
	--购买Vip按钮
	local vipBtn = createButtonWithFramename(RES("btn_1_select.png"))
	local vipBtnWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[13302],"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
	vipBtn:setTitleString(vipBtnWord)
	self.rootNode:addChild(vipBtn)
	VisibleRect:relativePosition(vipBtn,self.getAllBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))	
	local vipFunc = function()	
		--购买Vip功能
		local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
		vipLuckMgr:openVipView()
	end
	vipBtn:addTargetWithActionForControlEvents(vipFunc,CCControlEventTouchDown)	
end

function VipLuckDraw:setItemPosition(key)
	local pos = {}
	pos.x,pos.y = self.itemBgList[key]:getPosition()
--	print("key = "..key.." X = "..pos.x.." Y = "..pos.y)
	self.itemPos[key] = pos	
end

function VipLuckDraw:setBoardLabel()
	--抽奖说明的文字标签
	local viewSize = CCSizeMake(345*g_scale,135*g_scale)	
	self.container = CCLayer:create()	
	self.container:setContentSize(CCSizeMake(265*g_scale,180*g_scale))
	for key,value in ipairs(self.lableInfo) do
		local richNum = string.wrapRich(value.num,value.numColor,value.numSize)
		local richWords = value.fontWords..richNum..value.lastWords
		richWords = string.wrapRich(richWords,value.stringColor,value.stringSize)
		local richLb = createRichLabel(CCSizeMake(viewSize.width-10,0))
		richLb:appendFormatText(richWords)
		self.container:addChild(richLb)	
		VisibleRect:relativePosition(richLb,self.container,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(5+(key%2-1)*(-5),-(key-1)*value.stringSize*2.2-10))		
	end							
	self.rootNode:addChild(self.container)
	VisibleRect:relativePosition(self.container,self.boardTopLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
	--抽奖次数的文字标签
	self.vipLvLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13310],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.nextCountLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13311],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.curCountLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[13312],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.vipLvName = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self.nextCountNum = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self.curCountNum = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self.rootNode:addChild(self.vipLvLb)
	self.rootNode:addChild(self.nextCountLb)
	self.rootNode:addChild(self.curCountLb)
	self.rootNode:addChild(self.vipLvName)
	self.rootNode:addChild(self.nextCountNum)
	self.rootNode:addChild(self.curCountNum)
	VisibleRect:relativePosition(self.vipLvLb,self.bg,LAYOUT_CENTER,ccp(130+150,90-2))	
	VisibleRect:relativePosition(self.nextCountLb,self.vipLvLb,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(10,0))	
	VisibleRect:relativePosition(self.curCountLb,self.nextCountLb,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(10,0))	
	VisibleRect:relativePosition(self.vipLvName,self.vipLvLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))	
	VisibleRect:relativePosition(self.nextCountNum,self.nextCountLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))	
	VisibleRect:relativePosition(self.curCountNum,self.curCountLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))		
end
--刷新右侧vip信息和抽奖次数信息
function VipLuckDraw:refreshLabelNum()	
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	local identityId = vipLuckMgr:getIdentityId()
	local identityName,color = vipLuckMgr:getIdentityNameAndColorById(identityId)
	if identityName and color then
		if self.vipLvName and self.vipLvName.setString and self.vipLvName.setColor then
			self.vipLvName:setString(identityName)	
			self.vipLvName:setColor(color)
			VisibleRect:relativePosition(self.vipLvName,self.vipLvLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))		
		end			
	end
	local nextCount = vipLuckMgr:getNextCount()
	if nextCount then
		if self.nextCountNum and self.nextCountNum.setString then
			self.nextCountNum:setString(nextCount)
			VisibleRect:relativePosition(self.nextCountNum,self.nextCountLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		end
	end
	local curCount = vipLuckMgr:getCurrentCount()
	if curCount then
		if self.curCountNum and self.curCountNum.setString then
			self.curCountNum:setString(curCount)
			VisibleRect:relativePosition(self.curCountNum,self.curCountLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		end
	end
end

function VipLuckDraw:removeOldIcon()
	for i = 1,8 do
		self.itemBgList[i]:removeAllChildrenWithCleanup(true)
		self.itemNumLb[i]:setString("")
		self.itemNumLb[i]:setVisible(true)		
		if self.itemView[i] and itemViewNode then
			local itemViewNode = self.itemView[i]:getRootNode()
			itemViewNode:removeFromParentAndCleanup(true)
			self.itemView[i]:DeleteMe()
		end
	end		
end	

--往格子加道具图标
function VipLuckDraw:refreshItemIcon()
	self:clearItemView()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	self.itemList = vipLuckMgr:getItemList()	
	local itemViewNode = nil
	if table.size(self.itemList)>0 then
		for i,v  in ipairs(self.itemList) do
			local itemNum = vipLuckMgr:getItemCountByRefId(v)
			if itemNum then
				self.itemNumLb[i]:setString(itemNum)
			end
			local itemObject = ItemObject.New()
			itemObject:setRefId(v)
			PropertyDictionary:set_bindStatus(itemObject:getPT(),-1)	
			self.itemView[i] = ItemView.New()
			self.itemView[i]:setItem(itemObject)
			self.itemView[i]:showBg(false)
			itemViewNode = self.itemView[i]:getRootNode()
			self.itemBgList[i]:addChild(itemViewNode)
			local showItem = function()	
				G_clickItemEvent(itemObject)
			end
			self.itemBgList[i]:addTargetWithActionForControlEvents(showItem,CCControlEventTouchDown)
			itemViewNode:setTag(i)
			VisibleRect:relativePosition(itemViewNode, self.itemBgList[i], LAYOUT_CENTER,ccp(0,4))
			itemObject:DeleteMe()
		end
		self.drawBtn:setEnable(true)
		self.getAllBtn:setEnable(true)
	end
end

function VipLuckDraw:openBottomMarquee()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	--底部广播走马灯
	if self.ifShowMarquee == false then
		self.marquee = MainMarquee.New()
		local marNode = self.marquee:getRootNode()
		self.rootNode:addChild(marNode,50)	
		VisibleRect:relativePosition(marNode,self.bg,LAYOUT_CENTER,ccp(360, 0))
		marNode:setTag(100)		
		local msg = vipLuckMgr:getMarqueeMsg()		
		self.marquee:show(msg,nil,Config.FontColor["ColorYellow1"],400,nil,false)
		self.ifShowMarquee = true
	elseif self.ifShowMarquee == true then
		local msg = vipLuckMgr:getMarqueeMsg()
		self.marquee:insertMarqueeMessage(msg)
	end
end

function VipLuckDraw:closeBottomMarquee()
	local marNode = self.rootNode:getChildByTag(100)
	if marNode then
		self.rootNode : removeChildByTag(100,true)
		self.marquee:DeleteMe()
		self.ifShowMarquee = false
	end
end

--快速旋转动画
function VipLuckDraw:startFirstAnimation()	
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	self.endKey = vipLuckMgr:getLuckIndex()	
	local curPos_x,curPos_y = self.selBox:getPosition()
	if self.itemPos and self.endKey then
		for i,v in ipairs(self.itemPos) do		
			if v.x == curPos_x and v.y == curPos_y then
				--选中框当前所在框的索引
				self.curPosKey = i		
			end
		end											
		local index = self.curPosKey
		self.callBackIndex = index+1
		if self.callBackIndex>8 then
			self.callBackIndex = 1		
		end			
		local actionArray = CCArray:create()			
		repeat
			index = index + 1 
			if index>8 then
				index = 1		
			end				
			local delay = CCDelayTime:create(0.04)	
			local finishDelayFunc = function()
				self:finishDelayFunc()
				--print(self.firstRound.."\n")
			end
			local delayCallBack = CCCallFunc:create(finishDelayFunc)	
			actionArray:addObject(delayCallBack)		
			actionArray:addObject(delay)
		until index == self.curPosKey
		local function finishFirstCallback()
			if self.firstRound ~= 1 then
				self:startFirstAnimation()
				self.firstRound = self.firstRound -1
			else
				self:startFinalAnimation()
			end
		end			
		local callbackAction = CCCallFunc:create(finishFirstCallback)
		actionArray:addObject(callbackAction)		
		self.selBox:runAction(CCSequence:create(actionArray))
		self.drawBtn:setEnable(false)
	end	
end
--慢速旋转动画
function VipLuckDraw:startFinalAnimation()
	local index = self.curPosKey
	self.callBackIndex = index+1
	if self.callBackIndex>8 then
		self.callBackIndex = 1		
	end		
	local actionArray = CCArray:create()		
	repeat
		index = index + 1 
		if index>8 then
			index = 1		
		end	
		local delay = CCDelayTime:create(0.08)
		local finishDelayFunc = function()
			self:finishDelayFunc()
		end
		local delayCallBack = CCCallFunc:create(finishDelayFunc)					
		actionArray:addObject(delayCallBack)
		actionArray:addObject(delay)			
	until index == self.endKey
	local function finishFinalCallback()	
		self:showVipReward()		
	end
	local callbackAction = CCCallFunc:create(finishFinalCallback)
	actionArray:addObject(callbackAction)		
	self.selBox:runAction(CCSequence:create(actionArray))
end

function VipLuckDraw:finishDelayFunc()
	VisibleRect:relativePosition(self.selBox,self.itemBgList[self.callBackIndex],LAYOUT_CENTER)
	--[[VisibleRect:relativePosition(self.arrow,self.drawBtn,LAYOUT_CENTER,
		ccp(self.relativePos[self.callBackIndex].arrowX,self.relativePos[self.callBackIndex].arrowY))--]]
	local rotateTo = CCRotateTo:create(0,self.relativePos[self.callBackIndex].angel)	
	self.arrow:runAction(rotateTo)
	self.callBackIndex = self.callBackIndex + 1
	if self.callBackIndex>8 then
		self.callBackIndex = 1		
	end	
end

function VipLuckDraw:showBuyVipView()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	local identityId = vipLuckMgr:getIdentityId()
	local btns = {}
	local size = CCSizeMake(500,400)
	if identityId == 3 then
		btns = {
			{text = Config.Words[13317],		id = 1},		
		}
		size = nil
	else
		btns = 
		{
			{text = Config.Words[13317],	id = 1},
			{text = Config.Words[13302],		id = 0},		
		}
	end
	if identityId then
		local tips = vipLuckMgr:getBuyVipTipsByIdentityId(identityId)
				
		local buyVipFunc = function(arg,text,id)
			if identityId ~= 3 and id == 0 then
				--购买Vip
				local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
				vipLuckMgr:openVipView()
			end
		end				
		local msg = showMsgBox(tips)
		msg:setBtns(btns)
		msg:setNotify(buyVipFunc)					
	end		
end

--中奖效果
function VipLuckDraw:showVipReward()
	local function ccTouchHandler(eventType, x,y)	
		self:refreshLabelNum()
		if self.rewardNode then
			self.rewardNode:removeFromParentAndCleanup(true)
			self.rewardNode = nil
		end
		self.selBox:setVisible(false)
		self:removeOldIcon()
		self:refreshItemIcon()			
		
		if self.reward then
			self.reward:removeFromParentAndCleanup(true)
			self.reward = nil
		end
	end
	self.rewardNode = CCLayer:create()
	self.rewardNode:setTouchEnabled(true)
	self.rewardNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
	self.rewardNode:setContentSize(visibleSize)						
	self.rootNode:addChild(self.rewardNode,20)
	VisibleRect:relativePosition(self.rewardNode,self.rootNode,LAYOUT_CENTER)
	self.rewardNode:setVisible(false)		
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	local rewardRefId = vipLuckMgr:getLuckItemRefId()
	local rewardIndex = vipLuckMgr:getLuckIndex()
	self.blockNode:setVisible(false)	
	if rewardRefId and rewardIndex and rewardIndex ~= 100 then	--普通抽奖
		self:showRewardAction(rewardIndex,rewardRefId)
	elseif rewardIndex and rewardIndex == 100 then	--Vip抽取全部
		self:showAllReward()
	end
end

function VipLuckDraw:showAnimation()
	self.firstRound = 2			
	self.selBox:setVisible(true)
	self.stopFlag = true
	self:startFirstAnimation()
end

function VipLuckDraw:showRewardAction(rewardIndex,rewardRefId)
		
	--物品飘字
	local tipsMgr = LoginWorld.Instance:getTipsManager()  
	tipsMgr:setTipsShowFlag(true)
	local tipsList = tipsMgr:getUnShowTipsList()
	if table.size(tipsList)>0 then
		for i,v in pairs(tipsList) do
			UIManager.Instance:showSystemTips(v)	
		end
		tipsMgr:cleanUnShowTipsList()
	end
	--中奖图标移动
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	local oldIcon = self.itemBgList[rewardIndex]:getChildByTag(rewardIndex)
	if oldIcon then
		oldIcon:setVisible(false)
		--[[self.itemNumLb[rewardIndex]:setVisible(false)--]]
	end
	self.reward = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
	local itemType = vipLuckMgr:getItemTypeByRefId(rewardRefId)
	local itemBox
	if itemType == 0 then
		itemBox = G_createUnPropsItemBox(rewardRefId)
	elseif itemType == 1 then
		itemBox = G_createItemBoxByRefId(rewardRefId,true,nil,-1)
	end		
	self.reward:addChild(itemBox)
	VisibleRect:relativePosition(itemBox,self.reward,LAYOUT_CENTER)		
	self.rootNode:addChild(self.reward,30)
	VisibleRect:relativePosition(self.reward,self.itemBgList[rewardIndex],LAYOUT_CENTER)
	--local rewardStr = vipLuckMgr:getItemNameAndCountByRefId(rewardRefId)
	--local rewardLb = createLabelWithStringFontSizeColorAndDimension(rewardStr,"Arial",FSIZE("Size1"),FCOLOR("ColorYellow5"))
	--self.reward:addChild(rewardLb)
	--VisibleRect:relativePosition(rewardLb,self.reward,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
	local actionArray = CCArray:create()	
	local delay = CCDelayTime:create(0.3)
	local moveTo = CCMoveTo:create(0.5,self.rootNode:convertToNodeSpace(ccp(visibleSize.width/2,visibleSize.height/2)))	
	actionArray:addObject(delay)
	local function finishDelayFunc()		--延迟后显示CCLayer达到暗背景效果
		self.rewardNode:setVisible(true)
	end
	local finishDelayFunc = CCCallFunc:create(finishDelayFunc)
	actionArray:addObject(finishDelayFunc)	
	actionArray:addObject(moveTo)	
	local function finishMoveCallback()
		self:rewardFlash()		
	end
	local callbackAction = CCCallFunc:create(finishMoveCallback)
	
	actionArray:addObject(callbackAction)		
	self.reward:runAction(CCSequence:create(actionArray))	
	
end

function VipLuckDraw:showAllReward()
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	self.itemList = vipLuckMgr:getItemList()
	if table.size(self.itemList)>0 then
		for i,v  in ipairs(self.itemList) do
			local oldIcon = self.itemBgList[i]:getChildByTag(i)
			if oldIcon then
				oldIcon:setVisible(false)
			end
			self.itemNumLb[i]:setVisible(false)
			local itemNum = vipLuckMgr:getItemCountByRefId(v)
			local itemObject = ItemObject.New()
			itemObject:setRefId(v)
			self.allReward[i] = ItemView.New()
			self.allReward[i]:setItem(itemObject)			
			self.rewardNode:addChild(self.allReward[i]:getRootNode())
			if i <= 4 then
				local xLayout = 0
				if i > 2 then
					xLayout = (i-2)*65-32
				else
					xLayout = (i-3)*65+32
				end
				VisibleRect:relativePosition(self.allReward[i]:getRootNode(),self.rewardNode,LAYOUT_CENTER,ccp(xLayout,34))	
			else
				local xLayout = 0
				if i > 6 then
					xLayout = (i-6)*65-32
				else
					xLayout = (i-7)*65+32
				end
				VisibleRect:relativePosition(self.allReward[i]:getRootNode(),self.rewardNode,LAYOUT_CENTER,ccp(xLayout,-34))
			end	
		end
		self.rewardNode:setVisible(true)
	end
end

--图标闪光特效
function VipLuckDraw:rewardFlash()
	local sprite = CCSprite:create()
	self.reward:addChild(sprite)	
	VisibleRect:relativePosition(sprite,self.reward,LAYOUT_CENTER)
	local flashAnimate = createAnimate("iconFlash",8,0.125)
	local actionArray = CCArray:create()	
	local function finishFlash()		
		sprite:setVisible(false)
	end
	local callbackAction = CCCallFunc:create(finishFlash)
	actionArray:addObject(flashAnimate)
	actionArray:addObject(callbackAction)	
	sprite:runAction(CCSequence:create(actionArray))
end
function VipLuckDraw:openFailedFunc()
	UIManager.Instance:showSystemTips(Config.Words[13320])
	self:setBtnUnable()
end

function VipLuckDraw:setBtnUnable()
	if self.drawBtn then
		self.drawBtn:setEnable(false)
		UIControl:SpriteSetGray(self.drawBtn)
	end
	if self.getAllBtn then
		self.getAllBtn:setEnable(false)
		UIControl:SpriteSetGray(self.getAllBtn)
	end
end
function VipLuckDraw:setBtnAble()
	if self.drawBtn then
		self.drawBtn:setEnable(true)
		UIControl:SpriteSetColor(self.drawBtn)
	end
	if self.getAllBtn then
		self.getAllBtn:setEnable(true)
		UIControl:SpriteSetColor(self.getAllBtn)
	end
end
------------------------------------------新手引导----------------------------------------
function VipLuckDraw:getRewardTotalBtn()
	return self.getAllBtn
end













