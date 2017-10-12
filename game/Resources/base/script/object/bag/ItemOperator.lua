--  使用普通物品/出卖普通物品/
--  穿戴装备物品/卸下装备物品/出卖装备物品/
require("common.baseclass")
require("object.bag.BagDef")
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("object.equip.EquipDef")
require("object.equip.EquipMgr")
require("data.item.equipStrengthening")

ItemOperator = ItemOperator or BaseClass()
local g_bagMgr = nil
local constMessageSize = CCSizeMake(350, 260)
function ItemOperator:create()
	return ItemOperator.New()
end

function ItemOperator:__init()
end	

--[[
使用普通物品或 装备物品
参数：
	ttype	: 操作类型
	itemObj	: 需要使用的物品
	count  	: 使用数量
返回：
	ret: 	false/true
	des:	失败描述	
	
E_OperateType = 
{
	Use = 1,
	PutOn = 2, 
	Sell = 3,
	UnLoad = 4
}		
--]]
function ItemOperator:operateItem(ttype, itemObj)
	if (ttype == E_OperateType.Use) then	
		self:useNormalItem(itemObj)
	elseif (ttype == E_OperateType.PutOn) then
		self:putOnEquip(itemObj)
	elseif (ttype == E_OperateType.Sell) then
		self:sellItem(itemObj)
	elseif (ttype == E_OperateType.UnLoad) then
		self:unLoadEquip(itemObj)
	end
end


-- 出卖物品
function ItemOperator:sellItem(itemObj)		
	local ret, des = self:checkCanSellItem(itemObj) 
	if (ret == false) then
		UIManager.Instance:showSystemTips(des)
		return false, des
	else
		local stackNum = PropertyDictionary:get_number(itemObj:getPT())		
		if (stackNum > 1) then	
			self:askSellNum(itemObj, stackNum)
		else
			self:confirmByQualityBeforeSell(itemObj, 1)			
		end
	end
	return true
end	

-- 使用普通物品
function ItemOperator:useNormalItem(itemObj)		
	local ret, des = self:checkCanUseNormalItem(itemObj) 
	if (ret == false) then
		UIManager.Instance:showSystemTips(des)
		return false, des
	else
		
		local stackNum = PropertyDictionary:get_number(itemObj:getPT())		
		if (stackNum > 1 and PropertyDictionary:get_canBatchUse(itemObj:getStaticData().property) == 1) then	
			self:askUseNormalItemNum(itemObj, stackNum)
		else
			self:doUseNormalItem(itemObj, 1)			
		end
	end
	return true
end

-- 穿戴装备物品
function ItemOperator:putOnEquip(equipObj, pos)
	local ret, des = self:checkCanPutOnEquip(equipObj) 
	if (ret == false) then
		UIManager.Instance:showSystemTips(des)
		return false, des
	else
		self:comfirmByBindTypeBeforePutOn(equipObj, pos)
	end
	return true
end

-- 卸下装备物品
function ItemOperator:unLoadEquip(equipObj)
	local ret, des = self:checkCanUnLoadEquip(equipObj) 
	if (ret == false) then
		UIManager.Instance:showSystemTips(des)
		return false, des
	else
		self:doUnLoadEquip(equipObj)
	end
	return true
end


--[[检测是否能使用普通物品
返回
	ret: false/true
	des: 不能使用的原因	
限制：
1)	玩家等级限制
a)	0为不限制
b)	n(n＞0)为≥n级才可使用

2)	爵位等级限制
a)	0为不限制
b)	n(n＞0)为≥n级才可以使用

3)	每天最大使用次数限制
/* 某些绑定元宝购买的道具，要有每天使用次数限制。如绑定元宝购买的功勋令牌，成就令牌，荣誉令牌 */
a)	0为不限制
b)	n(n>0)为每天使用次数≤n次

4)	过期时间
//用于限时礼包，过期后消失。有2种限制方式
a)	x小时后消失
b)	指定日期和时间点，过了时间点后消失

5)	允许使用时间
//例如，n天后才可开启的礼包，吸引玩家登录。有2种方式
a)	x小时后才可以使用
b)	指定日期和时间点，过了时间点后才可使用
--]]

