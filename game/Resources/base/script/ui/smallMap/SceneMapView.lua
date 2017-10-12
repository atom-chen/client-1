require("common.baseclass")
require"data.scene.scene"
require"object.npc.NpcDef"
SceneMapView = SceneMapView or BaseClass()
local mapSize = CCSizeMake(520,433)
local viewSize = CCSizeMake(535,445)
local CurMap_TAG = 100
function  SceneMapView:__init()
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(mapSize)
	self.rootNode:retain()
	
	self.background = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),viewSize)
	self.rootNode:addChild(self.background)
	VisibleRect:relativePosition(self.background,self.rootNode,LAYOUT_CENTER)
	
	self.mapLayer = CCLayer:create()
	
	self.rootNode:addChild(self.mapLayer)
	
	self.npcLayer = CCLayer:create()
	self.npcLayer:setContentSize(mapSize)
	self.rootNode:addChild(self.npcLayer)	
	
	self.monsterLayer = CCLayer:create()
	self.rootNode:addChild(self.monsterLayer)	
	
	self.handupAreaLayer = CCLayer:create()
	self.handupAreaLayer:setContentSize(mapSize)
	self.rootNode:addChild(self.handupAreaLayer)
	VisibleRect:relativePosition(self.handupAreaLayer,self.rootNode,LAYOUT_CENTER)
		
	self.safeAreaLayer = CCLayer:create()
	self.safeAreaLayer:setContentSize(mapSize)
	self.rootNode:addChild(self.safeAreaLayer)
	VisibleRect:relativePosition(self.safeAreaLayer,self.rootNode,LAYOUT_CENTER)
	
	self.teammateLayer = CCLayer:create()
	self.rootNode:addChild(self.teammateLayer)
	self.teammateLayer:setContentSize(mapSize)	
	
	self.heroNode = createSpriteWithFrameName(RES("map_role.png"))
	self.heroNode:setAnchorPoint(ccp(0.5,0))

	self.rootNode:addChild(self.heroNode)
	self.mapWidth = 0
	self.mapHeight = 0
	self.contentSize = mapSize
		
end

function SceneMapView:remove()
	self.rootNode:removeFromParentAndCleanup(true)
end

function SceneMapView:createTitleView()
	local gameMapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = gameMapManager:getCurrentMapRefId()
	if self.tilteNode == nil then
		self.tilteNode = CCNode:create()
		local mapName = gameMapManager:getMapName(currentMapRefId)
		local background = createScale9SpriteWithFrameName(RES("forge_task_left_line.png"))
		background:setContentSize(CCSizeMake(368,30))
		self.tilteNode:addChild(background)
		self.tilteNode:setContentSize(background:getContentSize())
		VisibleRect:relativePosition(background,self.tilteNode,LAYOUT_CENTER)
		self.tilteLabel = createLabelWithStringFontSizeColorAndDimension(mapName,Config.fontName.fontName1,FSIZE("Size3"),FCOLOR("ColorYellow2"))
		VisibleRect:relativePosition(self.tilteLabel,self.tilteNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(10,0))
		self.tilteNode:addChild(self.tilteLabel)
		self.rootNode:addChild(self.tilteNode)
		VisibleRect:relativePosition(self.tilteNode,self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE)
	else
		self:updateTilte()
	end		
end

function SceneMapView:updateTilte()
	if self.tilteLabel then
		local gameMapManager = GameWorld.Instance:getMapManager()
		local currentMapRefId = gameMapManager:getCurrentMapRefId()
		local mapName = gameMapManager:getMapName(currentMapRefId)
		self.tilteLabel:setString(mapName)
		VisibleRect:relativePosition(self.tilteLabel,self.tilteNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(10,0))
	end
end

function SceneMapView:initSize(size)
	
end

function SceneMapView:getRootNode()
	return self.rootNode
end

function SceneMapView:onEnter()
	local teamMgr = G_getHero():getTeamMgr()	
	if teamMgr:getTeammateNumber() > 0 then
		teamMgr:setNeedGetPosition(true)
		teamMgr:requestTeamMemberDetails()	
	end
	
	self:updateHeroPosition()	
