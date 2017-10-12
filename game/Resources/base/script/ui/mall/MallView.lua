require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.mall.MallDef")
require("object.mall.MallObject")
require("object.bag.BagDef")
require("ui.utils.ItemView")

MallView = MallView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local grideSize = VisibleRect:getScaleSize(CCSizeMake(405,130))
local exchangeGridSize = VisibleRect:getScaleSize(CCSizeMake(405,160))
local cellSize = VisibleRect:getScaleSize(CCSizeMake(835,130))
local smallGridSize = VisibleRect:getScaleSize(CCSizeMake(303,110))
local smallCellSize = VisibleRect:getScaleSize(CCSizeMake(638,130))
local normalWidth = 405
local smallWidth = 303
local normalHeight = 150
local smallHeight = 122
local pageIndex = 1 -- 当前背包的页数，1-5页
local scale = VisibleRect:SFGetScale()
local CELL_TAG = 100
local width = 825
local height = 564

local exchangeUse = {
	[1] = {icon = "item_goldMedal" ,refId = "item_goldMedal"},
	[2] = {icon = "item_silverMedal" ,refId = "item_silverMedal"},
	[3] = {icon = "item_copperMedal" ,refId = "item_copperMedal"},
	[4] = {icon = "item_ironMedal",refId = "item_ironMedal" },
}
local mallName = {
	[1] = {name = Config.Words[5017]},
	[2] = {name = Config.Words[5016]},
	[3] = {name = Config.Words[5026]}
}	
local subTabprofessionList = {
	[ExchangeSubType.daoshi] = 3,
	[ExchangeSubType.fashi] = 2,
	[ExchangeSubType.zhanshi] = 1,
}

local mallTableViewList = {}

local GoodsType = 
{
	UnBind = 1,
	Bind = 2,
	ExchangeForAll = 3,
	ExchangeForZhanShi = 4,
	ExchangeForFaShi = 5,
	ExchangeForDaoShi = 6,
}		

local ItemLists = {}
local IndexList = {}
local IsTableViewVisible = {
	[GoodsType.UnBind] = false,
	[GoodsType.Bind] = false,
	[GoodsType.ExchangeForAll] = false,
	[GoodsType.ExchangeForZhanShi] = false,
	[GoodsType.ExchangeForFaShi] = false,
	[GoodsType.ExchangeForDaoShi] = false
}	

local exchangeSub = {	
	[ExchangeSubType.all] = { name = "word_all.png"},	
	[ExchangeSubType.zhanshi] = { name = "word_zhanshi.png"},
	[ExchangeSubType.fashi] = { name = "word_fashi.png"},	
	[ExchangeSubType.daoshi] = 	{ name = "word_daoshi.png"}						
} 

function MallView:__init()
	self.viewName = "MallView"	
	--self:init(CCSizeMake(width,height))
	self:initFullScreen()
	self.selectedCell = 0	
	G_setExchangeItemList()
	local mallMgr = GameWorld.Instance:getMallManager()
	--商品下标列表	
	self.equipSubType = 4
	self.mallType = 1	
	--tableview数据源的类型
	self.eventType = {}
	self.eventType.kTablegrideSizeForIndex = 0
	self.eventType.kgrideSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3

	ItemLists[GoodsType.UnBind] = mallMgr:getUnBindMallList()	
	ItemLists[GoodsType.Bind] = mallMgr:getBindMallList()			
	ItemLists[GoodsType.ExchangeForAll] = mallMgr:getExchangeTotalList()		
	ItemLists[GoodsType.ExchangeForZhanShi] = mallMgr:getSubItemListAndIndexListByTag(1)		
	ItemLists[GoodsType.ExchangeForFaShi] = mallMgr:getSubItemListAndIndexListByTag(2)		
	ItemLists[GoodsType.ExchangeForDaoShi] = mallMgr:getSubItemListAndIndexListByTag(3)			
	
	IndexList[1] = mallMgr:getUnBindMallIndexList()	
	IndexList[2] = mallMgr:getBindMallIndexList()			
	IndexList[3] = mallMgr:getExchangeIndexList()		
	local itemList
	itemList, IndexList[4] = mallMgr:getSubItemListAndIndexListByTag(1)		
	itemList, IndexList[5] = mallMgr:getSubItemListAndIndexListByTag(2)
	itemList, IndexList[6] = mallMgr:getSubItemListAndIndexListByTag(3)

	self.itemViewList = {}
	self.text = {}	
	self.numLb = {}
	self.tableCellList = {}		
	self.subInitTab = true

	
	--页卡
	self:initTabView()	
	self:initStaticView()	
	self:initTableView(1)
	--选中框
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemSelect.png"), grideSize)
	self.cellFrame:retain()
	
	self:initButton()
end	

