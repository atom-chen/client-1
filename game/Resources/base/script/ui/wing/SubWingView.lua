require("ui.UIManager")
require("common.BaseUI")

SubWingView = SubWingView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local wing_grade = {
	[1] = Config.Words[1030],
	[2] = Config.Words[1031],
	[3] = Config.Words[1032],
	[4] = Config.Words[1033],
	[5] = Config.Words[1034],
	[6] = Config.Words[1035],
	[7] = Config.Words[1036],
	[8] = Config.Words[1037],
	[9] = Config.Words[1038],
	[10] = Config.Words[1039],
}

local equipList = {}
equipList["1,1"] = {cloth = "equip_40_2110", weapon = "equip_40_1102"}
equipList["1,2"] = {cloth = "equip_40_2120", weapon = "equip_40_1102"}
equipList["2,1"] = {cloth = "equip_40_2210", weapon = "equip_40_1202"}
equipList["2,2"] = {cloth = "equip_40_2220", weapon = "equip_40_1202"}
equipList["3,1"] = {cloth = "equip_40_2310", weapon = "equip_40_1302"}
equipList["3,2"] = {cloth = "equip_40_2320", weapon = "equip_40_1302"}

local refId = "wing_2_0"

function SubWingView:__init()
	self.viewName = "SubWingView"
	self:init(CCSizeMake(395,495))
	self:initBg()	
	local level = tonumber(string.match(refId,"%a+_(%d+)_"))
	self:createModel(refId)
	self:createFigter(refId)
	self:createName(level)
	self:createLevel(level)
end

function SubWingView:__deleteMe()
	self.heroModelView:DeleteMe()
	self.heroModelView:getRootNode():removeFromParentAndCleanup(true)
end

function SubWingView:create()
	return SubWingView.New()
end

function SubWingView:onEnter()
	--[[local wingMgr = G_getHero():getWingMgr()
	if wingMgr:getNeedUpdateSubWingView() then
		self.heroModelView:DeleteMe()
		self.heroModelView:getRootNode():removeFromParentAndCleanup(true)
		self:createModel(refId)
		wingMgr:getNeedUpdateSubWingView(false)
	end--]]
end

function SubWingView:initBg()
	local titleNode = createLabelWithStringFontSizeColorAndDimension(Config.Words[13024], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self:setFormTitle(titleNode, TitleAlign.Center)
	
	local size = self:getContentNode():getContentSize()
	local secondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), size)
	self:addChild(secondBg)
	VisibleRect:relativePosition(secondBg, self:getContentNode(), LAYOUT_CENTER)
	
	local thirdBgSize = CCSizeMake(350,351)
	local thirdBgFrame = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_itemBg.png"), CCSizeMake(thirdBgSize.width+6,thirdBgSize.height+6))
	self:addChild(thirdBgFrame)
	VisibleRect:relativePosition(thirdBgFrame, self:getContentNode(), LAYOUT_CENTER,ccp(0,35))
	
	local thirdBg = CCSprite:create()	
	thirdBg:setContentSize(thirdBgSize)
	self:addChild(thirdBg)
	VisibleRect:relativePosition(thirdBg, self:getContentNode(), LAYOUT_CENTER,ccp(0,35))
	local texture = CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/wingBg.pvr")
	thirdBg:setTexture(texture)
	local texRect = CCRectMake(50,35,thirdBgSize.width,thirdBgSize.height)
	thirdBg:setTextureRect(texRect)
	
	local VipButton = createButtonWithFramename(RES("btn_1_select.png"))
	self:addChild(VipButton)
	VisibleRect:relativePosition(VipButton, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 0))
	local text = createLabelWithStringFontSizeColorAndDimension(Config.Words[13023], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	VipButton:setTitleString(text)
	local VipBtnFun = function ()
		GlobalEventSystem:Fire(GameEvent.EventOpenMallView)
		self:close()
	end
	VipButton:addTargetWithActionForControlEvents(VipBtnFun, CCControlEventTouchDown)
end

function SubWingView:createModel(wingRefid)
	self.heroModelView = HeroModelView.New()
	self:addChild(self.heroModelView:getRootNode())
	VisibleRect:relativePosition(self.heroModelView:getRootNode(), self:getContentNode(), LAYOUT_CENTER, ccp(0, 10))
	
	local hero = G_getHero()
	local pt = hero:getPT()
	local gender = PropertyDictionary:get_gender(pt)
	local professionId = PropertyDictionary:get_professionId(pt)
	local key = tostring(professionId)..","..tostring(gender)
	self.heroModelView:addEquipWithRefId(equipList[key].cloth, E_BodyAreaId.eCloth)
	self.heroModelView:addEquipWithRefId(equipList[key].weapon, E_BodyAreaId.eWeapon)
	self.heroModelView:setWing(string.match(wingRefid,"%a+_%d+"))
end

function SubWingView:createFigter(wingRefid)
	local powerSpriteBg = createScale9SpriteWithFrameName(RES("ride_fade_sprite.png"))
	powerSpriteBg:setScaleX(1.5)	
	powerSpriteBg:setOpacity(150)
	self:addChild(powerSpriteBg)
	VisibleRect:relativePosition(powerSpriteBg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, 0))
	
	local fightBg = createSpriteWithFrameName(RES("ride_power.png"))
	self:addChild(fightBg)
	VisibleRect:relativePosition(fightBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -20))
	
	local fightLable = createAtlasNumber(Config.AtlasImg.FightNumber,"")	--创建美术数字标签
	fightLable:setAnchorPoint(ccp(0, 0.5))
	self:addChild(fightLable)
	VisibleRect:relativePosition(fightLable, fightBg, LAYOUT_CENTER)
	
	local recordItem = GameData.Wing[wingRefid]
	local curTabel = recordItem["property"]
	fightLable:setString(PropertyDictionary:get_injure(curTabel))
end

function SubWingView:createName(level)
	local nameBg = createSpriteWithFrameName(RES("frontNameBg.png"))
	self:addChild(nameBg)
	VisibleRect:relativePosition(nameBg, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(2, -5))
		
	local wingName = "wing_name" .. level .. ".png"
	local wingNameSprite = createSpriteWithFrameName(RES(wingName))
	self:addChild(wingNameSprite)
	VisibleRect:relativePosition(wingNameSprite, nameBg, LAYOUT_CENTER)
end

function SubWingView:createLevel(level)	
	local WingGradeLabel = createStyleTextLable("","Stairs")				
	self:addChild(WingGradeLabel)
	WingGradeLabel:setString(wing_grade[level])
	VisibleRect:relativePosition(WingGradeLabel, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(90,-25))
	
	local WingGradeLabel1 = createStyleTextLable(Config.Words[1025],"Stairs")					
	self:addChild(WingGradeLabel1)
	VisibleRect:relativePosition(WingGradeLabel1, WingGradeLabel, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
end
