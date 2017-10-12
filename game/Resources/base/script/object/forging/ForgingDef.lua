require("config.words")
require ("data.item.equipWashProperty")
local const_scale = VisibleRect:SFGetScale()
local const_spacing = 20

--const_forgingPreviewSize = CCSizeMake(434*const_scale, 194*const_scale)
const_forgingPreviewSize = CCSizeMake(460*const_scale, 155*const_scale)
const_opratorSize = CCSizeMake(460*const_scale, 235*const_scale)
const_maxStrengthenLevel = 12
E_State_UnBind = 0
E_State_Bind = 1
E_MaterialEnough = 5
E_MaterialNotEnough = 6
E_MaterialShowBox = 7

ForgeSubViewType = 
{	
	Strengthen	= 1,
	Wash 		= 2,		
	Decompose 	= 3,
}
E_ForgingDisplayPropertys = 
{
    [1] = {name = "strengtheningLevel" 	, translateName =  Config.Words[10094]},
	[2] = {name = "minPAtk" 			, translateName =  Config.Words[10067], depend = 3, fullName = Config.Words[10047]},
	[3] = {name = "maxPAtk" 			, translateName =  Config.Words[10088], ignoreByDepend = true},
	[4] = {name = "minMAtk" 			, translateName =  Config.Words[10085], depend = 5, fullName = Config.Words[10048]},
	[5] = {name = "maxMAtk" 			, translateName =  Config.Words[10084], ignoreByDepend = true},
	[6] = {name = "minTao" 			    , translateName =  Config.Words[10081], depend = 7, fullName = Config.Words[10049]},
	[7] = {name = "maxTao" 			    , translateName =  Config.Words[10080], ignoreByDepend = true},
	[8] = {name = "minPDef" 			, translateName =  Config.Words[10087], depend = 9, fullName = Config.Words[10051]},
	[9] = {name = "maxPDef" 			, translateName =  Config.Words[10086], ignoreByDepend = true},
	[10] = {name = "minMDef" 			, translateName =  Config.Words[10083], depend = 11, fullName = Config.Words[10052]},
	[11] = {name = "maxMDef" 			, translateName =  Config.Words[10082], ignoreByDepend = true},
	[12] = {name = "fortune" 			, translateName =  Config.Words[10068]},
	[13] = {name = "hit" 				, translateName =  Config.Words[10089]},
	[14] = {name = "dodge" 				, translateName =  Config.Words[10090]},
	[15] = {name = "maxHP" 				, translateName =  Config.Words[10093]},
	[16] = {name = "perHP" 				, translateName =  Config.Words[10076]}, 
	[17] = {name = "maxMP" 				, translateName =  Config.Words[10077]},
	[18] = {name = "perMP" 				, translateName =  Config.Words[10075]},
	[19] = {name = "crit" 				, translateName =  Config.Words[10070]},
	[20] = {name = "critInjure" 		, translateName =  Config.Words[10069]},
	[21] = {name = "ignorePDef" 		, translateName =  Config.Words[10074]},
	[22] = {name = "ignoreMDef" 		, translateName =  Config.Words[10073]},
    [23] = {name = "PImmunityPer" 		, translateName =  Config.Words[10079]},
    [24] = {name = "MImmunityPer" 		, translateName =  Config.Words[10078]},
    [25] = {name = "PDodgePer" 			, translateName =  Config.Words[10091]},
    [26] = {name = "MDodgePer" 			, translateName =  Config.Words[10092]},
	[27] = {name = "atkSpeed" 			, translateName =  Config.Words[10071]},
	[28] = {name = "moveSpeed" 			, translateName =  Config.Words[10072]},	
}

function G_getStrengthenFailTipsByLevel(level)
	if (level >= 0 and level < 6) then
		return Config.Words[10095]
	elseif (level < 9) then
		return Config.Words[10096]
	elseif (level < 12) then
		return Config.Words[10097]
	else
		return ""
	end
end

function G_getWashPropertyFromStaticData(property, refId)
	if (property == nil or property == "") then
		return nil
	end
	
	local value = nil
	
	local data = GameData.EquipWashProperty[refId]
	if (data) then
		data = data.property
	end
	if (data) then
		value = data[property]
	end
	return value
end

function G_buildWashPropertys(equip, locksProperty)
	local pd = equip:getWashPT()
	if (pd == nil) then
		pd = {}
	end
		
	--name = {value = -1, maxValue = -1, isLock = false, isUp = nil}	
	local propertys = {}
	for i, displayProperty in ipairs(E_ForgingDisplayPropertys) do				
		local staticPD = G_getForgingMgr():getPropertyGenerator():getWashPD(equip:getRefId())
		if (staticPD ~= nil) then					
			local propertyName = displayProperty.name		
			local maxValue = staticPD[propertyName]
			
			if (maxValue ~= nil) then
				local element = {}			
				
				element.translateName = displayProperty.translateName
				element.maxValue = maxValue				
				element.value = pd[propertyName]
				if (element.value == nil) then
					element.value = 0
				end			
				element.isLock = false	
				if (locksProperty) then
					for k, v in pairs(locksProperty) do
						if (v == propertyName) then
							element.isLock = true
							break
						end
					end
				end
				propertys[propertyName] = element
			end
		end
	end	
	return propertys
