require("common.baseclass")
require("common.GameEventHandler")
require("data.scene.scene")
require("data.npc.collect")
require("object.handup.HandupDef")
require"data.scene.scene"
require("data.npc.adornmentnpc")

CanNotFlyReason =
{
CastleWar = 1,
Other = 2,
}

--添加活动地图管理  临时优化离开活动按钮的逻辑
local mapActivityList = {
[1] = {[1] = "S217"}, --挖矿
[2] = {[1] = "S218",[2]="S219"},--怪物入侵
[3] = {[1] = "S070",[2]="S071"},--付费地宫
}



local function npcEnterMap(npcId, npcRefId, cellX, cellY)
	if not npcId or not npcRefId or not cellX or not cellY then
		return
	end
	local entityManager= GameWorld.Instance:getEntityManager()
	local npcObj = entityManager:createEntityObject(EntityType.EntityType_NPC, npcId, npcRefId)
	if npcObj then
		local npcModelId = entityManager:getNpcModelId(npcRefId)
		npcObj:setModuleId(npcModelId)
		npcObj:setRefId(npcRefId)
		npcObj:enterMap(cellX,cellY)
		npcObj:setCellXY(cellX,cellY)
		npcObj:setId(npcId)
	end
end

GameMapManager = GameMapManager or BaseClass()

function GameMapManager:__init()
	-- 传送区域
	self.transferOutList = {}
	-- npc列表
	self.currentNpcId = 1000
	self.mapRefId  = ""
	self.bFirstLoad = false
	self.sfMap = nil
	self.bLoadMap = false
	self.lastSceneId = nil
	--传送计时
	self.transferTickFuncId = -1
	--Todo 传送监听
	local hero_stop_event = function ()
		self:handleTransferOutCheck()
	end
	self.didSendSceneReady = false
	self.checkSceneReadyId = nil
	self.heroStopEvent = GlobalEventSystem:Bind(GameEvent.EVENT_HERO_STOP,hero_stop_event)
end

function GameMapManager:__delete()
	if self.heroStopEvent then
		GlobalEventSystem:UnBind(self.heroStopEvent)
		self.heroStopEvent = nil
	end
	self:cancelCheckSceneReadySchedule()
end

function GameMapManager:handleTransferOutCheck()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if self.mapRefId  ~= "" then
		local x,y = hero:getCellXY()
		local transferOutData = self:getTransferOutTable(self.mapRefId)
		self:checkRangeOfTransferPoint(x,y,transferOutData,hero)
	end
end

function GameMapManager:getCurrentMapRefId()
	return self.mapRefId
end

function GameMapManager:canEnter(hero,transferOut)
	if not hero or not transferOut then
		return false
	end
	local level = PropertyDictionary:get_level(hero:getPT())
	local conditionLevel = transferOut.level
	if level >= conditionLevel then
		return true
	else
		return false
	end
end

--判断是否在传送阵里面
function GameMapManager:checkRangeOfTransferPoint(x,y,transferOutData,hero)
	if not x or not y or not transferOutData then
		return
	end
	local inRangeData = nil
	local hasTransferPointInRange = false
	if transferOutData then
		for k,data in pairs(transferOutData) do
			if  self:inGridRange(x,y,data) then
				if self:canEnter(hero,data) then
					self:requestSceneSwitch(data.tranferOutId)
					hero:forceStop()
					break
				else
					self:showCannotEnterTips(data)
				end
			end
		end
	end
end

function GameMapManager:showCannotEnterTips(data)
	if not data then
		return
	end
	local tips = Config.Words[1200]
	local level = data.level
	local name = data.name
	tips = string.gsub (tips,"xx",level)
	tips = string.gsub (tips,"yy",name)
	UIManager.Instance:showSystemTips(tips)
end

function GameMapManager:initMap(targetScene)
	if not targetScene then
		return
	end
	local mapService = SFMapService:instance()
	
	mapService:getShareMap():attach(targetScene)
	self:setLoadHandler()
end

function GameMapManager:loadConfig()
	local mapService = SFMapService:instance()
	mapService:shutDown()
	mapService:startUp("config/config.csv")
end


function GameMapManager:isOnValidMapState()
	if self.lastSceneId ~= nil and self.lastSceneId ~= self.mapRefId then
		return false
	end
	return true
end

function GameMapManager:reloadLastValidMap()
	if self.lastSceneId ~= nil then
		self.loadMap(self.lastSceneId)
	end
