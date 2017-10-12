require("actionEvent.ActionEventDef")
require ("data.achievement.achievement")
require ("object.achievement.ConditionObject")
require "data.achievement.achievement"	
require"data.achievement.medal"
require "data.scene.scene"
AchievementMgr = AchievementMgr or BaseClass()

local medalRefid = 
{
	[1] = { refId = "equip_10_9000"},
	[2] = { refId = "equip_20_9000"},
	[3] = { refId = "equip_30_9000"},
	[4] = { refId = "equip_40_9000"},
	[5] = { refId = "equip_50_9000"},
	[6] = { refId = "equip_60_9000"},
	[7] = { refId = "equip_70_9000"},
	[8] = { refId = "equip_80_9000"},
	[9] = { refId = "equip_90_9000"},
	[10] = { refId = "equip_100_9000"},

}
E_AchieveType = {
	
}

function AchievementMgr:__init()
	self.totalStaList = {}
	--完成状态list
	self.totalComList = {}	
end
function AchievementMgr:__delete()
	for i = 1,6 do
		local comList = self:getCompletedContainerByType(i)		
		for i,v in pairs(comList) do
			v:DeleteMe()
		end			
	end	
end

function AchievementMgr:clear()
	for i = 1,6 do
		local comList = self:getCompletedContainerByType(i)		
		if table.size(comList)>0 then
			for i,v in pairs(comList) do
				if v then
					v:DeleteMe()
				end
			end		
		end						
	end			
	self.totalComList = {}
	self.totalStaList = {}
	self.requestFlag = nil
end

function AchievementMgr:requestAchievementList() --登录时请求成就列表
	self:setStaticData()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Achievement_List)
	simulator:sendTcpActionEventInLua(writer)	
end

function AchievementMgr:requestAchievementGetReward(refId) --领取ID的成就奖励
	if refId == nil then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Achievement_GetReward)
	StreamDataAdapter:WriteStr(writer,refId)
	simulator:sendTcpActionEventInLua(writer)	
end
function AchievementMgr:requestAchievementExchangeMedal() --兑换勋章
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Achievement_ExchangeMedal)	
	simulator:sendTcpActionEventInLua(writer)	
end
function AchievementMgr:requestAchievementLevlUpMedal(position,refId,itemId)
	if position == nil or refId == nil or itemId == nil then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Achievement_LevlUpMedal)
	StreamDataAdapter:WriteChar(writer,position)  --0在身上，1在背包
	StreamDataAdapter:WriteStr(writer,refId)
	StreamDataAdapter:WriteStr(writer,itemId)
	simulator:sendTcpActionEventInLua(writer)	
end

function AchievementMgr:requestAchievementGetAllReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Achievement_GetAllReward)	
	simulator:sendTcpActionEventInLua(writer)	
end	

function AchievementMgr:setStaticData()
	self:clear()
	for id,value in pairs(GameData.Achievement) do
		local  achieveType= value.property.achieveType	
		local completedList = self:getCompletedContainerByType(achieveType)	
		local staticList = self:getStaticContainerByType(achieveType)
		if staticList then	
			staticList[value.refId] = value	
			self:setStaticContainerByType(achieveType,staticList)	
		end	
		local conditionObj = ConditionObject.New()
		conditionObj:setCompleted(0)
		conditionObj:setFlag(false)
		conditionObj:setRefId(value.refId)
		conditionObj:setNextFlag(0)
		if completedList then
			completedList[value.refId] = conditionObj
			self:setCompletedContainerByType(achieveType,completedList)	
		end	
	end
	for i=1,6 do
		local comList = self:getCompletedContainerByType(i)
		if comList then
			comList = self:sortList(comList)
			self:setCompletedContainerByType(i,comList)
		end
		local staticList = self:getStaticContainerByType(i)
		if staticList then	
			staticList = self:sortList(staticList)
			self:setStaticContainerByType(i,staticList)
		end
	end
	self.requestFlag = true
end


function AchievementMgr:setCompletedContainerByType(listType,list)
	--list = self:sortList(list)
	if listType == nil or list == nil then
		return
	end		
	self.totalComList[listType] = list
end

