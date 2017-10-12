AuctionMgr = AuctionMgr or BaseClass()

function AuctionMgr:__init()
	self:clear()
end

function AuctionMgr:__delete()

end	

function AuctionMgr:getBuyListMaxCount()
	return self.buyListMaxCount
end

function AuctionMgr:setBuyListMaxCount(count)
	self.buyListMaxCount = count
end

function AuctionMgr:clear()
	self.buyListMaxCount = 0
	self.buyList = {}
	self.buyListFrom = 0 
	self.buyListTo = 0
	self.sellList = {}
	self.searchFilter = {name = "", bodyAreaId = -1, level = -1, canUseLimit = -1, itemType = -1}	
end	

function AuctionMgr:clearBuyList()
	self.buyList = {}
	self.buyListFrom = -1
	self.buyListTo = -1
end

function AuctionMgr:setBuyList(list, from, to)
	if type(from) ~= "number" 
		or type(to) ~= "number" 
		or from > to then
		CCLuaLog("AuctionMgr:setBuyList param error")
		return
	end		
	
	self.buyListFrom = from 
	self.buyListTo = to
	self.sellList = list
end

function AuctionMgr:getBuyListRange()
	return self.from, self.to
end

function AuctionMgr:getBuyList()
	return self.buyList
end

function AuctionMgr:getSellList()
	return self.sellList
end

function AuctionMgr:setSellList(list)
	self.sellList = list
end

function AuctionMgr:clearSellList()
	self.sellList = {}
end

function AuctionMgr:saveSearchFilter(name, bodyAreaId, level, canUseLimit, itemType)
	if type(name) ~= "string" or type(bodyAreaId) ~= "number"
		or type(level) ~= "number" or type(canUseLimit) ~= "number"
		or type(itemType) ~= "number" then
		CCLuaLog("setSearchFilter param error")
		return
	end	
	self.searchFilter.name = name
	self.searchFilter.bodyAreaId = bodyAreaId
	self.searchFilter.level = level
	self.searchFilter.canUseLimit = canUseLimit
	self.searchFilter.itemType = itemType
end

function AuctionMgr:saveSearchFilterTable(param)
	local name = param.name 
	local bodyAreaId = param.bodyAreaId
	local level = param.level
	local canUseLimit = param.canUseLimit
	local itemType = param.itemType
	self:saveSearchFilter(name, bodyAreaId, level, canUseLimit, itemType)	
end

function AuctionMgr:getSearchFilter()
	return self.searchFilter
end

local const_baseMaxSellCount = 10
function AuctionMgr:getMaxSellCountByVipLevel(level)
	local count = const_baseMaxSellCount
	if type(level) ~= "number" then
		return count
	end
	local refId = "vip_"..level
	if not GameData.Vip[refId] then
		return count
	end
	
	return (count + GameData.Vip[refId].property.maxAuctionCount)
end

function AuctionMgr:requestBuyList(from, to, param, tag)
	if type(from) ~= "number" or type(to) ~= "number" or type(param) ~= "table" or type(tag) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_BuyList)
	
	writer:WriteInt(tag)
	writer:WriteInt(from)
	writer:WriteInt(to)
	writer:WriteString(param.name)
	writer:WriteShort(param.bodyAreaId)
	writer:WriteShort(param.level)
	writer:WriteShort(param.canUseLimit)	
	writer:WriteShort(param.itemType)	
--[[	
	writer:WriteChar(param.bodyAreaId)
	writer:WriteChar(param.level)
	writer:WriteChar(param.canUseLimit)	
	writer:WriteChar(param.itemType)	--]]
	simulator:sendTcpActionEventInLua(writer)
	
--[[	
	local simulator1 = SFGameSimulator:sharedGameSimulator()
	local writer1 = simulator:getBinaryWriter(888)
		
	writer1:WriteChar(-1);  --安卓手机发送，服务器会收到0，而不是 -1 
	writer1:WriteShort(-1);	--正常
	writer1:WriteInt(-1);	--正常

	simulator1:sendTcpActionEventInLua(writer1)
--]]
--[[
	print("requestBuyList")
	local list, f, t = self:buildTestAuctionItemList(from, to)	
	GlobalEventSystem:Fire(GameEvent.EventAuctionBuyList, list, f, t)
	--]]
end	

function AuctionMgr:buildTestAuctionItemList(from, to)
	local index = from
	local list = {}
	local bagList = G_getBagMgr():getItemMap()	
	for k, v in pairs(bagList) do
		local obj = AuctionItemObject.New()
		obj:setId(v:getId())
		obj:setRefId(v:getRefId())
		obj:setRemainTime(1000)
		obj:setAuctionPrice(88)
		obj:setPT(v:getPT())
		obj:setWashPT(v:getWashPT())
		list[index] = obj
		index = index + 1
		if index > to then
			break
		end
	end
	return list, from, index
end

function AuctionMgr:requestBuyOneItem(id)
	if (type(id) ~= "string" ) then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_Buy)	
	writer:WriteString(id)	
	simulator:sendTcpActionEventInLua(writer)	
end	

function AuctionMgr:requestSellList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_SellList)			
	simulator:sendTcpActionEventInLua(writer)	
end

function AuctionMgr:requestDoSell(id, number, price)
	if type(id) ~= "string" or type(number) ~= "number" or type(price) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_DoSell)		
	writer:WriteString(id)			
	writer:WriteInt(number)			
	writer:WriteInt(price)			
	simulator:sendTcpActionEventInLua(writer)	
end

function AuctionMgr:requestCancelSell(id)
	if type(id) ~= "string" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_CancelSell)
	writer:WriteString(id)				
	simulator:sendTcpActionEventInLua(writer)	
end

function AuctionMgr:requestDefaultPrice(id, number)
	if type(id) ~= "string" or type(number) ~= "number" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Auction_DefaultPrice)
	writer:WriteString(id)				
	writer:WriteInt(number)				
	simulator:sendTcpActionEventInLua(writer)	
end