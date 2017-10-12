require("common.baseclass")
require("common.BaseObj")

NearbyMonster = NearbyMonster or BaseClass(BaseObj)

function NearbyMonster:__init()
	
end

function NearbyMonster:__delete()
		
end

--monster名字
function NearbyMonster:setMonsterName(name)
	if string.isLegal(name) then
		self.monsterName = name
	end		
end

function NearbyMonster:getMonsterName()
	return self.monsterName
end
--monster refId
function NearbyMonster:setMonsterRefId(refId)
	self.monsterRefId = refId
end

function NearbyMonster:getMonsterRefId()
	return self.monsterRefId
end
--monster等级
function NearbyMonster:setMonsterLevel(level)
	self.monsterLevel = level
end

function NearbyMonster:getMonsterLevel()
	return self.monsterLevel
end
--品质
function NearbyMonster:setMonsterQuanlity(quanlity)
	self.monsterQuanlity = quanlity
end

function NearbyMonster:getMonsterQuanlity()
	return self.monsterQuanlity
end
--总数
function NearbyMonster:setMonsterTotalCount(count)
	self.totalCount = count
end

function NearbyMonster:getMonsterTotalCount()
	return self.totalCount
end
--当前数目
function NearbyMonster:setMonsterCurrentCount(number)
	self.currentCount = number
end

function NearbyMonster:getMonsterCurrentCount()
	return self.currentCount
end

