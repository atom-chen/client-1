require("common.baseclass")
require("object.gameInstance.GameInstanceObject")
require("data.gameInstance.Ins_3")
require("data.gameInstance.Ins_5")
require("data.gameInstance.Ins_1")
require("data.gameInstance.Ins_4")
require("data.gameInstance.Ins_2")
require("data.gameInstance.Ins_6")
require("data.gameInstance.Ins_7")
require("data.gameInstance.Ins_pk1")
require("data.gameInstance.Ins_pk2")

local const_entryLevel = 40

GameInstanceManager = GameInstanceManager or BaseClass()
E_LevelState = {
	StateWhite = 1,
	StatePink = 2,
	StateRed = 3,
	DeepRed = 4,
}
E_InstanceType = {
	level = 1,
	activity = 2,
}
function GameInstanceManager:__init()
	self.isInstanceFinished = false	
	self.isFinishWhenLogin = false
	self:init()
end

function GameInstanceManager:__delete()
	self:clear()
end

function GameInstanceManager:getIsInstanceFinished()
	return self.isInstanceFinished
end

function GameInstanceManager:setIsInstanceFinished(bFinished)
	self.isInstanceFinished = bFinished
end	

function GameInstanceManager:init()
	self.count = {}
	self.count[E_InstanceType.level] = 0
	self.count[E_InstanceType.activity] = 0
	self.updateCount = 0
	self.indexList = {}
	self.indexActivityList = {}
	self.gameInstanceList = {}
	self.updateList = {}
	self.stateList = {}
	self.stateActivityList = {}
	local onHeroProChanged = function(newPD,oldPD)
		self:isUpdateInstanceTitle(newPD,oldPD)
	end
	self.heroProChanged = GlobalEventSystem:Bind(GameEvent.EventHeroProChanged, onHeroProChanged)
end

function GameInstanceManager:clear()
	for k,v in pairs(self.gameInstanceList) do
		self.gameInstanceList[k]:DeleteMe()
	end				
--[[	self.count = 0
	self.updateCount = 0
	self.indexList = {}
	self.gameInstanceList = {}
	self.updateList = {}
	self.stateList = {}--]]
end

function GameInstanceManager:getGameInstanceObj(refId)
	return self.gameInstanceList[refId]
end

function GameInstanceManager:addToList(id,refId,countInDay,countInWeek)
	local instance = self.gameInstanceList[refId]
	if instance == nil then
		instance = GameInstanceObject.New()	
		instance:setRefId(refId)
		instance:setOpenLevel()
		local instanceType = QuestInstanceRefObj:getInstanceType(refId)
		if not instanceType or instanceType == 4 then --todu紧急处理,缺少ins_8表导致报错
			return
		end
		instance:setIndex(self.count[instanceType])
		self.gameInstanceList[refId] = instance
		self:setList(instanceType,refId,instance)
		self.count[instanceType] = self.count[instanceType] +1
	end
	instance:setId(id)
	local oldCount = instance:getCountInDay()
	if oldCount ~= countInDay then
		instance:setCountInDay(countInDay)
		self.updateList[refId] = instance
		self.updateCount = self.updateCount +1
	end
	instance:setCountInWeek(countInWeek)
end	

function GameInstanceManager:setList(instanceType,refId,instance)
	if instanceType==E_InstanceType.activity then	
		table.insert(self.indexActivityList,instance)
	else
		table.insert(self.indexList,instance)
	end
end

function GameInstanceManager:updateTableView(theTable)
	if self.updateCount > 0 then
		if (self.updateCount < self.count[E_InstanceType.activity]-1 or self.updateCount < self.count[E_InstanceType.level]-1 ) and self.updateCount ~= 0 then
			for k,v in pairs(self.updateList) do
				theTable:updateCellAtIndex(v:getIndex())
				self:clearUpdateList(v)
			end
		else
			theTable:reloadData()
			self.updateList = {}
			self.updateCount = 0
		end
	end		
end

function GameInstanceManager:clearUpdateList(instance)
	self.updateList[instance:getRefId()] = nil
	self.updateCount = self.updateCount -1
end

function GameInstanceManager:getActivityListData(index)
	return self.indexActivityList[index+1]
end

function GameInstanceManager:getData(index)
	return self.indexList[index+1]
end

function GameInstanceManager:getDataList()
	return self.indexList
end

function GameInstanceManager:getActivityDataList()
	return self.indexActivityList
end

function GameInstanceManager:getActivityListDataSize()
	return table.size(self.indexActivityList)
end

function GameInstanceManager:getDataSize()
	return table.size(self.indexList)
end

function GameInstanceManager:requestGameInstanceList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GameInstanceList)
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:requesEnterGameInstance(refId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GameInstanceEnter)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:requestLeaveGameInstance(refId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GameInstanceLeave)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:requestShowQuestReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Show_GameInstanceQuestReward)	
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:requestGetQuestReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Reward_GameInstanceQuest)
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:requestEnterNextLayer(refId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_GameInstanceEnterNextLayer)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)
end

