require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require"object.team.TeamObject"
TeamActionHandler = TeamActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()

function TeamActionHandler:__init()
		
	local handleNet_G2C_requestPlayerTeamStatus  = function(reader)
		self:handleNet_G2C_requestPlayerTeamStatus(reader)
	end
	self:Bind(ActionEvents.G2C_PlayerInfoActionEvent ,handleNet_G2C_requestPlayerTeamStatus)
	
	local handleNet_G2C_requestAssembleTeam  = function(reader)
		self:handleNet_G2C_requestAssembleTeam(reader)
	end
	self:Bind(ActionEvents.G2C_AssembleTeamActionEvent,handleNet_G2C_requestAssembleTeam)
	
	local handleNet_G2C_requestJoinTeam = function(reader)
		self:handleNet_G2C_requestJoinTeam(reader)
	end
	self:Bind(ActionEvents.G2C_JoinTeamActionEvent,handleNet_G2C_requestJoinTeam)
	
	local handleNet_G2C_requestLeaveTeam = function(reader)
		self:handleNet_G2C_requestLeaveTeam(reader)
	end
	self:Bind(ActionEvents.G2C_LeaveTeamActionEvent,handleNet_G2C_requestLeaveTeam)
	
	local handleNet_G2C_requestKickedOutTeam = function(reader)
		self:handleNet_G2C_requestKickedOutTeam(reader)
	end
	self:Bind(ActionEvents.G2C_KickedOutTeamMemberActionEvent,handleNet_G2C_requestKickedOutTeam)
	
	local handleNet_G2C_requestHandoverTeamLeader = function(reader)
		self:handleNet_G2C_requestHandoverTeamLeader(reader)
	end
	self:Bind(ActionEvents.G2C_HandoverTeamLeaderActionEvent,handleNet_G2C_requestHandoverTeamLeader)
	
	local handleNet_G2C_requestDisbandTeam = function(reader)
		self:handleNet_G2C_requestDisbandTeam(reader)
	end
	self:Bind(ActionEvents.G2C_DisbandTeamActionEvent,handleNet_G2C_requestDisbandTeam)
	
	local handleNet_G2C_requestTeamSetting = function(reader)
		self:handleNet_G2C_requestTeamSetting(reader)
	end
	self:Bind(ActionEvents.G2C_PlayerTeamSettingActionEvent,handleNet_G2C_requestTeamSetting)
	
	--广播消息
	local G2C_BC_TeamAction = function(reader)
		self:G2C_BC_TeamAction(reader)
	end
	self:Bind(ActionEvents.G2C_Broadcast_TeamActionEvent,G2C_BC_TeamAction)
	
	local G2C_BC_HandoverTeamAction = function(reader)
		self:G2C_BC_HandoverTeamAction(reader)
	end
	self:Bind(ActionEvents.G2C_Broadcast_HandoverTeamActionEvent,G2C_BC_HandoverTeamAction)
	
	local G2C_BC_TeamLeaderQuitTeamAction = function(reader)
		self:G2C_BC_TeamLeaderQuitTeamAction(reader)
	end
	self:Bind(ActionEvents.G2C_Broadcast_TeamLeaderQuitTeamActionEvent,G2C_BC_TeamLeaderQuitTeamAction)
	
	local G2C_BC_DisbandTeamAction = function(reader)
		self:G2C_BC_DisbandTeamAction(reader)
	end
	self:Bind(ActionEvents.G2C_Broadcast_DisbandTeamActionEvent,G2C_BC_DisbandTeamAction)
	
	local G2C_BC_TeamLeaderKickedOutAction = function(reader)
		self:G2C_BC_TeamLeaderKickedOutAction(reader)
	end
	
	local handleG2C_PlayerTeam_Create = function(reader)
		self:handleG2C_PlayerTeam_Create(reader)
	end
	
	local handleG2C_PlayerTeam_InfomationEvent = function(reader)
		self:handleG2C_PlayerTeam_InfomationEvent(reader)
	end	
	
	local handleG2C_PlayerTeam_JoinRequest = function(reader)
		self:handleG2C_PlayerTeam_JoinRequest(reader)
	end
	
	local handleG2C_JoinRequestReplyActionEvent = function(reader)
		self:handleG2C_JoinRequestReplyActionEvent(reader)
	end
	
	local handleG2C_PlayerTeam_Modify = function(reader)
		self:handleG2C_PlayerTeam_Modify(reader)
	end	

	local handleG2C_TeamMenber_Detail = function(reader)
		self:handleG2C_TeamMenber_Detail(reader)
	end	
	
	self:Bind(ActionEvents.G2C_TeamMenber_Detail,handleG2C_TeamMenber_Detail)	
	self:Bind(ActionEvents.G2C_PlayerTeam_JoinRequest,handleG2C_PlayerTeam_JoinRequest)
	self:Bind(ActionEvents.G2C_Broadcast_TeamLeaderKickedOutActionEvent,G2C_BC_TeamLeaderKickedOutAction)
	self:Bind(ActionEvents.G2C_PlayerTeam_Create,handleG2C_PlayerTeam_Create)
	self:Bind(ActionEvents.G2C_PlayerTeam_InfomationEvent,handleG2C_PlayerTeam_InfomationEvent)	
	self:Bind(ActionEvents.G2C_JoinRequestReplyActionEvent,handleG2C_JoinRequestReplyActionEvent)	
	self:Bind(ActionEvents.G2C_PlayerTeam_Modify,handleG2C_PlayerTeam_Modify)
