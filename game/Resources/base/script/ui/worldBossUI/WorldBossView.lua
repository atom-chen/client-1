require("common.BaseUI")
require("config.words")
WorldBossView = WorldBossView or BaseClass(BaseUI)
local cellSize = VisibleRect:getScaleSize(CCSizeMake(832,145))
local viewSize = VisibleRect:getScaleSize(CCSizeMake(874,564))

local kTableCellSizeForIndex = 0
local kCellSizeForTable = 1
local kTableCellAtIndex = 2
local kNumberOfCellsInTableView = 3

local eliteCellSize = CCSizeMake(828, 80)

local const_activity_guaiwuruqin = "activity_manage_6"
local hours_3 = 3*60*60

function WorldBossView:__init()
	self.viewName = "WorldBossView"			
	self.viewLayoutConfig = {
		tabButton = {size = "Size2",color = "ColorWhite1",font = Config.fontName.fontName1 },--tab名字
		bossName = {size = "Size4",color = "ColorWhite2",font = Config.fontName.fontName1 },--boss名字		
		refresh = {size = "Size3",color = "ColorBlack1",font = Config.fontName.fontName1 },--刷新文字
		drop = {size = "Size3",color = "ColorGreen1",font = Config.fontName.fontName1 },--掉落文字
		introduceTitle = {size = "Size3",color = "ColorBlack1",font = Config.fontName.fontName1 },--副本简介		
	}
	
	self.bossheadPosOffset = {
	["monster_20"] = ccp(-10,-23),
	["monster_6020"] = ccp(-10,-23),	
	["monster_7020"] = ccp(-10,-23),				
	["monster_24"] = ccp(0,-20),
	["monster_6024"] = ccp(0,-20),
	["monster_7024"] = ccp(0,-20),			
	["monster_30"] = ccp(-4,-18),	
	["monster_6030"] = ccp(-4,-18),	
	["monster_7030"] = ccp(-4,-18),			
	["monster_41"] = ccp(-10,-33),
	["monster_6041"] = ccp(-10,-33),	
	["monster_7041"] = ccp(-10,-33),				
	["monster_45"] = ccp(-3,-16),
	["monster_6045"] = ccp(-3,-16),
	["monster_7045"] = ccp(-3,-16),			
	["monster_53"] = ccp(0,-27),
	["monster_6053"] = ccp(0,-27),	
	["monster_7053"] = ccp(0,-27),				
	["monster_34"] = ccp(0,-24),
	["monster_6034"] = ccp(0,-24),	
	["monster_7034"] = ccp(0,-24),				
	["monster_56"] = ccp(-3,-15),	
	["monster_6056"] = ccp(-3,-15),	
	["monster_7056"] = ccp(-3,-15),		
	["monster_9020"] = ccp(-10,-15),	
	["monster_9061"] = ccp(-5,-15),
	}
	
	self.tabViewList = {	
	[0] = {tableView = nil, tabName = Config.Words[23513], },	
	[1] = {tableView = nil, tabName = Config.Words[23506], },
	[2] = {tableView = nil, tabName = Config.Words[23500],},
	}	
	local worldBossMgr = G_getHero():getWorldBossMgr()
	worldBossMgr:setEliteList()
	self.bShowing = false
	
	self:init(viewSize)
	
	local questImage = createSpriteWithFrameName(RES("main_world_boss.png"))	
	self:setFormImage(questImage, ccp(-6, 17))
	local questTitle = createSpriteWithFrameName(RES("word_boss.png"))
	self:setFormTitle(questTitle, TitleAlign.Left)	
	
	--self.tableView = nil	
	self.cellSize = CCSizeMake(832,145)	
	self.tableSize = CCSizeMake(832,425)
	
	self.backgroundBG = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(832,446))	
	self:addChild(self.backgroundBG)
	VisibleRect:relativePosition(self.backgroundBG,self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 10))	
	self.backgroundBG2 = CCSprite:create()
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.backgroundBG2:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.backgroundBG2:addChild(viewNodeBgLeft)
	self.backgroundBG2:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.backgroundBG2,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.backgroundBG2,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	self.backgroundBG2 : setScaleX(0.99)
	self.backgroundBG2 : setScaleY(0.95)
	self.backgroundBG:addChild(self.backgroundBG2)	
	--[[self.backgroundBG2:setScaleX(0.97)
	self.backgroundBG2:setScaleY(0.97)--]]
	
	VisibleRect:relativePosition(self.backgroundBG2,self.backgroundBG,LAYOUT_CENTER,ccp(0,2))
	self.backgroundBG3 = CCSprite:create("ui/ui_img/common/common_kraftRole.pvr")
	self.backgroundBG:addChild(self.backgroundBG3)
	VisibleRect:relativePosition(self.backgroundBG3,self.backgroundBG,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	
	self.tipsArrow = createSpriteWithFrameName(RES("main_questcontraction.png"))
	self.tipsArrow:setRotation(-90)
	self:addChild(self.tipsArrow)
	VisibleRect:relativePosition(self.tipsArrow,self:getContentNode(),LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER, ccp(0, -10))
	
		
	self.eliteList = worldBossMgr:getEliteList()
		
	self:initTabView()
	self:createBossTableView()
		self:createBossTempleTableView()	
end	

function WorldBossView:__delete()
	for key,v in pairs(self.tabViewList) do
		if v and v.tableView then
			v.tableView = nil			
		end
	end
	self.tabViewList = {}
	self.tipsArrow = nil
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end	
	
end	

function WorldBossView:initTabView()
	local btnArray = CCArray:create()
	local createBtn = function (key, name)	
		local button = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))		
		local text = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite4"))
		button:setTitleString(text)						
		local onTabPress = function()			
			self:pressTabView(key)
		end							
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchUpInside)
		btnArray:addObject(button)
	end
	
	for key,tabValue in pairs(self.tabViewList) do
		createBtn(key, tabValue.tabName)
	end		
		btnArray:reverseObjects()
	self.tabView = createTabView(btnArray,15, tab_horizontal)
	self:addChild(self.tabView, 20)
	VisibleRect:relativePosition(self.tabView, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(45, 5))		
