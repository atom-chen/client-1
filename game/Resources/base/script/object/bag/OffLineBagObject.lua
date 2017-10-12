require("common.baseclass")
require("common.BaseObj")

OffLineBagObject = OffLineBagObject or BaseClass(BaseObj)

function OffLineBagObject:__init()
	self.items = {--[[[1]={itemRefId = "item_jinengExp", itemNum = 10, },[2]={itemRefId = "item_jinengExp", itemNum = 20, }--]]}	--[1]={itemRefId = nil, itemNum = nil, }
	self.logs = {--[[[1]={logType = 2, log = {aiGameSceneRefId = "S1000", playerId = nil, playerName = "sxsx", dorpItem = {[1] = {itemRefId = "haha", itemNum = 10, }}}}--]]}	--[1]={logType = nil, log = {aiGameSceneRefId = nil, playerId = nil, playerName = nil, dorpItem = {[1] = {itemRefId = nil, itemNum = nil, }}}}
	self.exp = 0
	self.money = 0
	
	self.itemList = {}
end

function OffLineBagObject:getLogData(index)
	return self.logs[index]
end

function OffLineBagObject:getItemList()
	for i =1,table.getn(self.items) do
		local itemObj = ItemObject.New()
		itemObj:setId(tostring(i))
		itemObj:setRefId(self.items[i].itemRefId)
		itemObj:setGridId(i)
		local pt = {}
		pt.number = self.items[i].itemNum
		itemObj:setPT(pt)
		itemObj:setStaticData(G_getStaticDataByRefId(self.items[i].itemRefId))
		table.insert(self.itemList, itemObj)
	end
	self.items = {}
	return self.itemList
end

function OffLineBagObject:clearItemList()
	for k,v in pairs(self.itemList) do
		v:DeleteMe()
		self.itemList[k] = nil
	end
	self.itemList = {}
end

function OffLineBagObject:clearGoldAndExp()
	self.exp = 0
	self.money = 0
end

function OffLineBagObject:getExp()
	if self.exp then
		return tostring(self.exp)
	else
		return ""
	end
end

function OffLineBagObject:getMoney()
	if self.money then
		return tostring(self.money)
	else
		return ""
	end
end