end

function GameMapManager:setLoadHandler()
	local callBcak = function (per,currentFilename)
		if not self.didSendSceneReady then
			self:cancelCheckSceneReadySchedule()
			self:doSceneReady()
			self.didSendSceneReady = true
		end
	end
	local mapService = SFMapService:instance()
	mapService:setScriptHandler(callBcak)
end

function GameMapManager:doSceneReady()
	UIManager.Instance:hideLoadingSence()
	self:preLoadMonster()
	self:sendSceneReady()
	
	--更新所有任务NPC信息
	G_getQuestNPCStateMgr():setAllUpdateNpcQuestState()
	-- 同步场景信息
	GlobalEventSystem:Fire(GameEvent.EventHeroMovement)
	-- 发送场景切换消息
	GlobalEventSystem:Fire(GameEvent.EventSceneChanged, self:getMapRefId())
	--播放音乐
	local sceneData = GameData.Scene[self:getMapRefId()]
	if sceneData then
		local soundMgr = GameWorld.Instance:getSoundMgr()
		soundMgr:stopBackgroundMusic(true)
		local music = sceneData.property.musicId
		if 	music and string.len(music) > 0 then
			soundMgr:playBackgroundMusic("music/" .. music .. ".mp3")
		else
			soundMgr:setBackgroundMusicFile(nil)
		end
	end
	local sceneName = PropertyDictionary:get_name(GameData.Scene[self:getMapRefId()].property)
	local msg = {}
	table.insert(msg,{word = Config.Words[1204], color = Config.FontColor["ColorBlue2"]})
	table.insert(msg,{word = sceneName, color = Config.FontColor["ColorRed3"]})
	UIManager.Instance:showSystemTips(msg)
end

function GameMapManager:preLoadMonster()
	local sceneData = GameData.Scene[self:getMapRefId()]
	if self.sfMap then
		self.sfMap:setDefaultId(constMonsterDefaultId)
	end
	if sceneData then
		local monsterList = sceneData["monster"]
		local monstAdded = {}
		local data = nil
		local property = nil
		if monsterList then
			for k,v in pairs(monsterList) do
				--local mData = {}
				--[[				data = GameData.Monster[v.monsterRefId]
				if data then
					property = data.property
					local modelId = PropertyDictionary:get_modelId(property)
					if self.sfMap and modelId then
						for i=1,v.monsterRefreshCount do
							--self:readMonsterDataEntityData(reader,entityManager)
							self.sfMap:loadCharacterModel(modelId,eMapRenderDelMode_Monster)
						end
					end
				end--]]
				if monstAdded[v.monsterRefId] == nil then
					monstAdded[v.monsterRefId] = true
					data = GameData.Monster[v.monsterRefId]
					if data then
						property = data.property
						local modelId = PropertyDictionary:get_modelId(property)
						if self.sfMap and modelId then
							self.sfMap:loadCharacterModel(modelId,eMapRenderDelMode_Monster)
						end
					end
				end
				
			end
		end
	end
end

function GameMapManager:getMapRefId()
	return self.mapRefId
end

function GameMapManager:cancelCheckSceneReadySchedule()
	if self.checkSceneReadyId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.checkSceneReadyId)
		self.checkSceneReadyId = nil
	end
end

--todo 临时解决有时候地图加载回调不回调的问题
-- 5秒后强制回调并且标记
function GameMapManager:runCheckSceneReadySchedule()
	self:cancelCheckSceneReadySchedule()
	local check = function ()
		self:cancelCheckSceneReadySchedule()
		if self:isOnValidMapState() then		
			if not self.didSendSceneReady then
				self:doSceneReady()
				self.didSendSceneReady = true
			end
		else
			self:reloadLastValidMap()
		end			
	end
	self.checkSceneReadyId =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(check, 7, false)
end