end

function WorldBossView:pressTabView(key)
	for k,v in pairs(self.tabViewList) do
		if k == key then
			if self.tabViewList[k].tableView then
				self.tabViewList[k].tableView:setVisible(true)
				self.tabViewList[k].tableView:scroll2Cell(0, false)
			else
				if key == 1 then
					self:createEliteTableView()
				end
			end				
		else
			if self.tabViewList[k].tableView then
				self.tabViewList[k].tableView:setVisible(false)	
				self.tabViewList[k].tableView:scroll2Cell(0, false)			
			end	
		end
	end	
	
	if not self.titleNode then
		self:createTitleNode()
	end	
	if key == 1 then
		self.titleNode:setVisible(true)
		self.backgroundBG2:setVisible(false)
		self.backgroundBG3:setVisible(false)
	else
		self.titleNode:setVisible(false)
		self.backgroundBG2:setVisible(true)
		self.backgroundBG3:setVisible(true)
	end		
end

function WorldBossView:createTitleNode()
	self.titleNode = CCNode:create()
	self.titleNode:setContentSize(CCSizeMake(828, 40))
	self:addChild(self.titleNode)
	VisibleRect:relativePosition(self.titleNode, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(2, -44))	
	
	local textBg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"), CCSizeMake(828, 40))
	self.titleNode:addChild(textBg)
	VisibleRect:relativePosition(textBg, self.titleNode, LAYOUT_CENTER)
	local fontSize = FSIZE("Size5")
	local color = FCOLOR("ColorYellow2")
	local lineSize = CCSizeMake(40, 2)
	local eliteName = createLabelWithStringFontSizeColorAndDimension(Config.Words[23507], "Arial", fontSize, color)
	self.titleNode:addChild(eliteName)
	VisibleRect:relativePosition(eliteName, self.titleNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(45, 0))
	
	local nameLine = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), lineSize)
	self.titleNode:addChild(nameLine)
	nameLine:setRotation(90)
	VisibleRect:relativePosition(nameLine, eliteName, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(80, 0))
	
	local eliteScene = createLabelWithStringFontSizeColorAndDimension(Config.Words[23508], "Arial", fontSize, color)
	self.titleNode:addChild(eliteScene)
	VisibleRect:relativePosition(eliteScene, self.titleNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(265, 0))
	
	local sceneLine = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), lineSize)
	self.titleNode:addChild(sceneLine)
	sceneLine:setRotation(90)
	VisibleRect:relativePosition(sceneLine, eliteScene, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(55, 0))
	
	local eliteLevel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23509], "Arial", fontSize, color)
	self.titleNode:addChild(eliteLevel)
	VisibleRect:relativePosition(eliteLevel, self.titleNode, LAYOUT_CENTER, ccp(50, 0))
	
	local levelLine = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), lineSize)
	self.titleNode:addChild(levelLine)
	levelLine:setRotation(90)
	VisibleRect:relativePosition(levelLine, eliteLevel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(35, 0))
	
	local eliteTime = createLabelWithStringFontSizeColorAndDimension(Config.Words[23510], "Arial", fontSize, color)
	self.titleNode:addChild(eliteTime)
	VisibleRect:relativePosition(eliteTime, self.titleNode, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-190, 0))
	
	local timeLine = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), lineSize)
	self.titleNode:addChild(timeLine)
	timeLine:setRotation(90)
	VisibleRect:relativePosition(timeLine, eliteTime, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(35, 0))
	
	local eliteOperate = createLabelWithStringFontSizeColorAndDimension(Config.Words[23511], "Arial", fontSize, color)
	self.titleNode:addChild(eliteOperate)
	VisibleRect:relativePosition(eliteOperate, self.titleNode, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-67, 0))
