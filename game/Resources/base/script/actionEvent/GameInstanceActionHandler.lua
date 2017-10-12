require ("common.ActionEventHandler")
require ("gameevent.GameEvent")
require ("data.gameInstance.allIns_PK")

GameInstanceActionHandler = GameInstanceActionHandler or BaseClass(ActionEventHandler)

function GameInstanceActionHandler:__init()
	local gameInstanceList = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleG2C_GameInstanceList(reader)
	end
	
	local QuestAccepted = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readInstaneceQuestAccepted(reader)
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI,true)--显示任务
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_StrengthenQuest_UI)--显示变强任务		
	end
	
	local QuestUpdate = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readInstaneceQuestUpdate(reader)
		GlobalEventSystem:Fire(GameEvent.EventMainQuestUpdate)--解析任务更新
	end
	
	local QuestFinish = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readInstaneceQuestFinish(reader)
		GlobalEventSystem:Fire(GameEvent.EventMainQuestUpdate)--解析任务更新
	end
	
	local QuestReward = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readInstaneceReward(reader)
				
	end
	
	local InstanceLeave = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:readInstaneceLeave(reader)
	end
	
	local onInstanceFinished = function()
		local manager = GameWorld.Instance:getGameInstanceManager()
		manager:setIsInstanceFinished(true)
		G_getHandupMgr():stopWithPickup()
		
		manager:setZhenMoTaNPCArrow()		
		--如果在镇魔塔的最后一层，播放离开动画
		if true == manager:isInZhenMoTaLast() then   
			GlobalEventSystem:Fire(GameEvent.EventSetInstanceBtnAniamtion,true)
		end
		local instanceRefId = G_getQuestMgr():getInstanceRefId()
		if instanceRefId ~= "Ins_6" then
			manager:setFinishInstanceArrow("show")
		end
		GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FightView)
--		GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesFinishInstance()
		--		print("onInstanceFinished")
		--		UIManager.Instance:showSystemTips(Config.Words[1503])
		--showMsgBox(Config.Words[1509])
		
		G_getQuestLogicMgr():checkAllInstanceQuestFinish()--防止更新任务状态消息掉包，完成副本时检查所有任务状态
	end
	
	self:Bind(ActionEvents.G2C_GameInstanceList,gameInstanceList)
	self:Bind(ActionEvents.G2C_Instance_QuestAccepted,QuestAccepted)
	self:Bind(ActionEvents.G2C_Instance_QuestUpdate,QuestUpdate)
	self:Bind(ActionEvents.G2C_Instance_QuestFinish,QuestFinish)
	self:Bind(ActionEvents.G2C_Instance_QuestReward,QuestReward)
	self:Bind(ActionEvents.G2C_GameInstanceLeave,InstanceLeave)
	self:Bind(ActionEvents.G2C_Instance_Finished,onInstanceFinished)
	
	local sceneSwitchFunc = function ()
		--假PK停止挂机
		local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
		local instanceRefId = questMgr:getInstanceRefId()
		if GameData.AllIns_PK[instanceRefId] then
			local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
			if gameInstanceMgr:getIsInstanceFinished() then		
				--GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesFinishInstance()
				GlobalEventSystem:Fire(GameEvent.Event_SetFinishInstanceArrow,"show")
				GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.FightView)
			else
				showMsgBox(Config.Words[25100],E_MSG_BT_ID.ID_KNOW)
				GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.AutoFightView)		
				G_getHandupMgr():stop()
			end
			return					
		else
			GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainHeroHead","heroStatusBtn")
		end
		
		local unionInstanceMgr = GameWorld.Instance:getUnionInstanceMgr()		
		if unionInstanceMgr:IsUnionInstanceSceneRunning() and unionInstanceMgr:getIsFinish() then
			G_getHandupMgr():stop()
			return
		end	

		--自动挂机
		local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
		if self.doHandupInInstance==true and not gameInstanceMgr:getIsInstanceFinished() then
			G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
			self.doHandupInInstance=false
		end
	end
	
	GlobalEventSystem:Bind(GameEvent.EventGameSceneReady, sceneSwitchFunc)
end

