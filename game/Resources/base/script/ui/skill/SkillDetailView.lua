require "common.baseclass"

SkillDetailView = SkillDetailView or BaseClass()

local Text_Z_Order = 100  --按钮上文字的ZOrder
local viewSize = VisibleRect:getScaleSize(CCSizeMake(465, 455))
local detailScrollViewSize = CCSizeMake(335, 65)
local scale = VisibleRect:SFGetScale()
local skillLvMarkOffset = {
[1] = ccp(79, -104),
[2] = ccp(201, -10),
[3] = ccp(322, -104),
}

function SkillDetailView:__init()
	self:init()
end

function SkillDetailView:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end		  
end

function SkillDetailView:getRootNode()
	return self.rootNode
end	

function SkillDetailView:init()
	self:createRootNode()	
	self:createUI()
end

function SkillDetailView:createRootNode()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()
		
	--背景	
	local detailsNodeBg =  CCSprite:create("ui/ui_img/common/skill_detail_bg.pvr")
	self.rootNode:addChild(detailsNodeBg)
	VisibleRect:relativePosition(detailsNodeBg, self.rootNode, LAYOUT_CENTER)
	
	local frame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemUnselect.png"), viewSize)
	self.rootNode:addChild(frame)
	VisibleRect:relativePosition(frame, detailsNodeBg, LAYOUT_CENTER)
	
	--本级、下级效果
	--self.curLvDescLable = createSpriteWithFrameName(RES("cur_lv_effect_label.png"))
	--self.nextLvDescLable = createSpriteWithFrameName(RES("next_lv_effect_label.png"))
	self.curLvDescLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[2009], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.nextLvDescLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[2010], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		
	self.rootNode:addChild(self.curLvDescLable)
	self.rootNode:addChild(self.nextLvDescLable)
	
	VisibleRect:relativePosition(self.curLvDescLable, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(21, -210))	
	VisibleRect:relativePosition(self.nextLvDescLable, self.curLvDescLable, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -detailScrollViewSize.height + 10))
	
	--技能等级火球
	self.skillLvMark = {}
	self.skillLearnLv = {}
	for i=1, 3 do 
		self.skillLvMark[i] = createSpriteWithFrameName(RES("skll_lv_desc .png"))		
		self.skillLvMark[i]:setVisible(false)
		self.rootNode:addChild(self.skillLvMark[i])
		VisibleRect:relativePosition(self.skillLvMark[i], self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, skillLvMarkOffset[i])
		
		self.skillLearnLv[i] = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorGray3"))
		self.rootNode:addChild(self.skillLearnLv[i])
		VisibleRect:relativePosition(self.skillLearnLv[i], self.skillLvMark[i], LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -1))
	end
end

function SkillDetailView:createUI()
	self:createSkillNameAndLevel()  --创建技能名和等级	
	self:createDescription()	--创建技能描述	
	self:createUpdateInfo()    --创建升级信息
	self:createQuickOption()   --创建快捷选项
	self:createSkillExpProgressBar()  --技能熟练度进度条
end

--------------------------以下函数是创建UI----------------------------------

--创建技能名称和等级
function SkillDetailView:createSkillNameAndLevel()
	self.skillLvBgFrame = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(200, 35))	
	self.nameLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	
	self.rootNode:addChild(self.skillLvBgFrame)	
	self.rootNode:addChild(self.nameLabel)
	
	self:repositionSkillNameAndLevel()
end

