require("common.baseclass")
require("object.nearby.NearbyPlayer")
require("object.nearby.NearbyMonster")

NearbyManager = NearbyManager or BaseClass()

function NearbyManager:__init()
	self.nearbyPlayerObjList = {}
	self.nearbyMonsterList = {}	
	self.nearbyTempPlayerObjList = {}
	self.currentSceneId = nil		
end

function NearbyManager:__delete()
	self:clear()
end

function NearbyManager:clear()
	if not table.isEmpty(self.nearbyPlayerObjList) then
		for key,v in pairs(self.nearbyPlayerObjList) do
			if v then
				v:DeleteMe()
				v = nil				
			end
		end
		self.nearbyPlayerObjList = {}
	end

	if not table.isEmpty(self.nearbyTempPlayerObjList) then
		for key,v in pairs(self.nearbyTempPlayerObjList) do
			if v then
				v:DeleteMe()
				v = nil				
			end
		end
		self.nearbyTempPlayerObjList = {}
	end	
	
	if not table.isEmpty(self.nearbyMonsterList) then
		for key,v in pairs(self.nearbyMonsterList) do
			if v then
				v:DeleteMe()
				v= nil				
			end
		end
		self.nearbyMonsterList = {}
	end	
end
--玩家列表
function NearbyManager:getPlayerList()
	self:createPlayerList()		
	return self.nearbyPlayerObjList
end	
--createPlayerList
function NearbyManager:createPlayerList()
	local entigyMgr = GameWorld.Instance:getEntityManager()
	local playerList = entigyMgr:getPlayerList()
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	for key, v in pairs(self.nearbyPlayerObjList) do
		v:DeleteMe()
		v = nil
	end
	self.nearbyPlayerObjList = {}

	for tkey, tv in pairs(self.nearbyTempPlayerObjList) do
		if tv then
			tv:DeleteMe()
			tv = nil
		end
	end
	self.nearbyTempPlayerObjList = {}
	
	local heroPkModel = G_getHero():getPKStateID()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	local factionName = nil
	if factionMgr:getFactionInfo() then
		factionName = factionMgr:getFactionInfo().factionName
	end
	for key,player in pairs(playerList) do	
		local id = player.id
		local pt = player:getPT()
		local name = PropertyDictionary:get_name(pt)
		local level = PropertyDictionary:get_level(pt)
		local professionId = PropertyDictionary:get_professionId(pt)
		local pkMode = PropertyDictionary:get_pkModel(pt)
		local state = player:getState():getState()
		local unionName = PropertyDictionary:get_unionName(pt)		
		local nameColor = PropertyDictionary:get_nameColor(pt)
		
		if state ~= CharacterState.CharacterStateDead then
			local playerObj = NearbyPlayer.New()
			playerObj:setPlayerServerId(id)
			playerObj:setPlayerName(name)
			playerObj:setPlayerLevel(level)
			playerObj:setPlayerProfessionId(professionId)		
			playerObj:setState(state)
			playerObj:setPkModel(pkMode)
			playerObj:setUnionName(unionName)
			playerObj:setNameColor(nameColor)
			--根据英雄自己的PK模式 筛选需要优先显示的PK对象
			--和平模式不需要筛选
			--公会模式筛选本公会成员
			--善恶模式筛选PK值大于200成员
			--组队暂不处理 （同全体）
			--全体攻击不需筛选
						
			if heroPkModel == E_HeroPKState.statePeace or heroPkModel == E_HeroPKState.stateWhole  then
				table.insert(self.nearbyPlayerObjList, playerObj)
			elseif heroPkModel == E_HeroPKState.stateFaction then
				if factionName and factionName == unionName then
					table.insert(self.nearbyTempPlayerObjList, playerObj)
				else
					table.insert(self.nearbyPlayerObjList, playerObj)
				end	
			elseif heroPkModel == E_HeroPKState.stateQueue   then --组队模式
				if teamMgr:isMyTeamate(id) then
					table.insert(self.nearbyTempPlayerObjList, playerObj)
				else
					table.insert(self.nearbyPlayerObjList, playerObj)
				end
			elseif heroPkModel == E_HeroPKState.stateGoodOrEvil then
				if nameColor >= 2 then
					table.insert(self.nearbyPlayerObjList, playerObj)
				else
					table.insert(self.nearbyTempPlayerObjList, playerObj)
				end
			end
		end			
	end
	self:sortPlayerList(heroPkModel)
	self:buildPlayerList()
	self:removeDeathPlayer()
