-- 显示法宝详情 
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("ui.utils.ItemView")
require("ui.utils.MessageBox")
require("gameevent.GameEvent")
require("object.Talisman.TalismanDef")
require("object.forging.ForgingDef")
require("object.mall.MallDef")

TalismanView = TalismanView or BaseClass(BaseUI)

local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local width = 880
local height = 550
local cellSize = VisibleRect:getScaleSize(CCSizeMake(204,108))
local grideSize = VisibleRect:getScaleSize(CCSizeMake(80,80))
local CELL_TAG = 100
local ExpNum = 0

local attributeList = {
	[1] = {name = Config.Words[7538], attributeName = "talisManLevel", node = nil},
	[2] = {name = Config.Words[7539], attributeName = "PAtk", node = nil},
	[3] = {name = Config.Words[7540], attributeName = "MAtk", node = nil},
	[4] = {name = Config.Words[7541], attributeName = "Tao", node = nil},
	[5] = {name = Config.Words[7542], attributeName = "PDef", node = nil},
	[6] = {name = Config.Words[7543], attributeName = "MDef", node = nil},
}

local awardList = {
	[1] = {name = Config.Words[7523], node = nil},
	[2] = {name = Config.Words[7524], node = nil},
	[3] = {name = Config.Words[7525], node = nil},
	[4] = {name = Config.Words[7526], node = nil},
}

function TalismanView:__init()
	UIManager.Instance:registerUI("MessageBox",MessageBox.create)
	self.viewName = "TalismanView"
	self:initFullScreen()		
	self.eventType = {}	-- tableview的数据类型	
--	self.taliList = {}
	self.selectTalism = 1
	self:initVariable()
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()	
	if table.size(taliList) > 0 then	
		self:initView()	
	end		
end

function TalismanView:onEnter()
	self:updateDetailsView()
	self:updateAwardView()
	self:updateLeftView()
	self:updateMiddleView()
end

function TalismanView:create()
	return TalismanView.New()
end

function TalismanView:initVariable()
	--tableview数据源的类型
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	self.cellFrame = createScale9SpriteWithFrameName(RES("mall_goodsframe_selected.png"))
	self.cellFrame:retain()	
	self.activeSprite = createSpriteWithFrameName(RES("talisman_activation.png"))
	self.activeSprite:setRotation(-30)
	self.activeSprite:retain()
	self.clickFlag = true
	self.costItemNum = 0		
end	

--初始化界面
function TalismanView:initView()

	--顶部标题
	self:setFormImage( createSpriteWithFrameName(RES("main_artifact.png")))
	self:setFormTitle( createSpriteWithFrameName(RES("word_window_magic_weapon.png")),TitleAlign.Left)	

	local tableViewBgSprite =  createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),self:getContentNode():getContentSize())
	self:addChild(tableViewBgSprite)	
	VisibleRect:relativePosition(tableViewBgSprite, self:getContentNode(), LAYOUT_CENTER)
		
	--左边背景框
	self.tableBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(196,471))
	self:addChild(self.tableBg)	
	VisibleRect:relativePosition(self.tableBg,self:getContentNode(),LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(6,-12))	

	
	
	--中间背景框
	self.centelViewBgSprite = createScale9SpriteWithFrameNameAndSize(RES("squares_bg3.png"),CCSizeMake(614,471))
	self:addChild(self.centelViewBgSprite)	
	VisibleRect:relativePosition(self.centelViewBgSprite,self.tableBg,LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(9, 0))	
		
	
	--右边背景框
	self.rightUpBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"),CCSizeMake(235,197))	
	self.rightUpBg:setOpacity(200)
	VisibleRect:relativePosition(self.rightUpBg,self.centelViewBgSprite,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-10,-15))	
	self:addChild(self.rightUpBg)
	
	self.rightMidBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"),CCSizeMake(235,80))	
	self.rightMidBg:setOpacity(200)
	VisibleRect:relativePosition(self.rightMidBg,self.rightUpBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE,ccp(0,-10))	
	self:addChild(self.rightMidBg)
	
	self.rightDownBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"),CCSizeMake(235,165))
	self.rightDownBg:setOpacity(200)
	self:addChild(self.rightDownBg)	
	VisibleRect:relativePosition(self.rightDownBg,self.rightMidBg,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_RIGHT_INSIDE,ccp(0,-10))	
		
	self.eventLayer = CCLayer:create()
	self.rightDownBg:addChild(self.eventLayer)
	VisibleRect:relativePosition(self.eventLayer,self.rightDownBg,LAYOUT_CENTER)

	self:createBottomNode()	
	self:createGetTalismNode()

	self:initLeftView()
	self:initMiddleView()
	self:initRightView()	
end

