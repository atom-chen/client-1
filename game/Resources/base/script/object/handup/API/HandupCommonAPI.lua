--挂机的一些操作接口：拾取物品，保存配置等
--挂机相关接口
require"data.scene.scene"
local const_mpDrugList = 
{
	"item_drug_4",
	"item_drug_5",
	"item_drug_6",
	"item_drug_7",
	"item_drug_8",
	"item_drug_9",
}

local const_hpDrugList = 
{
	"item_drug_1",
	"item_drug_2",
	"item_drug_3",
	"item_drug_7",
	"item_drug_8",
	"item_drug_9",
}

--local const_handupRadius 				= 100	--挂机半径
local const_drugRefIdHead = "item_drug_"		--药品refId开头
HandupCommonAPI = HandupCommonAPI or BaseClass()

function HandupCommonAPI:__init()
	
end	

function HandupCommonAPI:switchPKMode(mode)
	if mode ~= GameWorld.Instance:getEntityManager():getHero():getPKStateID() then
		GameWorld.Instance:getEntityManager():getHero():changeHeroPKState(mode)
	end
end	

function HandupCommonAPI:getProfessionId()
	local professionId = PropertyDictionary:get_professionId(G_getHero():getPT())
	if (type(professionId) ~= "number") then
		professionId = 1
--		print("HandupConfigMgr:getProfessionId Warning. type(professionId) ~= number. set to 1")
	end
	return professionId
end

function HandupCommonAPI:sortByDistance(a, b, bMore)	
	local hero = G_getHero()
	if a == nil then
		return true
	end		
	return HandupCommonAPI:objDistance(a, hero) > HandupCommonAPI:objDistance(b, hero)	
end	

--判断当前是否有目标
function HandupCommonAPI:hasTarget(ttype, filterfunc, arg)
	local entityList = GameWorld.Instance:getEntityManager():getEntityListByType(ttype)
	if type(entityList) == "table" then
		for k, v in pairs(entityList) do
			if (not filterfunc) or filterfunc(v, arg) then
				return true
			end
		end
	end
	return false
end	

function HandupCommonAPI:getObj(entityType, filterfunc, arg, selectType)
	if selectType == E_SelectTargetType.Closest then
		return HandupCommonAPI:getClosestObj(entityType, filterfunc, arg)	
	elseif selectType == E_SelectTargetType.Random then
		return HandupCommonAPI:getRandomObj(entityType, filterfunc, arg)	
	else
		return nil
	end
end

function HandupCommonAPI:getRandomObj(entityType, filterfunc, arg)
	local list = GameWorld.Instance:getEntityManager():getEntityListByType(entityType)
	if type(list) ~= "table" then
		return nil
	end
	
	local random = math.random(1, size)	
	local tmpList = {}
	local size = 0
	for k, v in pairs(list) do
		if not filterfunc or filterfunc(v, arg) then
			table.insert(tmpList, v)
			size = size + 1
		end
	end
	if size > 0 then
		local random = math.random(1, size)
		return tmpList[random]
	else
		return nil
	end
end

function HandupCommonAPI:getClosestObj(entityType, filterfunc, arg)
	local list = GameWorld.Instance:getEntityManager():getEntityListByType(entityType)
	if type(list) ~= "table" then
		return nil
	end
	local obj = nil	
	local hero = G_getHero()
	local length = 1000
	local temp
	for k, v in pairs(list) do	
		temp = HandupCommonAPI:objDistance(v, hero)
		if length > temp and ((not filterfunc) or filterfunc(v, arg)) then
			length = temp
			obj = v
			if length < 4 then
				return obj
			end
		end 
	end
	--CCLuaLog("HandupCommonAPI:getClosestObj "..length)
	return obj
end

function HandupCommonAPI:getRandomObj(entityType, filterfunc)
	local list = GameWorld.Instance:getEntityManager():getEntityListByType(entityType)
	if not list then
		return nil
	end
	local obj = nil	
	local tmp = {}
	for k, v in pairs(list) do
		if (not filterfunc) or filterfunc(v) then
			table.insert(tmp, v)
		end
	end
	local size = #(tmp)
	if size > 0 then
		local random = math.random(1, size)
		return tmp[random]
	else
		return nil
	end
end

--自动补血
function HandupCommonAPI:autoAddHP(per)
	local config = G_getHandupConfigMgr():readHandupConfig()
	if (per <= config.HP_AutoAdd) then
		HandupCommonAPI:addHp()
	end
end

--自动补蓝
function HandupCommonAPI:autoAddMP(per)
	local config = G_getHandupConfigMgr():readHandupConfig()
	if (per <= config.MP_AutoAdd) then
		HandupCommonAPI:addMp()		
	end
end

--自动回城
function HandupCommonAPI:autoMoveToCity(per)
	if GameWorld.Instance:getMapManager():isInSafeArea(G_getHero():getCellXY()) then
		return -1
	end
	
	if not G_getBagMgr():isHuichengjuanCDReady() then
		return 0
	end
	
	local val = G_getHandupConfigMgr():getAutoMoveToCityValue()
	if (val and per <= val) then
		if HandupCommonAPI:useMoveToCity() then
			G_getBagMgr():resetHuichengjuanCD()
			return 1	--回城成功
		else
			return 0	--回城失败
		end
	else
		return -1 --不需要回城
	end
