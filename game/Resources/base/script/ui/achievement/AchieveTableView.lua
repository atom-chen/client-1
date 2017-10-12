require("ui.UIManager")
require("common.BaseUI")
require("config.words")

AchieveTableView = AchieveTableView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

local KTAG = {
completedIconTag = 1,
uncompletedIconTag = 2,
nameLbTag = 3,
ReceiveIconTag = 4
}

function AchieveTableView:__init()
	self.nameLb = {}
	self.completedList = {}
	self.showDoing = {}
	--self:refreshCompletedList()
end

function AchieveTableView:__delete()
	self.box : release()

	self.nameLb = {}
	self.completedList = {}
	self.showDoing = {}
end
function AchieveTableView:getTableCellAndSelectCellIndex()
	return self.cell,self.selectedCell
end
function AchieveTableView:initTableView(node,list,viewType)
	self.viewType = viewType	
	self.listSize  = table.size(list)
	local tableSize = CCSizeMake(290*g_scale,368*g_scale)
	self.cellSize =  CCSizeMake(290*g_scale,65*g_scale)
	self.box = createScale9SpriteWithFrameNameAndSize(RES("commom_SelectFrame.png"),self.cellSize) 
	self.box:retain()	
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
			data:setCell(self:createCell(tableP, index,list,viewType))	
			return 1
		elseif eventType == kNumberOfCellsInTableView then
			if(self.listSize) then
				data:setIndex(self.listSize)
				return 1
			else
				data:setIndex(0)
				return 1
			end
		end
	end
	
	local tableDelegate = function (tableP, cell, x, y)
		return self:tableViewDelegate(tableP, cell, x, y,list)
	end
		
	
	self.achieveTable = createTableView(dataHandler, tableSize)
	self.achieveTable:setTableViewHandler(tableDelegate)
	node : addChild(self.achieveTable)	
	self.achieveTable:reloadData()
	
end

function AchieveTableView:setNameLabel(list, index)
	if list then
		local name = list[index+1].property.name
		self.nameLb[index+1] = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
		self.cell : addChild(self.nameLb[index+1])
		self.nameLb[index+1] : setTag(KTAG.nameLbTag)
		VisibleRect:relativePosition(self.nameLb[index+1],self.cell,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(15,0))
	end
end

function AchieveTableView:setCompletedLogo(viewType, index)
	if self.completedList[viewType][index+1].flag == false then
		local completeChild = self.cell : getChildByTag(KTAG.completedIconTag)					
		if(completeChild ~= nil) then
			self.cell:removeChildByTag(KTAG.completedIconTag,true)
		end
		local getChild = self.cell : getChildByTag(KTAG.ReceiveIconTag)					
		if(getChild == nil) then
			local getIcon = createScale9SpriteWithFrameName(RES("main_questReceive.png"))
			getIcon:setRotation(-30)
			self.cell : addChild(getIcon)
			getIcon : setTag(KTAG.ReceiveIconTag)
			VisibleRect:relativePosition(getIcon,self.cell,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE)	
		end		
	elseif self.completedList[viewType][index+1].flag == true then
		local completeChild = self.cell : getChildByTag(KTAG.ReceiveIconTag)					
		if(completeChild ~= nil) then
			self.cell:removeChildByTag(KTAG.ReceiveIconTag,true)
		end
		local completeChild = self.cell : getChildByTag(KTAG.completedIconTag)					
		if(completeChild == nil) then
			local completedIcon = createScale9SpriteWithFrameName(RES("main_questComplete.png"))		
			completedIcon:setRotation(-30)
			self.cell : addChild(completedIcon)
			completedIcon : setTag(KTAG.completedIconTag)
			VisibleRect:relativePosition(completedIcon,self.cell,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE)	
		end			
	end
end

