
require("ui.UIManager")
require("common.BaseUI")
require("ui.utils.ItemView")

local cellSize = VisibleRect:getScaleSize(CCSizeMake(647,51))

RankListView = RankListView or BaseClass(BaseUI)

local rankType = {
	[0] = "fightRankName.png",
	[1] = "levelRankName.png",
	[2] = "richRankName.png",
	[3] = "knightRankName.png",
	[4] = "wingRankName.png",
	[5] = "rideRankName.png",
	[6] = "talismanRankName.png",
}

local RankType = {
	fight = 0,
	level = 1,
	rich = 2,
	knight = 3,
	wingLevel = 4,
	rideLevel = 5,
	talisman = 6, 
}

local limitRankTypeList = {
[1] = "fightRankName.png",
[2] = "levelRankName.png",
[3] = "wingRankName.png",
[4] = "rideRankName.png",
}

local limitRankTypeRequestList = {
[1] = 1,
[2] = 2,
[3] = 5,
[4] = 6,
}

local attrType = {
	[0] = Config.Words[16107],
	[1] = Config.Words[16108],
	[2] = Config.Words[16109],
	data = {[0]= Config.Words[16110],[1]=Config.Words[16111],[2]=Config.Words[16112],[3]=Config.Words[16113],[4]=Config.Words[16114],[5]=Config.Words[16115],[6]=Config.Words[16116]}
}

local selectList = {
	[0] = Config.Words[16117],
	[1] = Config.Words[16118],
	[2] = Config.Words[16119],
	[3] = Config.Words[16120],
}

local attrName = {
	[0] = "level",
	[1] = "nickName",
	[2] = "profession",
	[3] = "data"
}			

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local viewScale = VisibleRect:SFGetScale()
function RankListView:__init()
	
	self.viewName = "RankListView"
	self.attrNameLable = {}
	self.myRankLable = {}		
	self.selectWhich = nil
	self.selectedLimitRankType = 1	
	self.preIndex = 0
	self.eventType = {}	
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3		
	self:initUI()
		
--Juchao@20140628: 将tableView的点击事件屏蔽，有可能导致tableView再也不能点击，因为loading的回调不可靠
--现在已经将延迟showLoading的机制去掉，所以loading能在下一帧马上挡住点击事件。
--[[				
	local hudCalback = function ()
	self.leftTableView:setTouchEnabled(true)
	end
	self:showLoadingHUD(0.6, hudCalback)	
	self.leftTableView:setTouchEnabled(false)
--]]
	self:showLoadingHUD(0.6)					
end

function RankListView:__delete()
	if type(self.itemView) == "table" then
		for key,v in pairs(self.itemView) do
			if v then
				itemRootNode = v:getRootNode()
				if itemRootNode then
					itemRootNode:removeFromParentAndCleanup(true)
				end
				v:DeleteMe()
			end
		end
	end
	self.itemView = {}
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)  	
		self.scheduleId = nil
	end	
end


function RankListView:create()
	return RankListView.New()
end

function RankListView:initUI()
	self:initWindow()
end

function RankListView:initWindow()
	local const_size = CCSizeMake(833,459)
	
	self:initFullScreen()	
	
	self.mainBg = createScale9SpriteWithFrameName(RES("squares_bg2.png"))
	self.mainBg:setContentSize(const_size)
	self:addChild(self.mainBg)
	VisibleRect:relativePosition(self.mainBg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER)

	self.rankNode = CCNode:create()
	self.rankNode:setContentSize(const_size) 	
	self.mainBg:addChild(self.rankNode)
	VisibleRect:relativePosition(self.rankNode,self.mainBg,LAYOUT_CENTER,ccp(0,0))	
	
	self.leftBg = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.leftBg:setContentSize(CCSizeMake(175,441))
	self.rankNode:addChild(self.leftBg)
	VisibleRect:relativePosition(self.leftBg,self.rankNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(9,-9))
	self:initLeft()
	
	self.righBg = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.righBg:setContentSize(CCSizeMake(639,441))	
	self.leftBg:addChild(self.righBg)
	VisibleRect:relativePosition(self.righBg,self.leftBg,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_OUTSIDE,ccp(6,0))
	self:initRight()
	
	self.limitNode = CCNode:create()
	self.limitNode:setContentSize(const_size) 	
	self.mainBg:addChild(self.limitNode)
	VisibleRect:relativePosition(self.limitNode,self.mainBg,LAYOUT_CENTER)
	self:initLimitRankNode()
	self:createFPSubTabView()
end

function RankListView:showRankNode()
	self.rankNode:setVisible(true)	
	self.limitNode:setVisible(false)
	local titleSign = createSpriteWithFrameName(RES("main_activityRange.png"))	
	self:setFormImage(titleSign)	
	
	local titleName = createSpriteWithFrameName(RES("arenaTitle.png"))
	self:setFormTitle(titleName, TitleAlign.Left)
	
	local rankListMgr = GameWorld.Instance:getRankListManager()
	rankListMgr:setCurRankType(0)
end

function RankListView:showLimitRankNode()
	self:TabPress(1)
	if self.selectTableView then
		self.selectTableView:setVisible(false)	
	end	
	self.rankBtn:setVisible(true)
	self.limitRankBtn:setVisible(true)
	self.rankNode:setVisible(false)	
	self.limitNode:setVisible(true)	
	self.tabTitle:setSelIndex(1)
	local titleSign = createSpriteWithFrameName(RES("main_activityLimitTimeRank.png"))	
	self:setFormImage(titleSign)	
	
	local titleName = createSpriteWithFrameName(RES("word_window_limittimerank.png"))
	self:setFormTitle(titleName, TitleAlign.Left)	
	self.subType = nil	
	self.selectedLimitRankType = 1
	self.limitrankTypeTable:reloadData()		
end

