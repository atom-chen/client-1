-- 显示翅膀详情
require("ui.UIManager")
require("common.BaseUI")
require"data.wing.wing"
require("ui.utils.MessageBox")
require("object.wing.WingMgr")
require("object.wing.WingObject")
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.utils.BodyAreaView")
require("ui.utils.HeroModelView")
require("object.equip.EquipDef")
require("data.item.propsItem")
WingView = WingView or BaseClass(BaseUI)

local wing_grade = {
[1] = Config.Words[1030],
[2] = Config.Words[1031],
[3] = Config.Words[1032],
[4] = Config.Words[1033],
[5] = Config.Words[1034],
[6] = Config.Words[1035],
[7] = Config.Words[1036],
[8] = Config.Words[1037],
[9] = Config.Words[1038],
[10] = Config.Words[1039],
}

local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local wingMgr = nil
local g_equipMgr = nil
local WingSelected = 1  --记录被选择的item号
local FeatherNum = 0
local cellSize = VisibleRect:getScaleSize(CCSizeMake(131,110))
local cellBgSize = VisibleRect:getScaleSize(CCSizeMake(131,110))
--scrollView
local viewSize = CCSizeMake(192,154)
local nodeSize = CCSizeMake(192,21)

function WingView:__init()
	self.viewName = "WingView"
	UIManager.Instance:registerUI("MessageBox",MessageBox.create)
	wingMgr = GameWorld.Instance:getEntityManager():getHero():getWingMgr()
	g_equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	self:initFullScreen()
	self.baojiTipsCount = 0
	self.eventType = {}	-- tableview的数据类型
	self.scrollNodes = {}
	self:initVariable()
	self:initItem()
	self.refId  = wingMgr:getWingRefId()
	self:updateView(self.refId)
end

function WingView:create()
	return WingView.New()
end

function WingView:__delete()
	self.cellFrame:release()
	self.cellFrame = nil
	self.eventType = {}
	self.scrollNodes = {}
	self.heroModelView:DeleteMe()
	self.heroModelView = nil
end

function WingView:onEnter()
	self:ReturnNowWing()
	self.curExp = wingMgr:getWingExp()
	self.isAutoUpGrade = false
	self.cuRefId = wingMgr:getWingRefId()
	local refId = wingMgr:getWingRefId()
	local record = WingObject:getStaticData(refId)
	local maxExp = 0
	if record then
		maxExp = PropertyDictionary:get_maxExp(record)
	end
	self:setProcessBar(wingMgr:getWingExp() ,maxExp)
			
	if self.refId ~= refId then
		self.refId = refId
		self:updateView(self.refId)
		self:updateWingModle()
		--wingMgr:setNeedUpdate(false)
	end
	--self:showWingUpGradeAni(true,"wing_5_0",10)
end

function WingView:onExit()
	local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
	self.AutoImproveBtn:setTitleString(AutoImproveLabel)
	self.isAutoUpGrade = false
	if self.endExp and self.endMaxExp then
		self:updateView(self.endRefId)
		self:setProcessBar(self.endExp ,self.endMaxExp)		
	end
	self:removeBaojiSprite()	
end	

function WingView:removeBaojiSprite()
	if self.baojiTipsCount and self.baojiTipsCount > 0 then
		for i = 1 , self.baojiTipsCount do
			self:getContentNode():removeChildByTag(10,true)
		end
	end
end

function WingView:initVariable()
	--tableview数据源的类型
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	self.cellFrame = createSpriteWithFrameName(RES("mall_goodsframe_selected.png"))
	self.cellFrame:retain()
	self.aniSpr = CCSprite:create()
	self:addChild(self.aniSpr)
	self.wingNum = table.size(GameData.Wing)/4
	self.maxNum = self.wingNum
	self.clickFlag = true
	self.selectedCell = 1
	self.selectedCells = {}
	self.intervalSize_0 = 0
end

function WingView:createItem(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)
	--背景
	local cellBg = createSpriteWithFrameName(RES("mall_goodsframe.png"))
	item:addChild(cellBg)
	VisibleRect:relativePosition(cellBg,item,LAYOUT_CENTER)
	if index ~= self.maxNum then
		local line = createScale9SpriteWithFrameName(RES("left_line.png"))
		VisibleRect:relativePosition(line,item,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,0))
		item:addChild(line)
	end
	local iconName = "wing_" .. index
	local icon = createSpriteWithFileName(ICON(iconName))
	if self.refId == nil then
		UIControl:SpriteSetGray(icon)
		UIControl:SpriteSetGray(cellBg)
	elseif index > tonumber(string.match(self.refId,"%a+_(%d+)"))  then
		UIControl:SpriteSetGray(icon) --未开启的翅膀图标设置为黑白
		UIControl:SpriteSetGray(cellBg)
	else
		UIControl:SpriteSetColor(icon)
		UIControl:SpriteSetColor(cellBg)
	end
	cellBg:addChild(icon)
	VisibleRect:relativePosition(icon,cellBg,LAYOUT_CENTER, ccp(0, 0))
	
	return item
end