--初始化左边界面
function TalismanView:initLeftView()
	local passiveLable = createScale9SpriteWithFrameName(RES("passiveTalismanText.png"))
	self:addChild(passiveLable)
	VisibleRect:relativePosition(passiveLable,self.tableBg,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(7,-5))
	
	local activeLable = createScale9SpriteWithFrameName(RES("activeTalismanText.png"))
	self:addChild(activeLable)
	VisibleRect:relativePosition(activeLable,self.tableBg,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-7,-5))
	
	self:createTalisTable()	
end

--初始化中部界面
function TalismanView:initMiddleView()
	local talisBg = CCSprite:create("ui/ui_img/common/talismanBg.pvr")
	self.centelViewBgSprite:addChild(talisBg)
	VisibleRect:relativePosition(talisBg,self.centelViewBgSprite,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(2,-2))
	
	--test
--[[	local getBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	talisBg:addChild(getBtn)	
	VisibleRect:relativePosition(getBtn,talisBg,  LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE)	
	local getBtnFunc = function()	
		local artiMgr =	GameWorld.Instance:getTalismanManager()	
		local list = artiMgr:getTalismanList()
		list[6]:setState(Talisman_State.NotAchieve)	
		list[8]:setState(Talisman_State.Activate)
	end		
	getBtn:addTargetWithActionForControlEvents(getBtnFunc,CCControlEventTouchDown)--]]	
	--test

	self.talismPicSprite = CCSprite:create()
	self.centelViewBgSprite:addChild(self.talismPicSprite)
	VisibleRect:relativePosition(self.talismPicSprite, self.centelViewBgSprite, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(40,0))	
	
	self.nameBg = createSpriteWithFrameName(RES("frontNameBg.png"))
	self.centelViewBgSprite:addChild(self.nameBg)
	VisibleRect:relativePosition(self.nameBg,self.centelViewBgSprite,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(265,-20))

	local curActivateEffectHeadLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[7536], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.centelViewBgSprite:addChild(curActivateEffectHeadLable)
	VisibleRect:relativePosition(curActivateEffectHeadLable,self.centelViewBgSprite,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,-20))

	self.curActivateEffectLable = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"),CCSizeMake(235,50))	
	self.curActivateEffectLable:setAnchorPoint(ccp(0,1))
	curActivateEffectHeadLable:addChild(self.curActivateEffectLable)	
	VisibleRect:relativePosition(self.curActivateEffectLable,curActivateEffectHeadLable,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(30,0))
	
	local nextActivateEffectHeadLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[7537], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	curActivateEffectHeadLable:addChild(nextActivateEffectHeadLable)
	VisibleRect:relativePosition(nextActivateEffectHeadLable,curActivateEffectHeadLable,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(0,-45))

	self.nextActivateEffectLable = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorGreen1"),CCSizeMake(235,50))	
	self.nextActivateEffectLable:setAnchorPoint(ccp(0,1))
	nextActivateEffectHeadLable:addChild(self.nextActivateEffectLable)	
	VisibleRect:relativePosition(self.nextActivateEffectLable,nextActivateEffectHeadLable,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE,ccp(30,0))
	
	local tipLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[7533], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow1"))
	self:addChild(tipLable)
	VisibleRect:relativePosition(tipLable,self.centelViewBgSprite,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(25,10))
	
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()	
	local taliObj = taliList[self.selectTalism]
	if taliObj then
		local refID = taliObj:getRefId()
		self:showNameSprite(refID)
		self:setTalismPic(refID)
		self:setEffectText()
		self:updateMiddleView()
	end
end

