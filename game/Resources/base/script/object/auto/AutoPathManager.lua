require("common.baseclass")
require"data.scene.scene"
AutoPathManager = AutoPathManager or BaseClass()

AutoPathState = {
stateStop = "stop",
stateRun = "run",
stateCancel = "cancel"
}

local const_autoMountUpDis = 20

function AutoPathManager:__init()
	self.autoPathState = AutoPathState.stateStop
	self.mapManager =  GameWorld.Instance:getMapManager()
	self.targetMapRefId = nil
	self.targetRefId = nil
	self.targetPoint = nil
	self.autoPoint = nil
	--self.pathList = {}
	self.walkPaths = {}
	self.targetMapPaths = {}
	self.callBackFuncList = {}
	self.count = 0
	local scene_switch_func = function ()
		self:switchScene()
	end
	
	local heroStop = function ()
		self:handleHeroStop()
	end
	
	local speedUpdate = function ()
		self:reRun()
	end
	self.swichEvent = GlobalEventSystem:Bind(GameEvent.EventGameSceneReady,scene_switch_func)
	self.heroStopEvent =	GlobalEventSystem:Bind(GameEvent.EVENT_HERO_STOP,heroStop)
	self.heroMountUpEvent = GlobalEventSystem:Bind(GameEvent.EventHeroSpeedUpdate,speedUpdate)
	self:createMapPaths(self.walkPaths)
end

function AutoPathManager:__delete()
	if self.swichEvent then
		GlobalEventSystem:UnBind(self.swichEvent)
		self.swichEvent = nil
	end
	
	if self.heroStopEvent then
		GlobalEventSystem:UnBind(self.heroStopEvent)
		self.heroStopEvent = nil
	end
	
	if self.heroMountUpEvent then
		GlobalEventSystem:UnBind(self.heroMountUpEvent)
		self.heroMountUpEvent = nil
	end
end

function AutoPathManager:clear()
	for i,v in pairs(self.callBackFuncList) do
		self:unRegistCallBack(i)
	end
	self.count = 0	
	--self.pathList = {}
end

function AutoPathManager:reRun()
	if self.targetPoint then	
		local target = self.targetPoint		
		G_getHero():clearTargetXY()		
		self:moveToPosition(target.x, target.y)
	end
end

function AutoPathManager:handleHeroStop()
	if self:isRunning() then
		self:runAllCallBack()
		self:stop()		
	end
	self.targetPoint = nil	
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)
end
--判断是否在自动寻路状态



function AutoPathManager:isRunning()
	if self.autoPathState == AutoPathState.stateRun  then
		return true
	else
		return false
	end
end

function AutoPathManager:hasCallBackFunc()
	if table.size(self.callBackFuncList) then
		return true
	else
		return false
	end
end

function AutoPathManager:runAllCallBack()
	if self:hasCallBackFunc() then
		for k,func in pairs(self.callBackFuncList) do
			func(self.autoPathState,k)
		end
	end
end

function AutoPathManager:moveToWithCallBack(x,y,mapRefId)
	self:cancel()
	local currentMapRefId = self.mapManager:getCurrentMapRefId()
	if mapRefId == nil then
		mapRefId = currentMapRefId
	end
	if mapRefId and currentMapRefId ~= mapRefId then
		self.targetMapRefId = mapRefId
		self.autoPoint = ccp(x,y)
		--todo跨场景寻路	
		local currentMapRefId = self.mapManager:getCurrentMapRefId()
		local hasPath = self:startFindTargetPaths(mapRefId,currentMapRefId)
		if not hasPath then
			--self:requestTeleport(mapRefId,entityRefId)
		end
		return true
	else
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local heroX,heroY = hero:getCellXY()
		if self:isInBigGrid(heroX,heroY,x,y) then
			self.autoPathState = AutoPathState.stateRun
			self:runAllCallBack()
			self:stop()
			self.autoPoint = nil
			return false
		else
			self.autoPathState = AutoPathState.stateRun
			self.autoPoint = nil
			return self:moveToPosition(x,y)
		end
	end
end

function AutoPathManager:moveToPosition(x,y)
	local ret	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if hero then
		ret = hero:moveTo(x,y)
		local length = hero:getMoveLength()
		if length > const_autoMountUpDis then
			GameWorld.Instance:getMountManager():callMountUp()--上马
		end
		self.targetPoint = ccp(x,y)
		if ret then
			GlobalEventSystem:Fire(GameEvent.EventUpdateHeroActiveState, E_HeroActiveState.AutoFindRoad)
		end
	end
	return ret
end

function AutoPathManager:registCallBack(func)
	self.count = self.count +1
	self.callBackFuncList[self.count] = func
	return self.count
end

function AutoPathManager:unRegistCallBack(index)
	self.callBackFuncList[index] = nil
end

function AutoPathManager:setAutoPathState(state)
	self.autoPathState = state
