--[[
字符串的扩展API
]]

string.isLegal = function(str)
	return (type(str) == "string") and (str ~= "")
end

string.split = function(s, p)
	local rt= {}
	string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
		return 	rt
	end
	
	--[[
	@brief：设置副文本字符串
	
	@param：str 需要设置的字符串
	
	@param：color 字符串的颜色
	@param：size 字符串的大小
	@return: 设置后的字符串
	
	eg：string.wrapRich("我是字符串",Config.FontColor["ColorWhite1"],FSIZE("Size2"))
	--]]
	string.wrapRich = function(str,color,size)
		if str then
			local rcolor = ""
			local rsize = ""
			if color then
				rcolor = "color='#"..color.."'"
			end
			if size then
				rsize = "size='"..size.."'"
			end
			local  rStr =  "<font "..rcolor.." "..rsize..">"..str.."</font>"
			return rStr
		end
	end
	
	--[[
	@brief：设置副文本超链接
	
	@param：str 需要设置的字符串
	
	@param：color 字符串的颜色
	@param：size 字符串的大小
	@param：data 点击后传给回调函数的参数
	@param：line 是否带下划线
	@return: 设置后的字符串
	
	eg：string.wrapHyperLinkRich("我是字符串",Config.FontColor["ColorWhite1"],FSIZE("Size2"), “我是回调参数”, “false”)
	--]]
	string.wrapHyperLinkRich = function (str, color, size, data, line)
		if str then
			local rcolor = ""
			local rsize = ""
			local rdata = ""
			local rline = ""
			if color then
				rcolor = "color='#"..color.."'"
			end
			if size then
				rsize = "size='"..size.."'"
			end
			if data then
				rdata = "data='"..data.."'"
			end
			if line then
				rline = "line='"..line.."'"
			end
			
			local  rStr =  "<font "..rcolor.." "..rsize..">".."<a".." "..rdata.. " " .. rline..">"..str.."</a>".."</font>"
			return rStr
		end
	end
	
	string.wrapHyperImgLinkRich = function (imgfile, width, height, touchData)
		if imgfile then
			local rImg = ""
			local rWidth = ""
			local rheight = ""
			local rTouchData = ""
			
			rImg = "image='" .. imgfile .. "' "
			if width then
				rWidth = "width='"..width .. "' "
			end
			
			if height then
				rheight = "heght='" .. height .. "' "
			end
			--<img image="">dfff</img>
			if touchData then
				rTouchData = "data='"..touchData.."' "
			end
			local rStr = "<img " .. rImg .. rWidth .. rheight.. rTouchData .. "> </img>"
			return rStr
		end
	end