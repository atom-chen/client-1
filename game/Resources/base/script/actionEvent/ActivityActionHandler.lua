require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("object.activity.EveryPayObj")
require ("object.activity.FirstPayObj")

ActivityActionHandler = ActivityActionHandler or BaseClass(ActionEventHandler)

function ActivityActionHandler:__init()
	
	local handleNet_OT_ShowOnLineTimer = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:handleNet_OT_ShowOnLineTimer(reader)
	end
	
	local handleNet_Activity_GetAward = function(reader)
		self:handleNet_Activity_GetAward(reader)
	end		
	
	local handleNet_OA_TotalRechargeGiftListEvent = function (reader)	
		self:handleNet_OA_TotalRechargeGiftListEvent(reader)
	end
	
	local handleNet_OA_FirstRechargeGiftListEvent = function (reader)	
		self:handleNet_OA_FirstRechargeGiftListEvent(reader)
	end				
		
	--self:Bind(ActionEvents.G2C_OT_ShowDailyOnLineTimer,handleNet_OT_ShowDailyOnLineTimer)
	--self:Bind(ActionEvents.G2C_OT_ResetDailyOnLineTimer,handleNet_OT_ResetDailyOnLineTimer)	
	local handleNet_OA_EveryRechargeGiftListEvent = function (reader)
		self:handleNet_OA_EveryRechargeGiftListEvent(reader)
	end
	
	local handleNet_OA_WeekConsumeGiftListEvent = function (reader)
		self:handleNet_OA_WeekConsumeGiftListEvent(reader)
	end
	
	local handleNet_Discount_GetShopList = function (reader)
		self:handleNet_Discount_GetShopList(reader)
	end		
	
	local handleNet_OA_CanReceiveEvent = function (reader)
		self:handleNet_OA_CanReceiveEvent(reader)
	end
	
	local handle_isDiscountActivityStart = function (reader)
		self:handle_isDiscountActivityStart(reader)
	end
	
	local handleNet_UnionGameInstance_Apply = function (reader)
		self:handleNet_UnionGameInstance_Apply(reader)
	end
	
	local handleNet_UnionGameInstance_Enter = function (reader)
		self:handleNet_UnionGameInstance_Enter(reader)
	end
	
	local handleNet_UnionGameInstance_Update = function (reader)
		self:handleNet_UnionGameInstance_Update(reader)
	end
	
	self:Bind(ActionEvents.G2C_OT_ShowOnLineTimer,handleNet_OT_ShowOnLineTimer)			
	self:Bind(ActionEvents.G2C_OA_TotalRechargeGiftListEvent, handleNet_OA_TotalRechargeGiftListEvent)
	self:Bind(ActionEvents.G2C_OA_FirstRechargeGiftList, handleNet_OA_FirstRechargeGiftListEvent)
	self:Bind(ActionEvents.G2C_OA_EveryRechargeGiftListEvent, handleNet_OA_EveryRechargeGiftListEvent)	
	self:Bind(ActionEvents.G2C_Discount_GetShopList, handleNet_Discount_GetShopList)	
	self:Bind(ActionEvents.G2C_OA_WeekConsumeGiftListEvent, handleNet_OA_WeekConsumeGiftListEvent)
	self:Bind(ActionEvents.G2C_OA_CanReceiveEvent, handleNet_OA_CanReceiveEvent)
	self:Bind(ActionEvents.G2C_Discount_BeginOrEndNotify, handle_isDiscountActivityStart)
	self:Bind(ActionEvents.G2C_UnionGameInstance_Apply, handleNet_UnionGameInstance_Apply)
	self:Bind(ActionEvents.G2C_UnionGameInstance_Enter, handleNet_UnionGameInstance_Enter)
	self:Bind(ActionEvents.G2C_UnionGameInstance_Finish, handleNet_UnionGameInstance_Update)
end