end

function WorldBossView:createEliteTableCell(index)
	local node = CCNode:create()
	node:setContentSize(eliteCellSize)
	
	--[[local cellBg = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), eliteCellSize)
	node:addChild(cellBg)
	VisibleRect:relativePosition(cellBg, node, LAYOUT_CENTER)--]]
	
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(eliteCellSize.width, 2))
	node:addChild(line)
	VisibleRect:relativePosition(line, node, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	
	local eliteObj = self.eliteList[index+1]
	if eliteObj then	
		local fontSize = FSIZE("Size4")
		local color = FCOLOR("ColorWhite2")
		if eliteObj.eliteName then
			local eliteNameLabel = createLabelWithStringFontSizeColorAndDimension(eliteObj.eliteName, "Arial", fontSize, color)
			node:addChild(eliteNameLabel)
			VisibleRect:relativePosition(eliteNameLabel, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(25, 0))
		end					
		
		if eliteObj.sceneName then
			local eliteScene = createLabelWithStringFontSizeColorAndDimension(eliteObj.sceneName, "Arial", fontSize, color)
			node:addChild(eliteScene)
			VisibleRect:relativePosition(eliteScene, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(248, 0))
		end
		
		if eliteObj.level then
			local eliteLevel = createLabelWithStringFontSizeColorAndDimension(eliteObj.level, "Arial", fontSize, color)
			node:addChild(eliteLevel)
			VisibleRect:relativePosition(eliteLevel, node, LAYOUT_CENTER, ccp(48, 0))
		end			
		
		if eliteObj.refreshTime then
			local eliteTime = createLabelWithStringFontSizeColorAndDimension(eliteObj.refreshTime..Config.Words[23512], "Arial", fontSize, color)
			node:addChild(eliteTime)
			VisibleRect:relativePosition(eliteTime, node, LAYOUT_CENTER, ccp(170, 0))
		end
				
		local enterButton = createButtonWithFramename(RES("btn_1_select.png"),RES("btn_1_select.png"))
		local tilte = createSpriteWithFrameName(RES("world_boss_goto_label.png"))
		enterButton:setTitleString(tilte)
		
		local autoPathMgr = GameWorld.Instance:getAutoPathManager()
		local enterFunction = function()
			local monsterRefId = eliteObj.monsterRefId
			local sceneId = eliteObj.sceneRefId
			if monsterRefId and sceneId then
				GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad)	
				G_getHandupMgr():stop()
				autoPathMgr:find(monsterRefId, sceneId)
			end				
		end
		enterButton:addTargetWithActionForControlEvents(enterFunction,CCControlEventTouchDown)		
		node:addChild(enterButton)
		VisibleRect:relativePosition(enterButton, node, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y, ccp(-20, 0))
	end
		
	return node
