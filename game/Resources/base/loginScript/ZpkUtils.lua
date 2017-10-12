--[[
������zpk�汾, �Ƿ���Ҫ������Դ�ȹ�������
]]
require("utils.stringUtils")
require("utils.tableUtils")
require("AppVer")

FirstLevel = 25

PackageName = {
base = "base.zpk",
extend = "extend.zpk",
}

DownloadKey = {
base = "base",
extend = "extent",
other = "other",
extendAndPatch = "extendAndPatch",
baseNeedDelete = "baseNeedDelete",
extendNeedDelete = "extendNeedDelete",
}

ZpkFormat = {
	[1] = "pvr",
	[2] = "pvrtc4"
}

LevelRes = {
	[1] = {name = "extend.zpk",downloadKey = "extend",level = 40},
	--[2] = {name = "extend1.zpk",downloadKey = "extend1",level = 61},
	--[3] = {name = "extend2.zpk",downloadKey = "extend2",level = 80}
}

ExtendOrderList= {}		
ExtendOrderList["extend.zpk"]  = 1
--ExtendOrderList["extend1.zpk"]  = 2
--ExtendOrderList["extend2.zpk"]  = 3

versionTable = {
	4294967296,
	16777216,
	65536,
	256,
}

defaultVersion = "0.0.0.0"

extendVersionList = {}
for k,v in pairs(LevelRes) do
	extendVersionList[v.name] = defaultVersion
end	

function getZpkFormatName(format)
	if format and type(format) == "number" and format >= 0 and format <= 1 then
		return ZpkFormat[format+1]
	else
		return ZpkFormat[1]
	end
end

-- �����ֵİ汾��ת��Ϊ.�ֵĸ�ʽ
local function toVersionCount(versionStr)
	
	local currentVersionList = string.split(versionStr,".")
	local sum  = 0
	for k,v in pairs(currentVersionList) do
		sum  = sum + (tonumber(v)*versionTable[k])
	end
	return sum
end

local function numberVersionToString(strVersion)
	local ret = ""
	if strVersion then
		local first = math.floor(strVersion/(256*256*256))
		local second =  math.floor(strVersion/65536)
		local third = math.floor((strVersion%65536)/256)
		local fourth = strVersion%256
		ret = ret..first.."."..second.."."..third.."."..fourth
	end
	return ret
end

local function compareVersion(current, packageVersion)
	local currentVersionSum = toVersionCount(current)
	local packageVersionSum = toVersionCount(packageVersion)
	return currentVersionSum < packageVersionSum
end

function getPackVersion(packName)
	local basePackageVer = SFPackageManager:Instance():addPackageName(packName)
	local mainVer = basePackageVer.mainVersion
	local subVer = basePackageVer.subVersion
	local baseVersion = numberVersionToString(subVer)
	return baseVersion,mainVer,subVer
end

local function verifyZpkPack(name, appResVersion)
	local isFileExist = CCFileUtils:sharedFileUtils():isFileExist(name)
	local version = getPackVersion(name)
	
	CCLuaLog("version:"..name..","..version)
	
	if isFileExist and compareVersion(version, appResVersion) then
		return true
	end
	return false
end

--[[��ȡ������app�ڲ��İ汾��
�汾�Ź���{mainVersion}_{subVersion}
����: 1_4.6.2, 1��mainVersion, 4.6.2 ��subVersion
]]
function getAppResVersion()
	--local appResVersion = SFPackageManager:Instance():getFileStringContent("install.nw")
	--local versionList = string.split(appResVersion, "_")
	if AppZpkVer then
		return AppZpkVer
	else
		return "0.0.0.0"
	end
end

-- ���汾��, �ж��Ƿ���Ҫ������Դ
function needCopy()
	local appResVersion = getAppResVersion()
	if verifyZpkPack(PackageName.base, appResVersion) or verifyZpkPack(PackageName.extend, appResVersion) then
		CCLuaLog("needCopy")
		return true
	else
		return false
	end
end

function hasThisFile(fileName)
	local resPath = CCFileUtils:sharedFileUtils():fullPathForFilename(fileName)
	return CCFileUtils:sharedFileUtils():isFileExist(resPath)
end	

