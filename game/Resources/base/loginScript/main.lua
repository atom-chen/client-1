function __G__TRACKBACK__(msg)
	print("error")
	CCLuaLog("----------------------------------------")
	local errMsg = "LUA ERROR: " .. tostring(msg) .. "\n"..debug.traceback()
	CCLuaLog(errMsg)
	CCLuaLog("----------------------------------------")
	-- 替换换行符
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
	
	GlobalEventSystem = GlobalEventSystem or nil	--全局的游戏事件系统
	GlobalConfigMgr = GlobalConfigMgr or nil		--全局的配置管理
	GlobalEventSystem = EventSystem:New()
	GlobalConfigMgr = ConfigMgr:New()
	
	UIManager.New()									--全局的UI管理器
	UIManager.Instance:initAll()
	
	LoginWorld.New()
	
	SceneManager.New()								--全局的场景管理器
	SceneManager.Instance:initLoginScene()
	
	PatchManager.New()
	DownloadManager.New()
	ResManager.New()
	
	SceneManager:switchTo(SceneIdentify.LoginScene)	-- 切换到登录场景
end

local function main()
	-- luajit有随机崩溃, 目前先关掉
	jit.off()
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	math.randomseed(os.time())
	
	--require("LoginGameDef")
	require("ZpkUtils")
	
	-- win32不需要执行下面的逻辑
	if SFLoginManager:getInstance():getPlatform() ~= "win32" then
		if not needReadAppResources() and not needCopy() then
			SFPackageManager:Instance():releaseLoadPackage()
			--不需要拷贝, 直接读取zpk
			loadZpk()
		else
			SFPackageManager:Instance():releaseLoadPackage()
		end
	end
		
	init()
	GlobalEventSystem:Fire(GameEvent.EventShowGetServerListHUD)
	LoginWorld.Instance:getLoginManager():requestServerList()--请求服务器列表
end

xpcall(main, __G__TRACKBACK__)