--[[
--分包下载
--]]
ResDownloadView = ResDownloadView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local viewSize = VisibleRect:getScaleSize(CCSizeMake(625, 515))

function ResDownloadView:__init()
	self.viewName="ResDownloadView"
	self:initRootNode()
	self:createLogo()
	self:createGameTips()
	self:createLoadingTips()
	self:createSpeedTips()
	self:createDownloadProgress()
end

function ResDownloadView:__delete()
	
end

function ResDownloadView:onEnter()

end

function ResDownloadView:create()
	return ResDownloadView.New()
end

function ResDownloadView:initRootNode()	
	self.rootNode:setContentSize(viewSize)	
	local rect = CCRectMake(71,14,2,20)
	self:createBackground(viewSize,nil,rect)
end

function ResDownloadView:createLogo()
	--logo
	local logo = createSpriteWithFrameName(RES("loadSence_logo.png"))
	self.rootNode:addChild(logo)
	VisibleRect:relativePosition(logo, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, -12))
	
	--设置contentNode的大小和位置
	local logoSize = logo:getContentSize()
	local contentNodeSize = VisibleRect:getScaleSize(CCSizeMake(viewSize.width-10, viewSize.height-logoSize.height-15))
	self.contentNode:setContentSize(contentNodeSize)
	VisibleRect:relativePosition(self.contentNode, logo, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
end

function ResDownloadView:createGameTips()
	self.gameTipsBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(CCSizeMake(400, 30)))
	self.contentNode:addChild(self.gameTipsBg)
	VisibleRect:relativePosition(self.gameTipsBg, self.contentNode, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -10))
	
	self.gameTipsLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))
	self.gameTipsBg:addChild(self.gameTipsLabel)
	self:positionGameTips()
		
end	

function ResDownloadView:createLoadingTips()
	self.loadingTipsBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(CCSizeMake(250, 30)))
	self.contentNode:addChild(self.loadingTipsBg)
	VisibleRect:relativePosition(self.loadingTipsBg, self.gameTipsBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, -10))
	
	self.loadingTipsLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))
	self.loadingTipsBg:addChild(self.loadingTipsLabel)
	self:positionLoadingTips()	
end

function ResDownloadView:createSpeedTips()
	self.speedTipsBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(CCSizeMake(140, 30)))
	self.contentNode:addChild(self.speedTipsBg)
	VisibleRect:relativePosition(self.speedTipsBg, self.loadingTipsBg,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	
	self.speedTipsLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"))
	self.speedTipsBg:addChild(self.speedTipsLabel)
	self:positionSpeedTips()
end

function ResDownloadView:createDownloadProgress()
	self.downloadProgress = createProgressBar(RES("player_expBarBg.png"),RES("player_hp.png"),CCSizeMake(390,15))	
	self.downloadProgress:setPercentage(0)			
	self.downloadProgress:setNumberVisible(false)	
	self.contentNode:addChild(self.downloadProgress)
	VisibleRect:relativePosition(self.downloadProgress, self.loadingTipsBg, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
	VisibleRect:relativePosition(self.downloadProgress, self.contentNode, LAYOUT_CENTER_X)

	local border = createScale9SpriteWithFrameNameAndSize(RES("player_bar_frame.png"), CCSizeMake(398, 25))
	self.downloadProgress:addChild(border, -1)
	VisibleRect:relativePosition(border, self.downloadProgress, LAYOUT_CENTER, ccp(0, 0))
	
	self.precentBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(CCSizeMake(70, 30)))
	self.contentNode:addChild(self.precentBg)
	VisibleRect:relativePosition(self.precentBg, self.downloadProgress, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(0, -10))
	
	self.progressLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	self.precentBg:addChild(self.progressLabel)
	VisibleRect:relativePosition(self.progressLabel, self.precentBg, LAYOUT_CENTER)	
end

------pulic -----
function ResDownloadView:setGameTips(tips)
	if tips and type(tips) == "string" then 
		self.gameTipsLabel:setString(tips)
		self:positionGameTips()
	end
end

function ResDownloadView:setLoadingTips(tips)
	if tips and type(tips) == "string" then 
		self.loadingTipsLabel:setString(tips)
		self:positionLoadingTips()
	end
end

function ResDownloadView:setSpeedTips(speed)
	if speed then 
		local curSpeed = string.format("%.2f", speed)
		curSpeed = curSpeed .. " KB/S"
		self.speedTipsLabel:setString(curSpeed)
		self:positionSpeedTips()
	end
end


--更新调用此接口
function ResDownloadView:update(curPro, maxPro, speed)
	self:setSpeedTips(speed)
	self:setDownloadProgress(curPro, maxPro)
end

function ResDownloadView:setDownloadProgress(curProgress, maxProgress)
	if curProgress and maxProgress then 	
		if curProgress >= maxProgress then 
			curProgress = maxProgress
		end	
		self.downloadProgress:setCurrentNumber(curProgress)
		self.downloadProgress:setMaxNumber(maxProgress)		
		local precent = string.format("%.2f", self.downloadProgress:getPercentage())
		self.progressLabel:setString(precent .. "%")
		VisibleRect:relativePosition(self.progressLabel, self.precentBg, LAYOUT_CENTER)
	end	
end


------private-----
function ResDownloadView:positionGameTips()
	VisibleRect:relativePosition(self.gameTipsLabel, self.gameTipsBg, LAYOUT_CENTER)
end

function ResDownloadView:positionLoadingTips()
	VisibleRect:relativePosition(self.loadingTipsLabel, self.loadingTipsBg, LAYOUT_CENTER)
end

function ResDownloadView:positionSpeedTips()
	VisibleRect:relativePosition(self.speedTipsLabel, self.speedTipsBg, LAYOUT_CENTER)
end
