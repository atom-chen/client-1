-- 显示详细属性
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemView")
require("object.equip.EquipDef")
--require("GameWorld")
require "data.character.characterLevelData"
DetailPropertyView = DetailPropertyView or BaseClass(BaseUI)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
--local const_size_no_scale = CCSizeMake(332 + E_OffsetView.eWidth*2, 546+E_OffsetView.eHeight*2)
local const_size_no_scale = CCSizeMake(375 + E_OffsetView.eWidth*2, 552+E_OffsetView.eHeight*2)
local const_size = VisibleRect:getScaleSize(const_size_no_scale)
local const_scale = VisibleRect:SFGetScale()
local const_marginLeft = 26
local const_spacing = -0.5
local const_valueColor = FCOLOR("ColorWhite2")
local g_bagMgr 		= nil
local g_equipMgr 	= nil

function DetailPropertyView:create()
	return DetailPropertyView.New()
end

local ProgressBarType = 
{
	HP	= 1,
	MP	= 2,
	EXP	= 3
}

local DetailType = 
{
	Detail1	= 1,
	Detail2	= 2,
	Detail3	= 3
}	

function DetailPropertyView:__init()
	g_bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()		
	g_equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	self:init(const_size_no_scale)	
	self.viewName = "DetailPropertyView"
	
	self.progressBars = 
	{
		[ProgressBarType.HP] 	= {name = Config.Words[10013], image = "player_hp.png",		obj = nil, valueLabel = nil, nameLabel = nil},
		[ProgressBarType.MP] 	= {name = Config.Words[10014], image = "player_mp.png",		obj = nil, valueLabel = nil, nameLabel = nil},
		[ProgressBarType.EXP] 	= {name = Config.Words[10015], image = "player_expBar.png",	obj = nil, valueLabel = nil, nameLabel = nil},
	}
	
	self.detail1 = 
	{
		{name = Config.Words[10016], 	source = self.getLevel,			offset = ccp(20, -13),  valueColor = FCOLOR("ColorWhite1")},
		{name = Config.Words[10017], 	source = self.getProfession,	offset = ccp(175, -13), },
		{name = Config.Words[10018], 	source = self.getJueWei, 	 	offset = ccp(20, -43),  valueColor = FCOLOR("ColorWhite1")},		
--		{name = Config.Words[10019], 	source = self.getPK, 	 		offset = ccp(175, -92),	valueColor = FCOLOR("ColorYellow1")},		
		{name = Config.Words[10019], 	source = self.getPK, 	 		offset = ccp(175, -43),	valueColor = FCOLOR("Red1")},	
		{name = Config.Words[16033],	source = self.getUnion,			offset = ccp(20,  -73), valueColor = FCOLOR("ColorWhite1") },	
	}
	self.detail2 = 
	{
		{name = Config.Words[10020], 	source = self.getPhyAttack,		offset = ccp(20, -243), valueColor = const_valueColor},
		{name = Config.Words[10021], 	source = self.getMagicAttack, valueColor = const_valueColor},
		{name = Config.Words[10022], 	source = self.getDaoshuAttack, valueColor = const_valueColor},		
		{name = Config.Words[10023], 	source = self.getAccuracyPoint, valueColor = const_valueColor},		
		{name = Config.Words[10024], 	source = self.getBoomAttack, valueColor = const_valueColor	},		
		{name = Config.Words[10025], 	source = self.getPhySpare, valueColor = const_valueColor	 	},		
		{name = Config.Words[10026], 	source = self.getPoJia, valueColor = const_valueColor	 	},		
		{name = Config.Words[10027], 	source = self.getAttackSpeed, valueColor = const_valueColor	},
	}
	self.detail3 = 
	{
		{name = Config.Words[10028], 	source = self.getPhyDefense,	offset = ccp(175, -243), valueColor = const_valueColor},
		{name = Config.Words[10029], 	source = self.getMagicDefense, valueColor = const_valueColor	},
		{name = Config.Words[10030], 	source = self.getLuckyPoint, valueColor = const_valueColor	},		
		{name = Config.Words[10031], 	source = self.getDodge, valueColor = const_valueColor	 	},		
		{name = Config.Words[10032], 	source = self.getBoomHurt, valueColor = const_valueColor	 	},		
		{name = Config.Words[10033], 	source = self.getMagicSpare, valueColor = const_valueColor	},		
		{name = Config.Words[10034], 	source = self.getPoMo, valueColor = const_valueColor	 		},		
		{name = Config.Words[10035], 	source = self.getMoveSpeed, valueColor = const_valueColor	},
	}		
	
	self.details = 
	{
		[DetailType.Detail1] = self.detail1,
		[DetailType.Detail2] = self.detail2,
		[DetailType.Detail3] = self.detail3,
	}
	
	self.playerInfo = {}
	self:initBg()
	self:initTitle()
	self:initDetails()
	self:initProgressBars()
