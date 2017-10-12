--[[
资源的检测、更新的管理类
]]

require "common.BaseObj"
require "ZpkUtils"

ResManager = ResManager or BaseClass(BaseObj)

function ResManager:__init()
	ResManager.Instance = self
	self.needExtend = false
	self.baseVersion = defaultVersion	
	
	self.downloadkey = DownloadKey.other
	self.currentVersion = defaultVersion	
	self.loadMainScript = false
	
	self.patchUrlList = {}	
	self.isSlient = false	
	self.bCopying = false
	self.bInitSuccess = false
	self.downloadCallBack = nil
	self.rewardList = {}
	self.hasRewardFeedBack = false
	self.reward = nil
	self.rewardKey = nil
	for k,v in pairs(LevelRes) do
		self.rewardList[v.name] = false
	end
	self.level = -1
	
	self.packageUrl = {}			-- base和extend的url列表
	self.packageVersion = ""		-- 版本号
	
	self.packageMD5 = {}			-- 资源包MD5
end

function ResManager:__delete()
	
end

-- 是否正在拷贝
function ResManager:isCopying()
	return self.bCopying
end

-- 资源初始化是否成功
function ResManager:isInitSuccess()
	return self.bInitSuccess
end

function ResManager:setInitSuccess()
	self.bInitSuccess = true
end

function ResManager:loadScript()
	if not self.loadMainScript then
		SFScriptManager:shareScriptManager():excuteZpkLua("script/main.lua")
		self.loadMainScript = true
	end
end

function ResManager:getPatchUrlList()
	return self.patchUrlList
end

function ResManager:needCopy()
	return needCopy()
end

function ResManager:getPackVersion(packName)
	return getPackVersion(packName)
end

-- 先检测是否需要拷贝资源, 完成后会调用callback
function ResManager:resourceInit(callback)
	local ret =false
	
	if self:needCopy() then
		local function copyCallBack(errCode, param1, param2)
			if errCode == CopyError.Success or errCode == CopyError.NoFile then
				self.bInitSuccess = true
			end
			
			-- 下载完成的回调不在主线程，这里要转换一下			
			local schedulerId = 0
			
			local function scheduleCallback(time)			
				LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.CopyResFinish)
				self.bCopying = false
				if callback then
					callback(errCode, param1, param2)
				end
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedulerId)
			end
			schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 0, false)
		end
		
		CCLuaLog("resourceInit, start copy")
		LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.StartCopyRes)
		self.bCopying = true
		SFPackageManager:Instance():releaseLoadPackage()
		copyResource(copyCallBack)
		ret = true
	elseif callback then
		callback()
	end
	
	return ret
end

function ResManager:setNeedExtend(flag)
	self.needExtend = flag
end

function ResManager:needExtend()
	return self.needExtend
end

function ResManager:needDownLoadExtend()
	if SFLoginManager:getInstance():getPlatform() ~= "win32" then
		if self.needExtend then
			local version = getPackVersion("extend.zpk")
			return version == defaultVersion
		end
	end
	
	return false
end

function ResManager:removePatch(pathList,func)
	if self:hasfullExtend() then
		self:deleteFiles(pathList,func)
	else
		func()
	end		
end

function ResManager:downloadExtend(isSilent,key,version)
	local extendVersion = "miniVerUpdate"
	
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local server = serverMgr:getSelectServer()
	local downloadkey = DownloadKey.extend
	if key then
		downloadkey = key
	end
	if version then
		if server:getCurrentResourceVer() ~= version then
			extendVersion = version
		else
			downloadkey = DownloadKey.extend
		end
		if isSilent then
			self:requestUpdateRes(server:getServerId(),extendVersion,downloadkey, eHttpReqTag.ResUpdateSilentTag)
		else
			self:requestUpdateRes(server:getServerId(),extendVersion,downloadkey, eHttpReqTag.ResUpdateTag)
		end
	else
		self.isSlient = isSilent
		self:requestUpdateRes(server:getServerId(),extendVersion,downloadkey, eHttpReqTag.ExtendVersion)
	end
