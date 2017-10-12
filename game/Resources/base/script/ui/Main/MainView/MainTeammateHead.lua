MainTeammateHead = MainTeammateHead or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_headScale = nil

function MainTeammateHead:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(CCSizeMake(180,100))
	self.scale = VisibleRect:SFGetScale()
	self:initTeam()
--	self:updateTeammate()
end

function MainTeammateHead:__delete()
	self.TeammateHeadframehead = {}
	self.TeammateHeadframe = {}
	self.PlayerHead = {}
	self.TeammateOperation = {}
	self.PlayerHeadLayer  = {}
	self.HeadImageName = {}
	self.grayHead = {}
end

function MainTeammateHead:initTeam()
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self.TeammateHeadframehead = {}
	self.TeammateHeadframe = {}
	self.PlayerHead = {}
	self.TeammateHP = {}
	self.TeammateOperation = {}
	self.PlayerHeadLayer  = {}
	self.HeadImageName = {}
	self.grayHead = {}
	self:showView()
end

function MainTeammateHead:getRootNode()
	return self.rootNode
end


function MainTeammateHead:showView()
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()

		--测试代码---
--[[			self.TeamMemberObj = TeamObject.New()
			self.TeamMemberObj:setTeamMemberId(435346)
			self.TeamMemberObj:setTeamMemberName("duiyuan1")
			self.TeamMemberObj:setTeamMemberMaxHP(100)
			self.TeamMemberObj:setTeamMemberHP(50)
			teamMgr:setTeam(self.TeamMemberObj)	
			self.TeamMemberObj1 = TeamObject.New()
			self.TeamMemberObj1:setTeamMemberId(435347)
			self.TeamMemberObj1:setTeamMemberName("duiyuan2")
			self.TeamMemberObj1:setTeamMemberMaxHP(100)
			self.TeamMemberObj1:setTeamMemberHP(50)
			teamMgr:setTeam(self.TeamMemberObj1)	--]]		
	local disBandTeamFunc = function()
		teamMgr:requestDisbandTeam()
	end
	local disBandBt = createButtonWithFramename(RES("chat_nomal_btn.png"))
	disBandBt:setTitleString(createLabelWithStringFontSizeColorAndDimension(Config.Words[9028],"Arial",FSIZE("Size3"),FCOLOR("ColorWhite1"))) 
	self.rootNode:addChild(disBandBt)	
	VisibleRect:relativePosition(disBandBt,self.rootNode,LAYOUT_CENTER)	
	disBandBt:addTargetWithActionForControlEvents(disBandTeamFunc,CCControlEventTouchDown)
	disBandBt:setVisible(false)

	local team = teamMgr:getTeam()	
	if team == nil then
		return
	end		
	if ( table.size(team) < 1 and teamMgr:getMyTeamId() ) or (table.size(team)  == 1  and team[1]:getTeamMemberId() == G_getHero():getId() )  then
		disBandBt:setVisible(true)
	end

	local hero = GameWorld.Instance:getEntityManager():getHero()
	self.heroId =  hero:getId()
	local pos = 1
	for j,v in ipairs(team) do
		if v:getTeamMemberId() ~= self.heroId
			 then
			self:crateTeammate(j,v,pos)
			self:updateTeammate(j,v,pos)
			pos = pos + 1 
		end
	end
				
end

function MainTeammateHead:updateTeam()
	self.rootNode:removeAllChildrenWithCleanup(true)
	self:initTeam()
end

function MainTeammateHead:onEnter()
	
end