function MallView:initButton()
	local exchangeMgr = GameWorld.Instance:getExchangeCodeMgr()
	if exchangeMgr:getIsShowExchangeCodeView() then
		local exchangeButton = createButtonWithFramename(RES("btn_1_select.png"))
		local buttonText = createSpriteWithFrameName(RES("word_button_activityCode_exchange.png"))
		exchangeButton:setTitleString(buttonText)
		self:addChild(exchangeButton)
		VisibleRect:relativePosition(exchangeButton, self:getContentNode(), LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-100, 20))
		
		local openExchangeCodeView = function ()
			GlobalEventSystem:Fire(GameEvent.EventOpenExchangeCodeView)	
		end
		exchangeButton:addTargetWithActionForControlEvents(openExchangeCodeView, CCControlEventTouchDown)
	end
end

function MallView:__delete()
	self.cellFrame:release()
	for k , v in pairs(self.itemViewList) do
		v:DeleteMe()
		v = nil
	end
end

function MallView:onEnter(arg)
	if arg then
		self:TabPress(arg)
		self.tabView:setSelIndex(arg-1)
	else
		self:TabPress(1)
		self.tabView:setSelIndex(0)
	end
	if self.mallType < 3 then
		local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
		local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
		local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 		
		self:setYBNum(unbindedGold,bindedGold)
	end			
	mallTableViewList[self.mallType]:scroll2Cell(0, false)		
end

function MallView:UpdateMallCellView(index,ttype)
	if not self.tableCellList then
		self.tableCellList = {}
	end
	if not self.tableCellList[ttype] then
		self.tableCellList[ttype] = {}
	end
	local cellList = self.tableCellList[ttype]
	cellList[index] = self:createTableCell(index,ttype)
	if mallTableViewList[ttype] then
		mallTableViewList[ttype]:updateCellAtIndex(index)	
	end
	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
	local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 
	self:setYBNum(unbindedGold,bindedGold)
	
	self:updateMedalNum()
end

function MallView:updateMedalNum()
	for i = 1,4 do
		if self.numLb[i] then
			local num = self:getMedalNum(i)
			self.numLb[i]:setString(num)
		end
	end
end	

function MallView:UpdateView()
	self:setItemList()		
	for ttype = 1 ,2 do 
		self.tableCellList[ttype] = {}
		if 	mallTableViewList[ttype] then
			mallTableViewList[ttype]:reloadData()
		end		
	end	
end

function MallView:initYbItem(rootNode, object)
	--打折元宝
	local coinSprite = createSpriteWithFileName(ICON("item_unbindedGold"))
	coinSprite:setScale(0.4)
	VisibleRect:relativePosition(coinSprite,rootNode,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-160,-25))			
	rootNode:addChild(coinSprite)
	coinSprite:setColor(ccc3(100,100,100))		
	
	local lineSprite = createSpriteWithFrameName(RES("knight_line.png"))
	VisibleRect:relativePosition(lineSprite,rootNode,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-80,-32))			
	rootNode:addChild(lineSprite) 	
	--打折元宝价格
	local price
	if self.mallType == 1 then
		price = object:getUnBindOriginalPrice()
	elseif self.mallType == 2 then
		price = object:getBindOriginalPrice()
	end
	
	local goldPrice = createLabelWithStringFontSizeColorAndDimension(tostring(price),"Arial",FSIZE("Size3"),FCOLOR("ColorGray3"))
	VisibleRect:relativePosition(goldPrice,coinSprite,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(5,0))								
	rootNode:addChild(goldPrice)
end

function MallView:getRefIdByIndex(index,mallType) 
	if IndexList and  IndexList[mallType] then
		return IndexList[mallType][index]	
	end			
end