end	

function G_createWashProperty(property, bShowSelectBox, viewSize, notify)
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(property.translateName, "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow2"))	
	local value1Label 
	if (property.value == property.maxValue) then
		value1Label = createLabelWithStringFontSizeColorAndDimension(property.value, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow5"))		
	else
		value1Label = createLabelWithStringFontSizeColorAndDimension(property.value, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))		
	end
	
	local pointer = createSpriteWithFrameName(RES("forging_rightArrow.png"))	
	
	local value2Label = createLabelWithStringFontSizeColorAndDimension(property.maxValue, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))	
	local selectBox = nil
	if (bShowSelectBox == true) then
		selectBox = G_createWashSelectBox(property, notify)
	end
			
	local node = CCNode:create()
	node:addChild(keyLabel)
	node:addChild(value1Label)
	node:addChild(value2Label)
	node:addChild(pointer)
		
	node:setContentSize(CCSizeMake(viewSize.width, keyLabel:getContentSize().height  + 6))	
		
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(0, 0))
	VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(160, 0))	
	VisibleRect:relativePosition(pointer, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(210, 0))	
	VisibleRect:relativePosition(value2Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(267, 0))		
		
	if (selectBox ~= nil) then
		node:addChild(selectBox)
	VisibleRect:relativePosition(selectBox, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(340, 0))
	end
	
	return node
end

function G_createWashSelectBox(property, notify)
	local btn = createButtonWithFramename(RES("common_selectBox.png"))
	local selected = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn:addChild(selected)	
	VisibleRect:relativePosition(selected, btn, LAYOUT_CENTER)
	
	local switchLockState = function()
		if (property.isLock == true) then
			selected:setVisible(false)
			property.isLock = false
		else
			selected:setVisible(true)
			property.isLock = true
		end			
		
		if (notify) then
			notify()
		end
	end		
	
	selected:setVisible(property.isLock)
	btn:addTargetWithActionForControlEvents(switchLockState, CCControlEventTouchDown)
	return btn
end	

function G_buildStrengthenPropertys(gpropertys, viewSize, bShowCompare)	
	if (gpropertys == nil) then	
		return
	end		
	
	local nodes = {}  
	for index, displayProperty in ipairs(E_ForgingDisplayPropertys) do	
		local valuePair = gpropertys[displayProperty.name]
		if (valuePair) then
			if (valuePair[1] == nil) then
				valuePair[1] = 0
			end			
			if (valuePair[2] == nil) then
				valuePair[2] = 0
			end
			local node = G_createStrengtheningProperty(displayProperty.translateName, valuePair, viewSize, bShowCompare)	
			table.insert(nodes, node)		
		end
	end			
	
	local strengthenPropertysNode = CCNode:create()
	G_layoutContainerNode(strengthenPropertysNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize)	
	return strengthenPropertysNode
end	

function G_buildActivePropertys(propertys, viewSize, curStrengtheningLevel, xOffset)
	if (propertys == nil) then	
		return
	end		
	if (xOffset == nil) then
		xOffset = 0
	end
	
	local nodes = {}  	
	for strengtheningLevel, v in pairs(propertys) do	
		--local titleText = createStyleTextLable(Config.Words[10127], "Price")		--因为要置灰处理。改用了按钮图片
		local titleText = createSpriteWithFrameName(RES("word_label_strenghtenactivation.png"))
		local title = createLabelWithStringFontSizeColorAndDimension("+"..strengtheningLevel..":", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow5"))		
		local titleNode = CCNode:create()
		titleNode:addChild(title)
		titleNode:addChild(titleText)		
		
		titleNode:setContentSize(CCSizeMake(viewSize.width, title:getContentSize().height))	
		VisibleRect:relativePosition(titleText, titleNode, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(xOffset, 0))
		VisibleRect:relativePosition(title, titleText, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(0, 0))
		
		table.insert(nodes, titleNode)		
		for index, displayProperty in ipairs(E_ForgingDisplayPropertys) do		
			if (displayProperty.name ~= "strengtheningLevel") then							
				local value = v[displayProperty.name]
				if (value) then	
					if (curStrengtheningLevel ~= nil and curStrengtheningLevel < strengtheningLevel) then
						UIControl:SpriteSetGray(titleText)
						title:setColor(FCOLOR("ColorGray3"))
						table.insert(nodes, G_createEquipKeyValue(displayProperty.translateName, "+"..value, viewSize, FCOLOR("ColorGray3"), FCOLOR("ColorGray3")))														
					else
						UIControl:SpriteSetColor(titleText)
						table.insert(nodes, G_createEquipKeyValue(displayProperty.translateName, "+"..value, viewSize))						
					end
				end	
			end
		end
	end
	
	local activeNode = CCNode:create()
	G_layoutContainerNode(activeNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize)	
	return activeNode
end

function G_createEquipKeyValue(name, value, viewSize, keyColor, valueColor)
	if (valueColor == nil) then
		valueColor = FCOLOR("White3")
	end
	if (keyColor == nil) then
		keyColor = FCOLOR("Yellow1")
	end
	
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale, keyColor)
	local value1Label = createLabelWithStringFontSizeColorAndDimension(value, "Arial", FSIZE("Size3") * const_scale, valueColor)		