end

-- 读取zpk
function ResManager:loadZpk()
	self.versionBase = loadZpk()
end

-- 是否已经读取的zpk
function ResManager:releaseZpk()
	SFPackageManager:Instance():releaseLoadPackage()
end

-- 是否需要进行合包逻辑
function ResManager:needPatch()
	local ret = false
	if self.patchUrlList then
		for k,v in pairs(self.patchUrlList) do
			if not string.find(v.name, "base") and  not string.find(v.name, "extend") then
				-- 找到了补丁包
				local filePath = SFGameHelper:getExtStoragePath().."/"..v.name
				if CCFileUtils:sharedFileUtils():isFileExist(filePath) then
					ret = true
					break
				end
			end
		end
	end
	
	return ret
end

function ResManager:reloadZpk(list)
	local extendMax = -1
	local hasBase = false
	for k,v in pairs(list) do
		if v == "base.zpk" then
			hasBase = true
		elseif string.find(v,"extend") then
			local order =	ExtendOrderList[v]
			if order and order > extendMax then
				extendMax = order
			end
		end
	end
	
	if extendMax ~= -1 then
		SFPackageManager:Instance():releaseLoadPackage()
		loadExtend(extendMax)
		self.versionBase = SFPackageManager:Instance():addPackageName("base.zpk")
		if GameWorld then
			local gameMapManager = GameWorld.Instance:getMapManager()
			gameMapManager:loadConfig()
		end
	elseif hasBase then
		SFPackageManager:Instance():releaseLoadPackage()
		SFScriptManager:shareScriptManager():setZpkSupport(true)
		self.versionBase = SFPackageManager:Instance():addPackageName("base.zpk")
	end
end

function ResManager:checkResVersion()
	if SFLoginManager:getInstance():getPlatform() ~= "win32" or
		(SFLoginManager:getInstance():getPlatform() == "win32" and "0.0.0.0" ~= getPackVersion("base.zpk") ) then
		-- 检查资源更新
		local serverMgr = LoginWorld.Instance:getServerMgr()
		local selectServer = serverMgr:getSelectServer()
		
		self.downloadkey = DownloadKey.other		
		self.currentVersion = "miniVerUpdate"
		-- 获取当前资源版本号
		local serverVer = selectServer:getCurrentResourceVer()
		local serverMainVer = selectServer:getCurrentMainVer()	
		local baseVersion,mainVer,subVer = getPackVersion(PackageName.base)		
		self.baseVersion = baseVersion
		CCLuaLog("base mainVersion:"..mainVer.." ,subVersion:"..baseVersion)
		CCLuaLog("server mainVersion:"..selectServer:getCurrentMainVer().." ,subVersion:"..selectServer:getCurrentResourceVer())
		if  serverMainVer > mainVer then
			self.downloadkey = DownloadKey.baseNeedDelete			
			self.currentVersion = "miniVerUpdate"
			return true
		end
		if baseVersion == defaultVersion then
			self.downloadkey = DownloadKey.base			
		else
			local minKey = defaultVersion
			local minVer = versionTable[1]
			local minVersion = defaultVersion
			local extendVersion,extendMainVer,extendSubVer
			local needdCompleteUpdate  = false
			for k,v in pairs(LevelRes) do
				extendVersion,extendMainVer,extendSubVer = getPackVersion(v.name)
				extendVersionList[v.name] = extendVersion
				if extendMainVer < serverMainVer then
					needdCompleteUpdate = true					
				end
				if extendSubVer < minVer and extendSubVer > 0 then
					minVer = extendSubVer
					minKey = v.name
					minVersion = extendVersion
				end
			end
						
			if minKey == defaultVersion then
				self.currentVersion = baseVersion
			else
				if  needdCompleteUpdate then
					self.downloadkey = DownloadKey.extendNeedDelete
					self.currentVersion = "miniVerUpdate"
					return true
				end
				extendVersion = extendVersionList[minKey]
				if self:compareVersion(baseVersion, extendVersion)==true then
					self.currentVersion = extendVersion
				else
					self.currentVersion = baseVersion
				end
			end
		end
		
		--资源包版本对比， 不一样则请求更新
		CCLuaLog("extendVersion version"..self.currentVersion)
		
