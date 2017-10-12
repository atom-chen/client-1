require("common.baseclass")
require("common.BaseObj")

EveryPayObj = EveryPayObj or BaseClass(BaseObj)

function EveryPayObj:__init()
	self.itemList = {}
end

function EveryPayObj:__delete()
	self.itemList = {}
end

--�׳�״̬
function EveryPayObj:setEveryPayStatus(status)
	self.status = status
end

function EveryPayObj:getEveryPayStatus()
	return self.status
end

--�׳�����Ʒ�ļ�ֵ
function EveryPayObj:setEveryPayWorth(worth)
	self.worth = worth
end

function EveryPayObj:getEveryPayWorth()
	return self.worth
end

--�׳���Ʒ�б�
function EveryPayObj:setEveryPayItemList(itemList)
	self.itemList = itemList
end

function EveryPayObj:getEveryPayItemList()
	return self.itemList
end