end

function WorldBossView:createEliteTableView()
	local count = table.size(self.eliteList)	
	
	local dataHandler = function (eventType, tableP, index, data)
		tableP = tolua.cast(tableP,"SFTableView")
		data = tolua.cast(data,"SFTableData")
		if eventType == kTableCellSizeForIndex then
			data:setSize(eliteCellSize)
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(eliteCellSize)
			return 1
		elseif eventType == kTableCellAtIndex then	
			local offSet = tableP:getContentOffset().y	
			if eliteCellSize.height > (-offSet)then 
				self.tipsArrow:setVisible(false)
			else
				self.tipsArrow:setVisible(true)
			end		
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(eliteCellSize))
				local item = self:createEliteTableCell(index)
				cell:addChild(item)
				cell:setIndex(index+1)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(eliteCellSize))
				tableCell:setIndex(index+1)
				local item = self:createEliteTableCell(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == kNumberOfCellsInTableView then			
			data:setIndex(table.size(self.eliteList))
			return 1
		end
	end
	
	local tableDelegate = function (tableP,cell,x,y)
		self:handleEliteTableDelegate(tableP, cell, x, y)
	end
	
	local tableSize = CCSizeMake(820, 389)
	self.tabViewList[1].tableView = createTableView(dataHandler, tableSize)
	self.tabViewList[1].tableView:setTableViewHandler(tableDelegate)
	self.tabViewList[1].tableView:reloadData()	
	self:addChild(self.tabViewList[1].tableView)	
	VisibleRect:relativePosition(self.tabViewList[1].tableView, self.backgroundBG, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,10))	
end

function WorldBossView:handleEliteTableDelegate(tableP, cell, x, y)

end

function WorldBossView:createBossTableView()
	local cellSize = self.cellSize
	local worldBossMgr = G_getHero():getWorldBossMgr()
	
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
			local count = worldBossMgr:getBossCount()
			local offSet = tableP:getContentOffset().y	
			if cellSize.height > ( 0 - offSet )then 
				self.tipsArrow:setVisible(false)
			else
				self.tipsArrow:setVisible(true)
			end
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				local cell = SFTableViewCell:create()	
				self:createCellWithData(cell,cellSize,index)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				self:createCellWithData(tableCell,cellSize,index)
				tableCell:setIndex(index)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == kNumberOfCellsInTableView then			
			data:setIndex(worldBossMgr:getBossCount())
			return 1
		end
	end		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self:handleTableViewTouchEvent(tableP,cell,x,y)
	end
	self.tabViewList[2].tableView = createTableView(dataHandlerfunc,self.tableSize)
	self.tabViewList[2].tableView:setTableViewHandler(tableDelegate)	
	self:addChild(self.tabViewList[2].tableView)	
	VisibleRect:relativePosition(self.tabViewList[2].tableView, self.backgroundBG, LAYOUT_CENTER,ccp(0,5))	
end	

