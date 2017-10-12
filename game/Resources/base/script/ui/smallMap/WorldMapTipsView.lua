require("ui.UIManager")
require("common.BaseUI")

WorldMapTipsView = WorldMapTipsView or BaseClass(BaseUI)
local viewSize = CCSizeMake(265,400)
local tableSize = CCSizeMake(225, 210)
local gridSize = CCSizeMake(225, 60)
local g_smallMapMgr = nil
local g_gameMapManager = nil

function WorldMapTipsView:__init()
	self.viewName = "WorldMapTipsView"	
	g_smallMapMgr = GameWorld.Instance:getSmallMapManager()
	g_gameMapManager = GameWorld.Instance:getMapManager()	
	self:init(viewSize)	
	self.background:setVisible(false)	
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"), gridSize)
	self.cellFrame:retain()
	self:initBg()
end

function WorldMapTipsView:__delete()
	self.cellFrame:release()
end

function WorldMapTipsView:create()
	return WorldMapTipsView.New()
end

function WorldMapTipsView:initBg()
	local contentSize = self:getContentNode():getContentSize()
	local secendBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), contentSize)
	self:addChild(secendBg)
	secendBg:setOpacity(200)
	VisibleRect:relativePosition(secendBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
	
	self.textBg = CCLayerColor:create(ccc4(24, 21, 20, 194)) --createScale9SpriteWithFrameNameAndSize(RES("suqares_goldFrameBg.png"), CCSizeMake(contentSize.width, 32))
	self.textBg:setContentSize(CCSizeMake(contentSize.width-6, 32))
	self:addChild(self.textBg)
	VisibleRect:relativePosition(self.textBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -80))
	
	local textLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[906], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.textBg:addChild(textLabel)
	VisibleRect:relativePosition(textLabel, self.textBg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(10, 0))
	
	self.changeItemRootNode = CCNode:create()	
	self.changeItemRootNode:setContentSize(contentSize)
	self:addChild(self.changeItemRootNode)
	VisibleRect:relativePosition(self.changeItemRootNode, self:getContentNode(), LAYOUT_CENTER)
		
	self.tableViewText = createLabelWithStringFontSizeColorAndDimension(Config.Words[905], "Arial", FSIZE("Size3"), FCOLOR("ColorRed1"))
	self:addChild(self.tableViewText)
	VisibleRect:relativePosition(self.tableViewText, self.textBg, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)
end

function WorldMapTipsView:onEnter(sceneId)
	if sceneId then
		self:showSceneTitle(sceneId)
		self:showTableView(sceneId)
		if self.tableView then
			self.tableView:reloadData()
		end
	end	
end

function WorldMapTipsView:onExit()
	self.cellFrame:removeFromParentAndCleanup(true)	
	self.changeItemRootNode:removeAllChildrenWithCleanup(true)
end

function WorldMapTipsView:showSceneTitle(sceneId)
	local sceneIcon = self:getSceneIconBySceneId(sceneId)
	if sceneIcon then
		local sceneBtn = createButtonWithFramename(RES(sceneIcon))
		self.changeItemRootNode:addChild(sceneBtn)
		VisibleRect:relativePosition(sceneBtn, self.textBg, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_OUTSIDE, ccp(13, 5))
		sceneBtn:setTouchAreaDelta(5, 65, 10, 0)
		local sceneBtnFun = function ()
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:startFindTargetPaths(sceneId)
			G_getHandupMgr():stop()	
		end		
		sceneBtn:addTargetWithActionForControlEvents(sceneBtnFun, CCControlEventTouchDown)	
		
		local conditionLevel = g_smallMapMgr:getConditionLevelBySceneId(sceneId)		
		if conditionLevel then
			local text = conditionLevel .. Config.Words[903]
			local textLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))			
			self.changeItemRootNode:addChild(textLabel)			
			VisibleRect:relativePosition(textLabel, sceneBtn, LAYOUT_CENTER_Y)
			VisibleRect:relativePosition(textLabel, self.textBg, LAYOUT_CENTER_X, ccp(30, 0))
		end
		
		local flyshoesBtn = createButtonWithFramename(RES("map_shoes.png"))
		self.changeItemRootNode:addChild(flyshoesBtn)
		VisibleRect:relativePosition(flyshoesBtn, self.changeItemRootNode, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(-15, -35))	
		flyshoesBtn:setTouchAreaDelta(5, 10, 10, 10)	
		
		local transferInObj = g_smallMapMgr:getTransferInPointBySceneId(sceneId)			
		local flyshoesBtnFun = function ()
			local ret, reason = g_gameMapManager:checkCanUseFlyShoes(true)
			if ret then
				if transferInObj then
					g_gameMapManager:requestTransfer(sceneId, transferInObj.x + 256/32, transferInObj.y + 256/32+6, 1)
				end
				self:close()
			elseif reason ~= CanNotFlyReason.CastleWar then
				UIManager.Instance:showSystemTips(Config.Words[13021])
			end
		end	
		flyshoesBtn:addTargetWithActionForControlEvents(flyshoesBtnFun, CCControlEventTouchDown)	
	end
