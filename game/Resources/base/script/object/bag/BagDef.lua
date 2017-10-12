-- 物品的类型。只读属性，当做枚举使用。
require ("data.item.equipItem")
require ("data.item.propsItem")
require ("data.item.giftConfig")
require ("data.item.unPropsItem")
require("object.bag.ItemDetailArg")
--[[
"0=其他道具
1=装备  
2=药
3=任务物品 
4=材料
5=羽毛（翅膀界面）
6=坐骑经验丹（坐骑界面）
7=技能秘药（技能界面）
8=法宝碎片，法宝进阶石（法宝界面）
9=强化石（锻造界面）"
10=强化卷
11=传送石
12=礼包
13 = 回城卷
14 = 随机传送卷
--]]
ItemType = 
{
	eItemAll 			= 		10086,	
	eItemNotClassified 	= 		0,
	eItemEquip 			= 		1,
	eItemDrug 			= 		2,
	eItemTask 			= 		3,
	eItemMaterial 		= 		4,		
	eItemFeather 		= 		5,	
	eItemJingYanDan 	= 		6,	
	eItemSkillDrug 		= 		7,	
	eItemFabaoSuipian 	= 		8,	
	eItemQianghuashi 	= 		9,
	eItemQianghuajuan   =		10,
	eItemChuansongshi   =		11,
	eItemGift		    =		12,
	eItemHuichengjuan	=		13,
	eItemSuijijuan		=		14,
}

E_BagState = 
{
	Normal = 1, 
	BatchSell = 2,
	Store = 3,
}

ItemQualtiy = 
{
	White = 1,
	Blue = 2,
	Purple = 3,
}	

E_BagContentType = 
{
	All = 4,
	Equip = 3,
	Drug = 2,
	Other = 1,
}

E_OperateType = 
{
	Use = 1,
	PutOn = 2, 
	Sell = 3,
	UnLoad = 4
}	

E_UnableEquipType = 
{
	Level = 1,
	Profression = 2,
	Gender = 3,
	Knight = 4,
}

E_CDItemModifyTime = 
{
	AddCDTime = 1,
	RemoveCDTime = 2,
}

local const_scale = VisibleRect:SFGetScale()		


function G_getItemById(itemTable, id)
	if (itemTable == nil) then
		return
	end
 	for k, value in pairs(itemTable) do	
		if (id == value:getId()) then
			return value
		end	
	end
	return nil
end

function G_getProfessionIconById(id)
	if (id == 1) then
		return "common_zhanshi.png"		
	elseif (id == 2) then
		return "common_fashi.png"	
	elseif (id == 3) then
		return "common_daoshi.png"
	else
		return nil
	end
end

function G_getColorByItem(item)
	if (item == nil or item:getStaticData() == nil) then
		return
	end
	
	local quality = PropertyDictionary:get_quality(item:getStaticData().property)
	local qualityBg = nil
	if (quality == 1) then
		return FCOLOR("ColorWhite1")
	elseif (quality == 2) then
		return FCOLOR("ColorBlue1")
	elseif	(quality == 3) then
		return FCOLOR("ColorPurple1")
	else--[[if (quality == 4) then--]]
		return FCOLOR("ColorYellow1")
	end
end

function G_getQualityColorByRefId(refId)
	local quality
	if (GameData.EquipItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.EquipItem[refId].property)
	elseif (GameData.PropsItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.PropsItem[refId].property)
	end	
	
	local qualityBg = nil
	if (quality == 1) then
		return Config.FontColor["ColorWhite1"]
	elseif (quality == 2) then
		return Config.FontColor["ColorBlue1"]
	elseif	(quality == 3) then
		return Config.FontColor["ColorPurple1"]
	elseif (quality == 4) then
		return Config.FontColor["ColorYellow1"]
	else
		return Config.FontColor["ColorGreen1"]
	end
end

function G_getQualityByRefId(refId)
	local quality = 1
	if (GameData.EquipItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.EquipItem[refId].property)
	elseif (GameData.PropsItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.PropsItem[refId].property)
	end	
	return quality
end

function G_getQualityFColorByRefId(refId)
	local quality
	if (GameData.EquipItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.EquipItem[refId].property)
	elseif (GameData.PropsItem[refId] ~= nil) then
		quality = PropertyDictionary:get_quality(GameData.PropsItem[refId].property)
	end	
	
	local color = nil
	if (quality == 1) then
		color = "ColorWhite1"
	elseif (quality == 2) then
		color = "ColorBlue1"
	elseif	(quality == 3) then
		color = "ColorPurple1"
	elseif (quality == 4) then
		color = "ColorYellow1"
	else
		color = "ColorGreen1"
	end
	return color
