require("common.baseclass")
require("data.item.propsPurchase")

QuestLogicMgr = QuestLogicMgr or BaseClass()

function QuestLogicMgr:__init()
	self.flyinShoesTimerId = -1
	self.unFirstDoQuest = false
	self.bOutInstanceDontDoQuest = false
	self.isAcceptQuest = false
end

function QuestLogicMgr:__delete()
	self:clear()
end

function QuestLogicMgr:clear()
	self.unFirstDoQuest = false
	self.isAcceptQuest = false
	self:clearFlyinShoesScheduler()
end


--等级优先权
function QuestLogicMgr:levelPriority(a,b)
	if not a or not b then
		return false
	end
	local hero = GameWorld.Instance:getEntityManager():getHero()	
	local heroLevel = PropertyDictionary:get_level(hero:getPT())
	local aQuestId = a:getQuestId()
	local aQuestType = a:getQuestType()
	local bQuestId = b:getQuestId()	
	local bQuestType = b:getQuestType()
	local aAcceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(aQuestType,aQuestId)
	local bAcceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(bQuestType,bQuestId)
	local aMinus  = heroLevel-aAcceptLevel
	local bMinus  = heroLevel-bAcceptLevel
	
	if aMinus<0 then
		return false
	elseif bMinus<0 then
		return true
	else
		if aMinus>=bMinus then
			return false
		else
			return true
		end
	end
end

--自动打开NPC任务完成窗口
function QuestLogicMgr:AutoCompleteQuest(questId)
	if not questId then
		return
	end
	local obj = G_getQuestMgr():getQuestObj(questId)
	if obj~=nil then
		local questType = obj:getQuestType()
		
		-- 当前任务完成, 如果是购买类型的任务，要把商店的UI关闭
		local orderType, orderEvent = self:getUpGradeInfo(questType, questId)
		if orderType == QuestOrderType.eOrderTypeTime and orderEvent == QuestOrderEventType.eShopEvent then
			UIManager.Instance:hideUI("ShopView")
		end
	
		local questState = obj:getQuestState()
		local submitNpcId =  QuestRefObj:getStaticQusetNpcFieldNcRefId(questType,questId,"submitNpc")
		
		if submitNpcId==nil and questState == QuestState.eSubmittableQuestState then
			if questType==QuestType.eQuestTypeMain or questType==QuestType.eQuestTypeDaily or questType == QuestType.eQuestTypeStrengthen then
				--self:setNpcTalkViewInfo(submitNpcId,obj)
				local arglist = {npcRefId=submitNpcId,questObj=obj}
				GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
			end
		end
	end
end	

--杀完怪返回NPC提交任务
function QuestLogicMgr:AutoPathFindNpc(questId)
	if not questId then
		return
	end
	local function callBlack()
		if G_getHandupMgr():isHandup() then
			local function stopcallBlack(stopquestId)
				if stopquestId == questId then
					self:doAutoPathFindNpc(stopquestId)					
				end
			end
			G_getHandupMgr():stopWithPickup(stopcallBlack,questId)
		else
			self:doAutoPathFindNpc(questId)
		end
	end
	local action = BaseActionPlayer.New()
	action:setMaxPlayingDuration(0.1)
	action:addStopNotify(callBlack)
	ActionPlayerMgr.Instance:addPlayer(G_getHero():getId(), action)
end


