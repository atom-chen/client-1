require("scene.SceneManager")
require("common.eventsystem")
require("common.BaseScene")
require("ui.UIManager")
require("GameWorld")
require("config.ConfigMgr")
require("GameDef")

function __G__TRACKBACK__(msg)
	CCLuaLog("----------------------------------------")
	CCLuaLog("LUA ERROR: " .. tostring(msg) .. "\n")
	CCLuaLog(debug.traceback())
	CCLuaLog("----------------------------------------")
end

local function init()
	GlobalEventSystem = GlobalEventSystem or nil	--全局的游戏事件系统	
	GlobalConfigMgr = GlobalConfigMgr or nil		--全局的配置管理
	GlobalEventSystem = EventSystem:New()	
	GlobalConfigMgr = ConfigMgr:New()
	
	UIManager.New()									--全局的UI管理器
	UIManager.Instance:initAll()
	
	GameWorld.New()		
	
	SceneManager.New()								--全局的场景管理器
	SceneManager.Instance:initAll()								
end

local function main()
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)	

	init()
	SceneManager:switchTo(SceneIdentify.LoginScene)	
	
	GlobalEventSystem:Fire(GameEvent.EVENT_LOGIN_UI)	
end

xpcall(main, __G__TRACKBACK__)