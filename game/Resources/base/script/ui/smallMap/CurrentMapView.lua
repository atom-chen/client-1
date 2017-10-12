require("common.baseclass")
require("ui.smallMap.SceneMapView")
require("ui.smallMap.AutoPathListView")
CurrentMapView = CurrentMapView or BaseClass()

local viewSize = CCSizeMake(820,440)
function  CurrentMapView:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()		
	self:createSceneMapView()	
end

function CurrentMapView:createSceneMapView()
	self.sceneMapView = SceneMapView.New()	
	self.rootNode:addChild(self.sceneMapView:getRootNode())
	self.sceneMapView:showWithSceneId()
	VisibleRect:relativePosition(self.sceneMapView:getRootNode(),self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE)	
	self.autoPathListView = AutoPathListView.New()
	self.rootNode:addChild(self.autoPathListView:getRootNode())
	VisibleRect:relativePosition(self.autoPathListView:getRootNode(),self.sceneMapView:getRootNode(),LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(12,0))	
end

function CurrentMapView:remove()
	self.rootNode:removeFromParentAndCleanup(true)
end

function CurrentMapView:getRootNode()
	return self.rootNode
end

function CurrentMapView:onEnter()
	--self:update()
	self.sceneMapView:onEnter()
end

function CurrentMapView:onExit()
	self.sceneMapView:onExit()
end

function CurrentMapView:update()
	self.autoPathListView:updateView()
	self.sceneMapView:showWithSceneId()	
end

function CurrentMapView:showMovePath()
	self.sceneMapView:showMovePath()
end

function CurrentMapView:showTeammate()
	self.sceneMapView:showTeammate()
end

function CurrentMapView:removeMovePath()
	self.sceneMapView:removeMovePath()
end

function CurrentMapView:showWithSceneId(sceneId)
	self.sceneMapView:showWithSceneId(sceneId)
end

function CurrentMapView:updateHeroPosition()
	self.sceneMapView:updateHeroPosition()
end

function CurrentMapView:handleTouchEvent(eventType,x, y)
	self.sceneMapView:handleTouchEvent(eventType,x, y)	
end

function CurrentMapView:releaseMap()
	self.sceneMapView:releaseMap()
end

function CurrentMapView:__delete()
	self.rootNode:release()	
	self.rootNode = nil
	self.sceneMapView:DeleteMe()
	self.autoPathListView:DeleteMe()
end