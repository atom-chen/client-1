--申请列表界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.faction.FactionListTableView")

FactionListView = FactionListView or BaseClass(BaseUI)
local g_scale = VisibleRect:SFGetScale()

local labelWords = 
{	
	[1] = Config.Words[5514] ,
	[2] = Config.Words[5515] ,
	[3] = Config.Words[5516] ,
	[4] = Config.Words[5541] ,	
}

function FactionListView:__init()
	self.viewName = "FactionListView"
	self:init(CCSizeMake(884,558))
	local titleImage = createSpriteWithFrameName(RES("main_faction.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_sociaty.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)
	self.topLabel = {}
	self.tableSize = CCSizeMake(558*g_scale,369*g_scale)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.factionInfo = factionMgr:getFactionInfo()
	self:initBg()
	self:initTopLabel()	
	self:initLeftLabel()
	self:initTableView()
	self:initBtn()
	self:initBtnEvent()
end

function FactionListView:onEnter()
	if self.tableView then
		self.tableView.factionListTable:reloadData()
	end
	self:refreshLeftLabel()		--刷新左边标签	
	self:updateCheckBox()
end

function FactionListView:__delete()
	self.topLabel = {}
	self.tableView : DeleteMe()
end

function FactionListView:create()
	return FactionListView.New()
end


function FactionListView:initBg()
	self.leftBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(258*g_scale,418*g_scale))
	self.rightBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(575*g_scale,418*g_scale))
	self : addChild(self.leftBg)
	self : addChild(self.rightBg)
	VisibleRect:relativePosition(self.leftBg,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.rightBg,self:getContentNode(),LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
end

function FactionListView:initTopLabel()
	
	self.topBg = createScale9SpriteWithFrameName(RES("rank_title_bg.png"))
	self.topBg : setContentSize(CCSizeMake(557*g_scale,37*g_scale))
	self : addChild(self.topBg)
	VisibleRect:relativePosition(self.topBg,self.rightBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(4,-4))
	local labelCount = table.size(labelWords)
	for i = 1,labelCount do	
		--self.topLabel[i] =  createStyleTextLable(labelWords[i], "FactionApply")
		self.topLabel[i] = createLabelWithStringFontSizeColorAndDimension(labelWords[i], "Arial",FSIZE("Size5"),FCOLOR("ColorYellow2"))		
		self.topBg : addChild(self.topLabel[i])
		if(i == 1) then
			VisibleRect:relativePosition(self.topLabel[i],self.topBg,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(30,0))
		elseif(i == labelCount) then
			VisibleRect:relativePosition(self.topLabel[i],self.topBg,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-85,0))
		else
			VisibleRect:relativePosition(self.topLabel[i],self.topLabel[i-1],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(50,0))
		end
		if i~= 4 then
			local line = createScale9SpriteWithFrameNameAndSize(RES("verticalDivideLine.png"),CCSizeMake(2,20))
			self.topBg : addChild(line)	
			VisibleRect:relativePosition(line,self.topLabel[i],LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(25,0))
		end		
	end		
end
function FactionListView:initLeftLabel()
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
	if text then
		self.announcementWord = createLabelWithStringFontSizeColorAndDimension(text, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"),CCSizeMake(180*g_scale,0))
	else
		self.announcementWord = createLabelWithStringFontSizeColorAndDimension(" ", "Arial",  FSIZE("Size3"), FCOLOR("ColorYellow5"),CCSizeMake(180*g_scale,0))
	end
	self.announcementBoard : addChild(self.announcementWord)
	VisibleRect:relativePosition(self.announcementWord,self.announcementBoard,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(25,-10))
	self : addChild(anBoardBg)
	self : addChild(self.announcementBoard)
	VisibleRect:relativePosition(self.announcementBoard,self.leftBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(15,12))	
	VisibleRect:relativePosition(anBoardBg,self.announcementBoard,LAYOUT_CENTER)	
end

function FactionListView:initBtn()
	self.memberListBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	self.autoAgreeBtn = createScale9SpriteWithFrameName(RES("btn_1_select.png"))
	self.memberListBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local autoAgreeBtnLb =  createSpriteWithFrameName(RES("word_button_autoPass.png"))	
	local memberListBtnLb = createSpriteWithFrameName(RES("word_button_memList.png"))	
	self : addChild(self.autoAgreeBtn)
	self : addChild(self.memberListBtn)	
	self.autoAgreeBtn : addChild(autoAgreeBtnLb)
	self.memberListBtn : setTitleString(memberListBtnLb)
	VisibleRect:relativePosition(autoAgreeBtnLb,self.autoAgreeBtn,LAYOUT_CENTER)	
	VisibleRect:relativePosition(self.memberListBtn,self:getContentNode(),LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-0,0))
	VisibleRect:relativePosition(self.autoAgreeBtn,self.memberListBtn,LAYOUT_CENTER+LAYOUT_LEFT_OUTSIDE,ccp(-80,0))	
	local fun = function (checkBox)
		local isSel = self.checkBox:getSelect()
		if self.factionInfo then
			local factionName = self.factionInfo.factionName
			if isSel == true then
				factionMgr:requestChangeAutoState(factionName,"1")
			elseif isSel == false then
				factionMgr:requestChangeAutoState(factionName,"0")
			end
		end
	end
	self.checkBox = createCheckButton(RES("common_selectBox.png"), RES("common_selectIcon.png"), nil, fun)
	
	self:updateCheckBox()
	self:addChild(self.checkBox)
	VisibleRect:relativePosition(self.checkBox, self.autoAgreeBtn, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y, ccp(0, 0))
end

function FactionListView:initBtnEvent()
	--成员列表按钮功能
	local openInfoViewFunction = function()
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()				
		UIManager.Instance:showLoadingHUD(10,self:getContentNode())
		factionMgr:requestFactionList("2","1")
	end
	self.memberListBtn:addTargetWithActionForControlEvents(openInfoViewFunction,CCControlEventTouchDown)
end

function FactionListView:initTableView()
	self.tableView = FactionListTableView.New()
	self.tableView : initTableView(self:getContentNode(),self.tableSize)
	local layoutP = ccp(10,0)
	self.tableView:setTablePosition(self.topBg,layoutP)
end

function FactionListView:refreshApplyList()
	if self.tableView then
		self.tableView.factionListTable:reloadData()	
	end
end

function FactionListView:refreshLeftLabel()
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
				VisibleRect:relativePosition(self.chairmanLb,self.chairmanLbTitle,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
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

function FactionListView:updateCheckBox()
	local factionMgr = G_getHero():getFactionMgr()
	local autoState = factionMgr:getAutoState()
	if autoState == 1 then
		self.checkBox:setSelect(true)
	else
		self.checkBox:setSelect(false)
	end	
end