end		

function DetailPropertyView:initBg()
	local size = self:getContentNode():getContentSize()
	local secendBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), size)
	self:addChild(secendBg)
	VisibleRect:relativePosition(secendBg, self:getContentNode(), LAYOUT_CENTER)
	
	local line = createSpriteWithFrameName(RES("player_lineLeft.png"))
	self:addChild(line,10)
	VisibleRect:relativePosition(line, self:getContentNode(), LAYOUT_CENTER, ccp(0, 10))
	
	local thirdBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(328, 248))
	self:addChild(thirdBg)
	VisibleRect:relativePosition(thirdBg, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(8, 6))
end		

function DetailPropertyView:getMaxExp()
	
	local level = PropertyDictionary:get_level(g_playerObj:getPT())
	local professionLevelData = GameData.CharacterLevelData["enchanter"].levelData
	return professionLevelData[level].property.maxExp
end	

function DetailPropertyView:onEnter(arg)
	if ((arg == nil) or (type(arg) ~= "table") or (arg.playerObj == nil)) then
		arg = {}
		arg.playerObj = GameWorld.Instance:getEntityManager():getHero()
		arg.playerType = 0	--玩家自己
	end	
	local hero = G_getHero()
	if self.playerInfo.playerObj ~= arg.playerObj or  self.playerInfo.playerObj ~= hero then
		self.playerInfo = arg
		self:updateDetails()
		self:updateProgressBar()
--[[		if self.playerInfo.playerObj ~= hero then
			self.progressBars[ProgressBarType.EXP].obj:setVisible(false)
			self.progressBars[ProgressBarType.EXP].valueLabel:setVisible(false)
			self.progressBars[ProgressBarType.EXP].nameLabel:setVisible(false)
		end--]]
	end
end

function DetailPropertyView:onExit()
	
end

function DetailPropertyView:onCloseBtnClick()
	GlobalEventSystem:Fire(GameEvent.EVENT_HideMyDetailProperty)
	GlobalEventSystem:Fire(GameEvent.EVENT_HideHisDetailProperty)
	return true
end

function DetailPropertyView:initTitle()
	self.title = createSpriteWithFrameName(RES("player_detailProperty.png"))
	self:setFormTitle(self.title, TitleAlign.Center)	
end

function DetailPropertyView:updateTitle(titleName)
	self.title = createSpriteWithFrameName(RES(titleName))
	self:setFormTitle(self.title, TitleAlign.Center)	
end

function DetailPropertyView:getLevel()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end		
	return tostring(PropertyDictionary:get_level(self.playerInfo.playerObj:getPT()))			
end	
		
function DetailPropertyView:getProfession()	
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end			
	return tostring(G_getProfessionNameById(PropertyDictionary:get_professionId(self.playerInfo.playerObj:getPT()))) 	
end	

function DetailPropertyView:getProfessionId()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return ModeType.ePlayerProfessionWarior
	end		
	return PropertyDictionary:get_professionId(self.playerInfo.playerObj:getPT())	
