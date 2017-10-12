require("common.baseclass")
ActionEventHandler=ActionEventHandler or BaseClass()

--[[@
功能:	解除绑定事件
参数:	event_id事件id , event_func事件回调函数
返回值: 无
其它:	无
]]
function ActionEventHandler:UnBind(event_func,event_id)
	SFPriorityNotificationCenter:sharedPriorityNotificationCenter():removeObserver(event_func,event_id)
end
--[[@
功能:	绑定事件
参数:	event_id事件id , event_func事件回调函数
返回值: 无
其它:	无
]]
function ActionEventHandler:Bind(event_id, event_func)
	SFPriorityNotificationCenter:sharedPriorityNotificationCenter():addObserver(event_id,event_func)
end