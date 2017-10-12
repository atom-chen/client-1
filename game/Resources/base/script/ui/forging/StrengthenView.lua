require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.forging.BaseForgingSubView")
require("ui.forging.StrengthenPropertyPreview")
require("ui.utils.ScrollChoiceBar")
	
StrengthenView = StrengthenView or BaseClass(BaseForgingSubView)	
local const_scale = VisibleRect:SFGetScale()
local g_hero = nil

function StrengthenView:__init()
	g_hero = GameWorld.Instance:getEntityManager():getHero()
	self:initBg()	
	self:initStrengthenPreview()
	self:initBtn()	
	self.equipSimpleListView:setSingleSelect(true)	
	self.selectedEquip = nil
	self.isLocked = false	
	self.showMsgState = false		
	self:switchEquipSource(self.curEquipSource)	
end

function StrengthenView:__delete()
	if (self.choiceBar) then
		self.choiceBar:DeleteMe()
	end
	if (self.preview) then
		self.preview:DeleteMe()
	end
end

function StrengthenView:initBg()
	local fontBg = createSpriteWithFrameName(RES("forging_fontBg.png"))
	self.rootNode:addChild(fontBg)
	VisibleRect:relativePosition(fontBg, self.previewBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(10, -15))
	self.previewTipsLabel = createSpriteWithFrameName(RES("forging_strengthenPreviewFont.png"))
	self.rootNode:addChild(self.previewTipsLabel)	
	VisibleRect:relativePosition(self.previewTipsLabel, fontBg, LAYOUT_CENTER, ccp(0, 18))	
	
	local tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[575], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorRed1"))
	self.previewBg:addChild(tips)
	VisibleRect:relativePosition(tips, self.previewBg, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_OUTSIDE, ccp(10, 28))	
end	

function StrengthenView:subOnEnter()
	if self.curEquipSource == E_EquipSource.inBody then	
		self.equipSimpleListView:unSelectAll(true)	
		if self.needUpdateEquip then
			self:switchEquipSource(E_EquipSource.inBody)
			self.needUpdateEquip = false
		else
			self.equipSimpleListView:selectAtIndex(1, true, true)			
		end
	else	
		self:switchEquipSource(E_EquipSource.inBody)	--如果不是显示身上的，则切换到身上的
		self.needUpdateItem = false
	end		
end	

--切换背包和身上的装备
function StrengthenView:onSwitchEquipSource()
	self.selectedEquip = nil
	self:selecteOneEquip(nil)
	self.equipSimpleListView:selectAtIndex(1, true, true)	
end

--点击了一个装备
function StrengthenView:onEquipSelected(index, equip, selected)
	if (not self.selectedEquip) or (not equip) or (self.selectedEquip:getId() ~= equip:getId()) then	
		self:switchLockState(false)	--如果切换了选定的装备，则取消保持100%成功锁定
		local bindStatus = PropertyDictionary:get_bindStatus(equip:getPT())
		if bindStatus == E_State_Bind then		
			self.isUseBindFirst = true
	
		elseif bindStatus == E_State_UnBind then
			self.isUseBindFirst = false
		end			
		self.useBindIcon:setVisible(self.isUseBindFirst)
		self.showMsgState = true
	end		
	if (selected) then	
		self:selecteOneEquip(equip)
	else
		self:selecteOneEquip(nil)
	end	
end		

function StrengthenView:selecteOneEquip(equip)
	if (equip ~= nil) then
		self.selectedEquip = equip
		self.preview:setEquip(equip)
		self.curPD = self.preview:getCurPD()
		self.nextPD = self.preview:getNextPD()	
		--self.needTipsLabel:setVisible(true)
		
		self:showSuccessRateAddition()
		self:showStrengthenFailTips()	
		self:showUnbindGoldNum()
		self:showMaterialNum()
		self:showGoldNum()
		self:showMyStrengthInfo()
		--如果强化满级  则隐藏操作部分		
		local strengtheningLevel = PropertyDictionary:get_strengtheningLevel(equip:getPT())
		if (strengtheningLevel == const_maxStrengthenLevel) then
			self:setOperatorVisible(false)
		else
			self:setOperatorVisible(true)
		end	
	else
		self.selectedEquip = nil
		self.preview:setEquip(nil)
		self.curPD = nil
		self.nextPD = nil
		self:setOperatorVisible(false)
	end	
