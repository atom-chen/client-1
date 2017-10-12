--申请成员信息界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
FactionApplyInfoView = FactionApplyInfoView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function FactionApplyInfoView:__init()
	self.viewName = "FactionApplyInfoView"
	self:initWithBg(CCSizeMake(457,288),RES("suqares_goldFrameBg.png"),true)
	self:initStaticInfo()
	self:initBtn()
	self:initBtnEvent()
	self.openFlag = false
end

function FactionApplyInfoView:__delete()

end
function FactionApplyInfoView:onEnter()
	if self.openFlag == true then
		self:refreshApplyInfo()
	end
end
function FactionApplyInfoView:onExit()
	self.openFlag = true
end
function FactionApplyInfoView:create()
	return FactionApplyInfoView.New()
end

function FactionApplyInfoView:initStaticInfo()		--成员信息
	local playerInfoLb = createSpriteWithFrameName(RES("word_tip_memInfo.png"))
	local playerInfoBg = createScale9SpriteWithFrameNameAndSize(RES("squares_roleNameBg.png"),CCSizeMake(386*g_scale,45*g_scale))
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.applyPlayerInfo = factionMgr:getApplyPlayerInfo()
	if self.applyPlayerInfo then
		self.charId = self.applyPlayerInfo.charId
		self.playerName = self.applyPlayerInfo.name
		self.nameLb = createLabelWithStringFontSizeColorAndDimension(self.playerName,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		local professsionId = self.applyPlayerInfo.professsionId
		local professsionName = G_getProfessionNameById(professsionId)
		self.professsionLb = createLabelWithStringFontSizeColorAndDimension(professsionName,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		self.levelLb = createLabelWithStringFontSizeColorAndDimension(self.applyPlayerInfo.level,"Arial", FSIZE("Size2")*g_scale, FCOLOR("ColorWhite2"))
		self.applyLb = createSpriteWithFrameName(RES("word_button_apply.png"))
		self.rootNode : addChild(playerInfoLb)
		self.rootNode : addChild(playerInfoBg)
		self.rootNode : addChild(self.applyLb)
		playerInfoBg:addChild(self.nameLb)
		playerInfoBg:addChild(self.professsionLb)
		playerInfoBg:addChild(self.levelLb)
		VisibleRect:relativePosition(playerInfoLb,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-15))
		VisibleRect:relativePosition(playerInfoBg,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-47))
		VisibleRect:relativePosition(self.applyLb,playerInfoBg,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(-E_OffsetView.eWidth,-15))
		VisibleRect:relativePosition(self.nameLb,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
		VisibleRect:relativePosition(self.professsionLb,self.nameLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		VisibleRect:relativePosition(self.levelLb,self.professsionLb,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(30,0))
		local vipType = self.applyPlayerInfo.vipType				
		if vipType and vipType>0 then
			self.vipIcon = createSpriteWithFrameName(RES("common_vip"..vipType..".png"))
			playerInfoBg:addChild(self.vipIcon)
			VisibleRect:relativePosition(self.vipIcon,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
			VisibleRect:relativePosition(self.nameLb,self.vipIcon,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(3,0))
		else
			VisibleRect:relativePosition(self.nameLb,playerInfoBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y,ccp(20,0))
		end
	end		
end

function FactionApplyInfoView:initBtn()
	self.agreeBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	self.rejectBtn = createButtonWithFramename(RES("btn_3_select.png"), RES("btn_3_select.png"))
	self.chatBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.infoBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	self.inviteBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local agreeBtnLb =  createSpriteWithFrameName(RES("word_button_agree.png"))
	local rejectBtnLb =  createSpriteWithFrameName(RES("word_button_reject.png"))		
	local chatBtnLb = createSpriteWithFrameName(RES("word_button_chat.png"))	
	local infoBtnLb = createSpriteWithFrameName(RES("word_button_checkInfo.png"))	
	local inviteBtnLb = createSpriteWithFrameName(RES("word_button_invite.png"))	
	self.agreeBtn : setTitleString(agreeBtnLb)
	self.rejectBtn : setTitleString(rejectBtnLb)
	self.chatBtn : setTitleString(chatBtnLb)
	self.infoBtn : setTitleString(infoBtnLb)
	self.inviteBtn : setTitleString(inviteBtnLb)		
	self.rootNode : addChild(self.agreeBtn)
	self.rootNode : addChild(self.rejectBtn)	
	self.rootNode : addChild(self.chatBtn)
	self.rootNode : addChild(self.infoBtn)
	self.rootNode : addChild(self.inviteBtn)		
	VisibleRect:relativePosition(self.agreeBtn,self.applyLb,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(0,-5))
	VisibleRect:relativePosition(self.rejectBtn,self.agreeBtn,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(16,0))	
	VisibleRect:relativePosition(self.infoBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(24,-100))
	VisibleRect:relativePosition(self.chatBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-24,-40))
	VisibleRect:relativePosition(self.inviteBtn,self.chatBtn,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-5))
end

function FactionApplyInfoView:initBtnEvent()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
	local factionName = factionMgr:getFactionInfo().factionName
	local applyIndex = factionMgr:getApplyIndex()
	local agreeFunction = function()			--同意按钮
		if applyIndex then
			if self.charId  and factionName then
				factionMgr:requestHandleApply(self.charId,factionName,"1")
				factionMgr:setHandlerIndex(applyIndex)
				UIManager.Instance:showLoadingHUD(10,node)
			end
		end
	end
	self.agreeBtn:addTargetWithActionForControlEvents(agreeFunction,CCControlEventTouchDown)
	local rejectFunction = function()			--拒绝按钮
		if applyIndex then
			if self.charId and factionName then
				factionMgr:requestHandleApply(self.charId,factionName,"0")
				factionMgr:setHandlerIndex(applyIndex)
				UIManager.Instance:showLoadingHUD(10,node)
			end
		end
	end
	self.rejectBtn:addTargetWithActionForControlEvents(rejectFunction,CCControlEventTouchDown)
	
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
end

function FactionApplyInfoView:refreshApplyInfo()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	self.applyPlayerInfo = factionMgr:getApplyPlayerInfo()
	if self.applyPlayerInfo then
		self.charId = self.applyPlayerInfo.charId
		self.playerName = self.applyPlayerInfo.name
		self.nameLb : setString(self.playerName)
		local professsionId = self.applyPlayerInfo.professsionId
		local professsionName = G_getProfessionNameById(professsionId)
		self.professsionLb : setString(professsionName)
		self.levelLb : setString(self.applyPlayerInfo.level)
	end
end