function GameMapManager:handleMapClickEvent()
	local function onMapClick(touchEvent, eventType)
		
		touchEvent = tolua.cast(touchEvent, "SFTouchEvent")
		local cellX,cellY = touchEvent:getMapCellX(), touchEvent:getMapCellY()
		local mapX,mapY = touchEvent:getMapX(), touchEvent:getMapY()
		if (G_getHandupMgr():isHandup()) then --在地图上的任何点击事件，都将关闭挂机
			G_getHandupMgr():stop()
		end
		if eventType == eMapTouchEventBegin then
			
		elseif eventType == eMapTouchEventEnd then
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:cancel()
			
			--touch entity 判断
			local entityObject = self:getTouchEntity(mapX, mapY)
			if entityObject then
				GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT,entityObject:getEntityType(), entityObject:getId())
			else
				local hero = GameWorld.Instance:getEntityManager():getHero()
				hero:moveTo(cellX,cellY)
			end
		end
	end
	if self.sfMap == nil then
		self.sfMap = SFMapService:instance():getShareMap()
	end
	if self.bFirstLoad == false then
		self.sfMap:setScriptHandler(onMapClick)
		self.bFirstLoad = true
	end
end

function GameMapManager:loadMap(mapRefId)
	if not mapRefId then
		return
	end
	
	-- 停止天梯战斗的动画播放
	GlobalEventSystem:Fire(GameEvent.EventForceEndAreanAni)
	self.bLoadMap = true
	collectgarbage("collect")
	collectgarbage("collect")
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	hero:forceStop()
	
	-- id相同, 不需要重新loadmap
	if mapRefId ~= self.mapRefId then	
		self:setLoadHandler()
		local mapData = GameData.Scene[mapRefId]
		local kind = PropertyDictionary:get_kind(mapData)
		self:setCurrentMapKind(kind)
		
		-- TODO: 去掉这段逻辑，重复保存数据
		local mgr = GameWorld.Instance:getWorldBossActivityMgr()
		mgr:setCurrentSceneRefId(mapRefId)
		self.mapRefId = mapRefId
		
		self:handleMapClickEvent()
		self:mapLoadClear()
		
		self.didSendSceneReady = false
		
		local mapId = self:getMapId(mapRefId)
		self.sfMap:loadMap(mapId)
		
		self:runCheckSceneReadySchedule()
		
		GameWorld.Instance:getTextManager():enterMap()
		if hero then
			hero:enterMap()
		end
		-- 加载npcList
		self:loadNpcList(mapRefId)
		self:loadTransferOut(mapRefId)
		--self:loadAdornNPC()
		self:createSafeArea()
		GlobalEventSystem:Fire(GameEvent.EventHideSmallMapView)
		
		local manager = GameWorld.Instance:getGameInstanceManager()
		manager:setIsInstanceFinished(false)
	else
		UIManager.Instance:hideLoadingSence()
	end
	
	--mapService:getShareMap():OnMapDataLoaded()		
	GlobalEventSystem:Fire(GameEvent.EventClearMovePath)
	--移除原来选中的目标
	local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	if entityFocusManager then
		entityFocusManager:onFocusRemove()
	end
end

function GameMapManager:reset()
	if self.bLoadMap==true then
		local mapService = SFMapService:instance()
		mapService:getShareMap():dettach()
		self.bLoadMap = false
	end
	self.lastSceneId = nil
	self.mapRefId = ""
	self:cancelCheckSceneReadySchedule()
	--mapService:getShareMap():init()
end

function GameMapManager:loadTransferOut(mapRefId)
	if not mapRefId then
		return
	end
	local entityManager = GameWorld.Instance:getEntityManager()
	local tableInfo = self:getTransferOutTable(mapRefId)
	local idNum = 1020
	if tableInfo then
		for k,data in pairs(tableInfo) do
			local transferOut = entityManager:getEntityObject(EntityType.EntityType_Effect,idNum)
			transferOut:setActionId(0)
			transferOut:setModuleId(8000)
			transferOut:setResPath("res/scene/")
			transferOut:enterMap()
			local x = data.x+256/32
			local y = data.y+256/32
			transferOut:setCellXY(x,y)
			transferOut:addTitle(data.name,data.color)
			idNum = idNum +1
		end
	end
end

function GameMapManager:getAreaColor(kind)
	if kind == MapKind.city then
		return FCOLOR("ColorGreen1")
	elseif kind == MapKind.dangerousArea then
		return FCOLOR("ColorRed1")
	else
		return FCOLOR("ColorWhite2")
	end
end

local keyVertical = 1
local keyHorizotal  = 2
function GameMapManager:getPoints(list,startP,endP,dir)
	if not list or not startP or not endP or not dir then
		return
	end
	local distance = ccpDistance(startP,endP)
	local gaps = 10
	local time = distance / gaps -1
	local nextPoint = nil
	for i=1,time do
		if dir == keyHorizotal then
			nextPoint = ccp(startP.x+gaps*i,startP.y)
			table.insert(list,nextPoint)
		else
			nextPoint = ccp(startP.x,startP.y-gaps*i)
			table.insert(list,nextPoint)
		end
	end
