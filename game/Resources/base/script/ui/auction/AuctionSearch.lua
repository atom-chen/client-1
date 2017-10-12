AuctionSearch = AuctionSearch or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(176, 400)

AuctionSearchBtnType = 
{
	Type = 1,
	BodyAreaId = 2,
	Level = 3
}


function AuctionSearch:__init()	
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()

	self.searchFilter = {name = "", bodyAreaId = -1, level = -1, canUseLimit = -1, itemType = 1}
	self.btns = 
	{
		{ttype = AuctionSearchBtnType.Type, value = -1, btn = nil, label = nil, name = Config.Words[25302], 
				optionList = {
					{value = -1, name = Config.Words[25303], image = "word_Unlimit.png"}, 
					{value = 1, name = Config.Words[25304], image = "word_Equip.png"}, 
					{value = 2, name = Config.Words[25305], image = "word_Daoju.png"}
				}
		},
				
		{ttype = AuctionSearchBtnType.BodyAreaId, value = -1, btn = nil, label = nil, name = Config.Words[25306], 				
				optionList = {
					{value = -1, name = Config.Words[25303], image = "word_Unlimit.png"},
					{value = E_BodyAreaId.eWeapon, name = Config.Words[10197], image = "common_wuqi.png"},
					{value = E_BodyAreaId.eCloth, name = Config.Words[10198], image = "common_yifu.png"},
					{value = E_BodyAreaId.eHelmet, name = Config.Words[10199], image = "common_toukui.png"},
					{value = E_BodyAreaId.eBelt, name = Config.Words[10200], image = "common_yaodai.png"},
					{value = E_BodyAreaId.eShoe, name = Config.Words[10201], image = "common_xiezi.png"},
					{value = E_BodyAreaId.eNecklace, name = Config.Words[10202], image = "common_xianglian.png"},
					{value = E_BodyAreaId.eBracelet, name = Config.Words[10203], image = "common_shouzhuo.png"},	
					{value = E_BodyAreaId.eRing, name = Config.Words[10204], image = "common_jiezhi.png"},		
					{value = E_BodyAreaId.eMedal, name = Config.Words[10205], image = "common_xunzhang.png"},
--					{value = E_BodyAreaId.eMedal, name = Config.Words[10205], image = ""},
				}
		},
												
		{ttype = AuctionSearchBtnType.Level, value = -1, btn = nil, label = nil, name = Config.Words[25311], 				
				optionList = {
					{value = -1, name = Config.Words[25303], image = "word_Unlimit.png"}, 
					{value = 40, name = Config.Words[25312], image = ""}, 
					{value = 50, name = Config.Words[25313], image = ""}, 
					{value = 60, name = Config.Words[25314], image = ""}, 
					{value = 70, name = Config.Words[25315], image = ""}
				}
		},
	}
	
	self:initBg()
	self:initUI()
end

function AuctionSearch:__delete()
	self.rootNode:release()
end

function AuctionSearch:initBg()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), const_size)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
end

function AuctionSearch:initUI()
	local titleImage = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(150, 38))	
	self.rootNode:addChild(titleImage)
	VisibleRect:relativePosition(titleImage, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))	
	
	local titleText = createSpriteWithFrameName(RES("word_SearchFilter.png"))
	titleImage:addChild(titleText)	
	VisibleRect:relativePosition(titleText, titleImage, LAYOUT_CENTER)
	
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[303], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))	
	self.rootNode:addChild(nameLabel)
	VisibleRect:relativePosition(nameLabel, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(3, -60))	
	
	self.nameEditBox = createEditBoxWithSizeAndBackground(CCSizeMake(117, 43), RES("commom_editFrame.png"))	
	self.nameEditBox:setMaxLength(20)	
	self.nameEditBox:setFontSize(FSIZE("Size2"))
	self.nameEditBox:setFontColor(FCOLOR("ColorWhite1"))	
	self.rootNode:addChild(self.nameEditBox)	
	VisibleRect:relativePosition(self.nameEditBox, nameLabel, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(5, 0))		
	
	local preNode
	for k, v in ipairs(self.btns) do	
		v.btn = createButtonWithFramename(RES("rank_nomal_btn.png"))
		local btn, index = self:findBtnIndexByValue(v.ttype, v.value)
		if btn and index then
			v.label = createLabelWithStringFontSizeColorAndDimension(v.name.." "..v.optionList[index].name, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))								
			v.btn:setTitleString(v.label)
			self.rootNode:addChild(v.btn)
			VisibleRect:relativePosition(v.label, v.btn, LAYOUT_CENTER)	
			
			local onClick = function ()				
	--			print("click type="..v.ttype)
				GlobalEventSystem:Fire(GameEvent.EventOpenAuctionMenu)	
				local view = UIManager.Instance:getViewByName("AuctionMenu")
				if view then
					view:setOptionList(v.optionList, v.ttype)
				end				
			end
			v.btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
			
			if preNode == nil then
				VisibleRect:relativePosition(v.btn, nameLabel, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -20))	
			else
				VisibleRect:relativePosition(v.btn, preNode, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))	
			end
			preNode = v.btn
		end
	end	
	
	local onUseLimitClick = function()
		if self.canUseLimitBox:getSelect() then		
			self.searchFilter.canUseLimit = 1
		else
			self.searchFilter.canUseLimit = -1	 
		end
	end	
	self.canUseLimitBox = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, onUseLimitClick)
	self.rootNode:addChild(self.canUseLimitBox)
	VisibleRect:relativePosition(self.canUseLimitBox, nameLabel, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(15, -205))	
	
	local canUseLimitLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25323], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))	 
	self.rootNode:addChild(canUseLimitLabel)
	VisibleRect:relativePosition(canUseLimitLabel, self.canUseLimitBox, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(20, 0))	
	
	local searchBtn = createButtonWithFramename(RES("btn_1_select.png"))	
	local searchWord = createSpriteWithFrameName(RES("word_Search.png"))
	searchBtn:setTitleString(searchWord)
	VisibleRect:relativePosition(searchWord, searchBtn, LAYOUT_CENTER)
	self.rootNode:addChild(searchBtn)
	VisibleRect:relativePosition(searchBtn, self.canUseLimitBox, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -16))
	VisibleRect:relativePosition(searchBtn, self.rootNode, LAYOUT_CENTER_X)
	
	local onClick = function ()				
		if self.notifyFunc then
			self.notifyFunc()
		end
	end
	searchBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
