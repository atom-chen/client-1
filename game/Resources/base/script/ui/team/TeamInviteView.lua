require("ui.UIManager")
require("common.BaseUI")
require("config.words")
--require("object.Team.TeamObject")
TeamInviteView = TeamInviteView or BaseClass(BaseUI)


local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_scrollViewSize
local TeamMgr = nil 
 
function TeamInviteView:__init()
	self.viewName = "TeamInviteView"
	self:init(CCSizeMake(400*const_scale,544*const_scale))	
	TeamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
end

function TeamInviteView:__delete()
	
end

function TeamInviteView:onEnter()
	self:getContentNode():removeAllChildrenWithCleanup(true)
	self:initITeam()
end

function TeamInviteView:initITeam()
	local gap = 97
	local TeamInviteList =  TeamMgr:getTeamInviteList()
	--TeamInviteList = {}
--[[	local TeamObj = TeamObject.New()
	TeamObj:setInvitePlayerName("dsagsdgs")
	TeamObj:setInvitePlayerLevel(22)	
	table.insert(TeamInviteList,TeamObj)--]]
	--[[table.insert(TeamInviteList,TeamObj)
	table.insert(TeamInviteList,TeamObj)
	table.insert(TeamInviteList,TeamObj)
	table.insert(TeamInviteList,TeamObj)--]]
	local tableSize = table.size(TeamInviteList)
	if tableSize == 0 then
		GlobalEventSystem:Fire(GameEvent.EventSetTeamInviteBtnStatus,false)
		UIManager.Instance:hideUI("TeamInviteView")		
		return
	end
	self:init(CCSizeMake(400*const_scale,(tableSize*110+69)*const_scale))	--自适应大小
	local viewBg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"),CCSizeMake(360*const_scale,(tableSize*97+8)*const_scale))
	self:addChild(viewBg)
	VisibleRect:relativePosition(viewBg,self:getContentNode(),LAYOUT_CENTER+LAYOUT_TOP_INSIDE)
	for j,v in ipairs(TeamInviteList) do
		local TeamInviteItem = self:createTeamInviteItem(v,j)
		self:addChild(TeamInviteItem)
		VisibleRect:relativePosition(TeamInviteItem,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-(j-1)*gap))
	end		
end

function TeamInviteView:createTeamInviteItem(inviteObj,index)
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
	--根据类型 显示  申请还是邀请 TODO	
	local inviteType = inviteObj:getInviteType() 	
	if inviteType == 1 then
		typeStr  = Config.Words[9033]
	else
		typeStr = Config.Words[9029]
	end
	local describeLabel1 = string.wrapRich(typeStr,Config.FontColor["ColorYellow5"],FSIZE("Size3"))	
		
	local inviteInfo = playerName .. playerLevel .. " " .. describeLabel1
	
	local inviteInfoLb = createRichLabel(CCSizeMake(itemSize.width,20))	
	inviteInfoLb:appendFormatText(inviteInfo)
	inviteInfoLb:setAnchorPoint(ccp(1,0))
	item:addChild(inviteInfoLb)
	VisibleRect:relativePosition(inviteInfoLb,item,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-20))
		
	--按钮			
	local refuseFunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventReplyJoinTeam,invitePlayerId,3,inviteType)
	end	
	local refuseBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	item:addChild(refuseBtn)
	VisibleRect:relativePosition(refuseBtn,item,LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-13,7))
	local accept = createLabelWithStringFontSizeColorAndDimension(Config.Words[5538],"Arial",22*const_scale,FCOLOR("ColorWhite2"))
	refuseBtn:setTitleString(accept)
	refuseBtn:addTargetWithActionForControlEvents(refuseFunc, CCControlEventTouchDown)
	
	local acceptFunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventReplyJoinTeam,invitePlayerId,2,inviteType)
	end
	local acceptBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	item:addChild(acceptBtn)
	VisibleRect:relativePosition(acceptBtn,refuseBtn,LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(-10,0))
	local accept = createLabelWithStringFontSizeColorAndDimension(Config.Words[5537],"Arial",22*const_scale,FCOLOR("ColorWhite2"))
	acceptBtn:setTitleString(accept)
	acceptBtn:addTargetWithActionForControlEvents(acceptFunc, CCControlEventTouchDown)
	
	return item
end

function TeamInviteView:updateView()
	self:getContentNode():removeAllChildrenWithCleanup(true)
	self:initITeam()
end

