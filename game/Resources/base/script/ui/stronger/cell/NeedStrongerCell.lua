--变强的cell类

NeedStrongerCell = NeedStrongerCell or BaseClass(BaseStrongerCell)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local configData = {
["strong_1"] = {iconId = "equip_40_2110",metalId = "equip_40_2110"},
["strong_2"] = {iconId = "equip_40_2110",metalId = "item_qianghuashi"},
["strong_3"] = {iconId = "equip_40_2110",metalId = "item_qianghuashi"},
["strong_4"] = {iconId = "item_zuoqiExp",metalId = "item_zuoqiExp"},
["strong_5"] = {iconId = "item_chibangExp",metalId = "item_chibangExp"},
["strong_6"] = {iconId = "item_shenqiExp",metalId = "item_shenqiExp"},
["strong_7"] = {iconId = "item_merit",metalId = "item_merit"},
["strong_8"] = {iconId = "item_suipian_1",metalId = "item_suipian_1"},
}

function NeedStrongerCell:__init()
	self:setReady(true)
	self.hasInit = false
end


function NeedStrongerCell:onEnter()
	if not  self.hasInit  then 
		self:initData()
		self:initCell()	
		self.hasInit  = true
	end
end

function NeedStrongerCell:clear()
	
end

function NeedStrongerCell:__delete()
end

function NeedStrongerCell:initCell()
	self:setCellTitleImage()
	if self.fightValue ~= -1 then
		self:setCellControl()
		self:setCellItemImageAndLinkText(true)
	else
		self:setCellItemImageAndLinkText(false)
	end	
end

function NeedStrongerCell:setCellTitleImage()
	local titleIcon,ttype ,scale= GameWorld.Instance:getStrongerMgr():getNeedStrongTitleIconAndTypeAndScaleByRefId(self.refId)
	if  titleIcon then
		local iconFrame = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
		self.rootNode:addChild(iconFrame)		
		VisibleRect:relativePosition(iconFrame, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y,ccp(5,0))		
			
		
		local titleSprite 
		if ttype == "icon" then		
			titleSprite = createSpriteWithFileName(ICON(titleIcon))
		else
			titleSprite = createSpriteWithFrameName(RES(titleIcon.. ".png"))
		end
		if  titleSprite then
			titleSprite:setScale(scale/100)
			iconFrame:addChild(titleSprite)		
			VisibleRect:relativePosition(titleSprite, iconFrame,LAYOUT_CENTER)		
		end
		
		local arrowSprite = createSpriteWithFrameName(RES("strongerUpArrow.png"))
		iconFrame:addChild(arrowSprite)		
		VisibleRect:relativePosition(arrowSprite, iconFrame,LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE)		
	end	
end

function NeedStrongerCell:setCellControl()
	local fightValueStr = ""
	if self.fightValue ~= -1 then
		fightValueStr = string.format(self.hearStr,self.fightValue)
	else
		fightValueStr = string.format(self.hearStr,0)
	end
		
	local stateLabel 
	if  tostring(self.state) == tostring(1) then
		stateLabel= createSpriteWithFrameName(RES("strong_ImmediatelyUpdate.png"))
	elseif tostring(self.state) == tostring(2) then
		stateLabel = createSpriteWithFrameName(RES("strong_await Update.png"))		
	elseif tostring(self.state) == tostring(3) then
		stateLabel = createSpriteWithFrameName(RES("strong_PerfectUpdate.png"))		
	end
	stateLabel:setScale(0.85)
	self.rootNode:addChild(stateLabel)		
	VisibleRect:relativePosition(stateLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(80,-20))
	--stateLabel:setRotation(330)
	
	local fightLabel = createLabelWithStringFontSizeColorAndDimension(fightValueStr,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.rootNode:addChild(fightLabel)		
	VisibleRect:relativePosition(fightLabel, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(80,20))		
	
	local button = createButtonWithFramename(RES("btn_1_select.png"))
	self.rootNode:addChild(button)		
	VisibleRect:relativePosition(button, self.rootNode, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-10,0))	
	
	local textName = GameWorld.Instance:getStrongerMgr():getNeedStrongBtTextByRefId(self.refId)
	local btText = createSpriteWithFrameName(RES(textName ..".png"))
	button:setTitleString(btText)
	local callBackFunc = function()
		self:onCellBtClick()
	end	
	button:addTargetWithActionForControlEvents(callBackFunc,CCControlEventTouchDown)		