end

function G_createKeyValue(key, value, valueColor, keyColor, valueSize, keySize)
	local size = CCSizeMake(140, 30)
	if (valueColor == nil) then
		valueColor = FCOLOR("ColorWhite2")
	end
	if (keyColor == nil) then
		keyColor = FCOLOR("ColorYellow1")
	end		
	if (valueSize == nil) then
		valueSize = FSIZE("Size1")
	end
	if (keySize == nil) then
		keySize = FSIZE("Size1")
	end
	
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(key, "Arial",keySize * const_scale , keyColor)
	local valueLabel = createLabelWithStringFontSizeColorAndDimension(value, "Arial", valueSize * const_scale, valueColor)	
	local node = CCNode:create()		
	node:addChild(keyLabel)
	node:addChild(valueLabel)	
		
	node:setContentSize(VisibleRect:getScaleSize(size))
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(4, 0))
--	VisibleRect:relativePosition(valueLabel, keyLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))		
	VisibleRect:relativePosition(valueLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(85, 0))		
	return node, keyLabel, valueLabel
end	


function G_getIconByItem(item)
	if (item == nil) then
		return nil
	end
--	return ICON(item:getRefId())	
	return ICON(PropertyDictionary:get_iconId(item:getStaticData().property))	
end	

-- 通过refId获取物品的类型ItemType
function G_getItemTypeByRefId(refId)
	if (refId == nil) then
		return ItemType.eItemNotClassified
	end
	local staticData = G_getStaticDataByRefId(refId)
	if (staticData == nil) then
		return ItemType.eItemNotClassified
	end
	return PropertyDictionary:get_itemType(staticData.property)
end   

--通过refId判断是不是非属性物品,非属性物品return true,属性物品return false
function G_getIsUnPropsItem(refId)
	if refId and GameData.UnPropsItem[refId] then
		return true
	else
		return false
	end
end

-- 通过refId获取物品的静态数据
function G_getStaticDataByRefId(refId)
	if not refId then
		return nil
	end
	if (GameData.EquipItem[refId] ~= nil) then
		return GameData.EquipItem[refId]
	elseif (GameData.PropsItem[refId] ~= nil) then
		return GameData.PropsItem[refId]
	elseif GameData.UnPropsItem[refId] then
		return GameData.UnPropsItem[refId]
	end		
	return nil
end

function G_getContentStaticDataByRefId(refId)
	local contentTable = {}
	local num = 0
	for k,v in pairs(GameData.GiftConfig["gift_open"].configData) do
		num = num +1
		if v.giftRefId == refId then
			contentTable[k] = v
		end
	end
	return contentTable
end

-- 通过quality获取物品品质
function G_getQualityResName(quality)
	local qualityBg = nil
	if quality then		
		if (quality == 1 or quality == "1") then
			qualityBg = RES("bagBatch_iconBgWhite.png")
		elseif (quality == 2 or quality == "2") then
			qualityBg = RES("bagBatch_iconBgBlue.png")
		elseif	(quality == 3 or quality == "3" ) then
			qualityBg = RES("bagBatch_iconBgPurple.png")
		elseif	(quality == 4 or quality == "4") then
			qualityBg = RES("bagBatch_iconBgjinse.png")
		end			
	end
	return qualityBg
end	

--创建非道具物品格子对象
function G_createUnPropsItemBox(refId)	
	--品质底图
	local box = createSpriteWithFrameName(RES("bagBatch_iconBgWhite.png"))
	G_setScale(box)	
	
	--物品图片
	local picName = ICON(G_getStaticUnPropsIconId(refId))
	if picName then
		local pic = createSpriteWithFileName(picName)			
		if 	pic then
			G_setScale(pic)
			box:addChild(pic)
			VisibleRect:relativePosition(pic,box, LAYOUT_CENTER,ccp(0,0))
		end
	end		
	
	return box
end

--获取非道具物品Id
function G_getStaticUnPropsIconId(refId)
	if refId then	
		if GameData.UnPropsItem[refId] then
			if GameData.UnPropsItem[refId]["property"] then			
				return GameData.UnPropsItem[refId]["property"]["iconId"]									
			end			
		end
	end
end	