--创建技能描述
function SkillDetailView:createDescription()
	--lable
	--self.descriptionLabel1 = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"), CCSizeMake(detailScrollViewSize.width-30, 0))
	--self.descriptionLabel2 = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"), CCSizeMake(detailScrollViewSize.width-30, 0))
	self.descriptionLabel1 = createRichLabel(CCSizeMake(detailScrollViewSize.width,0))	
	self.descriptionLabel1:setFontSize(FSIZE("Size3"))	
	self.descriptionLabel2 = createRichLabel(CCSizeMake(detailScrollViewSize.width,0))	
	self.descriptionLabel2:setFontSize(FSIZE("Size3"))	
	--容器
	self.detailContainer1 = CCNode:create()
	self.detailContainer1:setContentSize(detailScrollViewSize)
	self.detailContainer1:addChild(self.descriptionLabel1)	
	
	self.detailContainer2 = CCNode:create()
	self.detailContainer2:setContentSize(detailScrollViewSize)
	self.detailContainer2:addChild(self.descriptionLabel2)	
	
	--scrollview
	self.descriptionScrollView1 = createScrollViewWithSize(detailScrollViewSize)
	self.descriptionScrollView1:setDirection(kSFScrollViewDirectionVertical)
	self.descriptionScrollView1:setPageEnable(false)
	self.descriptionScrollView1:setContainer(self.detailContainer1)
	self.rootNode:addChild(self.descriptionScrollView1)	
	
	self.descriptionScrollView2 = createScrollViewWithSize(detailScrollViewSize)
	self.descriptionScrollView2:setDirection(kSFScrollViewDirectionVertical)
	self.descriptionScrollView2:setPageEnable(false)
	self.descriptionScrollView2:setContainer(self.detailContainer2)
	self.rootNode:addChild(self.descriptionScrollView2)
	
	
	self:repositionDetailDescritpion()
end

--创建升级信息
function SkillDetailView:createUpdateInfo()
	--self.skillExpTitleLabel = createSpriteWithFrameName(RES("skill_need_exp_label.png"))
	self.skillExpTitleLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[2028], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.rootNode:addChild(self.skillExpTitleLabel)
			
	self.quickDrugsTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[2021], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.quickDrugstext = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite1"))	
	
	self.rootNode:addChild(self.quickDrugsTitle)		
	self.rootNode:addChild(self.quickDrugstext)	
	
	self:repositionUpdateInfo()
end


function SkillDetailView:createSkillExpProgressBar()
	self.skillProBar = createProgressBar(RES("player_expBarBg.png"),RES("player_hp.png"),CCSizeMake(311,15))
	--local percentage = heroHp/heroMaxHp*100
	self.skillProBar:setPercentage(0)			
	self.skillProBar:setNumberVisible(true)
	self.rootNode:addChild(self.skillProBar)
	VisibleRect:relativePosition(self.skillProBar, self.skillExpTitleLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(32, 0))

	local border = createScale9SpriteWithFrameNameAndSize(RES("player_bar_frame.png"), CCSizeMake(315, 25))
	self.skillProBar:addChild(border, -1)
	VisibleRect:relativePosition(border, self.skillProBar, LAYOUT_CENTER, ccp(0, 0))
end