end	

function NearbyManager:buildPlayerList()
	if self.nearbyTempPlayerObjList and table.size(self.nearbyTempPlayerObjList) > 0 then	
		for k,playerObj in  pairs(self.nearbyTempPlayerObjList) do
			table.insert(self.nearbyPlayerObjList,playerObj)			
		end
	end
end

function NearbyManager:getNearByViewRedNameCount()
	local heroPkModel = G_getHero():getPKStateID()
	if heroPkModel == E_HeroPKState.statePeace then
		return 0
	elseif heroPkModel == E_HeroPKState.stateWhole  then
		return table.size(self.nearbyPlayerObjList)
	elseif heroPkModel == E_HeroPKState.stateFaction or heroPkModel == E_HeroPKState.stateQueue  or heroPkModel == E_HeroPKState.stateGoodOrEvil then
		return  table.size(self.nearbyPlayerObjList) - table.size(self.nearbyTempPlayerObjList)	
	end	
	
end

--删除死亡玩家
function NearbyManager:removeDeathPlayer()
	for key,player in pairs(self.nearbyPlayerObjList) do
		if player:getState() == CharacterState.CharacterStateDead then
			for index, templayer in pairs(self.nearbyTempPlayerObjList)do
				if templayer:getPlayerServerId() == self.nearbyPlayerObjList[key]:getPlayerServerId() then
					templayer:DeleteMe()
					templayer = nil
				end
			end
			self.nearbyPlayerObjList[key]:DeleteMe()
			self.nearbyPlayerObjList[key] = nil
		end			
	end
end

--boss或者精英列表
function NearbyManager:createNeedShowMonsterList()	
	local mapMgr = GameWorld.Instance:getMapManager()
	local sceneId = mapMgr:getCurrentMapRefId()
	local sceneMonsterList = self:getSceneMonsterList()	
	--场景改变
	if self.currentSceneId ~= sceneId then	
		for key,v in pairs(self.nearbyMonsterList) do
			if v then
				v:DeleteMe()
				v = nil					
			end
		end
		self.nearbyMonsterList = {}			
				
		local staticMonsterList = self:createStaticMonsterList(sceneId)
		self.currentSceneId = sceneId
		self:setIsReloadMonsterList(true)
		for key,monster in pairs(staticMonsterList) do
			local refId = monster.monsterRefId			
			local quanlity = self:getMonsterQuanlityByRefId(refId)
			if quanlity and quanlity > 1 then
				local nearbyMonster = NearbyMonster.New()
				nearbyMonster:setMonsterQuanlity(quanlity)
				nearbyMonster:setMonsterRefId(refId)
				nearbyMonster:setMonsterTotalCount(monster.monsterRefreshCount)		
				nearbyMonster:setMonsterName(self:getMonsterNameByRefId(refId))	
				nearbyMonster:setMonsterLevel(self:getMonsterLevelByRefId(refId))
				local currentCount = 0
				for key1,sceneMonster in pairs(sceneMonsterList) do
					local sceneMonsterRefId = sceneMonster.refId
					if refId==sceneMonsterRefId then
						currentCount = currentCount + 1
					end
				end
				nearbyMonster:setMonsterCurrentCount(currentCount)							
				self:insertNearbyMonster(nearbyMonster)
			end
		end	
		self:sortMonsterList()
	--场景不变
	else	
		for key,monster in pairs(self.nearbyMonsterList) do
			local currentCount = 0
			local refId = monster:getMonsterRefId()
			for key1,sceneMonster in pairs(sceneMonsterList) do
				local sceneMonsterRefId = sceneMonster.refId
				if refId==sceneMonsterRefId then
					currentCount = currentCount + 1
				end
			end
			monster:setMonsterCurrentCount(currentCount)
		end
		self:setIsReloadMonsterList(false)
	end		
end
--场景静态怪物列表
function NearbyManager:createStaticMonsterList(sceneId)
	local staticMonsterList = GameData.Scene[sceneId].monster	
	return staticMonsterList
end

--场景怪物列表
function NearbyManager:getSceneMonsterList()
	local entigyMgr = GameWorld.Instance:getEntityManager()
	local sceneMonsterList = {}
	sceneMonsterList = entigyMgr:getMonsterList()
	return sceneMonsterList
end
--对怪物按照quanlity排序
function NearbyManager:sortMonsterList()
	local sortFun = function (a, b)
		if a:getMonsterQuanlity() >  b:getMonsterQuanlity() then
			return true
		else
			return a:getMonsterLevel() > b:getMonsterLevel()
		end			
	end
	table.sort(self.nearbyMonsterList, sortFun)	
