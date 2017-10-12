require("common.baseclass")
require("common.BaseObj")

EveryPayObj = EveryPayObj or BaseClass(BaseObj)

function EveryPayObj:__init()
	self.itemList = {}
end

function EveryPayObj:__delete()
	self.itemList = {}
end

--首充活动状态
function EveryPayObj:setEveryPayStatus(status)
	self.status = status
end

function EveryPayObj:getEveryPayStatus()
	return self.status
end

--首充送物品的价值
function EveryPayObj:setEveryPayWorth(worth)
	self.worth = worth
end

function EveryPayObj:getEveryPayWorth()
	return self.worth
end

--首充物品列表
function EveryPayObj:setEveryPayItemList(itemList)
	self.itemList = itemList
end

function EveryPayObj:getEveryPayItemList()
	return self.itemList
end