require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

VipActionHandler = VipActionHandler or BaseClass(ActionEventHandler)


function VipActionHandler:__init()	
	self.hadRequest = false
	
	local handleNet_G2C_Vip_State = function(reader)
		self:handleNet_G2C_Vip_State(reader)
	end
	local handleNet_G2C_Vip_AwardList = function(reader)
		self:handleNet_G2C_Vip_AwardList(reader)
	end
	
	local handle_G2C_Vip_GetAward = function(reader)
		self:handle_G2C_Vip_GetAward(reader)
	end
	local handleNet_G2C_Vip_OpenLottery = function(reader)
		self:handleNet_G2C_Vip_OpenLottery(reader)
	end
	local handleNet_G2C_Vip_Lottery = function(reader)
		self:handleNet_G2C_Vip_Lottery(reader)
	end
	local handleNet_G2C_Vip_LotteryMsg = function(reader)
		self:handleNet_G2C_Vip_LotteryMsg(reader)
	end
	self:Bind(ActionEvents.G2C_Vip_GetAward,handle_G2C_Vip_GetAward)
	self:Bind(ActionEvents.G2C_Vip_State, handleNet_G2C_Vip_State)
	self:Bind(ActionEvents.G2C_Vip_AwardList,handleNet_G2C_Vip_AwardList)	
	self:Bind(ActionEvents.G2C_Vip_OpenLottery,handleNet_G2C_Vip_OpenLottery)	
	self:Bind(ActionEvents.G2C_Vip_Lottery,handleNet_G2C_Vip_Lottery)	
	self:Bind(ActionEvents.G2C_Vip_LotteryMsg,handleNet_G2C_Vip_LotteryMsg)				
end

function VipActionHandler:handleNet_G2C_Vip_State(reader)
	reader = tolua.cast(reader,"iBinaryReader")		
	local vipLevel = StreamDataAdapter:ReadChar(reader)	--0  非   1 青铜   2白银  3 黄金
	local RestDay  = StreamDataAdapter:ReadInt(reader)
	
	local vipMgr = GameWorld.Instance:getVipManager()   
	if vipLevel ~= vipMgr:getVipLevel() then
		--TODO
		--如果当前vip	等级与返回vip等级不一致    则需要更新主界面vip标识
		local obj = GameWorld.Instance:getEntityManager():getHero()
		PropertyDictionary:set_vipType(obj:getPT(),vipLevel)	
		obj:updateTitleName(obj:getPT())
		--如果是非vip成为vip  则需要更新日常任务列表
		if   vipMgr:getVipLevel() == 0 and self.hadRequest == true then
			G_getQuestMgr():requestQuestList()--发送任务列表请求
		end
		self.hadRequest = true
	end	
		
	vipMgr:setVipLevel(vipLevel)	
	vipMgr:setVipDayRest(RestDay)
	GlobalEventSystem:Fire(GameEvent.EventVipLevelChanged,vipLevel)	
	local loginGame = false
--[[	if loginGame then
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
		if activityManageMgr then
			activityManageMgr:clickVipLuck()
		end
	else
		
	end--]]
end		

function VipActionHandler:handleNet_G2C_Vip_AwardList(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local expState = StreamDataAdapter:ReadChar(reader)
	local dayState = StreamDataAdapter:ReadChar(reader)
	local levelState = StreamDataAdapter:ReadChar(reader)
	local vipMgr = GameWorld.Instance:getVipManager() 
	
	if expState == 0  then
		vipMgr:setExpAwardState( false )
	else		
		vipMgr:setExpAwardState( true )				
	end
	if dayState == 0  then
		vipMgr:setDayGiftAwardState( false )		
	else
		vipMgr:setDayGiftAwardState( true )
	end		
	if levelState == 0  then
		vipMgr:setLevelAwardState( false )		
	else
		vipMgr:setLevelAwardState( true )
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateVipAwardView,0)
	
	if expState ~= 0 or dayState ~= 0 then
		GlobalEventSystem:Fire(GameEvent.EventShowVipEffect, true)
	else
		GlobalEventSystem:Fire(GameEvent.EventShowVipEffect, false)
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateActivityTipsView)
end

function VipActionHandler:handle_G2C_Vip_GetAward(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local ret = StreamDataAdapter:ReadChar(reader)
	--if ret == 1 then
		local vipMgr = GameWorld.Instance:getVipManager() 
		vipMgr:setStateFalse()		
		GlobalEventSystem:Fire(GameEvent.EventUpdateVipAwardView,0)
	--end
	
	local vipLevel = vipMgr:getVipLevel()
	if ret == 1 then	
		UIManager.Instance:showSystemTips(Config.Words[13032])
	end
	
	if ret == 2 then
		if vipLevel == Vip_Level.VIP_TONG  then
			UIManager.Instance:showSystemTips(Config.Words[13030])
			--GlobalEventSystem:Fire(GameEvent.EventUpdateActivityTipsView)
		elseif vipLevel == Vip_Level.VIP_JIN then
			UIManager.Instance:showSystemTips(Config.Words[13034])
			--GlobalEventSystem:Fire(GameEvent.EventUpdateActivityTipsView)
		end		
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateActivityTipsView)
end

function VipActionHandler:handleNet_G2C_Vip_OpenLottery(reader)
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()   
	reader = tolua.cast(reader,"iBinaryReader")	
	local vipType = StreamDataAdapter:ReadChar(reader)	
	vipLuckMgr:setIdentityId(vipType)
	local tomCount = StreamDataAdapter:ReadShort(reader)	--int->short
	local todayCount = StreamDataAdapter:ReadShort(reader) 	--int->short
	vipLuckMgr:setCurrentCount(todayCount)
	vipLuckMgr:setNextCount(tomCount)	
	vipLuckMgr:cleanItemList()
	for i= 1,8 do
		local index = StreamDataAdapter:ReadChar(reader)	
		local itemRefId = StreamDataAdapter:ReadStr(reader)			
		vipLuckMgr:setItemListByPosition(index,itemRefId)
	end
	UIManager.Instance:hideLoadingHUD()	
	GlobalEventSystem:Fire(GameEvent.EventVipLuckRefresh)		
	local activityMgr = GameWorld.Instance:getActivityManageMgr()
	activityMgr:setActivityState("activity_manage_16", todayCount > 0)
end

function VipActionHandler:handleNet_G2C_Vip_Lottery(reader)
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  
	reader = tolua.cast(reader,"iBinaryReader")	
	local index = StreamDataAdapter:ReadChar(reader)
	vipLuckMgr:setLuckIndex(index)
	GlobalEventSystem:Fire(GameEvent.EventShowVipReward,index)		
end

function VipActionHandler:handleNet_G2C_Vip_LotteryMsg(reader)
	local vipLuckMgr = GameWorld.Instance:getVipLuckManager()  		
	reader = tolua.cast(reader,"iBinaryReader")	
	local msg = StreamDataAdapter:ReadStr(reader)
	vipLuckMgr:setMarqueeMsg(msg)	
	GlobalEventSystem:Fire(GameEvent.EventShowVipMarquee)
end

