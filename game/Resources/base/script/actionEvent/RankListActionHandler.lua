require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("data.code")

RankListActionHandler = RankListActionHandler or BaseClass(ActionEventHandler)

function RankListActionHandler:__init()
	local handlerVersionNum = function(reader)
		self:handlerVersionNum(reader)
	end

	local handlerNameList = function(reader)
		self:handlerNameList(reader)	
	end
	
	local handlerTopPlayer = function(reader)
		self:handlerTopPlayer(reader)
	end		

	local handleG2C_SortBoard_PFS_GetBoardList = function(reader)
		self:handleG2C_SortBoard_PFS_GetBoardList(reader)	
	end

	self:Bind(ActionEvents.G2C_SortBoard_PFS_GetBoardList,handleG2C_SortBoard_PFS_GetBoardList)
	self:Bind(ActionEvents.G2C_SortBoard_GetSortBoardVersion,handlerVersionNum)	
	self:Bind(ActionEvents.G2C_SortBoard_GetSortBoardData,handlerNameList)
	self:Bind(ActionEvents.G2C_SortBoard_GetTopPlayerData,handlerTopPlayer)
end		

function RankListActionHandler:handlerVersionNum(reader)
	local rankListMgr = GameWorld.Instance:getRankListManager()	
	reader = tolua.cast(reader,"iBinaryReader")	
	
	local rankType = StreamDataAdapter:ReadInt(reader)
	local verNum = StreamDataAdapter:ReadInt(reader)
	
	rankListMgr:setCurRankType(rankType)
	local versionNum = rankListMgr:getVersionNum(rankType) 
	if versionNum then
		if versionNum ~= verNum then
			rankListMgr:setVersionNum(rankType, verNum)
			GlobalEventSystem:Fire(GameEvent.EventRequestNameList,rankType)
		else
			GlobalEventSystem:Fire(GameEvent.EventUpdateRankListView,rankType)
		end
	else
		rankListMgr:setVersionNum(rankType, verNum)
		GlobalEventSystem:Fire(GameEvent.EventRequestNameList,rankType)
	end
end

function RankListActionHandler:handlerNameList(reader)
	local rankListMgr = GameWorld.Instance:getRankListManager()
	reader = tolua.cast(reader,"iBinaryReader")	
	
	--版本号
	local rankType = StreamDataAdapter:ReadChar(reader)  --int ->byte
	rankListMgr:cleanMemberList(rankType)
	rankListMgr:setCurRankType(rankType)	
	
	--英雄记录
	local heroLevel = StreamDataAdapter:ReadInt(reader)
	local heroData  = StreamDataAdapter:ReadLLong(reader)
	if rankType == 5 or rankType == 4 then
		heroData = math.floor(heroData/10)
	end

	local recordObject = rankListMgr:getHero(rankType)
	
	recordObject:setLevel(heroLevel)
	recordObject:setData(heroData)

	--成员记录
	local lenght = StreamDataAdapter:ReadChar(reader) --int ->byte
	for i = 0,lenght-1 do		
		local level = i+1
		local refId = StreamDataAdapter:ReadStr(reader)
		local nickName = StreamDataAdapter:ReadStr(reader)
		local profession = StreamDataAdapter:ReadChar(reader)
		local dataValue = StreamDataAdapter:ReadLLong(reader)
		if rankType == 5 or  rankType == 4 then
			dataValue = math.floor(dataValue/10)
		end
		
		local recordObject = RankListObject.New()
		recordObject:setLevel(level)
		recordObject:setRefId(refId)
		recordObject:setNickName(nickName)
		recordObject:setProfession(profession)
		recordObject:setData(dataValue)	
		
		rankListMgr:addOneMember(rankType, i, recordObject)
	end
	rankListMgr:requestTopPlayer()
	GlobalEventSystem:Fire(GameEvent.EventUpdateRankListView,rankType)
end

function RankListActionHandler:handlerTopPlayer(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local topPlayerCount = StreamDataAdapter:ReadChar(reader)
	local topPlayerList = {}
	for i = 0, topPlayerCount-1 do
		local topPlayerName = StreamDataAdapter:ReadStr(reader)
		topPlayerList[i] = topPlayerName
	end
	local rankListMgr = GameWorld.Instance:getRankListManager()
	rankListMgr:setTopPlayerList(topPlayerList)
	local rankListView = UIManager.Instance:getViewByName("RankListView")
	rankListView:updateLeft()
end

function RankListActionHandler:handleG2C_SortBoard_PFS_GetBoardList(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local rankListMgr = GameWorld.Instance:getRankListManager()
	
	local rankType = StreamDataAdapter:ReadInt(reader)
	local verNum = StreamDataAdapter:ReadInt(reader)
	local proType = StreamDataAdapter:ReadChar(reader)
	rankListMgr:cleanSubMemberList(proType)
	rankListMgr:setSubVersionNum(proType, verNum)
	
	local count = StreamDataAdapter:ReadChar(reader)
	for i = 0 ,count-1 do			
		local level = i+1
		local refId = StreamDataAdapter:ReadStr(reader)
		local nickName = StreamDataAdapter:ReadStr(reader)
		local profession = StreamDataAdapter:ReadStr(reader)
		local dataValue = StreamDataAdapter:ReadLLong(reader)
		
		local recordObject = RankListObject.New()
		recordObject:setLevel(level)
		recordObject:setRefId(refId)
		recordObject:setNickName(nickName)
		recordObject:setProfession(profession)
		recordObject:setData(dataValue)	
		
		rankListMgr:addOneSubMember(proType, i, recordObject)
	end	
end

function RankListActionHandler:__delete()
	
end	