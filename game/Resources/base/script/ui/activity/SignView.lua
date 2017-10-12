require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.mall.MallDef")
require("object.mall.MallObject")
require("object.bag.BagDef")
require("ui.utils.ItemView")


SignView = SignView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local grideSize = VisibleRect:getScaleSize(CCSizeMake(150,100))
local cellSize = VisibleRect:getScaleSize(CCSizeMake(60,60))

local scale = VisibleRect:SFGetScale()
local width = 875
local height = 550

function SignView:__init()
	self.viewName = "SignView"	
	self:initFullScreen()
	self.selectedCell = 0	
	--tableview数据源的类型
	self.eventType = {}	
	self.count = 5
	self.itemView = {}
	self:initValue()
	self:initStaticView()
	self:initDaylyView()	
end

function SignView:__delete()
	local itemRootNode
	for key,v in pairs(self.itemView) do
		if v then
			itemRootNode = v:getRootNode()
			if itemRootNode then
				itemRootNode:removeFromParentAndCleanup(true)
			end
			v:DeleteMe()
		end
	end
	if  self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end
	self.itemView = {}
end

function SignView:initValue()
	self.eventType.kTablegrideSizeForIndex = 0
	self.eventType.kgrideSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3	
	
	local signSprite = createSpriteWithFrameName(RES("ui_sin_selectcycle.png"))	
	self.signBatchNode = CCSpriteBatchNode:createWithTexture(signSprite:getTexture(),31)
	self.signBatchNode:setContentSize(CCSizeMake(width,height))
	self.signBatchNode:setZOrder(2)
	self:addChild(self.signBatchNode)			
	VisibleRect:relativePosition(self.signBatchNode,self:getContentNode(),LAYOUT_CENTER)
	
	self.numberNode = CCNode:create()
	self.numberNode:setContentSize(CCSizeMake(width,height))
	self.numberNode:setZOrder(1)
	self:addChild(self.numberNode)
	VisibleRect:relativePosition(self.numberNode,self:getContentNode(),LAYOUT_CENTER)
		
	
end


function SignView:initStaticView()
	--已签到次数
	self:setFormImage( createSpriteWithFrameName(RES("main_activityAssign.png")))
	self:setFormTitle( createSpriteWithFrameName(RES("main_activityAssign_word.png")),TitleAlign.Left)	
	
	local centelViewBgSprite =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(centelViewBgSprite)	
	VisibleRect:relativePosition(centelViewBgSprite, self:getContentNode(), LAYOUT_CENTER)
	
	--背景
	self.leftBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(668, 469))
	VisibleRect:relativePosition(self.leftBg,centelViewBgSprite,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(8,12))
	self:addChild(self.leftBg)
	
	--本月签到标签
	local signLable = createSpriteWithFrameName(RES("word_sign_topsigncountText.png"))
	VisibleRect:relativePosition(signLable,self.leftBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-20,-15))
	self:addChild(signLable)

	self.signCountLabel = createAtlasNumber(Config.AtlasImg.NumberColor,0)
	self:addChild(self.signCountLabel)		
		
	--dayly 背景
	self.daylyBg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(648, 312))	
	self:addChild(self.daylyBg)	
	VisibleRect:relativePosition(self.daylyBg,centelViewBgSprite,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(19,120))	
	
	local StartY = 70
	for i = 1 ,4 do
		local divideLine = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"),CCSizeMake(655, 3))
		self:addChild(divideLine)
		VisibleRect:relativePosition(divideLine,self.daylyBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,-StartY))
		StartY =  StartY + 60	
	end	
	
	--table 背景
	self.tabBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(139, 469))	
	self:addChild(self.tabBg)
	VisibleRect:relativePosition(self.tabBg,centelViewBgSprite,LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(-10,12))
	
	local tableTitleBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(150, 35))
	VisibleRect:relativePosition(tableTitleBg,self.tabBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
	self:addChild(tableTitleBg)
	
	local tableTitle = createSpriteWithFrameName(RES("word_sign_signtotalText.png"))
	VisibleRect:relativePosition(tableTitle,self.tabBg,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,-5))
	self:addChild(tableTitle)
	
	
	self:createAwardTable()

	--补签提示
	self.fillSignTips = createLabelWithStringFontSizeColorAndDimension(" ", "Arial",FSIZE("Size3"), FCOLOR("ColorYellow1"))
	VisibleRect:relativePosition(self.fillSignTips,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE,ccp(-207,-78))
	self:addChild(self.fillSignTips)	

--	self:setDate("","")
		
	self:showDaylyAward()
	self:updateButton()
end

function SignView:UpdateCellView()
	self.awardTable:updateCellAtIndex(self.selectedCell)