--�������extend
function allExistExtend()
	local list = {}
	for k,v in pairs(LevelRes) do
		local destPath = SFGameHelper:getExtStoragePath() .. "/"..v.name
		if CCFileUtils:sharedFileUtils():isFileExist(destPath) then
			table.insert(list,v)
		end				
	end
	return list
end

local function checkExtend(list)
	local count = 0
	local name = ""
	for k,v in pairs(LevelRes) do
		if hasThisFile(v.name) then
			count = count + 1
			name = v.name
			table.insert(list,name)		
		end
	end
	return count
end

CopyError = {
	Success = 0,	-- �����ɹ�
	NoFile = 1,		-- ����Ҫ����
	NoSpace = 2,	-- �ռ䲻��
}

--[[
������Դ
@param callback -- 	��ɵĻص�, ��ѽ����Ϊ�����������õĺ���
					����ǿռ䲻������, ��ѿ��ÿռ����Ҫ�Ŀռ�Ĵ�Сһ�𴫹�ȥ
]]
function copyResource(callback)
	local count = 0
	local resName = "base.zpk"
	local copyList = {}
	
	if hasThisFile(resName) then
		count = count + 1
		table.insert(copyList,resName)	
	end
	
	local needSpace = 0
	local oldFileSize, newFileSize
	
	count = count + checkExtend(copyList)
	-- ������Ҫ�Ŀռ�
	for k,v in pairs(copyList) do
		newFileSize = CCFileUtils:sharedFileUtils():getFileLength(v)
		oldFileSize = CCFileUtils:sharedFileUtils():getFileLength(SFGameHelper:getExtStoragePath() .. "/"..v)
		needSpace = needSpace + newFileSize - oldFileSize
	end
	
	local totalFree = SFGameHelper:getRomFreeSpace()
	CCLuaLog("needSpace:"..needSpace..", totalFree:"..totalFree)
	if needSpace > totalFree then
		-- �ռ䲻��
		if callback then
			callback(CopyError.NoSpace, needSpace, totalFree)
		end
		return
	end
	
	local finishCallback = function ()
		count = count - 1
		if count <= 0 and callback then
			callback(CopyError.Success)
		end
	end
	
	local destPath = ""
	if count > 0 then
		for k,v in pairs(copyList) do
			destPath = SFGameHelper:getExtStoragePath() .. "/"..v
			local resPath = CCFileUtils:sharedFileUtils():fullPathForFilename(v)
			SFGameHelper:copyResouce(resPath,destPath,finishCallback)
		end
	elseif callback then
		callback(CopyError.NoFile)		
	end
end

function loadZpk()
	loadExtend()	
	local versionBase = SFPackageManager:Instance():addPackageName("base.zpk")	
	if versionBase.mainVersion ~= 0 or versionBase.subVersion ~= 0 then
		SFScriptManager:shareScriptManager():setZpkSupport(true)
	end
	baseVersionStr = numberVersionToString(versionBase.subVersion)
	return baseVersionStr
end

function loadExtend(count)
	local extendSize = table.size(LevelRes)
	if count == nil then
		count = extendSize
	end
	
	if count > extendSize then
		count = extendSize
	end
	
	if count < 1 then
		count = 1
	end
	for i=count,1,-1 do
		local resData = LevelRes[i]
		local version = SFPackageManager:Instance():addPackageName(resData.name)
		if extendVersionList then
			extendVersionList[resData.name] = numberVersionToString(version.subVersion)
		end			
	end	
end

function needReadAppResources()
	local version = getPackVersion(PackageName.base)	
	local appResVersion = getAppResVersion()
	local ret = compareVersion(version, appResVersion)
	if ret then
		CCLuaLog("needReadAppResources")
	end
	
	return ret
end

function getExtendPack(level)
	local result = {}	
	for k,v in pairs(LevelRes) do
		if level >= v.level and extendVersionList[v.name] == defaultVersion then		
			table.insert(result,v)
		end
	end
	return result
end

function tempNameToRealName(tempName)
	if string.find(tempName,"_") then
		local tempList = string.split(tempName,"_")
		local reloadName = tempList[1]..".zpk"
		return reloadName
	end
	return nil
end
