require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")

LevelAwardActionHandler = LevelAwardActionHandler or BaseClass(ActionEventHandler)

G_LevelAwardState = {
canGet = 1,
}

G_AwardTypeList = {
	gradeAward = 5,
	levelAward = 6,
	limitRank = 7,
}


function LevelAwardActionHandler:__init()	
	local handleNet_G2C_Advanced_List = function(reader)
		self:handleNet_G2C_Advanced_List(reader)
	end
	
	local handleG2C_LevelUpAward_List = function(reader)
		self:handleG2C_LevelUpAward_List(reader)
	end
	local handleNet_G2C_Activity_CanReceive = function(reader)
		self:handleNet_G2C_Activity_CanReceive(reader)
	end		
	
	self:Bind(ActionEvents.G2C_Activity_CanReceive,handleNet_G2C_Activity_CanReceive)		
	self:Bind(ActionEvents.G2C_LevelUpAward_List,handleG2C_LevelUpAward_List)
	self:Bind(ActionEvents.G2C_Advanced_List,handleNet_G2C_Advanced_List)				
end

function LevelAwardActionHandler:handleNet_G2C_Advanced_List(reader) --进阶奖励
	reader = tolua.cast(reader,"iBinaryReader")		
	local rtwMgr = GameWorld.Instance:getLevelAwardManager() 
	
	local rideCount = reader:ReadChar() --short->byte
	rtwMgr:initRideAwardList(rideCount)	
	local rideAwardList = rtwMgr:getRideAwardList()
	for i = 1,rideCount do
		local refId = StreamDataAdapter:ReadStr(reader)
		local state = StreamDataAdapter:ReadChar(reader)
		rideAwardList[refId] = state
	end				
end

function LevelAwardActionHandler:handleG2C_LevelUpAward_List(reader) -- 限时速冲
	reader = tolua.cast(reader,"iBinaryReader")		
	local remainTime = StreamDataAdapter:ReadInt(reader)
	local count = StreamDataAdapter:ReadChar(reader)  --short->byte
	local rtwMgr = GameWorld.Instance:getLevelAwardManager() 
	rtwMgr:setTotalSecond(remainTime)
	rtwMgr:initLevelUpAwardList(count)
	local levelUpAwardList = rtwMgr:getLevelUpAwardList()	
	for i = 1, count do
		local refId = StreamDataAdapter:ReadStr(reader)
		local state = StreamDataAdapter:ReadChar(reader)
		levelUpAwardList[refId] = state	
	end
	GlobalEventSystem:Fire(GameEvent.EventUpdateQuickUpLevelView)
end

function LevelAwardActionHandler:handleNet_G2C_Activity_CanReceive(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local ttype = StreamDataAdapter:ReadChar(reader)			
	local state = StreamDataAdapter:ReadChar(reader)	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	if state == G_LevelAwardState.canGet then
		if ttype == G_AwardTypeList.gradeAward then
			ActivityDelegate:showEffectInUpGradeButton(true)--mark
			activityManageMgr:setActivityState("activity_manage_4",true)		
		elseif ttype == G_AwardTypeList.levelAward then	
			ActivityDelegate:showEffectInLevelupButton(true)	--mark
			activityManageMgr:setActivityState("activity_manage_17",true)		
		elseif ttype == G_AwardTypeList.limitRank then
			ActivityDelegate:showEffectInLimitRankButton(true)--mark
			activityManageMgr:setActivityState("activity_manage_18",true)
		end
	else
--[[		if ttype == 5 then
			activityManageMgr:setActivityState("activity_manage_4",false)		
		elseif ttype == 6 then	
			activityManageMgr:setActivityState("activity_manage_17",false)
		elseif ttype == 7 then
			activityManageMgr:setActivityState("activity_manage_18",false)
		end	--]]
	end
end	
