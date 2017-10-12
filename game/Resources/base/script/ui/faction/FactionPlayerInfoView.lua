--成员信息界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require ("object.faction.MemberObject")
FactionPlayerInfoView = FactionPlayerInfoView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function FactionPlayerInfoView:__init()
	self.viewName = "FactionPlayerInfoView"
	self:initWithBg(CCSizeMake(457,288),RES("suqares_goldFrameBg.png"),true)
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	self.factionInfo = factionMgr:getFactionInfo()	
	self.chairmanFlag = factionMgr:isChairMan()	
	self.openFlag = false	
	self:initStaticInfo()
	self:initBtn()
	self:initBtnEvent()
end

function FactionPlayerInfoView:__delete()
	self.playerInfo:DeleteMe()
end

function FactionPlayerInfoView:onEnter()
	if self.openFlag == true then
		self:refreshPlayerInfo()
	end
	self:refreshOffice()
end
function FactionPlayerInfoView:onExit()
	self.openFlag = true
end

function FactionPlayerInfoView:create()
	return FactionPlayerInfoView.New()
end

function FactionPlayerInfoView:initStaticInfo()
	local playerInfoLb = createSpriteWithFrameName(RES("word_tip_memInfo.png"))
	local playerInfoBg = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(386*g_scale,45*g_scale))
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.playerInfo = factionMgr:getPlayerInfo()
	if self.playerInfo then
		self.charId = self.playerInfo:getCharId()
		self.playerName = self.playerInfo:getMemName()
		self.nameLb = createLabelWithStringFontSizeColorAndDimension(self.playerName,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		local professsionId = self.playerInfo:getProfesssionId()
		local professsionName = G_getProfessionNameById(professsionId)
		self.professsionLb = createLabelWithStringFontSizeColorAndDimension(professsionName,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		self.levelLb = createLabelWithStringFontSizeColorAndDimension(self.playerInfo:getLevel(),"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		self.fightValueLb = createLabelWithStringFontSizeColorAndDimension(self.playerInfo:getFightValue(),"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		self.officeId = self.playerInfo:getOffice()
		local officeName = self:getOfficeNameById(self.officeId)
		if officeName then
			self.officeLb = createLabelWithStringFontSizeColorAndDimension(officeName,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		else
			self.officeLb = createLabelWithStringFontSizeColorAndDimension(" ","Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		end
		local isOnline = self.playerInfo:getOnline()
		if isOnline == "0" then
			self.nameLb:setColor(FCOLOR("black4"))
			self.professsionLb:setColor(FCOLOR("black4"))
			self.levelLb:setColor(FCOLOR("black4"))
			self.fightValueLb:setColor(FCOLOR("black4"))
			self.officeLb:setColor(FCOLOR("black4"))
		end
		playerInfoBg:addChild(self.nameLb)
		playerInfoBg:addChild(self.professsionLb)
		playerInfoBg:addChild(self.levelLb)
		playerInfoBg:addChild(self.fightValueLb)
		playerInfoBg:addChild(self.officeLb)
		VisibleRect:relativePosition(self.nameLb,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
		VisibleRect:relativePosition(self.professsionLb,self.nameLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		VisibleRect:relativePosition(self.levelLb,self.professsionLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		VisibleRect:relativePosition(self.fightValueLb,self.levelLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		VisibleRect:relativePosition(self.officeLb,self.fightValueLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		local vipType = self.playerInfo:getVipType()				
		if vipType and vipType>0 then
			self.vipIcon = createSpriteWithFrameName(RES("common_vip"..vipType..".png"))
			playerInfoBg:addChild(self.vipIcon)
			VisibleRect:relativePosition(self.vipIcon,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
			VisibleRect:relativePosition(self.nameLb,self.vipIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(3,0))
		else
			VisibleRect:relativePosition(self.nameLb,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
		end
	end
	self.upgradeLb = createLabelWithStringFontSizeColorAndDimension(Config.Words[5528], "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow7"))
	self.rootNode : addChild(playerInfoLb)
	self.rootNode : addChild(playerInfoBg)
	self.rootNode : addChild(self.upgradeLb)	
	VisibleRect:relativePosition(playerInfoLb,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-15))
	VisibleRect:relativePosition(playerInfoBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-47))
	VisibleRect:relativePosition(self.upgradeLb,playerInfoBg,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(-E_OffsetView.eWidth,-15))
	
end

function FactionPlayerInfoView:initBtn()
	self.chairmanBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	self.unChairmanBtn = createSpriteWithFrameName(RES("btn_3_select.png"), RES("btn_3_select.png"))
	UIControl:SpriteSetGray(self.unChairmanBtn)
	self.lieutenantBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	self.unLieutenantBtn = createSpriteWithFrameName(RES("btn_3_select.png"), RES("btn_3_select.png"))
	UIControl:SpriteSetGray(self.unLieutenantBtn)
	self.eliteBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	self.unEliteBtn = createSpriteWithFrameName(RES("btn_3_select.png"), RES("btn_3_select.png"))
	UIControl:SpriteSetGray(self.unEliteBtn)
	self.exclusionBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.unExclusionBtn = createSpriteWithFrameName(RES("btn_1_select.png"), RES("btn_1_select.png"))
	UIControl:SpriteSetGray(self.unExclusionBtn)
	self.chatBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.infoBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.inviteBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
	local chairmanBtnLb = createSpriteWithFrameName(RES("word_button_chairman.png"))
	local unChairmanBtnLb = createSpriteWithFrameName(RES("word_button_chairman.png"))
	UIControl:SpriteSetGray(unChairmanBtnLb)
	local lieutenantBtnLb = createSpriteWithFrameName(RES("word_button_lieutenant.png"))
	local unLieutenantBtnLb = createSpriteWithFrameName(RES("word_button_lieutenant.png"))
	UIControl:SpriteSetGray(unLieutenantBtnLb)
	local eliteBtnLb =  createSpriteWithFrameName(RES("word_button_member.png"))
	local unEliteBtnLb =  createSpriteWithFrameName(RES("word_button_member.png"))
	UIControl:SpriteSetGray(unEliteBtnLb)
	local exclusionBtnLb = createSpriteWithFrameName(RES("word_button_kickOut.png"))	
	local unExclusionBtnLb = createSpriteWithFrameName(RES("word_button_kickOut.png"))
	UIControl:SpriteSetGray(unExclusionBtnLb)
	local chatBtnLb = createSpriteWithFrameName(RES("word_button_chat.png"))	
	local infoBtnLb = createSpriteWithFrameName(RES("word_button_checkInfo.png"))	
	local inviteBtnLb = createSpriteWithFrameName(RES("word_button_invite.png"))	
	self.chairmanBtn : setTitleString(chairmanBtnLb)
	self.unChairmanBtn:addChild(unChairmanBtnLb)
	self.lieutenantBtn : setTitleString(lieutenantBtnLb)
	self.unLieutenantBtn:addChild(unLieutenantBtnLb)
	self.eliteBtn : setTitleString(eliteBtnLb)
	self.unEliteBtn:addChild(unEliteBtnLb)
	self.exclusionBtn : setTitleString(exclusionBtnLb)
	self.unExclusionBtn:addChild(unExclusionBtnLb)
	self.chatBtn : setTitleString(chatBtnLb)
	self.infoBtn : setTitleString(infoBtnLb)
	self.inviteBtn : setTitleString(inviteBtnLb)
	self.rootNode : addChild(self.chairmanBtn)
	self.rootNode : addChild(self.unChairmanBtn)
	self.rootNode : addChild(self.lieutenantBtn)
	self.rootNode : addChild(self.unLieutenantBtn)
	self.rootNode : addChild(self.eliteBtn)
	self.rootNode : addChild(self.unEliteBtn)
	self.rootNode : addChild(self.exclusionBtn)
	self.rootNode : addChild(self.unExclusionBtn)
	self.rootNode : addChild(self.chatBtn)
	self.rootNode : addChild(self.infoBtn)
	self.rootNode : addChild(self.inviteBtn)
	VisibleRect:relativePosition(self.chairmanBtn,self.upgradeLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.unChairmanBtn,self.upgradeLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(unChairmanBtnLb,self.unChairmanBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.lieutenantBtn,self.chairmanBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(16,0))
	VisibleRect:relativePosition(self.unLieutenantBtn,self.chairmanBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(16,0))
	VisibleRect:relativePosition(unLieutenantBtnLb,self.unLieutenantBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.eliteBtn,self.lieutenantBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(16,0))
	VisibleRect:relativePosition(self.unEliteBtn,self.lieutenantBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(16,0))
	VisibleRect:relativePosition(unEliteBtnLb,self.unEliteBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.exclusionBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(24,-40))
	VisibleRect:relativePosition(self.unExclusionBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(20,-40))
	VisibleRect:relativePosition(unExclusionBtnLb,self.unExclusionBtn,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.chatBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-24,-40))
	VisibleRect:relativePosition(self.infoBtn,self.exclusionBtn,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.inviteBtn,self.chatBtn,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-5))
	if self.chairmanFlag == true then
		self.chairmanBtn:setVisible(true)
		self.lieutenantBtn:setVisible(true)
		self.eliteBtn:setVisible(true)
		self.exclusionBtn:setVisible(true)
		self.unChairmanBtn:setVisible(false)
		self.unLieutenantBtn:setVisible(false)
		self.unEliteBtn:setVisible(false)
		self.unExclusionBtn:setVisible(false)
	elseif self.chairmanFlag == false then
		self.chairmanBtn:setVisible(false)
		self.lieutenantBtn:setVisible(false)
		self.eliteBtn:setVisible(false)
		self.exclusionBtn:setVisible(false)
		self.unChairmanBtn:setVisible(true)
		self.unLieutenantBtn:setVisible(true)
		self.unEliteBtn:setVisible(true)
		self.unExclusionBtn:setVisible(true)
	end
end

function FactionPlayerInfoView:initBtnEvent()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local factionName = factionMgr:getFactionInfo().factionName
	
	local upGradeChairManFunc = function(arg,text,id)		--改会长职位	
		if id == 2 then
			if self.charId and factionName then
				factionMgr:requestUpgradeOffice(self.charId,factionName,"1")
				self.officeId = 1
				factionMgr:setOffice(1)
				local factionInfo = factionMgr:getFactionInfo()
				factionInfo.chairManName = self.playerName
				factionMgr:setFactionInfo(factionInfo.factionName,factionInfo.chairManName,factionInfo.memNum)
			end
		end
	end
	local upGradeChairManFunction = function()	
		local msg = showMsgBox(Config.Words[5561],E_MSG_BT_ID.ID_CANCELAndOK)			
		msg:setNotify(upGradeChairManFunc)	
	end		
	self.chairmanBtn:addTargetWithActionForControlEvents(upGradeChairManFunction,CCControlEventTouchDown)

	local upGradeLieutenantFunction = function()		--改副会长职位
		if self.charId  and factionName then
			self.playerInfo = factionMgr:getPlayerInfo()
			self.officeId = self.playerInfo:getOffice()
			if self.officeId then
				if self.officeId == 2 then
					UIManager.Instance:showSystemTips(Config.Words[5554])
				else
					factionMgr:requestUpgradeOffice(self.charId,factionName,"2")
					self.officeId = 2
					factionMgr:setOffice(2)
					self.playerInfo.office = 2
					factionMgr:setPlayerInfo(self.playerInfo)
				end
			end	
		end
	end
	self.lieutenantBtn:addTargetWithActionForControlEvents(upGradeLieutenantFunction,CCControlEventTouchDown)
	
	local upGradeEliteFunction = function()				--改帮众职位
		if self.charId and factionName then 
			self.playerInfo = factionMgr:getPlayerInfo()
			self.officeId = self.playerInfo:getOffice()
			if self.officeId == 3 then
				UIManager.Instance:showSystemTips(Config.Words[5554])
			else
				factionMgr:requestUpgradeOffice(self.charId,factionName,"3")
				self.officeId = 3
				factionMgr:setOffice(3)
				self.playerInfo.office = 3
				factionMgr:setPlayerInfo(self.playerInfo)
			end
		end
	end
	self.eliteBtn:addTargetWithActionForControlEvents(upGradeEliteFunction,CCControlEventTouchDown)
	
	local kickOutFaction = function(arg,text,id)
		if id == 2 then
			if self.charId and factionName then
				UIManager.Instance:showLoadingHUD(10,self.rootNode)
				factionMgr:requestKickOutPlayer(self.charId,factionName)	
			end
		end
	end
	local kickOutFactionFunction = function()			--踢出公会按钮
		local msg = showMsgBox(Config.Words[5555],E_MSG_BT_ID.ID_CANCELAndOK)			
		msg:setNotify(kickOutFaction)	
	end
	
	self.exclusionBtn:addTargetWithActionForControlEvents(kickOutFactionFunction,CCControlEventTouchDown)	
	
	local checkPlayerProperty = function()		--查看信息按钮
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		if self.charId then
			factionMgr:checkPlayerProperty(self.charId)
		end		
	end
	self.infoBtn:addTargetWithActionForControlEvents(checkPlayerProperty,CCControlEventTouchDown)	

	local chatToPlayer = function()		--私聊按钮
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		if self.playerName then
			factionMgr:chatToPlayer(self.playerName)
		end		
	end
	self.chatBtn:addTargetWithActionForControlEvents(chatToPlayer,CCControlEventTouchDown)
	
	local inviteFunction = function()			--组队
		local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
		teamMgr:requestAssembleTeam(self.charId) --组队邀请
	end	
	self.inviteBtn:addTargetWithActionForControlEvents(inviteFunction,CCControlEventTouchDown)	
end

function FactionPlayerInfoView:getOfficeNameById(officeId)
	if officeId == 1 then
		return Config.Words[5529]
	elseif officeId == 2 then
		return Config.Words[5530]
	elseif officeId == 3 then
		return Config.Words[5531]
	end
end

function FactionPlayerInfoView:refreshOffice()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	if self.officeId then
		local officeName = self:getOfficeNameById(self.officeId)
		self.officeLb:setString(officeName)
	end
	self.chairmanFlag = factionMgr:isChairMan()	
	if self.chairmanFlag == false then
		self.chairmanBtn:setVisible(false)
		self.lieutenantBtn:setVisible(false)
		self.eliteBtn:setVisible(false)
		self.exclusionBtn:setVisible(false)
		self.unChairmanBtn:setVisible(true)
		self.unLieutenantBtn:setVisible(true)
		self.unEliteBtn:setVisible(true)
		self.unExclusionBtn:setVisible(true)
	else
		self.chairmanBtn:setVisible(true)
		self.lieutenantBtn:setVisible(true)
		self.eliteBtn:setVisible(true)
		self.exclusionBtn:setVisible(true)
		self.unChairmanBtn:setVisible(false)
		self.unLieutenantBtn:setVisible(false)
		self.unEliteBtn:setVisible(false)
		self.unExclusionBtn:setVisible(false)
	end
end

function FactionPlayerInfoView:refreshPlayerInfo()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.playerInfo = factionMgr:getPlayerInfo()	
	if self.playerInfo then
		self.charId = self.playerInfo:getCharId()
		self.playerName = self.playerInfo:getMemName()
		self.nameLb:setString(self.playerName)
		local professsionId = self.playerInfo:getProfesssionId()
		local professsionName = G_getProfessionNameById(professsionId)
		self.professsionLb:setString(professsionName)
		self.levelLb : setString(self.playerInfo:getLevel())
		self.fightValueLb : setString(self.playerInfo:getFightValue())
		self.officeId = self.playerInfo:getOffice()
		local officeName = self:getOfficeNameById(self.officeId)
		if officeName then
			self.officeLb : setString(officeName)
		else
			self.officeLb : setString(" ")
		end
		local isOnline = self.playerInfo:getOnline()
		if isOnline == "0" then
			self.nameLb:setColor(FCOLOR("black4"))
			self.professsionLb:setColor(FCOLOR("black4"))
			self.levelLb:setColor(FCOLOR("black4"))
			self.fightValueLb:setColor(FCOLOR("black4"))
			self.officeLb:setColor(FCOLOR("black4"))
		end
	end
end