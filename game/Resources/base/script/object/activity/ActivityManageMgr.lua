require("object.activity.ActivityDelegate")
require("data.activity.activityManage")

ActivityManageMgr = ActivityManageMgr or BaseClass()

--�����(�����ݱ����Ͷ�Ӧ)
ActivityType = 
{
	Daily = 0, 		--�ճ�����
	OpenServer = 1, --�����
	BuyGuide = 2,	--�Ƽ�����
	Feedback = 3,	--��Ϸ����
	Other = 10086,	--����
}

SignAwardState = {
	unableGet = 0,
	hadGet = 1,
	canGet = 2,
}


local const_updateInterval = 1
function ActivityManageMgr:__init()
	self.typeActivityMap  = {}	--������-obj������
	self.refIdActivityMap = {}	--��refId-obj������
	
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
	self.typeActivityMap  = {}	--������-obj������
	self.refIdActivityMap = {}	--��refId-obj������
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

--����һ����Ƿ񼤻�(һ������Ļ����ʾ��Ч, ���Ҹ����������Ƿ����͵����������)
function ActivityManageMgr:setActivityState(refId, bActivated)
	local obj = self.refIdActivityMap[refId]
	if obj then
		obj:setActivated(bActivated)		
	end
end	

-- ��ȡһ����ļ���״̬
function ActivityManageMgr:getActitityState(refId)
	if self.refIdActivityMap[refId] then
		return self.refIdActivityMap[refId]:isActivated()
	else
		return false
	end
end

--����һ����Ƿ�ʹ�ܣ�һ����ʹ�ܵĻ�������ڻ�����ʾ��
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
���û�ص�
���ݸ��ص������Ĳ����б�Ϊ��refId, activityType, event, info
refId: �����¼��Ļ��refId
activityType�������¼��Ļ������
event:�����ľ����¼����ֱ�Ϊenable, active, open, time
	enable: ʹ��״̬�����仯
	activite������״̬�����仯
	open����״̬������		
	time������ʱ�����仯
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
--����Ϊ˽�з���
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