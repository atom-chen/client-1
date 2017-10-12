require("common.BaseUI")
require("object.bag.BagDef")
require("ui.utils.ItemView")

EveryWeekPayAwardView = EveryWeekPayAwardView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local width = 870*g_scale
local height = 540*g_scale


function EveryWeekPayAwardView:__init()
	self.viewName = "EveryWeekPayAwardView"
	self:initFullScreen()
	
	self.everyWeekconsumeMgr = GameWorld.Instance:getEveryWeekConsumeManager()
	self.haveReceiveImageList = {}
	self.itemNodeList = {}
	self.giftButtonList = {}
	self.selectFrameList = {}
	self.giftButtonListSize = 2
	self.selectGiftButton = 1
	self.giftList = {}
	self.itemView = {}
	self.receiveButton = {}
	self.haveReceiveButton = {}
	
	local weekNode = createSpriteWithFrameName(RES("main_activityWeekAward.png"))
	self:setFormImage(weekNode)
	local titleNode = createSpriteWithFrameName(RES("weekly_rebate_spree.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
		
	self:initStaticView()
	self:createGiftButton()	
	self:createBottomText()
end

function EveryWeekPayAwardView:__delete()
	self.haveReceiveImageList = {}
	self.itemNodeList = {}
	self.giftButtonList = {}
	self.giftList = {}
	self.selectFrameList = {}
end

function EveryWeekPayAwardView:create()
	return EveryWeekPayAwardView.New()
end

function EveryWeekPayAwardView:initStaticView()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(831, 490))
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER)
	
	--[[local title = createSpriteWithFrameName(RES(".png"))
	self:addChild(title)	
	VisibleRect:relativePosition(title, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(55, 32))
	
	local titlePicture = createSpriteWithFrameName(RES("main_activityWeekAward.png"))
	self:addChild(titlePicture)	
	VisibleRect:relativePosition(titlePicture, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-54,80))--]]
	--文字底板
	local timeWordBg = createScale9SpriteWithFrameNameAndSize(RES("activityTimeWold.png"), CCSizeMake(831, 60))
	self:addChild(timeWordBg)
	VisibleRect:relativePosition(timeWordBg, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -10))
	--中间红框
	local awardIconBg1 = CCSprite:create("ui/ui_img/activity/dailyconsumption_midBg.pvr")		
	self:addChild(awardIconBg1)
	VisibleRect:relativePosition(awardIconBg1, self:getContentNode(), LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(20, 58))
	local awardIconBg2 = CCSprite:create("ui/ui_img/activity/dailyconsumption_midBg.pvr")
	self:addChild(awardIconBg2)
	awardIconBg2:setScaleX(-1)
	VisibleRect:relativePosition(awardIconBg2, awardIconBg1, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	--字条
	self.wordBar = createScale9SpriteWithFrameNameAndSize(RES("common_wordBg.png"),CCSizeMake(790, 30))
	self:addChild(self.wordBar)
	VisibleRect:relativePosition(self.wordBar, awardIconBg1, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
	--礼包领取
	local line = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(790, 2))
	self:addChild(line)
	VisibleRect:relativePosition(line, awardIconBg1, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, -22))
	
	local frameBox = createScale9SpriteWithFrameNameAndSize(RES("sevenLoginTipFrame.png"), CCSizeMake(128, 35))
	self:addChild(frameBox)
	VisibleRect:relativePosition(frameBox, line, LAYOUT_CENTER)
	
	local word = createSpriteWithFrameName(RES("giftAward.png"))
	self:addChild(word)
	VisibleRect:relativePosition(word, frameBox, LAYOUT_CENTER)
	
	--点击商城按钮
	local comeToMallButton = createButtonWithFramename(RES("btn_1_select.png"))
	local textLabel = createSpriteWithFrameName(RES("enter_show.png"))
	comeToMallButton:setTitleString(textLabel)
	self:addChild(comeToMallButton)
	VisibleRect:relativePosition(comeToMallButton, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(-120, 6))
	--进入商城
	local comeToMallFun = function ()
		GlobalEventSystem:Fire(GameEvent.EventOpenMallView)
		UIManager.Instance:hideUI("EveryWeekPayAwardView")
	end
	comeToMallButton:addTargetWithActionForControlEvents(comeToMallFun, CCControlEventTouchDown)
end	

function EveryWeekPayAwardView:setTextString()
	local time = self.everyWeekconsumeMgr:getWeekStartEndTime()
	local totalPayValue = self.everyWeekconsumeMgr:getCurrentWeekValue()
	self.timeLabel:setString(time)
	self.payLabel:setString(totalPayValue)
	
	VisibleRect:relativePosition(self.yuanbaoText, self.payLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(5, -2))
