require("common.baseclass")
require("object.time.Action")
ActionScheduler = ActionScheduler or BaseClass()

function ActionScheduler:__init()
	self.actionList = {}
	self.count = 0
	self.scheduleId = nil
	self.isRunning = false
	self.tickCountMax = 5
end

function ActionScheduler:__delete()
	self:stop()
	self = nil
end

function ActionScheduler:clear()
	self:stop()
end

function ActionScheduler:addAction(object,selector)
	if self.scheduleId == nil then
		self:start()
	end
	local action = Action.New(object,selector)
	table.insert(self.actionList,action)
	self.count = self.count + 1
end


function ActionScheduler:tick()
	if self.isRunning then
		if self.count == 0 and self.scheduleId~= nil then
		self:stop()
		return		
		end
		local count = 0
		for k,v in pairs(self.actionList) do
			if count >= self.tickCountMax then
				break
			end
			v:run()
			self.actionList[k] = nil
			self.count = self.count -1
			count = count + 1
		end
	end		
end

function ActionScheduler:start()
	local tick = function ()
		self:tick()
	end
	if self.scheduleId == nil then
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)		
	end
	self.isRunning = true
end

function ActionScheduler:pause()
	self.isRunning = false
end

function ActionScheduler:resume()
	self.isRunning = true
end

function ActionScheduler:stop()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
	end		
	self.isRunning = false
	self.scheduleId = nil
end
