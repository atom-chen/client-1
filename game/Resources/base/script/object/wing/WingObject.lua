require("common.baseclass")
require("data.wing.wing")

WingObject = WingObject or BaseClass(BaseObj)

function WingObject:__init()
	
end		

function WingObject:__delete()
	
end	

function WingObject:getStaticData(refId)
	if refId ~= nil and string.len(refId) > 1 then
		return GameData.Wing[refId]["property"]
	end
end

function WingObject:getMaterial(refId)
	if refId ~= nil then
		return GameData.Wing[refId]["wingUpgradeData"]
	end
end