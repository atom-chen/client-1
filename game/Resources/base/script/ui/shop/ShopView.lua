require("ui.UIManager")
require("common.BaseUI")
require("ui.Npc.NpcBaseView")
require("ui.utils.MessageBox")
require("gameevent.GameEvent")
require("object.mall.MallDef")
require("object.mall.MallObject")
require("object.bag.BagDef")
require("config.color")
require("data.npc.npc")	
require("ui.utils.ItemView")
ShopView = ShopView or BaseClass(NpcBaseView)

local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local ShopSelected = 1  --记录被选择的item号
local goodsNum = 0

local width = 414
local height = 540
local cellSize = VisibleRect:getScaleSize(CCSizeMake(337,107))
local grideSize = VisibleRect:getScaleSize(CCSizeMake(337,107))

local ExpNum = 0


function ShopView:__init()
	self.viewName = "ShopView"	
	self:init(CCSizeMake(414,564))
	self.eventType = {}	-- tableview的数据类型
	self.selectedCell = 1		
	self.saveCellList = {} 
	self:initVariable()		
	self:initStaticView()	
	
	--显示谈话内容	
end

function ShopView:create()
	return ShopView.New()
end

function ShopView:getRootNode()
	return self.rootNode
end	

------------------------私有接口---------------------------------

function ShopView:createShopTableView(shopId)
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedCell  = cell:getIndex()+1	
		
		if(self.cellFrame : getParent() == nil) then
			cell:addChild(self.cellFrame)				
			VisibleRect:relativePosition(self.cellFrame,cell,LAYOUT_CENTER)
		else 
			self.cellFrame : removeFromParentAndCleanup(true)				
			cell : addChild(self.cellFrame)					
			VisibleRect:relativePosition(self.cellFrame,cell,LAYOUT_CENTER)
		end	
		local itemList = self.tableItemList[shopId]
		local indexList = self.tableIndexList[shopId]
		local refId = indexList[cell:getIndex()]	
		local rrefId = 	itemList[refId]:getItemId()	
		local buyNumber = G_getQuestLogicMgr():getNumberByShopViewWithQuest(rrefId)
		GlobalEventSystem:Fire(GameEvent.EventBuyItem,itemList[refId],buyNumber,"shop")		
		
		self:clickItemNode(itemList,refId)							
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then			
				local tableCell = tableP:dequeueCell(index)		
				local cellList = self.tableCellList[shopId]	
				if tableCell == nil then
					tableCell = SFTableViewCell:create()
					tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
					local item = self:createItem(index,shopId)
					tableCell:addChild(item)
					tableCell:setIndex(index)	
					data:setCell(tableCell)
					if not cellList then
						cellList = {}
					end
					cellList[index] = tableCell				
					
				else
					if 	cellList[index] then
						data:setCell(cellList[index])
					else
						tableCell:removeAllChildrenWithCleanup(true)
						tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
						local item = self:createItem(index,shopId)
						tableCell:addChild(item)					
						tableCell:setIndex(index)					
						data:setCell(tableCell)	
						if not cellList then
							cellList = {}
						end
						cellList[index] = tableCell
					end				
				end
			--end																							
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			local size = 0
			local itemList = self.tableItemList[shopId]
			if itemList then
				size = table.size(itemList)
			end
			data:setIndex(size)
			return 1
		end
	end			

	--创建tableview
	shopTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(337, height-145)))
	shopTable:reloadData()
	shopTable:setTableViewHandler(tableDelegate)
	shopTable:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(shopTable)		
	VisibleRect:relativePosition(shopTable, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 8))	
	return shopTable
end	

function ShopView:initVariable()
	--tableview数据源的类型
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	--选中框
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemSelect.png"),CCSizeMake(350,110))
	self.cellFrame:retain()	
	self.clickFlag = true	

	self.tableCellList = {}	
	--tableIndexList
	self.tableIndexList = {}
	--tableList 
	self.tableList = {}
	--self.tableItemList
	self.tableItemList = {}
	
end

function ShopView:UpdateShopCellView()
	if not self.tableCellList[self.openShopId] then	
		self.tableCellList[self.openShopId] = {}
	end
	self.tableList[self.openShopId]:reloadData()
end