function AchieveTableView:createCell(tableP,index,list,viewType)
	self.cell = tableP:dequeueCell(index)
	if(self.cell == nil)then
		self.cell = SFTableViewCell:create()
		self.cell: setContentSize(self.cellSize)
		self.cell:setIndex(index)		
		local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(self.cellSize.width,2))		
		self.cell : addChild(line)		
		VisibleRect:relativePosition(line,self.cell,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
		self:setNameLabel(list, index)
		if	table.size(self.completedList) > 0 then	
			local cellCompletedInfo = self.completedList[viewType][index+1]
			if cellCompletedInfo then
				self:setCompletedViewState(cellCompletedInfo,viewType,index)					
			end		
		end
		self:setSelectedCell(index)			
	else
		local nameChild = self.cell : getChildByTag(KTAG.nameLbTag) 
		if(nameChild == nil) then
			self:setNameLabel(list, index)
		end
		if	table.size(self.completedList) > 0 then	
			local cellCompletedInfo = self.completedList[viewType][index+1]
			if cellCompletedInfo then
				self:setCompletedViewState(cellCompletedInfo,viewType,index)												
			end	
		end
		self:setSelectedCell(index)		
	end
	return self.cell
end

--设置完成状态
function AchieveTableView:setCompletedViewState(cellCompletedInfo,viewType,index)	
	if cellCompletedInfo.completed == 1 and cellCompletedInfo.nextFlag == 0 then				
		local doingChild = self.cell : getChildByTag(KTAG.uncompletedIconTag)					
		if(doingChild ~= nil) then
			self.cell:removeChildByTag(KTAG.uncompletedIconTag,true)
		end							
		self:setCompletedLogo(viewType, index)
	elseif  cellCompletedInfo.nextFlag == 1 then
		local doingChild = self.cell : getChildByTag(KTAG.uncompletedIconTag)	
		if(doingChild == nil) then
			local uncompletedIcon = createScale9SpriteWithFrameName(RES("main_questDoing.png"))
			uncompletedIcon:setRotation(-30)
			self.cell : addChild(uncompletedIcon)
			uncompletedIcon : setTag(KTAG.uncompletedIconTag)
			VisibleRect:relativePosition(uncompletedIcon,self.cell,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE)
		end
	end			
end


--设置选中状态
function AchieveTableView:setSelectedCell(index)
	local nameLbColor = FCOLOR("ColorWhite2")
	if self.selectedCell == index+1 then
		if(self.box : getParent() == nil) then
			self.cell :addChild(self.box,-1)		
			VisibleRect:relativePosition(self.box,self.cell,LAYOUT_CENTER)
		else 
			self.box : removeFromParentAndCleanup(true)
			self.cell :addChild(self.box,-1)
			VisibleRect:relativePosition(self.box,self.cell,LAYOUT_CENTER)
		end	
		nameLbColor = FCOLOR("ColorYellow1")			
	end	
	self.nameLb[index+1]:setColor(nameLbColor)	
end


function AchieveTableView:tableViewDelegate(tableP, cell, x, y,list)
	tableP = tolua.cast(tableP,"SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")
--	CCLuaLog(x.." "..y)
	--记录被选中的index					
	local cellSel  = cell:getIndex()+1
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local selAchiId = list[cellSel].refId
	achievementMgr:fireSelIndex(selAchiId)
	self.selectedCell = cellSel
	local comList = self.completedList[self.viewType]
	if comList then				
		if (comList[self.selectedCell].completed == 1 and comList[self.selectedCell].flag == false) then
			achievementMgr:openBtn()	
		else			
			achievementMgr:closeBtn()
		end
	end
	achievementMgr:fireRefreshEvent(self.viewType,self.selectedCell)
	self.achieveTable:reloadData()
end

function AchieveTableView:setTablePosition(node,layoutP)
	VisibleRect:relativePosition(self.achieveTable,node,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,layoutP)
end	

function AchieveTableView:refreshCompletedList(vType)
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()
	local completedList = achievementMgr:getCompletedContainerByType(vType)
	if completedList then	
		self.completedList[vType] = nil
		self.completedList[vType] = completedList			
		self.achieveTable:reloadData()
	end
end

function AchieveTableView:scrollTocell(id)
	self.achieveTable:scroll2Cell(id-1,false)
end
