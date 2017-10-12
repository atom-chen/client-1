require("common.baseclass")
require("common.BaseObj")

ActivityObj = ActivityObj or BaseClass(BaseObj)

function ActivityObj:__init()
	self.data = nil
	self.startRemainSec = 0		--��ʼ����ʱ
	self.endRemainSec = 0		--��������ʱ
	self.bIsEnable = true
	self.showTime = true
end

function ActivityObj:__delete()
end	

function ActivityObj:getType()
	local data = self:getData()
	if data then
		return PropertyDictionary:get_kind(data.property)
	else
		return ActivityType.Other
	end
end	

function ActivityObj:setRefId(refId)
	self.refId = refId		
	if self.refId then
		self.data = GameData.ActivityManage[self.refId]		
	end
end

function ActivityObj:getRefId()
	return self.refId
end

--���û��ʼʣ��ʱ��/����ʣ��ʱ��
function ActivityObj:setRemainSec(startRemainSec, endRemainSec)
	if type(startRemainSec) == "number" then
		self.startRemainSec = startRemainSec
	end
	if type(endRemainSec) == "number" then
		self.endRemainSec = endRemainSec
	end
end

function ActivityObj:getStartRemainSec()
	return self.startRemainSec
end

function ActivityObj:getEndRemainSec()
	return self.endRemainSec	
end

--�뿪ʱ��ʣ�¶�����
function ActivityObj:getRemainSec()
	return math.ceil(self.startRemainSec), math.ceil(self.endRemainSec)
end	

function ActivityObj:getData()
	return self.data
end

--�û�Ƿ�ʹ��
function ActivityObj:isEnable()
	return self.bIsEnable
end	

function ActivityObj:setEnable(bEnable)
	if self.bIsEnable ~= bEnable then
		self.bIsEnable = bEnable		
		self:doNotify("enable", bEnable)
	end
end	

--�Ƿ�Ϊ���ͻ
function ActivityObj:needPush()
	local data = self:getData()
	if data then
		return (data.property.isPush == 1)
	else
		return false
	end
end

function ActivityObj:canPush()
	return self:isEnable() and self:isActivated() and self:needPush()
end

--�Ƿ���Ҫ��ʾtips
function ActivityObj:needTips()
	local data = self:getData()
	if data then
		return (data.property.needTips == 1)
	else
		return false
	end
end

function ActivityObj:getSortId()
	if self:getData() then
		return PropertyDictionary:get_activitySortId(self:getData().property)
	else
		return 0
	end
end


function ActivityObj:getRemainTimeStr(bIsStartRemainTime)
	local restSec
	if bIsStartRemainTime then
		restSec = self.startRemainSec
	else
		restSec = self.endRemainSec
	end
	if (type(restSec) ~= "number") or restSec < 0  then
		restSec = 0
	end
	if restSec < 0 then 
		return " "
	end
	if type(restSec) ~= "number" then
		return " "
	end
	
	local day = math.floor(restSec/86400--[[(24*3600)--]])	
	local hour = math.floor(restSec/3600)%24
	local minute = math.floor(restSec/60)%60
	local sec = restSec%60	
	local str = " "
	if day > 0 then
		str = day..Config.Words[13007]
	else
		if hour > 0 then
			str = string.format("%d%s", hour, Config.Words[13640])
		elseif minute > 0 then
			str = string.format("%02d%s%02d", minute, ":", sec)
		else
			str = string.format("%02d%s", sec, Config.Words[13642])
		end
	end	
	return str
end

function ActivityObj:update(elapse)
	local option = 0
	if self.startRemainSec > 0 then
		option = option + 1
		self.startRemainSec = self.startRemainSec - elapse
	end
	if self.endRemainSec > 0 then
		option = option + 2
		self.endRemainSec = self.endRemainSec - elapse				
	end
	if option > 0 then
		self:doNotify("time", option)	
	end
end

function ActivityObj:doNotify(event, info)
	if self.notifyFunc then
		self.notifyFunc(self:getRefId(), self:getType(), event, info)
	end
end

function ActivityObj:setShowTime(bshow)
	self.showTime = bshow
end

--��ȡ����ʱѡ��
--����
--ret: 1��ʾ��Ҫ��ʾ��ʼ����ʱ��2��ʾ��Ҫ��ʾ��������ʱ;����Ϊ����Ҫ��ʾ����ʱ
function ActivityObj:getCountDownOption()
	if (not self.data) then
		return -1
	end
	
	if self.showTime == false then
		return -1
	end
	
	local time = os.time()
	if self.startRemainSec > 0 then
		local startCountDown = self.data.property.startCountDown
		if startCountDown == -1 then	--����Ҫ��ʾ��ʼ����ʱ
			return -1
		elseif startCountDown == 0 then
			return 1
		else
			if self.startRemainSec <= startCountDown then
				return 1
			else
				return -1
			end
		end
	elseif self.endRemainSec > 0 then
		local endCountDown = self.data.property.endCountDown
		if endCountDown == -1 then	--����Ҫ��ʾ��������ʱ
			return -1
		elseif endCountDown == 0 then
			return 2
		else
			if self.endRemainSec <= endCountDown then
				return 2
			else
				return -1
			end
		end
	end		
end

--�Ƿ񼤻�
function ActivityObj:isActivated()
	return self.bIsActivated
end

--�����Ƿ񼤻�
function ActivityObj:setActivated(bIsActivated)
	if self.bIsActivated ~= bIsActivated then
		self.bIsActivated = bIsActivated		
		self:doNotify("active", bIsActivated)
	end
end

--�����¼�֪ͨ�ص�
--�ص���������Ϊevent����ʾ��������������
--time: ����ʱ�����仯
--active: ����״̬�����仯
--running: �Ƿ��ڻʱ��״̬�����仯
function ActivityObj:setNotify(notify)
	self.notifyFunc = notify
end	