end

--{ safeRegionId = 1, x = 75, y = 70, width = 82, height = 40,	},
--判断cellX和cellY是否在安全区
function GameMapManager:isInSafeArea(cellX, cellY)
	if not cellX and not cellY then
		return false
	end
	local mapRefId = self:getCurrentMapRefId()
	
	if not GameData.Scene[mapRefId] or not GameData.Scene[mapRefId]["safeRegion"] then
		return false
	end
	
	local data = GameData.Scene[mapRefId]["safeRegion"]	
	for k, v in pairs(data) do
		if (cellX >= v.x and cellX <= v.x + v.width)
			and (cellY >= v.y and cellY <= v.y + v.height) then
			return true
		end
	end
	return false
end


function GameMapManager:isInGameInstance()
	local mapRefId = self:getCurrentMapRefId()
	local data = GameData.Scene[mapRefId]
	if not data then
		return false
	end
	return (PropertyDictionary:get_kind(data) == 3)
end

function GameMapManager:isInGameAcitvity()
	local mapRefId = self:getCurrentMapRefId()
	local data = GameData.Scene[mapRefId]
	if not data then
		return false
	end
	return (PropertyDictionary:get_kind(data) == 2)
end

function GameMapManager:getSafeAreaPoints()
	local points = nil
	
	local mapRefId = self:getCurrentMapRefId()
	local data = GameData.Scene[mapRefId]["safeRegion"]
	if table.size(data) > 0 then
		data = data[1]
		points = {}
		local topLeftP = ccp(data.x,data.y+data.height)
		local topRightP = ccp(data.x+data.width,data.y+data.height)
		local bottomLeftP = ccp(data.x,data.y)
		local bottomRightP = ccp(data.x+data.width,data.y)
		table.insert(points,topLeftP)
		table.insert(points,topRightP)
		table.insert(points,bottomLeftP)
		table.insert(points,bottomRightP)
		self:getPoints(points,topLeftP,topRightP,keyHorizotal)
		self:getPoints(points,bottomLeftP,bottomRightP,keyHorizotal)
		self:getPoints(points,topLeftP,bottomLeftP,keyVertical)
		self:getPoints(points,topRightP,bottomRightP,keyVertical)
	end
	return points
end

function GameMapManager:createSafeArea()
	local points = self:getSafeAreaPoints()
	if points then
		local effectNum = 200000
		local entityManager = GameWorld.Instance:getEntityManager()
		for k,v in pairs(points) do
			local light = entityManager:getEntityObject(EntityType.EntityType_Safe_Region,effectNum)
			light:enterMap()
			light:setCellXY(v.x,v.y)
			effectNum = effectNum + 1
		end
	end
end

function GameMapManager:loadAdornNPC()
	local entityManager = GameWorld.Instance:getEntityManager()
	local mapRefId = self:getCurrentMapRefId()
	local list = self:getAdronNpcList(mapRefId)
	local num = 140000
	local adornNPC
	for k,v in pairs(list) do
		adornNPC = entityManager:getEntityObject(EntityType.EntityType_Effect,num)
		adornNPC:setActionId(0)
		adornNPC:setModuleId(v.model)
		adornNPC:setResPath("res/scene/")
		adornNPC:enterMap()
		adornNPC:setCellXY(v.x+16,v.y+16)
		num = num + 10
	end
end

function GameMapManager:getAdronNpcList(mapRefId)
	if not mapRefId then
		return {}
	end
	local outTable = GameData.Scene[mapRefId]["adornmentnpc"]
	local outPutData = 	{}
	for k,v in pairs(outTable) do
		local data = {}
		data.x = v.x
		data.y= v.y
		data.refid = v.npcRefId
		
		local targetData = GameData.Adornmentnpc[v.npcRefId]
		data.model = PropertyDictionary:get_modelId(targetData["property"])
		table.insert(outPutData,data)
	end
	return outPutData
end