--离开副本
function GameInstanceActionHandler:readInstaneceLeave()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	questMgr:removeQuestList()
	questMgr:removeInstanceRefId()
	questMgr:removeInstanceRewordList()
	G_getQuestLogicMgr():setOutInstanceDontDoQuest(true)
	G_getQuestMgr():requestQuestList()--发送任务列表请求
	
	local manager = GameWorld.Instance:getGameInstanceManager()
	manager:leaveInstance()

	GlobalEventSystem:Fire(GameEvent.EventExitUnionInstance)
	
	-- 请求变强任务
	--local strengthenQuestMgr = GameWorld.Instance:getEntityManager():getHero():getStrengthenQuestMgr()
	--strengthenQuestMgr:requestStrengthenQuest()
	
	self.doHandupInInstance = false
end

function GameInstanceActionHandler:handleG2C_GameInstanceList(reader)
	local manager = GameWorld.Instance:getGameInstanceManager()
	local lenght = StreamDataAdapter:ReadChar(reader)
	for i = 1,lenght do
		local refId = StreamDataAdapter:ReadStr(reader)
		local id = StreamDataAdapter:ReadStr(reader)
		local countDay = StreamDataAdapter:ReadChar(reader)  --int->byte
		local countWeek = StreamDataAdapter:ReadShort(reader)--int ->short
		if countDay >= 0 and not string.match(refId,"pk") then
			manager:addToList(id,refId,countDay,countWeek)
		end
	end
	GlobalEventSystem:Fire(GameEvent.EventGameInstanceViewUpdate)
	GameWorld.Instance:getStrongerMgr():setReady(StrongerChannel.Instance)
	GameWorld.Instance:getStrongerMgr():setReady(StrongerChannel.ZhengMoTa)
end

--副本任务
function GameInstanceActionHandler:readInstaneceQuestAccepted(reader)
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	questMgr:removeQuestList()
	
	local gameInstanceMgr = GameWorld.Instance:getGameInstanceManager()
	gameInstanceMgr:setIsInstanceFinished(true)
	
	local instanceRefId = StreamDataAdapter:ReadStr(reader)
	local ListCountVale = reader:ReadChar()
	questMgr:setInstanceRefId(instanceRefId)
	for i=1,ListCountVale do
		local questObj = QuestObj.New()
		
		local questId = StreamDataAdapter:ReadStr(reader)
		local questState = reader:ReadChar()
		local orderNumber = reader:ReadChar()
		
		if questState ~= QuestState.eSubmittableQuestState then
			if questState ~= QuestState.eCompletedQuestState then
				gameInstanceMgr:setIsInstanceFinished(false)
			end
		end
		
		questObj:setQuestId(questId)
		questObj:setQuestState(questState)
		questObj:setOrderNumber(orderNumber)
		questObj:setQuestType(QuestType.eQuestTypeInstance)
		
		for i=1,orderNumber do
			local orderType = reader:ReadChar()
			local number = reader:ReadInt()
			local time = reader:ReadInt()
			
			questObj:setOrderType(i,orderType)
			questObj:setNumber(i,number)
			questObj:setTime(time)
		end
		questMgr:setQuestList(questObj)
		--questMgr:addInatanceQueset()
	end
	if gameInstanceMgr:getIsInstanceFinished() then
		G_getHandupMgr():stop()		
	end
	self.doHandupInInstance = true
	G_getQuestLogicMgr():killAllAutoFindPath()
	
	--假PK显示新手指引
	if gameInstanceMgr:getIsInstanceFinished()==false then
		local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
		local instanceRefId = questMgr:getInstanceRefId()
		if GameData.AllIns_PK[instanceRefId] then
			GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesChosePKState()--执行点击PK状态的引导 --todo				
		end
	end
	
	if instanceRefId == "Ins_pk2" then
		GlobalEventSystem:Fire(GameEvent.EventShowPKGuidView)					
end
end

function GameInstanceActionHandler:readInstaneceQuestUpdate(reader)
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local questId = StreamDataAdapter:ReadStr(reader)
	local orderNumber = reader:ReadChar()
	local instanId = questMgr:getInstanceRefId()
	
	local questObj = questMgr:getQuestObj(questId)
	if not self:checkQuestObj(questObj) then
		return
	end
	questObj:setOrderNumber(orderNumber)
	
	for i=1,orderNumber do
		local number = reader:ReadInt()
		local time = reader:ReadInt()
		questObj:setNumber(i,number)
		G_getQuestLogicMgr():stateSystemTip(questId,number,instanId)
	end
