require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("object.auction.AuctionItemObject")
require ("object.auction.AuctionDef")

AuctionActionHandler = AuctionActionHandler or BaseClass(ActionEventHandler)

function AuctionActionHandler:__init()	
	local handleNet_G2C_Auction_BuyList = function(reader)	
		self:handleNet_G2C_Auction_BuyList(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_BuyList, handleNet_G2C_Auction_BuyList)
			
	local handleNet_G2C_Auction_Buy = function(reader)	
		self:handleNet_G2C_Auction_Buy(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_Buy, handleNet_G2C_Auction_Buy)
	
	local handleNet_G2C_Auction_SellList = function(reader)	
		self:handleNet_G2C_Auction_SellList(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_SellList, handleNet_G2C_Auction_SellList)
	
	local handleNet_G2C_Auction_DoSell = function(reader)	
		self:handleNet_G2C_Auction_DoSell(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_DoSell, handleNet_G2C_Auction_DoSell)		
	
	local handleNet_G2C_Auction_CancelSell = function(reader)	
		self:handleNet_G2C_Auction_CancelSell(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_CancelSell, handleNet_G2C_Auction_CancelSell)	
	
	local handleNet_G2C_Auction_DefaultPrice = function(reader)	
		self:handleNet_G2C_Auction_DefaultPrice(reader)
	end
	self:Bind(ActionEvents.G2C_Auction_DefaultPrice, handleNet_G2C_Auction_DefaultPrice)	
end	

function AuctionActionHandler:handleNet_G2C_Auction_DefaultPrice(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local id = StreamDataAdapter:ReadStr(reader)
	local price = reader:ReadInt()
	GlobalEventSystem:Fire(GameEvent.EventAuctionDefaultPrice, id, price)
end
	
function AuctionActionHandler:parseItems(reader, offset, count)	
	local list = {}
	for i = offset, offset + count - 1 do
		local obj = AuctionItemObject.New()
		obj:setId(StreamDataAdapter:ReadStr(reader))
--		print("id="..obj:getId())
		obj:setRefId(StreamDataAdapter:ReadStr(reader))
		obj:setRemainTime(reader:ReadInt())
		obj:setAuctionPrice(reader:ReadInt())
		
		local pdCount = StreamDataAdapter:ReadChar(reader)
		
		for j = 1, pdCount do
			local pdType = StreamDataAdapter:ReadChar(reader)
			local dataLenght = StreamDataAdapter:ReadShort(reader)
			local pd = getPropertyTable(reader)
			if type(pd) == "table" then
				if (pdType == 1) then 				--总属性字典
					obj:setPT(pd)
					obj:setStaticData(G_getStaticDataByRefId(obj:getRefId()))
				elseif (pdType == 2) then 			--洗练属性字典
					obj:setWashPT(pd)
				else
					CCLuaLog("AuctionActionHandler:parseItems unkown pd. pdType="..pdType)
				end					
			end
		end						
		list[i] = obj
	end
	return list
end	

function AuctionActionHandler:handleNet_G2C_Auction_BuyList(reader)
	UIManager.Instance:hideLoadingHUD(0)
	
	reader = tolua.cast(reader,"iBinaryReader")
	local tag = reader:ReadInt()
	local from = reader:ReadInt()
	local to = reader:ReadInt()
	local max = reader:ReadInt()	
	
	CCLuaLog(string.format("from=%d to=%d max=%d", from, to, max))
	if --[[(from < 0) or --]](from > to) or (from > (max - 1)) or (to > (max - 1)) then
		CCLuaLog("Error:from < 0 or from <= to or to > max - 1")		
		return
	end
		
	G_getAuctionMgr():setBuyListMaxCount(max)
	
	local list
	local count = reader:ReadInt()
	if (not (count > 0)) or (count ~= (to - from + 1)) then
		CCLuaLog("Warnning:(not (count > 0)) or (count ~= (to - from + 1))")
		list = {}
	else
		list = self:parseItems(reader, from, count)	
	end
	G_getAuctionMgr():setBuyList(list, from, to)
	GlobalEventSystem:Fire(GameEvent.EventAuctionBuyList, list, from, to, tag)
end
	
function AuctionActionHandler:handleNet_G2C_Auction_Buy(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local id = StreamDataAdapter:ReadStr(reader)	
	GlobalEventSystem:Fire(GameEvent.EventAuctionBuyRet, true, id)
end
	
function AuctionActionHandler:handleNet_G2C_Auction_SellList(reader)
	UIManager.Instance:hideLoadingHUD(0)
	
	reader = tolua.cast(reader, "iBinaryReader")
	local count = reader:ReadInt()
	local list
	if count > 0 then
		list = self:parseItems(reader, 0, count)		
	else
		list = {}
	end
	G_getAuctionMgr():setSellList(list)	
	GlobalEventSystem:Fire(GameEvent.EventAuctionSellList)	
end
	
function AuctionActionHandler:handleNet_G2C_Auction_DoSell(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local id = StreamDataAdapter:ReadStr(reader)
	G_getAuctionMgr():requestSellList()	--出卖成功后需要申请出卖列表
end
	
function AuctionActionHandler:handleNet_G2C_Auction_CancelSell(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local id = StreamDataAdapter:ReadStr(reader)
	G_getAuctionMgr():requestSellList()	--取消出卖后需要申请出卖列表
	UIManager.Instance:showSystemTips(Config.Words[25329])
end