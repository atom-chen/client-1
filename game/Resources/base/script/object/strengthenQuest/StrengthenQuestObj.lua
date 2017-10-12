require("common.BaseObj")

StrengthenQusetObj = StrengthenQusetObj or BaseClass(BaseObj)

function StrengthenQusetObj:__init()
	self.number = {}	
	self.orderType = {}
end	

--任务id
function StrengthenQusetObj:setQuestId(id)
	self.questId = id
end

function StrengthenQusetObj:getQuestId()
	return self.questId
end

--任务类型
function StrengthenQusetObj:setQuestType(questType)
	self.questType = questType
end

function StrengthenQusetObj:getQuestType()
	return self.questType
end

--任务状态
function StrengthenQusetObj:setQuestState(questState)
	self.questState = questState
end

function StrengthenQusetObj:getQuestState()
	return self.questState
end	

--数量
function StrengthenQusetObj:setNumber(orderIndex,num)
	self.number[orderIndex] = num	
end

function StrengthenQusetObj:getNumber(orderIndex)
	return self.number[orderIndex]
end	

