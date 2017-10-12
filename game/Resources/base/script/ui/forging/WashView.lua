require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.forging.BaseForgingSubView")
require("ui.forging.WashPreview")
require("ui.utils.ScrollChoiceBar")
	
WashView = WashView or BaseClass(BaseForgingSubView)	
local const_scale = VisibleRect:SFGetScale()
local g_hero = nil
local State_Bind = 1
local State_UnBind = 0
	
function WashView:__init()
	g_hero = GameWorld.Instance:getEntityManager():getHero()
	self:initBg()
	self:initPreview()
	self:initBtn()
	self.selectedEquip = nil
	self.showMsgState = false	
	self.lockPropertys = {}
	self.equipSimpleListView:setSingleSelect(true)
	self:switchEquipSource(self.curEquipSource)
end

function WashView:__delete()
	self.preview:DeleteMe()
end		


function WashView:initBg()
	local previewTipBg = createSpriteWithFrameName(RES("forging_fontBg.png"))
	self.rootNode:addChild(previewTipBg)
	VisibleRect:relativePosition(previewTipBg, self.previewBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(10, -15))--LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X, ccp(-194, -15))
	
	local previewTip = createSpriteWithFrameName(RES("forging_ concisePropertyFont.png"))
	self.rootNode:addChild(previewTip)
	VisibleRect:relativePosition(previewTip, previewTipBg, LAYOUT_CENTER, ccp(0, 18))
	
	--10115
	local tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[10115], "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorRed1"))								
	self.operatorBg:addChild(tips)
	VisibleRect:relativePosition(tips, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(0, 0))
end	

function WashView:subOnEnter()
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
function WashView:onSwitchEquipSource()
	UIManager.Instance:hideLoadingHUD()
	self.selectedEquip = nil
	self:selecteOneEquip(nil)
	self.equipSimpleListView:selectAtIndex(1, true, true)		
end

--点击了一个装备
function WashView:onEquipSelected(index, equip, selected)
	UIManager.Instance:hideLoadingHUD()	
	if (not self.selectedEquip) or (not equip) or (self.selectedEquip:getId() ~= equip:getId()) then		
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



function WashView:switchUseBindState()
	if self.showMsgState == true then
		if self.isUseBindFirst == true then			
			self:showWashMsg(Config.Words[10213])								
		elseif self.isUseBindFirst == false then			
			self:showWashMsg(Config.Words[10214])	
		end			
	else
		self.isUseBindFirst = not self.isUseBindFirst
		self.useBindIcon:setVisible(self.isUseBindFirst)
	end
	
end

function WashView:showWashMsg(msg)
	local isUseBindFirst = function(arg,text,id)
		if id == 2 then
			self.isUseBindFirst = not self.isUseBindFirst
			self.useBindIcon:setVisible(self.isUseBindFirst)
			self.showMsgState = false
		else
			return
		end
	end				
	local msg = showMsgBox(msg,3)	
	msg:setNotify(isUseBindFirst)						
end

function WashView:selecteOneEquip(equip)
	if (not self.selectedEquip) or (not equip) or (self.selectedEquip:getId() ~= equip:getId()) then
		self.preview:clearLockPropertys()
	end
	if (equip ~= nil) then
		self.selectedEquip = equip
		self.preview:setEquip(equip, self.preview:getLockPropertys())		
		self:setOperatorVisible(true)
	else
		self.selectedEquip = nil
		self.preview:setEquip(nil)
		self:setOperatorVisible(false)
	end	
	
	self:showMaterialNum()
	self:showGoldNum()
	self:showMyWashInfo()
end	

function WashView:initPreview()
	self.preview = WashPreview.New()	
	self.previewBg:addChild(self.preview:getRootNode())
	VisibleRect:relativePosition(self.preview:getRootNode(), self.previewBg, LAYOUT_CENTER, ccp(0, 30))	
	
	local onLockChanged = function()
		self:showMaterialNum()
		self:showGoldNum()
		self:showMyWashInfo()
	end
	self.preview:setLockNotify(nil, onLockChanged)
end			

