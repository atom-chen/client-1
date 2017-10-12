require("common.BaseObj")


QuestObj = QuestObj or BaseClass(BaseObj)

function QuestObj:__init()
	self.number = {}
	self.orderType = {}		
end

function QuestObj:__delete()
	self.number = {}
	self.orderType = {}		
end

--任务id
function QuestObj:setQuestId(id)
	self.questId = id
end

function QuestObj:getQuestId()
	return self.questId
end

--任务类型
function QuestObj:setQuestType(questType)
	self.questType = questType
end

function QuestObj:getQuestType()
	return self.questType
end

--任务状态
function QuestObj:setQuestState(questState)
	self.questState = questState
end

function QuestObj:getQuestState()
	return self.questState
end	

--目标数量
function QuestObj:setOrderNumber(num)
	self.orderNumber = num
end

function QuestObj:getOrderNumber()
	return self.orderNumber
end	

--数量
function QuestObj:setNumber(orderIndex,num)
	self.number[orderIndex] = num	
end

function QuestObj:getNumber(orderIndex)
	return self.number[orderIndex]
end	

--日常环数
function QuestObj:setDailyRing(num)
	self.dailyNumber = num	
end

function QuestObj:getDailyRing(orderIndex)
	return self.dailyNumber
end	

--日常任务类型
function QuestObj:setDailyQuestType(questType)
	self.dailyQuestType  = questType	
end

function QuestObj:getDailyQuestType()
	return self.dailyQuestType
end	

--日常任务附加类型
function QuestObj:setDailyQuestSubType(questId)
	local questType = QuestRefObj:getStaticDailyQusetSubType(questId)
	self.dailyQuestSubType  = questType	
end

function QuestObj:getDailyQuestSubType()
	return self.dailyQuestSubType
end	

--日常等级
function QuestObj:setDailyLevel(level)
	self.dailyLevel = level	
end

function QuestObj:getDailyLevel()
	return self.dailyLevel
end	

--目标类型
function QuestObj:setOrderType(i,oType)
	self.orderType[i] = oType	
end

function QuestObj:getOrderType(i)
	return self.orderType[i]
end

--随机目标
function QuestObj:setRandomOrderType(oType)
	self.randomOrderType = oType	
end

function QuestObj:getRandomOrderType()
	return self.randomOrderType
end	


--副本任务时间
function QuestObj:setTime(time)
	self.time = time
end

function QuestObj:getTime()
	return self.time
end