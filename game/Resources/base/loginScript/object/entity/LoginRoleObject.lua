require("common.BaseObj")

LoginRoleObject = LoginRoleObject or BaseClass(BaseObj)

function LoginRoleObject:__init()
	
end

--����id
function LoginRoleObject:setCharacterId(id)
	self.characterId = id
end

function LoginRoleObject:getCharacterId()
	return self.characterId
end

--��������
function LoginRoleObject:setName(name)
	self.name = name
end

function LoginRoleObject:getName()
	return self.name
end

--����ְҵ
function LoginRoleObject:setProfession(profession)
	self.profession = profession
end

function LoginRoleObject:getProfession()
	return self.profession
end

--�����Ա�
function LoginRoleObject:setGender(gender)
	self.gender = gender
end

function LoginRoleObject:getGender()
	return self.gender
end

--����ȼ�
function LoginRoleObject:setLevel(level)
	self.level = level
end

function LoginRoleObject:getLevel()
	return self.level
end