require("common.BaseUI")
require("config.words")
InstanceView = InstanceView or BaseClass(BaseUI)

local const_Tag_BG = 10
local const_Tag_TITLE = 20
local const_Tag_ZhenMoTaBtn = 100
function InstanceView:__init()
	self.viewName = "InstanceView"
	self.contentSize = CCSizeMake(874,564)
	self.button = {}
	
	
	self.viewLayoutConfig = {
		tabButton = {size = "Size2",color = "ColorWhite1",font = Config.fontName.fontName1 },--tab名字
		instanceTitle = {size = "Size4",color = "ColorWhite2",font = Config.fontName.fontName1 },--副本名字
		introduceTitle = {size = "Size4",color = "ColorBlack1",font = Config.fontName.fontName1 },--副本简介
		countTitle 	= {size = "Size3",color = "ColorRed1",font = Config.fontName.fontName1 },--副本次数
	}
	self.bossheadPosOffset = {
	[0] = ccp(-4,-18),
	[1] = ccp(-3,-16),	
	[2] = ccp(-10,-33),
	[3] = ccp(-10,-23),
	[4] = ccp(0,-27),
	[5] = ccp(-3,-15),
	[6] = ccp(0,-5),
	}
	self:init(self.contentSize)
	
	local questImage = createSpriteWithFrameName(RES("main_instance.png"))
	questImage:setScale(0.85)
	self:setFormImage(questImage)
	local questTitle = createSpriteWithFrameName(RES("word_game_instance.png"))
	self:setFormTitle(questTitle, TitleAlign.Left)
	
	self.tabView = nil
	self.tableView = nil
	self.tabIndex = 1
	self.cellSize = CCSizeMake(832,140)	
	self.tableSize = CCSizeMake(832,140*3)
	
	self.backgroundBG = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(832,450))	
	self:addChild(self.backgroundBG)
	VisibleRect:relativePosition(self.backgroundBG,self:getContentNode(), LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,7))
	--self.backgroundBG2 = createSpriteWithFileName("ui/ui_img/common/kraft_dungeon.png")
	self.backgroundBG2 = CCSprite:create()
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.backgroundBG2:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.backgroundBG2:addChild(viewNodeBgLeft)
	self.backgroundBG2:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.backgroundBG2,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.backgroundBG2,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	self.backgroundBG2 : setScaleX(1.0070)
	self.backgroundBG2 : setScaleY(1.0273)
	self.backgroundBG:addChild(self.backgroundBG2)	
	self.backgroundBG2:setScaleX(0.97)
	self.backgroundBG2:setScaleY(0.94)
	
	VisibleRect:relativePosition(self.backgroundBG2,self.backgroundBG,LAYOUT_CENTER,ccp(-2,2))
	self.backgroundBG3 = CCSprite:create("ui/ui_img/common/common_kraftRole.pvr")
	self.backgroundBG:addChild(self.backgroundBG3)
	VisibleRect:relativePosition(self.backgroundBG3,self.backgroundBG,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	
	self:createTabView()
	
	self:createTableView()
	
	self.tipsArrow = createSpriteWithFrameName(RES("main_questcontraction.png"))
	self.tipsArrow:setRotation(-90)
	self:addChild(self.tipsArrow)
	VisibleRect:relativePosition(self.tipsArrow,self:getContentNode(),LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER)
end

function InstanceView:onEnter()
	local manager = GameWorld.Instance:getGameInstanceManager()
	manager:requestGameInstanceList()	
	self:showLoadingHUD(5)
	self:refreshTitle()
	self:checkZhenMoTab()
		
	--self:checkZhenMoLing()
end

function InstanceView:__delete()
	self.tabView = nil
	self.tableView = nil
	self.tipsArrow = nil
	
	if self.forever then		
		self.forever:release()
	end
end

function InstanceView:checkZhenMoLing()
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
	
	local itemList = QuestInstanceRefObj:getStaticQusetToNextLayerItem("Ins_6","S201")
	local itemNumber = bgmgr:getItemNumByRefId(itemList.itemRefId)--todo,写死镇魔令道具
	
	local layerList = { "S201" ,"S202"}
	local needItemNumber = 0
	for i,v in pairs(layerList) do
		local num = QuestInstanceRefObj:getStaticQusetToNextLayerItemCount("Ins_6",v)
		if type(num) == "number" then
			needItemNumber = needItemNumber + num
		end
	end	
	
	local bShow = false
	if itemNumber >= needItemNumber then
		bShow = true
	end
	self:showZhenMoTaAni(bShow)
end

function InstanceView:showZhenMoTaAni(bShow)
	if bShow==true then
		if not self.framesprite then
			local animate = createAnimate("questframe",6,0.3)
			self.framesprite = CCSprite:create()
			self.forever = CCRepeatForever:create(animate)			
			self.forever:retain()
			self.framesprite:runAction(self.forever )	
			self.framesprite:setScaleX(0.57)
			self.framesprite:setScaleY(0.75)		
			self.button[2]:addChild(self.framesprite)
			VisibleRect:relativePosition(self.framesprite, self.button[2], LAYOUT_CENTER, ccp(-3,0))
			
			self.framesprite:setVisible(bShow)
		else
			if self.forever then
				self.framesprite:stopAllActions()
				self.framesprite:runAction(self.forever)
				self.framesprite:setVisible(bShow)
			end	
		end
	else
		if self.framesprite and self.forever then
			self.framesprite:stopAllActions()
			self.framesprite:setVisible(bShow)
		end
	end
end

function InstanceView:createTabView()
	local createContent = {
		Config.Words[1500],	
	}
	local btnArray = CCArray:create()
	for key,value in ipairs(createContent) do
		if self.button[key] then
			self.button[key]:removeFromParentAndCleanup(false)
			self.button[key] = nil
			self.framesprite = nil
			self.forever = nil
		end
		self.button[key] = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))	
		local layoutConfig = self.viewLayoutConfig["tabButton"]	
		local label = createLabelWithConfig(layoutConfig,value)
		self.button[key]:setTitleString(label)
		btnArray:addObject(self.button[key])
		local onTabPress = function()	
			self.tabIndex = key	
			self.tableView:reloadData()	
			self:cilckTabPress(key)
		end
		self.button[key]:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)		
	end
	self.tabView = createTabView(btnArray,12, tab_horizontal)
	self:addChild(self.tabView)
	VisibleRect:relativePosition(self.tabView,self.backgroundBG,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(40,0))
