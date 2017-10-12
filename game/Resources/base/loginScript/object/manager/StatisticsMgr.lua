--[[
	后台统计
--]]

GameStep = {
GameStart = 10000,--启动游戏  --handleServerList（获取服务器列表成功后）
-->如果需要拷包
StartCopyRes = 10010,--拷贝资源开始  --resourceInit
CopyResFinish = 10020,--拷贝资源完成  --resourceInit 拷贝完成的回调
GetServerListFinish = 10030,--获取服务器列表完成  --handleServerList
LoginSDKSuccess=10040,--登陆成功 --->registerLuaCallBack  --从sdk回到我们的游戏
StartEnterGame=10050,--进入游戏开始  -->handleServerLogin(点击服务器)
-->如果需要更新
AppDownloadStart=19010,--程序包开始下载
AppDownloadFinish=19020,--程序包完成下载
AppDownloadException=19030,--程序包下载异常
--< GOTO:0
-->如果需要更新资源
--[
ResDownloadStart=10060,--下载资源开始
ResDownloadFinish=10070,--下载资源完成
ResMergerStart=10080,--合并资源开始
ResMergerFinish=10090,--合并资源完成
--]//可能重复多次
-->如果没有创建角色
CreateRoleStart=10100,--创建角色开始
CreateRoleFinish=10110,--创建角色完成
EnterGameFinish=10120,--进入游戏完成
EnterScene=10130,--进入了场景
}

--0：木有保存，1：整包安装，2：小包安装，3：旧版本升级
local AppInstallType = {
NotSave = 0, 
FullInstall = 1, 
MinInstall = 2, 
Update = 3, 
}

StatisticsMgr = StatisticsMgr or BaseClass()

function StatisticsMgr:__init()
	self.hasSubmit = false
end

function StatisticsMgr:__delete()
	self.hasSubmit = false
end

function StatisticsMgr:buildRequestUrl(action, params)
	local url = LoginWorld.Instance:getServerMgr():getServicesUrl()	
	if url and action and params and type(action)=="string" and type(params)=="table" then 
		url = url .. "?action=" .. action
		for key, value in pairs(params) do 
			url = url .. "&" .. key .. "=" .. value
		end
		return url
	end
end

--安装统计
function StatisticsMgr:requestInstallStatistics()	
	local loginMgr = SFLoginManager:getInstance()
	local uuid = loginMgr:getUUid()
	local gameKey = loginMgr:getGameKey()
	local qdKey = loginMgr:getQDKey()
	local packageKey = SFGameHelper:getClientVersion()	
			
	if self:isSave(gameKey , qdKey , packageKey)~=true then				
		local installType = AppInstallType.NotSave
		local oldPackage = self:getOldVersion()
		if "" ~= oldPackage then  --旧版本升级
			installType = AppInstallType.Update
		elseif hasThisFile("base.zpk")==false then 
			installType = AppInstallType.MinInstall
		else
			installType = AppInstallType.FullInstall		
		end
		
		local frameSize = CCEGLView:sharedOpenGLView():getFrameSize()
		local widthPixels = frameSize.width
		local heightPixels = frameSize.height
		local density = SFGameHelper:getDensity()
		local densityDpi = SFGameHelper:getDensityDpi()
		local manufacture = SFGameHelper:getManuFactuer()
		local model = SFGameHelper:getModel()
		local OS = SFGameHelper:getSystemVer()
			
		local params = {}
		params["uuid"] = uuid
		params["gameKey"] = gameKey
		params["qdKey"] = qdKey
		params["packageKey"] = packageKey
		params["widthPixels"] = widthPixels
		params["heightPixels"] = heightPixels
		params["density"] = density
		params["densityDPI"] = densityDpi
		params["manufacture"] = SFGameHelper:base64Encode(manufacture)	
		params["model"] = SFGameHelper:base64Encode(model) 
		params["os"] = SFGameHelper:base64Encode(OS)  		
		params["oldPackageKey"] = oldPackage
		params["installType"] = installType

		local url = self:buildRequestUrl("install", params)
		if url then 		
			local httpTools = HttpTools:getInstance()
			httpTools:send(url, kTypePost, "noTag", 0, 0)			
			self:save(gameKey, qdKey, packageKey)
		else
			CCLuaLog("url install error")
		end
	end  			
end