end	

function DetailPropertyView:getJueWei()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end
	return G_getKightNameById(PropertyDictionary:get_knight(self.playerInfo.playerObj:getPT()))	
end 
	 			
function DetailPropertyView:getPK()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end				
	return tostring(PropertyDictionary:get_pkValue(self.playerInfo.playerObj:getPT()))	
end 	

function DetailPropertyView:getUnion()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "-"
	end
	local unionName = tostring(PropertyDictionary:get_unionName(self.playerInfo.playerObj:getPT()))
	if unionName ~= "" then
		return unionName
	else
		return "-"
	end
end  				


function DetailPropertyView:getPhyAttack()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0-0"
	end
	local str = string.format("%d-%d", PropertyDictionary:get_minPAtk(self.playerInfo.playerObj:getPT()), PropertyDictionary:get_maxPAtk(self.playerInfo.playerObj:getPT()))
	return str		
end		

function DetailPropertyView:getMagicAttack()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0-0"
	end
	local str = string.format("%d-%d", PropertyDictionary:get_minMAtk(self.playerInfo.playerObj:getPT()), PropertyDictionary:get_maxMAtk(self.playerInfo.playerObj:getPT()))	
	return str	
end	

function DetailPropertyView:getDaoshuAttack()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0-0"
	end
	local str = string.format("%d-%d", PropertyDictionary:get_minTao(self.playerInfo.playerObj:getPT()), PropertyDictionary:get_maxTao(self.playerInfo.playerObj:getPT()))	
	return str						
end 			

function DetailPropertyView:getAccuracyPoint()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end
	return tostring(PropertyDictionary:get_hit(self.playerInfo.playerObj:getPT()))		
end 
		
function DetailPropertyView:getBoomAttack()	
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end		
	return tostring(PropertyDictionary:get_crit(self.playerInfo.playerObj:getPT()))	
end 
			
function DetailPropertyView:getPhySpare()	
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end			
	return tostring(PropertyDictionary:get_PImmunityPer(self.playerInfo.playerObj:getPT()))	
end 	

--忽视对方物理防御 			
function DetailPropertyView:getPoJia()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end	
	return tostring(PropertyDictionary:get_ignorePDef(self.playerInfo.playerObj:getPT())) 							
end 
	 				
function DetailPropertyView:getAttackSpeed()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0%"
	end					
	local atkSpeed = PropertyDictionary:get_atkSpeedPer(self.playerInfo.playerObj:getPT())
	atkSpeed = math.floor(atkSpeed)
	return tostring(atkSpeed.."%")				
end 	


function DetailPropertyView:getPhyDefense()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0-0"
	end
	local str = string.format("%d-%d", PropertyDictionary:get_minPDef(self.playerInfo.playerObj:getPT()), PropertyDictionary:get_maxPDef(self.playerInfo.playerObj:getPT()))	
	return str	
end		

function DetailPropertyView:getMagicDefense()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0-0"
	end	
	local str = string.format("%d-%d", PropertyDictionary:get_minMDef(self.playerInfo.playerObj:getPT()), PropertyDictionary:get_maxMDef(self.playerInfo.playerObj:getPT()))	
	return str				
end	

function DetailPropertyView:getLuckyPoint()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end	
	return tostring(PropertyDictionary:get_fortune(self.playerInfo.playerObj:getPT()))	
end 
			
function DetailPropertyView:getDodge()	
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end			
	return tostring(PropertyDictionary:get_dodge(self.playerInfo.playerObj:getPT()))	
end 	 
				
function DetailPropertyView:getBoomHurt()	
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end				
	return tostring(PropertyDictionary:get_critInjure(self.playerInfo.playerObj:getPT()))	
end 
	 			
function DetailPropertyView:getMagicSpare()		
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end			
	return tostring(PropertyDictionary:get_MImmunityPer(self.playerInfo.playerObj:getPT()))	
