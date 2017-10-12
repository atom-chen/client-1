require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.auction.AuctionSearch")
require("ui.auction.AuctionItemCell")

AuctionBuy = AuctionBuy or BaseClass()

local RequestListType = 
{
	Reset = 1,
	NextPage = 2,	
	PrePage = 3,	
	Update = 4,
}

local const_requestSize = 12  --一次请求的列表的大小
local const_pageOffset = 100
local const_pageSize = 4
local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(833, 420)	
local const_buyAreaSize = CCSizeMake(620, 400)
local const_buyListCellSize = CCSizeMake(628, 79)
local const_buyListViewSize = CCSizeMake(628, const_buyListCellSize.height * const_pageSize)

function AuctionBuy:create()
	return AuctionBuy.New()
end

function AuctionBuy:__init()	
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(const_size)
	self.rootNode:retain()
	self.buyList = {}
	self.listFrom = 0 
	self.listTo = 0
	self.itemCellList = {}
	
	self:initBg()
	self:initSearchArea()
	self:initBuyListArea()
	self:initTableView()
end

function AuctionBuy:__delete()
	if self.searchArea then
		self.searchArea:DeleteMe()
		self.searchArea = nil
	end		
	self:releaseItemList()
	self.rootNode:release()	
end

function AuctionBuy:onEnter()
	self:resetList()
	
	--暂时这样。手机端的SFTableView暂时不支持touch事件的回调。
--[[	local platForm = CCUserDefault:sharedUserDefault():getStringForKey("PlatForm")	
	if platForm ~= "WIN32" then
		self:startUpdate(true)
	end--]]
end

function AuctionBuy:onExit()
--	self:startUpdate(false)
end	

function AuctionBuy:setBuyList(list, from, to, tag)
	if tag > RequestListType.Update or tag < RequestListType.Reset then
		CCLuaLog("setBuyList error: tag > RequestListType.Update or tag < RequestListType.Reset")
		return
	end
	if type(from) ~= "number" 
		or type(to) ~= "number" then
		CCLuaLog("AuctionBuy:setBuyList param error")
		return
	end
	
	--列表为空
	local hasContent = not (self.listFrom == -1 or self.listTo == 1 or table.isEmpty(list))
	if not hasContent then
		if tag == RequestListType.NextPage or tag == RequestListType.PrePage then --不处理由于换页导致的列表为空
			if G_getAuctionMgr():getBuyListMaxCount() - 1 == self.listTo and tag == RequestListType.NextPage then
				UIManager.Instance:showSystemTips(Config.Words[8019])	
			end
			return
		end
	end
	
	self.listFrom = from
	self.listTo = to
	self.buyList = list
	self:reloadData()
	UIManager.Instance:hideLoadingHUD()		
	self:updatePageTips()
	self:showNoItemTips(not hasContent)
end

function AuctionBuy:updatePageTips()
	if self.pageTips == nil then	
		self.pageTips = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorYellow2"))	  
		self.rootNode:addChild(self.pageTips)
		VisibleRect:relativePosition(self.pageTips, self.titleDownBg, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE, ccp(-38, 0))
	end
	
	local max = G_getAuctionMgr():getBuyListMaxCount()
	local curPage
	local maxPage
	if type(max) == "number" then
		if self.listTo > 0 then
			curPage = self.listTo / const_requestSize + 1
		end
		maxPage = (max - 1) / const_requestSize + 1
	end
	
	if curPage and maxPage then
		self.pageTips:setString(string.format("%d/%d", math.floor(curPage), math.floor(maxPage)))							
		self.pageTips:setVisible(true)						
	else
		self.pageTips:setVisible(false)						
	end
end

function AuctionBuy:reloadData()
	self:releaseItemList()
	if self.tabelView then
		self.tabelView:reloadData()
		self:updateGetMoreTips()
		self.tabelView:scroll2Cell(0, false)
	end
end

