require ("common.GameEventHandler")
require ("ui.UIManager")
require ("ui.achievement.AchieveView")
require ("ui.achievement.ExchangeMedalView")
AchieveUIHandler = AchieveUIHandler or BaseClass(GameEventHandler)

function AchieveUIHandler:__init()
	local manager =UIManager.Instance
	
	
	local loginRequest = function()
		--请求成就
		local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
		achieveMgr:requestAchievementList()
	end
	local handleClient_Open = function ()
		
		manager:registerUI("AchieveView", AchieveView.create)
		manager:showUI("AchieveView")		
	end	
	local showExchangeMedalView = function (arg)
		
		manager:registerUI("ExchangeMedalView", ExchangeMedalView.create)
		manager:showUI("ExchangeMedalView",E_ShowOption.eLeft,arg)
	end
	
	local onResultEvent = function(msgId,printCode)
		self:onResultEvent(msgId,printCode)
	end		
		
	self:Bind(GameEvent.EventHeroEnterGame,loginRequest)
	self:Bind(GameEvent.EventOpenAchieveView,handleClient_Open)
	self:Bind(GameEvent.EventOpenExchangeView,showExchangeMedalView,arg)
	self:Bind(GameEvent.EventErrorCode,onResultEvent)	
	
	local refreshBtnFunc = function(refId)
		local view = manager:getViewByName("ExchangeMedalView")
		if view then
			view:refreshBtn(refId)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshBtn,refreshBtnFunc,refId)
	
	local refreshView = function(pt)
		local newAchiNum = PropertyDictionary:get_achievement(pt)	
		if(newAchiNum ~= 0) then					
			local view = manager:getViewByName("AchieveView")					
			if(view) then
				view:refreshAchieveNum(newAchiNum)	
			end
			local view = manager:getViewByName("ExchangeMedalView")					
			if(view) then
				view:refreshNum(newAchiNum)	
			end
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventHeroProChanged, refreshView)
	self:checkNewReward()
	self:refreshScrollView()
	self:refreshTableView()
	self:setSelIndex()
	self:setCompleteList()
	self:setBtnVisible()
	self:checkNewImage()
	
	local onEventResetButtonState = function ()
		local view = manager:getViewByName("AchieveView")
		if view then
			view:resetButtonState()
		end
	end
	
	local onEventSetButtonVisible = function ()
		local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()		
		achieveMgr:closeBtn()			
	end
	
	self:Bind(GameEvent.EventSetButtonVisible, onEventSetButtonVisible)
	self:Bind(GameEvent.EventResetButtonState, onEventResetButtonState)
	
end
function AchieveUIHandler:__delete()
	
end	
function AchieveUIHandler:setCompleteList()
			--监视成就完成情况	
	local setCompList = function(key)			
		GlobalEventSystem:Fire(GameEvent.EventRefreshCompleted,key)		
	end
	GlobalEventSystem:Bind(GameEvent.EventCompletedListSet,setCompList,key)
end

function AchieveUIHandler:setBtnVisible()
	local manager =UIManager.Instance
	local openBtn = function()
		local view = manager:getViewByName("AchieveView")
		local tag = "open"
		if(view) then
			view:enterTabView(tag)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventOpenBtn,openBtn)
	local closeBtn = function()
		local view = manager:getViewByName("AchieveView")
		local tag = "close"
		if(view) then
			view:enterTabView(tag)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventCloseBtn,closeBtn)
end

function AchieveUIHandler:refreshScrollView()
	local manager =UIManager.Instance	
	local refreshText = function(cellIndex)
		local key = 1
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end		
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshNovice,refreshText,cellIndex)
	local refreshText = function(cellIndex)
		local key = 2
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshKillSubs,refreshText,cellIndex)
	local refreshText = function(cellIndex)
		local key = 3
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshKillBoss,refreshText,cellIndex)
	local refreshText = function(cellIndex)
		local key = 4
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshMountUp,refreshText,cellIndex)
	local refreshText = function(cellIndex)
		local key = 5
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshKnightUp,refreshText,cellIndex)
	--[[local refreshText = function(cellIndex)
		local key = 6
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshHeartUp,refreshText,cellIndex)--]]
	local refreshText = function(cellIndex)
		local key = 6
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshSubScroll(key,cellIndex)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshGetMedal,refreshText,cellIndex)
end

function AchieveUIHandler:refreshTableView()
	local refreshList = function(vType)
		local manager =UIManager.Instance	
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:refreshTableView(vType)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventRefreshCompleted,refreshList,vType)
end

function AchieveUIHandler:setSelIndex()
	local setSel = function(index)
		local manager =UIManager.Instance	
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:setSelIndex(index)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventSetSelIndex,setSel,index)
end
function AchieveUIHandler:checkNewImage()
	local checkNewFunc = function(achieveType)
		local manager =UIManager.Instance	
		local view = manager:getViewByName("AchieveView")
		if(view) then
			view:checkNewImage(achieveType)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventCheckNewImage,checkNewFunc,achieveType)
end
function AchieveUIHandler:checkNewReward()
	local checkNewReward = function()
		local manager =UIManager.Instance	
		local view = manager:getViewByName("AchieveView")
		if(view) then
			local achieveMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
			local newReward = achieveMgr:checkNewReward()
			view:setGetAllRewardBtn(newReward)
		end
	end
	GlobalEventSystem:Bind(GameEvent.EventCheckNewReward,checkNewReward)
end

function AchieveUIHandler:onResultEvent(msgId,errCode)
	local code = errCode 
	if msgId >= 2400 and msgId <2500 then
		if code and code < 0 then
			code = 0xFFFFFFFF + errCode + 1
		end
		if GameData and GameData.Code[code] then
			UIManager.Instance:showSystemTips(GameData.Code[code])
		end			
	end
end

function AchieveUIHandler:__delete()
	
end	