end

function SignView:UpdateAwardView()
	self.awardTable:reloadData()
end

function SignView:createTableViewItem(index)
	
	local signMgr = GameWorld.Instance:getSignManager()	
	local awardList = signMgr:getAwardList()
	local item = CCNode:create()
	item:setContentSize(grideSize)
	
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("bagBatch_itemBg.png"),cellSize)
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE,ccp(0,-10))
	item:addChild(cellBg)
	
	local giftIconName = "item_gift_" .. index+1
	local signRefId = "sign_"..(index+2)		
		
	local giftSprite = createSpriteWithFileName(ICON(giftIconName))	
--[[	local stateTextDesc = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"), FCOLOR("ColorYellow3"))
	VisibleRect:relativePosition(stateTextDesc,item,LAYOUT_CENTER,ccp(-10,-15))	
	item:addChild(stateTextDesc)	--]]
	if giftSprite then
		if awardList[signRefId] == nil  or awardList[signRefId] == SignAwardState.unableGet then
			UIControl:SpriteSetGray(giftSprite)		
		end		
		item:addChild(giftSprite)
		VisibleRect:relativePosition(giftSprite,cellBg,LAYOUT_CENTER)	
	end
	
	if awardList[signRefId] == SignAwardState.canGet then
		local scaleTo = CCScaleTo:create(0.3,1.3)
		local scaleBack = CCScaleTo:create(0.3,1)
		local actionArray = CCArray:create()
		actionArray:addObject(scaleTo)	
		actionArray:addObject(scaleBack)
		local repeatForever = CCRepeatForever:create(CCSequence:create(actionArray))
		giftSprite:runAction(repeatForever)	
	end
			
	if awardList[signRefId] == SignAwardState.hadGet then		
		local hadGetSpr = createSpriteWithFrameName(RES("hadReceivedLable.png"))
		hadGetSpr:setScale(0.8)
		hadGetSpr:setRotation(-30)
		item:addChild(hadGetSpr)
		VisibleRect:relativePosition(hadGetSpr,cellBg,LAYOUT_CENTER)		
	end
	
	local signCountCon = G_getSignCountReq(signRefId)
	
	local textDesc = createSpriteWithFrameName(RES("word_signcount.png"))
	item:addChild(textDesc)
	VisibleRect:relativePosition(textDesc,item,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(0,5))
	local offsetX = 0
	if signCountCon < 10 then
		offsetX = 10
	end
	local CountLabel = createAtlasNumber(Config.AtlasImg.NumberColor,signCountCon)
	item:addChild(CountLabel)		
	VisibleRect:relativePosition(CountLabel,item,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(63 + offsetX,0))
	
	return item
end

function SignView:updateSignView()
	self:initDaylyView()
	local signMgr = GameWorld.Instance:getSignManager()
	local signList = signMgr:getSignList()
	for k,v in pairs(signList) do
		if v == true then
			self:signGrideByIndex(k)
		end
	end		
	
	self:UpdateAwardView()
	self:updateButton()
end

function SignView:signGrideByIndex(index)
	local signSprite = createSpriteWithFrameName(RES("ui_sin_selectcycle.png"))
	self.signBatchNode:addChild(signSprite)
	local col = (index-1)%7
	local row = math.ceil(index/7)
	signSprite:setPosition(ccp(85 +  col*85 + 20,455 - row*58 + 20))
	local sprite = self.numberNode:getChildByTag(index)
	sprite = tolua.cast(sprite,"CCSprite")
	sprite:setColor(ccc3(255,255,255))
	self:updateButton()
end	

function SignView:initDaylyView()
	local signMgr = GameWorld.Instance:getSignManager()
	local dayCount = signMgr:getDaysOfMonth()
	local currentDay = signMgr:getCurrentDay()
	if self.signBatchNode then
		self.signBatchNode:removeAllChildrenWithCleanup(true)
	end
	
	if self.numberNode then
		self.numberNode:removeAllChildrenWithCleanup(true)
	end 
	
	if dayCount > 0 then

		for i = 1 ,dayCount do
			local textlabel = createAtlasNumber(Config.AtlasImg.NumberWhite,i)
			local col = (i-1)%7
			local row = math.ceil((i)/7)
			textlabel:setTag(i)
			local offsetX = 0
			if i < 10 then
				offsetX = 10
			end
			textlabel:setPosition(ccp(85 +  col*85 + offsetX,455 - row*58))
			if i < currentDay then
				textlabel:setColor(ccc3(100,100,100))
			end
			self.numberNode:addChild(textlabel)
		end	
	end