end

function NeedStrongerCell:setCellItemImageAndLinkText(state)
	local menuRefId = GameWorld.Instance:getStrongerMgr():getNeedStrongLinkMenu(self.refId)
	local metalIcon = GameWorld.Instance:getStrongerMgr():getMenuIconByRefId(menuRefId)		
	local metalSprite 
	local arg = 0
	if state then
		if  metalIcon then
			metalSprite= createSpriteWithFileName(ICON(metalIcon))
		end	
		arg = 1
	else
		metalSprite= createSpriteWithFileName(ICON("item_exp"))
	end
	metalSprite:setScale(0.8)
	local text = string.wrapHyperLinkRich(self.linkStr,Config.FontColor["ColorYellow1"],FSIZE("Size3"),arg , "true") 
	
	local linkLabel = createRichLabel(CCSizeMake(200,0))
	linkLabel:setGaps(5)
	linkLabel:setAnchorPoint(ccp(0.5,1))
	linkLabel:setFontSize(FSIZE("Size3"))
	linkLabel:appendFormatText(text)	
	linkLabel:setTouchEnabled(true)
	
	local richLabelHandler = function(arg, pTouch)	
		local touch = tolua.cast(pTouch, "CCTouch")
		local pos = touch:getLocation()
		self:linkTextNotify(arg)		
	end
	linkLabel:setEventHandler(richLabelHandler)	
	
	self.rootNode:addChild(linkLabel)	
	self.rootNode:addChild(metalSprite)				
	VisibleRect:relativePosition(metalSprite, self.rootNode, LAYOUT_CENTER,ccp(-60,0))
	VisibleRect:relativePosition(linkLabel, metalSprite, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(10,0))					
end

function NeedStrongerCell:setCellLinkText(text,linkRefId)
		
end

function NeedStrongerCell:linkTextNotify(state)
	local refId = "menu_2"
	local strongMgr = GameWorld.Instance:getStrongerMgr()
	if tostring(state) == tostring(1) then
		refId = strongMgr:getNeedStrongLinkMenu(self.refId)		
	end
	GlobalEventSystem:Fire(GameEvent.EventShowStrongerOptionView,refId)
end

function NeedStrongerCell:onCellBtClick()
	if self.refId == "strong_1"	then	--打开背包 装备页卡 --角色界面	
		GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,G_getHero()) 
		GlobalEventSystem:Fire(GameEvent.EventOpenBag, E_ShowOption.eMove2Right, {contentType = E_BagContentType.Equip, delayLoadingInterval = 0.5})
	elseif  self.refId == "strong_2" then --打开强化界面
		GlobalEventSystem:Fire(GameEvent.EventOpenForgingView,E_ShowOption.eMiddle)	
	elseif  self.refId == "strong_3" then --打开洗练界面
		GlobalEventSystem:Fire(GameEvent.EventOpenForgingView,E_ShowOption.eMiddle)
	elseif  self.refId == "strong_4" then --打开坐骑
		GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen,E_ShowOption.eMiddle)
	elseif  self.refId == "strong_5" then--打开翅膀
		GlobalEventSystem:Fire(GameEvent.EventOpenWingView,E_ShowOption.eMiddle)
	elseif  self.refId == "strong_6" then--打开心法
		GlobalEventSystem:Fire(GameEvent.EventTalismanViewOpen,E_ShowOption.eMiddle)
	elseif  self.refId == "strong_7" then--打开爵位
		local player = {playerObj=nil,playerType =0}	--0:玩家自己的信息
		GlobalEventSystem:Fire(GameEvent.EventOpenKnightView, E_ShowOption.eLeft, player)
	elseif  self.refId == "strong_8" then--打开法宝
		GlobalEventSystem:Fire(GameEvent.EventTalismanViewOpen,E_ShowOption.eMiddle)
	end
