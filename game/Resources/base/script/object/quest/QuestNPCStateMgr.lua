require("common.baseclass")
--[[
	self.npcQuestStateList[npcListKey][questId]
	npcListKey:��npcList��key��Ϊkey.����һ��npc���ϵ���������
	questId:����һ��npc������ӵ�е�����id
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

--��������npc״̬
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

--������������������npc״̬
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
--����Ϊ˽�з���

--ɾ��ָ��NPCͷ��״̬
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

--����NPC״̬
function QuestNPCStateMgr:updateNPCState(npcListKey,state)
	if not npcListKey or not state then
		return
	end
	
	local npcList = GameWorld.Instance:getEntityManager():getNPCList()
	local npcObj = npcList[npcListKey]
	if npcObj then				
		npcObj:onUpdateQuestState(state)--��������״̬
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

--��ȡ��Ҫ���õ�NPC refid�ͳ���
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
	if qState == QuestState.eAcceptableQuestState then--����ɽ�
		npcState = "acceptNpc"		
	elseif qState == QuestState.eAcceptedQuestState or --�����ѽӣ���δ���
		qState == QuestState.eSubmittableQuestState then --�����Ѿ����ύ������û�ύ
				
		npcState = "submitNpc"
	end
	
	if not npcState then
		return
	end
	
	npcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,npcState)
	mapRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,npcState)	
	
	return npcRefId,mapRefId
end	

--��ȡ��Ҫ�����NPC refid�ͳ���
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
	
	if qState == QuestState.eAcceptedQuestState or --�����ѽӣ���δ���
		qState == QuestState.eSubmittableQuestState then--�����Ѿ����ύ������û�ύ
				
		npcState = "acceptNpc"
	elseif qState == QuestState.eCompletedQuestState then --�����Ѿ���ɡ��Ѿ��ύ��ȡ����
		npcState = "submitNpc"
	end
	
	if not npcState then
		return
	end
	
	npcRefId = QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,npcState)
	mapRefId = QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,npcState)	
	
	return npcRefId,mapRefId
end

--��ȡ�������ͺ�״̬
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

--��ȡ�Զ���npcList�б�
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

--����npc״̬�߼�����
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

