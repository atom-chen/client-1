require ("common.ActionEventHandler")
require ("object.faction.CommonFactionObject")
require ("object.faction.MemberObject")		
FactionActionHandler = FactionActionHandler or BaseClass(ActionEventHandler)
local simulator = SFGameSimulator:sharedGameSimulator()
local E_Update = {
	add = 1,
	remove = 2,
	upgrade = 3,
}
local E_List = {
	faction = 1,
	member = 2,
	applyer = 3,
}
function FactionActionHandler:__init()
	local handleNet_G2C_Union_UnionList	= function(reader)
		self:handleNet_G2C_Union_UnionList(reader)
	end
	self:Bind(ActionEvents.G2C_Union_UnionList,handleNet_G2C_Union_UnionList)
	
	local handleNet_G2C_Union_CreateUnion	= function(reader)
		self:handleNet_G2C_Union_CreateUnion(reader)
	end
	self:Bind(ActionEvents.G2C_Union_CreateUnion,handleNet_G2C_Union_CreateUnion)
	
	local handleNet_G2C_Union_JoinUnion	= function(reader)
		self:handleNet_G2C_Union_JoinUnion(reader)
	end
	self:Bind(ActionEvents.G2C_Union_JoinUnion,handleNet_G2C_Union_JoinUnion)	
	
	local handleNet_G2C_Union_HandleApply	= function(reader)
		self:handleNet_G2C_Union_HandleApply(reader)
	end
	self:Bind(ActionEvents.G2C_Union_HandleApply,handleNet_G2C_Union_HandleApply)
	
	local handleNet_G2C_Union_Exit	= function(reader)
		self:handleNet_G2C_Union_Exit(reader)
	end
	self:Bind(ActionEvents.G2C_Union_Exit,handleNet_G2C_Union_Exit)
	
	local handleNet_G2C_Union_CancelJoin	= function(reader)
		self:handleNet_G2C_Union_CancelJoin(reader)
	end
	self:Bind(ActionEvents.G2C_Union_CancelJoin,handleNet_G2C_Union_CancelJoin)
	
	local handleNet_G2C_Union_KickOutMember	= function(reader)
		self:handleNet_G2C_Union_KickOutMember(reader)
	end
	self:Bind(ActionEvents.G2C_Union_KickOutMember,handleNet_G2C_Union_KickOutMember)
	
	local handleNet_G2C_Union_UpgradeOffice	= function(reader)
		self:handleNet_G2C_Union_UpgradeOffice(reader)
	end
	self:Bind(ActionEvents.G2C_Union_UpgradeOffice,handleNet_G2C_Union_UpgradeOffice)
	
	local handleNet_G2C_Union_EditNotice	= function(reader)
		self:handleNet_G2C_Union_EditNotice(reader)
	end
	self:Bind(ActionEvents.G2C_Union_EditNotice,handleNet_G2C_Union_EditNotice)
	
	local handleNet_G2C_Union_ApplyList	= function(reader)
		self:handleNet_G2C_Union_ApplyList(reader)
	end
	self:Bind(ActionEvents.G2C_Union_ApplyList,handleNet_G2C_Union_ApplyList)
	local handleNet_G2C_requestAssembleFaction  = function(reader)
		self:handleNet_G2C_requestAssembleFaction(reader)
	end
	self:Bind(ActionEvents.G2C_AssembleFactionActionEvent,handleNet_G2C_requestAssembleFaction)
	
	local handleNet_G2C_FactionInviteReplyActionEvent  = function(reader)
		self:handleNet_G2C_FactionInviteReplyActionEvent(reader)
	end
	self:Bind(ActionEvents.G2C_FactionInviteReplyActionEvent ,handleNet_G2C_FactionInviteReplyActionEvent)
	
	local handleNet_G2C_Union_Update	= function(reader)
		self:handleNet_G2C_Union_Update(reader)
	end
	self:Bind(ActionEvents.G2C_Union_Update,handleNet_G2C_Union_Update)
end

function FactionActionHandler:__delete()
	
end