function RankListView:initLimitRankNode()
	
	self.limitTabBg = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.limitTabBg:setContentSize(CCSizeMake(175,430))
	VisibleRect:relativePosition(self.limitTabBg,self.limitNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(9,-9))				
	self.limitNode:addChild(self.limitTabBg)

	self.limitTableBg = createScale9SpriteWithFrameName(RES("squares_bg3.png"))
	self.limitTableBg:setContentSize(CCSizeMake(638,430))	
	VisibleRect:relativePosition(self.limitTableBg,self.limitNode,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-7,-9))
	self.limitNode:addChild(self.limitTableBg)
	
	local titleBg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(638,29))
	self.limitTableBg:addChild(titleBg)
	VisibleRect:relativePosition(titleBg,self.limitTableBg,LAYOUT_CENTER + LAYOUT_TOP_INSIDE,ccp(0,0))
		
	self.limitRankBtn = createButton(createScale9SpriteWithFrameNameAndSize(RES("tab_2_normal.png"),CCSizeMake(50,100)),createScale9SpriteWithFrameNameAndSize( RES("tab_2_select.png"),CCSizeMake(40,100)))
	local limitLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[13618],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite3"),CCSizeMake(30,0))
	self.limitRankBtn:addChild(limitLabel)		
	VisibleRect:relativePosition(limitLabel,self.limitRankBtn,LAYOUT_CENTER,ccp(10,0))	
	
	self.rankBtn = createButton(createScale9SpriteWithFrameNameAndSize(RES("tab_2_normal.png"),CCSizeMake(50,100)),createScale9SpriteWithFrameNameAndSize( RES("tab_2_select.png"),CCSizeMake(40,100)))
	local rankLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[13619],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite3"),CCSizeMake(30,0))
	self.rankBtn:addChild(rankLabel)		
	VisibleRect:relativePosition(rankLabel,self.rankBtn,LAYOUT_CENTER,ccp(10,0))

	local rankBtnFunc = function()	
		self:showRankNode()	
		local rankListMgr = GameWorld.Instance:getRankListManager()	
		self.fpSubTabView:setVisible(true)
		self.fpSubTabView:setSelIndex(3)
		rankListMgr:requestVersionNum(0)		
		self.leftTableView:reloadData()			
	end
	self.rankBtn:addTargetWithActionForControlEvents(rankBtnFunc,CCControlEventTouchDown)

	self.disRankBtn = createButton(createScale9SpriteWithFrameNameAndSize(RES("tab_2_normal.png"),CCSizeMake(50,100)),createScale9SpriteWithFrameNameAndSize( RES("tab_2_select.png"),CCSizeMake(40,100)))
	local rankLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[13619],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite3"),CCSizeMake(30,0))
	self.disRankBtn:addChild(rankLabel)		
	VisibleRect:relativePosition(rankLabel,self.disRankBtn,LAYOUT_CENTER,ccp(10,0))

	local disRankBtnFunc = function()	
		UIManager.Instance:showSystemTips(Config.Words[16121])			
	end
	self.disRankBtn:addTargetWithActionForControlEvents(disRankBtnFunc,CCControlEventTouchDown)	
	self.mainBg:addChild(self.disRankBtn,2)	
	VisibleRect:relativePosition(self.disRankBtn, self.mainBg, LAYOUT_LEFT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(0,-133))		
		
	local limitRankBtnFunc = function()		
		self:showLimitRankNode()
	end
	self.limitRankBtn:addTargetWithActionForControlEvents(limitRankBtnFunc,CCControlEventTouchDown)		
	local titleTabArray = CCArray:create()
	titleTabArray:addObject(self.rankBtn)	
	titleTabArray:addObject(self.limitRankBtn)
	self.tabTitle = createTabView(titleTabArray, 10*viewScale, tab_vertical)
	self.mainBg:addChild(self.tabTitle)
	VisibleRect:relativePosition(self.tabTitle, self.mainBg, LAYOUT_LEFT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(0,-23))		
	self.tabTitle:setSelIndex(1)	
	
		
	--名次
	local rankHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[13602],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite2"))
	titleBg:addChild(rankHead)	
	VisibleRect:relativePosition(rankHead,titleBg,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE,ccp(55,0))
			
	--奖励
	local awardHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[13603],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite2"))
	titleBg:addChild(awardHead)	
	VisibleRect:relativePosition(awardHead,titleBg,LAYOUT_CENTER + LAYOUT_LEFT_INSIDE,ccp(310,0))

	local tipsBg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(455,85))
	self.limitTableBg:addChild(tipsBg)
	VisibleRect:relativePosition(tipsBg,self.limitTableBg,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(17,14))	

	
	--向上箭头
	self.updirectTips = createSpriteWithFrameName(RES("directtips.png"))
	self.limitTableBg:addChild(self.updirectTips,1)
	self.updirectTips:setRotation(180)
	VisibleRect:relativePosition(self.updirectTips,self.limitTableBg,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(-55,-30))
	
	--向下箭头
	self.downdirectTips = createSpriteWithFrameName(RES("directtips.png"))
	self.limitTableBg:addChild(self.downdirectTips,1)
	VisibleRect:relativePosition(self.downdirectTips,self.limitTableBg,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(-55,130))		
	
	self.downdirectTips:setVisible(false)
	self.updirectTips:setVisible(false)	
	
	local myRankTextHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[13601],"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
	tipsBg:addChild(myRankTextHead)	
	VisibleRect:relativePosition(myRankTextHead,tipsBg,LAYOUT_TOP_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(10,0))
	
	self.myLimitRank =  createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
	myRankTextHead:addChild(self.myLimitRank)
	VisibleRect:relativePosition(self.myLimitRank,myRankTextHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(0,0))
	--tips
	self.rankTypeTips = createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	myRankTextHead:addChild(self.rankTypeTips)		
	VisibleRect:relativePosition(self.rankTypeTips,myRankTextHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER,ccp(125,0))
	
	--活动时间：
	self.endTimeLabel =  createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
	self.endTimeLabel:setAnchorPoint(ccp(0,0.5))
	tipsBg:addChild(self.endTimeLabel)	
	VisibleRect:relativePosition(self.endTimeLabel,tipsBg,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,-5))
	--剩余时间
	local restTimeHeadLabel =  createLabelWithStringFontSizeColorAndDimension(Config.Words[13620],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite2"))
	tipsBg:addChild(restTimeHeadLabel)
	VisibleRect:relativePosition(restTimeHeadLabel,self.endTimeLabel,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-2))		

	self.restTimeLabel =  createLabelWithStringFontSizeColorAndDimension(" ","Arial",FSIZE("Size2"),FCOLOR("ColorGreen1"))
	self.restTimeLabel:setAnchorPoint(ccp(0,0.5))
	tipsBg:addChild(self.restTimeLabel)	
	VisibleRect:relativePosition(self.restTimeLabel,restTimeHeadLabel,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER,ccp(10,0))
	
	--tips
	local tipsLabel =  createLabelWithStringFontSizeColorAndDimension(Config.Words[13624],"Arial",FSIZE("Size4"),FCOLOR("ColorWhite2"))
	tipsBg:addChild(tipsLabel)
	VisibleRect:relativePosition(tipsLabel,tipsBg,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,5))
	--充值按钮
	--[[local chargeBtn = createButton(createScale9SpriteWithFrameName(RES("btn_1_select.png")))
	local rechargeBtnWord = createSpriteWithFrameName(RES("word_button_recharge.png"))
	chargeBtn:setTitleString(rechargeBtnWord)
	self.limitTableBg:addChild(chargeBtn)
	VisibleRect:relativePosition(chargeBtn,self.limitTableBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-14,27))
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
	chargeBtn:addTargetWithActionForControlEvents(chargeFunc,CCControlEventTouchDown)	--]]
	self:createBtn()
	
	self:createLimitTabView()	
end

