require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.rankList.RankListObject")
require("ui.UIManager")

RankListMgr = RankListMgr or BaseClass()

RankList_RankType = {
	fight = 0,
	level = 1,
	rich = 2,
	knight = 3,
	wingLevel = 4,
	rideLevel = 5,
	talisman = 6, 
}

RankList_ProType = {
	total = 0,
	zhanshi = 1,
	fashi = 2,
	daoshi = 3,
}

function RankListMgr:__init()
	self.rankList = {}
	self.subRankList = {}
	self:initRankListObject()
	self.curRankType = 0
end

function RankListMgr:clear()
	for k,v in pairs(RankList_RankType) do
		self.rankList[v].versionNum = nil
		self:cleanMemberList(v)
	end
	for k,v in pairs(RankList_ProType) do
		self.subRankList[v].versionNum = nil
		self:cleanSubMemberList(v)
	end
end

function RankListMgr:initRankListObject()
	local heroObj = GameWorld.Instance:getEntityManager():getHero()
	for k,v in pairs(RankList_RankType) do
		self.rankList[v] = {}
		self.rankList[v].member = {}
		self.rankList[v].hero = RankListObject.New()
		local heroNickName = PropertyDictionary:get_name(heroObj:getPT()) 
		local heroProfession = PropertyDictionary:get_professionId(heroObj:getPT())
		self.rankList[v].hero:setNickName(heroNickName)
		self.rankList[v].hero:setProfession(heroProfession)
	end
	for k,v in pairs(RankList_ProType) do
		self.subRankList[v] = {}
		self.subRankList[v].member = {}
	end
end

function RankListMgr:requestVersionNum(rankType)
	if type(rankType) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_SortBoard_GetSortBoardVersion)
		StreamDataAdapter:WriteInt(writer, rankType)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function RankListMgr:requestNameList(rankType)
	if type(rankType) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_SortBoard_GetSortBoardData)
		StreamDataAdapter:WriteInt(writer, rankType)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function RankListMgr:requestTopPlayer()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_SortBoard_GetTopPlayerData)
	simulator:sendTcpActionEventInLua(writer)
end

function RankListMgr:requestFpSubList(rankType,proffesion)
	if type(rankType) == "number" and type(proffesion) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_SortBoard_PFS_GetBoardList)
		StreamDataAdapter:WriteInt(writer, rankType)
		StreamDataAdapter:WriteInt(writer, proffesion)
		simulator:sendTcpActionEventInLua(writer)
	end
end	

function RankListMgr:setCurRankType(rankType)
	if type(rankType) == "number" then
		self.curRankType = rankType
	end
end

function RankListMgr:getCurRankType()
	return self.curRankType
end


function RankListMgr:getRankList(rankType)
	if type(rankType) == "number" then
		if self.rankList[rankType] then
			return self.rankList[rankType]
		else
			return nil
		end
	end
end

function RankListMgr:setVersionNum(rankType, verNum)
	if type(rankType) == "number" and type(verNum) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			rankList.versionNum = verNum
		end
	end
end

function RankListMgr:getVersionNum(rankType)
	if type(rankType) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			return rankList.versionNum
		else
			return nil
		end
	end
end

function RankListMgr:addOneMember(rankType, index, menber)
	if type(rankType) == "number" and type(index) == "number" and menber then
		local rankList = self:getRankList(rankType)	
		if rankList then
			if rankList.member and type(rankList.member) == "table" then
				table.insert(rankList.member, index, menber)
			end
		end
	end
end

function RankListMgr:getMemberList(rankType)
	if type(rankType) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			return rankList.member		
		end
	end
end

function RankListMgr:getOneMember(rankType, index)
	if type(rankType) == "number" and type(index) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			if rankList.member and type(rankList.member) == "table" then
				return rankList.member[index]
			end
		end
	end
end

function RankListMgr:cleanMemberList(rankType)
	if type(rankType) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			for k,v in pairs(rankList.member) do
				v:DeleteMe()
			end
			rankList.member = {}
		end
	end
end

function RankListMgr:setHero(rankType, hero)
	if hero and type(rankType) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			rankList.hero = hero
		end
	end
end

function RankListMgr:getHero(rankType)
	if type(rankType) == "number" then
		local rankList = self:getRankList(rankType)	
		if rankList then
			return rankList.hero		
		end
	end
end

function RankListMgr:getSubRankList(proType)
	if type(proType) == "number" then
		return self.subRankList[proType]
	end
end	

function RankListMgr:setSubVersionNum(proType, verNum)
	if type(proType) == "number" then
		local subRankList = self:getSubRankList(proType)
		if subRankList then
			subRankList.versionNum = verNum
		end
	end
end

function RankListMgr:getSubVersionNum(proType)
	if type(proType) == "number" then
		local subRankList = self:getSubRankList(proType)
		if subRankList then
			return subRankList.versionNum
		end
	end
end

function RankListMgr:addOneSubMember(proType, index, menber)
	if type(proType) == "number" and type(index) == "number" and type(menber) == "table" then
		local subRankList = self:getSubRankList(proType)	
		if subRankList then
			if subRankList.member and type(subRankList.member) == "table" then
				table.insert(subRankList.member, index, menber)
			end
		end
	end
end

function RankListMgr:getSubMemberList(proType)
	if type(proType) == "number" then
		local subRankList = self:getSubRankList(proType)	
		if subRankList then
			return subRankList.member		
		end
	end
end

function RankListMgr:getOneSubMember(proType, index)
	if type(proType) == "number" and type(index) == "number" then
		local subRankList = self:getSubRankList(proType)	
		if subRankList then
			if subRankList.member and type(subRankList.member) == "table" then
				return subRankList.member[index]
			end
		end
	end
end

function RankListMgr:cleanSubMemberList(proType)
	if type(proType) == "number" then
		local subRankList = self:getSubRankList(proType)	
		if subRankList then
			for k,v in pairs(subRankList.member) do
				v:DeleteMe()
			end
			subRankList.member = {}
		end
	end
end

function RankListMgr:setTopPlayerList(list)
	if type(list) == "table" then
		self.topPlayerList = list
	end
end

function RankListMgr:getTopPlayerList()
	return self.topPlayerList
end	

function RankListMgr:__delete()
	self.rankListObject:DeleteMe()
end