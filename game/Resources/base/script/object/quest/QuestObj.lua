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

--����id
function QuestObj:setQuestId(id)
	self.questId = id
end

function QuestObj:getQuestId()
	return self.questId
end

--��������
function QuestObj:setQuestType(questType)
	self.questType = questType
end

function QuestObj:getQuestType()
	return self.questType
end

--����״̬
function QuestObj:setQuestState(questState)
	self.questState = questState
end

function QuestObj:getQuestState()
	return self.questState
end	

--Ŀ������
function QuestObj:setOrderNumber(num)
	self.orderNumber = num
end

function QuestObj:getOrderNumber()
	return self.orderNumber
end	

--����
function QuestObj:setNumber(orderIndex,num)
	self.number[orderIndex] = num	
end

function QuestObj:getNumber(orderIndex)
	return self.number[orderIndex]
end	

--�ճ�����
function QuestObj:setDailyRing(num)
	self.dailyNumber = num	
end

function QuestObj:getDailyRing(orderIndex)
	return self.dailyNumber
end	

--�ճ���������
function QuestObj:setDailyQuestType(questType)
	self.dailyQuestType  = questType	
end

function QuestObj:getDailyQuestType()
	return self.dailyQuestType
end	

--�ճ����񸽼�����
function QuestObj:setDailyQuestSubType(questId)
	local questType = QuestRefObj:getStaticDailyQusetSubType(questId)
	self.dailyQuestSubType  = questType	
end

function QuestObj:getDailyQuestSubType()
	return self.dailyQuestSubType
end	

--�ճ��ȼ�
function QuestObj:setDailyLevel(level)
	self.dailyLevel = level	
end

function QuestObj:getDailyLevel()
	return self.dailyLevel
end	

--Ŀ������
function QuestObj:setOrderType(i,oType)
	self.orderType[i] = oType	
end

function QuestObj:getOrderType(i)
	return self.orderType[i]
end

--���Ŀ��
function QuestObj:setRandomOrderType(oType)
	self.randomOrderType = oType	
end

function QuestObj:getRandomOrderType()
	return self.randomOrderType
end	


--��������ʱ��
function QuestObj:setTime(time)
	self.time = time
end

function QuestObj:getTime()
	return self.time
end