--初始化右边界面
function TalismanView:initRightView()
	--初始化上部界面
	self.fightPowerLableHead = createScale9SpriteWithFrameName(RES("talisman_fightingPromote.png"))
	VisibleRect:relativePosition(self.fightPowerLableHead ,self.rightUpBg,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(10,6))
	self:addChild(self.fightPowerLableHead )			
	self.fightPowerLable = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow1"))
	self.fightPowerLable:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.fightPowerLable,self.fightPowerLableHead ,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))
	self:addChild(self.fightPowerLable)
	
	local scrollView = createScrollViewWithSize(CCSizeMake(140,165))	
	scrollView:setDirection(2)
	self.rightUpBg:addChild(scrollView)
	VisibleRect:relativePosition(scrollView,self.rightUpBg,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(5,-15))	
	local attributeDetailNode = CCNode:create()		
	attributeDetailNode:setContentSize(CCSizeMake(140,165))
	scrollView:setContainer(attributeDetailNode)
	
	local attributeListLen = table.getn(attributeList)
	for i = 1,attributeListLen do
		local attributeNameLable = createLabelWithStringFontSizeColorAndDimension(attributeList[i].name, "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
		attributeDetailNode:addChild(attributeNameLable)
		VisibleRect:relativePosition(attributeNameLable,attributeDetailNode ,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(0,-25*(i-1)))
		attributeList[i].node = createLabelWithStringFontSizeColorAndDimension("-", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
		attributeList[i].node:setAnchorPoint(ccp(0,0.5))
		attributeNameLable:addChild(attributeList[i].node)
		VisibleRect:relativePosition(attributeList[i].node,attributeNameLable ,LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(0,0))
	end
	
	local itemBoxShow = G_createItemShowByItemBox("item_shenqiExp",nil,nil,nil,"mall_goodsframe.png",-1)
	self.rightUpBg:addChild(itemBoxShow)
	VisibleRect:relativePosition(itemBoxShow,self.rightUpBg, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-10,-6))
	
	self.itemNeedLable = createLabelWithStringFontSizeColorAndDimension("---", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	itemBoxShow:addChild(self.itemNeedLable)
	VisibleRect:relativePosition(self.itemNeedLable,itemBoxShow ,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER,ccp(0,0))
	
	self.ImproveBtn = createButtonWithFramename(RES("chat_nomal_btn.png"), RES("chat_nomal_btn.png"))
	self.ImproveBtn:setScaleDef(0.8)
	self.rightUpBg:addChild(self.ImproveBtn)	
	VisibleRect:relativePosition(self.ImproveBtn,self.rightUpBg,  LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(0,27))
	local ImproveLabel = createSpriteWithFrameName(RES("improveBtnText.png"))
	self.ImproveBtn:setTitleString(ImproveLabel)	
	local ImproveBtnFunc = function()
		local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
		local hadItemCnt = bgmgr:getItemNumByRefId("item_shenqiExp")
		local talismgr = GameWorld.Instance:getTalismanManager()	
		local level = talismgr:getCittaLevel()	
		local needItemCnt = GetUseMaterialCountByRefId(level)
		if (needItemCnt  > hadItemCnt )	then
			local mObj = G_IsCanBuyInShop("item_shenqiExp")
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj, needItemCnt - hadItemCnt)
			else
				UIManager.Instance:showSystemTips(Config.Words[7507])
			end
		else
			local artiMgr =	GameWorld.Instance:getTalismanManager()
			artiMgr:requestCittaLevelUp()
		end
	end
	self.ImproveBtn:addTargetWithActionForControlEvents(ImproveBtnFunc,CCControlEventTouchDown)
	
	--初始化中部界面
	local activeTilesmanLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[7534], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.rightMidBg:addChild(activeTilesmanLable)
	VisibleRect:relativePosition(activeTilesmanLable,self.rightMidBg ,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(5,-7))
	
	self.activeTilesmanName = createLabelWithStringFontSizeColorAndDimension("-", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"))
	self.activeTilesmanName:setAnchorPoint(ccp(0,0.5))
	activeTilesmanLable:addChild(self.activeTilesmanName)
	VisibleRect:relativePosition(self.activeTilesmanName,activeTilesmanLable ,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER,ccp(5,0))

	self.tilesmanData = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorWhite2"), CCSizeMake(220, 0))
	self.tilesmanData:setAnchorPoint(ccp(0,1))
	self.rightMidBg:addChild(self.tilesmanData)
	VisibleRect:relativePosition(self.tilesmanData, self.rightMidBg, LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(5,-50))	
	--初始化下部界面
	local touchArea = CCSizeMake(250,165)
	local function ccTouchHandler(eventType, x, y)
		local point = self.rightDownBg:getParent():convertToNodeSpace(ccp(x,y))
		local rect = self.rightDownBg:boundingBox()
		if rect:containsPoint(point) then
			if eventType == "began" then
				local artiMgr =	GameWorld.Instance:getTalismanManager()
				artiMgr:requestTalismanReward()
			end
		end
		return 0
	end
	
	self.eventLayer:setTouchEnabled(true)
	self.eventLayer:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
	
	local topTitileBg = createScale9SpriteWithFrameNameAndSize(RES("player_nameBg.png"),CCSizeMake(235,40))
	self.rightDownBg:addChild(topTitileBg)
	VisibleRect:relativePosition(topTitileBg,self.rightDownBg,LAYOUT_TOP_INSIDE + LAYOUT_CENTER,ccp(0,-2))
		
	local topTitleWord = createScale9SpriteWithFrameName(RES("talisAwardText.png"))
	topTitileBg:addChild(topTitleWord)
	VisibleRect:relativePosition(topTitleWord,topTitileBg,LAYOUT_CENTER)
	
	local awardListLen = table.getn(awardList)
	for i = 1,awardListLen do
		local awardNameLable = createLabelWithStringFontSizeColorAndDimension(awardList[i].name, "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
		self.rightDownBg:addChild(awardNameLable)
		VisibleRect:relativePosition(awardNameLable,self.rightDownBg ,LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE,ccp(5,-45-25*(i-1)))	
		
		awardList[i].node = createRichLabel(CCSizeMake(160,0))
		awardList[i].node:setAnchorPoint(ccp(0,0.5))
		awardList[i].node:clearAll()
		awardNameLable:addChild(awardList[i].node)
		VisibleRect:relativePosition(awardList[i].node,awardNameLable ,LAYOUT_RIGHT_OUTSIDE + LAYOUT_TOP_INSIDE,ccp(0,-10))
	end
	self:updateDetailsView()
	self:updateInfoView()
	local artiMgr =	GameWorld.Instance:getTalismanManager()
	artiMgr:requestTalismanGetReward()

	self.framesprite = CCSprite:create()
	self.framesprite:setAnchorPoint(ccp(0.5,0.5))
	self.framesprite:setScaleX(235/185)
	self.framesprite:setScaleY(165/65)
	self.rightDownBg:addChild(self.framesprite)
	VisibleRect:relativePosition(self.framesprite,self.rightDownBg,LAYOUT_CENTER,ccp(-8,13))
end

function TalismanView:handMaxLevel(state)
	self.fightPowerLable:setVisible(state)
	self.fightPowerLableHead:setVisible(state)
end	


function TalismanView:createItem(index)
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()	
	local taliObj = taliList[index]		
	local itemNode = CCNode:create()	
	itemNode:setContentSize(grideSize)
	
	local itemBg =createScale9SpriteWithFrameName(RES("mall_goodsframe.png"))		
	itemNode:addChild(itemBg)	
	VisibleRect:relativePosition(itemBg,itemNode, LAYOUT_CENTER)	
	
	if taliObj then
		local icon = createSpriteWithFileName(ICON(taliObj:getRefId()))	
		icon:setScale(0.85)
		itemNode:addChild(icon)
		VisibleRect:relativePosition(icon,itemNode,LAYOUT_CENTER)
		
		local mgr = GameWorld.Instance:getTalismanManager()			
		if taliObj:getState() == Talisman_State.NotAchieve then
			UIControl:SpriteSetGray(icon)
		elseif taliObj:getState() == Talisman_State.NotActivate then
		elseif taliObj:getState() == Talisman_State.Activate then
			local index = taliObj:getIndex()/2
			if math.ceil(index) == index then
				if self.activeSprite:getParent() then
					self.activeSprite:removeFromParentAndCleanup(true)					
				end 
				VisibleRect:relativePosition(self.activeSprite, itemNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE ,ccp(10,0))
				itemNode:addChild(self.activeSprite)
			end
		end	
	end
	
	if index == self.selectTalism then
		if self.cellFrame:getParent() then
			self.cellFrame:removeFromParentAndCleanup(true)	
		end			
		itemNode:addChild(self.cellFrame)					
		VisibleRect:relativePosition(self.cellFrame, itemNode, LAYOUT_CENTER)
	end		
		
	return itemNode
end

function TalismanView:createTalisCell(index)
	local item = CCNode:create()
	item:setContentSize(cellSize)	
	--line
	local lineSprite = createSpriteWithFrameName(RES("knight_line.png"))
	VisibleRect:relativePosition(lineSprite,item,LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X,ccp(0,5))			
	item:addChild(lineSprite) 
	
	local node1 = self:createItem(2*index+1)
	node1:setTag(1)
	item:addChild(node1)
	VisibleRect:relativePosition(node1, item, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(12,-9))

	local node2 = self:createItem(2*(index +1))
	item:addChild(node2)
	node2:setTag(2)
	VisibleRect:relativePosition(node2, item, LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-12,-9))	
	item:setTag(CELL_TAG)
				
	return item		
end

function TalismanView:createTalisTable()
		
	local tableDelegate = function (tableP,cell,x,y)
		tableP = tolua.cast(tableP,"SFTableView")
		cell = tolua.cast(cell,"SFTableViewCell")		
		local index  = cell:getIndex()
		local item = cell:getChildByTag(CELL_TAG)	
		local count = 2
		local touchPoint = ccp(x,y)		
		local childItem, rect	
		for i = 1, count do 
			childItem = item:getChildByTag(i)		
			rect = childItem:boundingBox()
			if rect:containsPoint(touchPoint) then 	
				--选中框
				if self.cellFrame:getParent() then				
					self.cellFrame:removeFromParentAndCleanup(true)	
				end
				childItem:addChild(self.cellFrame)					
				VisibleRect:relativePosition(self.cellFrame, childItem, LAYOUT_CENTER)

				self.selectTalism = 2*index + i
				local mgr = GameWorld.Instance:getTalismanManager()
				local taliList = mgr:getTalismanList()	
				local taliObj = taliList[self.selectTalism]					
				if taliObj then
					if taliObj:getState() == Talisman_State.NotAchieve then	
						self:showGetTalismNode()
					elseif taliObj:getState() == Talisman_State.NotActivate then	
						self:showBottomNode()
					elseif taliObj:getState() == Talisman_State.Activate then	
						self:showBottomNode()
					end	
					
					local mgr = GameWorld.Instance:getTalismanManager()	
					local level = mgr:getCittaLevel()
					local refID = taliObj:getRefId()
					self:showNameSprite(refID)
					self:setTalismPic(refID)
					self:setEffectText()
				end								
			end
		end			
		return 1								
	end	
	function dataHandler(eventType,tableP,index,data)
		data = tolua.cast(data,"SFTableData")
		tableP = tolua.cast(tableP, "SFTableView")
		
		if eventType == self.eventType.kTableCellSizeForIndex then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kCellSizeForTable then
			data:setSize(VisibleRect:getScaleSize(cellSize))
			return 1
		elseif eventType == self.eventType.kTableCellAtIndex then
			local tableCell = tableP:dequeueCell(index)		
			if tableCell == nil then
				tableCell = SFTableViewCell:create()
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createTalisCell(index)
				tableCell:addChild(item)
				data:setCell(tableCell)
			else
				tableCell:removeAllChildrenWithCleanup(true)
				tableCell:setContentSize(VisibleRect:getScaleSize(cellSize))
				local item = self:createTalisCell(index)				
				tableCell:addChild(item)
				data:setCell(tableCell)
			end
			tableCell:setIndex(index)																				
			return 1
		elseif eventType == self.eventType.kNumberOfCellsInTableView then
			data:setIndex(5)
			return 1
		end
	end			

	--创建tableview
	self.talisTable = createTableView(dataHandler,VisibleRect:getScaleSize(CCSizeMake(204,430)))
	self.talisTable:reloadData()
	self.talisTable:setTableViewHandler(tableDelegate)
	self.talisTable:setContentOffset(ccp(0,-110))
	self.talisTable:scroll2Cell(0, false)  --回滚到第一个cell
	self:addChild(self.talisTable)		
	VisibleRect:relativePosition(self.talisTable,self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(0, -45))	
end	


function TalismanView:showGetTalismNode()
	self.bottomNode:setVisible(false)
	self.getTalismNode:setVisible(true)
	self:setGetCondition()	
end

function TalismanView:showBottomNode()
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()
	local taliObj = taliList[self.selectTalism]
	self.getTalismNode:setVisible(false)
	local index = taliObj:getIndex()/2
	if math.ceil(index) == index then
		self.bottomNode:setVisible(true)
		if taliObj:getState() == Talisman_State.Activate then
			self.cancleActivateLabel:setVisible(true)
			self.activateLabel:setVisible(false)
		elseif taliObj:getState() == Talisman_State.NotActivate then
			self.cancleActivateLabel:setVisible(false)
			self.activateLabel:setVisible(true)
		end
	else
		self.bottomNode:setVisible(false)
	end
end

function TalismanView:createGetTalismNode()
	self.getTalismNode = CCNode:create()
	self.getTalismNode:setContentSize(CCSizeMake(550,115))
	self:addChild(self.getTalismNode)
	VisibleRect:relativePosition(self.getTalismNode,self:getContentNode(),LAYOUT_BOTTOM_INSIDE+ LAYOUT_RIGHT_INSIDE,ccp(-280,35))	
	
	--获取条件
	local getCondition = createLabelWithStringFontSizeColorAndDimension(Config.Words[7504], "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))--createSpriteWithFrameName(RES("word_label_upgradeneed.png"))
	VisibleRect:relativePosition(getCondition,self.centelViewBgSprite,LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE,ccp(10,90))
	self.getTalismNode:addChild(getCondition)	
			
	--当前拥有碎片数量
	self.ownNumLable = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))	
	self.ownNumLable:setAnchorPoint(ccp(0,0.5))	
	self.getTalismNode:addChild(self.ownNumLable)
	VisibleRect:relativePosition(self.ownNumLable, getCondition,LAYOUT_LEFT_INSIDE)	
	VisibleRect:relativePosition(self.ownNumLable, getCondition,LAYOUT_BOTTOM_OUTSIDE,ccp(0,-7))	

	self.suiPianOwnLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorRed1"))
	self.suiPianOwnLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.suiPianOwnLabel,self.ownNumLable,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))
	self.getTalismNode:addChild(self.suiPianOwnLabel)
	
	self.needSuiPianNumLable = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3"), FCOLOR("ColorYellow2"))
	self.getTalismNode:addChild(self.needSuiPianNumLable)
	self.needSuiPianNumLable:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.needSuiPianNumLable, self.suiPianOwnLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
	
	--万能碎片数量
	self.wanSuiPianOwnLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.wanSuiPianOwnLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.wanSuiPianOwnLabel,self.ownNumLable,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-7))
	self.getTalismNode:addChild(self.wanSuiPianOwnLabel)
	
	--条件描叙
	self.requrieMentLabel = createLabelWithStringFontSizeColorAndDimension(" ","Arial", FSIZE("Size3")*scale, FCOLOR("ColorYellow2"))
	self.requrieMentLabel:setAnchorPoint(ccp(0,0.5))
	VisibleRect:relativePosition(self.requrieMentLabel,self.wanSuiPianOwnLabel, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(0,-7))
	self.getTalismNode:addChild(self.requrieMentLabel)
		
	--获取按钮
	local getBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	btText = createSpriteWithFrameName(RES("word_button_get.png"))		
	VisibleRect:relativePosition(getBtn,self.centelViewBgSprite,  LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(215,12))		
	self.getTalismNode:addChild(getBtn)
	getBtn:setTitleString(btText)

	local artiMgr =	GameWorld.Instance:getTalismanManager()		
	local getBtnFunc = function()	
		local mgr = GameWorld.Instance:getTalismanManager()
		local taliList = mgr:getTalismanList()
		local taliObj = taliList[self.selectTalism]
		if( taliObj == nil ) then
			return 1
		end	
		local refId = taliObj:getRefId()
		local itemRefId , Costnum = GetRequestItemAndNum(refId.."_"..tostring(0))	
		local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
		local haveCount = bgmgr:getItemNumByRefId(itemRefId) + bgmgr:getItemNumByRefId("item_suipian")				
			
		if( haveCount >= Costnum )then
			artiMgr:requestActivateTalisman(Talisman_Operate_Type.Achieve,self.selectTalism)
		else
			local mObj = G_IsCanBuyInShop(itemRefId)
			if(mObj ~=  nil) then
				GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,Costnum - bgmgr:getItemNumByRefId(itemRefId) )
			else
				UIManager.Instance:showSystemTips(Config.Words[7508])
			end					
		end
	end		
	getBtn:addTargetWithActionForControlEvents(getBtnFunc,CCControlEventTouchDown)				