function AuctionBuy:releaseItemList()
	for k, v in pairs(self.itemCellList) do
		v:DeleteMe()
	end
	self.itemCellList = {}
end

function AuctionBuy:getAutionItemObj(index)
	index = self.listFrom + index	
	return self.buyList[index]
end

function AuctionBuy:initBg()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), const_size)
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg, self.rootNode, LAYOUT_CENTER)
end

function AuctionBuy:showNoItemTips(bShow)
	if bShow and self.noItemTips == nil then	
		self.noItemTips = createLabelWithStringFontSizeColorAndDimension(Config.Words[25327], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
		self.rootNode:addChild(self.noItemTips)
		VisibleRect:relativePosition(self.noItemTips, self.buyListBg, LAYOUT_CENTER)
	end
	if self.noItemTips then
		self.noItemTips:setVisible(bShow)
	end
end

--请求列表
function AuctionBuy:requestList(from, to, tag)
	if type(from) == "number" and type(to) == "number" then
		local param = self.searchArea:getSearchParam()
		G_getAuctionMgr():saveSearchFilterTable(param)			--保存当前的搜索过滤条件
		G_getAuctionMgr():requestBuyList(from, to, param, tag)		--请求列表		
		UIManager.Instance:showLoadingHUD(5)	
	end
end

--更新当前index范围的列表
function AuctionBuy:updateList()
	if self.listFrom >= 0 and self.listTo >= 0 then
		self:requestList(self.listFrom, self.listTo, RequestListType.Update)
	end
end

--删除延迟获取
function AuctionBuy:removeDelayRequestPage()
	if self.delayRequestNextPage then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayRequestNextPage)
		self.delayRequestNextPage = nil
	end
end

--请求下一页/上一页
function AuctionBuy:requestNextOrPrePage(delay, isNext)
	self:removeDelayRequestPage()
	local onTimeout = function()
		self:removeDelayRequestPage()
		if isNext then
			if self.listTo >= 0 then
				self:requestList(self.listTo + 1, self.listTo + const_requestSize, RequestListType.NextPage)
			else
				self:resetList()
			end
		else
			if self.listFrom >= 0 then
				local from = self.listFrom - const_requestSize
				if from < 0 then
					from = 0
				end
				self:requestList(from, from + const_requestSize - 1, RequestListType.PrePage)
			else
				self:resetList()
			end
		end
	end
	self.delayRequestNextPage = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, delay, false)	
end

function AuctionBuy:startUpdate(bStart)
	if self.updateSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchId)
		self.updateSchId = nil
	end
	if bStart then
		local onTimeout = function()
			if not self.tabelView:isDragging() then
				self:tryGetMore()
			end
			self:updateGetMoreTips()
		end
		self.updateSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 0.1, false)	
	end
end

--重新列表
function AuctionBuy:resetList()
	self.listFrom = 0
	self.listTo = const_requestSize - 1
	self:requestList(self.listFrom, self.listTo, RequestListType.Reset)	
end

function AuctionBuy:initSearchArea()
	self.searchArea = AuctionSearch.New()
	self.rootNode:addChild(self.searchArea:getRootNode())
	VisibleRect:relativePosition(self.searchArea:getRootNode(), self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(15, 0))	
	local searchParam = G_getAuctionMgr():getSearchFilter()
	self.searchArea:setSearchParamTable(searchParam)
	
	local onSearch = function()		
		self:resetList()
	end		
	self.searchArea:setSearchNotify(onSearch)
end