function MainTeammateHead:crateTeammate(index,teamMember,pos)
	if not index or not teamMember or not pos then
		return
	end
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()	
	--hpBottom
	local hpBottom = createScale9SpriteWithFrameNameAndSize(RES("main_playerHpBg.png"),CCSizeMake(115,12))	
	self.rootNode:addChild(hpBottom)
		
	--HP					
	local headHPSprite = createSpriteWithFrameName(RES("main_playerHp.png"))
	headHPSprite:setScaleY(1.5)									
	self.TeammateHP[index] = CCProgressTimer:create(headHPSprite)	
	self.TeammateHP[index]:setScaleX(39)				
	self.TeammateHP[index]:setType(kCCProgressTimerTypeBar)		
	self.TeammateHP[index]:setMidpoint(ccp(0,0))
	self.TeammateHP[index]:setBarChangeRate(ccp(1,0))	
	self.TeammateHP[index]:setAnchorPoint(ccp(0,0.5))	
	self.rootNode:addChild(self.TeammateHP[index])
	
	--英雄面板
	--队长标志	
	if teamMember:getTeamMemberId() == teamMgr:getTeamLeaderId() then	
		self.TeammateHeadframehead[index] =  createSpriteWithFrameName(RES("team_teammateLeaderHead.png"))

	--elseif teamMgr:getTeamLeaderId() == self.heroId then
	
	else
		self.TeammateHeadframehead[index] =  createSpriteWithFrameName(RES("team_teammateHead.png"))
	end	
	self.TeammateHeadframehead[index]:setScale(1.6)
	self.rootNode:addChild(self.TeammateHeadframehead[index],10-index)			
	self.TeammateHeadframe[index] = createSpriteWithFrameName(RES("main_playerFrame.png"))	
	self.TeammateHeadframe[index]:setScale(1.5)
	self.TeammateHeadframe[index]:setFlipX(true)
	self.rootNode:addChild(self.TeammateHeadframe[index])	
		
	--等级
	--self.playerLevel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size1")*self.scale,FCOLOR("ColorYellow4"))	
	--self.rootNode:addChild(self.playerLevel)
		
	
	--人物名称
	self.playerName = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size3")*self.scale,FCOLOR("ColorWhite1"))
	--self.playerName:setAnchorPoint(ccp(1,0.5))
	self.playerName:setString(teamMember:getTeamMemberName())
	self.rootNode:addChild(self.playerName)		
			
	VisibleRect:relativePosition(self.TeammateHeadframe[index],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(50,-(pos-1)*70))				
	VisibleRect:relativePosition(self.TeammateHeadframehead[index],self.TeammateHeadframe[index],LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER_Y,ccp(18,-3))	
	VisibleRect:relativePosition(hpBottom,self.TeammateHeadframe[index],LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,-31))	
	VisibleRect:relativePosition(self.TeammateHP[index],self.TeammateHeadframe[index],LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,-31))	
	VisibleRect:relativePosition(self.playerName,self.TeammateHeadframe[index],LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,3))
	
	--头像			
	self:createHead(index,teamMember)	
	

--[[	--面板
	self.TeammateHeadframe[index] = createSpriteWithFrameName(RES("main_TeammateFrame.png"))
	G_setScale(self.TeammateHeadframe[index])
	self.rootNode:addChild(self.TeammateHeadframe[index])	
	VisibleRect:relativePosition(self.TeammateHeadframe[index],self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,TeammatePos[index])
	
	--Hp	
	local TeammateHpSprite = createSpriteWithFrameName(RES("main_TeammateHp.png"))
	self.TeammateHP = CCProgressTimer:create(TeammateHpSprite)
	self.TeammateHP:setReverseProgress(true)	
	self.TeammateHeadframe[index]:addChild(self.TeammateHP)
	VisibleRect:relativePosition(self.TeammateHP,self.TeammateHeadframe[index],LAYOUT_CENTER ,ccp(0,0))	--]]
	

	
end

function MainTeammateHead:showMenu(index,teamMember,pos)
	if not index then
		return
	end
	if teamMember:getTeamMemberId() == teamMgr:getTeamLeaderId() then	
		
	else

	end
	
	if self.TeammateOperation[index] == nil then
		--面板
		self.TeammateOperation[index] = createSpriteWithFrameName(RES("countDownBg.png"))
		G_setScale(self.TeammateOperation[index])
		self.rootNode:addChild(self.TeammateOperation[index])
		VisibleRect:relativePosition(self.TeammateOperation[index],self.TeammateHeadframehead[index],LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE  --[[,ccp(pos.x+20,pos.y-30)--]])				
	else
		local bshow = self.TeammateOperation[index]:isVisible()
		if bshow then		
			self.TeammateOperation[index]:setVisible(false)
		else
			VisibleRect:relativePosition(self.TeammateOperation[index],self.TeammateHeadframehead[index],LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE  --[[,ccp(pos.x+20,pos.y-30)--]])
			self.TeammateOperation[index]:setVisible(true)
		end
	end
	
	
end

