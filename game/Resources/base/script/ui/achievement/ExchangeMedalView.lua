require("ui.UIManager")
require("object.mall.MallDef")
require("common.BaseUI")
require("ui.Npc.NpcBaseView")
require("config.words")
require("data.achievement.medal")
ExchangeMedalView = ExchangeMedalView or BaseClass(NpcBaseView)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function ExchangeMedalView:__init()
	self.viewName = "ExchangeMedalView"
	self.viewSize = self:getContentNode():getContentSize()
	self.curIndex = 1
	self.iconBgList = {}
	self.lableBgList = {}
	self.needAchiNum = {}
	self.needAchieve = {}	
	self.ableBtnList = {} 	 --可兑换
	self.disableBtnList = {} --不可兑换
	self.passBtnList = {}
	self.passFlagList = {}
	self.iconBg = {}
	for i=1,10 do
		self.passFlagList[i] = false
	end
	self:initHalfScreen()
	self:initStaticView()
	self:initNode1()
	self:initNode2()
	self:initNode3()
	self:initScrollView()	
	self:initBtnEvent()
	self.btnFlag = "0"	
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	
end

function ExchangeMedalView:__delete()
	self.iconBgList = {}
	self.lableBgList = {}
	self.needAchiNum = {}
	self.needAchieve = {}
	self.ableBtnList = {}
	self.disableBtnList = {}
	self.passBtnList = {}
	self.passFlagList = {}
end

function ExchangeMedalView:create()
	return ExchangeMedalView.New()
end	

function ExchangeMedalView:onEnter(npcRefId)
	self:initheadNode(npcRefId)
	self:checkMedal()
	self:setAchiLbColorAndBtn()				
end
function ExchangeMedalView:onExit()
	if self.curSprite then
		self.curSprite : stopAllActions()
		self.curSprite : setVisible(false)	
		self.curSprite:release()
		self.curUpGradeAnimate:release()
		self.curUpGradeAnimate = nil
		self.curCallbackAction = nil
		self.curSprite = nil
		self.curSpawnArray = nil	
	end	
end
function ExchangeMedalView:checkMedal()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local i = achievementMgr:checkMedal()
	if(i ~= nil) then
		for j=1,i do
			self.ableBtnList[j].btn : setVisible(false)			
			self.disableBtnList[j] : setVisible(false)
			self.ableBtnList[j].btn : setEnable(false)	
			self.disableBtnList[j] : setEnable(false)
			self.passBtnList[j] : setVisible(true)			
			self.passFlagList[j] = true
			--self.needAchiNum[j]:setColor(FCOLOR("ColorGreen1"))
		end
		self.curIndex = i
		if(self.ableBtnList[i+1]) then
			self.ableBtnList[i+1].btn:setEnable(true)
		end
		--[[for j=i+2,10 do 
			self.ableBtnList[j].btn:setEnable(false) 
		end--]]
	--[[else
		for i = 2,10 do
			self.ableBtnList[i].btn:setEnable(false) 
		end--]]
	end
 end

function ExchangeMedalView:initheadNode(npcRefId)
	self:setNpcAvatar(npcRefId)
	self:setNpcName(npcRefId)
end