end 			

--忽视对方魔法防御
function DetailPropertyView:getPoMo()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0"
	end	
	return tostring(PropertyDictionary:get_ignoreMDef(self.playerInfo.playerObj:getPT())) 	
end 
	 				
function DetailPropertyView:getMoveSpeed()
	if not self.playerInfo.playerObj or type(self.playerInfo.playerObj:getPT()) ~= "table" then
		return "0%"
	end						
	local moveSpeed = PropertyDictionary:get_moveSpeedPer(self.playerInfo.playerObj:getPT())	
	if moveSpeed >= 0 then	
		return "+"..tostring(moveSpeed).."%"
	else
		return tostring(moveSpeed).."%"
	end				
end 		

function DetailPropertyView:initDetails()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local professionId  = PropertyDictionary:get_professionId(hero:getPT())
	for ttype, detail in ipairs(self.details) do	
		local previousNode = self.rootNode
		for index, item in ipairs(detail) do	
			if item.valueColor then
				item.node, item.keyLabel, item.valueLabel = G_createKeyValue(item.name, "", item.valueColor, FCOLOR("ColorYellow2"), FSIZE("Size3") * const_scale, FSIZE("Size3") * const_scale)
			else				
				if ttype==1 and professionId == ModeType.ePlayerProfessionWarior then
					item.node, item.keyLabel, item.valueLabel = G_createKeyValue(item.name, "", FCOLOR("ColorOrange1"), FCOLOR("ColorYellow2"), FSIZE("Size3") * const_scale, FSIZE("Size3") * const_scale)					
				elseif ttype==1 and professionId == ModeType.ePlayerProfessionMagic then
					item.node, item.keyLabel, item.valueLabel = G_createKeyValue(item.name, "", FCOLOR("ColorRed1"), FCOLOR("ColorYellow2"), FSIZE("Size3") * const_scale, FSIZE("Size3") * const_scale)
				elseif ttype==1 and professionId == ModeType.ePlayerProfessionWarlock then
					item.node, item.keyLabel, item.valueLabel = G_createKeyValue(item.name, "", FCOLOR("ColorBlue1"), FCOLOR("ColorYellow2"), FSIZE("Size3") * const_scale, FSIZE("Size3") * const_scale)
				end
			end	
						
			self:addChild(item.node)	
			if (item.offset ~= nil) then
				VisibleRect:relativePosition(item.node, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, item.offset)				
			else
				VisibleRect:relativePosition(item.node, previousNode, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(0, -const_spacing))
			end
			previousNode = item.node			
		end
	end
end	

function DetailPropertyView:updateDetails()
	for ttype, detail in ipairs(self.details) do	
		local previousNode = self.rootNode		
		for index, item in ipairs(detail) do
			if item.source(self) and (item.source(self) ~= item.valueLabel:getString()) then
				item.valueLabel:setString(item.source(self))	
			end
			-- 职业颜色的特殊处理
			if ttype == 1 and index == 2 then
				if self:getProfessionId() == ModeType.ePlayerProfessionWarior then
					item.valueLabel:setColor(FCOLOR("ColorWhite1"))
				elseif self:getProfessionId() == ModeType.ePlayerProfessionMagic then
					item.valueLabel:setColor(FCOLOR("ColorWhite1"))
				elseif self:getProfessionId() == ModeType.ePlayerProfessionWarlock then
					item.valueLabel:setColor(FCOLOR("ColorWhite1"))
				end
			end
			VisibleRect:relativePosition(item.valueLabel, item.keyLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(10, 0))				
		end			
	end
end