function FactionActionHandler:handleNet_G2C_Union_UnionList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local listType = StreamDataAdapter:ReadChar(reader)
	if listType == 0 then
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		local factionFlag = factionMgr:getFactionFlag()	
		local myFaction = PropertyDictionary:get_unionName(GameWorld.Instance:getEntityManager():getHero():getPT())
		if myFaction == "" or factionFlag ~= true then
			factionMgr:setFactionFlag(false)
			factionMgr:setFactionInfo(nil,nil,nil)
		end
		local totalPart = StreamDataAdapter:ReadChar(reader) --short->byte
		factionMgr:setTotalPart(totalPart)
		local count = StreamDataAdapter:ReadChar(reader) --short->byte
		factionMgr:emptyList(E_List.faction)			--释放问题
		
		for i = 1, count do
			local commonFactionObj = CommonFactionObject.New()
			local rank = StreamDataAdapter:ReadShort(reader)
			local factionName = StreamDataAdapter:ReadStr(reader)
			local chairManName = StreamDataAdapter:ReadStr(reader)
			local memNum = StreamDataAdapter:ReadShort(reader)  --int -->short
			commonFactionObj:setRank(rank)
			commonFactionObj:setFactionName(factionName)
			commonFactionObj:setChairManName(chairManName)
			commonFactionObj:setMemNum(memNum)
			factionMgr:setFactionListByKey(i,commonFactionObj)
		end	
		local applyFactionName = StreamDataAdapter:ReadStr(reader)		
		if applyFactionName then 
			factionMgr:setApplyFactionName(applyFactionName)
		end		
		local viewFlag = factionMgr:getApplyViewFlag()
		if viewFlag == nil then
			factionMgr:setApplyViewFlag(true)
			GlobalEventSystem:Fire(GameEvent.EventOpenFactionApplyView)
		elseif viewFlag == true then
			GlobalEventSystem:Fire(GameEvent.EventRefreshApplyTableView)		
		end			
		UIManager.Instance:hideLoadingHUD()
	elseif listType == 1 then
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()			
		local totalPart = StreamDataAdapter:ReadChar(reader)  --short->btte
		factionMgr:setTotalPart(totalPart)
		local factionName = StreamDataAdapter:ReadStr(reader)
		local chairManName = StreamDataAdapter:ReadStr(reader)
		local autoState = StreamDataAdapter:ReadChar(reader)
		local totalNum = StreamDataAdapter:ReadShort(reader)  --int ->short
		local unionNotice = StreamDataAdapter:ReadStr(reader)	
		local memNum = StreamDataAdapter:ReadChar(reader) --int ->byte
		factionMgr:setMemberNum(memNum)
		factionMgr:emptyList(E_List.member)
		factionMgr:setAnnouncementBoard(unionNotice)
		factionMgr:setAutoState(autoState)
		
		
		for i = 1, memNum do
			local memberObj = MemberObject.New()
			local playerId = StreamDataAdapter:ReadStr(reader)
			local memName = StreamDataAdapter:ReadStr(reader)
			local professsionId = StreamDataAdapter:ReadChar(reader)
			local level = StreamDataAdapter:ReadShort(reader)  --int->short
			local fightValue = StreamDataAdapter:ReadInt(reader)
			local office = StreamDataAdapter:ReadChar(reader)			
			local online = StreamDataAdapter:ReadChar(reader)
			local vipType = StreamDataAdapter:ReadChar(reader)
			local logoutType = StreamDataAdapter:ReadChar(reader)
			memberObj:setCharId(playerId)
			memberObj:setMemName(memName)
			memberObj:setProfesssionId(professsionId)
			memberObj:setLevel(level)
			memberObj:setFightValue(fightValue)
			memberObj:setOffice(office)
			memberObj:setOnline(online)
			memberObj:setVipType(vipType)
			memberObj:setLogoutType(logoutType)
			factionMgr:setMemberListByKey(i,memberObj)
			if office == 2 then
				factionMgr:setLieutenant(i,memName)
			elseif office == 1 then
				factionMgr:setFactionInfo(factionName,chairManName,totalNum,vipType)	
			end
		end		
		local viewFlag = factionMgr:getInfoViewFlag()
		if viewFlag == nil then
			factionMgr:setInfoViewFlag(true)
			GlobalEventSystem:Fire(GameEvent.EventOpenInfoView)
		elseif viewFlag == true then
			GlobalEventSystem:Fire(GameEvent.EventRefreshMemberList)	
			GlobalEventSystem:Fire(GameEvent.EventRefreshInfoTableView)				
		end		
		UIManager.Instance:hideLoadingHUD()
	end
end

function FactionActionHandler:handleNet_G2C_Union_ApplyList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local count = StreamDataAdapter:ReadChar(reader)  --short->btte
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	factionMgr:emptyList(E_List.applyer)
	for i=1,count do
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		local playerId = StreamDataAdapter:ReadStr(reader)
		local name = StreamDataAdapter:ReadStr(reader)
		local professsionId = StreamDataAdapter:ReadChar(reader)
		local level = StreamDataAdapter:ReadShort(reader)  --int->short
		local vipType = StreamDataAdapter:ReadChar(reader)
		factionMgr:setApplyList(i,playerId,name,professsionId,level,vipType)
	end	
	GlobalEventSystem:Fire(GameEvent.EventOpenListView)
	UIManager.Instance:hideLoadingHUD()
