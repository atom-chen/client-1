require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.auction.AuctionSearch")
require("ui.auction.AuctionItemCell")
require("ui.utils.ItemView")
require("ui.utils.GridView")
require("ui.utils.ItemGridView")
require("ui.utils.BatchItemGridView")

AuctionSell = AuctionSell or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(833, 420)	
local const_sellAreaSize = CCSizeMake(542, 400)
local const_sellListCellSize = CCSizeMake(542, 79)
local const_sellListViewSize = CCSizeMake(542, const_sellListCellSize.height * 4)
local const_bagAreaSize = CCSizeMake(266, 404)
local const_bagItemCellSize = CCSizeMake(65, 65)

local const_row 	= 4
local const_columu 	= 3
local const_pageCap = const_row * const_columu
local const_hSpacing = 10
local const_vSpacing = 16

local const_requestSize = 20  --一次请求的列表的大小

function AuctionSell:create()
	return AuctionSell.New()
end

function AuctionSell:__init()	
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()
	self.buyList = {}	
	self.itemCellList = {}
	self.needReloadBagItem  = true
	
	self:initBg()
	self:initBagArea()
	self:initSellListArea()
	self:initTableView()
	self:initItemGridView()		
	self:initPageIndicateView()
	
	local vipLevel = GameWorld.Instance:getVipManager():getVipLevel()
	self:setMaxSellCount(G_getAuctionMgr():getMaxSellCountByVipLevel(vipLevel))
end

function AuctionSell:__delete()
	self:releaseItemList()
	if self.gridView then
		self.gridView:DeleteMe()
		self.gridView = nil
	end
	self.rootNode:release()	
end

function AuctionSell:onEnter()
	self:reloadItemGridView()
	UIManager.Instance:showLoadingHUD(5)
	G_getAuctionMgr():requestSellList()
end

function AuctionSell:onExit()
	
end	

function AuctionSell:initItemGridView()	
	self.gridView = BatchItemGridView.New()
--	self.gridView = ItemGridView.New()
	self.gridView:setPageOption(const_row, const_columu)
	self.gridView:setSpacing(const_hSpacing, const_vSpacing)
	self.gridView:setTouchNotify(self, self.handleTouchItem)
	self.rootNode:addChild(self.gridView:getRootNode())	
end	

-- 初始化页数指示
function AuctionSell:initPageIndicateView()
	self.pageIndicateView = createPageIndicateView(5, 1) 
	self.rootNode:addChild(self.pageIndicateView:getRootNode())	
	self.gridView:setPageChangedNotify(self.pageIndicateView, self.pageIndicateView.setIndex)
end

function AuctionSell:getPageCountBySize(size)
	if size then
		return math.ceil(size / const_pageCap)
	end
		return 0
end

function AuctionSell:reloadItemGridView()
	local filterFunc = function(itemObj)
		return (PropertyDictionary:get_bindStatus(itemObj:getPT()) ~= 1)
	end
	
	local itemList = G_getBagMgr():getItemMap(filterFunc)	
	local pageCount = self:getPageCountBySize(#(itemList))		
	if pageCount == 0 then
		pageCount = 1
	end

	if self.pageCount ~= pageCount then
		self.pageIndicateView:setPageCount(pageCount, 1)
		self.pageCount = pageCount
	end		

	self.gridView:setItemList(itemList, const_bagItemCellSize, 1, pageCount)	
	VisibleRect:relativePosition(self.gridView:getRootNode(), self.bagBg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 25))
	VisibleRect:relativePosition(self.pageIndicateView:getRootNode(), self.bagBg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 65))	
end		

function AuctionSell:updateItem(eventType, map)
	local filterFunc = function(itemObj)	
		return (PropertyDictionary:get_bindStatus(itemObj:getPT()) ~= 1)
	end
	if UIManager.Instance:isShowing("AuctionView")  then				--只有正在显示才更新
		if (not self.gridView:updateItem(eventType, map, filterFunc)) then
			self:reloadItemGridView()
		else
			self.needReloadBagItem = true
		end
	else
		self.needReloadBagItem = true
	end
end

function AuctionSell:updateFpTips()
	if self.gridView then
		self.gridView:updateFpTips()
	end
end	

function AuctionSell:setSellList(list)
	self.buyList = list
	self:reloadData()
	UIManager.Instance:hideLoadingHUD(0)
end

function AuctionSell:reloadData()
	self:releaseItemList()
	if self.tabelView then
		self.tabelView:reloadData()
	end
end

function AuctionSell:releaseItemList()
	for k, v in pairs(self.itemCellList) do
		v:DeleteMe()
	end
	self.itemCellList = {}
end

function AuctionSell:getAutionItemObj(index)	
	return self.buyList[index]
end

function AuctionSell:initBg()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), const_size)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
end

function AuctionSell:initBagArea()
	self.bagBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), const_bagAreaSize)
	self.rootNode:addChild(self.bagBg)
	VisibleRect:relativePosition(self.bagBg, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(15, 0))
	
	local titleImage = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(150, 38))	
	self.rootNode:addChild(titleImage)
	VisibleRect:relativePosition(titleImage, self.bagBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))	
	
	local titleText = createSpriteWithFrameName(RES("word_BagItem.png"))
	titleImage:addChild(titleText)	
	VisibleRect:relativePosition(titleText, titleImage, LAYOUT_CENTER)
end

