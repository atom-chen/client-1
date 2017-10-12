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
	GlobalEventSystem = GlobalEventSystem or nil	--ȫ�ֵ���Ϸ�¼�ϵͳ	
	GlobalConfigMgr = GlobalConfigMgr or nil		--ȫ�ֵ����ù���
	GlobalEventSystem = EventSystem:New()	
	GlobalConfigMgr = ConfigMgr:New()
	
	UIManager.New()									--ȫ�ֵ�UI������
	UIManager.Instance:initAll()
	
	GameWorld.New()		
	
	SceneManager.New()								--ȫ�ֵĳ���������
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