end
function FactionActionHandler:handleNet_G2C_Union_KickOutMember(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()		
	local factionInfo = factionMgr:getFactionInfo()
	if factionInfo then
		factionInfo.memNum = factionInfo.memNum-1		--用来显示在左边标签
		factionMgr:setFactionInfo(factionInfo.factionName,factionInfo.chairManName,factionInfo.memNum)
	end					
	--[[self.page = factionMgr:getInfoPage()
	local heroId = GameWorld.Instance:getEntityManager():getHero():getId()	
	if heroId and self.page then
		factionMgr:requestFactionList(heroId,2,self.page)
	end	--]]			
	UIManager.Instance:showSystemTips(Config.Words[5551])	
	factionMgr:closePlayerInfoView()
end

function FactionActionHandler:handleNet_G2C_Union_UpgradeOffice(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	GlobalEventSystem:Fire(GameEvent.EventOfficeChanged)
	UIManager.Instance:showSystemTips(Config.Words[5550])
end	

function FactionActionHandler:handleNet_G2C_Union_EditNotice(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
end

function FactionActionHandler:handleNet_G2C_Union_CreateUnion(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	UIManager.Instance:hideUI("FactionCreateView")	
	UIManager.Instance:hideLoadingHUD()
	local msg = {}
	table.insert(msg,{word = Config.Words[5547], color = Config.FontColor["ColorWhite1"]})
	UIManager.Instance:showSystemTips(msg)
end

function FactionActionHandler:handleNet_G2C_Union_JoinUnion(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	UIManager.Instance:hideLoadingHUD()
	local applyState = StreamDataAdapter:ReadChar(reader)
	if applyState == 1 then
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
		factionMgr:requestFactionList("2","1")
		UIManager.Instance:showLoadingHUD(5,self.rootNode)		
	elseif applyState == 2 then
		local msg = {}
		table.insert(msg,{word = Config.Words[5557], color = Config.FontColor["ColorWhite1"]})
		UIManager.Instance:showSystemTips(msg)
		GlobalEventSystem:Fire(GameEvent.EventRefreshApplyBtn)
	end	
end


function FactionActionHandler:handleNet_G2C_Union_HandleApply(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	UIManager.Instance:hideLoadingHUD()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	local handIndex = factionMgr:getHandlerIndex()
	if handIndex then
		factionMgr:resetApplyList(handIndex)
		GlobalEventSystem:Fire(GameEvent.EventRefreshApplyList)
		UIManager.Instance:showSystemTips(Config.Words[5548])		
	end
	
end

function FactionActionHandler:handleNet_G2C_Union_Exit(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	factionMgr:setFactionInfo(nil,nil,nil)
end

function FactionActionHandler:handleNet_G2C_Union_CancelJoin(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	UIManager.Instance:hideLoadingHUD()
	local msg = {}
	table.insert(msg,{word = Config.Words[5558], color = Config.FontColor["ColorWhite1"]})
	UIManager.Instance:showSystemTips(msg)
	GlobalEventSystem:Fire(GameEvent.EventRefreshCancelBtn)
end

function FactionActionHandler:handleNet_G2C_Union_Update(reader)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local updateType = StreamDataAdapter:ReadChar(reader)		--数据更新类型
	if updateType == E_Update.add then
		GlobalEventSystem:Fire(GameEvent.EventMemberUpdate,E_Update.add)
	elseif updateType == E_Update.remove then
		GlobalEventSystem:Fire(GameEvent.EventMemberUpdate,E_Update.remove)
	elseif updateType == E_Update.upgrade then
		GlobalEventSystem:Fire(GameEvent.EventOfficeUpdate)
	end
		
end

function FactionActionHandler:handleNet_G2C_requestAssembleFaction(reader) --公会受邀
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local invitePlayerId = StreamDataAdapter:ReadStr(reader)
	local invitePlayerName = StreamDataAdapter:ReadStr(reader)
	local inviteFactionName = StreamDataAdapter:ReadStr(reader)
	local invitePlayerLevel = StreamDataAdapter:ReadInt(reader)

	local inviteObj = MemberObject.New()
	inviteObj:setInvitePlayerId(invitePlayerId)
	inviteObj:setInvitePlayerName(invitePlayerName)
	inviteObj:setInviteFactionName(inviteFactionName)
	inviteObj:setInvitePlayerLevel(invitePlayerLevel)
	factionMgr:setFactionInviteList(inviteObj)
	GlobalEventSystem:Fire(GameEvent.EventupdateFactionInviteView)
	if table.size(factionMgr:getFactionInviteList()) > 0 then
		GlobalEventSystem:Fire(GameEvent.EventSetFactionInviteBtnStatus,true)
	end
	self:factionInviteCountTime(inviteObj)
end
function FactionActionHandler:factionInviteCountTime(object)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	local playerId = object:getInvitePlayerId()
	local TimeFunc = function ()
		local inviteObj = factionMgr:getFactionInviteObjById(playerId)	
		if inviteObj then
			GlobalEventSystem:Fire(GameEvent.EventReplyJoinFaction,inviteObj:getInvitePlayerId(),object:getInviteFactionName(),1)			
		end		if self.testUISchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.testUISchId)
			self.testUISchId = nil
		end			
	end
	self.testUISchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(TimeFunc, 30, false)
end

function FactionActionHandler:handleNet_G2C_FactionInviteReplyActionEvent(reader) --公会邀请返回
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local playerName = StreamDataAdapter:ReadStr(reader)
	local status = StreamDataAdapter:ReadChar(reader)
	GlobalEventSystem:Fire(GameEvent.EventFactionInviteReply,playerName,status)
end
