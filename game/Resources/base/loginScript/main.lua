function __G__TRACKBACK__(msg)
	print("error")
	CCLuaLog("----------------------------------------")
	local errMsg = "LUA ERROR: " .. tostring(msg) .. "\n"..debug.traceback()
	CCLuaLog(errMsg)
	CCLuaLog("----------------------------------------")
	-- �滻���з�
	local emailContent = "Platform:"..SFLoginManager:getInstance():getPlatform().."\n"
	emailContent = emailContent.."AppVersion:"..SFGameHelper:getClientVersion().."\n"
	emailContent = emailContent.."BaseVersion:"..(getPackVersion("base.zpk")).."\n"
	emailContent = emailContent.."ExtendVersion:"..(getPackVersion("extend.zpk")).."\n"
	emailContent = emailContent.."ErrorTime: "..os.date("%y/%m/%d  %X").."\n"
	emailContent = emailContent..errMsg
	LoginWorld.Instance:getStatisticsMgr():requestErrorLogUpload(emailContent)
	--[[emailContent = string.gsub(emailContent, "\n", "<br>")
	
	math.randomseed(os.time())
	local mailId = math.random(1, 11)
	local sendFrom = "newbeeStudio"..mailId.."@163.com"
	
	local sendEmail = SFEasyMail:new(sendFrom, "newbeeStudio", "smtp://smtp.163.com:25", "<"..sendFrom..">")
	sendEmail:SetMailContent("lua error"..os.date(), emailContent)
	sendEmail:AddRecipient("newbeeStudioLog@163.com")
	sendEmail:SendMail()--]]
	
	--[[local file = io.open("log.txt", "w+")
	file:write(tostring(msg))
	file:close()]]
end

local function init()
	require("common.eventsystem")
	require("common.BaseScene")
	require("ui.UIManager")
	require("LoginWorld")
	require("config.ConfigMgr")
	require("scene.SceneManager")
	require("ui.UIDef")
	require("object.res.ResManager")
	require("object.res.DownloadManager")
	require("object.res.PatchManager")
	
	GlobalEventSystem = GlobalEventSystem or nil	--ȫ�ֵ���Ϸ�¼�ϵͳ
	GlobalConfigMgr = GlobalConfigMgr or nil		--ȫ�ֵ����ù���
	GlobalEventSystem = EventSystem:New()
	GlobalConfigMgr = ConfigMgr:New()
	
	UIManager.New()									--ȫ�ֵ�UI������
	UIManager.Instance:initAll()
	
	LoginWorld.New()
	
	SceneManager.New()								--ȫ�ֵĳ���������
	SceneManager.Instance:initLoginScene()
	
	PatchManager.New()
	DownloadManager.New()
	ResManager.New()
	
	SceneManager:switchTo(SceneIdentify.LoginScene)	-- �л�����¼����
end

local function main()
	-- luajit���������, Ŀǰ�ȹص�
	jit.off()
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	math.randomseed(os.time())
	
	--require("LoginGameDef")
	require("ZpkUtils")
	
	-- win32����Ҫִ��������߼�
	if SFLoginManager:getInstance():getPlatform() ~= "win32" then
		if not needReadAppResources() and not needCopy() then
			SFPackageManager:Instance():releaseLoadPackage()
			--����Ҫ����, ֱ�Ӷ�ȡzpk
			loadZpk()
		else
			SFPackageManager:Instance():releaseLoadPackage()
		end
	end
		
	init()
	GlobalEventSystem:Fire(GameEvent.EventShowGetServerListHUD)
	LoginWorld.Instance:getLoginManager():requestServerList()--����������б�
end

xpcall(main, __G__TRACKBACK__)