-- 背包界面（游戏主界面点击背包时进入）
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.PageIndicateView")
require("ui.utils.ItemView")
require("ui.utils.GridView")
require("GameDef")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")
require("object.bag.ItemDetailArg")

BagView = BagView or BaseClass(BaseUI) 	--BagView继承与BaseUI
local g_bagMgr = nil
local g_hero = nil

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_cellSize = CCSizeMake(65, 65)

local const_row 	= 5
local const_columu 	= 5
local const_pageCap = const_row * const_columu
local const_hSpacing = 10
local const_vSpacing = 9

function BagView:create()
	return BagView.New()
end

function BagView:__init()	
	self.contentTypes =
	{	
		[E_BagContentType.Other] 	= { name = Config.Words[10003], btn = nil	},
		[E_BagContentType.Drug] 	= {name = Config.Words[10002], 	btn = nil},
		[E_BagContentType.Equip] 	= {name = Config.Words[10001], 	btn = nil},
		[E_BagContentType.All] 		= {name = Config.Words[10000], 	btn = nil},
	}
	
	self.onSaleItemList = {}	--存放正在出售的物品列表（已经从背包UI上移动到了 BatchSellView 里面）	
	self.curContentType = nil   --记录当前背包显示内容的类型
	g_bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()		
	g_hero = GameWorld.Instance:getEntityManager():getHero()
	
	self.viewName = "BagView"
	self.bagState = E_BagState.Normal
	self.viewSize = CCSizeMake(430,564)
	self:init(self.viewSize)
	
	self:initTitleAndBg()
	self:initTabView()
	self:initItemGridView()	
	self:initPageIndicateView()
	self:showCapacity()
	self:showMoney()		
	self:initBtn()	
end

function BagView:onExit()
	if self.needReload then
		self:reloadBagContent(self:getCurContentType())
		self.needReload = false
	else			
		self.gridView:setPageIndex(1)
	end
	self:setBagState(E_BagState.Normal)
	local view = UIManager.Instance:getViewByName("BatchSellView")
	if view then
		view:clear(true)
		view:close()
	end
	
	GlobalEventSystem:Fire(GameEvent.EventCloseWarehouseView)
end

function BagView:onEnter(param)
	local contentType
	if param then
		contentType = param.contentType			
	end
	if contentType == nil then
		contentType = E_BagContentType.All
	end
	if (self.needReload or (contentType >= E_BagContentType.Other 
		and contentType <= E_BagContentType.All 
		and contentType ~= self.curContentType)) then
		self:reloadBagContent(contentType)
		self.tagView:setSelIndex(contentType - 1)			
	end
	self.needReload = false	
	
	GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesUseLevelReward()--使用等级礼包
end	

function BagView:setNeedReload(bReload)
	self.needReload = bReload
end

function BagView:__delete()
	if (self.gridView) then
		self.gridView:DeleteMe()
		self.gridView = nil
	end
	
	if (self.pageIndicateView) then
		self.pageIndicateView:DeleteMe()
		self.pageIndicateView = nil
	end
end

function BagView:initTitleAndBg()
	local titleImage = createSpriteWithFrameName(RES("main_bag.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_bag.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)	
	self.bgNode = CCNode:create()
	self.bgNode:setContentSize(CCSizeMake(self.viewSize.width , self.viewSize.height-48))
	self.bgNormal = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(392,406))				
	self.bgBottom = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(392,85))	
	self:addChild(self.bgNode)
	VisibleRect:relativePosition(self.bgNode, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0,  0))		
	self:addChild(self.bgNormal)
	self:addChild(self.bgBottom)
	VisibleRect:relativePosition(self.bgNormal, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.bgBottom, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(0,0))
	
	self.outsideFrame = createScale9SpriteWithFrameNameAndSize(RES("main_pk_lightframe.png"), CCSizeMake(392,406))
	self:addChild(self.outsideFrame, 1)
	VisibleRect:relativePosition(self.outsideFrame, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE)
	self.outsideFrame:setVisible(false)
end