--获取非道具物品名称
function G_getStaticUnPropsName(refId)
	if refId then	
		if GameData.UnPropsItem[refId] then
			if GameData.UnPropsItem[refId]["property"] then			
				return GameData.UnPropsItem[refId]["property"]["name"]									
			end			
		end
	end
end

--获取道具物品名称
function G_getStaticPropsName(refId)
	if refId then	
		local data = G_getStaticDataByRefId(refId)
		if data then
			if data["property"] then			
				return data["property"]["name"]									
			end			
		end
	end
end


--通过道具refId创建带品质底图的道具格子
--参数unClick若为true，则格子不带按钮点击事件
--clickCallBack, 点击后的回调
function G_createItemBoxByRefId(refId,unClick, clickCallBack,bindStatus)
	--物品格子	
	local itemObj = ItemObject.New()
	itemObj:setRefId(refId)
	itemObj:setStaticData(G_getStaticDataByRefId(itemObj:getRefId()))	
	if itemObj:getType()==ItemType.eItemEquip then
		itemObj:setPT(G_getStaticDataByRefId(itemObj:getRefId()).effectData)
		if not itemObj:getPT().fightValue then
			local fightValue = G_getEquipFightValue(refId)
			if fightValue then
				itemObj:updatePT({fightValue = fightValue})	
			end	
		end				
--[[	else
		itemObj:setPT({bindStatus = 0})--写死初始绑定状态为非绑定状态--]]
	end
	if bindStatus then
		PropertyDictionary:set_bindStatus(itemObj:getPT(),bindStatus)	
	end			
	--品质底图
	local quality = PropertyDictionary:get_quality(itemObj:getStaticData().property)
	local itemQualtiy = G_getQualityResName(quality)
	local box = createSpriteWithFrameName(itemQualtiy)
	G_setScale(box)	
	
	--物品图片	
	local picName = ICON(PropertyDictionary:get_iconId(itemObj:getStaticData().property)) 
	if picName then
		local pic = createButtonWithFilename(picName)		
		if pic then
			G_setScale(pic)
			box:addChild(pic)
			VisibleRect:relativePosition(pic,box, LAYOUT_CENTER,ccp(0,0))
		end	

		if unClick ~= true then
			local btnPicfunc =function ()
				G_clickItemEvent(itemObj)
				if clickCallBack then 
					clickCallBack(refId)
				end
			end
			pic:addTargetWithActionForControlEvents(btnPicfunc, CCControlEventTouchDown)
		else
			pic:setEnable(false)
		end
	end
	
	return box
end

-- 通过itemBox创建物品展示框，包括框背景，物品数量
function G_createItemShowByItemBox(refId,itemNum,itemNumColor,itemName,itemBoxBg,bindStatus)
	local isUnPropsItem = function(itemRefId)	
		for k,v in pairs(GameData.UnPropsItem) do
			if v.refId == itemRefId then
				return true
			end
		end
		return false
	end
	
	local itemBoxShow
	if itemBoxBg then
		itemBoxShow = createSpriteWithFrameName(RES(itemBoxBg))
	else
		itemBoxShow = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
	end

	local itemBox 
	local itemTipSign
	if isUnPropsItem(refId) then
		itemBox = G_createUnPropsItemBox(refId)	
		itemTipSign = "+"
	elseif string.sub(refId, 1, 8) == "yuanbao_" then
		itemBox = createSpriteWithFileName(ICON(refId))			
	else
		itemBox = G_createItemBoxByRefId(refId,nil,nil,bindStatus)
		itemTipSign = "x"	
	end

	itemBoxShow:addChild(itemBox)
	VisibleRect:relativePosition(itemBox,itemBoxShow,LAYOUT_CENTER)
	
	local itemTip = ""
	if itemName then
		itemTip = itemName
	end	
	if itemNum then
		itemTip = itemTip..itemTipSign..tostring(itemNum)
	end	
	local numColor = FCOLOR("ColorYellow1")
	if itemNumColor then
		numColor = itemNumColor
	end
	
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(itemTip, "Arial", FSIZE("Size3"), numColor)
	itemBox:addChild(nameLabel)
	VisibleRect:relativePosition(nameLabel,itemBox, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(0,-5))		
	
	local itemStaticData = G_getStaticDataByRefId(refId)
	if itemStaticData then
		local skill = PropertyDictionary:get_skillRefId(itemStaticData.property)
		if string.match(skill,"skill") then	
			local framesprite = CCSprite:create()				
			itemBox:addChild(framesprite)
			VisibleRect:relativePosition(framesprite, itemBox, LAYOUT_CENTER)
			
			local animate = createAnimate("purpleQuality", 4, 0.2)		
			local forever = CCRepeatForever:create(animate)				
			
			framesprite:stopAllActions()
			framesprite:runAction(forever)
		end	
	end	
	
	return itemBoxShow
