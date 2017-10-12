require("common.baseclass")
require("common.BaseObj")

TransObject =TransObject or BaseClass(BaseObj)


--[[
	"type": 1,
	"name": "±ÈÆæ",
	"targetScene": "SOO2",
	"tranferInId": 1
--]]
function TransObject:__init()
	self.type = -1
	self.Desname = nil
	self.targetScene = nil
	self.tranferInId = -1
end

function TransObject:setTransName(name)
	self.Desname = name
end

function TransObject:setType(ttype)
	self.type = ttype
end

function TransObject:setTransInId(portId)
	self.tranferInId = portId
end

function TransObject:setTargetScene(sceneId)
	self.targetScene = sceneId
end

function TransObject:getTransName()
	return self.Desname
end

function TransObject:getType()
	return self.type
end

function TransObject:getTransInId()
	return self.tranferInId
end

function TransObject:getTargetScene()
	return self.targetScene
end

function TransObject:__delet()
	
end