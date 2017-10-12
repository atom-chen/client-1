require("common.baseclass")
require("scene.LoginScene")
require("scene.GameScene")

SceneManager = SceneManager or BaseClass();
function SceneManager:__init()
	SceneManager.Instance = self
end

function SceneManager:getCurrentGameScene()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local gamePresenter = simulator:getGamePresenter()
	return gamePresenter
end

function SceneManager:initLoginScene()
	self.logiScene = LoginScene.New()				
end

function SceneManager:initGameScene()
	self.GameScene = GameScene.New()	
end	

function SceneManager:switchTo(sceneName)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local gamePresenter = simulator:getGamePresenter()
	gamePresenter:switchTo(sceneName)
	self.currentSceneName = sceneName
end	

function SceneManager:getCurrentGameSceneName()
	return self.currentSceneName
end

function SceneManager:isInLoginScene()
	return SceneIdentify.LoginScene == self.currentSceneName
end