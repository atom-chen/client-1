require("common.baseclass")
require("common.BaseObj")
require("object.friend.FriendDef")

FriendObject = FriendObject or BaseClass()

function FriendObject:__init()
	
end		

-- ���ú������ͣ���Ӧ��FriendDef���FriendType
--[[
FriendType = 
{
	eNormal = 0, 		--����
	eInBlackList = 1,  	--������
}	
--]]
function FriendObject:setType(typetype)
	self.type = typetype	
end

function FriendObject:getType()
	return self.type
end	

function FriendObject:setId(id)
	self.id = id
end	

function FriendObject:getId()
	return 	self.id
end

function FriendObject:setName(name)
	self.name = name
end	

function FriendObject:getName()
	return self.name
end	

function FriendObject:setLevel(level)
	self.level = level
end	

function FriendObject:getLevel()
	return self.level
end	

function FriendObject:setProfession(prof)
	self.profession = prof
end	

function FriendObject:getProfession()
	return self.profession
end	

--ְҵ�ȼ�����
function FriendObject:setProfessionRank(rank)
	self.professionRank = rank
end	

function FriendObject:getProfessionRank()
	return self.professionRank
end	

--��Ӫ
function FriendObject:setCamp(camp)
	self.camp = camp
end

function FriendObject:getCamp()
	return self.camp
end

function FriendObject:setFightPower(fightValue)
	self.fightValue = fightValue
end	

function FriendObject:getFightPower()
	return self.fightValue
end	

-- ���ˣ���ʵ�ڲ�֪��Ӣ�Ľ�ʲô��
function FriendObject:setXianMeng(xm)
	self.xianmeng = xm
end	

function FriendObject:getXianMeng()
	return self.xianmeng
end	

-- ��żid
function FriendObject:setSpouseId(id)
	self.spouseId = id
end		

function FriendObject:getSpouseId()
	return  self.spouseId
end		

function FriendObject:setSpouseName(name)
	self.spouseName = name
end		

function FriendObject:getSpouseName()
	return self.spouseName
end		

function FriendObject:setIsOnline(online)
	self.isOnline = online
end		

function FriendObject:getIsOnline()
	return  self.isOnline
end	

-- ���ܶ�
function FriendObject:setIntimacy(intimacy)
	self.intimacy = intimacy
end	

function FriendObject:getIntimacy()
	return self.intimacy
end			

function FriendObject:setLastLoginTime(time)
	self.lastLoginTime = time
end

function FriendObject:getLastLoginTime(time)
	self.lastLoginTime = time
end				

function FriendObject:setSex(sex)
	self.sex = sex
end		

function FriendObject:getSex(sex)
	self.sex = sex
end		

function FriendObject:setIsSelected(selected)
	self.isSelected = selected
end	

function FriendObject:getIsSelected(selected)
	self.isSelected = selected
end	