require("actionEvent.ActionEventDef")
--require ("data.team.team")
TeamMgr = TeamMgr or BaseClass()

function TeamMgr:__init()
	self.scheduleList = {}
	self.teamInviteList = {}
	self.team = {}
	self.myTeamId = nil
	self.teamList = {
--[[		[1] ={teamNum = 10001,teamId = 100001,levelChoice = 55,teamMember = 2,averageLevel = 35},
		[2] ={teamNum = 10002,teamId = 100002,levelChoice = 40,teamMember = 1,averageLevel = 40},
		[3] ={teamNum = 10003,teamId = 100003,levelChoice = 50,teamMember = 3,averageLevel = 45},
		[4] ={teamNum = 10004,teamId = 100004,levelChoice = 60,teamMember = 2,averageLevel = 50},
		[5] ={teamNum = 10005,teamId = 100005,levelChoice = 70,teamMember = 2,averageLevel = 55},
		[6] ={teamNum = 10006,teamId = 100006,levelChoice = 80,teamMember = 2,averageLevel = 60},--]]
	}	
	self.needGetPosition = true		
end

function TeamMgr:__delete()
	self:clear()
end

function TeamMgr:clear()
	if self.teamInviteList then
		for _,v in pairs(self.teamInviteList) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.teamInviteList = {}
	end

	for k ,v in pairs(self.scheduleList)  do
		if v then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v)
			v = nil		
		end
	end
	self.scheduleList = {}
	if self.team then
		for _,v in pairs(self.team) do
			if v then
				v:DeleteMe()
			end
		end
		self.team = {}
	end
	if self.teamObj then
		self.teamObj:DeleteMe()
		self.teamObj = nil
	end
	if self.teamMemberDetailsScheduleId then	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.teamMemberDetailsScheduleId)
		self.teamMemberDetailsScheduleId =  nil	
	end	
	self.leaderId = nil
	self.myTeamId = nil	
	self.needGetPosition = false	
end

function TeamMgr:setNeedGetPosition(bNeed)
	self.needGetPosition = bNeed
end

function TeamMgr:getNeedGetPosition()
	return self.needGetPosition
end

function TeamMgr:requestPlayerTeamStatus(playerId) --请求玩家组队状态
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerInfoActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestAssembleTeam(playerId) --组队邀请
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_AssembleTeamActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end
	
function TeamMgr:requestJoinTeam(playerId,replyJoinTeamType) --组队受邀返回
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_JoinTeamActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	StreamDataAdapter:WriteChar(writer,replyJoinTeamType)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestLeaveTeam() --离开队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_LeaveTeamActionEvent)	
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestKickedOutTeam(playerId) --踢出队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_KickedOutTeamMemberActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestHandoverTeamLeader(playerId) --队长转移
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_HandoverTeamLeaderActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestDisbandTeam() --解散队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_DisbandTeamActionEvent)	
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestTeamSetting(playerId) --设置不接受组队邀请
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeamSettingActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestJoinBossTeam(teamId) --申请加入队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeam_JoinRequest)
	StreamDataAdapter:WriteStr(writer,teamId)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:replyTeamJoinRequest(playerId,replyJoinTeamType) --组队申请处理
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_JoinRequestReplyActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	StreamDataAdapter:WriteChar(writer,replyJoinTeamType)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestCreateTeam(limitLevelType) --创建队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeam_Create)
	StreamDataAdapter:WriteChar(writer,limitLevelType)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestModifyTeam(limitLevelType) --创建队伍
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeam_Modify)
	StreamDataAdapter:WriteChar(writer,limitLevelType)
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestBossTeamList() --请求副本队伍列表
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerTeam_InfomationEvent)	
	simulator:sendTcpActionEventInLua(writer)	
end

function TeamMgr:requestTeamMemberDetails() --请求副本队伍列表
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_TeamMember_Detail)	
	simulator:sendTcpActionEventInLua(writer)	
end
	
function TeamMgr:setTeamObject(teamObj)	
	if teamObj then
		if self.teamObj then
			self.teamObj:DeleteMe()
		end
		self.teamObj = teamObj
	end
end

function TeamMgr:getTeamObject()
	return self.teamObj
end	

function TeamMgr:setTeamInviteList(teamObj,inviteType)
	if teamObj then
		if self.scheduleList[teamObj:getInvitePlayerId() .. inviteType] ~= nil then --如果已经发起过邀请则不需要处理
			return 
		end
		if table.size(self.teamInviteList) <5 then		--限制邀请数量不大于5个
			table.insert(self.teamInviteList,teamObj)
			self:createDeleteInviteSchedule(teamObj,inviteType)
		else
			teamObj:DeleteMe()
			teamObj = nil
		end	
	end		
end

function TeamMgr:getTeamMemberById(playerId) 
	if playerId == nil then
		return
	end
	for j,v in ipairs(self.team) do
		if v:getTeamMemberId() == playerId then
			return v
		end
	end		
end

function TeamMgr:getTeamInviteList()
	return self.teamInviteList
end

function TeamMgr:removeTeamInviteList()
	self.teamInviteList = {}
end

function TeamMgr:removeTeamInvite(playerId,inviteType)
	if playerId == nil then
		return
	end
	for j,v in ipairs(self.teamInviteList) do	
		if v:getInvitePlayerId() == playerId and v:getInviteType() == inviteType then
			table.remove(self.teamInviteList,j)
		end
	end
	if self.scheduleList[playerId .. inviteType ] then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleList[playerId .. inviteType])
		self.scheduleList[playerId .. inviteType] = nil		
	end
	if table.size(self.teamInviteList) == 0 then
		GlobalEventSystem:Fire(GameEvent.EventSetTeamInviteBtnStatus,false)
	end
