require("ui.UIManager")
require("common.BaseUI")
require("object.activity.DiscountSellStaticData")

DiscountSellView = DiscountSellView or BaseClass(BaseUI)
local bgSize = CCSizeMake(836, 423)
local tableSize = CCSizeMake(810, 240)
local cellSize = CCSizeMake(810, tableSize.height/2)
local subCellSize = CCSizeMake(400, 110)
local CellTag = 100
local sellOutZ_order = 100
local IconTag = 120

function DiscountSellView:__init()
	self.viewName = "DiscountSellView"
	self:initFullScreen()
	self.purchaseLabel = {}	
	self.purchasePersonLabel = {}
	
	self.timerId = -1
	
	g_hero = GameWorld.Instance:getEntityManager():getHero()	
	g_discountSellMgr = GameWorld.Instance:getDiscountSellMgr()
	
	self:initData()
	self:createStaticView()
	self:createCountDown()
	self:createTableView()
	self:createMyGold()
	self:createRechargeBtn()
end

function DiscountSellView:__delete()
	if self.selectFrame then 
		self.selectFrame:release()
	end	
	self:removeTimer()
end

function DiscountSellView:onEnter()
	g_discountSellMgr:requestGetDiscountSellList()
	self:updateMyGold()
	self:startTimer()
end

function DiscountSellView:onExit()
	self:removeTimer()
end

function DiscountSellView:create()
	return DiscountSellView.New()
end	

function DiscountSellView:createStaticView()
	--标题	
	local icon =createSpriteWithFrameName(RES("main_activityDiscountSell.png"))	
	self:setFormImage(icon)				
	--标题文字	
	local discountTitleText = createSpriteWithFrameName(RES("word_window_discount.png"))
	self:setFormTitle(discountTitleText, TitleAlign.Left)
	
	--背景
	local bg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"), bgSize)
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -5))
	
	--活动图
	self.activityBg = CCSprite:create("ui/ui_img/activity/discount_Advertisement.pvr")
	self:addChild(self.activityBg)
	VisibleRect:relativePosition(self.activityBg, bg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -8))
	
	--倒计时背景
	self.timeBg = createScale9SpriteWithFrameNameAndSize(RES("common_wordBg.png"), CCSizeMake(330, 30))
	self.timeBg:setRotation(180)
	self:addChild(self.timeBg)
	VisibleRect:relativePosition(self.timeBg, self.activityBg, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-2, 0))	
	
	self.selectFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bg3.png"), CCSizeMake(subCellSize.width, subCellSize.height+5))
	self.selectFrame:retain()
end