end

function TalismanView:createBottomNode()
	self.bottomNode = CCNode:create()
	self.bottomNode:setContentSize(CCSizeMake(550,115))
	self:addChild(self.bottomNode)
	VisibleRect:relativePosition(self.bottomNode,self:getContentNode(),LAYOUT_BOTTOM_INSIDE+ LAYOUT_RIGHT_INSIDE,ccp(-280,35))	
	
	--激活按钮
	self.activateBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
	self.cancleActivateLabel = createSpriteWithFrameName(RES("word_button_cancel.png"))
	self.activateLabel = createSpriteWithFrameName(RES("word_button_activate.png"))				

	self.activateBtn:addChild(self.cancleActivateLabel)
	self.activateBtn:addChild(self.activateLabel)
	VisibleRect:relativePosition(self.activateLabel,self.activateBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.cancleActivateLabel,self.activateBtn,LAYOUT_CENTER)
	
	VisibleRect:relativePosition(self.activateBtn,self.centelViewBgSprite,  LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(215,12))

		
	self.bottomNode:addChild(self.activateBtn)						

	local artiMgr =	GameWorld.Instance:getTalismanManager()	
	local activateBtnFunc = function()	
		local state = Talisman_Operate_Type.Activate
		local mgr = GameWorld.Instance:getTalismanManager()
		local taliList = mgr:getTalismanList()
		if(taliList[self.selectTalism]:getState() == Talisman_State.Activate) then			
			state = Talisman_Operate_Type.CancelActivate			
		end
		artiMgr:requestActivateTalisman( state , self.selectTalism )		
	end	
	self.activateBtn:addTargetWithActionForControlEvents(activateBtnFunc,CCControlEventTouchDown)	