--显示弹出框
function MainTeammateHead:showPopupMenu(index, teamMember)
	if not index then
		return
	end
	local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
	local height = 135	
	local handleQuitTeam = function (arg)	
		teamMgr:requestLeaveTeam()
	end
	local handleChangeHeader = function (arg)
		local playerId = arg:getTeamMemberId()
		teamMgr:requestHandoverTeamLeader(playerId)
	end
	
	local handleOutTeam = function (arg)
		local playerId = arg:getTeamMemberId()
		teamMgr:requestKickedOutTeam(playerId)
	end
	
	local disbandTeam = function(arg)
		teamMgr:requestDisbandTeam()
	end
	
	local handleChatPrivate = function (arg)
		local receiveName = arg:getTeamMemberName()
		if receiveName then
			GlobalEventSystem:Fire(GameEvent.EventWhisperChat,receiveName)
		end
	end
	
	local handleCheck = function (arg)
		local playerId = arg:getTeamMemberId()
		local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Player,playerId)
		if 	entityObject then
			local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
			local entityMgr = GameWorld.Instance:getEntityManager()		
			equipMgr:requestOtherPlayerEquipList(playerId)
			entityMgr:requestOtherPlayer(playerId)
			local equipMgr = GameWorld.Instance:getEntityManager():getHero():getEquipMgr()
			equipMgr:setOtherPlayerEquipList(nil)	--清空列表，防止读到其他玩家信息
			local player = {playerObj=entityObject,playerType =1}	--1: 其他玩家的信息
			GlobalEventSystem:Fire(GameEvent.EventHideAllUI)
			GlobalEventSystem:Fire(GameEvent.EventOpenRoleView, E_ShowOption.eMove2Left,player) 
			GlobalEventSystem:Fire(GameEvent.EVENT_OpenDetailProperty, E_ShowOption.eMove2Right,player)
		else
			UIManager.Instance:showSystemTips(Config.Words[9011])
		end
	end			
	local items = {
	{lable = Config.Words[9000], id = 1, callback = handleChatPrivate, arg = teamMember, disable = false},
	{lable = Config.Words[9001], id = 2, callback = handleCheck, arg = teamMember, disable = false},	
	{lable = Config.Words[9006], id = 3, callback = handleQuitTeam, arg = teamMember, disable = false},
--	{lable = Config.Words[9005], id = 2, callback = handleChangeHeader, arg = teamMember,disable = false},	
	}
	--
	if self.heroId == teamMgr:getTeamLeaderId() then
		items[4]= {lable = Config.Words[9004], id = 4, callback = handleOutTeam, arg = teamMember, disable = false}
		items[5] = {lable = Config.Words[9028], id = 5, callback = disbandTeam, arg = teamMember, disable = false}
		height = 210
	end

	local size = CCSizeMake(95, height)
	UIManager.Instance:showPopupMenu(size, items, self.TeammateHeadframehead[index],ccp(130,-40))
	self.showingPopupMenu = true
end

function MainTeammateHead:updateTeammate(i,teamMember,pos)
	self:updateTeammateHp(i,teamMember)	
end

function MainTeammateHead:updateTeammateHp(i,teamMember)
	if not i or not teamMember then
		return
	end
	local playerHP = teamMember:getTeamMemberHP()
	local playerMaxHP = teamMember:getTeamMemberMaxHP()
	if self.TeammateHP[i]==nil then
		local TeammateHpSprite = createSpriteWithFrameName(RES("main_playerHp.png"))
		self.TeammateHP[i] = CCProgressTimer:create(TeammateHpSprite)
		G_setScale(self.TeammateHp[i])		
		self.TeammateHP[i]:setPercentage(100*(playerHP/playerMaxHP))		
		self.TeammateHeadframehead[i]:addChild(self.TeammateHP[i])			
		VisibleRect:relativePosition(self.TeammateHP[i],self.TeammateHeadframe[i],LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(20,-31))
	else
		self.TeammateHP[i]:setPercentage(100*(playerHP/playerMaxHP))
	end			
end


