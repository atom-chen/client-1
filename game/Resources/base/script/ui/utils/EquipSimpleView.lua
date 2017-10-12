-- 显示一个装备的简单详情
 
require("common.baseclass")
require("object.bag.BagDef")
require("GameDef")
require("ui.utils.ItemView")

EquipSimpleView = EquipSimpleView or BaseClass()

local const_scale = VisibleRect:SFGetScale()
local const_size = VisibleRect:getScaleSize(CCSizeMake(278, 89))  --102

function EquipSimpleView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	
	self.isSelected = false
	self:init()
end		

function EquipSimpleView:__delete()
	self.rootNode:release()
	
	if (self.equipView) then
		self.equipView:DeleteMe()
		self.equipView = nil
	end		
end

function EquipSimpleView:getRootNode()
	return self.rootNode
end	

function EquipSimpleView:getShowFpTipsFlag()
	return self.bShowFpTips
end

function EquipSimpleView:setEquip(equip, bShowFpTips)
	if (equip == nil) then
		return
	end
	self.bShowFpTips = bShowFpTips
	self.equip = equip
	self:showIcon()
	self:showName()
	self:showFP()			
end	

function EquipSimpleView:setSelected(selected)
	if (self.seletedImage == nil) then
		self.seletedImage = createScale9SpriteWithFrameNameAndSize(RES("forging_selected.png"), const_size)
		self.rootNode:addChild(self.seletedImage, -1)
		VisibleRect:relativePosition(self.seletedImage, self.rootNode, LAYOUT_CENTER)
	end
	self.isSelected = selected
	self.seletedImage:setVisible(selected)
end

function EquipSimpleView:switchSelectedState()
	if (self.isSelected == true) then
		self:setSelected(false)
	else
		self:setSelected(true)
	end
	return self.isSelected	
end

function EquipSimpleView:getSelected()
	return self.isSelected
end

function EquipSimpleView:getEquipObj()
	return self.equipObj
end		


function EquipSimpleView:init()
	self.rootNode:setContentSize(const_size)
	
	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_size.width, 2))
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)
end

function EquipSimpleView:showName()
	if (self.nameLabel) then
		self.rootNode:removeChild(self.nameLabel, true)
	end
			
	if (self.equip and self.equip:getStaticData()) then	
		local color = G_getColorByItem(self.equip)
		local name = PropertyDictionary:get_name(self.equip:getStaticData().property)
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale, color)		
	else
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension("       ", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow7"))	
	end
	self.rootNode:addChild(self.nameLabel)		
	VisibleRect:relativePosition(self.nameLabel, self.equipView:getRootNode(), LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(10, -5))
end	

function EquipSimpleView:showFP()
	if (self.fpLabel == nil) then
		self.fpLabel = createStyleTextLable(Config.Words[10064], "FightPower")				
		self.fpText = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow5"))		
		self.rootNode:addChild(self.fpLabel)	
		self.rootNode:addChild(self.fpText)	
		
		VisibleRect:relativePosition(self.fpLabel, self.equipView:getRootNode(), LAYOUT_RIGHT_OUTSIDE + LAYOUT_BOTTOM_INSIDE, ccp(10, 0))
	end
	
	local name = "" 
	if (self.equip ~= nil) then
		name = string.format("%d", PropertyDictionary:get_fightValue(self.equip:getPT()))
	end		
	if (self.fpText:getString() ~= name)  then
		self.fpText:setString(name)
		self.fpText:setPosition(ccp(0, 0))		
		VisibleRect:relativePosition(self.fpText, self.fpLabel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 2))
	end
end	

function EquipSimpleView:showIcon()
	if (self.equipView == nil) then
		self.equipView = ItemView.New()
		self.equipView:showBindStatus(false)
		self.equipView:showText(false)
		self.rootNode:addChild(self.equipView:getRootNode())
		VisibleRect:relativePosition(self.equipView:getRootNode(), self.rootNode, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(16, 0))
	end	
	
	local equipMgr = G_getEquipMgr()
	if (self.equip) then
		self.equipView:setItem(self.equip)
		self.equipView:showBindStatus(true)
		self.equipView:showText(true)
		if (self.equip:getType() == ItemType.eItemEquip  and self.bShowFpTips) then
			G_showTipIcon(self.equip,self.equipView)
			--[[local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()	
			local isCanUse,buf,unableUseRet = G_getBagMgr():getOperator():checkCanPutOnEquip(self.equip)
			local levelRet = equipMgr:compareLp(self.equip)
			local compareWithPlayer = equipMgr:compareWithPlayerLevel(self.equip)	
			
			if isCanUse == true and levelRet == E_CompareRet.Smaller then
						 
				local ret = equipMgr:compareFp(self.equip)		--显示战力提示			
				if (ret == E_CompareRet.Greater) then
					self.equipView:showTipIcon("up")
				elseif (ret == E_CompareRet.Smaller) then
					self.equipView:showTipIcon("down")
				end					
			else
				if unableUseRet == E_UnableEquipType.Level then
					if compareWithPlayer == E_CompareRet.Smaller then
						self.equipView:showTipIcon("lessLevel")
					else
						self.equipView:showTipIcon("level")
					end	
				elseif unableUseRet == E_UnableEquipType.Profression then
					self.equipView:showTipIcon("profression")
				elseif unableUseRet == E_UnableEquipType.Gender then
					self.equipView:showTipIcon("gender")
				end
			end--]]
		
		else
			self.equipView:showTipIcon(nil)
		end
	end
end	