--自动寻Npc
function QuestLogicMgr:doAutoPathFindNpc(questId)
	if not questId then
		return 
	end

	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
	self.AutoQuestObj = G_getQuestMgr():getQuestObj(questId)
	if self.AutoQuestObj then
		self.AutoquestState = self.AutoQuestObj:getQuestState()
		self.questRefId = questId
		self.questType = self.AutoQuestObj:getQuestType()
		local qType = self.AutoQuestObj:getQuestType()
		
		if self.AutoquestState == QuestState.eAcceptableQuestState then --任务可接
			if QuestRefObj:getStaticQusetNpcField(qType,questId) ~= nil then
				self.AutoNpcRefId =  QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,"acceptNpc")
				self.SceneRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,"acceptNpc")
			end
		elseif self.AutoquestState == QuestState.eAcceptedQuestState then --任务已接，但未完成
			UIManager.Instance:showSystemTips(Config.Words[3155])
		elseif self.AutoquestState == QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
			if QuestRefObj:getStaticQusetNpcField(qType,questId) ~= nil then
				self.AutoNpcRefId =  QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,"submitNpc")
				self.SceneRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,"submitNpc")
			end
		end
		
		local bOpen  = self:IsNearNPC(self.SceneRefId,self.AutoNpcRefId)
		if bOpen then
			local state = self.AutoQuestObj:getQuestState()
			if state==QuestState.eAcceptableQuestState or state==QuestState.eSubmittableQuestState then
				--self:setNpcTalkViewInfo(self.AutoNpcRefId,self.AutoQuestObj)
				local arglist = {npcRefId=self.AutoNpcRefId,questObj=self.AutoQuestObj}
				GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
				return
			end
		end
		
		local function AutoEvent(stateType, id)
			if self.autoPathFindNpcCallBackId and self.autoPathFindNpcCallBackId == id then
				if stateType == AutoPathState.stateRun then
					local bIsOpen  = self:IsNearNPC(self.SceneRefId,self.AutoNpcRefId)
					if bIsOpen then
						local questObj = G_getQuestMgr():getQuestObj(self.questRefId)
						if questObj then
							local state = questObj:getQuestState()						
							if state and (state==QuestState.eAcceptableQuestState or state==QuestState.eSubmittableQuestState) then
								--self:setNpcTalkViewInfo(self.AutoNpcRefId,self.AutoQuestObj)
								local arglist = {npcRefId=self.AutoNpcRefId,questObj=self.AutoQuestObj}
								GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
							end
							AutoPathMgr:unRegistCallBack(self.autoPathFindNpcCallBackId)
						end
						
					end
				end
			end
		end
		
		if self.AutoNpcRefId~=nil then
			self:killAllAutoFindPath()
			self.autoPathFindNpcCallBackId = AutoPathMgr:registCallBack(AutoEvent)
			AutoPathMgr:find(self.AutoNpcRefId,self.SceneRefId,true)			
		else
			self:AutoCompleteQuest(questId)
		end
	else
		CCLuaLog("Error: AutoPathFindNpc self.AutoQuestObj is nil")
	end		
end	

--判断人物是否在npc旁边
function QuestLogicMgr:IsNearNPC(sceneRefId,npcRefId)
	if (not sceneRefId) or (not npcRefId) then
		return false
	end
	
	local bisNear = false
	local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()	
	if  currentMapRefId==sceneRefId then	
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
		local HeroPosX,HeroPosY = hero:getCellXY()
		local NpcPosX,NpcPosY = AutoPathMgr:findNpcXY(npcRefId,sceneRefId)
		local boxSize = 10
		if NpcPosX~=nil and NpcPosY~=nil then
			if NpcPosX>=(HeroPosX-boxSize) and NpcPosY<=(HeroPosY+boxSize) and NpcPosX<=(HeroPosX+boxSize) and NpcPosY>=(HeroPosY-boxSize)  then
				bisNear = true
			end
		end
	end
	return bisNear
end

function QuestLogicMgr:killAllAutoFindPath()
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()	
	if self.autoPathFindNpcCallBackId then
		AutoPathMgr:unRegistCallBack(self.autoPathFindNpcCallBackId)
		self.autoPathFindNpcCallBackId = nil
	end	
	if self.autoPathFindSceneHandupCallBackId then
		AutoPathMgr:unRegistCallBack(self.autoPathFindSceneHandupCallBackId)
		self.autoPathFindSceneHandupCallBackId = nil
	end		
end

--自动寻场景挂机
function QuestLogicMgr:AutoRecommendHandup(sceneId,pos)
	if (not sceneId) or (not pos) then
		return false
	end
	
	self:KillAllAction()
	self:killAllAutoFindPath()
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()
	
	local function AutoEvent(stateType, id)
		if self.autoPathFindSceneHandupCallBackId and self.autoPathFindSceneHandupCallBackId == id then
			if stateType == AutoPathState.stateRun then
				local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()
				if currentMapRefId and sceneId==currentMapRefId then
					AutoPathMgr:unRegistCallBack(self.autoPathFindSceneHandupCallBackId)					
					G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
				end
			end
		end
	end
	self.autoPathFindSceneHandupCallBackId = AutoPathMgr:registCallBack(AutoEvent)	
	AutoPathMgr:moveToWithCallBack(pos.x,pos.y,sceneId)
