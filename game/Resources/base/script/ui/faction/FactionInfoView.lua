--公会信息界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.faction.FactionInfoTableView")

FactionInfoView = FactionInfoView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local E_Update = {
	add = 1,
	remove = 2,
	upgrade = 3,
}
local labelWords = 
{	
	[1] = Config.Words[5514] ,
	[2] = Config.Words[5515] ,
	[3] = Config.Words[5516] ,
	[4] = Config.Words[5517] ,
	[5] = Config.Words[5518] ,
	[6] = Config.Words[5575] ,
}
local E_changeType = {
	office = 1,
	member = 2,
}

function FactionInfoView:__init()
	self.viewName = "FactionInfoView"
	self:init(CCSizeMake(884,558))
	local titleImage = createSpriteWithFrameName(RES("main_faction.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_sociaty.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)	
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.factionInfo = factionMgr:getFactionInfo()		
	self.topLabel = {}
	self.tableSize = CCSizeMake(540*g_scale,343*g_scale)
	self:initBg()
	self:initTopLabel()
	self:initLeftLabel()
	self:initTableView()
	self:initBtn()
	self:initBtnEvent()
	
end

function FactionInfoView:onExit()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	factionMgr:setInfoViewFlag(nil)
end

function FactionInfoView:__delete()
	self.topLabel = {}
	self.tableView : DeleteMe()
end

function FactionInfoView:onEnter()
	if self.tableView then
		self.tableView:onEnter()
	end
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self:refreshLeftLabel()		--刷新左边标签
	self.chairmanFlag = factionMgr:isChairMan()	--是否会长标志	
	local btnVisibleFlag = false
	if self.chairmanFlag == true then		--会长
		btnVisibleFlag = true
	end
	if self.applyListBtn and self.inputBtn then		--按钮可见
		self.applyListBtn:setVisible(btnVisibleFlag)
		self.inputBtn:setVisible(btnVisibleFlag)
	end
end	

function FactionInfoView:create()
	return FactionInfoView.New()
end

function FactionInfoView:initBg()
	self.leftBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(258*g_scale,418*g_scale))
	self.rightBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(575*g_scale,418*g_scale))
	self : addChild(self.leftBg)
	self : addChild(self.rightBg)
	VisibleRect:relativePosition(self.leftBg,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.rightBg,self:getContentNode(),LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
end

function FactionInfoView:initTopLabel()
	self.topBg = createScale9SpriteWithFrameName(RES("rank_title_bg.png"))
	self.topBg : setContentSize(CCSizeMake(567*g_scale,37*g_scale))
	self : addChild(self.topBg)
	VisibleRect:relativePosition(self.topBg,self.rightBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(4,-4))
	local labelCount = table.size(labelWords)
	for i = 1,labelCount do
		self.topLabel[i] = createLabelWithStringFontSizeColorAndDimension(labelWords[i], "Arial",FSIZE("Size4"),FCOLOR("ColorYellow2"))		
		self.topBg : addChild(self.topLabel[i])
		if(self.topLabel[i-1] == nil) then
			VisibleRect:relativePosition(self.topLabel[i],self.topBg,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(25,0))
		else
			VisibleRect:relativePosition(self.topLabel[i],self.topLabel[i-1],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(40,0))
		end
		if i~= labelCount then
			local line = createScale9SpriteWithFrameNameAndSize(RES("verticalDivideLine.png"),CCSizeMake(2,20))
			self.topBg : addChild(line)	
			VisibleRect:relativePosition(line,self.topLabel[i],LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(25,0))
		end		
	end
	
end

function FactionInfoView:initLeftLabel()
	self.nameLbTitle = createSpriteWithFrameName(RES("word_label_factionName.png"))
	self.chairmanLbTitle = createSpriteWithFrameName(RES("word_label_chairman.png"))
	self.numLbTitle = createSpriteWithFrameName(RES("word_label_factionNum.png"))
	local name = " "
	local chairman = " "
	local num = "0"
	local chairmanVipType = 0
	if self.factionInfo then
		name = self.factionInfo.factionName
		chairman = self.factionInfo.chairManName
		num  = self.factionInfo.memNum
		chairmanVipType = self.factionInfo.chairManVipType
	else
		
	end
	self.nameLb = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow1"))
	self.chairmanLb = createLabelWithStringFontSizeColorAndDimension(chairman, "Arial", FSIZE("Size3"), FCOLOR("ColorBlue1"))
	self.numLb = createLabelWithStringFontSizeColorAndDimension(num, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
	self.announcementLb = createSpriteWithFrameName(RES("word_label_announce.png"))
	self : addChild(self.nameLbTitle)
	self : addChild(self.chairmanLbTitle)
	self : addChild(self.numLbTitle)
	self : addChild(self.nameLb)
	self : addChild(self.chairmanLb)
	self : addChild(self.numLb)
	self : addChild(self.announcementLb)
	VisibleRect:relativePosition(self.nameLbTitle,self.leftBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(10,-10))
	VisibleRect:relativePosition(self.chairmanLbTitle,self.nameLbTitle,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.numLbTitle,self.chairmanLbTitle,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.nameLb,self.nameLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	--VisibleRect:relativePosition(self.chairmanLb,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	VisibleRect:relativePosition(self.numLb,self.numLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	if chairmanVipType and chairmanVipType > 0 then
		self.vipIcon = createSpriteWithFrameName(RES("common_vip"..chairmanVipType..".png"))
		self : addChild(self.vipIcon)
		VisibleRect:relativePosition(self.vipIcon,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		VisibleRect:relativePosition(self.chairmanLb,self.vipIcon,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))
	else
		VisibleRect:relativePosition(self.chairmanLb,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	end
	
	VisibleRect:relativePosition(self.announcementLb,self.numLbTitle,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))	
	
	--公告板
	self.announcementBoard = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"),CCSizeMake(229*g_scale,265*g_scale))	
	local anBoardBg = CCSprite:create("ui/ui_img/common/common_BgFrameimage.pvr")
	anBoardBg : setScale(0.75)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local text = factionMgr:getAnnouncementBoard()
	if not text then
		text = " "
	end
	self.announcementWord = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"),CCSizeMake(180*g_scale,0))
	self.announcementBoard : addChild(self.announcementWord)
	VisibleRect:relativePosition(self.announcementWord,self.announcementBoard,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(25,-10))
	self : addChild(anBoardBg)	
	self : addChild(self.announcementBoard)
	VisibleRect:relativePosition(self.announcementBoard,self.leftBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(15,12))	
	VisibleRect:relativePosition(anBoardBg,self.announcementBoard,LAYOUT_CENTER)
	--编辑公告按钮
	self.inputBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local inputBtnLb = createSpriteWithFrameName(RES("word_button_notice.png"))
	self.inputBtn:setTitleString(inputBtnLb)
	self : addChild(self.inputBtn)
	VisibleRect:relativePosition(self.inputBtn,self.leftBg,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-10))
	if self.chairmanFlag == true then
		self.inputBtn : setVisible(true)
	else
		self.inputBtn : setVisible(false)
	end
	local setTextFun = function(label,text,id)
		if id == 2 then   --确定	
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
			if text ~= ""	then
				local length = string.len(text)
				if length > 90 then
					UIManager.Instance:showSystemTips(Config.Words[5570])
				else
					label:setString(text)	
					label:setDimensions(CCSizeMake(180*g_scale,0))
					VisibleRect:relativePosition(self.announcementWord,self.announcementBoard,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(25,-10))	
					factionMgr:setAnnouncementBoard(text)
				end		
				
			else
				text = " "
				label:setString(text)	
				label:setDimensions(CCSizeMake(180*g_scale,0))
				VisibleRect:relativePosition(self.announcementWord,self.announcementBoard,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(25,-10))	
				factionMgr:setAnnouncementBoard(text)
			end
			local factionName = factionMgr:getFactionInfo().factionName				
			if factionName then
				factionMgr:requestEditNotice(factionName,text)			--请求编辑公告
			end
		end
	end
	local createFunction = function()
		local manager =UIManager.Instance
		local text = factionMgr:getAnnouncementBoard()
		if text then
			self.editWord = text
		else 
			self.editWord = " "
		end
		manager:showMsgBoxWithEdit(Config.Words[5523],self.announcementWord,setTextFun,nil,self.editWord,20)	
	end
	self.inputBtn:addTargetWithActionForControlEvents(createFunction,CCControlEventTouchDown)
	
end

function FactionInfoView:initBtn()
	self.applyListBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.factionListBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.exitFactionListBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local applyListBtnLb = createSpriteWithFrameName(RES("word_button_applyList.png"))
	local factionListBtnLb = createSpriteWithFrameName(RES("word_button_factionList.png"))
	local exitFactionListBtnLb = createSpriteWithFrameName(RES("word_button_exitFaction.png"))
	self : addChild(self.applyListBtn)
	self : addChild(self.factionListBtn)
	self : addChild(self.exitFactionListBtn)
	self.applyListBtn : setTitleString(applyListBtnLb)
	self.factionListBtn : setTitleString(factionListBtnLb)
	self.exitFactionListBtn : setTitleString(exitFactionListBtnLb)
	VisibleRect:relativePosition(self.applyListBtn,self.rightBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(20,-10))
	VisibleRect:relativePosition(self.factionListBtn,self.applyListBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(40,0))
	VisibleRect:relativePosition(self.exitFactionListBtn,self.factionListBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(40,0))	
	if self.chairmanFlag == true then
		self.applyListBtn : setVisible(true)
	else
		self.applyListBtn : setVisible(false)
	end
end

function FactionInfoView:initBtnEvent()
	--公会列表按钮功能
	local openListViewFunction = function()
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()					
		factionMgr:requestFactionList("1","1")
		factionMgr:setFactionFlag(true)
		factionMgr:setInfoViewFlag(nil)
	end
	self.factionListBtn:addTargetWithActionForControlEvents(openListViewFunction,CCControlEventTouchDown)
	--申请列表按钮功能
	local openApplyViewFunction = function()
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()							
		local factionName = factionMgr:getFactionInfo().factionName
		if factionName then
			factionMgr:requestApplyPlayerList(factionName)
			factionMgr:setInfoViewFlag(nil)
		end
	end
	self.applyListBtn:addTargetWithActionForControlEvents(openApplyViewFunction,CCControlEventTouchDown)
	--离开公会按钮功能
	local exitFaction = function(arg,text,id)
		if id == 2 then
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
			local factionName = factionMgr:getFactionInfo().factionName			
			if factionName then
				factionMgr:requestExitFaction(factionName)		--请求离开公会
				self:close()
				factionMgr:setInfoViewFlag(nil)
			end	
		end
	end
	local exitFactionFunction = function()
		local msg = showMsgBox(Config.Words[5552],E_MSG_BT_ID.ID_CANCELAndOK)			
		msg:setNotify(exitFaction)
	end
	
	self.exitFactionListBtn:addTargetWithActionForControlEvents(exitFactionFunction,CCControlEventTouchDown)
end

function FactionInfoView:initTableView()
	self.tableView = FactionInfoTableView.New()
	self.tableView : initTableView(self:getContentNode(),self.tableSize)
	local layoutP = ccp(10,0)
	self.tableView:setTablePosition(self.topBg,layoutP)
end

function FactionInfoView:refreshLeftLabel()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	if self.factionInfo then
		self.factionInfo = {}
	end
	self.factionInfo = factionMgr:getFactionInfo()
	if self.factionInfo then
		local factionName = self.factionInfo.factionName
		local chairManName = self.factionInfo.chairManName
		local memNum = self.factionInfo.memNum
		local vipType = self.factionInfo.chairManVipType
		if factionName then
			self.nameLb : setString(factionName)
			VisibleRect:relativePosition(self.nameLb,self.nameLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
		end
		if chairManName then
			self.chairmanLb : setString(chairManName)
			if vipType and vipType >0 then
				if self.vipIcon then
					VisibleRect:relativePosition(self.vipIcon,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
					VisibleRect:relativePosition(self.chairmanLb,self.vipIcon,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))
				else
					self.vipIcon = createSpriteWithFrameName(RES("common_vip"..vipType..".png"))
					self : addChild(self.vipIcon)
					VisibleRect:relativePosition(self.vipIcon,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
					VisibleRect:relativePosition(self.chairmanLb,self.vipIcon,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(3,0))
				end
			else
				if self.vipIcon then
					self.vipIcon:removeFromParentAndCleanup(true)
					self.vipIcon= nil
				end
			end
		end
		if memNum then
			self.numLb : setString(memNum)
		end
		local text = factionMgr:getAnnouncementBoard()
		if not text then
			text = " "
		end
		self.announcementWord:setString(text)
	end
end

function FactionInfoView:refreshInfoTableView(rType)
	if self.tableView then
		if rType == E_changeType.office then		--职位改变
			local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()			
			self.chairmanFlag = factionMgr:isChairMan()	
			if self.chairmanFlag == false then
				self.applyListBtn:setVisible(false)
				self.inputBtn:setVisible(false)
			elseif self.chairmanFlag == true then
				self.applyListBtn:setVisible(true)
				self.inputBtn:setVisible(true)
			end				
			self.tableView:refreshOffice()			
		elseif rType == E_changeType.member then	--成员列表发生变化	
			self:refreshMemberList()
		end		
	end
	self:refreshLeftLabel()
end

function FactionInfoView:refreshMemberList()
	if self.tableView then
		self.tableView.factionInfoTable:reloadData()
		self.tableView.factionInfoTable:scroll2Cell(0,false)
	end
end

function FactionInfoView:officeUpdate()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()		
	factionMgr:requestFactionList("2",self.tableView.page)	
	UIManager.Instance:showLoadingHUD(5,self:getContentNode())	
	self:refreshInfoTableView(1)
end

function FactionInfoView:memberUpdate(updateType)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()		
	if updateType == E_Update.add then
		if self.tableView then
			if self.tableView.page == self.tableView.totalPart then
				factionMgr:requestFactionList("2",self.tableView.page)	
				UIManager.Instance:showLoadingHUD(5,self:getContentNode())	
			end
		end
	elseif updateType == E_Update.remove then
		local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
		factionMgr:requestFactionList("2",self.tableView.page)	
		UIManager.Instance:showLoadingHUD(5,self:getContentNode())	
	end		
end