function RankListView:createBtn()
	self.normalBtn = createButtonWithFramename(RES("btn_1_select.png"))
	self.disBtn = createButtonWithFramename(RES("btn_1_disable.png"))
	local textlabel1 = createSpriteWithFrameName(RES("word_button_receive.png"))	
	local textlabel2 = createSpriteWithFrameName(RES("word_button_receive.png"))
	self.normalBtn:setTitleString(textlabel1)
	self.disBtn:setTitleString(textlabel2)	
	self.limitTableBg:addChild(self.normalBtn)
	self.limitTableBg:addChild(self.disBtn)
	VisibleRect:relativePosition(self.normalBtn,self.limitTableBg, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-14,27))
	VisibleRect:relativePosition(self.disBtn, self.limitTableBg, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-14,27))
	self.normalBtn:setVisible(false)
	self.disBtn:setVisible(false)	
	
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
	local disBtnFun = function ()
		local rankStateObj = limitTimeRankMgr:getRankStateObj(self.limitRankType)
		local endTime = os.date("%Y%m%d%H%M%S")		
		local limitEndTime = limitTimeRankMgr:getLimitEndTime(self.limitRankType)
		if limitEndTime and limitEndTime > endTime then
			if rankStateObj.state == SignAwardState.unableGet then			
				UIManager.Instance:showSystemTips(Config.Words[13644])								
			end
		else
			local myRank =  tonumber(limitTimeRankMgr:getLimitMyRank(self.limitRankType))
			if myRank and myRank > 0  and myRank < tonumber(G_GetLimitRankLastRank(self.limitRankType))  then
				UIManager.Instance:showSystemTips(Config.Words[13645])			
			else
				UIManager.Instance:showSystemTips(Config.Words[13646])		
			end
		end			
	end		
	self.disBtn:addTargetWithActionForControlEvents(disBtnFun, CCControlEventTouchDown)	
	
	local normalBtnFun = function ()	
		local rankStateObj = limitTimeRankMgr:getRankStateObj(self.limitRankType)
		local endTime = os.date("%Y%m%d%H%M%S")	
		local limitEndTime = limitTimeRankMgr:getLimitEndTime(self.limitRankType)
		if limitEndTime and limitEndTime > endTime then
			UIManager.Instance:showSystemTips(Config.Words[13647])
			self.limitRankTableView:scroll2Cell(rankStateObj.index-1)
		else
			local refId = "limitTimeRank_" .. self.limitRankType .. "_" .. rankStateObj.index
			limitTimeRankMgr:requestGetLimitRankAward(refId)				
			limitTimeRankMgr:setSelectType(self.limitRankType)
			self.limitRankTableView:scroll2Cell(rankStateObj.index-1)
		end
	end
	self.normalBtn:addTargetWithActionForControlEvents(normalBtnFun, CCControlEventTouchDown)	
end

function RankListView:TabPress(key)
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager() 	
	if limitRankTypeRequestList[key] and limitRankTypeRequestList[key] ~= self.limitRankType then
		self.limitRankType = limitRankTypeRequestList[key]		
		limitTimeRankMgr:requestLimitTimeRankVersion(limitRankTypeRequestList[key])
	end	
end	

function RankListView:updateBtn()
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
	local limitRankList  = limitTimeRankMgr:getRankSection(self.limitRankType)
	local limitRankCellCount = table.size(limitRankList)	
	local rankStateObj = limitTimeRankMgr:getRankStateObj(self.limitRankType)
	for i=1, limitRankCellCount do	
		--判断是否可点击   可点击则创建按钮   否则创建精灵
		--local limitRankList  = limitTimeRankMgr:getRankSection(self.limitRankType)
		local refId = "limitTimeRank_" .. self.limitRankType .. "_" .. i
		--local limitRankList  = limitTimeRankMgr:getRankSection(self.limitRankType)
		local state = limitRankList[refId]
		if  state == SignAwardState.canGet then		
			rankStateObj.index = i
			rankStateObj.state = SignAwardState.canGet
			break									
		elseif state == SignAwardState.hadGet then	
			if rankStateObj.state == SignAwardState.canGet then
				rankStateObj.index = -1
				rankStateObj.state = SignAwardState.hadGet
			end		
		else			
			rankStateObj.index = -1
			rankStateObj.state = SignAwardState.unableGet
		end	
	end
			
	--local rankStateObj = rankState[self.limitRankType]			
	if rankStateObj.state == SignAwardState.canGet then
		self.normalBtn:setVisible(true)
		self.disBtn:setVisible(false)
	else
		self.normalBtn:setVisible(false)
		self.disBtn:setVisible(true)
	end		
end

function RankListView:createLimitRankTypeCell(index)
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(175,62))
	local cellBg
	if self.selectedLimitRankType == index + 1 then
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_btn.png"),CCSizeMake(166,62))
	else		
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_nomal_btn.png"),CCSizeMake(166,62))
	end
	cellNode:addChild(cellBg)
	cellNode:setContentSize(cellBg:getContentSize())
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_CENTER)
	if limitRankTypeList[index+1] == nil or limitRankTypeRequestList[index+1] == nil then
		return
	end
	local cellWord = createSpriteWithFrameName(RES(limitRankTypeList[index + 1]))
	cellBg:addChild(cellWord)
	VisibleRect:relativePosition(cellWord,cellBg, LAYOUT_CENTER, ccp(0,13))
	
	local topPlayerNameBg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_textBg.png"),CCSizeMake(104,25))
	cellBg:addChild(topPlayerNameBg)
	VisibleRect:relativePosition(topPlayerNameBg,cellBg, LAYOUT_CENTER, ccp(0,-10))
	
	local remainDayLabel = createLabelWithStringFontSizeColorAndDimension(self:getRemainingDay(limitRankTypeRequestList[index + 1]), "Arial", FSIZE("Size2"), FCOLOR("ColorYellow9"))
	topPlayerNameBg:addChild(remainDayLabel)
	remainDayLabel:setTag(101)
	VisibleRect:relativePosition(remainDayLabel, topPlayerNameBg, LAYOUT_CENTER)
	return cellNode
end	

function RankListView:createLimitTabView()
	
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		self.selectedLimitRankType  = cell:getIndex()+1		
		self:TabPress(self.selectedLimitRankType)
		tableP:reloadData()	
		return 1								
	end
		
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(166,62)))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(CCSizeMake(166,62)))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(CCSizeMake(166,62)))
				local item = self:createLimitRankTypeCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(CCSizeMake(166,62)))
				local item = self:createLimitRankTypeCell(index)				
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																					
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(table.size(limitRankTypeList))
			return 1
		end
	end			

	--创建tableview
	self.limitrankTypeTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(175,420)))
	self.limitrankTypeTable:reloadData()
	self.limitrankTypeTable:setTableViewHandler(tableDelegate)
	self.limitrankTypeTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.limitNode:addChild(self.limitrankTypeTable)		
	VisibleRect:relativePosition(self.limitrankTypeTable,self.limitTabBg,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(3,-5))

end