function WingView:initItem()
	--图标和标题
	local titleSign = createSpriteWithFrameName(RES("main_wing.png"))
	self:setFormImage(titleSign)
	local titleName = createSpriteWithFrameName(RES("word_window_wing.png"))
	self:setFormTitle(titleName, TitleAlign.Left)
	--翅膀信息背景
	self.WingInfo_bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())--CCSizeMake(833,480))
	self:addChild(self.WingInfo_bg)
	VisibleRect:relativePosition(self.WingInfo_bg,self:getContentNode(), LAYOUT_CENTER)
	--左侧翅膀图标背景
	self.WingIcon_bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(131,453))
	self.WingInfo_bg:addChild(self.WingIcon_bg)
	VisibleRect:relativePosition(self.WingIcon_bg,self.WingInfo_bg, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(14,0))
	--翅膀展示背景
	self.Wing_bg = CCSprite:create("ui/ui_img/common/wingBg.pvr")
	self.WingIcon_bg:addChild(self.Wing_bg)
	VisibleRect:relativePosition(self.Wing_bg, self.WingIcon_bg, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER, ccp(14, 0))
	--形象预览
	local previewBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"), CCSizeMake(130, 33))
	self.WingIcon_bg:addChild(previewBg)
	VisibleRect:relativePosition(previewBg, self.WingIcon_bg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
	local previewLable = createSpriteWithFrameName(RES("word_label_imagepreview.png"))
	self.WingIcon_bg:addChild(previewLable)
	VisibleRect:relativePosition(previewLable, previewBg, LAYOUT_CENTER)
	--属性背景
	local propertyBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"),CCSizeMake(192, 420))
	self.Wing_bg:addChild(propertyBg)
	VisibleRect:relativePosition(propertyBg, self.Wing_bg, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER, ccp(-14,0))
	
	self.Star1,self.starBg1 = self:createStar(-150,-50)
	self.Star2,self.starBg2 = self:createStar(-100,-50)
	self.Star3,self.starBg3 = self:createStar(-50,-50)
	
	
	--创建翅膀图标tableview
	self:initIconView()
	--翅膀展示
	self:WingShowView()
	--升级控件
	self:UpdateController()
	
	--右边翅膀属性标签
	--当前等级翅膀属性
	self:createCurProperty(propertyBg)
	--下一等级翅膀属性
	self:createNextProperty(propertyBg)
	
	self:createExpProgressBar()
	
	self.nameBg = createSpriteWithFrameName(RES("frontNameBg.png"))
	self.Wing_bg:addChild(self.nameBg,3)
	VisibleRect:relativePosition(self.nameBg, self.Wing_bg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(11,-13))
	
	--战斗力提升
	self.fightImproveHead = createSpriteWithFrameName(RES("talisman_fightingPromote.png"))
	propertyBg:addChild(self.fightImproveHead)
	VisibleRect:relativePosition(self.fightImproveHead, propertyBg, LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE, ccp(-22,10))
	--self.fightImproveLabel = createAtlasNumber(Config.AtlasImg.Number1,"")	--创建美术数字标签
	--换为与坐骑一样的程序数字 @sj
	self.fightImproveLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow1"))
	self.fightImproveHead:addChild(self.fightImproveLabel)
	VisibleRect:relativePosition(self.fightImproveLabel,self.fightImproveHead,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(10,0))
end

function WingView:createStar(x,y)
	local starBg = createScale9SpriteWithFrameName(RES("common_star.png"))
	self:addChild(starBg)
	VisibleRect:relativePosition(starBg,self.Wing_bg,LAYOUT_CENTER_X +LAYOUT_TOP_INSIDE,ccp(x,y))
	local Star = createScale9SpriteWithFrameName(RES("common_star.png"))
	Star:setAnchorPoint(ccp(0,0))
	starBg:addChild(Star)
	starBg:setColor(ccc3(50,50,50))
	return Star,starBg
end

function WingView:createExpProgressBar()
	--进度条
	local processBg = createScale9SpriteWithFrameNameAndSize(RES("mountProgressBottom.png"),CCSizeMake(227, 16))
	self:addChild(processBg)
	VisibleRect:relativePosition(processBg, self.WingInfo_bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X, ccp(-35, 105))
	--左右两端
	local processLeftHand = createSpriteWithFrameName(RES("mountProgressTop.png"))
	local processRightHand  = createSpriteWithFrameName(RES("mountProgressTop.png"))
	processRightHand:setFlipX(true)
	self:addChild(processLeftHand, 10)
	self:addChild(processRightHand, 11)
	VisibleRect:relativePosition(processLeftHand, processBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE)
	VisibleRect:relativePosition(processRightHand, processBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	
	local expProcessbarSprite = createSpriteWithFrameName(RES("mountProgressMid.png"))
	self.expProcessbar =  CCProgressTimer:create(expProcessbarSprite)
	self.expProcessbar:setType(kCCProgressTimerTypeBar)
	self.expProcessbar:setScaleX(76)
	self.expProcessbar:setMidpoint(ccp(0, 0.5))
	self.expProcessbar:setBarChangeRate(ccp(1,0))
	VisibleRect:relativePosition(self.expProcessbar, processBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
	self:addChild(self.expProcessbar, 1)
	--玻璃罩
	local grassCover = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"), CCSizeMake(235,22))
	self:addChild(grassCover, 2)
	VisibleRect:relativePosition(grassCover, processBg, LAYOUT_CENTER)
	--经验条标签
	self.expLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size1")*scale, FCOLOR("ColorWhite1"))
	VisibleRect:relativePosition(self.expLabel,self.expProcessbar,LAYOUT_CENTER)
	self:addChild(self.expLabel, 5)
end

function WingView:updateInfo(refId)
	if refId == nil then
		return nil
	end
	local recordItem = GameData.Wing[refId]
	self.curTabel = recordItem["property"]
	self.effectDataTabel = recordItem["effectData"]
	if refId ~= "wing_" .. self.maxNum .. "_3" then
		self.nextRefId = PropertyDictionary:get_wingNextRefId(self.curTabel)
		self.nextTabel = GameData.Wing[self.nextRefId]["property"]
		self.nextEffectDataTabel = GameData.Wing[self.nextRefId]["effectData"]
	end
	self.ItemNum = GameData.Wing[refId]["property"].featherMaxConsume
	self:setWingName(refId)
	self:setGrade(tonumber( string.match(refId,"%a+_(%d+)")))
	--更新翅膀
	self:showWingModelByRefId(refId)
end

function WingView:updateView(refId)
	if refId ==nil then
		return nil
	end
	self.refId = refId
	self.wingLevel = wingMgr:getWingLevelById(refId)  --当前翅膀等级
	self:updateInfo(refId)
	if refId ~= "wing_" .. self.maxNum .. "_3" then
		--self.ItemNum = PropertyDictionary:get_number(self.materailTable)		--所需羽毛数量
		self:setWingProperty2(self.nextEffectDataTabel)
	else
		self.ItemNum = 0
	end
	self:setWingProperty(self.effectDataTabel)
	local FightImpValue = self:getFightImpValue()
	self:setFightImpValue(FightImpValue)
	self:setFeatherNumber()
	self.selectedCell = tonumber( string.match(refId,"%a+_(%d+)"))
	self.WingTable:reloadData()--updateCellAtIndex(self.selectedCell-1)
	self.WingTable:scroll2Cell(self.selectedCell-1 , false)  --滚动到当前icon
	self:updatePlayerModel()
	self:setStar(tonumber( string.match(refId,"%a+_%d+_(%d+)")))
	--隐藏升级
	self:hideUpGrade()
	
	--	self:showWingTips()
end

function WingView:getFeatherItem()
	
	Num = 0
	local Icon
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	Num = bgmgr:getItemNumByRefId("item_chibangExp")
	itemTable = GameData.PropsItem["item_chibangExp"]["property"]
	Icon = PropertyDictionary:get_iconId(itemTable)
	return Num,Icon
end

function WingView:isUpGrade()
	local featherOwnedNum = self:getFeatherItem()
	if self.refId == "wing_" .. self.maxNum .. "_3" then
		return false
	end
	if featherOwnedNum == nil then
		return false
	elseif tonumber(featherOwnedNum) >= self.ItemNum then
		return true
	else
		return false
	end
end

function WingView:updatePlayerModel()
	local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
	self.heroModelView:removeAllEquip()
	self.heroModelView:setEquipList(equipMgr:getEquipList())
end

function WingView:hideUpGrade()
	if self.refId == "wing_" .. self.maxNum .. "_3" then
		self.materialLabelHead:setVisible(false)
		self.ImproveBtn:setVisible(false)
		self.AutoImproveBtn:setVisible(false)
		self.featherNumberLabel:setVisible(false)
		self.fightImproveHead:setVisible(false)
		self.fightImproveLabel:setVisible(false)
		self.scrollView2:setVisible(false)
		self.ExpItemLabel:setVisible(false)
		self.ExpItemLabelHead:setVisible(false)
		self.FullLevelDescLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[717], "Arial", FSIZE("Size2")*scale, FCOLOR("ColorWhite2"),CCSizeMake(180,0))
		self:addChild(self.FullLevelDescLabel)
		VisibleRect:relativePosition(self.FullLevelDescLabel,self.propertyDescBg2,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(630,-45) )
	end
end

function WingView:showWingModelByRefId(refId)
	if refId == nil then
		return nil
	end
	local wingRefId = string.match(refId,"%a+_%d+")
	self.heroModelView:setWing(wingRefId)
	self:setFight(refId)
end

--设置翅膀名字
function WingView:setWingName(refId)
	local index = string.match(refId,"%a+_(%d+)")
	local wingName = "wing_name" .. index .. ".png"
	if self.wingNameSprite then
		self.wingNameSprite:removeFromParentAndCleanup(true)
	end
	self.wingNameSprite = createSpriteWithFrameName(RES(wingName))
	self:addChild(self.wingNameSprite,3)
	VisibleRect:relativePosition(self.wingNameSprite, self.nameBg, LAYOUT_CENTER,ccp(150,0))
end

--设置羽毛数量
function WingView:setFeatherNumber()
	--判断材料是否足够设置不同颜色
	local upGradeTag = self:isUpGrade();
	if upGradeTag == true then
		self.featherNumberLabel:setColor(FCOLOR("ColorGreen2"))
	else
		self.featherNumberLabel:setColor(FCOLOR("ColorRed2"))
	end
	if self.refId == "wing_" .. self.maxNum .. "_3" then
		self.featherNumberLabel:setString("")
	else
		self.featherNumberLabel:setString(self:getExpItem())
		if self.ItemNum  then
			self.ExpItemLabel:setString(self.ItemNum )
		end
	end
end

--设置翅膀等级  传入数字即可（1，2，...,10）
function WingView:setGrade(Grade)
	self.WingGradeLabel:setString(wing_grade[Grade])
end

--设置翅膀属性控件
function WingView:setWingProperty(wingTable)
	self:set_Desc(self.LW_AttackLabel,PropertyDictionary:get_minPAtk(wingTable),PropertyDictionary:get_maxPAtk(wingTable))
	self:set_Desc(self.LM_AttackLabel,PropertyDictionary:get_minMAtk(wingTable),PropertyDictionary:get_maxMAtk(wingTable))
	self:set_Desc(self.LD_AttackLabel,PropertyDictionary:get_minTao(wingTable) ,PropertyDictionary:get_maxTao(wingTable))
	self:set_Desc(self.LW_DefenceLabel,PropertyDictionary:get_PImmunityPer(wingTable))
	self:set_Desc(self.LM_DefenceLabel,PropertyDictionary:get_MImmunityPer(wingTable))
end

function WingView:setWingProperty2(wingTable)
	self:set_Desc(self.LW_AttackLabel2,PropertyDictionary:get_minPAtk(wingTable),PropertyDictionary:get_maxPAtk(wingTable))
	self:set_Desc(self.LM_AttackLabel2,PropertyDictionary:get_minMAtk(wingTable),PropertyDictionary:get_maxMAtk(wingTable))
	self:set_Desc(self.LD_AttackLabel2,PropertyDictionary:get_minTao(wingTable) ,PropertyDictionary:get_maxTao(wingTable))
	self:set_Desc(self.LW_DefenceLabel2,PropertyDictionary:get_PImmunityPer(wingTable))
	self:set_Desc(self.LM_DefenceLabel2,PropertyDictionary:get_MImmunityPer(wingTable))
end

function WingView:set_Desc(headLabel,leastStr,maxStr)
	if maxStr then
		headLabel:setString(leastStr.."-".. maxStr)
	else
		headLabel:setString(leastStr .. "%")
	end
end

function WingView:getRootNode()
	return self.rootNode
end

--播放动画  参数：动画ID
function WingView:PlayAnimation(animationId)
	
end

function WingView:DecreaseItemNum(label,decNum)
	label:setString(tonumber(label:getString())-decNum)
end

function WingView:ClearItemNum(label)
	label:setString("0")
end

function WingView:setFight(refId)
	local recordItem = GameData.Wing[refId]
	curTabel = recordItem["property"]
	self.fightLable:setString(PropertyDictionary:get_injure(curTabel))
end

function WingView:setFightImpValue(impValue)
	if impValue~= nil then
		self.fightImproveLabel:setString(impValue)
		VisibleRect:relativePosition(self.fightImproveLabel,self.fightImproveHead,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(10,0))
	end
end

function WingView:getFightImpValue()
	if self.refId == "wing_" .. self.maxNum .. "_3" then
		return nil
	end
	FighiImpvalue = PropertyDictionary:get_injure(self.nextTabel) - PropertyDictionary:get_injure(self.curTabel)
	return FighiImpvalue
end

function WingView:ReturnNowWing()
	if self.refId ~= nil then
		self:updateInfo(self.refId)
		if self.refId ~= "wing_" .. self.maxNum .. "_3" then --未满级
			self:setFeatherNumber()
		end
		self.selectedCell = tonumber( string.match(self.refId,"%a+_(%d+)"))
		self.WingTable:updateCellAtIndex(self.selectedCell-1)
		self.WingTable:scroll2Cell(self.selectedCell-1 , false)  --滚到当前icon
	end
end

function WingView:initIconView()
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")
		self.selectedCell  = cell:getIndex()+1
		self.WingTable:updateCellAtIndex(self.selectedCell-1)
		self:updateInfo("wing_" .. (cell:getIndex()+1) .."_0")
	end
	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellBgSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(cellBgSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(cellBgSize))
				local item = self:createItem(index+1)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellBgSize))
				local item = self:createItem(index+1)
				tableCell:addChild(item)
				VisibleRect:relativePosition(item,tableCell,LAYOUT_CENTER)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)
			if self.selectedCell == index+1 then
				if(self.cellFrame : getParent() == nil) then
					tableCell:addChild(self.cellFrame)
					VisibleRect:relativePosition(self.cellFrame,tableCell,LAYOUT_CENTER)
				else
					self.cellFrame : removeFromParentAndCleanup(true)
					tableCell : addChild(self.cellFrame)
					VisibleRect:relativePosition(self.cellFrame,tableCell,LAYOUT_CENTER)
				end
			end
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(self.wingNum)
			return 1
		end
	end

	--创建tableview
	self.WingTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(131,410)))
	self.WingTable:reloadData()
	self.WingTable:setTableViewHandler(tableDelegate)
	self.WingTable:scroll2Cell(self.selectedCell-1, false)  --滚到当前icon
	self.WingIcon_bg:addChild(self.WingTable)

	VisibleRect:relativePosition(self.WingTable, self.WingIcon_bg, LAYOUT_CENTER, ccp(0, -10))