end

--使用回城卷
local const_moveToCityRefId = "item_moveto_2"
function HandupCommonAPI:useMoveToCity()
--[[	do 
		return false
	end--]]
	local item = G_getBagMgr():getItemByRefId(const_moveToCityRefId)
	if item and G_getBagMgr():getOperator():checkCanUseNormalItem(item) then
		G_getBagMgr():requestUseItem(item, 1)	
		return true
	end
	return false
end
	
function HandupCommonAPI:useDrug(isHp)
	local drugs = G_getBagMgr():getItemListByType(ItemType.eItemDrug)
	if (type(drugs) ~= "table") then
		return
	end		
	
	local takeIt = function(refId)
		for k, v in pairs(drugs) do
			if v:getRefId() == refId then
				drugs[k] = nil
				return v
			end
		end
		return nil
	end
	local list 
	if isHp then
		list = const_hpDrugList
	else
		list = const_mpDrugList
	end
	for k, v in pairs(list) do
		local obj = takeIt(v)
		if obj and G_getBagMgr():getOperator():checkCanUseNormalItem(obj) then
			G_getBagMgr():getOperator():doUseNormalItem(obj, 1)
			return
		end
	end
end	

function HandupCommonAPI:addMp()
	HandupCommonAPI:useDrug(false)
end	

function HandupCommonAPI:addHp()
	HandupCommonAPI:useDrug(true)
end		

--获取以x, y点为原点，r为半径的圆内的 ，且在地图上为非阻塞的点
--y坐标向下增长，x坐标向右增长
function HandupCommonAPI:getPointInRange(r, x1, y1, x2, y2)
	local distance = HandupCommonAPI:calculateDistance(x1, y1, x2, y2)
	local scale = (distance - r) / distance
	
	local retX = (x2 - x1) * scale + x1
	local retY = (y2 - y1) * scale + y1

	retX, retY = GameWorld.Instance:getMapManager():convertToAoiCell(retX, retY)
	local sfmap = SFMapService:instance():getShareMap()
	if sfmap and sfmap:IsBlock(retX, retY) then
		return x2, y2		
	else
		return retX, retY
	end
end	

--计算两个点的额距离
function HandupCommonAPI:calculateDistance(x1, y1, x2, y2)
	return ccpDistance(ccp(x1, y1), ccp(x2, y2))
end	

--计算两个目标的小格子距离
function HandupCommonAPI:objDistance(obj1, obj2)
	local x1, y1 = obj1:getCellXY()
	local x2, y2 = obj2:getCellXY()
	local distance1 = math.abs(x1 - x2)
	local distance2 = math.abs(y1 - y2)
	
	local distance
	if distance1 > distance2 then
		distance = distance1
	else
		distance = distance2
	end
	return distance
end

--计算两个目标的AOI坐标距离
function HandupCommonAPI:objAoiDistance(obj1, obj2)
	local x1, y1 = GameWorld.Instance:getMapManager():convertToAoiCell(obj1:getCellXY())
	local x2, y2 = GameWorld.Instance:getMapManager():convertToAoiCell(obj2:getCellXY())	
	local distance1 = math.abs(x1 - x2)
	local distance2 = math.abs(y1 - y2)
	
	local distance
	if distance1 > distance2 then
		distance = distance1
	else
		distance = distance2
	end
	return distance / const_aoiCellSize	
end

function HandupCommonAPI:getRandomPoint(radius)
	if radius == nil then
		radius = const_handupRadius
	end
	
	local cellX, cellY = G_getHero():getCellXY()
	
	local angle = math.random(0, 360)
	
	local retX = cellX + radius * math.cos(math.rad(angle))
	local retY = cellY + radius * math.sin(math.rad(angle))
	
	local sfmap = SFMapService:instance():getShareMap()	
	local maxLoop = 10	
	while sfmap and (sfmap:IsBlock(retX, retY)) and maxLoop > 0 do	
		angle = math.random(0, 360)
		retX = cellX + radius * math.cos(math.rad(angle))
		retY = cellY + radius * math.sin(math.rad(angle))
		maxLoop = maxLoop - 1
	end
	if (maxLoop <= 0) then
--		print("HandupCommonAPI:getRandomPoint maxLoop <= 0. now set to x=1 y=1")
		retX = 1
		retY = 1
	end
--	print("HandupCommonAPI:getRandomPoint retX="..retX.." retY="..retY)
	return ccp(retX, retY)
end	

--   145,105|75,90|52,56|112,74
function HandupCommonAPI:buildHandupPoints()
	local sceneRefId = GameWorld.Instance:getMapManager():getCurrentMapRefId()
	
	local data = GameData.Scene[sceneRefId]
	
	local handupPoints = {}
	if not data then
		return
	end	
	local sceneType = PropertyDictionary:get_kind(data)
	if sceneType ~= 3 then	--非副本场景不要从表里获取挂机点
		return
	end
	data = PropertyDictionary:get_handupPoint(data.property)
	if not data then
		return
	end				
	data = string.split(data, "|")
	if not data then
		return
	end	
	
	for k, v in pairs(data) do
		local tmp = string.split(v, ",")
		if table.size(tmp) == 2 then
			table.insert(handupPoints, ccp(tonumber(tmp[1]), tonumber(tmp[2])))
		end
	end
	return handupPoints
end