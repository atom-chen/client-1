require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("object.handup.API.HandupCommonAPI")

NearbyView = NearbyView or BaseClass(BaseUI) 

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local gridSize = CCSizeMake(260, 52)

--[[local nearbyTabView = {
[1] = {name = Config.Words[23701], tableView = nil, title = nil, text = nil},
[2] = {name = Config.Words[23702], tableView = nil,  title = nil, text = nil},
}--]]

local kTableCellSizeForIndex = 0
local kCellSizeForTable = 1
local kTableCellAtIndex = 2
local kNumberOfCellsInTableView = 3

function NearbyView:__init()
	self.viewName = "NearbyView"
	self:init(CCSizeMake(300, 260))	
	self.currentTabView = 1
	self.nearbyTabView = {
	[1] = {name = Config.Words[23701], tableView = nil, title = nil, text = nil},
	[2] = {name = Config.Words[23702], tableView = nil,  title = nil, text = nil},
	}
	--self.titleNode = {}
	--self.tableView = {}	
	self.cellList = {}
	--self.text = {}
	self.nearbyMgr = GameWorld.Instance:getNearbyMgr()	
	self.playerList = self.nearbyMgr:getPlayerList()
	self.monsterList = self.nearbyMgr:getNeedShowMonsterList()	
	self.bShow = true
	self:initBg()
	self:initTabView()	
	self.background:setVisible(false)
end

function NearbyView:__delete()
	self:clearCellList()
end

function NearbyView:create()
	return NearbyView.New()
end

--[[function NearbyView:onEnter()
	if self.currentTabView == 1 then
		self.playerList = self.nearbyMgr:getPlayerList()	
		self.tableView[1]:reloadData()		
	else		
		self:UpdateMonsterTable()		
	end			
end

function NearbyView:onExit()
	
end--]]

function NearbyView:initBg()
	local size = self:getContentNode():getContentSize()
	
	--[[local titleBg = createScale9SpriteWithFrameNameAndSize(RES("main_questCurrentBackground.png"), CCSizeMake(size.width, 30))
	self:addChild(titleBg)
	VisibleRect:relativePosition(titleBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE, ccp(0, 5))
	
	local title = createSpriteWithFrameName(RES("nearbyTitleWord.png"))
	self:addChild(title)
	VisibleRect:relativePosition(title, titleBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))--]]
	
	local secondBg = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), size)
	self:addChild(secondBg)
	VisibleRect:relativePosition(secondBg, self:getContentNode(), LAYOUT_CENTER)
	
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(size.width, 2))
	self:addChild(line)
	VisibleRect:relativePosition(line, secondBg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -30))	
end

function NearbyView:initTabView()
	local btnArray = CCArray:create()
	local createBtn = function (key, name)
		local button = createButtonWithFramename(RES("tab_3_normal.png"), RES("tab_3_select1.png"))
		button:setContentSize(CCSizeMake(50,78))
		local text = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite4"), CCSizeMake(30, 0))
		button:setTitleString(text)
		--self.text[key] = text
		--button:addChild(text)
		VisibleRect:relativePosition(text, button, LAYOUT_CENTER)
		self.nearbyTabView[key].text = text
		local onTabPress = function()			
			self:pressTabView(key)
		end							
		button:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchUpInside)
		btnArray:addObject(button)
	end
	
	for key,tabValue in pairs(self.nearbyTabView) do
		createBtn(key, tabValue.name)
	end		

	self.tagView = createTabView(btnArray,15*const_scale, tab_vertical)
	self:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_LEFT_OUTSIDE+LAYOUT_TOP_INSIDE, ccp(0, -10))
	self.tagView:setSelIndex(1)
	self:createTitle(1)
	self:createTableView(1)
	--self.text[1]:setColor(FCOLOR("ColorYellow1"))
	self.nearbyTabView[1].text:setColor(FCOLOR("ColorYellow1"))
end