end

function WingView:WingShowView()
	--战斗力
	local fightLableHeadBg = createScale9SpriteWithFrameName(RES("ride_fade_sprite.png"))
	fightLableHeadBg:setScaleX(1.5)
	fightLableHeadBg:setOpacity(150)
	self:addChild(fightLableHeadBg,2)
	VisibleRect:relativePosition(fightLableHeadBg,self.Wing_bg,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE, ccp(170,20))
	
	self.fightLableHead = createSpriteWithFrameName(RES("ride_power.png"))
	self:addChild(self.fightLableHead,2)
	VisibleRect:relativePosition(self.fightLableHead,fightLableHeadBg,LAYOUT_CENTER)
	self.fightLable = createAtlasNumber(Config.AtlasImg.FightNumber,"")	--创建美术数字标签
	self.fightLable:setAnchorPoint(ccp(0, 0.5))
	self.fightLableHead:addChild(self.fightLable,2)
	VisibleRect:relativePosition(self.fightLable,self.fightLableHead,LAYOUT_CENTER, ccp(0,0))
	
	--人物模型
	if (self.heroModelView == nil) then
		self.heroModelView = HeroModelView.New()
		self.heroModelView:getRootNode():setAnchorPoint(ccp(0.5, 0.5))
		self.Wing_bg:addChild(self.heroModelView:getRootNode(),2)
		local size = self.heroModelView:getRootNode():getContentSize()
		local sex = PropertyDictionary:get_gender(G_getHero():getPT())
		if sex==1 then --男
			VisibleRect:relativePosition(self.heroModelView:getRootNode(), self.Wing_bg, LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE, ccp(-110,-size.height/2 + 215*scale))
		else
			VisibleRect:relativePosition(self.heroModelView:getRootNode(), self.Wing_bg, LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE, ccp(-110,-size.height/2 + 215*scale))
		end
		
	else
		self.heroModelView:removeAllEquip()
	end
	
	--翅膀等级标签
	self.WingGradeLabel = createStyleTextLable("","Stairs")	--创建美术数字标签
	self.WingGradeLabel:setAnchorPoint(ccp(0, 1))
	VisibleRect:relativePosition(self.WingGradeLabel, self.Wing_bg, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(110,-15))
	self:addChild(self.WingGradeLabel,3)
	self.WingGradeLabel1 = createStyleTextLable(Config.Words[1025],"Stairs")	--创建美术数字标签
	self.WingGradeLabel1:setAnchorPoint(ccp(0, 1))
	VisibleRect:relativePosition(self.WingGradeLabel1,self.WingGradeLabel, LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(9,-18))
	self:addChild(self.WingGradeLabel1, 3)
