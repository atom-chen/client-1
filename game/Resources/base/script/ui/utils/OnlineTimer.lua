require("object.activity.ActivityDef")

OnlineTimer = OnlineTimer or BaseClass(BaseObj)

local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(10,10)

G_DoTimer = {
	add = 1,--计时+1
	minus = 2,--计时-1
}

G_TimerState = {
	normal = 1,--正常
	reward = 2,--领奖
}

function OnlineTimer:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()
	
	self.text = createLabelWithStringFontSizeColorAndDimension("00:00","Arial", FSIZE("Size2") * const_scale, FCOLOR("White1"))
	self.rootNode:addChild(self.text)
	VisibleRect:relativePosition(self.text,self.rootNode,LAYOUT_CENTER)
	
	self.rebackTime = nil
	self.reBackFunc = nil
	self.checktimeList = {}
	--self.sameTimeRebackFunc = nil
	self.rebackonlineTimerId = -1
	self.timerState = G_TimerState.normal
end

function OnlineTimer:__delete()
	self:killTimer()
end

function OnlineTimer:getRootNode()
		return self.rootNode
end

function OnlineTimer:setColor(color)
	if self.text then
		self.text:setColor(color)
	end
end

function OnlineTimer:setSize(size)
	if self.text then
		self.text:setFontSize(size)
	end
end

--设置定时器状态
function OnlineTimer:setTimerState(state)
	self.timerState = state
	if self.text then
		if self.timerState==G_TimerState.normal then
			local time = self:analyticalTimeTime()			
			self.text:setString(time)
		elseif self.timerState==G_TimerState.reward then
			self.text:setString(Config.Words[3121])
		end
	end
end

--启动计时器
function OnlineTimer:setTimer(refid,reBackFunc,doTimer,rebackTime,timeList)	--用于添加倒计时标签
	if rebackTime then
		if rebackTime==0 and doTimer == G_DoTimer.minus  then
			self.rebackTime = rebackTime
			return
		end

		self.rebackTime = rebackTime	
		
		if timeList then
			self.checktimeList = timeList
		end
		
		if reBackFunc then
			self.reBackFunc = reBackFunc
		end
		
		local time = self:analyticalTimeTime()			
		self.text:setString(time)
		
		if self.reBackonlineTimerFunc == nil then
			self.reBackonlineTimerFunc = function ()	
				if self.timerState==G_TimerState.normal then
					self:CalculationTime(doTimer)
					local time = self:analyticalTimeTime()
					self.text:setString(time)	
					self:checkSameTime(refid)			
					if self.rebackTime == 0 then
						if self.rebackonlineTimerId ~= -1 then
							CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackonlineTimerId)
							self.rebackonlineTimerId = -1
							self:rebackFunc(self.reBackFunc,refid,self.rebackTime)
						end
					end
				end	
			end
		end
		self.rebackonlineTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.reBackonlineTimerFunc, 1, false)
	end	
end	

function OnlineTimer:killTimer()
	if self.text then
		self.text:removeFromParentAndCleanup(false)
		self.text = nil
	end
	
	if self.rebackonlineTimerId ~= -1  then	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.rebackonlineTimerId)
		self.rebackonlineTimerId = -1
	end
	self.rootNode:release()
end

--计算时间
function OnlineTimer:CalculationTime(doTimer)
	if doTimer == G_DoTimer.minus  then
		self.rebackTime = self.rebackTime - 1
	elseif	doTimer == G_DoTimer.add  then
		self.rebackTime = self.rebackTime + 1
	end
end

--解析时间
function OnlineTimer:analyticalTimeTime()
	
	local time = "00:00"
	if self.rebackTime then			
		
		local s_sec,s_min,s_hour = G_GetSecondsToDateString(self.rebackTime)
		
		if s_hour ~= "00" then
			time = s_hour..":"..s_min..":"..s_sec
		else
			time = s_min..":"..s_sec
		end	
	end
	
	return time
end

--获取当前时间
function OnlineTimer:getNowTimer()
	return self.rebackTime
end

--回调函数
function OnlineTimer:rebackFunc(func,refid,time)
	func(refid,time)
end

--设置检测相同时间
function OnlineTimer:checkSameTime(refid)
	if table.size(self.checktimeList)~=0 and self.reBackFunc then
		if self.rebackTime then
			for i,v in pairs(self.checktimeList) do
				if self.rebackTime==v then
					self:rebackFunc(self.reBackFunc,refid,self.rebackTime)
					self.checktimeList[i] = nil
				end
			end
		end	
	end	
end