--		UIManager.Instance:showSystemTips("extendVersion version"..self.currentVersion)
		
		if self.currentVersion=="miniVerUpdate" or self:compareVersion(serverVer, self.currentVersion) then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 请求资源更新的json
function ResManager:requestUpdateRes(serverId,version,key, tag)
	--在{resourceVer}字段之前添加服务器的Id
	local resourceCheckUrl = LoginWorld.Instance:getServerMgr():getResourceCheckUrl()
	local posBegin, posEnd = string.find(resourceCheckUrl, "{")
	local versionStr = string.match(resourceCheckUrl, "{.+")
	local tmpUrl = string.sub(resourceCheckUrl, 1, posBegin-1)
	resourceCheckUrl = tmpUrl..serverId.."/"..versionStr
	
	-- 替换资源更新列表的{resourceVer}字段
	local resCheckUrl = ""
	if version then
		resCheckUrl = string.gsub(resourceCheckUrl, "{resourceVer}", version)
	else
		resCheckUrl = string.gsub(resourceCheckUrl, "{resourceVer}", self.currentVersion)
	end
	
	resCheckUrl = string.gsub(resCheckUrl, "{format}", self:getSupportFormat())
	
	if key then
		self.downloadkey = key
	end
	CCLuaLog("resCheckUrl"..resCheckUrl)
	self:requestResUpdateList(resCheckUrl, tag)
end	

function ResManager:getDownloadKey()
	return self.downloadkey
end

function ResManager:setDownloadKey(key)
	self.downloadkey = key
end

function ResManager:getCurrentVersion()
	return self.currentVersion
end

-- 请求资源更新列表
-- isSlient: 是否在后台下载
function ResManager:requestResUpdateList(url, tag)
	if url and type(url) == "string" then
		local httpTools = HttpTools:getInstance()
		
		if httpTools then
			httpTools:send(url, kTypeGet, tag, nil, 0)
		end
	end
end

function ResManager:handleResUpdateList(state, responeData, tag)
	if state == 200 and  responeData ~= "null" then
		local cjson = require "cjson.safe"
		local resUpdateList,errorMsg = cjson.decode(responeData)
		if resUpdateList then
			if tag == eHttpReqTag.ExtendVersion then			
				self:downloadExtend(self.isSlient,DownloadKey.extendAndPatch,self.packageVersion)				
				return
			end
			local isSlient = (tag == eHttpReqTag.ResUpdateSilentTag)
			local parseRet = self:paserResJson(resUpdateList)
			
			if parseRet then
				local downloadFunc = function ()
					GlobalEventSystem:Fire(GameEvent.EventDownload, isSlient)
				end
				
				if SFGameHelper:getCurrentNetWork() ~= kWifi then
					self:showNetworkNotify(downloadFunc)
				else
					downloadFunc()
				end					
			elseif not parseRet then
				UIManager.Instance:showSystemTips(Config.LoginWords[341])
			end
		else
			UIManager.Instance:showSystemTips("Error:  " .. errorMsg)
			--TODO
		end
	else
		UIManager.Instance:showSystemTips(Config.LoginWords[341])
	end
	
	
end


function ResManager:showDownloadNotify(isSlient)
	local networkNotice = function(arg,text,id)
		if id == 0 then	
			GlobalEventSystem:Fire(GameEvent.EventDownload, isSlient)
		end
	end
	local btns ={
	{text = Config.LoginWords[10043], id = 0},
	{text = Config.LoginWords[10045], id = 1},
	}
	local notic = Config.LoginWords[14000]

	local msg = showMsgBox(notic)
	msg:setBtns(btns)
	msg:setNotify(networkNotice)
end

--[[function ResManager:getExtendVersion(json)
	return json["extent"][1].version
end]]