function ItemOperator:checkCanUseNormalItem(itemObj) 
	local hero = GameWorld.Instance:getEntityManager():getHero()
	
		if (PropertyDictionary:get_canUse(itemObj:getStaticData().property) ~= 1) then
		return false, Config.Words[10179]
	end
	
	if (PropertyDictionary:get_level(hero:getPT()) < PropertyDictionary:get_useLevel(itemObj:getStaticData().property)) then
		return false, Config.Words[10180]
	end
	if (PropertyDictionary:get_knight(hero) < PropertyDictionary:get_useKnight(itemObj:getStaticData().property)) then
		return false, Config.Words[10181]
	end
	
	if not G_getBagMgr():isCommonCDReady() then	
		return false, Config.Words[10182]
	end	
			
	if itemObj:getType() == ItemType.eItemDrug then
		if (not G_getBagMgr():isDrugCDReady(itemObj)) then	
			return false, Config.Words[10183]
		end	 
	end
	
	return true
end	

--[[检测是否能穿戴装备物品
返回
	ret: false/true
	des: 不能穿戴的原因	
职业Id	性别	穿戴等级

E_UnableEquipType = 	--不能穿戴的原因
{
	Level = 1,
	Profression = 2,
	Gender = 3,
	Knight = 4,
}
--]]
function ItemOperator:checkCanPutOnEquip(equipObj)
	local hero = GameWorld.Instance:getEntityManager():getHero()
		
	local professionId = PropertyDictionary:get_professionId(equipObj:getStaticData().property)
	if ((professionId ~= 0) and (professionId ~= PropertyDictionary:get_professionId(hero:getPT()))) then
		return false, string.format(Config.Words[15025]), E_UnableEquipType.Profression
	end		
	
	local genderIdgg = PropertyDictionary:get_gender(equipObj:getStaticData().property)	
	if ((genderIdgg ~= 0) and (genderIdgg ~= PropertyDictionary:get_gender(hero:getPT()))) then
		return false, string.format(Config.Words[15026]), E_UnableEquipType.Gender
	end			
	
	if (PropertyDictionary:get_level(hero:getPT()) < PropertyDictionary:get_equipLevel(equipObj:getStaticData().property)) then
		return false, Config.Words[15027], E_UnableEquipType.Level
	end
	
	local limitKnightLevel = PropertyDictionary:get_equipKnight(equipObj:getStaticData().property)
	local heroKnight = PropertyDictionary:get_knight(hero:getPT())
	if heroKnight < limitKnightLevel then
		return false, Config.Words[15036], E_UnableEquipType.Knight
	end
	--添加第三个返回值，当等级相同时，把提示LV变为绿色
	return true, "", E_UnableEquipType.Level
end

--[[检测是否能出卖物品
返回
	ret: false/true
	des: 不能出卖的原因	--]]
function ItemOperator:checkCanSellItem(itemObj)
--[[	do 
		return true
	end--]]
	
	if (PropertyDictionary:get_isCanSale(itemObj:getStaticData().property) == 0) then
		return false, string.format("该商品不能出售")
	end
	return true
end	

--[[检测是否能卸载装备
返回
	ret: false/true
	des: 不能卸载的原因	--]]
function ItemOperator:checkCanUnLoadEquip()	
	
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
	if (bagMgr:isFull()) then
		return false, "背包满了，先去卖点东西吧"
	end
	return true
end

-- 如果物品是珍稀的，则提示是否出卖确认
function ItemOperator:confirmByQualityBeforeSell(item, num)
	--[[local quality = PropertyDictionary:get_quality(item:getStaticData().property)		
		
	if	(quality == 3 or quality == 4) then--]]
	if G_IsHighQuilatyEquip(item) then
		local onMsgBoxCallBack = function(unused, text, id)
			if (id == 2) then
				self:doSellItem(item, num)	
				GlobalEventSystem:Fire(GameEvent.EventHideNormalItemDetailView)
				GlobalEventSystem:Fire(GameEvent.EventHideEquipItemDetailView)
			end
		end			
		--UIManager.Instance:showMsgBox(string.format("%s是珍稀物品，\n确定出售吗？", PropertyDictionary:get_name(item:getStaticData().property)), self, onMsgBoxCallBack, constMessageSize)
		local word = string.format(Config.Words[10207], PropertyDictionary:get_name(item:getStaticData().property))
		local msg = showMsgBox(word,E_MSG_BT_ID.ID_CANCELAndOK)			
		msg:setNotify(onMsgBoxCallBack)
	else
		self:doSellItem(item, num)
		GlobalEventSystem:Fire(GameEvent.EventHideNormalItemDetailView)
		GlobalEventSystem:Fire(GameEvent.EventHideEquipItemDetailView)
	end