--创建快捷选项
function SkillDetailView:createQuickOption()
	self.quickSettingBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.quickUpgradeBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.quickSettingSprite = createSpriteWithFrameName(RES("btn_1_select.png"))
	self.quickUpgradeSprite = createSpriteWithFrameName(RES("btn_1_select.png"))
	self.settingLabel = createSpriteWithFrameName(RES("quick_setting_label.png"))
	self.upgradeLabel = createSpriteWithFrameName(RES("quick_update_disable_label.png"))
	
	self.rootNode:addChild(self.quickSettingBtn)
	self.rootNode:addChild(self.quickUpgradeBtn)
	self.quickSettingBtn:addChild(self.quickSettingSprite, Text_Z_Order-1)
	self.quickUpgradeBtn:addChild(self.quickUpgradeSprite, Text_Z_Order-1)
	self.quickSettingBtn:addChild(self.settingLabel, Text_Z_Order)
	self.quickUpgradeBtn:addChild(self.upgradeLabel, Text_Z_Order)	
		
	VisibleRect:relativePosition(self.quickSettingSprite, self.quickSettingBtn, LAYOUT_CENTER)
	VisibleRect:relativePosition(self.quickUpgradeSprite, self.quickUpgradeBtn, LAYOUT_CENTER)
	VisibleRect:relativePosition(self.settingLabel, self.quickSettingBtn, LAYOUT_CENTER)
	VisibleRect:relativePosition(self.upgradeLabel, self.quickUpgradeBtn, LAYOUT_CENTER)
	VisibleRect:relativePosition(self.quickSettingBtn, self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-20, 5))
	VisibleRect:relativePosition(self.quickUpgradeBtn, self.quickSettingBtn, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_OUTSIDE, ccp(-25, 0))
	
	--快捷设置
	local quickSettingCB = function ()
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"SkillView")
		if self.curSkill and self.curSkill:isLearn() then 
			GlobalEventSystem:Fire(GameEvent.EventShowQuickView, self.curSkill)
		else
			UIManager.Instance:showSystemTips(Config.Words[2507])
		end	
	end 
	self.quickSettingBtn:addTargetWithActionForControlEvents(quickSettingCB, CCControlEventTouchDown)
	
	--快速升级
	local quickUpgradeCB = function()
		local quickDrug = G_getBagMgr():getItemNumByRefId("item_jinengExp")
		
		if quickDrug > 0 then
			local skillMgr = GameWorld.Instance:getSkillMgr()			
			if self.curSkill then			
				if self.curSkill:isMaxLevel() then
					UIManager.Instance:showSystemTips(Config.Words[2030])
				elseif not self.curSkill:isMaxExp() then
					local skillRefId = PropertyDictionary:get_skillRefId(self.curSkill:getPT())		
					skillMgr:requestAddSkillExp(skillRefId)
				else
					UIManager.Instance:showSystemTips(Config.Words[2029])
				end										
			end
		else
			--提示快速购买
			local mObj = G_IsCanBuyInShop("item_jinengExp") 
			if(mObj ~= nil) then 
				GlobalEventSystem:Fire(GameEvent.EventBuyItem, mObj,1)
			end				
		end
	end
	self.quickUpgradeBtn:addTargetWithActionForControlEvents(quickUpgradeCB, CCControlEventTouchDown)
end

-------------------------以下是界面需要的数据----------------------------------
function SkillDetailView:setIconSprite()
	local yOffset = -6
	if self.iconSprite then 
		self.iconSprite:removeFromParentAndCleanup(true)
		self.iconSprite = nil
	end
	local iconId = ""
	if self.curSkill and self.curSkill:isLearn() then 
		iconId = PropertyDictionary:get_iconId(self.curSkill:getStaticData())
		if iconId and iconId~="" then 
			self.iconSprite = createSpriteWithFileName(ICON(iconId))
		end
	else		
		self.iconSprite = createSpriteWithFrameName(RES("skill_lock.png"))
		yOffset = 13
	end	
	if self.iconSprite then 	
		self.rootNode:addChild(self.iconSprite)
		VisibleRect:relativePosition(self.iconSprite, self.rootNode, LAYOUT_CENTER_X, ccp(-8, 0))		
		VisibleRect:relativePosition(self.iconSprite, self.skillLvBgFrame, LAYOUT_BOTTOM_OUTSIDE, ccp(0, yOffset))		
	end
end

--设置技能名和等级
function SkillDetailView:setSkillNameAndLevel()
	if not self.curSkill then
		return
	end
	local skillName = ""
	--技能名
	local staticTable = self.curSkill:getStaticData()
	if staticTable ~= nil then
		skillName = PropertyDictionary:get_name(staticTable)
	end
	--技能等级	
	local curLv, maxLv = self.curSkill:geCurAndMaxLevel()
	
	skillName = skillName or ""
	curLv = curLv or ""
	maxLv = maxLv or ""
	
	local lvStr = string.format("LV.%d/%d", curLv, maxLv)
	self.nameLabel:setString(skillName .." ".. lvStr)	
	
	if self.curSkill then 
		local bLearn = self.curSkill:isLearn()
		if bLearn then 
			self:showLvMark(tonumber(curLv))
		else
			self:showLvMark(-1)
		end
	end
	self:showLearnLv()
	self:setIconSprite()
	self:repositionSkillNameAndLevel()
end

