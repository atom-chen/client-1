require("common.baseclass")
require("config.words")
require("data.npc.npc")
require"data.scene.scene"
require"data.monster.monster"
require"data.scene.scene"
require "data.worldBoss.worldBoss"
SmallMapManager = SmallMapManager or BaseClass()
local E_handupArea = {
expArea = 1,
goldArea = 2,
}
function SmallMapManager:__init()
	self.npcDataList  = {}
	self.transferOutDataList = {}
	self.monsterData = {}
	self.currentMapRefId = nil
end

function SmallMapManager:clear()
	
end

function SmallMapManager:getNpcData()
	return self.npcDataList
end

function SmallMapManager:currentMapRef()
	return self.currentMapRefId
end

function SmallMapManager:updateNpcData()
	local mapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = mapManager:getCurrentMapRefId()
	
	local sceneData = GameData.Scene[currentMapRefId]
	self.npcDataList = {}
	if sceneData then
		
		local npcData = sceneData["npc"]
		if npcData then
			for k,v in pairs(npcData) do
				local npcData = GameData.Npc[v.npcRefId]
				if npcData then
					local npc = {}
					npc["refId"] = npcData.refId
					npc["name"] = PropertyDictionary:get_name(npcData.property)
					local autoPath = GameWorld.Instance:getAutoPathManager()
					local x,y = autoPath:findNpcXY(npcData.refId,currentMapRefId)
					npc["color"] = FCOLOR("ColorWhite2")
					npc["x"] = x
					npc["y"] = y
					npc["isRoot"] = false
					table.insert(self.npcDataList,npc)
				end
			end
		end
	end
end

function SmallMapManager:getTransferOutData()
	return self.transferOutDataList
end

function SmallMapManager:updateTransferOutData()
	local mapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = mapManager:getCurrentMapRefId()
	
	local sceneData = GameData.Scene[currentMapRefId]
	self.transferOutDataList = {}
	
	if sceneData then
		local transferData = sceneData["tranferOut"]
		if transferData then
			for k,v in pairs(transferData) do
				local tranferOutData = {}
				targetData = GameData.Scene[v.targetSceneRefId]
				if targetData then
					tranferOutData["name"] = Config.Words[7000].."("..PropertyDictionary:get_name(targetData.property)..")"
				end
				local inX,inY = self:getTargetMapTransferInXY(currentMapRefId,targetData)
				tranferOutData["color"] = FCOLOR("ColorWhite2")
				tranferOutData["x"] = v.x+256/32
				tranferOutData["y"] = v.y+256/32+6
				tranferOutData["isRoot"] = false
				tranferOutData["isTransfer"] = true
				table.insert(self.transferOutDataList,tranferOutData)
			end
		end
	end
end

function SmallMapManager:getTargetMapTransferInXY(fromRef,toData)
	local transferData = toData["tranferOut"]
	local targetData = nil
	for k,v in pairs(transferData) do
		if v.targetSceneRefId == fromRef then
			targetData = v
			break
		end
	end
	if targetData then
		local transferInData = toData["tranferIn"]
		for k,v in pairs(transferInData) do
			if v.tranferInId == targetData.tranferOutId then
				return v.x,v.y
			end
		end
	end
end

function SmallMapManager:updateMonsterData()
	local mapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = mapManager:getCurrentMapRefId()
	
	local sceneData = GameData.Scene[currentMapRefId]
	self.monsterData = nil
	self.monsterData = {}
	if sceneData then
		local monsterList = sceneData["monster"]
		local monstAdded = {}
		if monsterList then
			for k,v in pairs(monsterList) do
				-- 类型为7的怪物不显示在小地图上
				if self:getMonsterKind(v.monsterRefId) ~= 7 then
					local mData = {}
					if monstAdded[v.monsterRefId] == nil then
						monstAdded[v.monsterRefId] = true
						
						targetData = GameData.Monster[v.monsterRefId]
						if targetData then
							local level = PropertyDictionary:get_level(targetData.property)
							local name  = PropertyDictionary:get_name(targetData.property)
							local quality = PropertyDictionary:get_quality(targetData.property)
							mData["name"] = name.." lv"..level
							mData["quality"] = quality
							mData["refId"] = v.monsterRefId
						end
						mData["color"] = FCOLOR("ColorWhite2")
						mData["x"] = v.x
						mData["y"] = v.y
						mData["isRoot"] = false
						table.insert(self.monsterData,mData)
					end
				end
				
			end
		end
	end
end

function SmallMapManager:getMonsterKind(refId)
	if refId and GameData.Monster[refId] and GameData.Monster[refId].property and GameData.Monster[refId].property.kind then
		return GameData.Monster[refId].property.kind
	else
		return 0
	end
end

