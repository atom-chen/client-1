require("actionEvent.ActionEventDef")
require("config.words")
FactionMgr = FactionMgr or BaseClass()
local E_Update = {
	add = 1,
	remove = 2,
	upgrade = 3,
}
function FactionMgr:__init()
	self.memberList = {}
	self.factionList = {}
	self.lieutenant	= {}
	self.factionInviteList = {}	
	local onErrorCodeReturn = function(msgId,errorCode)
		self:onErrorCodeReturn(msgId,errorCode)
	end		
	self.errCodeBind = GlobalEventSystem:Bind(GameEvent.EventErrorCode,onErrorCodeReturn)
end

function FactionMgr:onErrorCodeReturn(msgId,errorCode)	
	UIManager.Instance:hideLoadingHUD()
	if msgId == 2907 and (errorCode == 2147486166 or errorCode == 2147486164) then	
		self:requestFactionList("2","1")	
		UIManager.Instance:showLoadingHUD(3,self.rootNode)	
	elseif msgId == 2913 and errorCode == 2147486162 then		
		UIManager.Instance:showSystemTips(Config.Words[5571])
		local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
		local factionName = self:getFactionInfo().factionName
		if heroId and factionName then
			self:requestApplyPlayerList(heroId,factionName)
	end
end
end
function FactionMgr:__delete()
	self.playerObj : DeleteMe()
	for i,v in pairs(self.memberList) do
		v:DeleteMe()
	end
	for i,v in pairs(self.factionList) do
		v:DeleteMe()
	end
	for i,v in pairs(self.factionInviteList) do
		v:DeleteMe()
	end
	if self.errCodeBind then
		GlobalEventSystem:UnBind(self.errCodeBind)
		self.errCodeBind = nil
	end
end

function FactionMgr:clear()
	if self.playerObj then
		self.playerObj : DeleteMe()
		self.playerObj = nil
	end

	if self.memberList then
		for i,v in pairs(self.memberList) do
			v:DeleteMe()
		end
		self.memberList = {}
	end
	if self.factionList then
		for i,v in pairs(self.factionList) do
			v:DeleteMe()
		end
		self.factionList = {}
	end
	if self.factionInviteList then
		for i,v in pairs(self.factionInviteList) do
			v:DeleteMe()
		end
		self.factionInviteList = {}
	end		
	self.lieutenant	= {}
	self.factionInfo = {}
	self.applyList = {}
	self.totalPart = 0
	self.page = 0
	self.count = 0
	self.announcementWord = ""
end

--charName 该玩家唯一标识名字
function FactionMgr:requestFactionList(flag,part) --请求公会列表
	if not flag then
		flag = "2"
	end
	if not part then
		part = "1"
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_UnionList)	
	StreamDataAdapter:WriteChar(writer,flag)
	StreamDataAdapter:WriteChar(writer,part)
	simulator:sendTcpActionEventInLua(writer)		
end

function FactionMgr:requestCreateFaction(factionName)	--请求创建公会
	if type(factionName)~= "string" then
		UIManager.Instance:showSystemTips(Config.Words[5574])
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_CreateUnion)	
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)
end

function FactionMgr:requestJoinFaction(factionName)	--请求加入公会
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestJoinFaction")
		return
	end
	local isInCastleWar = G_getCastleWarMgr():isInCastleWar()
	if isInCastleWar == true then
		UIManager.Instance:showSystemTips(Config.Words[21003])
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_JoinUnion)	
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)	
end	

function FactionMgr:requestCancelJoin(factionName)		--请求取消申请
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestCancelJoin")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_CancelJoin)	
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)
end

function FactionMgr:requestApplyPlayerList(factionName)		--请求申请列表
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestApplyPlayerList")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_ApplyList)	
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)	
end