function ResManager:getServerBaseMD5()
	return self:getServerPackageMD5("base")
end

-- 获取packageName对应的MD5
function ResManager:getServerPackageMD5(packageName)
	if not packageName then
		return ""
	end
	
	local md5Key = packageName.."MD5"
	
	local format = self:getSupportFormat()
	if self.packageMD5[format] and self.packageMD5[format][md5Key] then
		return self.packageMD5[format][md5Key]
	else
		-- 如果没有找到对应的格式的版本，默认取pvr
		return self.packageMD5["pvr"][md5Key]
	end
end

function ResManager:getPackageUrl(packageName)
	if not packageName then
		return ""
	end
	
	return self.packageUrl[packageName]
end

-- 只处理base和extend的资源的解析
function ResManager:paserBase(list)
	return self:paserPackage(list, "base")
end	

function ResManager:paserPackage(list, packageName)
	local packageMD5 = self:getServerPackageMD5(packageName)
	
	local packageData = {}
	packageData.url = self.packageUrl[packageName]
	packageData.md5 = packageMD5
	packageData.name = packageName.."_"..self.packageVersion.."_"..self:getSupportFormat()..".zpk"
	
	-- 替换url里面的通配符
	packageData.url = string.gsub (packageData.url,"%[resVer%]",self.packageVersion)
	packageData.url = string.gsub (packageData.url,"%[format%]",self:getSupportFormat())
	table.insert(list,packageData)	
end

-- 获取当前手机支持的资源格式
function ResManager:getSupportFormat()
	local format = "pvr"
	if CCConfiguration:sharedConfiguration():supportsPVRTC() then
		format = "pvrtc4"
	end
	
	return format
end

function ResManager:packPatch(resPack,resURLTemplate)
	local count = 0
	local tempURl = ""
	local tempData = {}
	for k,v in pairs(resPack) do
		tempData = {}
		tempURl = string.gsub (resURLTemplate,"%[resVer%]",v.version)
		tempURl = string.gsub (tempURl,"%[format%]",self:getSupportFormat())
		tempURl = tempURl..".zpk"
		tempData.url = tempURl
		tempData.md5 = v.md5
		tempData.name = "download//"..v.resName
		table.insert(self.patchUrlList,tempData)
		count = count + 1
	end
	return count
end

function ResManager:packExtend(json,level,deleteList,all)
	local extendPack = getExtendPack(level)
	if all then
		extendPack = allExistExtend()
	end
	local count = 0
	local tempData = {}
	local key = ""
	local maxKey = nil
	local max = 0
	local order = 0
	for k,v in pairs(extendPack) do
		tempData = {}
		key = v.downloadKey		
		if self.packageUrl[key] then
			self:paserPackage(self.patchUrlList, key)
--[[			tempData.url = json[key][1].url
			tempData.md5 = json[key][1].md5
			local name = key
			if key == "extent" then
				name = "extend"
			end			
			tempData.name = name.."_"..json[key][1].version..".zpk"	
			table.insert(self.patchUrlList,tempData)--]]
			if deleteList then
				table.insert(deleteList,v.name)
			end
			order = ExtendOrderList[v.name]
			if order > max then
				maxKey =  v.name
				max = order
			end
			count = count + 1
			
		end
	end
	self.rewardKey = maxKey
	self.reward = self:getRewardListWithKey(maxKey)	
	return count
end

function ResManager:getRewardListWithKey(key)
	local list = nil
	if GameData.ResDownload then
		if key then
			list = {}
			local data = GameData.ResDownload[key]
			if data then
				local reward = data.reward
				if reward then
					local data = {}
					for k,v in pairs(reward) do
						data = {}
						local ref = v.refId
						if string.find(ref,"gold") then
							ref = string.gsub(ref,"item_","")
						end
						data.itemRefId = ref
						data.number = v.number
						table.insert(list,data)
					end
				end
			end
		end			
	end
	
	return list
end