--	local valueLabelBg = createScale9SpriteWithFrameNameAndSize(RES("faction_contentBg.png"),CCSizeMake(150, FSIZE("Size3")))
	
	local node = CCNode:create()
	node:addChild(keyLabel)
--	node:addChild(valueLabelBg)
	node:addChild(value1Label)
	node:setContentSize(CCSizeMake(viewSize.width, keyLabel:getContentSize().height))	
	
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(0, 0))	
	VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(90, 0))	
	return node
end

function G_createStrengtheningProperty(property, values, viewSize, bShowCompare)
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(property, "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow2"))
	local value1Label = createLabelWithStringFontSizeColorAndDimension(tostring(values[1]), "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))		
	local value2Label = nil
	local rightArrow = nil
	if (bShowCompare == true) then
		value2Label = createLabelWithStringFontSizeColorAndDimension(tostring(values[2]), "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))	
		rightArrow = createSpriteWithFrameName(RES("forging_rightArrow.png"))
	end
	
	local node = CCNode:create()
	node:addChild(keyLabel)
	node:addChild(value1Label)
	node:setContentSize(CCSizeMake(viewSize.width, keyLabel:getContentSize().height))	
	
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(80, 0))
	VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(180, 0))	
	if (bShowCompare == true) then
		node:addChild(rightArrow)
		node:addChild(value2Label)
		VisibleRect:relativePosition(rightArrow, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(230, 0))	
		VisibleRect:relativePosition(value2Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(290, 0))	
	end
	return node
end


function G_checkGoldEnough(gold, bShowTips)
	if (gold == nil) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10125], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)	
		end
		return false
	end
	local hasGold = PropertyDictionary:get_gold(G_getHero():getPT())
	local ret = (hasGold >= gold)
	if (ret == false) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10125], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)	
		end
		return false
	end
	return true
end

--[[function G_checkMaterialEnough(material, bShowTips)
	if (material == nil) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10124], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
		end
		return false
	end
	local hasMaterial = G_getBagMgr():getItemNumByRefId("item_qianghuashi")	
	local ret = (hasMaterial >= material)
	if (ret == false) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10124], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
		end
		return false,(material - hasMaterial) 
	end
	return true
end--]]



function G_checkMaterialEnough(material ,isUseBind)
	if (material == nil) then
		return E_MaterialNotEnough
	end		
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local bindMaterialNum,unbindMaterialNum =	bagMgr:getBindedAndUnbindItemNumByRefId("item_qianghuashi")		
		
	if isUseBind == true then
		if bindMaterialNum >= material then	--绑定强化石足够
			return E_MaterialEnough
		else
			if unbindMaterialNum+bindMaterialNum >= material then						
				return E_MaterialShowBox
			else
				local msg = {}
				table.insert(msg,{word = Config.Words[10124], color = Config.FontColor["ColorRed1"]})
				UIManager.Instance:showSystemTips(msg)
				return E_MaterialNotEnough
			end
		end
	elseif isUseBind == false then
		if unbindMaterialNum >= material then	--非绑定强化石足够
			return E_MaterialEnough
		else
			local msg = {}
			if unbindMaterialNum+bindMaterialNum >= material then			
				table.insert(msg,{word = Config.Words[10216], color = Config.FontColor["ColorYellow1"]})				
			else				
				table.insert(msg,{word = Config.Words[10124], color = Config.FontColor["ColorRed1"]})				
			end
			UIManager.Instance:showSystemTips(msg)
			return E_MaterialNotEnough
		end
	end
	
end



function G_checkYuanbaoEnough(yuanbao, bShowTips)
	if (yuanbao == nil) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10126], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
			--UIManager.Instance:showSystemTips(Config.Words [10126])
		end
		return false
	end
	local hasYuanbao = PropertyDictionary:get_unbindedGold(G_getHero():getPT())
	local ret = (hasYuanbao >= yuanbao)
	if (ret == false) then
		if (bShowTips == true) then
			local msg = {}
			table.insert(msg,{word = Config.Words[10126], color = Config.FontColor["ColorRed1"]})
			UIManager.Instance:showSystemTips(msg)
			--UIManager.Instance:showSystemTips(Config.Words [10126])
		end
		return false
	end
	return true
end