function AuctionSell:initSellListArea()
	self.sellListBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), const_sellAreaSize)
	self.rootNode:addChild(self.sellListBg)
	VisibleRect:relativePosition(self.sellListBg, self.bagBg, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(8, 0))
		
	local tipsBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(const_sellAreaSize.width, 38))
	self.rootNode:addChild(tipsBg)
	VisibleRect:relativePosition(tipsBg, self.sellListBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))
	
	local tipsText = createSpriteWithFrameName(RES("word_SellingItems.png"))
	self.rootNode:addChild(tipsText)
	VisibleRect:relativePosition(tipsText, tipsBg, LAYOUT_CENTER)
	
	local titleUpBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(const_sellAreaSize.width, 38))
	self.rootNode:addChild(titleUpBg)
	VisibleRect:relativePosition(titleUpBg, tipsBg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 5))
	
	local itemName = createLabelWithStringFontSizeColorAndDimension(Config.Words[25316], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemName)
	VisibleRect:relativePosition(itemName, titleUpBg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(80, 0))
	
	local itemLevel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25317], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemLevel)
	VisibleRect:relativePosition(itemLevel, itemName, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(85, 0))
	
	local itemRemainTime = createLabelWithStringFontSizeColorAndDimension(Config.Words[25318], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemRemainTime)
	VisibleRect:relativePosition(itemRemainTime, itemLevel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(45, 0))
	
	local itemPrice = createLabelWithStringFontSizeColorAndDimension(Config.Words[25319], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemPrice)
	VisibleRect:relativePosition(itemPrice, itemRemainTime, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(40, 0))		
	
	self:initTableView()
end

function AuctionSell:initTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.tabelView = createTableView(dataHandler, const_sellListViewSize)
	self.tabelView:setTableViewHandler(tableDelegate)
	self.tabelView:setClippingToBounds(true)
	self.rootNode:addChild(self.tabelView)
	VisibleRect:relativePosition(self.tabelView, self.sellListBg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 10))
	self.tabelView:reloadData()	
end

function AuctionSell:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_sellListCellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_sellListCellSize)
		return 1
	elseif eventType == kTableCellAtIndex then		
		data:setCell(self:createCell(tableView, index))
		return 1
	elseif eventType == kNumberOfCellsInTableView then
		if table.size(self.buyList) == 0 then
			data:setIndex(4)			
		else
			data:setIndex(table.size(self.buyList))			
		end
		return 1
	end
	return 0
end

function AuctionSell:createCell(tableView, index)
--	print("create "..index)
	local cell = tableView:dequeueCell(index)		
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_sellListCellSize)
		cell:setIndex(index)					
	else
		cell:removeAllChildrenWithCleanup(true)		
	end

	local itemCell = self.itemCellList[index]
	
	if not itemCell then
		itemCell = AuctionItemCell.New(const_sellListCellSize)
		itemCell:setSpacing(25, 15, 260, 330, 450)
		itemCell:setData(self:getAutionItemObj(index))
		self.itemCellList[index] = itemCell
	else
		itemCell:getRootNode():removeFromParentAndCleanup(true)
	end
	
	cell:addChild(itemCell:getRootNode())	
	VisibleRect:relativePosition(itemCell:getRootNode(), cell, LAYOUT_CENTER)
	return cell
end

function AuctionSell:tableViewDelegate(tableView, cell, x, y)
	tableView = tolua.cast(tableView, "SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")

	local index = cell:getIndex()
	local cell = self.itemCellList[index]
	if (cell) then	
		local item = cell:getData()
		if not item then
			return
		end
				
		local itemTpye = item:getType()
		local arg = ItemDetailArg.New()
		arg:setItem(item)
		arg:setBtnArray({E_ItemDetailBtnType.eAuctionCancelSell})
		arg:setShowPriceType(E_EquipShowPriceType.auctionPrice)		
		if (itemTpye == ItemType.eItemEquip) then
			arg:setBtnArray({E_ItemDetailBtnType.eAuctionCancelSell, E_ItemDetailBtnType.eDetail})
			GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) 										
		elseif (itemTpye == ItemType.eItemGift) then
			GlobalEventSystem:Fire(GameEvent.EventOpenGiftItemDetailView, E_ShowOption.eMiddle, arg) 	
		else								
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) 	
		end					
	end
end

function AuctionSell.handleTouchItem(self, index, itemView)
	local item
	if itemView then
		item = itemView:getItem()
	end			
			
	if (not item) or (not itemView:isContentVisible()) then
		return
	end
	self:clickBagItem(item)
end	

function AuctionSell:clickBagItem(item)
	local arg = ItemDetailArg.New()		--显示物品详情的界面传递的参数
	arg:setItem(item)	
	arg:setBtnArray({E_ItemDetailBtnType.eAuctionSell})
	arg:setShowPriceType(E_EquipShowPriceType.noPrice)	
	arg:setIsShowAuctionPrice(true)
	arg:setIsShowAuctionNumber(true)	
	local itemTpye = item:getType()
	if (itemTpye == ItemType.eItemEquip) then	
		arg:setBtnArray({E_ItemDetailBtnType.eAuctionSell, E_ItemDetailBtnType.eDetail})
		GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) 
	elseif (itemTpye == ItemType.eItemGift) then					
		GlobalEventSystem:Fire(GameEvent.EventOpenGiftItemDetailView, E_ShowOption.eMiddle, arg) 
	else										
		GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg)
	end										
	G_getAuctionMgr():requestDefaultPrice(item:getId(), PropertyDictionary:get_number(item:getPT()))	
end
	
function AuctionSell:getRootNode()
	return self.rootNode
end
--25334
function AuctionSell:setMaxSellCount(count)
	if not self.sellCountLabel then
		self.sellCountLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
		self.rootNode:addChild(self.sellCountLabel)
	end
	if type(count) == "number" and count > 0 then	
		self.sellCountLabel:setString(string.format(Config.Words[25334], count))
		VisibleRect:relativePosition(self.sellCountLabel, self.rootNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
	end
end