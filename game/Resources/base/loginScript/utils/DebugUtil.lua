isDebugMode = false

--[[
debug print
]]
function debugPrint(text)
	if isDebugMode then
		print(text)
	end
end