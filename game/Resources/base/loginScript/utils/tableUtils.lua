--[[
计算一个table元素的个数。跟table.getn()或者#方法不同，getn()在遇到间隙时就返回。例如：
local a = {}
a[1] = 100
a[5] = 200
print(table.getn(a)) -> 1
print(#a) -> 1
print(table.size(a)) -> 2
--]]
table.size = function(ttable)
	local size = 0
	if (ttable == nil or type(ttable) ~= "table") then
		return 0
	end
	for k, v in pairs(ttable) do
		size = size + 1
	end
	return size
end

table.isEqual = function(t1, t2)
	if table.size(t1) == table.size(t2) then
		for k, v in pairs(t1) do
			if t2[k] ~= v then
				return false
			end
		end
	end
	return true
end

table.has = function(t, value)
	for k, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

table.isEmpty = function(ttable)
	if type(ttable) ~= "table" then
		return true
	end
	for k, v in pairs(ttable) do
		return false
	end
	return true
end

table.merge = function(from, to)
	for k, v in pairs(from) do
		to[k] = v
	end
end

table.cp = function(src)
	local ret = {}
	for k, v in pairs(src) do
		ret[k] = v
	end
	return ret
end	