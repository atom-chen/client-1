require("common.BaseObj")

TeamObject = TeamObject or BaseClass(BaseObj)

function TeamObject:__init()	
	self.status = 1
	self.profession = 1	
end

function TeamObject:__delete()

end

--�����������id
function TeamObject:setInvitePlayerId(id)
	if id == nil then
		return nil
	end
	self.InvitePlayerId = id
end

function TeamObject:getInvitePlayerId()
	return self.InvitePlayerId
end

--���������������
function TeamObject:setInvitePlayerName(Name)
	if Name == nil then
		return nil
	end
	self.InvitePlayerName = Name
end

function TeamObject:getInvitePlayerName()
	return self.InvitePlayerName
end

--����������ҵȼ�
function TeamObject:setInvitePlayerLevel(Level)
	if Level == nil then
		return nil
	end
	self.InvitePlayerLevel = Level
end

function TeamObject:getInvitePlayerLevel()
	return self.InvitePlayerLevel
end

--������״̬��1:������2:�Ѿ�����ĵĶ�Ա3:δ��ӣ�
function TeamObject:setPlayerTeamStateType(state)
	if state == nil then
		return nil
	end
	self.playerTeamStateType = state
end

function TeamObject:getPlayerTeamStateType()
	return self.playerTeamStateType
end

--��������ҷ���״̬(1:���������30��û����Ӧ��,2: ͨ��������� 3:�ܾ��������)
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

--ttype 1 Ϊ����  2Ϊ����
function TeamObject:setInviteType(ttype)
	self.inviteType = ttype
end

function TeamObject:getInviteType()
	return self.inviteType
end

--��Ա״̬  1����    2����     3����
function TeamObject:setTeamMemberStatus(status)
	self.status = status
end

function TeamObject:getTeamMemberStatus()
	return self.status
end

--��Աְҵ  1սʿ    2��ʦ     3��ʿ
function TeamObject:setTeamMemberProfession(profession)
	self.profession = profession
end

function TeamObject:getTeamMemberProfession()
	return self.profession
end

--��Ա�Ա�  1��   2Ů
function TeamObject:setTeamMemberGender(gender)
	self.gender = gender
end	

function TeamObject:getTeamMemberGender()
	return self.gender
end

--��Ա����λ��
function TeamObject:setSceneId(sceneRefId)
	self.sceneId = sceneRefId
end

function TeamObject:getSceneId()
	return self.sceneId
end

--��Աλ��X
function TeamObject:setPositionX(x)
	self.posX = x
end

function TeamObject:getPositionX()
	return self.posX
end

--��Աλ��Y
function TeamObject:setPositionY(y)
	self.posY = y
end

function TeamObject:getPositionY()
	return self.posY
end
