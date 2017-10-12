require ("common.BaseObj")
require ("data.achievement.achievement")

ConditionObject = ConditionObject or BaseClass(BaseObj)

function ConditionObject:__init()
	
end

function ConditionObject:__delete()
	
end

function ConditionObject:setCompleted(completed)
	self.completed = completed
end
function ConditionObject:setFlag(flag)
	self.flag = flag
end
function ConditionObject:setRefId(refId)
	self.refId = refId
end
function ConditionObject:setNextFlag(nextFlag)
	self.nextFlag = nextFlag
end

function ConditionObject:getCompleted()
	if self.completed then
		return self.completed
	end
end
function ConditionObject:getFlag()
	if self.flag~= nil then
		return self.flag
	end
end
function ConditionObject:getRefId()
	if self.refId then
		return self.refId
	end
end
function ConditionObject:getNextFlag()
	if self.nextFlag ~= nil then
		return self.nextFlag
	end
end