function AchievementMgr:setStaticContainerByType(listType,list)
	--list = self:sortList(list)
	if listType == nil or list == nil then
		return
	end
	--[[if list == nil then
		list = {}
	end--]]
	self.totalStaList[listType] = list
end

function AchievementMgr:getCompletedContainerByType(listType)
	if listType then
		if listType >=1 and listType<=6 then
			if self.totalComList[listType] then
				return self.totalComList[listType]
			else
				self.totalComList[listType] = {}
				return self.totalComList[listType]
			end
		end
	end
end

function AchievementMgr:getStaticContainerByType(listType)
	if listType then
		if listType >=1 and listType<=6 then
			if self.totalStaList[listType] then
				return self.totalStaList[listType]
			else
				self.totalStaList[listType] = {}
				return self.totalStaList[listType]
			end
		end
	end
end	

function AchievementMgr:setCompletedListByTypeAndIdAndFlag(bType,id,flag,nextRefId,nextAchiType)
	local curCompletedList = self:getCompletedContainerByType(bType)
	if curCompletedList then
		for i,v in pairs(curCompletedList) do
			if id and v.refId == id  then
				self.curComObj = v
				break
			end
		end			
		if self.curComObj then
			self.curComObj:setCompleted(1)
			self.curComObj:setNextFlag(0)
			self.curComObj:setFlag(flag)			
		end				
	end
	local nextCompletedList = self:getCompletedContainerByType(nextAchiType)
	if nextCompletedList then
		for i,v in pairs(nextCompletedList) do
			if nextRefId and v.refId == nextRefId  then
				self.nextComObj = v
				break
			end
		end
		if self.nextComObj then
			if self.nextComObj:getCompleted()== 0 then
				self.nextComObj:setNextFlag(1)			
			end
		end		
	end
end

function AchievementMgr:sortList(list)
	if(list) then
		self.resortList = {}
		local index = 1
		for i,v in pairs(list) do	
			self.resortList[index] = v
			index = index + 1
		end			
		function sortLevelNameAsc(a, b)		
			local a1=tonumber(string.sub(a.refId,9))
			local b1=tonumber(string.sub(b.refId,9))
			return  a1 < b1
		end
		table.sort(self.resortList, sortLevelNameAsc)
		return self.resortList		
	end
end


function AchievementMgr:fireRefreshEvent(vType,selIndex)
	if(vType == 1) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshNovice,selIndex)
		return
	elseif(vType == 2) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshKillSubs,selIndex)
		return
	elseif(vType == 3) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshKillBoss,selIndex)	
		return
	elseif(vType == 4) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshMountUp,selIndex)
		return
	elseif(vType == 5) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshKnightUp,selIndex)
		return
	elseif(vType == 6) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshGetMedal,selIndex)
		return
	--[[elseif(vType == 7) then
		GlobalEventSystem:Fire(GameEvent.EventRefreshGetMedal,selIndex)
		return--]]
	end
end

function AchievementMgr:setRequestFlag(rflag)
	self.requestFlag = rflag
end

function AchievementMgr:getRequestFlag()
	if(self.requestFlag ~= nil) then
		return self.requestFlag
	end
end