end
--[[
3:拒绝加入队伍		  		
-- 队伍修改请求
C2G_PlayerTeam_Modify = MMORPGEventDefines.Team_Message_Begin + 13,--	  byte levelChoice(1~7:40、45、50、55、60、70、80)
--队伍修改返回
G2C_PlayerTeam_Modify = MMORPGEventDefines.Team_Message_Begin + 63,	--byte createSuccee   		1 成功  0 失败

]]
function TeamActionHandler:__delete()
	
end

--玩家组队状态
function TeamActionHandler:handleNet_G2C_requestPlayerTeamStatus(reader) --请求玩家组队状态
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local playerTeamStatus = StreamDataAdapter:ReadChar(reader)
	
	local TeamObj = TeamObject.New()
	TeamObj:setPlayerTeamStateType(playerTeamStatus)
	teamMgr:setTeamObject(TeamObj)
	GlobalEventSystem:Fire(GameEvent.EventPlayerTeamStatus)
end

function TeamActionHandler:handleNet_G2C_requestAssembleTeam(reader) --组队受邀
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local invitePlayerId = StreamDataAdapter:ReadStr(reader)
	local invitePlayerName = StreamDataAdapter:ReadStr(reader)
	local invitePlayerLevel = StreamDataAdapter:ReadInt(reader)
	
	local inviteObj = TeamObject.New()
	inviteObj:setInviteType(1)
	inviteObj:setInvitePlayerId(invitePlayerId)
	inviteObj:setInvitePlayerName(invitePlayerName)
	inviteObj:setInvitePlayerLevel(invitePlayerLevel)
	teamMgr:setTeamInviteList(inviteObj,1)
	GlobalEventSystem:Fire(GameEvent.EventSetTeamInviteBtnStatus,true)
end
	
function TeamActionHandler:handleNet_G2C_requestJoinTeam(reader) --组队邀请返回
	reader = tolua.cast(reader,"iBinaryReader")
	local playerActionType = StreamDataAdapter:ReadChar(reader)
	GlobalEventSystem:Fire(GameEvent.EventJoinTeamReturn,playerActionType)
end

function TeamActionHandler:handleNet_G2C_requestLeaveTeam(reader) --离开队伍
	reader = tolua.cast(reader,"iBinaryReader")
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
	teamMgr:setMyTeamId(nil)
	teamMgr:removeTeam()
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)		
	teamMgr:requestBossTeamList()		
	UIManager.Instance:showSystemTips(Config.Words[9037])	
end