end

function NeedStrongerCell:updateName()

end

function NeedStrongerCell:initData()
	self.fightValue = 0
	self.hearStr = ""
	self.linkStr = ""
	local closeLinkStr = ""
	local openLinkStr = ""
	local itemCount = 0
	self.state  = 1
	local strongMgr = GameWorld.Instance:getStrongerMgr()
	if self.refId == "strong_1"	then	
		self.hearStr = Config.Words[26001]
		closeLinkStr = Config.Words[26012]
		openLinkStr = Config.Words[26016]		
		itemCount = G_getEquipMgr():getGreaterEquipCount()
		self.fightValue = GameUtil:getEquipBaseFightValue()	
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,1)		
	elseif  self.refId == "strong_2"	then
		self.hearStr = Config.Words[26002]
		closeLinkStr = Config.Words[26015]
		openLinkStr = Config.Words[26017]		
		itemCount = G_getBagMgr():getItemNumByRefId("item_qianghuashi")	
		self.fightValue = GameUtil:getEquipForgFightValue()
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,2)			
	elseif  self.refId == "strong_3"	then
		self.hearStr = Config.Words[26003]
		closeLinkStr = Config.Words[26015]
		openLinkStr = Config.Words[26017]	
		itemCount = G_getBagMgr():getItemNumByRefId("item_qianghuashi")			
		self.fightValue = GameUtil:getEquipWashFightValue()
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,3)	
	elseif  self.refId == "strong_4" then
		self.hearStr = Config.Words[26004]
		closeLinkStr = Config.Words[26013]
		openLinkStr = Config.Words[26018]	
		itemCount = G_getBagMgr():getItemNumByRefId("item_zuoqiExp")	
		self.fightValue = GameUtil:getMountFightValue()
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,4)	
	elseif  self.refId == "strong_5"	then
		self.hearStr = Config.Words[26005]
		closeLinkStr = Config.Words[26015]
		openLinkStr = Config.Words[26019]	
		itemCount = G_getBagMgr():getItemNumByRefId("item_chibangExp")			
		self.fightValue = GameUtil:getWingFightValue()	
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,5)	
	elseif  self.refId == "strong_6"	then
		self.hearStr = Config.Words[26007]	
		closeLinkStr = Config.Words[26014]
		openLinkStr = Config.Words[26020]		
		itemCount = G_getBagMgr():getItemNumByRefId("item_shenqiExp")			
		self.fightValue = GameUtil:getCittaFightValue()
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,7)				
	elseif  self.refId == "strong_7"	then
		self.hearStr = Config.Words[26008]	
		closeLinkStr = Config.Words[26012]
		openLinkStr = Config.Words[26021]		
		itemCount = PropertyDictionary:get_merit(G_getHero():getPT())	
		self.fightValue = GameUtil:getKnightFightValue()
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,8)	
	elseif  self.refId == "strong_8"	then
		self.hearStr = Config.Words[26006]	
		closeLinkStr = Config.Words[26014]
		openLinkStr = Config.Words[26022]		
		itemCount = table.size(GetLessSuipianTalisListByNum(0))	
		self.fightValue = GameUtil:getTalismanFightValue()	
		self.state = strongMgr:getRequireImproveLevel(self.fightValue,6)	
	end
	if self.fightValue ~= -1 then
		self.linkStr = string.format(openLinkStr,itemCount)
	else
		self.linkStr = closeLinkStr
	end
end