function GameInstanceManager:isUpdateInstanceTitle(newPD,oldPD)
	local newHeroLevel	= PropertyDictionary:get_level(newPD)
	local oldHeroLevel  = PropertyDictionary:get_level(oldPD)
	if newHeroLevel > 65 then
		if self.heroProChanged then
			GlobalEventSystem:UnBind(self.heroProChanged)
			self.heroProChanged = nil
			return
		end
	end
	if newHeroLevel ~= 0 and oldHeroLevel ~= 0 and newHeroLevel ~= oldHeroLevel then	
		for i,v in ipairs(self.indexList) do
			local requestLevel = v:getOpenLevel()
			local newLevelState = self:operateLevelState(requestLevel,newHeroLevel)			
			self.stateList[i] = newLevelState
		end
		
		for i,v in ipairs(self.indexActivityList) do
			local requestLevel = v:getOpenLevel()
			local newLevelState = self:operateLevelState(requestLevel,newHeroLevel)			
			self.stateActivityList[i] = newLevelState
		end
		
		GlobalEventSystem:Fire(GameEvent.EventGameInstanceTitleRefresh)
	end
end

function GameInstanceManager:operateLevelState(requestLevel,heroLevel)
	if requestLevel <= heroLevel then	
		return E_LevelState.StateWhite
	else
		if requestLevel - heroLevel < 10 then
			return E_LevelState.StatePink
		else 
			return E_LevelState.StateRed
		end
	end
end

function GameInstanceManager:getColorByState(state)
	if state == E_LevelState.StateWhite then
		return FCOLOR("ColorWhite1")
	elseif state == E_LevelState.StatePink then
		return FCOLOR("ColorRed2")
	elseif state == E_LevelState.StateRed then
		return FCOLOR("ColorRed1")
	end
end

function GameInstanceManager:getStateList()
	return self.stateList
end

function GameInstanceManager:getStateActivityList()
	return self.stateActivityList
end

function GameInstanceManager:isInstanceOpen()
	local hero = G_getHero()
	local pt = hero:getPT()
	local level = PropertyDictionary:get_level(pt)
	return level >= const_entryLevel
end

function GameInstanceManager:isZhenMoTaOpen()
	local hero = G_getHero()
	local pt = hero:getPT()
	local level = PropertyDictionary:get_level(pt)

	local zhenMoTaPt = GameData.Ins_6["Ins_6"].configData["game_instance"].configData["Ins_6"]["property"]
	local needLevel = PropertyDictionary:get_level(zhenMoTaPt)
	
	return level >= needLevel
end

function GameInstanceManager:isWorldBossOpen()
	local hero = G_getHero()
	local pt = hero:getPT()
	local level = PropertyDictionary:get_level(pt)
	return level >= const_entryLevel
end

--是否在镇魔塔的虽有一层
function GameInstanceManager:isInZhenMoTaLast()
	require "data.gameInstance.Ins_6"
	if GameData.Ins_6 and GameData.Ins_6["Ins_6"] and GameData.Ins_6["Ins_6"].configData and
		GameData.Ins_6["Ins_6"].configData["game_instance"] and GameData.Ins_6["Ins_6"].configData["game_instance"].configData and
		GameData.Ins_6["Ins_6"].configData["game_instance"].configData["Ins_6"] and
		GameData.Ins_6["Ins_6"].configData["game_instance"].configData["Ins_6"].gameInstanceData and
		GameData.Ins_6["Ins_6"].configData["game_instance"].configData["Ins_6"].gameInstanceData.structureDetails then
		local detail = GameData.Ins_6["Ins_6"].configData["game_instance"].configData["Ins_6"].gameInstanceData.structureDetails
		if type(detail) == "table" then
			local lastMapId = detail[#detail]  --镇魔塔最后一层的refId			
			local mapMgr = GameWorld.Instance:getMapManager()
			local curMap = mapMgr:getCurrentMapRefId()
			if curMap == lastMapId then
				return true
			end
			return false
		end
	end
end

function GameInstanceManager:setZhenMoTaNPCArrow()
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	if instanceRefId == "Ins_6" then
		local npcList = GameWorld.Instance:getEntityManager():getNPCList()
		for i,v in pairs(npcList) do
			local npcId= v:getRefId()
			if npcId == "npc_14" then
				v:setArrow()
				return
			end
		end
	end		
end

--默认选中假PK中第一个怪
function GameInstanceManager:setFocusTeFirstMonsterPlayer(monster)
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	if instanceRefId and  GameData.AllIns_PK[instanceRefId] then
		local currentMapRefId =  GameWorld.Instance:getMapManager():getCurrentMapRefId()
		if self.savePKScene ~= currentMapRefId then
			local focusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
			focusManager:onEntityFocus(monster)
		end
		self.savePKScene = currentMapRefId	
	end
end

function GameInstanceManager:isInIns_PK()
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	if instanceRefId and  GameData.AllIns_PK[instanceRefId] then
		return true
	end
	return false
end

--在副本中进入活动判断
function GameInstanceManager:leaveInstaceToActivity(notify)
	local instanceRefId = G_getQuestMgr():getInstanceRefId()
	if instanceRefId then
		local exitFunction = function(arg,text,id)
			if id == 2 then
				if notify then
					notify()
				end
			end
		end
		
		local msg = showMsgBox(Config.Words[15037],E_MSG_BT_ID.ID_CANCELAndOK)	
		msg:setNotify(exitFunction)
	else	
		if notify then
			notify()
		end
	end
end

function GameInstanceManager:setFinishInstanceArrow(setType)
	if type(setType) == "string" then
		GameWorld.Instance:getNewGuidelinesMgr():clearArrow()
		GlobalEventSystem:Fire(GameEvent.Event_SetFinishInstanceArrow,setType)
	end
end

function GameInstanceManager:leaveInstance()
	GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()	
	local msg = {}
	table.insert(msg,{word = Config.Words[15011], color = Config.FontColor["ColorWhite1"]})
	UIManager.Instance:showSystemTips(msg)
	self:setFinishInstanceArrow("remove")
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainHeroHead","heroStatusBtn")
end

