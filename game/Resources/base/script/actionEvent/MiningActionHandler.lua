--挖矿
require ("common.ActionEventHandler")
require ("data.code")
require ("config.words")
MiningActionHandler = MiningActionHandler or BaseClass(ActionEventHandler)

function MiningActionHandler:__init()
	local handle_G2C_Mining_EnterEvent = function(reader)
		self:handle_G2C_Mining_EnterEvent(reader)
	end
	local handleNet_G2C_Mining_ExitEvent = function(reader)
		self:handleNet_G2C_Mining_ExitEvent(reader)
	end
	local handleNet_G2C_Mining_FinishEvent = function(reader)
		self:handleNet_G2C_Mining_FinishEvent(reader)
	end
	local handleG2C_Mining_Open = function(reader)
		self:handleG2C_Mining_Open(reader)
	end
	local handleNet_G2C_Mining_Update = function(reader)
		self:handleNet_G2C_Mining_Update(reader)
	end
	local handleNet_G2C_Mining_ContinuTime = function(reader)
		self:handleNet_G2C_Mining_ContinuTime(reader)
	end
	
	local handleNet_G2C_Mining_RemainRrfreshTime = function(reader)
		self:handleNet_G2C_Mining_RemainRrfreshTime(reader)
	end
	self:Bind(ActionEvents.G2C_Mining_Open,handleG2C_Mining_Open)
	self:Bind(ActionEvents.G2C_Mining_EnterEvent,handle_G2C_Mining_EnterEvent)
	self:Bind(ActionEvents.G2C_Mining_ExitEvent, handleNet_G2C_Mining_ExitEvent)
	self:Bind(ActionEvents.G2C_Mining_FinishEvent,handleNet_G2C_Mining_FinishEvent)
	self:Bind(ActionEvents.G2C_Mining_Update, handleNet_G2C_Mining_Update)	
	self:Bind(ActionEvents.G2C_Mining_ContinuTime, handleNet_G2C_Mining_ContinuTime)
	self:Bind(ActionEvents.G2C_Mining_RemainRrfreshTime, handleNet_G2C_Mining_RemainRrfreshTime)
end

function MiningActionHandler:handle_G2C_Mining_EnterEvent(reader)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	reader = tolua.cast(reader,"iBinaryReader")	
	local isEnter = StreamDataAdapter:ReadChar(reader)
	if isEnter == 0 then
		local leaveTime = StreamDataAdapter:ReadULLong(reader)	
		local curCount = StreamDataAdapter:ReadChar(reader)
		miningMgr:setCurrentCount(curCount)
		local typeCount = StreamDataAdapter:ReadChar(reader)		
		for i = 1,typeCount do
			local pluckType = StreamDataAdapter:ReadChar(reader)
			local collectedCount = StreamDataAdapter:ReadChar(reader)
			miningMgr:setPluckInfo(pluckType,collectedCount)
		end			
		miningMgr:setLeaveTime(leaveTime)
		miningMgr:enterMining()
		-- 新手指引完成
		GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_7")	
	elseif isEnter == 1 then
		local nextTime = StreamDataAdapter:ReadStr(reader)
		local tips = string.format("%s%s",Config.Words[19017],nextTime)
		UIManager.Instance:showSystemTips(tips)
	end
end
--主动退出
function MiningActionHandler:handleNet_G2C_Mining_ExitEvent(reader)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	reader = tolua.cast(reader,"iBinaryReader")	
	miningMgr:exitMining()
end
--时间结束强制退出
function MiningActionHandler:handleNet_G2C_Mining_FinishEvent(reader)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	reader = tolua.cast(reader,"iBinaryReader")
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	
end

function MiningActionHandler:handleNet_G2C_Mining_Update(reader)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	reader = tolua.cast(reader,"iBinaryReader")	
	local count = StreamDataAdapter:ReadChar(reader)
	local typeCount = StreamDataAdapter:ReadChar(reader)	
	for i = 1,typeCount do
		local pluckType = StreamDataAdapter:ReadChar(reader)
		local collectedCount = StreamDataAdapter:ReadChar(reader)	
		miningMgr:setPluckInfo(pluckType,collectedCount)		
	end			
	miningMgr:setCurrentCount(count)
	GlobalEventSystem:Fire(GameEvent.EventRefreshMiningCount)
end

function MiningActionHandler:handleG2C_Mining_Open(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local isOpen = StreamDataAdapter:ReadChar(reader)
	if isOpen == 0 then	--开启
		GameWorld.Instance:getMiningMgr():setMiningOpenState(true)
		activityManageMgr:setActivityState("activity_manage_7",true)	
	elseif isOpen == 1 then	--未开启
		GameWorld.Instance:getMiningMgr():setMiningOpenState(false)
		activityManageMgr:setActivityState("activity_manage_7",false)
	end
end

function MiningActionHandler:handleNet_G2C_Mining_ContinuTime(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local startRemainSec = StreamDataAdapter:ReadLLong(reader)
	local endRemainSec = StreamDataAdapter:ReadLLong(reader)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setRemainSec("activity_manage_7", startRemainSec, endRemainSec)
end

function MiningActionHandler:handleNet_G2C_Mining_RemainRrfreshTime(reader)
	reader = tolua.cast(reader, "iBinaryReader")
	local miningType = StreamDataAdapter:ReadChar(reader)
	local nextTime = StreamDataAdapter:ReadInt(reader)
	local miningMgr = GameWorld.Instance:getMiningMgr()
	miningMgr:setNextMineralTime(nextTime)
	GlobalEventSystem:Fire(GameEvent.EventRefreshNextMineralTime)
end