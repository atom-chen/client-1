require("common.BaseUI")
require("config.words")
WorldBossTeamListView = WorldBossTeamListView or BaseClass()

local  teamList = {}

local g_scale = VisibleRect:SFGetScale()
local cellSize = CCSizeMake(801*g_scale,65*g_scale)
local viewSize = CCSizeMake(874, 564)
function WorldBossTeamListView:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(viewSize)

	self.eventType = {}
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3	
	
	self:initStaticView()

end	

function WorldBossTeamListView:initStaticView()

	self.bodyBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(viewSize.width-42,425))--CCSizeMake(831,479))	
	self.rootNode:addChild(self.bodyBg)
	VisibleRect:relativePosition(self.bodyBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,0))
	
	self.titleText = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))
	self.rootNode:addChild(self.titleText)
	VisibleRect:relativePosition(self.titleText,self.bodyBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(13,0))	
	
	self.countDownText = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3"),FCOLOR("ColorRed1"))
	self.rootNode:addChild(self.countDownText)
	VisibleRect:relativePosition(self.countDownText,self.titleText,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(13,0))	
		
	self.tableBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(809,370))--CCSizeMake(831,479))	
	self.rootNode:addChild(self.tableBg)
	VisibleRect:relativePosition(self.tableBg,self.bodyBg,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(0,13))	
	
	local tableTitleBg = createScale9SpriteWithFrameNameAndSize(RES("grayBg.png"),CCSizeMake(809,40))	
	self.rootNode:addChild(tableTitleBg)
	VisibleRect:relativePosition(tableTitleBg,self.tableBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER)	

	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(40*g_scale,1*g_scale))
	line:setRotation(90)
	self.rootNode:addChild(line)	
	VisibleRect:relativePosition(line, tableTitleBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(140,0))
	
	local teamIdLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25503],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.rootNode:addChild(teamIdLable)
	VisibleRect:relativePosition(teamIdLable, tableTitleBg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(50,0))		
	
	local teamDescLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25504],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow2"))
	self.rootNode:addChild(teamDescLable)
	VisibleRect:relativePosition(teamDescLable, tableTitleBg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(300,0))		
		
	--一个tableview 
	self:createTeamListTableView() 
	--一个文本框
	self.editCommand =  createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(194*g_scale,43*g_scale)),RES("faction_editBoxBg.png"))
	self.rootNode:addChild(self.editCommand)
	self.editCommand:setFontColor(FCOLOR("ColorBlack1"))
	VisibleRect:relativePosition(self.editCommand,self.bodyBg,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(22,-20))	
	self.editCommand:setText(Config.Words[25523])	

	local editBoxHandler = function (pEventName, editBox)	
		if pEventName == "began" then 		
			if self.editCommand:getText() == Config.Words[25523] then 
				self.editCommand:setText("")
			end
			self.editCommand:setFontColor(FCOLOR("ColorWhite1"))
		end
	end		
	self.editCommand:registerScriptEditBoxHandler(editBoxHandler)	
	
	--加入按钮	
	self.joinBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.joinBt:setTitleString(createSpriteWithFrameName(RES("word_button_joingroup.png")))
	self.rootNode:addChild(self.joinBt)
	VisibleRect:relativePosition(self.joinBt,self.editCommand,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))	
	local onJoinBtPress = function()
		self:joinTeam()
	end
	self.joinBt:addTargetWithActionForControlEvents(onJoinBtPress, CCControlEventTouchDown)		


	--创建队伍按钮
	self.createTeamBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.createTeamBt:setTitleString(createSpriteWithFrameName(RES("word_button_creategroup.png")))	
	self.rootNode:addChild(self.createTeamBt)
	VisibleRect:relativePosition(self.createTeamBt,self.joinBt,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(100,0))	
	local onCreateTeamBtPress = function()
		self:createTeam()
	end
	self.createTeamBt:addTargetWithActionForControlEvents(onCreateTeamBtPress, CCControlEventTouchDown)			
	
	--退队警告
	self.warmingBt = createButtonWithFramename(RES("btn_1_select.png"))
	self.warmingBt:setTitleString(createSpriteWithFrameName(RES("word_button_exitgroupwarming.png")))	
	self.rootNode:addChild(self.warmingBt)
	VisibleRect:relativePosition(self.warmingBt,self.createTeamBt,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(100,0))			
	local onWarmingBtPress = function()
		self:showWarming()
	end
	self.warmingBt:addTargetWithActionForControlEvents(onWarmingBtPress, CCControlEventTouchDown)		

end	

function WorldBossTeamListView:createTeamListTableView()
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")								
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createTeamCell(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createTeamCell(index)				
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																																		
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then			
			data:setIndex(table.size(teamList))
			return 1
		end
	end			
	
	self.teamListTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(801, 330)))
	self.teamListTable:reloadData()
	self.teamListTable:setTableViewHandler(tableDelegate)
	self.teamListTable:scroll2Cell(0, false)  --回滚到第一个cell
	self.rootNode:addChild(self.teamListTable)		
	VisibleRect:relativePosition(self.teamListTable, self.tableBg, LAYOUT_CENTER + LAYOUT_BOTTOM_INSIDE)
end