end

function WingView:updateWingModle()
	self.heroModelView:removeWing()
	local refId = wingMgr:getWingRefId()
	if string.isLegal(refId) then
		self.heroModelView:setWing(refId)
	end
	
end

function WingView:UpdateWing(isLevelUp,upgradedWingId)
	UIManager.Instance:hideLoadingHUD()
	if isLevelUp ==1 then
		self.selectedCell = tonumber( string.match(upgradedWingId,"%a+_(%d+)"))
		self.WingTable:scroll2Cell(self.selectedCell-1 , true)  --滚动到当前icon
		self:updateView(upgradedWingId)
		local msg = {[1] = {word = Config.Words[719], color = Config.FontColor["ColorBlue2"]}}
		UIManager.Instance:showSystemTips(msg)
		GlobalEventSystem:Fire(GameEvent.EventUpdateWing)
	else
		--升级失败
		--UIManager.Instance:showMsgBox(Config.Words[713],self,TipsHandlefunc,CCSizeMake(400,200
		local msg = showMsgBox(Config.Words[713],E_MSG_BT_ID.ID_OKAndCANCEL)
	end
end

function WingView:UpdateController()
	--材料标签
	self.materialLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[706], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.Wing_bg:addChild(self.materialLabelHead)
	VisibleRect:relativePosition(self.materialLabelHead, self.Wing_bg, LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(14,40))
	
	--每次消耗羽毛数量标签
	self.featherNumberLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	self.featherNumberLabel:setAnchorPoint(ccp(0,0.5))
	self.materialLabelHead:addChild(self.featherNumberLabel)
	VisibleRect:relativePosition(self.featherNumberLabel,self.materialLabelHead,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER)
	
	--羽毛数量标签
	self.ExpItemLabelHead = createLabelWithStringFontSizeColorAndDimension(Config.Words[726], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.Wing_bg:addChild(self.ExpItemLabelHead)
	VisibleRect:relativePosition(self.ExpItemLabelHead,self.materialLabelHead, LAYOUT_BOTTOM_OUTSIDE  + LAYOUT_LEFT_INSIDE)
	
	self.ExpItemLabel = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	self.ExpItemLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.ExpItemLabel,self.ExpItemLabelHead,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y)
	self.Wing_bg:addChild(self.ExpItemLabel)
	
	--开始提升按钮/自动提升按钮
	self.ImproveBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.AutoImproveBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.ImproveLabel = createSpriteWithFrameName(RES("word_button_promotedonce.png"))
	local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
	
	self:addChild(self.ImproveBtn)
	self:addChild(self.AutoImproveBtn)
	
	VisibleRect:relativePosition(self.ImproveBtn,self.Wing_bg,  LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-360,30))
	VisibleRect:relativePosition(self.AutoImproveBtn,self.Wing_bg,  LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-210,30))
	
	self.ImproveBtn:setTitleString(self.ImproveLabel)
	self.AutoImproveBtn:setTitleString(AutoImproveLabel)
	
	local ImproveBtnFunc = function()
		if self.refId == nil then
			return false
		end
		--self.aniSpr:stopAllActions()
		local needNum = wingMgr:getFeedNeedNum(self.refId)
		if(self:getExpItem() >= needNum ) then
			if  self.refId ~= "wing_" .. self.maxNum .. "_3" then
				wingMgr:requestUpGradeWing("item_chibangExp",needNum)
			else
				--已满级
				UIManager.Instance:showSystemTips(Config.Words[714])
			end
			self.needTips = true
		else
			local mObj = G_IsCanBuyInShop("item_chibangExp")
			if(mObj ~=  nil) then
				local buyNum = self.ItemNum - self:getFeatherItem()
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,buyNum)
			else				
				UIManager.Instance:showSystemTips(Config.Words[710])				
			end
		end
	end
	local AutoImproveBtnFunc = function()
		self:clickAutoImproveBtn()
		local needNum =  wingMgr:getFeedNeedNum(self.refId)
		if(self:getExpItem() >= needNum ) then
			if self.refId ~= "wing_" .. self.maxNum .. "_3"  then
				if(self.isAutoUpGrade == true) then
					local AutoImproveLabel = createSpriteWithFrameName(RES("word_button_aotupromote.png"))
					self.AutoImproveBtn:setTitleString(AutoImproveLabel)
					self.isAutoUpGrade = false
					if self.endExp and self.endMaxExp then
						self:updateView(self.endRefId)
						self:setProcessBar(self.endExp ,self.endMaxExp)
					end
					return
				else
					local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_cancel.png"))
					self.AutoImproveBtn:setTitleString(AutoImproveLabel)
					wingMgr:requestUpGradeWing("item_chibangExp",needNum)
					self.isAutoUpGrade = true
				end
				self.needTips = true
			else
				UIManager.Instance:showSystemTips(Config.Words[714])
			end
		else
			local mObj = G_IsCanBuyInShop("item_chibangExp")
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,needNum - self:getExpItem())
			else
				UIManager.Instance:showSystemTips(Config.Words[710])	
			end
		end
		--UIManager.Instance:showMsgBox(Config.Words[710],self,TipsHandlefunc,CCSizeMake(400,200))
	end
	self.ImproveBtn:addTargetWithActionForControlEvents(ImproveBtnFunc,CCControlEventTouchDown)

	self.AutoImproveBtn:addTargetWithActionForControlEvents(AutoImproveBtnFunc,CCControlEventTouchDown)
	--	self:showWingTips()
