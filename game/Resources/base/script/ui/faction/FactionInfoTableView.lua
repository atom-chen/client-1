require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require ("object.faction.MemberObject")
--成员信息
FactionInfoTableView = FactionInfoTableView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local E_isOnline = { Online = 1,Offline = 0}
function FactionInfoTableView:__init()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local totalPart = factionMgr:getTotalPart()
	if totalPart then
		self.totalPart = tonumber(totalPart)
	end	
	self.page = 1
	self.heroId = GameWorld.Instance:getEntityManager():getHero():getId()
	self.memberCount = factionMgr:getMemberNum()
end

function FactionInfoTableView:__delete()
	for i,v in pairs(self.memberList) do
		v:DeleteMe()
	end
end

function FactionInfoTableView:onEnter()
	--[[local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local memberCount = factionMgr:getMemberNum()
	if self.memberCount ~= memberCount then
		self.factionInfoTable:reloadData()
		self.memberCount = memberCount
	end		
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local totalPart = factionMgr:getTotalPart()
	if totalPart ~= self.totalPart then
		self.totalPart = tonumber(totalPart)
		self.factionInfoTable:reloadData()		
	end	
	if self.page ~= 1 then
		self.page = 1
		self.factionInfoTable:reloadData()		
	end		--]]
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	if self.factionInfoTable then
		local totalPart = factionMgr:getTotalPart()
		if totalPart ~= self.totalPart then
			self.totalPart = tonumber(totalPart)			
		end	
		local memberCount = factionMgr:getMemberNum()
		if self.memberCount ~= memberCount then
			self.memberCount = memberCount
		end		
		if self.page ~= 1 then
			self.page = 1
		end
		self.factionInfoTable:reloadData()	
		self.factionInfoTable:scroll2Cell(0,false)
	end
end

function FactionInfoTableView:initTableView(node,tableSize)
	self.cellSize =  CCSizeMake(540*g_scale,49*g_scale)	
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
			data:setCell(self:createCell(tableP, index))
			return 1

		elseif eventType == kNumberOfCellsInTableView then
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
			self.memberList = factionMgr:getMemberList()
			if self.page == 1 then
				if self.memberList then
					self.listSize = table.size(self.memberList)
					if self.listSize then
						if self.page == self.totalPart then
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
			elseif self.page == self.totalPart and self.page ~= 1 then
				if self.memberList then
					self.listSize = table.size(self.memberList)
					if self.listSize then
						if self.listSize < 21 then
							data:setIndex(self.listSize+1)
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
			else
				self.listSize = table.size(self.memberList)
				data:setIndex(23)
				return 1
			end
		end
	end
	local tableDelegate = function (tableP, cell, x, y)
		return self:tableViewDelegate(tableP, cell, x, y)
	end	
	self.factionInfoTable = createTableView(dataHandler, tableSize)	
	self.factionInfoTable:setTableViewHandler(tableDelegate)
	--self.factionInfoTable:retain()
	node : addChild(self.factionInfoTable)	
	self.factionInfoTable:reloadData()		
end