end


function QuestLogicMgr:handOrderEvent(orderIndex, questId, questType)
	if (not orderIndex) or (not questId) or (not questType) then
		return false
	end
	
	--TODO
	if orderIndex == QuestOrderEventType.eMeritEvent then
		local player = {playerObj=nil,playerType =0}	--0:玩家自己的信息
		GlobalEventSystem:Fire(GameEvent.EventOpenKnightView, E_ShowOption.eRejectOther, player)		--打开爵位提升界面
	elseif orderIndex == QuestOrderEventType.eMountEvent then
		if (Config.MainMenu[MainMenu_Btn.Btn_mount].condition == false) then		
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen)
	elseif orderIndex == QuestOrderEventType.ePassInstanceEvent  or orderIndex == QuestOrderEventType.eEnterInstanceEvent then	
		GlobalEventSystem:Fire(GameEvent.EventGameInstanceViewOpen)
	elseif orderIndex == QuestOrderEventType.eWingEvent then
		if (Config.MainMenu[MainMenu_Btn.Btn_wing].condition == false) then
			return
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenWingView)
	elseif orderIndex == QuestOrderEventType.eShopEvent or orderIndex == QuestOrderEventType.eWarehouseEvent  then
		local autoPathMgr = GameWorld.Instance:getAutoPathManager()
		local field = QuestRefObj:getStaticQusetOrderField(questType,questId)
		if not field then
			return
		end
		local npcRefId = field[1].npcRefId
		local sceneId = field[1].sceneRefId				
				
		local function openShop(stateType, id)
			if self.FindNpcCallBackId and self.FindNpcCallBackId == id then
				if stateType == AutoPathState.stateRun then
					local bIsOpen  = self:IsNearNPC( sceneId, npcRefId)
					if bIsOpen then										
						self:openShopByNpcRefId(npcRefId,orderIndex)																									
					end
				end
			end
			autoPathMgr:unRegistCallBack(self.FindNpcCallBackId)
		end
		
		if npcRefId~=nil then
			self:killAllAutoFindPath()
			local npcMgr = GameWorld.Instance:getNpcManager()
			npcMgr:saveTouchNpcRefId(npcRefId)
			
			local bIsOpen  = self:IsNearNPC(sceneId, npcRefId)
			if bIsOpen then
				self:openShopByNpcRefId(npcRefId,orderIndex)																			
			else
				self.FindNpcCallBackId = autoPathMgr:registCallBack(openShop)
				autoPathMgr:find(npcRefId, sceneId,true)	
			end					
		end
	elseif orderIndex == QuestOrderEventType.eBuffEvent then
		UIManager.Instance:showSystemTips(Config.Words[3148])
	elseif orderIndex == QuestOrderEventType.eArenaEvent then
		GlobalEventSystem:Fire(GameEvent.EventOpenArenaView)
	end
end

function QuestLogicMgr:openShopByNpcRefId(npcRefId,orderIndex)
	if not npcRefId then
		return
	end
	if orderIndex == QuestOrderEventType.eShopEvent then
		local shopObj = G_GetNpcShopList(npcRefId)	
		if shopObj and shopObj[1] then
			local shopId = shopObj[1].shopID
			if shopId then
				GlobalEventSystem:Fire(GameEvent.EventOpenShop,shopId)	
			end	
		end	
	elseif orderIndex == QuestOrderEventType.eWarehouseEvent then
		GlobalEventSystem:Fire(GameEvent.EventOpenWarehouseView)
	end
end


function QuestLogicMgr:getUpGradeInfo(questType,questId)
	if (not questType) or (not questId)  then
		return
	end
	
	local field = QuestRefObj:getStaticQusetOrderField(questType,questId)
	if field then
		return  field[1].orderType, field[1].orderEventId
	end
end


function QuestLogicMgr:getInstanceTransInfo(questType,questId)
	if (not questType) or (not questId)  then
		return
	end
	
	local field = QuestRefObj:getStaticQusetOrderField(questType,questId)
	if field then
		return  field[1].gameInstanceRefId
	end
end


function QuestLogicMgr:setFlyinShoesTimer(time)
	self.FlyinShoesTimeList = time		
	self:flyinShoesScheduler()