-- 显示TabView
function BagView:initTabView()
	local btnArray = CCArray:create()	
	for key,value in ipairs(self.contentTypes) do
		local function createBtn(key)
			value.btn = createButtonWithFramename(RES("tab_2_normal.png"),RES("tab_2_select.png"))	
			value.btn:setRotation(180)		
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("Yellow2"),CCSizeMake(22*const_scale,0))											
			btnArray:addObject(value.btn)
			local onTabPress = function()	
--				self:debug()		
				if key ~= self.curContentType then
					self:reloadBagContent(key)						
				end
			end
			value.btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(key)
	end
	self.tagView = createTabView(btnArray, 10 * const_scale, tab_vertical)
	self:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE, ccp(3, -19))	

	for key,value in pairs(self.contentTypes) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.btn, LAYOUT_CENTER)
	end
end

--getItemMapExceptTypes
function BagView:getItemMapByContentType(contentType)
	local filterFunc
	if self.bagState == E_BagState.BatchSell then
		filterFunc = function(item)		
			if self.onSaleItemList[item:getId()] then --如果是正在批量出售，则不再显示处于出售中的商品 	
				return false
			end
			return self:checkCanSell(item)
		end
	end
	local itemMap	
	if contentType == E_BagContentType.All then
		itemMap = g_bagMgr:getItemMap(filterFunc)	
	elseif contentType == E_BagContentType.Equip then
		itemMap = g_bagMgr:getItemMapByType(ItemType.eItemEquip, filterFunc)	
	elseif contentType == E_BagContentType.Drug then
		itemMap = g_bagMgr:getItemMapByType(ItemType.eItemDrug, filterFunc)	
	else
		itemMap = g_bagMgr:getItemMapExceptTypes({[1] = ItemType.eItemDrug, [2] = ItemType.eItemEquip}, filterFunc)	
	end
		
	return itemMap
end

function BagView:isContentTypeContainItemType(contentType, itemType)
	if contentType == E_BagContentType.All then
		return true	
	elseif contentType == E_BagContentType.Equip then
		return itemType == ItemType.eItemEquip
	elseif contentType == E_BagContentType.Drug then
		return itemType == ItemType.eItemDrug
	else
		return ((itemType ~= ItemType.eItemEquip) and (itemType ~= ItemType.eItemDrug))
	end
end

function BagView:getCurContentType()
	return self.curContentType
end

function BagView:reloadBagContent(ttype, keepPageIndex, delay)
	local removeSchId = function()
		if self.delayReloadSchId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayReloadSchId)
			self.delayReloadSchId = nil
		end
	end
	removeSchId()
	if type(delay) ~= "number" or delay == 0 then
		self:doReloadBagContent(ttype, keepPageIndex)
	else
		local onTimeout = function()
			self:doReloadBagContent(ttype, keepPageIndex)
			removeSchId()
		end
		self.delayReloadSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, delay, false);			
	end
end

function BagView:doReloadBagContent(ttype, keepPageIndex)
	if ttype == nil then
		ttype = self.curContentType
	end		
	
	if ttype ~= self.curContentType then	
		if self.curContentType then
			self.contentTypes[self.curContentType].label:setColor(FCOLOR("Yellow2")) 
			self.contentTypes[self.curContentType].btn:setSelected(false)
		end
		self.contentTypes[ttype].btn:setSelected(true)
		self.contentTypes[ttype].label:setColor(FCOLOR("White1")) 
	end				
	self:updateGridView(ttype, keepPageIndex)		
	VisibleRect:relativePosition(self.gridView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -9))
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(),self.bgNormal, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 60))
	self.tagView:setSelIndex(ttype - 1)
end	

function BagView:updateItem(eventType, map)
	if UIManager.Instance:isShowing("BagView")  then				--只有正在显示才更新
		if (not self.gridView:updateItem(eventType, map)) then
			self:reloadBagContent(self:getCurContentType(), true)
		else
			self.needReload = true
		end
	else
		self.needReload = true
	end
end

function BagView:updateFpTips()
	self.gridView:updateFpTips()		