end

function InstanceView:checkZhenMoTab()
	local instanceManager = GameWorld.Instance:getGameInstanceManager()
	if instanceManager:isZhenMoTaOpen() then
		self:insertTabBtn(Config.Words[1501], 2)
	end
end

function InstanceView:insertTabBtn(btnWord, index)
	if self.button[index] == nil then
		local tabBtn = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))
		local layoutConfig = self.viewLayoutConfig["tabButton"]	
		local label = createLabelWithConfig(layoutConfig,btnWord)
		tabBtn:setTitleString(label)
		local onTabPress = function()	
			self.tabIndex = index	
			self.tableView:reloadData()	
			self:cilckTabPress(index)
		end
		tabBtn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		table.insert(self.button, index, tabBtn)
		self.tabView:insertControl(tabBtn)
		VisibleRect:relativePosition(self.tabView,self.backgroundBG,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(40,0))
	end
end

function InstanceView:createTableView()
	local	kTableCellSizeForIndex = 0
	local	kCellSizeForTable = 1
	local	kTableCellAtIndex = 2
	local	kNumberOfCellsInTableView = 3
	local cellSize = self.cellSize
	local manager = GameWorld.Instance:getGameInstanceManager()	
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
			--todo
			local cell = SFTableViewCell:create()	
			self:createCellWithData(cell,cellSize,manager,index)
			cell:setIndex(index)
			data:setCell(cell)
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			local size = self:getSize(manager)
			data:setIndex(size)
			return 1
		end
	end		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self:handleTableViewTouchEvent(tableP,cell,x,y)
	end
	self.tableView = createTableView(dataHandlerfunc,self.tableSize)
	self.tableView:setTableViewHandler(tableDelegate)
	self.tableView:reloadData()
	self:addChild(self.tableView)
	VisibleRect:relativePosition(self.tableView,self:getContentNode(), LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-45))	