end

function AutoPathManager:nameToNode(map,name)
	if  not map[name] then
		map[name] = {name = name,adj = {}}
	end
	return map[name]
end

function AutoPathManager:stop()
	self.autoPathState = AutoPathState.stateStop
end

function AutoPathManager:startFindTargetPaths(endMap,startMap)
	self.targetMapPaths = {}
	if not startMap then
		startMap = self.mapManager:getCurrentMapRefId()
	end
	local from = self.walkPaths[startMap]
	local to = self.walkPaths[endMap]
	if from ~= nil and to ~= nil then
		self:findPath(from,to,self.targetMapPaths)
		self.targetMapRefId = endMap
	else
		return false
	end
	if table.size(self.targetMapPaths) >1 then
		--删除第一个	
		table.remove(self.targetMapPaths,1)
		local nextId = self.targetMapPaths[1]
		table.remove(self.targetMapPaths,1)
		self:findTransferout(nextId.name)
		return true
	end
	return false
end
--todo

function AutoPathManager:createMapPaths(pathList)
		
	for k,v in pairs(GameData.Scene) do
		local mapName = k
		local tranferOuts = self:getTransferOutList(mapName)
		for k,v in pairs(tranferOuts) do
			local from = self:nameToNode(pathList,mapName)
			local to = self:nameToNode(pathList,v.targetSceneRefId)
			from.adj[to] = true
		end
	end
end

