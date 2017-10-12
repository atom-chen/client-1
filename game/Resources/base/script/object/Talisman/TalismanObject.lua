require("common.baseclass")
require("common.BaseObj")

TalismanObject = TalismanObject or BaseClass(BaseObj)

function TalismanObject:__init()
	self.State = false
	self.index = -1
	self.id = ""
end

function TalismanObject:setState(state)
	self.ownState = state
end

function TalismanObject:getState()
	return self.ownState
end

function TalismanObject:setIndex(index)
	self.index = index
end

function TalismanObject:getIndex()
	return self.index
end

--[[function TalismanObject:setId(id)
	self.id = id
end

function TalismanObject:getId()
	return self.id
end	--]]

function TalismanObject:setRefId(refId)
	self.RefId =refId
end


function TalismanObject:getRefId()
	return self.RefId
end

function TalismanObject:setStatisticsStr(str)
	self.statisticsStr =str
end


function TalismanObject:getStatisticsStr()
	if self.statisticsStr then
		return self.statisticsStr
	else
		return " "
	end
end