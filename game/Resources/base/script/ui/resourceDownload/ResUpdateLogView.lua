--[[
--资源更新日志
--]]

ResUpdateLogView = ResUpdateLogView or BaseClass(BaseUI)

local viewSize = VisibleRect:getScaleSize(CCSizeMake(625, 515))

function ResUpdateLogView:__init()
	self.viewName="ResUpdateLogView"
	self:init(viewSize)
	self:setVisiableCloseBtn(false)
	self:createLogLabel()
	self:createRewardNode()
	self:createBtn()
end

function ResUpdateLogView:__delete()
	
end	

function ResUpdateLogView:create()
	return ResUpdateLogView.New()
end

function ResUpdateLogView:createLogLabel()
	local contentSize = self:getContentNode():getContentSize()	
	self.scrollViewSize = VisibleRect:getScaleSize(CCSizeMake(contentSize.width-10, 200))
	
	self.contentBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), CCSizeMake(self.scrollViewSize.width, 320))
	self:addChild(self.contentBg)
	VisibleRect:relativePosition(self.contentBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -10))		
	
	self.scrollView = createScrollViewWithSize(self.scrollViewSize)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self:addChild(self.scrollView)		
	VisibleRect:relativePosition(self.scrollView, self.contentBg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -5))	
				
	self.LogLabel = createRichLabel(CCSizeMake(self.scrollViewSize.width-20,0))	
	self.LogLabel:setFontSize(FSIZE("Size4"))			
	self.LogLabel:setTouchEnabled(true)		
			
	self.containerNode = CCNode:create()
	self.containerNode:setContentSize(self.scrollViewSize)		
	self.scrollView:setContainer(self.containerNode)		
	self.containerNode:addChild(self.LogLabel)	
	VisibleRect:relativePosition(self.LogLabel,self.containerNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,0))	
		
	self:showLog()
end

function ResUpdateLogView:createRewardNode()
	local contentSize = self:getContentNode():getContentSize()
	local rewardNodeSize = CCSizeMake(contentSize.width, 70)
	self.rewardNode = CCNode:create()
	self.rewardNode:setContentSize(rewardNodeSize)
	self:addChild(self.rewardNode)
	VisibleRect:relativePosition(self.rewardNode, self.scrollView, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))	
	
	self:showReward()
end

function ResUpdateLogView:createBtn()
	self.recviveBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self:addChild(self.recviveBtn)
	VisibleRect:relativePosition(self.recviveBtn, self.contentBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(0, -10))
	
	local recvive = function ()
		
	end

	self.recviveBtn:addTargetWithActionForControlEvents(recvive,CCControlEventTouchDown)	
end

function ResUpdateLogView:showLog()
	self.LogLabel:clearAll()
	self.LogLabel:setTouchEnabled(true)	
	local resDownloadMgr = G_getHero():getResDownloadMgr()
	local versionNode = resDownloadMgr:getversionNode() or " "
	local logStr = Config.Words[23000] .. "\n" .. Config.Words[23001] .. versionNode.."\n" .. Config.Words[23002] .. "\n"
	local log = resDownloadMgr:getUpdateLog()
	for index, value in pairs(log) do 
		logStr = logStr .. index.. ". " ..value .. "\n"		
	end
	self.LogLabel:appendFormatText(logStr)
	VisibleRect:relativePosition(self.LogLabel,self.containerNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,0))
	
	local size = self.LogLabel:getContentSize()
	if self.scrollViewSize.height > size.height then
		size.height = self.scrollViewSize.height
		self.LogLabel:setContentSize(size)
	else
		self.containerNode:setContentSize(CCSizeMake(self.scrollViewSize.width, size.height+20))	
	end	
	self.scrollView:updateInset()
end

function ResUpdateLogView:showReward()
	local reward = G_getHero():getResDownloadMgr():getReward()
	local preNode = self.rewardNode
	for index, value in pairs(reward) do 	
		local itemBox = nil
		if value.ttype == RewardType.YuanBao then 
			itemBox = G_createItemShowByItemBox("unbindedGold", value.num)
		elseif value.ttype == RewardType.BindYuanBao then 
			itemBox = G_createItemShowByItemBox("bindedGold", value.num)
		elseif value.ttype == RewardType.Gold then 
			itemBox = G_createItemShowByItemBox("gold", value.num)
		elseif value.ttype == RewardType.Item then
			itemBox = CCNode:create()
		else 
			return
		end
		self.rewardNode:addChild(itemBox)
		if preNode == self.rewardNode then 
			VisibleRect:relativePosition(itemBox, preNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
		else
			VisibleRect:relativePosition(itemBox, preNode, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(20, 0))
		end
		preNode = itemBox
	end
	
end