require("common.BaseObj")

StrengthenQusetObj = StrengthenQusetObj or BaseClass(BaseObj)

function StrengthenQusetObj:__init()
	self.number = {}	
	self.orderType = {}
end	

--����id
function StrengthenQusetObj:setQuestId(id)
	self.questId = id
end

function StrengthenQusetObj:getQuestId()
	return self.questId
end

--��������
function StrengthenQusetObj:setQuestType(questType)
	self.questType = questType
end

function StrengthenQusetObj:getQuestType()
	return self.questType
end

--����״̬
function StrengthenQusetObj:setQuestState(questState)
	self.questState = questState
end

function StrengthenQusetObj:getQuestState()
	return self.questState
end	

--����
function StrengthenQusetObj:setNumber(orderIndex,num)
	self.number[orderIndex] = num	
end

function StrengthenQusetObj:getNumber(orderIndex)
	return self.number[orderIndex]
end	

