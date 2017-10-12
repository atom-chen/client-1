--[[
启动一个一次性的Schedule
]]

ScheduleObject = ScheduleObject or BaseClass()

--[[ func: 回调执行函数
delay:	延时
]]
function ScheduleObject:__init(func, delay)
	self.func = func
	self.scheduleId = -1
	
	self:startSchedule(self.func, delay)
end

function ScheduleObject:__delete()
	self:stopSchedule()
end

function ScheduleObject:create(func, delay)
	if func and delay then
		return ScheduleObject.New(func, delay)
	else
		return nil
	end
end

function ScheduleObject:startSchedule(func, delay)
	if not func or self.scheduleId ~= -1 then
		return
	end
	
	if not delay then
		delay = 0
	end
	
	local function callback()
		func()
		self:stopSchedule()
	end

	self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, delay, false)
end

function ScheduleObject:stopSchedule()
	if self.scheduleId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 1
	end
end