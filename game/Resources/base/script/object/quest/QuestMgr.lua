require("common.baseclass")
require("object.quest.QuestRefObj")
require("object.quest.QuestDef")
require("object.quest.recommendHandupRefObj")

QuestMgr = QuestMgr or BaseClass()

--环数 环内的优先级比环外高
DailyQuestRing = 
{
	outer = 1,--环外
	inner = 2,--环内
}

function QuestMgr:__init()
	self.QuesetList = {}
	--self.InatanceQuesetCount = 0
	
	self.requestQuestSchedulerId = -1 
	self.npcTalkViewQuestId = ""
	self.instanceRefId = nil	
	
	
	
	self.oldAcceptQuestId = ""
	self.oldFinishQuestId = ""
end

function QuestMgr:__delete()
	self:clear()
end

function QuestMgr:clear()
	if table.size(self.QuesetList)>0 then
		for _,v in pairs(self.QuesetList) do
			v:DeleteMe()			
		end
		self.QuesetList = {}
	end
	
	self.npcTalkViewQuestId = ""
	self.instanceRefId = nil	
	
	
	self:cancleReApply()
end

function QuestMgr:cancleReApply()
	self.reApply = false
	self:clearRequestQuestScheduler()
end

function QuestMgr:createRequestQuestScheduler()
	if self.requestQuestSchedulerId == -1 then
		if self.hideFunction == nil then
			self.hideFunction = function ()	
				self:clearRequestQuestScheduler()
				if self.reApply then
					self:requestQuestList()--发送任务列表请求		
				end					
			end
		end				
		self.requestQuestSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.hideFunction, 5, false)
	end	
end

function QuestMgr:clearRequestQuestScheduler()
	if self.requestQuestSchedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.requestQuestSchedulerId)
		self.requestQuestSchedulerId = -1
	end
end
----------------------------------------------------------------------------------------
function QuestMgr:findSameQuestIdIndexInQuestListByObj(obj)
	if not obj then
		return 0
	end

	local questId = obj:getQuestId()
	local questType = obj:getQuestType()
	if not questId and not questType then
		return 0
	end
	
	for i,v in pairs(self.QuesetList) do	
		local id = v:getQuestId()
		local ttype = v:getQuestType()
		if questType==ttype and questType==QuestType.eQuestTypeMain then
			return i
		else
			if questId==id then
				return i
			end
		end
	end	
	
	return 0
end

function QuestMgr:setQuestList(questObj)--设置任务列表
	if not questObj then
		return
	end
	
	local listSize = table.size(self.QuesetList)
	
	if listSize==0 then
		table.insert(self.QuesetList,questObj)
	elseif listSize>=0 then
		local index = self:findSameQuestIdIndexInQuestListByObj(questObj)
		if index==0 then
			table.insert(self.QuesetList,questObj)
		else
			if self.QuesetList[index] then
				self.QuesetList[index]:DeleteMe()
			end
			self.QuesetList[index] = questObj
		end
		--self:sortList()
	end
	
--[[	for i,v in pairs(self.QuesetList) do
		if v:getQuestId() == questObj:getQuestId() then
			
			if self.QuesetList[i] then
				self.QuesetList[i]:DeleteMe()
			end
			self.QuesetList[i] = questObj
			if questObj:getQuestState() == QuestState.eAcceptedQuestState then
				self:sortList()
			end
			return
		end
	end
	
	if questObj:getQuestType()==QuestType.eQuestTypeMain then
		table.insert(self.QuesetList,1,questObj)
	else
		table.insert(self.QuesetList,questObj)
	end
	self:sortList()--]]
end


function QuestMgr:getQuestList()--获取任务列表
	return self.QuesetList
end

function QuestMgr:getNewGuidelinesMainQuestId()--获取主线任务Id
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestType() == QuestType.eQuestTypeMain then
				if v:getQuestState() == QuestState.eAcceptedQuestState or v:getQuestState() == QuestState.eSubmittableQuestState then
					return v:getQuestId()
				end
			end
		end
	end
end

function QuestMgr:removeQuestList()--删除任务列表
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do		
			v:DeleteMe()
			self.QuesetList[i] = nil
		end
	end
	self.QuesetList = {}
	self.InatanceQuesetCount = 0
end

function QuestMgr:removeMianQuest()--删除主线任务
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestType() == QuestType.eQuestTypeMain then
				v:DeleteMe()
				self.QuesetList[i] = nil
				return
			end
		end
	end
