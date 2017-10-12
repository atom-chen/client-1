require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require ("object.faction.CommonFactionObject")
FactionApplyTableView = FactionApplyTableView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
--公会列表
function FactionApplyTableView:__init()
	self.applyBtnList = {}	
	self.applyIndex = {}
	self.factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()		
	self.factionInfo = self.factionMgr:getFactionInfo()
	
	if table.size(self.factionInfo)>0 then		--是否已加入公会
		self.factionFlag = true
	else
		self.factionFlag = false
	end
	self.needReload = self.factionFlag		    --是否需要reload	
	
	local totalPart = self.factionMgr:getTotalPart()
	if totalPart then
		self.totalPart = tonumber(totalPart)
	end
	self.page = 1
	self.fullFlag = -1
	self.heroId = GameWorld.Instance:getEntityManager():getHero():getId()	
end

function FactionApplyTableView:__delete()
	self.applyBtnList = nil	
	self.applyIndex = nil
	for i,v in pairs(self.factionList)do
		v:DeleteMe()
	end
end
function FactionApplyTableView:onEnter()
	if table.size(self.factionInfo)>0 then		--是否已加入公会
		self.factionFlag = true
	else
		self.factionFlag = false
	end
	if self.page ~= 1 then
		self.page = 1
	end	
	self.factionApplyTable:reloadData()	
	self.factionApplyTable:scroll2Cell(0,false)
end

function FactionApplyTableView:initTableView(node,tableSize)
	self.viewType = viewType
	self.cellSize =  CCSizeMake(820*g_scale,tableSize.height/5*g_scale)
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
			self.factionList = self.factionMgr:getFactionList()	
			if self.page == 1 then
				if self.factionList then
					self.listSize = table.size(self.factionList)
					if self.listSize then
						if self.totalPart == self.page then
							data:setIndex(self.listSize)
							return 1
						else
							data:setIndex(22)
							return 1
						end
					end
				else
					data:setIndex(0)
					return 1
				end					
			elseif self.page == self.totalPart then				
				if self.factionList then
					self.listSize = table.size(self.factionList)
					if self.listSize then
						if self.listSize <= 21 then
							data:setIndex(self.listSize+1)
							return 1							
						end
					end
				else
					data:setIndex(0)
					return 1
				end	
			else
				self.listSize = table.size(self.factionList)
				data:setIndex(23)
				return 1
			end
		end
	end
	local tableDelegate = function (tableP, cell, x, y)
		return self:tableViewDelegate(tableP, cell, x, y)
	end
	self.factionApplyTable = createTableView(dataHandler, tableSize)
	self.factionApplyTable:setTableViewHandler(tableDelegate)	
	node : addChild(self.factionApplyTable)
	self.factionApplyTable:reloadData()
end

function FactionApplyTableView:tableViewDelegate(tableP, cell, x, y)
	tableP = tolua.cast(tableP,"SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")	
	--记录被选中的index
	local cellSel  = cell:getIndex()+1	
	self.selectedCell = cellSel
	if self.page == 1  then
		if self.listSize >= 21 and self.selectedCell == 22 then
			self.page = self.page+1			
			self.factionMgr:requestFactionList(1,self.page)			
		end
	elseif self.page == self.totalPart and self.page ~= 1 and self.selectedCell == 1 then
		self.page = self.page-1	
		self.factionMgr:requestFactionList(1,self.page)	
	elseif self.page ~= 1 and self.page ~= self.totalPart then
		if self.selectedCell == 1 then
			self.page = self.page-1			
			self.factionMgr:requestFactionList(1,self.page)		
		end
		if self.selectedCell == 23 then
			self.page = self.page+1	
			self.factionMgr:requestFactionList(1,self.page)			
		end
	end		
end
function FactionApplyTableView:createCell(node,tableP,index)
	self.cell = tableP:dequeueCell(index)
	if(self.cell == nil)then
		self.cell = SFTableViewCell:create()
		self.cell: setContentSize(self.cellSize)
		self.cell:setIndex(index)				
		self:addLabel(self.cell,index)
		self:createCellInfo(node,self.cell,index)	
	else		
		self.cell:removeAllChildrenWithCleanup(true)	
		self:createCellInfo(node,self.cell,index)					
		if self.page == 1 then
			local firstChild = self.cell : getChildByTag(2)	
			if firstChild ~= nil then
				self.cell:removeChildByTag(2,true)
			end
		elseif self.page == self.totalPart then
			local lastChild = self.cell : getChildByTag(1)	
			if lastChild ~= nil then
				self.cell:removeChildByTag(1,true)
			end
		end
		self:addLabel(self.cell,index)
		
	end
	return self.cell
end

