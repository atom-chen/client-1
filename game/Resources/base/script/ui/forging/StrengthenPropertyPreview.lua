require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.forging.ForgingDef")
	
StrengthenPropertyPreview = StrengthenPropertyPreview or BaseClass(BaseUI)

local const_scale = VisibleRect:SFGetScale()
local const_size = const_forgingPreviewSize
local const_spacing = 20	

function StrengthenPropertyPreview:__init()
	self.rootNode:setContentSize(const_size)	
	self.scrollViewSize = CCSizeMake(const_size.width, const_forgingPreviewSize.height - 50 *  const_scale)
	
	self:initScrollView()	
	self.step = 1	
end

function StrengthenPropertyPreview:__delete()
	self.scrollNode:release()
end		

function StrengthenPropertyPreview:setScrollViewSize(size)
	self.scrollViewSize = size
	self.scrollView:setViewSize(size)
end	

function StrengthenPropertyPreview:setStep(step)
	self.step = step
end	

function StrengthenPropertyPreview:initScrollView()
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(const_size)
	self.scrollNode:retain()
	
	self.strengtheningLevelMaxTips = createLabelWithStringFontSizeColorAndDimension(string.format(Config.Words[10146], const_maxStrengthenLevel), "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))								
	self.rootNode:addChild(self.strengtheningLevelMaxTips)	
	VisibleRect:relativePosition(self.strengtheningLevelMaxTips, self.rootNode, LAYOUT_CENTER)	
	self.strengtheningLevelMaxTips:setVisible(false)			
	
	self.scrollView = self:createScrollView(self.scrollViewSize)
	self.rootNode:addChild(self.scrollView, 10)	
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -25))	
end

function StrengthenPropertyPreview:setEquip(equip)
	self.equip = equip
	if (equip ~= nil) then	
		local strengtheningLevel = PropertyDictionary:get_strengtheningLevel(equip:getPT())
		if (strengtheningLevel > const_maxStrengthenLevel or strengtheningLevel < 0) then
			self.scrollNode:removeAllChildrenWithCleanup(true)
			return
		elseif (strengtheningLevel == const_maxStrengthenLevel) then
			self.strengtheningLevelMaxTips:setVisible(true)
			self.scrollNode:removeAllChildrenWithCleanup(true)
		else		
			local nextStrengtheningLevel = strengtheningLevel + self.step
			self.strengtheningLevelMaxTips:setVisible(false)		
			self:buildPreview(equip, strengtheningLevel, nextStrengtheningLevel)
		end
	else
		self.strengtheningLevelMaxTips:setVisible(false)
		self.scrollNode:removeAllChildrenWithCleanup(true)
	end
end		

--[[PDOperator:differentPopertys	 
返回 table = { "property" ={[1] = value1, [2] = value2}, "property" ={[1] = value1, [2] = value2} .. }--]]
function StrengthenPropertyPreview:buildPreview(equip, curStrengtheningLevel, nextStrengtheningLevel)
	self.scrollNode:removeAllChildrenWithCleanup(true)
	
	self.curPD = self:getStrengthenPD(equip, curStrengtheningLevel)
	self.nextPD = self:getStrengthenPD(equip, nextStrengtheningLevel)
	
	local nodes = {}	
		
	local diffPropertys = PDOperator.differentPopertys(self.curPD, self.nextPD)	
	local strengthenPropertysNode = G_buildStrengthenPropertys(diffPropertys, self.scrollViewSize, true)		
	table.insert(nodes, strengthenPropertysNode)
	
	local curActivePropertys = G_getForgingMgr():getPropertyGenerator():getStrengthenActivePD(equip:getRefId(), curStrengtheningLevel)
	local nextActivePropertys = G_getForgingMgr():getPropertyGenerator():getStrengthenActivePD(equip:getRefId(), nextStrengtheningLevel)
	local ret = PDOperator.sub(nextActivePropertys, curActivePropertys)
	local activePropertysNode = nil
	if (ret ~= nil) then
		activePropertysNode = self:buildActivePropertys(ret, self.scrollViewSize, nil, 80)
		table.insert(nodes, activePropertysNode)
	end
	
	G_layoutContainerNode(self.scrollNode, nodes, const_spacing, E_DirectionMode.Vertical, self.scrollViewSize, true)	
	self.scrollView:setContainer(self.scrollNode)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(0, -self.scrollNode:getContentSize().height + self.scrollViewSize.height), false)
end

function StrengthenPropertyPreview:buildActivePropertys(propertys, viewSize, curStrengtheningLevel, xOffset)
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
						table.insert(nodes, self:createEquipKeyValue(displayProperty.translateName, "+"..value, viewSize, FCOLOR("ColorGray3"), FCOLOR("ColorGray3")))														
					else
						UIControl:SpriteSetColor(titleText)
						table.insert(nodes, self:createEquipKeyValue(displayProperty.translateName, "+"..value, viewSize))						
					end
				end	
			end
		end
	end
	
	local activeNode = CCNode:create()
	G_layoutContainerNode(activeNode, nodes, const_spacing, E_DirectionMode.Vertical, viewSize)	
	return activeNode
end

function StrengthenPropertyPreview:createEquipKeyValue(name, value, viewSize, keyColor, valueColor)
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
	
	VisibleRect:relativePosition(keyLabel, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(80, 0))	
	VisibleRect:relativePosition(value1Label, node, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(190, 0))	
	return node
end


function StrengthenPropertyPreview:getCurPD()
	return self.curPD
end

function StrengthenPropertyPreview:getNextPD()
	return self.nextPD
end	

function StrengthenPropertyPreview:getStrengthenPD(equip, strengtheningLevel)
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

function StrengthenPropertyPreview:createScrollView(viewSize)
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	return scrollView
end			

function StrengthenPropertyPreview:onEnter(arg)
	self:setEquip(arg.equip)
	self:setStep(arg.step)
end	