end 

-- 更新左边界面
function TalismanView:updateLeftView()
	if self.talisTable then
		self.talisTable:reloadData()--updateCellAtIndex(math.floor((self.selectTalism-1)/2))
	end
end

-- 更新右上界面
function TalismanView:updateDetailsView()
	local mgr = GameWorld.Instance:getTalismanManager()	
	local level = mgr:getCittaLevel()
	local attributeListLen = table.getn(attributeList)
	if level == 0 then
		for i = 1,attributeListLen do
			if attributeList[i].node then
				attributeList[i].node:setString("-")
			end
		end
	elseif level <=60 then
		local refId = "citta_"..tostring(level)
		local record = GetAttributeDetailsByRefId(refId)
		local effectData = record.effectData
		local property = record.property
		if effectData then
			for i = 1,attributeListLen do
				if attributeList[i].attributeName and attributeList[i].node then
					local attributeName = attributeList[i].attributeName
					if attributeName == "talisManLevel" then
						attributeList[i].node:setString(tostring(level))
					else
						local minValue = effectData["min"..attributeName]
						local maxValue = effectData["max"..attributeName]
						attributeList[i].node:setString(tostring(minValue).."-"..tostring(maxValue))
					end	
				end
			end
			local str = tostring(property["fightValue"])
			self.fightPowerLable:setString(str)	
		end
	end
	self:updateItemNeedLable()
