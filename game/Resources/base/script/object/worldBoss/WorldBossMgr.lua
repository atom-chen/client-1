require("common.baseclass")
require("data.worldBoss.worldBoss")
require("data.worldBoss.worldElite")

WorldBossMgr = WorldBossMgr or BaseClass()

BOSSKIND = {
	WorldBoss = 0,--普通boss
	MonsterInvasion = 1,--怪物入侵
}
function WorldBossMgr:__init()
	self.uiIndex = {}
	self.bossList={}	
	self.eliteList = {}
end

function WorldBossMgr:__delete()

end

function WorldBossMgr:clear()
	self.uiIndex = {}
	self.bossList={}	
	self.eliteList = {}
end

function WorldBossMgr:requestWorldBoss()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Boss_List)	
	simulator:sendTcpActionEventInLua(writer)		
end

function WorldBossMgr:getWorldBossProperty(bossId)
	if bossId and GameData.WorldBoss[bossId] and GameData.WorldBoss[bossId]["property"] then 
		local property = GameData.WorldBoss[bossId]["property"]				
		return property
	end
end

function WorldBossMgr:getBossKind(bossId)
	if not bossId then
		return 0
	end
	local property = self:getWorldBossProperty(bossId)
	if property and property.kind then 
		return property.kind
	end
	return 0
end	

function WorldBossMgr:getWorldBossDropItems(bossId)
	if bossId and GameData.WorldBoss[bossId] and GameData.WorldBoss[bossId]["showItems"] then 
		return GameData.WorldBoss[bossId].showItems
	end
end

function WorldBossMgr:getBossRefId(bossId)
	if bossId then
		local property = self:getWorldBossProperty(bossId)
		if property and property.monsterRefId then 
			return property.monsterRefId
		end
	end
end

function WorldBossMgr:getBossRefreshTime(bossId)
	if bossId then
		for k, boss in pairs(self.bossList) do 
			if bossId == boss.bossId then 
				return boss.refreshTime
			end
		end	
	end	
end

function WorldBossMgr:setBossList(list)
	if list then
		self.bossList = list
	end
end

function WorldBossMgr:getBossList()
	return self.bossList	
end

function WorldBossMgr:getBossCount()
	return (table.size(self.bossList))
end

function WorldBossMgr:setRefreshBossId(bossId)
	if bossId then
		self.refreshBossId = bossId
	end
end

function WorldBossMgr:getMonsterPTByRefId(monsterRefId)
	if monsterRefId then
		local data = GameData.Monster[monsterRefId] 
		if data then
			return data.property
		end
	end		
end

function WorldBossMgr:getMonsterLevelByRefId(monsterRefId)
	if monsterRefId then
		local pt = self:getMonsterPTByRefId(monsterRefId)
		if pt then
			return PropertyDictionary:get_level(pt)
		end
	end
end

function WorldBossMgr:getMonsterNameByRefId(monsterRefId)
	if monsterRefId then
		local pt = self:getMonsterPTByRefId(monsterRefId)
		if pt then
			return PropertyDictionary:get_name(pt)
		end
	end
end

function WorldBossMgr:getScenePTByRefId(sceneId)
	if sceneId then
		local sceneData = GameData.Scene[sceneId]
		if sceneData then
			return sceneData.property
		end
	end
end

function WorldBossMgr:getSceneNameBySceneId(sceneId)
	if sceneId then
		local pt = self:getScenePTByRefId(sceneId)
		if pt then
			return PropertyDictionary:get_name(pt)
		end
	end
end

function WorldBossMgr:setEliteList()
	local data = GameData.WorldElite
	if data then
		for key,v in pairs(data) do
			local eliteObj = v
			local monsterRefId = v.monsterRefId
			eliteObj.level = self:getMonsterLevelByRefId(monsterRefId)
			eliteObj.eliteName = self:getMonsterNameByRefId(monsterRefId)
			eliteObj.sceneName = self:getSceneNameBySceneId(v.sceneRefId)
			table.insert(self.eliteList, eliteObj)
		end
		
		local sortFun = function (a, b)			
			return tonumber(string.sub(a.refId, 7)) < tonumber(string.sub(b.refId, 7))
		end
		table.sort(self.eliteList, sortFun)
	end		
end

function WorldBossMgr:getEliteList()
	return self.eliteList 
end

function WorldBossMgr:getRefreshTimeByBoss(refId,sceneId)
	for i,v in pairs(self.bossList) do
		local property = self:getWorldBossProperty(v.bossId)
		local monsterRefId = PropertyDictionary:get_monsterRefId(property)
		local monsterSceneId = PropertyDictionary:get_sceneRefId(property)
		
		if ((not sceneId)or (sceneId and sceneId==monsterSceneId)) and refId==monsterRefId  then
			return v.refreshTime
		end
	end
	return nil
end

--以时分秒形式返回
function WorldBossMgr:calculateTime(time)
	local cnt = time
	local hour = math.modf(cnt / (60*60))
	hour = string.format("%02d", hour)
	cnt = cnt - hour * (60*60)
	local min = math.modf(cnt / 60)
	min = string.format("%02d", min)
	cnt = cnt - min * 60
	local sec = cnt
	sec = string.format("%02d", sec)
	return hour, min, sec
end

function WorldBossMgr:getTimeword(time)
	local timeWord = " "
	if time and time ~= 0 then 
		local hours_3 = 3*60*60
		if time>hours_3 then --大于3个小时显示已击败
			timeWord = Config.Words[19511]
		else
			local hour, min, sec = self:calculateTime(time)
			if tonumber(hour)==0 then
				timeWord = min..":"..sec
			else
				timeWord = hour..":"..min..":"..sec
			end
		end
	else
		timeWord = Config.Words[23505]
	end	
	return timeWord
end