function RankListView:createLimitRankCell(index)
	
	if self.preIndex < index then
		self.directdown = false
	else
		self.directdown = true
	end	
	self.preIndex = index

	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(638,93))
	cellNode:setContentSize(cellSize)
	local cellLine = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"),CCSizeMake(700,2))	
	cellNode:addChild(cellLine)
	VisibleRect:relativePosition(cellLine,cellNode,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)	
	local refId = "limitTimeRank_" .. self.limitRankType .. "_" .. (index+1)
	local nameList = limitTimeRankMgr:getPersonNameList(self.limitRankType)	
	local nameStr = nameList[refId]
			
	if self.directdown == false  then
		if index == self.totalCell - 1 and self.totalCell > 3 then
			self.downdirectTips:setVisible(false)
			self.updirectTips:setVisible(true)	
		end	
	else
		if index == 0 and self.totalCell > 3 then
			self.updirectTips:setVisible(false)
			self.downdirectTips:setVisible(true)			
		end				
	end	
	if string.len(nameStr) > 0 then	
		if index <= 3 then	
			local firstIcon = createSpriteWithFrameName(RES("no" .. (index+1) ..".png"))			
			cellNode:addChild(firstIcon)
			VisibleRect:relativePosition(firstIcon,cellNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(60,-15))

			local headIcon = createSpriteWithFrameName(RES("sign" .. (index+1) ..".png"))
			VisibleRect:relativePosition(headIcon,firstIcon,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(-10,-10))
			cellNode:addChild(headIcon)

			local firstName = createLabelWithStringFontSizeColorAndDimension(nameStr,"Arial",FSIZE("Size4"), FCOLOR("ColorWhite2"))
			VisibleRect:relativePosition(firstName,headIcon,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(5,0))
			cellNode:addChild(firstName)
		else
			local descStr = G_GetLimitRankSectionDescStr(refId)
			local descLable = createLabelWithStringFontSizeColorAndDimension(descStr,"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
			cellNode:addChild(descLable)
			VisibleRect:relativePosition(descLable,cellNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(60,-15))	
			
			local firstName = createLabelWithStringFontSizeColorAndDimension(nameStr,"Arial",FSIZE("Size3"), FCOLOR("ColorYellow1"))
			cellNode:addChild(firstName)		
			VisibleRect:relativePosition(firstName,descLable,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(-10,-10))	
		end				
	else
		local descStr = G_GetLimitRankSectionDescStr(refId)
		local descLable = createLabelWithStringFontSizeColorAndDimension(descStr,"Arial",FSIZE("Size3"),FCOLOR("ColorWhite2"))
		cellNode:addChild(descLable)
		VisibleRect:relativePosition(descLable,cellNode,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(60,-35))	
	end		
	
	--奖励物品
	local awardTable = G_GetLimitRankAwardTable(refId)	
	--道具奖励
	
	local itemAward = {}
	
	if awardTable.itemReward then
		itemAward = awardTable.itemReward.itemList		
	end
	
	local numList = {}
	local awardList =  {}
	local index = 1
	for k,v in pairs(itemAward) do
		local itemBox = G_createItemBoxByRefId(v.itemRefId,nil,nil,-1)
		awardList[index] = itemBox
		numList[index] = "X" .. v.itemCount
		index = index + 1
--		VisibleRect:relativePosition(itemBox,cellNode,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(startX,0))		
--		cellNode:addChild(itemBox)
--		startX = startX + 100
	end
	
	local posX = 180
	for i = 1 , 3 do
		local itemBG = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))
		VisibleRect:relativePosition(itemBG,cellNode,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(posX, 5))			
		cellNode:addChild(itemBG)
		posX = posX + 100
	end
	
	local propertyAward = awardTable.propertyReward
	--非道具奖励
	if  propertyAward then
		for k,v in pairs(propertyAward) do
			local itemBox = G_createUnPropsItemBox(k)
			awardList[index] = itemBox
			numList[index] = "+" .. v
			index = index + 1
--[[			VisibleRect:relativePosition(itemBox,cellNode,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(startX,0))			
			cellNode:addChild(itemBox)
			startX = startX + 100--]]
		end
	end
	
	local count = index - 1
	local startX = 184 
	for i = 1,count do
		if numList[i] and awardList[i] then
			local numLabel = createLabelWithStringFontSizeColorAndDimension(numList[i],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))			
			awardList[i]:addChild(numLabel)
			VisibleRect:relativePosition(numLabel,awardList[i],LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE , ccp(0,3))			
			cellNode:addChild(awardList[i])
			VisibleRect:relativePosition(awardList[i],cellNode,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(startX,5))					
			startX = startX + 100
		end
	end

	--判断是否可点击   可点击则创建按钮   否则创建精灵
	local limitRankList  = limitTimeRankMgr:getRankSection(self.limitRankType)
	local state = limitRankList[refId]
	if  state == SignAwardState.canGet  then			
		--选中该区域
		local selectFram = createScale9SpriteWithFrameNameAndSize(RES("squares_serverSelectedFrame.png"),cellSize)
		cellNode:addChild(selectFram)
		VisibleRect:relativePosition(selectFram,cellNode,LAYOUT_CENTER)
					
		--[[local getAwardBt = createButton(createScale9SpriteWithFrameName(RES("btn_1_select.png")))		
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))			
		getAwardBt:setTitleString(textlabel)		
		cellNode:addChild(getAwardBt)	
		VisibleRect:relativePosition(getAwardBt,cellNode,LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-12,0))			
		local getAwardBtFunc = function()				
			local endTime = os.date("%Y%m%d%H%M%S")	
			if limitTimeRankMgr:getLimitEndTime(self.limitRankType) > endTime then
				UIManager.Instance:showSystemTips(Config.Words[13625])
			else
				limitTimeRankMgr:requestGetLimitRankAward(refId)				
				limitTimeRankMgr:setSelectType(self.limitRankType)
			end
		end
		getAwardBt:addTargetWithActionForControlEvents(getAwardBtFunc,CCControlEventTouchDown)--]]							
	elseif state == SignAwardState.hadGet then
		--[[local getAwardBtSprite = createScale9SpriteWithFrameName(RES("hadReceivedLable.png"))		
		cellNode:addChild(getAwardBtSprite)	
		VisibleRect:relativePosition(getAwardBtSprite,cellNode,LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-12,0))--]]					
	else
		--[[local getAwardBtSprite = createScale9SpriteWithFrameName(RES("btn_1_disable.png"))
		local textlabel = createSpriteWithFrameName(RES("word_button_receive.png"))	
		getAwardBtSprite:addChild(textlabel)
		VisibleRect:relativePosition(textlabel,getAwardBtSprite,LAYOUT_CENTER)		
		cellNode:addChild(getAwardBtSprite)	
		VisibleRect:relativePosition(getAwardBtSprite,cellNode,LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-12,0))	--]]					
	end				
	return cellNode
end

function RankListView:updateLimitRankNode(ttype)	
	self:updateRemainDayOnType(ttype)
	if ttype ~= self.limitRankType then
		return 
	end
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local cellSize = VisibleRect:getScaleSize(CCSizeMake(638,93))
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createLimitRankCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createLimitRankCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量
			local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
			local limitRankList  = limitTimeRankMgr:getRankSection(self.limitRankType)
			local limitRankCellCount = table.size(limitRankList)	
			data:setIndex(limitRankCellCount)
			self.totalCell = limitRankCellCount
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)	
		cell = tolua.cast(cell,"SFTableViewCell")
		local selectIndex = cell:getIndex()
		return 1
	end
	if not  self.limitRankTableView  then
		self.limitRankTableView = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(638, 279)))	
		self.limitRankTableView:setTableViewHandler(tableDelegate)
		self.limitRankTableView:reloadData()
		self.limitRankTableView:scroll2Cell(0, false)  --回滚到第一个cell
		self.limitTableBg:addChild(self.limitRankTableView)
		VisibleRect:relativePosition(self.limitRankTableView, self.limitTableBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-30))
	else
		self.limitRankTableView:reloadData()
	end	
	self:updateLimitRankText()
	self:updateBtn()
