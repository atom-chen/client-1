-- ���ù���s��

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


-- ���ͼƬ��Ӧ��plist�ļ��Ƿ���أ����û�м��أ�����м���
-- ����: ��image����
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
	local plist = Config.UIImage[image]		--�ҳ���ͼƬ��Ӧ��plist�ļ�·��
	if (plist ~= nil) then						--�ҵ���ͼƬ�����м���	
		function loadPlist(plist)				-- ����plist�ļ�
			local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
			frameCache:addSpriteFramesWithFile(plist)
		end
		loadPlist(plist)
		--Config.UIImage[image] = nil		--����item��Config.UIImage��ɾ������Լ�ڴ��Լ�����´η��ʸú�����Ч��		
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
		if (start == iconPathHead) then --�Ѿ�������icon/ǰ׺����ֱ�ӷ���
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

-- ���������С���ַ��������С�����ֶ�Ӧ��Config.FontSize
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

--���������ֵ�·��
function ConfigMgr.getArtisticTextPathByName(name)
	local path = Config.ArtisticText[name]
	if (path == nil) then
		error("error. getTextStylePathByName(name): did not find the path")
	end
	return path
end		

--��ȡ�������ֵ�����·��
function ConfigMgr.getAtlasNumberPathByName(config)
	if config and config.name then
		return config.name
	else
		error("error. getTextStylePathByName(name): did not find the path")
		return ""
	end
end	

--��ȡ�������ֵĴ�С
function ConfigMgr.getAtlasNumberSize(config)
	if config and config.size then
		return config.size
	else
		return {width=14, height=14}
	end
end	

--��ȡģ�͵�·��
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

--��ȡû�д���Ĵ�ͼ��·��
local UI_imgPathHead = "ui/ui_img/"
local imageEnd = ".png"
function ConfigMgr.getUI_imgPathByName(name)
	if (name == nil) then
		return nil
	end
	if (string.len(name) >= string.len(UI_imgPathHead)) then
		local start = string.sub(name, 1, string.len(UI_imgPathHead))
		if (start == UI_imgPathHead) then --�Ѿ�������ui/ui_img/ǰ׺����ֱ�ӷ���
			return name
		end
	end
	if string.match(name, ".png") ~= nil then 
		return string.format("%s%s", UI_imgPathHead, name)
	else
		return string.format("%s%s%s", UI_imgPathHead, name, imageEnd)
	end		
end 