end
--[[
function SignView:setDate(year,month)
	-- 年月
	if self.dateLabel then
		self.dateLabel:setString(year .. Config.Words[13121] .. month ..  Config.Words[13122])
	else
		self.dateLabel = createLabelWithStringFontSizeColorAndDimension(year .. Config.Words[13121] .. month ..  Config.Words[13122] , "Arial",FSIZE("Size3"), FCOLOR("ColorBlack1"))		
		VisibleRect:relativePosition(self.dateLabel,self:getContentNode(),LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X ,ccp(-50,-60))
		self.rootNode:addChild(self.dateLabel)			
	end		
end--]]

function SignView:setSignCount(count)
	--count = 25
	if self.signCountLabel then
		local offsetX = 0
		if count >= 10 then
			offsetX = 9
		end				
		self.signCountLabel:setString(count)
		VisibleRect:relativePosition(self.signCountLabel,self.leftBg,LAYOUT_RIGHT_INSIDE + LAYOUT_TOP_INSIDE,ccp(-58 + offsetX,-10))	
	end			
end

function SignView:createAwardTable()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTablegrideSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kgrideSizeForTable then
			data:setSize(VisibleRect:getScaleSize(grideSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(grideSize))
				local item = self:createTableViewItem(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(grideSize))
				tableCell:setIndex(index+1)
				local item = self:createTableViewItem(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then			
			data:setIndex(4)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		cell = tolua.cast(cell,"SFTableViewCell")
		local cellIndex = cell:getIndex()	
		self.selectedCell = cellIndex - 1	
		
		local signMgr = GameWorld.Instance:getSignManager()	
		local awardList = signMgr:getAwardList()
		local signRefId = "sign_"..(cellIndex+1)		
	
		if awardList[signRefId] == nil  or awardList[signRefId] == SignAwardState.unableGet then	
			self:showDayAwardTips(cellIndex , x ,y)
			--UIManager.Instance:showSystemTips(Config.Words[13118])
		elseif awardList[signRefId] == SignAwardState.hadGet then			
			UIManager.Instance:showSystemTips(Config.Words[13119])
		else
			signMgr:requestGetReward(signRefId)
		end						
		return 1
	end
	
	--创建tableview
	self.awardTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(150, 400)))	
	self.awardTable:setTableViewHandler(tableDelegate)
	self.awardTable:reloadData()
	self.awardTable:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.awardTable)
	VisibleRect:relativePosition(self.awardTable, self:getContentNode(), LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(0,48))		
end

function SignView:updateButton()
	--底部按钮
	self.daylyBg:removeChildByTag(10,true)
	self.daylyBg:removeChildByTag(11,true)
	local signMgr = GameWorld.Instance:getSignManager()		
	if  signMgr:getFillSignState() then	
		self.fillSignTips:setString(Config.Words[13124])			
		local fillSignBt = createButtonWithFramename(RES("btn_1_select.png"))
		fillSignBt:setTag(10)
		local textlabel =  createSpriteWithFrameName(RES("Retroactive.png"))
		fillSignBt:addChild(textlabel)		
		VisibleRect:relativePosition(textlabel,fillSignBt,LAYOUT_CENTER)
		self.daylyBg:addChild(fillSignBt)	
		VisibleRect:relativePosition(fillSignBt,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-145,-13))
				
		local fillSignFunc = function()
			signMgr:requestSign(2)			
		end
		fillSignBt:addTargetWithActionForControlEvents(fillSignFunc,CCControlEventTouchDown)								
	else			
		local fillSignBt = createButtonWithFramename(RES("btn_1_disable.png"))
		fillSignBt:setTag(10)
		local textlabel =  createSpriteWithFrameName(RES("word_button_hasFillSign.png"))
		fillSignBt:addChild(textlabel)		
		VisibleRect:relativePosition(textlabel,fillSignBt,LAYOUT_CENTER)
		self.daylyBg:addChild(fillSignBt)	
		VisibleRect:relativePosition(fillSignBt,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE ,ccp(-145,-13))
		local fillSignTipsFunc = function()
			UIManager.Instance:showSystemTips(Config.Words[13120])	
		end
		fillSignBt:addTargetWithActionForControlEvents(fillSignTipsFunc,CCControlEventTouchDown)			
	end			

	--底部按钮	
	if  signMgr:canNormalSign() then				
		local signBt = createButtonWithFramename(RES("btn_1_select.png"))
		signBt:setTag(11)
		local textlabel =createSpriteWithFrameName(RES("sign_and_receive.png"))
		signBt:addChild(textlabel)
		VisibleRect:relativePosition(textlabel,signBt,LAYOUT_CENTER)
		self.daylyBg:addChild(signBt)
		VisibleRect:relativePosition(signBt,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE ,ccp(0,-13))		
		local signFunc = function()
			signMgr:requestSign(1)			
		end
		signBt:addTargetWithActionForControlEvents(signFunc,CCControlEventTouchDown)							
	else
		local signSprite = createButtonWithFramename(RES("btn_1_disable.png"))
		signSprite:setTag(11)
		local textlabel = createSpriteWithFrameName(RES("word_button_hassign.png"))
		signSprite:addChild(textlabel)
		VisibleRect:relativePosition(textlabel,signSprite,LAYOUT_CENTER)			
		self.daylyBg:addChild(signSprite)
		VisibleRect:relativePosition(signSprite,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE ,ccp(0,-13))					
		local signTipsFunc = function()
			UIManager.Instance:showSystemTips(Config.Words[13125])		
		end
		signSprite:addTargetWithActionForControlEvents(signTipsFunc,CCControlEventTouchDown)		
	end			
