require("common.baseclass")
require("object.equip.EquipObject")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("object.equip.EquipDef")

-- 显示装备的部位
local constZ_bg 		= 10
local constZ_Quality	= 11
local constZ_Icon 		= 12	
local constZ_Text 		= 13
local constZ_Bind 		= 14
local constZ_Tip		= 15

local QUALITY_WHITE = 1
local QUALITY_BLUE = 2
local QUALITY_PURPLE = 3
local QUALITY_JINSE = 4
BodyAreaView = BodyAreaView or BaseClass()
local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_size 

function BodyAreaView:__init(contentSize)
	if contentSize == nil then
		self.contentSize = CCSizeMake(66, 66)
	else
		self.contentSize = contentSize()
	end
	self.rootNode = CCNode:create()
	self.rootNode:retain()	
	self.effectFlag = false
	self:initBg()
	
	local function scriptHandler(eventType)  
		if eventType == "enter" then
			self:showEffect(self.effectFlag)
		elseif eventType == "exit" then
			self:showEffect(false)
		end
    end  
  
    self.rootNode:registerScriptHandler(scriptHandler)
end	

function BodyAreaView:initBg()
	local btn = createButtonWithFramename(RES("bagBatch_itemBg.png"), RES("bagBatch_itemBg.png"), self.contentSize)				
	g_size = btn:getContentSize()
	local onClick = function()
		if (self.notify) then
			self.notify.func(self.notify.arg, self)
		end
	end
	self.rootNode:addChild(btn)
	self.rootNode:setContentSize(g_size)
	VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_CENTER)
	btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
end

function BodyAreaView:__delete()
	self.rootNode:release()	
	if self.forever then	
		self.forever:release()
		self.forever = nil
	end
end

function BodyAreaView:getRootNode()
	return self.rootNode
end

function BodyAreaView:setName(name)
	if (self.nameLable == nil) then
--		self.nameLable = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite3"))	
		self.nameLable = createStyleTextLable(name, "BodyArea")		
		self.rootNode:addChild(self.nameLable, 10)
	else
		self.nameLable:setString(name)
	end		
	VisibleRect:relativePosition(self.nameLable, self.rootNode, LAYOUT_CENTER)
end

function BodyAreaView:showNameImage(bShow)
	if self.nameImage then
		self.nameImage:setVisible(bShow)
	end
end

function BodyAreaView:setNameImage(image)
	if self.nameImage then
		self.nameImage:removeFromParentAndCleanup(true)
		self.nameImage = nil
	end
	self.nameImage = createSpriteWithFrameName(RES(image))
	self.rootNode:addChild(self.nameImage)
	VisibleRect:relativePosition(self.nameImage, self.rootNode, LAYOUT_CENTER)
end

function BodyAreaView:getName(name)
	return self.name
end

function BodyAreaView:getData()
	return self.data
end

function BodyAreaView:showAddIcon(bShow)
	if bIsShowAddIcon == bShow then
		return
	end
	if self.addIcon == nil then
		self.addIcon = createSpriteWithFrameName(RES("common_add_tips.png"))
		self.rootNode:addChild(self.addIcon)
		VisibleRect:relativePosition(self.addIcon, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE)	
	end
	self.addIcon:setVisible(bShow)
	self.bIsShowAddIcon = bShow
end

function BodyAreaView:isShowAddIcon()
	return self.bIsShowAddIcon
end

function BodyAreaView:setData(data)
	if (self.icon) then
		self.rootNode:removeChild(self.icon, true)
		self.icon = nil
	end	
	if (self.qualityBg) then
		self.rootNode:removeChild(self.qualityBg, true)
		self.qualityBg = nil
	end		
	
	self.data = data
	if (data == nil) then			
		self:showBindStatus(false)
		self:showText(false)	
		self.effectFlag = false	
		self:showNameImage(true)
	else		
		self.qualityBg = self:createQualityIcon(data)
		if (self.qualityBg) then
			self.rootNode:addChild(self.qualityBg, constZ_Quality)
			VisibleRect:relativePosition(self.qualityBg, self.rootNode, LAYOUT_CENTER)
		end
		self.icon = self:createEquipIcon(data)
		self.rootNode:addChild(self.icon, constZ_Icon)
		VisibleRect:relativePosition(self.icon, self.rootNode, LAYOUT_CENTER)
		
		self:showBindStatus(true)
		self:showText(true)
		self:checkEffect()
		self:showNameImage(false)
	end
	self:showEffect(self.effectFlag)
