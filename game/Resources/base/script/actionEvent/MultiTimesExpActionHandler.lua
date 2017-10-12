require("actionEvent.ActionEventDef")
require("common.ActionEventHandler")

MultiTimesExpActionHandler = MultiTimesExpActionHandler or BaseClass(ActionEventHandler)

local teamBossTypeList = {
[1] = "activity_manage_20",
[2] = "activity_manage_21",
[3] = "activity_manage_22",
}


function MultiTimesExpActionHandler:__init()
	local handleG2C_MultiTimesExp_PreStart = function(reader)
		self:handleG2C_MultiTimesExp_PreStart(reader)
	end
--[[	local handleG2C_MultiTimesExp_End = function(reader)
		self:handleG2C_MultiTimesExp_End(reader)
	end--]]
	local handleG2C_MultiTimesExp_RequestTime = function(reader)
		self:handleG2C_MultiTimesExp_RequestTime(reader)
	end
	local handleG2C_MultiTimesExp_State = function(reader)
		self:handleG2C_MultiTimesExp_State(reader)
	end		

	self:Bind(ActionEvents.G2C_MultiTimesExp_PreStart,handleG2C_MultiTimesExp_PreStart)
--	self:Bind(ActionEvents.G2C_MultiTimesExp_End,handleG2C_MultiTimesExp_End)	
	self:Bind(ActionEvents.G2C_MultiTimesExp_RequestTime,handleG2C_MultiTimesExp_RequestTime)	
	self:Bind(ActionEvents.G2C_MultiTimesExp_State,handleG2C_MultiTimesExp_State)
end

function MultiTimesExpActionHandler:handleG2C_MultiTimesExp_PreStart(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local mgr = GameWorld.Instance:getMultiTimesExpMgr()	
	ActivityDelegate:setEnable("activity_manage_23", true)	
	mgr:requestReaminTime()	
end	

function MultiTimesExpActionHandler:handleG2C_MultiTimesExp_End(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local mgr = GameWorld.Instance:getMultiTimesExpMgr()	
	mgr:requestReaminTime()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState("activity_manage_23", false)
	ActivityDelegate:setEnable("activity_manage_23", false)		
end	

function MultiTimesExpActionHandler:handleG2C_MultiTimesExp_RequestTime(reader)
	reader = tolua.cast(reader,"iBinaryReader")
	local timeToStart = StreamDataAdapter:ReadLLong(reader)
	local timeToEnd = StreamDataAdapter:ReadLLong(reader)
	local mgr = GameWorld.Instance:getMultiTimesExpMgr()	
	mgr:setTimeToStart(timeToStart)
	mgr:setTimeToEnd(timeToEnd)
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	activityManageMgr:setRemainSec("activity_manage_23", timeToStart, timeToEnd)
end

function MultiTimesExpActionHandler:handleG2C_MultiTimesExp_State(reader)
	reader = tolua.cast(reader,"iBinaryReader")	
	local state = StreamDataAdapter:ReadChar(reader)
	local mgr = GameWorld.Instance:getMultiTimesExpMgr()	
	mgr:requestReaminTime()
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
	if state == 0 then
		ActivityDelegate:setEnable("activity_manage_23", true)	
		activityManageMgr:setActivityState("activity_manage_23", true)			
	else
		ActivityDelegate:setEnable("activity_manage_23", false)	
		activityManageMgr:setActivityState("activity_manage_23", false)	
	end

end

function MultiTimesExpActionHandler:__delete()

end