end
--[[
function WingView:showWingTips()
	--提示描述
	local refId = wingMgr:getWingRefId()
	if refId then	--TODO
		local wingLevel = wingMgr:getWingLevelById(refId)  --当前翅膀等级
		if wingLevel < 3 then
			if not self.tips then
				self.tips = createLabelWithStringFontSizeColorAndDimension(Config.Words[724], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
				self.Wing_bg:addChild(self.tips)
				VisibleRect:relativePosition(self.tips,self.ImproveBtn,LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER,ccp(0,3))
			end
		else
			if self.tips then
				self.tips:setVisible(false)
			end
		end
	end
end--]]

function WingView:createNodeItem(headName, color, showTip)
	local node = CCNode:create()
	node:setContentSize(nodeSize)
	local Head = createLabelWithStringFontSizeColorAndDimension(headName, "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	node:addChild(Head)
	VisibleRect:relativePosition(Head,node,LAYOUT_LEFT_INSIDE,ccp(16,0) )
	
	local valueNode = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3"), FCOLOR("ColorWhite2"))
	valueNode:setAnchorPoint(ccp(0,0.5))
	Head:addChild(valueNode)
	VisibleRect:relativePosition(valueNode, Head, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)
	if color then
		valueNode:setColor(color)
	end
	if showTip then
		local tip = createSpriteWithFrameName(RES("bagBatch_up_tip.png"))
		node:addChild(tip)
		VisibleRect:relativePosition(tip, Head, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(90, 0))
	end
	return node, valueNode
end

function WingView:createCurProperty(bgNode)
	--属性标题
	self.propertyDescBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(192,33))
	bgNode:addChild(self.propertyDescBg)
	VisibleRect:relativePosition(self.propertyDescBg, bgNode, LAYOUT_CENTER+LAYOUT_TOP_INSIDE, ccp(0,-5))
	self.propertyDescLabel = createSpriteWithFrameName(RES("talisman_curStepsProperty.png"))
	self.propertyDescBg:addChild(self.propertyDescLabel)
	VisibleRect:relativePosition(self.propertyDescLabel,self.propertyDescBg,LAYOUT_CENTER)
	--滚动
	if (self.scrollView) then
		bgNode:removeChild(self.scrollView, true)
	end
	self.scrollView = createScrollViewWithSize(viewSize)
	self.scrollView:setDirection(2)
	bgNode:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, bgNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-35))
	
	--物理攻击
	local physical_AttackLabel_node
	physical_AttackLabel_node, self.LW_AttackLabel = self:createNodeItem(Config.Words[701])
	--魔法攻击
	local magic_AttackLabel_node
	magic_AttackLabel_node, self.LM_AttackLabel = self:createNodeItem(Config.Words[702])
	--道术攻击
	local daoShu_AttackLabel_node
	daoShu_AttackLabel_node, self.LD_AttackLabel = self:createNodeItem(Config.Words[703])
	--物理防御
	local physi_DefenceLabel_node
	physi_DefenceLabel_node, self.LW_DefenceLabel = self:createNodeItem(Config.Words[704])
	--魔法防御
	local magic_DefenceLabel_node
	magic_DefenceLabel_node, self.LM_DefenceLabel = self:createNodeItem(Config.Words[705])
	
	self.scrollNodes = {}
	table.insert(self.scrollNodes,physical_AttackLabel_node)
	table.insert(self.scrollNodes,magic_AttackLabel_node)
	table.insert(self.scrollNodes,daoShu_AttackLabel_node)
	table.insert(self.scrollNodes,physi_DefenceLabel_node)
	table.insert(self.scrollNodes,magic_DefenceLabel_node)
	local container= CCNode:create()
	G_layoutContainerNode(container,self.scrollNodes,10,E_DirectionMode.Vertical,viewSize,true)
	self.scrollView:setContainer(container)
	self.scrollView:updateInset()
	self.scrollView:setContentOffset(ccp(0,-container:getContentSize().height + viewSize.height), false)
