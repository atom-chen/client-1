require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.stronger.cell.BaseStrongerCell")
require("ui.stronger.StrongerDetailView")

StrongerView = StrongerView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local const_size = CCSizeMake(833, 460)	
local const_optionCellSize = CCSizeMake(176, 64)
local const_optionTableViewSize = CCSizeMake(176, 425)

local getMgr = function()
	return GameWorld.Instance:getStrongerMgr()
end

function StrongerView:__init()
	self.viewName = "StrongerView"
	self.size = self:initFullScreen()
	
	local forgeNode = createSpriteWithFrameName(RES("menu_1_icon.png"))
	self:setFormImage(forgeNode)
	local titleNode = createSpriteWithFrameName(RES("word_window_strong.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)		
	
	self.curOptionIndex = -1
	self.optionList = {}	
		
	self:buildOptionList()
	self:initUI()
	self:showFightPower()
end

function StrongerView:__delete()
	getMgr():clearReadyCallBack()
end

function StrongerView:getStrongerCell(refId)
	return self.detailView:getCell(refId)
end

function StrongerView:onEnter()
	self:showOptionDetail(0)
	self:showFightPower()
end

function StrongerView:onExit()	
	getMgr():clearReadyCallBack()
end	

function StrongerView:showOptionDetailByRefId(refId)
	local index = self:findOptionIndexByRefId(refId)
	if index then
		self:showOptionDetail(index, true)
	end	
end	

----------------------内部接口---------------------

function StrongerView:findOptionIndexByRefId(refId)
	for k, v in ipairs(self.optionList) do
		if v == refId then
			return k-1
		end
	end
	return nil
end

--初始化UI
function StrongerView:initUI()
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), const_size)
	self:addChild(bg)
	VisibleRect:relativePosition(bg, self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -10))
	
	local bgLeft = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"), CCSizeMake(const_optionTableViewSize.width + 15, const_optionTableViewSize.height + 15))
	self:addChild(bgLeft)
	VisibleRect:relativePosition(bgLeft, bg, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(10, 0))
	
	self:initOptionTableView()
	VisibleRect:relativePosition(self.optionTableView, bgLeft, LAYOUT_CENTER)
	
	self:initOptionDetailView()
	VisibleRect:relativePosition(self.detailView:getRootNode(), bgLeft, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(7, 0))			
end

function StrongerView:initOptionDetailView()
	self.detailView = StrongerDetailView.New()
	self:addChild(self.detailView:getRootNode())
end	

function StrongerView:initOptionTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.optionTableView = createTableView(dataHandler, const_optionTableViewSize)
	self.optionTableView:setTableViewHandler(tableDelegate)
	self.optionTableView:setClippingToBounds(true)
	self:addChild(self.optionTableView)
	self.optionTableView:reloadData()
end

function StrongerView:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_optionCellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_optionCellSize)
		return 1
	elseif eventType == kTableCellAtIndex then			
		local cell = self:createCell(tableView, index)
		if cell then
			data:setCell(cell)
		end
		return 1
	elseif eventType == kNumberOfCellsInTableView then
		if table.size(self.optionList) == 0 then
			data:setIndex(4)			
		else
			data:setIndex(table.size(self.optionList))			
		end
		return 1
	end
	return 0
end

function StrongerView:createCell(tableView, index)
	if not tableView or not index then
		return nil
	end
	local cell = tableView:dequeueCell(index)		
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_optionCellSize)
		cell:setIndex(index)					
	else
		cell:removeAllChildrenWithCleanup(true)		
	end
	
	local option = self.optionList[index + 1]
	if not option then
		return cell
	end
	
	local bg 
	if index == self.curOptionIndex then
		bg = createScale9SpriteWithFrameNameAndSize(RES("rank_select_btn.png"), const_optionCellSize)
	else
		bg = createScale9SpriteWithFrameNameAndSize(RES("rank_nomal_btn.png"), const_optionCellSize)
	end
	cell:addChild(bg)		
	VisibleRect:relativePosition(bg, cell, LAYOUT_CENTER)
	
	local iconPath, iconWay = getMgr():getMenuIconId(option)	
		local bg = createSpriteWithFrameName(RES("bagBatch_itemBg.png"))	
		bg:setScale(0.6)
		cell:addChild(bg)	
		VisibleRect:relativePosition(bg, cell, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(16, 0))	
		
		if iconPath and iconWay then
		local icon 
		if iconWay == "icon" then
			icon = createSpriteWithFileName(ICON(iconPath))
		else
			icon = createSpriteWithFrameName(RES(iconPath..".png"))
		end
--		icon:setScale(0.6)
		bg:addChild(icon)	
		VisibleRect:relativePosition(icon, bg, LAYOUT_CENTER)		
	end
		
	local word = createSpriteWithFrameName(RES("strong_"..option.."_name.png"))
	cell:addChild(word)	
	VisibleRect:relativePosition(word, cell, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE, ccp(-10, 0))

	return cell
end

function StrongerView:tableViewDelegate(tableView, cell, x, y)
	tableView = tolua.cast(tableView, "SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")

	local index = cell:getIndex()
	self:showOptionDetail(index)	
end

--构建变强的选项卡：我要变强，我要经验，我要装备等
--TODO: 改为读取配置
function StrongerView:buildOptionList()
	self.optionList = GameWorld.Instance:getStrongerMgr():getMuneList()
end	

function StrongerView:showOptionDetail(index, bSrollTo)		
	if not index or not self.optionList[index + 1] then
		return
	end					
		
	if self.curOptionIndex >= 0 then
		local oldIndex = self.curOptionIndex
		self.curOptionIndex = index		
		self.optionTableView:updateCellAtIndex(oldIndex)
		self.optionTableView:updateCellAtIndex(self.curOptionIndex)	
	else		
		self.curOptionIndex = index			
		self.optionTableView:reloadData()	
	end
	if bSrollTo then
		self.optionTableView:scroll2Cell(index, false)
	end
	self:doShowOptionDetail(index)
end

--根据选项卡Id显示详情
function StrongerView:doShowOptionDetail(index)
	if not index then
		return
	end
	local optionId = self.optionList[index + 1]
	if not optionId then
		return
	end		
	
	local contentList = getMgr():getContentList(optionId)
	if type(contentList) ~= "table" then
		print("StrongerView:doShowOptionDetail Get data failed. optionId="..optionId)
		return
	end				
	getMgr():clearReadyCallBack()
	self.detailView:setContent(contentList)
end

function StrongerView:showFightPower()
	if (self.fpLabel == nil) then
		local fpBg = createSpriteWithFrameName(RES("player_fighting_lable.png"))
		self:addChild(fpBg)
		VisibleRect:relativePosition(fpBg, self:getContentNode(), LAYOUT_TOP_OUTSIDE + LAYOUT_RIGHT_INSIDE, ccp(-200, 0))
		local atlasName = Config.AtlasImg.PlayerFightNumber		
		self.fpLabel = createAtlasNumber(atlasName, "100")
		self:addChild(self.fpLabel)
		VisibleRect:relativePosition(self.fpLabel, fpBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	end

	local fp = PropertyDictionary:get_fightValue(G_getHero():getPT())
	if (fp ~= nil) then
				self.fpLabel:setString(string.format("%d", fp))
	else 
		self.fpLabel:setString("")
	end
end