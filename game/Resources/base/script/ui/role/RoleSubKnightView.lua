require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require ("data.knight.knight")

RoleSubKnightView = RoleSubKnightView or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local const_size_no_scale = CCSizeMake(383+10+10+E_OffsetView.eWidth*2, 538+E_OffsetView.eHeight*2)

function RoleSubKnightView:__init()
	self.viewName = "RoleSubKnightView"
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(CCSizeMake(392, 494))
	self.rootNode:retain()
	local g_hero = GameWorld.Instance:getEntityManager():getHero()	
	self.curLevel = PropertyDictionary:get_knight(g_hero:getPT())
	self.lFlag = true
	self.mFlag = true
	self:initBg()
	self:initLine()
	self:initCurrentLabel()
	self:initNextLabel()
	self:initButton()
	self:setKnightInfo(self.curLevel)	
end	

function RoleSubKnightView:create()
	return RoleSubKnightView.New()
end

function RoleSubKnightView:__delete()
	self.rootNode:release()
	if self.curSprite then
		self.curSprite:release()
		self.curSprite = nil
	end
	if self.curUpGradeAnimate then
		self.curUpGradeAnimate:release()
		self.curUpGradeAnimate = nil			
	end
	if self.nextSprite then
		self.nextSprite:release()
		self.nextSprite = nil
	end
	if self.nextUpGradeAnimate then
		self.nextUpGradeAnimate:release()
		self.nextUpGradeAnimate = nil			
	end
end

function RoleSubKnightView:onExit()
	if self.curSprite then
		self.curSprite:stopAllActions()
		self.curSprite : setVisible(false)		
	end		
	if self.nextSprite then
		self.nextSprite:stopAllActions()
		self.nextSprite : setVisible(false)		
	end						
end

function RoleSubKnightView:onEnter()
	
end

function RoleSubKnightView:getRootNode()
	return self.rootNode
end