function TeamActionHandler:handleNet_G2C_requestKickedOutTeam(reader) --踢出队伍
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	reader = tolua.cast(reader,"iBinaryReader")	
	teamMgr:setMyTeamId(nil)
	teamMgr:removeTeam()
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)	
	UIManager.Instance:showSystemTips(Config.Words[9036])	
end

function TeamActionHandler:handleNet_G2C_requestHandoverTeamLeader(reader) --队长转移
	reader = tolua.cast(reader,"iBinaryReader")	
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)	
end

function TeamActionHandler:handleNet_G2C_requestDisbandTeam(reader) --解散队伍
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
	reader = tolua.cast(reader,"iBinaryReader")
	teamMgr:setMyTeamId(nil)
	teamMgr:removeTeam()
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)		
end

function TeamActionHandler:handleNet_G2C_requestTeamSetting(reader) --设置不接受组队邀请
	reader = tolua.cast(reader,"iBinaryReader")
end

function TeamActionHandler:G2C_BC_TeamAction(reader) --队员进入/队员离开(广播)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local actionType = StreamDataAdapter:ReadChar(reader)
	local teamLeaderId = StreamDataAdapter:ReadStr(reader)
	local teamLeaderPro = StreamDataAdapter:ReadChar(reader)
	local teamLearderGender = StreamDataAdapter:ReadChar(reader)
	local teamLeaderName = StreamDataAdapter:ReadStr(reader)
	local teamLeaderHP = StreamDataAdapter:ReadInt(reader)
	local teamLeaderMaxHP = StreamDataAdapter:ReadInt(reader)		
	teamMgr:setTeamLeaderId(teamLeaderId)
	local teamMembersSize = StreamDataAdapter:ReadInt(reader)	
	for i = 1, teamMembersSize do
		local teamMemberId = StreamDataAdapter:ReadStr(reader)
		local teamMemberPro = StreamDataAdapter:ReadChar(reader)
		local teamMemberGender = StreamDataAdapter:ReadChar(reader)
		local teamMemberName = StreamDataAdapter:ReadStr(reader)
		local teamMemberHP = StreamDataAdapter:ReadInt(reader)
		local teamMemberMaxHP = StreamDataAdapter:ReadInt(reader)

		if actionType == 2  then
			local TeamMemberObj = TeamObject.New()
			TeamMemberObj:setTeamMemberId(teamMemberId)
			TeamMemberObj:setTeamMemberProfession(teamMemberPro)
			TeamMemberObj:setTeamMemberGender(teamMemberGender)
			TeamMemberObj:setTeamMemberName(teamMemberName)
			TeamMemberObj:setTeamMemberMaxHP(teamMemberMaxHP)
			TeamMemberObj:setTeamMemberHP(teamMemberHP)			
			if teamMemberId ~= teamLeaderId and  teamMemberId ~= G_getHero():getId() and not teamMgr:getTeamMemberById(teamMemberId) then
				local  tipsStr = string.format(Config.Words[9035],teamMemberName)
				UIManager.Instance:showSystemTips(tipsStr)	
			end			
			teamMgr:setTeam(TeamMemberObj)		
			if teamMemberId == G_getHero():getId() then			
				local teamLeaderObj = TeamObject.New()
				teamLeaderObj:setTeamMemberId(teamLeaderId)
				teamLeaderObj:setTeamMemberProfession(teamLeaderPro)
				teamLeaderObj:setTeamMemberGender(teamLearderGender)
				teamLeaderObj:setTeamMemberName(teamLeaderName)
				teamLeaderObj:setTeamMemberMaxHP(teamLeaderMaxHP)
				teamLeaderObj:setTeamMemberHP(teamLeaderHP)
				teamMgr:setTeam(teamLeaderObj)	
			end
		elseif actionType == 3 then
			local teamObj = teamMgr:getTeamMemberById(teamMemberId)
			if teamObj then
				local nameStr = teamObj:getTeamMemberName()
				local  tipsStr = string.format(Config.Words[9034],nameStr)
				UIManager.Instance:showSystemTips(tipsStr)		
			end
			teamMgr:removeTeamMember(teamMemberId)
		end

	end
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	teamMgr:requestBossTeamList()		
end

