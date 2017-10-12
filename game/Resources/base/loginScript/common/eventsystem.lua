require("common.baseclass")
require("common.event")

EventSystem = EventSystem or BaseClass()

--事件系统(非单健)
function EventSystem:__init()
	--事件列表
	self.event_list = {}	
end	

function EventSystem:Bind(event_name, event_func)
	if event_name == nil then
		CCLuaLog("Try to bind to a nil event_name")
		return
	end

	if self.is_deleted then
		return
	end

	if self.event_list[event_name] == nil then
		self:CreateEvent(event_name)
	end
	local tmp_event = self.event_list[event_name]
	
	return tmp_event:Bind(event_func)
end

function EventSystem:UnBind(event_handle)
	if event_handle == nil or event_handle.event_name == nil then
		CCLuaLog("Try to unbind a nil event_name")
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_handle.event_name]
	if tmp_event ~= nil then
		tmp_event:UnBind(event_handle)
	end
end

--立即触发
function EventSystem:Fire(event_name, ...)
	if event_name == nil then
		error("Try to call EventSystem:Fire() with a nil event_name")
		return
	end


	if self.is_deleted then
		return
	end
	
	local tmp_event = self.event_list[event_name] 
	if tmp_event ~= nil then
		tmp_event:Fire({...})
	end
end		

function EventSystem:CreateEvent(event_name)
	self.event_list[event_name] = Event.New(event_name)
end	

