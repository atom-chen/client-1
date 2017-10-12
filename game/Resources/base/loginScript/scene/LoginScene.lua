require("ui.UIFactory")
require("common.LoginBaseUI")
require("ui.UIManager")
require ("common.BaseScene")

LoginScene = LoginScene or BaseClass(BaseScene);

function LoginScene:onSceneEnter(sceneObject, event, sceneName)
	local uiManager = UIManager.Instance
	self.scene:addUILayer(uiManager:getGameRootNode())
	self.scene:addUILayer(uiManager:getUIRootNode())
	self.scene:addUILayer(uiManager:getDialogRootNode())
	
end	

function LoginScene:onSceneExit(sceneObject, event, sceneName)
	local uiManager = UIManager.Instance
	uiManager:clear(true)
	uiManager:showLoadingSence(10)
end

function LoginScene:__init()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local gamePresenter = simulator:getGamePresenter()
	
	--根绝实际屏幕的初试坐标设置scene的position
	local pos = CCDirector:sharedDirector():getVisibleOrigin()
	
	self.scene = gamePresenter:addAndGetScene("LoginScene")
	self.scene:setPosition(pos.x, pos.y)
	
	local onEnterFun =  function(sceneObject, event, sceneName)
		self:onSceneEnter(sceneObject, event, sceneName)
	end
	
	local onExitFun =  function(sceneObject, event, sceneName)
		self:onSceneExit(sceneObject, event, sceneName)
	end
	
	self.scene:addSceneEventHandler(SceneEventEnter, onEnterFun)
	self.scene:addSceneEventHandler(SceneEventExit, onExitFun)
	
	local function ccTouchHandler(eventType, touchPoint)
--		CCLuaLog("touch")
		return 1
	end
	
	self.scene:registerScriptTouchHandler(ccTouchHandler, false, -128, false)
end

