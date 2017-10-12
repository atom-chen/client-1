HandupMsg = HandupMsg or BaseClass()

function HandupMsg:__init()
	
end

function HandupMsg:__delete()
	
end

function HandupMsg:setType(ttype)
	self.type = ttype
end

function HandupMsg:getType()
	return self.type
end

function HandupMsg:setExtraInfo(extraInfo)
	self.extraInfo = extraInfo
end

function HandupMsg:getExtraInfo()
	return self.extraInfo
end	