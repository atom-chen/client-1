-- 角色的界面(游戏的主界面点击角色按键时进入)
require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.EquipCircleView")
require("GameDef")
require("ui.utils.HeroModelView")
require"data.wing.wing"
RoleSubPropertyView = RoleSubPropertyView or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size = VisibleRect:getScaleSize(CCSizeMake(392, 494))
local const_scale = VisibleRect:SFGetScale()
local ViewName_RoleView = "RoleView"
local ViewName_DetailPropertyView = "DetailPropertyView"
local ViewName_BagView = "BagView"

local const_heroModelViewZ = 0
local const_equipCircleViewZ = 20

function RoleSubPropertyView:__init()
	self.playerInfo = {}	
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(CCSizeMake(392, 494))		
	self:initBgAndTitle()
	self:initSplitLine()
	self:initBtn()
	self:initHeroModelView()
	self:initEquipCircleView()
end

function RoleSubPropertyView:__delete()
	if (self.equipCircleView) then
		self.equipCircleView:DeleteMe()
		self.equipCircleView = nil
	end		
	if (self.heroModelView) then
		self.heroModelView:DeleteMe()
		self.heroModelView = nil
	end
	self.rootNode:release()
end

function RoleSubPropertyView:getRootNode()
	return self.rootNode
end

function RoleSubPropertyView:onEnter(arg)
	if type(arg) ~= "table" then
		return
	end
	local equipMgr = G_getEquipMgr()
	if equipMgr:getNeedUpdateEquipList() then
		self:updateEquipList()
		self:updateWing()		
		equipMgr:setNeedUpdateEquipList(false)
	end
	
	local hero = G_getHero()		
	if not arg.playerObj or not arg.playerType then
		arg.playerObj = hero	
		arg.playerType = 0	
		CCLuaLog("arg illegal. set to hero")		
	end
	
	--不是英雄或者player变化了才需要重新update所有
	if arg and (self.playerInfo.playerObj ~= arg.playerObj or self.playerInfo.playerObj ~= hero) then
		self.playerInfo = arg		
		self:updateEquipList()
		self:updateWing()
		self:updatePlayerInfo()
	end		
	
	if self.playerInfo and self.playerInfo.playerType == 1 then	--其他玩家不需要显示背包按钮
		self.bagBtn:setVisible(false)
		VisibleRect:relativePosition(self.detailBtn , self.bgNode, LAYOUT_CENTER  + LAYOUT_BOTTOM_INSIDE, ccp(0, 8))
	else
		self.bagBtn:setVisible(true)
		VisibleRect:relativePosition(self.detailBtn , self.bgNode, LAYOUT_LEFT_INSIDE  + LAYOUT_BOTTOM_INSIDE, ccp(12, 8))
	end	
	self.equipCircleView:setIsHero(self:isHero())
end		

function RoleSubPropertyView:isHero()
	return self.playerInfo.playerType == 0
end

--更新装备列表
function RoleSubPropertyView:updateEquipList(eventType, map)
	if self.playerInfo.playerObj == nil  then
		return	
	end	
	
	if self:isHero() and eventType and map then
		self:updateHeroEquipList(eventType, map)
	else
		local equipList	
		local equipMgr	= G_getEquipMgr()
		if self:isHero() then
			equipList = equipMgr:getEquipList()
		else
			equipList = equipMgr:getOtherPlayerEquipList()		
		end
		self.heroModelView:removeAllEquip()
		if equipList then
			self.equipCircleView:updateBodyAreaView(equipList)		
			self.heroModelView:setEquipList(equipList)	
		end		
	end
end	

function RoleSubPropertyView:updateHeroEquipList(eventType, map)
	local twinkleTip = function(msgWord)
		local msg = {}
		table.insert(msg,{word = Config.Words[16042], color = Config.FontColor["ColorWhite1"]})
		table.insert(msg,{word = "["..msgWord.."]", color = Config.FontColor["ColorRed3"]})
		table.insert(msg,{word = Config.Words[16043], color = Config.FontColor["ColorWhite1"]})
		--GameWorld.Instance:getEntityManager():getHero():twinkleTip(msg,6)
		UIManager.Instance:showSystemTips(msg)
	end
	if (E_UpdataEvent.Add == eventType or E_UpdataEvent.Modify == eventType) then	
		for bodyAreaId, equipArray in pairs(map) do		
			for pos, equip in pairs(equipArray) do		
				self.equipCircleView:updateOneBodyAreaView(bodyAreaId, pos, equip)
				self.heroModelView:addEquip(equip)
				--local name = G_getStaticPropsName(refId)
				if E_UpdataEvent.Add == eventType and type(equip:getStaticData().property) == "table" then
					local name = PropertyDictionary:get_name(equip:getStaticData().property)
					twinkleTip(name,6)
				end
			end
		end			
	elseif (E_UpdataEvent.Delete == eventType) then
		for bodyAreaId, equipArray in pairs(map) do		
			for pos, equip in pairs(equipArray) do		
				self.equipCircleView:updateOneBodyAreaView(bodyAreaId, pos, nil)
				self.heroModelView:removeEquip(equip:getBodyAreaId())
				if bodyAreaId == E_BodyAreaId.eCloth then
					self.heroModelView:addLuomo()
				end
			end
		end
	end
	self:updateAddIcon()