function NearbyView:createTitle(key)
	if not self.nearbyTabView[key].title then	
		local size = self:getContentNode():getContentSize()
		local node = CCNode:create()
		node:setContentSize(CCSizeMake(size.width, 30))
		local nameLabel, professionLabel, levelLabel
		local fontSize = FSIZE("Size4")
		nameLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23706], "Arial", fontSize, FCOLOR("ColorYellow2"))	
		levelLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23705], "Arial", fontSize, FCOLOR("ColorYellow2"))	
		if key == 1 then			
			professionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23704], "Arial", fontSize, FCOLOR("ColorYellow2"))			
			--levelLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23705], "Arial", fontSize, FCOLOR("ColorYellow2"))			
		else
			professionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23719], "Arial", fontSize, FCOLOR("ColorYellow2"))										
		end
		node:addChild(nameLabel)		
		node:addChild(levelLabel)
		node:addChild(professionLabel)
		
		VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(20, 0))					
		VisibleRect:relativePosition(professionLabel, node, LAYOUT_CENTER, ccp(40, 0))
		VisibleRect:relativePosition(levelLabel, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-20, 0))				
		
		self:addChild(node)
		VisibleRect:relativePosition(node, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
		self.nearbyTabView[key].title = node
	end
end

function NearbyView:pressTabView(key)
	if key == self.currentTabView then
		return
	end
	if not self.nearbyTabView[key].title then
		self:createTitle(key)
	end
	if not self.nearbyTabView[key].tableView then
		self:createTableView(key)
	end
	
	for key1,tabNode in pairs(self.nearbyTabView) do
		if key1==key then
			self.nearbyTabView[key1].title:setVisible(true)
			self.nearbyTabView[key1].tableView:setVisible(true)
			self.nearbyTabView[key1].text:setColor(FCOLOR("ColorYellow1"))
		else
			self.nearbyTabView[key1].title:setVisible(false)
			self.nearbyTabView[key1].tableView:setVisible(false)
			self.nearbyTabView[key1].text:setColor(FCOLOR("ColorWhite4"))
		end
	end		

	self.currentTabView = key
	if self.currentTabView == 1 then
		self:UpdateHeroTable()	
	else		
		self:UpdateMonsterTable()
	end					
end

function NearbyView:createTableView(key)
	local dataHandler = function(eventType,tableP,index,data)			
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")		
		if eventType == kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(gridSize))
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(gridSize))
			return 1
		elseif eventType == kTableCellAtIndex then	
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(gridSize))
				--tableCell:setIndex(index)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(gridSize))
			end
			local item
			if key == 1 then				
				local playerObj = self.playerList[index+1]
				local serverId
				local bshow = false
				local color = FCOLOR("ColorWhite2")
				if playerObj then
					serverId = playerObj:getPlayerServerId()
					if index < self.nearbyMgr:getNearByViewRedNameCount() then
						color = FCOLOR("ColorRed1")
					end							
					if self.selectPlayerId and self.selectPlayerId == serverId then
						bshow = true
					end
				end					
	
				local node = self:getCellById(serverId)
				if node then				
					node:removeFromParentAndCleanup(false)	
					local level = playerObj:getPlayerLevel()
					self:updatePlayerLever(node, level,color,bshow)				
					item = node					
				else					
					item = self:createHeroTableCell(index,color)
					item:retain()
					self.cellList[playerObj:getPlayerServerId()] = item
				end						
			else
				item = self:createMonsterTabelCell(index)								
			end
			data:setCell(tableCell)
			tableCell:addChild(item)
			tableCell:setIndex(index)
			--VisibleRect:relativePosition(item, tableCell, LAYOUT_CENTER)
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			local count = 0
			if key == 1 then
				count = table.size(self.playerList)
			else
				count = table.size(self.monsterList)
			end				
			data:setIndex(count)
			return 1					
		end
	end	
	
	local tableDelegate = function (tableP, cell, x, y)
		self:tableDelegate(tableP, cell, x, y, key)
	end
	
	if not self.nearbyTabView[key].tableView then
		local size = self:getContentNode():getContentSize()		
		local tableView = createTableView(dataHandler, CCSizeMake(size.width, size.height-40))		
		tableView:setTableViewHandler(tableDelegate)
		self:addChild(tableView)		
		VisibleRect:relativePosition(tableView, self:getContentNode(), LAYOUT_CENTER, ccp(0,-15))	
		tableView:reloadData()
		tableView:scroll2Cell(0, false) 	
		self.nearbyTabView[key].tableView = tableView	
	end
end