--设置技能描述信息
function SkillDetailView:setDetailDescritpion(curLv, maxLv, curSkillDesc, nextSkillDesc)
	local nextLv = nil
	if curLv ~= nil and maxLv ~= nil then
		if curLv < maxLv then
			nextLv = curLv + 1
		else
			nextLv = maxLv
		end
	end		
	
	--本级
	if curSkillDesc=="" then
		curSkillDesc = " "
	end		
	curSkillDesc = string.wrapRich(curSkillDesc, Config.FontColor["ColorWhite2"], FSIZE("Size3"))
	self.descriptionLabel1:clearAll()
	self.descriptionLabel1:appendFormatText(curSkillDesc)	
	local size = self.descriptionLabel1:getContentSize()

	if detailScrollViewSize.height > size.height then
		size.height = detailScrollViewSize.height
		--self.descriptionLabel1:setContentSize(size)
		self.detailContainer1:setContentSize(detailScrollViewSize)
	else
		self.detailContainer1:setContentSize(CCSizeMake(detailScrollViewSize.width, size.height))	
		self.descriptionScrollView1:setContentOffset(ccp(0, -(size.height-detailScrollViewSize.height)), false)	
	end	
	self.descriptionScrollView1:updateInset()		
		
	--下级			
	if curLv == maxLv then
		nextSkillDesc = Config.Words[2008]
	end
	
	if nextSkillDesc=="" then
		nextSkillDesc = " "
	end
	nextSkillDesc = string.wrapRich(nextSkillDesc, Config.FontColor["ColorWhite2"], FSIZE("Size3"))
	self.descriptionLabel2:clearAll()
	self.descriptionLabel2:appendFormatText(nextSkillDesc)	
	size = self.descriptionLabel2:getContentSize()	

	if detailScrollViewSize.height > size.height then
		size.height = detailScrollViewSize.height
		--self.descriptionLabel2:setContentSize(size)
		self.detailContainer2:setContentSize(detailScrollViewSize)
	else
		self.detailContainer2:setContentSize(CCSizeMake(detailScrollViewSize.width, size.height))
		self.descriptionScrollView2:setContentOffset(ccp(0, -(size.height-detailScrollViewSize.height)), false)	
	end	
	self.descriptionScrollView2:updateInset()	
	
	--reposition
	self:repositionDetailDescritpion()
end

--设置升级信息
function SkillDetailView:setUpdateInfo(needProText, curProText, quickDrug, realizeLv)
	if not self.curSkill then
		return
	end
	local curSkillLv = PropertyDictionary:get_level(self.curSkill:getPT())			
	--技能成熟度
	if needProText and curProText then 	
		if tonumber(curProText) > tonumber(needProText) then 
			curProText = needProText
		end
		self.skillProBar:setMaxNumber(tonumber(needProText))
		self.skillProBar:setCurrentNumber(tonumber(curProText))		
	end				
		
	--速成药
	if type(quickDrug) == "number" then
		quickDrug = string.format("%d", quickDrug) or ""
		self.quickDrugstext:setString(quickDrug)
	end		
	
	self:repositionUpdateInfo()
end

function SkillDetailView:setCurSkill(skillObject)
	self.curSkill = skillObject
end

function SkillDetailView:setUpgradeEnabled(bEnabled)
	if bEnabled then 
		UIControl:SpriteSetColor(self.quickUpgradeSprite, self.upgradeLabel)
	else
		UIControl:SpriteSetGray(self.quickUpgradeSprite, self.upgradeLabel)
	end				
	self.quickUpgradeBtn:setEnabled(bEnabled)	
end

function SkillDetailView:setSettingEnabled(bEnabled)	
	if bEnabled then 
		UIControl:SpriteSetColor(self.quickSettingSprite, self.settingLabel)
	else
		UIControl:SpriteSetGray(self.quickSettingSprite, self.settingLabel)
	end	
	self.quickSettingBtn:setEnabled(bEnabled)
end

function SkillDetailView:showVisibleView()
	if not self.curSkill then
		return
	end
	local skillRefId = PropertyDictionary:get_skillRefId(self.curSkill:getPT())
	local curLv = PropertyDictionary:get_level(self.curSkill:getPT())
	local maxLv = table.size(self.curSkill:getSkillLevelTable())
	local skillMgr = GameWorld.Instance:getSkillMgr()
	
	local bLock = false
	if self.curSkill:isLearn() == false then 	
		bLock = true			
	else		
		local quickDrug = G_getBagMgr():getItemNumByRefId("item_jinengExp")	
	end			
	
	if skillRefId == const_skill_pugong then 
		self:showorHideUpgradeView(false)
		self:showorHideNextEffectInfo(false)							
	else		
		if curLv == maxLv or bLock then 
			self:showorHideUpgradeView(false)			
			if bLock then 						
				self:showorHideNextEffectInfo(false)
			else
				self:showorHideNextEffectInfo(true)
			end
		else
			self:showorHideUpgradeView(true)		
			self:showorHideNextEffectInfo(true)
		end								
	end
	