end

-- 如果绑定类型是穿戴后变为绑定，则提示是否穿戴确认
function ItemOperator:comfirmByBindTypeBeforePutOn(equipObj, pos)
	local bindType = PropertyDictionary:get_bindType(equipObj:getStaticData().property)		
	if	(bindType == 2 and (PropertyDictionary:get_bindStatus(equipObj:getPT()) ~= 1)) then
			local onMsgBoxCallBack = function(unused, text, id)
			if (id == 2) then
				self:doPutOnEquip(equipObj, pos)	
				
			end
		end
		--UIManager.Instance:showMsgBox(string.format("%s穿戴后会被绑定，\n确定穿戴吗？", PropertyDictionary:get_name(equipObj:getStaticData().property)), self, onMsgBoxCallBack, constMessageSize)
		local word = string.format(Config.Words[10206], PropertyDictionary:get_name(equipObj:getStaticData().property))
		local msg = showMsgBox(word,E_MSG_BT_ID.ID_CANCELAndOK)			
		msg:setNotify(onMsgBoxCallBack)
	else
		self:doPutOnEquip(equipObj, pos)
	end
end

-- 如果物品的数量大于1，则询问出卖数量
function ItemOperator:askSellNum(item, stackNum)
	local onNumEvent = function(item, eventType, num, titleText)
		if (eventType == 2 and num >= 1) then --确定
			self:confirmByQualityBeforeSell(item, num)
		end 			
	end
	UIManager.Instance:showEditBox(item, onNumEvent, stackNum, "请输入出售数量", 1, stackNum)
end

-- 如果物品的数量大于1，则询问使用数量
function ItemOperator:askUseNormalItemNum(item, stackNum)
	local onNumEvent = function(item, eventType, num, titleText)
		if (eventType == 2 and num >= 1) then --确定
			self:doUseNormalItem(item, num)
		end 			
	end
	UIManager.Instance:showEditBox(item, onNumEvent, stackNum, "请输入使用数量", 1, stackNum)
end


-- 使用物品
function ItemOperator:doUseNormalItem(item, count)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
	bagMgr:requestUseItem(item, count)		
	G_getBagMgr():resetCommonCD()
	--local refid = item:getRefId()
	G_getBagMgr():resetDrugCD(item)
--	UIManager.Instance:showSystemTips("发送使用请求，num=1")
end

function ItemOperator:doSellItem(item, count)	
    --UIManager.Instance:showSystemTips("发送出售请求，num="..count)
	if item:getType() == ItemType.eItemEquip then	
		local equipList = {}
		table.insert(equipList,item)
		G_getForgingMgr():requestBag_Decompose(equipList)
	else
		local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
		bagMgr:requestSellItem(item, count)
	end
end

-- 穿戴装备
function ItemOperator:doPutOnEquip(equipObj, posId)
	if (equipObj == nil) then
		return
	end	
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local bodyAreaId = G_getBodyAreaId(equipObj)
	if ((bodyAreaId >= E_BodyAreaId.eWeapon) or (bodyAreaId <= E_BodyAreaId.eWing)) then
		if not posId then
			posId = equipMgr:getPutOnPosIdByBodyAreaId(bodyAreaId)		
		end
		if (posId == nil) then		
			UIManager.Instance:showSystemTips("穿戴出错")
		else
			equipMgr:requestEquipPutOn(equipObj, bodyAreaId, posId)	
		end
	end
end		
	
--卸下装别
function ItemOperator:doUnLoadEquip(equipObj)
	if (equipObj == nil) then
		return
	end	
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	equipMgr:requestEquipUnLoad(equipObj)
--	UIManager.Instance:showSystemTips("卸下请求已发送")	
end