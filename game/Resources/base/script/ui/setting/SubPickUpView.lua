require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.setting.SettingMgr")

SubPickUpView = SubPickUpView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local settingMgr = nil

local levelOverDescrible = {
	[1] =  Config.Words[10157],
	[2] =  Config.Words[10158],
	[3] =  Config.Words[10159],
	[4] =  Config.Words[10160],
	[5] =  Config.Words[10161],
	[6] =  Config.Words[10162],
}

local qualityDescrible = {
	[1] = Config.Words[10164],
	[2] = Config.Words[10165],
	[3] = Config.Words[10166],
}

local professionDescrible = {
	[1] = Config.Words[10168],
	[2] = Config.Words[10169],
	[3] = Config.Words[10170],
}

local levelOver_index = {
	[1] = Setting_EquipPickUp.overLevel_10,
	[2] = Setting_EquipPickUp.overLevel_30,
	[3] = Setting_EquipPickUp.overLevel_40,
	[4] = Setting_EquipPickUp.overLevel_50,
	[5] = Setting_EquipPickUp.overLevel_60,
	[6] = Setting_EquipPickUp.overLevel_70,
}

local quailty_index = {
	[1] = ItemQualtiy.White,
	[2] = ItemQualtiy.Blue,
	[3] = ItemQualtiy.Purple,
}

local profession_index = {
	[1] = ModeType.ePlayerProfessionWarior,
	[2] = ModeType.ePlayerProfessionMagic,
	[3] = ModeType.ePlayerProfessionWarlock,
}

function SubPickUpView:__init()
	self.rootNode:setContentSize(const_settingBgSize)
	settingMgr = GameWorld.Instance:getSettingMgr()
	self.levelCheckBtn = {}
	self.PickUpConfig = {}
	self.qualityCheckBtn = {}
	self.professionCheckBtn = {}
	self:initView()		
end

function SubPickUpView:__delete()
	self.levelCheckBtn = {}
	self.PickUpConfig = {}
	self.qualityCheckBtn = {}
	self.professionCheckBtn = {}
end

function SubPickUpView:onExit()
	settingMgr:savePickUpConfig(self.PickUpConfig)
	settingMgr:requestOffLineAISeting(self.PickUpConfig)
end

function SubPickUpView:initView()
	self.PickUpConfig = settingMgr:readPickUpConfig()	
	self:initEquipLevelSetting()
	self:initEquipQualitySetting()
	self:initEquipProfessionSetting()
	self:setCheckBtn()	
end	

function SubPickUpView:onEnter()
	
end

function SubPickUpView:setCheckBtn()
	for i,v in pairs(levelOver_index) do
		if self.PickUpConfig.EquipLevel and self.PickUpConfig.EquipLevel == v then
			self.levelCheckBtn[i]:setSelect(true)
		end
	end	
	if self.PickUpConfig.EquipQualityList then
		for i,v in pairs(self.PickUpConfig.EquipQualityList) do
			if v>0 and v<4 then
				self.qualityCheckBtn[v]:setSelect(true)
			end
		end
	end
	
	if self.PickUpConfig.ProfessionList then
		for i,v in pairs(self.PickUpConfig.ProfessionList) do
			if v>0 and v<4 then
				self.professionCheckBtn[v]:setSelect(true)
			end
		end	
	end
			
end