end

function SceneMapView:onExit()
	self.teammateLayer:removeAllChildrenWithCleanup(true)
end

function SceneMapView:releaseMap()
	self.mapLayer:removeChildByTag(CurMap_TAG,true)
end

function SceneMapView:showWithSceneId(sceneId)
	if sceneId == nil then
		local mapManager = GameWorld.Instance:getMapManager()
		local currentMapRefId = mapManager:getCurrentMapRefId()
		sceneId = currentMapRefId
	end
	
	local sceneData = GameData.Scene[sceneId]
	self.mapLayer:removeAllChildrenWithCleanup(true)
	self:showMap(sceneData,sceneId)
	self:showNpc()
	--self:showTeammate()
	self:showMonster()
	self:showBestHandupArea()
	self:showSafeArea()
	self:showMovePath()
	self:createTitleView()
end
--黄金挂机区
function SceneMapView:showBestHandupArea()
	self.handupAreaLayer:removeAllChildrenWithCleanup(true)
	self.areaBatchNode = nil
	self.areaBatchNode = {}
	local mapManager = GameWorld.Instance:getSmallMapManager()
	local handupAreaData = mapManager:getHandupAreaData()	
	local manager = GameWorld.Instance:getMapManager()
	if handupAreaData then	
		for areaType,areaData in pairs(handupAreaData) do
			local iconName = areaData.Icon
			local iconColor = areaData.color
			local areaName = areaData.name
			local sprite =  createSpriteWithFrameName(RES(iconName))
			self.areaBatchNode[areaType] = CCSpriteBatchNode:createWithTexture(sprite:getTexture(),30)
			self.handupAreaLayer:addChild(self.areaBatchNode[areaType],30)		
			local nameTitlePoint = areaData.nameTitlePoint
			if nameTitlePoint then
				local mapX,mapY = manager:cellToMap(nameTitlePoint.x,nameTitlePoint.y)
				local x,y = self:toSmallMapXY(mapX,mapY)
				local areaNameLb = createLabelWithStringFontSizeColorAndDimension(areaName,"Arial",FSIZE("Size3"),iconColor)
				self.handupAreaLayer:addChild(areaNameLb,30)
				areaNameLb:setPosition(x,mapSize.height-y+sprite:getContentSize().height+10)
			end	
			for i,v in ipairs(areaData.pointList) do			
				local mapX,mapY = manager:cellToMap(v.x,v.y)
				local x,y = self:toSmallMapXY(mapX,mapY)							
				local pathNode = createSpriteWithFrameName(RES(iconName))
				self.areaBatchNode[areaType]:addChild(pathNode,10)
				pathNode:setPosition(x,mapSize.height-y)				
			end
		end
	end
end
function SceneMapView:showSafeArea()
	self.safeAreaLayer:removeAllChildrenWithCleanup(true)
	self.safeBatchNode = nil
	self.safeBatchNode = {}
	local mapManager = GameWorld.Instance:getMapManager()
	local points = mapManager:getSafeAreaPoints()
	if points then
		local sprite =  CCSprite:create("res/scene/safe_area.png")		
		sprite:setScale(0.3)
		self.safeBatchNode = CCSpriteBatchNode:createWithTexture(sprite:getTexture(),30)
		self.handupAreaLayer:addChild(self.safeBatchNode,30)		
		for i,v in ipairs(points) do
			local mapX,mapY = mapManager:cellToMap(v.x,v.y)
			local x,y = self:toSmallMapXY(mapX,mapY)							
			local pathNode = CCSprite:create("res/scene/safe_area.png")				
			pathNode:setScale(0.3)
			self.safeBatchNode:addChild(pathNode,10)
			pathNode:setPosition(x,mapSize.height-y)	
		end
	end
end