function FactionMgr:requestHandleApply(applyPlayerId,factionName,vote)		--请求处理申请
	if type(applyPlayerId)~= "string" or type(factionName)~= "string" or vote == nil then
		CCLuaLog("Arg Error:FactionMgr:requestHandleApply")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_HandleApply)	
	StreamDataAdapter:WriteStr(writer,applyPlayerId)
	StreamDataAdapter:WriteStr(writer,factionName)
	StreamDataAdapter:WriteChar(writer,vote)
	simulator:sendTcpActionEventInLua(writer)
end
function FactionMgr:requestKickOutPlayer(kickoutPlayerId,factionName)		--请求踢出公会
	if type(kickoutPlayerId)~= "string" or type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestKickOutPlayer")
		return
	end
	local isInCastleWar = G_getCastleWarMgr():isInCastleWar()
	if isInCastleWar == true then
		UIManager.Instance:showSystemTips(Config.Words[21003])
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_KickOutMember)	
	StreamDataAdapter:WriteStr(writer,kickoutPlayerId)
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)
end

function FactionMgr:requestExitFaction(factionName)		--请求退出公会
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestApplyPlayerList")
		return
	end
	local isInCastleWar = G_getCastleWarMgr():isInCastleWar()
	if isInCastleWar == true then
		UIManager.Instance:showSystemTips(Config.Words[21003])
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_Exit)	
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)
end	

function FactionMgr:requestUpgradeOffice(upPlayerId,factionName,officeId)		--请求提升官职
	if type(upPlayerId)~= "string" or type(factionName)~= "string" or officeId == nil then
		CCLuaLog("Arg Error:FactionMgr:requestUpgradeOffice")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_UpgradeOffice)	
	StreamDataAdapter:WriteStr(writer,upPlayerId)
	StreamDataAdapter:WriteStr(writer,factionName)
	StreamDataAdapter:WriteChar(writer,officeId)
	simulator:sendTcpActionEventInLua(writer)
end
function FactionMgr:requestEditNotice(factionName,message)		--请求修改公告
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestEditNotice")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_EditNotice)	
	StreamDataAdapter:WriteStr(writer,factionName)
	StreamDataAdapter:WriteStr(writer,message)
	simulator:sendTcpActionEventInLua(writer)
end
function FactionMgr:requestChangeAutoState(factionName,autoState)
	if type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestChangeAutoState")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Union_AutoAgree)	
	StreamDataAdapter:WriteStr(writer,factionName)
	StreamDataAdapter:WriteChar(writer,autoState)
	simulator:sendTcpActionEventInLua(writer)
end

function FactionMgr:openCreateView()
	GlobalEventSystem:Fire(GameEvent.EventOpenCreateView)
end

function FactionMgr:openListView()
	GlobalEventSystem:Fire(GameEvent.EventOpenListView)
end	

function FactionMgr:openApplyView()
	GlobalEventSystem:Fire(GameEvent.EventOpenFactionApplyView)
end
function FactionMgr:closePlayerInfoView()
	GlobalEventSystem:Fire(GameEvent.EventClosePlayerInfoView)
end

function FactionMgr:isFullMember()
	local factionInfo = self:getFactionInfo()
	if factionInfo then	--判断公会是否满成员
		local memNum = factionInfo.memNum
		if memNum and memNum < 30 then
			return false --未满
		elseif memNum and memNum == 30 then
			return true  --已满
		end
	end
end

function FactionMgr:isChairMan()
	local hero = GameWorld.Instance:getEntityManager():getHero()	
--[[	self.officeId  = PropertyDictionary:get_unionOfficialId(hero:getPT())
	if self.officeId == 1 then
		return true
	else
		return false
	end
	--]]
	local factionInfo = self:getFactionInfo()
	if factionInfo and hero then	--判断是否是会长
		local chairManName = factionInfo.chairManName	
		local heroName = PropertyDictionary:get_name(hero:getPT()) 
		local pt = hero:getPT()
		local officeId = PropertyDictionary:get_unionOfficialId(hero:getPT())
		--[[if chairManName == heroName and (PropertyDictionary:get_unionOfficialId(hero:getPT()) == 1) then--]]
		if chairManName == heroName then
			return true
		else
			return false
		end
	else
		return false
	end
