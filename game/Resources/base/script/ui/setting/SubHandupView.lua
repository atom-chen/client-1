require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require"data.skill.skill"
SubHandupView = SubHandupView or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_skillViewSpacing = 0
local const_pageSize = 3

local g_cellWidth = nil
--[[
	self.uiConfig = 	--UIconfig的格式
	{
		MP_AutoAdd = 50,
		HP_AutoAdd = 50,
		skillList = 
		{
			{refId = "", selectFlagIcon = nil, isSelected = false,}
		}
	}
--]]	

function SubHandupView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(const_settingBgSize)
	self.isShowTip = true	
	self:initUIConfig()
	self:initUI()
end

function SubHandupView:__delete()
	for k, v in pairs(self.uiConfig.skillList) do
		v.skillBgNode:release()
	end
	self.pageIndicateView:DeleteMe()
	self.rootNode:release()
end

function SubHandupView:getRootNode()
	return self.rootNode
end

function SubHandupView:onEnter()
	
end

function SubHandupView:initUI()
	self:initSliders()
	self:initScrollView()
	self:initPageIndicateView()
	self:createSkillViewList()
	self:updateSkillViewList()
	self:initBtn()
end	

function SubHandupView:updateUI() 
	self:handupConfigToUIConfig()
	self.hpSlider:setValue(self.uiConfig.HP_AutoAdd)
	self.mpSlider:setValue(self.uiConfig.MP_AutoAdd)
	self.moveToCitySlider:setValue(self.uiConfig.autoMoveToCityValue)
	for k, v in pairs(self.uiConfig.skillList) do	
		if v.selectFlagIcon then
			v.selectFlagIcon:setVisible(v.isSelected)
		end
	end
	self:updateSkillViewList()
end

--根据最新的挂机配置，更新ui配置
function SubHandupView:handupConfigToUIConfig()
	local handupConfig = G_getHandupConfigMgr():readHandupConfig()	

	self.uiConfig.MP_AutoAdd = handupConfig.MP_AutoAdd
	self.uiConfig.HP_AutoAdd = handupConfig.HP_AutoAdd
	self.uiConfig.autoMoveToCityValue = handupConfig.autoMoveToCityValue
	
	for k, v in pairs(self.uiConfig.skillList) do	
		v.isSelected = self:isSkillExist(handupConfig, v.refId)
	end	
end

function SubHandupView:initUIConfig()
	local defaultSkillList = G_getHandupConfigMgr():getDefaultSkillList()	--从配置表里获取出所有技能
	local handupConfig = G_getHandupConfigMgr():readHandupConfig()
		
	self.uiConfig = {}	
	self.uiConfig.MP_AutoAdd = handupConfig.MP_AutoAdd
	self.uiConfig.HP_AutoAdd = handupConfig.HP_AutoAdd
	self.uiConfig.autoMoveToCityValue = handupConfig.autoMoveToCityValue
	self.uiConfig.skillList = {}
	
	for k, v in pairs(defaultSkillList) do	--将所有可能的技能
		local skillObject = G_getHero():getSkillMgr():getSkillObjectByRefId(v)							
		local tmp =  {}
		tmp.refId = v
		tmp.icon = nil
		tmp.isSelected = self:isSkillExist(handupConfig, v)
		table.insert(self.uiConfig.skillList, tmp)
	end			
end

function SubHandupView:isSkillExist(handupConfig, refId)
	for k, v in pairs(handupConfig.skillList) do
		if v == refId then
			return true
		end
	end
	return false
end

--根据ui里的配置，生成挂机配置
function SubHandupView:uiConfigToHandupConfig()
	local handupConfig = {}
	handupConfig.MP_AutoAdd = self.uiConfig.MP_AutoAdd
	handupConfig.HP_AutoAdd = self.uiConfig.HP_AutoAdd
	handupConfig.autoMoveToCityValue = self.uiConfig.autoMoveToCityValue
	handupConfig.skillList = {}
	for k, v in pairs(self.uiConfig.skillList) do
		if (v.isSelected == true) then
			table.insert(handupConfig.skillList, v.refId)
		end
	end
	return handupConfig
end	

function SubHandupView:saveConfig()
	self.uiConfig.MP_AutoAdd = self.mpSlider:getValue()
	self.uiConfig.HP_AutoAdd = self.hpSlider:getValue()
	self.uiConfig.autoMoveToCityValue = self.moveToCitySlider:getValue()
	local handupConfig = self:uiConfigToHandupConfig()		
	
	G_getHandupConfigMgr():saveHandupConfig(handupConfig)
end

function SubHandupView:createSkillViewList()
	for k, v in pairs(self.uiConfig.skillList) do		
		self:createSkillView(v)		
	end