function TeamActionHandler:G2C_BC_HandoverTeamAction(reader) --队长转让(广播)
	reader = tolua.cast(reader,"iBinaryReader")
	local oldTeamLeaderId = StreamDataAdapter:ReadStr(reader)
	local newTeamLeaderId =StreamDataAdapter:ReadStr(reader)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	teamMgr:setTeamLeaderId(newTeamLeaderId)
	GlobalEventSystem:Fire(GameEvent.EventHandoverTeamAction)	
	
	if  newTeamLeaderId == G_getHero():getId() then
		UIManager.Instance:showSystemTips(Config.Words[9031])		
	else
		local teamObj = teamMgr:getTeamMemberById(newTeamLeaderId)
		if teamObj then
			local nameStr = teamObj:getTeamMemberName()
			local  tipsStr = string.format(Config.Words[9030],nameStr)
			UIManager.Instance:showSystemTips(tipsStr)		
		end
	end				
end

function TeamActionHandler:G2C_BC_TeamLeaderQuitTeamAction(reader) --队长离开队伍(广播)
	reader = tolua.cast(reader,"iBinaryReader")	
	local quitTeamLeaderId = StreamDataAdapter:ReadStr(reader)
	local newTeamLeaderId =StreamDataAdapter:ReadStr(reader)	
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	teamMgr:setTeamLeaderId(newTeamLeaderId)
	teamMgr:removeTeamMember(quitTeamLeaderId)
	GlobalEventSystem:Fire(GameEvent.EventTeamLeaderQuitTeamAction)	
	UIManager.Instance:showSystemTips(Config.Words[9032])		
	if  newTeamLeaderId == G_getHero():getId() then
		UIManager.Instance:showSystemTips(Config.Words[9031])		
	else
		local teamObj = teamMgr:getTeamMemberById(newTeamLeaderId)
		if teamObj then
			local nameStr = teamObj:getTeamMemberName()
			local  tipsStr = string.format(Config.Words[9030],nameStr)
			UIManager.Instance:showSystemTips(tipsStr)		
		end
	end		
end

function TeamActionHandler:G2C_BC_DisbandTeamAction(reader) --队长解散队伍(广播)
	reader = tolua.cast(reader,"iBinaryReader")
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	teamMgr:setMyTeamId(nil)	
	teamMgr:removeTeam()
	UIManager.Instance:showSystemTips(Config.Words[25524])		
	GlobalEventSystem:Fire(GameEvent.EventDisbandTeamAction)
end

function TeamActionHandler:G2C_BC_TeamLeaderKickedOutAction(reader) --队长踢出队员(广播)
	reader = tolua.cast(reader,"iBinaryReader")
	local kickedOutTeamLeader = StreamDataAdapter:ReadStr(reader)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
	teamMgr:removeTeamMember(kickedOutTeamLeader)	
	GlobalEventSystem:Fire(GameEvent.EventTeamLeaderKickedOutAction)	
end	

