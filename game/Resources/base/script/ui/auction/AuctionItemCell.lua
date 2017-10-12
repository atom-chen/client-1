AuctionItemCell = AuctionItemCell or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

function AuctionItemCell:__init(size)
	self.size = size
		
	self.rootNode = CCNode:create()	
	self.rootNode:retain()
	self.rootNode:setContentSize(self.size)	
	self:setSpacing(10, 5, 240, 350, 470)	
	self:initUI()		
end

function AuctionItemCell:__delete()
	self.rootNode:removeFromParentAndCleanup(true)
	self.rootNode:release()
end

function AuctionItemCell:initUI()
	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(self.size.width - 20, 2))
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)
end

function AuctionItemCell:setData(data)
	self.data = data
	self:updateView(data)
end	

function AuctionItemCell:updateView(data)
	if not self.itemView then
		self.itemView = ItemView.New()
		self.rootNode:addChild(self.itemView:getRootNode())
	end
	self.itemView:setItem(data)	
	self.itemView:showText(true)	
	VisibleRect:relativePosition(self.itemView:getRootNode(), self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(self.spacingIcon, 0))
	self.itemView:getRootNode():setVisible(data ~= nil)
	
	self:updateName(data)
	self:updateLevel(data)
	self:updateRemainTime(data)
	self:updatePrice(data)
end

function AuctionItemCell:setSpacing(spacingIcon, spacingName, spacingLevel, spacingRemainSec, spacingPrice)
	self.spacingIcon = spacingIcon
	self.spacingName = spacingName
	self.spacingLevel = spacingLevel
	self.spacingRemainSec = spacingRemainSec
	self.spacingPrice = spacingPrice
end

function AuctionItemCell:updateName(data)
	if not self.nameLabel then
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("Yellow2"))	
		self.rootNode:addChild(self.nameLabel)
	end		
	
	if (data and data:getStaticData()) then 	
		local color = G_getColorByItem(data)
		self.nameLabel:setString(PropertyDictionary:get_name(data:getStaticData().property))
		self.nameLabel:setColor(color)
	else
		self.nameLabel:setString(" ")
	end		
	VisibleRect:relativePosition(self.nameLabel, self.itemView:getRootNode(), LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(self.spacingName, 0))	
end

function AuctionItemCell:updateLevel(data)
	if not self.levelLabel then
		self.levelLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))	
		self.rootNode:addChild(self.levelLabel)
	end		
	
	if (data and data:getStaticData()) then 
		local str
		if data:getType() == ItemType.eItemEquip then
			str = tostring(PropertyDictionary:get_equipLevel(data:getStaticData().property))
		else
			str = tostring(PropertyDictionary:get_useLevel(data:getStaticData().property))
		end
		self.levelLabel:setString(str)
	else
		self.levelLabel:setString(" ")
	end		
	VisibleRect:relativePosition(self.levelLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(self.spacingLevel, 0))
end

function AuctionItemCell:updateRemainTime(data)
	if not self.remainTimeLabel then
		self.remainTimeLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))	
		self.rootNode:addChild(self.remainTimeLabel)
	end		
	
	if (data) then 	
		self.remainTimeLabel:setString(data:getRemainStr())
	else
		self.remainTimeLabel:setString(" ")
	end		
	VisibleRect:relativePosition(self.remainTimeLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(self.spacingRemainSec, 0))
end	

function AuctionItemCell:updatePrice(data)
	if not self.priceNode then
		self.priceNode = CCNode:create()				
		self.priceLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))							
		self.unbindedGoldIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))		
		self.priceNode:addChild(self.priceLabel)		
		self.priceNode:addChild(self.unbindedGoldIcon)	
		self.rootNode:addChild(self.priceNode)
	end		
	
	if (data) then 
		self.priceLabel:setString(tostring(data:getAuctionPrice()))
		self.priceNode:setContentSize(CCSizeMake(self.priceLabel:getContentSize().width + self.unbindedGoldIcon:getContentSize().width,  self.priceLabel:getContentSize().height + self.unbindedGoldIcon:getContentSize().height))
		VisibleRect:relativePosition(self.unbindedGoldIcon, self.priceNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y)		
		VisibleRect:relativePosition(self.priceLabel, self.priceNode, LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER_Y)			
		VisibleRect:relativePosition(self.priceNode, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(self.spacingPrice, 0))
	end		
	self.priceNode:setVisible(data ~= nil)
end	

function AuctionItemCell:getData()
	return self.data
end	
	
function AuctionItemCell:getRootNode()
	return self.rootNode
end