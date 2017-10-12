require("ui.auction.AuctionBuy")
require("ui.auction.AuctionSell")
require("ui.auction.AuctionView")
require("ui.auction.AuctionMenu")

AuctionUIHandler = AuctionUIHandler or BaseClass(GameEventHandler)

function AuctionUIHandler:__init()
	local manager = UIManager.Instance
	manager:registerUI("AuctionView", AuctionView.New)	
	manager:registerUI("AuctionMenu", AuctionMenu.New)	
	
	local onEventOpenAuctionView = function (showOption, arg)		
		manager:showUI("AuctionView",  showOption, arg)		
	end
	local onEventOpenAuctionMenu = function ()		
		manager:showUI("AuctionMenu", E_ShowOption.eMiddle, nil)		
	end
	
	local onEventAuctionBuyList = function (list, f, t, tag)	
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("buy")
		end
		if view then
			view:setBuyList(list, f, t, tag)
		end
	end
	
	local onEventAuctionSearchValueChanged = function (ttype, value)	
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("buy")
		end
		if view then
			view:setBtnValue(ttype, value)
		end
	end
	
	local onItemUpdate = function(eventType, map)
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("sell")
		end
		if view then	
			view:updateItem(eventType, map)			
		end		
	end
	local onEquipUpdate = function(eventType, map)
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("sell")
		end
		if view then
			view:updateFpTips()				
		end						
	end
	local onEventAuctionSellList = function()
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("sell")
		end
		if view then
			view:setSellList(G_getAuctionMgr():getSellList())			
		end						
	end
	local onEventAuctionBuyRet = function(ret)	
		local view = manager:getViewByName("AuctionView")
		if view then
			view = view:getViewByName("buy")
		end
		if view then
			view:updateList()			
		end	
		if ret then
			UIManager.Instance:showSystemTips(Config.Words[25328])
		end
	end
	local onEventHeroProChanged = function()	
		local view = manager:getViewByName("AuctionView")		
		if view then
			view:showMoney(newPD)				
		end	
	end
		

	local onEventAuctionReSell = function(refId)
		if type(refId) == "string" then
			local item = G_getBagMgr():getItemByRefId(refId)
			if item then
				manager:showUI("AuctionView", E_ShowOption.eRejectOther)
				local view = manager:getViewByName("AuctionView")
				if view then
					view:showSubView(AuctionSubViewType.Sell)
				end
				if view then
					view = view:getViewByName("sell")
				end
				if view then	
					view:clickBagItem(item)			
				end						
			end
		end
	end
	
	local onEventErrorCode = function(msgId, errorCode)
		if msgId == ActionEvents.C2G_Auction_DoSell and errorCode == 0x80000773 then
			local vipLevel = GameWorld.Instance:getVipManager():getVipLevel()
			if vipLevel ~= 3 then	--非黄金VIP需要弹框提示
				showMsgBox(Config.Words[25333])		
			end
		end
	end
	
	local onEventVipLevelChanged = function(vipLevel)
		local view = manager:getViewByName("AuctionView")
		if not view then
			return
		end
		
		view = view:getViewByName("sell")
		if not view then
			return
		end	
		view:setMaxSellCount(G_getAuctionMgr():getMaxSellCountByVipLevel(vipLevel))			
	end
	
	self:Bind(GameEvent.EventAuctionReSell, onEventAuctionReSell)
	self:Bind(GameEvent.EventHeroProChanged, onEventHeroProChanged)
	self:Bind(GameEvent.EventAuctionBuyRet, onEventAuctionBuyRet)
	self:Bind(GameEvent.EventOpenAuctionView, onEventOpenAuctionView)
	self:Bind(GameEvent.EventOpenAuctionMenu, onEventOpenAuctionMenu)
	self:Bind(GameEvent.EventAuctionBuyList, onEventAuctionBuyList)
	self:Bind(GameEvent.EventItemUpdate, onItemUpdate)
	self:Bind(GameEvent.EventEquipUpdate, onEquipUpdate)
	self:Bind(GameEvent.EventAuctionSearchValueChanged,onEventAuctionSearchValueChanged)
	self:Bind(GameEvent.EventAuctionSellList, onEventAuctionSellList)
	self:Bind(GameEvent.EventErrorCode, onEventErrorCode)
	self:Bind(GameEvent.EventVipLevelChanged, onEventVipLevelChanged)

end

function AuctionUIHandler:__delete()
	
end	
