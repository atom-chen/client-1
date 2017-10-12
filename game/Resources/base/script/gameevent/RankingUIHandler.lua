require "common.baseclass"
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.Ranking.RankListView"

RankingUIHandler = RankingUIHandler or BaseClass(GameEventHandler)

function RankingUIHandler:__init()
	self.eventObjTable = {}
	local manager =UIManager.Instance	
	
	local eventRequestVersionNum = function(rankType)
		local rankListMgr = GameWorld.Instance:getRankListManager()
		rankListMgr:requestVersionNum(rankType)
	end
	
	local eventRequestNameList = function(rankType)
		local rankListMgr = GameWorld.Instance:getRankListManager()
		rankListMgr:requestNameList(rankType)
		if rankType == 0 then
			for proffesion = 1 ,3 do
				rankListMgr:requestFpSubList(rankType,proffesion)
			end
		end
	end
	
	local eventOpenRankListView = function(ttype)
		
		manager:registerUI("RankListView",RankListView.create)
		manager:showUI("RankListView",E_ShowOption.eMiddle,ttype)

		if ttype == 1 then
			local rankListMgr = GameWorld.Instance:getRankListManager()
			local curRankType = rankListMgr:getCurRankType()
			if curRankType then
				rankListMgr:requestVersionNum(curRankType)
			end
		end
	end
	
	local eventUpdateRankListView = function(rankType)		
		local rankListView = manager:getViewByName("RankListView")
		rankListView:updateRight()
	end
	
	local eventRequestOtherPeopleDetailInfo = function(playerId)
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local equipMgr = hero:getEquipMgr()
		local heroId = hero:getId()
		local player = {}
		if heroId ~= playerId then
			local entityMgr = GameWorld.Instance:getEntityManager()	
			equipMgr:requestOtherPlayerEquipList(playerId)
			entityMgr:requestOtherPlayer(playerId)		
			equipMgr:setOtherPlayerEquipList(nil)	--清空列表，防止读到其他玩家信息
			local playerObject = PlayerObject.New()
			playerObject:setId(playerId)
			player = {playerObj=playerObject,playerType =1}	--1: 其他玩家的信息
		end
				
		GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player) 
		GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
	end
		
	local eventRequestOtherPeopleInfo = function(playerId)
		local entityMgr = GameWorld.Instance:getEntityManager()
		local equipMgr = entityMgr:getHero():getEquipMgr()

		local heroObject = GameWorld.Instance:getEntityManager():getHero()
		local hero = {playerObj=heroObject,playerType =0,titleName="myProperty.png"}		--0: 自己的信息

		entityMgr:requestOtherPlayer(playerId)
		local playerObject = PlayerObject.New()
		playerObject:setId(playerId)
		local player = {playerObj=playerObject,playerType =1,titleName="otherProperty.png"}	--1: 其他玩家的信息

		GlobalEventSystem:Fire(GameEvent.EVENT_OpenMyDetailProperty, E_ShowOption.eMove2Right,hero)
		GlobalEventSystem:Fire(GameEvent.EVENT_OpenHisDetailProperty, E_ShowOption.eMove2Left,player)	
	end
	
	local eventLimitRankNodeUpdate = function(ttype)
		local rankListView = manager:getViewByName("RankListView")
		if rankListView then
			rankListView:updateLimitRankNode(ttype)		
		end
	end
	
	local eventRequestLimitTimeRankState = function()
		local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
		limitTimeRankMgr:requestLimitRankAwardCanGet()
	end
		
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventLimitRankNodeUpdate,eventLimitRankNodeUpdate))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRequestVersionNum, eventRequestVersionNum))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRequestNameList, eventRequestNameList))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventOpenRankListView, eventOpenRankListView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventUpdateRankListView,eventUpdateRankListView))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRequestOtherPeopleDetailInfo,eventRequestOtherPeopleDetailInfo))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventRequestOtherPeopleInfo,eventRequestOtherPeopleInfo))
	table.insert(self.eventObjTable, self:Bind(GameEvent.EventHeroEnterGame,eventRequestLimitTimeRankState))
end

function RankingUIHandler:__delete()
	for k, v in pairs(self.eventObjTable) do
		self:UnBind(v)
	end
end