function RoleSubKnightView:initBg()
	self.allBg =  createSpriteWithFileName("ui/ui_img/common/skill_gridBox_bg.pvr")
	self.allBg:setScaleX(0.95)
	self.allBg:setScaleY(1.1)
	self.currentBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(157*g_scale,466*g_scale+E_OffsetView.eHeight*2))
	self.nextBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(157*g_scale,466*g_scale+E_OffsetView.eHeight*2))
	self.fullLvBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(157*g_scale,466*g_scale+E_OffsetView.eHeight*2))
	
	self.rootNode : addChild(self.allBg)
	self.rootNode : addChild(self.currentBg)
	self.rootNode : addChild(self.nextBg)
	self.rootNode : addChild(self.fullLvBg)
	VisibleRect:relativePosition(self.allBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(5,0))
	VisibleRect:relativePosition(self.currentBg,self.allBg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(21-E_OffsetView.eWidth,-13+E_OffsetView.eHeight))
	VisibleRect:relativePosition(self.nextBg,self.currentBg,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(32,0))	
	VisibleRect:relativePosition(self.fullLvBg,self.currentBg,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(32,0))
	local arrow = createScale9SpriteWithFrameName(RES("knight_arrow.png"))
	G_setScale(arrow)
	self.rootNode : addChild(arrow)
	VisibleRect:relativePosition(arrow,self.currentBg,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,0))

	--当前等级
	self.currentIconBg = createSpriteWithFrameName(RES("mall_goodsframe.png"))
	self.curLv = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.curName = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.currentBg : addChild(self.currentIconBg)
	self.currentBg : addChild(self.curLv)
	self.currentBg : addChild(self.curName)
	VisibleRect:relativePosition(self.currentIconBg,self.currentBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-10))	
	VisibleRect:relativePosition(self.curName,self.currentIconBg,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.curLv,self.curName,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,0))
	--下一等级
	self.nextIconBg = createSpriteWithFrameName(RES("mall_goodsframe.png"))
	self.nextLv = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.nextName = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.nextBg : addChild(self.nextIconBg)
	self.nextBg : addChild(self.nextLv)
	self.nextBg : addChild(self.nextName)
	VisibleRect:relativePosition(self.nextIconBg,self.nextBg,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-10))	
	VisibleRect:relativePosition(self.nextName,self.nextIconBg,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.nextLv,self.nextName,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,0))
	--满级
	self.fullIconBg = createSpriteWithFrameName(RES("mall_goodsframe.png"))
	self.fullLv = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.fullName = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.fullLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[6015], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))
	self.fullLvBg : addChild(self.fullIconBg)
	self.fullLvBg : addChild(self.fullLv)
	self.fullLvBg : addChild(self.fullName)
	self.fullLvBg : addChild(self.fullLabel)
	VisibleRect:relativePosition(self.fullIconBg,self.fullLvBg,LAYOUT_CENTER,ccp(0,15))	
	VisibleRect:relativePosition(self.fullName,self.fullIconBg,LAYOUT_CENTER+LAYOUT_TOP_OUTSIDE,ccp(0,23))
	VisibleRect:relativePosition(self.fullLv,self.fullName,LAYOUT_CENTER+LAYOUT_TOP_OUTSIDE,ccp(0,3))
	VisibleRect:relativePosition(self.fullLabel,self.fullIconBg,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	
	self.fullLvBg : setVisible(false)
	
	--功勋文字
	local textLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[6018], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow10"), CCSizeMake(160, 0))
	self.rootNode:addChild(textLabel)
	VisibleRect:relativePosition(textLabel, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(23, 95))
end

function RoleSubKnightView:initLine()
	--当前等级
	self.currentLine_1 = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(150*g_scale,0))
	self.currentLine_2 = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(150*g_scale,0))
	self.currentBg : addChild(self.currentLine_1)
	self.currentBg : addChild(self.currentLine_2)
	VisibleRect:relativePosition(self.currentLine_1,self.currentBg,LAYOUT_CENTER,ccp(0,85))
	VisibleRect:relativePosition(self.currentLine_2,self.currentBg,LAYOUT_CENTER,ccp(0,-40))
	--下一等级
	self.nextLine_1 = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(150*g_scale,0))
	self.nextLine_2 = createScale9SpriteWithFrameNameAndSize(RES("knight_line.png"), CCSizeMake(150*g_scale,0))
	self.nextBg : addChild(self.nextLine_1)
	self.nextBg : addChild(self.nextLine_2)
	VisibleRect:relativePosition(self.nextLine_1,self.nextBg,LAYOUT_CENTER,ccp(0,85))
	VisibleRect:relativePosition(self.nextLine_2,self.nextBg,LAYOUT_CENTER,ccp(0,-40))
end