function WorldBossView:createBossTempleTableView()
	local cellSize =  CCSizeMake(832,170)	
	local bossTempleMgr = GameWorld.Instance:getBossTempleMgr()
	
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
			if tableCell == nil then
				local cell = SFTableViewCell:create()
				cell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createBossTempleCell(index)
				cell:addChild(item)
				VisibleRect:relativePosition(item,cell,LAYOUT_CENTER)
				cell:setIndex(index)
				data:setCell(cell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				tableCell:setIndex(index)
				local item = self:createBossTempleCell(index)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			return 1
		elseif eventType == kNumberOfCellsInTableView then	
			local count = bossTempleMgr:getBossTempleCount()		
			data:setIndex(count)
			return 1
		end
	end		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self:handleTableViewTouchEvent(tableP,cell,x,y)
	end
	self.tabViewList[0].tableView = createTableView(dataHandlerfunc,self.tableSize)
	self.tabViewList[0].tableView:setTableViewHandler(tableDelegate)
	self.tabViewList[0].tableView:reloadData()	
	self:addChild(self.tabViewList[0].tableView)
	self.tabViewList[0].tableView:setVisible(false)
	VisibleRect:relativePosition(self.tabViewList[0].tableView, self.backgroundBG, LAYOUT_CENTER,ccp(0,5))	
end	

function WorldBossView:createBossTempleCell(index)
	local cell = CCNode:create()
	local cellSize = CCSizeMake(832,170)	
	cell:setContentSize(cellSize)	
	local bossTempleMgr = GameWorld.Instance:getBossTempleMgr()	
	local titleBG = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSize(368,33))
	cell:addChild(titleBG)	
	VisibleRect:relativePosition(titleBG,cell,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(100,0))	
	--灰色遮罩
	local fontBg = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), CCSizeMake(cellSize.width-150, cellSize.height-35))
	cell:addChild(fontBg)
	VisibleRect:relativePosition(fontBg, titleBG,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -1))		
		
	local propertyPt = bossTempleMgr:getTempleProperty(index+1)
	--boss名字 等级  位置
	if propertyPt then
		local titleLabel = createLabelWithStringFontSizeColorAndDimension(propertyPt.name,"Arial",FSIZE("Size4"),FCOLOR("ColorWhite2"))
		cell:addChild(titleLabel)
		VisibleRect:relativePosition(titleLabel, titleBG, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(45, 0))

		local tipsLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25802],"Arial",FSIZE("Size3"),FCOLOR("ColorBlack1"))
		cell:addChild(tipsLable)
		VisibleRect:relativePosition(tipsLable, fontBg, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(45,-1))
						
		--开启时间
		local openDateStr = bossTempleMgr:getOpenDate(index+1)
		local openDataLabel = createLabelWithStringFontSizeColorAndDimension(openDateStr,"Arial",FSIZE("Size4"),FCOLOR("ColorBlack1"))
		cell:addChild(openDataLabel)
		VisibleRect:relativePosition(openDataLabel, tipsLable, LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE)
		
		local dropLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25803],"Arial",FSIZE("Size3"),FCOLOR("ColorGreen1"))
		cell:addChild(dropLable)		
		VisibleRect:relativePosition(dropLable,openDataLabel,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE)			
		
		--boss头像
		local bossHeadNode = createSpriteWithFrameName(RES("ins_clickFrame.png"))
		cell:addChild(bossHeadNode)
		VisibleRect:relativePosition(bossHeadNode,cell,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,40))
		local bossHead = createSpriteWithFrameName(RES(propertyPt.iconId ..".png"))
		if bossHead then
			bossHeadNode:addChild(bossHead)	
			VisibleRect:relativePosition(bossHead,bossHeadNode,LAYOUT_CENTER,ccp(0,-20))
		end		
	end

	local items = bossTempleMgr:getTempleSceneAward(index+1)
	--掉落物品
	for index, item in pairs(items) do 
		local itemBox = G_createItemShowByItemBox(item.itemRefId,nil,nil,nil,nil,-1)
		if itemBox then 
			itemBox:setScale(0.8)
			cell:addChild(itemBox)			
			local size = itemBox:boundingBox().size			
			VisibleRect:relativePosition(itemBox, fontBg, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(45+(5+size.width)*(index-1), 10))
		end
	end	
		
	local enterButton = createButtonWithFramename(RES("btn_1_select.png"),RES("btn_1_select.png"))
	local tilte = createSpriteWithFrameName(RES("ins_enter.png"))
	enterButton:setTitleString(tilte)
	
	local refId,num = bossTempleMgr:getNeedItemRefIdAndNum(index + 1)
	local enterFunction = function()
		--请求进入BOSS神殿  --TODO
		local haveNum = G_getBagMgr():getItemNumByRefId(refId)
		if haveNum >= num then
			local sceneRefId = bossTempleMgr:getTransferScene(index + 1)
			bossTempleMgr:requestEnterBossTemple(sceneRefId)
			self:close()
		else
			local mObj = G_IsCanBuyInShop(refId)
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,num - G_getBagMgr():getItemNumByRefId(refId))
			else
				local tipsStr = string.format(Config.Words[25801],G_GetItemNameByRefId(refId),num)
				UIManager.Instance:showSystemTips(tipsStr)
			end
		end
	end
	enterButton:addTargetWithActionForControlEvents(enterFunction,CCControlEventTouchDown)		
	cell:addChild(enterButton)
	VisibleRect:relativePosition(enterButton,fontBg,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y,ccp(-10, 0))		
	--消耗物品	
	local costStr = string.format(Config.Words[25804],num,G_GetItemNameByRefId(refId))
	local costLabel = createLabelWithStringFontSizeColorAndDimension(costStr,"Arial",FSIZE("Size3"),FCOLOR("ColorBlack1"))
	cell:addChild(costLabel)
	VisibleRect:relativePosition(costLabel,fontBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-10,5))			
	return cell