function FactionApplyTableView:createCellInfo(node,cell,index)
	--[[if(index%2 == 1)then
		local cellBtn = createScale9SpriteWithFrameName(RES("faction_contentBg.png"))
		cellBtn : setContentSize(self.cellSize)
		cell : addChild(cellBtn)
		VisibleRect:relativePosition(cellBtn,cell,LAYOUT_CENTER)
	end		--]]	
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(self.cellSize.width,2))		
	cell : addChild(line)	
	VisibleRect:relativePosition(line,cell,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	if index < self.listSize then
		if self.page == 1 or self.page == self.totalPart then
			self:addInfo(cell,index,self.page)	
			self:initBtn(node,cell,index,self.page)	
		end		
	elseif  index == self.listSize then
		if self.page ~= 1 and self.listSize ~= 21 then
			self:addInfo(cell,index,self.page)
			self:initBtn(node,cell,index,self.page)
		end
	end
	if index<=self.listSize then
		if self.page ~= 1 and self.page ~= self.totalPart and index ~= 22 then
			self:addInfo(cell,index,self.page)	
			self:initBtn(node,cell,index,self.page)		
		end
	end	
end

function FactionApplyTableView:initBtn(node,cell,index,page)
	local addIndex = -1
	if page == 1 then
		addIndex = index+1		
	else
		if index == 0 then
			return 
		else
			addIndex = index	
		end	
	end
	self.applyBtnList = createButtonWithFramename(RES("chat_select_btn.png"), RES("chat_nomal_btn.png"))
	local applyBtnLb =  createSpriteWithFrameName(RES("word_button_apply.png"))
	self.applyBtnList : setTitleString(applyBtnLb)
	cell : addChild(self.applyBtnList)
	VisibleRect:relativePosition(self.applyBtnList,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-40,0))
	self.unApplyBtnList = createSpriteWithFrameName(RES("chat_nomal_btn.png"))
	local unApplyBtnLb =  createSpriteWithFrameName(RES("word_button_apply.png"))
	UIControl:SpriteSetGray(self.unApplyBtnList)
	UIControl:SpriteSetGray(unApplyBtnLb)
	cell : addChild(self.unApplyBtnList)	
	self.unApplyBtnList : addChild(unApplyBtnLb)
	VisibleRect:relativePosition(unApplyBtnLb,self.unApplyBtnList,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.unApplyBtnList,cell,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-40,0))	
	
	--打开
	self.openButton = createButtonWithFramename(RES("chat_select_btn.png"))
	local openText = createSpriteWithFrameName(RES("word_button_open.png"))
	self.openButton:setTitleString(openText)
	cell:addChild(self.openButton)
	VisibleRect:relativePosition(self.openButton, cell, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER, ccp(-40,0))
	
	self:setBtnFlag(addIndex)	
	--按钮功能
	local applyFunction =  function ()	
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local heroId = hero:getId()		
		if self.applyFlag == false then		
			local commonFactionObj = self.factionList[addIndex]
			self.applyFactionName = commonFactionObj:getFactionName()
			local heroLevel = PropertyDictionary:get_level(hero:getPT())
			if self.applyFactionName then			
				if heroLevel < 10 then
					UIManager.Instance:showSystemTips(Config.Words[5568])
				else
					UIManager.Instance:showLoadingHUD(10,node)	
					self.factionMgr:requestJoinFaction(self.applyFactionName)
				end												 
			end
		elseif self.applyFlag == true then			
			local commonFactionObj = self.factionList[addIndex]
			self.cancelFactionName = commonFactionObj:getFactionName()			
			if  self.cancelFactionName then
				self.factionMgr:requestCancelJoin(self.cancelFactionName)
				UIManager.Instance:showLoadingHUD(10,node)				
			end
		end
	end
	self.applyBtnList:addTargetWithActionForControlEvents(applyFunction,CCControlEventTouchDown)
	
	local openFun = function ()
		--GlobalEventSystem:Fire(GameEvent.EventOpenInfoView)
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		factionMgr:requestFactionList("2","1")
	end	
	self.openButton:addTargetWithActionForControlEvents(openFun, CCControlEventTouchDown)
end

function FactionApplyTableView:setTablePosition(node,layoutP)
	VisibleRect:relativePosition(self.factionApplyTable,node,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,layoutP)
end

