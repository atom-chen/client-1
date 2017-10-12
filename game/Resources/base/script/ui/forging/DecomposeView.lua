require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.forging.BaseForgingSubView")
require("ui.forging.StrengthenPropertyPreview")
require("ui.utils.ScrollChoiceBar")
require("data.item.propsItem")
	
DecomposeView = DecomposeView or BaseClass(BaseForgingSubView)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local const_row 	= 3
local const_columu 	= 4
local const_pageCap = const_row * const_columu
local const_cellSize = CCSizeMake(85, 85)

function DecomposeView:__init()
	self.equipGridList = {}
	self.btnType = "selectAll"
	self.pageCount = 0
	
	self:initBg()
	self:initBtn()
	self:initItemGridView()
	self:initPageIndicateView()
	self:showSwitchBtn(false)	
	
	self.curEquipSource = E_EquipSource.inBag
	self:switchEquipSource(self.curEquipSource)	
	self.needHandleUpdateEvent = false
end

function DecomposeView:__delete()
	self.itemGridView:DeleteMe()
end	

function DecomposeView:setRet(ret)
	UIManager.Instance:hideLoadingHUD()
	
	if (self.curEquipSource == E_EquipSource.inBag) then 	--得到分解结果后再更新
		self:switchEquipSource(E_EquipSource.inBag)
	else
		self:switchEquipSource(E_EquipSource.inBody)
	end
	--[[local des = Config.Words[10118].."+"..ret.totalGold..", "..Config.Words[10121].."+"..ret.exp..", "
		
	if (ret.itemKindCount > 0) then
		des = des..Config.Words[10119]
	end
	
	local itemName = {}
	for k, v in pairs(ret.items) do
		local refIdx = v.refId
		local data = GameData.PropsItem[v.refId].property
		local name = "unkown-item"
		if (data) then
			name = PropertyDictionary:get_name(data)
		end
		des = des..name..v.number..Config.Words[10122]..", "
	end
	
	des = string.sub(des, 1, string.len(des) - 2)	
	if (ret.itemKindCount > 2) then
		des = des..Config.Words[10120]
	end
	UIManager.Instance:showSystemTips(des, nil, nil, nil, 5)
	UIManager.Instance:hideLoadingHUD()
	
	if (self.curEquipSource == E_EquipSource.inBag) then 	--得到分解结果后再更新
		self:switchEquipSource(E_EquipSource.inBag)
	else
		self:switchEquipSource(E_EquipSource.inBody)
	end--]]
end	

function DecomposeView:onEquipSelected(index, equipObj, selected)
	if (equipObj == nil) then
		return
	end
	if (selected == true) then
		self:addEquip(equipObj)
	else
		self:removeEquip(equipObj)
	end
end

function DecomposeView:initBg()
	self.previewBg:setPreferredSize(CCSizeMake(const_forgingPreviewSize.width, 289 * const_scale))	
	VisibleRect:relativePosition(self.previewBg, self.equipSimpleListView:getRootNode(), LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_OUTSIDE, ccp(15, 0))
	
	self.tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[10111], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow2"))
	self.rootNode:addChild(self.tips)
	VisibleRect:relativePosition(self.tips, self.operatorBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -55))	
	
	local btn = createButtonWithFramename(RES("tab_2_select.png"))	
	local text = createLabelWithStringFontSizeColorAndDimension(Config.Words[554], "Arial", FSIZE("Size3") * const_scale, FCOLOR("ColorYellow6"), CCSizeMake(20*const_scale,0))									
	self.rootNode:addChild(btn)
	self.rootNode:addChild(text)
	VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_LEFT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(5, -10))	
	VisibleRect:relativePosition(text, btn, LAYOUT_CENTER, ccp(2, -3)) 
	btn:setScale(1.1)
end	

function DecomposeView:initItemGridView()	
	self.itemGridView = ItemGridView.New()
	self.itemGridView:setPageOption(const_row, const_columu)
	self.itemGridView:setSpacing(3, 3)	
	self.itemGridView:setTouchNotify(self, self.handleItemGridViewTouch)
	self.itemGridView:setItemList({}, const_cellSize, 1, 1, nil)	
	
	self.rootNode:addChild(self.itemGridView:getRootNode())
	VisibleRect:relativePosition(self.itemGridView:getRootNode(), self.previewBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -8))
end	

--
function DecomposeView:isPageCountChanged(size)
	local pageCount = math.ceil(size / const_pageCap) 	
	local ret = (pageCount ~= self.pageCount)
	self.pageCount = pageCount
	return ret
end

function DecomposeView:findEquip(equipObj)
	for k, v in pairs(self.equipGridList) do
		if (v == equipObj) then
			return k, v
		end
	end
	return nil
end

