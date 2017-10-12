require ("common.BaseObj")

BuffStateObject = BuffStateObject or BaseClass(BaseObj)

function BuffStateObject:__init()
	self.stateId = 0
end

function BuffStateObject:__delete()

end

function BuffStateObject:setStateId(stateId)
	self.stateId = stateId
end