function FactionApplyTableView:addLabel(cell,index)
	local selIndex = index+1
	if self.page==1  then			
		if self.listSize >= 21 and selIndex == 22 then
			local lastChild = self.cell : getChildByTag(1)	
			if lastChild == nil then
				local lastLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5545], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))	
				cell : addChild(lastLabel)
				lastLabel : setTag(1)
				VisibleRect:relativePosition(lastLabel,cell,LAYOUT_CENTER)
			end			
		end			
	elseif self.page == self.totalPart and selIndex == 1 then
		local lastChild = cell : getChildByTag(1)	
		if lastChild ~= nil then
			cell:removeChildByTag(1,true)
		end
		local firstChild = cell : getChildByTag(2)	
		if firstChild == nil then
			local firstLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5546], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))	
			cell : addChild(firstLabel)
			firstLabel : setTag(2)
			VisibleRect:relativePosition(firstLabel,cell,LAYOUT_CENTER)
		end			
	elseif self.page ~= 1 and self.page ~= self.totalPart then			
		if selIndex == 23 then
			local lastChild = cell : getChildByTag(1)	
			if lastChild == nil then
				local lastLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5545], "Arial",FSIZE("Size4"), FCOLOR("ColorWhite2"))	
				cell : addChild(lastLabel)
				lastLabel : setTag(1)
				VisibleRect:relativePosition(lastLabel,cell,LAYOUT_CENTER)
			end			
		end
		if selIndex == 1 then		
			local firstChild = cell : getChildByTag(2)	
			if firstChild == nil then
				local firstLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5546], "Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))	
				cell : addChild(firstLabel)
				firstLabel : setTag(2)
				VisibleRect:relativePosition(firstLabel,cell,LAYOUT_CENTER)
			end			
		end
	end
end

function FactionApplyTableView:addInfo(cell,index,page)
	local addIndex = -1
	if page == 1 then
		addIndex = index+1		
	else
		if index == 0 then
			return 
		else
			addIndex = index	
		end	
	end
	if self.factionList then
		local commonFactionObj = self.factionList[addIndex]
		self.factionName = commonFactionObj:getFactionName()		
		local applyFactionName = self.factionMgr:getApplyFactionName()
		if applyFactionName ~= "" then
			if applyFactionName == self.factionName then
				self.applyIndex[addIndex] = addIndex 
			else
				self.applyIndex[addIndex] = -1
			end
		else
			self.applyIndex = {}
		end
		local memNum = commonFactionObj:getMemNum()
		
		if memNum == 50 then
			self.memNumWord = memNum..Config.Words[5556]
			self.fullFlag = addIndex
		else
			self.memNumWord = memNum
			self.fullFlag = -1
		end
		self.nameLb = createLabelWithStringFontSizeColorAndDimension(self.factionName,"Arial",FSIZE("Size4"), FCOLOR("ColorWhite2"))		
		self.chairmanLb = createLabelWithStringFontSizeColorAndDimension(commonFactionObj:getChairManName(),"Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
		self.memNumLb = createLabelWithStringFontSizeColorAndDimension(self.memNumWord,"Arial", FSIZE("Size4"), FCOLOR("ColorWhite2"))
		self.rankLb = createLabelWithStringFontSizeColorAndDimension(commonFactionObj:getRank(),"Arial",FSIZE("Size4"), FCOLOR("ColorWhite2"))			
		cell:addChild(self.nameLb)		
		cell:addChild(self.chairmanLb)
		cell:addChild(self.memNumLb)
		cell:addChild(self.rankLb)			
		VisibleRect:relativePosition(self.rankLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(50,0))
		VisibleRect:relativePosition(self.nameLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(190,0))
		VisibleRect:relativePosition(self.chairmanLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(350,0))
		VisibleRect:relativePosition(self.memNumLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(535,0))				
	end	
end
function FactionApplyTableView:setBtnFlag(index)	
	local commonFactionObj = self.factionList[index]
	local applyFactionName = commonFactionObj:getFactionName()
	local hero = G_getHero()
	local unionName = PropertyDictionary:get_unionName(hero:getPT())
	if unionName and unionName == applyFactionName then
		self.openButton:setVisible(true)
		self.applyBtnList: setVisible(false)
		self.unApplyBtnList : setVisible(true)	
		return		
	end
	
	self.openButton:setVisible(false)
	if self.factionFlag == true  then	
		self.applyBtnList: setVisible(false)
		self.unApplyBtnList : setVisible(true)							
	else
		if table.size(self.applyIndex)>0 then
			if index == self.applyIndex[index] then
				local cancelBtnLb =  createSpriteWithFrameName(RES("word_button_cancelApply.png"))
				self.applyBtnList:setTitleString(cancelBtnLb)
				self.applyBtnList : setVisible(true)
				self.unApplyBtnList : setVisible(false)
				self.applyFlag = true
			else
				self.applyBtnList: setVisible(false)
				self.unApplyBtnList : setVisible(true)	
			end
		else
			local applyBtnLb =  createSpriteWithFrameName(RES("word_button_apply.png"))
			self.applyBtnList:setTitleString(applyBtnLb)
			self.applyBtnList: setVisible(true)
			self.unApplyBtnList: setVisible(false)		
			self.applyFlag = false	
		end
	end
	if self.fullFlag == index and  index ~= self.applyIndex[index] then
		self.applyBtnList: setVisible(false)
		self.unApplyBtnList : setVisible(true)	
	end
	
end

function FactionApplyTableView:refreshApplyBtn()	
	self.factionMgr:setApplyFactionName(self.applyFactionName)
	self.factionApplyTable:reloadData()
end

function FactionApplyTableView:refreshCancelApplyBtn()
	self.factionMgr:setApplyFactionName("")
	self.factionApplyTable:reloadData()
end