end

function RoleSubPropertyView:updateAddIcon()
	self.equipCircleView:updateAddIcon()
end

function RoleSubPropertyView:updatePlayerInfo()
	if not self.playerInfo.playerObj or not self.playerInfo.playerObj:getPT() then
		return
	end		
	self:showFightPower()
	local vipLevel = PropertyDictionary:get_vipType(self.playerInfo.playerObj:getPT())
	if vipLevel > 0 then
		self:showVIP(true)
	else
		self:showVIP(false)
	end			
	self:showLevelAndName()
end

--更新翅膀
function RoleSubPropertyView:updateWing()
	if self.playerInfo.playerObj == nil  then
		return	
	end	
	
	if self.playerInfo.playerType == 0 then				--玩家自己
		local wingMgr = G_getHero():getWingMgr()
		self.heroModelView:removeWing()
		self.heroModelView:setWing(wingMgr:getWingRefId())
	elseif self.playerInfo.playerType == 1 then			--其他玩家
		if type(self.playerInfo.playerObj:getPT()) ~= "table" then	--其他玩家可能没有PT
			self.heroModelView:removeWing()
			return
		end
		local wingModelId = PropertyDictionary:get_wingModleId(self.playerInfo.playerObj:getPT())
		local wingRefId
		for j, v in pairs(GameData.Wing) do		
			if v.property.modelId == wingModelId then
				wingRefId = v.refId
			end
		end
		if wingRefId then
			self.heroModelView:removeWing()
			self.heroModelView:setWing(wingRefId)
		else
			self.heroModelView:removeWing()
		end
	end
end












---------以下为私有方法-----------
function RoleSubPropertyView:initBgAndTitle()
	self.bgNode = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(379, 500))
	self.rootNode:addChild(self.bgNode)
	VisibleRect:relativePosition(self.bgNode, self.rootNode, LAYOUT_CENTER, ccp(0, -2))

	self.heroBg = CCSprite:create("ui/ui_img/common/player_bg.pvr")	
	self.rootNode:addChild(self.heroBg)
	VisibleRect:relativePosition(self.heroBg, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))	

	local player_outside_left = createSpriteWithFrameName(RES("player_outside_frame.png"))
	local player_outside_right = createSpriteWithFrameName(RES("player_outside_frame.png"))
	self.rootNode:addChild(player_outside_left)
	self.rootNode:addChild(player_outside_right)
	player_outside_right:setScaleX(-1)
	VisibleRect:relativePosition(player_outside_left, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-8, 51))
	VisibleRect:relativePosition(player_outside_right, self.rootNode, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(8, 51))
end

function RoleSubPropertyView:showFightPower()
	if (self.fpLabel == nil) then
		self.fpBg = createSpriteWithFrameName(RES("player_fighting_lable.png"))
		self.rootNode:addChild(self.fpBg)
		VisibleRect:relativePosition(self.fpBg, self.heroBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(-40, 95))
--		VisibleRect:relativePosition(self.fpBg, self.heroBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X, ccp(0, -40))
		local atlasName = Config.AtlasImg.PlayerFightNumber
		self.fpLabel = createAtlasNumber(atlasName, "100")
		self.rootNode:addChild(self.fpLabel)
		VisibleRect:relativePosition(self.fpLabel, self.fpBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	end

	local fp = PropertyDictionary:get_fightValue(self.playerInfo.playerObj:getPT())
	if (fp ~= nil) then
		self.fpLabel:setString(string.format("%d", fp))
	else 
		self.fpLabel:setString("")
	end
end

function RoleSubPropertyView:showVIP(flag)
	if (self.vipIcon == nil) then
		self.vipIcon = createSpriteWithFrameName(RES("main_vipgold.png"))
		self.rootNode:addChild(self.vipIcon)
		VisibleRect:relativePosition(self.vipIcon, self.heroBg, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(75, -5))		
--		VisibleRect:relativePosition(self.vipIcon, self.heroBg, LAYOUT_TOP_OUTSIDE + LAYOUT_LEFT_INSIDE, ccp(30, 10))		
	end
	if (flag) then
		self.vipIcon:setVisible(true)
	else
		self.vipIcon:setVisible(false)
	end
end

function RoleSubPropertyView:showLevelAndName()
	local level = PropertyDictionary:get_level(self.playerInfo.playerObj:getPT())
	local name = PropertyDictionary:get_name(self.playerInfo.playerObj:getPT())
	if (self.levelLabel == nil) then
		--[[self.levelBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(180, 33))
		G_setScale(self.levelBg)
		self.rootNode:addChild(self.levelBg)		
		VisibleRect:relativePosition(self.levelBg, self.bgNode, LAYOUT_CENTER_X)	
		VisibleRect:relativePosition(self.levelBg, self.vipIcon, LAYOUT_CENTER_Y)	--]]
		
		self.levelLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorWhite2"))
		self.rootNode:addChild(self.levelLabel)
	end
	if (level and name) then
		self.levelLabel:setString(string.format("%d%s  %s", level, Config.Words[10063], name))
	else
		self.levelLabel:setString("-1")
	end
	VisibleRect:relativePosition(self.levelLabel, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -11))	