end

function TeamMgr:setTeam(teammate)
	if table.size(self.team) > 2 then
		return
	end	
		
	if teammate then
		for k ,v in pairs(self.team) do
			if v:getTeamMemberId() == teammate:getTeamMemberId() then
				return
			end
		end		
		table.insert(self.team,teammate)
		--如果在AOI范围内，则在小地图上显示
		local entityMgr = GameWorld.Instance:getEntityManager()
		local playObj = entityMgr:getEntityObject(EntityType.EntityType_Player, teammate:getTeamMemberId())
		GlobalEventSystem:Fire(GameEvent.EventAddTeammate, playObj)
		
		local function sortFunc(a,b)
			if a:getTeamMemberId() == self.leaderId then
				return true
			else
				return false
			end
		end	
		table.sort(self.team,sortFunc)		
	end
	if  table.size(self.team) > 0  then
		if not self.teamMemberDetailsScheduleId then
			local scheduleFunc = function()
				self:requestTeamMemberDetails()				
			end			
			self.teamMemberDetailsScheduleId =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleFunc, 5, false)					
		end
	end
end

function TeamMgr:getTeam()
	return self.team
end

function TeamMgr:removeTeamMember(teamMemberId)
	if teamMemberId == nil then
		return
	end
	for j,v in ipairs(self.team) do
		if v:getTeamMemberId() == teamMemberId then
			table.remove(self.team,j)
			v = nil
		end
	end
	if  table.size(self.team)  == 0  or  (table.size(self.team)  == 1  and self.team[1]:getTeamMemberId() == G_getHero():getId() )  then
		if self.teamMemberDetailsScheduleId then	
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.teamMemberDetailsScheduleId)
			self.teamMemberDetailsScheduleId =  nil	
		end
	end		
	
	--如果在小地图上，则从小地图中移除
	local entityMgr = GameWorld.Instance:getEntityManager()
	local playObj = entityMgr:getEntityObject(EntityType.EntityType_Player, teamMemberId)	
	GlobalEventSystem:Fire(GameEvent.EventRemoveTeammate, playObj)
end

function TeamMgr:removeTeam()
	for k , v  in pairs(self.team) do
		v:DeleteMe()
		v = nil
	end
	if self.teamMemberDetailsScheduleId then	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.teamMemberDetailsScheduleId)
		self.teamMemberDetailsScheduleId =  nil		
	end	
	self.team = {}	
	GlobalEventSystem:Fire(GameEvent.EventRemoveAllTeamate)
end

function TeamMgr:getTeammateNumber()
	if self.team then
		return table.size(self.team)
	end
end

function TeamMgr:setTeamLeaderId(leaderId)
	if leaderId then
		self.leaderId = leaderId		
		local function sortFunc(a,b)
			if a:getTeamMemberId() == self.leaderId then
				return true
			else
				return false
			end
		end	
		table.sort(self.team,sortFunc)				
	end	
end

function TeamMgr:getTeamLeaderId()
	return self.leaderId
end

function TeamMgr:getTeamInviteObjById(playerId)
	if playerId == nil then
		return nil
	end
	local inviteObj
	for j,v in ipairs(self.teamInviteList) do
		if v:getInvitePlayerId() == playerId then
			inviteObj = v
			return inviteObj
		end
	end
end

function TeamMgr:createDeleteInviteSchedule(inviteObj,inviteType)
	if inviteObj and inviteObj:getInvitePlayerId() then
		local scheduleKey =  inviteObj:getInvitePlayerId() .. inviteType
		local deleteFunc = function ()	
			if inviteObj then
				GlobalEventSystem:Fire(GameEvent.EventReplyJoinTeam,inviteObj:getInvitePlayerId(),1 ,inviteObj:getInviteType())			
			end
			if self.scheduleList[scheduleKey] then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleList[scheduleKey])
				self.scheduleList[scheduleKey] = nil
			end			
		end
		self.scheduleList[scheduleKey] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(deleteFunc, 30, false)
	end
end

function TeamMgr:getTeamList()
	return self.teamList
end

function TeamMgr:initTeamList(size)
	self.teamList = {}
	for i = 1 , size do
		self.teamList[i] = {}
	end
end

function TeamMgr:isTeamExist(teamName)
	for k,v in pairs(self.teamList) do
		if tostring(v.teamName) == tostring(teamName) then
			return true	,v.teamId		
		end
	end
	return false
end

function TeamMgr:joinTeamWithCheck(teamName)
	local isExist , teamId = self:isTeamExist(teamName) 
	if isExist and teamId then
		self:setRequestJoinTeamId(teamId)
		self:requestJoinBossTeam(teamId)
		return 0
	else
		return  1
	end
end	

function TeamMgr:setRequestJoinTeamId(teamId)
	self.requestJoinTeamId = teamId
end

function TeamMgr:getRequestJoinTeamId()
	return self.requestJoinTeamId
end

function TeamMgr:setMyTeamId(teamId)
	self.myTeamId = teamId
end


function TeamMgr:getMyTeamId()
	return self.myTeamId
end

function TeamMgr:sortTeamList()
	if  table.size(self.teamList) < 2 then
		return
	end
	local sortTeamFunc = function(a,b)
		if a.teamId == self.myTeamId then
			return true
		else			
			return false		
		end
	end 
	table.sort(self.teamList,sortTeamFunc)
end

function TeamMgr:isMyTeamate(playerId)
	if self.team then
		for k,v in pairs(self.team) do
			if v:getTeamMemberId() == playerId then
				return true
			end
		end	
	end
	return false
end

