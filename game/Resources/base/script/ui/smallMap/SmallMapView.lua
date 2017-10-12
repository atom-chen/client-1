require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.smallMap.CurrentMapView")
require("ui.smallMap.WorldMapView")
SmallMapView = SmallMapView or BaseClass(BaseUI)
local bgSize = CCSizeMake(831, 472)
local selectIndex = 1
local viewTage = {
	current = 1,
	world = 2,
}
function SmallMapView:__init()
	self.viewName = "SmallMapView"
	self:initFullScreen()
	--标题	
	local icon =createSpriteWithFrameName(RES("main_map.png"))		
	self:setFormImage(icon)	
	
	--标题文字	
	local skillTitleText = createSpriteWithFrameName(RES("word_map.png"))
	self:setFormTitle(skillTitleText, TitleAlign.Left)
	
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), bgSize)
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER)
	
	self.currentMapView= nil
	self.worldMapView = nil
	self.viewTable = {
		[2] = {create = CurrentMapView.New,viewName = "currentView",tag = viewTage.current,instance = nil,offsetX = 10,offsetY = -20 },
		[1] = {create = WorldMapView.New,viewName = "worldView",tag = viewTage.world,instance = nil ,offsetX = 0,offsetY = -10},
	}
	self.selectView = nil
	self:createTabView()
	selectIndex = 1
	self.tagView:setSelIndex(selectIndex-1)
	self.viewTable[1].instance = self.viewTable[1].create()
	self.viewTable[2].instance = self.viewTable[2].create()	
	self:addChild(self.viewTable[1].instance:getRootNode())		
	
	VisibleRect:relativePosition(self.viewTable[1].instance:getRootNode(),bg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(self.viewTable[1].offsetX,self.viewTable[1].offsetY))		
	self:addChild(self.viewTable[2].instance:getRootNode())	
	VisibleRect:relativePosition(self.viewTable[2].instance:getRootNode(),bg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(self.viewTable[2].offsetX,self.viewTable[2].offsetY))					
	self.viewTable[1].instance:getRootNode():setVisible(false)
	self.viewTable[2].instance:getRootNode():setVisible(false)
		
	self:showView(selectIndex)
end


function SmallMapView:showView(index)	
	if not index then
		return
	end
	if self.selectView then		
		self.selectView.instance:getRootNode():setVisible(false)
		self.selectView = self.viewTable[index]
		self.selectView.instance:update()
		self.selectView.instance:getRootNode():setVisible(true)
	else			
		self.selectView = self.viewTable[index]
		self.selectView.instance:getRootNode():setVisible(true)
	end
	if index ~= 1 then
		GlobalEventSystem:Fire(GameEvent.EventCloseWorldMapTipsView)
	end
end



function SmallMapView:updatePosition()
	if self.selectView.tag == viewTage.current then
		self.selectView.instance:updateHeroPosition()
	end
end

function SmallMapView:updateMovePath()
	if self.selectView.tag == viewTage.current then
		self.selectView.instance:removeMovePath()
		self.selectView.instance:showMovePath()
	end
end

function SmallMapView:showTeammate()
	if self.selectView.tag == viewTage.current then	
		self.selectView.instance:showTeammate()
	end
end

function SmallMapView:removeMovePath()
	if self.selectView.tag == viewTage.current then
		self.selectView.instance:removeMovePath()
	end	
end

function SmallMapView:createTabView()
	local createContent = {	
	Config.Words[901],
	Config.Words[900],
	}
	local btnArray = CCArray:create()
	for key,value in ipairs(createContent) do
		local button = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))		
		local label = createLabelWithStringFontSizeColorAndDimension(value, "Arial", FSIZE("Size2"), FCOLOR("ColorWhite1"),CCSizeMake(16,0))		
		button:setTitleString(label)
		btnArray:addObject(button)
		local onTabPress = function()
			self:showView(key)
		end
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)		
	end
	self.tagView = createTabView(btnArray, 10, tab_vertical)
	local contentNode = self:getContentNode()
	contentNode:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView,contentNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_OUTSIDE,ccp(5,-25))
end

function SmallMapView:__delete()
	if 	self.viewTable[1].instance then
		self.viewTable[1].instance:remove()
		self.viewTable[1].instance:DeleteMe()
		self.viewTable[1].instance= nil
	end
	if 	self.viewTable[2].instance then
		self.viewTable[2].instance:remove()
		self.viewTable[2].instance:DeleteMe()
		self.viewTable[2].instance= nil
	end			
end
function SmallMapView:onEnter()
	if not self.moveEventId then
		local updateHeroPositionFunc = function ()
			self:updatePosition()
		end
		self.moveEventId = GlobalEventSystem:Bind(GameEvent.EventHeroMovement,updateHeroPositionFunc)
	end
	self.showing = true	
	local gameMapManager = GameWorld.Instance:getMapManager()	
	local currentMap = gameMapManager:getCurrentMapRefId()
	if 	currentMap ~= self.currentMapRefId then
		local mapManager = GameWorld.Instance:getSmallMapManager()	
		mapManager:updateData()
		self.currentMapRefId = currentMap
	end	
	
	if self.selectView then
		self.selectView.instance:update()
		self.tagView:setSelIndex(1)
		self:showView(2)	
	end
	self.selectView.instance:onEnter()
end

function SmallMapView:onExit()
	if self.moveEventId then
		GlobalEventSystem:UnBind(self.moveEventId)
		self.moveEventId  = nil
	end
	self.showing = false	
	for k,v in pairs(self.viewTable) do
		if v.instance then
			v.instance:onExit()
		end
	end		
end

function SmallMapView:isShowing()
	return self.showing
end

function SmallMapView:updateCurrentMapView()
	if self.selectView.tag == viewTage.current then
		local mapManager = GameWorld.Instance:getSmallMapManager()
		mapManager:updateData()
		self.selectView.instance:update()
	end	
end

function SmallMapView:updateWordMapView()
	if self.selectView.tag == viewTage.world then	
		self.selectView.instance:update()
		
	end	
end

function SmallMapView:create()
	return SmallMapView.New()
end

function SmallMapView:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		if (G_getHandupMgr():isHandup()) then	
			G_getHandupMgr():stop()
		end	
		--终止任务进行
		G_getQuestLogicMgr():KillAllAction()
		
		return self:touchHandler(eventType, x, y)
	end
	
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.Control, true)
end

function SmallMapView:releaseMap()
	if self.viewTable[2] then
		 self.viewTable[2].instance:releaseMap()
	end
end

function SmallMapView:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent()  then
		
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			if self.selectView.tag == 1 then
				self.selectView.instance:handleTouchEvent(eventType, x, y)
			end			
			return 1
		else
			return 0
		end
	else
		return 0
	end
end
