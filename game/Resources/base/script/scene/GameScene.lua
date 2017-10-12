require ("common.BaseScene")

GameScene = GameScene or BaseClass(BaseScene)

function GameScene:__init()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local gamePresenter = simulator:getGamePresenter()
	--根绝实际屏幕的初试坐标设置scene的position
	local pos = CCDirector:sharedDirector():getVisibleOrigin()
	
	self.scene = gamePresenter:addAndGetScene("GameScene")
	self.scene:setPosition(pos.x, pos.y)
		
	function onSceneEnter()
		self:onSceneEnter()
	end
	
	function onSceneExit()
		self.onSceneExit()
	end
	
	self.scene:addSceneEventHandler(SceneEventEnter, onSceneEnter)
	self.scene:addSceneEventHandler(SceneEventExit, onSceneExit)
	
	local function ccTouchHandler(eventType, x,y)
		local sfMap = SFMapService:instance():getShareMap()
		--local touchPoint = touch:getLocationInView()
		local worldTouchPoint
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		if x then
			if type(x)  == "table"then
				worldTouchPoint = self.scene:convertToWorldSpace(ccp(x[1], visibleSize.height-x[2]))
			else
				worldTouchPoint = self.scene:convertToWorldSpace(ccp(x,visibleSize.height-y))
			end
		end
		if eventType == "began" then
			sfMap:injectTouchBegin(worldTouchPoint.x, worldTouchPoint.y)
		elseif eventType == "ended" then
			sfMap:injectTouchEnd(worldTouchPoint.x, worldTouchPoint.y)
		elseif eventType == "cancelled" then
			sfMap:injectTouchEnd(worldTouchPoint.x, worldTouchPoint.y)
		end
		return 1
	end
	
	self.scene:registerScriptTouchHandler(ccTouchHandler, false, -50, false)
end

function GameScene:onSceneEnter()
	local uiManager = UIManager.Instance
	if uiManager:getGameRootNode():getParent() == nil then
		self.scene:addUILayer(uiManager:getGameRootNode())
		self.scene:addUILayer(uiManager:getUIRootNode())
		self.scene:addUILayer(uiManager:getDialogRootNode())
	end	
	-- init map
	local mapManager = GameWorld.Instance:getMapManager()
	mapManager:initMap(self.scene)
end

function GameScene:onSceneExit()
	local uiManager = UIManager.Instance
	uiManager:clear(true)
end