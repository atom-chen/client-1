--[[
场景的基本接口
onEnter: 进入场景的通知
onExit:	离开场景的通知
]]--

SceneIdentify = {
	LoginScene = "LoginScene",
	GameScene = "GameScene"	
}

SceneEventEnter = 1
SceneEventExit = 2

BaseScene = BaseScene or BaseClass();

function BaseScene:__init()
	
end

function BaseScene:onEnter(sceneObject, event, sceneName)
	
end

function BaseScene:onExit(sceneObject, event, sceneName)

end