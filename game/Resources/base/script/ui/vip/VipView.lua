-- 显示VIP详情 
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("object.vip.VipDef")
require("ui.utils.ItemView")
require("ui.utils.MessageBox")
require("gameevent.GameEvent")
require("data.scene.scene")
VipView = VipView or BaseClass(BaseUI)

local viewSize = CCSizeMake(455,564)
local scale = VisibleRect:SFGetScale()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local grideSize = VisibleRect:getScaleSize(CCSizeMake(120,60))

local itemCount = 10

local vipTypeList = {
[1] = Config.Words[13001],
--[2] = Config.Words[13002],
[2] = Config.Words[13003],
}
local vipTabTitle = {
[1] = "copperVip.png",
--[2] = "sliverVip.png",
[2] = "goldVip.png",
}

local valueTable = {
[1] = 1,
[2] = 3,
}

function VipView:__init()
	self.viewName = "VipView"
	local titleSprite = createSpriteWithFrameName(RES("topTitle.png"))
	self:createVipFrame(CCSizeMake(viewSize.width+40*2, viewSize.height+20), titleSprite)	
	self:createVipFrameCloseBtn()
	--self:init(viewSize)
	self.eventType = {}	-- tableview的数据类型
	self:initVariable()			
	self:initItem()				
end

function VipView:initVariable()
	--tableview数据源的类型
	self.eventType.kTableCellSizeForIndex = 0
	self.eventType.kCellSizeForTable = 1
	self.eventType.kTableCellAtIndex = 2
	self.eventType.kNumberOfCellsInTableView = 3
	self.cellFrame = createScale9SpriteWithFrameNameAndSize(RES("suqares_mallItemSelect.png"),CCSizeMake(100,85))
	self.cellFrame:retain()		
end

function VipView:create()
	return VipView.New()
end

function VipView:TabPress(key)
	--
	self.key = key
	local textPt = G_GetVipDescriptionByLevel(key)
	local richText = self:parserDescStr(textPt)		
	self.vipDescStr:clearAll()
	self.vipDescStr:appendFormatText(richText)
	self.vipDescStr:setTouchEnabled(true)
	local vipBuyFunction = function()
		local mObj = G_IsCanBuyInShop("item_vip_" .. self.key)
		if(mObj ~=  nil) then
			GlobalEventSystem:Fire(GameEvent.EventBuyItem,mObj,1)
		end
		--self:close()
	end
	if self.vipBuyBtn == nil then
		self.vipBuyBtn = createButtonWithFramename(RES("btn_1_select.png"))
		self:addChild(self.vipBuyBtn)
		VisibleRect:relativePosition(self.vipBuyBtn, self.viewNodeBg, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-10,10))
		self.vipBuyBtn:addTargetWithActionForControlEvents(vipBuyFunction,CCControlEventTouchDown)
	end	
	
	local vipMgr = GameWorld.Instance:getVipManager()	
	local vipLevel = vipMgr:getVipLevel()
	
	if key == 1 then
		local vipTextLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[13014],"Arial",FSIZE("Size7"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
		self.vipBuyBtn:setTitleString(vipTextLable)
	else
		local vipTextLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[13016],"Arial",FSIZE("Size7"),FCOLOR("ColorBrown2"),CCSizeMake(0,0))
		self.vipBuyBtn:setTitleString(vipTextLable)	
	end
	
	if vipLevel<key then
		self.vipBuyBtn:setVisible(true)
	else
		self.vipBuyBtn:setVisible(false)
	end
	
	local height = self.vipDescStr:getContentSize().height
	if height < 350 then
		height = 350
	end
	self.containerNode:setContentSize(CCSizeMake(400, height+40))
	self.scrollView:updateInset()
--	self.containerNode:addChild(self.vipDescStr)
	if key == 3 then
		VisibleRect:relativePosition(self.vipDescStr,self.containerNode,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(0,-65))	
	else
		VisibleRect:relativePosition(self.vipDescStr,self.containerNode,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(0,-55))
	end	
