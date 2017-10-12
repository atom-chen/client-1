require("ui.UIManager")
require("common.BaseUI")
require("config.words")
--require("object.faction.FactionObject")
FactionInviteView = FactionInviteView or BaseClass(BaseUI)


local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_scrollViewSize
local FactionMgr = nil 
 
function FactionInviteView:__init()
	self.viewName = "FactionInviteView"
	self.rootNode:setContentSize(CCSizeMake(400*const_scale,544*const_scale))	
	FactionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self:initFactionInvite()
end

function FactionInviteView:__delete()
	
end

function FactionInviteView:onEnter()
	--self:initFactionInvite()
end

function FactionInviteView:initFactionInvite()
	local gap = 97
	local FactionInviteList =  FactionMgr:getFactionInviteList()
--[[	FactionInviteList = {}
	local FactionObj = MemberObject.New()
	FactionObj:setInvitePlayerName("dsagsdgs")
	FactionObj:setInvitePlayerLevel(22)
	FactionObj:setInviteFactionName("gdgdgd")	
	table.insert(FactionInviteList,FactionObj)
	table.insert(FactionInviteList,FactionObj)
	table.insert(FactionInviteList,FactionObj)
	table.insert(FactionInviteList,FactionObj)
	table.insert(FactionInviteList,FactionObj)--]]
	local tableSize = table.size(FactionInviteList)
	if tableSize == 0 then
		GlobalEventSystem:Fire(GameEvent.EventSetFactionInviteBtnStatus,false)
		self:close()
		return
	end
	self:init(CCSizeMake(400*const_scale,(tableSize*97+69)*const_scale))	--自适应大小
	local viewBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"),CCSizeMake(360*const_scale,(tableSize*97+8)*const_scale))
	self.rootNode:addChild(viewBg)
	VisibleRect:relativePosition(viewBg,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-41))
	for j,v in ipairs(FactionInviteList) do
		local FactionInviteItem = self:createFactionInviteItem(v,j)
		self.rootNode:addChild(FactionInviteItem)
		VisibleRect:relativePosition(FactionInviteItem,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-45-(j-1)*gap))
	end		
end

function FactionInviteView:createFactionInviteItem(inviteObj,index)
	local invitePlayerId = inviteObj:getInvitePlayerId()
	local item = CCNode:create()
	local itemSize = CCSizeMake(352*const_scale,97*const_scale)
	item:setContentSize(itemSize)
	if index%2 == 1 then
		local itemBg = createScale9SpriteWithFrameNameAndSize(RES("faction_contentBg.png"),itemSize)
		item:addChild(itemBg)
		VisibleRect:relativePosition(itemBg,item,LAYOUT_CENTER)
	end
	
	local playerName = inviteObj:getInvitePlayerName()
	playerName = string.wrapRich(playerName,Config.FontColor["ColorBlue1"],FSIZE("Size3"))
	local playerLevel = "(" .. Config.Words[9025] .. inviteObj:getInvitePlayerLevel() .. ")"
	playerLevel = string.wrapRich(playerLevel,Config.FontColor["ColorBlue1"],FSIZE("Size3"))
	local factionName = inviteObj:getInviteFactionName()
	factionName = string.wrapRich(factionName,Config.FontColor["ColorGreen1"],FSIZE("Size3"))	
	local describeLabel1 = string.wrapRich(Config.Words[5562],Config.FontColor["ColorYellow5"],FSIZE("Size3"))
	local describeLabel2 = string.wrapRich(Config.Words[5563],Config.FontColor["ColorYellow5"],FSIZE("Size3"))
	local inviteInfo = playerName .. playerLevel .. " " .. describeLabel1 .. " " .. factionName .. " " .. describeLabel2	
	
	local inviteInfoLb = createRichLabel(CCSizeMake(itemSize.width,20))	
	inviteInfoLb:appendFormatText(inviteInfo)
	inviteInfoLb:setAnchorPoint(ccp(1,0))
	item:addChild(inviteInfoLb)
	VisibleRect:relativePosition(inviteInfoLb,item,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-20))
		
	--按钮			
	local refuseFunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventReplyJoinFaction,invitePlayerId,inviteObj:getInviteFactionName(),3)
	end	
	local refuseBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	item:addChild(refuseBtn)
	VisibleRect:relativePosition(refuseBtn,item,LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-13,7))
	local accept = createLabelWithStringFontSizeColorAndDimension(Config.Words[5538],"Arial",FSIZE("Size5")*const_scale,FCOLOR("ColorWhite2"))
	refuseBtn:setTitleString(accept)
	refuseBtn:addTargetWithActionForControlEvents(refuseFunc, CCControlEventTouchDown)
	
	local acceptFunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventReplyJoinFaction,invitePlayerId,inviteObj:getInviteFactionName(),2)
	end
	local acceptBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	item:addChild(acceptBtn)
	VisibleRect:relativePosition(acceptBtn,refuseBtn,LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(-10,0))
	local accept = createLabelWithStringFontSizeColorAndDimension(Config.Words[5537],"Arial",FSIZE("Size5")*const_scale,FCOLOR("ColorWhite2"))
	acceptBtn:setTitleString(accept)
	acceptBtn:addTargetWithActionForControlEvents(acceptFunc, CCControlEventTouchDown)
	
	return item
end

function FactionInviteView:updateView()
	self.rootNode:removeAllChildrenWithCleanup(true)
	self:initFactionInvite()
end