end

function FactionMgr:setLieutenant(key,memName)	
	if key == nil or memName == nil then
		CCLuaLog("Arg Error:FactionMgr:setLieutenant")
		return
	end	
	self.lieutenant[key] = memName
end
function FactionMgr:getLieutenant()		--取得副会长列表
	if self.lieutenant then
		return self.lieutenant
	end
end

function FactionMgr:canInvite()
	local g_hero = GameWorld.Instance:getEntityManager():getHero()
	local heroUnionOfficialId = PropertyDictionary:get_unionOfficialId(g_hero:getPT())
	if heroUnionOfficialId == 1 or heroUnionOfficialId == 2 then
		return true
	else			
		return false
	end
end

function FactionMgr:setTotalPart(totalPart)
	self.totalPart = totalPart
end

function FactionMgr:getTotalPart()
	if self.totalPart then
		return self.totalPart
	end
end

function FactionMgr:setAnnouncementBoard(text)
	self.announcementWord = text
end

function FactionMgr:getAnnouncementBoard()
	if self.announcementWord then
		return self.announcementWord
	end	
end

function FactionMgr:setFactionListByKey(key,commonFactionObj)
	if key == nil or commonFactionObj == nil then
		CCLuaLog("Arg Error:FactionMgr:setFactionListByKey")
		return
	end	
	if self.factionList[key] then
		self.factionList[key]:DeleteMe()
	end
	self.factionList[key] = commonFactionObj
end	

function FactionMgr:getFactionList()
	if self.factionList then
		return self.factionList
	end
end


function FactionMgr:setFactionInfo(factionName,chairManName,memNum,vipType)
	if not self.factionInfo then
		self.factionInfo = {}
		self.factionInfo.factionName = factionName
		self.factionInfo.chairManName = chairManName
		self.factionInfo.memNum = memNum
		self.factionInfo.chairManVipType = vipType
	else
		self.factionInfo.factionName = factionName
		self.factionInfo.chairManName = chairManName
		self.factionInfo.memNum = memNum
		self.factionInfo.chairManVipType = vipType
	end
end

function FactionMgr:getFactionInfo()
	if self.factionInfo then
		return self.factionInfo
	end
end

function FactionMgr:setMemberListByKey(key,memObj)
	if key == nil or memObj == nil then
		CCLuaLog("Arg Error:FactionMgr:setMemberListByKey")
		return
	end	
	self.memberList[key] = memObj
end
function FactionMgr:getMemberList()
	if self.memberList then
		return self.memberList
	end
end

function FactionMgr:setApplyFactionName(applyFactionName)
	self.applyFactionName  = applyFactionName
end

function FactionMgr:getApplyFactionName()
	if self.applyFactionName then
		return self.applyFactionName
	end
end

function FactionMgr:setApplyList(key,charId,name,professsionId,level,vipType)
	if key == nil or type(charId)~="string" or type(name)~="string" or professsionId == nil or level == nil or vipType == nil then
		CCLuaLog("Arg Error:FactionMgr:setApplyList")
		return
	end
	if not self.applyList then
		self.applyList = {}
		local apply = {}
		apply.charId = charId
		apply.name = name
		apply.professsionId = professsionId
		apply.level = level		
		apply.vipType = vipType
		self.applyList[key] = apply
	else
		local apply = {}
		apply.charId = charId
		apply.name = name
		apply.professsionId = professsionId
		apply.level = level	
		apply.vipType = vipType	
		self.applyList[key] = apply
	end
end

function FactionMgr:getApplyList()
	if self.applyList then
		return self.applyList
	end
end

function FactionMgr:emptyList(listType)
	if listType == 1 then
		if self.factionList then
			for i,v in pairs(self.factionList) do
				v:DeleteMe()			
			end
			self.factionList = nil
			self.factionList = {}
		end
	elseif listType == 2 then
		if self.memberList then
			for i,v in pairs(self.memberList) do
				v:DeleteMe()			
			end
			self.memberList = nil
			self.memberList = {}
		end
	elseif listType == 3 then
		if self.applyList then
			self.applyList = nil
			self.applyList = {}
		end
	end
