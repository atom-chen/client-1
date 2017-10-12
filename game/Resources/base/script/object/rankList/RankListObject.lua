require("common.baseclass")
require("common.BaseObj")

RankListObject = RankListObject or BaseClass(BaseObj)

function RankListObject:__init()

end

function RankListObject:__delete()
	
end

function RankListObject:setRefId(refId)
	self.refId = refId
end

function RankListObject:getRefId()
	return self.refId
end

function RankListObject:setLevel(level)
	self.level = level
end

function RankListObject:getLevel()
	return self.level
end

function RankListObject:setNickName(nickName)
	self.nickName = nickName
end

function RankListObject:getNickName()
	return self.nickName
end

function RankListObject:setProfession(profession)
	self.profession = profession
end

function RankListObject:getProfession()
	return self.profession
end

function RankListObject:setData(data)
	self.data = data
end

function RankListObject:getData()
	return self.data
end

function RankListObject:getProperty(propertyName)
	return self[propertyName]
end