function DetailPropertyView:initProgressBars()
	self.lineUp = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_size.width-64, 0))
	self:addChild(self.lineUp)
	VisibleRect:relativePosition(self.lineUp, self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -113))	
	local previousNode = self.rootNode
	for ttype, bar in ipairs(self.progressBars) do
		bar.obj, bar.nameLabel, bar.valueLabel = self:createProgressBar(bar.name, bar.image)		
		self:addChild(bar.obj)
		self:addChild(bar.nameLabel)
		self:addChild(bar.valueLabel)
		
		if (ttype == ProgressBarType.HP) then		
			VisibleRect:relativePosition(bar.nameLabel, self.lineUp, LAYOUT_BOTTOM_OUTSIDE, ccp(20, -12))
			VisibleRect:relativePosition(bar.nameLabel, self:getContentNode(), LAYOUT_LEFT_INSIDE, ccp(const_marginLeft*0.5+10, 0))
		else 
			VisibleRect:relativePosition(bar.nameLabel, previousNode, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(0, -12))
		end
		previousNode = bar.nameLabel
		VisibleRect:relativePosition(bar.obj, bar.nameLabel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(20, 0))
--		VisibleRect:relativePosition(bar.valueLabel, bar.obj, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(25, 0))
		VisibleRect:relativePosition(bar.valueLabel, bar.obj, LAYOUT_CENTER)
	end
	
	self.lineDown = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_size.width-64, 0))
	self:addChild(self.lineDown)
	VisibleRect:relativePosition(self.lineDown, self.lineUp, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -110))
end

function DetailPropertyView:createProgressBar(name, image)
--	local bar = createProgressBar(RES("player_expBarBg.png"), RES(image), VisibleRect:getScaleSize(CCSizeMake(200, 15)))
	local bar = createProgressBar(RES("player_expBarBg.png"), RES(image), VisibleRect:getScaleSize(CCSizeMake(233, 15)))
	bar:setNumberVisible(false)
	bar:setMaxNumber(100)
	bar:setCurrentNumber(50)
	local border = createScale9SpriteWithFrameNameAndSize(RES("player_bar_frame.png"), CCSizeMake(241, 24))
	bar:addChild(border, 10)
	VisibleRect:relativePosition(border, bar, LAYOUT_CENTER, ccp(-1, 0))
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3") * const_scale , FCOLOR("ColorYellow2"))
	local valueLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite1"))			
	
--[[	local topLevel = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"), VisibleRect:getScaleSize(CCSizeMake(165, 15)))
	bar:addChild(topLevel)
	VisibleRect:relativePosition(topLevel, bar, LAYOUT_CENTER)--]]
	return bar, nameLabel, valueLabel
end	

function DetailPropertyView:updateProgressBar()
	for ttype = ProgressBarType.HP, ProgressBarType.EXP do
		local cur
		local max
		if ttype == ProgressBarType.HP then
			cur = PropertyDictionary:get_HP(self.playerInfo.playerObj:getPT())
			max = G_getMaxHp(self.playerInfo.playerObj:getPT())
		elseif ttype == ProgressBarType.MP then
			cur = PropertyDictionary:get_MP(self.playerInfo.playerObj:getPT())
			max = G_getMaxMP(self.playerInfo.playerObj:getPT())
		else
			cur = PropertyDictionary:get_exp(self.playerInfo.playerObj:getPT())
			max = G_getMaxExp(self.playerInfo.playerObj:getPT())
		end
		if not max or not cur then
			return
		end	
		local bar = self.progressBars[ttype]	
		local text = string.format("%d/%d", cur, max)
		if (text ~= bar.valueLabel:getString()) then
			bar.valueLabel:setString(text)
--			VisibleRect:relativePosition(bar.valueLabel, bar.obj, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(25, 0))	
			VisibleRect:relativePosition(bar.valueLabel, bar.obj, LAYOUT_CENTER)				
			self.progressBars[ttype].obj:setMaxNumber(max)
			self.progressBars[ttype].obj:setCurrentNumber(cur)				
		end
	end
end

function DetailPropertyView:isHero()
	if self.playerInfo.playerType then
		return self.playerInfo.playerType == 0
	end
end