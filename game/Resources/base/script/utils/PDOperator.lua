--  比较属性字典

--返回 table = { "property" ={[1] = value1, [2] = value2}, "property" ={[1] = value1, [2] = value2} .. }
PDOperator = {}

function PDOperator.differentPopertys(pt1, pt2)
	return PDOperator.compare(pt1, pt2, true)
end		

--返回 table = { "property" ={[1] = value1, [2] = value2}, "property" ={[1] = value1, [2] = value2} .. }
function PDOperator.samePropertys(pt1, pt2)
	return PDOperator.compare(pt1, pt2, false)
end

--返回 table = { "property" ={[1] = value1, [2] = value2}, "property" ={[1] = value1, [2] = value2} .. }
function PDOperator.add(pt1, pt2)
	local rets = {}
	for k, v in pairs(pt1) do
		local v2 = pt2[k]
		if (v2 == nil) then
			v2 = -1
		end
		rets[k] = {[1] = v, [2] = v2}
	end
	for kk, vv in pairs(pt2) do
		local vv2 = pt1[kk]
		if (vv2 == nil) then
			vv2 = -1
		end
		rets[k] = {[1] = vv2, [2] = vv}
	end
	return rets
end

--pt1 - pt2
function PDOperator.sub(pt1, pt2)
	if (pt1 ==  nil or pt2 == nil) then
		return pt1
	end
	
	local rets = {}
	for k, v in pairs(pt1) do
		if (pt2[k]) then
			pt1[k] = nil
		end
	end
	return pt1
end

function PDOperator.compare(pt1, pt2, different)
	local rets = {}
	
	if (pt1 == nil) then
		pt1 = {}
	end
	if (pt2 == nil) then
		pt2 = {}
	end
		
	local value2
	for key, value1 in pairs(pt1) do
		value2 = pt2[key]
		if (different == true) then		
			if (value1 ~= value2) then
				rets[key] = {[1] = value1, [2] = value2}
			end
		else
			if (value1 == value2) then
				rets[key] = {[1] = value1, [2] = value2}
			end
		end
	end
	for key, value1 in pairs(pt2) do
		value2 = pt1[key]
		if (different == true) then		
			if (value1 ~= value2) then
				rets[key] = {[2] = value1, [1] = value2}
			end
		else
			if (value1 == value2) then
				rets[key] = {[2] = value1, [1] = value2}
			end
		end
	end
	return rets
end

function PDOperator.generatePDCode(file, pd, pdName, mode)
	if (pd == nil) then
		return
	end
	if (mode == "nil") then
		mode = "a"
	end		
	local file = io.open(file, "a")	
	file:write(pdName.." = {\n")		
	for k, v in pairs(pd) do	
		local str
		if (type(v) ~= "string") then
			str = "    "..k.."="..v..",\n" 
		else
			str = "    "..k.."=".."\""..v.."\""..",\n" 
		end
		file:write(str)
	end
	file:write("}\n")
	file:close()
end