function ResManager:paserResJson(json)
	-- 清空数据
	self.patchUrlList = {}
	
	local resURLTemplate = json.resUrlPath
	local resPack = json.resUpdate
	
	local tempData = {}
	local count = 0	
	local key = self:getDownloadKey()
	local level = self:getLevel()
	if level < LevelRes[1].level then
		level = LevelRes[1].level
	end
	if key == DownloadKey.other then
		count = count + self:packPatch(resPack,resURLTemplate)
	elseif key == DownloadKey.extendAndPatch	then
		count = count + self:packPatch(resPack,resURLTemplate)	
		
		count = count + self:packExtend(json,level)
	elseif key == DownloadKey.baseNeedDelete or key == DownloadKey.extendNeedDelete then
		local name = DownloadKey.base
		local deleteList = {}
		if key == DownloadKey.extendNeedDelete then
			name = DownloadKey.extend
			count = count + self:packExtend(json,level,deleteList,true)
		else
			table.insert(deleteList,PackageName.base)
			count = count + 1
			self:paserBase(self.patchUrlList)
		end
						
		local deleteCallBack = function ()
			local finishCallback = function ()
				self.downloadCallBack = nil
			end
			self:deleteFiles(deleteList,finishCallback)
		end
		self:setDownloadCallBack(deleteCallBack)
	else
		if string.find(key,	"extent") or string.find(key,"extend") then
			count = count + self:packExtend(json,level)
		else
			count = count + 1
			self:paserBase(json,self.patchUrlList,key)
		end
		
	end		
	self:setDownloadKey(DownloadKey.other)
	
	return count > 0
end


function ResManager:getPatchUrlList()
	return self.patchUrlList, self.reloadName
end

-- 开始下载
function ResManager:startDownload(callback)
	local function downloadCallback(eventCode, intValue, stringData, doubleValue)
		if callback then
			callback(eventCode, intValue, stringData, doubleValue)
		end
	end
	
	local manager = DownloadManager.Instance
	manager:registerCallBack(downloadCallback)
	
	local downloadPath =  SFGameHelper:getExtStoragePath().."download"
	manager:setDownloadPath(downloadPath)
	manager:startDownloadURL(self.patchUrlList)
end

--ver1和ver2都是字符串, 格式为:0.9.0.1
--ver1>ver2返回 true
--ver1<=ver2返回false
function ResManager:compareVersion(ver1, ver2)
	ver1 = string.split(ver1, ".")
	ver2 = string.split(ver2, ".")
	local cnt1 = table.size(ver1)
	local cnt2 = table.size(ver2)
	if cnt1==0 or cnt2==0 then
		return false
	end
	local cnt = 0
	if cnt1 > cnt2 then
		cnt = cnt2
	else
		cnt = cnt1
	end
	for i = 1, cnt do
		if tonumber(ver1[i]) > tonumber(ver2[i]) then
			return true
		elseif tonumber(ver1[i]) < tonumber(ver2[i]) then
			return false
		end
	end
	--剩下的情况是ver1和ver2的每一位都相等（除了多出来的位）
	if cnt1 == cnt2 then
		return false
	end
	if cnt == cnt1 then
		if ver2[cnt2] > 0 then
			return false
		end
	end
	if cnt == cnt2 then
		if tonumber(ver1[cnt1]) > 0 then
			return true
		end
	end
end

function ResManager:setDownloadCallBack(func)
	if func then
		self.downloadCallBack = func
	end
end

function ResManager:getDownloadCallBack()
	return self.downloadCallBack
end

function ResManager:canGetReward()
	if self.hasRewardFeedBack then
		if self.rewardList[self.rewardKey] then
			return true
		end
	end
	return false
end

function ResManager:requestGetReward(rewardId)
	if rewardId then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_resDownloadGetReward)
		StreamDataAdapter:WriteStr(writer,rewardId)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function ResManager:requestCanGetReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_resDownloadCanGetReward)		
	simulator:sendTcpActionEventInLua(writer)	
end

