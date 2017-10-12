require ("common.GameEventHandler")
require ("gameevent.GameEvent")
require ("ui.UIManager")
require ("ui.wing.WingView")
require ("ui.wing.SubWingView")
WingUIHandler = WingUIHandler or BaseClass(GameEventHandler)

function WingUIHandler:__init()
	local manager =UIManager.Instance
	
	local handleClient_Open = function (showOption)
		
		manager:registerUI("WingView", WingView.create)	
		manager:showUI("WingView",showOption)									
		local view = manager:getMainView()		
		if view then
			--view:onRemoveAnimateByBtnId(MainMenu_Btn.Btn_wing)
			view:onStopAction(MainMenu_Btn.Btn_wing)
		end		
	end		
	
	local handleClient_wingRequest = function ()
		local wingMgr =  GameWorld.Instance:getEntityManager():getHero():getWingMgr() --发送当前拥有翅膀请求
		wingMgr:requestNowWing()								
	end
	
	local onUpdateWing = function (isLevelUp,upgradedWingId,exp)
		local view = manager:getViewByName("WingView")
		if view then
			view:showWingUpGradeAni(isLevelUp,upgradedWingId,exp)
			--view:UpdateWing(isLevelUp,upgradedWingId)
		end							
	end
	
	local handleClient_strengthenQuestRequest = function ()	
		local mapMgr = GameWorld.Instance:getMapManager()
		local mapRefId = mapMgr:getCurrentMapRefId()	
		if  mapMgr:getCurrentMapKind() == MapKind.instanceArea then
			mapMgr:handleMapKindState()	
		elseif mapRefId == "S070" or mapRefId == "S071" then
			GlobalEventSystem:Fire(GameEvent.EventEnterBossTemple)
		elseif mapRefId == "S217" then
			GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,false)
		end
		if PropertyDictionary:get_level(G_getHero():getPT()) < 40 then
			GlobalEventSystem:Fire(GameEvent.EventOpenRideControl,false)
		end
	end
		
	local handleClient_Close = function ()
		
	end
	
	local onUpdateModel = function()	
		local view = manager:getViewByName("WingView")
		if view then
			view:updatePlayerModel()
		end
	end
	
	local onUpdateMaterail = function()
		local view = manager:getViewByName("WingView")
		if view then
			view:getFeatherItem()
			view:setFeatherNumber()
		end				
	end	
	
	local onEventUpdateGetWingBtn = function (bShow)	
		local view = manager:getMainView()
		if view then
			local activityView = view:getMainOtherMenu()
			if activityView then
				activityView:updateWingBtn(bShow)
			end
		end
	end
	
	local onEventOpenSubWingView = function ()
		manager:registerUI("SubWingView", SubWingView.create)
		manager:showUI("SubWingView")
	end
	
	local eventShowWingBaoji = function(baojiNum)
		local view = manager:getViewByName("WingView")
		if(view ~= nil) then
			view:showBaoji(baojiNum)
		end	
	end
	
	self:Bind(GameEvent.EventWingBaoJi,eventShowWingBaoji)					
	self:Bind(GameEvent.EventOpenWingView,handleClient_Open)	
	self:Bind(GameEvent.EventHeroEnterGame,handleClient_wingRequest)
	self:Bind(GameEvent.EventWingUpGrade, onUpdateWing)
	self:Bind(GameEvent.EventMainViewCreated,handleClient_strengthenQuestRequest)
	self:Bind(GameEvent.EventEquipUpdate, onUpdateModel)
	self:Bind(GameEvent.EventItemUpdate, onUpdateMaterail)	
	self:Bind(GameEvent.EventUpdateGetWingBtn, onEventUpdateGetWingBtn)	
	self:Bind(GameEvent.EventOpenSubWingView, onEventOpenSubWingView)			
end	

function WingUIHandler:__delete()

end