end

function WingView:createNextProperty(bgNode)
	--属性标题
	self.propertyDescBg2 = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(192,33))
	bgNode:addChild(self.propertyDescBg2)
	VisibleRect:relativePosition(self.propertyDescBg2,bgNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-190))
	self.propertyDescLabel2 = createSpriteWithFrameName(RES("talisman_nextLevelProperty.png"))
	self.propertyDescBg2:addChild(self.propertyDescLabel2)
	VisibleRect:relativePosition(self.propertyDescLabel2,self.propertyDescBg2,LAYOUT_CENTER)
	
	--滚动
	if (self.scrollView2) then
		bgNode:removeChild(self.scrollView2, true)
	end
	self.scrollView2 = createScrollViewWithSize(viewSize)
	self.scrollView2:setDirection(2)
	bgNode:addChild(self.scrollView2)
	VisibleRect:relativePosition(self.scrollView2, bgNode, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-220))
	
	local wordColor = FCOLOR("Yellow1")
	local valueColor = FCOLOR("ColorGreen1")
	--物理攻击
	local physical_AttackLabel_node
	physical_AttackLabel_node, self.LW_AttackLabel2 = self:createNodeItem(Config.Words[701], valueColor, true)
	--魔法攻击
	local magic_AttackLabel_node
	magic_AttackLabel_node, self.LM_AttackLabel2 = self:createNodeItem(Config.Words[702], valueColor, true)
	--道术攻击
	local daoShu_AttackLabel_node
	daoShu_AttackLabel_node, self.LD_AttackLabel2 = self:createNodeItem(Config.Words[703], valueColor, true)
	--物理防御
	local physi_DefenceLabel_node
	physi_DefenceLabel_node, self.LW_DefenceLabel2 = self:createNodeItem(Config.Words[704], valueColor, true)
	--魔法防御
	local magic_DefenceLabel_node
	magic_DefenceLabel_node, self.LM_DefenceLabel2 = self:createNodeItem(Config.Words[705], valueColor, true)
	
	self.scrollNodes = {}
	table.insert(self.scrollNodes,physical_AttackLabel_node)
	table.insert(self.scrollNodes,magic_AttackLabel_node)
	table.insert(self.scrollNodes,daoShu_AttackLabel_node)
	table.insert(self.scrollNodes,physi_DefenceLabel_node)
	table.insert(self.scrollNodes,magic_DefenceLabel_node)
	local container= CCNode:create()
	G_layoutContainerNode(container,self.scrollNodes,10,E_DirectionMode.Vertical,viewSize,true)
	self.scrollView2:setContainer(container)
	self.scrollView2:updateInset()
	self.scrollView2:setContentOffset(ccp(0,-container:getContentSize().height + viewSize.height), false)
