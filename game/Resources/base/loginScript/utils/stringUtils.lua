--[[
�ַ�������չAPI
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
	@brief�����ø��ı��ַ���
	
	@param��str ��Ҫ���õ��ַ���
	
	@param��color �ַ�������ɫ
	@param��size �ַ����Ĵ�С
	@return: ���ú���ַ���
	
	eg��string.wrapRich("�����ַ���",Config.FontColor["ColorWhite1"],FSIZE("Size2"))
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
	@brief�����ø��ı�������
	
	@param��str ��Ҫ���õ��ַ���
	
	@param��color �ַ�������ɫ
	@param��size �ַ����Ĵ�С
	@param��data ����󴫸��ص������Ĳ���
	@param��line �Ƿ���»���
	@return: ���ú���ַ���
	
	eg��string.wrapHyperLinkRich("�����ַ���",Config.FontColor["ColorWhite1"],FSIZE("Size2"), �����ǻص�������, ��false��)
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