	-- 背包界面（游戏主界面点击背包时进入）
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")

EquipShowView = EquipShowView or BaseClass(BaseUI) 

local const_scale = VisibleRect:SFGetScale()
local const_size_no_scale = CCSizeMake(426, 280)
local const_size = VisibleRect:getScaleSize(const_size_no_scale)
local const_scrollViewSize = CCSizeMake(const_size.width - 42 * const_scale, 171 * const_scale)
local const_bgSize = CCSizeMake(const_size.width - 42 * const_scale , 171 * const_scale)
local const_cellSize = CCSizeMake(66, 66)
local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_row 	= 2
local const_columu 	= 5
local const_pageCap = const_row * const_columu


function EquipShowView:create()
	return EquipShowView.New()
end

function EquipShowView:__init()
	self:initWithBg(const_size_no_scale, RES("squares_bg1.png"), true, false)			
	self.viewName = "EquipShowView"
	self.btns =
	{
		{name = Config.Words[10065], ttype = E_EquipSource.inBag, 	obj = nil},
		{name = Config.Words[10066], ttype = E_EquipSource.inBody, 	obj = nil},
	}				
	
	self.itemViewList = {}
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), const_bgSize)
	self:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self:getContentNode(), LAYOUT_CENTER)
	
	self:initItemGridView()
	self:initPageIndicateView()
	self:initTabView()	
	self.curEquipSource = E_EquipSource.inBag
end		

function EquipShowView:__delete()
	self.pageIndicateView:DeleteMe()
	self.itemGridView:DeleteMe()
end

function EquipShowView:onEnter(qianghuajuan)
	if (qianghuajuan and qianghuajuan ~= self.qianghuajuan) then	--如果强化卷发生了变化，则需要重新筛选装备
		self.qianghuajuan = qianghuajuan
		self:switchEquipSource(self.curEquipSource)
	else
		if self.needUpdateEquip and self.curEquipSource == E_EquipSource.inBody then
			self:switchEquipSource(E_EquipSource.inBody)
		elseif self.needUpdateItem and self.curEquipSource == E_EquipSource.inBag then
			self:switchEquipSource(E_EquipSource.inBag)
		end	
	end
	self.needUpdateEquip = false
	self.needUpdateItem = false
end

function EquipShowView:onItemUpdate()
	if (self.curEquipSource == E_EquipSource.inBag) then
		if UIManager.Instance:isShowing("EquipShowView") then
			self:switchEquipSource(E_EquipSource.inBag)
			self.needUpdateItem = false
		else
			self.needUpdateItem = true
		end
	end
end

function EquipShowView:onEquipUpdate()
	if (self.curEquipSource == E_EquipSource.inBody) then
		if UIManager.Instance:isShowing("EquipShowView") then
			self:switchEquipSource(E_EquipSource.inBody)
			self.needUpdateEquip = false
		else
			self.needUpdateEquip = true
		end
	end
end

function EquipShowView:initTabView()
	local btnArray = CCArray:create()	
	for key, value in pairs(self.btns) do
		local function createBtn(key)
			value.obj = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))
			--value.obj:setRotation(90)	
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow7"))								
			btnArray:addObject(value.obj)
			local onTabPress = function()
				if (value.ttype ~= self.curEquipSource) then
					self:switchEquipSource(value.ttype)					
				end
			end
			value.obj:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(key)
	end
	self.tagView = createTabView(btnArray, 10 * const_scale, tab_horizontal)
	self:addChild(self.tagView, 100)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_LEFT_INSIDE, ccp(10, 0))	
	VisibleRect:relativePosition(self.tagView, self.bg, LAYOUT_TOP_OUTSIDE, ccp(0, 5))	

	for key, value in pairs(self.btns) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.obj, LAYOUT_CENTER, ccp(2, -3))
	end
end

function EquipShowView:filte(equipMap)
	if (self.qianghuajuan == nil) then
		return equipMap
	end
	
	local scrollLevel = -1
	if (self.qianghuajuan) then
		local data = G_getForgingMgr():getPropertyGenerator():getStrengthenScrollPD(self.qianghuajuan:getRefId())
		if (data) then
			scrollLevel = PropertyDictionary:get_strengtheningLevel(data)						
		end
	end
	
	local tmp = {}
	for k, v in pairs(equipMap) do
		if (scrollLevel > PropertyDictionary:get_strengtheningLevel(v:getPT())) then
			table.insert(tmp, v)
		end
	end
	return tmp
end

function EquipShowView:switchEquipSource(source)
	if source == E_EquipSource.inBag then
		self.btns[1].label:setColor(FCOLOR("ColorYellow6"))
		self.btns[2].label:setColor(FCOLOR("ColorYellow7"))
	else
		self.btns[1].label:setColor(FCOLOR("ColorYellow7"))
		self.btns[2].label:setColor(FCOLOR("ColorYellow6"))
	end
					
	self.curEquipSource = source		
	if (source == E_EquipSource.inBag) then
		self.equipList = G_getBagMgr():getItemListByType(ItemType.eItemEquip)		
	else
		self.equipList = G_getEquipMgr():getEquipArray()	
	end
	
	if (self.equipList == nil) then
		return
	end
	self.equipList = self:filte(self.equipList)
	
	local size = #(self.equipList)
	local pageCount = self:getPageCountBySize(size)
	if pageCount == 0 then	--默认一个空页
		pageCount = 1
	end
			
	if pageCount ~= self.pageCount then
		self.pageIndicateView:setPageCount(pageCount, 1)
		self.pageCount = pageCount
	end
	
	local pageIndex = self.pageIndicateView:getIndex()	
	if not (pageIndex >= 1 and pageIndex <= self.pageCount) then
		pageIndex = 1
	end
	
	self.itemGridView:setItemList(self.equipList, const_cellSize, pageIndex, self.pageCount, nil)	
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.itemGridView:getRootNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 48))
end	

--关闭按钮被点击
function EquipShowView:onCloseBtnClick()
	GlobalEventSystem:Fire(GameEvent.EventHideAllScrollStrengthenView)
end

function EquipShowView:initItemGridView()	
	self.itemGridView = BatchItemGridView.New()
	--self.itemGridView = ItemGridView.New()
	self.itemGridView:setPageOption(const_row, const_columu)
	self.itemGridView:setSpacing(5, 10)	
	self.itemGridView:setTouchNotify(self, self.handleItemGridViewTouch)
	self.itemGridView:setItemList({}, const_cellSize, 1, 1, nil)
	self:addChild(self.itemGridView:getRootNode())
	VisibleRect:relativePosition(self.itemGridView:getRootNode(), self.bg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -12))
end		

-- 初始化页数指示
function EquipShowView:initPageIndicateView()
	self.pageCount = 1
	self.pageIndicateView = createPageIndicateView(1, 1) --memory
	self:addChild(self.pageIndicateView:getRootNode())	
	self.itemGridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.itemGridView:getRootNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 48))
end

function EquipShowView.handleItemGridViewTouch(self, index, item)
	if item then
		item = item:getItem()
		if item then
			local qianghuajuan = self.qianghuajuan
			local argg = {equip = item, qianghuajuan = self.qianghuajuan} 
			GlobalEventSystem:Fire(GameEvent.EventOpenStrengthenScrollPreview, E_ShowOption.eRight, argg)
			GlobalEventSystem:Fire(GameEvent.EventOpenPutInEquipView, E_ShowOption.eLeft, {itemObj = item, qianghuajuan = self.qianghuajuan })
			self:close()		
		end
	end
end		

function EquipShowView:getPageCountBySize(size)
	return math.ceil(size / const_pageCap)
end	