end

function WorldBossView:handleTableViewTouchEvent(tableP,cell,x,y)
	
end


function WorldBossView:createCellWithData(cell,cellSize,index)
	cell:setContentSize(cellSize)	
	cell:removeAllChildrenWithCleanup(true)
	
	--[[local bggggg = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), self.cellSize)
	cell:addChild(bggggg)
	VisibleRect:relativePosition(bggggg, cell, LAYOUT_CENTER)--]]
	
	local worldBossMgr = G_getHero():getWorldBossMgr()	
	local bossList = worldBossMgr:getBossList()
	if bossList[index+1] == nil then 
		return
	end
	local bossId = bossList[index+1].bossId
	
	local bossKind = worldBossMgr:getBossKind(bossId)
	
	local monsterRefId = worldBossMgr:getBossRefId(bossId)
	if monsterRefId == nil then 
		return
	end
	local property = worldBossMgr:getWorldBossProperty(bossId)	
	if property == nil then 
		return
	end
	local titleBG = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSize(368,33))
	cell:addChild(titleBG)	
	VisibleRect:relativePosition(titleBG,cell,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(100,0))	
	
	--boss名字 等级  位置
	local entityMgr = GameWorld.Instance:getEntityManager()
	local sceneId = PropertyDictionary:get_sceneRefId(property)
	local nameStr = entityMgr:getMonsterName(monsterRefId) or " "
	local lvStr = entityMgr:getMonsterLevel(monsterRefId) or " "	
	local location = " "
	if sceneId then 
		if GameData.Scene[sceneId] then 
			location = PropertyDictionary:get_name(GameData.Scene[sceneId].property)
		end
	end	
	local titleLabel = createLabelWithConfig(self.viewLayoutConfig["bossName"], nameStr.."   "..lvStr..Config.Words[23501].."   "..location)
	cell:addChild(titleLabel)
	VisibleRect:relativePosition(titleLabel, titleBG, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(45, 0))
	--刷新间隔	
	local refreshDurationWord = self:getRefreshDurationWord(bossKind,property)
	local refreshDurationLabel = createLabelWithConfig(self.viewLayoutConfig["refresh"],refreshDurationWord)		
	cell:addChild(refreshDurationLabel)
	VisibleRect:relativePosition(refreshDurationLabel, titleBG, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(45,-2))
	
	--灰色遮罩
	local fontBg = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), CCSizeMake(cellSize.width-150, cellSize.height-35))
	cell:addChild(fontBg)
	VisibleRect:relativePosition(fontBg, titleBG,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -1))
	--刷新时间	
	local refreshLabel = createRichLabel(CCSizeMake(480,0))	
	refreshLabel:setFontSize(FSIZE("Size3"))
	refreshLabel:setTag(index)
	cell:addChild(refreshLabel)	
	local time = worldBossMgr:getBossRefreshTime(bossId)	
	local timeWord = worldBossMgr:getTimeword(time)
	local showtime = string.wrapRich(timeWord , Config.FontColor["ColorGreen1"],FSIZE("Size3"))
	self:updateTime(refreshLabel, showtime)	
	VisibleRect:relativePosition(refreshLabel, refreshDurationLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(10,0))
	--掉落物品
	local dropStr = PropertyDictionary:get_description(property)	
	local layoutConfig = self.viewLayoutConfig["drop"]
	local dropTitle = createLabelWithConfig(layoutConfig,dropStr)
	cell:addChild(dropTitle)
	VisibleRect:relativePosition(dropTitle, titleBG, LAYOUT_LEFT_INSIDE,ccp(45,0))
	VisibleRect:relativePosition(dropTitle,refreshLabel, LAYOUT_BOTTOM_OUTSIDE)
	
	local items = worldBossMgr:getWorldBossDropItems(bossId)
	for index, item in pairs(items) do 
		local itemBox = G_createItemShowByItemBox(item.itemRefId,nil,nil,nil,nil,-1)
		if itemBox then 
			itemBox:setScale(0.8)
			cell:addChild(itemBox)			
			local size = itemBox:boundingBox().size			
			VisibleRect:relativePosition(itemBox, dropTitle, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp((5+size.width)*(index-1), -3))
		end
	end
	--boss头像
	local bossHeadNode = createSpriteWithFrameName(RES("ins_clickFrame.png"))
	cell:addChild(bossHeadNode)
	VisibleRect:relativePosition(bossHeadNode,cell,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,40))
	local icon = PropertyDictionary:get_iconId(property)
	if icon and icon ~= "" then 
		icon = icon .. ".png"
		local bossHead = createSpriteWithFrameName(RES(icon))
		if bossHead then
			bossHeadNode:addChild(bossHead)	
			local offsetPt = self.bossheadPosOffset[monsterRefId] or ccp(0, 0)
			VisibleRect:relativePosition(bossHead,bossHeadNode,LAYOUT_CENTER, offsetPt)
		end
	end
		
	local enterButton = createButtonWithFramename(RES("btn_1_select.png"),RES("btn_1_select.png"))
	local tilte = self:getButtonTilte(bossKind)
	enterButton:setTitleString(tilte)
	local enterFunction = function()
		if property["sceneRefId"] then 
			G_getHandupMgr():stop()
			if bossKind~=BOSSKIND.WorldBoss then
				G_getHero():moveStop()		
				self:doActivityBossLogic(bossKind)
			else
				local sceneId = property["sceneRefId"]
				local autoPathMgr = GameWorld.Instance:getAutoPathManager()
				G_getHandupMgr():stop()
				autoPathMgr:find(monsterRefId, sceneId)
			end
		end
	end
	enterButton:addTargetWithActionForControlEvents(enterFunction,CCControlEventTouchDown)		
	cell:addChild(enterButton)
	VisibleRect:relativePosition(enterButton,fontBg,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y,ccp(-10, 0))	
	
	--活动BOSS标示
	if bossKind~=BOSSKIND.WorldBoss then
		local completedIcon = createScale9SpriteWithFrameName(RES("worldBoss_activityTips.png"))				
		cell:addChild(completedIcon)
		completedIcon:setRotation(-15)
		VisibleRect:relativePosition(completedIcon,cell,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(150,-10))	
	end	
