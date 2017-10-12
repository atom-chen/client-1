-- 显示一个物品  
require("common.baseclass")
require("object.bag.BagDef")
require("GameDef")
require("ui.utils.RelativeNode")

BatchItemView = BatchItemView or BaseClass()

local const_scale = VisibleRect:SFGetScale()

local QUALITY_WHITE = 1
local QUALITY_BLUE = 2
local QUALITY_PURPLE = 3
local QUALITY_JINSE = 4

local constZ_bg 		= 5
local constZ_Quality	= 6
local constZ_Icon 		= 12	
local constZ_Text 		= 13
local constZ_Bind 		= 14
local constZ_Tip		= 15
local constZ_Lock		= 16
local constZ_Effect		= 20

function BatchItemView:__init(size)
	if not size then
		size = CCSizeMake(64, 64)
	end
	self.bIsContentVisible = true
	self.effectFlag = false
		
	self.batchRootNode = RelativeNode.New(createSpriteWithFrameName(RES("bagBatch_itemBg.png"))	)
	
	local node = CCNode:create()
	node:setContentSize(size)
	self.normalRootNode = RelativeNode.New(node)	
	
	local onEvent = function(event)
		if event == "enter" then
			self:showEffect(self.effectFlag)
		elseif event == "exit" then
			self:showEffect(false)
		end
	end
	self.normalRootNode:getRootNode():registerScriptHandler(onEvent)
end		

function BatchItemView:__delete()
	if self.batchRootNode then
		self.batchRootNode:DeleteMe()
		self.batchRootNode = nil
	end
	if self.normalRootNode then
		self.normalRootNode:DeleteMe()
		self.normalRootNode = nil
	end
	if self.forever then
		self.forever:release()
		self.forever = nil
	end
end	

function BatchItemView:getBatchRootNode()
	return self.batchRootNode:getRootNode()
end	

function BatchItemView:getNormalRootNode()
	return self.normalRootNode:getRootNode()
end	

function BatchItemView:getRootNode()
	return self.normalRootNode:getRootNode()
end	

function BatchItemView:showContent(bShow)
	self.batchRootNode:setChildrenVisible(bShow)
	self.normalRootNode:setVisible(bShow)
	self.bIsContentVisible = bShow
end

function BatchItemView:isContentVisible()
	return self.bIsContentVisible
end

function BatchItemView:setItem(item)
	self.item = item
	self:showQualityBg()
	self:showIcon()
	self:checkEffect()
	self:showEffect(self.effectFlag)
end	

function BatchItemView:getItem()
	return self.item	
end	

function BatchItemView:showLock(bShow)
	self:setLockVisible(bShow)
end	

function BatchItemView:setLockVisible(bVisible)
	if (self.lockIcon == nil) and bVisible then
		self.lockIcon = createSpriteWithFrameName(RES("bagBatch_small_lock.png"))
		self.batchRootNode:addChild(self.lockIcon, constZ_Lock, LAYOUT_CENTER)
	end
	if self.lockIcon then
		self.lockIcon:setVisible(bVisible)
	end
end

function BatchItemView:showBg(bShow)
	self.batchRootNode:getRootNode():setVisible(bShow)
end

function BatchItemView:showQualityBg()
	if self.qualityBg then
		self.batchRootNode:removeChild(self.qualityBg)		
		self.qualityBg = nil
	end
	
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		return
	end
	local quality = PropertyDictionary:get_quality(self.item:getStaticData().property)	
	
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

function BatchItemView:createQualityBg(image)
	local qualityBg = createSpriteWithFrameName(RES(image))	
	self.batchRootNode:addChild(qualityBg, constZ_Quality, LAYOUT_CENTER)
	return qualityBg
end

function BatchItemView:showTipIcon(iconType)
	if self.tipsType == iconType then
		return
	end
	if self.tipsIcon then
--		self.batchRootNode:removeChild(self.tipsIcon)
		self.normalRootNode:removeChild(self.tipsIcon)
		self.tipsIcon = nil
	end
	
	self.tipsType = iconType
	self.tipsIcon = nil
	if iconType == "up" then
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_up_tip.png"))
	elseif iconType == "down" then	
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_down_tip.png"))				
	elseif iconType == "level" then	
		--self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_levellimit.png"))				
	elseif iconType == "profression" or iconType == "gender" then	
		self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_prohibit.png"))	
	elseif iconType == "lessLevel" then
		--self.tipsIcon = createSpriteWithFrameName(RES("bagBatch_greenlevellimit.png"))	
	end		
	if self.tipsIcon then
--		self.batchRootNode:addChild(self.tipsIcon, constZ_Tip, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))
		self.normalRootNode:addChild(self.tipsIcon, constZ_Tip, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-5, 3))
	end
end

function BatchItemView:showBindStatus(show)
	bShow = (show and self.item and self.item:getStaticData() and PropertyDictionary:get_bindStatus(self.item:getPT()) == 1)
	if self.bindIcon == nil then
		self.bindIcon = createSpriteWithFrameName(RES("bagBatch_iocnLock.png"))				