function ShopView:createTableCell(index,shopId)
	local cell = SFTableViewCell:create()
	cell:setContentSize(VisibleRect:getScaleSize(grideSize))
	local item = self:createItem(index,shopId)
	cell:addChild(item)
	cell:setIndex(index)
	return cell
end

function ShopView:UpdateShopView()
	if not self.tableCellList[self.openShopId] then	
		self.tableCellList[self.openShopId] = {}
	end
	self.tableList[self.openShopId]:reloadData()
end

function ShopView:onEnter(shopId)
	self.saveCellList = {} 
	
	self.openShopId = shopId
	local npcMgr = GameWorld.Instance:getNpcManager()
	local viewNpcId = npcMgr:getTouchNpcRefId()	
	self:setHeadIcon(viewNpcId)
	self:setTalkContent(viewNpcId)	

	if not self.tableCellList[shopId] then
		self.tableCellList[shopId] = {}
	end		
	
	for k , v in pairs(self.tableList) do
		v:setVisible(false)
	end

	if shopId  == "shop_1" or shopId  == "shop_2" or shopId  == "shop_3" then
		self:showKindList()
	else
		if self.kindNode then
			self.kindNode:setVisible(false)
		end
		local mallMgr = GameWorld.Instance:getMallManager()	
		
		local shopList = mallMgr:getShopItemListByShopId(shopId ,4)			
		self.tableItemList[shopId] = table.cp(shopList)
		

		if not self.tableIndexList[shopId] then
			local shopIndexList = mallMgr:getOpenShopIndexList()	
			self.tableIndexList[shopId] = table.cp(shopIndexList)
		end			
		
		for k,v in pairs(self.tableList) do
			v:setVisible(false)		
		end
		
		if self.tableList[shopId] then
			self.tableList[shopId]:removeFromParentAndCleanup(true)
		end
		
		self.tableCellList[shopId] = {}
		self.tableList[shopId] = self:createShopTableView(shopId)		
		self.tableList[shopId]:setVisible(true)
	end
	
	GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesUseItemInShop()--引导点击药店中的指定道具	
end

function ShopView:showKindList()
	if not self.kindNode then
		self.kindNode = CCNode:create()
		self.kindNode:setContentSize(CCSizeMake(337, height-145))
		self:addChild(self.kindNode)
		VisibleRect:relativePosition(shopTable, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(20, -80))	
		
		local btStr = {
		[1] = Config.Words[5028],
		[2] = Config.Words[5029],	
		[3] = Config.Words[5030],
		}
					
		local tabArray = CCArray:create()			
		for  kind = 1 , 3 do 
			local openKindShopFunc = function()	
				local mallMgr = GameWorld.Instance:getMallManager()	
				
				local shopList = mallMgr:getShopItemListByShopId(self.openShopId ,kind)			
				self.tableItemList[self.openShopId] = table.cp(shopList)					
				
				local shopIndexList = mallMgr:getOpenShopIndexList()	
				self.tableIndexList[self.openShopId] = table.cp(shopIndexList)				
				
				for k,v in pairs(self.tableList) do
					v:setVisible(false)		
				end
				
				if self.tableList[self.openShopId] then
					self.tableList[self.openShopId]:removeFromParentAndCleanup(true)
				end
				
				self.tableCellList[self.openShopId] = {}
				self.tableList[self.openShopId] = self:createShopTableView(self.openShopId)		
				self.tableList[self.openShopId]:setVisible(true)
			end		
				
			local bt = createButton(createScale9SpriteWithFrameName(RES("tab_2_normal.png")) , createScale9SpriteWithFrameName(RES("tab_2_select.png")))
			local lable = createLabelWithStringFontSizeColorAndDimension(btStr[kind] , "Arial" ,FSIZE("Size4"),FCOLOR("ColorWhite3"),CCSizeMake(30,0))
			bt:setTitleString(lable)
			bt:addTargetWithActionForControlEvents(openKindShopFunc, CCControlEventTouchDown)	
			tabArray:addObject(bt)
		end				
		tabArray:reverseObjects()
		self.kindTab = createTabView(tabArray, 10*viewScale, tab_vertical)
		self.kindNode:addChild(self.kindTab)
		VisibleRect:relativePosition(self.kindTab,self.kindNode,LAYOUT_TOP_INSIDE  + LAYOUT_LEFT_OUTSIDE,ccp(0,20))
	else
		self.kindNode:setVisible(true)	
	end

	local proId = PropertyDictionary:get_professionId(G_getHero():getPT())
	local mallMgr = GameWorld.Instance:getMallManager()	
	local shopList = mallMgr:getShopItemListByShopId(self.openShopId ,proId)			
	self.tableItemList[self.openShopId] = table.cp(shopList)
	self.kindTab:setSelIndex(3 - proId)					
	
	local shopIndexList = mallMgr:getOpenShopIndexList()	
	self.tableIndexList[self.openShopId] = table.cp(shopIndexList)				
	
	for k,v in pairs(self.tableList) do
		v:setVisible(false)		
	end
	
	if self.tableList[self.openShopId] then
		self.tableList[self.openShopId]:removeFromParentAndCleanup(true)
	end		
	self.tableCellList[self.openShopId] = {}
	self.tableList[self.openShopId] = self:createShopTableView(self.openShopId)		
	self.tableList[self.openShopId]:setVisible(true)		