end
--显示需要元宝的数量
function StrengthenView:showUnbindGoldNum()
	if (self.unbindGoldNumNode) then
		self.operatorBg:removeChild(self.unbindGoldNumNode, true)	
		self.unbindGoldNumNode = nil	
	end	
	if (self.nextPD == nil) then
		return
	end

	local unbindGold = PropertyDictionary:get_succeedUpConsume(self.nextPD)
	
	local color 
	if (G_checkYuanbaoEnough(unbindGold) == true) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed1")
	end
	local num = self.successRateAdditionMap[self.choiceBar:getIndex()]
	if not num then
		num = 0
	end
	--[[if table.size(self.successRateAdditionMap)>0 then
		num = 0
	else
		num = unbindGold
	end--]]
	self.unbindGoldNumNode, self.unbindGoldNumKey, self.unbindGoldNumValue = G_createKeyValue(Config.Words[10190],tostring(num) , color, FCOLOR("ColorYellow2"), FSIZE("Size3"), FSIZE("Size3"))
	self.operatorBg:addChild(self.unbindGoldNumNode)
	VisibleRect:relativePosition(self.unbindGoldNumNode, self.operatorBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0, 52))
end

--显示需要强化石的数量
function StrengthenView:showMaterialNum()
	if (self.materialNumNode) then
		self.operatorBg:removeChild(self.materialNumNode, true)	
		self.materialNumNode = nil	
	end	
	if (self.nextPD == nil) then
		return
	end

	local num = PropertyDictionary:get_useMaterialCount(self.nextPD)
	self.materialNum = num
	
	local color 
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local bindMaterialNum,unbindMaterialNum =	bagMgr:getBindedAndUnbindItemNumByRefId("item_qianghuashi")	
	if (bindMaterialNum+unbindMaterialNum >= num) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed1")
	end
	
	self.materialNumNode, self.materialNumKey, self.materialNumValue = G_createKeyValue(Config.Words[10100], tostring(num), color, FCOLOR("ColorYellow2"), FSIZE("Size3"), FSIZE("Size3"))
	self.operatorBg:addChild(self.materialNumNode)
	VisibleRect:relativePosition(self.materialNumNode, self.unbindGoldNumNode, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 5))
end



--显示需要金币的数量
function StrengthenView:showGoldNum()
	if (self.goldNode) then
		self.operatorBg:removeChild(self.goldNode, true)	
		self.goldNode = nil	
	end	
	if (self.nextPD == nil) then
		return
	end
	
	local num = PropertyDictionary:get_gold(self.nextPD)
	self.goldNum = num
	local color 
	if (G_checkGoldEnough(num) == true) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed1")
	end
	
	self.goldNode, self.goldKey, self.goldValue = G_createKeyValue(Config.Words[10101], tostring(num), color, FCOLOR("ColorYellow2"), FSIZE("Size3"), FSIZE("Size3"))
	self.operatorBg:addChild(self.goldNode)	
	VisibleRect:relativePosition(self.goldNode, self.materialNumNode, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 5))
end	

