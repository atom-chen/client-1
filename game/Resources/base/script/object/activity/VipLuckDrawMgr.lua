require("common.baseclass")
require("config.words")
require("data.vip.viplottery")
VipLuckDrawMgr = VipLuckDrawMgr or BaseClass()

function VipLuckDrawMgr:__init()
	
end

function VipLuckDrawMgr:__delete()
	
end

function VipLuckDrawMgr:clear()
	self.identityId = nil
	self.curCount = 0
	self.nextCount = 0
	self.itemList = {}
	self.luckIndex = nil
	self.luckItemRefId = nil
end

--打开抽奖界面请求
function VipLuckDrawMgr:requestOpenLuckDraw()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Vip_OpenLottery)
	simulator:sendTcpActionEventInLua(writer)	
end
--抽奖请求
function VipLuckDrawMgr:requestLuckDraw(lotteryType)
	if lotteryType == nil then
		CCLuaLog("ArgError:VipLuckDrawMgr:requestLuckDraw")
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Vip_Lottery)
	StreamDataAdapter:WriteChar(writer,lotteryType)
	simulator:sendTcpActionEventInLua(writer)	
end

--设置vip身份Id
function VipLuckDrawMgr:setIdentityId(identityId)
	self.identityId = identityId
end

function VipLuckDrawMgr:getIdentityId()
	return self.identityId
end

function VipLuckDrawMgr:getIdentityNameAndColorById(identityId)
	if identityId == E_identity.none then
		return Config.Words[13316],FCOLOR("ColorWhite1")
	elseif identityId == E_identity.bronzeVip then
		return Config.Words[13313],FCOLOR("ColorGreen1")
	--[[elseif identityId == E_identity.silverVip then
		return Config.Words[13314]--]]
	elseif identityId == E_identity.goldVip then
		return Config.Words[13315],FCOLOR("ColorYellow1")
	end

end
--当前剩余抽奖次数
function VipLuckDrawMgr:setCurrentCount(curCount)
	self.curCount = curCount
end

function VipLuckDrawMgr:getCurrentCount()
	return self.curCount
end
--明日可抽奖次数
function VipLuckDrawMgr:setNextCount(nextCount)
	self.nextCount = nextCount
end

function VipLuckDrawMgr:getNextCount()
	return self.nextCount
end	

function VipLuckDrawMgr:cleanItemList()
	self.itemList = {}
end

function VipLuckDrawMgr:setItemListByPosition(index,itemRefId)
	if index == nil or itemRefId == nil then
		CCLuaLog("ArgError:VipLuckDrawMgr:setItemListByPosition")
		return
	end
	self.itemList[index] = itemRefId
end

function VipLuckDrawMgr:getItemList()
	return self.itemList
end
--中奖ID
function VipLuckDrawMgr:setLuckIndex(index)
	if index == nil then
		CCLuaLog("ArgError:VipLuckDrawMgr:setLuckIndex")
		return
	end
	self.luckIndex = index
	if self.itemList and index ~= -1 then
		self.luckItemRefId = self.itemList[index]
	end
end

function VipLuckDrawMgr:getLuckIndex()
	return self.luckIndex
end

--奖品refId
function VipLuckDrawMgr:getLuckItemRefId()
	return self.luckItemRefId
end

--抽奖次数不足提示
function VipLuckDrawMgr:getBuyVipTipsByIdentityId(identityId)
	local vipInfo = GameData.Viplottery["lotteryvip"]
	if vipInfo then
		local data = vipInfo.configData
		if data then
			if identityId == 3 then
				for i,v in pairs(data) do
					if v.property then
						if v.property.vipType == identityId then
							return v.property.tips
						end
					end
				end
			else		
				if data["lotvip_0"].property.tips and data["lotvip_1"].property.tips then
					local tips = string.format("%s\n%s",data["lotvip_0"].property.tips,data["lotvip_1"].property.tips)
					return tips
				end
			end
		end
	end
end

--抽奖vip增加次数
function VipLuckDrawMgr:getBuyVipTipsCountByIdentityId(identityId)
	if identityId == nil then
		CCLuaLog("ArgError:VipLuckDrawMgr:getBuyVipTipsCountByIdentityId")
		return
	end
	local vipInfo = GameData.Viplottery["lotteryvip"]
	if vipInfo then
		local data = vipInfo.configData
		if data then
			local refId = "lotvip_"..identityId
			if data[refId] then
				if data[refId].property then				
					return  data[refId].property.timesADay
				end
			end
		end
	end
end

function VipLuckDrawMgr:getItemTypeByRefId(refId)
	local rewardInfo = GameData.Viplottery["lotteryreward"]
	if rewardInfo then
		local data = rewardInfo.configData
		if data then
			for i,v in pairs(data) do
				if v.property then
					if refId and PropertyDictionary:get_itemRefId(v.property) == refId then
						return v.property.itemType
					end
				end
			end
		end
	end
end

function VipLuckDrawMgr:getItemCountByRefId(refId)
	local rewardInfo = GameData.Viplottery["lotteryreward"]
	if rewardInfo then
		local data = rewardInfo.configData
		if data then
			for i,v in pairs(data) do
				if v.property then
					if refId and v.property.itemRefId == refId then
						local itemType = v.property.itemType
						local count = v.property.number
						return count
					end						
				end
			end
		end
	end
end

function VipLuckDrawMgr:setMarqueeMsg(msg)
	self.marqueeMsg = msg
end

function VipLuckDrawMgr:getMarqueeMsg()
	return self.marqueeMsg
end

function VipLuckDrawMgr:openVipView()
	GlobalEventSystem:Fire(GameEvent.EventVipViewOpen)		
end