end	

function WorldBossView:doActivityBossLogic(bossKind)
	if bossKind == BOSSKIND.MonsterInvasion then--怪物入侵活动BOSS
		GlobalEventSystem:Fire(GameEvent.EventActivityClick, const_activity_guaiwuruqin)
		return
	else
		UIManager.Instance:showSystemTips( Config.Words[7511])
		return
	end
end

function WorldBossView:getRefreshDurationWord(bossKind,property)
	local word
	if bossKind~=BOSSKIND.WorldBoss then
		word = Config.Words[23502]	
	else
		word = Config.Words[23503] .. property["refreshTime"] .. Config.Words[23504].."   "..Config.Words[23502]
	end
	return word
end

function WorldBossView:getButtonTilte(bossKind)
	local tilte
	if bossKind~=BOSSKIND.WorldBoss then
		tilte = createSpriteWithFrameName(RES("word_enter.png"))
	else
		tilte = createSpriteWithFrameName(RES("world_boss_goto_label.png"))
	end
	return tilte
end

function WorldBossView:updateTime(richlabel, timeStr)			
	richlabel:clearAll()
	richlabel:appendFormatText(timeStr)
end

function WorldBossView:create()
	return WorldBossView.New()
end	

function WorldBossView:doCountDown()
	local bStop = false
	local zeroCnt, totalCnt = 0, table.size(self.bossList)
	for index, boss in pairs(self.bossList) do 
		if boss.refreshTime > 0 then
			boss.refreshTime = boss.refreshTime - 1			
		end
		if boss.refreshTime == 0 then
			zeroCnt = zeroCnt + 1
			bStop = (zeroCnt == totalCnt)
		end
	end		
	if bStop then
		self:stopCountDown()
	end
	local worldBossMgr = G_getHero():getWorldBossMgr()		
	local count = worldBossMgr:getBossCount()
	for i=0, count-1 do 
		local cell = self.tabViewList[2].tableView:cellAtIndex(i)	
		if cell then
			local label = cell:getChildByTag(i)			
			if label then	
				label = tolua.cast(label,"SFRichLabel")						
				if self.bossList[i+1].refreshTime then 
					local cnt = self.bossList[i+1].refreshTime
					if cnt<=hours_3 then--大于3个小时不更新
						local time = ""
						if cnt ~=0 then
							local hour, min, sec = worldBossMgr:calculateTime(cnt)
							hour = string.format("%02d", hour)
							min = string.format("%02d", min)
							sec = string.format("%02d", sec)
							if tonumber(hour)==0 then
								time = string.wrapRich(min..":"..sec, Config.FontColor["ColorGreen1"],FSIZE("Size3"))
							else
								time = string.wrapRich(hour..":"..min..":"..sec, Config.FontColor["ColorGreen1"],FSIZE("Size3"))
							end	
						else						
							time = string.wrapRich(Config.Words[23505], Config.FontColor["ColorGreen1"],FSIZE("Size3"))
						end
						self:updateTime(label, time)
					end	
				end
			end
		end
	end