function MallView:createItem(index,mallType)
	local size = 0
	local width = 0
	local height = 0
	if mallType < 3 then
		size = grideSize
		width = normalWidth
		height = smallHeight
	else
		size = smallGridSize
		width = smallWidth
		height = normalHeight
	end
	local item = CCNode:create()	
	item:setContentSize(size)	
	local refId = self:getRefIdByIndex(index,mallType)
	if not refId then
		return item
	end
	--获得商品
	local obj = ItemLists[mallType][refId]
	--背景
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("mallCellBg.png"),CCSizeMake(width,height))
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER)			
	item:addChild(cellBg)		
	if mallType < 3 then	
		--蓝色条
		local coinBg = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSizeMake(width,33))
		VisibleRect:relativePosition(coinBg,cellBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(2,-17))			
		cellBg:addChild(coinBg)	
	else
		local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(width-30,2))	
		VisibleRect:relativePosition(line,cellBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(10,-18))			
		cellBg:addChild(line)
	end
	--商品名称
	local goodsName = createLabelWithStringFontSizeColorAndDimension(G_GetItemNameByRefId(obj:getItemId() ),"Arial",FSIZE("Size3"),FCOLOR("ColorPurple2"))
	goodsName:setAnchorPoint(ccp(0,1))
	if mallType < 3 then
		VisibleRect:relativePosition(goodsName,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(130 ,-25))		
	else
		VisibleRect:relativePosition(goodsName,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(30 ,10))
	end							
	cellBg:addChild(goodsName)	
	
	local itemObj = ItemObject.New()
	itemObj:setRefId(obj:getItemId())
	local color = G_getColorByItem(itemObj)
	if color then
		goodsName:setColor(color)	
	end	
	--商品介绍
	local mallMgr = GameWorld.Instance:getMallManager()	
	local itemId = obj:getItemId()
	if mallType < 3 then
		local goodsDes = createLabelWithStringFontSizeColorAndDimension(G_GetItemDescByRefId(obj:getItemId() ),"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"),CCSizeMake(250,0))
		goodsDes:setAnchorPoint(ccp(0,1))
		VisibleRect:relativePosition(goodsDes,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(130,-55))								
		cellBg:addChild(goodsDes)			
	else		
		local fontSize = FSIZE("Size2")
		if itemObj:getType() == ItemType.eItemEquip then		
			local professionId,level = mallMgr:getProfessionAndLevel(itemId)
			local profession = G_getProfessionNameById(professionId)
			local professionTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[5032],"Arial",fontSize,FCOLOR("ColorYellow2"))
			local levelTitle = createLabelWithStringFontSizeColorAndDimension(Config.Words[5031],"Arial",fontSize,FCOLOR("ColorYellow2"))
			local professionLb = createLabelWithStringFontSizeColorAndDimension( profession,"Arial",fontSize,FCOLOR("ColorYellow2"))
			self.levelLb = createLabelWithStringFontSizeColorAndDimension( level,"Arial",fontSize,FCOLOR("ColorYellow2"))
			local name,des = mallMgr:getDescription(itemId)
			des = name..":"..des
			local desLb = createLabelWithStringFontSizeColorAndDimension(des,"Arial",fontSize,FCOLOR("ColorWhite2"),CCSizeMake(width/3*2-2 + 20,0))
			cellBg:addChild(professionTitle)	
			cellBg:addChild(levelTitle)	
			cellBg:addChild(professionLb)	
			cellBg:addChild(self.levelLb)
			cellBg:addChild(desLb)		 
			VisibleRect:relativePosition(levelTitle,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(80,-50))		
			VisibleRect:relativePosition(professionTitle,cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(195,-50))		
			VisibleRect:relativePosition(professionLb,professionTitle,LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE,ccp(3,0))		
			VisibleRect:relativePosition(self.levelLb,levelTitle,LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE,ccp(-5,0))	
			VisibleRect:relativePosition(desLb,levelTitle,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))	
			local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
			--local heroLv = PropertyDictionary:get_level(g_hero:getPT())
			local heroPro = PropertyDictionary:get_professionId(g_hero:getPT())
			--[[if heroLv < level then
				self.levelLb:setColor(FCOLOR("ColorRed2"))
			end--]]
			if heroPro ~= professionId then
				professionLb:setColor(FCOLOR("ColorRed2"))
			end
		else
			local name,des = mallMgr:getDescription(itemId)
			des = name..":"..des
			local desLb = createLabelWithStringFontSizeColorAndDimension(des,"Arial",fontSize,FCOLOR("ColorWhite2"),CCSizeMake(width/3*2-22,0))
			cellBg:addChild(desLb)	
			VisibleRect:relativePosition(desLb,cellBg, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-20, 20))	
		end
		
	end		
			
	if(mallType == 1) then		
		if(obj:getItemSellType() == 3) then			
			self:initYbItem(cellBg, obj)
		end			
		--元宝
		local bindcoinSprite = createSpriteWithFileName(ICON("item_unbindedGold"))
		bindcoinSprite:setScale(0.4)
		VisibleRect:relativePosition(bindcoinSprite,cellBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-80,-25))			
		cellBg:addChild(bindcoinSprite)	
		--价格
		local bindgoldPrice = createLabelWithStringFontSizeColorAndDimension(obj:getUnBindedGold(),"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
		VisibleRect:relativePosition(bindgoldPrice,bindcoinSprite,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(5,0))								
		cellBg:addChild(bindgoldPrice)
	elseif(mallType == 2) then	
		if(obj:getItemSellType() == 3) then	
			self:initYbItem(cellBg, obj)
		end			
		--绑定元宝
		local bindcoinSprite = createSpriteWithFileName(ICON("item_bindedGold"))
		bindcoinSprite:setScale(0.4)
		VisibleRect:relativePosition(bindcoinSprite,cellBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-80,-25))			
		cellBg:addChild(bindcoinSprite)					
		--价格
		local bindgoldPrice = createLabelWithStringFontSizeColorAndDimension(obj:getBindedGold(),"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
		VisibleRect:relativePosition(bindgoldPrice,bindcoinSprite,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(5,0))								
		cellBg:addChild(bindgoldPrice)			
	elseif(mallType >= 3) then	
		local sellTypeList = mallMgr:checkSellType(obj)
		if sellTypeList then
			local count = table.size(sellTypeList)
			for i=1,count do
				local icon = mallMgr:getSellTypeIconByType(sellTypeList[i].type)
				local iconSprite
				if sellTypeList[i].type >=4 and sellTypeList[i].type <=7 then
					iconSprite = createSpriteWithFileName(ICON(icon))
					iconSprite:setScale(0.5)
				else
					iconSprite = createSpriteWithFileName(ICON("item_gold"))
					iconSprite:setScale(0.4)
				end
				cellBg:addChild(iconSprite)	
				VisibleRect:relativePosition(iconSprite,cellBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-60+(i-1)*100,-5))			
				
				local sellPrice = createLabelWithStringFontSizeColorAndDimension(sellTypeList[i].num,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
				cellBg:addChild(sellPrice)
				VisibleRect:relativePosition(sellPrice,iconSprite,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			end	
		end
	end			
			
	--商品背景
	local itemObject = ItemObject.New()
	itemObject:setRefId(obj:getItemId())
	
	local goodsItem = ItemView.New()
	goodsItem:setItem(itemObject)	
	if mallType < 3 then
		VisibleRect:relativePosition(goodsItem:getRootNode(),cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y ,ccp(20,0))			
	else
		VisibleRect:relativePosition(goodsItem:getRootNode(),cellBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(7,-23))			
	end	
	cellBg:addChild(goodsItem:getRootNode())
	itemObject:DeleteMe()
	itemObject = nil
	
	table.insert(self.itemViewList,goodsItem)
	--[[0=普通 1=热卖 2=新品3=打折--]]
	local goodsTypeSpr 
	local ttype = obj:getItemSellType()
	--限购描述
	if mallType == 1 or mallType == 2 then
		--限购数量描述	
		local descStr = self:createString(obj)
		local stringLabel = createLabelWithStringFontSizeColorAndDimension(descStr, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow3"))
		cellBg:addChild(stringLabel)	
		VisibleRect:relativePosition(stringLabel,cellBg, LAYOUT_LEFT_INSIDE, ccp(5, 15))
		--限购时间描述
		local descStrTime = self:createTimeString(obj)
		local timeLabel = createLabelWithStringFontSizeColorAndDimension(descStrTime, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow3"))
		cellBg:addChild(timeLabel)
		--timeLabel:setAnchorPoint(ccp(0, 0.5))
		VisibleRect:relativePosition(timeLabel, cellBg, LAYOUT_LEFT_INSIDE, ccp(240, 15))
	end

	if(ttype ==1) then
		goodsTypeSpr = createSpriteWithFrameName(RES("mall_hotsell.png")) 
	elseif(ttype==2) then
		goodsTypeSpr = createSpriteWithFrameName(RES("mall_newgoods.png")) 
	elseif(ttype==3) then
		goodsTypeSpr = createSpriteWithFrameName(RES("mall_discount.png")) 
	else
	end
	if(goodsTypeSpr) then
		VisibleRect:relativePosition(goodsTypeSpr,cellBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,0))
		cellBg:addChild(goodsTypeSpr)
	end		
	itemObj:DeleteMe()
	return item
end	

function MallView:createString(obj)
	local descStr = ""
	local limitType = obj:getItemLimitType()
	if limitType == 0 then
		descStr = Config.Words[5035]
		return descStr
	elseif limitType == 1 then		
		descStr = Config.Words[5033]
	else
		descStr = Config.Words[5034]
	end
	
	local str = ""
	local number = obj:getNumber()
	if number == 1 then
		descStr = descStr..Config.Words[5036]
	elseif number == 2 then
		descStr = descStr..Config.Words[5037]
	elseif number == 3 then
		descStr = descStr..Config.Words[5038]
	end
	descStr = descStr..Config.Words[5039]	
	local refId = obj:getRefId()
	local maxNum = obj:getMaxNumByRefId(refId)	
	descStr = descStr..maxNum
	descStr = descStr..Config.Words[5040]
	descStr = descStr..Config.Words[5041]	
	local surplusNum = obj:getItemLimitNum()
	descStr = descStr..surplusNum
	descStr = descStr..Config.Words[5040]
	return descStr
end

function MallView:createTimeString(obj)
	local descStr = "" 
	local limitTime = obj:getStoreLimitTime()
	if limitTime == "" then
		descStr = descStr..Config.Words[5043]
		return descStr
	else
		descStr = descStr..Config.Words[5042]..limitTime
		return descStr
	end
end

function MallView:getGoodCount(key)
	if IndexList and IndexList[key] then
		return table.size(IndexList[key])
	end
	return 0
end

function MallView:createTableViewItem(index,key)
	local item = CCNode:create()
	local size = 0
	if key < 3 then
		size = cellSize
	else
		size = smallCellSize
	end
	item:setContentSize(size)	
	local bSingle = false	
	local goodCount = self:getGoodCount(key)
	if 2*index+1 == goodCount then
		bSingle = true
	end	
	local node1 = self:createItem(2*index+1,key)
	node1:setTag(1)
	item:addChild(node1)
	VisibleRect:relativePosition(node1, item, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(10,0))
	if bSingle == false	then
		local node2 = self:createItem(2*(index +1),key)
		item:addChild(node2)
		node2:setTag(2)
		VisibleRect:relativePosition(node2, item, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-10,0))
	end
	item:setTag(CELL_TAG)
	return item
end	

function MallView:initTabView()
	local createBtn = function (BtnName, key)
		local btn = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))
		local label = createLabelWithStringFontSizeColorAndDimension(BtnName, "Arial", FSIZE("Size3"),FCOLOR("ColorWhite1"))--CCLabelTTF:create(BtnName, "", FSIZE("Size3"))
		btn:addChild(label)
		VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)
		
		onTabPress = function ()		
			self:TabPress(key)
		end
		btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		return btn
	end
	
	local btnArray = CCArray:create()
	local button = nil
	local buttonName = nil
	for key,v in ipairs(mallName) do
		buttonName = v.name
		button = createBtn(buttonName, key)
		if button then
			btnArray:addObject(button)
		end
	end
	self.tabView = createTabView(btnArray, 10, tab_horizontal)
	self:addChild(self.tabView)
	VisibleRect:relativePosition(self.tabView, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(43,0))