--创建队伍返回
function TeamActionHandler:handleG2C_PlayerTeam_Create(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()		
	local result =  StreamDataAdapter:ReadChar(reader)	
	local teamId = StreamDataAdapter:ReadStr(reader)	
	if  result == 1 then
		--成功
		teamMgr:setMyTeamId(teamId)
		GlobalEventSystem:Fire(GameEvent.EventCreateTeamSuccess)
		UIManager.Instance:showSystemTips(Config.Words[25508])
		GlobalEventSystem:Fire(GameEvent.EventTeamAction)		
		teamMgr:requestBossTeamList()			
	else
		--失败
		UIManager.Instance:showSystemTips(Config.Words[25509])
	end
end

--队伍列表返回

function TeamActionHandler:handleG2C_PlayerTeam_InfomationEvent(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local myTeamId =  StreamDataAdapter:ReadStr(reader)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()		
	if myTeamId and string.len(myTeamId) > 0 then
		teamMgr:setMyTeamId(myTeamId)
	end	
	local size =  StreamDataAdapter:ReadShort(reader)
	teamMgr:initTeamList(size)	
	if size and size > 0 then	
		local teamlist = teamMgr:getTeamList()	
		for i=1, size do
			local teamName = StreamDataAdapter:ReadStr(reader)
			local teamId =  StreamDataAdapter:ReadStr(reader)
			local levelChoice =  StreamDataAdapter:ReadChar(reader)
			local teamMember =  StreamDataAdapter:ReadChar(reader)
			local averageLevel =  StreamDataAdapter:ReadChar(reader)
			teamlist[i].teamName = teamName	
			teamlist[i].teamId = teamId	
			teamlist[i].levelChoice = levelChoice	
			teamlist[i].teamMember = teamMember	
			teamlist[i].averageLevel = averageLevel	
		end			
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateTeamListView)
end

function TeamActionHandler:handleG2C_PlayerTeam_JoinRequest(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local invitePlayerId = StreamDataAdapter:ReadStr(reader)
	local invitePlayerName = StreamDataAdapter:ReadStr(reader)
	local invitePlayerLevel = StreamDataAdapter:ReadInt(reader)
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()			
	local inviteObj = TeamObject.New()
	inviteObj:setInviteType(2)
	inviteObj:setInvitePlayerId(invitePlayerId)
	inviteObj:setInvitePlayerName(invitePlayerName)
	inviteObj:setInvitePlayerLevel(invitePlayerLevel)
	teamMgr:setTeamInviteList(inviteObj,2)
	GlobalEventSystem:Fire(GameEvent.EventSetTeamInviteBtnStatus,true)		
end

function TeamActionHandler:handleG2C_JoinRequestReplyActionEvent(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ret = StreamDataAdapter:ReadChar(reader)
	GlobalEventSystem:Fire(GameEvent.EventRequestJoinTeamReturn,ret)	
end

function TeamActionHandler:handleG2C_PlayerTeam_Modify(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local ret = StreamDataAdapter:ReadChar(reader)
	GlobalEventSystem:Fire(GameEvent.EventModifyTeamReturn,ret)	
end	


--[[
	 
//请求队员的状态信息
C2G_TeamMember_Detail = MMORPGEventDefines.Team_Message_Begin + 14;

	 
// 队伍状态信息返回
G2C_TeamMenber_Detail = MMORPGEventDefines.Team_Message_Begin + 64;
		byte size  队员数目
			{
				byte  state 队员状态   1 在线   2 离线  3 死亡
				string memberId  队员Id
				int MaxHp 队员最大血量
				int Hp   队员当前血量
		  }
	  
]]

function TeamActionHandler:handleG2C_TeamMenber_Detail(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()			
	local size =  StreamDataAdapter:ReadChar(reader)
	if size and size > 0 then	
		local teamlist = teamMgr:getTeamList()	
		for i=1, size do
			local state = StreamDataAdapter:ReadChar(reader)
			local playerId =  StreamDataAdapter:ReadStr(reader)
			local MaxHp = StreamDataAdapter:ReadInt(reader)
			local curHp = StreamDataAdapter:ReadInt(reader)	
			local sceneRefId = 	StreamDataAdapter:ReadStr(reader)
			local posX = StreamDataAdapter:ReadInt(reader)		
			local posY = StreamDataAdapter:ReadInt(reader)
			local teamMember = teamMgr:getTeamMemberById(playerId) 	
			if teamMember then
				teamMember:setTeamMemberStatus(state)
				teamMember:setTeamMemberMaxHP(MaxHp)
				teamMember:setTeamMemberHP(curHp)
				teamMember:setSceneId(sceneRefId)
				teamMember:setPositionX(posX)
				teamMember:setPositionY(posY)				
			end					
		end			
	end
	GlobalEventSystem:Fire(GameEvent.EventTeamAction)	
		
	if teamMgr:getNeedGetPosition() then
		teamMgr:setNeedGetPosition(false)
		GlobalEventSystem:Fire(GameEvent.EventUpdateSceneMapViewTeammatePosition)
	end
end	