end

function G_clickItemEvent(item)
	if (item) then	
		local arg = ItemDetailArg.New()
		arg:setItem(item)
		arg:setBtnArray({})
		if (item:getType() == ItemType.eItemEquip) then			
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情			
		else			
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		end
	end
end

function G_createItemView(item, bShowBindState, bShowText, bShowTips , bShowInfo, size)
	local view = ItemView.New(bShowInfo, size)	
	G_updateItemView(view, item, bShowBindState, bShowText, bShowTips)
	return view
end

function G_updateItemView(itemView, itemObj, bShowBindState, bShowText, bShowTips)
	if  bShowBindState == nil then
		bShowBindState = true
	end
	if  bShowText == nil  then
		bShowText = true
	end
	if  bShowTips == nil  then
		bShowTips = true
	end
	
	local node = itemView:getRootNode()	
	if (not itemObj) then
		return
	end
	itemView:showLock(false)
	itemView:setItem(itemObj,beShowInfo)
	itemView:showBindStatus(bShowBindState)	--显示绑定状态
	itemView:showText(bShowText)			--显示堆叠数量/强化等级
	
	if bShowTips then
		if (itemObj:getType() == ItemType.eItemEquip) then	
			G_showTipIcon(itemObj,itemView)			
		end
	end
end

function G_clearItemView(view)
	view:showBindStatus(false)
	view:showText(false)		
	view:showTipIcon(nil)	
	view:setItem(nil)			
	view:showQualityBg()			
end
--装备战力比较图标
function G_showTipIcon(itemObj,itemView)
	local isCanUse,buf,unableUseRet = G_getBagMgr():getOperator():checkCanPutOnEquip(itemObj)
	local EquipMgr = G_getEquipMgr()
	if isCanUse == true then
		local ret = EquipMgr:compareFp(itemObj)		--显示战力提示			
		if (ret == E_CompareRet.Greater) then
			itemView:showTipIcon("up")	
		else
			itemView:showTipIcon(nil)	
		end
	else
		if unableUseRet == E_UnableEquipType.Profression then
			itemView:showTipIcon("profression")
		elseif unableUseRet == E_UnableEquipType.Gender then
			itemView:showTipIcon("gender")
		else
			local ret = EquipMgr:compareFp(itemObj)		--显示战力提示			
			if (ret == E_CompareRet.Greater) then
				itemView:showTipIcon("up")					
			end
		end
	end
end

function G_getEquipFightValue(refId) --得到装备战斗力，用于奖励装备展示
		local hero = G_getHero()	
	local effectData = G_getStaticDataByRefId(refId).effectData
	local HeroLevel = PropertyDictionary:get_level(hero:getPT())
	local professionId = PropertyDictionary:get_professionId(hero:getPT())	
	local fightValue
	
	local minPAtk = effectData.minPAtk or 0
	local maxPAtk = effectData.maxPAtk or 0
	local minMAtk = effectData.minMAtk or 0
	local maxMAtk = effectData.maxMAtk or 0
	local minTao = effectData.minTao or 0
	local maxTao = effectData.maxTao or 0
	local minPDef = effectData.minPDef or 0
	local maxPDef = effectData.maxPDef or 0
	local minMDef = effectData.minMDef or 0
	local maxMDef = effectData.maxMDef or 0
	local maxHP = effectData.maxHP or 0
	local maxMP = effectData.maxMP or 0
	local hit = effectData.hit or 0
	local dodge = effectData.dodge or 0
	local PDodgePer = effectData.PDodgePer or 0
	local MDodgePer = effectData.MDodgePer or 0
	local fortune = effectData.fortune or 0
	local crit = effectData.crit or 0
	local critInjure = effectData.critInjure or 0
	local PImmunityPer = effectData.PImmunityPer or 0
	local MImmunityPer = effectData.MImmunityPer or 0
	local ignorePDef = effectData.ignorePDef or 0
	local ignoreMDef = effectData.ignoreMDef or 0
	local atkSpeedPer = effectData.atkSpeedPer or 0

	if professionId == ModeType.ePlayerProfessionWarior then
		fightValue = minPAtk*2+maxPAtk*3+minMAtk*0.5+maxMAtk*0.5+minTao*0.5+maxTao*0.5
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	elseif professionId == ModeType.ePlayerProfessionMagic then
		fightValue = minPAtk*0.5+maxPAtk*0.5+minMAtk*2+maxMAtk*3+minTao*0.5+maxTao*0.5
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	elseif professionId == ModeType.ePlayerProfessionWarlock then
		fightValue = minPAtk*0.5+maxPAtk*0.5+minMAtk*0.5+maxMAtk*0.5+minTao*2+maxTao*3
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	else
	
	end
	fightValue = math.ceil(fightValue)	--向上取整
	return fightValue
		
