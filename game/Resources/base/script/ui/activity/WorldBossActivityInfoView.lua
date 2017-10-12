WorldBossActivityInfoView = WorldBossActivityInfoView or BaseClass()

local teamBossTypeList = {
[1] = "activity_manage_20",
[2] = "activity_manage_21",
[3] = "activity_manage_22",
}

local viewSize = CCSizeMake(874, 564)
local scrollViewSize = CCSizeMake(viewSize.width-80, 70)

function WorldBossActivityInfoView:__init()
	self.rootNode = CCLayer:create()	
	self.rootNode:setTouchEnabled(true)
	self.rootNode:retain()
	self.rootNode:setContentSize(viewSize)	
	self:createBg()	
	self:createLimitDescription()
	self:createInstroduce()	
	self:createRichText()	
end

function WorldBossActivityInfoView:__delete()

end

function WorldBossActivityInfoView:getRootNode()
	return self.rootNode
end

function WorldBossActivityInfoView:create()
	return WorldBossActivityInfoView.New()
end

function WorldBossActivityInfoView:update()
	self:setIntroduce()
	self:setLimitDescription()
	self:setRichText()
	--富文本信息
end

function WorldBossActivityInfoView:onExit()
	
end	

function WorldBossActivityInfoView:createBg()
	self.bodyBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(viewSize.width-55,255))--CCSizeMake(831,479))	
	self.rootNode:addChild(self.bodyBg)
	VisibleRect:relativePosition(self.bodyBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,0))
end

function WorldBossActivityInfoView:createLimitDescription()
	--开始时间
	self.startTimeTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24000], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.rootNode:addChild(self.startTimeTitle)
	VisibleRect:relativePosition(self.startTimeTitle,self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(50, -15))
	
	self.startTime = createLabelWithStringFontSizeColorAndDimension(""--[[Config.Words[24000]--]], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self.rootNode:addChild(self.startTime)
	self:positionStartTimeLabel()
	--结束时间
	self.endTimeTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24001], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.rootNode:addChild(self.endTimeTitle)
	VisibleRect:relativePosition(self.endTimeTitle, self.startTimeTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
	
	self.endTime = createLabelWithStringFontSizeColorAndDimension(""--[[Config.Words[24001]--]], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self.rootNode:addChild(self.endTime)
	self:positionEndTimeLabel()

	--警告
	self.warning = createLabelWithStringFontSizeColorAndDimension(Config.Words[24005] ..Config.Words[24007], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self.rootNode:addChild(self.warning)
	self:positionwarningLabel()

	local limitArea = createLabelWithStringFontSizeColorAndDimension(Config.Words[25529], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self.rootNode:addChild(limitArea)
	VisibleRect:relativePosition(limitArea,self.bodyBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(25,-5))
		
	
	--分割线
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(viewSize.width-100,2))
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.warning, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(10, -15))
end

function WorldBossActivityInfoView:createRichText()
	self.linkRichText = createRichLabel(CCSizeMake(700,0))
	self.linkRichText:setGaps(10)
	self.linkRichText:setAnchorPoint(ccp(0.5,1))
	self.linkRichText:setFontSize(FSIZE("Size3"))	
	self.linkRichText:setTouchEnabled(true)
	self.rootNode:addChild(self.linkRichText)
	VisibleRect:relativePosition(self.linkRichText, self.bodyBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(50,-60))	
	self:setRichLabelHandler()
end

--活动简介
function WorldBossActivityInfoView:createInstroduce()
	local introduceTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[24003], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.rootNode:addChild(introduceTitle)
	VisibleRect:relativePosition(introduceTitle, self.warning, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -25))	
	
	self.scrollView = createScrollViewWithSize(scrollViewSize)
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)
	self.scrollView:setPageEnable(false)
	self.rootNode:addChild(self.scrollView)		
	VisibleRect:relativePosition(self.scrollView, introduceTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE)
	
	self.scrollContentNode = CCNode:create()
	self.scrollContentNode:setContentSize(scrollViewSize)
	self.scrollView:setContainer(self.scrollContentNode)
	
	--self.introduce = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorWhite1"), CCSizeMake(scrollViewSize.width, 0))
	self.introduce = createRichLabel(CCSizeMake(scrollViewSize.width,0))	
	self.introduce:setFontSize(FSIZE("Size3"))	
	self.scrollContentNode:addChild(self.introduce)
--	self:positionIntroduceLabel()
end

function WorldBossActivityInfoView:setIntroduce()
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	local ttype  = 	mgr:getCurrentActivityType()	
	local refId = teamBossTypeList[ttype]
	local str = GameData.ActivityManage[refId]["property"]["description"]			
	self.introduce:clearAll()
	self.introduce:appendFormatText("       "..str)
	local size = CCSizeMake(self.introduce:getContentSize().width, self.introduce:getContentSize().height)	
	if size.height < scrollViewSize.height then	
		size.height = scrollViewSize.height
	end		
	
	self.scrollContentNode:setContentSize(size)				
	self.scrollView:setContentOffset(ccp(0, -size.height + scrollViewSize.height))	
	self.scrollView:updateInset()	

	self:positionIntroduceLabel()