end

function VipView:createVipTabView()

	local createBtn = function (BtnName, key)
		local seleSprite = createScale9SpriteWithFrameName(RES("tab_1_select.png"))		
		local normalSprite = createScale9SpriteWithFrameName(RES("tab_1_normal.png"))		
		local btn = createButton(normalSprite,seleSprite)		
		local label = createSpriteWithFrameName(RES(vipTabTitle[key]))	
		btn:setTitleString(label)
		
		local onTabPress = function ()		
			self:TabPress(valueTable[key])
		end
		btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchUpInside)
			
		return btn
	end
	if not self.tabView then
		local btnArray = CCArray:create()
		local button = nil
		local buttonName
		for key,v in ipairs(vipTypeList) do
			buttonName = v
			button = createBtn(buttonName, key)
			if button then
				btnArray:addObject(button)
			end
		end	
		self.tabView = createTabView(btnArray, 10*viewScale, tab_horizontal)		
		self:addChild(self.tabView,11)
		VisibleRect:relativePosition(self.tabView, self.centelViewBgSprite, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_OUTSIDE, ccp(8,0))		
	end	
end


function VipView:initItem()
	
	local layer = CCLayer:create()	
	layer:setContentSize(CCSizeMake(viewSize.width+40*2,120))
	self:addChild(layer,10)		
	layer:setTouchEnabled(true)
	VisibleRect:relativePosition(layer,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0, 30))	
	local function ccTouchHandler(eventType, x,y)
		local parent = layer:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local  rect = layer:boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			return 0
		end
	end	
	layer:registerScriptTouchHandler(ccTouchHandler, false, -50, true)
		
	local vipMgr = GameWorld.Instance:getVipManager()
	self.centelViewBgSprite = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(414,430))
	self:addChild(self.centelViewBgSprite)	
	VisibleRect:relativePosition(self.centelViewBgSprite,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0, 30))	
	--牛皮纸
	self.viewNodeBg = CCSprite:create()
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.viewNodeBg:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.viewNodeBg:addChild(viewNodeBgLeft)
	self.viewNodeBg:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.viewNodeBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.viewNodeBg,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))	
	self.viewNodeBg : setScaleX(1.0070*0.47)
	self.viewNodeBg : setScaleY(1.0273*0.86)	
	self:addChild(self.viewNodeBg)	
	VisibleRect:relativePosition(self.viewNodeBg,self.centelViewBgSprite,LAYOUT_CENTER)
		
	self.vipDescStr = createRichLabel(CCSizeMake(400-20,0))
	self.vipDescStr:setGaps(5)
	self.vipDescStr:setAnchorPoint(ccp(0.5,1))
	self.vipDescStr:setFontSize(FSIZE("Size3"))	
	self.vipDescStr:setTouchEnabled(true)

	self.containerNode = CCNode:create()
	self:createVipTabView()
	
	self.tabView:setSelIndex(0)
			
	local height = self.vipDescStr:getContentSize().height
	if height < 350 then
		height = 350
	end
	self.containerNode:setContentSize(CCSizeMake(400, height))
	self.containerNode:addChild(self.vipDescStr)	
	VisibleRect:relativePosition(self.vipDescStr,self.containerNode,LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X,ccp(0,-55))		

	self.scrollView = createScrollViewWithSize(CCSizeMake(400,350))
	self.scrollView:setDirection(kSFScrollViewDirectionVertical)	
	self.scrollView:setContainer(self.containerNode)
	--scrollView:setContentOffset( ccp(0, 350 - height))		
	self:addChild(self.scrollView, 5)
	VisibleRect:relativePosition(self.scrollView, self.centelViewBgSprite, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10, -10))
			
	self:showVipState()
	self:setRichLabelHandler()	
end	