function ActivityActionHandler:handle_isDiscountActivityStart(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local isStart = StreamDataAdapter:ReadChar(reader)-- 0 未开启或结束，1，开启
	
	local discountSellMgr = GameWorld.Instance:getDiscountSellMgr()	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	discountSellMgr:setStartFlag(isStart)
	if discountSellMgr:isStart() then 
		activityManageMgr:setActivityState("activity_manage_9", true)
	else
		activityManageMgr:setActivityState("activity_manage_9", false)
	end
end

function ActivityActionHandler:handleNet_OT_ShowOnLineTimer(reader)
	local refId = StreamDataAdapter:ReadStr(reader)
	local time = StreamDataAdapter:ReadInt(reader)--具体时间以秒为单位
	local state = StreamDataAdapter:ReadChar(reader)--登录时0：不可领取，1：可领取	
	
	local activityOnlineTimeMgr = GameWorld.Instance:getActivityOnlineTimeMgr()
	local lastRefId = activityOnlineTimeMgr:getOnlineTimeRefId()
	if lastRefId then
		activityOnlineTimeMgr:showReward()
	end
	activityOnlineTimeMgr:setOnlineTimeRefId(refId)
	activityOnlineTimeMgr:setOnlineTimeSeverTime(time)
	activityOnlineTimeMgr:setOnlineTimeRewardState(state)
	
	local frist = activityOnlineTimeMgr:getTheFrist()
	if frist==false then
		GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_3")	
	end
	activityOnlineTimeMgr:setTheFrist(false)
	ActivityDelegate:doOnlineTimeBySever() --mark	
end	

function ActivityActionHandler:handleNet_Activity_GetAward(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local refId = StreamDataAdapter:ReadStr(reader)
	local signMgr = GameWorld.Instance:getSignManager()
	local awardList = signMgr:getAwardList()
	awardList[refId] = SignAwardState.hadGet
	GlobalEventSystem:Fire(GameEvent.EventSignViewAwardUpdate)	
end	

function ActivityActionHandler:handleNet_OA_TotalRechargeGiftListEvent(reader)
	local payActivityMgr = GameWorld.Instance:getPayActivityManager()
	reader = tolua.cast(reader, "iBinaryReader")	
	
	local leaveTime = StreamDataAdapter:ReadULLong(reader)
	local beginTime = StreamDataAdapter:ReadULLong(reader)
	local endTime = StreamDataAdapter:ReadULLong(reader)
	local currentValue = StreamDataAdapter:ReadInt(reader)
			
	payActivityMgr:setLeaveTime(leaveTime)
	payActivityMgr:setBeginTime(beginTime)
	payActivityMgr:setEndTime(endTime)
	payActivityMgr:setCurrentValue(currentValue)

	local count = StreamDataAdapter:ReadChar(reader)	--short->char
	local tableItemList = {}
	local stage, status, itemCount
	local itemRefId, number, bind
	local itemList = {}
	local itemTable, tableItem, item
	for key1 = 1, count do
		tableItem = {}
		stage = StreamDataAdapter:ReadStr(reader)
		condValue = StreamDataAdapter:ReadInt(reader)
		status = StreamDataAdapter:ReadChar(reader)
		
		itemCount = StreamDataAdapter:ReadChar(reader) --short->char
		itemList = {}		
		for key2 = 1, itemCount do
			item = {}
			itemRefId = StreamDataAdapter:ReadStr(reader)
			number = StreamDataAdapter:ReadInt(reader)
			bind = StreamDataAdapter:ReadChar(reader)
			
			item["refId"] = itemRefId
			item["number"] = number
			item["bind"] = bind
			
			itemList[itemRefId] = item
		end
		
		tableItem["stage"] = stage
		tableItem["condValue"] = condValue
		tableItem["status"] = status
		tableItem["itemList"] = itemList		
		tableItemList[stage] = tableItem		
	end
	payActivityMgr:setAwardTableList(tableItemList)
	GlobalEventSystem:Fire(GameEvent.EventUpdateOpenPayGiftBag)
end

function ActivityActionHandler:handleNet_OA_FirstRechargeGiftListEvent(reader)
	local payActivityMgr = GameWorld.Instance:getPayActivityManager()
	reader = tolua.cast(reader, "iBinaryReader")
	local status = StreamDataAdapter:ReadChar(reader)
	--已领取的处理
	--[[if status == 2 then
		GlobalEventSystem:Fire(GameEvent.EventHaveReceiveFirstPayGiftBag)
		return
	end--]]
	
	local worth = StreamDataAdapter:ReadInt(reader)	
	local itemSize = StreamDataAdapter:ReadShort(reader)
		
		

	local firstPayObj = FirstPayObj.New()
	firstPayObj:setFirstPayStatus(status)
	firstPayObj:setFirstPayWorth(worth)
	local itemList = {}
	local payAwardItem
	local itemRefId, number, bind
	for key=1, itemSize do
		payAwardItem = {}
		itemRefId = StreamDataAdapter:ReadStr(reader)
		number = StreamDataAdapter:ReadInt(reader)
		bind = StreamDataAdapter:ReadChar(reader)
		
		payAwardItem["refId"] = itemRefId
		payAwardItem["number"] = number
		payAwardItem["bind"] = bind
		
		itemList[itemRefId] = payAwardItem
	end		
	firstPayObj:setFirstPayItemList(itemList)	
	payActivityMgr:setFirstPayObj(firstPayObj)
	GlobalEventSystem:Fire(GameEvent.EventUpdateFirstPayGiftBag)
end

function ActivityActionHandler:handleNet_OA_EveryRechargeGiftListEvent(reader)
	
	
	
	local payActivityMgr = GameWorld.Instance:getPayActivityManager()
	reader = tolua.cast(reader, "iBinaryReader")
	local status = StreamDataAdapter:ReadChar(reader)
	local worth = StreamDataAdapter:ReadInt(reader)	
	local itemSize = StreamDataAdapter:ReadChar(reader)--short->byte
	local itemList = {}
	local payAwardItem
	local itemRefId, number, bind
	for key=1, itemSize do
		payAwardItem = {}
		itemRefId = StreamDataAdapter:ReadStr(reader)
		number = StreamDataAdapter:ReadInt(reader)
		bind = StreamDataAdapter:ReadChar(reader)
		
		payAwardItem["refId"] = itemRefId
		payAwardItem["number"] = number
		payAwardItem["bind"] = bind
		
		itemList[itemRefId] = payAwardItem
	end
	local everyPayObj = EveryPayObj.New()
	everyPayObj:setEveryPayStatus(status)
	everyPayObj:setEveryPayWorth(worth)
	everyPayObj:setEveryPayItemList(itemList)
	payActivityMgr:setEveryPayObj(everyPayObj)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateEveryDayPayBag)
end

function ActivityActionHandler:handleNet_OA_WeekConsumeGiftListEvent(reader)
	
	
	
	reader = tolua.cast(reader, "iBinaryReader")
	local everyWeekConsumeMgr = GameWorld.Instance:getEveryWeekConsumeManager()
	
	local leaveTime = StreamDataAdapter:ReadULLong(reader)
	local beginTime = StreamDataAdapter:ReadULLong(reader)
	local endTime = StreamDataAdapter:ReadULLong(reader)
	local weekStartEndTime = StreamDataAdapter:ReadStr(reader)
	local currentWeekValue = StreamDataAdapter:ReadInt(reader)
	local giftCount = StreamDataAdapter:ReadChar(reader)  --short->byte
	
	local giftList = {}
	local itemList = {}
	local gift, item
	local stage, condValue, status, itemCount
	local itemRefId, number, bind
	for key1=1, giftCount do
		stage = StreamDataAdapter:ReadStr(reader)		
		condValue = StreamDataAdapter:ReadInt(reader)
		worth = StreamDataAdapter:ReadInt(reader)
		status = StreamDataAdapter:ReadChar(reader)		
		itemCount = StreamDataAdapter:ReadChar(reader)  --short->byte
		itemList = {}
		for key2=1, itemCount do
			itemRefId = StreamDataAdapter:ReadStr(reader)
			number = StreamDataAdapter:ReadInt(reader)
			bind = StreamDataAdapter:ReadChar(reader)
					
			item = {}
			item["refId"] = itemRefId
			item["number"] = number
			item["bind"] = bind
			itemList[itemRefId] = item
		end
				
		gift = {}
		gift["stage"] = stage
		gift["condValue"] = condValue
		gift["worth"] = worth
		gift["status"] = status
		gift["itemList"] = itemList	
		giftList[stage] = gift
	end
	
	everyWeekConsumeMgr:setLeaveTime(leaveTime)
	everyWeekConsumeMgr:setBeginTime(beginTime)
	everyWeekConsumeMgr:setEndTime(endTime)
	everyWeekConsumeMgr:setWeekStartEndTime(weekStartEndTime)
	everyWeekConsumeMgr:setCurrentWeekValue(currentWeekValue)
	everyWeekConsumeMgr:setWeekConsumeGiftList(giftList)
	
	GlobalEventSystem:Fire(GameEvent.EventUpdateEveryWeekPayGiftBag)
end

function ActivityActionHandler:handleNet_Discount_GetShopList(reader)
	local discountSellMgr = GameWorld.Instance:getDiscountSellMgr()
	reader = tolua.cast(reader, "iBinaryReader")
	local leftTime = StreamDataAdapter:ReadULLong(reader)
	local count = StreamDataAdapter:ReadShort(reader)
	
	local discountSellList = {}
	for i=1,count do
		local refId = StreamDataAdapter:ReadStr(reader)
		local leftNumber = StreamDataAdapter:ReadShort(reader)
		local personLeftNumber = StreamDataAdapter:ReadShort(reader)
		
		local dataList = {refId=refId,leftNumber=leftNumber,personLeftNumber=personLeftNumber}
		table.insert(discountSellList,i,dataList)
	end	
	
	discountSellMgr:setSeverLeftTime(leftTime)
	discountSellMgr:setDiscountSellList(discountSellList)
	discountSellMgr:updateView()
end

function ActivityActionHandler:handleNet_OA_CanReceiveEvent(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local payActivityMgr = GameWorld.Instance:getPayActivityManager()
	local canReceiveList = {}
	local count = StreamDataAdapter:ReadShort(reader)
	local whichActivity = nil
	for key=1, count do
		whichActivity = StreamDataAdapter:ReadShort(reader)
		canReceiveList[whichActivity] = whichActivity
		whichActivity = nil
	end
	payActivityMgr:setCanReceiveList(canReceiveList)
		
	GlobalEventSystem:Fire(GameEvent.EventShowEffectInFirstPayButton, payActivityMgr:canReceiveFirstPayAward())				
	GlobalEventSystem:Fire(GameEvent.EventShowEffectInPayButton, payActivityMgr:canReceivePayAward())
	GlobalEventSystem:Fire(GameEvent.EventShowEffectInEveryDayPayButton, payActivityMgr:canReceiveEveryDayPayAward())		
	GlobalEventSystem:Fire(GameEvent.EventShowEffectInEveryWeekConsumeButton, payActivityMgr:canReceiveEveryWeekConsumeAward())			
	
end

function ActivityActionHandler:handleNet_UnionGameInstance_Apply(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local isSuccess = StreamDataAdapter:ReadChar(reader)
	if isSuccess == 1 then
		UIManager.Instance:showSystemTips(Config.Words[25402])
	else
		UIManager.Instance:showSystemTips(Config.Words[25403])
	end
end

function ActivityActionHandler:handleNet_UnionGameInstance_Enter(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local unionMgr = GameWorld.Instance:getUnionInstanceMgr()
	local isSuccess = StreamDataAdapter:ReadChar(reader)
	local isFinish = StreamDataAdapter:ReadChar(reader)
	
	if isSuccess == 1 then
		UIManager.Instance:showSystemTips(Config.Words[25404])
		GlobalEventSystem:Fire(GameEvent.EventEnterUnionInstance)
	else
		UIManager.Instance:showSystemTips(Config.Words[25405])
	end
	
	if isFinish == 1 then
		unionMgr:setIsFinish(true)
	else
		unionMgr:setIsFinish(false)
	end	
	GlobalEventSystem:Fire(GameEvent.EventUpdateUnionInstanceView)		
end

function ActivityActionHandler:handleNet_UnionGameInstance_Update(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local unionMgr = GameWorld.Instance:getUnionInstanceMgr()
	local isFinish = StreamDataAdapter:ReadChar(reader)
	
	if isFinish == 1 then
		unionMgr:setIsFinish(true)
	else
		unionMgr:setIsFinish(false)
	end	
	GlobalEventSystem:Fire(GameEvent.EventUpdateUnionInstanceView)	
end