function AuctionBuy:initBuyListArea()
	self.buyListBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), const_buyAreaSize)
	self.rootNode:addChild(self.buyListBg)
	VisibleRect:relativePosition(self.buyListBg, self.searchArea:getRootNode(), LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(8, 0))
	
	local titleUpBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(const_buyAreaSize.width, 38))
	self.rootNode:addChild(titleUpBg)
	VisibleRect:relativePosition(titleUpBg, self.buyListBg, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))
	
	local itemName = createLabelWithStringFontSizeColorAndDimension(Config.Words[25316], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemName)
	VisibleRect:relativePosition(itemName, titleUpBg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(80, 0))
	
	local itemLevel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25317], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemLevel)
	VisibleRect:relativePosition(itemLevel, itemName, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(85, 0))
	
	local itemRemainTime = createLabelWithStringFontSizeColorAndDimension(Config.Words[25318], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  
	self.rootNode:addChild(itemRemainTime)
	VisibleRect:relativePosition(itemRemainTime, itemLevel, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(60, 0))
	
	local itemPrice = createLabelWithStringFontSizeColorAndDimension(Config.Words[25319], "Arial", FSIZE("Size4"), FCOLOR("ColorYellow2"))	  	
	self.rootNode:addChild(itemPrice)
	VisibleRect:relativePosition(itemPrice, itemRemainTime, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(55, 0))	
	
	self.titleDownBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(const_buyAreaSize.width, 38))
	self.rootNode:addChild(self.titleDownBg)
	VisibleRect:relativePosition(self.titleDownBg, self.buyListBg, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 0))
	
	self.getMoreLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite3"))	
	self.rootNode:addChild(self.getMoreLabel)	
	VisibleRect:relativePosition(self.getMoreLabel, self.titleDownBg, LAYOUT_CENTER)
	
	self:initTableView()
end

function AuctionBuy:initTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.tabelView = createTableView(dataHandler, const_buyListViewSize)
	self.tabelView:setTableViewHandler(tableDelegate)
	self.tabelView:setClippingToBounds(true)
	self.rootNode:addChild(self.tabelView)
	VisibleRect:relativePosition(self.tabelView, self.buyListBg, LAYOUT_CENTER)
	self.tabelView:reloadData()	
end

function AuctionBuy:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_buyListCellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_buyListCellSize)
		return 1
	elseif eventType == kTableCellAtIndex then		
		data:setCell(self:createCell(tableView, index))
		return 1
	elseif eventType == kNumberOfCellsInTableView then		
		data:setIndex(self:getCellSize())	
		return 1				
	elseif eventType == kTableViewTouchMoved or eventType == kTableViewDidAnimateScrollEnd then
		self:updateGetMoreTips()
		return 1
	elseif eventType == kTableViewTouchEnded then
		self:tryGetMore()
		return 1	
	end
	return 0
end

function AuctionBuy:getCellSize()
	local size = table.size(self.buyList)
	if size > 0 then
		return size
	else
		return const_pageSize
	end
end

function AuctionBuy:setBtnValue(ttype, value)
	if self.searchArea then
		self.searchArea:setBtnValue(ttype, value)
	end
end

function AuctionBuy:createCell(tableView, index)
	local cell = tableView:dequeueCell(index)		
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_buyListCellSize)
		cell:setIndex(index)					
	else
		cell:removeAllChildrenWithCleanup(true)		
	end

	local itemCell = self.itemCellList[index]
	
	if not itemCell then
		itemCell = AuctionItemCell.New(const_buyListCellSize)
		itemCell:setSpacing(25, 15, 265, 355, 485)
		itemCell:setData(self:getAutionItemObj(index))
		self.itemCellList[index] = itemCell
	else
		itemCell:getRootNode():removeFromParentAndCleanup(true)
	end
	
	cell:addChild(itemCell:getRootNode())	
	VisibleRect:relativePosition(itemCell:getRootNode(), cell, LAYOUT_CENTER)
	return cell
end	

