require("common.BaseObj")

TeamObject = TeamObject or BaseClass(BaseObj)

function TeamObject:__init()	
	self.status = 1
	self.profession = 1	
end

function TeamObject:__delete()

end

--发起邀请玩家id
function TeamObject:setInvitePlayerId(id)
	if id == nil then
		return nil
	end
	self.InvitePlayerId = id
end

function TeamObject:getInvitePlayerId()
	return self.InvitePlayerId
end

--发起邀请玩家名字
function TeamObject:setInvitePlayerName(Name)
	if Name == nil then
		return nil
	end
	self.InvitePlayerName = Name
end

function TeamObject:getInvitePlayerName()
	return self.InvitePlayerName
end

--发起邀请玩家等级
function TeamObject:setInvitePlayerLevel(Level)
	if Level == nil then
		return nil
	end
	self.InvitePlayerLevel = Level
end

function TeamObject:getInvitePlayerLevel()
	return self.InvitePlayerLevel
end

--玩家组队状态（1:其他队2:已经是你的的队员3:未组队）
function TeamObject:setPlayerTeamStateType(state)
	if state == nil then
		return nil
	end
	self.playerTeamStateType = state
end

function TeamObject:getPlayerTeamStateType()
	return self.playerTeamStateType
end

--被邀请玩家返回状态(1:放弃（玩家30秒没有响应）,2: 通过加入队伍 3:拒绝加入队伍)
function TeamObject:setPlayerActionType(Type)
	if Type == nil then
		return nil
	end
	self.PlayerActionType = Type
end

function TeamObject:getPlayerActionType()
	return self.PlayerActionType
end	

function TeamObject:setTeamMemberId(TeamMemberId)
	if TeamMemberId == nil then
		return nil
	end
	self.TeamMemberId = TeamMemberId
end

function TeamObject:getTeamMemberId()
	return self.TeamMemberId
end	

function TeamObject:setTeamMemberName(TeamMemberName)
	if TeamMemberName == nil then
		return nil
	end
	self.TeamMemberName = TeamMemberName
end

function TeamObject:getTeamMemberName()
	return self.TeamMemberName
end	

function TeamObject:setTeamMemberMaxHP(TeamMemberMaxHP)
	if TeamMemberMaxHP == nil then
		return nil
	end
	self.TeamMemberMaxHP = TeamMemberMaxHP
end

function TeamObject:getTeamMemberMaxHP()
	return self.TeamMemberMaxHP
end	

function TeamObject:setTeamMemberHP(TeamMemberHP)
	if TeamMemberHP == nil then
		return nil
	end
	self.TeamMemberHP = TeamMemberHP
end

function TeamObject:getTeamMemberHP()
	return self.TeamMemberHP
end	

--ttype 1 为邀请  2为申请
function TeamObject:setInviteType(ttype)
	self.inviteType = ttype
end

function TeamObject:getInviteType()
	return self.inviteType
end

--队员状态  1在线    2离线     3死亡
function TeamObject:setTeamMemberStatus(status)
	self.status = status
end

function TeamObject:getTeamMemberStatus()
	return self.status
end

--队员职业  1战士    2法师     3道士
function TeamObject:setTeamMemberProfession(profession)
	self.profession = profession
end

function TeamObject:getTeamMemberProfession()
	return self.profession
end

--队员性别  1男   2女
function TeamObject:setTeamMemberGender(gender)
	self.gender = gender
end	

function TeamObject:getTeamMemberGender()
	return self.gender
end

--队员场景位置
function TeamObject:setSceneId(sceneRefId)
	self.sceneId = sceneRefId
end

function TeamObject:getSceneId()
	return self.sceneId
end

--队员位置X
function TeamObject:setPositionX(x)
	self.posX = x
end

function TeamObject:getPositionX()
	return self.posX
end

--队员位置Y
function TeamObject:setPositionY(y)
	self.posY = y
end

function TeamObject:getPositionY()
	return self.posY
end