end

--EventUpdateExtendSkillRefId
function SubHandupView:updateSkillViewList()
	local scrollNode = self.scrollView:getContainer()
	if scrollNode then
		scrollNode:removeAllChildrenWithCleanup(true)	
	end
	
	local nodes = {}
	local handupConfig = G_getHandupConfigMgr():readHandupConfig()
	local index = 1
	for k, v in pairs(self.uiConfig.skillList) do		
		local skillObject = G_getHero():getSkillMgr():getSkillObjectByRefId(v.refId)
		if skillObject and skillObject:isLearn() then			--已经学习的技能才显示		
			table.insert(nodes, v.skillBgNode)	
			local skillMgr = G_getHero():getSkillMgr()
			local extendSkill =  skillMgr:switchToExtendSkill(v.refId)
			if extendSkill and (extendSkill ~= v.refId) then	--需要显示为扩展技能
				v.setIcon(extendSkill)
			else
				v.setIcon(v.refId)
			end
			v.indexAtScrollView = index							--记录下其在scrollView中的索引，在点击的时候使用到
			index = index + 1				
		else
			v.indexInScrollView = nil
		end
	end	
	
	local count = #(nodes)
	if count < 1 then
		return	
	end		
	local height = nodes[1]:getContentSize().height
	g_cellWidth = nodes[1]:getContentSize().width
	local width = g_cellWidth * const_pageSize
	local viewSize = CCSizeMake(width, height)
	self.scrollView:setViewSize(viewSize)
	self.scrollView:setPageEnable(true)
	VisibleRect:relativePosition(self.scrollView, self.line, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(0, -20))
	
	local layoutNode = CCNode:create()
	G_layoutContainerNode(layoutNode, nodes, const_skillViewSpacing, E_DirectionMode.Horizontal, viewSize, true)	
	
	
	local pageCount = math.ceil(count / const_pageSize)
	local container = CCNode:create()
	container:setContentSize(CCSizeMake(viewSize.width*pageCount, viewSize.height))	
	container:addChild(layoutNode)
	VisibleRect:relativePosition(layoutNode,container,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE)
	self.scrollView:setContainer(container)
	self.pageIndicateView:setPageCount(pageCount, 1)	
	self:layoutPageIndicateView()		
end

function SubHandupView:initScrollView()
	self.scrollView = createScrollViewWithSize(CCSizeMake(2, 2))
	self.scrollView:setDirection(1)
	self.rootNode:addChild(self.scrollView)
	--self.scrollView:setClippingToBounds(false)
	
	local switchSelectState = function(skill)
		if (skill.isSelected == true) then
			skill.selectFlagIcon:setVisible(false)
			skill.isSelected = false
		else
			skill.selectFlagIcon:setVisible(true)
			skill.isSelected = true
		end	
	end
	local scrollHandler = function(view, eventType, x, y)	
		if (eventType == 4) then  --kScrollViewTouchEnd		
			local offect = self.scrollView:getContentOffset().x				
			local isClick = self.scrollView:isTouchMoved()
			if isClick == false and table.size(self.uiConfig.skillList) > 0 then				
				local index = math.ceil((x - offect) / g_cellWidth)				
				local skill = self:findSkillViewByIndexAtScrollView(index)
				if skill then
					switchSelectState(skill)					
				end
				GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"SettingView","firstHandUpSkill")
			end
		end
		if (eventType == 5) then  --kScrollViewDidAnimateScrollEnd
			self.pageIndicateView:setIndex(self.scrollView:getPage() + 1)
			self:layoutPageIndicateView()
		end
	end
	self.scrollView:setHandler(scrollHandler)
end	

--根据在scrollView中index获取
function SubHandupView:findSkillViewByIndexAtScrollView(index)
	for k, v in pairs(self.uiConfig.skillList) do
		if v.indexAtScrollView == index then
			return v
		end
	end
	return nil
end

