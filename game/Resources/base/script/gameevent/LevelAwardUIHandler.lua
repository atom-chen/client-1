require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.activity.LevelAwardView"
require "ui.activity.QuickUpLevelView"
LevelAwardUIHandler = LevelAwardUIHandler or BaseClass(GameEventHandler)
	
function LevelAwardUIHandler:__init()
	local rtwMgr = GameWorld.Instance:getLevelAwardManager() 
	local manager =UIManager.Instance	
			
	local eventOpenRTWLevelAwardView = function (ttype)
			
		manager:registerUI("LevelAwardView", LevelAwardView.create)
		manager:showUI("LevelAwardView",E_ShowOption.eMiddle,ttype)					
	end	

	local onResquestState = function()
		rtwMgr:requestAwardList()	
	end
	
	local eventUpdateRTWAwardView = function()
		local view = manager:getViewByName("LevelAwardView")
		if view then
			view:updateAwardView()
			--rtwMgr:requestUpGradeAwardCanGet()
		end
	end
	
	local eventGetAwardSuccess = function()
		local view = manager:getViewByName("LevelAwardView")
		if view then
			view:changeGetAwardCellState(1)			
		end
		GlobalEventSystem:Fire(GameEvent.EventRTWAwardViewUpdate)		
		
		local putDown = true
		local rlist = rtwMgr:getRideAwardList()
		for k,v in pairs(rlist) do
			if  v == 2 then
				putDown = false
			end
		end
		
		if putDown then
			local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
			activityManageMgr:setActivityState("activity_manage_4",false)
			ActivityDelegate:showEffectInUpGradeButton(false)--mark
		end		
		
	end
	
	local eventOpenQuickUpLevelView = function()
		
		manager:registerUI("QuickUpLevelView", QuickUpLevelView.create)		
		manager:showUI("QuickUpLevelView",E_ShowOption.eMiddle,ttype)		
		rtwMgr:requestLevelUpAwardList()
	end
		
	local eventUpdateQuickUpLevelView = function()
		local view = manager:getViewByName("QuickUpLevelView")
		if view then		
			view:updateAwardView()
			rtwMgr:requestLevelUpAwardCanGet()
		end
	end
	
	local eventHandleGetLevelUpAwardSuccess = function()
		local view = manager:getViewByName("QuickUpLevelView")
		if view then
			view:changeGetAwardCellState(1)			
		end
		local putDown = true
		local list = rtwMgr:getLevelUpAwardList()
		for k,v in pairs(list) do
			if  v == 2 then
				putDown = false
			end
		end
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
		if putDown then	
			activityManageMgr:setActivityState("activity_manage_17",false)	
			ActivityDelegate:showEffectInLevelupButton(false) --mark
		end
		-- 新手指引完成
		GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("activity_manage_17")	
	end
	
	local onResqueLevelAwardCanGet = function()
		rtwMgr:requestLevelUpAwardCanGet() 
	end

	local onResquestUpGradeAwardCanGets = function()
		rtwMgr:requestUpGradeAwardCanGet() 
	end
	
	self:Bind(GameEvent.EventUpdateQuickUpLevelView,eventUpdateQuickUpLevelView)
	self:Bind(GameEvent.EventGetQuickUpLevelAwardSuccess,eventHandleGetLevelUpAwardSuccess)
	self:Bind(GameEvent.EventOpenQuickUpLevelView,eventOpenQuickUpLevelView)	
	self:Bind(GameEvent.EventGetAwardSuccess,eventGetAwardSuccess)	
	self:Bind(GameEvent.EventRTWAwardViewUpdate,eventUpdateRTWAwardView)				
	self:Bind(GameEvent.EventOpenRTWLevelAwardView, eventOpenRTWLevelAwardView)
	self:Bind(GameEvent.EventHeroEnterGame,onResquestState)	
	self:Bind(GameEvent.EventHeroEnterGame,onResqueLevelAwardCanGet)	
	self:Bind(GameEvent.EventHeroEnterGame,onResquestUpGradeAwardCanGets)										
end	

function LevelAwardUIHandler:__delete()
	
end		