function NearbyView:tableDelegate(tableP, cell, x, y, key)
	--local autoPathMgr = GameWorld.Instance:getAutoPathManager()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()	
	local mapMgr = GameWorld.Instance:getMapManager()
	local sceneId = mapMgr:getCurrentMapRefId()	 
	tableP = tolua.cast(tableP,"SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")	
	local index = cell:getIndex()+1
	local entityObj = nil
	if key == 1 then
		entityObj = self.playerList[index]
		if entityObj then
			GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, EntityType.EntityType_Player, entityObj:getPlayerServerId())
			if self.selectPlayerId then
				local item = self.cellList[self.selectPlayerId]
				if  item then
					local selectFrame = item:getChildByTag(8)
					if selectFrame then
						selectFrame:setVisible(false)
					end
				end
			end	
			self.selectPlayerId = 	entityObj:getPlayerServerId()
			if self.selectPlayerId then
				local item = self.cellList[self.selectPlayerId]
				if  item then
					local selectFrame = item:getChildByTag(8)
					if selectFrame then
						selectFrame:setVisible(true)
					end
				end
			end		
		end		
	else
		entityObj = self.monsterList[index]
		local refId = entityObj:getMonsterRefId()
		self.selectMonsterRefId = refId
		if entityObj then
			local filterfunc = function (object, arg)
				if refId == object:getRefId() then
					return true
				else
					return false
				end
			end
			
			--[[local object = HandupCommonAPI:getClosestObj(EntityType.EntityType_Monster, filterfunc, arg)
			if object then
				GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, EntityType.EntityType_Monster, object:getId())
			else--]]
				G_getQuestLogicMgr():AutoPathFindMonster(refId, sceneId)
				--autoPathMgr:find(refId, sceneId)
			--end
			tableP:reloadData()				
		end
	end			
end

function NearbyView:createHeroTableCell(index,color)
	local node = CCNode:create()
	node:setContentSize(gridSize)
	local fontSize = FSIZE("Size4")
	local playerObj = self.playerList[index+1]
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(playerObj:getPlayerName(), "Arial", fontSize,color)
	local professionId = playerObj:getPlayerProfessionId()
	local professionLabel
	if professionId==1 then
		professionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23708], "Arial", fontSize, FCOLOR("ColorWhite2"))
	elseif professionId==2 then
		professionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23709], "Arial", fontSize, FCOLOR("ColorWhite2"))
	elseif professionId==3 then
		professionLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[23710], "Arial", fontSize, FCOLOR("ColorWhite2"))
	end
	local levelLabel = createLabelWithStringFontSizeColorAndDimension(playerObj:getPlayerLevel(), "Arial", fontSize, FCOLOR("ColorWhite2"))	
	node:addChild(nameLabel,0,9)
	node:addChild(professionLabel)
	node:addChild(levelLabel, 0, 10)
	
	local selectFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bg3.png"),gridSize)
	node:addChild(selectFrame,0,8)
	selectFrame:setVisible(false)
	VisibleRect:relativePosition(selectFrame, node, LAYOUT_CENTER)
	VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(2,0))
	VisibleRect:relativePosition(professionLabel, node, LAYOUT_CENTER, ccp(40, 0))
	VisibleRect:relativePosition(levelLabel, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-30, 0))
	if self.selectPlayerId  and playerObj:getPlayerServerId() == self.selectPlayerId then
		selectFrame:setVisible(true)
	end		
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(gridSize.width, 2))
	node:addChild(line)
	VisibleRect:relativePosition(line, node, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)	
	
	return node
end

function NearbyView:createMonsterTabelCell(index)
	local node = CCNode:create()
	node:setContentSize(gridSize)
	local monster = self.monsterList[index+1]
	local color, typeText	
	if monster:getMonsterQuanlity()>=3 then
		color = FCOLOR("ColorRed1")
		typeText = Config.Words[23717]
	else
		color = FCOLOR("ColorOrange3")	
		typeText = Config.Words[23718]
	end
	local fontSize = FSIZE("Size4")
	local nameLabel = createLabelWithStringFontSizeColorAndDimension(monster:getMonsterName(), "Arial", fontSize, color)
	local level = monster:getMonsterLevel()	
	local levelLabel = createLabelWithStringFontSizeColorAndDimension(level, "Arial", fontSize, color)
	local typeTextLabel = createLabelWithStringFontSizeColorAndDimension(typeText, "Arial", fontSize, color)
	--[[local current = monster:getMonsterCurrentCount()
	local total = monster:getMonsterTotalCount()	
	local numberLabel = createLabelWithStringFontSizeColorAndDimension(current..Config.Words[23711]..total, "Arial", fontSize, color)--]]	
	node:addChild(nameLabel)		
	node:addChild(levelLabel)
	node:addChild(typeTextLabel)
	--node:addChild(numberLabel, 0, index+1)
	VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(2,0))
	VisibleRect:relativePosition(levelLabel, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-30, 0))
	VisibleRect:relativePosition(typeTextLabel, node, LAYOUT_CENTER, ccp(40, 0))
	--VisibleRect:relativePosition(numberLabel, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-35, 0))	
	local selectFrame = createScale9SpriteWithFrameNameAndSize(RES("common_bg3.png"),gridSize)
	node:addChild(selectFrame,0,8)
	selectFrame:setVisible(false)
	VisibleRect:relativePosition(selectFrame, node, LAYOUT_CENTER)
	if self.selectMonsterRefId  and  monster:getMonsterRefId() == self.selectMonsterRefId then
		selectFrame:setVisible(true)
	end		
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(gridSize.width, 2))
	node:addChild(line)
	VisibleRect:relativePosition(line, node, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)	
	
	--monster:setCell(node)
	return node
