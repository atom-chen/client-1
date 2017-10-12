require("common.BaseObj")

RewardType = {
	unbind = 1,
	bind = 2,	
}

RechargeObject = RechargeObject or BaseClass(BaseObj)

function RechargeObject:__init(data,index)
	if self:validateData(data) then
		self.refId = data.refid
		self.level = data.level
		self.yuanBao = data.yuanBao
		self.money = data.money
		self.reward = data.reward
		self.rewardBound = data.rewardBound
		self.itemRefId = data.iconId
		self.firstReward =  data.firstReward
		self.productName = data.goodName
		self.firstRewardBound = data.firstRewardBound
		self.firstTopUp = false
		self.index = index
	end		
end

function RechargeObject:__delete()
		
end

function RechargeObject:validateData(data)
	return data.level and data.yuanBao and data.money and data.reward and data.iconId
end

function RechargeObject:getRefId()
	return self.refId
end

function RechargeObject:getLevel()
	return self.level
end

function RechargeObject:getProductName()
	return self.productName
end

function RechargeObject:getYuanBao()
	return self.yuanBao
end

function RechargeObject:getMoney()
	return self.money
end

function RechargeObject:getReward()
	return self.reward
end

function RechargeObject:getItemRefId()
	return self.itemRefId
end

function RechargeObject:isFirstTopup()
	return self.firstTopUp
end

function RechargeObject:setFirstTopup(isFirst)
	self.firstTopUp = isFirst
end

function RechargeObject:getShowingReward()
	if self.firstTopUp then
		if self.firstReward >0 then
			return self.firstReward,RewardType.unbind
		else
			return self.firstRewardBound,RewardType.bind
		end
		return self.firstReward
	else
		if self.reward > 0 then
			return self.reward,RewardType.unbind
		else
			return self.rewardBound,RewardType.bind
		end			
	end
end

function RechargeObject:getIndex()
	return self.index
end


	

	