end

function RankListView:updateLimitRankText()
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager()
	local myRank =  limitTimeRankMgr:getLimitMyRank(self.limitRankType)
	if myRank == nil then
		self.myLimitRank:setString("UNKNOW")
	elseif myRank == 0 then
		self.myLimitRank:setString(G_GetLimitRankLastRank(self.limitRankType) .. "+")
	else
		self.myLimitRank:setString(myRank)
	end
	
	--tips
	local index = 13630+ self.limitRankType
	self.rankTypeTips:setString(Config.Words[index] .. Config.Words[13637])

	local startTime = limitTimeRankMgr:getLimitStartTime(self.limitRankType)
	local endTime = limitTimeRankMgr:getLimitEndTime(self.limitRankType)
	local curTime = os.date("%Y%m%d%H%M%S")	
	if startTime and endTime then  
		local sYear = string.sub(startTime,1,4)
		local sMon = string.sub(startTime,5,6)
		local sDay = string.sub(startTime,7,8)
		local sHour = string.sub(startTime,9,10)
		local sMin = string.sub(startTime,11,12)
		local sSec = string.sub(startTime,13,14)
		
		local eYear = string.sub(endTime,1,4)
		local eMon = string.sub(endTime,5,6)
		local eDay = string.sub(endTime,7,8)
		local eHour = string.sub(endTime,9,10)
		local eMin = string.sub(endTime,11,12)
		local eSec = string.sub(endTime,13,14)
		
		local cYear = string.sub(curTime,1,4)
		local cMon = string.sub(curTime,5,6)
		local cDay = string.sub(curTime,7,8)
		local cHour = string.sub(curTime,9,10)
		local cMin = string.sub(curTime,11,12)
		local cSec = string.sub(curTime,13,14)
		
		self.endTimeLabel:setString(sYear .. Config.Words[13621] .. sMon .. Config.Words[13622] .. sDay .. Config.Words[13623] .. sHour ..":" .. sMin .. ":" .. sSec ..   " - " .. eYear .. Config.Words[13621] .. eMon .. Config.Words[13622] .. eDay .. Config.Words[13623] .. eHour ..":" .. eMin .. ":" .. eSec )		
		local time1 = {year=cYear, month=cMon, day=cDay, hour=cHour,min=cMin,sec=cSec,isdst=false}
		local time2 = {year=eYear, month=eMon, day=eDay, hour=eHour,min=eMin,sec=eSec,isdst=false}
		local t1 = os.time(time1)
		local t2 = os.time(time2)
		
		local restSec = os.difftime(t2, t1)
		self:showCountDown(restSec)		
	end		
end	

function RankListView:requestAllRankType()
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager() 
	for k, v in pairs(limitRankTypeRequestList) do
		limitTimeRankMgr:requestLimitTimeRankVersion(v)
	end
end

--更新在类型上显示的时间
function RankListView:updateRemainDayOnType(ttype)
	local index
	for k, v in pairs(limitRankTypeRequestList) do
		if v == ttype then
			index = k
			break
		end
	end
	if type(index) == "number" and index > 0 then
		--local cellNode = self.limitrankTypeTable:dequeueCell(index-1)
		self.limitrankTypeTable:updateCellAtIndex(index-1)
		--[[print(cellNode)
		if cellNode then
			local remainDayLabel = cellNode:getChildByTag(101)
			print("remainDayLabel")
			if remainDayLabel then
				local day = self:getRemainingDay(ttype)				
				remainDayLabel:setString(day)
				VisibleRect:relativePosition(remainDayLabel, cellNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-10, 7))
			end
		end--]]
		end
	end		

function RankListView:getRemainingDay(ttype)
	local limitTimeRankMgr = GameWorld.Instance:getLimitTimeRankManager() 	
	local endTime = limitTimeRankMgr:getLimitEndTime(ttype)
	local curTime = os.date("%Y%m%d%H%M%S")	
	local restSec = 0
	local day
	if endTime then	
		local eYear = string.sub(endTime,1,4)
		local eMon = string.sub(endTime,5,6)
		local eDay = string.sub(endTime,7,8)
		local eHour = string.sub(endTime,9,10)
		local eMin = string.sub(endTime,11,12)
		local eSec = string.sub(endTime,13,14)
		
		local cYear = string.sub(curTime,1,4)
		local cMon = string.sub(curTime,5,6)
		local cDay = string.sub(curTime,7,8)
		local cHour = string.sub(curTime,9,10)
		local cMin = string.sub(curTime,11,12)
		local cSec = string.sub(curTime,13,14)
		
		local time1 = {year=cYear, month=cMon, day=cDay, hour=cHour,min=cMin,sec=cSec,isdst=false}
		local time2 = {year=eYear, month=eMon, day=eDay, hour=eHour,min=eMin,sec=eSec,isdst=false}
		local t1 = os.time(time1)
		local t2 = os.time(time2)		
		restSec = os.difftime(t2, t1)

		day = math.floor(restSec/(24*3600))			
	end
	local str
	if type(day) == "number" and day >= 1 then
		str = day..Config.Words[13643]
	elseif restSec > 0 then
		str = "<1" .. Config.Words[13643]
	elseif endTime and restSec <= 0 then
		local refId = "limitTimeRank_" .. ttype .. "_1"
		local nameList = limitTimeRankMgr:getPersonNameList(ttype)	
		local nameStr = nameList[refId]	
		if nameStr and nameStr ~= "" then
			str = nameStr--Config.Words[13648]
		else
			str = Config.Words[13648]
		end
	else
		str =" "
	end
	return str
end

function RankListView:showCountDown(restSec)
	if restSec > 0 then
		local day = math.floor(restSec/(24*3600))	
		local hour = math.floor(restSec/3600)%24
		local minite = math.floor(restSec/60)%60
		local sec = restSec%60	
		local str = " "
		if day > 0 then
			str = day .. Config.Words[13007]..string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
		else
			if hour > 0 then
				str = string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
			else
				if minite > 0 then
					str = string.format("%02d%s%02d%s", minite, Config.Words[13641], sec, Config.Words[13642])
				else
					str = string.format("%02d%s", sec, Config.Words[13642])
				end
			end
		end						

		self.restTimeLabel:setString(str)
	else
		self.restTimeLabel:setString(Config.Words[13639])
	end
	
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)  	
		self.scheduleId = nil
	end	
	
	local countDown = function()
		restSec = restSec - 1
		if restSec > 0 then
			local day = math.floor(restSec/(24*3600))	
			local hour = math.floor(restSec/3600)%24
			local minite = math.floor(restSec/60)%60
			local sec = restSec%60	
			local str = " "
			if day > 0 then
				str = day .. Config.Words[13007]..string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
			else
				if hour > 0 then
					str = string.format("%d%s%02d%s%02d%s",hour, Config.Words[13640], minite, Config.Words[13641], sec, Config.Words[13642])
				else
					if minite > 0 then
						str = string.format("%02d%s%02d%s", minite, Config.Words[13641], sec, Config.Words[13642])
					else
						str = string.format("%02d%s", sec, Config.Words[13642])
					end
				end
			end				
			
			self.restTimeLabel:setString(str)
		else
			self.restTimeLabel:setString(Config.Words[13639])		
		end
	end		
	self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countDown, 1, false)