end

function WorldMapTipsView:showTableView(sceneIcon)
	self.transferList = {}
	self.transferList = g_smallMapMgr:getDiGongTransitionBySceneId(sceneIcon)
	local transferListSize = table.size(self.transferList)
	if transferListSize > 0 then
		self.tableViewText:setVisible(false)
	else
		self.tableViewText:setVisible(true)
	end
	
	if not self.tableView then
		self:createTableView()
	end
end

function WorldMapTipsView:createTableView()
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
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(gridSize))
			end	
						
			local item = self:createTabelCell(index+1)											
			data:setCell(tableCell)
			tableCell:addChild(item)
			tableCell:setIndex(index)			
			
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			local count = table.size(self.transferList)			
			data:setIndex(count)
			return 1					
		end
	end	
	
	local tableDelegate = function (tableP, cell, x, y)
		self:tableDelegate(tableP, cell, x, y)
	end
	
	if not self.tableView then	
		self.tableView = createTableView(dataHandler, tableSize)		
		self.tableView:setTableViewHandler(tableDelegate)
		self:addChild(self.tableView)		
		VisibleRect:relativePosition(self.tableView, self.textBg, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE)	
		self.tableView:reloadData()
		self.tableView:scroll2Cell(0, false) 			
	end
end

function WorldMapTipsView:tableDelegate(tableP, cell, x, y)
	cell = tolua.cast(cell,"SFTableViewCell")	
	local index = cell:getIndex()+1
	local sceneId = self.transferList[index]
	if sceneId then
		local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
		local conditionLevel = g_smallMapMgr:getConditionLevelBySceneId(sceneId)	
		if heroLevel < conditionLevel then
			UIManager.Instance:showSystemTips(Config.Words[907])
		else
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:startFindTargetPaths(sceneId)
			G_getHandupMgr():stop()
		end
		
		if self.cellFrame:getParent() then
			self.cellFrame:removeFromParentAndCleanup(true)	
		end				
		cell:addChild(self.cellFrame)		
		VisibleRect:relativePosition(self.cellFrame, cell, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)		
	end		
end

function WorldMapTipsView:createTabelCell(index)
	local node = CCNode:create()
	node:setContentSize(gridSize)
	local sceneId = self.transferList[index]
	local name = g_smallMapMgr:getNameBySceneId(sceneId)
	local heroLevel = PropertyDictionary:get_level(G_getHero():getPT())
	local conditionLevel = g_smallMapMgr:getConditionLevelBySceneId(sceneId)	
	
	if name then
		local nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
		node:addChild(nameLabel)
		VisibleRect:relativePosition(nameLabel, node, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE, ccp(10, 0))
	end
	
	if conditionLevel then
		local fontColor = FCOLOR("ColorWhite1")
		if heroLevel < conditionLevel then
			fontColor = FCOLOR("ColorRed1")
		end
		local levelText = conditionLevel .. Config.Words[903]
		local levelLabel = createLabelWithStringFontSizeColorAndDimension(levelText, "Arial", FSIZE("Size3"), fontColor)
		node:addChild(levelLabel)
		VisibleRect:relativePosition(levelLabel, node, LAYOUT_CENTER_Y+LAYOUT_CENTER_X, ccp(30, 0))
	end		
	
	local flyshoesBtn = createButtonWithFramename(RES("map_shoes.png"))
	node:addChild(flyshoesBtn)
	VisibleRect:relativePosition(flyshoesBtn, node, LAYOUT_CENTER_Y+LAYOUT_RIGHT_INSIDE, ccp(-15, 0))
	
	local transferInObj = g_smallMapMgr:getTransferInPointBySceneId(sceneId)
	flyshoesBtn:setTouchAreaDelta(5, 10, 10, 10)	
	local flyshoesBtnFun = function ()
		local ret, reason = g_gameMapManager:checkCanUseFlyShoes(true)
		if ret then
			if transferInObj then
				g_gameMapManager:requestTransfer(sceneId, transferInObj.x, transferInObj.y, 1)
			end
			self:close()
		elseif reason ~= CanNotFlyReason.CastleWar then
			UIManager.Instance:showSystemTips(Config.Words[13021])
		end
	end		
	flyshoesBtn:addTargetWithActionForControlEvents(flyshoesBtnFun, CCControlEventTouchDown)
	
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(gridSize.width, 2))
	node:addChild(line)
	VisibleRect:relativePosition(line, node, LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	
	return node
end

function WorldMapTipsView:createCloseBtn()
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

function WorldMapTipsView:onCloseBtnClick()
	return true
end

function WorldMapTipsView:getSceneIconBySceneId(sceneId)
	if sceneId then
		local sceneIcon = "map_" .. sceneId .. ".png"
		return sceneIcon
	end
end


