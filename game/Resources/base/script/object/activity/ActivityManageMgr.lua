require("object.activity.ActivityDelegate")
require("data.activity.activityManage")

ActivityManageMgr = ActivityManageMgr or BaseClass()

--活动类型(与数据表类型对应)
ActivityType = 
{
	Daily = 0, 		--日常任务
	OpenServer = 1, --开服活动
	BuyGuide = 2,	--推荐购买
	Feedback = 3,	--游戏回馈
	Other = 10086,	--其他
}

SignAwardState = {
	unableGet = 0,
	hadGet = 1,
	canGet = 2,
}


local const_updateInterval = 1
function ActivityManageMgr:__init()
	self.typeActivityMap  = {}	--以类型-obj来保存活动
	self.refIdActivityMap = {}	--以refId-obj来保存活动
	
	self.notifyCount = 0
	self.notifyList = {}
end	

function ActivityManageMgr:__delete()
	self:clear()	
	self:stop()
	self.notifyCount = 0
	self.notifyList = {}
end	

function ActivityManageMgr:clear()
	self.typeActivityMap  = {}	--以类型-obj来保存活动
	self.refIdActivityMap = {}	--以refId-obj来保存活动
	self:start()
end

function ActivityManageMgr:start()
	self:stop()
	self:initActivity()		
	local onTimeout = function(elapse)	
		for k, v in pairs(self.refIdActivityMap) do			
			v:update(elapse)				
		end
	end
	self.schId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, const_updateInterval, false);			
end
	
function ActivityManageMgr:stop()
	if self.schId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schId)
	end
	self.schId = nil
end

function ActivityManageMgr:getActivityListByType(activityType)
	return self.typeActivityMap[activityType]
end

function ActivityManageMgr:getActivityByRefId(refId)
	return self.refIdActivityMap[refId]
end

function ActivityManageMgr:getTypeActivityMap()
	return self.typeActivityMap
end

function ActivityManageMgr:getRefIdActivityMap()
	return self.refIdActivityMap
end

--设置一个活动是否激活(一个激活的活动会显示特效, 并且根据配表决定是否推送到主界面活动面板)
function ActivityManageMgr:setActivityState(refId, bActivated)
	local obj = self.refIdActivityMap[refId]
	if obj then
		obj:setActivated(bActivated)		
	end
end	

-- 获取一个活动的激活状态
function ActivityManageMgr:getActitityState(refId)
	if self.refIdActivityMap[refId] then
		return self.refIdActivityMap[refId]:isActivated()
	else
		return false
	end
end

--设置一个活动是否使能（一个不使能的活动将不会在活动面板显示）
function ActivityManageMgr:setActivityEnable(refId, bEnable)
	local obj = self.refIdActivityMap[refId]
	if obj then
		obj:setEnable(bEnable)		
	end
end	



function ActivityManageMgr:setRemainSec(refId, startRemainSec, endRemainSec)
	local obj = self.refIdActivityMap[refId]	
	if obj then
		obj:setRemainSec(startRemainSec, endRemainSec)
	end
end

function ActivityManageMgr:setShowTime(refId,bshow)
	local obj = self.refIdActivityMap[refId]	
	if obj then
		obj:setShowTime(bshow)
	end
end

--[[
设置活动回调
传递给回调函数的参数列表为：refId, activityType, event, info
refId: 发生事件的活动的refId
activityType：发生事件的活动的类型
event:发生的具体事件，分别为enable, active, open, time
	enable: 使能状态发生变化
	activite：激活状态发生变化
	open：打开状态发生变		
	time：倒计时发生变化
--]]	
function ActivityManageMgr:addActivityNotify(notify)
	self.notifyCount = self.notifyCount + 1
	self.notifyList[self.notifyCount] = notify
	return self.notifyCount
end

function ActivityManageMgr:removeActivityNotify(id)
	self.notifyList[id] = nil	
end

	
---------------------------------------------------------------------
--以下为私有方法
---------------------------------------------------------------------

function ActivityManageMgr:initActivity()
	local time = os.time()
	for k, v in pairs(GameData.ActivityManage) do	
		if v.property and v.property.isEnable then
			local obj = ActivityObj.New()			
			obj:setRefId(k)
--			obj:setActivated(true)	--test
--			obj:setRemainSec(100, 115) --test
			self.refIdActivityMap[k] = obj	
			self:insertActivity(obj, obj:getType())			
			
			local onNotify = function(refId, activityType, event, info)	
				self:doNotify(refId, activityType, event, info)
			end
			obj:setNotify(onNotify)
		end
	end
end

function ActivityManageMgr:insertActivity(obj, activityType)
	local list = self.typeActivityMap[activityType]		
	if type(list) ~= "table" then
		list = {}
		self.typeActivityMap[activityType] = list
	end
	local sortId = PropertyDictionary:get_activitySortId(obj:getData().property)
	for k, v in ipairs(list) do	
		if sortId < PropertyDictionary:get_activitySortId(v:getData().property) then		
			table.insert(list, k, obj)
			return
		end
	end
	table.insert(list, obj)
end		

function ActivityManageMgr:doNotify(refId, activityType, event, info)
	for k, v in pairs(self.notifyList) do
		v(refId, activityType, event, info)
	end
end

function ActivityManageMgr:getFigthValueByRefId(refId)
	if refId then
		local activityData = GameData.ActivityManage[refId]
		if activityData then
			return activityData.property.recPower
		end
	end
end