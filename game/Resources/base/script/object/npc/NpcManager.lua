require("common.baseclass")
require("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")	
require"data.npc.collect"
NpcManager = NpcManager or BaseClass()

function NpcManager:__init()
	self.collectingInfo = {refId = nil, serverId = nil}
	self.collectActionId = nil --采集行为播放器的id
	self.moveToCollectActionId = nil 
end

function NpcManager:__delete()
end	
	
function NpcManager:clear()		
	self:cancelCollect()
	self.collectingInfo = {}

	GlobalEventSystem:Fire(GameEvent.EventInteruptCollect)
	GameWorld.Instance:getEntityManager():getHero():removePluckingAnimation()
end

function NpcManager:requestNpc(npcRefId,sceneId,portId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Npc_Transfer)
	writer:WriteString(npcRefId)
	writer:WriteString(sceneId)
	writer:WriteInt(portId)
	simulator:sendTcpActionEventInLua(writer)	
end

function NpcManager:requestPickNpcBegin(serverId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_StarttoPluck)
	writer:WriteString(serverId)	
	simulator:sendTcpActionEventInLua(writer)		
end	

function NpcManager:cancelCollect()
	if self.collectActionId then
		ActionPlayerMgr.Instance:removePlayerById(self.collectActionId)
		self.collectActionId = nil
		self.collectingInfo = {}
	end		
	if self.moveToCollectActionId then
		ActionPlayerMgr.Instance:removePlayerById(self.moveToCollectActionId)
		self.moveToCollectActionId = nil
	end	
end

--采集
function NpcManager:collect(npcId, callBack)
	local target = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_NPC, npcId)	
	if target and self:canCollect(npcId, false) then	
		return self:fastCollect(target, callBack)
	else
		return false
	end
end	

--采集：不检测采集条件
function NpcManager:fastCollect(target, callBack)
	self:cancelCollect()
	local action
	local hero = G_getHero()
	if not hero:isOverlap(target) then	
		self.moveToCollectActionId = (hero:addMoveToTargetAction(target, 0):getId())
	end
	action = hero:addCollectAction(target:getId())		
	self.collectingInfo = {refId = target:getRefId(), serverId = target:getId()}		
	local onCollectFinished = function()	--采集完成的回调
		self.collectingInfo = {}
		self.collectActionId = nil
		if callBack then
			callBack()			
			self.moveToCollectActionId = nil
		end
	end
	action:addStopNotify(onCollectFinished, nil)
	self.collectActionId = action:getId()
	return true
end	

--判断是否能采集
--bCheckPos: 是否检测位置
function NpcManager:canCollect(npcId, bCheckPos)
	local target = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_NPC, npcId)
	if not target then
		return false, target
	end
	
	local data = GameData.Collect[target:getRefId()]
	if not data then
		return false, target
	end
	local ret = PropertyDictionary:get_level(G_getHero():getPT()) >= PropertyDictionary:get_pluckLevel(data.property)
	if not bCheckPos then
		return ret, target
	else
		return (G_getHero():isOverlap(target) and ret), target
	end		
end	

--获取正在采集对象的信息
function NpcManager:getCollectInfo()
	return self.collectingInfo
end	

function NpcManager:isCollecting()
	return self.collectActionId
end

function NpcManager:saveTouchNpcRefId(id)
	self.npcRefId = id		
end	

function NpcManager:getTouchNpcRefId()
	return self.npcRefId	
end		