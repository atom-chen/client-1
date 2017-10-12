require("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require("object.quest.QuestObj")
require("object.quest.QuestDef")
require("utils.GameUtil")

QuestActionHandle = QuestActionHandle or BaseClass(ActionEventHandler)

function QuestActionHandle:__init()
	--self.hadShowView = false
		
	self:initMainQuest()
	self:initDailyQuest()
end	

--主线任务
function QuestActionHandle:initMainQuest()
	local AcceptedQuestList = function(reader)	
		reader = tolua.cast(reader,"iBinaryReader")
		self:readMainAcceptedList(reader)
	end
	
	local QuestVisibleEvent = function (reader)	
		reader = tolua.cast(reader,"iBinaryReader")
		self:readMainVisibleEvent(reader)
	end
	
	local StateUpdate = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readMainStateUpdate(reader)
	end
	
	local QuestUpdate = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readMainQuestUpdate(reader)
	end
	
	self:Bind(ActionEvents.G2C_QST_QuestAcceptedList,AcceptedQuestList)
	self:Bind(ActionEvents.G2C_QST_QuestVisibleList,QuestVisibleEvent)
	self:Bind(ActionEvents.G2C_QST_StateUpdate,StateUpdate)
	self:Bind(ActionEvents.G2C_QST_QuestUpdate,QuestUpdate)
end

function QuestActionHandle:readMainAcceptedList(reader)--解析任务列表
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()		
	local ListCountVale = reader:ReadChar()
	local questId = nil
	local questState = nil
	local needTrans = false	
	local transScene = nil
	for i=1,ListCountVale do
		questId = StreamDataAdapter:ReadStr(reader)
		questState = reader:ReadChar()
		local orderNumber = reader:ReadChar()
				
		local questObj = questMgr:getMainQuestObj()
		if not questObj then
			questObj = QuestObj.New()
			questMgr:setQuestList(questObj)
		end
		
		questObj:setQuestId(questId)
		questObj:setQuestState(questState)
		questObj:setOrderNumber(orderNumber)
		questObj:setQuestType(QuestType.eQuestTypeMain)

		for i=1,orderNumber do
			local valueNumber = reader:ReadInt()
			questObj:setNumber(i,valueNumber)
		end
	end	
	questMgr:sortList()
	G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
	if questState == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交
		G_getQuestLogicMgr():AutoCompleteQuest(questId)--自动弹框完成任务		
	end
		
	if questId then
		questMgr:cancleReApply()--取消重新申请任务
	end
		
	if G_getQuestLogicMgr():getIsFirstDoQuest() and questMgr:getOldMainAcceptQuestId() ~= questId then
		local parentNode = UIManager.Instance:getDialogRootNode()
		GameUtil:createAnimateAndAction(parentNode, "acceptQuest_", 4, 0.1, 0, true)
		questMgr:setOldMainAcceptQuestId(questId)
	end
		
	G_getQuestLogicMgr():doMainQuestWithInstanceEvent(questId,questState)
		
	--[[if questId  == "quest_51" and not self.hadShowView then
		GlobalEventSystem:Fire(GameEvent.EventShowPKGuidView)	
		self.hadShowView = true				
	end	--]]
end

function QuestActionHandle:readMainVisibleEvent(reader)--解析可增任务
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local ListCountVale = reader:ReadChar()
	local questId = nil
	local state = nil
	for i=1,ListCountVale do	
		questId = StreamDataAdapter:ReadStr(reader)
		local isAccept = G_getQuestLogicMgr():getAcceptNowQuest()
		state = G_getQuestLogicMgr():getquestState(isAccept,QuestType.eQuestTypeMain,questId)
		--local questObj = QuestObj.New()
		local questObj = questMgr:getMainQuestObj()
		if not questObj then
			questObj = QuestObj.New()
			questMgr:setQuestList(questObj)
		end
		questObj:setQuestId(questId)		
		questObj:setQuestState(state)
		questObj:setQuestType(QuestType.eQuestTypeMain)
		--questMgr:setQuestList(questObj)
		questMgr:sortList()
		G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
	end
	GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
	G_getQuestLogicMgr():autoDoQuest(questId,state)
	
	if questId then
		questMgr:cancleReApply()--取消重新申请任务
	end
end


function QuestActionHandle:readMainStateUpdate(reader)--解析任务状态更新
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local instanceRefId = questMgr:getInstanceRefId()
	if instanceRefId then
		return
	end
	local questId = StreamDataAdapter:ReadStr(reader)
	local questState = reader:ReadChar()	
	local questObj = questMgr:getQuestObj(questId)
	if questObj then
		if questState == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交
			local oldquestState = questObj:getQuestState()
			if oldquestState ~= questState then
				G_getQuestLogicMgr():AutoCompleteQuest(questId)--自动弹框完成任务
				questObj:setQuestState(questState)
				G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
				G_getQuestLogicMgr():AutoPathFindNpc(questId)
			end
			
		elseif questState == QuestState.eCompletedQuestState then--任务已完成	
			questObj:setQuestState(questState)
			G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
			G_getQuestLogicMgr():setAcceptNextQuest(QuestType.eQuestTypeMain,questId)
			questMgr:removeQuest(questId)--删除任务
			--UIManager.Instance:showSystemTips(Config.Words[3113])
			
			if questMgr:getOldMainFinishQuestId() ~= questId then
				local parentNode = UIManager.Instance:getDialogRootNode()
				GameUtil:createAnimateAndAction(parentNode, "finishQuest_", 4, 0.1, 0)
				local soundMgr = GameWorld.Instance:getSoundMgr()
				soundMgr:playEffect("music/celebrate.mp3" , false)
				questMgr:setOldMainFinishQuestId(questId)
			end	
		else
			G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
			questObj:setQuestState(questState)
		end
		
		G_getQuestLogicMgr():doMainQuestWithInstanceEvent(questId,questState)
	end
end

function QuestActionHandle:readMainQuestUpdate(reader)--解析任务更新
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local questId = StreamDataAdapter:ReadStr(reader)
	local orderNumber = reader:ReadChar()
	
	local questObj = questMgr:getQuestObj(questId)
	if questObj then
		questObj:setOrderNumber(orderNumber)

		for i=1,orderNumber do
			local number = reader:ReadInt()
			if questObj:getNumber(i)~=number then
				questObj:setNumber(i,number)
				G_getQuestLogicMgr():stateSystemTip(questId,number)		
				break	
			end
		end		

		GlobalEventSystem:Fire(GameEvent.EventMainQuestUpdate)	
	else		
		CCLuaLog("Invalide QuestId : " .. questId)
	end	
end

-----------------------------------------------------------------------------------------
--日常任务
function QuestActionHandle:initDailyQuest()
	local DailyAcceptedQuestList = function(reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readDailyAcceptedList(reader)
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)--刷新主界面	
	end
	
	local DailyQuestVisibleEvent = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readDailyVisibleEvent(reader)
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
	end
	
	local DailyStateUpdate = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readDailyStateUpdate(reader)
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
	end
	
	local DailyQuestUpdate = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readDailyQuestUpdate(reader)
	end
	
	local DailyStartLevel = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readDailyStartLevel(reader)
	end
	
	self:Bind(ActionEvents.G2C_QST_DailyQuestAcceptedList,DailyAcceptedQuestList)
	self:Bind(ActionEvents.G2C_QST_DailyQuestVisibleList,DailyQuestVisibleEvent)
	self:Bind(ActionEvents.G2C_QST_DailyStateUpdate,DailyStateUpdate)
	self:Bind(ActionEvents.G2C_QST_DailyQuestUpdate,DailyQuestUpdate)
	self:Bind(ActionEvents.G2C_QST_DailyStartLevel,DailyStartLevel)
end

function QuestActionHandle:readDailyAcceptedList(reader)--解析任务列表
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local ListCountVale = reader:ReadChar()
	for i=1,ListCountVale do	
		local questId = StreamDataAdapter:ReadStr(reader)
		local dailyRing = reader:ReadShort() --int->short
		local dailyLevel = reader:ReadChar()
		local questState = reader:ReadChar()
		local orderNumber = reader:ReadChar()
				
		local oldstate = questMgr:getQuestObjState(questId)
		if oldstate and questState ~= oldstate then
			local parentNode = UIManager.Instance:getDialogRootNode()
			GameUtil:createAnimateAndAction(parentNode, "acceptQuest_", 4, 0.1, 0, true)
			local soundMgr = GameWorld.Instance:getSoundMgr()
			soundMgr:playEffect("music/celebrate.mp3" , false)						
		end				
		
		local questObj = questMgr:getQuestObj(questId)
		if not questObj then
			questObj = QuestObj.New()
			questMgr:setQuestList(questObj)
		end
		
		questObj:setQuestId(questId)
		questObj:setDailyQuestType(QuestRefObj:getStaticDailyQusetRepeatType(questId))
		questObj:setQuestType(QuestType.eQuestTypeDaily)
		questObj:setDailyRing(dailyRing)
		questObj:setDailyLevel(dailyLevel)
		questObj:setQuestState(questState)
		questObj:setOrderNumber(orderNumber)
		questObj:setDailyQuestSubType(questId)
		questMgr:sortList()
		for i=1,orderNumber do
			local randomOrderType = reader:ReadChar()+1
			local valueNumber = reader:ReadShort()  --int->short
			
			questObj:setRandomOrderType(randomOrderType)
			questObj:setNumber(randomOrderType,valueNumber)
		end
		
		G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)
		if questState == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交
			G_getQuestLogicMgr():AutoCompleteQuest(questId)--自动弹框完成任务
		end
		
		if questId then
			questMgr:cancleReApply()--取消重新申请任务
		end
	end