end

function TalismanView:updateItemNeedLable()
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()	
	local hadItemCnt = bgmgr:getItemNumByRefId("item_shenqiExp")

	local talismgr = GameWorld.Instance:getTalismanManager()	
	local level = talismgr:getCittaLevel()	
	local needItemCnt = GetUseMaterialCountByRefId(level)
	
	local lableText = tostring(hadItemCnt).."/"..tostring(needItemCnt)
	if self.itemNeedLable and  self.itemNeedLable.setString  then
		self.itemNeedLable:setString(lableText)		
	end
end

-- 更新右中界面
function TalismanView:updateInfoView()
	local mgr = GameWorld.Instance:getTalismanManager()	
	local activeObj = mgr:getActiveTalisman()
	if activeObj then
		local refId = activeObj:getRefId()		
		
		local talismanName = GetTalisNameByIndex(refId)	
		self.activeTilesmanName:setString(talismanName)

		
		local level = mgr:getCittaLevel()
		local description = GetDescriptionByRefId(refId.."_"..tostring(level))
		self.tilesmanData:setString(description)	
	else
		self.activeTilesmanName:setString("-")
		self.tilesmanData:setString(" ")
	end
end

-- 更新右下界面
function TalismanView:updateAwardView()
	local mgr = GameWorld.Instance:getTalismanManager()
	local award = mgr:getAwardList()

	local canGet = false
	local awardListLen = table.getn(awardList)
	for i = 1,awardListLen do		
		if award then	
			awardList[i].node:clearAll()
			if award[2*i] > 0 then
				canGet = true
			end
			local cumulateData
			local canGetData
			if i == 2 or i == 4	then
				if award[2*i-1] > 10000 then
					cumulateData = tostring(math.floor(award[2*i-1]/10000))..Config.Words[7545]
				else
					cumulateData = tostring(award[2*i-1])
				end
				
				if award[2*i] > 10000 then
					canGetData = tostring(math.floor(award[2*i]/10000))..Config.Words[7545]
				else
					canGetData = tostring(award[2*i])
				end
			else
				cumulateData = tostring(award[2*i-1])
				canGetData = tostring(award[2*i])
			end
			awardList[i].node:appendFormatText(string.wrapHyperLinkRich(cumulateData, Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
			awardList[i].node:appendFormatText(string.wrapHyperLinkRich("+", Config.FontColor["ColorWhite1"], FSIZE("Size3"), nil, "false"))
			awardList[i].node:appendFormatText(string.wrapHyperLinkRich(canGetData, Config.FontColor["ColorGreen1"], FSIZE("Size3"), nil, "false"))
		else
			awardList[i].node:appendFormatText(string.wrapHyperLinkRich("-", Config.FontColor["ColorYellow2"], FSIZE("Size3"), nil, "false"))
		end
	end
	
	if canGet then	
		self.framesprite:setVisible(true)
		self.framesprite:stopAllActions()
		local animate = createAnimate("questframe",6,0.4)	
		local forever = CCRepeatForever:create(animate)
		self.framesprite:runAction(forever)								
	else		
		self.framesprite:stopAllActions()
		self.framesprite:setVisible(false)			
	end
end

-- 更新中部界面
function TalismanView:updateMiddleView()
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()
	local taliObj = taliList[self.selectTalism]	
	if taliObj then
		local state = taliObj:getState()
		local refID = taliObj:getRefId()
		self:showNameSprite(refID)
		self:setTalismPic(refID)
		self:setEffectText()
		if state == Talisman_State.NotAchieve then			
			self:showGetTalismNode()			
		elseif state == Talisman_State.NotActivate then
			self:showBottomNode()	
		elseif state == Talisman_State.Activate then
			self:showBottomNode()
		end
	end	
end


function TalismanView:setEffectText()
	local mgr = GameWorld.Instance:getTalismanManager()	
	local level = mgr:getCittaLevel()

	local taliList = mgr:getTalismanList()
	local taliObj = taliList[self.selectTalism]		
	local refId = taliObj:getRefId()
	local curDescription = GetDescriptionByRefId(refId.."_"..tostring(level))
	local nextDescription = GetDescriptionByRefId(refId.."_"..tostring(level+1)) 

	if curDescription then
		self.curActivateEffectLable:setString(curDescription)	
	else
		self.curActivateEffectLable:setString(" ")
	end
	if nextDescription then
		self.nextActivateEffectLable:setString(nextDescription)	
	else
		self.nextActivateEffectLable:setString(" ")	
	end
end

function TalismanView:setGetCondition()
	local mgr = GameWorld.Instance:getTalismanManager()
	local taliList = mgr:getTalismanList()
	local taliObj = taliList[self.selectTalism]
	local refId = taliObj:getRefId()
	local talismId = refId.."_"..tostring(0)
	
	local record = GetRecordByRefId(talismId) 
	local questpt = record.questDescription	
	local itemRefId , Costnum = GetRequestItemAndNum(talismId)	
	local bgmgr = GameWorld.Instance:getEntityManager():getHero():getBagMgr()
	local haveCount = bgmgr:getItemNumByRefId(itemRefId)
	local wannengNum = bgmgr:getItemNumByRefId("item_suipian")	
	local name = self:getItemNameByRefId(itemRefId)
	if name then
		self.ownNumLable:setString(name)
	end		
	local count = haveCount+wannengNum
	self.suiPianOwnLabel:setString(count)
	self.needSuiPianNumLable:setString(string.format(Config.Words[7546], Costnum))
	
	local str = string.format(Config.Words[7518],wannengNum)
	self.wanSuiPianOwnLabel:setString(str)
	self.requrieMentLabel:setString(PropertyDictionary:get_description(questpt))
	
	local color = FCOLOR("ColorRed1")
	if count >= Costnum then
		color = FCOLOR("ColorGreen1")
	end
	self.suiPianOwnLabel:setColor(color)
	VisibleRect:relativePosition(self.suiPianOwnLabel,self.ownNumLable,LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y,ccp(10,0))
	VisibleRect:relativePosition(self.needSuiPianNumLable, self.suiPianOwnLabel, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE)
end

function TalismanView:getItemNameByRefId(refId)
	if refId then
		local data = GameData.PropsItem[refId]
		if data then
			local name = PropertyDictionary:get_name(data.property)
			return name
		end			
	end
end

function TalismanView:showNameSprite(refId)
	if(self.nameSpr ~= nil and self.nameSpr:getParent()) then
		self.nameSpr:removeFromParentAndCleanup(true)
	end	
	local iconName = "title_name1.png"	
	local index = string.match(refId,"%d+")
	if index then
		iconName = "title_name" .. index .. ".png"
	end
	
	self.nameSpr = createSpriteWithFrameName(RES(iconName))	
	self.nameBg:addChild(self.nameSpr)
	VisibleRect:relativePosition(self.nameSpr,self.nameBg, LAYOUT_CENTER)
	
end

function TalismanView:setTalismPic(refId)
	local offSet = {
	["talis1"] = 20,
	["talis2"] = 60,
	["talis3"] = 0,
	["talis4"] = 20,
	["talis5"] = 30,
	["talis6"] = 20,
	["talis7"] = 45,
	["talis8"] = 35,
	["talis9"] = 40,
	["talis10"] = 0,		
	}	
	local texturePic = "ui/ui_img/activity/ui_game_talisman_pic1.pvr"	
	local index = 1
	if refId then
		index = string.match(refId,"%d+")
	end
	if index then
		texturePic = "ui/ui_img/activity/ui_game_talisman_pic" .. index .. ".pvr"
	end
	if self.talismPicSprite then
		local texture = self.talismPicSprite:getTexture()
		if texture then
			self.talismPicSprite:setTexture(nil)
			CCTextureCache:sharedTextureCache():removeTexture(texture)
		end
		
		texture = CCTextureCache:sharedTextureCache():addImage(texturePic) 
		self.talismPicSprite:setTexture(texture)
		local pixelWidth = texture:getContentSizeInPixels().width
		local pixelHeight = texture:getContentSizeInPixels().height
		local textRect = CCRectMake(0, 0, pixelWidth, pixelHeight)
		self.talismPicSprite:setTextureRect(textRect)			
		self.talismPicSprite:setAnchorPoint(ccp(0.5,0))
		local taliOffset = "talis" .. index		
		local posOffset = offSet[taliOffset] or 0		
		VisibleRect:relativePosition(self.talismPicSprite, self.centelViewBgSprite, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE,ccp(60 + posOffset ,0))		
	end
	
end

function TalismanView:__delete()
	self.cellFrame:release()
	self:getContentNode():removeAllChildrenWithCleanup(true)
end

function TalismanView:onExit()
	
end









