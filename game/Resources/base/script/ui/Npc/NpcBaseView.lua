--[[
NPC对话框的模板
]]

require("common.BaseUI")

NpcBaseView = NpcBaseView or BaseClass(BaseUI)

function NpcBaseView:__init()
	self:initHalfScreen()
	self.npcViewNode = CCNode:create()
	local viewSize = self.contentNode:getContentSize()
	self.npcViewNode:setContentSize(CCSizeMake(viewSize.width, viewSize.height-86))
	self:addChild(self.npcViewNode)
	VisibleRect:relativePosition(self.npcViewNode, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
end

function NpcBaseView:__delete()

end

function NpcBaseView:getNpcViewNode()
	return self.npcViewNode
end

-- 创建牛皮纸背景
function NpcBaseView:createViewBg()
	--重置窗口
	local viewSize = self.contentNode:getContentSize()
	
	--边框
	local frameBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(viewSize.width, viewSize.height-86))
	self.contentNode:addChild(frameBg)
	VisibleRect:relativePosition(frameBg,self:getContentNode(),LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE)
	
	local frameTextBg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"),CCSizeMake(viewSize.width, 86))
	self:addChild(frameTextBg)
	VisibleRect:relativePosition(frameTextBg, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE)
	--牛皮纸
	--[[self.imageBg = CCNode:create()
	self.imageBg:setAnchorPoint(ccp(0.5, 0.5))
	local viewNodeBgRight = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	local viewNodeBgLeft = CCSprite:create("ui/ui_img/common/kraft_bg.pvr")
	viewNodeBgLeft:setFlipX(true)
	self.imageBg:setContentSize(CCSizeMake(viewNodeBgRight:getContentSize().width*2,viewNodeBgRight:getContentSize().height))
	self.imageBg:addChild(viewNodeBgLeft)
	self.imageBg:addChild(viewNodeBgRight)
	VisibleRect:relativePosition(viewNodeBgLeft,self.imageBg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))
	VisibleRect:relativePosition(viewNodeBgRight,self.imageBg,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,0))		
	
	local scaleY = viewSize.width/viewNodeBgRight:getContentSize().height
	local scaleX = viewSize.height/(viewNodeBgRight:getContentSize().width*2)
	self.imageBg:setScaleX(scaleX)
	self.imageBg:setScaleY(scaleY)
	self.imageBg:setRotation(90)
	
	self.frameBg:addChild(self.imageBg)
	VisibleRect:relativePosition(self.imageBg,self.frameBg,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(0,0))--]]
end

-- 设置左上角的头像
function NpcBaseView:setNpcAvatar(npcRefId)
	local headIcon = "npc_2018.png"
	if GameData.Npc[npcRefId] then
		headIcon = GameData.Npc[npcRefId].head.head..".png"
	end
	
	self.iconbg = createSpriteWithFrameName(RES("quest_npcIconFram.png"))
	local icon =createSpriteWithFrameName(RES(headIcon))
	
	if  self.iconbg then
		if icon then
			self.iconbg:addChild(icon)
			VisibleRect:relativePosition(icon, self.iconbg, LAYOUT_CENTER ,ccp(10,20))
		end		
		self.rootNode:addChild(self.iconbg, 3)
		VisibleRect:relativePosition(self.iconbg,self.rootNode,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-22,15))
	end
end

-- 设置NPC名字
function NpcBaseView:setNpcName(npcRefId)
	local npcNameWord = " "
	if GameData.Npc[npcRefId]~=nil then
		npcNameWord =  GameData.Npc[npcRefId]["property"]["name"]
	end	
	local npcName = createLabelWithStringFontSizeColorAndDimension(npcNameWord,"Arial",FSIZE("Size4"),FCOLOR("ColorYellow6"),CCSizeMake(self.background:getContentSize().width-20,0))
	self:setFormTitle(npcName, TitleAlign.Left)
	if self.iconbg then
		VisibleRect:relativePosition(npcName,self.iconbg,LAYOUT_RIGHT_OUTSIDE,ccp(10, 0))
	end
end

--设置NPC文字描述
function NpcBaseView:setNpcText(textString)
	if not textString or textString == "" then
		return
	end
	local contentSize = self.contentNode:getContentSize()
	local textLabel = createLabelWithStringFontSizeColorAndDimension(textString , "Arial", FSIZE("Size3"), FCOLOR("ColorWhite3"), CCSizeMake(contentSize.width-60, 0))
	
	local scrollViewSize = CCSizeMake(contentSize.width, 63)
	if not self.scrollView then
		self.scrollView = createScrollViewWithSize(scrollViewSize)
		self.scrollView:setDirection(2)
		local container = CCNode:create()
		container:setContentSize(scrollViewSize)
		self.scrollView:setContainer(container)
		self:addChild(self.scrollView)
		VisibleRect:relativePosition(self.scrollView, self:getContentNode(), LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -18))	
	else
		self.scrollView:getContainer():removeAllChildrenWithCleanup(true)
	end		
	
	local labelSize = textLabel:getContentSize()	
	if labelSize.height > scrollViewSize.height then
		self.scrollView:setContentSize(CCSizeMake(contentSize.width, labelSize.height))
		local offset = self.scrollView:minContainerOffset()
		self.scrollView:setContentOffset(offset)
	else
		self.scrollView:setContentSize(scrollViewSize)
	end					
	
	self.scrollView:addChild(textLabel, 1)
	VisibleRect:relativePosition(textLabel, self.scrollView:getContainer(), LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(60, 0))
end