end

--累计消费，活动时间
function EveryWeekPayAwardView:createBottomText()
	local time = ""
	local totalPayValue = ""	
	
	local timeStaticLabelText = createSpriteWithFrameName(RES("activityTime.png"))
	timeStaticLabelText:setAnchorPoint(ccp(0, 0.5))
	self.timeLabel = createLabelWithStringFontSizeColorAndDimension(time, "Arial", FSIZE("Size3"), FCOLOR("ColorGreen1"))
	self.timeLabel:setAnchorPoint(ccp(0, 0.5))	
	
	local consumeLabel = createSpriteWithFrameName(RES("acculatePayWold.png"))
	self:addChild(consumeLabel)
	consumeLabel:setAnchorPoint(ccp(0, 0.5))
	
	self.payLabel = createLabelWithStringFontSizeColorAndDimension(totalPayValue, "Arial", FSIZE("Size4"), FCOLOR("ColorYellow1"))
	self:addChild(self.payLabel)
	self.payLabel:setAnchorPoint(ccp(0, 0.5))
	
	self.yuanbaoText = createSpriteWithFrameName(RES("yuanbao1.png"))
	self:addChild(self.yuanbaoText)
	self.yuanbaoText:setAnchorPoint(ccp(0, 0.5))
	
	self:addChild(timeStaticLabelText)
	self:addChild(self.timeLabel)	
	
	VisibleRect:relativePosition(consumeLabel, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(20, -30))		
	VisibleRect:relativePosition(self.payLabel, consumeLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(4, 2))
	VisibleRect:relativePosition(self.yuanbaoText, self.payLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(5, -2))
	VisibleRect:relativePosition(timeStaticLabelText, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(300, -30))
	VisibleRect:relativePosition(self.timeLabel, timeStaticLabelText, LAYOUT_RIGHT_OUTSIDE +LAYOUT_CENTER_Y, ccp(10, 2))	
end

--礼包图标
function EveryWeekPayAwardView:createGiftButton()
	local button
	local receiveImage
	local selectFrame	
	local buttonCallBackFun 
	
	for key=1, self.giftButtonListSize do
		button = createButtonWithFramename(RES("weekItem"..key..".png"))
		self.giftButtonList[key] = button
		self:addChild(button)
		--button:setScaleDef(1.6)	
		VisibleRect:relativePosition(button, self:getContentNode(), LAYOUT_CENTER, ccp((key-1)*300-154, 50))
		--已领取
		receiveImage = createSpriteWithFrameName(RES("main_questComplete.png"))
		button:addChild(receiveImage)
		VisibleRect:relativePosition(receiveImage, button, LAYOUT_CENTER)
		self.haveReceiveImageList[key] = receiveImage
		receiveImage:setRotation(-30)
		receiveImage:setVisible(false)
		--选中框
		selectFrame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemSelect.png"), CCSizeMake(150, 130))
		button:addChild(selectFrame)
		self.selectFrameList[key] = selectFrame
		VisibleRect:relativePosition(selectFrame, button, LAYOUT_CENTER)
		if key ~= self.selectGiftButton then
			selectFrame:setVisible(false)
		end
		
		buttonCallBackFun = function ()
			self:buttonCallBackFun(key)
		end
		button:addTargetWithActionForControlEvents(buttonCallBackFun,CCControlEventTouchDown)
	end
	
end

function EveryWeekPayAwardView:buttonCallBackFun(index)
	self.selectGiftButton = index
	for key=1, self.giftButtonListSize do
		if key == self.selectGiftButton then
			self.selectFrameList[key]:setVisible(true)
			if self.itemNodeList[key] then
				self.itemNodeList[key]:setVisible(true)
			end				
		else
			self.selectFrameList[key]:setVisible(false)
			if self.itemNodeList[key] then
				self.itemNodeList[key]:setVisible(false)
			end			
		end
	end
end

function EveryWeekPayAwardView:createItemViewList()
	for key=1, self.giftButtonListSize do
		self.itemNodeList[key] = self:createItemView(key)
		if key ~= self.selectGiftButton then
			if self.itemNodeList[key] then
				self.itemNodeList[key]:setVisible(false)
			end
		end
	end
end	

