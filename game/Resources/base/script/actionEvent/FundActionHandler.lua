require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

FundActionHandler = FundActionHandler or BaseClass(ActionEventHandler)

function FundActionHandler:__init()	
	self.verSionList = {}
	local handleNet_G2C_Fund_ReturnVersion = function(reader)
		self:handleNet_G2C_Fund_ReturnVersion(reader)		
	end
	
	local handleNet_G2C_Fund_FundGetRewardList = function(reader)
		self:handleNet_G2C_Fund_FundGetRewardList(reader)			
	end
	
	local handleNet_G2C_Fund_BuyWhichFund = function(reader)
		self:handleNet_G2C_Fund_BuyWhichFund(reader)		
	end
	
	local handleNet_G2C_Fund_GetReward = function(reader)
		self:handleNet_G2C_Fund_GetReward(reader)		
	end

	local handNet_G2C_Fund_IsReceive = function(reader)
		self:handNet_G2C_Fund_IsReceive(reader)
	end

	self:Bind(ActionEvents.G2C_Fund_IsReceive,handNet_G2C_Fund_IsReceive)
	self:Bind(ActionEvents.G2C_Fund_ReturnVersion,handleNet_G2C_Fund_ReturnVersion)
	self:Bind(ActionEvents.G2C_Fund_FundGetRewardList,handleNet_G2C_Fund_FundGetRewardList)		
	self:Bind(ActionEvents.G2C_Fund_BuyWhichFund,handleNet_G2C_Fund_BuyWhichFund)
	self:Bind(ActionEvents.G2C_Fund_GetReward,handleNet_G2C_Fund_GetReward)			
end

--[[
G2C_Fund_ReturnVersion = Activity_Message_Begin + 76	//返回基金类型版本号
	fundType             byte//基金类型
	version              int //版本号
]]
function FundActionHandler:handleNet_G2C_Fund_ReturnVersion(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local fundType = StreamDataAdapter:ReadChar(reader)
	local verSion = StreamDataAdapter:ReadInt(reader)
	self.verSionList[fundType] = verSion
	local fundMgr = GameWorld.Instance:getFundManager()
	local pVersion = fundMgr:getFundVersion(fundType)
	if verSion >= 0 then
		if pVersion ~= verSion then
			fundMgr:requestFundList(fundType)
		end
		GlobalEventSystem:Fire(GameEvent.EventFundShowBuyBt,false)						
	else
		GlobalEventSystem:Fire(GameEvent.EventFundShowBuyBt,true)	
	end
end
--[[
G2C_Fund_FundGetRewardList = Activity_Message_Begin + 78	//返回基金领奖列表
	fundType             byte//基金类型
	count{                int // 当前第几天 
		status			byte  //领取状态 1表示已领取 0表示未领取 2过期	
	}
]]
function FundActionHandler:handleNet_G2C_Fund_FundGetRewardList(reader)
	reader = tolua.cast(reader,"iBinaryReader")				
	local fundType = StreamDataAdapter:ReadChar(reader)
	
	local fundMgr = GameWorld.Instance:getFundManager()
	fundMgr:initFundList(fundType)	
	local fundStateList = fundMgr:getFundStateList(fundType)
	local count = StreamDataAdapter:ReadInt(reader)	
	fundMgr:setCurrentDay(fundType,count)
	for day = 1,count do
		local state = StreamDataAdapter:ReadChar(reader)
		fundStateList[day] = state
	end
	fundMgr:setFundVersion(fundType,self.verSionList[fundType])
	--更新列表
	GlobalEventSystem:Fire(GameEvent.EventUpdateFundView,fundType)
	fundMgr:requestFundState()	
end
--[[
G2C_Fund_BuyWhichFund = Activity_Message_Begin + 80	//购买结果
	fundType             byte//基金类型
	result       byte//成功失败 0失败 1成功 
]]
function FundActionHandler:handleNet_G2C_Fund_BuyWhichFund(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local fundType = StreamDataAdapter:ReadChar(reader)
	local result = StreamDataAdapter:ReadChar(reader)
	
	local fundMgr = GameWorld.Instance:getFundManager()
	if result == 1 then
		fundMgr:requestFundVersion(fundType)
		local msg = {}
		table.insert(msg,{word = Config.Words[20008], color = Config.FontColor["ColorYellow1"]})
		UIManager.Instance:showSystemTips(msg)	
	else
		
	end		
end
--[[

G2C_Fund_GetReward = Activity_Message_Begin + 82	//领取结果
	fundType             byte//基金类型
	result       		byte//成功失败 0失败 1成功 
]]
function FundActionHandler:handleNet_G2C_Fund_GetReward(reader)
	reader = tolua.cast(reader,"iBinaryReader")		
	local fundType = StreamDataAdapter:ReadChar(reader)
	local result = StreamDataAdapter:ReadChar(reader)
	
	local fundMgr = GameWorld.Instance:getFundManager()
	if result == 1 then
		GlobalEventSystem:Fire(GameEvent.EventUpdateFundCell,fundType)	
		--更新cell
		fundMgr:requestFundState()
	else
		
	end		
end

function FundActionHandler:handNet_G2C_Fund_IsReceive(reader)
	reader = tolua.cast(reader,"iBinaryReader")		
	local count = StreamDataAdapter:ReadInt(reader)
	local canGetList = {}
	for i = 1, count do 
		local ttype = StreamDataAdapter:ReadChar(reader)
		local state = StreamDataAdapter:ReadChar(reader)
		if state == 0 then
			canGetList[ttype] = state
		end		
	end
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	if table.size(canGetList) > 0 then		
		activityManageMgr:setActivityState("activity_manage_12",true)
		ActivityDelegate:showEffectInFundButton(true)
	else
		activityManageMgr:setActivityState("activity_manage_12",false)
		ActivityDelegate:showEffectInFundButton(false)
	end
end	