end

--
function QuestLogicMgr:getFlyinShoesTimer()
	return self.FlyinShoesTimeList
end

--
function QuestLogicMgr:flyinShoesScheduler()
	if self.flyinShoesTimerId~=-1 then
		return
	end
	local mainQuestView = UIManager.Instance:getMainView():getQuest()
	local flyrebackFunc = function()
		if self.FlyinShoesTimeList then
			if self.FlyinShoesTimeList > 0 then
				self.FlyinShoesTimeList = self.FlyinShoesTimeList -1
				mainQuestView:updateFlyinShoesTime(self.FlyinShoesTimeList)
			else
				mainQuestView:setFlyinShoesVisible(false)
				self.FlyinShoesTimeList = nil
			end	
		else
			self:clearFlyinShoesScheduler()
		end	
	end
	self.flyinShoesTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(flyrebackFunc, 1, false)
end

function QuestLogicMgr:clearFlyinShoesScheduler()
	if self.flyinShoesTimerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.flyinShoesTimerId)
		self.flyinShoesTimerId = -1
	end
end

function QuestLogicMgr:doMainQuestWithInstanceEvent(questId,questState)
	if (not questId) or (not questState)  then
		return
	end
	
	local field = QuestRefObj:getStaticQusetOrderField(QuestType.eQuestTypeMain,questId)
	if field  and field[1] and field[1].orderEventId then
		local orderEventId = field[1].orderEventId
		--特殊任务类型
		if questState~=QuestState.eSubmittableQuestState and
			 (orderEventId==QuestOrderEventType.ePassInstanceEvent or
			 orderEventId==QuestOrderEventType.eTransferInstanceEvent) then			
			--GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI,true)--进入副本接到副本任务后会再次刷新任务追踪面板
			--if questId ==  then
			--end
		elseif questState==QuestState.eSubmittableQuestState and orderEventId==QuestOrderEventType.eTransferInstanceEvent then	
			GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
			self:handlePKQuest()
			self:autoDoQuest(questId,questState)
		elseif questState==QuestState.eAcceptedQuestState then				
			GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
			
			local step = QuestRefObj:getNewGuidelinesByQuestId(questId)
			GameWorld.Instance:getNewGuidelinesMgr():doQuestNewGuidelinesByStep(step)
			self:autoDoSubAcceptQuest(questId,questState)
		else
			GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
		end	
	else		
		GlobalEventSystem:Fire(GameEvent.EVENT_Main_Quest_UI)
		self:autoDoQuest(questId,questState)
	end	
end

function QuestLogicMgr:autoDoSubAcceptQuest(questId,questState)
	if not questId or not questState then
		return
	end
	
	local orderEventId = QuestRefObj:getOrderEventId(QuestType.eQuestTypeMain,questId)
	if orderEventId and (orderEventId == QuestOrderEventType.eWarehouseEvent or orderEventId == QuestOrderEventType.eShopEvent) then
		self:autoDoQuest(questId,questState)
	end
end

function QuestLogicMgr:handlePKQuest()
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	if  instanceRefId and GameData.AllIns_PK[instanceRefId] then
		showMsgBox(Config.Words[25100],E_MSG_BT_ID.ID_KNOW)
		GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.AutoFightView)
	end
end


function QuestLogicMgr:getNextSceneLayer()
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	local senceLayer = G_getQuestMgr():getSceneLayer()
	if instanceRefId and senceLayer then
		local nextLayer = QuestInstanceRefObj:getStaticQusetToNextLayerRefId(instanceRefId,senceLayer)
		return nextLayer
	end
end