end		

function BagView:updateGridView(contentType, keepPageIndex)
	local bagCurCap = g_bagMgr:getCurCap()
	local bagMaxCap = g_bagMgr:getMaxCap()
	
	local itemList = self:getItemMapByContentType(contentType)
	if (itemList == nil) then
		itemList = {}
	end	
	
	local pageCount = 0
	local totalGridCount
	local lockCriticalIndex
	if contentType == E_BagContentType.All then		
		lockCriticalIndex = bagCurCap		
		pageCount = self:getPageCountBySize(bagMaxCap)	
	else
		pageCount = self:getPageCountBySize(#(itemList))
	end		
	if pageCount == 0 then
		pageCount = 1
	end
	
	self.curContentType = contentType
	totalGridCount = pageCount * const_pageCap
	
	local pageIndex = self.pageIndicateView:getIndex()		
	if self.pageCount ~= pageCount then
		self.pageIndicateView:setPageCount(pageCount, 1)
		self.pageCount = pageCount
	end	
	self:updateFilterFunc()
	if keepPageIndex then
		self.gridView:setItemList(itemList, const_cellSize, 1, pageCount, lockCriticalIndex)		
	else
		self.gridView:setItemList(itemList, const_cellSize, 1, pageCount, lockCriticalIndex)		
	end
end	

function BagView:getPageCountBySize(size)
	if size then
		return math.ceil(size / const_pageCap)
	end
		return 0
end

function BagView:initItemGridView()	
	self.gridView = BatchItemGridView.New()
--	self.gridView = ItemGridView.New()
	self.gridView:setCellSize(const_cellSize)
	self.gridView:setPageOption(const_row, const_columu)
	self.gridView:setSpacing(const_hSpacing, const_vSpacing)
	self.gridView:setTouchNotify(self, self.handleTouchItem)
	self:addChild(self.gridView:getRootNode())
	VisibleRect:relativePosition(self.gridView:getRootNode(), self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -9))
end	

-- 显示背包容量
function BagView:showCapacity()
	local count = g_bagMgr:getItemCount()
	local curCap = g_bagMgr:getCurCap()
		
	if self.itemCount == count and self.curCap == curCap then
		return
	end
	self.itemCount = count
	self.curCap = curCap
	
	if (self.capacityLabel == nil) then
		self.capacityLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size1") * const_scale, FCOLOR("Yellow3"))		
		self:addChild(self.capacityLabel)
	end
	if (count ~= nil and curCap ~= nil) then
		self.capacityLabel:setString(string.format("%d/%d", count, curCap))
	else --加载失败
		self.capacityLabel:setString(" ")
	end
	VisibleRect:relativePosition(self.capacityLabel, self.bgNormal, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-10, 3))
end

-- 初始化页数指示
function BagView:initPageIndicateView()
	self.pageIndicateView = createPageIndicateView(5, 1) 
	self:addChild(self.pageIndicateView:getRootNode())	
	self.gridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.bgNormal, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0,60))
end

