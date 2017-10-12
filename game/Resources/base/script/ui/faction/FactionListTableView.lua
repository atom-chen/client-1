require("ui.UIManager")
require("common.BaseUI")
require("config.words")
--成员申请列表
FactionListTableView = FactionListTableView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function FactionListTableView:__init()
	self.charId = {}
	
end

function FactionListTableView:__delete()

end

function FactionListTableView:initTableView(node,tableSize)
	self.cellSize =  CCSizeMake(554*g_scale,tableSize.height/6*g_scale)	
	self.selectedCell = -1  --记录被选择的item号	
	function dataHandler(eventType,tableP,index,data)
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
			data:setCell(self:createCell(node,tableP, index))
			return 1

		elseif eventType == kNumberOfCellsInTableView then
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
			self.applyList = factionMgr:getApplyList()
			if self.applyList then
				self.listSize = table.size(self.applyList)
			end
			if self.listSize then
				data:setIndex(self.listSize)
				return 1
			else
				data:setIndex(0)
				return 1
			end
		end
	end
	local tableDelegate = function (tableP,cell,x,y)
		self:tableDelegate(tableP,cell,x,y)	
	end
	self.factionListTable = createTableView(dataHandler, tableSize)	
	self.factionListTable:setTableViewHandler(tableDelegate)
	node : addChild(self.factionListTable)	
	self.factionListTable:reloadData()		
end
function FactionListTableView:tableDelegate(tableP,cell,x,y)
	tableP = tolua.cast(tableP,"SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")
--	CCLuaLog(x.." "..y)
	--记录被选中的index					
	local cellSel  = cell:getIndex()+1	
	self.selectedCell = cellSel
	if self.applyList then	
		if self.listSize == 21 then
			if self.listSize > self.selectedCell then
				self:showApplyInfo()
			end
		else
			self:showApplyInfo()
		end
	end
	self.factionListTable:reloadData()	
end
function FactionListTableView:showApplyInfo()
	local memberName = self.applyList[self.selectedCell].name
	local g_hero = GameWorld.Instance:getEntityManager():getHero()	
	local heroName = PropertyDictionary:get_name(g_hero:getPT()) 
	if memberName ~= heroName then
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
		factionMgr:setApplyIndex(self.selectedCell)
		factionMgr:showApplyPlayerInfo(self.applyList[self.selectedCell])
	end		
end
function FactionListTableView:createCell(node,tableP,index)
	self.cell = tableP:dequeueCell(index)
	if(self.cell == nil)then
		self.cell = SFTableViewCell:create()
		self.cell: setContentSize(self.cellSize)
		self.cell:setIndex(index)
		self:addCellContent(node,self.cell,index)				
	else	
		self.cell:removeAllChildrenWithCleanup(true)
		self:addCellContent(node,self.cell,index)
	end
	return self.cell
end

function FactionListTableView:addCellContent(node,cell,index)
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(self.cellSize.width,2))	
	cell : addChild(line)	
	VisibleRect:relativePosition(line,cell,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	if table.size(self.applyList)>0 then
		self.charId[index+1] = self.applyList[index+1].charId	
		local nameLb = createLabelWithStringFontSizeColorAndDimension(self.applyList[index+1].name,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		local professsionId = self.applyList[index+1].professsionId
		local professsionName = G_getProfessionNameById(professsionId)
		local professsionLb = createLabelWithStringFontSizeColorAndDimension(professsionName,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		local levelLb = createLabelWithStringFontSizeColorAndDimension(self.applyList[index+1].level,"Arial",FSIZE("Size3"), FCOLOR("ColorYellow5"))		
		cell:addChild(nameLb)
		cell:addChild(professsionLb)
		cell:addChild(levelLb)
		VisibleRect:relativePosition(nameLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(25,0))
		VisibleRect:relativePosition(professsionLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(165,0))
		VisibleRect:relativePosition(levelLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(260,0))
		local vipType = self.applyList[index+1].vipType
		if vipType and vipType>0 then
			local vipIcon = createSpriteWithFrameName(RES("common_vip"..vipType..".png"))
			cell:addChild(vipIcon)
			VisibleRect:relativePosition(vipIcon,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(15,0))
			VisibleRect:relativePosition(nameLb,vipIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(3,0))
		else
			VisibleRect:relativePosition(nameLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(15,0))
		end	
		--按钮		
		self.agreeBtnList= createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))	
		self.rejectBtnList = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))	
		local agreeBtnLb =  createSpriteWithFrameName(RES("word_button_agree.png"))
		local rejectlBtnLb =  createSpriteWithFrameName(RES("word_button_reject.png"))
		cell : addChild(self.agreeBtnList)
		cell : addChild(self.rejectBtnList)
		self.agreeBtnList : setTitleString(agreeBtnLb)
		self.rejectBtnList : setTitleString(rejectlBtnLb)			
		VisibleRect:relativePosition(self.rejectBtnList,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-5,0))
		VisibleRect:relativePosition(self.agreeBtnList,self.rejectBtnList,LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(-25,0))
		local applyFunction =  function ()	--同意
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()			
			local factionName = factionMgr:getFactionInfo().factionName
			if self.charId[index+1] and factionName then
				factionMgr:requestHandleApply(self.charId[index+1],factionName,"1")
				factionMgr:setHandlerIndex(index+1)
				UIManager.Instance:showLoadingHUD(10,node)
			end
		end
		self.agreeBtnList:addTargetWithActionForControlEvents(applyFunction,CCControlEventTouchDown)
		
		local cancelFunction =  function ()		--拒绝
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()			
			local factionName = factionMgr:getFactionInfo().factionName
			if self.charId[index+1] and factionName then
				factionMgr:requestHandleApply(self.charId[index+1],factionName,"0")
				factionMgr:setHandlerIndex(index+1)
				UIManager.Instance:showLoadingHUD(10,node)
			end
		end
		self.rejectBtnList:addTargetWithActionForControlEvents(cancelFunction,CCControlEventTouchDown)
	end		
end
function FactionListTableView:setTablePosition(node,layoutP)
	VisibleRect:relativePosition(self.factionListTable,node,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,layoutP)
end	