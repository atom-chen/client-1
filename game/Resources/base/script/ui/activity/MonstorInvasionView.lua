--[[
--怪物入侵   活动
--]]
require ("ui.utils.BaseActivityNode")

MonstorInvasionView = MonstorInvasionView or BaseClass(BaseActivityNode)

local rootNodeSize = CCSizeMake(245, 192)
local Ten_Minute = 10*60

local BossIcon = {
monster_9020 = "Ins_4.png",
monster_9061 = "Ins_2.png",
}

local bossTouchArea = VisibleRect:getScaleSize(CCSizeMake(rootNodeSize.width, 70))
	
function MonstorInvasionView:__init()
	self.activityCountDown = 0
	self.bossCountDown = 0
	self.bossName = ""		
	self.bossRefId = ""
	local title = createSpriteWithFrameName(RES("monstor_invasion_label.png"))
	self:setTitle(title)	
	self:createActivityCountDown()  --活动倒计时
	self:createDesc()    --活动的说明	
	self:createBossInfo() 		
	self:createTouchLayer() 
	
	self.rootNode:setVisible(false)
end

function MonstorInvasionView:__delete()
	self:stopCountDown()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end	

--活动倒计时
function MonstorInvasionView:createActivityCountDown()
	self.timeDescLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[19502], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
	self:addChild(self.timeDescLabel)
	VisibleRect:relativePosition(self.timeDescLabel, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(5, -5))
	self.timeLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
	self:addChild(self.timeLabel)
	VisibleRect:relativePosition(self.timeLabel, self.timeDescLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	
	self.line1 = self:createLine(self.timeDescLabel)
end

--活动的说明
function MonstorInvasionView:createDesc()
	local desc1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[19514], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
	local desc2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[19515], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
	self:addChild(desc1)
	self:addChild(desc2)
	VisibleRect:relativePosition(desc1, self.timeDescLabel, LAYOUT_LEFT_INSIDE, ccp(0, 0))
	VisibleRect:relativePosition(desc1, self.line1, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
	VisibleRect:relativePosition(desc2, desc1, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE, ccp(0, -3))
	
	self.line2 = self:createLine(desc2)
end

function MonstorInvasionView:createTouchLayer()
	self.bossLayer = CCLayer:create()
	self.bossLayer:setContentSize(bossTouchArea)
	self.bossLayer:setTouchEnabled(true)
	self:addChild(self.bossLayer)
	VisibleRect:relativePosition(self.bossLayer, self:getContentNode(), LAYOUT_CENTER_X, ccp(0, 0))
	VisibleRect:relativePosition(self.bossLayer, self.line2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
	self:setTouchHandler(self.bossLayer)	
end


function MonstorInvasionView:setTouchHandler(node)
	local function ccTouchHandler(eventType, x,y)
		if eventType == "began" then
			return self:handleTouch(eventType, x, y, node)
		end			
	end
	node:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function MonstorInvasionView:handleTouch(eventType, x, y, node)
	if node:isVisible() and node:getParent() then	
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then
			if node == self.bossLayer then   --boss
				local autoPathMgr = GameWorld.Instance:getAutoPathManager()
				local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
				local monstorRefId = monstorInvasionMgr:getMonstorRefId()
				local sceneId = monstorInvasionMgr:getBossSceneRefId()			
				if monstorRefId and monstorRefId~="" and  sceneId then
					autoPathMgr:find(monstorRefId, sceneId)
				end						
			end
			return 1
		else
			return 0
		end
	else
		return 0
	end
end		

function MonstorInvasionView:createBossInfo()
	self.bossIconBg = createSpriteWithFrameName(RES("ins_clickFrame.png"))	
	self.bossIconBg:setScale(0.7)
	self:addChild(self.bossIconBg)	
	VisibleRect:relativePosition(self.bossIconBg, self.line2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, 23))
	VisibleRect:relativePosition(self.bossIconBg, self:getContentNode(), LAYOUT_LEFT_INSIDE, ccp(5, 0))	
	
	self.richLabel = createRichLabel(CCSizeMake(rootNodeSize.width-105,0))
	self.richLabel:setGaps(2)	
	self:addChild(self.richLabel)
	self:positionRichLabel()	
end


-----------------public ----------------------
--以时分秒形式返回
function MonstorInvasionView:calculateTime(time)
	local cnt = time
	local hour = math.modf(cnt / (60*60))
	hour = string.format("%02d", hour)
	cnt = cnt - hour * (60*60)
	local min = math.modf(cnt / 60)
	min = string.format("%02d", min)
	cnt = cnt - min * 60
	local sec = cnt
	sec = string.format("%02d", sec)
	return hour, min, sec
end

function MonstorInvasionView:start(remainingTime, exp)
	--开始倒计时
	self:setCount(remainingTime)
	self:startCountDown()		
end

function MonstorInvasionView:stop()
	self:stopCountDown()
	self:setCount(0)
	self.bossCountDown = 0
end

--设置活动倒计时时间
function MonstorInvasionView:setCount(time)
	if time < 0 then
		time = 0
	end
	self.activityCountDown = time
end


function MonstorInvasionView:updateBossInfo(refId, refreshTime)
	self.bossCountDown = refreshTime
	self.bossRefId = refId
	self:updateBossName(refId)
	self:updateBossIcon(refId)
end	

function MonstorInvasionView:updateBossName(refId)
	local monsterData = GameData.Monster[refId]	
	self.bossName = ""
	if monsterData then
		self.bossName = PropertyDictionary:get_name(monsterData["property"]) 
	end				
end

function MonstorInvasionView:updateBossIcon(refId)
	if self.bossImage then
		self.bossImage:removeFromParentAndCleanup(true)
		self.bossImage = nil		
	end
	local iconId = nil
	if refId and BossIcon[refId] then
		iconId = BossIcon[refId]			
		if iconId then 
			self.bossImage = createSpriteWithFrameName(RES(iconId))
			self.bossImage:setScale(0.7)
			self:addChild(self.bossImage)
			self:positionBossImage()
		end
	end
end

function MonstorInvasionView:doCountDown()
	if self.activityCountDown == 0 then
		self:stopCountDown()
		return
	end
	--更新活动倒计时
	self.activityCountDown = self.activityCountDown - 1
	local _, min, sec = self:calculateTime(self.activityCountDown)
	local activityTime = ""
	if min and sec then
		activityTime = min ..":" .. sec
	end
	self.timeLabel:setString(activityTime)
	VisibleRect:relativePosition(self.timeLabel, self.timeDescLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	
	--更新boss刷新时间
	local refreshStr = ""
	if self.bossRefId ~= "" then 
		if self.bossCountDown ~= 0 then
			local bossTime = ""
			self.bossCountDown = self.bossCountDown - 1
			hou, min, sec = self:calculateTime(self.bossCountDown)
			bossTime = min .. ":" .. sec
			
			local nameStr = string.wrapHyperLinkRich(self.bossName.."\n", Config.FontColor["ColorWhite2"],FSIZE("Size3"), "123", "true")
			refreshStr = string.wrapHyperLinkRich(bossTime..Config.Words[19505], Config.FontColor["ColorWhite2"],FSIZE("Size3"), "123", "false")
			refreshStr = nameStr .. refreshStr
		else
			local mgr = G_getHero():getMonstorInvasionMgr()
			local nameStr = string.wrapHyperLinkRich(self.bossName.."\n", Config.FontColor["ColorWhite2"],FSIZE("Size3"), "123", "true")
			if mgr:isBossDeath() then 		
				refreshStr = string.wrapHyperLinkRich(Config.Words[19511], Config.FontColor["ColorWhite2"],FSIZE("Size3"), "123", "false")					
			else
				refreshStr = string.wrapHyperLinkRich(Config.Words[19504], Config.FontColor["ColorWhite2"],FSIZE("Size3"), "123", "false")		
			end
			refreshStr = nameStr .. refreshStr
		end
	else
		refreshStr = ""
	end
	self.richLabel:clearAll()
	self.richLabel:setTouchEnabled(true)
	self.richLabel:appendFormatText(refreshStr)	
	self:positionRichLabel()
end

function MonstorInvasionView:startCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
	local tick = function ()
		self:doCountDown()
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end

function MonstorInvasionView:stopCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

function MonstorInvasionView:showExitDlg()
	local onMsgBoxCallBack = function(unused, text, id)
		if (id == 2) then
			local mgr = G_getHero():getMonstorInvasionMgr()
			mgr:requestExitMonstorInvasionActivity()
		end
	end		
	
	local msg = showMsgBox(Config.Words[19510],E_MSG_BT_ID.ID_CANCELAndOK)	
	msg:setNotify(onMsgBoxCallBack)
end

function MonstorInvasionView:createLine(relativeNode)
	local  width = self.rootNode:getContentSize().width
	local line = createScale9SpriteWithFrameNameAndSize(RES("main_questLine.png"), CCSizeMake(width, 2))
	self:addChild(line)	
	VisibleRect:relativePosition(line, self:getContentNode(), LAYOUT_CENTER_X, ccp(0, 0))
	VisibleRect:relativePosition(line, relativeNode, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
	return line
end		

------------private --------------
function MonstorInvasionView:positionBossImage()
	VisibleRect:relativePosition(self.bossImage, self:getContentNode(), LAYOUT_LEFT_INSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.bossImage, self.line2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
end

function MonstorInvasionView:positionRichLabel()
	VisibleRect:relativePosition(self.richLabel, self:getContentNode(), LAYOUT_RIGHT_INSIDE, ccp(0, 0))	
	VisibleRect:relativePosition(self.richLabel, self.line2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
end	
