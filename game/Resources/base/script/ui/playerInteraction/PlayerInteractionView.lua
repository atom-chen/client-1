require("ui.UIManager")
require("config.words")

PlayerInteractionView = PlayerInteractionView or BaseClass()

btnTag = {
	tag_chatPrivate = 1,
	tag_check = 2,
	tag_teamInvite = 3,
	tag_haveTeam = 4,
	tag_disbandTeam  = 5,
	tag_outTeam = 6,
	tag_changeHeader = 7,
	tag_quitTeam = 8,	
	tag_addFriend = 9,
	tag_yourFriend = 10,
	tag_copyName = 11,
	tag_FactionInvite = 12,
}

local PlayerInteractionList = {
	[btnTag.tag_chatPrivate] = {name = "main_headprivatechat.png",tag = btnTag.tag_chatPrivate},
	[btnTag.tag_check] = {name =  "main_headcheck.png",tag = btnTag.tag_check},
	[btnTag.tag_teamInvite] = {name =  "main_headteaminvite.png",tag = btnTag.tag_teamInvite},
	[btnTag.tag_haveTeam] = {name =  "main_headhaveteam.png",tag = btnTag.tag_haveTeam},
	[btnTag.tag_disbandTeam] = {name =  "main_headdisband.png",tag = btnTag.tag_disbandTeam},
	[btnTag.tag_outTeam] = {name =  "main_headkickout.png",tag = btnTag.tag_outTeam},
	[btnTag.tag_changeHeader] = {name =  "main_headprivatechat.png",tag = btnTag.tag_changeHeader},
	[btnTag.tag_quitTeam] = {name =  "main_headquitteam.png",tag = btnTag.tag_quitTeam},
	[btnTag.tag_addFriend] = {name =  "main_headprivatechat.png",tag = btnTag.tag_addFriend},
	[btnTag.tag_yourFriend] = {name =  "main_headprivatechat.png",tag = btnTag.tag_yourFriend},
	[btnTag.tag_copyName] = {name =  "main_headprivatechat.png",tag = btnTag.tag_copyName},
	[btnTag.tag_FactionInvite] = {name =  "main_headfaction.png",tag = btnTag.tag_FactionInvite},
}

local PlayerTeamStatus = {
	[1] = {name = Config.Words[9001]},
	[2] = {name = Config.Words[9002]},
	[3] = {name = Config.Words[9003]}, 	
}

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_scrollViewSize
local teamMgr

function PlayerInteractionView:__init()
	self.viewName = "PlayerInteractionView"
	teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)	
	self.rootNode:setContentSize(CCSizeMake(124*const_scale,337*const_scale))
	self.rootNode:retain()
	self.btntable = {}	
end

function PlayerInteractionView:__delete()
	self.btntable = {}
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function PlayerInteractionView:getRootNode()
	return self.rootNode
end

function PlayerInteractionView:setViewSize(size)
	self.rootNode:setContentSize(size)
	self.background = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"), size)
	self.rootNode:addChild(self.background)	
	VisibleRect:relativePosition(self.background,self.rootNode, LAYOUT_CENTER)	
end

function PlayerInteractionView:setPlayerId(playerId)
	self.selectEntityObjectId = playerId	
	self:updateIteam()
end

function PlayerInteractionView:updateIteam()	
	local teamObject = teamMgr:getTeamObject()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()			
	local interactionTable = {}
	local selectEntityObject = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player,self.selectEntityObjectId)
	table.insert(interactionTable,PlayerInteractionList[btnTag.tag_chatPrivate])
	table.insert(interactionTable,PlayerInteractionList[btnTag.tag_check])	
	if selectEntityObject then		
		--[[
		if false then
			table.insert(interactionTable,PlayerInteractionList[btnTag.tag_addFriend])
		end
		if false then
			table.insert(interactionTable,PlayerInteractionList[btnTag.tag_yourFriend])
		end		
		table.insert(interactionTable,PlayerInteractionList[btnTag.tag_copyName])--]]
		local factionName = PropertyDictionary:get_unionName(selectEntityObject:getPT())
		if factionMgr:canInvite() and factionName == "" then
			table.insert(interactionTable,PlayerInteractionList[btnTag.tag_FactionInvite])
		end		
	end
	if teamMgr:isMyTeamate(self.selectEntityObjectId) and teamMgr:getTeamLeaderId() == G_getHero():getId() then
		table.insert(interactionTable,PlayerInteractionList[btnTag.tag_outTeam])			
		table.insert(interactionTable,PlayerInteractionList[btnTag.tag_disbandTeam])
	end			
	if teamMgr:isMyTeamate(self.selectEntityObjectId) then
		table.insert(interactionTable,PlayerInteractionList[btnTag.tag_quitTeam])
	end
	if teamObject then
		if teamObject:getPlayerTeamStateType() == 3 and not teamMgr:isMyTeamate(self.selectEntityObjectId)  and 
			(( table.size(teamMgr:getTeam()) < 3 and 
			teamMgr:getTeamLeaderId() == G_getHero():getId())
			 or table.size(teamMgr:getTeam()) == 0 ) then
			table.insert(interactionTable,PlayerInteractionList[btnTag.tag_teamInvite])
		elseif teamObject:getPlayerTeamStateType() == 1 then
			table.insert(interactionTable,PlayerInteractionList[btnTag.tag_haveTeam])			
		end
	end	
	--得到选项个数
	local btnNum = table.size(interactionTable)	
	self.rootNode:removeAllChildrenWithCleanup(true)
	self:setViewSize(CCSizeMake(124,btnNum*58+40))	
	self:createCloseBtn()
	for j,v in ipairs(interactionTable) do		
		local btn = createButtonWithFramename(RES(v.name))
		btn:setTouchAreaDelta(16,16,10,10)
		self.rootNode:addChild(btn)
		VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE,ccp(0,-(50 + (j-1)*58)))	
		if j ~= #interactionTable then
			local line = createScale9SpriteWithFrameNameAndSize(RES("left_dividLine.png"), CCSizeMake(100, 2))
			self.rootNode:addChild(line)
			VisibleRect:relativePosition(line,btn,LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE,ccp(0,-15))	
		end	
		local btnFunc = function ()
			GlobalEventSystem:Fire(GameEvent.EventShowInteractionByTag,v.tag,self.selectEntityObjectId)
			GlobalEventSystem:Fire(GameEvent.EventHideInteractionView)
		end
		btn:addTargetWithActionForControlEvents(btnFunc, CCControlEventTouchDown)
	end					
end

function PlayerInteractionView:createCloseBtn()
	self.btnClose = createButtonWithFramename(RES("closeButton.png"))
	self.btnClose:setTouchPriority(UIPriority.Control)
	self.rootNode:addChild(self.btnClose, 50)	
	local btnCloseSize = self.btnClose:getContentSize()
	VisibleRect:relativePosition(self.btnClose,self.rootNode,LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(10,15))
	local exitFunction =  function ()	
		GlobalEventSystem:Fire(GameEvent.EventHideInteractionView)
	end
	self.btnClose:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
end