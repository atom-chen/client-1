require("common.baseclass")
require("object.bag.ItemObject")

EquipObject = EquipObject or BaseClass(ItemObject)

function EquipObject:__init()
	
end		

function EquipObject:setBodyAreaId(bodyId)
	self.bodyId = bodyId
end

function EquipObject:getBodyAreaId()
	return self.bodyId
end