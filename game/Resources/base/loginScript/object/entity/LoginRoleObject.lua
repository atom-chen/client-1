require("common.BaseObj")

LoginRoleObject = LoginRoleObject or BaseClass(BaseObj)

function LoginRoleObject:__init()
	
end

--人物id
function LoginRoleObject:setCharacterId(id)
	self.characterId = id
end

function LoginRoleObject:getCharacterId()
	return self.characterId
end

--人物名称
function LoginRoleObject:setName(name)
	self.name = name
end

function LoginRoleObject:getName()
	return self.name
end

--人物职业
function LoginRoleObject:setProfession(profession)
	self.profession = profession
end

function LoginRoleObject:getProfession()
	return self.profession
end

--人物性别
function LoginRoleObject:setGender(gender)
	self.gender = gender
end

function LoginRoleObject:getGender()
	return self.gender
end

--人物等级
function LoginRoleObject:setLevel(level)
	self.level = level
end

function LoginRoleObject:getLevel()
	return self.level
end