end


--------------------------------------------------------排行版----------------------------------------------------------------

function RankListView:initLeft()
	self:initLeftTableView()
	local updateTipLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16122],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow1"),CCSizeMake(0,0))
	self.rankNode:addChild(updateTipLable)
	VisibleRect:relativePosition(updateTipLable,self.leftBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER,ccp(0,-15))
end

function RankListView:initRight()
	local topTitleBg = createScale9SpriteWithFrameName(RES("talisman_bg.png"))
	topTitleBg:setContentSize(CCSizeMake(cellSize.width-10,30))
	self.righBg:addChild(topTitleBg)
	VisibleRect:relativePosition(topTitleBg,self.righBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER)
	
	local rankListMgr = GameWorld.Instance:getRankListManager()
	local curRankType = rankListMgr:getCurRankType()
	
	for i=0,3 do
		local attrNameNode = CCNode:create()
		attrNameNode:setContentSize(CCSizeMake(cellSize.width/4,10))
		
		if i==3 then
			self.attrNameLable[i] = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
			self.attrNameLable[i]:setString(attrType.data[curRankType])
		else
			self.attrNameLable[i] = createLabelWithStringFontSizeColorAndDimension(attrType[i],"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
			local dividLine = createSpriteWithFrameName(RES("verticalDivideLine.png"))
			attrNameNode:addChild(dividLine)
			VisibleRect:relativePosition(dividLine,attrNameNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER)	
		end
		attrNameNode:addChild(self.attrNameLable[i])
		VisibleRect:relativePosition(self.attrNameLable[i],attrNameNode, LAYOUT_CENTER)

		self.righBg:addChild(attrNameNode)
		VisibleRect:relativePosition(attrNameNode,self.righBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(i*(cellSize.width/4),-10))
	end
	
	self:initRightTableView()
	self:initRightLayerView()
	
	for i = 0,3 do
		local word
		local rankListMgr = GameWorld.Instance:getRankListManager()
		local curRankType = rankListMgr:getCurRankType()
		local heroObject = rankListMgr:getHero(curRankType)		
		if heroObject and heroObject:getProperty(attrName[i]) then
			word = heroObject:getProperty(attrName[i])
		else
			word = ""
		end
		if i == 2 then
			if word == ModeType.ePlayerProfessionWarior then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarior)
				self.myRankLable[i] = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))
			elseif word == ModeType.ePlayerProfessionMagic then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionMagic)
				self.myRankLable[i] = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorRed1"),CCSizeMake(0,0))
			elseif word == ModeType.ePlayerProfessionWarlock then
				professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarlock)
				self.myRankLable[i] = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorBlue1"),CCSizeMake(0,0))
			else
				self.myRankLable[i] = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
			end	
		else
			self.myRankLable[i] = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size4")*viewScale,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
		end
		
		local myRankNode = CCNode:create()
		myRankNode:setContentSize(CCSizeMake(cellSize.width/4,20))
		myRankNode:addChild(self.myRankLable[i])
		VisibleRect:relativePosition(self.myRankLable[i],myRankNode, LAYOUT_CENTER)
		self.righBg:addChild(myRankNode)
		VisibleRect:relativePosition(myRankNode,self.righBg, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(i*(cellSize.width/4),-15))
	end
end

function RankListView:initLeftTableView()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local cellSize = VisibleRect:getScaleSize(CCSizeMake(175,62))
		
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createLeftCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createLeftCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量	
			data:setIndex(7)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)			
		cell = tolua.cast(cell,"SFTableViewCell")
		local rankListMgr = GameWorld.Instance:getRankListManager()
		local curRankType = rankListMgr:getCurRankType()
		
		if 	curRankType ~= cell:getIndex()	then
			if self.selectTableView then
				self.selectTableView:removeFromParentAndCleanup(true)
				self.selectTableView = nil
			end
			local ttype = cell:getIndex()
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local level = PropertyDictionary:get_level(hero:getPT())
			if ttype >2 and level<40 then 
				if ttype == 3 then
					UIManager.Instance:showSystemTips(Config.Words[16123])
				elseif ttype == 4 then
					UIManager.Instance:showSystemTips(Config.Words[16124])
				elseif ttype == 5 then
					UIManager.Instance:showSystemTips(Config.Words[16125])
				elseif ttype == 6 then
					UIManager.Instance:showSystemTips(Config.Words[16126])
				end	
				return
			end
			rankListMgr:setCurRankType(ttype)
			curRankType = rankListMgr:getCurRankType()
			if curRankType ~= 0 then		
				self.fpSubTabView:setVisible(false)
			else			
				self.fpSubTabView:setVisible(true)
				self.fpSubTabView:setSelIndex(3)
			end
			self.subType = nil	
			self:updateLeft()
			self:showLoadingHUD(0.6)
			GlobalEventSystem:Fire(GameEvent.EventRequestVersionNum,curRankType)
		else
			return 
		end
	end
	
	self.leftTableView = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(175, 430)))	
	self.leftTableView:setTableViewHandler(tableDelegate)
	self.leftTableView:reloadData()
	--self.leftTableView:scroll2Cell(0, false)  --回滚到第一个cell
	self.leftBg:addChild(self.leftTableView)
	VisibleRect:relativePosition(self.leftTableView, self.leftBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-5))
end

function RankListView:createLeftCell(index)
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(175,62))
	local rankListMgr = GameWorld.Instance:getRankListManager()
	local curRankType = rankListMgr:getCurRankType()
	local cellBg
	if curRankType == index then
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_btn.png"),CCSizeMake(166,62))
	else
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("rank_nomal_btn.png"),CCSizeMake(166,62))
	end
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_CENTER)

	if rankType[index] then
		local cellWord = createSpriteWithFrameName(RES(rankType[index]))
		cellBg:addChild(cellWord)
		VisibleRect:relativePosition(cellWord,cellBg, LAYOUT_CENTER, ccp(0,13))
	end

	local topPlayerNameBg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_textBg.png"),CCSizeMake(104,25))
	cellBg:addChild(topPlayerNameBg)
	VisibleRect:relativePosition(topPlayerNameBg,cellBg, LAYOUT_CENTER, ccp(0,-10))

	local topPlayerList = rankListMgr:getTopPlayerList()
	if topPlayerList then
		if topPlayerList[index] then
			local topPlayer = createLabelWithStringFontSizeColorAndDimension(topPlayerList[index],"Arial",FSIZE("Size2"),FCOLOR("ColorYellow9"),CCSizeMake(0,0))
			topPlayerNameBg:addChild(topPlayer)
			VisibleRect:relativePosition(topPlayer,topPlayerNameBg, LAYOUT_CENTER)
		end
	end
	
	
	return cellNode