function SubHandupView:createSkillView(skill)	
	skill.setIcon = function(refId)
		if skill.icon then
			skill.skillBgNode:removeChild(skill.icon, true)
			skill.icon = nil
		end
			
		skill.icon = createSpriteWithFileName(ICON(PropertyDictionary:get_iconId(GameData.Skill[refId].property)))
		skill.skillBgNode:addChild(skill.icon)
		VisibleRect:relativePosition(skill.icon, skill.skillBgNode, LAYOUT_CENTER, ccp(0, 12))	
		if skill.nameLabel then
			skill.skillBgNode:removeChild(skill.nameLabel, true)
			skill.nameLabel = nil
		end
		local name = ""	
			
		local data = GameData.Skill[refId]	
		if (data) then
			data = data.property
			name = PropertyDictionary:get_name(data)
		end
		if name then
			skill.nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite1"))
			skill.skillBgNode:addChild(skill.nameLabel)
			VisibleRect:relativePosition(skill.nameLabel, skill.skillBgNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 10))	
		end			
	end
	
	skill.skillBgNode = CCNode:create()
	skill.skillBgNode:retain()
	skill.skillBgNode:setContentSize(VisibleRect:getScaleSize(CCSizeMake(114, 138)))

	skill.skillBg = createSpriteWithFrameName(RES("main_skillframe.png"))	
	local nameBg = createSpriteWithFrameName(RES("skill_skillBg.png"))	
	skill.skillBgNode:addChild(skill.skillBg)
	skill.skillBgNode:addChild(nameBg)
	VisibleRect:relativePosition(skill.skillBg, skill.skillBgNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -20))
	VisibleRect:relativePosition(nameBg, skill.skillBgNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 5))

	local selectBtn
	selectBtn, skill.selectFlagIcon = self:createSelectBox(skill)	
	skill.skillBgNode:addChild(selectBtn)		
	VisibleRect:relativePosition(selectBtn, skill.skillBgNode, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE, ccp(-3, -3))			
	
	skill.setIcon(skill.refId)
end

function SubHandupView:initBtn()
	self.okBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local okText = createSpriteWithFrameName(RES("word_button_sure.png"))
	self.rootNode:addChild(self.okBtn)
	self.rootNode:addChild(okText)		
	VisibleRect:relativePosition(self.okBtn, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(0, 13))
	VisibleRect:relativePosition(okText, self.okBtn, LAYOUT_CENTER)
	local onClick = function()
		self:saveConfig()
		GlobalEventSystem:Fire(GameEvent.EventHideSettingView)
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"SettingView","okBtn")
		-- 新手指引已完成
		GameWorld.Instance:getNewGuidelinesMgr():requestFunStepCompleteRequest("handUpSkillGuidence")	
	end
	self.okBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)		
end

function SubHandupView:createSelectBox(skill)
	local btn = createSpriteWithFrameName(RES("common_selectBox.png"))
	local selected = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn:addChild(selected)	
	VisibleRect:relativePosition(selected, btn, LAYOUT_CENTER)
	
	selected:setVisible(skill.isSelected)
	return btn, selected
end		
	
