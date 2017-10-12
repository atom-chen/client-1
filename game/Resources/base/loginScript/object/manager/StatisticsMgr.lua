--[[
	��̨ͳ��
--]]

GameStep = {
GameStart = 10000,--������Ϸ  --handleServerList����ȡ�������б�ɹ���
-->�����Ҫ����
StartCopyRes = 10010,--������Դ��ʼ  --resourceInit
CopyResFinish = 10020,--������Դ���  --resourceInit ������ɵĻص�
GetServerListFinish = 10030,--��ȡ�������б����  --handleServerList
LoginSDKSuccess=10040,--��½�ɹ� --->registerLuaCallBack  --��sdk�ص����ǵ���Ϸ
StartEnterGame=10050,--������Ϸ��ʼ  -->handleServerLogin(���������)
-->�����Ҫ����
AppDownloadStart=19010,--�������ʼ����
AppDownloadFinish=19020,--������������
AppDownloadException=19030,--����������쳣
--< GOTO:0
-->�����Ҫ������Դ
--[
ResDownloadStart=10060,--������Դ��ʼ
ResDownloadFinish=10070,--������Դ���
ResMergerStart=10080,--�ϲ���Դ��ʼ
ResMergerFinish=10090,--�ϲ���Դ���
--]//�����ظ����
-->���û�д�����ɫ
CreateRoleStart=10100,--������ɫ��ʼ
CreateRoleFinish=10110,--������ɫ���
EnterGameFinish=10120,--������Ϸ���
EnterScene=10130,--�����˳���
}

--0��ľ�б��棬1��������װ��2��С����װ��3���ɰ汾����
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

--��װͳ��
function StatisticsMgr:requestInstallStatistics()	
	local loginMgr = SFLoginManager:getInstance()
	local uuid = loginMgr:getUUid()
	local gameKey = loginMgr:getGameKey()
	local qdKey = loginMgr:getQDKey()
	local packageKey = SFGameHelper:getClientVersion()	
			
	if self:isSave(gameKey , qdKey , packageKey)~=true then				
		local installType = AppInstallType.NotSave
		local oldPackage = self:getOldVersion()
		if "" ~= oldPackage then  --�ɰ汾����
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

--����ͳ��
function StatisticsMgr:requestStepStatistics(step)
	CCLuaLog("step statistics, step = ".. step)
	
	-- ��ʱֻ�򿪵�¼��ɵĲ���ͳ�ƣ��û�����Ϣ���Ժ�����˺Źҹ�
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

--ͳ�ư�װ��ʽ 1=�Զ���װ�� 2=�ֶ���װ
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
		writer:setStringForKey(Config.UserDefaultKey.Cur_Version_Key, packageKey)  --���浱ǰ�汾��
		writer:flush()
	end
end

--������־�ϴ�
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
	--����ɫ����id���ȼ���������id����Ϣ����sdk
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
