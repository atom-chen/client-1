require("common.baseclass")
require("object.handup.FSM.HandupState")
CollectState = CollectState or BaseClass(HandupState)

function CollectState:__init()
	self:setType(E_HandupStateType.Collect)
	self.targetInfo = {}
	self.collectedList = {}
end

function CollectState:__delete()
	
end	

function CollectState:onEnter()
	self.targetInfo = {}
	self.collectedList = {}
	self.targetInfo = self.mgr:getTargetInfo()	
	self.searchFilter = self.fightTargetMgr:getTargetFilter(self.mgr:getHandupMode())
	self:loopCollect()	
end

function CollectState:getTarget()
	self.fightTargetMgr:setTargetIgnoreList(self.collectedList)
	for k, v in ipairs(self.targetInfo.typeList) do
		local target = HandupCommonAPI:getClosestObj(v, self.searchFilter, self.targetInfo.refIdList)
		if target then
			return target
		end
	end
	return nil
end

function CollectState:loopCollect()
	local npcMgr = GameWorld.Instance:getNpcManager()
	local npc = self:getTarget()
	if npc then	
		local onCollectFinished = function()
			if self.isRunning then
				self.fsm:changeState(self.mgr:getState(E_HandupStateType.Pickup), HandupStatePriority.Pickup, const_handupDelayPickupTime)					
			end
		end
		npcMgr:fastCollect(npc, onCollectFinished)				
		self.collectedList[npc:getId()] = true
	else
		if table.size(self.collectedList) > 0 then	--如果上次筛选时过滤掉了已拾取的。则将过滤列表情况，再搜索一次
			self.collectedList = {}
			self:loopCollect()
		else
			self.fsm:changeState(self.mgr:getState(E_HandupStateType.Search), HandupStatePriority.Pickup, 1)
		end
	end
end

function CollectState:onExit()
	self.targetInfo = {}
	self.collectedList = {}
	self.fightTargetMgr:setTargetIgnoreList(self.collectedList)
end

function CollectState:onMessage(msg)
	return false
end