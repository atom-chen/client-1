require("object.npc.NpcDef")
require("object.npc.TransObject")
require("data.npc.npc")	
require("common.BaseUI")
require("ui.Npc.NpcBaseView")
NpcTalkView = NpcTalkView or BaseClass(NpcBaseView)

local width = 393
local height = 540
visibleSize = CCDirector:sharedDirector():getVisibleSize()
viewScale = VisibleRect:SFGetScale()
viewSize = CCSizeMake(393*viewScale,236*viewScale)

function NpcTalkView:__init()
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	local npcMgr = GameWorld.Instance:getNpcManager()
	--local viewNpcId = questMgr:getNpcTalkViewInfo()	
	self.viewName = "NpcTalkView"
	--self:init(viewSize)										
	--self:setHeadIcon(viewNpcId)
	--self:setTalkContent(viewNpcId)			
	self:createViewBg()	
	self:setButton()
end

function NpcTalkView:__delete()

end

function NpcTalkView:onExit()

end

function NpcTalkView:onEnter(npcRefId)
	self:setNpcAvatar(npcRefId)
	self:setNpcName(npcRefId)
	self:setTalkContent(npcRefId)	
end

function NpcTalkView:create()
	return NpcTalkView.New()
end

--显示NPC图片
--显示谈话内容
function NpcTalkView:setTalkContent(viewNpcId)

	local npcTalkWord = ""

	if GameData.Npc[viewNpcId] then
		npcTalkWord = GameData.Npc[viewNpcId]["property"]["description"]
	else
		npcTalkWord = string.wrapRich(Config.Words[3202],Config.FontColor["ColorWhite1"],FSIZE("Size4"))
	end
	npcTalkWord = "    " .. npcTalkWord
	self:setNpcText(npcTalkWord)
	--[[if self.questTitle == nil then
		local childViewSize = CCSizeMake((width-30)*viewScale,100*viewScale)	
		local containerNode = CCNode:create()
		containerNode:setContentSize(childViewSize)
		local scrollView = createScrollViewWithSize(childViewSize)
		scrollView:setDirection(kSFScrollViewDirectionVertical)	
		scrollView:setContainer(containerNode)
		self:addChild(scrollView)
		VisibleRect:relativePosition(scrollView, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(0, -60.0))	
			
		self.questTitle = createLabelWithStringFontSizeColorAndDimension( npcTalkWord , "Arial",FSIZE("Size4"),FCOLOR("ColorWhite1"),CCSizeMake((width-40)*viewScale,0))
		containerNode:addChild(self.questTitle)
		VisibleRect:relativePosition(self.questTitle,containerNode,LAYOUT_TOP_INSIDE +LAYOUT_CENTER , ccp(0,0))	
	else
		self.questTitle:setString(npcTalkWord)
	end--]]
end

--[[function NpcTalkView:setHeadIcon(viewNpcId)
	local headSpritefilename = "npc_2018.png"
	local iconName = G_GetNpcHeadIconName(viewNpcId)
	if iconName then
		headSpritefilename = iconName..".png"
	end
	
	if not self.iconbg then
		self.iconbg = createSpriteWithFrameName(RES("quest_npcIconFram.png"))
		self:addChild(self.iconbg)
		VisibleRect:relativePosition(self.iconbg,self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE ,ccp(-35,63))
	else
		self.iconbg:removeAllChildrenWithCleanup(false)
	end
		
	local head = createSpriteWithFrameName(RES(headSpritefilename))
	self.iconbg:addChild(head)
	VisibleRect:relativePosition(head,self.iconbg, LAYOUT_CENTER ,ccp(7,15))
	

	local npcNameWord = ""
	if GameData.Npc[viewNpcId] then
		npcNameWord =  GameData.Npc[viewNpcId]["property"]["name"]
	end	
	
	if not self.npcName then
		self.npcName = createLabelWithStringFontSizeColorAndDimension(npcNameWord,"Arial",FSIZE("Size7"),FCOLOR("ColorBrown2"))
		self:addChild(self.npcName)
		VisibleRect:relativePosition(self.npcName,self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER ,ccp(0,20))
	else
		self.npcName:setString(npcNameWord)
	end
end--]]


function NpcTalkView:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then	
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			self:close()
			return 1
		else
			self:close()
			return 0
		end
	else
		self:close()
		return 0
	end
end

function NpcTalkView:setButton()
	local button = createButtonWithFramename(RES("btn_1_normal.png"))
	local textLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[3151], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	button:setTitleString(textLabel)
	self:addChild(button)
	VisibleRect:relativePosition(button, self:getContentNode(), LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE, ccp(-20, 20))
	local buttonFun = function ()
		self:close()
	end
	button:addTargetWithActionForControlEvents(buttonFun,CCControlEventTouchDown)
end