function ExchangeMedalView:initStaticView()
	local viewSize = self:getContentNode():getContentSize()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),viewSize)
	self: addChild(self.bg)
	VisibleRect:relativePosition(self.bg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,0))
	
	self:createViewBg()
		
	--npc描述
	local npcTalk = Config.Words[6518]
	npcTalk = "    " .. npcTalk
	self:setNpcText(npcTalk)
	--[[self : addChild(npcTalk)
	VisibleRect:relativePosition(npcTalk,self.bg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(60,-25))	--]]
	--分割线
	--[[self.line = createScale9SpriteWithFrameName(RES("npc_dividLine.png"))
	self : addChild(self.line)
	VisibleRect:relativePosition(self.line,self.bg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,-80))--]]
	
	self.nextPageBtn = createButtonWithFramename(RES("main_questcontraction.png"))
	self.nextPageBtn : setRotation(180)
	self : addChild(self.nextPageBtn)
	VisibleRect:relativePosition(self.nextPageBtn,self.bg,LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-10,5))
	self.fontPageBtn = createButtonWithFramename(RES("main_questcontraction.png"))
	self : addChild(self.fontPageBtn)
	VisibleRect:relativePosition(self.fontPageBtn,self.bg,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,5))
	self.fontPageBtn : setVisible(false)
	--下一页按钮
	local nextPageFunc = function()
			self.pageIndex = self.pageIndex + 1
			if(self.pageIndex < 1) then		
				self:setPage(self.pageIndex)	
			elseif(self.pageIndex == 1) then
				self:setPage(self.pageIndex)
				self.btnFlag = "1"
			elseif(self.pageIndex == 2) then
				self:setPage(self.pageIndex)
				self.btnFlag = "2"
			end
			if(self.btnFlag == "1") then
				self.nextPageBtn : setVisible(true)
				self.fontPageBtn : setVisible(true)
			elseif(self.btnFlag == "2") then
				self.nextPageBtn : setVisible(false)
				self.fontPageBtn : setVisible(true)
			end
	end
	self.nextPageBtn:addTargetWithActionForControlEvents(nextPageFunc,CCControlEventTouchDown)
	--上一页按钮
	local fontPageFunc = function()
			self.pageIndex = self.pageIndex - 1
			if(self.pageIndex > 1) then		
				self:setPage(self.pageIndex)
			elseif(self.pageIndex == 1) then
				self:setPage(self.pageIndex)
				self.btnFlag = "1"	
			elseif(self.pageIndex == 0) then
				self:setPage(self.pageIndex)
				self.btnFlag = "0"
			end
			if(self.btnFlag == "0") then
				self.fontPageBtn : setVisible(false)
				self.nextPageBtn : setVisible(true)
			elseif(self.btnFlag == "1") then
				self.fontPageBtn : setVisible(true)
				self.nextPageBtn : setVisible(true)
			end
	end
	self.fontPageBtn:addTargetWithActionForControlEvents(fontPageFunc,CCControlEventTouchDown)
		
end

function ExchangeMedalView:setPage(index)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(-self.viewSize.width * index, 0), false)
	
end

function ExchangeMedalView:createScrollView()
	local scrollSize = CCSizeMake(368*g_scale,386*g_scale)
	local scrollView = createScrollViewWithSize(scrollSize)
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setPageEnable(true)
	return scrollView