end

function RankListView:initRightTableView()
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		
		local rankListMgr = GameWorld.Instance:getRankListManager()
		local curRankType = rankListMgr:getCurRankType()		
		
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createRightCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createRightCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量
			if self.subType == nil then
				local tableLen = table.size(rankListMgr:getMemberList(curRankType))
				data:setIndex(tableLen)
			else
				local subMemberList = rankListMgr:getSubMemberList(self.subType)
				if subMemberList then
					local tableLen = table.size(subMemberList)
					data:setIndex(tableLen)
				else
					data:setIndex(0)
				end	
			end	
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		local cell = tolua.cast(cell,"SFTableViewCell")
		self.selectWhich = cell:getIndex()
		if	self.selectTableView then
			self.selectTableView:setVisible(true)
		end	
		self.rightTableView:reloadData()	
	end
	
	self.rightTableView = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(cellSize.width, cellSize.height*8)))	
	self.rightTableView:setTableViewHandler(tableDelegate)
	self.rightTableView:reloadData()
	self.rightTableView:scroll2Cell(0, true)  --回滚到第一个cell
	self.righBg:addChild(self.rightTableView)
	VisibleRect:relativePosition(self.rightTableView, self.righBg, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-30))
end	

function RankListView:getNumberByType(rankType)
	local hero = G_getHero()
	local pt = hero:getPT()
	if pt then
		local number = 0
		if rankType == RankType.fight then
			number = PropertyDictionary:get_fightValue(pt)
		elseif rankType == RankType.level then
			number = PropertyDictionary:get_level(pt)
		elseif rankType == RankType.rich then
			number = PropertyDictionary:get_gold(pt)
		elseif rankType == RankType.knight then
			number = PropertyDictionary:get_knight(pt)
		elseif rankType == RankType.wingLevel then
			number = PropertyDictionary:get_wingLevel(pt)
		elseif rankType == RankType.rideLevel then
			local mountId = PropertyDictionary:get_mountModleId(pt)
			local mountMgr = GameWorld.Instance:getMountManager()			
			number = mountMgr:getLevelByMountStateId(mountId)
		elseif rankType == RankType.talisman then
			number = PropertyDictionary:get_talisManLevel(pt)
		end
		return number
	end
	return 0
end

function RankListView:updateLeft()
	self.leftTableView:reloadData()	
end

function RankListView:updateRight()
	local rankListMgr = GameWorld.Instance:getRankListManager()
	local curRankType = rankListMgr:getCurRankType()
	
	if self.attrNameLable and attrType.data[curRankType] then
		self.attrNameLable[3]:setString(attrType.data[curRankType])
		if self.subType then
			self.attrNameLable[2]:setString(Config.Words[16131])
		else
			self.attrNameLable[2]:setString(Config.Words[16109])
		end
		
		local heroObject = rankListMgr:getHero(curRankType)
		local text0, text3
		if heroObject then
			text0 = heroObject:getProperty(attrName[0])
			text3 = heroObject:getProperty(attrName[3])
		end
		if text0 == nil or text3 == nil or text0 == 0 then	--英雄名次还未上榜或在1000以外
			if table.getn(rankListMgr:getMemberList(curRankType)) == 100 then
				self.myRankLable[0]:setString("1000+")
				if text3 == 0 then
					text3 = self:getNumberByType(curRankType)
				end
				self.myRankLable[3]:setString(text3)
			else
				self.myRankLable[0]:setString("-")
				self.myRankLable[3]:setString("-")
			end
		else
			self.myRankLable[0]:setString(tostring(text0))
			self.myRankLable[3]:setString(text3)
		end
		self.selectWhich = nil
		self.rightTableView:reloadData()
		self.rightTableView:scroll2Cell(0, false)  --回滚到第一个cell
	end
end

function RankListView:createRightCell(index)
	local cellNode = CCNode:create()	
	cellNode:setContentSize(cellSize)
	local cellBg
	if self.selectWhich and self.selectWhich == index then
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"),CCSizeMake(cellSize.width-10,cellSize.height))
		cellNode:addChild(cellBg)
		VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_CENTER)
	else
		cellBg = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"),CCSizeMake(cellSize.width,2))
		cellNode:addChild(cellBg)
		VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)
	end
	local rankListMgr = GameWorld.Instance:getRankListManager()
	local curRankType = rankListMgr:getCurRankType()
	if self.subType then
		for i = 0,3 do
			local word
			local wordLable
			
			local memberObject = rankListMgr:getOneSubMember(self.subType, index)
			if memberObject then
				if memberObject:getProperty(attrName[i]) then
					word = memberObject:getProperty(attrName[i])
				else
					word = ""
				end	

				if i == 0 then				-- 排名域的特殊处理
					if memberObject:getProperty(attrName[0])<4 then
						wordLable = createSpriteWithFrameName(RES("no"..(index+1)..".png"))
					else
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
					end
				elseif i == 1 then			-- 昵称域的特殊处理
					if memberObject:getProperty(attrName[0])<4 then
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
						local littleSign = createSpriteWithFrameName(RES("sign"..(index+1)..".png"))
						wordLable:addChild(littleSign)
						VisibleRect:relativePosition(littleSign,wordLable, LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(0,0))	
					else
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))		
					end
				elseif i == 2 then			-- 职业域的特殊处理				
					wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))			
				else						-- 数据域的特殊处理
					wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))		
				end
			end

			local textNode = CCNode:create()
			textNode:setContentSize(CCSizeMake(cellSize.width/4,cellSize.height))
			textNode:addChild(wordLable)
			VisibleRect:relativePosition(wordLable,textNode, LAYOUT_CENTER)
			cellNode:addChild(textNode)
			VisibleRect:relativePosition(textNode,cellNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(i*(cellSize.width/4),0))
		end
	else
		for i = 0,3 do
			local word = ""
			local wordLable
			local memberObject = rankListMgr:getOneMember(curRankType, index)
			if memberObject then
				if memberObject:getProperty(attrName[i]) then
					word = memberObject:getProperty(attrName[i])
				end						
				
				if i == 0 then				-- 排名域的特殊处理				
					if memberObject:getProperty(attrName[0])<4 then
						wordLable = createSpriteWithFrameName(RES("no"..(index+1)..".png"))
					else
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
					end								
				elseif i == 1 then			-- 昵称域的特殊处理					
					if memberObject:getProperty(attrName[0])<4 then
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
						local littleSign = createSpriteWithFrameName(RES("sign"..(index+1)..".png"))
						wordLable:addChild(littleSign)
						VisibleRect:relativePosition(littleSign,wordLable, LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(0,0))	
					else
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))		
					end	
				elseif i == 2 then			-- 职业域的特殊处理
					if word == ModeType.ePlayerProfessionWarior then
						professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarior)
						wordLable = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorYellow1"),CCSizeMake(0,0))
					elseif word == ModeType.ePlayerProfessionMagic then
						professionName = G_getProfessionNameById(ModeType.ePlayerProfessionMagic)
						wordLable = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorRed2"),CCSizeMake(0,0))
					elseif word == ModeType.ePlayerProfessionWarlock then
						professionName = G_getProfessionNameById(ModeType.ePlayerProfessionWarlock)
						wordLable = createLabelWithStringFontSizeColorAndDimension(professionName,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorBlue2"),CCSizeMake(0,0))
					else
						wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))
					end	
				else						-- 数据域的特殊处理
					wordLable = createLabelWithStringFontSizeColorAndDimension(word,"Arial",FSIZE("Size3")*viewScale,FCOLOR("ColorWhite2"),CCSizeMake(0,0))		
				end
	
				local textNode = CCNode:create()
				textNode:setContentSize(CCSizeMake(cellSize.width/4,cellSize.height))
				textNode:addChild(wordLable)
				VisibleRect:relativePosition(wordLable,textNode, LAYOUT_CENTER)
				cellNode:addChild(textNode)
				VisibleRect:relativePosition(textNode,cellNode, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(i*(cellSize.width/4),0))
			end
		end	
	end	
	return cellNode