--		self.batchRootNode:addChild(self.bindIcon, constZ_Bind, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(6, 5))						
		self.normalRootNode:addChild(self.bindIcon, constZ_Bind, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, ccp(6, 5))						
	end
	if self.bindIcon then 
		self.bindIcon:setVisible(bShow)
	end			
end
		
function BatchItemView:checkEffect()
	if (self.item == nil or (self.item:getStaticData() == nil)) then
		self.effectFlag = false
		return
	end	
	
	local skill = PropertyDictionary:get_skillRefId(self.item:getStaticData().property)
	if string.match(skill,"skill") then	
		self.effectFlag = true
	else
		self.effectFlag = false
	end
end

-------------------------------------------
--非批处理
-------------------------------------------
function BatchItemView:showIcon()
	if (self.icon ~= nil) then
		self.normalRootNode:removeChild(self.icon)
		self.icon = nil
	end
	
	if (self.item == nil or (self.item:getStaticData() == nil)) then	
		return
	end
	
 	local path = G_getIconByItem(self.item)		
	if (path ~= nil) then
		self.icon = createSpriteWithFileName(path)	
		if (self.icon ~= nil) then
			self.normalRootNode:addChild(self.icon, constZ_Icon, LAYOUT_CENTER)	
		end
	end		
end		

function BatchItemView:showEffect(bShow)
	if (not self.framesprite) and bShow then
		self.framesprite = CCSprite:create()				
		self.normalRootNode:addChild(self.framesprite, constZ_Quality, LAYOUT_CENTER)
		
		local animate = createAnimate("purpleQuality", 4, 0.3)		
		self.forever = CCRepeatForever:create(animate)	
		self.forever:retain()
	end		
	if self.framesprite then	
		self.framesprite:setVisible(bShow)
		self.framesprite:stopAllActions()
		if bShow then
			self.framesprite:runAction(self.forever)
		else
			self.framesprite:stopAllActions()
		end
	end
end

function BatchItemView:setButtomText(tips)
	if not tips then
		return
	end		
	if self.buttomTextLabel then
		self.buttomTextLabel:setString(tips)
	else
		self.buttomTextLabel = createLabelWithStringFontSizeColorAndDimension(tips, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		self.normalRootNode:addChild(self.buttomTextLabel, 1, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -2))		
	end
end

function BatchItemView:updateLayout()
	self.batchRootNode:updateLayout()
	self.normalRootNode:updateLayout()
end

function RelativeNode:setPosition(point)
	self.batchRootNode:setPosition(point)
	self.normalRootNode:setPosition(point)
end

function BatchItemView:layoutNormalRootNode(target, layout, offset)
	self.normalRootNode:relativePosition(target, layout, offset)
end

function BatchItemView:layoutBatchRootNode(target, layout, offset)
	self.batchRootNode:relativePosition(target, layout, offset)
end

function BatchItemView:setParent(normalParent, batchParent)
	if normalParent then
		self.normalRootNode:setParent(normalParent)
		if batchParent then
			self.batchRootNode:setParent(batchParent)
		else
			self.batchRootNode:setParent(normalParent)
		end
	end
end

function BatchItemView:removeParent()
	self.batchRootNode:removeParent(normalParent)
	self.normalRootNode:removeParent(batchParent)
end

function BatchItemView:showText(show)
	if self.textLabel then
		self.normalRootNode:removeChild(self.textLabel)
		self.textLabel = nil
	end
	
	if ((not show) or (not self.item) or (not self.item:getStaticData())) then
		return
	end
	
	local text = ""
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
	
	if text ~= "" then
		self.textLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorGreen1"))	
		if (self.item:getType() == ItemType.eItemEquip) then
			self.normalRootNode:addChild(self.textLabel, constZ_Text, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(4, -2))	
		else
			self.normalRootNode:addChild(self.textLabel, constZ_Text, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-4, 2))
		end
	end
end

--显示物品下面的黄色数字
function BatchItemView:showNum(number)
	if not number then
		return
	end
	
	local isUnPropsItem = function(itemRefId)	
		for k,v in pairs(GameData.UnPropsItem) do
			if v.refId == itemRefId then
				return true
			end
		end
		return false
	end
	
	local itemTipSign = nil
	local refId = self.item:getRefId()
	if isUnPropsItem(refId) then
		itemBox = G_createUnPropsItemBox(refId)	
		itemTipSign = "+"
	elseif string.sub(refId, 1, 8) == "yuanbao_" then
		itemBox = createSpriteWithFileName(ICON(refId))			
	else
		itemBox = G_createItemBoxByRefId(refId,nil,nil,bindStatus)
		itemTipSign = "x"	
	end
	local numColor = FCOLOR("ColorYellow1")
	
	local itemTip = itemTipSign..tostring(number)
	
	if self.nameLabel then
		self.normalRootNode:removeChild(self.nameLabel)
		self.nameLabel = nil
	end
	self.nameLabel = createLabelWithStringFontSizeColorAndDimension(itemTip, "Arial", FSIZE("Size3"), numColor)
	self.normalRootNode:addChild(self.nameLabel, constZ_Text, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE)	
end