end

function QuestMgr:removeQuest(questId)--删除指定任务
	if not questId then
		return
	end
	if table.size(self.QuesetList) ~= 0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestId() == questId then
				v:DeleteMe()
				self.QuesetList[i] = nil
				self:sortList()
				return
			end
		end
	end
end	

--任务列表排序
function QuestMgr:sortList()
	local sortTable = {}
	local sortIndex = 1
	for i,v in pairs(self.QuesetList) do
		sortTable[sortIndex] = v
		sortIndex = sortIndex + 1
	end
	self.QuesetList = sortTable
	
	
	local function sortLevelNameAsc(a, b)
		local questTypeA = a:getQuestType()
		local questTypeB = b:getQuestType()
		
		if questTypeA  and questTypeB and questTypeA  == questTypeB then --判断任务类型		
			if questTypeA == QuestType.eQuestTypeDaily then--日常任务
				local sort = self:sortDailyQuest(a,b)
				return sort
			else
				return false
			end	
		else
			if not questTypeA then
				return true
			elseif not questTypeB then
				return false
			else
				return  questTypeA < questTypeB
			end		
		end
	end		
	table.sort(self.QuesetList, sortLevelNameAsc)
end	
					
function QuestMgr:sortDailyQuest(a,b)
	local questStateA = a:getQuestState()	--A任务状态	
	local questStateB = b:getQuestState()	--B任务状态
		
	if questStateA and questStateB and questStateA == questStateB then						
		local ringA = self:getDailyQuestRing(a) --A任务环状态
		local ringB = self:getDailyQuestRing(b) --B任务环状态
		
		if ringA == ringB then --相同环状态
			local dailyQuestSubTypeA = a:getDailyQuestSubType() --A任务附加类型
			local dailyQuestSubTypeB = b:getDailyQuestSubType()	--B任务附加类型
			if dailyQuestSubTypeA and dailyQuestSubTypeB and dailyQuestSubTypeA == dailyQuestSubTypeB then--判断日常任务附加类型
				local priority = G_getQuestLogicMgr():levelPriority(a,b)--相同类型由
				return priority
			else
				if not dailyQuestSubTypeA then
					return true
				elseif not dailyQuestSubTypeB then
					return false
				else
					return dailyQuestSubTypeA < dailyQuestSubTypeB
				end	
			end	
		else
			if ringA>ringB then --A任务环状态优先
				return true
			else
				return false
			end
		end	
	else
		if not questStateA then
			return false
		elseif not questStateB then
			return true
		else
			return  questStateA > questStateB--任务类型相同，任务状态完成优先级高
		end		
	end
end

function QuestMgr:getDailyQuestRing(obj)
	if not obj then
		return nil
	end
	
	local ring = nil
	local nowRin = obj:getDailyRing() --B任务当前环数
	local maxRing = QuestRefObj:getStaticDailyQusetMaxRing(obj:getQuestId())--A任务最大环数
	
	if nowRin>maxRing then
		ring = DailyQuestRing.outer--环外
	else
		ring = DailyQuestRing.inner--环内
	end				
	
	return ring
end


--副本任务排序
function QuestMgr:instanceSortList()
	local function sortStateAsc(a, b)
		return  a:getQuestState() < b:getQuestState()--任务类型相同，任务状态完成优先级高
	end
	
	table.sort(self.QuesetList, sortStateAsc)
end

function QuestMgr:getMainQuestObj()
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestType() == QuestType.eQuestTypeMain then
				return v
			end
		end
	end
end

function QuestMgr:getQuestObj(questId)--获取任务对象
	if not questId then
		return
	end
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestId() == questId then
				return v
			end
		end
	end
end

function QuestMgr:getQuestObjState(questId)
	if not questId then
		return
	end
	local Obj = self:getQuestObj(questId)
	if Obj then
		return Obj:getQuestState()	
	end		
end

function QuestMgr:getMianQuestId()
	if table.size(self.QuesetList)~=0 then
		for i,v in pairs(self.QuesetList) do
			if v:getQuestType() == QuestType.eQuestTypeMain then
				return v:getQuestId()
			end
		end
	end
end


-----------------------------------------------------------------------------------
--NPC任务对话框任务信息
function QuestMgr:setNpcTalkViewInfo(npcId,questObj)
	self.npcTalkViewNpcId = npcId
	self.npcTalkViewQuestObj = questObj
end

function QuestMgr:getNpcTalkViewInfo()
	return self.npcTalkViewNpcId,self.npcTalkViewQuestObj
