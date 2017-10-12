
PKHitManager = PKHitManager or BaseClass()

PKHitState = {
	Normal = 1,
	PK = 2,
}
--缺音效
function PKHitManager:__init()
	self.PKStateDelay = 30 --30秒结束恶意PK状态
	self.showTipsDelay = 5 --5秒内显示提示
	self.showTipsTimer = 0--提示计时器
	self.PKStateTimer = 0--PK状态计时器
	
	self.PKSchedulerId = -1	
	self.PKHitState = PKHitState.Normal
	
	self:bindBeAttackedEvent()
end

function PKHitManager:clear()
	self:clearScheduler()
	self:unbindBeAttackedEvent()
end

function PKHitManager:hit(obj)
	if not obj then
		return
	end
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if hero:getPKStateID()==E_HeroPKState.statePeace or hero:getPKStateID()==E_HeroPKState.stateGoodOrEvil then
		if self.PKStateTimer == 0 and self.PKHitState == PKHitState.Normal then
			if obj:getEntityType() == EntityType.EntityType_Player then
				self:showHit(obj)
			end
		end
		self:setPKHitStateToPK()
	end
end

function PKHitManager:setPKHitStateToNormal()
	self.PKHitState = PKHitState.Normal	
	self:clearScheduler()
end	

function PKHitManager:setPKHitStateToPK()
	self.PKHitState = PKHitState.PK	
	self:createScheduler()
end			

function PKHitManager:getPKHitState()
	return self.PKHitState
end

function PKHitManager:showHit(obj)
	if not obj then
		return
	end
	GlobalEventSystem:Fire(GameEvent.EventShowPKHitView)--显示受击效果
	self:showTips(obj)
	self.showTipsTimer = 0
end

function PKHitManager:createScheduler()
	self.PKStateTimer = 0
	
	if self.PKSchedulerId == -1 then
		if self.hideFunction == nil then
			self.hideFunction = function ()
				self:doSchedulerTimer()
			end
		end				
		self.PKSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.hideFunction, 1, false)
	end	
end

function PKHitManager:clearScheduler()
	if self.PKSchedulerId ~= -1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PKSchedulerId)
		self.PKSchedulerId = -1	
		self.PKStateTimer = 0
		self.showTipsTimer = 0
	end
end

function PKHitManager:doSchedulerTimer()
	self.PKStateTimer = self.PKStateTimer + 1
	self.showTipsTimer = self.showTipsTimer + 1
	
	if self.showTipsTimer<self.showTipsDelay then
		self:showTips()
	else
		self.Attackername = nil
	end
	
	if self.PKStateTimer >= self.PKStateDelay then
		self:clearScheduler()
		self.PKHitState = PKHitState.Normal
	end
end

function PKHitManager:bindBeAttackedEvent()
	self:unbindBeAttackedEvent()
	local onBeAttacked = function(obj, isNew)
		if obj then		
			self:hit(obj)			
		end
	end
	self.beAttackedEventId = GlobalEventSystem:Bind(GameEvent.EventBeAttacked, onBeAttacked)
end

function PKHitManager:unbindBeAttackedEvent()
	if self.beAttackedEventId then
		GlobalEventSystem:UnBind(self.beAttackedEventId)
		self.beAttackedEventId = nil
	end
end

function PKHitManager:showTips(obj)	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local state =  hero:getState()
	--角色死亡后不播放被攻击提示
	if  state:isState(CharacterState.CharacterStateDead) or state:isState(CharacterState.CharacterStateWillDead) then		
		self.showTipsTimer = self.showTipsDelay
		return
	end
	
	if obj then
		self.Attackername = PropertyDictionary:get_name(obj:getPT()) 
	end
		
	if self.Attackername then
		UIManager.Instance:showSystemTips(Config.Words[1202]..self.Attackername..Config.Words[1203])
	end		
end