function WashView:initBtn()
	
	
	--优先使用绑定材料按钮
	local useBindFirstBtn = createButtonWithFramename(RES("common_selectBox.png"))
	self.useBindIcon = createSpriteWithFrameName(RES("common_selectIcon.png"))
	VisibleRect:relativePosition(self.useBindIcon, useBindFirstBtn, LAYOUT_CENTER,ccp(15,13))	
	useBindFirstBtn:addChild(self.useBindIcon)	
	local useBindText = createLabelWithStringFontSizeColorAndDimension(Config.Words [10208], "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow1"))
	self.operatorBg:addChild(useBindFirstBtn)
	self.operatorBg:addChild(useBindText)	

	VisibleRect:relativePosition(useBindFirstBtn, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(0, -118))	
	VisibleRect:relativePosition(useBindText, useBindFirstBtn, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(5,0))
	local useBindClick = function()	
		self:switchUseBindState()		
	end
	self.useBindIcon:setVisible(self.isUseBindFirst)
	useBindFirstBtn:addTargetWithActionForControlEvents(useBindClick, CCControlEventTouchDown)	
	
	local startBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local startText = createSpriteWithFrameName(RES("word_button_forge.png"))
	self.operatorBg:addChild(startBtn)
	self.operatorBg:addChild(startText)		
	
	VisibleRect:relativePosition(startBtn, self.operatorBg, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE , ccp(0, 0))	
	VisibleRect:relativePosition(startText, startBtn, LAYOUT_CENTER)
	local startClick = function()	
		self:startWash()
	end
	startBtn:addTargetWithActionForControlEvents(startClick, CCControlEventTouchDown)			
end

--显示需要强化石的数量
function WashView:showMaterialNum()
	if (self.materialNumNode) then
		self.operatorBg:removeChild(self.materialNumNode, true)	
		self.materialNumNode = nil	
	end	
	if (self.selectedEquip == nil) then
		return
	end

	local lockPropertys = self.preview:getLockPropertys()
	local size = table.size(lockPropertys)	
	local num = G_getWashPropertyFromStaticData("useMaterialCount", self.selectedEquip:getRefId())
	if (num == nil) then
		num = -1
	else
		for i = 1, size do
			num = num * 2
		end	
	end	
	self.materialNum = num	
	
	local color 
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local bindMaterialNum ,unbindMaterialNum =	bagMgr:getBindedAndUnbindItemNumByRefId("item_qianghuashi")		
	if (bindMaterialNum+unbindMaterialNum >= num) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed1")
	end
	
	self.materialNumNode, self.materialNumKey, self.materialNumValue = G_createKeyValue(Config.Words[10100], tostring(num), color, FCOLOR("ColorYellow2"),FSIZE("Size3"), FSIZE("Size3"))
	self.operatorBg:addChild(self.materialNumNode)
	VisibleRect:relativePosition(self.materialNumNode, self.operatorBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(0, 27))
end

--显示需要金币的数量
function WashView:showGoldNum()
	if (self.goldNode) then
		self.operatorBg:removeChild(self.goldNode, true)	
		self.goldNode = nil	
	end
	if (self.selectedEquip == nil) then
		return
	end
	local lockPropertys = self.preview:getLockPropertys()
	local size = table.size(lockPropertys)	
	local num = G_getWashPropertyFromStaticData("gold", self.selectedEquip:getRefId())	
	if (num == nil) then
		num = -1
	else
		for i = 1, size do
			num = num * 2
		end	
	end	
	self.goldNum = num
	
	local color 
	if (G_checkGoldEnough(num) == true) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed1")
	end
	
	self.goldNode, self.goldKey, self.goldValue = G_createKeyValue(Config.Words[10101], tostring(num), color, FCOLOR("ColorYellow2"),FSIZE("Size3"), FSIZE("Size3"))
	self.operatorBg:addChild(self.goldNode)
	VisibleRect:relativePosition(self.goldNode, self.materialNumNode, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 5))
end	
function WashView:showMyWashInfo()
	local gold = PropertyDictionary:get_gold(g_hero:getPT())
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local bindMaterialNum,unbindMaterialNum =	bagMgr:getBindedAndUnbindItemNumByRefId("item_qianghuashi")		
	local materialNumString = string.format(" /  %s(%s) %s(%s)",tostring(bindMaterialNum),Config.Words[10211],tostring(unbindMaterialNum),Config.Words[10212])	
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
end
function WashView:startWash()
	if (self.selectedEquip == nil) then
		return
	end		
	local canStart = G_checkMaterialEnough(self.materialNum, self.isUseBindFirst)
	if canStart == E_MaterialShowBox then	
		local isUseBindFirst = function(arg,text,id)
			if id == 1 then
				return
			elseif id == 2 then
				self:doWash()
			end
		end											
		local msgBox = showMsgBox(Config.Words[10215],3)		
		msgBox:setNotify(isUseBindFirst)
		return
	elseif canStart == E_MaterialNotEnough then
		return
	end
	if (G_checkGoldEnough(self.goldNum, true) ~= true) then
		return
	end	
	self:doWash()
end	

function WashView:doWash()
	UIManager.Instance:showLoadingHUD(2)	
	local useBindState = ""
	if self.isUseBindFirst == true then
		useBindState = 1
	else
		useBindState = 0
	end
	self.lockPropertys = self.preview:getLockPropertys()	
	if (self.curEquipSource == E_EquipSource.inBag) then
		G_getForgingMgr():requestBag_Wash(self.selectedEquip, self.lockPropertys,useBindState)
	else
		G_getForgingMgr():requestBody_Wash(self.selectedEquip, self.lockPropertys,useBindState)
	end
end