function QuestLogicMgr:autoDoQuest(questId,state)
	if (not questId) or (not state)  then
		return
	end
	
	if self:getOutInstanceDontDoQuest()==false then
		if self.unFirstDoQuest then
			local bDo = false
			if state==QuestState.eSubmittableQuestState and self.autoDoSubmitQuestRefId ~= questId then
				bDo = true
			elseif state==QuestState.eAcceptableQuestState and self.autoDoAcceptQuestRefId ~= questId then
				bDo = true
			elseif state==QuestState.eAcceptedQuestState and self.autoDoAcceptedQuestRefId ~= questId then
				bDo = true	
				
			end
			if bDo==true then
				--接任务后自动执行任务
				local view = UIManager.Instance:getMainView()
				if view then
					view:doNewGuidelinesByClickIdex(1)--主线任务接口
				end
			end	
		end	
		self.unFirstDoQuest = true
		if state==QuestState.eSubmittableQuestState then
			self.autoDoSubmitQuestRefId = questId
		elseif state==QuestState.eAcceptableQuestState then
			self.autoDoAcceptQuestRefId = questId
		elseif state==QuestState.eAcceptedQuestState then
			self.autoDoAcceptedQuestRefId = questId
		end			
	end
	self:setOutInstanceDontDoQuest(false)
end	

function QuestLogicMgr:setOutInstanceDontDoQuest(bDo)
	self.bOutInstanceDontDoQuest = bDo
end

function QuestLogicMgr:getOutInstanceDontDoQuest()
	return self.bOutInstanceDontDoQuest
end

--杀完怪返回NPC提交任务 
function QuestLogicMgr:AutoPathFindNpc(questId)
	if not questId then
		return
	end	
	
	local function callBlack()
		if G_getHandupMgr():isHandup() then
			local function stopcallBlack(stopquestId)
				if stopquestId == questId then
					self:doAutoPathFindNpc(stopquestId)					
				end
			end
			G_getHandupMgr():stopWithPickup(stopcallBlack,questId)
		else
			self:doAutoPathFindNpc(questId)
		end
	end
	local action = BaseActionPlayer.New()
	action:setMaxPlayingDuration(0.1)
	action:addStopNotify(callBlack)
	ActionPlayerMgr.Instance:addPlayer(G_getHero():getId(), action)
end	

function QuestLogicMgr:KillAllAction()
	G_getHandupMgr():stop()
end


--自动寻怪
function QuestLogicMgr:AutoPathFindMonster(monsterRefId, sceneId)
	if (not monsterRefId) or (not sceneId) then
		return
	end
	G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {monsterRefId}, sceneId, nil, E_SearchTargetMode.RefId)
end

--自动采集 
function QuestLogicMgr:AutoCollectItem(collectId,sceneId)
	if (not collectId) or (not sceneId) then
		return
	end
	G_getHandupMgr():start(E_AutoSelectTargetMode.Collect, {EntityType.EntityType_NPC}, {collectId}, sceneId, nil, E_SearchTargetMode.RefId)
end


--是否达到等级 
function QuestLogicMgr:IsAchieveLevel(questId)
	if not questId then
		return
	end
	
	local bIs = false
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local questObj = G_getQuestMgr():getQuestObj(questId)
	if questObj then	
		local questLevel = PropertyDictionary:get_level(hero:getPT())
		local questType = questObj:getQuestType()
		local staticQuestLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(questType,questId)
		if questLevel>=staticQuestLevel then
			bIs = true
		else
			--UIManager.Instance:showSystemTips(Config.Words[3125],CCSizeMake(400,70),FSIZE("Size5"),FCOLOR("ColorYellow2"))
		end
	end
	return bIs
end

--设置下个任务是否可接 
function QuestLogicMgr:setAcceptNextQuest(questType,nowquestId)
	if (not questType) or (not nowquestId) then
		return
	end
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local herolevel = PropertyDictionary:get_level(hero:getPT())
	local nextquestId = QuestRefObj:getStaticQusetNextQuest(questType,nowquestId)
	self.isAcceptQuest = false
	local nextquestAcceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(questType,nextquestId)
	if nextquestAcceptLevel then
		if herolevel >= nextquestAcceptLevel then
			self.isAcceptQuest = true
		end
	end
end

--获取当前任务是否可接 
function QuestLogicMgr:getAcceptNowQuest()
	return self.isAcceptQuest
end


