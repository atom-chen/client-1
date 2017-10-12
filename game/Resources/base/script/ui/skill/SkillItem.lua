SkillItem = SkillItem or BaseClass()

local rootNodeSize = CCSizeMake(95, 145)

function SkillItem:__init()
	self.viewName = "SkillItem"
	self.skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	self.rootNode = CCNode:create()	
	self.rootNode:retain()	
	self:initBg()
end		

function SkillItem:__delete()
	if self.rootNode then 
		self.rootNode:release()
		self.rootNode = nil
	end
end

function SkillItem:getRootNode()
	return self.rootNode
end		

function SkillItem:initBg()
	self.rootNode:setContentSize(rootNodeSize)	
	self.iconBg = createSpriteWithFrameName(RES("skill_bg.png"))
	self.skillNameBg = createScale9SpriteWithFrameNameAndSize(RES("skill_name_bg.png"), CCSizeMake(88, 20))	
	self.rootNode:addChild(self.iconBg)
	self.rootNode:addChild(self.skillNameBg)
	VisibleRect:relativePosition(self.iconBg, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(0, -10))
	VisibleRect:relativePosition(self.skillNameBg, self.iconBg, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))	

	self.nameLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow8"))
	self.rootNode:addChild(self.nameLabel)
	VisibleRect:relativePosition(self.nameLabel, self.skillNameBg, LAYOUT_CENTER)
end

function SkillItem:setSkillIconAndLearnLv(skillObject)
	if self.skillSprite and self.skillSprite:getParent() then 
		self.skillSprite:removeFromParentAndCleanup(true)
		self.skillSprite = nil
	end		
	if self.lockSprite and self.lockSprite:getParent() then 
		self.lockSprite:removeFromParentAndCleanup(true)
		self.lockSprite = nil
	end
	--技能图标	
	local iconId = PropertyDictionary:get_iconId(skillObject:getStaticData())
	if iconId == nil then
		iconId = "skill_bg.png"
	end		
	if iconId ~= nil then
		self.skillSprite = createSpriteWithFileName(ICON(iconId))
	else
		self.skillSprite = createSpriteWithFrameName(RES("skill_bg.png"))
	end			
	if self.skillSprite then 	
		self.rootNode:addChild(self.skillSprite)	
		VisibleRect:relativePosition(self.skillSprite, self.iconBg, LAYOUT_CENTER)
	end
	
	local bLock = self:checkLock(skillObject)
	if bLock then 
		self.lockSprite = createSpriteWithFrameName(RES("skill_lock.png"))	
		local heightLightSprite = createSpriteWithFrameName(RES("skill_heightlight_frame.png"))
		if self.lockSprite then 				
			self.rootNode:addChild(self.lockSprite)
			self.lockSprite:addChild(heightLightSprite)
			VisibleRect:relativePosition(self.lockSprite, self.iconBg, LAYOUT_CENTER)
			VisibleRect:relativePosition(heightLightSprite, self.lockSprite, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-5, -5))
		end		
		--[[local lv = PropertyDictionary:get_skillLearnLevel(skillObject:getStaticData())
		local lvLabel = nil
		if lv then 
			lv = "LV" .. lv
			lvLabel = createLabelWithStringFontSizeColorAndDimension(lv, "Arial", FSIZE("Size2"), FCOLOR("ColorGray3"))
			self.lockSprite:addChild(lvLabel)
			VisibleRect:relativePosition(lvLabel, self.lockSprite, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(0, 6))
		end	--]]
	end				
end		

function SkillItem:setSkillName(skillObject)
	if skillObject then 
	local name = PropertyDictionary:get_name(skillObject:getStaticData())	
		if name then 
			if skillObject:isLearn() then 
				self.nameLabel:setColor(FCOLOR("ColorYellow8"))
			else
				self.nameLabel:setColor(FCOLOR("ColorGray3"))
			end
			self.nameLabel:setString(name)			
			VisibleRect:relativePosition(self.nameLabel, self.skillNameBg, LAYOUT_CENTER)
		end
	end
end
						

--快捷标记
function SkillItem:setQuickMarkVisible(bShow)
	if self.markBg == nil then 	
		self.markBg = createSpriteWithFrameName(RES("common_selectBox.png"))
		self.rootNode:addChild(self.markBg)
		VisibleRect:relativePosition(self.markBg, self.nameLabel, LAYOUT_TOP_OUTSIDE, ccp(0, 1))
		VisibleRect:relativePosition(self.markBg, self.rootNode, LAYOUT_RIGHT_INSIDE, ccp(-3, 0))
	end
	if self.mark == nil then 
		self.mark = createSpriteWithFrameName(RES("common_selectIcon.png"))
		self.rootNode:addChild(self.mark)
		VisibleRect:relativePosition(self.mark, self.markBg, LAYOUT_CENTER)
	end
	
	self.mark:setVisible(bShow)
	self.markBg:setVisible(bShow)
end

function SkillItem:checkLock(skillObject)
	if skillObject then 
		local learn = skillObject:isLearn()	
		return  (not learn)
	end
end

function SkillItem:getIconBg()
	return self.iconBg
end


