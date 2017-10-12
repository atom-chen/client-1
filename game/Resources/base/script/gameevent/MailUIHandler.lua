require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.mail.MailView")
MailUIHandler = MailUIHandler or BaseClass(GameEventHandler)

function MailUIHandler:__init()
	local manager =UIManager.Instance	
				
	local handleClient_Open = function ()				
		manager:registerUI("MailView", MailView.create)
		manager:showUI("MailView")									
	end
	
	local handleClient_mailRequest = function ()		
		-- 请求邮件	
		local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()	
		mailMgr:requestMailList()							
	end
		
	local handleClient_Close = function ()
		
	end	
	
	local updateAllMailView = function ()		
		local ContentView = manager:getViewByName("MailContentView")
		if ContentView then
			ContentView:updateContentView()
			self.mailObj = ContentView:getMailObj()
		end	
		local mailType = self.mailObj:getMailType()
		local TableView =  manager:getViewByName("MailView")		
		if TableView then		
			if mailType then
				if mailType == Activity then
					TableView:updateTableView(UIMailType.ActivityMailType)
				elseif mailType == Notice then
					TableView:updateTableView(UIMailType.NoticeMailType)
				elseif mailType == GM2Client or mailType == Client2GM then 
					TableView:updateTableView(UIMailType.GMMailType)
				else
					TableView:updateTableView(UIMailType.AllMailType)				
				end	
			end					
		end
		
		local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()		
		local mailUnreadNum = mailMgr:getMailUnreadNum()
		GlobalEventSystem:Fire(GameEvent.EventMailBtnIsShow,mailUnreadNum)
		
		--再次出售
		if ContentView:isClickReSell() and (mailType == MailType.AuctionCancel or mailType == MailType.AuctionTimeout) then					
			ContentView:clearClickReSell()
			local itemList = self.mailObj:getItemList()
			local item = itemList[1]
			if item then
				GlobalEventSystem:Fire(GameEvent.EventAuctionReSell, item:getRefId())
			end
		else
			manager:showUI("MailView", nil, 1)		
		end
	end	
	
	local UpdateMailList = function (mailType)	
			
		local TableView =  manager:getViewByName("MailView")		
		if TableView then
			if mailType == 0 then
				TableView:updateTableView(2)
			elseif mailType == 1 then
				TableView:updateTableView(3)
			elseif mailType == 2 then 
				TableView:updateTableView(4)			
			else
				
			end						
		end	
		local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()		
		local mailUnreadNum = mailMgr:getMailUnreadNum()
		GlobalEventSystem:Fire(GameEvent.EventMailBtnIsShow,mailUnreadNum)					
	end	
	
	local mailBtnShow = function (mailUnreadNum)		
		local View =  manager:getMainView()
		if View then
			View:setMainOtherBtnVisible(MainOtherType.Mail, mailUnreadNum > 0)
		end				
	end	
	
	local ReturnMailView = function (arg)		
		manager:registerUI("MailView", MailView.create)
		manager:showUI("MailView",nil,arg)
	end	
	
	local openMailContentView = function ()
		local view = manager:getViewByName("MailView")
		if view then
			view:openContentView()
		end
	end
					
	self:Bind(GameEvent.EventOpenMailView,handleClient_Open)
	self:Bind(GameEvent.EventHeroEnterGame,handleClient_mailRequest)	
	self:Bind(GameEvent.EventMailPickupSuccess,updateAllMailView)
	self:Bind(GameEvent.EventAddMial, UpdateMailList)
	self:Bind(GameEvent.EventMailBtnIsShow, mailBtnShow)
	self:Bind(GameEvent.EventReturnMailView, ReturnMailView)
	self:Bind(GameEvent.EventMailRead, UpdateMailList)	
	self:Bind(GameEvent.EventOpenMailContentView, openMailContentView)			
end

function MailUIHandler:__delete()

end