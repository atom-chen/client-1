require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.skillShow.SkillShowManager")

SubOptionView = SubOptionView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local SettingMgr = nil
local musicOff = nil
local voiceOff = nil

function SubOptionView:__init()
	self.rootNode:setContentSize(const_settingBgSize)
	SettingMgr = GameWorld.Instance:getSettingMgr()
	self:initView()
end

function SubOptionView:__delete()

end

function SubOptionView:onExit()
	SettingMgr:saveOptionConfig(self.OptionConfig)
end

function SubOptionView:initView()
	self.OptionConfig = SettingMgr:readOptionConfig()
	--self:saveOptionConfig(config)
	self:initSoundSetting()
	self:initOptionSetting()
	self:initButton()
end

function SubOptionView:onEnter()
	
end

function SubOptionView:initSoundSetting()
	local soundSettingSpr = createSpriteWithFrameName(RES("setting_sound.png"))
	
	local line1 = createSpriteWithFrameName(RES("setting_line.png"))
	
	local voiceValueLab = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	voiceValueLab:setString(math.floor(self.OptionConfig.voiceValue).."%")
	local musicValueLab = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	musicValueLab:setString(math.floor(self.OptionConfig.musicValue).."%")
	
	--声音
	local node1
	node1, self.musicSlider = self:createSlider(Config.Words[10501], "squares_yellowBar.png")
	self.musicSlider:setValue(self.OptionConfig.musicValue)
	local musicSliderFunc = function()
		self.OptionConfig.musicValue = math.floor(self.musicSlider:getValue())
		musicValueLab:setString(self.OptionConfig.musicValue.."%")
		if self.OptionConfig.musicOff == Setting_checkStatus.FALSE  then
			self:setMusicValue(self.OptionConfig.musicValue)
		end
	end
	self.musicSlider:addTargetWithActionForControlEvents(musicSliderFunc,CCControlEventValueChanged)
	--静音
	local musicOffFunc = function()
		if musicOff:getSelect() then
			self.OptionConfig.musicOff = Setting_checkStatus.TRUE	--设置为静音

			self:setMusicValue(0)
		elseif musicOff:getSelect() == false then
			self.OptionConfig.musicOff = Setting_checkStatus.FALSE
			self:setMusicValue(self.OptionConfig.musicValue)
		end
	end
	musicOff = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, musicOffFunc)
	musicOff:setTouchAreaDelta(0, 40, 0, 0)
	local musicOffLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10509], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	if self.OptionConfig.musicOff == Setting_checkStatus.TRUE then
		musicOff:setSelect(true)
	elseif self.OptionConfig.musicOff == Setting_checkStatus.FALSE then
		musicOff:setSelect(false)
	end
	
	--音效
	local node2
	node2, self.voiceSlider = self:createSlider(Config.Words[10502], "squares_yellowBar.png")
	self.voiceSlider:setValue(self.OptionConfig.voiceValue)
	local voiceSliderFunc = function()
		self.OptionConfig.voiceValue = math.floor(self.voiceSlider:getValue())
		voiceValueLab:setString(self.OptionConfig.voiceValue.."%")
		if self.OptionConfig.voiceOff == Setting_checkStatus.FALSE then
			self:setVoiceValue(self.OptionConfig.voiceValue)
			SettingMgr:setVoiceValue(self.OptionConfig.voiceValue)
		end
	end
	self.voiceSlider:addTargetWithActionForControlEvents(voiceSliderFunc,CCControlEventValueChanged)
	--静音
	local voiceOffFunc = function()
		if voiceOff:getSelect() then
			self.OptionConfig.voiceOff = Setting_checkStatus.TRUE	--设置为静音

			self:setVoiceValue(0)
			SettingMgr:setVoiceOff(Setting_checkStatus.TRUE)
		elseif voiceOff:getSelect() == false then
			self.OptionConfig.voiceOff = Setting_checkStatus.FALSE
			self:setVoiceValue(self.OptionConfig.voiceValue)
			SettingMgr:setVoiceOff(Setting_checkStatus.FALSE)
		end
	end
	voiceOff = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, voiceOffFunc)
	voiceOff:setTouchAreaDelta(0, 40, 0, 0)
	local voiceOffLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10509], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	
	local line2 = createSpriteWithFrameName(RES("setting_line.png"))
	
	
	if self.OptionConfig.voiceOff == Setting_checkStatus.TRUE then
		voiceOff:setSelect(true)
	elseif self.OptionConfig.voiceOff == Setting_checkStatus.FALSE then
		voiceOff:setSelect(false)
	end
	
	self.rootNode:addChild(soundSettingSpr)
	self.rootNode:addChild(line1)
	self.rootNode:addChild(node1)
	self.rootNode:addChild(musicOff)
	self.rootNode:addChild(musicOffLab)
	self.rootNode:addChild(voiceValueLab)
	self.rootNode:addChild(node2)
	self.rootNode:addChild(voiceOff)
	self.rootNode:addChild(voiceOffLab)
	self.rootNode:addChild(musicValueLab)
	self.rootNode:addChild(line2)
	--[[	self.rootNode:addChild(autoMoveToCityValueLabel)
	self.rootNode:addChild(node3)
	self.rootNode:addChild(line3)--]]
	
	VisibleRect:relativePosition(soundSettingSpr,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,-25))
	VisibleRect:relativePosition(line1,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-56))
	VisibleRect:relativePosition(node1, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(20, -91))
	VisibleRect:relativePosition(musicOff,node1,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(-63,5))
	VisibleRect:relativePosition(musicOffLab,musicOff,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
	VisibleRect:relativePosition(musicValueLab, node1, LAYOUT_TOP_OUTSIDE + LAYOUT_CENTER_X, ccp(0, 5))
	VisibleRect:relativePosition(node2, node1, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -35))
	VisibleRect:relativePosition(voiceOff,node2,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(-63,5))
	VisibleRect:relativePosition(voiceOffLab,voiceOff,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
	VisibleRect:relativePosition(voiceValueLab, node2, LAYOUT_TOP_OUTSIDE + LAYOUT_CENTER_X, ccp(0, 5))
	VisibleRect:relativePosition(line2,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-241))
	--[[	VisibleRect:relativePosition(node3, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(20, -195))
	VisibleRect:relativePosition(autoMoveToCityValueLabel, node3, LAYOUT_TOP_OUTSIDE + LAYOUT_CENTER_X, ccp(0, 5))
	VisibleRect:relativePosition(line3,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-245))	--]]
