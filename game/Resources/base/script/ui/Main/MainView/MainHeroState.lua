--[[
人物状态界面
--]]
require("common.baseclass")
require("config.words")
MainHeroState = MainHeroState or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()


function MainHeroState:__init()
	self.cellContent = 
{
	--[[[1] = {icon = "main_peace.png" , des = Config.Words[12001]},
	[2] = {icon = "main_together.png" , des = Config.Words[12002]},
	[3] = {icon = "main_sociaty.png" , des = Config.Words[12003]},
	[4] = {icon = "main_goodAndEvil.png" , des = Config.Words[12004]},
	[5] = {icon = "main_whole.png" , des = Config.Words[12005]},--]]
	
	{icon = "main_peace.png" , des = Config.Words[12001],stateId = E_HeroPKState.statePeace},
	{icon = "main_together.png" , des = Config.Words[12002],stateId = E_HeroPKState.stateQueue},
	{icon = "main_sociaty.png" , des = Config.Words[12003],stateId = E_HeroPKState.stateFaction},
	{icon = "main_goodAndEvil.png" , des = Config.Words[12004],stateId = E_HeroPKState.stateGoodOrEvil},
	{icon = "main_whole.png" , des = Config.Words[12005],stateId = E_HeroPKState.stateWhole},
}
	self.rootNode = createScale9SpriteWithFrameName(RES("countDownBg.png"))	
	self.rootNode:retain()	
	self.tableSize = CCSizeMake(300*const_scale,300*const_scale)
	self.rootNode:setContentSize(self.tableSize)	
	self.hero = GameWorld.Instance:getEntityManager():getHero()	
	self:initStateTable()
end

function MainHeroState:__delete()
	self.rootNode:release()
end

function MainHeroState:getRootNode()
	return self.rootNode
end

function MainHeroState:initStateTable()
	self.cellSize =  CCSizeMake(312*const_scale,60*const_scale)	
	self.selectedCell = -1  --记录被选择的item号	
	local dataHandler = function(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")	
		--tableview数据源的类型
		local kTableCellSizeForIndex = 0
		local kCellSizeForTable = 1
		local kTableCellAtIndex = 2
		local kNumberOfCellsInTableView = 3
	
		if eventType == kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(self.cellSize))
			return 1
		elseif eventType == kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(self.cellSize))
			return 1
		elseif eventType == kTableCellAtIndex then	
			data:setCell(self:createCell(tableP, index))	
			return 1
		elseif eventType == kNumberOfCellsInTableView then			
			data:setIndex(5)
			return 1			
		end
	end
	
	local tableDelegate = function (tableP, cell, x, y)
		return self:tableViewDelegate(tableP, cell, x, y)
	end
			
	self.stateTable = createTableView(dataHandler, self.tableSize)
	self.stateTable:setTableViewHandler(tableDelegate)
	self.rootNode : addChild(self.stateTable)	
	self.stateTable:reloadData()
end

function MainHeroState:createCell(tableP,index)
	self.cell = tableP:dequeueCell(index)
	if(self.cell == nil)then
		self.cell = SFTableViewCell:create()
		self.cell: setContentSize(self.cellSize)
		self.cell:setIndex(index)			
		local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(self.cellSize.width-20,2))	
		self.cell:addChild(line)
		VisibleRect:relativePosition(line,self.cell,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
		local iconName = self.cellContent[index+1].icon
		local icon = createSpriteWithFrameName(RES(iconName))
		G_setScale(icon)
		self.cell:addChild(icon)
		VisibleRect:relativePosition(icon,self.cell,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(5,0))
		local des = self.cellContent[index+1].des
		local desLb = createLabelWithStringFontSizeColorAndDimension(des,"Arial", FSIZE("Size2"), FCOLOR("ColorWhite3"))
		self.cell:addChild(desLb)
		VisibleRect:relativePosition(desLb,icon,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	else
		
	end
	return self.cell
end



function MainHeroState:tableViewDelegate(tableP, cell, x, y)
	tableP = tolua.cast(tableP,"SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")
	local stateId  = self.cellContent[cell:getIndex()+1].stateId	
	local heroObj = GameWorld.Instance:getEntityManager():getHero()
	if heroObj then
		heroObj:changeHeroPKState(stateId)
	end
	self:clickCellByGoodOrEvil(stateId)
end

function MainHeroState:getCellNode(index)
	local cellIndex = -1
	for key,value in pairs(self.cellContent) do
		if value.stateId == index then
			cellIndex = key
			break
		end
	end
	if self.stateTable and index and cellIndex ~= -1 then
		local cell = self.stateTable:cellAtIndex(cellIndex-1)		
		return cell		
	end
end

function MainHeroState:clickCellByGoodOrEvil(index)
	if index==E_HeroPKState.stateWhole then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainHeroHead","stateWhole")	
	end
end	