end

function ShopView:createItem(index,shopId)
	local item = CCNode:create()
	item:setContentSize(grideSize)

	local itemList = self.tableItemList[shopId]
	local indexList = self.tableIndexList[shopId]
	
	if indexList == nil or table.size(indexList) == 0  then
		return item
	end
	local refId = indexList[index]
	local obj = itemList[refId]	
	if obj == nil  then
		return item	
	end
	
	--以refid为Key记录node
	local rrefId = obj:getItemId()
	self.saveCellList[rrefId] = item
	
	--背景		
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(340,100))
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER)			
	item:addChild(cellBg)
	
	--蓝色条
	local coinBg = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSizeMake(337,33))
	VisibleRect:relativePosition(coinBg,cellBg,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(0,-3))			
	cellBg:addChild(coinBg)	
	
	local itemObj = ItemObject.New()
	itemObj:setRefId(obj:getItemId())
	local color = G_getColorByItem(itemObj)
	itemObj:DeleteMe()	
	--商品名称
	local goodsName = createLabelWithStringFontSizeColorAndDimension( G_GetItemNameByRefId( obj:getItemId() ),"Arial",FSIZE("Size3"),color)
	goodsName:setAnchorPoint(ccp(0,1))
	VisibleRect:relativePosition(goodsName,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(95 ,-8))								
	VisibleRect:relativePosition(goodsName,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(100 ,-8))								
	cellBg:addChild(goodsName)
	
	--商品介绍
	local goodsDes = createLabelWithStringFontSizeColorAndDimension( G_GetItemDescByRefId( obj:getItemId() ),"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"),CCSizeMake(210,0))
	goodsDes:setAnchorPoint(ccp(0,1))
	VisibleRect:relativePosition(goodsDes,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(100,-40))								
	cellBg:addChild(goodsDes)		
	
	local priceTable = {}
	if table.size(obj:getObjPriceType()) > 0 then
		priceTable  = obj:getObjPriceType()	
	end
	
	local size = table.size(priceTable)	
	
	local iconStr = "item_unbindedGold"
	local scale  = 1
	local price = 0

	for k ,value in pairs(priceTable) do
		iconStr = PriceIcon[k].icon
		price = value
		scale = PriceIcon[k].scale
	end	
	
	local limitType = obj:getItemLimitType()
	local descStr =""
	if(limitType ~= 0) then
		if(limitType == 1) then
			--单人限购
			descStr = Config.Words[5021]
		else
			--全服限购
			descStr = Config.Words[5022]		
		end
		--显示剩余数量
		local limitLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5010] .. obj:getItemLimitNum(),"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		VisibleRect:relativePosition(limitLabel,cellBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(120,-80))
		cellBg:addChild(limitLabel)		
	end	

	--钱币
	local coinSprite = createSpriteWithFileName(ICON(iconStr))
	coinSprite:setScale(scale)
	VisibleRect:relativePosition(coinSprite,cellBg,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(70,-10))			
	cellBg:addChild(coinSprite)	
	if 	obj:getBindedGold()>0 then
		local bindcoinLock = createSpriteWithFrameName(RES("bagBatch_iocnLock.png"))
		VisibleRect:relativePosition(bindcoinLock,cellBg,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(70,-10))			
		cellBg:addChild(bindcoinLock)	
	end	
	--价格
	local goldPrice = createLabelWithStringFontSizeColorAndDimension(price,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	VisibleRect:relativePosition(goldPrice,coinSprite,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(10,0))								
	cellBg:addChild(goldPrice)		
	--商品背景
	local goodsBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_itemBg.png"),CCSizeMake(68, 68))		
	VisibleRect:relativePosition(goodsBg,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y ,ccp(10,-5))			
	cellBg:addChild(goodsBg)
	
	local qualit = G_getQualityByRefId(obj:getItemId())
	--商品品质背景
	local qualityBg = createSpriteWithFrameName(RES(G_getQualityResName(qualit)))
	goodsBg:addChild(qualityBg)	
	VisibleRect:relativePosition(qualityBg,goodsBg,LAYOUT_CENTER)		
	--商品Icon
	local goodsIcon = createSpriteWithFileName(ICON(G_GetItemICONByRefId( obj:getItemId() )))
	goodsBg:addChild(goodsIcon)
	VisibleRect:relativePosition(goodsIcon,goodsBg,LAYOUT_CENTER)				
			
	return item
end	

function ShopView:setTalkContent(viewNpcId)
	if not  viewNpcId then
		return
	end

	local npcTalkWord = ""
	if GameData.Npc[viewNpcId]~=nil then
		npcTalkWord = GameData.Npc[viewNpcId]["property"]["description"]
	else
		npcTalkWord = string.wrapRich(Config.Words[3202],Config.FontColor["ColorWhite1"],FSIZE("Size4"))
	end
	npcTalkWord = "    " .. npcTalkWord 
	self:setNpcText(npcTalkWord)
	--[[if self.questTitle == nil then
		local childViewSize = CCSizeMake((width-30)*scale,70*scale)	
		local containerNode = CCNode:create()
		containerNode:setContentSize(childViewSize)
		local scrollView = createScrollViewWithSize(childViewSize)
		scrollView:setDirection(kSFScrollViewDirectionVertical)	
		scrollView:setContainer(containerNode)
		self:addChild(scrollView)
		VisibleRect:relativePosition(scrollView, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10.0, 0))	
			
		self.questTitle = createLabelWithStringFontSizeColorAndDimension(npcTalkWord , "Arial",FSIZE("Size4"),FCOLOR("ColorBlack1"),CCSizeMake(width-70-45,0))
		containerNode:addChild(self.questTitle)
		VisibleRect:relativePosition(self.questTitle,containerNode,LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE , CCPointMake(20+45,-20))	
	else
		self.questTitle:setString(npcTalkWord)
	end--]]
