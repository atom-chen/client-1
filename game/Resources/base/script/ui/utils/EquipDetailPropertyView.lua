require("ui.UIManager")
require("common.BaseUI")

EquipDetailPropertyView = EquipDetailPropertyView or BaseClass(BaseUI)

local viewSize = CCSizeMake(306, 478)
local upScrollViewSize = CCSizeMake(280, 282)
local downScrollViewSize = CCSizeMake(280, 105)
local const_scale = VisibleRect:SFGetScale()
local const_spacing = 8
local KeyValueType = {
	Depend = 1,
	Independ = 2,
}

function EquipDetailPropertyView:__init()
	self.viewName = "EquipDetailPropertyView"
	self:initWithBg(viewSize, RES("squares_bag_bg.png"), true, false)	
	self:initBg()
	self:initScrollView()
end

function EquipDetailPropertyView:create()
	return EquipDetailPropertyView.New()
end

function EquipDetailPropertyView:__delete()

end

function EquipDetailPropertyView:onEnter(item)
	if item then
		self:showStrengthenDetail(item)
		self:showXilianDetail(item)
	end		
end

function EquipDetailPropertyView:initBg()
	local frame = createScale9SpriteWithFrameNameAndSize(RES("squares_bag_frame.png"), viewSize)	
	self.rootNode:addChild(frame)
	VisibleRect:relativePosition(frame, self.rootNode, LAYOUT_CENTER)
	
	local strengthenText = createSpriteWithFrameName(RES("word_button_strengthen_property.png"))
	self:addChild(strengthenText)
	VisibleRect:relativePosition(strengthenText, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-10, 32))
	
	local contentSize = self:getContentNode():getContentSize()
	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(contentSize.width-20, 2))
	self:addChild(line)
	VisibleRect:relativePosition(line, self:getContentNode(), LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE, ccp(0, 126))
	
	local xilianText = createSpriteWithFrameName(RES("word_button_sophistication_property.png"))
	self:addChild(xilianText)
	VisibleRect:relativePosition(xilianText, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-10, 95))
	
	self.noStrengthenTips = createLabelWithStringFontSizeColorAndDimension(Config.Words[10226], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self:addChild(self.noStrengthenTips)
	VisibleRect:relativePosition(self.noStrengthenTips, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-10, 0))
	self.noStrengthenTips:setVisible(false)
	
	self.noXilianTips = createLabelWithStringFontSizeColorAndDimension(Config.Words[10227], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self:addChild(self.noXilianTips)
	VisibleRect:relativePosition(self.noXilianTips, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-10, 60))
	self.noXilianTips:setVisible(false)
end

function EquipDetailPropertyView:initScrollView()
	if not self.upScrollView then
		self.upScrollView = createScrollViewWithSize(upScrollViewSize)		
		self.upScrollView:setDirection(2)	
			
		local node = CCNode:create()
		--local node = CCLayerColor:create(ccc4(255, 0, 0, 200))
		node:setContentSize(CCSizeMake(280, 280))
		self.upScrollView:setContainer(node)
		self:addChild(self.upScrollView)
		VisibleRect:relativePosition(self.upScrollView, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, 5))		
	end
	
	if not self.downScrollView then
		self.downScrollView = createScrollViewWithSize(downScrollViewSize)		
		self.downScrollView:setDirection(2)	
			
		local node = CCNode:create()
		--local node = CCLayerColor:create(ccc4(255, 0, 0, 200))
		node:setContentSize(downScrollViewSize)
		self.downScrollView:setContainer(node)
		self:addChild(self.downScrollView)
		VisibleRect:relativePosition(self.downScrollView, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, -10))
	end
end

function EquipDetailPropertyView:showStrengthenDetail(item)
	if not self.upScrollView then
		return 
	end
	self.upScrollView:removeAllChildrenWithCleanup(true)
	
	local contenter = CCNode:create()
	contenter:setContentSize(upScrollViewSize)
	local nodes = {}
	local tmpPd = self:getStrengthenPD(item, PropertyDictionary:get_strengtheningLevel(item:getPT()))
	local pd = {}
	if (tmpPd) then
		for k, v in pairs(tmpPd) do
			pd[k] = {[1] = v}
		end		
	end	
	pd["strengtheningLevel"] = nil
	local strengtheningLevel = PropertyDictionary:get_strengtheningLevel(item:getPT())	
	if (strengtheningLevel > 0 and table.size(pd) > 0) then	
		
		local strengthenPropertysNode = self:buildStrengthenPropertys(pd, upScrollViewSize)		
		if (strengthenPropertysNode) then
			table.insert(nodes, strengthenPropertysNode)
		end						
	end
					
	local activePropertys = G_getForgingMgr():getPropertyGenerator():getStrengthenActivePD(item:getRefId(), const_maxStrengthenLevel)		
	if (activePropertys ~= nil) and not table.isEmpty(activePropertys) then
		local activePropertysNode = self:buildActivePropertys(activePropertys, upScrollViewSize, strengtheningLevel, -3)
		table.insert(nodes, activePropertysNode)
	end
	
	if table.isEmpty(nodes) then
		self.noStrengthenTips:setVisible(true)
	else
		self.noStrengthenTips:setVisible(false)
	end
	
	G_layoutContainerNode(contenter, nodes, const_spacing, E_DirectionMode.Vertical, upScrollViewSize, true)	
	
	self.upScrollView:setContainer(contenter)	