end

------------------------------------------------------------------------------------
--请求任务列表函数	
function QuestMgr:requestQuestList()
	self:reMainQuestQuestList()
	self:reDailyQuestQuestList()
	
	self.reApply = true
	self:createRequestQuestScheduler()
end
	
function QuestMgr:reMainQuestQuestList()--请求任务列表
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_GetQuestList)
	writer:WriteChar(1)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:requestAcceptQuest(questID)--接收任务
	if not questID then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_QuestAccept)
	StreamDataAdapter:WriteStr(writer,questID)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:requestSubmitQuest(questID)--完成任务
	if not questID then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_QuestSubmit)
	StreamDataAdapter:WriteStr(writer,questID)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:requestActionToSucceed(questID)--完成某项事件
	if not questID then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_COM_ActionToSucceed)
	StreamDataAdapter:WriteStr(writer,questID)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:reDailyQuestQuestList()--请求任务列表
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_GetDailyQuestList)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:reDailyQuestAcceptQuest(questID)--接收任务
	if not questID then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_DailyQuestAccept)
	StreamDataAdapter:WriteStr(writer,questID)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:reDailyQuestSubmitQuest(questID,count)--完成任务
	if not questID or not count then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_DailyQuestSubmit)
	StreamDataAdapter:WriteStr(writer,questID)
	writer:WriteChar(count)
	simulator:sendTcpActionEventInLua(writer)
end


function QuestMgr:reDailyFreshQuestLevel(questID)--刷新任务等级
	if not questID then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_DailyStartLevel)
	StreamDataAdapter:WriteStr(writer,questID)
	simulator:sendTcpActionEventInLua(writer)
end


function QuestMgr:requestInstanceTrans(questId,instanceId)--请求副本传送
	if not questId or not instanceId then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_QST_QuestInstanceTrans)
	writer:WriteString(questId)
	writer:WriteString(instanceId)
	simulator:sendTcpActionEventInLua(writer)
end

function QuestMgr:requestInstanceQuestList()
	if not self.instanceRefId then
		return
	end
	
	-- 服务器4.7才加上了这个协议，4.6暂时屏蔽
	--[[local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Instance_GetQuestList)
	writer:WriteString(self.instanceRefId)
	simulator:sendTcpActionEventInLua(writer)]]
end
-----------------------------------------------------------------------------------
	


--副本数据
function QuestMgr:setInstanceRefId(id)
	self.instanceRefId = id
end

function QuestMgr:removeInstanceRefId()
	self.instanceRefId = nil
end

function QuestMgr:getInstanceRefId()
	return self.instanceRefId
end



function QuestMgr:setInstanceRewordList(bInBag,list,time)
	self.inBag = bInBag
	self.instanceRewordList = list
	self.passInstanceTime = time
end

function QuestMgr:removeInstanceRewordList()
	self.inBag = nil
	self.instanceRewordList = {}
	self.passInstanceTime = nil
end

function QuestMgr:getInstanceRewordList()
	return self.inBag,self.instanceRewordList,self.passInstanceTime
end

function QuestMgr:setSceneLayer(refid)
	self.senceLayer = refid
end

function QuestMgr:getSceneLayer()
	return self.senceLayer
end

function QuestMgr:getQuestTitleNameWord(questRefId)
	if (not questRefId) then
		return
	end
	
	local titleword = ""
	local subType = QuestRefObj:getStaticDailyQusetSubType(questRefId)
	if subType==DailyQuestSubType.eDailyQuest then
		titleword = Config.Words[3115]
	elseif subType==DailyQuestSubType.eGoldQuest then
		titleword = Config.Words[3152]
	elseif subType==DailyQuestSubType.eMeritQuest then
		titleword = Config.Words[3153]
	end
	return titleword
end



--窗口管理
function QuestMgr:setQuestView_ClickQuestIndex(index)
	self.clickQuestIndex = index
end

function QuestMgr:getQuestView_ClickQuestIndex()
	return self.clickQuestIndex
end	

function QuestMgr:setOldMainAcceptQuestId(questId)
	self.oldAcceptQuestId = questId
end

function QuestMgr:getOldMainAcceptQuestId()
	return self.oldAcceptQuestId
end

function QuestMgr:setOldMainFinishQuestId(questId)
	self.oldFinishQuestId = questId
end

function QuestMgr:getOldMainFinishQuestId()
	return self.oldFinishQuestId
end



