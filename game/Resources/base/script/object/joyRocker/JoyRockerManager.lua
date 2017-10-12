require("common.baseclass")


JoyRockerManager = JoyRockerManager or BaseClass()

function JoyRockerManager:__init()
	self:clear()
	self.targetX = 0
	self.targetY = 0
end

--判断摇杆是否正在摇晃中....
function JoyRockerManager:isRocking()
	return self.bIsRocking
end

function JoyRockerManager:clear()
	self.lastDir = eDir_UnKnow
	self.bIsRocking = false
end

function JoyRockerManager:canJoyRockMove(dir)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	return hero and (((hero:getState():canChange(CharacterState.CharacterStateMove) or hero:getState():canChange(CharacterState.CharacterStateRideMove))
	and (not hero:getState():isState(CharacterState.CharacterStateMove) and not hero:getState():isState(CharacterState.CharacterStateRideMove))
	and not hero:getSkillMgr():isAutoUseSkill()) or self.lastDir ~= dir)
end

function JoyRockerManager:doMove(dir)
	self.lastDir = dir
	self.bIsRocking = true
	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local autoPath = GameWorld.Instance:getAutoPathManager()
	autoPath:cancel()
	local handupMgr = hero:getHandupMgr()
	if (handupMgr:isHandup()) then	--停止挂机
		handupMgr:stop()
	end
	
	local startX,startY = hero:getCellXY()
	local map = SFMapService:instance():getShareMap()
	local mapWidth= map:getMapWidth()-1
	local mapHeight = map:getMapHeight()-1
	local endX,endY = GameWorld.Instance:getMapManager():mapToCell(mapWidth,mapHeight)
	
	local maxDistance = 12
	if dir == eDir_Up then
		self.targetX = startX
		self.targetY = startY - maxDistance
	elseif dir == eDir_Down then
		self.targetX = startX
		self.targetY = startY + maxDistance
	elseif dir ==  eDir_Left then
		self.targetX = startX - maxDistance
		self.targetY = startY
	elseif dir == eDir_Right then
		self.targetX = startX + maxDistance
		self.targetY = startY
	elseif dir == eDir_LeftUp then
		self.targetX = startX - maxDistance
		self.targetY = startY - maxDistance
	elseif dir == eDir_LeftDown then
		self.targetX = startX - maxDistance
		self.targetY = startY + maxDistance
	elseif dir == eDir_RightUp then
		self.targetX = startX + maxDistance
		self.targetY = startY - maxDistance
	elseif dir == eDir_RightDown then
		self.targetX = startX + maxDistance
		self.targetY = startY + maxDistance
	end
	
	if self.targetX < 0 then
		self.targetX = 0
	elseif self.targetX > endX then
		self.targetX = endX
	end
	
	if self.targetY < 0 then
		self.targetY = 0
	elseif self.targetY > endY then
		self.targetY = endY
	end
	
	local bp = map:findBlock(startX, startY,self.targetX,self.targetY)
	if bp:getX() > 0 or bp:getY()>0 then
		self.targetX = bp:getX()
		self.targetY = bp:getY()
	end
	
	hero:moveTo(self.targetX,self.targetY)
	--			CCLuaLog("hero move to. bMoveIgnoreRockDir="..tostring(self.bMoveIgnoreRockDir))
end

function JoyRockerManager:getNextCell(cellX, cellY, dir)
	if cellX and cellY and dir then
		-- TODO: 获取cellX, cellY的下一个的AOI中心格
		local nextX, nextY = GameWorld.Instance:getMapManager():convertToAoiCell(cellX, cellY)
		
		if dir == eDir_Up then
			nextX = cellX
			nextY = cellY - const_aoiCellSize
		elseif dir == eDir_Down then
			nextX = cellX
			nextY = cellY + const_aoiCellSize
		elseif dir ==  eDir_Left then
			nextX = cellX - const_aoiCellSize
			nextY = cellY
		elseif dir == eDir_Right then
			nextX = cellX + const_aoiCellSize
			nextY = cellY
		elseif dir == eDir_LeftUp then
			nextX = cellX - const_aoiCellSize
			nextY = cellY - const_aoiCellSize
		elseif dir == eDir_LeftDown then
			nextX = cellX - const_aoiCellSize
			nextY = cellY + const_aoiCellSize
		elseif dir == eDir_RightUp then
			nextX = cellX + const_aoiCellSize
			nextY = cellY - const_aoiCellSize
		elseif dir == eDir_RightDown then
			nextX = cellX + const_aoiCellSize
			nextY = cellY + const_aoiCellSize
		end
		
		return nextX, nextY
	else
		return 0, 0
	end
end

function JoyRockerManager:handleJoyRockEvent(eventType,rocker,dir)
	rocker = tolua.cast(rocker,"SFJoyRocker")
	rocker:setOpacity(255)
	
	-- 处理多点触摸在攻击后要继续移动的需求
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if not hero then
		return 1
	end
	if eventType == kRockerDirection then
		if self:canJoyRockMove(dir) then
			self:doMove(dir)
		elseif (hero:getState():isState(CharacterState.CharacterStateMove) or hero:getState():isState(CharacterState.CharacterStateRideMove)) and
			not hero:getSkillMgr():isAutoUseSkill() then
			-- 如果不在长按技能的状态，并且在移动中，要检查是否接近目标点
			local startX,startY = hero:getCellXY()
			if math.abs(startX-self.targetX) <= 2 and math.abs(startY-self.targetY) <= 2 then
				self:doMove(dir)
			end
		end
	elseif eventType == kRockerFinish then
		self.targetX = 0
		self.targetY = 0
		
		local cellX, cellY = hero:getCellXY()
		if not GameWorld.Instance:getMapManager():isInAoiCenter(cellX, cellY) then
			-- 找下一格的中心
			local map = SFMapService:instance():getShareMap()
			local mapWidth= map:getMapWidth()-1
			local mapHeight = map:getMapHeight()-1
			local endX,endY = GameWorld.Instance:getMapManager():mapToCell(mapWidth,mapHeight)
			
			local nextX, nextY = self:getNextCell(cellX, cellY, self.lastDir)
			if nextX < 0 then
				nextX = 0
			elseif nextX > endX then
				nextX = endX
			end
			
			if nextY < 0 then
				nextY = 0
			elseif nextY > endY then
				nextY = endY
			end
			
			hero:moveTo(nextX, nextY)
		else
			hero:moveStop()
			hero:sysHeroLocation()
		end
		
		self.lastDir = eDir_UnKnow
		self.bIsRocking = false
		
		hero:clearShowingPath()
		self.lastDir = eDir_UnKnow;
		rocker:setOpacity(255*0.5)
	else
		self.lastDir = eDir_UnKnow
	end
	
	return 1
end

