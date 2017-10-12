require("common.baseclass")
--[[
	self.npcQuestStateList[npcListKey][questId]
	npcListKey:以npcList的key作为key.保存一个npc身上的任务数据
	questId:对于一个npc身上所拥有的任务id
--]]

QuestNPCStateMgr = QuestNPCStateMgr or BaseClass()

function QuestNPCStateMgr:__init()
	self.npcQuestStateList = {}
	self.saveNpcList = {}
end

function QuestNPCStateMgr:__delete()
	self:clear()	
end

function QuestNPCStateMgr:clear()
	self.npcQuestStateList = {}
	self.saveNpcList = {}
end

--更新任务npc状态
function QuestNPCStateMgr:setUpdateNpcQuestState(questId)
	local questObj = G_getQuestMgr():getQuestObj(questId)
	if not questObj then
		return
	end
		
	local deletenpcRefId,deletemapRefId = self:getEmptyStateNpc(questId)
	if deletenpcRefId and deletemapRefId then
		self:setNPCState(questId,deletenpcRefId,deletemapRefId,QuestState.eUnvisiableQuestState)
	end
	
	local setnpcRefId,setmapRefId = self:getUnEmptyStateNpc(questId)
	if setnpcRefId and setmapRefId then
		local qState = questObj:getQuestState()
		self:setNPCState(questId,setnpcRefId,setmapRefId,qState)
	end
end

--跳场景更新所有任务npc状态
function QuestNPCStateMgr:setAllUpdateNpcQuestState()
	self:clearSaveNPCList()
	local sNpcList = self:getNPCListToRefId()
	self:clear()
	local questList = G_getQuestMgr():getQuestList()
	local questListSize = table.size(questList)
	for i=questListSize,1,-1 do
		local questObj = questList[i]
		if questObj then
			local questId = questObj:getQuestId()
			local questState = questObj:getQuestState()	
			local npcRefId,mapRefId = self:getUnEmptyStateNpc(questId)
			if npcRefId and mapRefId then
				local npcList = GameWorld.Instance:getEntityManager():getNPCList()
				local currentMapRefId = GameWorld.Instance:getMapManager():getCurrentMapRefId()
				if currentMapRefId==mapRefId then								
					local key = sNpcList[npcRefId]
					local npcObj = npcList[key]
					if npcObj then
						self:setNpcQuestState(questId,key,questState)
					end							
				else
					local key = sNpcList[npcRefId]
					local npcObj = npcList[key]
					if npcObj then
						self:updateNPCState(key,QuestState.eUnvisiableQuestState)
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------
--以下为私有方法

--删除指定NPC头顶状态
function QuestNPCStateMgr:deleteNPCStateListByQuestId(npcListKey,questId)
	if not npcListKey or not questId then
		return
	end
	
	if self.npcQuestStateList[npcListKey] and self.npcQuestStateList[npcListKey][questId] then	
		self.npcQuestStateList[npcListKey][questId] = nil
	end
	
	local npcQuestStateListSize = table.size(self.npcQuestStateList[npcListKey])
	if npcQuestStateListSize == 0 then	
		self.npcQuestStateList[npcListKey] = nil
	end
end	

--更新NPC状态
function QuestNPCStateMgr:updateNPCState(npcListKey,state)
	if not npcListKey or not state then
		return
	end
	
	local npcList = GameWorld.Instance:getEntityManager():getNPCList()
	local npcObj = npcList[npcListKey]
	if npcObj then				
		npcObj:onUpdateQuestState(state)--设置任务状态
	end	
end


function QuestNPCStateMgr:setNPCState(questId,npcRefId,mapRefId,qState)
	if not questId or not npcRefId or not mapRefId or not qState then
		return
	end
	
	local currentMapRefId = GameWorld.Instance:getMapManager():getCurrentMapRefId()
	if currentMapRefId==mapRefId then
		local sNpcList = self:getNPCListToRefId()
		local key = sNpcList[npcRefId]
		if key then
			local npcList = GameWorld.Instance:getEntityManager():getNPCList()
			local npcObj = npcList[key]
			if npcObj then
				self:setNpcQuestState(questId,key,qState)
			end
		end
	end