end



function WingView:showWingUpGradeAni(isLevelUp,refId,Exp)
	if( self.refId == refId  and Exp == 0) then
		return
	else
		self.endRefId = refId
		self.endExp = Exp
		local endRecord = WingObject:getStaticData(self.endRefId)
		if endRecord then
			self.endMaxExp = PropertyDictionary:get_maxExp(endRecord)
		end
		local function sendFeedRequest()
			local needNum =  wingMgr:getFeedNeedNum(self.refId)
			if self:getExpItem() >= needNum  then
				wingMgr:requestUpGradeWing("item_chibangExp",needNum)
			else
				local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_aotupromote.png"))
				self.AutoImproveBtn:setTitleString(AutoImproveLabel)
				self.isAutoUpGrade = false
			end
		end
			
		local function UpdateExp(sender)
			if self.refId ~= "wing_" .. self.maxNum .. "_3" then
				if self.refId ~= self.endRefId  or  self.curExp < self.endExp  then
					local record = WingObject:getStaticData(self.refId)
					if record then
						local maxExp = PropertyDictionary:get_maxExp(record)
						if(self.curExp < maxExp) then
							self.curExp = self.curExp +1
							self:setProcessBar(self.curExp , maxExp)
						else
							self.refId = PropertyDictionary:get_wingNextRefId(record)
							self:updateView(self.refId)
							local record = WingObject:getStaticData(self.refId)
							if record then
								self.curExp = 0
								local maxExp = PropertyDictionary:get_maxExp(record)
								self:setProcessBar(0, maxExp)
								self:showLevelUp(tonumber(string.match(self.refId,"%a+_%d+_(%d+)")))
							end
						end
					end
				else
					self.aniSpr:stopAllActions()
					local record = WingObject:getStaticData(self.endRefId)
					if record then
						local maxExp = PropertyDictionary:get_maxExp(record)
						self:setProcessBar(Exp ,maxExp)
					end
					if self.isAutoUpGrade == false then
						local AutoImproveLabel =  createSpriteWithFrameName(RES("word_button_aotupromote.png"))
						self.AutoImproveBtn:setTitleString(AutoImproveLabel)
					elseif  self.isAutoUpGrade == true  and  self.refId ~= "wing_" .. self.maxNum .. "_3" then
						sendFeedRequest()
					end	
				end
			else
				self.cuRefId = "wing_" .. self.maxNum .. "_3"
				self:setProcessBar()
			end
		end
		local dt = 0.01
		local array = CCArray:create()
		array:addObject(CCCallFuncN:create(UpdateExp));
		array:addObject(CCDelayTime:create(dt));
		local action = CCSequence:create(array)
		local forever = CCRepeatForever:create(action)
		self.aniSpr:runAction(forever)
	end
