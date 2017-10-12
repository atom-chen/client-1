require("common.baseclass")
require("data.unionGameInstance.unionGameInstance")
require("data.monster.monster")
require("data.gameInstance.Ins_8")

UnionInstanceMgr = UnionInstanceMgr or BaseClass()

function UnionInstanceMgr:__init()
	self.isFinish = false		
end

function UnionInstanceMgr:__delete()
	self:clear()
end

function UnionInstanceMgr:clear()
	self.isFinish = false
end

function UnionInstanceMgr:requestUnionInstanceApply()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_UnionGameInstance_Apply)	
	simulator:sendTcpActionEventInLua(writer)	
end

function UnionInstanceMgr:requestUnionInstanceEnter()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_UnionGameInstance_Enter)	
	simulator:sendTcpActionEventInLua(writer)
end
--判断是否已经击杀boss完成
function UnionInstanceMgr:getIsFinish()
	return self.isFinish
end

function UnionInstanceMgr:setIsFinish(bIsFinish)
	self.isFinish = bIsFinish
end
--获取要击杀怪物的名称
function UnionInstanceMgr:getMonsterName()
	local refId = self:getMonsterRefId()
	if refId then
		local monsterPT = GameData.Monster[refId].property
		if monsterPT then
			local name = monsterPT.name
			return name
		end
	end		
end

--获得怪物refId
function UnionInstanceMgr:getMonsterRefId()
	local pt = self:getUnionGameInstancePT()
	if pt then
		local refId = pt.monsterRefId
		if refId then
			return refId
		end			
	end
end

--获取公会副本的场景Id
function UnionInstanceMgr:getUnionInstanceSceneId()
	local PT = GameData.Ins_8["Ins_8"].configData["game_instance_scene"].configData["I013"].property
	if PT then
		local sceneId = PT.sceneRefId
		return sceneId
	end
end
--判断当前场景是不是公会副本
function UnionInstanceMgr:IsUnionInstanceSceneRunning()
	local mapMgr = GameWorld.Instance:getMapManager()
	local currentMapId = mapMgr:getCurrentMapRefId()	
	local unionInstanceSceneId = self:getUnionInstanceSceneId()
	return currentMapId == unionInstanceSceneId
end
--获取公会副本需要的人数
function UnionInstanceMgr:getNeedPlayerNumber()
	local pt = self:getUnionGameInstancePT()
	if pt then
		local maxStackNumber = pt.maxStackNumber
		if maxStackNumber then
			return maxStackNumber
		end			
	end
	return 0
end
--获取公会消耗的金币
function UnionInstanceMgr:getNeedGoldNumber()
	local pt = self:getUnionGameInstancePT()
	if pt then
		local gold = pt.gold
		if gold then
			return gold
		end			
	end
	return 0
end

function UnionInstanceMgr:getUnionGameInstancePT()
	local pt = GameData.UnionGameInstance["unionGameInstance"].property
	if pt then
		return pt
	end
end