end

function MallView:setItemList()
	local mallMgr = GameWorld.Instance:getMallManager()
	ItemLists[GoodsType.UnBind] = mallMgr:getUnBindMallList()	
	ItemLists[GoodsType.Bind] = mallMgr:getBindMallList()			
	ItemLists[GoodsType.ExchangeForAll] = mallMgr:getExchangeTotalList()		
	ItemLists[GoodsType.ExchangeForZhanShi] = mallMgr:getSubItemListAndIndexListByTag(1)		
	ItemLists[GoodsType.ExchangeForFaShi] = mallMgr:getSubItemListAndIndexListByTag(2)		
	ItemLists[GoodsType.ExchangeForDaoShi] = mallMgr:getSubItemListAndIndexListByTag(3)	
	
	IndexList[1] = mallMgr:getUnBindMallIndexList()	
	IndexList[2] = mallMgr:getBindMallIndexList()			
	IndexList[3] = mallMgr:getExchangeIndexList()		
	local itemList
	itemList, IndexList[4] = mallMgr:getSubItemListAndIndexListByTag(1)		
	itemList, IndexList[5] = mallMgr:getSubItemListAndIndexListByTag(2)
	itemList, IndexList[6] = mallMgr:getSubItemListAndIndexListByTag(3)		
end		