-- 显示金币（图标，标题，背景，数量）
function BagView:showMoney(pt)
	if (self.unbindedGoldLabel == nil) then
		local unbindedGoldIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))
		--unbindedGoldIcon:setScale(0.3)
		local bindedGoldIcon = createSpriteWithFrameName(RES("common_iocnBindWind.png"))		
		--bindedGoldIcon:setScale(0.3)
		local goldIcon = createSpriteWithFrameName(RES("common_iocnGold.png"))
		--goldIcon:setScale(0.3)
		self:addChild(unbindedGoldIcon)
		self:addChild(bindedGoldIcon)
		self:addChild(goldIcon)
		VisibleRect:relativePosition(unbindedGoldIcon,self.bgBottom, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(12, -10))
		VisibleRect:relativePosition(bindedGoldIcon, unbindedGoldIcon, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
		VisibleRect:relativePosition(goldIcon, bindedGoldIcon, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
									
		self.unbindedGoldBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"), VisibleRect:getScaleSize(CCSizeMake(110, 24)))
		self.bindedGoldBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"), VisibleRect:getScaleSize(CCSizeMake(110, 24)))
		self.goldBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"), VisibleRect:getScaleSize(CCSizeMake(110, 24)))		
		self:addChild(self.unbindedGoldBg)
		self:addChild(self.bindedGoldBg)
		self:addChild(self.goldBg)
		VisibleRect:relativePosition(self.unbindedGoldBg, unbindedGoldIcon, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(12, 0))
		VisibleRect:relativePosition(self.bindedGoldBg, bindedGoldIcon, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(12, 0))
		VisibleRect:relativePosition(self.goldBg, goldIcon, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(12, 0))
						
		self.unbindedGoldLabel = createLabelWithStringFontSizeColorAndDimension("88", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))
		self.bindedGoldLabel = createLabelWithStringFontSizeColorAndDimension("88","Arial",FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))
		self.goldLabel = createLabelWithStringFontSizeColorAndDimension("88", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))		
		self:addChild(self.unbindedGoldLabel)
		self:addChild(self.bindedGoldLabel)
		self:addChild(self.goldLabel)			
	end
	
	local unbindedGold 	= -1
	local bindedGold  	= -1  
	local gold   		= -1
	if pt then
		if pt["unbindedGold"] then
			unbindedGold = PropertyDictionary:get_unbindedGold(pt)
		end
		if pt["bindedGold"] then
			bindedGold = PropertyDictionary:get_bindedGold(pt)
		end
		if pt["gold"] then
			gold = PropertyDictionary:get_gold(pt)
		end
	else
		unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
		bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	    
		gold   			= PropertyDictionary:get_gold(g_hero:getPT())
	end	
	
	if (unbindedGold >= 0) and self.unbindedGoldLabel then
		self.unbindedGoldLabel:setString(tostring(unbindedGold))
		VisibleRect:relativePosition(self.unbindedGoldLabel, self.unbindedGoldBg, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(5, 0))
	end		
	if (bindedGold >= 0) and self.bindedGoldLabel then
		self.bindedGoldLabel:setString(tostring(bindedGold))
		VisibleRect:relativePosition(self.bindedGoldLabel, self.bindedGoldBg, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(5, 0))
	end		
	if (gold >= 0) and self.goldLabel then
		self.goldLabel:setString(tostring(gold))
		VisibleRect:relativePosition(self.goldLabel, self.goldBg, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(5, 0))
	end		
end

-- 注意：gridBoxIndex 是该物品在gridbox里面的位置索引，并不是该物品的gridId。
-- 物品的gridId是用于跟服务通信时的id
function BagView.handleTouchItem(self, index, itemView)
	local item
	if itemView then
		item = itemView:getItem()
	end
	
	if item then
		local refId = item:getRefId()
		self:clickItem(refId)
	end
	
	if self.bagState == E_BagState.Normal then	--处于正常状态，弹tips
		if index <= g_bagMgr:getCurCap() then		
			if item and itemView:isContentVisible() then
				self:showItemTips(item)
			end
		elseif index > g_bagMgr:getCurCap() then 
			g_bagMgr:requestUnLockSlot(index)	--解锁格子
		end
	elseif self.bagState == E_BagState.BatchSell then	--处于批量出售状态
		if item and itemView:isContentVisible() then
			self:moveItemToSale(item)
		end
	elseif self.bagState == E_BagState.Store then	--处于存储状态
		local warehouseMgr = GameWorld.Instance:getWarehouseMgr()
		if item then
			warehouseMgr:requireWareHouseItemUpdate(E_warehouseItemTouchHandleType.AddItemToWarehouse, item:getGridId())
		end			
	end		
end	