function VipView:showVipState()
	--剩余时间
	local vipMgr = GameWorld.Instance:getVipManager()	
	local vipLevel = vipMgr:getVipLevel()
	local restDay = vipMgr:getVipDayRest()
	if vipLevel > 0 then
		local index = 13000 + vipLevel
		if not self.vipTypeLabel then
			self.vipTypeLabel =  createLabelWithStringFontSizeColorAndDimension(Config.Words[13004] ..  Config.Words[index].."VIP","Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))	
			VisibleRect:relativePosition(self.vipTypeLabel,self.centelViewBgSprite,LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE,ccp(15,54))
			self:addChild(self.vipTypeLabel)	

			self.vipRestDay = createLabelWithStringFontSizeColorAndDimension( Config.Words[13005]..restDay .. Config.Words[13007],"Arial",FSIZE("Size3"),FCOLOR("ColorYellow1"))	
			VisibleRect:relativePosition(self.vipRestDay,self.centelViewBgSprite,LAYOUT_BOTTOM_OUTSIDE + LAYOUT_LEFT_INSIDE,ccp(15,44))
			self:addChild(self.vipRestDay)	
		else
			self.vipTypeLabel:setString(Config.Words[13004] ..  Config.Words[index].."VIP")
			self.vipRestDay:setString(Config.Words[13005]..restDay .. Config.Words[13007])
		end
		if self.vipTips then
			self.vipTips:setString(" ")
		end
	else
		if self.vipTypeLabel then
			self.vipTypeLabel:setString(" ")
			self.vipRestDay:setString(" ")
		end
	end	
	if vipLevel < 2 then
		self.tabView:setSelIndex(0)
		self:TabPress(1)
	else
		self.tabView:setSelIndex(1)
		self:TabPress(3)
	end
end

function VipView:onEnter()
	self:showVipState()
end

function VipView:__delete()
	self.cellFrame:release()
	self:getContentNode():removeAllChildrenWithCleanup(true)
end

function VipView:onExit()
	
end

function VipView:parserDescStr(textPt)
	local richText = ""	
	local textList = {}
	local subRich = ""
	local subIndex = 1
	for k , v in pairs(textPt) do
		local arg = string.match( k ,"%d+")
		local descStr = v.description	
		if descStr then	
			while string.match(descStr,"||(.-)||" ) do
				local words = string.match(descStr,"||(.-)||" )
				local subS = string.match(descStr,"||.-||")
				local subStr =  string.wrapHyperLinkRich(words,Config.FontColor["ColorRed1"],FSIZE("Size3"),arg , "true") 
				descStr = string.gsub(descStr, subS, subStr)				
			end
		end	
		textList[tostring(subIndex)] =  subIndex ..Config.Words[13008] .. descStr .. "\n"
		subIndex = subIndex + 1		
	end	
	for index = 1, table.size(textList)  do
		richText = richText .. textList[ tostring(index)]
	end	
	richText = string.wrapHyperLinkRich(richText,Config.FontColor["ColorBlack1"],FSIZE("Size3"),arg , "true") 
	return richText
end

function VipView:setRichLabelHandler()
	local richLabelHandler = function(arg, pTouch)	
		local touch = tolua.cast(pTouch, "CCTouch")
		local pos = touch:getLocation()
		if arg then		
			local vipMgr = GameWorld.Instance:getVipManager()	
			local vipLevel = vipMgr:getVipLevel()
			if vipLevel > 0 then
				local npcData = GameData.Scene["S002"].npc
				local posX =  0
				local posY =  0
				for k ,v in pairs(npcData) do
					if v.npcRefId == "npc_12" then
						posX = v.x
						posY = v.y
						break
					end	
				end
				local level = PropertyDictionary:get_level(G_getHero():getPT())
				if level >= 10 then 	
					local gameMapManager = GameWorld.Instance:getMapManager()
					if gameMapManager:checkCanUseFlyShoes(true) then
						gameMapManager:requestTransfer("S002", posX, posY,1)
					end
				else
					UIManager.Instance:showSystemTips(Config.Words[13018])
				end	
			else
				UIManager.Instance:showSystemTips(Config.Words[13019])
			end
		end
	end
	self.vipDescStr:setEventHandler(richLabelHandler)
end