function StrengthenView:showMyStrengthInfo()
	local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())		    
	local gold = PropertyDictionary:get_gold(g_hero:getPT())
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local bindMaterialNum,unbindMaterialNum =	bagMgr:getBindedAndUnbindItemNumByRefId("item_qianghuashi")	
	local materialNumString = string.format(" /  %s(%s) %s(%s)",tostring(bindMaterialNum),Config.Words[10211],tostring(unbindMaterialNum),Config.Words[10212])
	if (self.myUnbindGoldLabel) then	
		self.myUnbindGoldLabel:setString(" / "..tostring(unbindedGold))		
	else
		self.myUnbindGoldLabel = createLabelWithStringFontSizeColorAndDimension(" / "..tostring(unbindedGold),"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		self.operatorBg:addChild(self.myUnbindGoldLabel)
	end	
	if (self.myGoldLabel) then
		self.myGoldLabel:setString(" / "..tostring(gold))
	else
		self.myGoldLabel = createLabelWithStringFontSizeColorAndDimension(" / "..tostring(gold),"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		self.operatorBg:addChild(self.myGoldLabel)	
	end	
	if (self.myMaterialLabel) then
		self.myMaterialLabel:setString(materialNumString)
	else
		self.myMaterialLabel = createLabelWithStringFontSizeColorAndDimension(materialNumString,"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		self.operatorBg:addChild(self.myMaterialLabel)	
	end			
	VisibleRect:relativePosition(self.myGoldLabel, self.goldNode, LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.myMaterialLabel, self.materialNumNode, LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.myUnbindGoldLabel, self.unbindGoldNumNode, LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
end

function StrengthenView:initStrengthenPreview()
	self.preview = StrengthenPropertyPreview.New()	
	self.rootNode:addChild(self.preview:getRootNode())
	VisibleRect:relativePosition(self.preview:getRootNode(), self.previewBg, LAYOUT_CENTER)
end		

function StrengthenView:showStrengthenFailTips()
	if (self.strengthenFailTips == nil) then
		self.strengthenFailTips = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorRed1"))
		self.operatorBg:addChild(self.strengthenFailTips)
	end
	
	if (self.curPD == nil) then
		self.strengthenFailTips:setString(" ")	
		return
	end
	local des = G_getStrengthenFailTipsByLevel(PropertyDictionary:get_strengtheningLevel(self.curPD))	
	self.strengthenFailTips:setString(des)	
	VisibleRect:relativePosition(self.strengthenFailTips, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(335, -20))	
end

function StrengthenView:switchLockState(lock)
	if lock == self.isLocked then
		return
	end
	if (self.isLocked == true) then
		self.selectedIcon:setVisible(false)
		self.isLocked = false
		self.choiceBar:setIndex(0)			
	else
		self.selectedIcon:setVisible(true)
		self.isLocked = true	
		self.choiceBar:setIndex(table.size(self.successRateAdditionMap) - 1)		
	end	
	self:updateGoldNumber()
end

function StrengthenView:initBtn()
	--一键100%勾选按钮
	local oneKeyBtn = createButtonWithFramename(RES("common_selectBox.png"))
	self.selectedIcon = createSpriteWithFrameName(RES("common_selectIcon.png"))
	VisibleRect:relativePosition(self.selectedIcon, oneKeyBtn, LAYOUT_CENTER,ccp(15,13))	
	oneKeyBtn:addChild(self.selectedIcon)	
	local onKeyText = createLabelWithStringFontSizeColorAndDimension(Config.Words [10189], "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow1"))
	self.operatorBg:addChild(oneKeyBtn)
	self.operatorBg:addChild(onKeyText)	
	
	VisibleRect:relativePosition(oneKeyBtn, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(0, -70))
	VisibleRect:relativePosition(onKeyText, oneKeyBtn, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(5,0))
	local oneKeyClick = function()	
		self:switchLockState(not self.isLocked)		
	end
	self.selectedIcon:setVisible(self.isLocked)
	oneKeyBtn:addTargetWithActionForControlEvents(oneKeyClick, CCControlEventTouchDown)
		
	--优先使用绑定材料按钮
	local useBindFirstBtn = createButtonWithFramename(RES("common_selectBox.png"))
	self.useBindIcon = createSpriteWithFrameName(RES("common_selectIcon.png"))
	VisibleRect:relativePosition(self.useBindIcon, useBindFirstBtn, LAYOUT_CENTER,ccp(15,13))	
	useBindFirstBtn:addChild(self.useBindIcon)	
	local useBindText = createLabelWithStringFontSizeColorAndDimension(Config.Words [10208], "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow1"))
	self.operatorBg:addChild(useBindFirstBtn)
	self.operatorBg:addChild(useBindText)	
	
	VisibleRect:relativePosition(useBindFirstBtn, oneKeyBtn, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE , ccp(0, -20))	
	VisibleRect:relativePosition(useBindText, useBindFirstBtn, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(5,0))
	local useBindClick = function()	
		self:switchUseBindState()		
	end
	self.useBindIcon:setVisible(self.isUseBindFirst)
	useBindFirstBtn:addTargetWithActionForControlEvents(useBindClick, CCControlEventTouchDown)
	--强化按钮
	local startBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local startText = createSpriteWithFrameName(RES("word_button_strengthen.png"))
	self.operatorBg:addChild(startBtn)
	startBtn:setTitleString(startText)
	
	VisibleRect:relativePosition(startBtn, self.operatorBg, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE , ccp(0, 0))	
	local startClick = function()	
		self:startStrengthen()
	end
	startBtn:addTargetWithActionForControlEvents(startClick, CCControlEventTouchDown)
end

function StrengthenView:switchUseBindState()
	if self.showMsgState == true then
		if self.isUseBindFirst == true then			
			self:showStrengMsg(Config.Words[10209])								
		elseif self.isUseBindFirst == false then			
			self:showStrengMsg(Config.Words[10210])	
		end	
	else
		self.isUseBindFirst = not self.isUseBindFirst
		self.useBindIcon:setVisible(self.isUseBindFirst)
	end
	
end

function StrengthenView:showStrengMsg(msg)
	local isUseBindFirst = function(arg,text,id)
		if id == 2 then
			self.isUseBindFirst = not self.isUseBindFirst
			self.useBindIcon:setVisible(self.isUseBindFirst)
			self.showMsgState = false
		else
			return
		end
	end				
	local msgBox = showMsgBox(msg,3)	
	msgBox:setNotify(isUseBindFirst)						
end

function StrengthenView:showSuccessRateAddition()
	if (self.choiceBar == nil) then
		self.choiceBar = ScrollChoiceBar.New()	
		self.choiceBar:setMode(E_DirectionMode.Horizontal)		
		
		local bg = createSpriteWithFrameName(RES("ui_game_whiteBar.png"))
		self.operatorBg:addChild(bg)		
		self.operatorBg:addChild(self.choiceBar:getRootNode())
		bg:setScaleX(1.05)
		
		local bgSize = bg:getContentSize()		
		self.choiceBar:setPageSize(CCSizeMake(bgSize.width/3, bgSize.height))
		self.choiceBar:setViewSize(CCSizeMake(bgSize.width, bgSize.height))
		--self.choiceBar:getRootNode():setPageEnable(false)
		local midPointLine = createSpriteWithFrameName(RES("main_slider.png"))
		bg:addChild(midPointLine)	
		
		local successLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[571], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
		self.operatorBg:addChild(successLabel)		
		
		VisibleRect:relativePosition(midPointLine, bg, LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE, ccp(0, -16))
		VisibleRect:relativePosition(self.choiceBar:getRootNode(), self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(90, -10))
		VisibleRect:relativePosition(bg, self.choiceBar:getRootNode(), LAYOUT_CENTER, ccp(-15, 0))
		--VisibleRect:relativePosition(self.choiceBar:getRootNode(), bg, LAYOUT_CENTER)
		VisibleRect:relativePosition(successLabel, bg, LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER_Y, ccp(-10, 0))	
	end
	local handleChoiceBarNotify = function (eventType, indexx)
		self:handleChoiceBarNotify(eventType, indexx)
	end

	self.choiceBar:setNotify(self.choiceBar:getIndex(), handleChoiceBarNotify)
	self.choiceBar:setDataList(self:buildSuccessRateAdditionList())	
	self.choiceBar:reload()
	local size = self.choiceBar:getRootNode():getContentSize()		
	if self.isLocked then	
		if self.successRateAdditionMap then
			self.choiceBar:setIndex(table.size(self.successRateAdditionMap) - 1)					
		end
	end	
end

function StrengthenView:handleChoiceBarNotify(eventType, index)
	if not self.successRateAdditionMap then
		return
	end
	self:updateGoldNumber()
	self:setSelectIconVisible()
end

function StrengthenView:updateGoldNumber()
	local text = self.successRateAdditionMap[self.choiceBar:getIndex() +1]
	if text then
		self.unbindGoldNumValue:setString(text)
	else
		self.unbindGoldNumValue:setString("0")
	end		
	if (G_checkYuanbaoEnough(tonumber(text)) == true) then
		self.unbindGoldNumValue:setColor(FCOLOR("ColorGreen1"))
	else
		self.unbindGoldNumValue:setColor(FCOLOR("ColorRed2"))
	end
--	VisibleRect:relativePosition(self.unbindGoldNumValue, self.unbindGoldNumKey, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(10, 0))
	VisibleRect:relativePosition(self.unbindGoldNumValue, self.unbindGoldNumNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(85, 0))
end

function StrengthenView:setSelectIconVisible()
	self.selectedIcon:setVisible(false)
	self.isLocked = false		
end

function StrengthenView:buildSuccessRateAdditionList()
	if (self.nextPD == nil) then
		return nil
	end
	
	local unbindGold = 0
	local succeedUpConsumeStep = PropertyDictionary:get_succeedUpConsume(self.nextPD)	--每增加10%成功率需要消耗的元宝	
	local successRate = PropertyDictionary:get_probability(self.nextPD)
	
	self.successRateAdditionMap = {}
	local list = {}
	local step = 0
	while true do
		if (successRate >= 110) then
			break 
		elseif successRate > 100 then
			successRate = 100
		end
				
 		local str = string.format("%d%s", successRate,"%")
		table.insert(list, str)		
		table.insert(self.successRateAdditionMap, unbindGold)	
		
		successRate = successRate + 10	
		unbindGold = unbindGold + succeedUpConsumeStep
	end
	table.insert(list, "")
	table.insert(list, 1, "")
	--[[table.insert(list, "")
	table.insert(list, 1, "")--]]
	return list
end	

function StrengthenView:startStrengthen()
	if (self.selectedEquip == nil) then
		return
	end
	
	if PropertyDictionary:get_strengtheningLevel(self.selectedEquip:getPT()) >= const_maxStrengthenLevel then
		UIManager.Instance:showSystemTips(string.format(Config.Words[10146], const_maxStrengthenLevel))
		return
	end		
	if (G_checkGoldEnough(self.goldNum, true) == false) then
		return
	end		
	local canStart = G_checkMaterialEnough(self.materialNum, self.isUseBindFirst)	
	if canStart == E_MaterialShowBox then
	
		local isUseBindFirst = function(arg,text,id)
			if id == 1 then
				return
			elseif id == 2 then
				self:doStrengthen()
			end
		end											
		local msgBox = showMsgBox(Config.Words[10215],3)		
		msgBox:setNotify(isUseBindFirst)
		return
	elseif canStart == E_MaterialNotEnough then
		return
	end
	
	
	self:doStrengthen()
	
end

function StrengthenView:doStrengthen()
	local index = self.choiceBar:getIndex()
	if (self.successRateAdditionMap) then
		local yuanbao = self.successRateAdditionMap[index + 1]
		if (yuanbao == nil) then
			return
		end
				  	
		if (G_checkYuanbaoEnough(yuanbao, true) == false) then
			return
		end	
		local useBindState = ""
		if self.isUseBindFirst == true then
			useBindState = 1
		else
			useBindState = 0
		end
		if (self.curEquipSource == E_EquipSource.inBag) then
			UIManager.Instance:showLoadingHUD(2)
			G_getForgingMgr():requestBag_Streng(self.selectedEquip, yuanbao,useBindState)
		else
			UIManager.Instance:showLoadingHUD(2)
			G_getForgingMgr():requestBody_Streng(self.selectedEquip, yuanbao,useBindState)
		end
	end
end