end

function FactionMgr:setApplyViewFlag(flag)
	self.applyViewFlag = flag
end

function FactionMgr:getApplyViewFlag()
	if self.applyViewFlag then
		return self.applyViewFlag
	end
end	
function FactionMgr:setInfoViewFlag(flag)
	self.infoViewFlag = flag
end

function FactionMgr:getInfoViewFlag()
	if self.infoViewFlag then
		return self.infoViewFlag
	end
end

function FactionMgr:showPlayerInfo(playerInfo)
	if playerInfo == nil then
		CCLuaLog("Arg Error:FactionMgr:showPlayerInfo")
		return
	end
	self:setPlayerInfo(playerInfo)
	GlobalEventSystem:Fire(GameEvent.EventOpenPlayerInfoView)
end

function FactionMgr:showApplyPlayerInfo(applyPlayerInfo)
	if applyPlayerInfo == nil then
		CCLuaLog("Arg Error:FactionMgr:showApplyPlayerInfo")
		return
	end
	self:setApplyPlayerInfo(applyPlayerInfo)
	GlobalEventSystem:Fire(GameEvent.EventOpenApplyInfoView)
end

function FactionMgr:setPlayerInfo(playerInfo)
	self.playerInfo = playerInfo
end
function FactionMgr:getPlayerInfo()
	if self.playerInfo then
		return self.playerInfo
	end
end
function FactionMgr:setApplyPlayerInfo(applyPlayerInfo)
	self.applyPlayerInfo = applyPlayerInfo
end
function FactionMgr:getApplyPlayerInfo()
	if self.applyPlayerInfo then
		return self.applyPlayerInfo
	end
end

function FactionMgr:setHandlerIndex(index)
	self.handlerIndex = index
end
function FactionMgr:getHandlerIndex()
	if self.handlerIndex then
		return self.handlerIndex
	end
end

function FactionMgr:resetApplyList(key)
	if self.applyList and key then
		local listSize = table.size(self.applyList) 
		if key == listSize then
			self.applyList[key] = nil
		else
			for i = key , listSize-1 do
				self.applyList[i] = {}
				self.applyList[i] = self.applyList[i+1]
			end
			self.applyList[listSize] = nil
		end
	end
end

function FactionMgr:resetInfoList(key)
	if self.memberList and key then
		local listSize = table.size(self.memberList)
		if key == listSize then
			self.memberList[key] = nil
		else
			for i = key , listSize-1 do
				self.memberList[i]:DeleteMe()
				self.memberList[i] = self.memberList[i+1]
			end
		end
		self.memberList[listSize] = nil
	end
end

function FactionMgr:setApplyIndex(applyIndex)
	self.applyIndex = applyIndex
end

function FactionMgr:getApplyIndex()
	if self.applyIndex then
		return self.applyIndex
	end
end

function FactionMgr:setAutoState(autoState)
	self.autoState = autoState
end

function FactionMgr:getAutoState()
	if self.autoState then
		return self.autoState
	end
end

function FactionMgr:setOffice(officeId)
	self.office = officeId 
end
function FactionMgr:getOffice()
	if self.office then
		return self.office
	end
end

function FactionMgr:setInfoIndex(infoIndex)
	self.infoIndex = infoIndex
end

function FactionMgr:getInfoIndex()
	if self.infoIndex then
		return self.infoIndex
	end
end

function FactionMgr:checkPlayerProperty(playerId)
	if playerId then
		local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
		local entityMgr = GameWorld.Instance:getEntityManager()	
		equipMgr:requestOtherPlayerEquipList(playerId)
		entityMgr:requestOtherPlayer(playerId)		
		equipMgr:setOtherPlayerEquipList(nil)	--清空列表，防止读到其他玩家信息
		self.playerObj = PlayerObject.New()
		self.playerObj:setId(playerId)
		local player = {playerObj=self.playerObj,playerType =1}	--1: 其他玩家的信息
		--GlobalEventSystem:Fire(GameEvent.EventHideAllUI)
		GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player) 
		GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
	end