end


function G_getFightValue(fightPT) --计算战斗力  传入pd
	local hero = G_getHero()		
	local HeroLevel = PropertyDictionary:get_level(hero:getPT())
	local professionId = PropertyDictionary:get_professionId(hero:getPT())	
	local fightValue
	
	local minPAtk = fightPT.minPAtk or 0
	local maxPAtk = fightPT.maxPAtk or 0
	local minMAtk = fightPT.minMAtk or 0
	local maxMAtk = fightPT.maxMAtk or 0
	local minTao = fightPT.minTao or 0
	local maxTao = fightPT.maxTao or 0
	local minPDef = fightPT.minPDef or 0
	local maxPDef = fightPT.maxPDef or 0
	local minMDef = fightPT.minMDef or 0
	local maxMDef = fightPT.maxMDef or 0
	local maxHP = fightPT.maxHP or 0
	local maxMP = fightPT.maxMP or 0
	local hit = fightPT.hit or 0
	local dodge = fightPT.dodge or 0
	local PDodgePer = fightPT.PDodgePer or 0
	local MDodgePer = fightPT.MDodgePer or 0
	local fortune = fightPT.fortune or 0
	local crit = fightPT.crit or 0
	local critInjure = fightPT.critInjure or 0
	local PImmunityPer = fightPT.PImmunityPer or 0
	local MImmunityPer = fightPT.MImmunityPer or 0
	local ignorePDef = fightPT.ignorePDef or 0
	local ignoreMDef = fightPT.ignoreMDef or 0
	local atkSpeedPer = fightPT.atkSpeedPer or 0

	if professionId == ModeType.ePlayerProfessionWarior then
		fightValue = minPAtk*2+maxPAtk*3+minMAtk*0.5+maxMAtk*0.5+minTao*0.5+maxTao*0.5
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	elseif professionId == ModeType.ePlayerProfessionMagic then
		fightValue = minPAtk*0.5+maxPAtk*0.5+minMAtk*2+maxMAtk*3+minTao*0.5+maxTao*0.5
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	elseif professionId == ModeType.ePlayerProfessionWarlock then
		fightValue = minPAtk*0.5+maxPAtk*0.5+minMAtk*0.5+maxMAtk*0.5+minTao*2+maxTao*3
					 +minPDef*1.25+maxPDef*1.25+minMDef*1.25+maxMDef*1.25+maxHP*0.2+maxMP*0.2
					 +hit*100*math.pow(HeroLevel/100,2)+dodge*100*math.pow(HeroLevel/100,2)+PDodgePer*25*math.pow(HeroLevel/100,2)
					 +MDodgePer*25*math.pow(HeroLevel/100,2)+fortune*500*math.pow(HeroLevel/100,2)+crit*50*math.pow(HeroLevel/100,2)
					 +critInjure*0.5+PImmunityPer*25*math.pow(HeroLevel/100,2)+MImmunityPer*25*math.pow(HeroLevel/100,2)
					 +ignorePDef*25*math.pow(HeroLevel/100,2)+ignoreMDef*25*math.pow(HeroLevel/100,2)+atkSpeedPer*50*math.pow(HeroLevel/100,2)
	else
	
	end
	fightValue = math.ceil(fightValue)	--向上取整
	return fightValue
		
end

function G_IsEquip(refId)
	if GameData.EquipItem[refId] then
		return true
	end
	return false
end

function G_getItemKindByRefId(refId)
	if GameData.EquipItem[refId] then
		return 2
	end
	return 1
end

function G_IsHighQuilatyEquip(item)
	local quality = PropertyDictionary:get_quality(item:getStaticData().property)		
	local isHighestEuqip =  PropertyDictionary:get_isHighestEquipment(item:getPT())
	if quality == 3 or quality == 4 or isHighestEuqip == 1 then
		return true
	else
		return false
	end
end