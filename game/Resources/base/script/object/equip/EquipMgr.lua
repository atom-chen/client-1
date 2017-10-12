--  装备（数据管理）
require("common.baseclass")
require("data.knight.knight")

local const_vs = 5 		-- const_verticalSpacing
local const_hs = 8		-- const_horizontalSpacing

EquipMgr = EquipMgr or BaseClass()
local g_simulator = nil
	
function EquipMgr:__init()
	g_simulator = SFGameSimulator:sharedGameSimulator()	
	self.heroEquipInfo = 
	{
		[E_BodyAreaId.eWeapon] 		= {name = Config.Words[10197], num = 1, image = "weapon_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eNecklace, 0}, offset = ccp(13, -46), view = nil, layout = LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE}}},
		
		[E_BodyAreaId.eCloth] 		= {name = Config.Words[10198], num = 1, image = "clothes_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eHelmet, 0}, pre = {E_BodyAreaId.eBracelet, 1}, offset = ccp(0, const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE}}},
		
		[E_BodyAreaId.eHelmet] 		= {name = Config.Words[10199], num = 1, image = "armet_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eMedal, 0}, pre = {E_BodyAreaId.eCloth, 0}, offset = ccp(0, const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE}}},
		
		[E_BodyAreaId.eBelt] 		= {name = Config.Words[10200], num = 1, image = "belt_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eShoe, 0}, pre = {E_BodyAreaId.eRing, 0}, offset = ccp(0, -const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE}}},
		
		[E_BodyAreaId.eShoe] 		= {name = Config.Words[10201], num = 1, image = "shoes_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eRing, 1}, pre = {E_BodyAreaId.eBelt, 0}, offset = ccp(215, 0), view = nil, layout = LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE}}},
			
		[E_BodyAreaId.eNecklace] 	= {name = Config.Words[10202], num = 1, image = "necklace_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eBracelet, 0}, pre = {E_BodyAreaId.eWeapon, 0}, offset = ccp(0,  -const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE}}},
		
		[E_BodyAreaId.eBracelet] 	= {name = Config.Words[10203], num = 2, image = "bangle_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eRing, 0}, pre = {E_BodyAreaId.eNecklace, 0}, offset = ccp(0, -const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE}, 
															[1] = {nnext = {E_BodyAreaId.eCloth, 0}, pre = {E_BodyAreaId.eRing, 1}, offset = ccp(0, const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE}}},
														
		[E_BodyAreaId.eRing] 		= {name = Config.Words[10204], num = 2, image = "ring_bg.png", grids  = {[0] = {nnext = {E_BodyAreaId.eBelt, 0}, pre = {E_BodyAreaId.eBracelet, 0}, offset = ccp(0, -const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE},
														   [1] = {nnext = {E_BodyAreaId.eBracelet, 1}, pre = {E_BodyAreaId.eShoe, 0}, offset = ccp(0, const_vs), view = nil, layout = LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE}}},
																
		[E_BodyAreaId.eMedal] 		= {name = Config.Words[10205], 	num = 1, image = "honor_bg.png", grids  = {[0] = {pre = {E_BodyAreaId.eHelmet, 0}, offset = ccp(-const_hs,  0), view = nil, layout = LAYOUT_CENTER_Y + LAYOUT_LEFT_OUTSIDE}}},															
	}
	self.bNeedUpdate = false
end	

function EquipMgr:clear()
	self.equipList = {}
	self.OtherPlayerequipList = {}
	self.bNeedUpdate = true
end

function EquipMgr:getHeroEquipInfo()
	return self.heroEquipInfo
end

--格式：list[bodyAreaId][posId]
function EquipMgr:getEquipList()
	return self.equipList
end			

function EquipMgr:getPutonPos()
	return self.putonPos
end

function EquipMgr:setPutonPos(pos)
	self.putonPos = pos
end


function EquipMgr:getEquipArray()
	if (self.equipList == nil) then
		return nil
	end
	
	local array = {}
	for index, value in pairs(self.equipList) do
		for i, v in pairs(value) do
			table.insert(array, v)					
		end
	end
	return array
end

--检测是否有某件装备
function EquipMgr:hasEquip(refId)
	if (self.equipList == nil) then
		return false
	end
	for index,value in pairs(self.equipList) do
		for i,v in pairs(value) do
			if(refId == v:getRefId()) then
				return true
			end
		end
	end
	return false
end
--根据refid返回Object
function  EquipMgr:getEquipByRefId(refId)
	for index,value in pairs(self.equipList) do
		for i,v in pairs(value) do
			if(refId == v:getRefId()) then
				return v
			end
		end
	end
	return nil
end

--根据BodyAreaId返回所有装备
function EquipMgr:getEquipListByBodyAreaId(bodyAreaId)
	if (self.equipList) then
		return self.equipList[bodyAreaId]
	end
	return nil
end

--根据BodyAreaId获取该部位的count
function EquipMgr:getPosCountByBodyAreaId(bodyAreaId)
	local ret = -1
	if self:getHeroEquipInfo()[bodyAreaId] then
		ret = self:getHeroEquipInfo()[bodyAreaId].num
	end
	return ret
end

--获取可穿戴的posID
function EquipMgr:getPutOnPosIdByBodyAreaId(bodyAreaId)
	if (self.equipList == nil) then
		return nil
	end	
	if ((bodyAreaId >= E_BodyAreaId.eWeapon) and (bodyAreaId <= E_BodyAreaId.eWing)) then	
		if (self.equipList[bodyAreaId] == nil) then
			return 0
		else			
			local minFpEquip = nil
			for i = 1, self:getHeroEquipInfo()[bodyAreaId].num do	
				if ((self.equipList[bodyAreaId][i - 1]) == nil) then
					return i - 1
				end
				if (minFpEquip) then
					local fpOld = PropertyDictionary:get_fightValue(minFpEquip:getPT())
					local fpNew = PropertyDictionary:get_fightValue(self.equipList[bodyAreaId][i - 1]:getPT())
					if (fpNew < fpOld) then
						minFpEquip = self.equipList[bodyAreaId][i - 1]
					end
				else
					minFpEquip = self.equipList[bodyAreaId][i - 1]
				end
			end
			return minFpEquip:getPosId()
		end
	end	
end	

--将equipObj与 身上所穿戴的同类的装备中战力最低的一个装备 进行战力比较
--返回1表示equipObj大于身上的，返回2表示equipObj小于身上的，返回3表示equipObj等于身上的，返回nil表示出错
--[[E_CompareRet =
{
	Greater = 1,
	Smaller = 2,
	Equal = 3,
	Error 	= -1
}--]]
function EquipMgr:compareFp(equipObj)
	if (equipObj == nil) then
		return nil
	end
	local bodyAreaId = 	PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property)
	if (self.equipList == nil) then
		return E_CompareRet.Greater
	end								
	if (self.equipList[bodyAreaId] == nil) then
		return E_CompareRet.Greater
	end
	--local ret = E_CompareRet.Smaller
	local fp = PropertyDictionary:get_fightValue(equipObj:getPT())

	if not self:isBodyAreaFull(bodyAreaId) then	
		return E_CompareRet.Greater
	end
	
	local fpValue = 0
	for pos, value in pairs(self.equipList[bodyAreaId]) do
		fpValue = PropertyDictionary:get_fightValue(value:getPT())
		if fp > fpValue then		
			return E_CompareRet.Greater
		end
	end
	return E_CompareRet.Smaller
end

--将equipObj与 身上所穿戴的同类的装备中等级最低的一个装备 进行等级比较
--返回1表示equipObj大于身上的，返回2表示equipObj小于身上的，返回3表示equipObj等于身上的，返回nil表示出错
--[[E_CompareRet =
{
	Greater = 1,
	Smaller = 2,
	Equal = 3,
	Error 	= -1
}--]]
function EquipMgr:compareLp(equipObj)
	if (equipObj == nil) then
		return nil
	end
	local bodyAreaId = PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property)
	if (self.equipList == nil) then
		return E_CompareRet.Greater
	end								
	if (self.equipList[bodyAreaId] == nil) then
		return E_CompareRet.Greater
	end

	if not self:isBodyAreaFull(bodyAreaId) then	
		return E_CompareRet.Greater
	end
	
	local Lp = PropertyDictionary:get_equipLevel(equipObj:getStaticData().property)
	local heroLevel = 0
	for pos, value in pairs(self.equipList[bodyAreaId]) do
		heroLevel = PropertyDictionary:get_equipLevel(value:getStaticData().property)
		if (Lp > heroLevel) then		
			return E_CompareRet.Greater
		end
	end
	return E_CompareRet.Smaller
end

--将equipObj与 玩家等级比较
--返回1表示equipObj大于身上的，返回2表示equipObj小于身上的，返回3表示equipObj等于身上的，返回nil表示出错
--[[E_CompareRet =
{
	Greater = 1,
	Smaller = 2,
	Equal = 3,
	Error 	= -1
}--]]
function EquipMgr:compareWithPlayerLevel(equipObj)
	if (equipObj == nil) then
		return nil
	end		
	local equipLevel = PropertyDictionary:get_equipLevel(equipObj:getStaticData().property)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local heroLevel = PropertyDictionary:get_level(hero:getPT())
	if heroLevel < equipLevel then
		return E_CompareRet.Greater
	end
	return E_CompareRet.Smaller
end

--判断某个部位的装备是否满
function EquipMgr:isBodyAreaFull(bodyArea)
	local data = self:getHeroEquipInfo()[bodyArea]
	if not data then
		return false
	end
	for iii, v in pairs(data.grids) do
		if not self:hasEquipWithBodyArea(bodyArea, iii) then
			return false			
		end
	end
	return true
end

--检查某个部位某个pos是否有装备
function EquipMgr:hasEquipWithBodyArea(bodyArea, pos)
	if (self.equipList == nil or self.equipList[bodyArea] == nil) then
		return false
	end		
	for i, v in pairs(self.equipList[bodyArea]) do
		if pos == nil then
			if(bodyArea == v:getBodyAreaId()) and G_getBagMgr():getOperator():checkCanPutOnEquip(v) then
				return true
			end
		else
			if(bodyArea == v:getBodyAreaId() and pos == i) and G_getBagMgr():getOperator():checkCanPutOnEquip(v) then
				return true
			end
		end
	end
	return false
end

function EquipMgr:getMinFpEquipObj(list)
	local minFpEquip = nil
	if (list ~= nil) then
		for k, v in pairs(list) do
			if (minFpEquip == nil) then
				minFpEquip = v
			else
				local fp = PropertyDictionary:get_fightValue(v:getPT())	
				if (fp < PropertyDictionary:get_fightValue(minFpEquip:getPT())) then
					minFpEquip = v
				end	
			end			
		end
	end
	return minFpEquip
end

function EquipMgr:setEquipList(list)
	self.equipList = list
end	

function EquipMgr:updateEquipList(eventType, map)
--	print("BagMgr:updateItemMap eventType="..eventType)	
	if (E_UpdataEvent.Add == eventType) then	
		for bodyAreaId, equipArray in pairs(map) do		
			for pos, equip in pairs(equipArray) do		
				if (self.equipList[bodyAreaId] == nil) then
					self.equipList[bodyAreaId] = {}
				end				
				self.equipList[bodyAreaId][pos] = equip
			end
		end
		GlobalEventSystem:Fire(GameEvent.EventEquipUpdate, E_UpdataEvent.Add, map)
	elseif (E_UpdataEvent.Delete == eventType) then
		for bodyAreaId, equipArray in pairs(map) do		
			for pos, equip in pairs(equipArray) do		
				if ((self.equipList[bodyAreaId] ~= nil) and (self.equipList[bodyAreaId][pos])) then
					self.equipList[bodyAreaId][pos] = nil
				end	
			end
		end
		GlobalEventSystem:Fire(GameEvent.EventEquipUpdate, E_UpdataEvent.Delete, map)
	elseif (E_UpdataEvent.Modify == eventType) then		
		local addEquips = {}
		local modifiedEquips = {}
		local hasModified = false
		local hasAdded = false
		for bodyAreaId, equipArray in pairs(map) do		
			for pos, equip in pairs(equipArray) do		
				if (self.equipList[bodyAreaId] == nil) then		--增加
					self.equipList[bodyAreaId] = {}
					self.equipList[bodyAreaId][pos] = equip
					if addEquips[bodyAreaId] == nil then
						addEquips[bodyAreaId] = {}
					end
					addEquips[bodyAreaId][pos] = equip
					hasAdded = true
				else
					if self.equipList[bodyAreaId] == nil then
						self.equipList[bodyAreaId] = {}
					end
					self.equipList[bodyAreaId][pos] = equip	--改动的时候，服务端会将Equip的完整属性发回来，所以可以直接替换
					
					if modifiedEquips[bodyAreaId] == nil then
						modifiedEquips[bodyAreaId] = {}
					end
					modifiedEquips[bodyAreaId][pos] = equip
					hasModified = true
				end
			end
		end
		if hasAdded then
			GlobalEventSystem:Fire(GameEvent.EventEquipUpdate, E_UpdataEvent.Add, addEquips)
		end				
		if hasModified then
			GlobalEventSystem:Fire(GameEvent.EventEquipUpdate, E_UpdataEvent.Modify, modifiedEquips)
		end
	end	
end

function EquipMgr:requestEquipList()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_Equip_List)
	g_simulator:sendTcpActionEventInLua(writer)	
end	

function EquipMgr:requestEquipPutOn(itemObj, bodyAreaId, posId)
	if (itemObj == nil) or (type(bodyAreaId) ~= "number")  or (type(posId) ~= "number") then
		return
	end
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_Equip_PutOn)
	writer:WriteShort(itemObj:getGridId())
	writer:WriteChar(bodyAreaId)
	writer:WriteChar(posId)
	g_simulator:sendTcpActionEventInLua(writer)	
end	

function EquipMgr:requestEquipUnLoad(equipObj)
	if (equipObj == nil) then
		return
	end
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_Equip_UnLoad)	
	writer:WriteChar(equipObj:getBodyAreaId())
	writer:WriteChar(equipObj:getPosId())
	g_simulator:sendTcpActionEventInLua(writer)	
end	

function EquipMgr:requestOtherPlayerEquipList(playerId)
	if type(playerId) ~= "string" then
		return
	end
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_OtherPlayer_EquipList)
	StreamDataAdapter:WriteStr(writer,playerId)	
	simulator:sendTcpActionEventInLua(writer)	
end	
	
function EquipMgr:setOtherPlayerId(playerId)	
	self.OtherPlayerId = playerId
end

function EquipMgr:getOtherPlayerId()
	return self.OtherPlayerId
end

--其他玩家的装备列表
function EquipMgr:setOtherPlayerEquipList(quipList)
	self.OtherPlayerequipList = quipList
end

function EquipMgr:getOtherPlayerEquipList()
	return self.OtherPlayerequipList
end

--是否断线重连要更新武器列表
function EquipMgr:setNeedUpdateEquipList(bNeedUpdate)
	self.bNeedUpdate = bNeedUpdate
end

function EquipMgr:getNeedUpdateEquipList()
	return self.bNeedUpdate
end

function EquipMgr:getKnightNameByRefid(refId)
	if refId then
		local data = GameData.Knight[refId]
		if data then
			local property = data.property
			if property then
				return property.name
			end
		end
	end		
end

--获取当前背包同位置高于身上装备的战力的装备数目
function EquipMgr:getGreaterEquipCount()
	local equipList = G_getBagMgr():getItemListByType(ItemType.eItemEquip)
	local count = 0
	for k ,v in pairs(equipList) do
		if self:compareFp(v) == E_CompareRet.Greater  and G_getBagMgr():getOperator():checkCanPutOnEquip(v) then
			count = count + 1
		end
	end
	return count
end