function MallView:TabPress(index)
	local professionList = {
		[1] = ExchangeSubType.zhanshi - 1,
		[2] = ExchangeSubType.fashi  - 1,
		[3] = ExchangeSubType.daoshi - 1,
	}

	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local professionId = PropertyDictionary:get_professionId(g_hero:getPT())	
	
	
	if index == 3 then
		index = index + subTabprofessionList[professionId]	
	end	
	self.mallType = index
	
	local mgr = GameWorld.Instance:getMallManager()
	mgr:setOpenMallType(self.mallType)
			
	local tableView 
	for k, v in pairs(GoodsType) do	
		if self.mallType == v then		
			if not mallTableViewList[v] then
				self:initTableView(v)
			end		
			tableView = mallTableViewList[v]
			tableView:scroll2Cell(0, false)	
			if self.cellFrame and self.cellFrame.setVisible  then
				self.cellFrame:setVisible(false)
			end		
			if tableView and tableView.setVisible then
				tableView:setVisible(true)			
			end	
			self:setItemList()
			if not IsTableViewVisible[v] then
				self.tableCellList[self.mallType] = {}						
				tableView:reloadData()
			end	
			IsTableViewVisible[v] = true		
			
			if self.mallType >= 3 then
				if self.mallNode  and self.mallNode.setVisible then
					self.mallNode:setVisible(false)
				end
				if 	self.exchangeNode and self.exchangeNode.setVisible then
					self.exchangeNode:setVisible(true)	
				end	
				if self.exchangeSubTab then				
					self.exchangeSubTab:setSelIndex(professionList[professionId])
				end					
			else
				if self.mallNode  and self.mallNode.setVisible then
					self.mallNode:setVisible(true)
				end
				if 	self.exchangeNode and self.exchangeNode.setVisible then
					self.exchangeNode:setVisible(false)	
				end				
				local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
				local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 
				self:setYBNum(unbindedGold,bindedGold)	
			end
		else
			tableView = mallTableViewList[v]	
			if tableView then		
				tableView:setVisible(false)
			end
		end	
	end				
end

function MallView:setScroll2Cell(professionId)		
	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local heroprofessionId = PropertyDictionary:get_professionId(g_hero:getPT())
	local herolevel = PropertyDictionary:get_level(g_hero:getPT())
	
	local professionindex = subTabprofessionList[self.malltype]
		
	if professionindex ~= heroprofessionId then
		return
	end
	
	local mallMgr = GameWorld.Instance:getMallManager()	
	
	local saveLevel = 0
	local saveIndex = 0
	for i=1,table.size(ItemLists[self.malltype]) do
		local refId = self:getRefIdByIndex(i,self.malltype)
		local obj = ItemLists[self.malltype][refId]	
		if obj then
			local itemId = obj:getItemId()
			local professionId,level = mallMgr:getProfessionAndLevel(itemId)
			
			if level<=herolevel and level~=saveLevel then
				saveLevel = level
				saveIndex = i
			elseif level>herolevel then
				break
			end				
		end		
	end
	
	if saveIndex>1 then
		if saveIndex%2~=0 then
			saveIndex = saveIndex +1
		end
		local index = math.floor(saveIndex/2)-1
		mallTableViewList[self.mallType]:scroll2Cell(index, false)
	end	
