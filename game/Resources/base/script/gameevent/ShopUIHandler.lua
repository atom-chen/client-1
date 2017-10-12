require "gameevent.GameEvent"
require "ui.shop.ShopView"
ShopUIHandler = ShopUIHandler or BaseClass(GameEventHandler)

function ShopUIHandler:__init()
	local manager =UIManager.Instance
	
	self.isInitList = false
	local mallMgr = GameWorld.Instance:getMallManager()	
	local eventOpenShop = function (shopId)
		--�����̵�ID  ������ʾ����
		if(self.isInitList == false) then
			mallMgr:initShopList()
			self.isInitList = true
		end
				
		--�����Ӧ�̵��������
		mallMgr:requestMallLimitList(shopId)

		
		manager:registerUI("ShopView",ShopView.create)	
		manager:showUI("ShopView",E_ShowOption.eLeft,shopId)				
	end		
	
	local eventUpdateShop = function(shopId)
		local view = manager:getViewByName("ShopView")
		if(view ~= nil) then
			view:UpdateShopView()
		end
	end		
	local eventInitStaticList = function()	
		mallMgr:initShopList()
	end		
	
	local eventUpdateShopCell = function ()
		local view = manager:getViewByName("ShopView")
		if(view ~= nil) then
			view:UpdateShopCellView()
		end
	end
	
	self:Bind(GameEvent.EventUpdateShopCell, eventUpdateShopCell)
	self:Bind(GameEvent.EventOpenShop, eventOpenShop)
	self:Bind(GameEvent.EventUpdateShop,eventUpdateShop)
end

function ShopUIHandler:__delete()
	
end	