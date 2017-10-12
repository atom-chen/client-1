--批量出售
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")

BatchSellView = BatchSellView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local const_row 	= 4
local const_columu 	= 5
local const_pageCap = const_row * const_columu
local const_cellSize = CCSizeMake(64, 64)

function BatchSellView:__init()
	self.viewName = "BatchSellView"
	
	self.viewSize = self:initHalfScreen()
	self.itemList = {}
	self.pageCount = 0
	self.expenSiveCount = 0
	self.onSaleEquipList = {}
	self.onSaleItemList = {}
	
	self:initBg()
	self:initItemGridView()
	self:initPageIndicateView()
	self:initTips()
	self:showMoney()
	self:initBtn()
end

function BatchSellView:__delete()
	self.itemGridView:DeleteMe()
end	

function BatchSellView:onExit()
	self:clear(true)
	local bag = UIManager.Instance:getViewByName("BagView")	
	if bag then
		bag:setBagState(E_BagState.Normal)	
	end
end
	
function BatchSellView:onEnter()
end	

function BatchSellView:initBg()
	local titleNode = createSpriteWithFrameName(RES("bulk_sale.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
	
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(self.viewSize.width - 41, self.viewSize.height - 231))			
	self:addChild(self.bg)
	VisibleRect:relativePosition(self.bg,self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -2))
	
	self.bottomBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(self.viewSize.width-41, self.viewSize.height/2 -130))
	self:addChild(self.bottomBg)
	VisibleRect:relativePosition(self.bottomBg, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE)
end	

function BatchSellView:initTips()
	local tips1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10171], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow3"))
	self.tips2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[10172], "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow3"))
	self:addChild(tips1)
	self:addChild(self.tips2)
	VisibleRect:relativePosition(tips1, self.bottomBg, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(15, -5))
	VisibleRect:relativePosition(self.tips2, tips1, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -FSIZE("Size2")-10))
end

function BatchSellView:showMoney()
	self.sellPrice = 0
	if not self.moneyLabel then
		self.moneyLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[10173]..self.sellPrice, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))
		self:addChild(self.moneyLabel)
		self.moneyLabel:setAnchorPoint(ccp(0, 0.5))
	end
	VisibleRect:relativePosition(self.moneyLabel, self.tips2, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(0, -FSIZE("Size2")-8))
end

function BatchSellView:initBtn()
	self.sellBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local sellText = createSpriteWithFrameName(RES("word_button_sell.png"))
	self:addChild(self.sellBtn)
	self.sellBtn:setTitleString(sellText)
	VisibleRect:relativePosition(self.sellBtn, self.bottomBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(10, 6))
	local sellClick = function()	
		if self.expenSiveCount > 0 then
			local onMsgBoxCallBack = function(unused, text, id)
				if (id == 2) then
					self:sell()	
				end
			end	
			local word = string.format(Config.Words[10187],self.expenSiveCount)
			local msg = showMsgBox(word,E_MSG_BT_ID.ID_CANCELAndOK)			
			msg:setNotify(onMsgBoxCallBack)
		else
			self:sell()
		end
	end
	self.sellBtn:addTargetWithActionForControlEvents(sellClick, CCControlEventTouchDown)
	
	self.quickSelectBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local quickSelectText = createSpriteWithFrameName(RES("quick_select.png"))
	self:addChild(self.quickSelectBtn)
	self.quickSelectBtn:setTitleString(quickSelectText)
	VisibleRect:relativePosition(self.quickSelectBtn, self.bottomBg, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-13, 6))
	VisibleRect:relativePosition(sellText, self.sellBtn , LAYOUT_CENTER)
	VisibleRect:relativePosition(quickSelectText, self.quickSelectBtn, LAYOUT_CENTER)	
		
	local quickSellClick = function()		
		local bagMgr = G_getBagMgr()
		local quickSellEquipList = bagMgr:getQuickSellItemList()
		local bagView = UIManager.Instance:getViewByName("BagView")
		if not bagView or not quickSellEquipList then
			return
		end				
		for key, itemObj in pairs(quickSellEquipList) do		
			bagView:moveItemToSale(itemObj)			
		end
	end
	
	self.quickSelectBtn:addTargetWithActionForControlEvents(quickSellClick, CCControlEventTouchDown)
end

function BatchSellView:initItemGridView()	
--	self.itemGridView = ItemGridView.New()
	self.itemGridView = BatchItemGridView.New()
	
	self.itemGridView:setPageOption(const_row, const_columu)
	self.itemGridView:setSpacing(3, 3)	
	self.itemGridView:setTouchNotify(self, self.handleItemGridViewTouch)
	self.itemGridView:setItemList({}, const_cellSize, 1, 1, nil)	
	
	self:addChild(self.itemGridView:getRootNode())
	VisibleRect:relativePosition(self.itemGridView:getRootNode(), self.bg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -30))