function QuestLogicMgr:checkUpdateLevelGetQuestList(level)
	if (not level) then
		return
	end
	
	local function compareLevel(acceptLevel,nowLevel)
		if nowLevel >= acceptLevel then	
			return true
		end
		return false
	end
	
	--判断是否由推荐挂机改变为主线任务
	if self.isAcceptQuest==false then
		local mainquestId = G_getQuestMgr():getMianQuestId()		
		if not mainquestId then
			G_getQuestMgr():requestQuestList()--发送任务列表请求
		else
			local acceptMainQuestLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(QuestType.eQuestTypeMain,mainquestId)
			if level >= acceptMainQuestLevel then
				G_getQuestMgr():requestQuestList()--发送任务列表请求
			end
		end	
	end
	
	--判断是否有日常任务
	if not self.dailyQuestLevelList then
		self.dailyQuestLevelList = {}
		for i,v in pairs(GameData.DailyQuest) do
			local questId = v.refId
			local acceptLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(QuestType.eQuestTypeDaily,questId)			
			local list = {id = questId,level = acceptLevel}
			table.insert(self.dailyQuestLevelList,acceptLevel,list)			
		end	
	end
	
	for i,v in pairs(self.dailyQuestLevelList) do
		local acceptLevel = v.level
		local isGet = compareLevel(acceptLevel,level)
		if isGet==true then
			G_getQuestMgr():requestQuestList()--发送任务列表请求
			self.dailyQuestLevelList[i] = nil
			break
		end
	end				
end	


--获得任务状态 
function QuestLogicMgr:getquestState(bIsAccept,questType,questId)
	if (not questType) or (not questId) then
		return
	end
	
	if not bIsAccept then
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local herolevel = PropertyDictionary:get_level(hero:getPT())
		local questLevel = QuestRefObj:getStaticQusetConditionFieldAcceptLevel(questType,questId)	
	
		if herolevel>=questLevel then
			return QuestState.eAcceptableQuestState
		else
			return QuestState.eVisiableQuestState
		end
	else
		if bIsAccept==true then
			return QuestState.eAcceptableQuestState
		else
			return QuestState.eVisiableQuestState
		end
	end	
end

--判断是否存在任务 
function QuestLogicMgr:IsHaveQuest(npcObjRefId)
	if (not npcObjRefId) then
		return
	end
	local questList = G_getQuestMgr():getQuestList()
	local npcQuestList = {}
	for i,v in pairs(questList) do
		local questRefIdfgd = v:getQuestId()
		local questTypegd = v:getQuestType()
		local acceptNpcId,submitNpcId,acceptSceneId,submitSceneId
		if QuestRefObj:getStaticQusetNpcField(questTypegd,questRefIdfgd) ~= nil then
			acceptNpcId =  QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypegd,questRefIdfgd,"acceptNpc")
			submitNpcId =  QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypegd,questRefIdfgd,"submitNpc")
			acceptSceneId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypegd,questRefIdfgd,"acceptNpc")
			submitSceneId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypegd,questRefIdfgd,"submitNpc")
		end
		local questState = G_getQuestMgr():getQuestObj(questRefIdfgd):getQuestState()
		local list = {
		questId = questRefIdfgd ,
		questState = questState ,
		acceptNpcRefId = acceptNpcId,
		submitNpcRefId = submitNpcId,
		acceptSceneRefId = acceptSceneId,
		submitSceneRefId = submitSceneId,
		questObj = v
		}
		if questState == QuestState.eSubmittableQuestState then
			table.insert(npcQuestList,1,list)
		else
			table.insert(npcQuestList,list)
		end
	end
	
	for j,v in pairs(npcQuestList) do
		local acceptNpcId =  v.acceptNpcRefId
		local submitNpcId =  v.submitNpcRefId
		local acceptSceneId = v.acceptSceneRefId
		local submitSceneId = v.submitSceneRefId
		local state =  v.questState
		local questObj = v.questObj
		local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()
		if (npcObjRefId==acceptNpcId and acceptSceneId==currentMapRefId and state == QuestState.eAcceptableQuestState)or
			(npcObjRefId==submitNpcId and submitSceneId==currentMapRefId and state == QuestState.eSubmittableQuestState) then
			return questObj			
		end
	end
end	

function QuestLogicMgr:getIsFirstDoQuest()
	return self.unFirstDoQuest
end	

