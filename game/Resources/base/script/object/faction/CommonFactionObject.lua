require ("common.BaseObj")

CommonFactionObject = CommonFactionObject or BaseClass(BaseObj)

function CommonFactionObject:__init()
	
end

function CommonFactionObject:__delete()
	
end

function CommonFactionObject:setRank(rank)
	self.rank = rank
end

function CommonFactionObject:setFactionName(factionName)
	self.factionName = factionName
end

function CommonFactionObject:setChairManName(chairManName)
	self.chairManName = chairManName
end

function CommonFactionObject:setMemNum(memNum)
	self.memNum = memNum
end

function CommonFactionObject:getRank()
	if self.rank then
		return self.rank
	end
end
function CommonFactionObject:getFactionName()
	if self.factionName then
		return self.factionName
	end
end
function CommonFactionObject:getChairManName()
	if self.chairManName then
		return self.chairManName
	end
end
function CommonFactionObject:getMemNum()
	if self.memNum then
		return self.memNum
	end
end