require("ui.forging.StrengthenPropertyPreview")

StrengthenScrollPreview = StrengthenScrollPreview or BaseClass(StrengthenPropertyPreview)

local const_scale = VisibleRect:SFGetScale()
local const_size_no_scale = CCSizeMake(370, 244)
local const_size = VisibleRect:getScaleSize(const_size_no_scale)

function StrengthenScrollPreview:create()
	return StrengthenScrollPreview.New()
end

function StrengthenScrollPreview:__init()
	self:initWithBg(const_size_no_scale, RES("squares_bg1.png"), true, false)			
	self.viewName = "StrengthenScrollPreview"
	
	local bg = createSpriteWithFrameName(RES("forging_titleBg.png"))
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -10))	
	
	--local title = createSpriteWithFrameName(RES("forging_strengthenPreviewFont.png"))
	--self.rootNode:addChild(title)
	--VisibleRect:relativePosition(title, bg, LAYOUT_CENTER)		
	
	self:initBtn()
		
	self:setScrollViewSize(CCSizeMake(370, 113))	
	VisibleRect:relativePosition(self.scrollView, self.rootNode, LAYOUT_CENTER, ccp(0, 10))
end	

function StrengthenScrollPreview:onExit()
end

function StrengthenScrollPreview:onEnter(arg)
	if (arg) then
		self.qianghuajuan = arg.qianghuajuan
		self:inputEquip(arg.equip)
		self:showGoldNum()		
	end
end	
	
function StrengthenScrollPreview:getEquip()
	return self.equip
end

function StrengthenScrollPreview:onCloseBtnClick()
	GlobalEventSystem:Fire(GameEvent.EventHideAllScrollStrengthenView)
end

function StrengthenScrollPreview:inputEquip(equip)
	if not equip then
		return
	end
	self.equip = equip
	
	if (self.qianghuajuan) then
		local data = G_getForgingMgr():getPropertyGenerator():getStrengthenScrollPD(self.qianghuajuan:getRefId())
		if (data) then
			local level = PropertyDictionary:get_strengtheningLevel(data)						
			self:setStep(level - PropertyDictionary:get_strengtheningLevel(equip:getPT()))
		end
	end
	self:setEquip(equip)
end

function StrengthenScrollPreview:__delete()
end	

function StrengthenScrollPreview:startStrengthen()
	
	if (G_checkGoldEnough(self.goldNum, true) == false) then
		return
	end	
	
	UIManager.Instance:showLoadingHUD(2)	
	if (self.equip:getSource() == E_EquipSource.inBag) then
		G_getForgingMgr():requestBag_StrengScroll(self.equip, self.qianghuajuan:getGridId())
	else
		G_getForgingMgr():requestBody_StrengScroll(self.equip, self.qianghuajuan:getGridId())
	end
end

function StrengthenScrollPreview:initBtn()
	self.startBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local startText = createSpriteWithFrameName(RES("word_button_strengthen.png"))
	self.rootNode:addChild(self.startBtn)
	self.rootNode:addChild(startText)		
	
	VisibleRect:relativePosition(self.startBtn, self.rootNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-10, 10))
	VisibleRect:relativePosition(startText, self.startBtn, LAYOUT_CENTER)
	local startClick = function()	
		--self:startStrengthen()
		self:checkBindForStrengthen()
	end
	self.startBtn:addTargetWithActionForControlEvents(startClick, CCControlEventTouchDown)			
end	
function StrengthenScrollPreview:checkBindForStrengthen()
	if (self.equip == nil or self.qianghuajuan == nil) then
		return
	end
	local equipBindStatus = PropertyDictionary:get_bindStatus(self.equip:getPT())
	local qianghuajuanBindStatus = PropertyDictionary:get_bindStatus(self.qianghuajuan:getPT())
	local tips = ""
	if (equipBindStatus == E_State_Bind and qianghuajuanBindStatus == E_State_Bind) or 
		(equipBindStatus == E_State_UnBind and qianghuajuanBindStatus == E_State_UnBind) then		
		self.isUseBindFirst = true
		self:startStrengthen()
	elseif equipBindStatus == E_State_Bind and qianghuajuanBindStatus == E_State_UnBind then
		tips = Config.Words[10220]
		self:showStrengMsgBox(tips)
	elseif equipBindStatus == E_State_UnBind and qianghuajuanBindStatus == E_State_Bind then
		tips = Config.Words[10219]
		self:showStrengMsgBox(tips)
	end			
end

function StrengthenPropertyPreview:showStrengMsgBox(tips)
	local isUseBindFirst = function(arg,text,id)
		if id == 1 then
			return
		elseif id == 2 then
			self:startStrengthen()
		end
	end											
	local msgBox = showMsgBox(tips,3)		
	msgBox:setNotify(isUseBindFirst)
end
--显示需要金币的数量
function StrengthenScrollPreview:showGoldNum()
	if (self.goldNode) then
		self.rootNode:removeChild(self.goldNode, true)
	end	
	
	local num = -1 
	if (self.qianghuajuan) then
		local data = G_getForgingMgr():getPropertyGenerator():getStrengthenScrollPD(self.qianghuajuan:getRefId())
		if (data) then
			num = PropertyDictionary:get_gold(data)
		end
	end
	
	self.goldNum = num
	local color 
	if (G_checkGoldEnough(num, true) == true) then
		color = FCOLOR("ColorGreen1")
	else
		color = FCOLOR("ColorRed2")
	end

	self.goldNode, self.goldKey, self.goldValue = G_createKeyValue(Config.Words[10101], tostring(num), color, nil)
	self.rootNode:addChild(self.goldNode)
	VisibleRect:relativePosition(self.goldNode, self.startBtn, LAYOUT_CENTER_Y, ccp(0, 0))
	VisibleRect:relativePosition(self.goldNode, self.rootNode, LAYOUT_LEFT_INSIDE, ccp(15, 0))		
end	