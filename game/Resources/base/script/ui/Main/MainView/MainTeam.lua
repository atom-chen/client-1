--邮件界面
MainTeam = MainTeam or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

function MainTeam:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)	
	self.scale = VisibleRect:SFGetScale()
	
	self.viewNode = CCLayer:create()
	self.viewNode:setContentSize(visibleSize)
	self.rootNode:addChild(self.viewNode)
	
	self.showBtn = true				
	self:showView()
end

function MainTeam:__delete()

end

function MainTeam:getRootNode()
	return self.rootNode
end

function MainTeam:showView()
	local offectX = 0		
	--组队邀请
	self.Btn_team = createButtonWithFramename(RES("main_pk.png"))	
	self.Btn_team:setScale(self.scale)	
	self.Btn_team:setTitleString(createSpriteWithFrameName(RES("main_together.png")))
	self.rootNode:addChild(self.Btn_team)
	VisibleRect:relativePosition(self.Btn_team,self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(0,-330))
	self.teamInviteNum = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2") * const_scale,FCOLOR("ColorGreen2"))
	self.Btn_team:addChild(self.teamInviteNum)
	VisibleRect:relativePosition(self.teamInviteNum,self.Btn_team,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(1,-1))
	local Btn_instancefunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventOpenTeamInviteView)
	end
	self.Btn_team:addTargetWithActionForControlEvents(Btn_instancefunc,CCControlEventTouchUpInside)
	self.Btn_team:setVisible(false)	
	--公会邀请
	self.Btn_faction = createButtonWithFramename(RES("main_pk.png"))
	self.Btn_faction:setScale(self.scale)	
	self.Btn_faction:setTitleString(createSpriteWithFrameName(RES("main_sociaty.png")))
	self.rootNode:addChild(self.Btn_faction)
	VisibleRect:relativePosition(self.Btn_faction,self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, CCPointMake(0, -380))
	self.teamInviteNum = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2") * const_scale,FCOLOR("ColorGreen2"))
	self.Btn_faction:addChild(self.teamInviteNum)
	VisibleRect:relativePosition(self.teamInviteNum,self.Btn_faction,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(1,-1))
	local Btn_instancefunc = function ()	
		GlobalEventSystem:Fire(GameEvent.EventOpenFactionInviteView)
	end
	self.Btn_faction:addTargetWithActionForControlEvents(Btn_instancefunc,CCControlEventTouchUpInside)
	self.Btn_faction:setVisible(false)		
	
end			

function MainTeam:setFactionBtnStatus(boole)
	if self.Btn_faction then
		self.Btn_faction:setVisible(boole)
	end		
	if boole then
		local scaleTo = CCScaleTo:create(0.3,1.5)
		local scaleBack = CCScaleTo:create(0.3,1)
		local actionArray = CCArray:create()
		actionArray:addObject(scaleTo)	
		actionArray:addObject(scaleBack)
		local repeatForever = CCRepeatForever:create(CCSequence:create(actionArray))
		self.Btn_faction:runAction(repeatForever)	
	else
		self.Btn_faction:stopAllActions()
	end					
end

function MainTeam:setTeamInviteBtnStatus(boole)
	if self.Btn_team then
		self.Btn_team:setVisible(boole)		
	end
	if boole then
		local scaleTo = CCScaleTo:create(0.3,1.5)
		local scaleBack = CCScaleTo:create(0.3,1)
		local actionArray = CCArray:create()
		actionArray:addObject(scaleTo)	
		actionArray:addObject(scaleBack)
		local repeatForever = CCRepeatForever:create(CCSequence:create(actionArray))
		self.Btn_team:runAction(repeatForever)	
	else
		self.Btn_team:stopAllActions()
	end		
end