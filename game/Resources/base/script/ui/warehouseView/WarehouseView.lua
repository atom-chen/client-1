require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.PageIndicateView")
require("ui.utils.GridView")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")
require("object.bag.ItemDetailArg")
require("utils.GameUtil")				

WarehouseView = WarehouseView or BaseClass(BaseUI)

local g_warehouseMgr = nil

local const_scale = VisibleRect:SFGetScale()
local const_cellSize = CCSizeMake(65, 65)

local const_row 	= 5
local const_columu 	= 5
local const_pageCap = const_row * const_columu
local const_hSpacing = 10
local const_vSpacing = 9
local viewSize = CCSizeMake(430,564)

function WarehouseView:__init()
	self.viewName = "WarehouseView"
	g_warehouseMgr = GameWorld.Instance:getWarehouseMgr()	
	self.tabViewList = 
	{		
		{valueType = E_warehouseContentType.Other, name = Config.Words[25704]},
		{valueType = E_warehouseContentType.Material, name = Config.Words[25703]},
		{valueType = E_warehouseContentType.Equip, name = Config.Words[25702]},
		{valueType = E_warehouseContentType.All, name = Config.Words[25701]},		
	}				
	
	self:init(viewSize)
	
	self.warehouseState = E_warehouseState.Normal
	self.selectTabView = nil
	g_warehouseMgr:requireWareHouseItemList()
	g_warehouseMgr:requireWareHouseCapacity()
	UIManager.Instance:showLoadingHUD(20)
	self:initBG()
	self:initButton()
	self:initTabView()
	self:initItemGridView()
	self:initPageIndicateView()	
	self:showCapacity()
		
end

function WarehouseView:create()
	return WarehouseView.New()
end

function WarehouseView:__delete()
	if (self.gridView) then
		self.gridView:DeleteMe()
		self.gridView = nil
	end
	
	if (self.pageIndicateView) then
		self.pageIndicateView:DeleteMe()
		self.pageIndicateView = nil
	end
end

function WarehouseView:onEnter()
	if self.warehouseState ~= E_warehouseState.Normal then
		self:setState(E_warehouseState.Normal)
	end
	
	if self.needReload or (self.selectTabView and self.selectTabView ~= E_warehouseContentType.All) then	
		self:reloadData(E_warehouseContentType.All)					
	end
	self.needReload = false		
end

function WarehouseView:setNeedReload(bReload)
	self.needReload = bReload
end

function WarehouseView:updateView()
	self:reloadData(E_warehouseContentType.All)
end

function WarehouseView:onExit()
	self:setState(E_warehouseState.Normal)
	G_getQuestLogicMgr():sendQuestActionByOpenWarehouse()
end

function WarehouseView:initBG()
	local titleImage = createSpriteWithFrameName(RES("main_bag.png"))
	self:setFormImage(titleImage)
	local titleText = createSpriteWithFrameName(RES("window_warehouse.png"))
	self:setFormTitle(titleText, TitleAlign.Left)
	
	local contentSize = self:getContentNode():getContentSize()
	local secondBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(contentSize.width, contentSize.height - 85))
	self:addChild(secondBg)
	VisibleRect:relativePosition(secondBg, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X)
	
	self.outsideFrame = createScale9SpriteWithFrameNameAndSize(RES("main_pk_lightframe.png"), CCSizeMake(contentSize.width, contentSize.height - 85))
	self:addChild(self.outsideFrame, 1)
	VisibleRect:relativePosition(self.outsideFrame, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
	self.outsideFrame:setVisible(false)
end

function WarehouseView:initButton()
	self.removeButton = createButtonWithFramename(RES("btn_1_select.png"))
	local removeText = createSpriteWithFrameName(RES("word_button_remove.png"))
	self.removeButton:setTitleString(removeText)
	self:addChild(self.removeButton)
	VisibleRect:relativePosition(self.removeButton, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE, ccp(40, 10))
	
	local removeFun = function ()
		if self.warehouseState == E_warehouseState.Normal or self.warehouseState == E_warehouseState.Storage then
			self:setState(E_warehouseState.Remove)
		else
			self:setState(E_warehouseState.Normal)
		end
	end
	
	self.removeButton:addTargetWithActionForControlEvents(removeFun, CCControlEventTouchDown)
	
	self.storageButton = createButtonWithFramename(RES("btn_1_select.png"))
	local storageText = createSpriteWithFrameName(RES("word_button_storage.png"))
	self.storageButton:setTitleString(storageText)
	self:addChild(self.storageButton)
	VisibleRect:relativePosition(self.storageButton, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-40, 10))
	
	local storageFun = function ()
		if self.warehouseState == E_warehouseState.Normal or self.warehouseState == E_warehouseState.Remove then
			self:setState(E_warehouseState.Storage)			
		else
			self:setState(E_warehouseState.Normal)
		end
	end
	
	self.storageButton:addTargetWithActionForControlEvents(storageFun, CCControlEventTouchDown)
