--  使用物品
require("common.baseclass")
require("object.bag.BagDef")

ItemUsingMgr = ItemUsingMgr or BaseClass()

function ItemUsingMgr:__init()
end	

--[[
使用物品：对于装备为穿戴 ，对于普通物品则为使用
	itemObj: 需要使用的物品
	count  : 使用数量
--]]
function ItemUsingMgr:useItem(itemObj, count)
end

--[[
返回两个参数：
	ret : false/true
	des	: 不能使用的原因
--]]
function ItemUsingMgr:checkCanUse(itemObj)
	
end

--[[
返回两个参数：
	ret : false/true
	des	: 不能出售的原因
--]]
function ItemUsingMgr:checkCanSell(itemObj)
	
end	