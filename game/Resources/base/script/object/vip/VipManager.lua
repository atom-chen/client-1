require("common.baseclass")

VipManager = VipManager or BaseClass()

function VipManager:__init()
	self.vipLevel = 0
	self.dayRest = 0
	self.expAwardState = false
	self.dayGiftState = false
	self.levelAwardState = false

end	

function VipManager:clear()
	self.vipLevel = 0
	self.dayRest = 0
	self.expAwardState = false
	self.dayGiftState = false
	self.levelAwardState = false
end

--使用Vip卡
function VipManager:requestUsingVipCard(cardType)
		
end

function VipManager:requestGetReward(opt)  -- 1  2  3  4
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Vip_GetAward)
	writer:WriteChar(opt)	
	simulator:sendTcpActionEventInLua(writer)		
end

--请求奖励列表
function VipManager:requestVipAwardList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Vip_AwardList)	
	simulator:sendTcpActionEventInLua(writer)		
end

--请求Vip State
function VipManager:requestVipState()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Vip_State)	
	simulator:sendTcpActionEventInLua(writer)	
end

function VipManager:setVipLevel(level)
	self.vipLevel = level
end

function VipManager:getVipLevel()
	return self.vipLevel
end


function VipManager:setVipDayRest(restday)
	self.dayRest = restday
end

function VipManager:getVipDayRest()
	return self.dayRest
end

--每日经验奖励
function VipManager:setExpAwardState(state)
	self.expAwardState = state
end

--每日礼包
function VipManager:setDayGiftAwardState(state)
	self.dayGiftState = state	
end

function VipManager:setStateFalse()
	local index = self.awardGetIndex 
	
	if index == 1 then
		self.expAwardState = false
		local tipsStr = string.format(Config.Words[13020] , self.vipLevel + 1)
		UIManager.Instance:showSystemTips(tipsStr)
	elseif index == 2 then
		self.dayGiftState = false	
	elseif index == 3	then	
		self.levelAwardState = false	
	elseif index == 4 then
		if self.expAwardState == true then
			local tipsStr = string.format(Config.Words[13020] , self.vipLevel + 1)
			UIManager.Instance:showSystemTips(tipsStr)
		end
		self.expAwardState = false
		self.dayGiftState = false
		self.levelAwardState = false
	end
end

function VipManager:setIndexState(index,state)
	if index == 1 then
		self.expAwardState = state
	elseif index == 2 then
		self.dayGiftState = State
	else
		self.levelAwardState = state
	end	
end

function VipManager:getIndexState(index)
	if index == 1 then
		return self.expAwardState
	elseif index == 2 then
		return self.dayGiftState
	else
		return self.levelAwardState
	end	
end

function VipManager:CanGetAward()
	return (self.expAwardState or self.dayGiftState or self.levelAwardState )	
end

--等级奖励  （已领取的高级等级礼包）
function VipManager:setLevelAwardState(state)
	self.levelAwardState = state
end

--每日经验奖励
function VipManager:getExpAwardState()
	return self.expAwardState
end

--每日礼包
function VipManager:getDayGiftAwardState()
	return self.dayGiftState
end

--等级奖励
function VipManager:getLevelAwardState()
	return self.levelAwardState
end	

--每日礼包
function VipManager:setAwardGetIndex(index)
	self.awardGetIndex = index
end

--等级奖励
function VipManager:getAwardGetIndex()
	return self.awardGetIndex
end	