require("common.baseclass")

WorldMapView = WorldMapView or BaseClass()
local viewSize = CCSizeMake(831,472)
local g_smallMapMgr = nil

function WorldMapView:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()
	self.wordMap = nil
	g_smallMapMgr = GameWorld.Instance:getSmallMapManager()
	--[[self.background = createScale9SpriteWithFrameNameAndSize(RES("mallCellBg.png"),CCSizeMake(960,640))
	self.rootNode:addChild(self.background)
	VisibleRect:relativePosition(self.background,self.rootNode,LAYOUT_CENTER)--]]
	self:createMap()
	self:createSceneButtons()
end

function WorldMapView:__delete()
	self.rootNode:release()
	
	if self.arrow then
		self.arrow:release()
		self.arrow = nil
	end
end

function WorldMapView:remove()
	self.rootNode:removeFromParentAndCleanup(true)	
end

function WorldMapView:getRootNode()
	return self.rootNode
end

function WorldMapView:onEnter()
	
end

function WorldMapView:onExit()
	GlobalEventSystem:Fire(GameEvent.EventCloseWorldMapTipsView)
end

function WorldMapView:update()
	self.rootNode:removeAllChildrenWithCleanup(true)
	self:createMap()
	self:createSceneButtons()
end

function WorldMapView:createMap()
	self.wordMap = createSpriteWithFileName("thumbnailMap/565/worldMap.pvr")
	if  self.wordMap then
		self.rootNode:addChild(self.wordMap)
		VisibleRect:relativePosition(self.wordMap,self.rootNode,LAYOUT_CENTER,ccp(0,9))
	end
end

function WorldMapView:getRefAndIcon(index)
	local refId,iconName = "",""
	if not index then
		return refId,iconName
	end
	
	refId = "S0"		
	if index<10  then
		refId = refId.."0"
	end
	refId = refId..index
	iconName = "map_"..refId..".png"
	return refId,iconName		
end

function WorldMapView:canEnter(mapRefId)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local level = PropertyDictionary:get_level(hero:getPT())	
	local conditionLevel = g_smallMapMgr:getConditionLevelBySceneId(mapRefId)
	if conditionLevel and level >= conditionLevel then
		return true
	end			
	return false
end

function WorldMapView:createSceneButtons()
	local scenePosition = {
		["S001"]  = {x=214 ,y = 108},
		["S002"]  = {x=308 ,y = 186},
		["S003"]  = {x=214 ,y = 230 },
		["S004"]  = {x=106 ,y = 260},
		["S005"]  = {x=148 ,y = 333},
		["S006"]  = {x=290 ,y = 410},
		["S007"]  = {x=355 ,y = 310},
		["S008"]  = {x=484 ,y = 354},
		["S009"]  = {x=588 ,y = 292},
		["S010"]  = {x=710 ,y = 370},
		["S011"]  = {x=695 ,y = 180},
	}
	local manager = UIManager.Instance
	local mapMgr = GameWorld.Instance:getMapManager()
	local curSceneId = mapMgr:getCurrentMapRefId()
	local sceneCount = 10	
	for i=1,sceneCount do
		if i ~= 6 then
			local refId,iconName = self:getRefAndIcon(i)
			local button = createButtonWithFramename(RES(iconName), RES(iconName))		
			local fontColor = FCOLOR("ColorWhite1")	
			--local open = false	
			
			if self:canEnter(refId) then
				button = createButtonWithFramename(RES(iconName), RES(iconName))
				local onTabPress = function()
					--[[local autoPath = GameWorld.Instance:getAutoPathManager()
					autoPath:startFindTargetPaths(refId)
					G_getHandupMgr():stop()	--]]
					if not manager:isShowing("WorldMapTipsView") then
						local layout = E_ShowOption.eRight									
						if i >= 8 then
							layout = E_ShowOption.eLeft												
						end
						GlobalEventSystem:Fire(GameEvent.EventOpenWorldMapTipsView, layout, refId)
					end						
				end
				button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)	
				
				--open = true					
				if curSceneId == refId then
					self:addArrow(button)
				end
			else
				button = createButtonWithFramename(RES(iconName))
				UIControl:SpriteSetGray(button)	
				fontColor = FCOLOR("ColorRed1")
				local butFun = function()
					UIManager.Instance:showSystemTips(Config.Words[904])					
				end
				button:addTargetWithActionForControlEvents(butFun, CCControlEventTouchDown)	
			end	
			self.rootNode:addChild(button)
			local position = scenePosition[refId]
			if position then
				button:setPosition(ccp(position.x,position.y))	
			end	
			
			local conditionLevel = g_smallMapMgr:getConditionLevelBySceneId(refId)
			if conditionLevel then
				local text = conditionLevel .. Config.Words[903]
				local textLebel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3"), fontColor)
				button:addChild(textLebel)
				--[[if open then--]]
					VisibleRect:relativePosition(textLebel, button, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(5, 0))
				--[[else
					VisibleRect:relativePosition(textLebel, button, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(5,10))
				end	--]]			
			end
		end				
	end
end	

function WorldMapView:addArrow(parent)
	
	local array = CCArray:create()
	local moveUp = CCMoveBy:create(0.4, ccp(0,10))
	local moveDown = CCMoveBy:create(0.4, ccp(0,-10))
	array:addObject(moveUp)
	array:addObject(moveDown)
	local seqAction = CCSequence:create(array)
	local forever = CCRepeatForever:create(seqAction)
	
	if not self.arrow then
		self.arrow = createSpriteWithFrameName(RES("map_arrow.png"))
		self.arrow:retain()		
	end
	
	if self.arrow:getParent() then
		self.arrow:removeFromParentAndCleanup(true)
	end
	
	self.arrow:runAction(forever)
	parent:addChild(self.arrow)
	VisibleRect:relativePosition(self.arrow, parent, LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE)
end	