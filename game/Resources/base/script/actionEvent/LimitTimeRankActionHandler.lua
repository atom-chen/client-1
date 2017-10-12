require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

LimitTimeRankActionHandler = LimitTimeRankActionHandler or BaseClass(ActionEventHandler)


function LimitTimeRankActionHandler:__init()	
	local handleNet_G2C_LimitTimeRank_TimeOver = function(reader)
		self:handleNet_G2C_LimitTimeRank_TimeOver(reader)
	end
	
	local handleNet_G2C_LimitTimeRank_Version = function(reader)
		self:handleNet_G2C_LimitTimeRank_Version(reader)
	end

	local handleNet_G2C_LimitTimeRank_List = function(reader)
		self:handleNet_G2C_LimitTimeRank_List(reader)
	end
	
	local handleNet_G2C_LimitTimeRank_GetReward = function(reader)
		self:handleNet_G2C_LimitTimeRank_GetReward(reader)
	end

	self:Bind(ActionEvents.G2C_LimitTimeRank_List,handleNet_G2C_LimitTimeRank_List)
	self:Bind(ActionEvents.G2C_LimitTimeRank_TimeOver,handleNet_G2C_LimitTimeRank_TimeOver)
	self:Bind(ActionEvents.G2C_LimitTimeRank_Version,handleNet_G2C_LimitTimeRank_Version)		
	self:Bind(ActionEvents.G2C_LimitTimeRank_GetReward,handleNet_G2C_LimitTimeRank_GetReward)		
end

function LimitTimeRankActionHandler:handleNet_G2C_LimitTimeRank_TimeOver(reader)
	reader = tolua.cast(reader,"iBinaryReader")		
	local limitRankMgr = GameWorld.Instance:getLimitTimeRankManager() 	
	local state = reader:ReadChar()
	if state == 1 then	--
		limitRankMgr:setCanOpenLimitRankView(true)
--[[	local heroObj = G_getHero()
		mainActivityMgr  = heroObj:getMainMgr()
		local btList = mainActivityMgr:getBtnList()
		local key = table.size(btList) + 1
		mainActivityMgr:--]]
	else
		limitRankMgr:setCanOpenLimitRankView(false)
	end
end

function LimitTimeRankActionHandler:handleNet_G2C_LimitTimeRank_Version(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local ttype = StreamDataAdapter:ReadChar(reader)	
	local verSion = StreamDataAdapter:ReadInt(reader)	
	
	local limitRankMgr = GameWorld.Instance:getLimitTimeRankManager()
	local preVerSion = limitRankMgr:getLimitTimeRankVersion(ttype)	
	if preVerSion ~= verSion then
		limitRankMgr:setTempVerSion(ttype,verSion)
		limitRankMgr:requestLimitTimeRankList(ttype)
	else
		GlobalEventSystem:Fire(GameEvent.EventLimitRankNodeUpdate,ttype)
	end
end

function LimitTimeRankActionHandler:handleNet_G2C_LimitTimeRank_List(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local beginTime = StreamDataAdapter:ReadStr(reader)	
	local endTime = StreamDataAdapter:ReadStr(reader)		
	local myRank = StreamDataAdapter:ReadInt(reader)
	local count = StreamDataAdapter:ReadShort(reader)
	
	local limitRankMgr = GameWorld.Instance:getLimitTimeRankManager()

	local refId = StreamDataAdapter:ReadStr(reader)	
	local ttype = nil
	if refId then
		ttype = tonumber(string.match(refId,"%d+"))				
	end
	if ttype then
		local state =  StreamDataAdapter:ReadChar(reader)	
		local name = StreamDataAdapter:ReadStr(reader)		
		local limitRankList = limitRankMgr:getRankSection(ttype)
		local limitNameList = limitRankMgr:getPersonNameList(ttype)
		
		limitRankMgr:setLimitStartTime(ttype,beginTime)
		limitRankMgr:setLimitEndTime(ttype,endTime)	
		limitRankMgr:setLimitMyRank(ttype,myRank)
		
		limitRankList[refId] = state
		limitNameList[refId] = name
		for i=1,count-1 do
			local refId = StreamDataAdapter:ReadStr(reader)
			local state =  StreamDataAdapter:ReadChar(reader)	
			local name = StreamDataAdapter:ReadStr(reader)		
			limitRankList[refId] = state
			limitNameList[refId] = name
		end
		limitRankMgr:setLimitTimeRankVersion(ttype,limitRankMgr:getTempVerSion(ttype))
		GlobalEventSystem:Fire(GameEvent.EventLimitRankNodeUpdate,ttype)
	else
		CCLuaLog("handleNet_G2C_LimitTimeRank_List refId is unvalided")
	end
	
end

function LimitTimeRankActionHandler:handleNet_G2C_LimitTimeRank_GetReward(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local refId = StreamDataAdapter:ReadStr(reader)	
	local ttype = tonumber(string.match(refId,"%d+"))	
	local limitRankMgr = GameWorld.Instance:getLimitTimeRankManager()	
	local section  = limitRankMgr:getRankSection(ttype)
	section[refId] = 1
	
	if not limitRankMgr:hasAwardCanget()  then
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
		activityManageMgr:setActivityState("activity_manage_18",false)
		ActivityDelegate:showEffectInLimitRankButton(false)--mark
	end		

	GlobalEventSystem:Fire(GameEvent.EventLimitRankNodeUpdate,ttype)	
end

