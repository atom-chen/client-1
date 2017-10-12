require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require("object.bag.BagDef")
require ("ui.mall.MallView")
require("object.bag.ItemDetailArg")
require("ui.mall.BuyingView")
require("ui.mall.ExchangeCodeView")
--[[
--UI显示的选项
E_ShowOption =
{
eRejectOther = 1, 	--显示在中间，隐藏其他窗口
eMove2Left	 = 3,  	--从中间移动到左侧，不影响其他窗口
eMove2Right	 = 4,  	--从中间移动到右侧，不影响其他窗口
eMiddle	 = 5,		--显示在中间，不影响其他窗口
eLeft	 = 6,  		--显示在左边，不影响其他窗口
eRight	 = 7,  		--显示在右边，不影响其他窗口
}
]]
MallUIHandler = MallUIHandler or BaseClass(GameEventHandler)

function MallUIHandler:__init()
	local manager =UIManager.Instance	
		
		
	local mallMgr = GameWorld.Instance:getMallManager()	
	local requestMallVersion = function()
		mallMgr:requestMallVerSion()
	end

	local handleClient_Open = function (index)
		requestMallVersion()
	
		manager:registerUI("MallView", MallView.create)	
		manager:showUI("MallView",E_ShowOption.eMiddle,index)		
	end			
	
	local requestMallList = function()
		mallMgr:requestMallList()
	end
	local handleItem_Buy = function(Obj,num,ttype)
		local buyNum
		if not num then
			buyNum = 1
		else
			buyNum = num
		end
		if ttype ~= nil then
			mallMgr:setIsQuickBuy(false)
		else
			mallMgr:setIsQuickBuy(true)
		end
		mallMgr:setTempBuyObj(Obj)
		mallMgr:setBuyObj(Obj)
		self.refId = Obj:getItemId()
		if string.match(Obj:getItemId(),"equip_") then
			
			local itemObj = ItemObject.New()
			itemObj:setRefId(Obj:getItemId())			
			itemObj:setStaticData(G_getStaticDataByRefId(Obj:getItemId()))			
			local pt = table.cp(G_getStaticDataByRefId(Obj:getItemId()).effectData)
			pt["fightValue"] = 0	
			itemObj:setPT(pt)		
			local fightValue = G_getEquipFightValue(Obj:getItemId())
			if fightValue then
				itemObj:updatePT({fightValue = fightValue})	
			end										
			PropertyDictionary:set_bindStatus(itemObj:getPT(),-1)	
			local arg1 = ItemDetailArg.New()						
			arg1:setTitleTips(Config.Words[10001])
			arg1:setItem(itemObj)
			arg1:setShowPriceType(E_EquipShowPriceType.buyPrice)
			arg1:setBtnArray({E_ItemDetailBtnType.eBuy, E_ItemDetailBtnType.eDetail})
			local isShopViewShow = UIManager.Instance:isShowing("ShopView")			
			if isShopViewShow == true then	
				GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMove2Right, arg1) --进入详情				
				if (UIManager.Instance:getViewPositon("ShopView") ~= E_ViewPos.eLeft) then			
					UIManager.Instance:moveViewByName("ShopView", E_ViewPos.eLeft)						
				end	
			else 
				GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg1)--进入详情			
			end
		else
			
			manager:registerUI("BuyingView", BuyingView.create)	
			if string.match(Obj:getStoreType(),"mall") or  string.match(Obj:getStoreType(),"discount")	 then			
				manager:showUI("BuyingView",E_ShowOption.eMiddle,buyNum)						
			else			 
				if (UIManager.Instance:getViewPositon("ShopView") ~= E_ViewPos.eLeft) then			
					UIManager.Instance:moveViewByName("ShopView", E_ViewPos.eLeft)						
				end
				manager:showUI("BuyingView",E_ShowOption.eMiddle,buyNum)			
			end
		end	
	end	
	
	local handleBuyItemResult = function(ret)
		local mallMgr = GameWorld.Instance:getMallManager()			
		if(ret == 1) then		
			GlobalEventSystem:Fire(GameEvent.EventBuyItemSucess,self.refId)
			local msg = {}
			table.insert(msg,{word = Config.Words[5013], color = Config.FontColor["ColorYellow1"]})
			manager:showSystemTips(msg)	
		else
--			manager:showSystemTips(Config.Words[5014])
		end
		mallMgr:setBuyObj(nil)	
	end				
	local updateMallView = function()		
		local view = manager:getViewByName("MallView")
		if(view ~= nil) then
			view:UpdateView()
		end
	end		
	
	local eventUpdateCell = function(arg)
		local view = manager:getViewByName("MallView")
		if(view ~= nil) then
			local ttype = arg.ttype
			local realIndex = math.floor((arg.index -1)/2)
			view:UpdateMallCellView(realIndex,ttype)
		end
	end
	
	local updateMedalNum = function()
		local view = manager:getViewByName("MallView")
		if(view ~= nil) then
			view:updateMedalNum()
		end			
	end
	
	local onEventOpenExchangeCodeView = function ()
		manager:registerUI("ExchangeCodeView", ExchangeCodeView.create)	
		manager:showUI("ExchangeCodeView",E_ShowOption.eMiddle)	
	end
	
	local onEventResetEditeBox = function ()
		local view = manager:getViewByName("ExchangeCodeView")
		if view then
			view:resetEditBox()
		end
	end
	
	local updateYBNum = function(pt)
		if pt and pt["unbindedGold"] then
			local view = manager:getViewByName("MallView")
			if(view ~= nil) then
				view:updateYbNum()
			end							
		end
	end
	
	self:Bind(GameEvent.EventHeroProChanged, updateYBNum)	
	self:Bind(GameEvent.EventUpdateCell,eventUpdateCell)
	self:Bind(GameEvent.EventBuyReult,handleBuyItemResult)
	self:Bind(GameEvent.EventBuyItem,handleItem_Buy)
	self:Bind(GameEvent.EventOpenMallView,handleClient_Open)	
	self:Bind(GameEvent.EventHeroEnterGame,requestMallVersion)
	self:Bind(GameEvent.EventUpdateMall,updateMallView)
	self:Bind(GameEvent.EventItemUpdate,updateMedalNum)
	self:Bind(GameEvent.EventOpenExchangeCodeView, onEventOpenExchangeCodeView)
	self:Bind(GameEvent.EventResetEditeBox, onEventResetEditeBox)
end
