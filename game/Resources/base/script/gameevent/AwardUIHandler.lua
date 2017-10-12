require "gameevent.GameEvent"
require "ui.activity.SevenLoginAwardView"
require "ui.activity.DigTreasureView"
require "ui.activity.DigWareHouse"
require "ui.activity.OpenPayGiftBagView"
require "ui.activity.FirstPayGiftBagView"
require "ui.activity.EveryDayPayGiftBagView"
require "ui.activity.EveryWeekPayAwardView"

AwardUIHandler = AwardUIHandler or BaseClass(GameEventHandler)

function AwardUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance	
	
	local eventOpenSevenLogin = function()	
		manager:registerUI("SevenLoginAwardView", SevenLoginAwardView.create)
		manager:showUI("SevenLoginAwardView",E_ShowOption.eMiddle)
	end
	
	local eventFreshSevenLoginView = function()
		local awardMgr = GameWorld.Instance:getAwardManager()	
		local view = manager:getViewByName("SevenLoginAwardView")
		
		--第一天没领取，默认优先选择第一天，否则默认选择开服的第n天
--		local firstDayState = awardMgr:getStatus(1)

		local whichDay = awardMgr:getWhichDay()
		--[[if firstDayState == awardGetStateType.canDraw then
			whichDay = 1
			awardMgr:setSelectDay(whichDay)
		end--]]

		view:updateOpenServiceSelect(whichDay)
		view:scrollOpenServiceIcon(whichDay)
		
		local awardList = awardMgr:getAwardList(whichDay)
		view:updateOpenServiceAward(awardList)
		
		local openServiceDate = awardMgr:getOpenServiceDate()
		view:updateOpenServiceDate(openServiceDate)
		
		local state = awardMgr:getStatus(whichDay)
		view:updateOpenServiceBtn(state)
		
		local stateList = {}
		for k = 1,7 do
			stateList[k] = awardMgr:getStatus(k)
		end
		view:updateOpenServiceIcon(stateList)	
	end
	
	local eventPopupSevenLogin = function(num)
		local awardMgr = GameWorld.Instance:getAwardManager()			
		if num == 8 then
			ActivityDelegate:doSevenLoginBySever(num,false,false)--mark
		elseif num == 0 then
			ActivityDelegate:doSevenLoginBySever(num,false,true)--mark
		elseif num > 0 and num < 8 then	
			ActivityDelegate:doSevenLoginBySever(num,true,true)--mark						
		end
	end		
	
	local eventChangeSevenLoginIcon = function()	
		local awardMgr = GameWorld.Instance:getAwardManager()
		local num = 0
		for k = 1,7 do
			if awardMgr:getStatus(k) == awardGetStateType.canDraw then
				num = num +1
			end
		end	
		if num == 0 then
			ActivityDelegate:doSevenLoginBySever(num,false,true)--mark
		elseif num > 0 then
			ActivityDelegate:doSevenLoginBySever(num,true,true)--mark
		end					
	end
	
	local eventReceiveAward = function()
		local view = manager:getViewByName("SevenLoginAwardView")
		if view then
			local awardMgr = GameWorld.Instance:getAwardManager()
			local whichDay = awardMgr:getSelectDay()
			awardMgr:setStatus(whichDay,awardGetStateType.hadDraw)
			view:updateOpenServiceBtn(awardGetStateType.hadDraw)
			-- 如果领取的是第一天，则设置领取标志，新手引导需要
			if whichDay == 1 then
				GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_2")	
			end
			local stateList = {}
			for k = 1,7 do
				stateList[k] = awardMgr:getStatus(k)
			end
			view:updateOpenServiceIcon(stateList)
			GlobalEventSystem:Fire(GameEvent.EventChangeSevenLoginIcon)		
		end	
	end
	
	local eventRequestIsPopupSevenLoginView = function()
		local awardMgr = GameWorld.Instance:getAwardManager()
		awardMgr:requestHaveReceive()
	end
	
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenSevenLoginView,eventOpenSevenLogin))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventFreshSevenLoginView,eventFreshSevenLoginView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventPopupSevenLoginView,eventPopupSevenLogin))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventReceiveAward, eventReceiveAward))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventChangeSevenLoginIcon,eventChangeSevenLoginIcon))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame,eventRequestIsPopupSevenLoginView))	
	
	--打开挖宝界面
	local eventDigTreasureViewOpen = function()
		
		manager:registerUI("DigTreasureView", DigTreasureView.create)
		manager:showUI("DigTreasureView",E_ShowOption.eMiddle)
	end
	--打开挖宝仓库	
	local eventWareHouseOpen = function()
		
		manager:registerUI("DigWareHouse", DigWareHouse.create)
		manager:showUI("DigWareHouse",E_ShowOption.eMiddle)
	end
	--仓库物品变化	
	local onItemUpdate = function(eventType, map)
		local view = manager:getViewByName("DigWareHouse")
		if view then
			view:updateItem(eventType, map)
			view:refreshCapacity()				
		end									
	end	
	--清空仓库
	local clearAllHouseItem = function()
		local view = manager:getViewByName("DigWareHouse")
		if view then
			view:clearAllItem()
			view:refreshCapacity()	
		end
	end
	--展示挖宝物品界面	
	local eventShowDigAwardList = function()
		local view = manager:getViewByName("DigTreasureView")
		if view then
			view:showRewardAction()		
		end	
		UIManager.Instance:hideLoadingHUD()	
	end
	--挖宝卡数量变化
	local updateGiftCard = function()
		local view = manager:getViewByName("DigTreasureView")
		if view then
			view:refreshGiftCard()		
		end	
		self:updateDigTreasureActivity()
	end
	local eventOpenPayGiftBag = function ()
		local payActivityMgr = GameWorld.Instance:getPayActivityManager()
		payActivityMgr:requestGiftList()
		
		manager:registerUI("OpenPayGiftBagView", OpenPayGiftBagView.create)
		manager:showUI("OpenPayGiftBagView",E_ShowOption.eMiddle)	
		--manager:setDeleteOnExit("OpenPayGiftBagView", true)	
	end
	
	local eventOpenFirstPayGiftBag = function ()
		
		manager:registerUI("FirstPayGiftBagView", FirstPayGiftBagView.create)
		manager:showUI("FirstPayGiftBagView", E_ShowOption.eMiddle)
		--manager:setDeleteOnExit("FirstPayGiftBagView", true)
		local payActivityMgr = GameWorld.Instance:getPayActivityManager()
		payActivityMgr:requestFirstPayList()
	end
	
	local eventUpdateOpenPayGiftBag = function ()
		local view = manager:getViewByName("OpenPayGiftBagView")
		if view then
			view:updateView()
		end
	end
	
	local eventUpdateFirstPayGiftBag = function ()
		local view = manager:getViewByName("FirstPayGiftBagView")
		if view then
			view:updateView()
		end
	end
	
	local eventOpenEveryDayPayBag = function ()
		local payActivityMgr = GameWorld.Instance:getPayActivityManager()
		payActivityMgr:requestEveryDayPayGiftBagList()
		
		manager:registerUI("EveryDayPayGiftBagView", EveryDayPayGiftBagView.create)
		manager:showUI("EveryDayPayGiftBagView",E_ShowOption.eMiddle)
		--manager:setDeleteOnExit("EveryDayPayGiftBagView", true)
	end
	
	local eventUpdateEveryDayPayBag = function ()
		local view = manager:getViewByName("EveryDayPayGiftBagView")
		if view then
			view:updateView()
		end
	end
	--礼包领取成功后的操作
	--[[local eventReceiveSucceed = function ()
		local view = manager:getViewByName("OpenPayGiftBagView")
		if view then
			view:resetStatus()
		end
	end--]]
	--打开每周消费奖励
	local eventOpenEveryWeekPayGiftBag = function ()
		local everyWeekConsumeMgr = GameWorld.Instance:getEveryWeekConsumeManager()
		everyWeekConsumeMgr:requestWeekConsumeGiftList()
		
		manager:registerUI("EveryWeekPayAwardView", EveryWeekPayAwardView.create)
		manager:showUI("EveryWeekPayAwardView", E_ShowOption.eMiddle)
		--manager:setDeleteOnExit("EveryWeekPayAwardView", true)
	end
	local eventUpdateEveryWeekPayGiftBag = function ()
		local view = manager:getViewByName("EveryWeekPayAwardView")
		if view then
			view:updateView()
		end
	end
	
	--英雄属性变化
	local onHeroProChanged = function(newPD,oldPD)
		local newUnbindedGold = PropertyDictionary:get_unbindedGold(newPD)
		if  newUnbindedGold ~= nil then
			local view = manager:getViewByName("DigTreasureView")
			if view then
				view:refreshUnbindedGold()		
			end				
		end
	end			
	
	local showEffectInFirstPayButton = function (show)
		ActivityDelegate:showEffectInFirstPayButton(show)
	end
	
	local showEffectInPayAwardButton = function (show)
		ActivityDelegate:showEffectInPayAwardButton(show)
	end
	
	local showEffectInEveryDayPayAwardButton = function (show)
		ActivityDelegate:showEffectInEveryDayPayAwardButton(show)--mark
	end
	
	local showEffectInEveryWeekConsumeAwardButton = function (show)
		ActivityDelegate:showEffectInEveryWeekConsumeAwardButton(show)--mark
	end
	
	self:Bind(GameEvent.EventUpdateEveryWeekPayGiftBag, eventUpdateEveryWeekPayGiftBag)
	self:Bind(GameEvent.EventUpdateEveryDayPayBag, eventUpdateEveryDayPayBag)			
	self:Bind(GameEvent.EventDigTreasureViewOpen,eventDigTreasureViewOpen)		
	self:Bind(GameEvent.EventShowDigWareHouse,eventWareHouseOpen)
	self:Bind(GameEvent.EventHouseUpdate,onItemUpdate,eventType,map)
	self:Bind(GameEvent.EventOpenPayGiftBag, eventOpenPayGiftBag)
	self:Bind(GameEvent.EventUpdateOpenPayGiftBag, eventUpdateOpenPayGiftBag)
	self:Bind(GameEvent.EventOpenFirstPayGiftBag, eventOpenFirstPayGiftBag)
	self:Bind(GameEvent.EventUpdateFirstPayGiftBag, eventUpdateFirstPayGiftBag)
	self:Bind(GameEvent.EventOpenEveryDayPayBag, eventOpenEveryDayPayBag)
	self:Bind(GameEvent.EventOpenEveryWeekPayGiftBag, eventOpenEveryWeekPayGiftBag)
	self:Bind(GameEvent.EventShowDigAwardList, eventShowDigAwardList)
	self:Bind(GameEvent.EventHeroProChanged, onHeroProChanged)	
	self:Bind(GameEvent.EventShowEffectInFirstPayButton, showEffectInFirstPayButton)
	self:Bind(GameEvent.EventShowEffectInPayButton, showEffectInPayAwardButton)
	self:Bind(GameEvent.EventShowEffectInEveryDayPayButton, showEffectInEveryDayPayAwardButton)
	self:Bind(GameEvent.EventShowEffectInEveryWeekConsumeButton, showEffectInEveryWeekConsumeAwardButton)
	self:Bind(GameEvent.EventGiftCardUpdate,updateGiftCard)
	self:Bind(GameEvent.EventItemList,updateGiftCard)
	self:Bind(GameEvent.EventClearAllHouseItem,clearAllHouseItem)
end

function AwardUIHandler:updateDigTreasureActivity()
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	activityMgr:setActivityState("activity_manage_15", G_getBagMgr():hasItem("item_giftcard"))
end

function AwardUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end
