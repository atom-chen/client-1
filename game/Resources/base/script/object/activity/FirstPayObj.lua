require("common.baseclass")
require("common.BaseObj")

FirstPayObj = FirstPayObj or BaseClass(BaseObj)

function FirstPayObj:__init()
	self.itemList = {}
end

function FirstPayObj:__delete()
	self.itemList = {}
end

--首充活动状态
function FirstPayObj:setFirstPayStatus(status)
	self.status = status
end

function FirstPayObj:getFirstPayStatus()
	return self.status
end

--首充送物品的价值
function FirstPayObj:setFirstPayWorth(worth)
	self.worth = worth
end

function FirstPayObj:getFirstPayWorth()
	return self.worth
end

--首充物品列表
function FirstPayObj:setFirstPayItemList(itemList)
	self.itemList = itemList
end

function FirstPayObj:getFirstPayItemList()
	return self.itemList
end