function SmallMapManager:getBossIconIdByRefId(refId)
	for k ,v in pairs(GameData.WorldBoss) do
		if v.property.monsterRefId == refId then
			return v.property.iconId
		end
	end
end

function SmallMapManager:getMonsterData()
	return self.monsterData
end

function SmallMapManager:updateData()
	local mapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = mapManager:getCurrentMapRefId()
	if self.currentMapRefId ~= currentMapRefId then
		self:updateNpcData()
		self:updateTransferOutData()
		self:updateMonsterData()
		self:updateHandupAreaData()
	end
end

function SmallMapManager:createShowData(showName,list)
	local node = {
	name = showName,
	data = {},
	color = FCOLOR("ColorYellow4"),
	isOpen = false,
	isRoot = true,
	}
	for k,v in pairs(list) do
		table.insert(node.data,v)
	end
	return node
end

function SmallMapManager:margeData()
	local data = {}
	if #self.npcDataList > 0 then
		local npcNode = self:createShowData(Config.Words[7002],self.npcDataList)
		table.insert(data,npcNode)
	end
	
	if #self.monsterData > 0 then
		local monsterNode = self:createShowData(Config.Words[7001],self.monsterData)
		table.insert(data,monsterNode)
	end
	
	if #self.transferOutDataList > 0 then
		local transferOutNode = self:createShowData(Config.Words[7000],self.transferOutDataList)
		table.insert(data,transferOutNode)
	end
	return data
end

function SmallMapManager:updateHandupAreaData()
	local mapManager = GameWorld.Instance:getMapManager()
	local currentMapRefId = mapManager:getCurrentMapRefId()
	
	local sceneData = GameData.Scene[currentMapRefId]
	self.handupAreaData = nil
	self.handupAreaData = {}
	if sceneData["bestHandup"] then
		local areaDataList = sceneData["bestHandup"]
		for areaType,areaData in pairs(areaDataList) do
			local data = {}
			local pointList = {}
			if areaType == E_handupArea.expArea then
				data.Icon = "map_expHandup.png"
				data.color = FCOLOR("ColorBlue1")
				data.name = Config.Words[7004]
			elseif areaType == E_handupArea.goldArea then
				data.Icon = "map_goldHandup.png"
				data.color = FCOLOR("ColorYellow1")
				data.name = Config.Words[7003]
			end
			local startX,startY = areaData.x,areaData.y
			local endX = startX+areaData.width
			local endY = startY+areaData.height
			local nameTitlePoint = {}
			nameTitlePoint.x = startX+areaData.width/2
			nameTitlePoint.y = startY
			data.nameTitlePoint = nameTitlePoint
			for i=startX,endX,areaData.width/6 do
				local point = {}
				point.x = i
				point.y = startY
				table.insert(pointList,point)
			end
			for i=startX,endX,areaData.width/6 do
				local point = {}
				point.x = i
				point.y = endY
				table.insert(pointList,point)
			end
			for j=startY,endY,areaData.height/6 do
				local point = {}
				point.x = startX
				point.y = j
				table.insert(pointList,point)
			end
			for j=startY,endY,areaData.height/6 do
				local point = {}
				point.x = endX
				point.y = j
				table.insert(pointList,point)
			end
			data.pointList = pointList
			self.handupAreaData[areaType] = data
		end
	end
end

function SmallMapManager:getHandupAreaData()
	return self.handupAreaData
end

function SmallMapManager:getConditionLevelBySceneId(mapRefId)
	local mapData = GameData.Scene[mapRefId]
	if mapData then
		local conditionLevel = PropertyDictionary:get_openLevel(mapData["property"])
		return conditionLevel
	end
end

function SmallMapManager:getTranstionBySceneId(sceneId)
	local sceneData = GameData.Scene[sceneId]
	if sceneData then
		local transferData = sceneData["tranferOut"]
		return transferData
	end
end

function SmallMapManager:getDiGongTransitionBySceneId(sceneId)
	local transferData = self:getTranstionBySceneId(sceneId)
	if not transferData then
		return
	end
	
	local transferList = {}
	for k,v in pairs(transferData) do
		local tranferSceneId = v.targetSceneRefId
		if tranferSceneId then
			local kind = GameData.Scene[tranferSceneId].kind
			if kind and (kind==1  or kind==2 ) then
				table.insert(transferList, tranferSceneId)
			end
		end
	end
	
	return transferList
end

function SmallMapManager:getNameBySceneId(sceneId)
	if not sceneId then
		return
	end
	
	local sceneData = GameData.Scene[sceneId]
	if sceneData then
		local property = sceneData.property
		if property then
			return property.name
		end
	end
end

function SmallMapManager:getTransferInPointBySceneId(sceneId)
	local sceneData = GameData.Scene[sceneId]
	if sceneData then
		local transferData = sceneData["tranferIn"]
		if table.size(transferData) > 0 then
			return transferData[1]
		end
	end
end