function EveryWeekPayAwardView:createGiftButtomText()
	--消费多少元宝的文字
	local consumeText
	local condValue, yuanbao	
	for key=1, self.giftButtonListSize do
		local node = CCNode:create()
		node:setContentSize(CCSizeMake(210, 33))
		condValue = self.giftList[tostring(key)].condValue	
		if self:getContentNode():getChildByTag(key+10) then
			self:getContentNode():removeChildByTag(key+10)
		end			
		consumeText = createSpriteWithFrameName(RES("consumeWold.png"))
		condValueLable = createLabelWithStringFontSizeColorAndDimension(condValue, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		yuanbao = createSpriteWithFrameName(RES("yuanbao2.png"))
		node:addChild(consumeText)
		node:addChild(condValueLable)
		node:addChild(yuanbao)
		VisibleRect:relativePosition(consumeText, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
		VisibleRect:relativePosition(condValueLable, consumeText, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
		VisibleRect:relativePosition(yuanbao, condValueLable, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
		if key == 1 then
			VisibleRect:relativePosition(node, self:getContentNode(), LAYOUT_CENTER, ccp((key-1)*210-133, -39))
		else
			VisibleRect:relativePosition(node, self:getContentNode(),LAYOUT_CENTER, ccp((key-1)*212-49, -39))
		end	
		self:addChild(node)		
	end
end

function EveryWeekPayAwardView:createText(reachNum, worth, node)
	local textConsumeLabel = createSpriteWithFrameName(RES("weekAcculateConsumeWord.png"))
	node:addChild(textConsumeLabel)
	textConsumeLabel:setAnchorPoint(ccp(0, 0.5))
	local reachValueLabel = createLabelWithStringFontSizeColorAndDimension(reachNum, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	node:addChild(reachValueLabel)
	local getTextLabel = createSpriteWithFrameName(RES("getValueWold.png"))
	node:addChild(getTextLabel)
	local worthValueLabel = createLabelWithStringFontSizeColorAndDimension(worth.. Config.Words[13737], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	node:addChild(worthValueLabel)
	local backTextLabel = createSpriteWithFrameName(RES("backGiftWold.png"))
	node:addChild(backTextLabel)
	local yuanbao = createSpriteWithFrameName(RES("yuanbao2.png"))
	node:addChild(yuanbao)
		
	VisibleRect:relativePosition(textConsumeLabel, node, LAYOUT_TOP_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(-20, 32))
	VisibleRect:relativePosition(reachValueLabel, textConsumeLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(yuanbao, reachValueLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(getTextLabel, yuanbao, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(worthValueLabel, getTextLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(backTextLabel, worthValueLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
end

function EveryWeekPayAwardView:createItemView(index)
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(800, 340))
	self:addChild(node)
	VisibleRect:relativePosition(node, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(40, 33))
	
	local nodeViewObj = self.giftList[tostring(index)]
	--文字
	local reachNum = nodeViewObj.condValue
	local worth = nodeViewObj.worth
	self:createText(reachNum, worth, node)
	
	
	--[[local textBg = createSpriteWithFrameName(RES("btn_3_disable.png"))
	node:addChild(textBg)
	VisibleRect:relativePosition(textBg, node, LAYOUT_CENTER, ccp(0, 30))
	local textWord = createLabelWithStringFontSizeColorAndDimension(Config.Words[13736], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow3"))
	node:addChild(textWord)
	VisibleRect:relativePosition(textWord, textBg, LAYOUT_CENTER)--]]
	--TODO
	local itemList = nodeViewObj.itemList
	--领取物品品质背景，物品，数量
	local itemRefId, qualityBg	
	local itemIcon, itemNumLabel, bindSprite	
	local key = 0
	for i, item in pairs(itemList) do
		itemRefId = item["refId"]	
		local itemBox = G_createItemShowByItemBox(item.refId,item.number,nil,nil,nil,-1)
		node:addChild(itemBox)
		VisibleRect:relativePosition(itemBox, node, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(key*126-8, 70))	
		key = key + 1
	end
	
	local status = nodeViewObj.status
	self.receiveButton[index] = createButtonWithFramename(RES("btn_1_select.png"))
	local receiveTextLabel = createSpriteWithFrameName(RES("word_button_getreword.png"))
	self.receiveButton[index]:setTitleString(receiveTextLabel)
	node:addChild(self.receiveButton[index])
	VisibleRect:relativePosition(self.receiveButton[index], node, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(120, -28))	
	
	self.haveReceiveButton[index] = createButtonWithFramename(RES("btn_1_disable.png"))
	local haveReceiveTextLabel = createSpriteWithFrameName(RES("word_button_getreword.png"))
	self.haveReceiveButton[index]:setTitleString(haveReceiveTextLabel)
	node:addChild(self.haveReceiveButton[index])
	VisibleRect:relativePosition(self.haveReceiveButton[index], node, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(120, -25))		
	self.haveReceiveButton[index]:setVisible(false)			
	--领取回调
	local receiveFun = function ()
		local status = nodeViewObj.status
		if status == 0 then
			UIManager.Instance:showSystemTips(Config.Words[13728])
		elseif status == 2 then	
			local stage = nodeViewObj.stage	
			self.everyWeekconsumeMgr:requestWeekConsumeGiftReceive(stage)		
			local payMgr = GameWorld.Instance:getPayActivityManager()
			payMgr:setEveryWeekConsumeReceiveIndex(stage)			
		elseif status == 1 then
			UIManager.Instance:showSystemTips(Config.Words[13731])		
		end
						
	end
	self.receiveButton[index]:addTargetWithActionForControlEvents(receiveFun,CCControlEventTouchDown)	
	--已领取回调
	local haveReceiveFun = function ()
		local status = nodeViewObj.status
		if status == 1 then
			UIManager.Instance:showSystemTips(Config.Words[13731])	
		end			
	end
	self.haveReceiveButton[index]:addTargetWithActionForControlEvents(haveReceiveFun, CCControlEventTouchDown)
	
	if status == 1 then
		self.haveReceiveButton[index]:setVisible(true)	
		self.receiveButton[index]:removeFromParentAndCleanup(true)
	end
	
	return node
end

function EveryWeekPayAwardView:receiveEveryWeekGifg(index)											
	local payActivityMgr = GameWorld.Instance:getPayActivityManager()
	payActivityMgr:requestCanReceiveActivityList()
	local nodeViewObj = self.giftList[tostring(index)]
	nodeViewObj.status = 1	
	self:refreshReceiveImageList()
	self:refreshSelectFrame()	
	self.receiveButton[tonumber(index)]:removeFromParentAndCleanup(true)
	self.haveReceiveButton[tonumber(index)]:setVisible(true)							
end

function EveryWeekPayAwardView:updateView()
	self.giftList = self.everyWeekconsumeMgr:getWeekConsumeGiftList()	
	for key,item in pairs(self.itemView) do
		ItemViewRootNode = item:getRootNode()
		if ItemViewRootNode and ItemViewRootNode:getParent() then
			ItemViewRootNode:removeFromParentAndCleanup(true)
		end
		item:DeleteMe()
	end
	self.itemView = {}
	self:createGiftButtomText()
	self:createItemViewList()	
	self:setTextString()
	self:refreshReceiveImageList()
	self:refreshSelectFrame()
end

function EveryWeekPayAwardView:onEnter()
	
end

function EveryWeekPayAwardView:onExit()
	for key=1, self.giftButtonListSize do
		if self.itemNodeList[key] then
			self.itemNodeList[key]:removeFromParentAndCleanup(true)
			self.itemNodeList[key] = nil
		end			
	end
	for key,item in pairs(self.itemView) do
		ItemViewRootNode = item:getRootNode()
		if ItemViewRootNode and ItemViewRootNode:getParent() then
			ItemViewRootNode:removeFromParentAndCleanup(true)
		end
		item:DeleteMe()
	end
	self.itemView = {}
end

function EveryWeekPayAwardView:refreshReceiveImageList()
	local status
	for key=1, self.giftButtonListSize do
		status = self.giftList[tostring(key)].status
		if status == 1 then
			self.haveReceiveImageList[key]:setVisible(true)
		end
	end
end

function EveryWeekPayAwardView:refreshSelectFrame()
	local status
	local isFind = false
	local selectKey = 0
	local haveChoice = false
	local receiveCount = 0
	for key=1, self.giftButtonListSize do
		status = self.giftList[tostring(key)].status
		if status == 1 then
			receiveCount = receiveCount+1
		end
		if not isFind and status==2 then
			self.selectGiftButton = key
			self.selectFrameList[key]:setVisible(true)
			if  self.itemNodeList[key] then
				self.itemNodeList[key]:setVisible(true)
			end					
			isFind = true
		else
			self.selectFrameList[key]:setVisible(false)
			if self.itemNodeList[key] then
				self.itemNodeList[key]:setVisible(false)
			end	
			if not haveChoice and status == 0 then
				selectKey = key
				haveChoice = true
			end
		end			
	end
	if not isFind then
		if self.selectFrameList[selectKey] then
			self.selectFrameList[selectKey]:setVisible(true)
		end
		if self.itemNodeList[selectKey] then
			self.itemNodeList[selectKey]:setVisible(true)
		end			
	end
	
	if receiveCount == self.giftButtonListSize then	
		self.selectFrameList[1]:setVisible(true)
		if self.itemNodeList[1] then 						
			self.itemNodeList[1]:setVisible(true)					
		end
	end
end