function MainTeammateHead:createHead(index,teamMember)
	if not index or not teamMember then
		return
	end
	--头像
	local playerId = teamMember:getTeamMemberId()	
	local playerProfession = teamMember:getTeamMemberProfession()
	local playerSex = teamMember:getTeamMemberGender()
		
	local pTable = ProfessionGender_Table
	for i,v in pairs(pTable) do
		local profession = v.tProfession
		local gender = v.tGender
		if profession==playerProfession and playerSex==gender  then
			self.HeadImageName[index] = v.tImage
		end
	end
	
	if self.HeadImageName[index] then
		self.PlayerHeadLayer[index] = CCLayer:create()
		self.PlayerHeadLayer[index] :setContentSize(CCSizeMake(61*self.scale,61*self.scale))
		self.PlayerHeadLayer[index] :setTouchEnabled(true)
		self.TeammateHeadframehead[index]:addChild(self.PlayerHeadLayer[index] )
		VisibleRect:relativePosition(self.PlayerHeadLayer[index] ,self.TeammateHeadframehead[index],LAYOUT_CENTER)
		local headSpr = createScale9SpriteWithFrameName(RES(self.HeadImageName[index]))
		if teamMember:getTeamMemberStatus() ~= 1 then  --离线和死亡皆显示灰色头像
			UIControl:SpriteSetGray(self.TeammateHeadframehead[index])
			UIControl:SpriteSetGray(self.TeammateHeadframe[index])
			headSpr:setColor(ccc3(96,96,96))
		end
		
		self.PlayerHead[index] = createButton(headSpr)	
		g_headScale = 0.6				
		self.PlayerHead[index]:setScaleDef(g_headScale)
		self.PlayerHead[index]:setTouchAreaDelta(0, 85, 2, 2)
		self.rootNode:addChild(self.PlayerHead[index],10)
		VisibleRect:relativePosition(self.PlayerHead[index],self.TeammateHeadframehead[index],LAYOUT_CENTER)
		local PlayerHeadfunc = function ()--按钮			
			GlobalEventSystem:Fire(GameEvent.EventOpenPlayerInteractionView,playerId)
			local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
			teamMgr:requestPlayerTeamStatus(playerId)
		end
		self.PlayerHead[index]:addTargetWithActionForControlEvents(PlayerHeadfunc,CCControlEventTouchDown)
		--self:registerTeammateHeadTouchHandler(self.PlayerHeadLayer[index] ,index,PlayerHeadfunc)
		
	end
end

--玩家死亡
function MainTeammateHead:setTeammateHeadGray(index)
	if not index then
		return
	end
	self.grayHead[index] = createSpriteWithFrameName(self.HeadImageName[index])
	self.grayHead[index]:setScale(g_headScale)
	self.PlayerHead[index]:addChild(self.grayHead[index])
	self.grayHead[index]:setVisible(true)
	VisibleRect:relativePosition(self.grayHead[index],self.grayHead[index],LAYOUT_CENTER)
	
	UIControl:SpriteSetGray(self.TeammateHeadframe[index])
	UIControl:SpriteSetGray(self.TeammateHeadframehead[index])
end

function MainTeammateHead:hideInteractionView()
	local manager =UIManager.Instance
	manager:hideUI("PlayerInteractionView")		
end

local beginPointX = 0
function MainTeammateHead:registerTeammateHeadTouchHandler(node, argIndex, callBackFunc)
	local function ccTouchHandler(eventType, x, y)		
		return self:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, true)
end

function MainTeammateHead:touchHandlerabc(node, eventType, x, y, argIndex, callBackFunc)
	if node:isVisible() and node:getParent() then
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then		
			if eventType == "began" then
				beginPointX = x
				self:ccTouchBegan(argIndex)
			elseif eventType == "ended" then
				local xOffset = beginPointX - x
				if (math.abs(xOffset) < 5) then	--当x坐标偏移在5以内，才认为是点击
					callBackFunc()
				end
				self:ccTouchEnded(argIndex)	
			end								
			return 1					
		else
			if eventType == "began" then		
				--UIManager.Instance:hidePopupMenu()
			end
			if eventType == "ended" then
				self:ccTouchEnded(argIndex)	
			end						
		end				
	else		
		return 0
	end
end

function MainTeammateHead:ccTouchBegan(argIndex)
	if not argIndex then
		return
	end
	local scaleTo = CCScaleTo:create(0.05,0.95*g_headScale)
	if self.PlayerHead[argIndex]  then
		self.PlayerHead[argIndex]:runAction(scaleTo)
	end
end	

function MainTeammateHead:ccTouchEnded(argIndex)
	if not argIndex then
		return
	end
	local scaleTo = CCScaleTo:create(0.05,1*g_headScale)
	if self.PlayerHead[argIndex]  then
		self.PlayerHead[argIndex]:runAction(scaleTo)
	end
end
