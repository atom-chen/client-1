require("common.baseclass")

SignManager = SignManager or BaseClass()

function SignManager:__init()
	self.signList = {}
	self.awardStateList = {}
	self.awardList = {}
	self.dateStr = "000001"
	self.signDayCount = 0
	self.dayOfMonth = 0
	self.signState = true
	self.fillSign = true
	self.canGetAward = true
end	

function SignManager:clear()
	self.signList = {}
	self.awardStateList = {}
	self.awardList = {}
	self.dateStr = "000001"
	self.signDayCount = 0
	self.dayOfMonth = 0
	self.signState = true
	self.fillSign = true
	self.canGetAward = true
end

function SignManager:initSignList(size)
	for i=1,size do
		self.signList[i] = false
	end	
end

--签到
function SignManager:requestSign(signType)  --1 为签到   2为 补签
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Sign_SignIn)
	writer:WriteChar(signType)	
	simulator:sendTcpActionEventInLua(writer)	
end

--领取累积奖励
function SignManager:requestGetReward(refId)  -- 1  2  3  4
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Activity_GetAward)
	writer:WriteChar(2)
	writer:WriteString(refId)	
	simulator:sendTcpActionEventInLua(writer)		
end

--请求签到列表
function SignManager:requestSignList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Sign_SignList)	
	simulator:sendTcpActionEventInLua(writer)		
end

--是否有累积签到奖励
function SignManager:hasSignAward()
	for k, v in pairs(self.awardList) do
		if v == 2 then	--可领取
			return true
		end
	end
	return false
end

function SignManager:setCanNormalSign(state)
	self.signState = state
end

function SignManager:canNormalSign()
	return self.signState
end

function SignManager:setFillSignState(state)
	self.fillSign = state
end

function SignManager:getFillSignState()
	return self.fillSign
end

function SignManager:setCanGetAwardState(state)
	self.canGetAward = state
end

function SignManager:getCanGetAwardState()
	return self.canGetAward
end

function SignManager:signIndex(index)
	self.signList[index] = true	
end

function SignManager:setSignList(list)
	self.signList = list
end

function SignManager:setAwardList(list)
	self.awardList = list
end

function SignManager:setAwardStateList(list)
	self.awardStateList = list
end

function SignManager:getAwardStateList()
	return self.awardStateList	
end

function SignManager:getSignList()
	return self.signList
end

function SignManager:getAwardList()
	return self.awardList
end

function SignManager:setDateStr(str)
	self.dateStr = str
end

function SignManager:getDateStr()
	return self.dateStr
end

function SignManager:setDaysOfMonth(count)
	self.dayOfMonth = count	
end

function SignManager:getDaysOfMonth()
	return self.dayOfMonth
end

function SignManager:setSignDayCount(num)
	self.signDayCount = num
end

function SignManager:getFirstFillDay()
	for k ,v in pairs(self.signList) do
		if v == false then
			return k
		end
	end	
end

function SignManager:getCurrentDay()
	if string.len(self.dateStr) >0 then
		local cDay = tonumber(string.sub(self.dateStr,7))
		return 	cDay
	end
end

function SignManager:getSignDayCount()
	return self.signDayCount
end