-- 配置管理（s）

ConfigMgr = ConfigMgr or BaseClass()
	
function ConfigMgr:__init()
	ConfigMgr.Instance = self
	RES = self.checkPlist
	FSIZE = self.getFontSizeByName
	FCOLOR = self.getFontColorByName
	ART_TEXT = self.getArtisticTextPathByName	
	ICON = self.getIconPathByRefId
	ATLIMG_NAME = self.getAtlasNumberPathByName	
	ATLIMG_SIZE = self.getAtlasNumberSize
	MODEL = self.getModelPathByRefId
	UI_IMG = self.getUI_imgPathByName
end


-- 检查图片对应的plist文件是否加载，如果没有加载，则进行加载
-- 返回: 将image返回
function ConfigMgr.checkPlist(image)	
	if (type(image) ~= "string") then
		error("error. RES(res): res must be string")
	end
	local image, plist = ConfigMgr.doCheckPlist(image)
	return image
end	

function ConfigMgr.doCheckPlist(image)	
	if (type(image) ~= "string") then
		error("error. RES(res): res must be string")
	end
	local plist = Config.UIImage[image]		--找出该图片对应的plist文件路径
	if (plist ~= nil) then						--找到该图片，进行加载	
		function loadPlist(plist)				-- 加载plist文件
			local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
			frameCache:addSpriteFramesWithFile(plist)
		end
		loadPlist(plist)
		--Config.UIImage[image] = nil		--将该item从Config.UIImage里删除，节约内存以及提高下次访问该函数的效率		
	end
	return image, plist	
end	

local iconPathHead = "icon/"
local imageEnd = ".pvr"
function ConfigMgr.getIconPathByRefId(refId)
	if (refId == nil) then
		return nil
	end
	if (string.len(refId) >= string.len(iconPathHead)) then
		local start = string.sub(refId, 1, string.len(iconPathHead))
		if (start == iconPathHead) then --已经增加了icon/前缀，则直接返回
			return refId
		end
	end
	if string.match(refId, imageEnd) ~= nil then 
		return string.format("%s%s", iconPathHead, refId)
	else
		return string.format("%s%s%s", iconPathHead, refId, imageEnd)
	end
--[[	local path
	if (string.match(refId, imageEnd) == nil) then
		path = string.format("%s%s%s", iconPathHead, refId, imageEnd)
	else
		path = string.format("%s%s", iconPathHead, refId)
	end
	return path--]]
	
end

-- 根据字体大小名字返回字体大小，名字对应于Config.FontSize
function ConfigMgr.getFontSizeByName(name)
	local size = Config.FontSize[name]
	if (size == nil) then
		error("error. getFontSizeByName(name): did not find the size")
	end
	return size
end

function ConfigMgr.getFontColorByName(name)
	local rgb = Config.FontColor[name]
	if ((rgb == nil) or (string.len(rgb) ~= 6)) then
		error("error. getFontColorByName(name): did not find the rgb or string.len(rgb) ~= 6)")
	end
	
	local rr = string.sub(rgb, 1, 2)
	local gg = string.sub(rgb, 3, 4)
	local bb = string.sub(rgb, 5, 6)
	
	rr = tonumber(rr, 16)
	gg = tonumber(gg, 16)  
	bb = tonumber(bb, 16)
	return ccc3(rr, gg, bb)
end	

--返回美术字的路径
function ConfigMgr.getArtisticTextPathByName(name)
	local path = Config.ArtisticText[name]
	if (path == nil) then
		error("error. getTextStylePathByName(name): did not find the path")
	end
	return path
end		

--获取美术数字的名字路径
function ConfigMgr.getAtlasNumberPathByName(config)
	if config and config.name then
		return config.name
	else
		error("error. getTextStylePathByName(name): did not find the path")
		return ""
	end
end	

--获取美术数字的大小
function ConfigMgr.getAtlasNumberSize(config)
	if config and config.size then
		return config.size
	else
		return {width=14, height=14}
	end
end	

--获取模型的路径
local modelPathHead = ""
local imageEnd = ".png"
function ConfigMgr.getModelPathByRefId(refId)
	if (refId == nil) then
		return nil
	end
	local name
	if string.match(refId, imageEnd) ~= nil then 
		name = string.format("%s%s", modelPathHead, refId)
	else
		name = string.format("%s%s%s", modelPathHead, refId, imageEnd)
	end		
	return ConfigMgr.doCheckPlist(name)
end 

--获取没有打包的大图的路径
local UI_imgPathHead = "ui/ui_img/"
local imageEnd = ".png"
function ConfigMgr.getUI_imgPathByName(name)
	if (name == nil) then
		return nil
	end
	if (string.len(name) >= string.len(UI_imgPathHead)) then
		local start = string.sub(name, 1, string.len(UI_imgPathHead))
		if (start == UI_imgPathHead) then --已经增加了ui/ui_img/前缀，则直接返回
			return name
		end
	end
	if string.match(name, ".png") ~= nil then 
		return string.format("%s%s", UI_imgPathHead, name)
	else
		return string.format("%s%s%s", UI_imgPathHead, name, imageEnd)
	end		
end 