end

function NearbyView:UpdateHeroTable()
	self.playerList = self.nearbyMgr:getPlayerList()	
	local bExist = false	
	if self.selectPlayerId then	
		for k,v in ipairs(self.playerList) do
			if v:getPlayerServerId() == self.selectPlayerId then
				bExist = true
				break
			end
		end
	end		
	if  not bExist then
		self.selectPlayerId = nil
	end
	self.nearbyTabView[1].tableView:reloadData()				
end

function NearbyView:UpdateMonsterTable()
	self.monsterList = self.nearbyMgr:getNeedShowMonsterList()
	local needReload = self.nearbyMgr:getIsReloadMonsterList()
	self.selectMonsterRefId = nil
	if needReload then	
		self.nearbyTabView[2].tableView:reloadData()
	else
		--[[for key,monster in pairs(self.monsterList) do
			local cell = monster:getCell()
			if cell then
				local numberLabel = cell:getChildByTag(key)
				numberLabel = tolua.cast(numberLabel,"SFLabel")
				if numberLabel then
					local current = monster:getMonsterCurrentCount()
					local total = monster:getMonsterTotalCount()
					numberLabel:setString(current..Config.Words[23711]..total)
				end
			end
		end--]]
	end	
end

function NearbyView:getSelectTabView()
	return self.currentTabView
end

function NearbyView:onCloseBtnClick()
	GlobalEventSystem:Fire(GameEvent.EventCloseNearByView)
	return true
end

function NearbyView:closeView()
	--self.nearbyMgr:setNearByViewIsShowing(false)		
	self:clearCellList()
	return true
end 

function NearbyView:getCellById(serverId)
	return self.cellList[serverId]
end

function NearbyView:resetView()
	if self.nearbyTabView[1].tableView then
		self.playerList = self.nearbyMgr:getPlayerList()	
		self.nearbyTabView[1].tableView:reloadData()
	end
	
	if self.nearbyTabView[2].tableView then
		self.selectMonsterRefId = nil
		self.monsterList = self.nearbyMgr:getNeedShowMonsterList()		
		self.nearbyTabView[2].tableView:reloadData()
	end		
		
end

function NearbyView:clearCellList()
	for key,cell in pairs(self.cellList) do
		if cell then
			cell:release()			
		end
	end	
	self.cellList = {}
end

function NearbyView:createCloseBtn()
	self:removeFromRootNode(self.btnClose)
	
	self.btnClose = createButtonWithFramename(RES("closeButton.png"))
	self.btnClose:setTouchPriority(UIPriority.Control)
	self.rootNode:addChild(self.btnClose, 50)	
	local btnCloseSize = self.btnClose:getContentSize()
	VisibleRect:relativePosition(self.btnClose,self:getContentNode(),LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(20,25))
	local exitFunction =  function ()
		if self.onCloseBtnClick then
			if self:onCloseBtnClick() ~= false then
				self:close()
			end
		else
			self:close()
		end
	end
	self.btnClose:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
end

function NearbyView:updatePlayerLever(node, level,color,bShowSelect)
	local levelLabel = node:getChildByTag(10)
	if levelLabel then
		levelLabel = tolua.cast(levelLabel, "SFLabel")
		levelLabel:setString(level)
	end
	
	local nameLabel  = node:getChildByTag(9)
	if nameLabel then
		nameLabel = tolua.cast(nameLabel, "SFLabel")
		nameLabel:setColor(color)
	end
	
	local selectFrame = node:getChildByTag(8)
	if selectFrame then
		selectFrame:setVisible(bShowSelect)
	end	
end