end

function WarehouseView:setState(state)
	if self.warehouseState == state then
		return
	end
	
	self.warehouseState = state
	local bagView = UIManager.Instance:getViewByName("BagView")	
	local removeText, storageText
	
	if self.warehouseState == E_warehouseState.Normal then
		removeText = createSpriteWithFrameName(RES("word_button_remove.png"))		
		storageText = createSpriteWithFrameName(RES("word_button_storage.png"))	
		self.outsideFrame:setVisible(false)
		if bagView and bagView:getBagState() == E_BagState.Store then
			bagView:setBagState(E_BagState.Normal)
		end
	elseif self.warehouseState == E_warehouseState.Remove then
		removeText = createSpriteWithFrameName(RES("word_button_canselStorage.png"))		
		storageText = createSpriteWithFrameName(RES("word_button_storage.png"))	
		self.outsideFrame:setVisible(true)
		if bagView then
			bagView:setBagState(E_BagState.Normal)
			bagView:reloadBagContent(E_BagContentType.All)
		end
		
	elseif self.warehouseState == E_warehouseState.Storage then
		removeText = createSpriteWithFrameName(RES("word_button_remove.png"))		
		storageText = createSpriteWithFrameName(RES("word_button_canselRemove.png"))	
		self.outsideFrame:setVisible(false)
		if bagView then
			bagView:setBagState(E_BagState.Store)			
		end			
		self:reloadData(E_warehouseContentType.All)
	end
	
	if removeText and storageText then
		self.removeButton:setTitleString(removeText)
		self.storageButton:setTitleString(storageText)
	end		
end

function WarehouseView:getState()
	return self.warehouseState
end

function WarehouseView:initTabView()
	local btnArray = CCArray:create()
	local createBtn = function (key, name)
		local button = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))				
		local text = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size4"), FCOLOR("ColorWhite4"), CCSizeMake(25, 0))
		button:setTitleString(text)						
		local onTabPress = function()			
			self:pressTabView(key)
		end							
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchUpInside)
		btnArray:addObject(button)
	end
	
	for key,tabValue in pairs(self.tabViewList) do
		createBtn(tabValue.valueType, tabValue.name)
	end	
	
	self.tagView = createTabView(btnArray, 10 * const_scale, tab_vertical)
	self:addChild(self.tagView)	
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_LEFT_OUTSIDE, ccp(3, -19))	
end	

function WarehouseView:initItemGridView()	
	self.gridView = BatchItemGridView.New()	
	self.gridView:setCellSize(const_cellSize)
	self.gridView:setPageOption(const_row, const_columu)
	self.gridView:setSpacing(const_hSpacing, const_vSpacing)
	self.gridView:setTouchNotify(self, self.handleTouchItem)
	self:addChild(self.gridView:getRootNode())
	VisibleRect:relativePosition(self.gridView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -9))
end	

function WarehouseView:initPageIndicateView()
	self.pageIndicateView = createPageIndicateView(5, 1) 
	self:addChild(self.pageIndicateView:getRootNode())	
	self.gridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0,145))
end

function WarehouseView:pressTabView(key)
	if self.selectTabView ~= key then			
		self:reloadData(key)		
	end		
end

function WarehouseView:reloadData(selectTabView, keepPageIndex)	
	if selectTabView and self.selectTabView ~= selectTabView then
		self.selectTabView = selectTabView
		self:buildGridBoxData(self.selectTabView, keepPageIndex)		
		VisibleRect:relativePosition(self.gridView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -9))	
		self.tagView:setSelIndex(self.selectTabView - 1)	
	end		
end