function SceneMapView:showNpc()
	self.npcLayer:removeAllChildrenWithCleanup(true)
	local mapManager = GameWorld.Instance:getSmallMapManager()
	local npcData = mapManager:getNpcData()
	for k,npc in pairs(npcData) do
		local npcNode = createSpriteWithFrameName(RES("map_npc.png"))
		self.npcLayer:addChild(npcNode,10)
		local sightLable =  createLabelWithStringFontSizeColorAndDimension(G_GetNpcSignName(npc.refId),"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
		npcNode:addChild(sightLable)
		VisibleRect:relativePosition(sightLable, npcNode, LAYOUT_CENTER,ccp(-10,0))
		
		local manager = GameWorld.Instance:getMapManager()
		local mapX,mapY = manager:cellToMap(npc.x,npc.y)
		local x,y = self:toSmallMapXY(mapX,mapY)
		npcNode:setPosition(x,mapSize.height-y)
	end
	local transferData = mapManager:getTransferOutData()
	for k,transfer in pairs(transferData) do
		local transferNode = createSpriteWithFrameName(RES("map_transfer.png"))
		self.npcLayer:addChild(transferNode,10)
		local manager = GameWorld.Instance:getMapManager()
		local mapX,mapY = manager:cellToMap(transfer.x,transfer.y)
		local x,y = self:toSmallMapXY(mapX,mapY)
		transferNode:setPosition(x,mapSize.height-y)
	end
end

function SceneMapView:showTeammate()
	self.teammateLayer:removeAllChildrenWithCleanup(true)
	local mapMgr = GameWorld.Instance:getMapManager()
	local teamMgr = G_getHero():getTeamMgr()
	local curSceneId = mapMgr:getCurrentMapRefId()
	local heroId = G_getHero():getId()
	local teamList = teamMgr:getTeam()
	for k,teammate in pairs(teamList) do
		local scene = teammate:getSceneId()
		local playerId = teammate:getTeamMemberId()
		if scene and scene == curSceneId and playerId and playerId ~= heroId  and teammate:getTeamMemberStatus() ~= 2 then
			local tNode = createSpriteWithFrameName(RES("map_teammate.png"))	
			
--[[			self.heroNode = createSpriteWithFrameName(RES("map_role.png"))
									
			local tNode = createSpriteWithFrameName(RES("map_teammate.png"))	--]]						
			local posX = teammate:getPositionX()
			local posY = teammate:getPositionY()
			--local playerObj = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player, playerId)
			if posX and posY then
				self.teammateLayer:addChild(tNode,10)
				tNode:setAnchorPoint(ccp(0.5, 0))
				local pX, pY = mapMgr:cellToMap(posX, posY)
				local mapX,mapY = self:toSmallMapXY(pX, pY)						
								
				tNode:setPosition(mapX, mapSize.height-mapY)	
			end					
		end			
	end
end

function SceneMapView:showMonster()
	self.monsterLayer:removeAllChildrenWithCleanup(true)
	local mapManager = GameWorld.Instance:getSmallMapManager()
	local mData = mapManager:getMonsterData()
	for k,m in pairs(mData) do
		local mNode = nil
		if m.quality == 3 then		--boss头像
			local bossIconId = mapManager:getBossIconIdByRefId(m.refId)
			if bossIconId then
				mNode = createSpriteWithFrameName(RES(bossIconId..".png"))
				if not mNode then
					mNode = createSpriteWithFrameName(RES("map_monster.png"))
				else
					mNode:setScale(0.4)
				end
			else	--没有对应头像的情况
				mNode = createSpriteWithFrameName(RES("map_monster.png"))
			end
		else
			mNode = createSpriteWithFrameName(RES("map_monster.png"))
		end

		--local label = createLabelWithStringFontSizeColorAndDimension(m.name,Config.fontName.fontName1,FSIZE("Size1"),FCOLOR("ColorOrange1"))
		self.monsterLayer:addChild(mNode,10)
		local manager = GameWorld.Instance:getMapManager()
		local mapX,mapY = manager:cellToMap(m.x,m.y)
		local x,y = self:toSmallMapXY(mapX,mapY)
		mNode:setPosition(x,mapSize.height-y)
		--mNode:addChild(label)
	end
end


