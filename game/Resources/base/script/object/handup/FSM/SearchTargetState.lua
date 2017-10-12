require("common.baseclass")
require("object.handup.FSM.HandupState")

SearchTargetState = SearchTargetState or BaseClass(HandupState)

function SearchTargetState:__init()
	self:setType(E_HandupStateType.Search)
	self.targetInfo = {}
	self.curHandupPointIndex = 1
	self.handupPointList = {}	
	self.searchActionId = nil	
	self.searchFilter = nil
	self.searchMode = nil
end

function SearchTargetState:__delete()
	
end

--this will execute when the state is entered
function SearchTargetState:onEnter()
	self.searchMode = self.mgr:getSearchMode()
	self.targetInfo = self.mgr:getTargetInfo()
	self.handupPointList = HandupCommonAPI:buildHandupPoints()		
	self.searchFilter = self.fightTargetMgr:getTargetFilter(self.mgr:getHandupMode())
	
	if self:hasTarget() then
		self:onTargetAppeared()
	else
		self:searchTarget()
	end
end	

--�ж��Ƿ���Ŀ��
function SearchTargetState:hasTarget()
	for k, v in ipairs(self.targetInfo.typeList) do
		if HandupCommonAPI:hasTarget(v, self.searchFilter, self.targetInfo.refIdList) then
			return true
		end
	end
	return false
end

function SearchTargetState:searchTarget()
	local onSearchFinished = function()
		if not self.isRunning then
			return
		end
		self.searchActionId = nil
		if self:hasTarget() then
			self:onTargetAppeared()
		else
			self:searchTarget()
		end
	end
	
	local action = SearchTargetActionPlayer.New()		
	action:setSearchOption(self.searchMode, self.searchFilter, self.targetInfo.refIdList)		
	if self.searchMode == E_SearchTargetMode.Random then		--���Ѱ��
		local point = self:getNextHandupPoint()
		action:setTargetCellXY(point.x, point.y) 		
	elseif self.searchMode == E_SearchTargetMode.RefId then		--����refIdѰ��
		action:setTargetInfo(self.targetInfo.typeList, self.targetInfo.refIdList, self.targetInfo.sceneId) 		
	else
		error("SearchTargetState:searchTarget search mode illegal")
	end
	action:addStopNotify(onSearchFinished, nil)		--����stopʱ�Ļص�
	self.searchActionId = ActionPlayerMgr.Instance:addPlayer(G_getHero():getId(), action)		
end

--Ѱ�ҵ���Ŀ�꣬תΪս��״̬
function SearchTargetState:onTargetAppeared()
	local mode = self.mgr:getHandupMode() 
	if mode == E_AutoSelectTargetMode.Normal or mode == E_AutoSelectTargetMode.CastleWar then
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Fight))	
		self:selectTarget()
	elseif mode == E_AutoSelectTargetMode.Collect then
		self.fsm:changeState(self.mgr:getState(E_HandupStateType.Collect))
	end
end		

function SearchTargetState:selectTarget()
	local target = GameWorld.Instance:getFightTargetMgr():getMainTargetObj()	--����Ѿ�������Ŀ�꣬��Ŀ���������������Ҫ����ѡ��
	if (not target) or (self.searchFilter and (not self.searchFilter(target, self.targetInfo.refIdList))) then
		target = G_getFightTargetMgr():autoSelectTarget(self.targetInfo.refIdList)
	end		
	return target
end

--��ȡ��һ��Ŀ���
function SearchTargetState:getNextHandupPoint()
	if table.isEmpty(self.handupPointList) then			--�һ���listΪ��ʱ�������ȡһ����
		return HandupCommonAPI:getRandomPoint(const_handupRadius)
	else
		self.curHandupPointIndex = self.curHandupPointIndex + 1
		if self.curHandupPointIndex > #(self.handupPointList) then
			self.curHandupPointIndex = 1
		end
		return self.handupPointList[self.curHandupPointIndex]
	end
end

--this will execute when the state is exited. 
function SearchTargetState:onExit()
	self.targetInfo = {}
	self.searchFilter = nil
	self.searchMode = nil
	self.curHandupPointIndex = 1
	if self.searchActionId then
		ActionPlayerMgr.Instance:removePlayerById(self.searchActionId)
		self.searchActionId = nil
	end
	local autoPathMgr = GameWorld.Instance:getAutoPathManager()
	autoPathMgr:cancel()
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)
end

function SearchTargetState:onMessage()
	return false
end	