function FactionInfoTableView:tableViewDelegate(tableP, cell, x, y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
--		CCLuaLog(x.." "..y)
		--记录被选中的index					
		local cellSel  = cell:getIndex()+1	
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		self.selectedCell = cellSel
		if self.memberList then
			if self.page == 1 and self.selectedCell ~= 22 then
				self:showMemInfo(1)
			elseif self.page == self.totalPart and self.page  ~= 1 and self.selectedCell ~= 1 then				
				self:showMemInfo(2)			
			elseif self.page ~= 1 and self.page ~= self.totalPart and self.selectedCell ~= 1 and self.selectedCell ~= 23 then
				self:showMemInfo(2)		
			end		
		end
		if self.page == 1  then
			if self.listSize >= 21 and self.selectedCell == 22 then
				self.page = self.page+1			
				factionMgr:requestFactionList(2,self.page)			
			end
		elseif self.page == self.totalPart and self.page ~= 1 and self.selectedCell == 1 then
			self.page = self.page-1	
			factionMgr:requestFactionList(2,self.page)		
		elseif self.page ~= 1 and self.page ~= self.totalPart then
			if self.selectedCell == 1 then
				self.page = self.page-1			
				factionMgr:requestFactionList(2,self.page)		
			end
			if self.selectedCell == 23 then
				self.page = self.page+1	
				factionMgr:requestFactionList(2,self.page)			
			end
		end		
end

function FactionInfoTableView:showMemInfo(flag)
	if flag == 1 then
		self.memIndex = self.selectedCell
	elseif flag == 2 then
		self.memIndex = self.selectedCell-1
	end
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	local memberName = self.memberList[self.memIndex].memName
	local g_hero = GameWorld.Instance:getEntityManager():getHero()	
	local heroName = PropertyDictionary:get_name(g_hero:getPT()) 	
	if memberName ~= heroName then
		factionMgr:setInfoIndex(self.memIndex)
		factionMgr:setInfoPage(self.page)
		factionMgr:showPlayerInfo(self.memberList[self.memIndex])	
	end
end
function FactionInfoTableView:createCell(tableP,index)
	self.cell = tableP:dequeueCell(index)
	if(self.cell == nil)then
		self.cell = SFTableViewCell:create()
		self.cell: setContentSize(self.cellSize)
		self.cell:setIndex(index)		
		
		--翻页
		self:addLabel(self.cell,index)
		self:createCellInfo(self.cell,index)	
	else
		self.cell:removeAllChildrenWithCleanup(true)	
		self:createCellInfo(self.cell,index)			
		--翻页
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
--翻页标签
function FactionInfoTableView:addLabel(cell,index)
	local selIndex = index+1
	if self.page==1  then			
		if self.listSize >= 21 and selIndex == 22 then
			local lastChild = self.cell : getChildByTag(1)	
			if lastChild == nil then
				local lastLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5545], "Arial",FSIZE("Size3"), FCOLOR("ColorYellow5"))	
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
			local firstLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5546], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))	
			cell : addChild(firstLabel)
			firstLabel : setTag(2)
			VisibleRect:relativePosition(firstLabel,cell,LAYOUT_CENTER)
		end			
	elseif self.page ~= 1 and self.page ~= self.totalPart then			
		if selIndex == 23 then
			local lastChild = cell : getChildByTag(1)	
			if lastChild == nil then
				local lastLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5545], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))	
				cell : addChild(lastLabel)
				lastLabel : setTag(1)
				VisibleRect:relativePosition(lastLabel,cell,LAYOUT_CENTER)
			end			
		end
		if selIndex == 1 then		
			local firstChild = cell : getChildByTag(2)	
			if firstChild == nil then
				local firstLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[5546], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))	
				cell : addChild(firstLabel)
				firstLabel : setTag(2)
				VisibleRect:relativePosition(firstLabel,cell,LAYOUT_CENTER)
			end			
		end
	end
end
function FactionInfoTableView:createCellInfo(cell,index)
	local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"),CCSizeMake(self.cellSize.width,2))	
	cell : addChild(line)	
	VisibleRect:relativePosition(line,cell,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)		
	if index < self.listSize then
		if self.page == 1 then
			self:addInfo(cell,index,self.page)				
		elseif self.page == self.totalPart  then
			self:addInfo(cell,index,self.page)			
		end
	elseif  index == self.listSize then
		if self.page ~= 1 and self.listSize ~= 21 then
			self:addInfo(cell,index,self.page)
		end
	end
	if index<=self.listSize then
		if self.page ~= 1 and self.page ~= self.totalPart and index ~= 22 then
			self:addInfo(cell,index,self.page)			
		end
	end	
end