end
function ExchangeMedalView:initNode1()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	self.node1 = CCNode:create()
	self.node1 : setContentSize(self.viewSize)
	local name, nameLb, needAchieveLb, iconRefId, medalIcon	,nameBg
	local ableBtnLb, disbleBtnLb, passBtnLb
	--node1 节点内容
	for i=1 ,4 do
		self.iconBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"),CCSizeMake(207*g_scale,82*g_scale))
		--self.lableBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(170*g_scale,90*g_scale))
		nameBg = createScale9SpriteWithFrameName(RES("common_blueBar.png"))
		nameBg:setContentSize(CCSizeMake(368,32))
		nameBg:setScaleX(207/368)
		self.iconBgList[i] : addChild(nameBg)
		VisibleRect:relativePosition(nameBg,self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-5))
		--勋章图标
		iconRefId = achievementMgr:getMedalInfo(i,"refId")
		self.iconBg[i] = createScale9SpriteWithFrameName(RES("bagBatch_itemBg.png"))		
		medalIcon = G_createItemBoxByRefId(iconRefId,nil,nil,-1)
		self.iconBgList[i] : addChild(self.iconBg[i])
		self.iconBgList[i] : addChild(medalIcon)
		VisibleRect:relativePosition(self.iconBg[i],self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(7,-11))
		VisibleRect:relativePosition(medalIcon,self.iconBg[i],LAYOUT_CENTER)
		--勋章名字
		name = achievementMgr:getMedalInfo(i,"name")
		local nameLb = createLabelWithStringFontSizeColorAndDimension(name,"Arial",FSIZE("Size1"),FCOLOR("ColorWhite1"))
		
		--需求成就点数
		self.needAchieve[i] = achievementMgr:getMedalInfo(i,"needAchieve")
		needAchieveLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6519],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"))
		self.needAchiNum[i] = createLabelWithStringFontSizeColorAndDimension(self.needAchieve[i],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1")) 
		self.iconBgList[i] : addChild(nameLb)
		self.iconBgList[i] : addChild(needAchieveLb)
		self.iconBgList[i] : addChild(self.needAchiNum[i])		
		VisibleRect:relativePosition(nameLb,medalIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE,ccp(10,-0))
		VisibleRect:relativePosition(needAchieveLb,nameLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
		VisibleRect:relativePosition(self.needAchiNum[i],needAchieveLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
		
		--按钮
		local btnInfo = {}
		btnInfo.btn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
		btnInfo.refId = iconRefId
		self.ableBtnList[i] = btnInfo
		self.disableBtnList[i] = createButtonWithFramename(RES("btn_1_select.png"))
		self.passBtnList [i] = createSpriteWithFrameName(RES("btn_1_select.png"))
		UIControl:SpriteSetGray(self.disableBtnList[i])
		UIControl:SpriteSetGray(self.passBtnList[i])
		if(i==1) then
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6514],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6521],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		else
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6522],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6523],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		end
		self.node1 : addChild(self.iconBgList[i])
		--self.node1 : addChild(self.lableBgList[i])
		self.node1 : addChild(self.ableBtnList[i].btn)
		self.node1 : addChild(self.disableBtnList[i])
		self.node1 : addChild(self.passBtnList[i])
		if(i == 1) then
			VisibleRect:relativePosition(self.iconBgList[i],self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(14,-130))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		else
			VisibleRect:relativePosition(self.iconBgList[i],self.iconBgList[i-1],LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		end
	end
end

function ExchangeMedalView:initNode2()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	self.node2 = CCNode:create()
	self.node2 : setContentSize(self.viewSize)
	local name, nameLb, needAchieveLb, iconRefId, medalIcon	
	local ableBtnLb, disbleBtnLb, passBtnLb
	--node2 节点内容
	for i=5 ,8 do
		self.iconBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"),CCSizeMake(207*g_scale,82*g_scale))
		--self.lableBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(170*g_scale,90*g_scale))
		nameBg = createScale9SpriteWithFrameName(RES("common_blueBar.png"))
		nameBg:setContentSize(CCSizeMake(368,32))
		nameBg:setScaleX(207/368)
		self.iconBgList[i] : addChild(nameBg)
		VisibleRect:relativePosition(nameBg,self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-5))
		--勋章图标
		iconRefId = achievementMgr:getMedalInfo(i,"refId")
		self.iconBg[i] = createScale9SpriteWithFrameName(RES("bagBatch_itemBg.png"))		
		medalIcon = G_createItemBoxByRefId(iconRefId,nil,nil,-1)
		self.iconBgList[i] : addChild(self.iconBg[i])
		self.iconBgList[i] : addChild(medalIcon)
		VisibleRect:relativePosition(self.iconBg[i],self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(7,-11))
		VisibleRect:relativePosition(medalIcon,self.iconBg[i],LAYOUT_CENTER)
		--勋章名字
		name = achievementMgr:getMedalInfo(i,"name")
		local nameLb = createLabelWithStringFontSizeColorAndDimension(name,"Arial",FSIZE("Size1"),FCOLOR("ColorWhite1"))
		
		--需求成就点数
		self.needAchieve[i] = achievementMgr:getMedalInfo(i,"needAchieve")
		needAchieveLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6519],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"))
		self.needAchiNum[i] = createLabelWithStringFontSizeColorAndDimension(self.needAchieve[i],"Arial",FSIZE("Size1"),FCOLOR("ColorWhite1")) 
		self.iconBgList[i] : addChild(nameLb)
		self.iconBgList[i] : addChild(needAchieveLb)
		self.iconBgList[i] : addChild(self.needAchiNum[i])		
		VisibleRect:relativePosition(nameLb,medalIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE,ccp(10,-0))
		VisibleRect:relativePosition(needAchieveLb,nameLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
		VisibleRect:relativePosition(self.needAchiNum[i],needAchieveLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
		
		--按钮
		local btnInfo = {}
		btnInfo.btn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
		btnInfo.refId = iconRefId
		self.ableBtnList[i] = btnInfo
		self.disableBtnList[i] = createButtonWithFramename(RES("btn_1_select.png"))
		self.passBtnList [i] = createSpriteWithFrameName(RES("btn_1_select.png"))
		UIControl:SpriteSetGray(self.disableBtnList[i])
		UIControl:SpriteSetGray(self.passBtnList[i])
		if(i==5) then
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6522],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6523],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		else
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6522],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6523],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		end
		self.node2 : addChild(self.iconBgList[i])
		--self.node1 : addChild(self.lableBgList[i])
		self.node2 : addChild(self.ableBtnList[i].btn)
		self.node2 : addChild(self.disableBtnList[i])
		self.node2 : addChild(self.passBtnList[i])
		if(i == 5) then
			VisibleRect:relativePosition(self.iconBgList[i],self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(14,-130))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		else
			VisibleRect:relativePosition(self.iconBgList[i],self.iconBgList[i-1],LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		end
	end
end

function ExchangeMedalView:initNode3()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	self.node3 = CCNode:create()
	self.node3 : setContentSize(self.viewSize)
	local name, nameLb, needAchieveLb, iconRefId, medalIcon	
	local ableBtnLb, disbleBtnLb, passBtnLb
	--node3 节点内容
	for i=9 ,10 do
		self.iconBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"),CCSizeMake(207*g_scale,82*g_scale))
		--self.lableBgList[i] = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(170*g_scale,90*g_scale))
		nameBg = createScale9SpriteWithFrameName(RES("common_blueBar.png"))
		nameBg:setContentSize(CCSizeMake(368,32))
		nameBg:setScaleX(207/368)
		self.iconBgList[i] : addChild(nameBg)
		VisibleRect:relativePosition(nameBg,self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-5))
		--勋章图标
		iconRefId = achievementMgr:getMedalInfo(i,"refId")
		self.iconBg[i] = createScale9SpriteWithFrameName(RES("bagBatch_itemBg.png"))		
		medalIcon = G_createItemBoxByRefId(iconRefId,nil,nil,-1)
		self.iconBgList[i] : addChild(self.iconBg[i])
		self.iconBgList[i] : addChild(medalIcon)
		VisibleRect:relativePosition(self.iconBg[i],self.iconBgList[i],LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(7,-11))
		VisibleRect:relativePosition(medalIcon,self.iconBg[i],LAYOUT_CENTER)
		--勋章名字
		name = achievementMgr:getMedalInfo(i,"name")
		local nameLb = createLabelWithStringFontSizeColorAndDimension(name,"Arial",FSIZE("Size1"),FCOLOR("ColorWhite1"))
		
		--需求成就点数
		self.needAchieve[i] = achievementMgr:getMedalInfo(i,"needAchieve")
		needAchieveLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6519],"Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"))
		self.needAchiNum[i] = createLabelWithStringFontSizeColorAndDimension(self.needAchieve[i],"Arial",FSIZE("Size1"),FCOLOR("ColorWhite1")) 
		self.iconBgList[i] : addChild(nameLb)
		self.iconBgList[i] : addChild(needAchieveLb)
		self.iconBgList[i] : addChild(self.needAchiNum[i])		
		VisibleRect:relativePosition(nameLb,medalIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_TOP_INSIDE,ccp(10,-0))
		VisibleRect:relativePosition(needAchieveLb,nameLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
		VisibleRect:relativePosition(self.needAchiNum[i],needAchieveLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-3))
		
		--按钮
		local btnInfo = {}
		btnInfo.btn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
		btnInfo.refId = iconRefId
		self.ableBtnList[i] = btnInfo
		self.disableBtnList[i] = createButtonWithFramename(RES("btn_1_select.png"))
		self.passBtnList [i] = createSpriteWithFrameName(RES("btn_1_select.png"))
		UIControl:SpriteSetGray(self.disableBtnList[i])
		UIControl:SpriteSetGray(self.passBtnList[i])
		if(i==9) then
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6522],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6523],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		else
			ableBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6522],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.ableBtnList[i].btn:setTitleString(ableBtnLb)	
			disbleBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6524],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.disableBtnList[i] : setTitleString(disbleBtnLb)	
			passBtnLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[6523],"Arial",FSIZE("Size1"),FCOLOR("ColorBrown2"))
			self.passBtnList[i] : addChild(passBtnLb)
			VisibleRect:relativePosition(passBtnLb,self.passBtnList[i],LAYOUT_CENTER)
			self.ableBtnList[i].btn : setVisible(false)
			self.passBtnList[i] : setVisible(false)
		end
		self.node3 : addChild(self.iconBgList[i])
		--self.node1 : addChild(self.lableBgList[i])
		self.node3 : addChild(self.ableBtnList[i].btn)
		self.node3 : addChild(self.disableBtnList[i])
		self.node3 : addChild(self.passBtnList[i])
		if(i == 9) then
			VisibleRect:relativePosition(self.iconBgList[i],self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(14,-130))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		else
			VisibleRect:relativePosition(self.iconBgList[i],self.iconBgList[i-1],LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
			--VisibleRect:relativePosition(self.lableBgList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
			VisibleRect:relativePosition(self.ableBtnList[i].btn,self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.disableBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
			VisibleRect:relativePosition(self.passBtnList[i],self.iconBgList[i],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		end
	end
end
function ExchangeMedalView:initScrollView()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()			
	self.scrollNode = CCNode:create()
	self.scrollNode : setContentSize(CCSizeMake(self.viewSize.width*3,self.viewSize.height))
	self.scrollNode : addChild(self.node1)
	self.scrollNode : addChild(self.node2)
	self.scrollNode : addChild(self.node3)
	VisibleRect:relativePosition(self.node1,self.scrollNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE)	
	VisibleRect:relativePosition(self.node2,self.scrollNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(self.viewSize.width,0))
	VisibleRect:relativePosition(self.node3,self.scrollNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(self.viewSize.width*2,0))
	self.scrollView = self:createScrollView()
	self.scrollView :setTouchEnabled(false)
	self : addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView,self.bg,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER,ccp(0,35))
	self.scrollView:setContainer(self.scrollNode)
	self.pageIndex = 0
	self:setPage(self.pageIndex)
end

function ExchangeMedalView:initBtnEvent()
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local manager =UIManager.Instance	
	local exchangeMedal = function()
		achievementMgr:requestAchievementExchangeMedal()		
		manager:showLoadingHUD(10,self.rootNode)
	end
	
	self.ableBtnList[1].btn:addTargetWithActionForControlEvents(exchangeMedal,CCControlEventTouchDown)	
	for i=2,10 do	
		self:createBtnEvent(i)
	end
	
	local buyToken = function()		
		local mObj = G_IsCanBuyInShop("item_lingpai_3") 
		if(mObj ~= nil) then 
		GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj)
		end
	end
	for i=1,10 do		
		self.disableBtnList[i]:addTargetWithActionForControlEvents(buyToken,CCControlEventTouchDown)
	end
end

function ExchangeMedalView:createBtnEvent(index)
	local bagMgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	local achievementMgr = GameWorld.Instance:getEntityManager():getHero():getAchievementMgr()	
	local manager =UIManager.Instance	
	
	local updateMedal = function()
		local hasInBag = bagMgr:hasItem(self.ableBtnList[index-1].refId)
		local hasInEquip = equipMgr:hasEquip(self.ableBtnList[index-1].refId)		
		if(hasInBag == true) then
			local itemObj = bagMgr:getItemByRefId(self.ableBtnList[index-1].refId)
			if itemObj then
				local itemId = itemObj:getId()
				achievementMgr:requestAchievementLevlUpMedal(1,self.ableBtnList[index-1].refId,itemId)			
				manager:showLoadingHUD(5,self.rootNode)
			end
		elseif(hasInEquip == true) then
			local equipObj = equipMgr:getEquipByRefId(self.ableBtnList[index-1].refId)
			if equipObj then
				local itemId = equipObj:getId()
				achievementMgr:requestAchievementLevlUpMedal(0,self.ableBtnList[index-1].refId,itemId)			
				manager:showLoadingHUD(5,self.rootNode)
			end
		else
			local medalName = achievementMgr:getMedalInfo(index-1,"name")
			local tips = self:createTipString(medalName)
			manager:showSystemTips(tips)
		end
	end
	self.ableBtnList[index].btn:addTargetWithActionForControlEvents(updateMedal,CCControlEventTouchDown)
end

function ExchangeMedalView:setAchiLbColorAndBtn()	
	self.achievement = PropertyDictionary:get_achievement(self.hero:getPT())	
	for i=1,10 do
		if self.passFlagList[i] == false then
			if (self.needAchieve[i] > self.achievement) then
				self.needAchiNum[i] : setColor(FCOLOR("ColorRed1"))		
				self.ableBtnList[i].btn : setVisible(false)
				self.disableBtnList[i] : setVisible(true)
			else
				self.needAchiNum[i] : setColor(FCOLOR("ColorGreen1"))
				self.ableBtnList[i].btn : setVisible(true)			
				self.disableBtnList[i] : setVisible(false)
			end
		else
			self.needAchiNum[i] : setColor(FCOLOR("ColorGreen1"))
		end
				
	end
		
end

function ExchangeMedalView:refreshBtn(refId)
	local isDone
	local function finishRunRightCallback()
		if self.curSprite then
			self.curSprite : setVisible(false)	
			self.curSprite:release()
			self.curUpGradeAnimate:release()
			self.curUpGradeAnimate = nil
			self.curCallbackAction = nil
			self.curSprite = nil
			self.curSpawnArray = nil	
		end	
	end		
	for i=self.curIndex,10 do
		if self.ableBtnList[i].refId == refId then
			self.ableBtnList[i].btn : setVisible(false)			
			self.disableBtnList[i] : setVisible(false)
			self.passBtnList[i] : setVisible(true)
			self.ableBtnList[i].btn : setEnable(false)
			self.needAchiNum[i]:setColor(FCOLOR("ColorGreen1"))
			self.passFlagList[i] = true
			if(self.ableBtnList[i+1]) then
				self.ableBtnList[i+1].btn:setEnable(true)
			end
			if self.curUpGradeAnimate then
				isDone = self.curUpGradeAnimate:isDone()
				if isDone == false then		
					self.curSprite : setVisible(false)	
					self.curSprite:release()
					self.curUpGradeAnimate:release()
					self.curUpGradeAnimate = nil
					self.curCallbackAction = nil
					self.curSprite = nil
					self.curSpawnArray = nil
				end
			end
			if not self.curUpGradeAnimate then
				self.curUpGradeAnimate = createAnimate("iconFlash",8,0.125)
				self.curUpGradeAnimate:retain()
			end
			if not self.curSprite then
				self.curSprite = CCSprite:create()	
				self.curSprite:retain()
			end
			if self.curUpGradeAnimate and self.curSprite then			
				self.curCallbackAction = CCCallFunc:create(finishRunRightCallback)
				if not self.curSpawnArray then
					self.curSpawnArray = CCArray:create()
				end
				self.curSpawnArray:addObject(self.curUpGradeAnimate)
				self.curSpawnArray:addObject(self.curCallbackAction)
				self.curSprite:runAction(CCSequence:create(self.curSpawnArray))		
				self.iconBg[i]:addChild(self.curSprite)
				VisibleRect:relativePosition(self.curSprite, self.iconBg[i],LAYOUT_CENTER)
			end				
			break
		end
	end
end

function ExchangeMedalView:refreshNum(achieveNum)
	if(achieveNum ~= 0 and achieveNum ~= self.achievement) then
		self.achievement = achieveNum
		for i=self.curIndex+1,10 do
			if (self.needAchieve[i] > self.achievement and self.passFlagList[i] == false) then
				self.needAchiNum[i] : setColor(FCOLOR("ColorRed1"))		
				if self.passFlagList[i] == false then
					self.ableBtnList[i].btn : setVisible(false)	
					self.disableBtnList[i] : setVisible(true)
				end
			else
				self.needAchiNum[i] : setColor(FCOLOR("ColorGreen1"))						
			end
		end
	end
end

function ExchangeMedalView:createTipString(medalName)
	local descStr = Config.Words[6527]
	descStr = descStr..medalName
	descStr = descStr..Config.Words[6528]
	return descStr
end


