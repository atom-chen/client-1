require("common.baseclass")
require("object.actionPlayer.BaseActionPlayer")

MoveToTargetActionPlayer = MoveToTargetActionPlayer or BaseClass(BaseActionPlayer)

function MoveToTargetActionPlayer:__init()	
	self:setMaxPlayingDuration(-1)		--不限制播放时间
	self.maxPlayCount = 1
	self.playCount = 0
	self.des = "MoveToTargetActionPlayer"
end

function MoveToTargetActionPlayer:__delete()
	self:clear()	
end

--设置目标信息
function MoveToTargetActionPlayer:setTargetInfo(id, ttype)
	self.targetId = id
	self.targetType = ttype
end

--设置与目标的停止距离，距离的单位是大格子，也就是AOI格子
function MoveToTargetActionPlayer:setStopDistance(distance)
	self.stopDistance = distance
end	

--设置最大播放次数(如果英雄停止后，与目标的距离大于停止距离，如果没有超过最大播放次数，则进行重复播放)
function MoveToTargetActionPlayer:setMaxPlayCount(count)
	self.maxPlayCount = count
end

--重写
function MoveToTargetActionPlayer:doPlay()
	self.playCount = self.playCount + 1
	self:doMove()
end
--476 360
function MoveToTargetActionPlayer:doMove()
	if (not self.targetType) or (not self.targetId) or (not self.stopDistance) then
		error("MoveToTargetActionPlayer arg error")
		return
	end
	if not self:checkShouldStop() then
		G_getHero():moveStop()	--移动之前要先stop英雄，以免移动失败		
		local target = GameWorld.Instance:getEntityManager():getEntityObject(self.targetType, self.targetId)
		self.lastX, self.lastY = GameWorld.Instance:getMapManager():convertToAoiCell(G_getHero():getCellXY())
		self.targetX, self.targetY = GameWorld.Instance:getMapManager():convertToAoiCell(target:getCellXY())			
		if self.stopDistance > 0 then
			local retX, retY 
			retX, retY = HandupCommonAPI:getPointInRange(self.stopDistance * const_aoiCellSize, self.lastX, self.lastY, self.targetX, self.targetY)
			retX, retY = GameWorld.Instance:getMapManager():convertToAoiCell(retX, retY)
			if not ((retX == self.lastX) and (retY == self.lastY)) then --如果获取到的位置与英雄不在同一格子，则使用获取到的坐标
				self.targetX = retX
				self.targetY = retY
			end
		end
		local autoPathMgr = GameWorld.Instance:getAutoPathManager()	
		local onAutoFindCallBack = function(stateType, id)
			if self.autoFindCallBackId == id then
				if stateType == AutoPathState.stateRun then 							
					if not self:checkShouldStop() then
						if self.playCount < self.maxPlayCount or (self.maxPlayCount == -1) then
							self:restart()
						else
							self:stopFailed(0)
							self:clear()
						end
					end
				elseif stateType == AutoPathState.stateCancel then 	
					self:stopCanceled(0)		
					self:clear()		
				end
			end
		end	
		self.autoFindCallBackId = autoPathMgr:registCallBack(onAutoFindCallBack)	
		local ret = autoPathMgr:moveToWithCallBack(self.targetX, self.targetY) 	
		--Juchao@20140417: 调用了英雄的移动函数，可能返回true，但没有真正的移动。所以这里需要再次判断英雄的状态是否移动
		if (not ret) then				
			self:stopFailed(0)
		elseif ((not G_getHero():getState():isState(CharacterState.CharacterStateMove)) 
						 and (not G_getHero():getState():isState(CharacterState.CharacterStateRideMove))) then
			CCLuaLog("MoveToTargetActionPlayer move failed.")	
			GlobalEventSystem:Fire(GameEvent.EventHeroMoveException)	
			self:stopFailed(0)					
		end
	end	
end

function MoveToTargetActionPlayer:clear()
	if self.autoFindCallBackId then
		GameWorld.Instance:getAutoPathManager():unRegistCallBack(self.autoFindCallBackId)		
		self.autoFindCallBackId = nil	
	end
	--local autoPathMgr = GameWorld.Instance:getAutoPathManager()--tudo导致自动寻路回调参数改为Cancel
	--autoPathMgr:cancel()
end	

--清理，并设置状态为Waiting
function MoveToTargetActionPlayer:restart()
	self:clear()
	self:setState(E_ActionPlayerState.Waiting)	--设置为Waiting，重新播放	
end

function MoveToTargetActionPlayer:checkShouldStop()
	local target = GameWorld.Instance:getEntityManager():getEntityObject(self.targetType, self.targetId)
	if not target then
		self:clear()
		self:stopFailed(0)			
		return true
	end
	if HandupCommonAPI:objAoiDistance(target, G_getHero()) <= self.stopDistance then		
		self:clear()
		self:stopSucceed(0)		
		return true
	end
	return false
end

local const_checkInterval = 1.5
function MoveToTargetActionPlayer:doUpdate(time)
	if self:getPlayingDuration() > const_checkInterval then	
		local x, y = G_getHero():getCellXY()
		if (self.lastX == x and self.lastY == y) then	--位置没有发生变化，则下一帧停止
			self:clear()
			self:stopFailed(0)			
			CCLuaLog("MoveToTargetActionPlayer counld not move: heroX="..x.." heroY="..y.." targetX="..self.targetX.." targetY="..self.targetY.." id="..self:getId())
			print("MoveToTargetActionPlayer counld not move: heroX="..x.." heroY="..y.." targetX="..self.targetX.." targetY="..self.targetY.." id="..self:getId())			
			GlobalEventSystem:Fire(GameEvent.EventHeroMoveException)
		else			
			self.lastX, self.lastY = G_getHero():getCellXY()
			self:setMaxPlayingDuration(-1)	--清除已播放时间
		end
	end			
end	