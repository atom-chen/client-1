--技能效果
require("common.baseclass")

SkillEffect = SkillEffect or BaseClass(BaseObj)

--技能特效类型类型
E_SkillEffectType = 	
{
	Miss = 0,	
	HP = 1,
	Criti = 2,
	Dead = 3,
	Fortune = 4,
	Transport = 5,
	Addblood = 6,
	Keeptime =7,
	Sumon = 8
}


function SkillEffect:__init()
	
end

function SkillEffect:__delete()
	
end

--作用在谁身上
function SkillEffect:setOwner(entityType, serverId)
	self.entityType = entityType
	self.serverId = serverId
end

function SkillEffect:getEntityType()
	return self.entityType
end

function SkillEffect:getServerId()
	return self.serverId
end
	
function SkillEffect:setSkillRefId(refId)
	self.refId = refId
end

function SkillEffect:getRefId()
	return self.refId
end

function SkillEffect:setType(ttype)
	self.type = ttype
end

function SkillEffect:getType()
	return self.type
end

function SkillEffect:getEffectParam()
	return self.effectParam
end

function SkillEffect:setEffectParam(effectParam)
	self.effectParam = effectParam
end