end

function ShopView:setHeadIcon(viewNpcId)
	self:setNpcAvatar(viewNpcId)
	self:setNpcName(viewNpcId)
end

function ShopView:initStaticView()	
	self:createViewBg()

	local viewLine1 =  createScale9SpriteWithFrameNameAndSize(RES("npc_dividLine.png"), CCSizeMake((393-20)*scale,3*scale))
	self:addChild(viewLine1)	
	VisibleRect:relativePosition(viewLine1,self.viewNodeBg, LAYOUT_TOP_INSIDE +LAYOUT_LEFT_INSIDE  ,ccp(10,-70))		
end		

function ShopView:onExit()
	local manager =UIManager.Instance
	manager:hideUI("BuyingView")		
	manager:hideUI("EquipItemDetailView")
end	

function ShopView:__delete()
	self.cellFrame:release()	
	self:getContentNode():removeAllChildrenWithCleanup(true)	
end	

----------------------------------------------------------------------
--新手指引
function ShopView:getItemNode(refId)
	if table.size(self.saveCellList)>0 then
		for i,v in pairs(self.saveCellList) do
			if refId==i then
				return v
			end
		end
	end
	return nil
end

function ShopView:clickItemNode(itemList,refId)
	local rrefId = 	itemList[refId]:getItemId()
	if rrefId=="item_drug_2" then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"ShopView",rrefId)
	end	
end	
----------------------------------------------------------------------