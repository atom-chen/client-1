require ("common.BaseObj")
--公会成员对象
MemberObject = MemberObject or BaseClass(BaseObj)

function MemberObject:__init()
	
end

function MemberObject:__delete()
	
end

function MemberObject:setCharId(charId)
	self.charId = charId
end
function MemberObject:setMemName(memName)
	self.memName = memName
end
function MemberObject:setProfesssionId(professsionId)
	self.professsionId = professsionId
end
function MemberObject:setLevel(level)
	self.level = level
end
function MemberObject:setFightValue(fightValue)
	self.fightValue = fightValue
end
function MemberObject:setOffice(office)
	self.office = office
end
function MemberObject:setMemNum(memNum)
	self.memNum = memNum
end
function MemberObject:setOnline(online)
	self.online = online
end

function MemberObject:getCharId()
	if self.charId then
		return self.charId
	end
end

function MemberObject:getMemName()
	if self.memName then
		return self.memName
	end
end
function MemberObject:getProfesssionId()
	if self.professsionId then
		return self.professsionId
	end
end
function MemberObject:getLevel()
	if self.level then
		return self.level
	end
end
function MemberObject:getFightValue()
	if self.fightValue then
		return self.fightValue
	end
end
function MemberObject:getOffice()
	if self.office then
		return self.office
	end
end
function MemberObject:getMemNum()
	if self.memNum then
		return self.memNum
	end
end
function MemberObject:getOnline()
	if self.online then
		return self.online
	end
end
--增加或删除1=增加，2=删除
function MemberObject:setUpdateType(updateType)
	if updateType then
		self.updateType = updateType
	end
end

function MemberObject:getUpdateType()
	return self.updateType
end

--发起邀请玩家id
function MemberObject:setInvitePlayerId(id)
	if id == nil then
		return nil
	end
	self.InvitePlayerId = id
end

function MemberObject:getInvitePlayerId()
	return self.InvitePlayerId
end

--发起邀请玩家名字
function MemberObject:setInvitePlayerName(Name)
	if Name == nil then
		return nil
	end
	self.InvitePlayerName = Name
end

function MemberObject:getInvitePlayerName()
	return self.InvitePlayerName
end

--发起邀请玩家等级
function MemberObject:setInvitePlayerLevel(Level)
	if Level == nil then
		return nil
	end
	self.InvitePlayerLevel = Level
end

function MemberObject:getInvitePlayerLevel()
	return self.InvitePlayerLevel
end

--发起邀请公会名字
function MemberObject:setInviteFactionName(Name)
	if Name == nil then
		return nil
	end
	self.InviteFactionName = Name
end

function MemberObject:getInviteFactionName()
	return self.InviteFactionName
end


function MemberObject:setVipType(vipType)
	self.vipType = vipType
end

function MemberObject:getVipType()
	if self.vipType then
		return self.vipType
	end
end

function MemberObject:setOfflineTimeType(offlineTimeType)
	self.offlineTimeType = offlineTimeType
end

function MemberObject:getOfflineTimeType()
	return self.offlineTimeType
end

function MemberObject:setLogoutType(logoutType)
	self.logoutType = logoutType
end

function MemberObject:getLogoutType()
	return self.logoutType
end