function DecomposeView:addEquip(equipObj)
	local index, obj = self:findEquip(equipObj)
	if index then
		return
	end
	
	table.insert(self.equipGridList, equipObj)
	if self:isPageCountChanged(#(self.equipGridList)) then
		self:reloadGridView()		
	else
		self.itemGridView:addOneItem(equipObj)
		self:updateBtnType()
	end
end

function DecomposeView:removeEquip(equipObj)
	local index, obj = self:findEquip(equipObj)
	if index then
		table.remove(self.equipGridList, index)
		if self:isPageCountChanged(#(self.equipGridList)) then
			self:reloadGridView()		
		else
			self.itemGridView:removeOneItem(equipObj)
			self:updateBtnType()
		end
	end
end	

function DecomposeView:subOnExit()
	self:unselectAll()
end
	
function DecomposeView:subOnEnter()
	if self.needUpdateItem then	
		self:switchEquipSource(E_EquipSource.inBag)
		self.needUpdateItem = false
	else
		self.equipSimpleListView:unSelectAll(true)	
	end
end

-- 初始化页数指示
function DecomposeView:initPageIndicateView()
	self.pageCount = 1
	self.pageIndicateView = createPageIndicateView(1, 1) 
	self.rootNode:addChild(self.pageIndicateView:getRootNode())	
	self.itemGridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.itemGridView:getRootNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 48))
end

function DecomposeView.handleItemGridViewTouch(self, index, itemView)
	if itemView then
		local equipObj =  itemView:getItem()
		if equipObj then
			self:removeEquip(equipObj)	
			self.equipSimpleListView:selectByEquipId(equipObj:getId(), false, false, false)		
		end
	end
end		

--切换背包和身上的装备
function DecomposeView:onSwitchEquipSource()
--[[	
	if (#(self.equipList) > 0) then
		self.tips:setString(Config.Words[10111])
	else
		self.tips:setString(Config.Words[10112])
	end
	VisibleRect:relativePosition(self.tips, self.operatorBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -55))	
--]]	
end

function DecomposeView:setBtnType(ttype)
	if self.btnType == ttype then
		return
	end
	if ttype == "selectAll" then
		self.smartSelectText:setString(Config.Words[10106])		
	else
		self.smartSelectText:setString(Config.Words[10154])		
	end
	self.btnType = ttype
end

function DecomposeView:initBtn()
	local smartSelectBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.smartSelectText = createLabelWithStringFontSizeColorAndDimension(Config.Words [10106], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
	self.rootNode:addChild(smartSelectBtn)
	self.rootNode:addChild(self.smartSelectText)		
	
	VisibleRect:relativePosition(smartSelectBtn, self.operatorBg, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(52, 50))
	VisibleRect:relativePosition(self.smartSelectText, smartSelectBtn, LAYOUT_CENTER)	
	local smartSelectClick = function()	
		if self.btnType == "selectAll" then
			self:selectAll()
		else
			self:unselectAll()
		end
	end
	smartSelectBtn:addTargetWithActionForControlEvents(smartSelectClick, CCControlEventTouchDown)
	
	self.startBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local startText = createLabelWithStringFontSizeColorAndDimension(Config.Words [10107], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
	self.rootNode:addChild(self.startBtn)
	self.rootNode:addChild(startText)		
	
	VisibleRect:relativePosition(self.startBtn, smartSelectBtn, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(103, 0))
	VisibleRect:relativePosition(startText, self.startBtn, LAYOUT_CENTER)
	
	local startClick = function()	
		self:startDecompose()
	end
	self.startBtn:addTargetWithActionForControlEvents(startClick, CCControlEventTouchDown)					
end

function DecomposeView:updateBtnType()
	local selectedCount = #(self.equipGridList)	
	local totalCount = #(self.equipList)
	if selectedCount >= totalCount and selectedCount>0 and totalCount > 0 then
		self:setBtnType("unselectAll")
	else
		self:setBtnType("selectAll")
	end	
end

function DecomposeView:reloadGridView()
	self.pageCount = math.ceil(#(self.equipGridList) / const_pageCap)
	self:updateBtnType()
	if self.pageCount == 0 then	--如果没有选中，则默认显示一个空页
		self.pageCount = 1
	end
	local totalGridCount = self.pageCount * const_pageCap
	
	local pageIndex = self.pageIndicateView:getIndex()	
	if not (pageIndex >= 1 and pageIndex <= self.pageCount) then
		pageIndex = self.pageCount
	end		
	self.pageIndicateView:setPageCount(self.pageCount, 1)
	self.itemGridView:setItemList(self.equipGridList, const_cellSize, 1, self.pageCount, nil)		
	VisibleRect:relativePosition(self.itemGridView:getRootNode(), self.previewBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -8))
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.itemGridView:getRootNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 48))
end

--选择所有品质为白色并且没有强化过的物品
function DecomposeView:selectAll()
	self.equipSimpleListView:selectAll()	
	self.equipGridList = table.cp(self.equipList)
	self:reloadGridView(self.equipGridList)
end		

function DecomposeView:unselectAll()
	self.equipSimpleListView:unSelectAll()
	self.equipGridList = {}
	self:reloadGridView()
end

function DecomposeView:startDecompose()
	local itemList = self.equipGridList
	if (table.isEmpty(itemList)) then
		return 
	end		
	UIManager.Instance:showLoadingHUD(3)
	if (self.curEquipSource == E_EquipSource.inBag) then
		G_getForgingMgr():requestBag_Decompose(itemList)
	else
		G_getForgingMgr():requestBody_Decompose(itemList)
	end	
	self:unselectAll()
end