end

--获取需要设置的NPC refid和场景
function QuestNPCStateMgr:getUnEmptyStateNpc(questId)
	if not questId then
		return
	end
	
	local qType,qState = self:getQuestTypeAndState(questId)
	if not qType or not qState then
		return
	end
	
	local  npcRefId,mapRefId
	
	local npcState = nil
	if qState == QuestState.eAcceptableQuestState then--任务可接
		npcState = "acceptNpc"		
	elseif qState == QuestState.eAcceptedQuestState or --任务已接，但未完成
		qState == QuestState.eSubmittableQuestState then --任务已经可提交。但还没提交
				
		npcState = "submitNpc"
	end
	
	if not npcState then
		return
	end
	
	npcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,npcState)
	mapRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,npcState)	
	
	return npcRefId,mapRefId
end	

--获取需要清除的NPC refid和场景
function QuestNPCStateMgr:getEmptyStateNpc(questId)
	if not questId then
		return
	end
	
	local qType,qState = self:getQuestTypeAndState(questId)
	if not qType or not qState then
		return
	end
	
	local  npcRefId,mapRefId
	
	local npcState = nil
	
	if qState == QuestState.eAcceptedQuestState or --任务已接，但未完成
		qState == QuestState.eSubmittableQuestState then--任务已经可提交。但还没提交
				
		npcState = "acceptNpc"
	elseif qState == QuestState.eCompletedQuestState then --任务已经完成。已经提交领取奖励
		npcState = "submitNpc"
	end
	
	if not npcState then
		return
	end
	
	npcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,npcState)
	mapRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,npcState)	
	
	return npcRefId,mapRefId
end

--获取任务类型和状态
function QuestNPCStateMgr:getQuestTypeAndState(questId)
	if not questId then
		return
	end
	
	local questObj = G_getQuestMgr():getQuestObj(questId)
	if not questObj then
		return
	end
	
	local qType = questObj:getQuestType()
	local qState = questObj:getQuestState()
	return qType,qState
end

function QuestNPCStateMgr:clearSaveNPCList()
	self.saveNpcList = {}
end

--获取自定义npcList列表
function QuestNPCStateMgr:getNPCListToRefId()
	if table.size(self.saveNpcList)==0 then
		self.saveNpcList = {}
		local npcList = GameWorld.Instance:getEntityManager():getNPCList()
		for i,v in pairs(npcList) do
			local npcRefId= v:getRefId()
			self.saveNpcList[npcRefId] = i
		end	
	end
	return self.saveNpcList
end

--设置npc状态逻辑处理
function QuestNPCStateMgr:setNpcQuestState(questId,npcListKey,state)
	if not questId or not npcListKey or not state then
		return
	end
	
	local statelist = self.npcQuestStateList[npcListKey]
	if statelist then	
		if state==QuestState.eUnvisiableQuestState then
			if table.size(statelist)>=2 then
				self:deleteNPCStateListByQuestId(npcListKey,questId)
				local lstate = self.npcQuestStateList[npcListKey]
				for i,v in pairs(lstate) do
					if not maxState or v>maxState then
						maxState = v
					end
				end	
				state = maxState
				
				self:updateNPCState(npcListKey,state)
			else
				self:deleteNPCStateListByQuestId(npcListKey,questId)
				self:updateNPCState(npcListKey,state)		
			end
		else
			local lstate = statelist[questId]
			if lstate ~= state then
				local savestatelist = self.npcQuestStateList[npcListKey]
				savestatelist[questId] = state
				self.npcQuestStateList[npcListKey] = savestatelist
				
				self:updateNPCState(npcListKey,state)
			end
		end				
	else
		if state~=QuestState.eUnvisiableQuestState then
			local savestatelist = {}
			savestatelist[questId] = state
			self.npcQuestStateList[npcListKey] = savestatelist
			
			self:updateNPCState(npcListKey,state)
		end
	end
end

