require("common.baseclass")
require("common.BaseObj")

FirstPayObj = FirstPayObj or BaseClass(BaseObj)

function FirstPayObj:__init()
	self.itemList = {}
end

function FirstPayObj:__delete()
	self.itemList = {}
end

--�׳�״̬
function FirstPayObj:setFirstPayStatus(status)
	self.status = status
end

function FirstPayObj:getFirstPayStatus()
	return self.status
end

--�׳�����Ʒ�ļ�ֵ
function FirstPayObj:setFirstPayWorth(worth)
	self.worth = worth
end

function FirstPayObj:getFirstPayWorth()
	return self.worth
end

--�׳���Ʒ�б�
function FirstPayObj:setFirstPayItemList(itemList)
	self.itemList = itemList
end

function FirstPayObj:getFirstPayItemList()
	return self.itemList
end