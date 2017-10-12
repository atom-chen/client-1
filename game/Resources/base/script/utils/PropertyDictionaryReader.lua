--[[
从BinaryReader中读取属性字典数据， 转换成table
]]--
require ("data.symbol")

function getPropertyTable(binaryReader)
	local property = {}
	
	-- 属性的数量
	local number = binaryReader:ReadShort()
	
	for i=1,number do
		-- symbol id		
		local symbolId = binaryReader:ReadShort()
		require "data.symbol"		
		local symbolRow = GameData.Symbol[symbolId]
		if symbolRow~=nil then
			local key = symbolRow["key"]
			if  symbolRow["type"] == "int32" then
				property[key] = binaryReader:ReadInt()
			elseif symbolRow["type"] == "string" then				
				property[key] = StreamDataAdapter:ReadStr(binaryReader)
			elseif symbolRow["type"] == "float32" then
				property[key] = binaryReader:ReadFloat()
			elseif symbolRow["type"] == "int16" then
				property[key] = binaryReader:ReadShort()
			elseif symbolRow["type"] == "int8" then
				property[key] = binaryReader:ReadChar()
			elseif symbolRow["type"] == "int64" then
				property[key] = binaryReader:ReadULLong()
			else
				local a = 10
			end
		else
			error("File=PropertyDictionaryReader Func=getPropertyTable fatal error! symbolRow == nil please check symbol.lua. symbolId="..symbolId)
		end
	end
	return property
end

function MF_getPropertyTable(binaryReader)
	local property = {}
	
	-- 属性的数量
	local number = binaryReader:ReadShort()
	
	for i=1,number do
		-- symbol id
		local symbolId = binaryReader:ReadShort()
		require "data.symbol"		
		local symbolRow = GameData.Symbol[symbolId]
		if symbolRow~=nil then
			local key = symbolRow["key"]
			if  symbolRow["type"] == 1 then
				property[key] = binaryReader:ReadInt()
			elseif symbolRow["type"] == 2 then				
				property[key] = StreamDataAdapter:ReadStr(binaryReader)
			elseif symbolRow["type"] == 3 then
				property[key] = binaryReader:ReadFloat()
			elseif symbolRow["type"] == 4 then
				property[key] = binaryReader:ReadShort()
			elseif symbolRow["type"] == 5 then
				property[key] = binaryReader:ReadChar()
			elseif symbolRow["type"] == 6 then
				property[key] = binaryReader:ReadULLong()
			elseif symbolRow["type"] == 7 then
				property[key] = binaryReader:ReadDouble()
			elseif symbolRow["type"] == 8 then
				--property[key] = binaryReader:ReadInt()
			elseif symbolRow["type"] == 9 then
				--property[key] = binaryReader:ReadInt()
			elseif symbolRow["type"] == 10 then
				--property[key] = binaryReader:ReadInt()
			elseif symbolRow["type"] == 11 then
				--property[key] = binaryReader:ReadInt()
			end
		end
	end
	return property
end	