--touch npc 判断
function GameMapManager:getTouchEntity(mapX, mapY)
	if not mapX or not mapY then
		return
	end
	local entityManager = GameWorld.Instance:getEntityManager()
	
	local playerList = entityManager:getPlayerList()
	local entityObject = self:getEntityFormList(playerList, mapX, mapY)
	
	if entityObject == nil then
		local npcList = entityManager:getNPCList()
		entityObject = self:getNpcFromList(npcList, mapX, mapY)
	end
	
	if entityObject == nil then
		local monsterList = entityManager:getMonsterList()
		entityObject = self:getEntityFormList(monsterList, mapX, mapY)
	end
	
	if entityObject == nil then
		local playerAvatarList = entityManager:getPlayerAvatarList()
		entityObject = self:getEntityFormList(playerAvatarList, mapX, mapY)
	end
	return entityObject
end

function GameMapManager:getNpcFromList(npcList, mapX, mapY)
	if not npcList or not mapX or not mapY then
		return
	end
	local npc = nil
	for k,v in pairs(npcList) do
		local rect = v.renderSprite:getBoundRect()
		local origin = rect.origin
		if v:isCollect() then
			local spriteSize = v.sprite:getContentSize()
			rect.size = spriteSize
			rect.origin = ccp(origin.x-spriteSize.width/2,origin.y-spriteSize.height/2)
		end
		local point = ccp(mapX,mapY)
		if rect:containsPoint(point) then
			npc = v
			break
		end
	end
	return npc
end

function GameMapManager:getEntityFormList(entityList, mapX, mapY)
	if not entityList or not mapX or not mapY then
		return
	end
	local entityObject = nil
	for k,v in pairs(entityList) do
		-- 忽略火墙
		if v:getRefId() ~= "monster_skill_1" and v.renderSprite then
			local rect = v.renderSprite:getBoundRect()
			local size = rect.size
			if size.width <20 and size.height < 20 then
				rect.size = CCSizeMake(50,50)
			end
			local point = ccp(mapX,mapY)
			if rect:containsPoint(point) then
				entityObject = v
				break
			end
		end
	end
	
	return entityObject
end

--判断是否在传送阵里面
function GameMapManager:inRange(x,y,data)
	if not x or not y or not data then
		return
	end
	local rect = CCRectMake(data.x,data.y,data.width,data.height)
	local touchPoint = ccp(x,y)
	return rect:containsPoint(touchPoint)
end

function GameMapManager:inGridRange(x,y,data)
	if not x or not y or not data then
		return
	end
	local rect = CCRectMake(data.x+135/16 - 4,data.y+199/16,data.width + 4, data.height)
	local rect2 = CCRectMake(x-2,y-2,5,5)
	return rect:intersectsRect(rect2)
end

--场景跳转
function GameMapManager:requestSceneSwitch(tranferOutId)
	if not tranferOutId then
		return
	end
	local function sendMsg()
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Switch)
		StreamDataAdapter:WriteInt(writer,tranferOutId)
		simulator:sendTcpActionEventInLua(writer)
	end
	
	self:checkResPatch(sendMsg)
end

--npc场景跳转
function GameMapManager:requestNpcSceneSwitch(npcRefId,sceneId,portId)
	if not npcRefId or not sceneId or not portId then
		return
	end
	local function sendMsg()
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Npc_Transfer)
		writer:WriteString(npcRefId)
		writer:WriteString(sceneId)
		writer:WriteInt(portId)
		simulator:sendTcpActionEventInLua(writer)
	end
	
	if self:hasResource() then
		sendMsg()
	else
		self:checkResPatch(sendMsg)
	end
end

function GameMapManager:requestTransfer(tranferId, cellX, cellY,ttype)
	if not tranferId or not cellX or not cellY or not ttype then
		return
	end
	local function sendMsg()
		--local hero = GameWorld.Instance:getEntityManager():getHero()
		--hero:moveStop()--eg:如果在传送阵使用飞鞋，会有moveStop回调中把角色入传当前送阵中的问题
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Transfer)
		writer:WriteChar(ttype)
		StreamDataAdapter:WriteStr(writer,tranferId)
		writer:WriteInt(cellX)
		writer:WriteInt(cellY)
		simulator:sendTcpActionEventInLua(writer)
	end
	if self:hasResource() then
		sendMsg()
	else
		self:checkResPatch(sendMsg)
	end
	G_getHandupMgr():stop(false)
	G_getHero():forceStop()
	local autoPath = GameWorld.Instance:getAutoPathManager()
	autoPath:cancel()
end