end

function MallView:createTableCell(index,key)
	local cell = SFTableViewCell:create()
	cell:setContentSize(VisibleRect:getScaleSize(grideSize))
	local item = self:createTableViewItem(index,key)
	cell:addChild(item)
	cell:setIndex(index)
	return cell
end

function MallView:createDataSource(count,key, handlFunc)
	local dataSourceFunc = function(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local size = 0
		if self.mallType < 3 then
			size = grideSize
		else
			size = exchangeGridSize
		end
		if eventType == self.eventType.kTablegrideSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(size))
			return 1
		elseif eventType == self.eventType.kgrideSizeForTable then
			data:setSize(VisibleRect:getScaleSize(size))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			local cellList = self.tableCellList[key]
			if not cellList then
				cellList = {}
			end
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(size))
				local item = handlFunc(index,key)
				cell:addChild(item)
				cell:setIndex(index)
				data:setCell(cell)
				cellList[index] = cell
			else
				if 	cellList[index] then
					data:setCell(cellList[index])
				else
					tableCell:removeAllChildrenWithCleanup(true)
					tableCell:setContentSize(VisibleRect:getScaleSize(size))
					local item = handlFunc(index,key)
					tableCell:addChild(item)					
					tableCell:setIndex(index)					
					data:setCell(tableCell)	
					cellList[index] = tableCell
				end
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then			
			data:setIndex(count)
			return 1
		end
	end		
	return dataSourceFunc
end  

function MallView:getTableCellNum(index)
	local Num = 0			
	local listNum = self:getGoodCount(index)	
	if(listNum%2 == 0) then
		Num = listNum/2
	else
		Num = (listNum+1)/2
	end			
	return Num
end

function MallView:tableDelegate(tableP, cell, x, y)
	cell = tolua.cast(cell,"SFTableViewCell")		
	local item = cell:getChildByTag(CELL_TAG)	
	local cellIndex = cell:getIndex()	
	self.selectedCell = cellIndex
	local count = item:getChildren():count()
	local touchPoint = ccp(x,y)		
	local refId, childItem, rect, obj, limitDate, cDate
	local num = 1	
	for i = 1, count do 
		childItem = item:getChildByTag(i)		
		rect = childItem:boundingBox()
		if rect:containsPoint(touchPoint) then 	
								
			self.curIndex = cellIndex*2 + i				
			refId = self:getRefIdByIndex(self.curIndex,self.mallType)
			obj = ItemLists[self.mallType][refId]
			if obj then
				local itemObj = GameData.PropsPurchase[obj:getItemId()]
				if itemObj then
					num = itemObj.defaultNumber
				end
			end
			if self.mallType == 1 or self.mallType == 2 then	
				self.cellFrame:setContentSize(grideSize)				
				limitDate = obj:getStoreLimitTime()
				if(limitDate ~= "" ) then
					cDate = os.date("%Y%m%d",systime)
					if( cDate < limitDate ) then  --没过期
						GlobalEventSystem:Fire(GameEvent.EventBuyItem,obj,num,"mall")											
					else
						UIManager.Instance:showSystemTips(Config.Words[5024])
					end	
				else
					GlobalEventSystem:Fire(GameEvent.EventBuyItem,obj,num,"mall")		
				end	
			elseif self.mallType >= 3  and self.mallType <= 6 then		
				self.cellFrame:setContentSize(CCSizeMake(smallWidth,150))		
				GlobalEventSystem:Fire(GameEvent.EventBuyItem, obj,1,"shop")				
			end				
			--选中框
			if(self.cellFrame:getParent() == nil) then
				childItem:addChild(self.cellFrame)				
				VisibleRect:relativePosition(self.cellFrame, childItem, LAYOUT_CENTER)
			else 
				self.cellFrame:removeFromParentAndCleanup(true)				
				childItem:addChild(self.cellFrame)					
				VisibleRect:relativePosition(self.cellFrame, childItem, LAYOUT_CENTER)
			end		
		end
	end			
	return 1
end

