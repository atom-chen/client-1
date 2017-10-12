--寻找目标的行为播放器
require("common.baseclass")

SearchTargetActionPlayer = SearchTargetActionPlayer or BaseClass(BaseActionPlayer)

function SearchTargetActionPlayer:__init()	
	self.targetInfo = {}
	self.targetCellXY = {}
	self.searchFilter = nil
	self.searchMode = nil
	self.lastX = nil
	self.lastY = nil
	self.autoFindCallBackId = -1
	self.des = "SearchTargetActionPlayer"
end

function SearchTargetActionPlayer:__delete()
	self:release()
end		

function SearchTargetActionPlayer:release()
	if self.entityAddedEvent then
		GlobalEventSystem:UnBind(self.entityAddedEvent)
	end
	self.entityAddedEvent = nil
	
	if self.autoFindCallBackId then
		GameWorld.Instance:getAutoPathManager():unRegistCallBack(self.autoFindCallBackId)			
	end
	
	self.targetInfo = {}
	self.targetCellXY = {}
	self.searchFilter = nil
	self.searchMode = nil
	self.autoFindCallBackId = -1
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)
	local autoPathMgr = GameWorld.Instance:getAutoPathManager()
	autoPathMgr:cancel()
end

function SearchTargetActionPlayer:bindEntityAddedEvent()
	local onEntityAdded = function(obj)	
		if self.searchFilter(obj, self.searchFilterArg) then
			self:stopSucceed(0)			
			self:release()
			--print("SearchTargetActionPlayer find target")
		end
	end
	self.entityAddedEvent = GlobalEventSystem:Bind(GameEvent.EventEntityAdded, onEntityAdded)  
end	

--设置目标坐标
function SearchTargetActionPlayer:setTargetCellXY(x, y)
	self.targetCellXY.x = x
	self.targetCellXY.y = y
end

--设置目标信息
function SearchTargetActionPlayer:setTargetInfo(typeList, refIdList, sceneId)
	self.targetInfo.refIdList 	= refIdList	
	self.targetInfo.sceneId = sceneId
	self.targetInfo.typeList 	= typeList	
end		

--mode: refId: 根据refId寻找; pos: 根据位置去找
function SearchTargetActionPlayer:setSearchOption(mode, filter, arg)
	self.searchMode = mode
	self.searchFilter = filter
	self.searchFilterArg = arg
end

--重写
function SearchTargetActionPlayer:doPlay()
	if (not self.searchFilter) or (not self.searchMode) then
		error("SearchTargetActionPlayer:doPlay error. please setSearchOption")
	end
	
	local ret = false
	self:bindEntityAddedEvent()
	
	local autoPathMgr = GameWorld.Instance:getAutoPathManager()	
	local onAutoFindCallBack = function(stateType, id)
		if self.autoFindCallBackId == id then
			if stateType == AutoPathState.stateRun then 			
				if (not string.isLegal(self.targetInfo.sceneId)) then --没有指定目标场景，则认为到达了目的地
					self:stopSucceed(0)
					self:release()					
				else
					local currentScene = GameWorld.Instance:getMapManager():getCurrentMapRefId()
					--如果指定了目标场景id，则需要判断当前是否在目标场景。如果不是则忽略本次回调
					if currentScene == self.targetInfo.sceneId then						
						self:stopSucceed(0)
						self:release()
					end
				end
			elseif stateType == AutoPathState.stateCancel then 
				self:stopCanceled(0)
				self:release()
			end
		end
	end	
	self.autoFindCallBackId = autoPathMgr:registCallBack(onAutoFindCallBack)
	
	if self.searchMode == E_SearchTargetMode.RefId then		--根据refId寻找
		if table.isEmpty(self.targetInfo.refIdList) then
			error("self.targetInfo.refIdList not legal")
		else
			local refId = self.targetInfo.refIdList[1]
			if string.isLegal(self.targetInfo.sceneId) then	
				autoPathMgr:find(refId, self.targetInfo.sceneId)
				ret = true
			else
				autoPathMgr:find(refId)
				ret = true
			end		
		end
	else
		if type(self.targetCellXY.x) == "number" and type(self.targetCellXY.y) == "number" then
			autoPathMgr:moveToWithCallBack(self.targetCellXY.x, self.targetCellXY.y)
			ret = true
		else
			error("self.targetCellXY not legal")
		end
	end
	
	if not ret then
		self:stopFailed(0)
		self:release()	
	else
		self.lastX, self.lastY = G_getHero():getCellXY()
	end	
end	

local const_checkInterval = 1
function SearchTargetActionPlayer:doUpdate(time)
	local x, y = G_getHero():getCellXY()
	if self:getPlayingDuration() > const_checkInterval then		
		if (self.lastX == x and self.lastY == y) then
			self:stopFailed(0)
			self:release()			
			CCLuaLog("SearchTargetActionPlayer counld not move: heroX="..x.." heroY="..y)
			GlobalEventSystem:Fire(GameEvent.EventHeroMoveException)
		else
			self:setMaxPlayingDuration(10)			
			self.lastX, self.lastY = G_getHero():getCellXY()
		end
	end
end