end	

--
function BatchSellView:isPageCountChanged(size)
	local pageCount = math.ceil(size / const_pageCap) 	
	local ret = (pageCount ~= self.pageCount)
	self.pageCount = pageCount
	return ret
end

function BatchSellView:findItem(id)
	for k, v in pairs(self.itemList) do
		if (v:getId() == id) then
			return k
		end
	end
	return nil
end

function BatchSellView:addItem(itemObj)
	local index = self:findItem(itemObj:getId())
	if index then
		return
	end
	
	table.insert(self.itemList, itemObj)
	local number = PropertyDictionary:get_number(itemObj:getPT())
	local salePrice = PropertyDictionary:get_salePrice(itemObj:getStaticData().property)
	if number and salePrice then
		self.sellPrice = self.sellPrice + number*salePrice
		self.moneyLabel:setString(Config.Words[10173]..self.sellPrice)
	end
	
	if self:isPageCountChanged(#(self.itemList)) then
		self:reloadGridView()		
	else
		self.itemGridView:addOneItem(itemObj)
	end		
	--统计放入稀有物品个数
	if G_IsHighQuilatyEquip(itemObj) then
		self.expenSiveCount = self.expenSiveCount + 1
	end
end

function BatchSellView:removeItem(itemObj)
	local index = self:findItem(itemObj:getId())
	if index then
		table.remove(self.itemList, index)
		
		local number = PropertyDictionary:get_number(itemObj:getPT())
		local salePrice = PropertyDictionary:get_salePrice(itemObj:getStaticData().property)
		if number and salePrice then
			self.sellPrice = self.sellPrice - number*salePrice
			self.moneyLabel:setString(Config.Words[10173]..self.sellPrice)	
		end
		
		if self:isPageCountChanged(#(self.itemList)) then
			self:reloadGridView()		
		else			
			self.itemGridView:removeOneItem(itemObj)
		end
	end
	
	if G_IsHighQuilatyEquip(itemObj) then
		self.expenSiveCount = self.expenSiveCount - 1
	end
end	

-- 初始化页数指示
function BatchSellView:initPageIndicateView()
	self.pageCount = 1
	self.pageIndicateView = createPageIndicateView(1, 1) 
	self:addChild(self.pageIndicateView:getRootNode())	
	self.itemGridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.bg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 63))
end

function BatchSellView.handleItemGridViewTouch(self, index, itemView)
	if not itemView then
		return
	end
	local itemObj =  itemView:getItem()
	if not itemObj then
		return
	end			

	local bagView = UIManager.Instance:getViewByName("BagView")
	bagView:moveItemBackFromSale(itemObj)
	self:removeItem(itemObj)			
	--[[local arg = ItemDetailArg.New()	
	arg:setItem(itemObj)			
	arg:setBtnArray({E_ItemDetailBtnType.eCancelSell})
	
	if itemObj:getType() == ItemType.eItemEquip then
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg)
	else
		GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg)
	end--]]								
end		

function BatchSellView:reloadGridView()
	self.pageCount = math.ceil(#(self.itemList) / const_pageCap)	
	if self.pageCount == 0 then	--如果没有选中，则默认显示一个空页
		self.pageCount = 1
	end
	local pageIndex = self.pageIndicateView:getIndex()	
	if not (pageIndex >= 1 and pageIndex <= self.pageCount) then
		pageIndex = self.pageCount
	end		
	self.pageIndicateView:setPageCount(self.pageCount, 1)
	self.itemGridView:setItemList(self.itemList, const_cellSize, pageIndex, self.pageCount, nil)		
	VisibleRect:relativePosition(self.itemGridView:getRootNode(), self.previewBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -8))
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.bg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 63))
end

function BatchSellView:sell()
	local onSaleEquipList = {}
	local onSaleItemList = {}
	for k, v in pairs(self.itemList) do
		if v:getType() == ItemType.eItemEquip then
			table.insert(onSaleEquipList, v)
		else
			table.insert(onSaleItemList, v)
		end
	end	
	G_getBagMgr():requestBatchSellItem(onSaleItemList)
	G_getForgingMgr():requestBag_Decompose(onSaleEquipList)
	self:clear(false)
end

function BatchSellView:clear(bGiveBack2Bag)
	local bag = UIManager.Instance:getViewByName("BagView")	
	if bag and bGiveBack2Bag then			--将物品归还给背包
		for k, v in pairs(self.itemList) do
			bag:moveItemBackFromSale(v)
		end				
	end
	self.itemList = {}	--清空itemList
	self.sellPrice = 0	--清空价格
	self.expenSiveCount = 0 --情况珍贵物品数量
	self.moneyLabel:setString(Config.Words[10173]..self.sellPrice)
	self:reloadGridView()
end	