end

function SubOptionView:initOptionSetting()
	--local optionSettingLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10503], "Arial", FSIZE("Size2") * const_scale , FCOLOR("ColorWhite1"))
	local optionSettingSpr = createSpriteWithFrameName(RES("setting_option.png"))
	self.rootNode:addChild(optionSettingSpr)
	VisibleRect:relativePosition(optionSettingSpr, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(20, -210))
	
	-- add by zhanxianbo usercenterButton
	if SFLoginManager:getInstance():needShowUserCenter() then
		local userCenterButton = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
		local okText = createLabelWithStringFontSizeColorAndDimension([[用户中心]], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
		self.rootNode:addChild(userCenterButton)
		self.rootNode:addChild(okText)
		VisibleRect:relativePosition(userCenterButton, optionSettingSpr, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(60,15))
		VisibleRect:relativePosition(okText, userCenterButton, LAYOUT_CENTER)
		local showUserCenter = function()
			SFLoginManager:getInstance():showUserCenter()			
		end
		userCenterButton:addTargetWithActionForControlEvents(showUserCenter, CCControlEventTouchDown)
	end
	
	
	--显示其他玩家选项
	local otherPlayerSettingLab	= createLabelWithStringFontSizeColorAndDimension(Config.Words[10504], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(otherPlayerSettingLab)
	VisibleRect:relativePosition(otherPlayerSettingLab, optionSettingSpr, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -50))
	
	local btn1 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn1:setTouchAreaDelta(0, 40, 0, 0)
	btn1:setZoomOnTouchDown(false)
	self.selected1 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn1:addChild(self.selected1)
	VisibleRect:relativePosition(self.selected1, btn1, LAYOUT_CENTER)
	self:addChild(btn1)
	VisibleRect:relativePosition(btn1, otherPlayerSettingLab, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(20,0))
	local Lab1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10506], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab1)
	VisibleRect:relativePosition(Lab1, btn1, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	
	local btn1Func = function()
		if self.OptionConfig.IsShowOtherPlayer == Setting_checkStatus.TRUE then
			return
		end
		self.selected2:setVisible(false)
		self.selected1:setVisible(true)
		self.OptionConfig.IsShowOtherPlayer = Setting_checkStatus.TRUE
		GameWorld.Instance:getEntityManager():showPlayers(true)
	end
	btn1:addTargetWithActionForControlEvents(btn1Func, CCControlEventTouchDown)
	
	local btn2 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn2:setTouchAreaDelta(0, 40, 0, 0)
	btn2:setZoomOnTouchDown(false)
	self.selected2 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn2:addChild(self.selected2)
	VisibleRect:relativePosition(self.selected2, btn2, LAYOUT_CENTER)
	self:addChild(btn2)
	VisibleRect:relativePosition(btn2, btn1, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(60,0))
	local Lab2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10507], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab2)
	VisibleRect:relativePosition(Lab2, btn2, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	
	local btn2Func = function()
		if self.OptionConfig.IsShowOtherPlayer == Setting_checkStatus.FALSE then
			return
		end
		self.selected1:setVisible(false)
		self.selected2:setVisible(true)
		self.OptionConfig.IsShowOtherPlayer = Setting_checkStatus.FALSE
		GameWorld.Instance:getEntityManager():showPlayers(false)
	end
	btn2:addTargetWithActionForControlEvents(btn2Func, CCControlEventTouchDown)
	
	--显示特效选项
	local otherEffectSettingLab	= createLabelWithStringFontSizeColorAndDimension(Config.Words[10505], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(otherEffectSettingLab)
	VisibleRect:relativePosition(otherEffectSettingLab, otherPlayerSettingLab, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -25))
	local btn3 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn3:setTouchAreaDelta(0, 40, 0, 0)
	btn3:setZoomOnTouchDown(false)
	self.selected3 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn3:addChild(self.selected3)
	VisibleRect:relativePosition(self.selected3, btn3, LAYOUT_CENTER)
	self:addChild(btn3)
	VisibleRect:relativePosition(btn3, otherEffectSettingLab, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(20,0))
	local Lab3 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10506], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab3)
	VisibleRect:relativePosition(Lab3, btn3, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	local btn3Func = function()
		if self.OptionConfig.IsShowEffect == Setting_checkStatus.TRUE then
			return
		end
		self.selected4:setVisible(false)
		self.selected3:setVisible(true)
		self.OptionConfig.IsShowEffect = Setting_checkStatus.TRUE
		SkillShowManager:setDisplayEffect(true)
		GameWorld.Instance:getEntityManager():showFireWall(true)
	end
	btn3:addTargetWithActionForControlEvents(btn3Func, CCControlEventTouchDown)
	
	local btn4 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn4:setTouchAreaDelta(0, 40, 0, 0)
	btn4:setZoomOnTouchDown(false)
	self.selected4 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn4:addChild(self.selected4)
	VisibleRect:relativePosition(self.selected4, btn4, LAYOUT_CENTER)
	self:addChild(btn4)
	VisibleRect:relativePosition(btn4, btn3, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(60,0))
	local Lab4 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10507], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab4)
	VisibleRect:relativePosition(Lab4, btn4, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	local btn4Func = function()
		if self.OptionConfig.IsShowEffect == Setting_checkStatus.FALSE then
			return
		end
		self.selected3:setVisible(false)
		self.selected4:setVisible(true)
		self.OptionConfig.IsShowEffect = Setting_checkStatus.FALSE
		SkillShowManager:setDisplayEffect(false)
		GameWorld.Instance:getEntityManager():showFireWall(false)
	end
	btn4:addTargetWithActionForControlEvents(btn4Func, CCControlEventTouchDown)
	
	--显示玩家姓名
	local PlayerNameSettingLab	= createLabelWithStringFontSizeColorAndDimension(Config.Words[10513], "Arial", FSIZE("Size3")*const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(PlayerNameSettingLab)
	VisibleRect:relativePosition(PlayerNameSettingLab, otherEffectSettingLab, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -25))
	
	local btn5 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn5:setTouchAreaDelta(0, 40, 0, 0)
	btn5:setZoomOnTouchDown(false)
	self.selected5 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn5:addChild(self.selected5)
	VisibleRect:relativePosition(self.selected5, btn5, LAYOUT_CENTER)
	self:addChild(btn5)
	VisibleRect:relativePosition(btn5, PlayerNameSettingLab, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(20,0))
	local Lab5 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10506], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab5)
	VisibleRect:relativePosition(Lab5, btn5, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	
	local btn5Func = function()
		if self.OptionConfig.IsShowPlayerName == Setting_checkStatus.TRUE then
			return
		end
		self.selected6:setVisible(false)
		self.selected5:setVisible(true)
		self.OptionConfig.IsShowPlayerName = Setting_checkStatus.TRUE
		GameWorld.Instance:getEntityManager():showPlayersName(true)
	end
	btn5:addTargetWithActionForControlEvents(btn5Func, CCControlEventTouchDown)
	
	local btn6 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn6:setTouchAreaDelta(0, 40, 0, 0)
	btn6:setZoomOnTouchDown(false)
	self.selected6 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn6:addChild(self.selected6)
	VisibleRect:relativePosition(self.selected6, btn6, LAYOUT_CENTER)
	self:addChild(btn6)
	VisibleRect:relativePosition(btn6, btn5, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(60,0))
	local Lab6 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10507], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab6)
	VisibleRect:relativePosition(Lab6, btn6, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	
	local btn6Func = function()
		if self.OptionConfig.IsShowPlayerName == Setting_checkStatus.FALSE then
			return
		end
		self.selected5:setVisible(false)
		self.selected6:setVisible(true)
		self.OptionConfig.IsShowPlayerName = Setting_checkStatus.FALSE
		GameWorld.Instance:getEntityManager():showPlayersName(false)
	end
	btn6:addTargetWithActionForControlEvents(btn6Func, CCControlEventTouchDown)
	
	local wingSettingLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10514], "Arial", FSIZE("Size3")*const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(wingSettingLab)
	VisibleRect:relativePosition(wingSettingLab, PlayerNameSettingLab, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -25))
	
	local btn7 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn7:setTouchAreaDelta(0, 40, 0, 0)
	btn7:setZoomOnTouchDown(false)
	self.selected7 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn7:addChild(self.selected7)
	VisibleRect:relativePosition(self.selected7, btn7, LAYOUT_CENTER)
	self:addChild(btn7)
	VisibleRect:relativePosition(btn7, wingSettingLab, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(20,0))
	local Lab7 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10506], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab7)
	VisibleRect:relativePosition(Lab7, btn7, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(5, 0))
	
	local btn7Func = function()
		self.selected8:setVisible(false)
		self.selected7:setVisible(true)
		self.OptionConfig.IsShowPlayerWing = Setting_checkStatus.TRUE
		GameWorld.Instance:getSettingMgr():showPlayerWing(true)
	end
	btn7:addTargetWithActionForControlEvents(btn7Func, CCControlEventTouchDown)
	
	local btn8 = createButtonWithFramename(RES("common_selectBox.png"),RES("common_selectBox.png"))
	btn8:setTouchAreaDelta(0, 40, 0, 0)
	btn8:setZoomOnTouchDown(false)
	self.selected8 = createSpriteWithFrameName(RES("common_selectIcon.png"))
	btn8:addChild(self.selected8)
	VisibleRect:relativePosition(self.selected8, btn8, LAYOUT_CENTER)
	self:addChild(btn8)
	VisibleRect:relativePosition(btn8, btn7, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(60,0))
	local Lab8 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10507], "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorWhite1"))
	self.rootNode:addChild(Lab8)
	VisibleRect:relativePosition(Lab8, btn8, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER, ccp(5, 0))
	
	local btn8Func = function()
		self.selected7:setVisible(false)
		self.selected8:setVisible(true)
		self.OptionConfig.IsShowPlayerWing = Setting_checkStatus.FALSE
		GameWorld.Instance:getSettingMgr():showPlayerWing(false)
	end
	btn8:addTargetWithActionForControlEvents(btn8Func, CCControlEventTouchDown)
	
	self:setSelectOption()