end

function QuestActionHandle:readDailyVisibleEvent(reader)--解析可增任务
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local ListCountVale = reader:ReadInt()
	
	for i=1,ListCountVale do	
		local questId = StreamDataAdapter:ReadStr(reader)
		local dailyRing = reader:ReadInt()
		local dailyLevel = reader:ReadChar()
		local questObj = QuestObj.New()
		questObj:setQuestId(questId)
		questObj:setDailyQuestType(QuestRefObj:getStaticDailyQusetRepeatType(questId))
		questObj:setQuestType(QuestType.eQuestTypeDaily)
		questObj:setDailyLevel(dailyLevel)
		questObj:setDailyRing(dailyRing + 1) -- 健圻的需求  日常任务环数显示
		questObj:setQuestState(QuestState.eAcceptableQuestState)
		questObj:setDailyQuestSubType(questId)
		
		questMgr:setQuestList(questObj)
		questMgr:sortList()
		G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)--更改NPC状态	
		
		if questId then
			questMgr:cancleReApply()--取消重新申请任务
		end
	end
end


function QuestActionHandle:readDailyStateUpdate(reader)--解析任务状态更新
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	if not questMgr then
		return
	end
	local questId = StreamDataAdapter:ReadStr(reader)
	local questState = reader:ReadChar()	
	local questObj = questMgr:getQuestObj(questId)
	if not QuestObj then
		return
	end
	if questState == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交	
		questObj:setQuestState(questState)
		G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)--更改NPC状态
		G_getQuestLogicMgr():AutoCompleteQuest(questId)--自动弹框完成任务
		G_getQuestLogicMgr():AutoPathFindNpc(questId)
		questMgr:sortList()
	elseif questState == QuestState.eCompletedQuestState then--任务已完成	
		questObj:setQuestState(questState)
		G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId)--更改NPC状态	
		questMgr:removeQuest(questId)--删除任务
		--UIManager.Instance:showSystemTips(Config.Words[3113])		
		
		local parentNode = UIManager.Instance:getDialogRootNode()
		GameUtil:createAnimateAndAction(parentNode, "finishQuest_", 4, 0.1, 0)						
	else
		questObj:setQuestState(questState)
	end
end

function QuestActionHandle:readDailyQuestUpdate(reader)--解析任务更新
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local questId = StreamDataAdapter:ReadStr(reader)
	local orderNumber = reader:ReadChar()
	
	local questObj = questMgr:getQuestObj(questId)
	if questObj then
		questObj:setOrderNumber(orderNumber)
		for i=1,orderNumber do
			local randomOrderType = reader:ReadChar()+1
			local numbervalue = reader:ReadInt()
			questObj:setNumber(randomOrderType,numbervalue)
			G_getQuestLogicMgr():stateSystemTip(questId,numbervalue)
		end	
		GlobalEventSystem:Fire(GameEvent.EventMainQuestUpdate)--解析任务更新
	end

end

function QuestActionHandle:readDailyStartLevel(reader)--解析任务等级更新
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local questId = StreamDataAdapter:ReadStr(reader)	
	local dailyLevel = reader:ReadChar()
	local questObj = questMgr:getQuestObj(questId)
	questObj:setDailyLevel(dailyLevel)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateNPCQuestLevel,questId)--刷新日常任务等级
	GlobalEventSystem:Fire(GameEvent.EventUpdateQuestLevel,questId)--刷新日常任务等级
end	