function GameMapManager:checkResPatch(finishCallback)
	if SFLoginManager:getInstance():getPlatform() == "win32" then
		if finishCallback then
			finishCallback()
		end
		return
	else
		if self:hasResource() then
			if ResManager.Instance:needPatch() and not DownloadManager.Instance:isDownload() then
				-- 合包
				local patchUrlList = ResManager.Instance:getPatchUrlList()
				local patchList = {}
				for k,v in pairs(patchUrlList) do
					if string.find(v.name, "base") == nil and string.find(v.name, "extend") == nil then
						table.insert(patchList, v.name)
					end
				end
				
				local function patchCallback()
					local manager =UIManager.Instance
					manager:hideUI("ResourcesUpdateView")
					
					if finishCallback then
						finishCallback()
					end
				end
				
				-- 开始合包
				GlobalEventSystem:Fire(GameEvent.EventPatch, patchList, patchCallback)
			elseif finishCallback then
				finishCallback()
			end
		elseif DownloadManager.Instance:isDownload() then
			-- 正在下载, 提示用户
			UIManager.Instance:showSystemTips(Config.Words[342])
		else
			-- 提示是否要开始下载扩展包
			local downloadfunc = function ()
				ResManager.Instance:downloadExtend(true,DownloadKey.extendAndPatch)
			end
			ResManager.Instance:showDownloadMessage(Config.Words[341],downloadfunc)
		end
	end
end

function GameMapManager:hasResource()
	local level = PropertyDictionary:get_level(GameWorld.Instance:getEntityManager():getHero():getPT())
	return ResManager.Instance:hasLevelRes(level)
end

--拿到地图加载id
function GameMapManager:getMapId(mapRefId)
	if not mapRefId then
		return
	end
	local mapData  = GameData.Scene[mapRefId]
	if mapData then
		return mapData["mapId"]
	else
		return nil
	end
end

function GameMapManager:getMapName(refId)
	if not refId then
		return ""
	end
	local mapData  = GameData.Scene[refId]
	if mapData then
		return PropertyDictionary:get_name(mapData["property"])
	else
		return ""
	end
end

-- 获取传送点数据
function GameMapManager:getTransferOutTable(mapRefId)
	if not  mapRefId then
		return {}
	end
	local outTable = GameData.Scene[mapRefId]["tranferOut"]
	local outPutData = 	{}
	for k,v in pairs(outTable) do
		local data = {}
		data.x = v.x
		data.y= v.y
		data.width = v.width
		data.height = v.height
		data.tranferOutId = v.tranferOutId
		local targetMap = v.targetSceneRefId
		targetData = GameData.Scene[targetMap]
		local property = targetData["property"]
		data.level = PropertyDictionary:get_openLevel(property)
		local kind = PropertyDictionary:get_kind(targetData)
		data.color = self:getAreaColor(kind)
		data.name = PropertyDictionary:get_name(property)
		table.insert(outPutData,data)
	end
	return outPutData
end

-- 获取安全区数据
function GameMapManager:getSafeRegion(mapRefId)
	if not mapRefId then
		return
	end
	if GameData.Scene[mapRefId]["safeRegion"] then
		return GameData.Scene[mapRefId]["safeRegion"]
	else
		return nil
	end
end

-- 阻挡格和地图坐标的转换
function GameMapManager:cellToMap(cellXX, cellYY)
	if not cellXX or not cellYY then
		return 0,0
	end
	local sfPoint = SFMap:coodCell2Map(cellXX, cellYY)
	if not sfPoint then
		return 0,0
	end
	return sfPoint:getX(), sfPoint:getY()
end

function GameMapManager:mapToCell(mapX, mapY)
	if not mapX or not mapY then
		return 0,0
	end
	local sfPoint = SFMap:coodMap2Cell(mapX, mapY)
	if not sfPoint then
		return 0,0
	end
	return sfPoint:getX(), sfPoint:getY()
end

-- AOI格子和地图坐标的转换
function GameMapManager:aoiCellToMap(cellX, cellY)
	if not cellX or not cellY then
		return 0,0
	end
	local sfPoint = SFMap:coodCell2Map(cellX*const_aoiCellSize+1, cellY*const_aoiCellSize+1)
	if not sfPoint then
		return 0,0
	end
	return sfPoint:getX(), sfPoint:getY()
end

