require("common.baseclass")
require("object.actionPlayer.BaseActionPlayer")
require"data.npc.collect"	
CollectActionPlayer = CollectActionPlayer or BaseClass(BaseActionPlayer)
local lastTipTime = 0
function CollectActionPlayer:__init()	
	self.npcId = nil
	self.collectEndEventId = nil
	self.collectInteruptEventId = nil
	self.collectErrorEventId = nil
	
	self.des = "CollectActionPlayer"
end

function CollectActionPlayer:__delete()
	self:unbind()	
end

function CollectActionPlayer:setNpcTarget(id)
	self.npcId = id
end	

function CollectActionPlayer:bindEvent()
	local onCollectFinished = function()
		self:unbind()
		self:stopSucceed(0)
	end
	self.collectEndEventId = GlobalEventSystem:Bind(GameEvent.EventEndCollect, onCollectFinished)	
	
	local onCollectFailed = function(msgId, errorCode)
		if msgId == ActionEvents.C2G_Scene_StarttoPluck and 
			(errorCode == 0x80000515			
			or errorCode == 0x80000516
			or errorCode == 0x80000517
			or errorCode == 0x80000518) then
--			print("CollectActionPlayer onCollectFailed")
			self:unbind()
			self:stopFailed(0)	
			if errorCode == 0x80000517 then			
				if os.time() - lastTipTime > 5 then
					lastTipTime = os.time()
					local data = GameData.Code[errorCode]
					if data then
						CCLuaLog("cccccccccccccccccccccc")
						local msg = {[1] = {word = data, color = Config.FontColor["ColorYellow1"]}}
						UIManager.Instance:showSystemTips(msg)
					end
				end
			end
		end
	end
	self.collectErrorEventId = GlobalEventSystem:Bind(GameEvent.EventErrorCode, onCollectFailed)	
	self.collectInteruptEventId = GlobalEventSystem:Bind(GameEvent.EventInteruptCollect, onCollectFailed)	
end

function CollectActionPlayer:unbind()
	if self.collectEndEventId then
		GlobalEventSystem:UnBind(self.collectEndEventId)
		self.collectEndEventId = nil
	end
	if self.collectInteruptEventId then
		GlobalEventSystem:UnBind(self.collectInteruptEventId)
		self.collectInteruptEventId = nil
	end
	if self.collectErrorEventId then
		GlobalEventSystem:UnBind(self.collectErrorEventId)
		self.collectErrorEventId = nil
	end
end

function CollectActionPlayer:doStop()
	if self:getStopReason() == E_ActionStopReason.Timeout then
--		UIManager.Instance:showSystemTips(Config.Words[3313])
	end
end

function CollectActionPlayer:doPlay()
	self:bindEvent()
	
	local mgr = GameWorld.Instance:getNpcManager()
	local canCollect, target = mgr:canCollect(self.npcId, true)
	if not canCollect then
		self:stopFailed(0)
		self:unbind()
	else
		mgr:requestPickNpcBegin(self.npcId)		
		local pluckDuration = PropertyDictionary:get_pluckTime(GameData.Collect[target:getRefId()].property)
		self:setMaxPlayingDuration(pluckDuration + 3)	--设置最大超时为 pluckDuration 
	end
end