end

function GameInstanceActionHandler:readInstaneceQuestFinish(reader)
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local questId = StreamDataAdapter:ReadStr(reader)
	local rewardType = reader:ReadChar()
	
	local instanceId = questMgr:getInstanceRefId()
	if rewardType == GameInstancerewardType.leave then--离开发奖
		if instanceId then
			local questName = QuestInstanceRefObj:getStaticQusetPropertyQuestName(instanceId,questId)
			if questName then
				local tipsWords = string.format("%s%s",Config.Words[15012],questName)
				UIManager.Instance:showSystemTips(tipsWords)
			end
		end
		
		--UIManager.Instance:showSystemTips(Config.Words[3113])
	elseif rewardType == GameInstancerewardType.immediate then--即时发奖
		if instanceId then
			local questName = QuestInstanceRefObj:getStaticQusetPropertyQuestName(instanceId,questId)
			if questName then
				local tipsWords = string.format("%s%s",Config.Words[15012],questName)
				UIManager.Instance:showSystemTips(tipsWords)
			end
			
			--属性奖励
			local propertyReward = QuestRefObj:getStaticQusetRewardProperty(QuestType.eQuestTypeInstance,questId,instanceId)
			if propertyReward~=nil then
				for j,v in pairs(propertyReward) do
					local itemRefId = j
					local itemCount = v
					local propertyRewardName = G_getStaticUnPropsName(itemRefId)
					UIManager.Instance:showSystemTips(propertyRewardName.."+"..itemCount,nil,nil,nil,nil,E_TipsType.fight,false)
				end
			end
			--道具奖励
			local itemReward = QuestRefObj:getStaticQusetItemReward(QuestType.eQuestTypeInstance,questId,instanceId)
			if itemReward~=nil then
				for l,v in pairs(itemReward) do
					local tItemList = v
					local itemCount = QuestRefObj:getStaticQusetItemListItemCount(tItemList)
					local itemRefId = QuestRefObj:getStaticQusetItemListItemRefId(tItemList)
					if  itemRefId and itemCount then
						local propertyRewardName
						local itemStaticData = G_getStaticDataByRefId(itemRefId)
						if itemStaticData and  itemStaticData.property then
							propertyRewardName = PropertyDictionary:get_name(itemStaticData.property)
						end	
						if  propertyRewardName then
							UIManager.Instance:showSystemTips(propertyRewardName.."+"..itemCount,nil,nil,nil,nil,E_TipsType.fight,false)
						end
					end
				end
			end
		end
	end
	--G_getQuestNPCStateMgr():setUpdateNpcQuestState(questId,QuestState.eCompletedQuestState)
	local questObj = questMgr:getQuestObj(questId)
	if not self:checkQuestObj(questObj) then
		return
	end
	questObj:setQuestState(QuestState.eSubmittableQuestState)
	questMgr:instanceSortList()
end


function GameInstanceActionHandler:readInstaneceReward(reader)
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local passInstanceTime = reader:ReadULLong()
	local bInBag = reader:ReadChar()
	local orderNumber = reader:ReadChar()
	local rewordList = {}
	for i=1,orderNumber do
		local questId = StreamDataAdapter:ReadStr(reader)
		table.insert(rewordList,questId)
	end
	questMgr:setInstanceRewordList(bInBag,rewordList,passInstanceTime)
	
	if tonumber(orderNumber)>0 and (not GameWorld.Instance:getUnionInstanceMgr():IsUnionInstanceSceneRunning()) then
		GlobalEventSystem:Fire(GameEvent.EventGameInstanceQuestViewOpen)
	else
		local exitFunction = function(arg,text,id)
			if id == 2 then	
				local manager = GameWorld.Instance:getGameInstanceManager()
				manager:requestLeaveGameInstance()
				--manager:leaveInstance()
			end
		end

		local msg = showMsgBox(Config.Words[15022],E_MSG_BT_ID.ID_CANCELAndOK)	
		msg:setNotify(exitFunction)
	end	
end

--检查任务对象是否存在
function GameInstanceActionHandler:checkQuestObj(obj)
	if not obj then
		GameWorld.Instance:getEntityManager():getHero():getQuestMgr():requestInstanceQuestList()
		return false
	end
	return true
end