function SubHandupView:initSliders()
	local node1
	node1, self.hpSlider = self:createSlider(Config.Words[10138], "squares_redBar.png")
	self.hpSlider:setValue(self.uiConfig.HP_AutoAdd)
	
	local hpValueLab = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	hpValueLab:setString(math.floor(self.uiConfig.HP_AutoAdd).."%")
	local autoMoveToCityValueLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	autoMoveToCityValueLabel:setString(math.floor(self.uiConfig.autoMoveToCityValue).."%")
	
	local hpSliderFunc = function()
		self.uiConfig.HP_AutoAdd = math.floor(self.hpSlider:getValue())
		if self.uiConfig.HP_AutoAdd < self.uiConfig.autoMoveToCityValue  then
			if self.isShowTip == true then
				UIManager.Instance:showSystemTips(Config.Words[10511])
				self.isShowTip = false
									
				local TimeFunc = function ()									
					self.isShowTip = true
					if self.tipSchId then
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tipSchId)
						self.tipSchId = nil
					end			
				end
				self.tipSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(TimeFunc, 5, false)
								
			end			
			
			self.uiConfig.autoMoveToCityValue = self.uiConfig.HP_AutoAdd
			self.moveToCitySlider:setValue(self.uiConfig.autoMoveToCityValue)
			autoMoveToCityValueLabel:setString(self.uiConfig.autoMoveToCityValue.."%")
		end		
		hpValueLab:setString(self.uiConfig.HP_AutoAdd .."%")		
	end
	self.hpSlider:addTargetWithActionForControlEvents(hpSliderFunc,CCControlEventValueChanged)
	
	local node2 
	node2, self.mpSlider = self:createSlider(Config.Words[10139], "squares_blueBar.png")	
	self.mpSlider:setValue(self.uiConfig.MP_AutoAdd)
		
	self.line = createSpriteWithFrameName(RES("setting_line.png"))
	
	local mpValueLab = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	mpValueLab:setString(math.floor(self.uiConfig.MP_AutoAdd).."%")
	local mpSliderFunc = function()
		self.uiConfig.MP_AutoAdd = math.floor(self.mpSlider:getValue())		
		mpValueLab:setString(self.uiConfig.MP_AutoAdd .."%")		
	end
	self.mpSlider:addTargetWithActionForControlEvents(mpSliderFunc,CCControlEventValueChanged)	
	
	local node3
	node3, self.moveToCitySlider = self:createSlider(Config.Words[10510], "squares_redBar.png")
	
	if self.uiConfig.autoMoveToCityValue > self.uiConfig.HP_AutoAdd  then
		self.uiConfig.autoMoveToCityValue = self.uiConfig.HP_AutoAdd		
	end
	self.moveToCitySlider:setValue(self.uiConfig.autoMoveToCityValue)
	local onAutoMoveToCityValueChanged = function()
		self.uiConfig.autoMoveToCityValue = math.floor(self.moveToCitySlider:getValue())
		autoMoveToCityValueLabel:setString(self.uiConfig.autoMoveToCityValue.."%")	
		if self.uiConfig.autoMoveToCityValue > self.uiConfig.HP_AutoAdd  then
			if self.isShowTip == true then
				UIManager.Instance:showSystemTips(Config.Words[10511])
				self.isShowTip = false
									
				local TimeFunc = function ()									
					self.isShowTip = true
					if self.tipSchId then
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tipSchId)
						self.tipSchId = nil
					end			
				end
				self.tipSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(TimeFunc, 2, false)
								
			end
			
			self.uiConfig.autoMoveToCityValue = self.uiConfig.HP_AutoAdd
			self.moveToCitySlider:setValue(self.uiConfig.autoMoveToCityValue)
			autoMoveToCityValueLabel:setString(self.uiConfig.autoMoveToCityValue.."%")
		end		
	end
	self.moveToCitySlider:addTargetWithActionForControlEvents(onAutoMoveToCityValueChanged, CCControlEventValueChanged)
	
	local line3 = createSpriteWithFrameName(RES("setting_line.png"))
	
	self.rootNode:addChild(node1)
	self.rootNode:addChild(hpValueLab)
	self.rootNode:addChild(node2)
	self.rootNode:addChild(mpValueLab)
	self.rootNode:addChild(self.line)
	self.rootNode:addChild(autoMoveToCityValueLabel)
	self.rootNode:addChild(node3)
	self.rootNode:addChild(line3)
	VisibleRect:relativePosition(node1, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10, -45))
	VisibleRect:relativePosition(hpValueLab,node1,LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER_X,ccp(30,5))
	VisibleRect:relativePosition(node2, node1, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -35))
	VisibleRect:relativePosition(mpValueLab,node2,LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER_X,ccp(30,5))
	VisibleRect:relativePosition(self.line, node2, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -70))
	VisibleRect:relativePosition(node3, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10, -155))
	VisibleRect:relativePosition(autoMoveToCityValueLabel, node3, LAYOUT_TOP_OUTSIDE + LAYOUT_CENTER_X, ccp(30, 5))
	VisibleRect:relativePosition(line3,node3,LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE,ccp(0,20))		
end

function SubHandupView:createSlider(name, image)
	local bg = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"),CCSizeMake(230,20))		
	local progress = createScale9SpriteWithFrameNameAndSize(RES(image),G_sliderSize)
	local thumb = createSpriteWithFrameName(RES("main_slider.png"))	
	local slider = createSFControlSlider(bg, progress, thumb,G_sliderSize)
	local shade = createScale9SpriteWithFrameNameAndSize(RES("player_bar_frame.png"),CCSizeMake(G_sliderSize.width,20))
	slider:setShade(shade)	
	
	slider:setMinimumValue(0)
	slider:setMaximumValue(99)
	slider:setContentSize(CCSizeMake(225, bg:getContentSize().height))
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))	
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(330, 15))
	node:addChild(nameLabel)
	node:addChild(slider)
	VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(0,2))
	VisibleRect:relativePosition(slider, node, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE)
	return node, slider
end

function SubHandupView:initPageIndicateView()
	self.pageCount = 1
	self.pageIndicateView = createPageIndicateView(1, 1) 
	self.rootNode:addChild(self.pageIndicateView:getRootNode())	
	self:layoutPageIndicateView()
end

function SubHandupView:layoutPageIndicateView()
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.scrollView, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 30))
end

--新手引导
function SubHandupView:getFirstHandUpSkill()
	for k, v in pairs(self.uiConfig.skillList) do	
		if v.selectFlagIcon then
			v.isSelected = false
			v.selectFlagIcon:setVisible(v.isSelected)
		end
	end
	
	local firstHandupSkill = self:findSkillViewByIndexAtScrollView(1)
	if firstHandupSkill then
		return self.scrollView--firstHandupSkill.skillBg
	end
end

function SubHandupView:getOKBtn()
	return self.okBtn
end