end

function WorldBossView:startCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
	local tick = function ()
		self:doCountDown()
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end

function WorldBossView:onEnter(arg)
	self.bShowing = true
	local mgr = G_getHero():getWorldBossMgr()
	mgr:requestWorldBoss()	
	self:showLoadingHUD(5)	
	if arg then	
		local bossList = mgr:getBossList()
		for k ,v in ipairs(bossList) do
			local bossId = v.bossId
			local monsterRefId = mgr:getBossRefId(bossId)
			if 	monsterRefId == arg then
				self.needScrollIndex = k-1
				break
			end	
		end
		self.tabView:setSelIndex(0)
		if self.tabViewList[0].tableView then
			self.tabViewList[0].tableView:setVisible(false)			
		end
		if self.tabViewList[1].tableView then
			self.tabViewList[1].tableView:setVisible(false)	
		end
		if self.tabViewList[2].tableView then
			self.tabViewList[2].tableView:setVisible(true)			
		end	
		if self.titleNode then		
			self.titleNode:setVisible(false)
		end				
		self.backgroundBG2:setVisible(true)
		self.backgroundBG3:setVisible(true)
	end	
end

function WorldBossView:onExit()
	self.bShowing = false
	self:stopCountDown()
end

function WorldBossView:stopCountDown()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

function WorldBossView:start()
	local worldBossMgr = G_getHero():getWorldBossMgr()			
	self.bossList = worldBossMgr:getBossList()
	self:startCountDown()
end

function WorldBossView:update()
	self.tabViewList[2].tableView:reloadData()
	if self.needScrollIndex then
		self.tabViewList[2].tableView:scroll2Cell(self.needScrollIndex)
		self.needScrollIndex = nil
	end	
	self:hideLoadingHUD()
	self:start()
end

function WorldBossView:isShowing()
	return self.bShowing 
end