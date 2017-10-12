require("common.baseclass")
require("config.words")
require ("ui.utils.BaseActivityNode")
MiningInfoView = MiningInfoView or BaseClass(BaseActivityNode)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
function MiningInfoView:__init()
	self.iconName = {
		[1] = "2032",
		[2] = "2030",
		[3] = "2029",		
	}
	self.mineralInfo = {
		[1] = {refId = "npc_collect_6",name = Config.Words[19005],color = FCOLOR("ColorPurple1")},
		[2] = {refId = "npc_collect_5",name = Config.Words[19006],color = FCOLOR("ColorGreen1")},
		[3] = {refId = "npc_collect_4",name = Config.Words[19007],color = FCOLOR("ColorWhite1")},
	}
	self.rebackonlineTimerId = -1
	self.nextTimerId = -1
	self.autoFindCallBackId = -1	
	local title = createLabelWithStringFontSizeColorAndDimension(Config.Words[19002], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite1"))
	self:setTitle(title)
	local pkTitleLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19020],"Arial",FSIZE("Size3"),FCOLOR("ColorRed5"))
	self.titleBg:addChild(pkTitleLb)
	VisibleRect:relativePosition(pkTitleLb,self.titleBg,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-30,0))	
	self:initStaticInfoView()	
	self.rootNode:setVisible(false)	
end

function MiningInfoView:getRootNode()
	return self.rootNode
end

function MiningInfoView:__delete()
	if self.callBackId then
		GameWorld.Instance:getAutoPathManager():unRegistCallBack(self.callBackId)
		self.callBackId = nil
	end
end

function MiningInfoView:initStaticInfoView()
	local miningLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19003],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self:addChild(miningLb)
	VisibleRect:relativePosition(miningLb,self.contentNode,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(5,-5))	
	
	self.countLb = createLabelWithStringFontSizeColorAndDimension("0/20","Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))	
	self:addChild(self.countLb)
	VisibleRect:relativePosition(self.countLb,miningLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))	
	
	self.timeTitleLb =  createLabelWithStringFontSizeColorAndDimension(Config.Words[19011],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self:addChild(self.timeTitleLb)
	VisibleRect:relativePosition(self.timeTitleLb,miningLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	
	
	
	self.leftTimeLb = createLabelWithStringFontSizeColorAndDimension("00:00:00","Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))	
	self:addChild(self.leftTimeLb)
	VisibleRect:relativePosition(self.leftTimeLb,self.timeTitleLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))	

	local line = createScale9SpriteWithFrameName(RES("main_questLine.png"))	
	self:addChild(line)
	VisibleRect:relativePosition(line,self.timeTitleLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	self:createTouchLayer()
	--[[local describeTitleLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19004],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self:addChild(describeTitleLb)
	VisibleRect:relativePosition(describeTitleLb,self.timeTitleLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	--]]
	
	--[[for i = 1,4 do
		local iconBg = createScale9SpriteWithFrameName(RES("bagBatch_itemBg.png"))
		iconBg:setScale(0.7)
		local icon = createSpriteWithFileName(ICON(self.iconName[i]))
		icon:setScale(0.7)
		self.width = iconBg:getContentSize().width*0.7
		self:addChild(iconBg)
		self:addChild(icon)
		VisibleRect:relativePosition(iconBg,describeTitleLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(5+(i-1)*(self.width+5),-5))
		VisibleRect:relativePosition(icon,iconBg,LAYOUT_CENTER)
	end--]]
	 
	--[[local rewardLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19010],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite2"))
	self:addChild(rewardLb)
	VisibleRect:relativePosition(rewardLb,describeTitleLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-self.width-10))	
	local goldLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19005],"Arial",FSIZE("Size3"),FCOLOR("ColorPurple1"))
	local silverLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19006],"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
	local copperLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[19007],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite1"))	
	self:addChild(goldLb)
	self:addChild(silverLb)
	self:addChild(copperLb)	
	VisibleRect:relativePosition(goldLb,rewardLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	VisibleRect:relativePosition(silverLb,goldLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
	VisibleRect:relativePosition(copperLb,silverLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))	--]]
end