end

function SubOptionView:setSelectOption()
	if self.OptionConfig.IsShowOtherPlayer == Setting_checkStatus.FALSE then
		self.selected1:setVisible(false)
		self.selected2:setVisible(true)
	elseif self.OptionConfig.IsShowOtherPlayer == Setting_checkStatus.TRUE then
		self.selected2:setVisible(false)
		self.selected1:setVisible(true)
	end
	
	if self.OptionConfig.IsShowEffect == Setting_checkStatus.FALSE then
		self.selected3:setVisible(false)
		self.selected4:setVisible(true)
	elseif self.OptionConfig.IsShowEffect == Setting_checkStatus.TRUE then
		self.selected4:setVisible(false)
		self.selected3:setVisible(true)
	end
	
	if self.OptionConfig.IsShowPlayerName == Setting_checkStatus.FALSE then
		self.selected5:setVisible(false)
		self.selected6:setVisible(true)
	elseif self.OptionConfig.IsShowPlayerName == Setting_checkStatus.TRUE then
		self.selected6:setVisible(false)
		self.selected5:setVisible(true)
	end
	
	if self.OptionConfig.IsShowPlayerWing == Setting_checkStatus.FALSE then
		self.selected7:setVisible(false)
		self.selected8:setVisible(true)
	elseif self.OptionConfig.IsShowPlayerWing == Setting_checkStatus.TRUE then
		self.selected8:setVisible(false)
		self.selected7:setVisible(true)
	end