function BagView:showItemTips(item)
	if not item then
		return
	end
	local arg = ItemDetailArg.New()		--显示物品详情的界面传递的参数
	arg:setItem(item)

	local itemTpye = item:getType()
	if (itemTpye == ItemType.eItemEquip) then	--点击的物品时装备
		local btnArray
		if PropertyDictionary:get_isCanSale(item:getStaticData().property) ~= 1	then
			btnArray = {E_ItemDetailBtnType.eShow,E_ItemDetailBtnType.eDetail,E_ItemDetailBtnType.ePutOn}
		else
			btnArray = {E_ItemDetailBtnType.eSell, E_ItemDetailBtnType.eShow,E_ItemDetailBtnType.ePutOn,  E_ItemDetailBtnType.eDetail}
		end
		arg:setBtnArray(btnArray) --定义需要的按键	
		local minFpEquip = self:getMinFpEquipInPutOnEquipList(item)	--从身上装备获取战力最低的装备
		if (minFpEquip == nil) then	--获取失败，则不需要对比						
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		else
			arg:setTitleTips(Config.Words[10006])
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMove2Right, arg) --进入详情
			
			local arg1 = ItemDetailArg.New()	
			arg1:setTitleTips(Config.Words[10007])
			arg1:setItem(minFpEquip)
			arg1:setBtnArray({})	
			arg1:setViewName("PutOnEquipItemDetailView")
			arg1:setIsShowCloseBtn(false)
			arg1:setIsShowFpTips(false)								
			GlobalEventSystem:Fire(GameEvent.EventOpenPutOnEquipItemDetailView, E_ShowOption.eMove2Left, arg1) --进入详情					
		end
	elseif (itemTpye == ItemType.eItemGift) then
		local btnArray = { E_ItemDetailBtnType.eSell, E_ItemDetailBtnType.eUse}
		local  staticPt = item:getStaticData()
		local isCanSell = PropertyDictionary:get_isCanSale(staticPt.property)
		if isCanSell ~= 1	then
			btnArray = {E_ItemDetailBtnType.eUse}
		end
		arg:setBtnArray(btnArray) --定义需要的按键	
		GlobalEventSystem:Fire(GameEvent.EventOpenGiftItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
	else
		local btnArray
		local  staticPt = item:getStaticData()
		local isCanSell = PropertyDictionary:get_isCanSale(staticPt.property)
		local isCanUse = PropertyDictionary:get_canUse(staticPt.property)		
		if isCanSell ~= 1 then
			if isCanUse ~= 1 then
				btnArray = {E_ItemDetailBtnType.eShow}
			else
				btnArray = {E_ItemDetailBtnType.eShow,E_ItemDetailBtnType.eUse}					
			end
		else					
			if isCanUse ~= 1 then
				btnArray = {E_ItemDetailBtnType.eSell,E_ItemDetailBtnType.eShow}
			else
				btnArray = {E_ItemDetailBtnType.eSell,E_ItemDetailBtnType.eShow, E_ItemDetailBtnType.eUse}
			end
		end					

		arg:setBtnArray(btnArray) --定义需要的按键	
		arg:setShowPriceType(E_EquipShowPriceType.sellPrice)							
		GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
	end		
end

--将物品移动到批出售界面
function BagView:moveItemToSale(item)
	if not item then
		return
	end
	local view = UIManager.Instance:getViewByName("BatchSellView")
	if view then
		view:addItem(item)	--将该物品传递给BatchSellView
	end
	self:updateItem(E_UpdataEvent.Delete, {[1] = item})	--从背包中删除
	
	if self.onSaleItemList[item:getId()] then
		print("BagView:moveItemToSale Warning. Duplicated id")
	end
	self.onSaleItemList[item:getId()] = item			--放到这里
end

function BagView:moveItemBackFromSale(item)
	self:updateItem(E_UpdataEvent.Add, {[1] = item})	--添加到背包里
	self.onSaleItemList[item:getId()] = nil
end	

function BagView:clearOnSaleItemList()
	self.onSaleItemList = {}
end

function BagView:getMinFpEquipInPutOnEquipList(equipObj)
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()	
	if not equipMgr:isBodyAreaFull(PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property)) then
		return nil
	end
	local list = equipMgr:getEquipListByBodyAreaId(PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property))	
	return equipMgr:getMinFpEquipObj(list)
end	