function QuestLogicMgr:stateSystemTip(questId,nowNum,instanId)
	if not questId or not nowNum then
		return
	end
	
	local questObj = G_getQuestMgr():getQuestObj(questId)
	local questType = questObj:getQuestType()

	local questIndex = 1
	if questType == QuestType.eQuestTypeDaily then
		questIndex = questObj:getRandomOrderType()
	end
	
	local orderType = QuestRefObj:getStaticQusetOrderFieldType(questType,questId,questIndex,instanId)
	
	local targetId = ""
	local targetName = ""
	local preWord = ""
	local totalNum = 0
	if orderType == QuestOrderType.eOrderTypeKill then
		preWord = Config.Words[3301]
		targetId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questType,questId,questIndex,instanId)
		targetName = PropertyDictionary:get_name(GameData.Monster[targetId].property)	
		totalNum = QuestRefObj:getStaticQusetOrderFieldKillCount(questType,questId,questIndex,instanId)	
		if questType==QuestType.eQuestTypeDaily then
			local nowRing = questObj:getDailyRing()
			local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)								
			if nowRing>maxRing then--判断是否在推荐环外
				bOverOrder =true
				totalNum = QuestRefObj:getStaticDailyQusetOverOrderFieldKillCount(questType,questId,questIndex,instanId)
			end	
		end
		
	elseif orderType == QuestOrderType.eOrderTypeCollection then
		preWord = Config.Words[3304]
		targetId = QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(questType,questId,questIndex)
		targetName = PropertyDictionary:get_name(GameData.Collect[targetId].property)
		totalNum = QuestRefObj:getStaticQusetOrderFieldItemCount(questType,questId,questIndex,instanId)
	elseif orderType == QuestOrderType.eOrderTypeTime then
		local field = QuestRefObj:getStaticQusetOrderField(questType,questId)
		if field  and field[1] and field[1].orderEventId then
			local orderEventId = field[1].orderEventId
			if orderEventId==QuestOrderEventType.eShopEvent then
				preWord = Config.Words[5020]
				targetId = QuestRefObj:getStaticQusetOrderFieldBuyItemName(questType,questId,questIndex)	
				targetName = PropertyDictionary:get_name(GameData.PropsItem[targetId].property)			
				totalNum = QuestRefObj:getStaticQusetOrderFieldBuyItemCount(questType,questId,questIndex,instanId)
			end
		end
	end
	
	local msg = {[1] = {word = preWord, color = Config.FontColor["ColorWhite1"]},
				[2] = {word = targetName, color = Config.FontColor["ColorOrange3"]},
				[3] = {word = "("..tostring(nowNum).."/"..tostring(totalNum)..")", color = Config.FontColor["ColorRed1"]}}
	UIManager.Instance:showSystemTips(msg,E_TipsType.emphasize)
end

function QuestLogicMgr:getDistributaryScene(scene)
	if not  scene then
		return
	end
	local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()
	local mapData = GameData.Scene[scene]
	local nowmapData = GameData.Scene[currentMapRefId]
	if mapData and nowmapData then
		local kind = PropertyDictionary:get_kind(mapData)
		local nowkind = PropertyDictionary:get_kind(nowmapData)
		if kind == MapKind.newVillage and nowkind==MapKind.newVillage then		
			scene = currentMapRefId
		end
	end
	
	return scene
end	

function QuestLogicMgr:getNumberByShopViewWithQuest(refId)
	local num = 1
	if not refId then
		return num
	else
		local itemObj = GameData.PropsPurchase[refId]
		if itemObj then
			num = itemObj.defaultNumber
		end
	end
		
	local questId = G_getQuestMgr():getMianQuestId()
	local orderEventId = QuestRefObj:getOrderEventId(QuestType.eQuestTypeMain,questId)	
	local orderBuyItem = QuestRefObj:getOrderBuyItem(QuestType.eQuestTypeMain,questId)	
		
	if orderEventId==QuestOrderEventType.eShopEvent and orderBuyItem==refId then
		local questObj = G_getQuestMgr():getQuestObj(questId)
		if questObj then
			local questState = questObj:getQuestState()
			if questState==QuestState.eAcceptedQuestState then
				local number = questObj:getNumber(1)
				local totalNum = QuestRefObj:getStaticQusetOrderFieldBuyItemCount(QuestType.eQuestTypeMain,questId,1)
				if number and totalNum then
					num = totalNum - number
				end
			end
		end
	end
	
	return num
end