end

function SignView:create()
	return SignView.New()
end

function SignView:onEnter()
	self:UpdateAwardView()
end



function SignView:showDaylyAward()
	local itemAward,propertyAward = G_GetSignAwardListByRefId("sign_1")
	
	local startX = 0
	if itemAward ~= nil then	--道具奖励
		for k,v in pairs(itemAward) do
			
			--[[local cellBg = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
			self.daylyBg:addChild(cellBg)
			VisibleRect:relativePosition(cellBg,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(startX,-10))
			
			local itemBox = G_createItemBoxByRefId(v.itemRefId)
			cellBg:addChild(itemBox)
			VisibleRect:relativePosition(itemBox,cellBg,LAYOUT_CENTER)

			local nameLabel = createLabelWithStringFontSizeColorAndDimension("X"..tostring(v.itemCount), "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
			if nameLabel then
				itemBox:addChild(nameLabel)
				VisibleRect:relativePosition(nameLabel,itemBox, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(0,-5))				
			end--]]
			local itemBoxShow = G_createItemShowByItemBox(v.itemRefId,v.itemCount,nil,nil,nil,-1)
			self.daylyBg:addChild(itemBoxShow)
			VisibleRect:relativePosition(itemBoxShow,self.daylyBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(startX,-10))
			startX = startX + 89
		end
	end
	
	if propertyAward ~= nil then	--属性奖励
		for k,v in pairs(propertyAward) do
			local propBox = G_createUnPropsItemBox(k)
			VisibleRect:relativePosition(propBox,self:getContentNode(),LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(startX,10))			
			self:addChild(propBox)
			startX = startX + 89
		end
	end		
end

function SignView:showDayAwardTips(index, x, y)
	self:getContentNode():removeChildByTag(100,true)
	local itemAward,propertyAward = G_GetSignAwardListByRefId("sign_" .. index + 1)	
	local node = CCNode:create()
	node:setContentSize(CCSizeMake(150,100))
	node:setTag(100)
	self:addChild(node,2)
	local bg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(150,100))
	node:addChild(bg)
	VisibleRect:relativePosition(bg ,node,LAYOUT_CENTER)
	VisibleRect:relativePosition(node ,self.tabBg,LAYOUT_LEFT_OUTSIDE + LAYOUT_BOTTOM_INSIDE,ccp(10, visibleSize.height - index*100 - 250))
	
	local lableStr  = " "
	local nameStr  = " "
	local height = 10
		
	if itemAward ~= nil then	--道具奖励	
		for k,v in pairs(itemAward) do	
			nameStr = G_getStaticPropsName(v.itemRefId)
			lableStr = nameStr  .."X" ..  v.itemCount	
			local numberLabel = createLabelWithStringFontSizeColorAndDimension(lableStr,"Arial",FSIZE("Size2"),FCOLOR("ColorGreen1"),CCSizeMake(150,0))			
			node:addChild(numberLabel)
			VisibleRect:relativePosition(numberLabel,node,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,-height))			
			height = height + 20
		end
	end
	
	if propertyAward ~= nil then	--属性奖励
		for k,v in pairs(propertyAward) do
			nameStr = G_getStaticUnPropsName(k)
			lableStr = nameStr  .."+" ..  v	
			local numberLabel = createLabelWithStringFontSizeColorAndDimension(lableStr,"Arial",FSIZE("Size2"),FCOLOR("ColorGreen1"),CCSizeMake(150,0))			
			node:addChild(numberLabel)
			VisibleRect:relativePosition(numberLabel,node,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,-height))			
			height = height + 20
		end
	end	
	local scheduleCallback = function()
		self:getContentNode():removeChildByTag(100,true)
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end			
	if  not self.scheduleId then
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 1.5, false)
	else
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 1.5, false)
	end
end
