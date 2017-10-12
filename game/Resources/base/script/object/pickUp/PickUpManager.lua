require("common.baseclass")

PickUpManager = PickUpManager or BaseClass()

--Juchao@20140221: 定义拾取范围
local const_pickupRange = 3	 --拾取周围 const_pickupRange * const_pickupRange个aoi格子的掉落物
local const_defaultRePickupInterval = 0

function PickUpManager:__init()
	self.pickConfigFilterFuncList = 
	{	
		[PickupConfigType.equipLevel] 	= "undefined",
		[PickupConfigType.quality] 		= "undefined",
		[PickupConfigType.profession] 	= "undefined",
	}

	PickUpManager.Instance = self	
	local onHeroStop = function ()
		self:handleHeroStop()
	end		
	self.heroStopEvent = GlobalEventSystem:Bind(GameEvent.EVENT_HERO_STOP, onHeroStop)	
	
	self.rePickupInterval = const_defaultRePickupInterval; --对一个掉落的重复拾取间隔时间
	self:buildPickupConfigFilterFuncList()		
end

function PickUpManager:__delete()
	if self.heroStopEvent then
		GlobalEventSystem:UnBind(self.heroStopEvent)
		self.heroStopEvent = nil
	end
end	

function PickUpManager:createFilterFunc(ttype)
	local func
	if ttype == PickupConfigType.equipLevel then	
		func = function(pickUpConfig, loot)	
			if not loot:isEquip() then
				return true
			end	
			local level = pickUpConfig.EquipLevel
			if level == Setting_EquipPickUp.Level_All then
				return true
			else
				return (loot:getEquipLevel() >= level)
			end
			return false
		end
	elseif ttype == PickupConfigType.quality then		
		func = function(pickUpConfig, loot)	
			if not loot:isEquip() then
				return true
			end
			local qualityList = pickUpConfig.EquipQualityList
			for k, v in pairs(qualityList) do
				if v == loot:getEquipQuality() then
					return true
				end
			end 
			return false
		end
	elseif ttype == PickupConfigType.profession then		
		func = function(pickUpConfig, loot)
			if not loot:isEquip() then
				return true
			end
			if loot:getProfessionId() == 0 then
				return true
			end
			local professionList = pickUpConfig.ProfessionList
			for k, v in pairs(professionList) do
				if (v == loot:getProfessionId()) then
					return true
				end
			end 					
			return false
		end			
	end
	return func
end	
	
--Juchao@20140221: 根据拾取配置，创建过滤函数
function PickUpManager:buildPickupConfigFilterFuncList()
	local pickUpConfig = GameWorld.Instance:getSettingMgr():readPickUpConfig()
	for k, v in pairs(self.pickConfigFilterFuncList) do
		self.pickConfigFilterFuncList[k] = self:createFilterFunc(k)
	end
end

function PickUpManager:handleHeroStop()
	local entityManager = GameWorld.Instance:getEntityManager()
	local cellXStart,cellYStart = entityManager:getHero():getCellXY()
	self:pickLootAroundXY(cellXStart, cellYStart )
end

--Juchao@20140221: 拾取以(originX, originY)为原点，周围 const_pickupRange * const_pickupRange 范围的掉落
function PickUpManager:pickLootAroundXY(originX, originY)
	if originX == nil or originY == nil then
		originX, originY = G_getHero():getCellXY()
	end
	
	local mapManager = GameWorld.Instance:getMapManager()
	local entityManager = GameWorld.Instance:getEntityManager()
	originX, originY = mapManager:convertToAoiCell(originX, originY)
	
	local pickUpConfig = GameWorld.Instance:getSettingMgr():readPickUpConfig()	
	local list = {}
	local mid = math.floor(const_pickupRange / 2)
	local x, y
	for i = -mid, mid do
		for j = -mid, mid do
			x = originX + (i * const_aoiCellSize)
			y = originY + (j * const_aoiCellSize)
			local tmpList = entityManager:getLoot(x,y)		
			if type(tmpList) == "table" then
				for k, v in pairs(tmpList) do
					if self:canBeCollected(pickUpConfig, v) then
						table.insert(list, v)
					end
				end
			end
		end
	end
--[[	local tmpList = entityManager:getLoot(originX,originY)		
	if type(tmpList) == "table" then
		for k, v in pairs(tmpList) do
			if self:canBeCollected(pickUpConfig, v) then
				table.insert(list, v)
			end
		end
	end--]]
	self:requestpickUpAll(list)
end

function PickUpManager:canBeCollected(pickUpConfig, loot)
	if loot:canBeCollect() == false then
		return false
	end
	for k, v in pairs(self.pickConfigFilterFuncList) do			
		if not v(pickUpConfig, loot) then
			return false
		end
	end
	return true	
end	

function PickUpManager:setRePickupInterval(interval)
	if type(interval) == "number" then
		self.rePickupInterval = interval
	else
		self.rePickupInterval = const_defaultRePickupInterval
	end
end

function PickUpManager:requestpickUpAll(list)
	local lenght = #(list)
	if lenght > 0 then
		-- 检测掉落物是否过期，过期需要确定是否掉落物在服务器已经不存在了
		for k, loot in pairs(list) do
			if loot:isTimeout() then
				local focusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
				focusManager:requestFindCharacter(EntityType.EntityType_Loot, loot:getId())
			end
		end
		
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_PickUp)
		StreamDataAdapter:WriteShort(writer, lenght)
		for k, loot in pairs(list) do		
			StreamDataAdapter:WriteStr(writer, loot:getId())
			loot:setNextPickupTime(self.rePickupInterval + os.time())
		end
		simulator:sendTcpActionEventInLua(writer)		
	end
end

function PickUpManager:getClosestPickupTarget() 
	local searchFilter = function(obj,refIdList)
		local pickUpConfig = GameWorld.Instance:getSettingMgr():readPickUpConfig()
		local canPick = self:canBeCollected(pickUpConfig,obj)
		return canPick
	end
	return HandupCommonAPI:getObj(EntityType.EntityType_Loot, searchFilter, nil, E_SelectTargetType.Closest)
end

function PickUpManager:clearAllLootNextPickTime()
	local list = GameWorld.Instance:getEntityManager():getEntityListByType(EntityType.EntityType_Loot)
	if type(list) == "table" then
		for k, v in pairs(list) do
			v:setNextPickupTime(0)
		end
	end
end

function PickUpManager:pickupItem(target, pickupCallback)
	local action
	local hero = G_getHero()
	if not hero:isOverlap(target) then	
		hero:addMoveToTargetAction(target, 0)	
	end
	action = hero:addPickupAction()
	local onPickupFinished = function()	--拾取完成的回调
		self.pickupActionId = nil
		if pickupCallback then
			pickupCallback()						
		end
	end
	action:addStopNotify(onPickupFinished, nil)
	self.pickupActionId = action:getId()
	return true
end