function SubPickUpView:initEquipLevelSetting()
	--装备等级筛选
	--local levelLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10156], "Arial", FSIZE("Size2") * const_scale , FCOLOR("ColorYellow1"))
	local levelSpr = createSpriteWithFrameName(RES("setting_level.png"))
	self.rootNode:addChild(levelSpr)
	VisibleRect:relativePosition(levelSpr, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(30, -30))
	
	local line1 = createSpriteWithFrameName(RES("setting_line.png"))
	self.rootNode:addChild(line1)
	VisibleRect:relativePosition(line1, self.rootNode, LAYOUT_CENTER + LAYOUT_TOP_INSIDE, ccp(0, -55))

	for i = 1,6 do
		local levelCheckfFunc = function()
			if self.levelCheckBtn[i]:getSelect() == false then
				--print(Setting_EquipPickUp[Level_All])
				self.PickUpConfig.EquipLevel = Setting_EquipPickUp.Level_All
				GlobalEventSystem:Fire(GameEvent.EventPickUpConfigChange,self.PickUpConfig,PickupConfigType.equipLevel)
				return
			end
			for j=1,6 do
				self.levelCheckBtn[j]:setSelect(false)
			end
			self.levelCheckBtn[i]:setSelect(true)
			self.PickUpConfig.EquipLevel = levelOver_index[i]
			GlobalEventSystem:Fire(GameEvent.EventPickUpConfigChange,self.PickUpConfig,PickupConfigType.equipLevel)	
		end
		self.levelCheckBtn[i] = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, levelCheckfFunc)
		self.levelCheckBtn[i]:setTouchAreaDelta(0, 40, 0, 0)
		local levelOverCheckLab = createLabelWithStringFontSizeColorAndDimension(levelOverDescrible[i],"Arial",FSIZE("Size3")*const_scale,FCOLOR("ColorWhite1"))
		self.rootNode:addChild(self.levelCheckBtn[i])
		self.rootNode:addChild(levelOverCheckLab)
		if i%2 == 0 then
			VisibleRect:relativePosition(self.levelCheckBtn[i],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(195,-(i/2)*55-25))
			VisibleRect:relativePosition(levelOverCheckLab,self.levelCheckBtn[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
		elseif i%2 == 1 then
			VisibleRect:relativePosition(self.levelCheckBtn[i],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,-(math.floor(i/2)+1)*55-25))
			VisibleRect:relativePosition(levelOverCheckLab,self.levelCheckBtn[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
		end	
	end			
			
end

function SubPickUpView:initEquipQualitySetting()
	--local equipQualityLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10163], "Arial", FSIZE("Size2") * const_scale , FCOLOR("ColorYellow1"))
	local equipQualitySpr = createSpriteWithFrameName(RES("setting_quality.png"))
	self.rootNode:addChild(equipQualitySpr)
	VisibleRect:relativePosition(equipQualitySpr, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(30, -240))
	
	local line1 = createSpriteWithFrameName(RES("setting_line.png"))
	self.rootNode:addChild(line1)
	VisibleRect:relativePosition(line1, self.rootNode, LAYOUT_CENTER + LAYOUT_TOP_INSIDE, ccp(0, -260))
	
	for i = 1,3 do
		local qualityCheckfFunc = function()
			if self.qualityCheckBtn[i]:getSelect() == true then						
				self.PickUpConfig.EquipQualityList[quailty_index[i]] = quailty_index[i]
			else				
				self.PickUpConfig.EquipQualityList[quailty_index[i]] = nil						
			end
			GlobalEventSystem:Fire(GameEvent.EventPickUpConfigChange,self.PickUpConfig,PickupConfigType.quality)												
		end
		self.qualityCheckBtn[i] = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, qualityCheckfFunc)
		self.qualityCheckBtn[i]:setTouchAreaDelta(0, 40, 0, 0)
		local qualityCheckLab = createLabelWithStringFontSizeColorAndDimension(qualityDescrible[i],"Arial",FSIZE("Size3")*const_scale,FCOLOR("ColorWhite1"))
		self.rootNode:addChild(self.qualityCheckBtn[i])	
		self.rootNode:addChild(qualityCheckLab)	
		VisibleRect:relativePosition(self.qualityCheckBtn[i],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,-(i*55+245)))
		VisibleRect:relativePosition(qualityCheckLab,self.qualityCheckBtn[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))
	end				
	
end	

function SubPickUpView:initEquipProfessionSetting()
	--local professionLab = createLabelWithStringFontSizeColorAndDimension(Config.Words[10167], "Arial", FSIZE("Size2") * const_scale , FCOLOR("ColorYellow1"))
	local professionSpr = createSpriteWithFrameName(RES("setting_profession.png"))
	self.rootNode:addChild(professionSpr)
	VisibleRect:relativePosition(professionSpr, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(195, -240))

	for i = 1,3 do
		local professionCheckfFunc = function()
			if self.professionCheckBtn[i]:getSelect() == true then							
				self.PickUpConfig.ProfessionList[profession_index[i]] = profession_index[i]
			else						
				self.PickUpConfig.ProfessionList[profession_index[i]] =  nil											
			end											
			GlobalEventSystem:Fire(GameEvent.EventPickUpConfigChange,self.PickUpConfig,PickupConfigType.profession)									
		end
		self.professionCheckBtn[i] = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, professionCheckfFunc)
		self.professionCheckBtn[i]:setTouchAreaDelta(0, 40, 0, 0)
		local professionCheckLab = createLabelWithStringFontSizeColorAndDimension(professionDescrible[i],"Arial",FSIZE("Size3")*const_scale,FCOLOR("ColorWhite1"))
		self.rootNode:addChild(self.professionCheckBtn[i])
		self.rootNode:addChild(professionCheckLab)		
		VisibleRect:relativePosition(self.professionCheckBtn[i],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(195,-(i*55+245)))
		VisibleRect:relativePosition(professionCheckLab,self.professionCheckBtn[i],LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(5,0))			
	end			
end

function SubPickUpView:updateUI()
	local settingMgr = GameWorld.Instance:getSettingMgr()	
	self.PickUpConfig = settingMgr:readOptionConfig()			
	self:setCheckBtn()		
end
	
