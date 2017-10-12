-- 显示背包的详情 
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("ui.utils.BaseItemDetailView")
require("object.forging.ForgingDef")
require"data.skill.skill"
EquipItemDetailView = EquipItemDetailView or BaseClass(BaseItemDetailView)
	
local const_scale = VisibleRect:SFGetScale()
local const_spacing = 8

local PropertyType = 
{	
	Detail = 1,
	Summary = 2,
}
local KeyValueType = {
	Depend = 1,
	Independ = 2,
}

function EquipItemDetailView:create()
	return EquipItemDetailView.New()	
end

function EquipItemDetailView:__init()
	self.viewName = "EquipItemDetailView"	
	self.summaryPropertyNode = CCNode:create()	
	self.summaryPropertyNode:retain()
	self.detailPropertyNode = CCNode:create()
	self.detailPropertyNode:retain()	
end		

function EquipItemDetailView:__delete()
	if (self.detailPropertyNode) then
		self.detailPropertyNode:release()
	end
	if (self.summaryPropertyNode) then
		self.summaryPropertyNode:release()
	end
end	

function EquipItemDetailView:showSwitchEquipBtn(bShow)	
	if bShow and self.switchEquipBtn == nil then
		local onClick = function()
			if not self.item then
				return
			end
			local bodyAreaId = PropertyDictionary:get_areaOfBody(self.item:getStaticData().property)
			local bodyEquipList = G_getEquipMgr():getEquipListByBodyAreaId(bodyAreaId) --获取身上装备列表
			local size = table.size(bodyEquipList)
			if not self.curBodyAreaPos then		--self.curBodyAreaPos为 0 - n			
				for k, v in pairs(bodyEquipList) do
					if v:getId() == self.item:getId() then
						self.curBodyAreaPos = k
						break
					end
				end
			end
			if self.curBodyAreaPos then
				local tmp = self.curBodyAreaPos + 1	
				if tmp >= size then
					tmp = 0 
				end
				self.itemDetailArg:setItem(bodyEquipList[tmp])
				self:onEnter(self.itemDetailArg)
				self.curBodyAreaPos = tmp
			end
			G_getEquipMgr():setPutonPos(self.curBodyAreaPos)
			local rotation = self.switchEquipBtn:getRotation()
			if rotation == 0 then
				self.switchEquipBtn:setRotation(180)
			else
				self.switchEquipBtn:setRotation(0)
		end
			
		end
		
		self.switchEquipBtn = createButtonWithFramename(RES("main_questcontraction.png"))
		self.switchEquipBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
		self:addChild(self.switchEquipBtn, 100)
		VisibleRect:relativePosition(self.switchEquipBtn, self:getContentNode(), LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(-30, 50))
	end
	if self.switchEquipBtn then
		self.switchEquipBtn:setVisible(bShow)
	end
end
	
-- 显示item的各种属性
function EquipItemDetailView:onUpdataItem()
	self.curBodyAreaPos = nil 	
	self:showBodyAreaName()
	self:showProfession()
	self:showSummary()
	self:showFP()
	self:showEquipKnight()
				
	if (self.switchEquipInfoBtn == nil) then
		--self:initSwitchBtn()		
	end
--[[	if self.viewName == "PutOnEquipItemDetailView" then
		self:updateSwitchEquipBtn()
	end--]]
end		

