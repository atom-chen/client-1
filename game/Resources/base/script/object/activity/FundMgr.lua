require("common.baseclass")
require"object.activity.ActivityDef"
FundMgr = FundMgr or BaseClass()


--[[
C2G_Fund_ApplyVersionByType = Activity_Message_Begin + 75	//请求基金类型版本号
	fundType             byte//基金类型
C2G_Fund_FundGetRewardList = Activity_Message_Begin + 77	//请求基金领奖列表
	fundType             byte//基金类型

C2G_Fund_GetReward = Activity_Message_Begin + 81	//请求领取基金奖励
	fundType             byte//基金类型
	day                  int//领取第几天
C2G_Fund_BuyWhichFund = Activity_Message_Begin + 79	//请求购买哪个基金
	fundType             byte//基金类型
]]
function FundMgr:__init()
	self.fundVerSionList = {}
	self.fundStateList = {}
	self.currentDayList = {}
	self.currentDay = 1
	self:initFundSize()
end		

function FundMgr:clear()
	self.fundVerSionList = {}
	self.fundStateList = {}
	self.currentDayList = {}
	self.currentDay = 1	
	self:initFundSize()	
end

function FundMgr:requestFundState() 
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Fund_IsReceive)		
	simulator:sendTcpActionEventInLua(writer)		
end

function FundMgr:requestFundVersion(fundType)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Fund_ApplyVersionByType)	
	writer:WriteChar(fundType)	
	simulator:sendTcpActionEventInLua(writer)
end

function FundMgr:requestFundList(fundType)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Fund_FundGetRewardList)	
	writer:WriteChar(fundType)		
	simulator:sendTcpActionEventInLua(writer)
end


function FundMgr:requestBuyFund(fundType)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Fund_BuyWhichFund)	
	writer:WriteChar(fundType)	
	simulator:sendTcpActionEventInLua(writer)
end


function FundMgr:requestGetFundReward(fundType,day)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Fund_GetReward)	
	writer:WriteChar(fundType)	
	writer:WriteInt(day)			
	simulator:sendTcpActionEventInLua(writer)
end


function FundMgr:initFundSize()
	
	self.fundSize = G_GetFundSize()
	for i=1,self.fundSize do
		self:initFundList(i)
	end	
end

function FundMgr:getFundSize()
	return self.fundSize
end

function FundMgr:setFundVersion(fundType,verSion)
	self.fundVerSionList[fundType] = verSion
end

function FundMgr:getFundVersion(fundType)
	return self.fundVerSionList[fundType]
end

function FundMgr:initFundList(ttype)
	self.fundStateList[ttype] = {}
	local stateList = self.fundStateList[ttype]
	for day = 1,30 do
		stateList[day] = -1
	end
end

function FundMgr:getFundStateList(ttype)
	return self.fundStateList[ttype]
end

function FundMgr:setCurrentDay(ttype,day)
	self.currentDayList[ttype] = day	
end

function FundMgr:getCurrentDay(ttype)
	return self.currentDayList[ttype]
end