function BagView:checkCanSell(item)
	return PropertyDictionary:get_isCanSale(item:getStaticData().property) == 1
end

function BagView:getBagState()
	return self.bagState
end

function BagView:setBagState(state)
	if self.bagState == state then
		return
	end
	self.bagState = state
	self:clearOnSaleItemList()
	
	--显示或隐藏不能出售/分解的物品
	local showUnsalableCItem = function(bShow)
		local itemViewCache = self.gridView:getUsingItemViews()
		for k, v in pairs(itemViewCache) do		
			if v:getItem() and (not self:checkCanSell(v:getItem())) then
				v:showContent(bShow)
			end
		end
	end		
	if state == E_BagState.Normal then		
		self.batchSellBtn:setTitleString(createSpriteWithFrameName(RES("Bulk_sale.png")))
		showUnsalableCItem(true)
		self.outsideFrame:setVisible(false)
	elseif state == E_BagState.BatchSell then
		self.batchSellBtn:setTitleString(createSpriteWithFrameName(RES("cancel_sale.png")))
		showUnsalableCItem(false)	
		self.outsideFrame:setVisible(false)
	else
		local BatchSellText = createSpriteWithFrameName(RES("Bulk_sale.png"))
		self.batchSellBtn:setTitleString(createSpriteWithFrameName(RES("Bulk_sale.png")))
		showUnsalableCItem(true)
		self.outsideFrame:setVisible(true)
	end			
end

function BagView:debug()
	self.gridView:debug()
end

function BagView:initBtn()
	self.batchSellBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
	self.batchSellBtn:setTitleString(createSpriteWithFrameName(RES("Bulk_sale.png")))
	self:addChild(self.batchSellBtn)
	
	VisibleRect:relativePosition(self.batchSellBtn, self:getContentNode(), LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-18, 8))	
	local onClick = function()		
		if self.bagState == E_BagState.Normal or self.bagState == E_BagState.Store then
			self:setBagState(E_BagState.BatchSell)		
			local show = UIManager.Instance:isShowing("RoleView")
			if show then
				GlobalEventSystem:Fire(GameEvent.EventOpenBatchSellView, E_ShowOption.eLeft) 
				GlobalEventSystem:Fire(GameEvent.EventHideRoleView)
			else
				if (UIManager.Instance:getViewPositon("BagView") == E_ViewPos.eRight) then		
					GlobalEventSystem:Fire(GameEvent.EventOpenBatchSellView, E_ShowOption.eLeft) 	
				else	
					GlobalEventSystem:Fire(GameEvent.EventOpenBatchSellView, E_ShowOption.eMove2Left)	
				end					
				UIManager.Instance:moveViewByName(self.viewName, E_ViewPos.eRight, true)			--将背包移到右边												
			end
		else
			self:setBagState(E_BagState.Normal)		
			local view = UIManager.Instance:getViewByName("BatchSellView")
			if view then
				view:clear(true)
				view:close()
			end
		end
	end
	self.batchSellBtn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
end	

function BagView:updateFilterFunc()
	local func = self:getFilterFunc()
	if self.gridView then
		self.gridView:setGlobalFilterFunc(func, self)
	end
end
	
function BagView:getFilterFunc()
	local filterFunc = function(bag, itemObj)
		if not bag or not itemObj then
			return false
		end
		if bag.bagState == E_BagState.BatchSell then
			return (bag:checkCanSell(itemObj) and bag:isContentTypeContainItemType(bag.curContentType, itemObj:getType()))
		else
			return bag:isContentTypeContainItemType(self.curContentType, itemObj:getType()) 
		end
	end
	return filterFunc
end

----------------------------------------------------------------------
--新手指引
function BagView:getItemNode(refId)
	if self.gridView then
		local gridId = g_bagMgr:getItemIdByRefId(refId)
		local node,index = self.gridView:findItemNodeById(gridId)
		return node,index
	end
	return nil
end

function BagView:getGridView()
	return self.gridView
end

function BagView:clickItem(refId)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"BagView",refId)
end
----------------------------------------------------------------------