function SceneMapView:showMap(sceneData,sceneId)
	if sceneData then
		local sceneProperty = sceneData["property"]
		self.mapWidth = PropertyDictionary:get_width(sceneProperty)
		self.mapHeight = PropertyDictionary:get_height(sceneProperty)
		self.scaleX = self.contentSize.width/self.mapWidth
		self.scaleY = self.contentSize.height/ self.mapHeight
		local smallMapId = sceneData.mapId
		local mapSprite = CCSprite:create("thumbnailMap/"..smallMapId..".jpg")	
		if mapSprite then
			mapSprite:setTag(CurMap_TAG)
			self.mapLayer:addChild(mapSprite)
			VisibleRect:relativePosition(mapSprite,self.mapLayer,LAYOUT_CENTER)
		end
		self:updateHeroPosition()
		VisibleRect:relativePosition(self.mapLayer,self.rootNode,LAYOUT_CENTER)
	end
end

function SceneMapView:showMovePath()
	local pathData = self.hero:getShowingMovePath()
	self:removeMovePath()	
	if table.size(pathData) > 0 then	
		if self.batchNode == nil then
			local sprite = createSpriteWithFrameName(RES("map_pathNode.png"))			
			self.batchNode = CCSpriteBatchNode:createWithTexture(sprite:getTexture(),30)
			self.rootNode:addChild(self.batchNode)	
		end
				
		local index = 0
		self.pointList = {}
		local pathList = self:paserPathData(pathData)
		for k,m in pairs(pathList) do
			local manager = GameWorld.Instance:getMapManager()
			local mapX,mapY = manager:cellToMap(m.x,m.y)
			local x,y = self:toSmallMapXY(mapX,mapY)
			local pathNode = createSpriteWithFrameName(RES("map_pathNode.png"))
			self.batchNode:addChild(pathNode)					
			pathNode:setTag(k)
			data = {["x"]=x, ["y"]=y}
			self.pointList[k] = {key = k , Data = data}
			pathNode:setPosition(x,mapSize.height-y)
		end
	end
end



function SceneMapView:updateHeroPosition()
	if self.hero then
		local x,y = self.hero:getMapXY()
		local mapX,mapY = self:toSmallMapXY(x,y)
		self:updateMovePath(mapX,mapY)
		self.heroNode:setPosition(mapX,mapSize.height-mapY)
	end
end

function SceneMapView:handleTouchEvent(eventType,x, y)
	if eventType == "ended" then
		self:removeMovePath()
		local point = self.rootNode:convertToNodeSpace(ccp(x,y))
		local rect = CCRectMake(0,0,self.contentSize.width,self.contentSize.height)
		if rect:containsPoint(point) then
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:cancel()
			G_getHandupMgr():stop()
			local cellX,cellY = self:toCellXY(x,y)
			autoPath:moveToPosition(cellX,cellY)
		end
	end
end

function SceneMapView:toSmallMapXY(x,y)
	if not x or not y then
		return 0,0
	end
	return x*self.scaleX, y*self.scaleY
end

function SceneMapView:toCellXY(x,y)
	if not x or not y then
		return 0,0
	end
	local w = self.mapWidth/self.contentSize.width;
	local h = self.mapHeight/self.contentSize.height
	
	local pos =self.rootNode:convertToNodeSpace(ccp(x,y))
	local manager = GameWorld.Instance:getMapManager()
	local mapX,mapY = manager:mapToCell(pos.x*w, (self.contentSize.height-pos.y)*h)
	return mapX,mapY
end

function SceneMapView:updateMovePath(x,y)
	if not x or not y then
		return
	end
	if table.size(self.pointList) > 0 then
		for k,v in pairs(self.pointList) do
			local hx = v.Data.x
			local hy = v.Data.y
			local key = v.key
			if ccpDistance(ccp(x,y),ccp(hx,hy))<8 then
				self.batchNode:removeChildByTag(key,true)
				table.remove(self.pointList,k)
				return
			end
		end
	end
end

function SceneMapView:removeMovePath()
	if self.batchNode then
		self.batchNode:removeAllChildrenWithCleanup(true)
	end
end

function SceneMapView:paserPathData(pathData)
	local pathList = {}	
	for k,v in ipairs(pathData) do
		pathList[1] = v
	end
	return pathList
end

function SceneMapView:__delete()
	self.rootNode:release()
	self.rootNode = nil
end