function RoleSubKnightView:initCurrentLabel()
	local numBgSize = CCSizeMake(80, 20)
	--当前等级
	local curProPlus = createSpriteWithFrameName(RES("word_label_propertyAdd.png"))
	--物理攻击
	local curPAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6001], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local pAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.curPAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.curPAttackNum:setAnchorPoint(ccp(0, 0.5))
	--魔法攻击
	local curMAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6002], "Arial",FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local mAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.curMAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.curMAttackNum:setAnchorPoint(ccp(0, 0.5))
	--道术攻击
	local curTAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6003], "Arial",FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local tAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.curTAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.curTAttackNum:setAnchorPoint(ccp(0, 0.5))
	--俸禄领取
	local curSalary = createSpriteWithFrameName(RES("word_label_knightSalary.png"))
	local curBindGold = createLabelWithStringFontSizeColorAndDimension(Config.Words[6016], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow2"))
	--local bindGoldNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.curBindGoldNum =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.curBindGoldNum:setAnchorPoint(ccp(0, 0.5))
	
	--[[local curGold = createLabelWithStringFontSizeColorAndDimension(Config.Words[6006], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow2"))
	local goldNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.curGoldNum =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.curGoldNum:setAnchorPoint(ccp(0, 0.5))--]]
	
	self.currentBg : addChild(curProPlus)
	self.currentBg : addChild(curPAttack)
	self.currentBg : addChild(curMAttack)
	self.currentBg : addChild(curTAttack)
	--self.currentBg : addChild(pAtkNumBg)
	--self.currentBg : addChild(mAtkNumBg)
	--self.currentBg : addChild(tAtkNumBg)
	self.currentBg : addChild(self.curPAttackNum)
	self.currentBg : addChild(self.curMAttackNum)
	self.currentBg : addChild(self.curTAttackNum)
	self.currentBg : addChild(curSalary)
	self.currentBg : addChild(curBindGold)
	--self.currentBg : addChild(curGold)
	--self.currentBg : addChild(bindGoldNumBg)
	--self.currentBg : addChild(goldNumBg)
	self.currentBg : addChild(self.curBindGoldNum)
	--goldNumBg : addChild(self.curGoldNum)
	VisibleRect:relativePosition(curProPlus,self.currentLine_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-5))
	VisibleRect:relativePosition(curPAttack,curProPlus,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(3,-5))
	--VisibleRect:relativePosition(pAtkNumBg,curPAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.curPAttackNum,curPAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(curMAttack,curPAttack,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	--VisibleRect:relativePosition(mAtkNumBg,curMAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.curMAttackNum,curMAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(curTAttack,curMAttack,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	--VisibleRect:relativePosition(tAtkNumBg,curTAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.curTAttackNum,curTAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(curSalary,self.currentLine_2,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-5))
	VisibleRect:relativePosition(curBindGold,curSalary,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(3,-5))
	--VisibleRect:relativePosition(bindGoldNumBg,curBindGold,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.curBindGoldNum,curBindGold,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	--[[VisibleRect:relativePosition(curGold,curMerit,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(goldNumBg,curGold,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.curGoldNum,goldNumBg,LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(5, 0))--]]
	
	--满级
	local myMerit_Full =  createLabelWithStringFontSizeColorAndDimension(Config.Words[6008], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow10"))	
	self.myMeritNum_Full =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.fullLvBg : addChild(myMerit_Full)
	self.fullLvBg : addChild(self.myMeritNum_Full)	
	VisibleRect:relativePosition(myMerit_Full,self.fullLvBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(15,50))
	VisibleRect:relativePosition(self.myMeritNum_Full,myMerit_Full,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(20,0))	
end

function RoleSubKnightView:initNextLabel()
	local numBgSize = CCSizeMake(80, 20)
		--下一等级
	local nextProPlus = createSpriteWithFrameName(RES("word_label_propertyAdd.png"))
	--物理攻击
	local nextPAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6001], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local nextPAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.nextPAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorGreen1"))
	self.nextPAttackNum:setAnchorPoint(ccp(0, 0.5))
	self.upPAttactArrow = createSpriteWithFrameName("bagBatch_up_tip.png")
	--魔法攻击
	local nextMAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6002], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local nextMAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.nextMAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorGreen1"))
	self.nextMAttackNum:setAnchorPoint(ccp(0, 0.5))
	self.upMAttactArrow = createSpriteWithFrameName("bagBatch_up_tip.png")
	--道术攻击
	local nextTAttack = createLabelWithStringFontSizeColorAndDimension(Config.Words[6003], "Arial",FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local nextTAtkNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.nextTAttackNum = createLabelWithStringFontSizeColorAndDimension("0-0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorGreen1"))
	self.nextTAttackNum:setAnchorPoint(ccp(0, 0.5))
	self.upTAttactArrow = createSpriteWithFrameName("bagBatch_up_tip.png")
	--提升爵位
	local nextCondition =  createSpriteWithFrameName(RES("word_label_upgradeCondition.png"))
	--升级需要功勋
	local nextMerit = createLabelWithStringFontSizeColorAndDimension(Config.Words[6005], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local nextMeritNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.nextMeritNum =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.nextMeritNum:setAnchorPoint(ccp(0,0.5))
	--升级需要等级
	local needLv = createLabelWithStringFontSizeColorAndDimension(Config.Words[6011], "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	--local needLvNumBg = createScale9SpriteWithFrameNameAndSize(RES("common_bgNumFrame.png"), VisibleRect:getScaleSize(numBgSize))
	self.needLvNum =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.needLvNum:setAnchorPoint(ccp(0, 0.5))
	--当前功勋
	local myMerit =  createLabelWithStringFontSizeColorAndDimension(Config.Words[6008], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow1"))	
	self.myMeritNum =  createLabelWithStringFontSizeColorAndDimension("0", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorWhite2"))
	self.myMeritNum:setAnchorPoint(ccp(0, 0.5))
	
	self.nextBg : addChild(nextProPlus)
	self.nextBg : addChild(nextPAttack)
	self.nextBg : addChild(nextMAttack)
	self.nextBg : addChild(nextTAttack)
	--self.nextBg : addChild(nextPAtkNumBg)
	--self.nextBg : addChild(nextMAtkNumBg)
	--self.nextBg : addChild(nextTAtkNumBg)
	self.nextBg : addChild(self.nextPAttackNum)
	self.nextBg : addChild(self.nextMAttackNum)
	self.nextBg : addChild(self.nextTAttackNum)
	self.nextBg : addChild(nextCondition)
	self.nextBg : addChild(self.upPAttactArrow)
	self.nextBg : addChild(self.upMAttactArrow)
	self.nextBg : addChild(self.upTAttactArrow)
	--self.nextBg : addChild(nextMeritNumBg)
	--self.nextBg : addChild(needLvNumBg)	
	self.nextBg : addChild(nextMerit)
	self.nextBg : addChild(self.nextMeritNum)
	self.nextBg : addChild(needLv)
	self.nextBg : addChild(self.needLvNum)
	self.nextBg : addChild(myMerit)
	self.nextBg : addChild(self.myMeritNum)
	VisibleRect:relativePosition(nextProPlus,self.nextLine_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-5))
	VisibleRect:relativePosition(nextPAttack,nextProPlus,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(3,-5))
	--VisibleRect:relativePosition(nextPAtkNumBg,nextPAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.nextPAttackNum,nextPAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.upPAttactArrow,self.nextPAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(nextMAttack,nextPAttack,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	--VisibleRect:relativePosition(nextMAtkNumBg,nextMAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.nextMAttackNum,nextMAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.upMAttactArrow,self.nextMAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(nextTAttack,nextMAttack,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	--VisibleRect:relativePosition(nextTAtkNumBg,nextTAttack,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.nextTAttackNum,nextTAttack,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(self.upTAttactArrow,self.nextTAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(nextCondition,self.nextLine_2,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(10,-5))
	VisibleRect:relativePosition(nextMerit,nextCondition,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(3,-5))
	--VisibleRect:relativePosition(nextMeritNumBg,nextMerit,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.nextMeritNum,nextMerit,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(needLv,nextMerit,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	--VisibleRect:relativePosition(needLvNumBg,needLv,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE)
	VisibleRect:relativePosition(self.needLvNum,needLv,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
	VisibleRect:relativePosition(myMerit,needLv,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.myMeritNum,myMerit,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))	
end

function RoleSubKnightView:initButton()
	local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
	self.getSalaryBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.upgradeKnightBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.unableGetBtn = createSpriteWithFrameName(RES("btn_1_select.png"))
	self.unableUpBtn = createSpriteWithFrameName(RES("btn_1_select.png"))
	UIControl:SpriteSetGray(self.unableGetBtn)
	UIControl:SpriteSetGray(self.unableUpBtn)
	local getSalaryBtnWord = createSpriteWithFrameName(RES("word_button_receivesalary.png"))
	local upgradeKnightBtnWord = createSpriteWithFrameName(RES("word_button_promoteknight.png"))
	G_setScale(getSalaryBtnWord)
	G_setScale(upgradeKnightBtnWord)
	local unableGetBtnWord = createSpriteWithFrameName(RES("word_button_receivesalary.png"))
	UIControl:SpriteSetGray(unableGetBtnWord)	
	local unableUpBtnWord = createSpriteWithFrameName(RES("word_button_promoteknight.png"))
	UIControl:SpriteSetGray(unableUpBtnWord)
	G_setScale(unableGetBtnWord)
	G_setScale(unableUpBtnWord)
	self.currentBg : addChild(self.getSalaryBtn)
	self.nextBg : addChild(self.upgradeKnightBtn)
	self.currentBg : addChild(self.unableGetBtn)
	self.nextBg : addChild(self.unableUpBtn)
	self.getSalaryBtn:setTitleString(getSalaryBtnWord)
	self.upgradeKnightBtn:setTitleString(upgradeKnightBtnWord)
	self.unableGetBtn:addChild(unableGetBtnWord)
	self.unableUpBtn:addChild(unableUpBtnWord)
	VisibleRect:relativePosition(unableGetBtnWord,self.unableGetBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(unableUpBtnWord,self.unableUpBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.getSalaryBtn,self.currentBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,2))
	VisibleRect:relativePosition(self.upgradeKnightBtn,self.nextBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,2))	
	VisibleRect:relativePosition(self.unableGetBtn,self.currentBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(self.unableUpBtn,self.nextBg,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,0))	
	local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()	
	local salaryFlag = knightMgr:getSalaryFlag()
	if salaryFlag == true then
		self.unableGetBtn : setVisible(true)
		self.getSalaryBtn : setVisible(false)
	elseif salaryFlag == false then
		self.unableGetBtn : setVisible(false)
		self.getSalaryBtn : setVisible(true)	
	else
		self.unableGetBtn : setVisible(false)
		self.getSalaryBtn : setVisible(true)
	end
	self.unableUpBtn : setVisible(false)
	--领取俸禄按钮功能
	local getSalaryFunc = function()
		if(self.curLevel ~= 0) then
			knightMgr:requestGetSalary()
		end
	end
	self.getSalaryBtn:addTargetWithActionForControlEvents(getSalaryFunc,CCControlEventTouchDown)
	
	--升级按钮功能
	local upgradeKnightFunc = function()
		self:clickUpgradeKnightBtn()
		if(self.mFlag == true and self.lFlag == true) then
			knightMgr:requestUpGrade()
		end
	end
	self.upgradeKnightBtn:addTargetWithActionForControlEvents(upgradeKnightFunc,CCControlEventTouchDown)
end

function RoleSubKnightView:setSalary()
	--已经领取设置不可选
	self.getSalaryBtn:setVisible(false)
	self.unableGetBtn : setVisible(true)
	
end

function RoleSubKnightView:setKnightInfo(knightLv)

	local g_hero = GameWorld.Instance:getEntityManager():getHero()
	self.heroLv = PropertyDictionary:get_level(g_hero:getPT())
	self.merit = PropertyDictionary:get_merit(g_hero:getPT())
	self.myMeritNum : setString(self.merit)
	self.myMeritNum_Full : setString(self.merit)
	if(knightLv ~= 0) then
		self.curLevel = knightLv
		self.currentKnight = "knight_"..knightLv
		self.curStaticData = self:getStaticData(self.currentKnight) --取当前等级的静态数据
		self.curLv : setString("Lv."..self.curLevel)
		
		--设置当前等级信息
		if(self.curStaticData) then
			local curKnightName = self.curStaticData.property.name
			self.curName : setString(curKnightName)	--设置爵位名字
			local minPAtk = self.curStaticData.property.minPAtk
			local maxPAtk = self.curStaticData.property.maxPAtk
			local pAtk = minPAtk.."-"..maxPAtk
			self.curPAttackNum : setString(pAtk)	--设置物理攻击数值
			local minMAtk = self.curStaticData.property.minMAtk
			local maxMAtk = self.curStaticData.property.maxMAtk
			local mAtk = minMAtk.."-"..maxMAtk
			self.curMAttackNum : setString(mAtk)	--设置魔法攻击数值
			local minTao = self.curStaticData.property.minTao
			local maxTao = self.curStaticData.property.maxTao
			local tAtk = minTao.."-"..maxTao
			self.curTAttackNum : setString(tAtk)	--设置道术攻击数值
			
			--设置爵位图标
			self.currentIconBg : removeAllChildrenWithCleanup(true)
			local icon = self.curStaticData.property.iconId			
			if(icon) then
				local curIcon =  createSpriteWithFileName(ICON(icon))	
				--curIcon:setScale(60/79)		
				if curIcon==nil then
					curIcon =   createSpriteWithFileName(ICON("unkown"))
					curIcon : setScale(0.5)
				end
				self.currentIconBg : addChild(curIcon)
				VisibleRect:relativePosition(curIcon,self.currentIconBg,LAYOUT_CENTER)				
			end 
			
			--升级等级条件
			self.needLevel = self.curStaticData.property.roleGrade
			if(self.needLevel) then
				self.needLvNum : setString(self.needLevel)
				if(self.needLevel>self.heroLv) then
					self.needLvNum : setColor(FCOLOR("ColorRed2")) 
					self.lFlag = false
					self.upgradeKnightBtn:setVisible(false)
					self.unableUpBtn:setVisible(true)
				else
					self.needLvNum : setColor(FCOLOR("ColorWhite2"))
					self.lFlag = true
					--[[self.upgradeKnightBtn:setVisible(true)
					self.unableUpBtn:setVisible(false)--]]
				end
			end
			--设置可领取的资源
			local dailySalary = self.curStaticData.knightData			
			local bindGoldTb = dailySalary.knightSalary						
			local dailyGold = 0
			
			if type(bindGoldTb) == "table" then	
				for k,v in pairs(bindGoldTb) do 
					for key,number in pairs(v) do
						dailyGold = number
					end
				end	
			end				
			self.curBindGoldNum : setString(dailyGold)
		end
		if(knightLv <10) then
			
			self.nextLv : setString("Lv."..(self.curLevel+1))
			self.nextKnight = "knight_"..(knightLv+1)		
			self.nextStaticData = self:getStaticData(self.nextKnight) --取下一等级的静态数据	
			--设置下一等级信息
			if(self.nextStaticData) then
				local nextKnightName = self.nextStaticData.property.name
				self.nextName : setString(nextKnightName)	--设置爵位名字
				local minPAtk = self.nextStaticData.property.minPAtk
				local maxPAtk = self.nextStaticData.property.maxPAtk
				local pAtk = minPAtk.."-"..maxPAtk
				self.nextPAttackNum : setString(pAtk)	--设置物理攻击数值
				VisibleRect:relativePosition(self.upPAttactArrow,self.nextPAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
				local minMAtk = self.nextStaticData.property.minMAtk
				local maxMAtk = self.nextStaticData.property.maxMAtk
				local mAtk = minMAtk.."-"..maxMAtk
				self.nextMAttackNum : setString(mAtk)	--设置魔法攻击数值
				VisibleRect:relativePosition(self.upMAttactArrow,self.nextMAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
				local minTao = self.nextStaticData.property.minTao
				local maxTao = self.nextStaticData.property.maxTao
				local tAtk = minTao.."-"..maxTao
				self.nextTAttackNum : setString(tAtk)	--设置道术攻击数值
				VisibleRect:relativePosition(self.upTAttactArrow,self.nextTAttackNum,LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE, ccp(5, 0))
				
				--设置爵位图标
				self.nextIconBg : removeAllChildrenWithCleanup(true)
				local icon = self.nextStaticData.property.iconId
				if(icon) then							
					local nextIcon = createSpriteWithFileName(ICON(icon ))
					--nextIcon:setScale(60/79)	
					if nextIcon==nil then
						nextIcon =   createSpriteWithFileName(ICON("unkown"))
						nextIcon : setScale(0.5)
					end
					self.nextIconBg : addChild(nextIcon)
					VisibleRect:relativePosition(nextIcon,self.nextIconBg,LAYOUT_CENTER)
				end
				--设置升级消耗
				self.upgradeSrcConsume = self.curStaticData.knightData.upgradeSrcConsume[1]
				if(self.upgradeSrcConsume) then
					self.nextMeritNum : setString(self.upgradeSrcConsume["merit"])
				
					--升级功勋条件
					if(self.merit<self.upgradeSrcConsume["merit"]) then
						self.nextMeritNum : setColor(FCOLOR("ColorRed2"))
						self.mFlag = false
						self.upgradeKnightBtn:setVisible(false)
						self.unableUpBtn:setVisible(true)
					else
						self.nextMeritNum : setColor(FCOLOR("ColorWhite2"))
						self.mFlag = true
						--[[self.upgradeKnightBtn:setVisible(true)
						self.unableUpBtn:setVisible(false)--]]
					end
				end
			end
			if(self.mFlag == true and self.lFlag == true) then
				self.upgradeKnightBtn:setVisible(true)
				self.unableUpBtn:setVisible(false)
			end
		else --满级情况
			self.nextBg : setVisible(false)
			self.fullLvBg : setVisible(true)
			local fullKnightName = self.curStaticData.property.name
			self.fullLv : setString("Lv."..self.curLevel)
			self.fullName : setString(fullKnightName)	--设置爵位名字
				
			--设置爵位图标
			self.fullIconBg : removeAllChildrenWithCleanup(true)
			local icon = self.curStaticData.property.iconId
			if(icon) then
				local fullIcon =  createSpriteWithFileName(ICON(icon))
				--fullIcon:setScale(60/79)
				if fullIcon==nil then
					fullIcon =   createSpriteWithFileName(ICON("unkown"))
					fullIcon : setScale(0.5)
				end
				self.fullIconBg : addChild(fullIcon)
				VisibleRect:relativePosition(fullIcon,self.fullIconBg,LAYOUT_CENTER)
				
			end 
		end
	end
end

function RoleSubKnightView:getStaticData(refId)
	
	local staticData = GameData.Knight[refId]
	if (staticData ~= nil) then
		return staticData
	end
end	

function RoleSubKnightView:refreshKnightInfo(pt)
	local newLevel = PropertyDictionary:get_knight(pt)	
	local newLv = PropertyDictionary:get_level(pt)
	local newMerit = PropertyDictionary:get_merit(pt)
	
	if(newLv ~= 0 and newLv ~= self.heroLv) then
		self.heroLv = newLv
		if(self.needLevel) then
			if(self.needLevel <= self.heroLv) then
				self.needLvNum : setColor(FCOLOR("ColorWhite2"))
				self.lFlag = true		
			end
		end
	end
	if(newMerit ~= 0) then
		if(newMerit ~= self.merit) then
			self.merit = newMerit
			self.myMeritNum : setString(self.merit)
			self.myMeritNum_Full : setString(self.merit)	
			if(self.upgradeSrcConsume) then
				if(self.upgradeSrcConsume["merit"] <= self.merit) then
					self.nextMeritNum : setColor(FCOLOR("ColorWhite2"))
					self.mFlag = true		
				end
			end
		end
	end
	if(self.mFlag == true and self.lFlag == true) then
		self.upgradeKnightBtn:setVisible(true)
		self.unableUpBtn:setVisible(false)
	end
	if(newLevel ~= 0) then
		if(self.curLevel ~= newLevel) then		
			self:setKnightInfo(newLevel)
			self:upgradeAnimate()
			local msg = {[1] = {word = Config.Words[15002], color = Config.FontColor["ColorBlue2"]}}
			UIManager.Instance:showSystemTips(msg)
		end
	end	
end

function RoleSubKnightView:rewardReset()
	self.getSalaryBtn:setVisible(true)
	self.unableGetBtn : setVisible(false)
end

function RoleSubKnightView:upgradeAnimate()
	if self.curUpGradeAnimate then
		local isDone = self.curUpGradeAnimate:isDone()
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
	if self.nextUpGradeAnimate then
		local isDone = self.nextUpGradeAnimate:isDone()
		if isDone == false then	
			self.nextIconBg:removeChildByTag(1,true)	
			self.nextSprite : setVisible(false)	
			self.nextUpGradeAnimate:release()
			self.nextSprite:release()
			self.nextUpGradeAnimate = nil
			self.nextCallbackAction = nil
			self.nextSprite = nil
			self.nextSpawnArray = nil
		end
	end
	if self.curLevel > 1 then
		if not self.curUpGradeAnimate then
			self.curUpGradeAnimate = createAnimate("iconFlash",8,0.125)
			self.curUpGradeAnimate:retain()
		end
		if not self.curSprite then
			self.curSprite = CCSprite:create()	
			self.curSprite:retain()
		end
		if self.curUpGradeAnimate and self.curSprite then
			local function finishRunRightCallback()
				self.curSprite : setVisible(false)	
				self.curUpGradeAnimate:release()
				self.curSprite:release()
				self.curUpGradeAnimate = nil
				self.curCallbackAction = nil
				self.curSprite = nil
				self.curSpawnArray = nil			
			end
			self.curCallbackAction = CCCallFunc:create(finishRunRightCallback)
			if not self.curSpawnArray then
				self.curSpawnArray = CCArray:create()
			end
			self.curSpawnArray:addObject(self.curUpGradeAnimate)
			self.curSpawnArray:addObject(self.curCallbackAction)
			self.curAction = CCSequence:create(self.curSpawnArray)
			self.curSprite:runAction(self.curAction)				
			self.currentIconBg:addChild(self.curSprite)
			VisibleRect:relativePosition(self.curSprite, self.currentIconBg, LAYOUT_CENTER, ccp(0,0))
		end
		if not self.nextUpGradeAnimate then
			self.nextUpGradeAnimate = createAnimate("iconFlash",8,0.125)
			self.nextUpGradeAnimate:retain()
		end
		if not self.nextSprite then
			self.nextSprite = CCSprite:create()	
			self.nextSprite:retain()
		end
		if self.nextUpGradeAnimate and self.nextSprite then
			local function finishRunRightCallback()
				self.nextSprite : setVisible(false)	
				self.nextUpGradeAnimate:release()
				self.nextSprite:release()
				self.nextUpGradeAnimate = nil
				self.nextCallbackAction = nil
				self.nextSprite = nil
				self.nextSpawnArray = nil			
			end
			self.nextCallbackAction = CCCallFunc:create(finishRunRightCallback)
			if not self.nextSpawnArray then
				self.nextSpawnArray = CCArray:create()
			end
			self.nextSpawnArray:addObject(self.nextUpGradeAnimate)
			self.nextSpawnArray:addObject(self.nextCallbackAction)
			self.nextSprite:runAction(CCSequence:create(self.nextSpawnArray))
			if self.curLevel ~= 10 then		
				self.nextIconBg:addChild(self.nextSprite)
				self.nextSprite:setTag(1)
				VisibleRect:relativePosition(self.nextSprite, self.nextIconBg, LAYOUT_CENTER, ccp(0,0))
			else 
				self.fullIconBg:addChild(self.nextSprite)
				VisibleRect:relativePosition(self.nextSprite, self.fullIconBg, LAYOUT_CENTER, ccp(0,0))
			end
		end			
	end		
end

-----------------------------------------------------------
--新手指引
function RoleSubKnightView:getUpgradeKnightBtn()
	return self.upgradeKnightBtn
end

function RoleSubKnightView:clickUpgradeKnightBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"RoleView","upgradeKnightBtn")
end	
-----------------------------------------------------------