end

function FactionMgr:chatToPlayer(playerName)
	if playerName then
		GlobalEventSystem:Fire(GameEvent.EventWhisperChat,playerName)
	end
end

function FactionMgr:setFactionFlag(flag)
	self.factionFlag = flag
end
function FactionMgr:getFactionFlag()
	if self.factionFlag ~= nil then
		return self.factionFlag
	end
end

function FactionMgr:setInfoPage(page)
	self.page = page
end
function FactionMgr:getInfoPage()
	if self.page then
		return self.page
	end
end
function FactionMgr:setChairmanIndex(index)
	self.chairmanIndex = index
end
function FactionMgr:getChairmanIndex()
	if self.chairmanIndex then
		return self.chairmanIndex
	end
end

function FactionMgr:requestPlayerFactionStatus(playerId) --请求玩家公会状态
	if type(playerId)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestPlayerFactionStatus")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_PlayerFactionInfoActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	simulator:sendTcpActionEventInLua(writer)	
end

function FactionMgr:requestAssembleFaction(playerId,factionName) --公会邀请
	if type(playerId)~= "string" or type(factionName)~= "string" then
		CCLuaLog("Arg Error:FactionMgr:requestAssembleFaction")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_AssembleFactionActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	StreamDataAdapter:WriteStr(writer,factionName)
	simulator:sendTcpActionEventInLua(writer)	
end
	
function FactionMgr:JoinFactionreply(playerId,factionName,replyJoinFactionType) --公会受邀返回
	if type(playerId)~= "string" or type(factionName)~= "string" or replyJoinFactionType == nil then
		CCLuaLog("Arg Error:FactionMgr:JoinFactionreply")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_JoinFactionActionEvent)
	StreamDataAdapter:WriteStr(writer,playerId)
	StreamDataAdapter:WriteStr(writer,factionName)
	StreamDataAdapter:WriteChar(writer,replyJoinFactionType)
	simulator:sendTcpActionEventInLua(writer)	
end

function FactionMgr:setFactionInviteList(inviteObj)
	if inviteObj == nil then
		return
	end
	if table.size(self.factionInviteList) <5 then		--限制邀请数量不大于5个
		table.insert(self.factionInviteList,inviteObj)
	end			
end

function FactionMgr:getFactionInviteList()
	return self.factionInviteList
end

function FactionMgr:getFactionInviteObjById(playerId)
	if playerId == nil then
		return
	end
	local inviteObj
	for j,v in ipairs(self.factionInviteList) do
		if v:getInvitePlayerId() == playerId then
			inviteObj = v
			return inviteObj
		end
	end
end

function FactionMgr:removeFactionInviteList()
	self.factionInviteList = {}
end

function FactionMgr:removeFactionInvite(playerId)
	if playerId == nil then
		return
	end
	for j,v in ipairs(self.factionInviteList) do	
		if v:getInvitePlayerId() == playerId then
			table.remove(self.factionInviteList,j)
		end
	end
end
--公会成员数
function FactionMgr:setMemberNum(Num)
	if Num then
		self.count = Num
	end
end

function FactionMgr:getMemberNum()
	return self.count
end

function FactionMgr:getLogoutWordsByType(logoutType)
	if logoutType == 1 then
		return Config.Words[5576]
	elseif logoutType == 2 then
		return Config.Words[5577]
	elseif logoutType == 3 then
		return Config.Words[5578]
	elseif logoutType == 4 then
		return Config.Words[5579]
	end
end

function FactionMgr:getOfficeNameById(officeId)
	if officeId == 1 then
		return Config.Words[5529]
	elseif officeId == 2 then
		return Config.Words[5530]
	elseif officeId == 3 then
		return Config.Words[5531]
	end
end	

