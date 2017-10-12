require("common.BaseUI")
SubPackageLoadView = SubPackageLoadView or BaseClass(BaseUI)

local contentSize = CCSizeMake(473,331)

function SubPackageLoadView:__init()
	self.viewName = "SubPackageLoadView"
	self:init(contentSize)
	self:initStaticView()
	self.hasError = false
end	

function SubPackageLoadView:__delete()

end

function SubPackageLoadView:create()
	return SubPackageLoadView.New()
end

function SubPackageLoadView:onEnter(arg)

	self:updateRewardView()
end


function SubPackageLoadView:setError(hasError)
	self.hasError = hasError
end

function SubPackageLoadView:updateRewardView()
	if ResManager.Instance:canGetReward() and self.hasError == false then
		local list = ResManager.Instance:getReward()
		self:updateAwardList(list)
	else
		self:updateAwardList(nil)	
	end
end

function SubPackageLoadView:initStaticView()
	local secondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(contentSize.width-30,contentSize.height-70))
	self:addChild(secondBg)
	VisibleRect:relativePosition(secondBg, self:getContentNode(), LAYOUT_CENTER)
	
	self.thirdBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(contentSize.width-60,contentSize.height-160))
	secondBg:addChild(self.thirdBg)
	VisibleRect:relativePosition(self.thirdBg, secondBg, LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-10))
	
	self.titleName = createLabelWithStringFontSizeColorAndDimension(Config.Words[347], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow1"))	
	secondBg:addChild(self.titleName)
	VisibleRect:relativePosition(self.titleName, secondBg, LAYOUT_CENTER+LAYOUT_TOP_OUTSIDE)	
end

function SubPackageLoadView:updateContentText(text)
	self:clearTopContent()
	
	if text == nil then
		text = ""
	end
	if self.contentText == nil then
		self.contentText = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"),CCSizeMake(contentSize.width-80,0))
		self.thirdBg:addChild(self.contentText)
		VisibleRect:relativePosition(self.contentText, self.thirdBg, LAYOUT_CENTER)
	else
		self.contentText:setString(text)
	end
end

-- 创建奖品列表
function SubPackageLoadView:updateAwardList(awardList)
	self:clearTopContent()
	
	if awardList == nil then
		if self.logoIcon == nil then
			self.logoIcon = createScale9SpriteWithFrameName(RES("loadSence_logo.png"))
			self.logoIcon:setScale(0.6)
			self.thirdBg:addChild(self.logoIcon)
			VisibleRect:relativePosition(self.logoIcon, self.thirdBg, LAYOUT_CENTER)
		else
			self.logoIcon:setVisible(true)
		end
	else
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
		
		self.awardListView = createScrollViewWithSize(viewSize)
		self.awardListView:setContainer(container)
		self.awardListView:setDirection(1)
		self.thirdBg:addChild(self.awardListView)
		VisibleRect:relativePosition(self.awardListView, self.thirdBg, LAYOUT_CENTER)	
	end
end

-- 创建单个奖品
function SubPackageLoadView:createItem(v)
	local eachAwardNode = CCNode:create()
	eachAwardNode:setContentSize(VisibleRect:getScaleSize(CCSizeMake(130, 150)))
		
	local itemBoxShow = G_createItemShowByItemBox(v.itemRefId,v.number,nil,nil,nil,-1)
	eachAwardNode:addChild(itemBoxShow)
	VisibleRect:relativePosition(itemBoxShow,eachAwardNode, LAYOUT_CENTER)

	return eachAwardNode
end

function SubPackageLoadView:clearTopContent()
	if self.awardListView then
		self.awardListView:removeFromParentAndCleanup(true)
		self.awardListView = nil
	end
	if self.contentText then
		self.contentText:setVisible(false)
	end
	if self.logoIcon then
		self.logoIcon:setVisible(false)
	end
end

function SubPackageLoadView:updateProgress(tipsWord,rateWord,speedWord)
	self:clearBottomContent()
	
	if self.buttomNode == nil then
		self.buttomNode = CCNode:create()
		self.buttomNode:setContentSize(CCSizeMake(contentSize.width-60,65))
		self.thirdBg:addChild(self.buttomNode)
		VisibleRect:relativePosition(self.buttomNode, self.thirdBg, LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
		
		self.tipsText = createLabelWithStringFontSizeColorAndDimension(Config.Words[348]..tipsWord, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		self.buttomNode:addChild(self.tipsText)
		VisibleRect:relativePosition(self.tipsText, self.buttomNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
		
		self.rateText = createLabelWithStringFontSizeColorAndDimension(rateWord.."%", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
		self.buttomNode:addChild(self.rateText)
		VisibleRect:relativePosition(self.rateText, self.buttomNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)
		
		self.speedText = createLabelWithStringFontSizeColorAndDimension(speedWord.."KB/S", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
		self.buttomNode:addChild(self.speedText)
		VisibleRect:relativePosition(self.speedText, self.buttomNode, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE)
		
		
		local blueProgress = createSpriteWithFrameName(RES("main_BOSSHp_blue.png"))
		local blackProgress = createSpriteWithFrameName(RES("main_BOSSHpBg.png"))
		self.rateBar = CCProgressTimer:create(blueProgress)		
		self.rateBarBg = CCProgressTimer:create(blackProgress)
		local progressWidthScale = (contentSize.width-60)/(blackProgress:getContentSize().width)
		self.rateBar:setScaleX(progressWidthScale)
		self.rateBar:setScaleY(0.8)
		self.rateBarBg:setScaleX(progressWidthScale)
		self.rateBarBg:setScaleY(0.8)
		self.rateBar:setType(kCCProgressTimerTypeBar)
		self.rateBarBg:setType(kCCProgressTimerTypeBar)
		self.rateBar:setMidpoint(ccp(0, 0.5))
		self.rateBar:setBarChangeRate(ccp(1,0))
		self.buttomNode:addChild(self.rateBarBg)
		self.buttomNode:addChild(self.rateBar)
		self.rateBar:setPercentage(rateWord)
		self.rateBarBg:setPercentage(100)		
		VisibleRect:relativePosition(self.rateBarBg,self.buttomNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-22))
		VisibleRect:relativePosition(self.rateBar,self.buttomNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-22))
	else
		self.tipsText:setString(Config.Words[348]..tipsWord)
		self.rateText:setString(rateWord.."%")
		self.speedText:setString(speedWord.."KB/S")
		self.rateBar:setPercentage(rateWord)
		self.buttomNode:setVisible(true)
	end
end

function SubPackageLoadView:updateBtn()
	self:clearBottomContent()
	
	if self.sureBtn == nil then
		self.sureBtn = createButtonWithFramename(RES("btn_1_select.png"))
		self.thirdBg:addChild(self.sureBtn)
		VisibleRect:relativePosition(self.sureBtn, self.thirdBg, LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
		local sureBtnFun = function()
			if self.hasError == false then
				local key = ResManager.Instance:getResDownloadRewardKey()
				if key then
					ResManager.Instance:requestGetReward(key)
				end
			end				
			self:updateProgress("",0,0)
			self:close()
			GlobalEventSystem:Fire(GameEvent.EventChangeDownloadButtonState,false)			
		end
		self.sureBtn:addTargetWithActionForControlEvents(sureBtnFun, CCControlEventTouchDown)
		local sureBtnText = createLabelWithStringFontSizeColorAndDimension(Config.Words[23007], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		self.sureBtn:addChild(sureBtnText)
		VisibleRect:relativePosition(sureBtnText, self.sureBtn, LAYOUT_CENTER)
	else
		self.sureBtn:setVisible(true)
	end
end

function SubPackageLoadView:clearBottomContent()
	if self.sureBtn then
		self.sureBtn:setVisible(false)
	end
	if self.buttomNode then
		self.buttomNode:setVisible(false)
	end
end