require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.mail.MailContentView")

MailTableView = MailTableView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function MailTableView:__init()
	self.contentLb = {}	
	self.typeLb = {}
	self.btnLb = {}
	--向UIManager注册邮件界面	
	self.uiManager =UIManager.Instance
	self.uiManager:registerUI("MailContentView", MailContentView.New)	
end

function MailTableView:__delete()
	self.box:release()
	self.contentLb = {}	
	self.typeLb = {}
	self.btnLb = {}
end


function MailTableView:initTableView(node,tableSize,list,viewType)
	self.cellSize =  CCSizeMake(tableSize.width,82)
	self.box = createScale9SpriteWithFrameNameAndSize(RES("common_bg3.png"),self.cellSize) 
	self.box:retain()
	self.clickFlag = true
	self.selectedCell = 1  --记录被选择的item号	
	self.mailList = list
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
			self.cell = tableP:dequeueCell(index)
			self.cell = SFTableViewCell:create()
			self.cell: setContentSize(self.cellSize)
			if self.mailList then
				local item = self:createMailItem(index,self.mailList)
				self.cell:addChild(item)
				VisibleRect:relativePosition(item,self.cell,LAYOUT_CENTER)
				
				if self.selectedCell == index+1 then
					if(self.box : getParent() == nil) then
						self.cell : addChild(self.box)					
						VisibleRect:relativePosition(self.box,self.cell,LAYOUT_CENTER)
					else 
						self.box : removeFromParentAndCleanup(true)
						self.cell : addChild(self.box)						
						VisibleRect:relativePosition(self.box,self.cell,LAYOUT_CENTER)
					end							
				end	
			end	
			self.cell:setIndex(index)										
			data : setCell(self.cell)
			return 1

		elseif eventType == kNumberOfCellsInTableView then
			local number = table.size(self.mailList)
			if(number) then
				data:setIndex(number)
				return 1
			else
				data:setIndex(0)
				return 1
			end
		end
	end
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")	
		local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()							
		self.selectedCell  = cell:getIndex()+1			
		if self.mailList and self.mailList[self.selectedCell] then
			local mailObj = self.mailList[self.selectedCell]
			local mailId = mailObj:getMailId()
			if mailObj:getMailContent() then
				self:openMail()
			else
				mailMgr:requestMailContent(mailId)
				UIManager.Instance:showLoadingHUD(20)
			end
			
			--[[if self.mailList[self.selectedCell]:getMailState() == 0 then		--未读
				if self.mailList[self.selectedCell]:isHaveReward() == 0 then				
					mailMgr:requestMailRead(self.mailList[self.selectedCell]:getMailId())
					self.mailList[self.selectedCell]:setMailState(1) 	--将邮件状态设置为已读
					--mailObj = self.mailList[self.selectedCell]
					local mailType = self.mailList[self.selectedCell]:getMailType()
					GlobalEventSystem:Fire(GameEvent.EventMailRead,mailType)
					self.MailTable:reloadData()
				else
					self.MailTable:updateCellAtIndex(self.selectedCell-1)				
				end
			else
				self.MailTable:updateCellAtIndex(self.selectedCell-1)
			end--]]
			--self:showMailContentUI(mailObj)						
		end
	end				
	self.MailTable = createTableView(dataHandler, tableSize)
	self.MailTable:setTableViewHandler(tableDelegate)
	node : addChild(self.MailTable)	
	self.MailTable:reloadData()
	self.MailTable:scroll2Cell(self.selectedCell-1, false)
end

function MailTableView:openMail(list)
	if list then
		self.mailList = list
	end		
	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	if self.mailList then
		local mailObj = self.mailList[self.selectedCell]
		if mailObj then	
			if mailObj:getMailState() == 0 then		--未读
				if mailObj:isHaveReward() == 0 then				
					mailMgr:requestMailRead(mailObj:getMailId())
					mailObj:setMailState(1) 	--将邮件状态设置为已读
					local mailType = mailObj:getMailType()
					GlobalEventSystem:Fire(GameEvent.EventMailRead,mailType)
					self.MailTable:reloadData()
				else
					self.MailTable:updateCellAtIndex(self.selectedCell-1)				
				end
			else
				self.MailTable:updateCellAtIndex(self.selectedCell-1)
			end
			self:showMailContentUI(mailObj)	
		end
	end
end