end

function EquipDetailPropertyView:showXilianDetail(item)
	if not self.downScrollView then
		return 
	end
	self.downScrollView:removeAllChildrenWithCleanup(true)
	
	local contenter = CCNode:create()
	contenter:setContentSize(downScrollViewSize)
	
	local nodes = {}
	local washPropertys = G_buildWashPropertys(item)
	if (washPropertys ~= nil)  then		
		for i, property in pairs(washPropertys) do			
			table.insert(nodes, self:createWashProperty(property, downScrollViewSize))
		end	
	end		
	G_layoutContainerNode(contenter, nodes, const_spacing, E_DirectionMode.Vertical, downScrollViewSize, true)
	
	if table.isEmpty(nodes) then
		self.noXilianTips:setVisible(true)
	else
		self.noXilianTips:setVisible(false)
	end
	
	self.downScrollView:setContainer(contenter)
end

function EquipDetailPropertyView:createWashProperty(property, viewSize)
	if (property.value == property.maxValue) then
		return self:createEquipKeyValue(KeyValueType.Independ,viewSize, property.translateName, property.value, FCOLOR("ColorYellow2"), FCOLOR("ColorYellow5"))	
	else
		return self:createEquipKeyValue(KeyValueType.Independ,viewSize, property.translateName, property.value, FCOLOR("ColorYellow2"), FCOLOR("ColorWhite2"))	
	end
end

function EquipDetailPropertyView:createEquipKeyValue(keyValueType,viewSize,name, minValue,maxValue, keyColor, minValueColor,maxValueColor)
	if (keyColor == nil) then
		keyColor = FCOLOR("ColorYellow2")
	end	
	
	local keyLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale, keyColor)
	local node = CCNode:create()
	node:addChild(keyLabel)	
	node:setContentSize(CCSizeMake(viewSize.width, keyLabel:getContentSize().height))	
	if keyValueType == KeyValueType.Depend then
		if minValueColor == nil then		
			minValueColor = FCOLOR("ColorWhite2")
		end
		if maxValueColor == nil then
			maxValueColor = FCOLOR("ColorWhite2")
		end
		local minValueLabel = createLabelWithStringFontSizeColorAndDimension(minValue.."-", "Arial", FSIZE("Size3") * const_scale, minValueColor)	
		local maxValueLabel = createLabelWithStringFontSizeColorAndDimension(maxValue, "Arial", FSIZE("Size3") * const_scale, maxValueColor)	
		node:addChild(minValueLabel)
		node:addChild(maxValueLabel)		
		VisibleRect:relativePosition(minValueLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(93, 0))	
		VisibleRect:relativePosition(maxValueLabel, minValueLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(0, 0))	
	elseif keyValueType == KeyValueType.Independ then
		local valueColor
		if minValueColor == nil and maxValueColor == nil then
			valueColor = FCOLOR("ColorWhite2")
		elseif maxValueColor == nil then
			valueColor = minValueColor
		end
		local value1Label = createLabelWithStringFontSizeColorAndDimension(minValue, "Arial", FSIZE("Size3") * const_scale, valueColor)	
		node:addChild(value1Label)
		VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(93, 0))	
	end
		
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(0, 0))			
	return node
end

function EquipDetailPropertyView:buildStrengthenPropertys(gpropertys, viewSize)	
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
			local node = self:createStrengtheningProperty(displayProperty.translateName, valuePair, viewSize)	
			table.insert(nodes, node)		
		end
	end			
	
	local strengthenPropertysNode = CCNode:create()
	G_layoutContainerNode(strengthenPropertysNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize)	
	return strengthenPropertysNode
end	

function EquipDetailPropertyView:getStrengthenPD(equip, strengtheningLevel)
	if (equip == nil or equip:getStaticData() == nil or strengtheningLevel == nil) then
		return
	end
	
	local professionId	= PropertyDictionary:get_professionId(equip:getStaticData().property)
	local bodyArea = PropertyDictionary:get_areaOfBody(equip:getStaticData().property)		
	
	if (professionId == nil or bodyArea == nil) then
		return
	end		
	
	return G_getForgingMgr():getPropertyGenerator():getStrengthenPD(bodyArea, professionId, strengtheningLevel)
end

function EquipDetailPropertyView:buildActivePropertys(propertys, viewSize, curStrengtheningLevel, xOffset)
	if (propertys == nil) then	
		return
	end		
	if (xOffset == nil) then
		xOffset = 0
	end
	
	local nodes = {}  		
	for strengtheningLevel = 0, const_maxStrengthenLevel do	
		local v = propertys[strengtheningLevel]
		if v then
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
							table.insert(nodes, self:createEquipKeyValue(KeyValueType.Independ, viewSize,displayProperty.translateName, "+"..value, FCOLOR("ColorGray3"), FCOLOR("ColorGray3")))														
						else
							UIControl:SpriteSetColor(titleText)
							table.insert(nodes, self:createEquipKeyValue(KeyValueType.Independ,viewSize,displayProperty.translateName, "+"..value ))						
						end
					end	
				end
			end
		end
	end
	
	local activeNode = CCNode:create()
	G_layoutContainerNode(activeNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize)	
	return activeNode
end

function EquipDetailPropertyView:createStrengtheningProperty(property, values, viewSize)
	return self:createEquipKeyValue(KeyValueType.Independ,viewSize,property, tostring(values[1]))		
end