function ResManager:hasLevelRes(level)
	if level == nil then
		level = self:getLevel()
	end
	local hasRes = true
	for k,v in pairs(LevelRes) do
		if level >= v.level and extendVersionList[v.name] == defaultVersion then
			hasRes = false
		end
	end
	return hasRes
end

function ResManager:hasfullExtend()
	for k,v in pairs(extendVersionList) do
		if v == defaultVersion then
			return false
		end
	end
	return true
end

function ResManager:setLevel(level)
	self.level = level
end

function ResManager:getLevel()
	if GameWorld and GameWorld.Instance then
		local hero = GameWorld.Instance:getEntityManager():getHero()
		if hero then
			return PropertyDictionary:get_level(hero:getPT())
		end			
	end
	return self.level
end

function ResManager:clearPatchList()
	self.patchUrlList = {}
end

function ResManager:deleteFiles(deleteList,finishCallback)
	local count = table.size(deleteList)
	local finish = function ()
		count = count - 1
		if count == 0 or count < 0 then
			if finishCallback then
				finishCallback()
			end				
		end
	end
	local fileName = ""
	SFPackageManager:Instance():releaseLoadPackage()
	for k,v in pairs(deleteList) do
		fileName = SFGameHelper:getExtStoragePath()..v
		SFGameHelper:deleteFile(fileName,finish)
	end
	if count == 0 then
		finishCallback()
	end
end

function ResManager:showDownloadMessage(message,func)
	
	local msgBoxCallback = function(arg,text,id)
		if id == 0 then
			if SFGameHelper:getCurrentNetWork() ~= kWifi then
				self:showNetworkNotify(func)
			else
				func()
			end	
		end
	end					
	local btns ={
		{text = Config.Words[10045], id = 1},
		{text = Config.Words[10043], id = 0},
	}		
	local msg = showMsgBox(message)
	msg:setBtns(btns)
	msg:setNotify(msgBoxCallback)
end

function ResManager:showNetworkNotify(func)
	local networkNotice = function(arg,text,id)
		if id == 0 then
			if func then
				func()
			end
		end
	end
	local btns ={
		{text = Config.LoginWords[10043], id = 0},
		{text = Config.LoginWords[10045], id = 1},
	}
	local notic = Config.LoginWords[14000]

	local msg = showMsgBox(notic)
	msg:setBtns(btns)
	msg:setNotify(networkNotice)
end

function ResManager:getResDownloadRewardKey()
	return self.rewardKey
end

function ResManager:setResRewardData(data)
	for k,v in pairs(data) do
		self.rewardList[v] = true
	end
	self.hasRewardFeedBack = true
end

function ResManager:hasResrewardFeedBack()
	return self.hasRewardFeedBack
end

function ResManager:getReward()
	return self.reward
end

function ResManager:checkData(resVer)
	-- 必须要有pvr格式的版本信息，这个是默认的资源格式
	if not (resVer and type(resVer) == "table" and resVer["baseUrl"] and resVer["version"] and resVer["pvr"] and resVer["pvr"]["baseMD5"]) then
		return false
	end 
	
	-- 检查是否有完整的extend信息
	local ret = true
	for k,v in pairs(LevelRes) do
		local name = v.downloadKey
		
		if not resVer[name.."Url"] or not resVer["pvr"][name.."MD5"] then
			ret = false
			break
		end
	end
	
	return ret
end

function ResManager:paserVersionData(resVer)
	--return true
	if self:checkData(resVer) then
		self.packageUrl["base"] = resVer["baseUrl"]
		self.packageVersion = resVer["version"]
		
		-- 根据配置解析extend的资源信息
		for k,v in pairs(LevelRes) do
			local name = v.downloadKey
			local urlKey = name.."Url"
			self.packageUrl[name] = resVer[urlKey]
		end
		
		-- 解析各种格式的MD5信息
		for i,v in pairs(ZpkFormat) do
			if v and resVer[v] then
				self.packageMD5[v] = {}
				self.packageMD5[v] = resVer[v]
			end
		end
		
		return true
	else
		return false
	end
end