end

function SubOptionView:initButton()
	local HerochooseBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	HerochooseBtn:setTouchAreaDelta(0, 40, 0, 0)
	local HerochooseBtnLab	= createSpriteWithFrameName(RES("role_select.png"))
	HerochooseBtn:setTitleString(HerochooseBtnLab)
	--[[self.rootNode:addChild(HerochooseBtn)
	VisibleRect:relativePosition(HerochooseBtn,self.rootNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(8,11))--]]
	local HerochooseBtnFunc = function()
		local settingMgr = GameWorld.Instance:getSettingMgr()
		local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
		settingMgr:requireLeaveGame(heroId)
	end
	HerochooseBtn:addTargetWithActionForControlEvents(HerochooseBtnFunc, CCControlEventTouchDown)
	
end

function SubOptionView:createSlider(name, image)
	local bg = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"),CCSizeMake(180,20))
	local progress = createScale9SpriteWithFrameNameAndSize(RES(image), CCSizeMake(180, 20))
	local thumb = createSpriteWithFrameName(RES("main_slider.png"))
	local slider = createSFControlSlider(bg, progress, thumb,CCSizeMake(180, 20))
	local shade = createScale9SpriteWithFrameNameAndSize(RES("player_bar_frame.png"),CCSizeMake(182,20))
	slider:setShade(shade)	--设置高亮遮罩
	
	slider:setMinimumValue(0)
	slider:setMaximumValue(100)
	slider:setContentSize(CCSizeMake(225, bg:getContentSize().height))
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size2") * const_scale , FCOLOR("ColorWhite1"))
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(330, 15))
	node:addChild(nameLabel)
	node:addChild(slider)
	VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(0,2))
	VisibleRect:relativePosition(slider, node, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-30,0))
	return node, slider
end

--设置音效（传入0~100）

function SubOptionView:setVoiceValue(value)
	local soundMgr = GameWorld.Instance:getSoundMgr()
	soundMgr:setEffectsVolume(value/100)
end

--设置背景音乐（传入0~100）

function SubOptionView:setMusicValue(value)
	local soundMgr = GameWorld.Instance:getSoundMgr()
	soundMgr:setBackgroundMusicVolume(value/100)	
end

function SubOptionView:updateUI()
	local settingMgr = GameWorld.Instance:getSettingMgr()
	self.OptionConfig = SettingMgr:readOptionConfig()
	self:setSelectOption()
	self:setVoiceValue(self.OptionConfig.voiceValue)
	self:setMusicValue(self.OptionConfig.musicValue)
	
	if self.OptionConfig.musicOff == Setting_checkStatus.TRUE then
		musicOff:setSelect(true)
	elseif self.OptionConfig.musicOff == Setting_checkStatus.FALSE then
		musicOff:setSelect(false)
	end
	if self.OptionConfig.voiceOff == Setting_checkStatus.TRUE then
		voiceOff:setSelect(true)
	elseif self.OptionConfig.voiceOff == Setting_checkStatus.FALSE then
		voiceOff:setSelect(false)
	end
end