function DiscountSellView:updateMyGold()
	--更新元宝
	if self.unbindedGoldLabel then
		local unbindedGoldValue = PropertyDictionary:get_unbindedGold(g_hero:getPT())		
		self.unbindedGoldLabel:setString(unbindedGoldValue)
		VisibleRect:relativePosition(self.unbindedGoldLabel, self.unbindedGoldBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	end
	
	--更新金币
	if self.goldLabel then
		local goldValue = PropertyDictionary:get_gold(g_hero:getPT())		
		self.goldLabel:setString(goldValue)
		VisibleRect:relativePosition(self.goldLabel, self.goldBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	end
end

--限购已售完返回
function DiscountSellView:doSoldOutBySever(refId)
	local index = self:findListIndex(refId)
	local nowValue = 0
	self:updateItemLimitNum(index,refId,nowValue)		
end

function DiscountSellView:doUpdateAllDataBySever()
	self:initData()
	self.tasktable:reloadData()
end

--购买成功返回
function DiscountSellView:doBuySuccessBySever(refId,buyNum)
	local index = self:findListIndex(refId)
	local nowLeftValue = self.discountSellList[index]["leftNumber"]-buyNum
	local nowLeftPersonValue = self.discountSellList[index]["personLeftNumber"]-buyNum
	
	g_discountSellMgr:setSellListLimitNum(index,nowLeftValue)
	g_discountSellMgr:setSellListPersonLimitNum(index,nowLeftPersonValue)
		
	self:updateItemLimitNum(index,refId,nowLeftValue,nowLeftPersonValue)		
end

--更新限购次数
function DiscountSellView:updateItemLimitNum(index,refId,nowLeftValue,nowLeftPersonValue)
	if self.purchaseLabel[index] and self.purchasePersonLabel[index] then		
		local maxValie = DiscountSellStaticData:getItemLimitNum(refId)
		local word = Config.Words[17103]..nowLeftValue.."/"..maxValie
		self.purchaseLabel[index]:setString(word)
		
		local maxPersonValie = DiscountSellStaticData:getItemLimitNum(refId)
		local Personword = Config.Words[17107]..nowLeftPersonValue.."/"..maxPersonValie
		self.purchasePersonLabel[index]:setString(Personword)
		
		self.tasktable:reloadData()
	end	
end

function DiscountSellView:updateSeverTimeOut()
	self:removeTimer()	
	if self.countDownLabel then
		self.countDownLabel:setString(Config.Words[17106])
	end	
end

function DiscountSellView:initData()
	self.discountSellList = g_discountSellMgr:getDiscountSellList()	
	self.discountSellListCount = table.size(self.discountSellList)	
	self.rebackTime = g_discountSellMgr:getLeftTime()
	self.curSel = 1
end

--倒计时
function DiscountSellView:createCountDown()
	local countDownTime = g_discountSellMgr:getLeftTime()
	
	self.countDownLabel = createRichLabel(CCSizeMake(285,0))	
	self.countDownLabel:setFontSize(FSIZE("Size3"))		
	
	--self.countDownLabel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size4"),FCOLOR("ColorYellow5"))
	self:addChild(self.countDownLabel)		
	
	if countDownTime and countDownTime~=0 then	
		self.rebackTime = countDownTime					
		local timeWord = self:getTimeWord(self.rebackTime)
		self.countDownLabel:clearAll()
		self.countDownLabel:appendFormatText(timeWord)		
		
		--self:startTimer()
	else
		self.countDownLabel:clearAll()
		self.countDownLabel:appendFormatText(Config.Words[17106])
	end
	VisibleRect:relativePosition(self.countDownLabel, self.timeBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE)	
end

function DiscountSellView:getTimeWord(time)
	local s_sec,s_min,s_hour,s_day = G_GetSecondsToDateString(time)
	s_day = string.wrapRich(s_day, Config.FontColor["ColorRed1"], FSIZE("Size3"))
	s_hour = string.wrapRich(s_hour, Config.FontColor["ColorRed1"], FSIZE("Size3"))
	s_min = string.wrapRich(s_min, Config.FontColor["ColorRed1"], FSIZE("Size3"))
	s_sec = string.wrapRich(s_sec, Config.FontColor["ColorRed1"], FSIZE("Size3"))
	local timeWordText = Config.Words[17100]..s_day..Config.Words[13007]..s_hour..Config.Words[13208]..s_min..Config.Words[13209]..s_sec..Config.Words[13210]
	local timeWord = string.wrapRich(timeWordText, Config.FontColor["ColorWhite2"], FSIZE("Size3"))
	return timeWord
end	

function DiscountSellView:startTimer()
	if self.rebackTime and self.rebackTime~=0 and self.timerId==-1 then
		if self.timerFunc == nil then
			self.timerFunc = function ()	
				self.rebackTime = self.rebackTime - 1
				g_discountSellMgr:setLeftTime(self.rebackTime)
				
				if self.countDownLabel then				
					local timeWord = self:getTimeWord(self.rebackTime)
					self.countDownLabel:clearAll()
					self.countDownLabel:appendFormatText(timeWord)
				end
				
				if self.rebackTime == 0 then
					self:handleTimeout()
					self:removeTimer()	
				end
			end
		end
		self.timerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(self.timerFunc, 1, false)
	end
end

function DiscountSellView:handleTimeout()
	local onMsgBoxCallBack = function(unused, text, id)
		if (id == 0) then
			self:close()
		end
	end
	local btns ={
	{text = Config.LoginWords[10043], id = 0},	
	}	
	
	local msg = showMsgBox(Config.Words[17108])
	msg:setBtns(btns)
	msg:setNotify(onMsgBoxCallBack)		
end

function DiscountSellView:removeTimer()
	if type(self.timerId) == "number" and self.timerId ~= -1 then	
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
		self.timerId = -1
	end
end

function DiscountSellView:createTableView()
	local tableViewBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(tableSize.width+12, tableSize.height+10))
	self:addChild(tableViewBg)
	VisibleRect:relativePosition(tableViewBg, self.activityBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(0, -5))
	--定义
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	
	local dataHandlerfunc = function(eventType,tableP,index,data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(cellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(cellSize)
			return 1
		elseif eventType == kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if not tableCell then
				local cell = SFTableViewCell:create()
				cell:setContentSize(cellSize)
				cell:setIndex(index)
				--self:showCell(cell,index+1)
				local item = self:createCellItem(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item, cell, LAYOUT_CENTER)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(cellSize)
				--self:showCell(tableCell,index+1)
				local item = self:createCellItem(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item, tableCell, LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			
			return 1
		elseif eventType == kNumberOfCellsInTableView then				
			data:setIndex(self:getCellCnt())
			return 1
		end
	end	
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self:clickCell(cell, x, y)		
	end
	
	self.tasktable = createTableView(dataHandlerfunc, tableSize)
	self.tasktable:setTableViewHandler(tableDelegate)	
	self:addChild(self.tasktable)	
	VisibleRect:relativePosition(self.tasktable, tableViewBg, LAYOUT_CENTER)	
	self.tasktable:reloadData()
	self.tasktable:scroll2Cell(0, false)
end

function DiscountSellView:getCellCnt()
	local cnt = math.modf((self.discountSellListCount-1)/2)+1
	return cnt
end

function DiscountSellView:clickCell(cell, x, y)
	local item = cell:getChildByTag(CellTag)
	if item == nil  then 
		return
	end
	local cellIndex = cell:getIndex()	
	local count = item:getChildren():count()
	local touchPoint = ccp(x,y)		
	for i = 1, count do 		
		local subItem = item:getChildByTag(i)
		local rect = subItem:boundingBox()
		if rect:containsPoint(touchPoint) then		
			self.curSel = cellIndex*2+i
			if self.selectFrame and self.selectFrame:getParent() then
				self.selectFrame:removeFromParentAndCleanup(true)
			end
			subItem:addChild(self.selectFrame)
			VisibleRect:relativePosition(self.selectFrame, subItem, LAYOUT_CENTER)
			break
		end
	end
end

function DiscountSellView:createCellItem(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)
	item:setTag(CellTag)	
	local realIndex = index * 2
	if realIndex+1 > self.discountSellListCount then
		return item
	end
	local subItem1 = self:createSubCellItem(realIndex)
	if subItem1 then
		subItem1:setTag(1)
		item:addChild(subItem1)
		VisibleRect:relativePosition(subItem1, item, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(0, 0))
		if (realIndex+2) > self.discountSellListCount then 
			return item
		end
		local subItem2 = self:createSubCellItem(realIndex+1)
		subItem2:setTag(2)
		item:addChild(subItem2)
		VisibleRect:relativePosition(subItem2, item, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(0, 0))
	end	
	return item
end

function DiscountSellView:createSubCellItem(index)
	index = index + 1
	local item = CCNode:create()
	item:setContentSize(subCellSize)
	local discountItemRefid = self.discountSellList[index]["refId"]
	local discountleftNumber = self.discountSellList[index]["leftNumber"]
	local discountpersonLeftNumber = self.discountSellList[index]["personLeftNumber"]
	
	local cellBg =  createScale9SpriteWithFrameNameAndSize(RES("mallCellBg.png"),subCellSize)
	item:addChild(cellBg)
	VisibleRect:relativePosition(cellBg, item, LAYOUT_CENTER)
		
	local itemBg = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
	item:addChild(itemBg)
	VisibleRect:relativePosition(itemBg,item, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(10,0))
	
	local clickCallBack = function (refId)
		for idx, v in pairs(self.discountSellList) do 
			local curRefId = DiscountSellStaticData:getItemId(v.refId)
			if curRefId == refId then
				--local cellIndex = math.modf((idx-1)/2)
				--local cellItem = self.tasktable:cellAtIndex(cellIndex)
				--local realIdx = math.mod(idx, 2)
				--if cellItem then 
				--	self.curSel = idx
					--local subCellItem = cellItem:getChildByTag(realIdx+1)
					--if subCellItem then					
						self:showSelectFrame(item)
					--end
				--end
				break
			end
		end
	end
	--道具图标		
	local itemRefid = DiscountSellStaticData:getItemId(discountItemRefid)
	if not itemRefid then
		CCLuaLog("Error ：createSubCellItem  itemRefid is nil，Refid is :"..discountItemRefid)
		return
	end
	local itemBox = G_createItemBoxByRefId(itemRefid, false, clickCallBack,-1)	
	itemBox:setTag(IconTag)
	item:addChild(itemBox)
	VisibleRect:relativePosition(itemBox,itemBg, LAYOUT_CENTER)
	
	--道具名称
	local itemName = G_getStaticDataByRefId(itemRefid)["property"]["name"]
	local itemObject = ItemObject.New()
	itemObject:setRefId(itemRefid)
	local color = G_getColorByItem(itemObject)
	local itemNameLabel = createLabelWithStringFontSizeColorAndDimension(itemName,"Arial",FSIZE("Size3"), color)
	item:addChild(itemNameLabel)
	VisibleRect:relativePosition(itemNameLabel,itemBox, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER, ccp(20, 27))
	
	--原价		
	local originalPriceValue = DiscountSellStaticData:getOriginalsalePrice(discountItemRefid)
	local originalPriceCompany = self:getOriginalsalePriceCompany(discountItemRefid)	
	local originalPriceCompanyLabel = createLabelWithStringFontSizeColorAndDimension(originalPriceCompany..": ","Arial",FSIZE("Size3"),FCOLOR("ColorYellow3"))
	item:addChild(originalPriceCompanyLabel)
	VisibleRect:relativePosition(originalPriceCompanyLabel,itemNameLabel, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))	
	local originalPriceLabel = createLabelWithStringFontSizeColorAndDimension(originalPriceValue,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow3"))
	item:addChild(originalPriceLabel)
	VisibleRect:relativePosition(originalPriceLabel,originalPriceCompanyLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER)
	local originalPriceLabelSize = originalPriceLabel:getContentSize()
	local orgLine = createScale9SpriteWithFrameNameAndSize(RES("price_nick.png"), CCSizeMake(originalPriceLabelSize.width, 2))
	orgLine:setRotation(10)
	item:addChild(orgLine)	
	VisibleRect:relativePosition(orgLine, originalPriceLabel, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y, ccp(-2, 0))
	
	--折扣价
	local discountPriceValue = DiscountSellStaticData:getSalePrice(discountItemRefid)
	local salePriceCompany = self:getSalePriceCompany(discountItemRefid)
	local discountPriceCompanyLabel = createLabelWithStringFontSizeColorAndDimension(salePriceCompany..": ","Arial",FSIZE("Size3"),FCOLOR("ColorYellow4"))
	item:addChild(discountPriceCompanyLabel)
	VisibleRect:relativePosition(discountPriceCompanyLabel,originalPriceCompanyLabel, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -10))
	local discountPriceLabel = createLabelWithStringFontSizeColorAndDimension(discountPriceValue,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow4"))
	item:addChild(discountPriceLabel)
	VisibleRect:relativePosition(discountPriceLabel,discountPriceCompanyLabel,  LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER)
		
	--购买按钮	
	local buyBtn = createButtonWithFramename(RES("btn_1_select.png"))			
	item:addChild(buyBtn)
	VisibleRect:relativePosition(buyBtn,item, LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE ,ccp(-10,-3))
	
	local buyBtnWord = createSpriteWithFrameName(RES("word_buynow.png"))
	if discountleftNumber==0 or discountpersonLeftNumber==0 then
		local graySprite = createSpriteWithFrameName(RES("btn_1_select.png"))
		UIControl:SpriteSetGray(buyBtnWord)
		UIControl:SpriteSetGray(graySprite)
		buyBtn:addChild(graySprite)
		VisibleRect:relativePosition(graySprite, buyBtn, LAYOUT_CENTER)
		buyBtn:setEnable(false)			
	end	
	
	buyBtn:addChild(buyBtnWord)	
	VisibleRect:relativePosition(buyBtnWord,buyBtn, LAYOUT_CENTER, ccp(0,0))
	
	local buyBtnfunc = function ()
		local obj = MallObject.New()
		obj:setRefId(discountItemRefid)
		obj:setItemId(itemRefid)
		obj:setStoreType("discount")
		local companyType = DiscountSellStaticData:getSalePriceType(discountItemRefid)
		if companyType == 1  then
			obj:setUnBindedGold(discountPriceValue)			
		elseif companyType == 2 then
			obj:setCoinPrice(discountPriceValue)
		end		
		
		
		local discountleftNumber = self.discountSellList[index]["leftNumber"]
		local discountpersonLeftNumber = self.discountSellList[index]["personLeftNumber"]			
		local buyNum = 1 
		if 	discountleftNumber >= discountpersonLeftNumber then
			buyNum = discountpersonLeftNumber
		else
			buyNum = discountleftNumber
		end
		obj:setItemLimitNum(buyNum)	
		GlobalEventSystem:Fire(GameEvent.EventBuyItem,obj,buyNum,"discount")	
		
		self.curSel = index
		self:showSelectFrame(item)	
	end
	buyBtn:addTargetWithActionForControlEvents(buyBtnfunc, CCControlEventTouchDown)
	
	--本次限购
	local nowLeftValue = discountleftNumber
	local maxLeftValie = DiscountSellStaticData:getItemLimitNum(discountItemRefid)
	local purchaseWord = Config.Words[17103]..nowLeftValue.."/"..maxLeftValie
	self.purchaseLabel[index] = createLabelWithStringFontSizeColorAndDimension(purchaseWord,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow4"))
	item:addChild(self.purchaseLabel[index])
	VisibleRect:relativePosition(self.purchaseLabel[index], buyBtn, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(0, 2))
	
	--个人限购
	local nowPersonLeftValue = discountpersonLeftNumber
	local maxPersonLeftValie = DiscountSellStaticData:getItemPersonLimitNum(discountItemRefid)
	local purchasePersonWord = Config.Words[17107]..nowPersonLeftValue.."/"..maxPersonLeftValie
	self.purchasePersonLabel[index] = createLabelWithStringFontSizeColorAndDimension(purchasePersonWord,"Arial",FSIZE("Size2"),FCOLOR("ColorYellow4"))
	item:addChild(self.purchasePersonLabel[index])
	VisibleRect:relativePosition(self.purchasePersonLabel[index],self.purchaseLabel[index], LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE)
	
	if self.curSel == index then
		self:showSelectFrame(item)
	end
	
	if discountleftNumber== 0 then 
		local sellOut = createSpriteWithFrameName(RES("discount_sellOut.png"))		
		item:addChild(sellOut, sellOutZ_order)
		VisibleRect:relativePosition(sellOut, item, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(10, 10))
	end
	return item
end

--创建金钱
function DiscountSellView:createMyGold()
	--元宝
	local unbindedGoldIcon = createScale9SpriteWithFrameName(RES("common_iocnWind.png"))
	self:addChild(unbindedGoldIcon)	
	VisibleRect:relativePosition(unbindedGoldIcon, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(20, 20))
	
	self.unbindedGoldBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),	CCSizeMake(150,25))
	self:addChild(self.unbindedGoldBg)
	VisibleRect:relativePosition(self.unbindedGoldBg, unbindedGoldIcon, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(20, 0))
	
	local unbindedGoldValue = PropertyDictionary:get_unbindedGold(g_hero:getPT())	
	self.unbindedGoldLabel = createLabelWithStringFontSizeColorAndDimension(unbindedGoldValue,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(self.unbindedGoldLabel)	
	VisibleRect:relativePosition(self.unbindedGoldLabel, self.unbindedGoldBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	
	--金币
	local goldIcon = createScale9SpriteWithFrameName(RES("common_iocnGold.png"))
	self:addChild(goldIcon)	
	VisibleRect:relativePosition(goldIcon, unbindedGoldIcon, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER, ccp(200, 0))
	
	self.goldBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),	CCSizeMake(150,25))
	self:addChild(self.goldBg)
	VisibleRect:relativePosition(self.goldBg, goldIcon, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(20, 0))
	
	local goldValue = PropertyDictionary:get_gold(g_hero:getPT())	
	self.goldLabel = createLabelWithStringFontSizeColorAndDimension(goldValue,"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self:addChild(self.goldLabel)	
	VisibleRect:relativePosition(self.goldLabel, self.goldBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
end	

--充值
function DiscountSellView:createRechargeBtn()
	local rechargeBtn = createButtonWithFramename(RES("btn_1_select.png"))			
	self:addChild(rechargeBtn)
	VisibleRect:relativePosition(rechargeBtn,self:getContentNode(), LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE ,ccp(-20,-3))
		
	local rechargeBtnWord = createSpriteWithFrameName(RES("word_button_discountRecharge.png"))
	rechargeBtn:addChild(rechargeBtnWord)
	VisibleRect:relativePosition(rechargeBtnWord,rechargeBtn, LAYOUT_CENTER, ccp(0,0))
	
	local rechargeBtnfunc =function ()	
		local pay = function (tag, state)
			if tag == "pay" then 	
				if state == 1 then 
					CCLuaLog("success")			
				else
					CCLuaLog("fail")
				end
			end
		end
		local rechargeMgr = G_getHero():getRechargeMgr()
		rechargeMgr:openPay(pay)
	end
	rechargeBtn:addTargetWithActionForControlEvents(rechargeBtnfunc, CCControlEventTouchDown)
end

function DiscountSellView:findListIndex(refId)
	for i,v in pairs(self.discountSellList) do
		local discountItemRefid = v["refId"]
		local discountleftNumber = v ["leftNumber"]
		if discountItemRefid == refId then
			return i
		end
	end
end

function DiscountSellView:showSelectFrame(parent)
	if self.selectFrame and self.selectFrame:getParent() then 
		self.selectFrame:removeFromParentAndCleanup(true)
	end
	parent:addChild(self.selectFrame, sellOutZ_order- 1)
	VisibleRect:relativePosition(self.selectFrame, parent, LAYOUT_CENTER)
end

--获取原价的单位
function DiscountSellView:getOriginalsalePriceCompany(refid)
	local companyType = DiscountSellStaticData:getgetOriginalsalePriceType(refid)
	local value = self:getCompanyValue(companyType)
	return value
end

--获取原价的单位
function DiscountSellView:getSalePriceCompany(refid)
	local companyType = DiscountSellStaticData:getSalePriceType(refid)
	local value = self:getCompanyValue(companyType)
	return value
end

function DiscountSellView:getCompanyValue(companyType)
	local value
	if companyType == 1  then
		value = Config.Words[570] --元宝
	elseif companyType == 2 then
		value = Config.Words[10118] --金币
	end
	return value
end