end

function WorldBossActivityInfoView:setLimitDescription()
	local startTime, endTime = self:getStartAndEndTime()		
	self:setStartTime(startTime)
	self:setEndTime(endTime)	
end	

function WorldBossActivityInfoView:setStartTime(time)
	time = time or " "
	local startTime = --[[Config.Words[24000] .. --]]time
	self.startTime:setString(startTime)
	self:positionStartTimeLabel()
end

function WorldBossActivityInfoView:setEndTime(time)
	time = time or " "
	local endTime = --[[Config.Words[24001] .. --]]time
	self.endTime:setString(endTime)
	self:positionEndTimeLabel()
end

function WorldBossActivityInfoView:setWarning(warning)
	warning = warning or " "
	local warningStr = Config.Words[24005] .. warning
	self.warning:setString(warningStr)
	self:positionwarningLabel()	
end

function WorldBossActivityInfoView:setRichText()
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	local linkList = mgr:getCurrentActivitySceneAndBossList()
	local fillStr = "                          "
	local richText = ""
	local  index = 1 
	for k ,v in ipairs(linkList)do	
		local mapMgr =  GameWorld.Instance:getMapManager()		
		local mapNameword = mapMgr:getMapName(v.transfer.targetScene)
		local sceneLen = string.len(mapNameword)			
		local sceneText =  string.wrapHyperLinkRich(mapNameword,Config.FontColor["ColorYellow2"],FSIZE("Size3"),v.transfer.targetScene .. "|" .. v.bossRefId, "true") 		
		local fillSubStr = string.sub(fillStr,sceneLen)	
		local watchText =  string.wrapHyperLinkRich(Config.Words[25528],Config.FontColor["ColorWhite1"],FSIZE("Size3"),v.bossRefId, "true") 
		
		local recordText = sceneText  .. fillSubStr .. watchText 
		richText = richText .. recordText
		if index%2 == 0 then
			richText = richText .. "\n"
		else
			richText = richText .. "           "
		end
		index = index + 1
	end
	self.linkRichText:clearAll()	
	self.linkRichText:appendFormatText(richText)
	VisibleRect:relativePosition(self.linkRichText, self.bodyBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(50,-60))	
	self.linkRichText:setTouchEnabled(true)
end

--private
function WorldBossActivityInfoView:positionStartTimeLabel()
	VisibleRect:relativePosition(self.startTime, self.startTimeTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function WorldBossActivityInfoView:positionEndTimeLabel()
	VisibleRect:relativePosition(self.endTime, self.endTimeTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function WorldBossActivityInfoView:positionLimitLvLabel()
	VisibleRect:relativePosition(self.limitLv, self.limitLvTitle, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE)
end

function WorldBossActivityInfoView:positionwarningLabel()
	VisibleRect:relativePosition(self.warning, self.endTimeTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
end

function WorldBossActivityInfoView:positionIntroduceLabel()
	VisibleRect:relativePosition(self.introduce, self.scrollContentNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE)
end

--获取开始和结束时间
function WorldBossActivityInfoView:getStartAndEndTime()
	local startTime, endTime = "", ""
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	local ttype  = 	mgr:getCurrentActivityType()
	local tmpTime = ""
	require "data.activity.teamBoss"
	local time  = " "
	for k , v  in pairs(GameData.TeamBoss) do
		if v.activityData[1].type == ttype then
			time = v.time.duration
		end
	end	
	time = string.split(time, "&")
	if time and time[1] then 
		tmpTime = string.split(time[1], "|")
		if tmpTime then 
			startTime = tmpTime[1]
			endTime = tmpTime[2]
		end
	end
	if time and time[2] then 
		tmpTime = string.split(time[2], "|")
		if tmpTime then 
			startTime = startTime .."   ".. tmpTime[1]
			endTime = endTime .. "   "..tmpTime[2]
		end
	end

	return startTime, endTime, weekDay
end

function WorldBossActivityInfoView:setRichLabelHandler()
	local richLabelHandler = function(arg, pTouch)	
		local touch = tolua.cast(pTouch, "CCTouch")
		local pos = touch:getLocation()
		if arg then		
			if string.find(arg,"|") then
				local params = string.split(arg,"|")
				local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
				AutoPathMgr:find(params[2],params[1])
			else
				local monsterRefId = arg			
				GlobalEventSystem:Fire(GameEvent.EventShowWorldBossView,monsterRefId)
			end
		end
	end
	self.linkRichText:setEventHandler(richLabelHandler)
end	