function QuestLogicMgr:sendQuestActionByOpenWarehouse()
	local questId = G_getQuestMgr():getMianQuestId()
	local field = QuestRefObj:getStaticQusetOrderField(QuestType.eQuestTypeMain,questId)
	if field  and field[1] and field[1].orderEventId then
		local orderEventId = field[1].orderEventId
		if orderEventId==QuestOrderEventType.eWarehouseEvent then
			G_getQuestMgr():requestActionToSucceed(questId)
		end
	end
end

function QuestLogicMgr:getTransferByDailyQuest(questId)
	if not questId then
		return
	end
	
	local questObj = G_getQuestMgr():getQuestObj(questId)	
	if not questObj then
		return
	end
		
	local questType = questObj:getQuestType()
	local questState = questObj:getQuestState()
	
	local transferSceneRefid = nil
	local transferPos = nil	
	
	if questState==QuestState.eAcceptableQuestState then --任务可接
		transferSceneRefid = QuestRefObj:getStaticQusetNpcFieldSceneRefId(questType,questId,"acceptNpc")
		local NpcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questType,questId,"acceptNpc")
		transferPos = G_getNPCPosByOrderRefidAndSceneRefid(NpcRefid,transferSceneRefid)
	elseif questState==QuestState.eAcceptedQuestState then --任务已接，但未完成
		local orderType = QuestRefObj:getStaticQusetOrderFieldType(questType,questId,1)
		if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪	
			local randomOrder = questObj:getRandomOrderType()	
			local nowRing = questObj:getDailyRing()
			local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)		
			if nowRing>maxRing then--判断是否在推荐环外
				local monsterId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(questType,questId,randomOrder)
				transferSceneRefid = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(questType,questId,randomOrder)
				transferPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,transferSceneRefid)
			else--推荐环内杀怪数据
				local monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questType,questId,randomOrder)
				transferSceneRefid = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questType,questId,randomOrder)
				transferPos = G_getMonsterPosByOrderRefidAndSceneRefid(monsterId,transferSceneRefid)
			end
		end
	elseif questState==QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
		transferSceneRefid	= QuestRefObj:getStaticQusetNpcFieldSceneRefId(questTypeValue,questRefId,"submitNpc")
		local NpcRefid = QuestRefObj:getStaticQusetNpcFieldNcRefId(questTypeValue,questRefId,"submitNpc")
		transferPos = G_getNPCPosByOrderRefidAndSceneRefid(NpcRefid,transferSceneRefid)
	end
	
	return transferSceneRefid,transferPos
end

function QuestLogicMgr:autoDoDailyQuest(questId)
	if not questId then
		return
	end
	
	local questObj = G_getQuestMgr():getQuestObj(questId)	
	if not questObj then
		return
	end
	
	local questType = questObj:getQuestType()	
	if questType~=QuestType.eQuestTypeDaily then
		return
	end
	local questState = questObj:getQuestState()
	
	if questState==QuestState.eAcceptableQuestState then --任务可接
		self:doAutoPathFindNpc(questId)
	elseif questState==QuestState.eAcceptedQuestState then --任务已接，但未完成
		local orderType = QuestRefObj:getStaticQusetOrderFieldType(questType,questId,1)
		if orderType == QuestOrderType.eOrderTypeKill then --任务类型-杀怪	
			local randomOrder = questObj:getRandomOrderType()	
			local nowRing = questObj:getDailyRing()
			local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(questId)		
			if nowRing>maxRing then--判断是否在推荐环外
				local monsterId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(questType,questId,randomOrder)
				local sceneId = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(questType,questId,randomOrder)
				self:AutoPathFindMonster(monsterId,sceneId)
			else--推荐环内杀怪数据
				local monsterId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(questType,questId,randomOrder)
				local sceneId = QuestRefObj:getStaticQusetOrderFieldSceneRefId(questType,questId,randomOrder)			
				self:AutoPathFindMonster(monsterId,sceneId)			
			end
		end
	elseif questState==QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
		self:doAutoPathFindNpc(questId)
	end		
end

--检查是否所有任务状态是已完成
function QuestLogicMgr:checkAllInstanceQuestFinish()
	local questMgr = G_getQuestMgr()
	if not questMgr:getInstanceRefId() then
		return
	end 

	for i,v in pairs(questMgr:getQuestList()) do
		if  v:getQuestState()~= QuestState.eSubmittableQuestState then
			questMgr:requestInstanceQuestList()
			return
		end
	end	
end