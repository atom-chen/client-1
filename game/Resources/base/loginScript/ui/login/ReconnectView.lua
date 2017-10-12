--[[
断线重连的UI
]]

require("common.LoginBaseUI")
ReconnectView = ReconnectView or BaseClass(LoginBaseUI)

function ReconnectView:__init()
	self.viewSize = VisibleRect:getScaleSize(CCSizeMake(300, 130))
	self:SetSize(self.viewSize)
	local bg = createScale9SpriteWithFrameNameAndSize(RES("login_commom_editFrame.png"), self.viewSize)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode)
	
	self.labelTips = createLabelWithStringFontSizeColorAndDimension(Config.Words[350],"Arial",FSIZE("Size3"),FCOLOR("ColorBlack3"))
	self.rootNode:addChild(self.labelTips)
	VisibleRect:relativePosition(self.labelTips, self.rootNode, LAYOUT_CENTER, ccp(-30, 0))
	
	self.countSchedule = -1
end

function ReconnectView:__delete()
	self:endCountDown()
end

-- 设置剩余的时间
function ReconnectView:setLeftTime(time)
	if time and type(time) == "number" then
		local strTime = string.format(Config.Words[351], time)
		
		if not self.labelTime then
			self.labelTime = createLabelWithStringFontSizeColorAndDimension(strTime,"Arial",FSIZE("Size3"),FCOLOR("ColorBlack3"))
			self.rootNode:addChild(self.labelTime)
		else
			self.labelTime:setString(strTime)
		end
		
		if self.labelTips then
			VisibleRect:relativePosition(self.labelTime, self.labelTips, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
		end	
	end
end

-- 开始倒计时
function ReconnectView:startCountDown(time)
	self:endCountDown()
	
	if time and type(time) == "number" and time > 0 then
		self:setLeftTime(time)
		
		local leftTime = time
		local function timeoutCallback()
			leftTime = leftTime - 1
			if leftTime < 0 then
				self:endCountDown()
			else
				self:setLeftTime(leftTime)
			end
		end
		
		self.countSchedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeoutCallback, 1, false)
	end
end

function ReconnectView:endCountDown()
	if self.countSchedule ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.countSchedule)
		self.countSchedule = -1
	end
end