end	

function RankListView:initRightLayerView()
	local touchArea = CCSizeMake(960,640)
	local function ccTouchHandler(eventType, x, y)
		local originalPoint = ccp(0,0)	
		local rect = CCRectMake(originalPoint.x,originalPoint.y,touchArea.width,touchArea.height)
		if rect:containsPoint(ccp(x,y)) then	
			if eventType == "began" then
				if self.selectTableView then
					self.selectTableView:removeFromParentAndCleanup(true)
					self.selectTableView = nil
				end
				self:initSelectTableView(x, y)
			end
		end
		return 0
	end

	self.rightLayer = CCLayer:create()
	self.rightLayer:setContentSize(touchArea)
	self:addChild(self.rightLayer)
	VisibleRect:relativePosition(self.rightLayer,self:getContentNode(), LAYOUT_CENTER)
	self.rightLayer:setTouchEnabled(true)
	self.rightLayer:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.LoadingHUD, true)
end

function RankListView:initSelectTableView(x, y)
	local function dataHandler(eventType,tableP,index,data)
		local data = tolua.cast(data,"SFTableData")
		local tableP = tolua.cast(tableP, "SFTableView")
		local cellSize = VisibleRect:getScaleSize(CCSizeMake(100,40))
		
		if eventType == 0 then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 1 then				-- TableView的大小
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == 2 then				-- TableView中的cell内容
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createSelectCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createSelectCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == 3 then				-- TableView中的cell数量	
			data:setIndex(4)
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		if self.selectTableView then
			self.selectTableView:setVisible(false)
		end
		local cell = tolua.cast(cell,"SFTableViewCell")	
		local index = cell:getIndex()
		local member
		local rankListMgr = GameWorld.Instance:getRankListManager()
		local curRankType = rankListMgr:getCurRankType()
		if self.subType == nil then
			member = rankListMgr:getOneMember(curRankType, self.selectWhich)				
		else
			member = rankListMgr:getOneSubMember(self.subType, self.selectWhich)			
		end
		if member then
			if index == 0 then
				GlobalEventSystem:Fire(GameEvent.EventRequestOtherPeopleDetailInfo,member:getProperty("refId"))
			elseif index == 1 then
				GlobalEventSystem:Fire(GameEvent.EventWhisperChat,member:getProperty("nickName"))
			elseif index == 2 then
			
			elseif index == 3 then
				GlobalEventSystem:Fire(GameEvent.EventRequestOtherPeopleInfo,member:getProperty("refId"))
			end
		end
	end
	
	self.selectTableView = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(100, 160)))	
	self.selectTableView:setTableViewHandler(tableDelegate)
	self.selectTableView:setVisible(false)
	self.selectTableView:reloadData()
	self.selectTableView:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.selectTableView)
	VisibleRect:relativePosition(self.selectTableView,self:getContentNode(), LAYOUT_CENTER,ccp(x-430,y-400))
end

function RankListView:createSelectCell(index)
	local cellNode = CCNode:create()
	local cellSize = VisibleRect:getScaleSize(CCSizeMake(100,40))
	cellNode:setContentSize(cellSize)
	
	local cellBg = createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"),cellSize)
	cellNode:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,cellNode,LAYOUT_CENTER)
	
	local cellLable = createLabelWithStringFontSizeColorAndDimension(selectList[index],"Arial",FSIZE("Size4"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
	cellBg:addChild(cellLable)
	VisibleRect:relativePosition(cellLable, cellBg, LAYOUT_CENTER)
		
	return cellNode
end	

function RankListView:onEnter(arg)
	self:requestAllRankType()
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local level = PropertyDictionary:get_level(hero:getPT())
	if level<30 then
		self.disRankBtn:setVisible(true)
		self.rankBtn:setVisible(false)
		self.tabTitle:setSelIndex(1)
	else
		self.disRankBtn:setVisible(false)
		self.rankBtn:setVisible(true)		
	end
	if arg == 1 then
		self.tabTitle:setSelIndex(0)
		self:showRankNode()	
	else
		self.selectedLimitRankType = 1	
		self.limitrankTypeTable:reloadData()	
		self:showLimitRankNode()	
	end
end

function RankListView:onCloseBtnClick()
	if self.selectTableView then
		self.selectTableView:removeFromParentAndCleanup(true)
		self.selectTableView = nil
	end
	return true
end

function RankListView:onExit()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)  	
		self.scheduleId = nil
	end	
end

function RankListView:createFPSubTabView()
	local btStr = {
		[0] = Config.Words[16127],
		[1] = Config.Words[16128],
		[2] = Config.Words[16129],
		[3] = Config.Words[16130],	
	}
	local tabArray = CCArray:create()
	for kind = 0 ,3 do
		local showFPSubBoardView = function()		
			if kind ~= 0 then
				if self.subType == kind then					
					return
				else
					self.subType = kind
				end
			else
				if self.subType == nil then
					return 
				else
					self.subType = nil
				end
			end
			self:updateRight()			
		end
		local normalSpr = createScale9SpriteWithFrameName(RES("tab_2_normal.png"))
		normalSpr:setRotation(180)
		local selSpr = createScale9SpriteWithFrameName(RES("tab_2_select.png"))
		selSpr:setRotation(180)		
		local bt = createButton(normalSpr, selSpr)
		local lable = createLabelWithStringFontSizeColorAndDimension(btStr[kind] , "Arial" ,FSIZE("Size4"),FCOLOR("ColorWhite3"),CCSizeMake(30,0))
		bt:setTitleString(lable)
		bt:addTargetWithActionForControlEvents(showFPSubBoardView, CCControlEventTouchDown)	
		tabArray:addObject(bt)
	end
	tabArray:reverseObjects()
	self.fpSubTabView = createTabView(tabArray, 10*viewScale, tab_vertical)
	self.rankNode:addChild(self.fpSubTabView)
	VisibleRect:relativePosition(self.fpSubTabView, self.mainBg, LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE, ccp(0,-50))		
	self.fpSubTabView:setSelIndex(3)	
end