end
	
function AuctionSearch:getRootNode()
	return self.rootNode
end

function AuctionSearch:setSearchParamTable(param)
	self.searchFilter = param
	self:setName(self.searchFilter.name)
	self:setBodyAreaId(self.searchFilter.bodyAreaId)
	self:setLevel(self.searchFilter.level)
	self:setCanUseLimit(self.searchFilter.canUseLimit)
	self:setType(self.searchFilter.itemType)	
end
	
function AuctionSearch:setSearchParam(name, bodyAreaId, level, canUseLimit, itemType)	
	self.searchFilter.name = param
	self.searchFilter.bodyAreaId = bodyAreaId
	self.searchFilter.level = level
	self.searchFilter.canUseLimit = canUseLimit
	self.searchFilter.itemType = itemType	
		
	self:setName(name)
	self:setBodyAreaId(bodyAreaId)
	self:setLevel(itemLevel)
	self:setCanUseLimit(canUseLimit)
	self:setType(itemType)
end	

function AuctionSearch:getSearchParam()
	self.searchFilter.name = self.nameEditBox:getText()
	return self.searchFilter		
end

function AuctionSearch:setBtnValue(ttype, value)
	local btn, index = self:findBtnIndexByValue(ttype, value)
	if btn and index then
		btn.label:setString(btn.name.." "..btn.optionList[index].name)
		btn.value = value
	end		
	if ttype == AuctionSearchBtnType.BodyAreaId then
		self:setBodyAreaId(value)
	elseif ttype == AuctionSearchBtnType.Level then
		self:setLevel(value)
	elseif ttype == AuctionSearchBtnType.Type then
		self:setType(value)	
	end
end

function AuctionSearch:setName(name)
	if type(name) == "string" then
		self.searchFilter.name = name
		self.nameEditBox:setText(name)
	end
end

function AuctionSearch:setType(itemType)
	local btn, index = self:findBtnIndexByValue(AuctionSearchBtnType.Type, itemType)
	if btn and index then
		btn.label:setString(btn.name.." "..btn.optionList[index].name)
		btn.value = itemType
		self.searchFilter.itemType = btn.optionList[index].value
	end					
end

function AuctionSearch:setBodyAreaId(bodyAreaId)
	local btn, index = self:findBtnIndexByValue(AuctionSearchBtnType.BodyAreaId, bodyAreaId)
	if btn and index then
		btn.label:setString(btn.name.." "..btn.optionList[index].name)
		btn.value = bodyAreaId
		self.searchFilter.bodyAreaId = btn.optionList[index].value
	end					
end

function AuctionSearch:setLevel(level)
	local btn, index = self:findBtnIndexByValue(AuctionSearchBtnType.Level, level)
	if btn and index then
		btn.label:setString(btn.name.." "..btn.optionList[index].name)
		btn.value = level
		self.searchFilter.level = btn.optionList[index].value
	end					
end

function AuctionSearch:setCanUseLimit(canUseLimit)
	if canUseLimit then
		self.searchFilter.canUseLimit = canUseLimit
		self.canUseLimitBox:setSelect(canUseLimit == 1)		
	end
end

function AuctionSearch:findBtnByType(btnType)
	for k, v in pairs(self.btns) do
		if v.ttype == btnType then
			return v
		end
	end
	return nil
end

function AuctionSearch:findBtnIndexByValue(btnType, value)
	local btn = self:findBtnByType(btnType)
	if btn then
		for k, v in ipairs(btn.optionList) do
			if v.value == value  then
				return btn, k
			end
		end
	end
	return nil
end

function AuctionSearch:setSearchNotify(notify)
	self.notifyFunc = notify
end		