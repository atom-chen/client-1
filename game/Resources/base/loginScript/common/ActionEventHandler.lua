require("common.baseclass")
ActionEventHandler=ActionEventHandler or BaseClass()

--[[@
����:	������¼�
����:	event_id�¼�id , event_func�¼��ص�����
����ֵ: ��
����:	��
]]
function ActionEventHandler:UnBind(event_func,event_id)
	SFPriorityNotificationCenter:sharedPriorityNotificationCenter():removeObserver(event_func,event_id)
end
--[[@
����:	���¼�
����:	event_id�¼�id , event_func�¼��ص�����
����ֵ: ��
����:	��
]]
function ActionEventHandler:Bind(event_id, event_func)
	SFPriorityNotificationCenter:sharedPriorityNotificationCenter():addObserver(event_id,event_func)
end