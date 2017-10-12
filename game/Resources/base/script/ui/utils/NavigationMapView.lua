require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.ClippingSprite")
require"data.scene.scene"
require ("object.team.TeamObject")

NavigationMapView = NavigationMapView or BaseClass()

local const_radius = 50
local const_mapSpriteTag = 10086
local const_updateInterval = 0.3
local const_mapRangeScale = 0.5

function NavigationMapView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(CCDirector:sharedDirector():getVisibleSize())
	self.rootNode:retain()	
	
	self.mapScaleX = nil
	self.mapScaleY = nil
	self.mapRealWidth = 0
	self.mapRealHeight = 0
	
	self:init()
	self:updateScene()
	self:updateHeroPos()	
	
	self.showingMonsters = {}
	self.showingTeammates = {}
	local onTimeout = function()
		self:onNavigationTimeOut()
	end
	self.schId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, const_updateInterval, false)
end

function NavigationMapView:onNavigationTimeOut()	
	if self.mapSprite then
		self:updateMonsters()
		self:updateTeammates()
		self:updateHeroPos()
	end
end

function NavigationMapView:__delete()	
	self.rootNode:release()
	self.heroArrow:release()
	self.navigationMap:DeleteMe()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schId)
	self.schId = nil	
	self.mapSprite = false
end

function NavigationMapView:onEnter()
end

function NavigationMapView:onExit()
end	

function NavigationMapView:init()
	self.navigationMap = ClippingSprite.New()
	self.navigationMap:drawCircle(const_radius)	
--	self.navigationMap:setInverted(true)
	self.rootNode:addChild(self.navigationMap:getRootNode())
	VisibleRect:relativePosition(self.navigationMap:getRootNode(), self.rootNode, LAYOUT_CENTER)	
	
	self.heroArrow = createSpriteWithFrameName(RES("common_upTriangle.png"))
	self.heroArrow:setZOrder(10)
	self.heroArrow:retain()
	self.heroArrow:setScale(0.6)	
end

function NavigationMapView:addMonster(obj)
	if self.mapSprite then
		local v = createSpriteWithFrameName(RES("monster_redLabel.png"))
		self.showingMonsters[obj:getId()] = {obj = obj, view = v}
		self.mapSprite:addChild(v)	
	end
end		

function NavigationMapView:addTeammate(teamObj)
	if self.mapSprite then
		local teammate = createSpriteWithFrameName(RES("small_map_teammate.png"))
		self.showingTeammates[teamObj:getId()] = {obj = teamObj, view = teammate}
		self.mapSprite:addChild(teammate)
	end
end

function NavigationMapView:removeMonster(obj)
	if self.mapSprite then
		local monster = self.showingMonsters[obj:getId()]
		if monster then
			if monster.view and self.mapSprite then
				self.mapSprite:removeChild(monster.view, true)	
				monster.view = nil		
			end
			self.showingMonsters[obj:getId()] = nil
		end
	end
end	

function NavigationMapView:removeTeammate(teamObj)
	if self.mapSprite then
		local teammate = self.showingTeammates[teamObj:getId()]
		if teammate then
			if teammate.view and self.mapSprite then
				self.mapSprite:removeChild(teammate.view, true)	
				teammate.view = nil		
			end
			self.showingTeammates[teamObj:getId()] = nil
		end
	end
end

function NavigationMapView:updateMonsters()
	if not self.mapSprite then
		return
	end
	local size = self.mapSprite:getContentSize()
	local index = 1
	for k, v in pairs(self.showingMonsters) do	
		local cellX, cellY = GameWorld.Instance:getMapManager():cellToMap(v.obj:getCellXY())
		local smallCellX
		local smallCellY	
		smallCellX, smallCellY = self:toSmallXY(cellX, cellY)
		if v.view then			
			v.view:setPosition(smallCellX, size.height - smallCellY)		
			index = index + 1
			if index >= 25 then
				return
			end
		end
	end
end