function WorldBossTeamListView:createTeamCell(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)	
	--背景		
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(801*g_scale,2*g_scale))
	item:addChild(line)
	VisibleRect:relativePosition(line, item, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE)
	--队伍编号
	local teamIdLable = createLabelWithStringFontSizeColorAndDimension(teamList[index+1].teamName,"Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"))
	item:addChild(teamIdLable)
	VisibleRect:relativePosition(teamIdLable, item, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(40,0))	
	--队伍人数
	local teamMenberLable = createLabelWithStringFontSizeColorAndDimension(teamList[index+1].teamMember.. "/3","Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"))
	item:addChild(teamMenberLable)
	VisibleRect:relativePosition(teamMenberLable, item, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(220,-5))	
	
	--队伍要求
	local teamLevelRequireLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25515] .. teamList[index+1].levelChoice,"Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"))
	item:addChild(teamLevelRequireLable)
	VisibleRect:relativePosition(teamLevelRequireLable, teamMenberLable, LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_OUTSIDE,ccp(10,0))		
	
	--队伍平均等级
	local teamAveLevelLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[25516] .. teamList[index+1].averageLevel,"Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"))
	item:addChild(teamAveLevelLable)
	VisibleRect:relativePosition(teamAveLevelLable, teamMenberLable, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-2))		
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
	--按钮
	local cellBt = createButton(createScale9SpriteWithFrameNameAndSize(RES("chat_nomal_btn.png"),CCSizeMake(108,56)))
	item:addChild(cellBt)
	VisibleRect:relativePosition(cellBt, item, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE,ccp(-22,0))		
		
	if teamMgr:getMyTeamId() then
		if teamList[index+1].teamId  == teamMgr:getMyTeamId()  then--自己队伍
			if teamList[index+1].teamName == PropertyDictionary:get_name(G_getHero():getPT()) then
				cellBt:setTitleString(createSpriteWithFrameName(RES("word_button_watchgroup.png")))
				local onWatchTeamBtPress = function()
					GlobalEventSystem:Fire(GameEvent.EventCreateTeam,teamList[index+1].levelChoice)
				end				
				cellBt:addTargetWithActionForControlEvents(onWatchTeamBtPress, CCControlEventTouchDown)			
			else
				cellBt:setTitleString(createLabelWithStringFontSizeColorAndDimension(Config.Words[9006],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite1")))
				local onQuiteTeamBtPress = function()
					teamMgr:requestLeaveTeam()
				end				
				cellBt:addTargetWithActionForControlEvents(onQuiteTeamBtPress, CCControlEventTouchDown)					
			end
		else
			local showTipsFunc = function()
				UIManager.Instance:showSystemTips(Config.Words[25517])
			end	
			cellBt:setTitleString(createSpriteWithFrameName(RES("word_button_joingroup.png")))
			cellBt:addTargetWithActionForControlEvents(showTipsFunc, CCControlEventTouchDown)			
		end
	else
		--其他队伍
		local joinTeamFunc = function()
			if PropertyDictionary:get_level( G_getHero():getPT() ) >= teamList[index+1].levelChoice then
				teamMgr:joinTeamWithCheck(teamList[index+1].teamName)
			else
				UIManager.Instance:showSystemTips(Config.Words[25526])
			end	
		end			
		cellBt:setTitleString(createSpriteWithFrameName(RES("word_button_joingroup.png")))
		cellBt:addTargetWithActionForControlEvents(joinTeamFunc, CCControlEventTouchDown)		
	end	
	return item			
end	

function WorldBossTeamListView:getRootNode()
	return self.rootNode
end	

function WorldBossTeamListView:setTitleText(arg)
	local mapMgr =  GameWorld.Instance:getMapManager()
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()
	local currentMapRefId = mgr:getCurrentSceneRefId()
	local mapNameword = mapMgr:getMapName(currentMapRefId)		
	local titleStr = string.format(Config.Words[25505],mapNameword)		
	self.titleText:setString(titleStr)
	VisibleRect:relativePosition(self.titleText,self.bodyBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(13,-10))
	self:showCountDown()	
end	


function WorldBossTeamListView:updateTeamListView()
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	teamMgr:sortTeamList()	
	teamList = teamMgr:getTeamList()
	self.teamListTable:reloadData()
end	

function WorldBossTeamListView:joinTeam()
	local text = self.editCommand:getText()
	if text and text~= "" then
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
		local erroCode = teamMgr:joinTeamWithCheck(text)
		if erroCode > 0 then
			UIManager.Instance:showSystemTips(Config.Words[25510])
		end		
	end
end

function WorldBossTeamListView:createTeam()
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()		
	GlobalEventSystem:Fire(GameEvent.EventCreateTeam)	
end

function WorldBossTeamListView:showCountDown()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)  	
		self.scheduleId = nil
	end
	local mgr = GameWorld.Instance:getWorldBossActivityMgr()			
	local countDown = function()
		local str = " "
		if mgr:getTimeStrToStart() ~= "" then
			str = Config.Words[25531] .. mgr:getTimeStrToStart() 
		elseif mgr:getTimeStrToEnd() ~= "" then 
			str = Config.Words[25532] .. mgr:getTimeStrToEnd() 
		end
		self.countDownText:setString(str)
		VisibleRect:relativePosition(self.countDownText,self.titleText,LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(13,0))	
	end		
	self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(countDown, 1, false)

end

function WorldBossTeamListView:showWarming()
	showMsgBox(Config.Words[25533])
end

function WorldBossTeamListView:__delete()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)  	
		self.scheduleId = nil
	end
end	


