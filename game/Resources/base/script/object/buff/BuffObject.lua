require ("common.BaseObj")
require ("data.d_buff.d_buff")

BuffObject = BuffObject or BaseClass(BaseObj)

function BuffObject:__init()

end

function BuffObject:getStaticData()	
	local buffRefId = PropertyDictionary:get_buffRefId(self:getPT())	
	return GameData.D_buff[buffRefId]["property"]
end

function BuffObject:getEffectData()
	local buffRefId = PropertyDictionary:get_buffRefId(self:getPT())
	return GameData.D_buff[buffRefId]["effectData"]
end