function AchievementMgr:getMedalInfo(index,mtype)
	
	if(index == 1) then
		local refId = "equip_10_9000"
		local pd = GameData.Medal["medal"].configData["equip_10_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 2) then
		local refId = "equip_20_9000"
		local pd = GameData.Medal["medal"].configData["equip_20_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 3) then
		local refId = "equip_30_9000"
		local pd = GameData.Medal["medal"].configData["equip_30_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 4) then
		local refId = "equip_40_9000"
		local pd = GameData.Medal["medal"].configData["equip_40_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 5) then
		local refId = "equip_50_9000"
		local pd = GameData.Medal["medal"].configData["equip_50_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 6) then
		local refId = "equip_60_9000"
		local pd = GameData.Medal["medal"].configData["equip_60_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 7) then
		local refId = "equip_70_9000"
		local pd = GameData.Medal["medal"].configData["equip_70_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 8) then
		local refId = "equip_80_9000"
		local pd = GameData.Medal["medal"].configData["equip_80_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 9) then
		local refId = "equip_90_9000"
		local pd = GameData.Medal["medal"].configData["equip_90_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	elseif(index == 10) then
		local refId = "equip_100_9000"
		local pd = GameData.Medal["medal"].configData["equip_100_9000"].property
		if(mtype == "name") then
			return PropertyDictionary:get_name(pd)
		elseif(mtype == "needAchieve") then
			return PropertyDictionary:get_needAchieve(pd)
		elseif(mtype == "refId") then
			return refId
		end
	end
end

function AchievementMgr:openBtn()
	GlobalEventSystem:Fire(GameEvent.EventOpenBtn)
end
function AchievementMgr:closeBtn()
	GlobalEventSystem:Fire(GameEvent.EventCloseBtn)
end
function AchievementMgr:fireCompleteList(keys)
	GlobalEventSystem:Fire(GameEvent.EventCompletedListSet,keys)
end
function AchievementMgr:fireSelIndex(selAchiId)
	GlobalEventSystem:Fire(GameEvent.EventSetSelIndex,selAchiId)
end
function AchievementMgr:fireCheckNewImage(achieveType)
	GlobalEventSystem:Fire(GameEvent.EventCheckNewImage,achieveType)
end
function AchievementMgr:fireCheckNewReward()
	GlobalEventSystem:Fire(GameEvent.EventCheckNewReward)
end
function AchievementMgr:checkMedal()
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local hasInBag
	local hasInEquip
	for i,v in ipairs(medalRefid) do
		hasInBag = bagMgr:hasItem(v.refId)
		hasInEquip = equipMgr:hasEquip(v.refId)
		if(hasInBag == true or hasInEquip == true) then		
			return i						
		end
	end
	
end


function AchievementMgr:getAllReward()
	for i=1,6 do
		local completedList = self:getCompletedContainerByType(i)
		if completedList then
			for i,v in pairs(completedList) do
				local completed = v:getCompleted()
				local flag = v:getFlag()
				if completed == 1 and flag == false then
					v:setFlag(true)
				end
			end
		end
	end	
	for i=1,6 do
		self:fireCheckNewImage(i)
		self:fireCompleteList(i)	
	end
end

function AchievementMgr:checkNewReward()
	for i = 1,6 do
		local completeList = self:getCompletedContainerByType(i)
		--completeList = self:sortList(completeList)
		if completeList then
			for id,value in pairs(completeList) do
				local completed = value:getCompleted()
				local flag = value:getFlag()
				if(completed == 1 and flag == false) then			
					return true
				end
			end	
		end			
	end	
	return false
end

function AchievementMgr:getExchangeMedalNpcPos()
	local sceneData = GameData.Scene["S002"]
	if sceneData then
		local npcList = sceneData.npc
		if npcList then
			for i,v in pairs(npcList) do
				if v.npcRefId == "npc_16" then
					return v.x,v.y
				end
			end
		end
	end
end


function AchievementMgr:getShowPageAndCell()
	local completeList = {}
	local showPage = 1
	local showCellIndex = 1
	local needBreak = false
	for i=1,6 do
		completeList = self:getCompletedContainerByType(i)		
		for id,value in pairs(completeList) do
			--completed是否完成，flag是否领取
			if(value.completed == 1 and value.flag == false) then
				showPage = i
				showCellIndex = id
				needBreak = true
				break
			end
		end
		if needBreak then
			break
		end			
	end
	return showPage , showCellIndex
end

function AchievementMgr:getFirstCompletedWithoutRewardedAchievementIdByPage(page)
	local completeList = self:getCompletedContainerByType(page)	
	for id,value in pairs(completeList) do
		if(value.completed == 1 and value.flag == false) then
			return id
		end
	end
	return nil
end

function AchievementMgr:hasNewAchieveByPage(page)
	local completeList = self:getCompletedContainerByType(page)	
	for id,value in pairs(completeList) do
		local completed = value:getCompleted()
		local flag = value:getFlag()
		if(completed == 1 and flag == false) then
			return true
		end		
	end
	return false
end

function AchievementMgr:hasClearAchieveByPage(page)
	local completeList = self:getCompletedContainerByType(page)	
	for id,value in pairs(completeList) do
		local completed = value:getCompleted()
		local flag = value:getFlag()
		if(completed == 0 or flag == false) then
			return false
		end
	end
	return true
end	