--三种矿的点击栏
function MiningInfoView:createTouchLayer()
	self.layerList = {}
	self.icon = {}
	self.tipsLabel = {}
	for i = 1,3 do
		self.layerList[i] = CCLayer:create()
		self.layerList[i]:setContentSize(CCSizeMake(self.rootNode:getContentSize().width,40))
		self.layerList[i]:setTouchEnabled(true)
		self:addChild(self.layerList[i])
		if i == 1 then
			VisibleRect:relativePosition(self.layerList[i],self.timeTitleLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
		else
			VisibleRect:relativePosition(self.layerList[i],self.layerList[i-1],LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
		end
		local line = createScale9SpriteWithFrameName(RES("main_questLine.png"))	
		self.layerList[i]:addChild(line)
		VisibleRect:relativePosition(line,self.layerList[i],LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,0))
		self.icon[i] = CCSprite:create("map/collect/".. self.iconName[i] ..".pvr")
		if self.icon[i] then
			self.icon[i]:setScaleX(30/self.icon[i]:getContentSize().width)
			self.icon[i]:setScaleY(30/self.icon[i]:getContentSize().height)
			self.layerList[i]:addChild(self.icon[i])
			VisibleRect:relativePosition(self.icon[i],self.layerList[i],LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(10,0))
			local nameLabel = createLabelWithStringFontSizeColorAndDimension(self.mineralInfo[i].name,"Arial",FSIZE("Size1"),self.mineralInfo[i].color)
			self.layerList[i]:addChild(nameLabel)
			VisibleRect:relativePosition(nameLabel,self.icon[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(10,0))
			if i == 1 then
				self.timeLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[19008],"Arial",FSIZE("Size1"),FCOLOR("ColorWhite2"))
				self.layerList[i]:addChild(self.timeLabel)
				VisibleRect:relativePosition(self.timeLabel,self.icon[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*5,0))
			end
			local initTipsStr = string.format("%s%s%s",Config.Words[19009],"0",Config.Words[19010])
			self.tipsLabel[i] = createLabelWithStringFontSizeColorAndDimension(initTipsStr,"Arial",FSIZE("Size1"),FCOLOR("ColorWhite2"))
			self.layerList[i]:addChild(self.tipsLabel[i])
			VisibleRect:relativePosition(self.tipsLabel[i],self.icon[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*8,0))				
		end
		self:setTouchHandler(self.layerList[i],i)	
	end
end

function MiningInfoView:setTouchHandler(node,index)
	local function ccTouchHandler(eventType, x,y)
		if eventType == "began" then
			return self:handleTouch(eventType, x, y, node,index)
		end			
	end
	node:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function MiningInfoView:handleTouch(eventType, x, y, node,index)
	if node:isVisible() and node:getParent() then	
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then				
			--local miningMgr = GameWorld.Instance:getMiningMgr()
			--G_getHandupMgr():start(E_AutoSelectTargetMode.Collect, {EntityType.EntityType_NPC}, {self.mineralInfo[index].refId}, nil, nil, E_SearchTargetMode.RefId)
			
			if self.lastIndex ~= index then
				self.lastIndex = index
				local endRuning = function(state,id)
					if self.callBackId and self.callBackId == id then
						G_getHandupMgr():start(E_AutoSelectTargetMode.Collect, {EntityType.EntityType_NPC}, {"npc_collect_4","npc_collect_5","npc_collect_6"}, nil, nil, E_SearchTargetMode.Random)
						GameWorld.Instance:getAutoPathManager():unRegistCallBack(self.callBackId)
						self.callBackId = nil
						self.lastIndex= -1
					end
				end
				G_getHandupMgr():stop()		
				if  self.callBackId then					
					GameWorld.Instance:getAutoPathManager():unRegistCallBack(self.callBackId)
					self.callBackId = nil
				end	
				self.callBackId = GameWorld.Instance:getAutoPathManager():registCallBack(endRuning)
				GameWorld.Instance:getAutoPathManager():find(self.mineralInfo[index].refId,"S217")	
			end
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

--[[function MiningInfoView:getCollectListByIndex(index)
	local j = 2
	local collectList = {}
	for i,v in pairs(self.mineralInfo) do
		if index ~= i then
			if self.mineralInfo[i].refId then
				collectList[j] = self.mineralInfo[i].refId
				j = j+1
			end
		end
	end
	collectList[1] = self.mineralInfo[index].refId
	return collectList
end--]]

function MiningInfoView:refreshCount()
	local miningMgr = GameWorld.Instance:getMiningMgr()
	local curCount = miningMgr:getCurrentCount()
	if not curCount then
		curCount = 0
	end
	local countStr = string.format("%s/20",curCount)
	self.countLb:setString(countStr)
	if curCount == 20 then
		self.countLb:setColor(FCOLOR("ColorRed1"))
	end
	local pluckInfo = miningMgr:getPluckInfo()
	if pluckInfo then
		for i = 1,3 do
			if pluckInfo[i] then
				local tipsStr = string.format("%s%s%s",Config.Words[19009],tostring(pluckInfo[i]),Config.Words[19010])
				if self.tipsLabel then
					self.tipsLabel[i]:setString(tipsStr)
					VisibleRect:relativePosition(self.tipsLabel[i],self.icon[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*8,0))		
				end
			end
		end
	end
end

function MiningInfoView:refreshMiningLeftTime()
	local miningMgr = GameWorld.Instance:getMiningMgr()
	local leftTime = miningMgr:getLeaveTime()
	if leftTime then
		self.leftTime = leftTime
		local s_sec,s_min,s_hour = G_GetSecondsToDateString(self.leftTime)
		local time = string.format("%s:%s:%s",s_hour,s_min,s_sec)
		self.leftTimeLb:setString(time)
		VisibleRect:relativePosition(self.leftTimeLb,self.timeTitleLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))	
		if self.reBackonlineTimerFunc == nil then
			self.reBackonlineTimerFunc = function ()
				self.leftTime = self.leftTime - 1 
				if self.leftTime < 0 then
					self:stopMiningTime()
					return
				end
				s_sec,s_min,s_hour = G_GetSecondsToDateString(self.leftTime)
				time = string.format("%s:%s:%s",s_hour,s_min,s_sec)
				self.leftTimeLb:setString(time)
				VisibleRect:relativePosition(self.leftTimeLb,self.timeTitleLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))	
			end
		end
		if self.rebackonlineTimerId == -1 then
			self.rebackonlineTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackonlineTimerFunc, 1, false)
		elseif self.rebackonlineTimerId ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackonlineTimerId)
			self.rebackonlineTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackonlineTimerFunc, 1, false)
		end
	end