end
--
function NearbyManager:getNeedShowMonsterList()
	self:createNeedShowMonsterList()		
	return self.nearbyMonsterList
	
end	

function NearbyManager:sortPlayerList(pkModel)
	
	local sortFun = function (a, b)
		local modelA = a:getPkModel()
		local modelB = b:getPkModel()
		if modelA and modelB then
			if modelA > modelB then
				return true
			elseif modelA == modelB then--模式相同 比较PK值
				if a:getNameColor() > b:getNameColor() then
					return true
				elseif a:getNameColor() == b:getNameColor() then
					if a:getPlayerLevel() > b:getPlayerLevel() then
						return true
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end		
	end
	
	local sortGoodOrEvilFun = function(a,b)
		if (not a) or (not a.getPkValue) then
			return false
		elseif (not b) or (not b.getPkValue) then
			return true
		end
		if a:getNameColor() > b:getNameColor() then
			return false
		elseif a:getNameColor() == b:getNameColor() then
			if a:getPlayerLevel() > b:getPlayerLevel() then
				return true
			else
				return false
			end
		else
			return true
		end
	end
	
	if pkModel == E_HeroPKState.statePeace or pkModel == E_HeroPKState.stateWhole  or pkModel == E_HeroPKState.stateQueue  then
		table.sort(self.nearbyPlayerObjList, sortFun)
	elseif pkModel == E_HeroPKState.stateFaction then
		table.sort(self.nearbyPlayerObjList, sortFun)
	elseif pkModel == E_HeroPKState.stateGoodOrEvil then
		table.sort(self.nearbyPlayerObjList, sortGoodOrEvilFun)
	end							
end

function NearbyManager:updateNearByPlayer()
	GlobalEventSystem:Fire(GameEvent.EventNearByPlayerStateChange)	
end

--避免同类的怪物重复插入
function NearbyManager:insertNearbyMonster(nearbyMonster)
	for key,monster in pairs(self.nearbyMonsterList) do
		if monster:getMonsterRefId() == nearbyMonster:getMonsterRefId() then
			local totalCount = monster:getMonsterTotalCount() + nearbyMonster:getMonsterTotalCount()
			monster:setMonsterTotalCount(totalCount)
			nearbyMonster:DeleteMe()
			return
		end
	end
	table.insert(self.nearbyMonsterList, nearbyMonster)
end

--通过refid获得怪物PT
function NearbyManager:getMonsterPTByRefId(refId)
	if refId and string.isLegal(refId) then
		local monsterData = GameData.Monster[refId]
		return monsterData.property
	else
		return {}
	end
	
end
--通过refid获得怪物quanlity
function NearbyManager:getMonsterQuanlityByRefId(refId)
	local pt = self:getMonsterPTByRefId(refId)
	if pt then
		local quanlity = PropertyDictionary:get_quality(pt)
		return quanlity
	end	
	return 0	
end
--通过refid获得怪物name
function NearbyManager:getMonsterNameByRefId(refId)
	local pt = self:getMonsterPTByRefId(refId)
	if pt then
		local name = PropertyDictionary:get_name(pt)
		return name		
	else
		return ""
	end		
end
--通过refid获得怪物level
function NearbyManager:getMonsterLevelByRefId(refId)
	local pt = self:getMonsterPTByRefId(refId)
	if pt then
		local level = PropertyDictionary:get_level(pt)
		return level
	else
		return 0
	end		
end

function NearbyManager:getIsReloadMonsterList()
	return self.needReLoad
end

function NearbyManager:setIsReloadMonsterList(bNeedReload)
	self.needReLoad = bNeedReload
end
--nearbyView是否正在显示
function NearbyManager:setNearByViewIsShowing(bShow)
	self.bShow = bShow
end

function NearbyManager:getNearByViewIsShowing()
	return self.bShow
end
--是否更新playerList
function NearbyManager:setIsUpdatePlayerList(bUpdate)
	self.bPlayerUpdate = bUpdate
end

function NearbyManager:getIsUpdatePlayerList()
	return self.bPlayerUpdate
end
--是否更新monsterList
function NearbyManager:setIsUpdateMonsterList(bUpdate)
	self.bMonsterUpdate = bUpdate
end

function NearbyManager:getIsUpdateMonsterList()
	return self.bMonsterUpdate
end




