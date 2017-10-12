require "common.baseclass"	
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.nearby.NearbyView"

NearbyUIHandle = NearbyUIHandle or BaseClass(GameEventHandler)

--[[local EventType = {
insert = 1,
remove = 2,
}--]]

function NearbyUIHandle:__init()
	local manager = UIManager.Instance
	local nearbyMgr = GameWorld.Instance:getNearbyMgr()
	
	local onEventOpenNearByView = function ()	
		if not self.nearbyView then
			self.nearbyView = NearbyView:create()
		end
		
		local mainView = manager:getMainView()
		if mainView then
			mainView:setQuestNodeVisible(false)
			--GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,false)			
			mainView:setNearbySelectVisible(true)
		end
		
		nearbyMgr:setNearByViewIsShowing(true)
		local gameRootNode = manager:getGameRootNode()		
		gameRootNode:addChild(self.nearbyView:getRootNode(), -1)
		VisibleRect:relativePosition(self.nearbyView:getRootNode(), gameRootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(30, 60))

		if self.nearbyView:getSelectTabView()==1  then
			self.nearbyView:UpdateHeroTable()
		else
			self.nearbyView:UpdateMonsterTable()
		end
	end		
	
	local onEventCloseNearByView = function ()		
		local mainView = manager:getMainView()
		if mainView then
			mainView:setQuestNodeVisible(true)
			--GlobalEventSystem:Fire(GameEvent.EventSetQuestVisible,true)			
			mainView:setNearbySelectVisible(false)
		end
		if self.nearbyView then
			self.nearbyView:closeView()
			self.nearbyView:getRootNode():removeFromParentAndCleanup(false)					
			nearbyMgr:setNearByViewIsShowing(false)
		end	
	end
	
	local onEventEntityAdded = function (obj)
		self:updateNearbyView(obj)			
	end
	
	local onEventEntityRemoved = function (obj)
		self:updateNearbyView(obj)
	end
	
	local onReloadNearbyView = function ()
		if not self.nearbyView or not nearbyMgr:getNearByViewIsShowing() then
			return
		end
		self.nearbyView:resetView()
	end	
	
	local eventUpdateNearPlayerList = function()
		local nearbyMgr = GameWorld.Instance:getNearbyMgr()
		if not self.nearbyView or not nearbyMgr:getNearByViewIsShowing() then	
			return
		end	
		self.nearbyView:UpdateHeroTable()	
	end	
	self:Bind(GameEvent.EventNearByPlayerStateChange,eventUpdateNearPlayerList)
	self:Bind(GameEvent.EventOpenNearByView, onEventOpenNearByView)
	self:Bind(GameEvent.EventCloseNearByView, onEventCloseNearByView)
	self:Bind(GameEvent.EventEntityAdded, onEventEntityAdded)
	self:Bind(GameEvent.EventEntityRemoved, onEventEntityRemoved)
	self:Bind(GameEvent.EventGameSceneReady, onReloadNearbyView)	
end

function NearbyUIHandle:updateNearbyView(obj)
	if self.delayUpdateSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayUpdateSchId)
		self.delayUpdateSchId = nil
	end
	local nearbyMgr = GameWorld.Instance:getNearbyMgr()
	if not self.nearbyView or not nearbyMgr:getNearByViewIsShowing() then	
		return
	end			
	
	if obj:getEntityType()==EntityType.EntityType_Monster then
		local refId = obj:getRefId()
		if refId then
			local quanlity = nearbyMgr:getMonsterQuanlityByRefId(refId)
			if quanlity and quanlity > 1 then
				if self.nearbyView then					
					if self.nearbyView:getSelectTabView()==2 then				
						nearbyMgr:setIsUpdateMonsterList(true)
					end
				end
			end
		end
		
	elseif obj:getEntityType()==EntityType.EntityType_Player then			
		if self.nearbyView:getSelectTabView()==1 then
			nearbyMgr:setIsUpdatePlayerList(true)
		end						
	end	
	
	local updateEntity = function ()	
		if nearbyMgr:getIsUpdatePlayerList() then
			self.nearbyView:UpdateHeroTable()
		end
		if nearbyMgr:getIsUpdateMonsterList() then
			self.nearbyView:UpdateMonsterTable()
		end
				
		if self.delayUpdateSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayUpdateSchId)
			self.delayUpdateSchId = nil
		end	
		nearbyMgr:setIsUpdatePlayerList(false)
		nearbyMgr:setIsUpdateMonsterList(false)		
	end						
	self.delayUpdateSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateEntity, 0.2, false);
end

function NearbyUIHandle:__delete()

end