--[[function EquipItemDetailView:updateSwitchEquipBtn()
	local bodyAreaId = PropertyDictionary:get_areaOfBody(self.item:getStaticData().property)	
	local bodyEquipList = G_getEquipMgr():getEquipListByBodyAreaId(bodyAreaId) --获取身上装备列表
	self:showSwitchEquipBtn(table.size(bodyEquipList) > 1)
end
--]]
--------------以下为私有接口-------------------
function EquipItemDetailView:showBodyAreaName()	
	if (self.bodyAreaNameLabel == nil) then
		self.bodyAreaNameLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorOrange1"))		
		self:addChild(self.bodyAreaNameLabel)		
	end
	
	local name = "" 
	local sex = ""
	if (self.item ~= nil and self.item:getStaticData()) then
		name = G_getBodyAreaName(PropertyDictionary:get_areaOfBody(self.item:getStaticData().property))
		sex = G_getSexNameById(PropertyDictionary:get_gender(self.item:getStaticData().property))
	end			
	
	if sex ~= "" then 
		name = sex .. name		
		if sex ~= G_getSexNameById(PropertyDictionary:get_gender(G_getHero():getPT())) then
			self.bodyAreaNameLabel : setColor(FCOLOR("ColorRed2"))		--性别不符红色显示
		else
			self.bodyAreaNameLabel:setColor(FCOLOR("ColorOrange1"))
		end
	else
		self.bodyAreaNameLabel:setColor(FCOLOR("ColorOrange1"))
	end
	self.bodyAreaNameLabel:setString(name)	
	local isHighestEquip = PropertyDictionary:get_isHighestEquipment(self.item:getPT())	
	if isHighestEquip == 1 then
		if not  self.highestEquipLabel then
			self.highestEquipLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[10221],"Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))	
			self:addChild(self.highestEquipLabel)
		end
		self.highestEquipLabel:setVisible(true)
		VisibleRect:relativePosition(self.highestEquipLabel, self.itemView:getRootNode(), LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(15, 0))	
		VisibleRect:relativePosition(self.bodyAreaNameLabel, self.highestEquipLabel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	else
		if self.highestEquipLabel then
			self.highestEquipLabel:setVisible(false)
		end
		VisibleRect:relativePosition(self.bodyAreaNameLabel, self.itemView:getRootNode(), LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(15, 0))	
	end
	
		
end

function EquipItemDetailView:showFP()
	self.fpLabel = createStyleTextLable(Config.Words[10064], "FightPower")				
	self.fpText = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow1"))		
	self.summaryPropertyNode:addChild(self.fpLabel)	
	self.summaryPropertyNode:addChild(self.fpText)			
	VisibleRect:relativePosition(self.fpLabel, self.summaryPropertyNode, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE, ccp(-127, 0))		
	
	local name = "" 
	if (self.item ~= nil and self.item:getStaticData()) then
		name = string.format("%d", PropertyDictionary:get_fightValue(self.item:getPT()))
	end				
	
	self.fpText:setString(name)
	VisibleRect:relativePosition(self.fpText, self.fpLabel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(13, 2))		
end	

function EquipItemDetailView:showProfession()
	if (self.professionIcon ~= nil) then
		self:getContentNode():removeChild(self.professionIcon, true)	
		self.professionIcon = nil	
	end
	
	local profressionName = "" 
	if (self.item ~= nil and self.item:getStaticData()) then
		profressionName = G_getProfessionNameById(PropertyDictionary:get_professionId(self.item:getStaticData().property))		
	end	
	if (profressionName ~= nil) then
		self.professionIcon =  createLabelWithStringFontSizeColorAndDimension(profressionName, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorOrange1"))	
		local professionId = PropertyDictionary:get_professionId(self.item:getStaticData().property)
		if professionId ~= 0 and professionId ~= PropertyDictionary:get_professionId(G_getHero():getPT()) then		--职业不符红色显示
			self.professionIcon : setColor(FCOLOR("ColorRed2"))
		end
		self:addChild(self.professionIcon)			
		VisibleRect:relativePosition(self.professionIcon, self.levelLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	end			
end

function EquipItemDetailView:createDesLabel()
	local des 
	local viewSize = self:getScrollViewSize()
	if (self.item == nil or self.item:getStaticData() == nil) then
		des = " "		
	else
		des = PropertyDictionary:get_description(self.item:getStaticData().property)
	end
	
	if (des == "") then
		return nil
	end
	
	local desLabel = createLabelWithStringFontSizeColorAndDimension(des, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite2"), CCSizeMake(viewSize.width, 0))--设置高为0，让其自动调节	
	return desLabel
end

function EquipItemDetailView:initSwitchBtn()
	self.switchEquipInfoBtn = createButtonWithFramename(RES("common_tipsIcon.png"), RES("common_tipsIcon.png"))
	self:addChild(self.switchEquipInfoBtn, 10000)	
	VisibleRect:relativePosition(self.switchEquipInfoBtn, self.lineDown, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_OUTSIDE,ccp(-12,0))

	local onClick = function()
		if (self.curPropertyType == PropertyType.Detail) then
			self.curPropertyType = PropertyType.Summary
			self:showSummary()
			self:showFP()
		else
			self.curPropertyType = PropertyType.Detail		
			self:showDetail()			
		end
	end
	self.switchEquipInfoBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
end	

--返回 name value
function EquipItemDetailView:buildSummaryProperty()
	local pd = self.item:getPT()
	local washPropertys = G_buildWashPropertys(self.item)		
	if pd == nil then
		return
	end	
	local nodes = {}	
	local viewSize = self:getScrollViewSize()
	--todo 临时解决服务器不发min引发的显示问题，效率不高，有空改进
	for k,v in ipairs(E_ForgingDisplayPropertys) do
		if not pd[v.name] then
			pd[v.name] = 0
		end
	end
	for k, v in ipairs(E_ForgingDisplayPropertys) do	
		if (pd[v.name] and v.name ~= "strengtheningLevel") then
			local depend = v.depend
			if (depend) then
				local value1 = pd[v.name]
				if (value1 == nil) then
					value1 = 0
				end				
				local value2 = pd[(E_ForgingDisplayPropertys[v.depend].name)]
				if (value2 == nil) then
					value2 = 0
				end			
				
				if ((value2 == 0 and value1 == 0) or (value2 < value1)) then
--					print("EquipItemDetailView:buildSummaryProperty error: (value2 == 0 and value1 == 0) or (value2 < value1)")
				else
					--local value = string.format("%d-%d", value1, value2)
					local minValueColor = FCOLOR("ColorWhite2")
					local maxValueColor = nil
					local maxName = E_ForgingDisplayPropertys[v.depend].name
					if washPropertys[maxName] then		
						if 	washPropertys[maxName].value == 0 then
							maxValueColor = FCOLOR("ColorWhite2")
						elseif washPropertys[maxName].value == washPropertys[maxName].maxValue then
							maxValueColor = FCOLOR("ColorYellow5")
						else
							maxValueColor = FCOLOR("ColorBlue2")
						end
					end
					local node = self:createEquipKeyValue(KeyValueType.Depend, viewSize,v.fullName, value1,value2,nil,minValueColor,maxValueColor)
					table.insert(nodes, node)
				end
			elseif (v.ignoreByDepend ~= true) then
				local value = pd[v.name]
				if value > 0 then
					local node = self:createEquipKeyValue(KeyValueType.Independ, viewSize,v.translateName, value)
					table.insert(nodes, node)
				end
			end
		end
	end	
	local summaryPropertyNode = CCNode:create()
	
	G_layoutContainerNode(summaryPropertyNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize, false)
	return summaryPropertyNode
end		

function EquipItemDetailView:createEquipKeyValue(keyValueType,viewSize,name, minValue,maxValue, keyColor, minValueColor,maxValueColor)
	--[[if (valueColor == nil) then
		valueColor = FCOLOR("ColorWhite2")
	end--]]
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
	
function EquipItemDetailView:showSummary()	
	self.summaryPropertyNode:removeAllChildrenWithCleanup(true)
	
	local nodes = {}
	
	local viewSize = self:getScrollViewSize()
	
	local title1 = createSpriteWithFrameName(RES("word_label_wholeproperty.png"))
	local titleNode1 = CCNode:create()
	titleNode1:addChild(title1)
	titleNode1:setContentSize(CCSizeMake(viewSize.width, title1:getContentSize().height))	
	VisibleRect:relativePosition(title1, titleNode1, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(-3, 0))
	table.insert(nodes, titleNode1)		
		
	local summaryPropertyNode = self:buildSummaryProperty()
	table.insert(nodes, summaryPropertyNode)

	local skillNode = self:createSkillNode()
	if skillNode then
		table.insert(nodes, skillNode)	
	end
	
	local desNode = self:createDesLabel()
	if desNode ~= nil then
		local title2 = createSpriteWithFrameName(RES("word_label_description.png"))		
		local titleNode2 = CCNode:create()
		titleNode2:addChild(title2)
		titleNode2:setContentSize(CCSizeMake(viewSize.width, title2:getContentSize().height))	
		VisibleRect:relativePosition(title2, titleNode2, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(-3, 0))
		table.insert(nodes, titleNode2)		
		table.insert(nodes, desNode)
	end
	

	
	G_layoutContainerNode(self.summaryPropertyNode , nodes, const_spacing, E_DirectionMode.Vertical, self:getScrollViewSize(), true)
	self:setScrollNode(self.summaryPropertyNode)
end	

function EquipItemDetailView:createSkillNode()
	local skillRefId = PropertyDictionary:get_skillRefId(self.item:getStaticData())	
	if string.match(skillRefId,"skill") then
		local nodes = {}
		local viewSize = self:getScrollViewSize()
		local skillNameNode = CCNode:create()
		skillNameNode:setContentSize(CCSizeMake(viewSize.width,30))	
		local skillTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[10184],"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		VisibleRect:relativePosition(skillTitle,skillNameNode,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,0))
		skillNameNode:addChild(skillTitle)
			
		local nameStr = PropertyDictionary:get_name(GameData.Skill[skillRefId].property)	
		local skillName = createLabelWithStringFontSizeColorAndDimension(nameStr,"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1")) 					
		VisibleRect:relativePosition(skillName,skillTitle,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		skillNameNode:addChild(skillName)		
		table.insert(nodes,skillNameNode)
		
		local skillMgr = G_getHero():getSkillMgr()		
		local skillObj = skillMgr:getSkillObjectByRefId(skillRefId)
		local level  = 1
		if skillObj then	
			level = PropertyDictionary:get_level(skillObj:getPT())
		end
		
		local skillDescStr = self.item:getStaticData().property.tips						
		local skillDesc = createLabelWithStringFontSizeColorAndDimension(skillDescStr,"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"),CCSizeMake(viewSize.width-20,0)) 							
		table.insert(nodes,skillDesc)
		local skillNode = CCNode:create()
	
		G_layoutContainerNode(skillNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize, false)			
		return skillNode
	else
		return nil
	end
end
	
function EquipItemDetailView:showDetail()
	if (self.item == nil) then
		return
	end
	
	self.detailPropertyNode:removeAllChildrenWithCleanup(true)	
	local viewSize = self:getScrollViewSize()	
	local nodes = {}	
	
	local washPropertys = G_buildWashPropertys(self.item)
	if (washPropertys ~= nil)  then	
		if (table.size(washPropertys) > 0) then
			local title2 = createStyleTextLable(Config.Words[10054], "Price")
			local titleNode2 = CCNode:create()
			titleNode2:addChild(title2)
			titleNode2:setContentSize(CCSizeMake(viewSize.width, title2:getContentSize().height))	
			VisibleRect:relativePosition(title2, titleNode2, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(0, 0))
			table.insert(nodes, titleNode2)
		end
		for i, property in pairs(washPropertys) do			
			table.insert(nodes, self:createWashProperty(property, viewSize))
		end	
	end
	
	local tmpPd = self:getStrengthenPD(self.item, PropertyDictionary:get_strengtheningLevel(self.item:getPT()))
	local pd = {}
	if (tmpPd) then
		for k, v in pairs(tmpPd) do
			pd[k] = {[1] = v}
		end		
	end	
	pd["strengtheningLevel"] = nil
	local strengtheningLevel = PropertyDictionary:get_strengtheningLevel(self.item:getPT())	
	if (strengtheningLevel > 0 and table.size(pd) > 0) then
		local title1 = createStyleTextLable(Config.Words[10058], "Price")
		local titleNode1 = CCNode:create()
		titleNode1:addChild(title1)
		titleNode1:setContentSize(CCSizeMake(viewSize.width, title1:getContentSize().height))	
		VisibleRect:relativePosition(title1, titleNode1, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(0, 0))
		table.insert(nodes, titleNode1)
		
		local strengthenPropertysNode = self:buildStrengthenPropertys(pd, viewSize)		
		if (strengthenPropertysNode) then
			table.insert(nodes, strengthenPropertysNode)
		end						
	end
					
	local activePropertys = G_getForgingMgr():getPropertyGenerator():getStrengthenActivePD(self.item:getRefId(), const_maxStrengthenLevel)		
	if (activePropertys ~= nil) then
		local activePropertysNode = self:buildActivePropertys(activePropertys, viewSize, strengtheningLevel, -3)
		table.insert(nodes, activePropertysNode)
	end
		
	G_layoutContainerNode(self.detailPropertyNode , nodes, const_spacing, E_DirectionMode.Vertical, self:getScrollViewSize(), true)
	self:setScrollNode(self.detailPropertyNode)
end

function EquipItemDetailView:buildActivePropertys(propertys, viewSize, curStrengtheningLevel, xOffset)
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

function EquipItemDetailView:buildStrengthenPropertys(gpropertys, viewSize)	
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

function EquipItemDetailView:createStrengtheningProperty(property, values, viewSize)
	return self:createEquipKeyValue(KeyValueType.Independ,viewSize,property, tostring(values[1]))		
end


function EquipItemDetailView:createWashProperty(property, viewSize)
	if (property.value == property.maxValue) then
		return self:createEquipKeyValue(KeyValueType.Independ,viewSize, property.translateName, property.value, FCOLOR("ColorYellow2"), FCOLOR("ColorYellow5"))	
	else
		return self:createEquipKeyValue(KeyValueType.Independ,viewSize, property.translateName, property.value, FCOLOR("ColorYellow2"), FCOLOR("ColorWhite2"))	
	end
end

function EquipItemDetailView:getStrengthenPD(equip, strengtheningLevel)
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

function EquipItemDetailView:showEquipKnight()
	local heroPt = G_getHero():getPT()
	local limitKnightLevel = PropertyDictionary:get_equipKnight(self.item:getStaticData().property)
	local heroKnightLevel = PropertyDictionary:get_knight(heroPt)
	if not self.limitKnightLevelLabel then
		self.limitKnightLevelLabel = createLabelWithStringFontSizeColorAndDimension("010", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow10"))
		self:addChild(self.limitKnightLevelLabel)			
		self.limitKnightLevelLabel:setAnchorPoint(ccp(0, 0.5))
		VisibleRect:relativePosition(self.limitKnightLevelLabel, self.bodyAreaNameLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))	
	end	
	
	if limitKnightLevel == 0 then
		self.limitKnightLevelLabel:setVisible(false)
		return
	end
	
	local color = nil
	if heroKnightLevel >= limitKnightLevel then
		color = FCOLOR("ColorYellow10")
	elseif heroKnightLevel < limitKnightLevel then
		color = FCOLOR("ColorRed1")
	end	
	
	local name = G_getEquipMgr():getKnightNameByRefid("knight_"..limitKnightLevel)
	if color and name then
		self.limitKnightLevelLabel:setString(name)
		self.limitKnightLevelLabel:setColor(color)
		VisibleRect:relativePosition(self.limitKnightLevelLabel, self.bodyAreaNameLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))
	end
	self.limitKnightLevelLabel:setVisible(true)
end