end

function InstanceView:getSize(manager)
	local size = 0
	if self.tabIndex == 1 then
		size = manager:getDataSize()
	else
		size = manager:getActivityListDataSize()
	end
	return size	
end

function InstanceView:handleTableViewTouchEvent(tableP,cell,x,y)
	
end

function InstanceView:getInstanceData(manager,index)
	local data = nil
	if self.tabIndex==2 then
		data =  manager:getActivityListData(index)		
	else
		data =  manager:getData(index)
	end
	return data
end

function InstanceView:createCellWithData(cell,cellSize,manager,index)
	local showData = self:getInstanceData(manager,index)
	local level =  0 
	local posOffsetY = 20

	if showData then
		if showData:getOpenLevel() then
			level = showData:getOpenLevel()
		end
	end	
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local heroLevel = PropertyDictionary:get_level(hero:getPT())
	cell:setContentSize(cellSize)
	cell:removeAllChildrenWithCleanup(true)
	local titleBG = createScale9SpriteWithFrameNameAndSize(RES("common_blueBar.png"),CCSize(368,33))
	cell:addChild(titleBG)
	titleBG:setTag(index+1)
	VisibleRect:relativePosition(titleBG,cell,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(100,10+posOffsetY))
	local instanceName = showData:getInstanceName()
	if instanceName then
		local layoutConfig = self.viewLayoutConfig["instanceTitle"]
		local instanceTitle = createLabelWithConfig(layoutConfig,instanceName)
		titleBG:addChild(instanceTitle,0,index+11)
		--instanceTitle:setTag(index+11)
		VisibleRect:relativePosition(instanceTitle,titleBG,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(40,0))
		local suggestlevel = QuestInstanceRefObj:getInstanceSuggestlevel(showData:getRefId())
		if suggestlevel then
			local diffLevel = suggestlevel - heroLevel
			if diffLevel >= 5 and diffLevel <= 10 then
				instanceTitle:setColor(FCOLOR("ColorRed4"))
				showData:setLevelState(E_LevelState.StatePink)
			elseif diffLevel >= 10 and diffLevel <= 15 then
				instanceTitle:setColor(FCOLOR("ColorRed1"))
				showData:setLevelState(E_LevelState.StateRed)
			elseif diffLevel >= 15 then
				instanceTitle:setColor(FCOLOR("ColorRed3"))
				showData:setLevelState(E_LevelState.DeepRed)
			else
				showData:setLevelState(E_LevelState.StateWhite)
			end
		else
			showData:setLevelState(E_LevelState.StateWhite)
		end
		
	end		
	local introduce = showData:getInstanceDescription()
	if introduce then
		local layoutConfig = self.viewLayoutConfig["introduceTitle"]
		local introduceTitle = createLabelWithConfig(layoutConfig,introduce,CCSizeMake(490,0))
		cell:addChild(introduceTitle)
		VisibleRect:relativePosition(introduceTitle,titleBG,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(45,-7))
	end
	local bossHeadNode = createSpriteWithFrameName(RES("ins_clickFrame.png"))
	cell:addChild(bossHeadNode)
	VisibleRect:relativePosition(bossHeadNode,cell,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(20,0+posOffsetY))	
	local bossHead = createSpriteWithFrameName(RES(showData:getRefId()..".png"))
	if bossHead then
		bossHeadNode:addChild(bossHead)	
		VisibleRect:relativePosition(bossHead,bossHeadNode,LAYOUT_CENTER,self.bossheadPosOffset[index])
	end				
	local enterButton = createButtonWithFramename(RES("btn_1_select.png"),RES("btn_1_select.png"))
	local tilte = createSpriteWithFrameName(RES("ins_enter.png"))
	enterButton:setTitleString(tilte)
	if self.tabIndex==2 and index==0 then
		enterButton:setTag(const_Tag_ZhenMoTaBtn)
	end		
	local enterFunction = function()
		local autoPath = GameWorld.Instance:getAutoPathManager()
		local id = showData:getId()			
		local countInday = showData:getCountInDay()	
		if id~= "" and countInday ~= 0 then
			autoPath:cancel()
			G_getHandupMgr():stop()
			manager:requesEnterGameInstance(id)
			self:close()
		else
			local vipMgr = GameWorld.Instance:getVipManager()
			local vipLevel = vipMgr:getVipLevel()
			if vipLevel > 0 then
				local msg = {}
				table.insert(msg,{word = Config.Words[15033], color = Config.FontColor["ColorWhite1"]})
				table.insert(msg,{word = Config.Words[15018], color = Config.FontColor["ColorRed1"]})
				table.insert(msg,{word = Config.Words[15034], color = Config.FontColor["ColorWhite1"]})
				UIManager.Instance:showSystemTips(msg)
			else
				UIManager.Instance:showSystemTips(Config.Words[15031])
			end			
		end
	end
	enterButton:addTargetWithActionForControlEvents(enterFunction,CCControlEventTouchDown)		

	VisibleRect:relativePosition(enterButton,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-35,-25+posOffsetY))
	
	cell:addChild(enterButton)	
	
	local line = createSpriteWithFrameName(RES("npc_dividLine.png"))
	line:setScaleX(1.8)
	cell:addChild(line)
	VisibleRect:relativePosition(line,cell,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(120,-20+posOffsetY))
	
	local tipTitle = createSpriteWithFrameName(RES("ins_font.png"))	
	cell:addChild(tipTitle)
	VisibleRect:relativePosition(tipTitle,line,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE,ccp(10,0))	

	local text = showData:getCountShowingWord()
	if text then
		local function richLabelHandler()
			GlobalEventSystem:Fire(GameEvent.EventVipViewOpen)	
		end
		
		local countTitle = createRichLabel(CCSizeMake(cell:getContentSize().width,0))	
		countTitle:appendFormatText(text)
		countTitle:setEventHandler(richLabelHandler)
		cell:addChild(countTitle)
		VisibleRect:relativePosition(countTitle,tipTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	end	
end	


function InstanceView:update()
	local manager = GameWorld.Instance:getGameInstanceManager()	
	manager:updateTableView(self.tableView)	
	self:hideLoadingHUD()
end

function InstanceView:create()
	return InstanceView.New()
end

function InstanceView:refreshTitle()
	local manager = GameWorld.Instance:getGameInstanceManager()	
	local dataList = manager:getDataList()
	local stateList = manager:getStateList()
	if table.size(dataList)>0 then
		for i,v in ipairs(dataList) do
			local oldState = v:getLevelState()
			local curState = stateList[i]
			if curState and oldState ~= curState then									
				self.tableView:updateCellAtIndex(i-1)
			end
		end
	end
	
	local dataActivityList = manager:getActivityDataList()
	local stateActivityList = manager:getStateActivityList()
	if table.size(dataActivityList)>0 then
		for i,v in ipairs(dataActivityList) do
			local oldState = v:getLevelState()
			local curState = stateActivityList[i]
			if curState and oldState ~= curState then									
				self.tableView:updateCellAtIndex(i-1)
			end
		end
	end
end

----------------------------------------------------------------------
--新手指引
function InstanceView:getZhenMoTaTabNode()
	local node = self.button[2]
	return node
end

function InstanceView:getZhenMoTaEnterBtn()
	if self.tabIndex == 2 then
		local cell = self.tableView:cellAtIndex(0)
		if cell  then
			local btn = cell:getChildByTag(const_Tag_ZhenMoTaBtn)		
			return btn
		end
	end
end

function InstanceView:cilckTabPress(key)
	if key==2 then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"InstanceView")
	end
end
----------------------------------------------------------------------