function GameMapManager:mapToAoiCell(mapX, mapY)
	if not mapX or not mapY then
		return 0,0
	end
	local size = const_mapCellSize * const_aoiCellSize
	return math.ceil(mapX/size), math.ceil(mapY/size)
end

-- AOI格子和阻挡格子的转换
function GameMapManager:convertToAoiCell(cellX, cellY)
	if not cellX or not cellY then
		return 0,0
	end
	local aoiCellX = math.ceil((cellX-cellX % const_aoiCellSize)/const_aoiCellSize)
	local aoiCellY = math.ceil((cellY-cellY % const_aoiCellSize)/const_aoiCellSize)
	
	return aoiCellX*const_aoiCellSize+1, aoiCellY*const_aoiCellSize+1
end

function GameMapManager:isInAoiCenter(cellX, cellY)
	if not cellX or not cellY then
		return false
	end
	local aoiCellX
	local aoiCellY
	aoiCellX, aoiCellY = self:convertToAoiCell(cellX, cellY)
	return (cellX == aoiCellX and cellY == aoiCellY)
end

function GameMapManager:setViewCenter(mapX,mapY)
	if not mapX or not mapY then
		return
	end
	self.sfMap:setViewCenter(mapX,mapY)
end

function GameMapManager:loadNpcList(mapRefId)
	if not mapRefId then
		return
	end
	local stess = GameData.Scene[mapRefId]
	if GameData.Scene[mapRefId] ~= nil and GameData.Scene[mapRefId]["npc"] ~= nil then
		local npcData = GameData.Scene[mapRefId]["npc"]
		for i,v in pairs(npcData) do
			
			if string.find(v["npcRefId"],"collect") == nil then
				npcEnterMap(self.currentNpcId, v["npcRefId"], v["x"], v["y"])
				self.currentNpcId = self.currentNpcId+1
			end
		end
	end
end

function GameMapManager:sendSceneReady()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Ready)
	simulator:sendTcpActionEventInLua(writer)
end

-- 跳转地图的清理函数
function GameMapManager:mapLoadClear()
	self.transferOutList = {}
	self.currentNpcId = 1000
	
	GameWorld.Instance:getEntityManager():clearAll()
	GameWorld.Instance:getAnimatePlayManager():removeAll()
end

function GameMapManager:setCurrentMapKind(kind)
	self.currentmapKind = kind
end

function GameMapManager:getCurrentMapKind()
	return self.currentmapKind
end

-- 地图晃动
function GameMapManager:shakeMap()
	local sfMap = SFMapService:instance():getShareMap()
	
	if sfMap then
		local renderScene = sfMap:getRenderScene()
		local actionArray = CCArray:create()
		actionArray:addObject(CCMoveBy:create(0.05, ccp(-2, 2)))
		actionArray:addObject(CCMoveBy:create(0.05, ccp(2, -2)))
		
		local shakeAction = CCSequence:create(actionArray)
		renderScene:runAction(shakeAction)
	end
end

--判断是否可以使用飞鞋

function GameMapManager:checkCanUseFlyShoes(bShowTips)
	local isCastleTime = G_getCastleWarMgr():getIsInCastleWarTime()
	if isCastleTime then
		local mapRefId = self:getCurrentMapRefId()
		if mapRefId == "S012" or mapRefId == "S009" then --攻城期间，不能在皇宫或龙城使用飞鞋
			if bShowTips then
				UIManager.Instance:showSystemTips(Config.Words[18009])
			end
			return false, CanNotFlyReason.CastleWar
		end
	end
	
	local bagMgr = G_getBagMgr()
	local vipMgr = GameWorld.Instance:getVipManager()
	local vipLevel = vipMgr:getVipLevel()
	if bagMgr:hasItem("item_feixie") or vipLevel>0 then
		return true
	else
		return false, CanNotFlyReason.Other
	end
end

function GameMapManager:handleMapKindState()
	GlobalEventSystem:Fire(GameEvent.EventLeaveButtonStateChange,true)
	local msg = {}
	table.insert(msg,{word = Config.Words[15010], color = Config.FontColor["ColorWhite1"]})
	UIManager.Instance:showSystemTips(msg)
end

function GameMapManager:setLastSceneId(sceneId)
	self.lastSceneId = sceneId
end

function GameMapManager:getMapActivityType(mapRefId)
	for k,v in pairs(mapActivityList) do
		for j,mapId in pairs(v) do
			if mapId == mapRefId then
				return k
			end
		end
	end
end