end

function RoleSubPropertyView:initEquipCircleView()
	self.equipCircleView = EquipCircleView.New()	
	self.rootNode:addChild(self.equipCircleView:getRootNode())
	VisibleRect:relativePosition(self.equipCircleView:getRootNode(), self.bgNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,2))
	self.equipCircleView:setClickNotify(self, self.handleBodyAreaClick)
end

function RoleSubPropertyView:initHeroModelView()
	self.heroModelView = HeroModelView.New()
	self.rootNode:addChild(self.heroModelView:getRootNode(), const_heroModelViewZ)
	self.heroModelView:setGender(PropertyDictionary:get_gender(G_getHero():getPT()))
	VisibleRect:relativePosition(self.heroModelView:getRootNode(), self.bgNode, LAYOUT_CENTER, ccp(0, -20))	
end

function RoleSubPropertyView:initSplitLine()
--[[	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(const_size.width, 2))
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.bgNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 53))--]]
end

-- 显示功能按键
function RoleSubPropertyView:initBtn()
	self.detailBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local detailText = createSpriteWithFrameName(RES("word_button_detailedinfo.png"))
	self.rootNode:addChild(self.detailBtn )
	self.detailBtn :setTitleString(detailText)
	VisibleRect:relativePosition(self.detailBtn , self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(12, 8))
	local detailClick = function()	
		if UIManager.Instance:isShowing(ViewName_DetailPropertyView) then
			GlobalEventSystem:Fire(GameEvent.EVENT_HideDetailProperty)
		else			
			if (UIManager.Instance:getViewPositon(ViewName_RoleView) ~= E_ViewPos.eLeft) then
				GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,self.playerInfo)
				UIManager.Instance:moveViewByName(ViewName_RoleView, E_ViewPos.eLeft)
			else
				GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eRight, self.playerInfo)
			end
			GlobalEventSystem:Fire(GameEvent.EventHideBag)	
		end
	end
	self.detailBtn :addTargetWithActionForControlEvents(detailClick, CCControlEventTouchDown)
	
	self.bagBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local bagText = createSpriteWithFrameName(RES("word_button_openbag.png"))
	self.rootNode:addChild(self.bagBtn)
	self.bagBtn:setTitleString(bagText)
	VisibleRect:relativePosition(self.bagBtn, self.bgNode, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-12, 8))
	VisibleRect:relativePosition(detailText, self.detailBtn , LAYOUT_CENTER)
	VisibleRect:relativePosition(bagText, self.bagBtn, LAYOUT_CENTER)
	local bagClick = function()
		if UIManager.Instance:isShowing(ViewName_BagView) then
			GlobalEventSystem:Fire(GameEvent.EventHideBag)
		else
			if (UIManager.Instance:getViewPositon(ViewName_RoleView) ~= E_ViewPos.eLeft) then
				GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eMove2Right, {contentType = E_BagContentType.Equip, delayLoadingInterval = 0.5})				
				UIManager.Instance:moveViewByName(ViewName_RoleView, E_ViewPos.eLeft)
			else
				GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eRight, {contentType = E_BagContentType.Equip, delayLoadingInterval = 0.05})
			end
			GlobalEventSystem:Fire(GameEvent.EVENT_HideDetailProperty)
		end
	end
	self.bagBtn:addTargetWithActionForControlEvents(bagClick, CCControlEventTouchDown)
end

function RoleSubPropertyView:handleBodyAreaClick(view) 
	if not view then
		return
	end
	
	local equipObj = view:getData()
	if (equipObj) then
		local arg = ItemDetailArg.New()
		arg:setItem(equipObj)	
		arg:setIsShowFpTips(false)		
		arg:setBtnArray({E_ItemDetailBtnType.eShow, E_ItemDetailBtnType.eDetail, E_ItemDetailBtnType.eUnload})
		if self.playerInfo.playerType ==1 then  --其他玩家屏蔽展示和卸下按钮
			arg:setBtnArray({})
		end
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg)
		arg:DeleteMe()
	elseif self.playerInfo.playerType == 0 and view:isShowAddIcon() then	--玩家自己
		if (UIManager.Instance:getViewPositon("RoleView") ~= E_ViewPos.eLeft) then
			UIManager.Instance:moveViewByName("RoleView", E_ViewPos.eLeft)
			GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eMove2Right, {contentType = E_BagContentType.Equip, delayLoadingInterval = 0.5})
		else
			GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eRight, {contentType = E_BagContentType.Equip, delayLoadingInterval = 0.05})
		end
		GlobalEventSystem:Fire(GameEvent.EVENT_HideDetailProperty)
	else	--其他玩家
				
	end
end	