end

function MiningInfoView:stopMiningTime()
	if self.rebackonlineTimerId ~= nil and self.rebackonlineTimerId ~= -1 then
		self.leftTimeLb:setString(Config.Words[19014])
		VisibleRect:relativePosition(self.leftTimeLb,self.timeTitleLb,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackonlineTimerId)
		self.rebackonlineTimerId = -1
	end	
end

function MiningInfoView:refreshNextMineralTime()
	local miningMgr = GameWorld.Instance:getMiningMgr()
	local nextTime = miningMgr:getNextMineralTime()
	if nextTime == 0 then
		self:stopNextMineralTime()
		return
	else
		self.nextTime = nextTime
		--local s_sec,s_min,s_hour = G_GetSecondsToDateString(self.nextTime)
		--local timeString = string.format("%s:%s %s",s_min,s_sec,Config.Words[19019])
		local timeString = string.format("(%s%s)",tostring(self.nextTime),"s")
		self.timeLabel:setString(timeString)
		VisibleRect:relativePosition(self.timeLabel,self.icon[1],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*5,0))		
		if self.nextTimerFunc == nil then
			self.nextTimerFunc = function ()
				self.nextTime = self.nextTime - 1 
				if self.nextTime <= 0 then
					self:stopNextMineralTime()
					return
				elseif self.nextTime == 30 then
					miningMgr:requestNextMineralTime()
				elseif self.nextTime == 10 then
					miningMgr:requestNextMineralTime()
				end
				--s_sec,s_min,s_hour = G_GetSecondsToDateString(self.nextTime)
				--local timeString = string.format("%s:%s %s",s_min,s_sec,Config.Words[19019])
				local timeString = string.format("(%s%s)",tostring(self.nextTime),"s")
				self.timeLabel:setString(timeString)
				VisibleRect:relativePosition(self.timeLabel,self.icon[1],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*5,0))		
			end			
		end
		if self.nextTimerId == -1 then
			self.nextTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.nextTimerFunc, 1, false)
		elseif self.nextTimerId ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.nextTimerId)
			self.nextTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.nextTimerFunc, 1, false)
		end
	end
end

function MiningInfoView:stopNextMineralTime()
	if self.nextTimerId ~= nil and self.nextTimerId ~= -1 then
		self.timeLabel:setString(Config.Words[19008])
		VisibleRect:relativePosition(self.timeLabel,self.icon[1],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(FSIZE("Size1")*5,0))		
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.nextTimerId)
		self.nextTimerId = -1
	end	
end