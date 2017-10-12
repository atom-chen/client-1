require ("gameevent.GameEvent")
require ("ui.UIManager")
require("ui.quest.QuestView")
QuestUIHandler = QuestUIHandler or BaseClass(GameEventHandler)

function QuestUIHandler:__init()
	local eventEnterQuest = function ()
		
		UIManager.Instance:registerUI("QuestView",QuestView.create)
		UIManager.Instance:showUI("QuestView")	
	end
	--更新接口
	local function eventQuestUpdatefunc()
		
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:onEventQuestUpdate()
		end	
		
		local view1 = manager:getViewByName("QuestView")
		if view1 then
			view1:updateOrder()
		end			
	end
		
	local function eventQuestshowfunc(instance)
		
		local manager =UIManager.Instance
		local view = manager:getMainView()
		if view then
			view:onEventQuestshow(instance)
		end	
		
		local view1 = manager:getViewByName("QuestView")
		if view1 then
			view1:updateQuestView()
		end			
	end
	
	local function eventUpdateQuestLevelfunc(questId)
		
		local manager =UIManager.Instance
		local view = manager:getViewByName("QuestView")
		if view then
			view:EventUpdateQuestLevel()
		end	
	end
	
	local function eventCloseQuestViewfunc()
		
		local manager =UIManager.Instance
		local view = manager:getViewByName("QuestView")
		if view then
			manager:hideUI("QuestView")
		end
	end
	
	local function UpdateStrengthenQuest()
		
		local manager =UIManager.Instance
		local view = manager:getViewByName("QuestView")
		if view then
			view:updateQuestView()
		end	
	end

	local eventHandleErroCode = function(msgId, errorCode)
		if msgId == ActionEvents.C2G_Scene_StarttoPluck  then 
			if errorCode == 0x8000032A then	
				G_getHandupMgr():stop()
				UIManager.Instance:showSystemTips(Config.Words[3314])
			elseif errorCode == 0x80000263 or errorCode == 0x8000025B then	
				GlobalEventSystem:Fire(GameEvent.EVENT_GET_QUESTLIST)--发送任务列表请求
			end
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventErrorCode, eventHandleErroCode)	
	GlobalEventSystem:Bind(GameEvent.EVENT_Quest_UI, eventEnterQuest)	
	GlobalEventSystem:Bind(GameEvent.EventMainQuestUpdate, eventQuestUpdatefunc)
	GlobalEventSystem:Bind(GameEvent.EVENT_Main_Quest_UI,eventQuestshowfunc)	
	GlobalEventSystem:Bind(GameEvent.EventUpdateQuestLevel, eventUpdateQuestLevelfunc)
	GlobalEventSystem:Bind(GameEvent.EventCloseQuestView, eventCloseQuestViewfunc)
	GlobalEventSystem:Bind(GameEvent.EVENT_Main_StrengthenQuest_UI,UpdateStrengthenQuest)
	
end

function QuestUIHandler:__delete()

end