function AutoPathManager:findPath(current,to,path,visited)
	path  = path or {}
	visited = visited or {}
	if visited[current] then
		return nil
	end
	visited[current] = true
	path[#path +1] = current
	if current == to then
		return path
	end
	--
	for node in pairs(current.adj) do
		local p = self:findPath(node,to,path,visited)
		if p then
			--[[self.pathList = {}
			for k,v in ipairs(p) do
				table.insert(self.pathList, k, v.name)
			end--]]
			return p
		end
	end
	path[#path] = nil
end

function AutoPathManager:getTransferInList(mapRefId)	
	local mapData = GameData.Scene[mapRefId]
	if mapData then
		local tranferIn = mapData["tranferIn"]
		return tranferIn
	end
end

function AutoPathManager:getTransferOutList(mapRefId)	
	local mapData = GameData.Scene[mapRefId]
	if mapData then
		local tranferOuts = mapData["tranferOut"]
		return tranferOuts
	end
end

function AutoPathManager:findTransferout(mapRefId)
	local currentMapRefId = self.mapManager:getCurrentMapRefId()
	local tranferOuts = self:getTransferOutList(currentMapRefId)
	local x,y,width,height = self:findTransferPoint(tranferOuts,mapRefId)
	if x ~= nil and y ~= nil then
		self.autoPathState = AutoPathState.stateRun
		self:moveToPosition(x+256/32,y+256/32+6)
	end
end

function AutoPathManager:find(entityRefId,mapRefId,bLimitTrans)
	local currentMapRefId = self.mapManager:getCurrentMapRefId()
	if mapRefId and currentMapRefId ~= mapRefId then
		self.targetMapRefId = mapRefId
		self.targetRefId = entityRefId
		--todo跨场景寻路	
		local currentMapRefId = self.mapManager:getCurrentMapRefId()
		local hasPath = self:startFindTargetPaths(mapRefId,currentMapRefId)		
		if (not hasPath) and not bLimitTrans then
			self:requestTeleport(mapRefId,entityRefId)
		end
	else
		local mapX,mapY = self:findXY(entityRefId,currentMapRefId)
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local heroX,heroY = hero:getCellXY()
		--hero:moveStop()
		if mapX ~= nil and mapY ~= nil then
			if self:isInBigGrid(heroX,heroY,mapX,mapY) then
				self.autoPathState = AutoPathState.stateRun
				self:runAllCallBack()
				self.targetRefId = nil
				self:stop()
			else
				self.autoPathState = AutoPathState.stateRun
				self:moveToPosition(mapX,mapY)
				self.targetRefId = nil
			end
		end
		
	end
end

function AutoPathManager:isInBigGrid(x1,y1,x2,y2)
	local xx,yy = self.mapManager:convertToAoiCell(x1,y1)
	local xxx,yyy = self.mapManager:convertToAoiCell(x2,y2)
	if xx == xxx and yy == yyy then
		return true
	else
		return false
	end
end

function AutoPathManager:clearPath()
	self.targetMapPaths ={}
end

function AutoPathManager:findXY(entityRefId,mapRefId)
	local mapX,mapY = nil,nil
	if string.find(entityRefId,"npc") ~= nil then
		mapX,mapY = self:findNpcXY(entityRefId,mapRefId)
		mapX,mapY = self:findGridPoint(mapX,mapY)
	elseif string.find(entityRefId,"monster") ~= nil then
		mapX,mapY = self:findMonsterXY(entityRefId,mapRefId)
	end
	return mapX,mapY
end

function AutoPathManager:findGridPoint(mapX,mapY)
	if mapX == nil and mapY == nil then
		return nil,nil
	end
	local x,y = mapX-5,mapY
	local tempX,tempY
	for i=0,2 do	
		tempX = x+ i*5
		tempY = y

		-- NPC的坐标有可能不在AOI中心内, 这里要取AOI中心格子来判定
		local centerX, centerY = GameWorld.Instance:getMapManager():convertToAoiCell(tempX, tempY)
		if not SpriteMove:IsBlock(centerX,centerY) and tempX~=mapX then			
			return tempX,tempY
		end				
	end
	return mapX,mapY
end

function AutoPathManager:findTransferIn(sceneId,locationId)
	local mapData = GameData.Scene[sceneId]
	local x,y = nil,nil
	if mapData then
		local inList = mapData["tranferIn"]
		for k,v in pairs(inList) do
			if locationId == v.tranferInId then
				x = v.x
				y = v.y
				break
			end
		end
	end
	return x,y
end

function AutoPathManager:findNpcXY(npcRefId,mapRefId)
	
	local mapData = GameData.Scene[mapRefId]
	if mapData then
		local npcData = mapData["npc"]
		if npcData then
			local npc = nil
			for k,v in pairs(npcData) do
				if v["npcRefId"] == npcRefId then
					npc = v
					break
				end
			end
			if npc then
				return npc["x"],npc["y"]
			end
		end
	end
end

function AutoPathManager:requestTeleport(mapRefId,entityRefId)
	if self:checkFlyShoes() then 
		local mapX, mapY = self:findXY(entityRefId,mapRefId)		
		if mapX ~= nil and mapY ~= nil then
			self.mapManager:requestTransfer(mapRefId,mapX,mapY,1)
		end		
	end
end

function AutoPathManager:requestTeleportWithXY(mapRefId,x,y)
	if self:checkFlyShoes() then 	
		if x ~= nil and y ~= nil then
			self.mapManager:requestTransfer(mapRefId,x,y,1)
		end		
	end
end

function AutoPathManager:checkFlyShoes()
	if self.mapManager:checkCanUseFlyShoes() then
		return true
	else
		UIManager.Instance:showSystemTips(Config.Words[13021])
		return false
	end
end

function AutoPathManager:requestTeleportTransferIn(sceneId,locationId)
	local x,y = self:findTransferIn(sceneId,locationId)
	x = x+256/32
	y = y+256/32
	self:requestTeleportWithXY(sceneId,x,y)
end

function AutoPathManager:findMonsterXY(monsterRefId,mapRefId)
	
	local mapData = GameData.Scene[mapRefId]
	if mapData then
		local monsterData = mapData["monster"]
		if monsterData then
			local monsterList = {}
			local count = 0
			for k,v in pairs(monsterData) do
				if v["monsterRefId"] == monsterRefId then
					table.insert(monsterList,v)
					count = count+1
				end
			end
			if count > 0 then
				local random = math.random(1,count)
				local monster = monsterList[random]
				local w = monster["width"]
				local h = monster["height"]
				local x,y = monster["x"],monster["y"]
				local xx = x
				local yy = y
				return xx,yy
			end
		end
	end
end

function AutoPathManager:findTransferPoint(tranferOuts,targetMapRefId)
	if tranferOuts then
		for k,transferout in pairs(tranferOuts) do
			local targetMap = transferout["targetSceneRefId"]
			if targetMap == targetMapRefId then
				return transferout["x"],transferout["y"],transferout["width"],transferout["height"]
			end
		end
	end
end

function AutoPathManager:cancel()
	if self:isRunning() then
		self:setAutoPathState(AutoPathState.stateCancel)
		self:runAllCallBack()
		self:clearPath()
		self.targetRefId = nil
		self.targetMapRefId = nil
		self:stop()
		self.autoPoint = nil
	end
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)	
	self.targetPoint = nil	
end

function AutoPathManager:switchScene()
	-- 场景加载

	if table.size(self.targetMapPaths) > 0 then
		self.autoPathState = AutoPathState.stateRun
		local nextId = self.targetMapPaths[1]
		table.remove(self.targetMapPaths,1)
		self:findTransferout(nextId.name)
	else
		if self.targetRefId then
			self:find(self.targetRefId)
		end
		if self.autoPoint then
			self:moveToWithCallBack(self.autoPoint.x,self.autoPoint.y)
		end
	end
end

function AutoPathManager:getTargetMapId()
	return self.targetMapRefId
end

function AutoPathManager:getTargetPoint()
	return self.targetPoint
end

function AutoPathManager:getAutoPoint()
	return self.autoPoint
end

function AutoPathManager:getTargetRefId()
	return self.targetRefId
end

--[[function AutoPathManager:getPathList()
	return self.pathList
end--]]