function NavigationMapView:updateTeammates()
	if not self.mapSprite then
		return
	end
	local size = self.mapSprite:getContentSize()
	local index = 1
	local teamMgr = G_getHero():getTeamMgr()
	for k, v in pairs(self.showingTeammates) do	
		--local teamObj = teamMgr:getTeamMemberById(v.obj:getId())		
		--local posX = teamObj:getPositionX()
		--local posY = teamObj:getPositionY()
		--if posX and posY then
			local cellX, cellY = GameWorld.Instance:getMapManager():cellToMap(v.obj:getCellXY())
			local smallCellX
			local smallCellY	
			smallCellX, smallCellY = self:toSmallXY(cellX, cellY)
			if v.view then			
				v.view:setPosition(smallCellX, size.height - smallCellY)		
				index = index + 1
				if index >= 25 then
					return
				end
			end
		--end			
	end
end

function NavigationMapView:removeAllMonster()
	if type(self.showingMonsters) == "table" then
		for k, v in pairs(self.showingMonsters) do
			if v.view then
				v.view:removeFromParentAndCleanup(true)
				v.view = nil
			end
		end
		self.showingMonsters = {}
	end
end

function NavigationMapView:removeAllTeammate()
	if type(self.showingTeammates) == "table" then
		for k, v in pairs(self.showingTeammates) do
			if v.view then
				v.view:removeFromParentAndCleanup(true)
				v.view = nil
			end
		end
		self.showingTeammates = {}
	end
end

function NavigationMapView:getRootNode()
	return self.rootNode
end

function NavigationMapView:updateHeroPos()
	if not self.mapSprite then
		return
	end
	local cellX, cellY = GameWorld.Instance:getMapManager():cellToMap(G_getHero():getCellXY())
	local smallCellX
	local smallCellY	
	smallCellX, smallCellY = self:toSmallXY(cellX, cellY)
	local size = self.mapSprite:getContentSize()
	
	self.heroArrow:setPosition(smallCellX, size.height - smallCellY)		
	
	local radius = const_radius / const_mapRangeScale
	if smallCellX < radius then
		smallCellX = radius
	elseif  size.width - smallCellX < radius then
		smallCellX = size.width - radius
	end
	if smallCellY < radius then
		smallCellY = radius
	elseif  size.height - smallCellY < radius then
		smallCellY = size.height - radius
	end
		
	local offsetX = (size.width / 2 - smallCellX) * const_mapRangeScale
	local offsetY = (size.height / 2 - smallCellY) * const_mapRangeScale
		
	self.navigationMap:moveDrawNodeTo(ccp(-offsetX, offsetY))
	VisibleRect:relativePosition(self.navigationMap:getRootNode(), self.rootNode, LAYOUT_CENTER, ccp(offsetX, -offsetY))
	self:updateHeroDir()
end

function NavigationMapView:toSmallXY(x, y)
	return x * self.mapScaleX, y * self.mapScaleY
end

function NavigationMapView:updateScene()
	self:removeAllMonster()
	self:removeAllTeammate()
	self.heroArrow:removeFromParentAndCleanup(true)
	self.navigationMap:getRootNode():removeChildByTag(const_mapSpriteTag, true)
	
	local currentScene = GameWorld.Instance:getMapManager():getCurrentMapRefId()
	local sceneData = GameData.Scene[currentScene]
	local mapId = sceneData.mapId	
	self.mapSprite = CCSprite:create("thumbnailMap/"..mapId..".jpg")		
	if not self.mapSprite then	
		return
	end
	
	self.mapSprite:setScale(const_mapRangeScale)
	self.mapSprite:addChild(self.heroArrow)	
	self.navigationMap:getRootNode():addChild(self.mapSprite)		

	self.mapRealWidth = PropertyDictionary:get_width(sceneData.property) 
	self.mapRealHeight = PropertyDictionary:get_height(sceneData.property)	 
	self.mapScaleX = self.mapSprite:getContentSize().width / self.mapRealWidth
	self.mapScaleY = self.mapSprite:getContentSize().height / self.mapRealHeight
end

function NavigationMapView:updateHeroDir()
	local angle = G_getHero():getAngle()
	if angle then
		self.heroArrow:setRotation(angle * 45 + 180)
	end
end