end
--[[
self.Star1,self.starBg1 = self:createStar(-150,-50)
self.Star2,self.starBg2 = self:createStar(-100,-50)
self.Star3,self.starBg3 = self:createStar(-50,-50)
]]
function WingView:showLevelUp(level)
	if level and level > 0  then
		local aniSprite = createSpriteWithFrameName(RES("star0.png"))
		self.Wing_bg:addChild(aniSprite,5)
		aniSprite:setAnchorPoint(ccp(0,0))
		if level == 1 then
			VisibleRect:relativePosition(aniSprite,self.Wing_bg,LAYOUT_LEFT_INSIDE +LAYOUT_TOP_INSIDE,ccp(90,-20))
		elseif level == 2 then
			VisibleRect:relativePosition(aniSprite,self.Wing_bg,LAYOUT_LEFT_INSIDE +LAYOUT_TOP_INSIDE,ccp(140,-20))
		elseif level == 3 then
			VisibleRect:relativePosition(aniSprite,self.Wing_bg,LAYOUT_LEFT_INSIDE +LAYOUT_TOP_INSIDE,ccp(190,-20)	)
		end
		
		local removeSelf = function(sender)
			if aniSprite then
				aniSprite:removeFromParentAndCleanup(true)
				aniSprite = nil
			end
		end
		
		local animation = createAnimate("star",4,0.15)
		local array = CCArray:create()
		array:addObject(animation);
		array:addObject(CCCallFuncN:create(removeSelf))
		local sequence = CCSequence:create(array)
		aniSprite:runAction(sequence)
	end
end

function WingView:showBaoji(times)
	local label = nil
	if times == 2 then
		label = createSpriteWithFrameName(RES("mount_baoji_exp_2.png"))
	else
		label = createSpriteWithFrameName(RES("mount_baoji_exp_3.png"))
	end
	--local label =  createStyleTextLable(times .. Config.Words[1057],"RideExpTips")-- createLabelWithStringFontSizeColorAndDimension(Config.Words[1056] .. times .. Config.Words[1057] , "Arial", FSIZE("Size4"),FCOLOR("ColorYellow3"))
	VisibleRect:relativePosition(label,self:getContentNode(),LAYOUT_CENTER,ccp(-50,0))
	label:setTag(10)
	self:addChild(label,3)
	self.baojiTipsCount = self.baojiTipsCount + 1
	local removeSelf = function(sender)
		if label then
			label:removeFromParentAndCleanup(true)
			self.baojiTipsCount = self.baojiTipsCount - 1
		end
	end
	
	local moveTo = CCMoveTo:create(0.5,CCPoint(visibleSize.width*0.4,visibleSize.height*0.6))
	local array = CCArray:create()
	array:addObject(moveTo);
	array:addObject(CCCallFuncN:create(removeSelf))
	local sequence = CCSequence:create(array)
	label:runAction(sequence)
	
end

function  WingView:setStar(Num)
	if( Num == 0 ) then
	self.Star1:setVisible(false)
	self.Star2:setVisible(false)
	self.Star3:setVisible(false)
	elseif(Num == 1 ) then
	self.Star1:setVisible(true)
	self.Star2:setVisible(false)
	self.Star3:setVisible(false)
	elseif( Num == 2 ) then
	self.Star1:setVisible(true)
	self.Star2:setVisible(true)
	self.Star3:setVisible(false)
	elseif(Num ==3) then
	self.Star1:setVisible(true)
	self.Star2:setVisible(true)
	self.Star3:setVisible(true)
end
end

function WingView:setProcessBar(curentExp,MaxExp)
	if(self.cuRefId ~= "wing_" .. self.maxNum .. "_3") then
		self.expProcessbar:setPercentage(curentExp*100/MaxExp)
		self.expLabel:setString(curentExp .."/".. MaxExp)
	else		
		local preRefId = "wing_" .. self.maxNum .. "_2"
		local record = WingObject:getStaticData(preRefId)
		local maxExp = 0
		if record then
			maxExp = PropertyDictionary:get_maxExp(record)
		end						
		self.expLabel:setString(maxExp .. "/" .. maxExp)
		self.expProcessbar:setPercentage(100)	
	end
end

function WingView:getExpItem()
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	return bgmgr:getItemNumByRefId("item_chibangExp")
	
end

-----------------------------------------------------------
--新手指引

function WingView:getAutoImproveBtn()
	return self.AutoImproveBtn
end

function WingView:clickAutoImproveBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"WingView","AutoImproveBtn")
end	
-----------------------------------------------------------