end

--是否显示升级信息
function SkillDetailView:showorHideUpgradeView(bShow)
	self.skillExpTitleLabel:setVisible(bShow)
	--self.skillExpText:setVisible(bShow)
	self.quickDrugsTitle:setVisible(bShow) 
	self.quickDrugstext:setVisible(bShow) 
	self.skillProBar:setVisible(bShow)	
end

--是否显示下级效果
function SkillDetailView:showorHideNextEffectInfo(bShow)
	self.descriptionScrollView2:setVisible(bShow)	
	self.nextLvDescLable:setVisible(bShow)
end	

function SkillDetailView:showorHideBtn(bShow)
	self.quickSettingBtn:setVisible(bShow)
	self.quickUpgradeBtn:setVisible(bShow)
end

--------------------------------Private--------------------
function SkillDetailView:showLvMark(curLv)
	if curLv < 0 then 
		for lv, sprite in pairs(self.skillLvMark) do 		
			sprite:setVisible(false)			
		end
	end
	for lv, sprite in pairs(self.skillLvMark) do 
		if curLv >= lv then
			sprite:setVisible(true)
		else
			sprite:setVisible(false)
		end
	end
end

function SkillDetailView:showLearnLv()
	if not self.curSkill then
		return
	end
	local cnt = table.size(self.curSkill:getSkillLevelTable())
	if cnt == 0 then 
		for i = 1, 3 do
			self.skillLearnLv[i]:setVisible(false)
		end
	end
	for i=1, cnt do 
		self.skillLearnLv[i]:setVisible(true)
		local lv = PropertyDictionary:get_skillLearnLevel(self.curSkill:getSkillLevelPropertyTable(i))
		self.skillLearnLv[i]:setString(lv..Config.Words[2014])		
		VisibleRect:relativePosition(self.skillLearnLv[i], self.skillLvMark[i], LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -1))
	end
	
end

function SkillDetailView:repositionUpdateInfo()
	VisibleRect:relativePosition(self.skillExpTitleLabel, self.descriptionScrollView2, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -1))
	VisibleRect:relativePosition(self.skillExpTitleLabel, self.nextLvDescLable, LAYOUT_LEFT_INSIDE, ccp(0, 0))
	--VisibleRect:relativePosition(self.skillExpText, self.skillExpTitleLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(25, 0))
	VisibleRect:relativePosition(self.quickDrugsTitle, self.quickUpgradeBtn, LAYOUT_CENTER_Y, ccp(0, 0))
	VisibleRect:relativePosition(self.quickDrugsTitle, self.rootNode, LAYOUT_LEFT_INSIDE, ccp(15, 0))
	VisibleRect:relativePosition(self.quickDrugstext, self.quickDrugsTitle, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
end

function SkillDetailView:repositionDetailDescritpion()
	VisibleRect:relativePosition(self.descriptionLabel1, self.detailContainer1, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, 0))
	VisibleRect:relativePosition(self.descriptionLabel2, self.detailContainer2, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, 0))	
	VisibleRect:relativePosition(self.descriptionScrollView1, self.curLvDescLable, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(10, 0))		
	VisibleRect:relativePosition(self.descriptionScrollView2, self.nextLvDescLable, LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(10, 0))	
end	

function SkillDetailView:repositionSkillNameAndLevel()
	VisibleRect:relativePosition(self.skillLvBgFrame, self.rootNode, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(-6, -89))	
	VisibleRect:relativePosition(self.nameLabel, self.skillLvBgFrame, LAYOUT_CENTER, ccp(-6, 0))
end

----------------------新手指引----------------------
function SkillDetailView:getQuickSettingBtn()
	return self.quickSettingBtn
end