function AuctionBuy:tableViewDelegate(tableView, cell, x, y)
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
		arg:setBtnArray({E_ItemDetailBtnType.eAuctionBuy})		
		arg:setShowPriceType(E_EquipShowPriceType.auctionPrice)		

		local itemTpye = item:getType()
		if (itemTpye == ItemType.eItemEquip) then	--点击的物品时装备	
			arg:setBtnArray({E_ItemDetailBtnType.eAuctionBuy, E_ItemDetailBtnType.eDetail})		
			local minFpEquip = self:getMinFpEquipInPutOnEquipList(item)	--从身上装备获取战力最低的装备
			if (minFpEquip == nil) then	--获取失败，则不需要对比											
				GlobalEventSystem:Fire(GameEvent.EventOpenEquipItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
			else
				arg:setTitleTips(Config.Words[25332])
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
			GlobalEventSystem:Fire(GameEvent.EventOpenGiftItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		else									
			GlobalEventSystem:Fire(GameEvent.EventOpenNormalItemDetailView, E_ShowOption.eMiddle, arg) --进入详情
		end
	end
end

function AuctionBuy:getMinFpEquipInPutOnEquipList(equipObj)
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()	
	if not equipMgr:isBodyAreaFull(PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property)) then
		return nil
	end
	local list = equipMgr:getEquipListByBodyAreaId(PropertyDictionary:get_areaOfBody(equipObj:getStaticData().property))	
	return equipMgr:getMinFpEquipObj(list)
end	

function AuctionBuy:tryGetMore()
	local offset = self.tabelView:getContentOffset()
	local size = self.tabelView:getContentSize()								
	if size.height >= const_buyListViewSize.height then
		if offset.y >= const_pageOffset then		
			self:requestNextOrPrePage(0.3, true)	
			return true							
		elseif (- offset.y + const_buyListViewSize.height) - size.height >= const_pageOffset then 			
			self:requestNextOrPrePage(0.3, false)
			return true				
		end
	else				
		if const_buyListViewSize.height - size.height - offset.y >= const_pageOffset then
			self:requestNextOrPrePage(0.3, false)	
			return true						
		elseif offset.y + size.height - const_buyListViewSize.height >= const_pageOffset then			
			self:requestNextOrPrePage(0.3, true)		
			return true							
		end
	end
	return false
end

--
function AuctionBuy:updateGetMoreTips()
	local offset = self.tabelView:getContentOffset()
	local size = self.tabelView:getContentSize()
	if size.height >= const_buyListViewSize.height then
		if offset.y >= const_pageOffset then	
			self:showGetMoreTips("update")		
		elseif offset.y >= 0 then	
			self:showGetMoreTips("up")		
		elseif (- offset.y + const_buyListViewSize.height) - size.height >= const_pageOffset then			
			self:showGetMoreTips("update")		
		elseif (- offset.y + const_buyListViewSize.height) - size.height >= 0 then 
			self:showGetMoreTips("down")								
		else
			self:showGetMoreTips("read")
		end
	else				
		if const_buyListViewSize.height - size.height - offset.y >= const_pageOffset then			
			self:showGetMoreTips("update")		
		elseif const_buyListViewSize.height - size.height - offset.y >= 0 then			
			self:showGetMoreTips("up")								
		elseif offset.y + size.height - const_buyListViewSize.height >= const_pageOffset then	
			self:showGetMoreTips("update")				
		elseif offset.y + size.height - const_buyListViewSize.height >= 0 then	
			self:showGetMoreTips("down")								
		else
			self:showGetMoreTips("read")
		end
	end
end

function AuctionBuy:showGetMoreTips(ttype)
	if ttype == "up" then
		self.getMoreLabel:setString(Config.Words[8018])
	elseif ttype == "down" then
		self.getMoreLabel:setString(Config.Words[8017])
	elseif ttype == "update" then	
		self.getMoreLabel:setString(Config.Words[8016])
	elseif ttype == "read" then
		self.getMoreLabel:setString(Config.Words[8020])
	else
		self.getMoreLabel:setString(" ")
	end
	VisibleRect:relativePosition(self.getMoreLabel, self.titleDownBg, LAYOUT_CENTER)
end	
	
function AuctionBuy:getRootNode()
	return self.rootNode
end