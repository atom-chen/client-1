-- 显示一个物品  
require("common.baseclass")
require("object.bag.BagDef")
require("GameDef")

ItemView = ItemView or BaseClass()

local const_scale = VisibleRect:SFGetScale()

local QUALITY_WHITE = 1
local QUALITY_BLUE = 2
local QUALITY_PURPLE = 3
local QUALITY_JINSE = 4

local constZ_bg 		= 5
local constZ_Content	= 8
local constZ_Quality	= 500
local constZ_Icon 		= 12	
local constZ_Text 		= 13
local constZ_Bind 		= 14
local constZ_Tip		= 15
local constZ_Lock		= 16

function ItemView:__init(contentSize)
	if contentSize == nil then
		self.contentSize = CCSizeMake(60, 60)
	else
		self.contentSize = contentSize
	end
	self.rootNode = CCNode:create()
	self.rootNode:retain()	
	
	self.effectFlag = false
	self.isShowText = true
	self.contentNode = CCNode:create()
	self.rootNode:addChild(self.contentNode, constZ_Content)	
	
	self.contentVisible = true
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

function ItemView:__delete()
	self.rootNode:release()
	if self.forever then	
		self.forever:release()
		self.forever = nil
	end
end	

function ItemView:getRootNode()
	return self.rootNode
end	

function ItemView:showContent(bShow)
	self.contentNode:setVisible(bShow)
	self.contentVisible = bShow
end

function ItemView:isContentVisible()
	return self.contentVisible
end

function ItemView:setItem(item)
	self.item = item
	self:showQualityBg()
	self:showIcon()
	self:checkEffect()
	self:showEffect(self.effectFlag)	
	self:showText(self.isShowText)
end	

function ItemView:getItem()
	return self.item	
end	

function ItemView:showLock(bShow)
	self:setLockVisible(bShow)
end	

function ItemView:setLockVisible(bVisible)
	if self.lockIcon == nil and bVisible then
		self.lockIcon = createSpriteWithFrameName(RES("bagBatch_small_lock.png"))
		self.contentNode:addChild(self.lockIcon, constZ_Lock)
		VisibleRect:relativePosition(self.lockIcon, self.contentNode, LAYOUT_CENTER)
	end
	if self.lockIcon then
		self.lockIcon:setVisible(bVisible)
	end
end

function ItemView:initBg()
	self.itemBg = createScale9SpriteWithFrameName(RES("bagBatch_itemBg.png"))--, self.contentSize)			
	self.rootNode:addChild(self.itemBg, constZ_bg, constZ_bg)	
	self.contentNode:setContentSize(self.contentSize)
	self.rootNode:setContentSize(self.contentSize)	
	VisibleRect:relativePosition(self.itemBg, self.contentNode, LAYOUT_CENTER+LAYOUT_TOP_INSIDE)
end

function ItemView:showBg(bShow)
	if bShow then
		self.itemBg:setVisible(true)
	else
		self.itemBg:setVisible(false)
	end
end

function ItemView:showQualityBg()
	if self.qualityBg then
		self.contentNode:removeChild(self.qualityBg, true)
		self.qualityBg = nil
	end
	
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		return
	end
	local quality = PropertyDictionary:get_quality(self.item:getStaticData().property)	
	if self.quality == quality then
		return
	end
	
	if (quality == QUALITY_WHITE or quality == "1") then
		self.qualityBg = self:createQualityBg("bagBatch_iconBgWhite.png")		
	elseif (quality == QUALITY_BLUE or quality == "2") then
		self.qualityBg = self:createQualityBg("bagBatch_iconBgBlue.png")
	elseif	(quality == QUALITY_PURPLE or quality == "3") then
		self.qualityBg = self:createQualityBg("bagBatch_iconBgPurple.png")
	elseif	(quality == QUALITY_JINSE or quality == "4") then
		self.qualityBg = self:createQualityBg("bagBatch_iconBgjinse.png")
	end	
end

function ItemView:createQualityBg(image)
	local qualityBg = createScale9SpriteWithFrameNameAndSize(RES(image), self.contentSize)
	self.contentNode:addChild(qualityBg, constZ_Quality)
	VisibleRect:relativePosition(qualityBg, self.itemBg, LAYOUT_CENTER)	
	return qualityBg
end