--步骤统计
function StatisticsMgr:requestStepStatistics(step)
	CCLuaLog("step statistics, step = ".. step)
	
	-- 暂时只打开登录完成的步骤统计，让机型信息可以和玩家账号挂钩
	if step == GameStep.EnterScene then		
		local loginMgr = SFLoginManager:getInstance()			
		local uuid = loginMgr:getUUid()			
		local gameKey = loginMgr:getGameKey()			
		local qdKey = loginMgr:getQDKey()			
		local packageKey = SFGameHelper:getClientVersion()							
			
		local params = {}
		params["uuid"] = uuid
		params["gameKey"] = gameKey
		params["qdKey"] = qdKey
		params["packageKey"] = packageKey
		params["step"] = step
		
		if step == GameStep.EnterScene then
			local login = LoginWorld.Instance:getLoginManager() 		
			local userId = login:getUserId()
			if userId then 
				params["userId"] = SFGameHelper:base64Encode(userId)
				CCLuaLog("enterScene userId = " .. userId)
			end
		end
		local url = self:buildRequestUrl("step", params)	
		if url then 				
			local httpTools = HttpTools:getInstance()
			httpTools:send(url, kTypePost, "noTag", 0, 0)
		else
			CCLuaLog("url step error")
		end
	end
end

--统计安装方式 1=自动安装， 2=手动安装
function StatisticsMgr:requestAppVersionTypeStatistics(ttype)
	CCLuaLog("auto install")
	if ttype==1 or ttype==2 then 	
		CCLuaLog("aoto install type = ".. ttype)	
		local serverMgr = LoginWorld.Instance:getServerMgr()
		local selectServer = serverMgr:getSelectServer()
		local loginMgr = SFLoginManager:getInstance()
		local uuid = loginMgr:getUUid()
		local gameKey = loginMgr:getGameKey()
		local qdKey = loginMgr:getQDKey()
		local packageKey = SFGameHelper:getClientVersion()		
		local targetKey = selectServer:getClientVer()	
			
		local params = {}
		params["uuid"] = uuid
		params["gameKey"] = gameKey
		params["qdKey"] = qdKey
		params["packageKey"] = packageKey
		params["targetKey"] = targetKey
		params["updateType"] = ttype
		local url = self:buildRequestUrl("versionUpdate", params)
		
		if url then 		
			local httpTools = HttpTools:getInstance()
			httpTools:send(url, kTypePost, "noTag", 0, 0)	
		else
			CCLuaLog("url update error")	
		end	
	end
end

function StatisticsMgr:isSave(gameKey , qdKey , packageKey)
	if gameKey and qdKey and packageKey then 
		local key = gameKey..qdKey..packageKey		
		local reader = CCUserDefault:sharedUserDefault()
		local bSave = reader:getBoolForKey(key)
		return bSave
	end		
end

function StatisticsMgr:save(gameKey , qdKey , packageKey)
	if gameKey and qdKey and packageKey then 
		local key = gameKey..qdKey..packageKey
		local writer = CCUserDefault:sharedUserDefault()
		writer:setBoolForKey(key, true)								
		writer:setStringForKey(Config.UserDefaultKey.Cur_Version_Key, packageKey)  --保存当前版本号
		writer:flush()
	end
end

--错误日志上传
function StatisticsMgr:requestErrorLogUpload(log, playerName)	
	if log and type(log)=="string" then	
		log = SFGameHelper:base64Encode(log)		
		local params = {}
		params["content"] = log		
		if playerName then 
			params["playerName"] = SFGameHelper:base64Encode(playerName)
		end
		local url = self:buildRequestUrl("upload", params)		
		if url then 
			local httpTools = HttpTools:getInstance()
			httpTools:send(url, kTypePost, eHttpReqTag.ErrorLogUpload, 0, 0)				
		end
	end		
end	

function StatisticsMgr:getOldVersion()
	local reader = CCUserDefault:sharedUserDefault()
	local version = reader:getStringForKey(Config.UserDefaultKey.Cur_Version_Key)
	return version
end

function StatisticsMgr:submitExtendData()
	if self.hasSubmit then
		return 
	end
	--将角色名、id、等级、服务器id等信息发给sdk
	local hero = G_getHero()
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local server = serverMgr:getSelectServer()	
	if server then 
		local data = {}
		data.roleId = hero:getId()
		data.unbindGold = PropertyDictionary:get_unbindedGold(hero:getPT())
		data.roleName = PropertyDictionary:get_name(hero:getPT())
		data.roleLevel = PropertyDictionary:get_level(hero:getPT())
		data.unionName = PropertyDictionary:get_unionName(hero:getPT())
		data.viplevel = GameWorld.Instance:getVipManager():getVipLevel()
		data.zoneId = server:getServerId()
		data.zoneName = server:getServerName()
		local cjson = require "cjson.safe"		
		local extendData = cjson.encode(data)
		SFLoginManager:getInstance():submitExtendData(extendData)
		self.hasSubmit = true
	end
end