function WarehouseView.handleTouchItem(self, index, itemView)
	if not self then
		return
	end
	
	local item = nil
	if itemView then
		item = itemView:getItem()
	end	
		
	if not item then
		if index > g_warehouseMgr:getCurCap() then
			g_warehouseMgr:requireWareHouseItemSoltUnLock() 
		end			
		return
	end
	
	if self.warehouseState == E_warehouseState.Normal or self.warehouseState == E_warehouseState.Storage then	
		--G_clickItemEvent(item)
		local arg = ItemDetailArg.New()		--显示物品详情的界面传递的参数
		arg:setItem(item)
		local btnArray = { E_ItemDetailBtnType.eGetOut}
		local  staticPt = item:getStaticData()		
		arg:setBtnArray(btnArray) --定义需要的按键	
		local itemTpye = item:getType()
		if (itemTpye == ItemType.eItemEquip) then
			btnArray = {E_ItemDetailBtnType.eDetail, E_ItemDetailBtnType.eGetOut}
			arg:setBtnArray(btnArray)
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		elseif (itemTpye == ItemType.eItemGift) then
			GlobalEventSystem:Fire(GameEvent.EventOpenGiftItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		else
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		end
			
	else		
		g_warehouseMgr:requireWareHouseItemUpdate(E_warehouseItemTouchHandleType.DeleteItemFromWarehouse, item:getGridId())	
	end			
end

function WarehouseView:onCloseBtnClick()
	GlobalEventSystem:Fire(GameEvent.EventHideBag)
	return true
end	

function WarehouseView:buildGridBoxData(selectTabView)
	local bagCurCap = g_warehouseMgr:getCurCap()
	local bagMaxCap = g_warehouseMgr:getMaxCap()
	
	local itemList = g_warehouseMgr:getItemListByContentType(selectTabView)	
	
	local getPageCountAndLockIndex = function ()
		local pageCount = 0		
		local lockCriticalIndex = nil	
		
		if selectTabView == E_BagContentType.All then		
			lockCriticalIndex = bagCurCap		
			pageCount = self:getPageCountBySize(bagMaxCap)	
		else
			pageCount = self:getPageCountBySize(#(itemList))
		end		
		if pageCount == 0 then
			pageCount = 1
		end
		return pageCount, lockCriticalIndex
	end								
	
	local pageCount, lockCriticalIndex = getPageCountAndLockIndex()
--	local totalGridCount = pageCount * const_pageCap
	
	--local pageIndex = self.pageIndicateView:getIndex()		
	if self.pageCount ~= pageCount then
		self.pageIndicateView:setPageCount(pageCount, 1)
		self.pageCount = pageCount
	end	
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0,145))
	
	self.gridView:setItemList(itemList, const_cellSize, 1, pageCount, lockCriticalIndex)			
end	

function WarehouseView:getPageCountBySize(size)
	if size then
		return math.ceil(size / const_pageCap)
	end
	return 0
end

function WarehouseView:showCapacity()
	local curCap = g_warehouseMgr:getCurCap()
	local count = g_warehouseMgr:getItemCount()
	if not self.curCapLabel then
		self.curCapLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size1"), FCOLOR("Yellow3"))
		self:addChild(self.curCapLabel)
		VisibleRect:relativePosition(self.curCapLabel, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-10, 92))
		self.curCapLabel:setAnchorPoint(ccp(1, 0.5))
	end
	
	if (count ~= nil and curCap ~= nil) then
		self.curCapLabel:setString(string.format("%d/%d", count, curCap))
	else --加载失败
		self.curCapLabel:setString(" ")
	end
end

function WarehouseView:getCurrentSelectView()
	return self.selectTabView
end

function WarehouseView:updateItem(eventType, list)
	local isContentTypeContainItemType = function (contentType, itemType)
		if contentType == E_warehouseContentType.All then
			return true	
		elseif contentType == E_warehouseContentType.Equip then
			return itemType == ItemType.eItemEquip
		elseif contentType == E_warehouseContentType.Material then
			return itemType == ItemType.eItemMaterial
		else
			return ((itemType ~= ItemType.eItemEquip) and (itemType ~= ItemType.eItemMaterial))
		end
	end
	
	local filterFunc = function(itemObj)
		return isContentTypeContainItemType(self.selectTabView, itemObj:getType()) 
	end
	
	if UIManager.Instance:isShowing("WarehouseView") then				--只有正在显示才更新
		if (not self.gridView:updateItem(eventType, list, filterFunc)) then
			self:reloadData(self:getCurrentSelectView(), true)
		else
			self.needReload = true
		end
	else
		self.needReload = true
	end
end