function MallView:initStaticView()
	--顶部商城标题		
	self:setFormImage(createSpriteWithFrameName(RES("main_mall.png")))
	self:setFormTitle(createSpriteWithFrameName(RES("word_window_mall.png")), TitleAlign.Left)						

	
	self.mallNode = CCNode:create()
	self.exchangeNode = CCNode:create()
	self.mallNode:setContentSize(CCSizeMake(width-42,height-69))
	self.exchangeNode:setContentSize(CCSizeMake(width-42,height-69))
	self:addChild(self.mallNode)
	self:addChild(self.exchangeNode)
	VisibleRect:relativePosition(self.mallNode,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-20))
	VisibleRect:relativePosition(self.exchangeNode,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-20))
	
	local centelBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(840,390))
	self.mallNode:addChild(centelBg)
	VisibleRect:relativePosition(centelBg,self:getContentNode(),LAYOUT_CENTER,ccp(-20,8))	

	--背景		
	local mallTableBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(self:getContentNode():getContentSize().width-3,380)) 
	VisibleRect:relativePosition(mallTableBg,self.mallNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-7))
	self.mallNode:addChild(mallTableBg)
	
		
	self.exchangeAllBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(834,410))
	VisibleRect:relativePosition(self.exchangeAllBg,self.exchangeNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-5))
	self.exchangeNode:addChild(self.exchangeAllBg)
	self.exchangeBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"),CCSizeMake(639,396))
	VisibleRect:relativePosition(self.exchangeBg,self.exchangeAllBg,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-7,-8))
	self.exchangeNode:addChild(self.exchangeBg)
	
	
	self.exchangeNode:setVisible(false)
	self:addBottomInfo()
	self:exchangeSubTab()			
end

function MallView:initTableView(index)
--	print("initTableView index="..index)
	local createFunc = function(i, key)
		return self:createTableViewItem(i, key)
	end		
			
	local tableDelegate = function (tableP,cell,x,y)
		self:tableDelegate(tableP, cell, x, y)
	end		

	self.tableCellList[index] = {}

	local num = self:getTableCellNum(index)
	local dateSource = self:createDataSource(num, index, createFunc)
	local tableView = createTableView(dateSource, VisibleRect:getScaleSize(CCSizeMake(width, 370)))
	tableView:setTableViewHandler(tableDelegate)
	tableView:reloadData()
	tableView:scroll2Cell(0, false)
	self:addChild(tableView)
	if self.mallType ~= index then
		tableView:setVisible(false)
	else
		IsTableViewVisible[index] = true
	end	
	if index < 3 then			
		VisibleRect:relativePosition(tableView, self:getContentNode(), LAYOUT_CENTER, ccp(-4, 10))	
	else
		VisibleRect:relativePosition(tableView, self.exchangeBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(1, -25))	
	end
	mallTableViewList[index] = tableView			