function MailTableView:createMailItem(index,list)
	local item = CCNode:create()
	item:setContentSize(self.cellSize)
	--邮件列表背景
	
	local bottomLine = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"),CCSizeMake(839,2))			
	item : addChild(bottomLine)
	VisibleRect:relativePosition(bottomLine,item,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE)	

	--邮件类型
	local mailType = list[index+1]:getMailType()	
	local mailTypeText

	if mailType == MailType.Activity then
		mailTypeText = Config.Words[8001]
	elseif mailType == MailType.Notice then
		mailTypeText = Config.Words[8002]	
	elseif mailType == MailType.GM2Client then 
		mailTypeText = Config.Words[8013]	
	elseif mailType == MailType.Client2GM then 
		mailTypeText = Config.Words[8013]	
	elseif mailType == MailType.AuctionNormal then 
		mailTypeText = Config.Words[8014]
	elseif mailType == MailType.AuctionCancel then 
		mailTypeText = Config.Words[8014]
	elseif mailType == MailType.AuctionDelay then 
		mailTypeText = Config.Words[8014]
	elseif mailType == MailType.AuctionTimeout then 			
		mailTypeText = Config.Words[8014]	
	else
		CCLuaLog("MailTableView:createMailItem: Fuck! Unknown mail type!")
		return 
	end
	
	self.typeLb[index+1] = createLabelWithStringFontSizeColorAndDimension(mailTypeText, "Arial", FSIZE("Size4")*g_scale, FCOLOR("ColorWhite2"))
	item : addChild(self.typeLb[index+1])
	VisibleRect:relativePosition(self.typeLb[index+1],item,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(50,0))
							
	--邮件标题内容							
	local mailContent = list[index+1]:getTitleContent()
	self.contentLb[index+1] = createLabelWithStringFontSizeColorAndDimension(mailContent, "Arial", FSIZE("Size4")*g_scale, FCOLOR("ColorWhite2"))
	item : addChild(self.contentLb[index+1])
	VisibleRect:relativePosition(self.contentLb[index+1],self.typeLb[index+1],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(70,0))
	if list[index+1]:getMailType() == 0 then
		self.typeLb[index+1]:setColor(FCOLOR("ColorYellow1"))
		self.contentLb[index+1]:setColor(FCOLOR("ColorYellow1"))
	elseif list[index+1]:getMailType() == 1 then
		self.typeLb[index+1]:setColor(FCOLOR("ColorRed1"))
		self.contentLb[index+1]:setColor(FCOLOR("ColorRed1"))
	elseif list[index+1]:getMailType() == 2 then 	
		self.typeLb[index+1]:setColor(FCOLOR("ColorRed1"))
		self.contentLb[index+1]:setColor(FCOLOR("ColorRed1"))
	end
						
	if list[index+1]:getMailState() == 0 then
		--未读			
		local openBtn = createButtonWithFramename(RES("btn_1_normal.png"), RES("btn_1_select.png"))	
		item : addChild(openBtn)
		VisibleRect:relativePosition(openBtn,item,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER,ccp(-60,0))			
		local openBtnFunc = function()
			self.selectedCell = index + 1
			local mailObj = list[index+1]
			local mailId = mailObj:getMailId()
			local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
			if mailObj:getMailContent() then
				self:openMail()
			else
				mailMgr:requestMailContent(mailId)
				UIManager.Instance:showLoadingHUD(20)
			end									
		end
		openBtn:addTargetWithActionForControlEvents(openBtnFunc,CCControlEventTouchDown)				
		--按钮文字		
		self.btnLb[index+1] = createSpriteWithFrameName(RES("word_button_open.png"))
		openBtn:addChild(self.btnLb[index+1])
		VisibleRect:relativePosition(self.btnLb[index+1],openBtn,LAYOUT_CENTER)
		
		if  list[index+1]:isHaveReward() == 1 then
			--有道具				
			self.rewardFlag = createScale9SpriteWithFrameName(RES("mail_property.png"))
			item:addChild(self.rewardFlag)
			VisibleRect:relativePosition(self.rewardFlag,openBtn,LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE,ccp(-15,0))			
		end
	else			
		--已读标志
		local readFlag = createLabelWithStringFontSizeColorAndDimension(Config.Words[8004],"Arial",FSIZE("Size4")*g_scale,FCOLOR("ColorWhite2"))
		item:addChild(readFlag)
		VisibleRect:relativePosition(readFlag,item,LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER_Y,ccp(-115,0))		
	end

	return item
end

function MailTableView:setTablePosition(node,layoutP)
	VisibleRect:relativePosition(self.MailTable,node,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,layoutP)
end	

function MailTableView:showMailContentUI(mailObj)
	if mailObj then
		UIManager.Instance:setDeleteOnExit("MailView",false)
		self.uiManager:showUI("MailContentView",nil,mailObj)
		UIManager.Instance:hideLoadingHUD()
	end		
end

function MailTableView:updateMailTable(list)
	self.mailList = list
	self.MailTable:reloadData()
	self.MailTable:scroll2Cell(0, false)  --回滚到第一个cell
end

function MailTableView:setSelectedCell(index)
	self.selectedCell = index
	self.MailTable:scroll2Cell(self.selectedCell-1 , false)  --滚动到当前icon	
	self.MailTable:updateCellAtIndex(index-1)
end