function FactionInfoTableView:addInfo(cell,index,page)		--成员信息标签
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
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
	if self.memberList then
		local listSize = table.size(self.memberList)
		local memObj = self.memberList[addIndex]	
		if not memObj then
			CCLuaLog("Error in FactionInfoTableView addInfo")
			return
		end	
		local name = memObj:getMemName()
		local professsionId = memObj:getProfesssionId()
		local level = memObj:getLevel()
		local fightValue = memObj:getFightValue()
		local officeId = memObj:getOffice()
		if officeId == 1 then		
			factionMgr:setChairmanIndex(addIndex)
		end
		local isOnline = memObj:getOnline()				
		local nameLb = createLabelWithStringFontSizeColorAndDimension(name,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		local professsionName = G_getProfessionNameById(professsionId)
		local professsionLb = createLabelWithStringFontSizeColorAndDimension(professsionName,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		local levelLb = createLabelWithStringFontSizeColorAndDimension(level,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		local fightValueLb = createLabelWithStringFontSizeColorAndDimension(fightValue,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))	
		local officeName = factionMgr:getOfficeNameById(officeId)		
		local offLb = createLabelWithStringFontSizeColorAndDimension(officeName,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
		
		local g_hero = GameWorld.Instance:getEntityManager():getHero()	
		local myName =  PropertyDictionary:get_name(g_hero:getPT())
		cell:addChild(nameLb)
		cell:addChild(professsionLb)
		cell:addChild(levelLb)
		cell:addChild(fightValueLb)
		cell:addChild(offLb)		
		professsionLb:setTag(3)		
		local vipType = memObj:getVipType()				
		if vipType and vipType>0 then
			local vipIcon = createSpriteWithFrameName(RES("common_vip"..vipType..".png"))
			cell:addChild(vipIcon)
			VisibleRect:relativePosition(vipIcon,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(15,0))
			VisibleRect:relativePosition(nameLb,vipIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(3,0))
		else
			VisibleRect:relativePosition(nameLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(15,0))
		end		
		VisibleRect:relativePosition(professsionLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(135,0))
		VisibleRect:relativePosition(levelLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(225,0))
		VisibleRect:relativePosition(fightValueLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(295,0))
		VisibleRect:relativePosition(offLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(380,0))
		local logoutType = memObj:getLogoutType()
		local logoutWord = factionMgr:getLogoutWordsByType(logoutType)		
		local logoutLb = createLabelWithStringFontSizeColorAndDimension(logoutWord,"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))		
		cell:addChild(logoutLb)
		VisibleRect:relativePosition(logoutLb,cell,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(470,0))			
		local color 
		if isOnline == E_isOnline.Offline then			--不在线
			color = FCOLOR("black4")			
		elseif isOnline == E_isOnline.Online then		--在线
			color = FCOLOR("ColorYellow5")		
		end
		nameLb:setColor(color)
		professsionLb:setColor(color)
		levelLb:setColor(color)
		fightValueLb:setColor(color)
		offLb:setColor(color)
		if logoutLb then
			logoutLb:setColor(color)
		end
	end
end
function FactionInfoTableView:setTablePosition(node,layoutP)
	VisibleRect:relativePosition(self.factionInfoTable,node,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,layoutP)
end	



function FactionInfoTableView:refreshOffice()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	local changeIndex = factionMgr:getInfoIndex()
	local office = factionMgr:getOffice()
	if office and changeIndex then
		local memObj = self.memberList[changeIndex]
		memObj:setOffice(office)
		if office == 1 then
			local chairmanIndex = factionMgr:getChairmanIndex()
			if chairmanIndex then
				local chairmanObj = self.memberList[chairmanIndex]
				if chairmanObj then
					chairmanObj:setOffice(3)
				end
				local changeCell = self.factionInfoTable:cellAtIndex(changeIndex-1)
				local chairmanCell = self.factionInfoTable:cellAtIndex(chairmanIndex-1)
				if changeCell and chairmanCell then
					self.factionInfoTable:updateCellAtIndex(changeIndex-1)
					self.factionInfoTable:updateCellAtIndex(chairmanIndex-1)
				end	
			end
		else
			if changeIndex then
				local changeCell = self.factionInfoTable:cellAtIndex(changeIndex-1)
				if changeCell then
					self.factionInfoTable:updateCellAtIndex(changeIndex-1)
				end	
			end
		end
	end	
end


