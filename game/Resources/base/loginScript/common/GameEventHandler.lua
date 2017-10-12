require("common.baseclass")

GameEventHandler = GameEventHandler or BaseClass()

function GameEventHandler:Bind(event_name, event_func)
	return GlobalEventSystem:Bind(event_name,event_func)
end
--[[@
功能:	解除绑定事件
参数:	事件的handler
返回值: 无
其它:	无
]]
function GameEventHandler:UnBind( obj )
	GlobalEventSystem:UnBind( obj )
end
--[[@
功能:	立即触发事件
参数:	绑定的id，绑定的函数
返回值: 绑定的id，传递的参数
其它:	无
]]
function GameEventHandler:Fire(event_name,...)
	GlobalEventSystem:Fire( event_name ,...)
end	