function ItemView:showText(show)
	if self.textLabel then
		self.contentNode:removeChild(self.textLabel, true)
		self.textLabel = nil
	end
	
	if ((not show) or (not self.item) or (not self.item:getStaticData())) then
		return
	end
	
	local text = " "
	if (self.item:getType() == ItemType.eItemEquip) then	
		local level = PropertyDictionary:get_strengtheningLevel(self.item:getPT())
		if level > 0 then
			text = string.format("+%d", level)
		end
	else
		local number = PropertyDictionary:get_number(self.item:getPT())
		if (number > 1) then
			text = tostring(number)
		end
	end		
	
	self.textLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))
	self.contentNode:addChild(self.textLabel, constZ_Text)
	
	if (self.item:getType() == ItemType.eItemEquip) then
		VisibleRect:relativePosition(self.textLabel, self.itemBg,  LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(4, -2))	
	else
		VisibleRect:relativePosition(self.textLabel, self.itemBg,  LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-4, 2))	
	end
end

function ItemView:showTipIcon(iconType)
	if self.tipsType == iconType then
		return
	end
	if self.tipsIcon then
		self.contentNode:removeChild(self.tipsIcon, true)
	end
	
	self.tipsType = iconType
	self.tipsIcon = nil
	if iconType == "up" then
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_up_tip.png"))
		self.contentNode:addChild(self.tipsIcon, constZ_Tip)
		VisibleRect:relativePosition(self.tipsIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))			
	elseif iconType == "down" then	
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_down_tip.png"))		
		self.contentNode:addChild(self.tipsIcon, constZ_Tip)
		VisibleRect:relativePosition(self.tipsIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))		
	elseif iconType == "level" then	
		--[[self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_levellimit.png"))		
		self.contentNode:addChild(self.tipsIcon, constZ_Tip)
		VisibleRect:relativePosition(self.tipsIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))			--]]
	elseif iconType == "profression" or iconType == "gender" then	
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_prohibit.png"))
		self.contentNode:addChild(self.tipsIcon, constZ_Tip)
		VisibleRect:relativePosition(self.tipsIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))		
	elseif iconType == "lessLevel" then
		--[[self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_greenlevellimit.png"))
		self.contentNode:addChild(self.tipsIcon, constZ_Tip)
		VisibleRect:relativePosition(self.tipsIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))--]]		
	end					
end

function ItemView:showBindStatus(show)
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		return
	end
	
	if (show == true and PropertyDictionary:get_bindStatus(self.item:getPT()) == 1) then
		if (self.bindIcon == nil) then
			self.bindIcon = createSpriteWithFrameName(RES("bagBatch_iocnLock.png"))				
			self.contentNode:addChild(self.bindIcon, constZ_Bind)
			VisibleRect:relativePosition(self.bindIcon, self.itemBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(6, 5))
		else
			self.bindIcon:setVisible(true)
		end
	else
		if (self.bindIcon ~= nil) then
			self.bindIcon:setVisible(false)
		end
	end
end

function ItemView:showIcon()
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		if (self.icon) then
			self.contentNode:removeChild(self.icon, true)
		end
		return
	end
	
	if (self.icon ~= nil) then
		self.contentNode:removeChild(self.icon, true)
	end
	
 	local path = G_getIconByItem(self.item)		
	if (path ~= nil) then
		self.icon = createSpriteWithFileName(path)	
		if (self.icon ~= nil) then
			self.contentNode:addChild(self.icon, constZ_Icon)	
			VisibleRect:relativePosition(self.icon, self.itemBg, LAYOUT_CENTER)	
		end
	end		
end					

function ItemView:checkEffect()
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		self.effectFlag = false
		return
	end	
	if self.contentNode:getChildByTag(10) then
		self.contentNode:removeChildByTag(10,true)
	end
	local skill = PropertyDictionary:get_skillRefId(self.item:getStaticData().property)
	if string.match(skill,"skill") then	
		self.effectFlag = true
	else
		self.effectFlag = false
	end
end

function ItemView:showEffect(bShow)
	if not self.framesprite then
		self.framesprite = CCSprite:create()				
		self.contentNode:addChild(self.framesprite, constZ_Quality)
		VisibleRect:relativePosition(self.framesprite, self.itemBg, LAYOUT_CENTER)
		
		local animate = createAnimate("purpleQuality", 4, 0.2)		
		self.forever = CCRepeatForever:create(animate)	
		self.forever:retain()
	end
	if bShow then	
		self.framesprite:stopAllActions()
		self.framesprite:runAction(self.forever)
	else
		self.framesprite:stopAllActions()
	end
	self.framesprite:setVisible(bShow)
end

function ItemView:setButtomText(tips)
	if not tips then
		return
	end		
	if self.buttomTextLabel then
		self.buttomTextLabel:setString(tips)
	else
		self.buttomTextLabel = createLabelWithStringFontSizeColorAndDimension(tips, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		self.contentNode:addChild(self.buttomTextLabel, 1, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -2))		
	end
end