end
--[[
["bindedGold"] = {icon = "item_bindedGold" ,scale = 0.3 },
["unbindedGold"] = {icon = "item_unbindedGold" ,scale = 0.3 },
]]
function MallView:addBottomInfo()
	if self.mallNode then
		--底部元宝背景
		local ybBg = CCNode:create()
		ybBg:setContentSize(CCSizeMake(425,33))
		VisibleRect:relativePosition(ybBg,self:getContentNode(),LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,5))
		self.mallNode:addChild(ybBg)
		
		local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
		local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
		local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 
		
		--绑定元宝icon
		local bindIcon = createSpriteWithFileName(ICON("item_bindedGold"))
		VisibleRect:relativePosition(bindIcon,ybBg,LAYOUT_CENTER,ccp(30,0))
		bindIcon:setScale(0.4)
		self.mallNode:addChild(bindIcon)

		--元宝数量BG
		local bybBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),CCSizeMake(150,25))
		VisibleRect:relativePosition(bybBg,bindIcon,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))
		self.mallNode:addChild(bybBg)
		
		--元宝数量		
		self.bindYbNum = createLabelWithStringFontSizeColorAndDimension(unbindedGold,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
		self.bindYbNum:setAnchorPoint(ccp(0,0.5))
		VisibleRect:relativePosition(self.bindYbNum,bybBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(5,0))
		self.mallNode:addChild(self.bindYbNum)	
		--元宝icon
		local unbindIcon = createSpriteWithFileName(ICON("item_unbindedGold"))
		unbindIcon:setScale(0.4)		
		VisibleRect:relativePosition(unbindIcon,ybBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(10,0))
		self.mallNode:addChild(unbindIcon)
		--元宝数量BG
		local ubybBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),CCSizeMake(150,25))
		VisibleRect:relativePosition(ubybBg,unbindIcon,LAYOUT_RIGHT_OUTSIDE+ LAYOUT_CENTER_Y,ccp(10,0))
		self.mallNode:addChild(ubybBg)
		--元宝数量	
		self.YbNum = createLabelWithStringFontSizeColorAndDimension(bindedGold,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
		self.YbNum:setAnchorPoint(ccp(0,0.5))
		VisibleRect:relativePosition(self.YbNum,ubybBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(5,0))
		self.mallNode:addChild(self.YbNum)			

		--底部充值按钮
		local chargeBt = createButtonWithFramename(RES("btn_1_select.png"))
		VisibleRect:relativePosition(chargeBt,self:getContentNode(),LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-20,-5))	
		chargeBt:setScale(scale)
		self.mallNode:addChild(chargeBt)
		
		local chargeText = createSpriteWithFrameName(RES("word_button_recharge.png"))
		chargeBt:setTitleString(chargeText)
		local chargeFunc = function()	
			local pay = function (tag, state)
				if tag == "pay" then 	
					if state == 1 then 
						CCLuaLog("success")			
					else
						CCLuaLog("fail")
					end
				end
			end
			G_getHero():getRechargeMgr():openPay(pay)

		end
		chargeBt:addTargetWithActionForControlEvents(chargeFunc,CCControlEventTouchDown)
		
		--元宝比例
		local proportionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25606], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
		self.mallNode:addChild(proportionLabel)
		VisibleRect:relativePosition(proportionLabel, chargeBt, LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE, ccp(-10, 0))
	end
	if self.exchangeNode then
		local ybBg = CCNode:create()
		ybBg:setContentSize(CCSizeMake(width,33))
		VisibleRect:relativePosition(ybBg,self:getContentNode(),LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(0,0))
		self.exchangeNode:addChild(ybBg)
		for i = 1,4 do
			local medalIcon = createSpriteWithFileName(ICON(exchangeUse[i].icon))
			medalIcon:setScale(0.5)
			VisibleRect:relativePosition(medalIcon,ybBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(35+(i-1)*200,0))
			self.exchangeNode:addChild(medalIcon)
			--牌子数量BG
			local numBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),CCSizeMake(100,25))
			VisibleRect:relativePosition(numBg,medalIcon,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))	
			self.exchangeNode:addChild(numBg)
			--牌子数量
			local num = self:getMedalNum(i)
			self.numLb[i] = createLabelWithStringFontSizeColorAndDimension(num,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
			self.numLb[i]:setAnchorPoint(ccp(0,0.5))
			VisibleRect:relativePosition(self.numLb[i],numBg,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE,ccp(4,0))
			self.exchangeNode:addChild(self.numLb[i])	
		end
	end
end	

function MallView:getMedalNum(medalType)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	if medalType == MedalType.eGold then
		local goldMedal 	= bagMgr:getItemNumByRefId(exchangeUse[medalType].refId)
		return goldMedal
	elseif medalType == MedalType.eSilver then
		local silverMedal = bagMgr:getItemNumByRefId(exchangeUse[medalType].refId)
		return silverMedal 
	elseif medalType == MedalType.eCopper then
		local copperMedal 	= bagMgr:getItemNumByRefId(exchangeUse[medalType].refId)
		return copperMedal
	elseif medalType == MedalType.eIron then
		local ironMedal 	= bagMgr:getItemNumByRefId(exchangeUse[medalType].refId)
		return ironMedal
	end
end

function MallView:create()
	return MallView.New()
end

function MallView:subTabPress(index)
	local tableViewIndex = index + 3
	if tableViewIndex == 7 then
		tableViewIndex = 3
	end	
	self.mallType = tableViewIndex
	for k, v in pairs(GoodsType) do
		if tableViewIndex == v then	
			if not mallTableViewList[tableViewIndex] then
				self:initTableView(tableViewIndex, tableViewIndex)
			end
			if (not IsTableViewVisible[tableViewIndex])  then			
				mallTableViewList[tableViewIndex]:reloadData()
				IsTableViewVisible[tableViewIndex] = true
			end
			mallTableViewList[tableViewIndex]:setVisible(true)
		else
			if mallTableViewList[v] then 
				mallTableViewList[v]:setVisible(false)
			end
		end
	end
	
	self:setScroll2Cell(index)
end

function MallView:exchangeSubTab()
	local btnArray = CCArray:create()	
	local mallMgr = GameWorld.Instance:getMallManager()	
	local function createBtn(keys, values)
		values.btn = createButtonWithFramename(RES("rank_nomal_btn.png"), RES("rank_select_btn.png"))												
		self.text[keys] = createSpriteWithFrameName(RES(values.name))							
		values.btn:setTitleString(self.text[keys])			
		btnArray:addObject(values.btn)
		local onTabPress = function()
			self:subTabPress(keys)
		end	
		values.btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
	end
	for keys,values in ipairs(exchangeSub) do	
		createBtn(keys, values)
	end
	self.exchangeSubTab = createTabView(btnArray,5*scale,tab_vertical)
	self.subTabViewBg = createScale9SpriteWithFrameName(RES("squares_formBg2.png"))
	self.subTabViewBg:setContentSize(CCSizeMake(176,396))
	self.exchangeNode: addChild(self.subTabViewBg,20)
	self.exchangeNode: addChild(self.exchangeSubTab,20)
	VisibleRect:relativePosition(self.subTabViewBg,self.exchangeAllBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(6,-8))
	VisibleRect:relativePosition(self.exchangeSubTab,self.subTabViewBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(0,-10))
end

function MallView:setYBNum(ybNum,bYbNum)
	if self.bindYbNum then
		self.bindYbNum:setString(bYbNum)
	end
	if 	self.YbNum then
		self.YbNum:setString(ybNum) 	
	end
end

function MallView:updateYbNum()
	local g_hero = GameWorld.Instance:getEntityManager(	):getHero()
	local unbindedGold 	= PropertyDictionary:get_unbindedGold(g_hero:getPT())
	local bindedGold  	= PropertyDictionary:get_bindedGold(g_hero:getPT())	 
	self:setYBNum(unbindedGold,bindedGold)
end