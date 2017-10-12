require("common.baseclass")

LimitTimeRankMgr = LimitTimeRankMgr or BaseClass()

function LimitTimeRankMgr:__init()
	self.limitTimeRankList = {
	[1] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[2] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[3] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[4] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[5] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[6] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[7] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[8] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},		
	}
	self.verSionList = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	}
	self.tempVerSionList = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	}
	self.selectType = 1
	self.canOpenState = false
	
	self.rankState = {
	[1] = {index = -1, state = -1},
	[2] = {index = -1, state = -1},
	[5] = {index = -1, state = -1},
	[6] = {index = -1, state = -1},
	}	
end	

function LimitTimeRankMgr:clear()
	self.limitTimeRankList = {
	[1] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[2] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[3] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[4] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[5] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[6] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[7] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},
	[8] = {nameList = {},myRank = nil ,rankSection = {},startTime = nil,endTime = nil},		
	}
	self.verSionList = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	}
	self.tempVerSionList = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	}
	self.selectType = 1
	self.canOpenState = false
	self.rankState = {
	[1] = {index = -1, state = -1},
	[2] = {index = -1, state = -1},
	[5] = {index = -1, state = -1},
	[6] = {index = -1, state = -1},
	}
end

--«Î«Û¡–±Ì
function LimitTimeRankMgr:requestLimitTimeRankList(ttype)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_LimitTimeRank_List)
	writer:WriteChar(ttype)
	simulator:sendTcpActionEventInLua(writer)
end

--version
function LimitTimeRankMgr:requestLimitTimeRankVersion(ttyp)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_LimitTimeRank_Version)
	writer:WriteChar(ttyp)
	simulator:sendTcpActionEventInLua(writer)
end

function LimitTimeRankMgr:requestGetLimitRankAward(refId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_LimitTimeRank_GetReward)
	writer:WriteString(refId)	
	simulator:sendTcpActionEventInLua(writer)
end	

function LimitTimeRankMgr:requestLimitRankAwardCanGet() 
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Activity_CanReceive)	
	writer:WriteChar(7)	
	simulator:sendTcpActionEventInLua(writer)		
end

function LimitTimeRankMgr:getLimitTimeRankList()
	return self.limitTimeRankList
end

function LimitTimeRankMgr:getLimitTimeRankVersionList()
	return self.verSionList
end

function LimitTimeRankMgr:getPersonNameList(ttyp)
	return self.limitTimeRankList[ttyp].nameList
end

function LimitTimeRankMgr:setLimitMyRank(ttyp,rank)
	self.limitTimeRankList[ttyp].myRank = rank
end

function LimitTimeRankMgr:getLimitMyRank(ttyp)
	return self.limitTimeRankList[ttyp].myRank
end

function LimitTimeRankMgr:setRankSection(ttyp,section)
	self.limitTimeRankList[ttyp].rankSection = section
end

function LimitTimeRankMgr:getRankSection(ttyp)
	return self.limitTimeRankList[ttyp].rankSection
end	

function LimitTimeRankMgr:setLimitStartTime(ttyp,start)
	self.limitTimeRankList[ttyp].startTime = start	
end

function LimitTimeRankMgr:getLimitStartTime(ttyp)
	return self.limitTimeRankList[ttyp].startTime
end

function LimitTimeRankMgr:setLimitEndTime(ttyp,endTime)
	self.limitTimeRankList[ttyp].endTime = endTime	
end

function LimitTimeRankMgr:getLimitEndTime(ttyp)
	return self.limitTimeRankList[ttyp].endTime
end

function LimitTimeRankMgr:setSelectType(ttyp)
	self.selectType = ttyp	
end

function LimitTimeRankMgr:getSelectType()
	return self.selectType
end

function LimitTimeRankMgr:setTempVerSion(ttyp,verSion)
	self.tempVerSionList[ttyp] = verSion	
end

function LimitTimeRankMgr:getTempVerSion(ttyp)
	return self.tempVerSionList[ttyp]
end

function LimitTimeRankMgr:setCanOpenLimitRankView(state)
	self.canOpenState = state
end

function LimitTimeRankMgr:getCanOpenLimitRankView()
	return self.canOpenState
end

function LimitTimeRankMgr:getLimitTimeRankVersion(ttype)
	return  self.verSionList[ttype]
end

function LimitTimeRankMgr:setLimitTimeRankVersion(ttype,verSion)
	self.verSionList[ttype] = verSion
end

function LimitTimeRankMgr:getRankStateList()
	return self.rankState
end

function LimitTimeRankMgr:getRankStateObj(index)
	return self.rankState[index]
end

function LimitTimeRankMgr:hasAwardCanget()
	for k ,v in pairs(self.limitTimeRankList) do
		for  j , state in pairs(v.rankSection) do
			if state == 2 then
				return  true
			end
		end		
	end
	return false
end