end

function BodyAreaView:setClickNotify(aarg, ffunc)
	self.notify = {arg = aarg, func = ffunc}
end	

-- 创建装备的view
function BodyAreaView:createEquipIcon(data)
	local icon = G_getIconByItem(data)	
	if (icon ~= nil) then
		icon = createSpriteWithFileName(icon)	
		G_setScale(icon)
	end		
	return icon
end	

function BodyAreaView:createQualityIcon(data)
	local staticData = data:getStaticData()
	if (staticData == nil) then
		return
	end
	local quality = PropertyDictionary:get_quality(staticData.property)
	local qualityBg = nil
	if (quality == QUALITY_WHITE or quality == "1") then
		qualityBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_iconBgWhite.png"), self.contentSize)
	elseif (quality == QUALITY_BLUE or quality == "2") then
		qualityBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_iconBgBlue.png"), self.contentSize)
	elseif	(quality == QUALITY_PURPLE or quality == "3") then
		qualityBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_iconBgPurple.png"), self.contentSize)	
		elseif	(quality == QUALITY_JINSE or quality == "4") then
		qualityBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_iconBgjinse.png"), self.contentSize)
	end			
	return qualityBg
end

function BodyAreaView:showText(show)
	if (show == true and self.data ~= nil and (self.data:getStaticData() ~= nil)) then	
		local text = " "
		if (self.data:getType() == ItemType.eItemEquip) then	
			local level = 	PropertyDictionary:get_strengtheningLevel(self.data:getPT())
			if level > 0 then
				text = string.format("+%d", level)
			end
		else
			local number = PropertyDictionary:get_number(self.data:getPT())
			if (number > 0) then
				text = tostring(number)
			end
		end		
		if (self.textLabel == nil) then	
			self.textLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))
			self.rootNode:addChild(self.textLabel, constZ_Text + 20)
			VisibleRect:relativePosition(self.textLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(8, 0))
		else
			if (self.textLabel:getString() ~= text) then
				self.textLabel:setString(text)
				VisibleRect:relativePosition(self.textLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(8, 0))
			end
		end
		self.textLabel:setVisible(true)
	else
		if (self.textLabel ~= nil) then
			self.textLabel:setVisible(false)
		end
	end
end

function BodyAreaView:showBindStatus(show)
	if (show == true and self.data ~= nil and self.data:getStaticData() ~= nil and PropertyDictionary:get_bindStatus(self.data:getPT()) == 1) then
		if (self.bindIcon == nil) then
			self.bindIcon = createSpriteWithFrameName(RES("bagBatch_iocnLock.png"))				
			self.rootNode:addChild(self.bindIcon, constZ_Bind)
			VisibleRect:relativePosition(self.bindIcon, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(8, 3))
		else
			self.bindIcon:setVisible(true)
		end
	else
		if (self.bindIcon ~= nil) then
			self.bindIcon:setVisible(false)
		end
	end
end

function BodyAreaView:checkEffect()
	if (self.data == nil or (self.data:getStaticData() == nil)) then
		self.effectFlag = false
		return
	end	
	if self.rootNode:getChildByTag(10) then
		self.rootNode:removeChildByTag(10,true)
	end
	local skill = PropertyDictionary:get_skillRefId(self.data:getStaticData().property)
	if string.match(skill,"skill") then	
		self.effectFlag = true
	else
		self.effectFlag = false
	end
end

function BodyAreaView:showEffect(beffectFlag)
	if not self.framesprite then
		self.framesprite = CCSprite:create()			
		self.rootNode:addChild(self.framesprite, constZ_Quality)
		VisibleRect:relativePosition(self.framesprite, self.rootNode, LAYOUT_CENTER)
		
		local animate = createAnimate("purpleQuality", 4, 0.2)
		self.forever = CCRepeatForever:create(animate)	
		self.forever:retain()
	end
	if beffectFlag then	
		self.framesprite:stopAllActions()
		self.framesprite:runAction(self.forever)
	else
		self.framesprite:stopAllActions()
	end
	self.framesprite:setVisible(beffectFlag)
end

