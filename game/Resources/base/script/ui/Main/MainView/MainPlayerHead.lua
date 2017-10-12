--人物头像界面
MainPlayerHead = MainPlayerHead or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local ProfessionGender_Table_otherPlayer =
{
[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "main_headManWarior.png", tOffset = ccp(0,7)},
[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "main_headFemanWarior.png", tOffset = ccp(0,9)},
[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "main_headManMagic.png", tOffset = ccp(2,8)},
[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "main_headFemanMagic.png", tOffset = ccp(1,6)},
[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "main_headManDaoshi.png", tOffset = ccp(2,12)},
[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "main_headFemanDaoshi.png", tOffset = ccp(0,14)}
}

function MainPlayerHead:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)	
	self.scale = VisibleRect:SFGetScale()		
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self:showView()
end

function MainPlayerHead:__delete()
	self.playerId = nil
	self.playerType = nil
end

function MainPlayerHead:onEnter(arg)
	if arg then
		self.playerId = arg:getId()
		self.playerType = arg:getType()
	end
	self:CountTime()
	self:Update()	
end

function MainPlayerHead:getRootNode()
	return self.rootNode
end

function MainPlayerHead:showView()
	--hpBottom
	local hpBottom = createScale9SpriteWithFrameNameAndSize(RES("main_playerHpBg.png"),CCSizeMake(78,8))	
	self.rootNode:addChild(hpBottom)
		
	--HP					
	local headHPSprite = createSpriteWithFrameName(RES("main_playerHp.png"))									
	self.HP = CCProgressTimer:create(headHPSprite)	
	self.HP:setScaleX(26)				
	self.HP:setType(kCCProgressTimerTypeBar)		
	self.HP:setMidpoint(ccp(1,0))
	self.HP:setBarChangeRate(ccp(1,0))	
	self.HP:setAnchorPoint(ccp(0,0.5))	
	self.rootNode:addChild(self.HP)
	
	--英雄面板
	self.playerHeadframehead =  createSpriteWithFrameName(RES("main_playerHead.png"))
	G_setScale(self.playerHeadframehead)
	self.rootNode:addChild(self.playerHeadframehead)	
	self.playerHeadframe = createSpriteWithFrameName(RES("main_playerFrame.png"))	
	G_setScale(self.playerHeadframe)
	self.rootNode:addChild(self.playerHeadframe)	
		
	--等级
	--self.playerLevel = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size1")*self.scale,FCOLOR("ColorYellow4"))	
	--self.rootNode:addChild(self.playerLevel)
	
	--人物名称
	self.playerName = createLabelWithStringFontSizeColorAndDimension("","Arial",FSIZE("Size2")*self.scale,FCOLOR("ColorWhite1"))
	self.playerName:setAnchorPoint(ccp(1,0.5))
	self.rootNode:addChild(self.playerName)		
			
	VisibleRect:relativePosition(self.playerHeadframe,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(300,-30))				
	VisibleRect:relativePosition(self.playerHeadframehead,self.playerHeadframe,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y,ccp(-13,-3))	
	VisibleRect:relativePosition(hpBottom,self.playerHeadframe,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(26,-21))	
	VisibleRect:relativePosition(self.HP,self.playerHeadframe,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(26,-21))	
	VisibleRect:relativePosition(self.playerName,self.playerHeadframe,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-12,-7))
	--VisibleRect:relativePosition(self.playerLevel,self.playerHeadframe,LAYOUT_TOP_INSIDE+LAYOUT_CENTER_X,ccp(70,-47))
	--VisibleRect:relativePosition(PlayerHead,self.playerHeadframe,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(-2,22))	
end

--更新数据
function MainPlayerHead:Update()
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
	if not entityObject then
		return
	end	
	self:UpdateHP()
	self:UpdateLevel()
	self:UpdateName()
	self:UpdateHead()
end

function MainPlayerHead:UpdateHP()
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
	local propertyTable = entityObject:getPT()
	local playerHP = PropertyDictionary:get_HP(propertyTable)
	local playerMaxHP = PropertyDictionary:get_maxHP(propertyTable)
	if playerHP < 0 then
		playerHP = 0
	end
	if playerMaxHP < 0 then
		playerMaxHP = 1
	end
	if playerHP == 0 then	--玩家死亡
		self:hideInteractionView()
	end
	
	if self.HP==nil then
		local headHPSprite = createSpriteWithFrameName(RES("main_playerHp.png"))									
		self.HP = CCProgressTimer:create(headHPSprite)	
		self.HP:setScaleX(45)				
		self.HP:setType(kCCProgressTimerTypeBar)		
		self.HP:setMidpoint(ccp(0,0))
		self.HP:setBarChangeRate(ccp(1,0))	
		self.HP:setAnchorPoint(ccp(0,0.5))	
		self.rootNode:addChild(self.HP)
		VisibleRect:relativePosition(self.HP,self.playerHeadframe,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(42,-14))
		local percentage = playerHP/playerMaxHP*100
		self.HP:setPercentage(percentage)
	else		
		local percentage = playerHP/playerMaxHP*100
		self.HP:setPercentage(percentage)
	end
end	

function MainPlayerHead:UpdateLevel()
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
	local propertyTable = entityObject:getPT()
	local playerLevel = PropertyDictionary:get_level(propertyTable)
	if self.playerLevel==nil then
		self.playerLevel = createLabelWithStringFontSizeColorAndDimension("","Arial",11*self.scale,ccc3(255,255,255))	
		self.rootNode:addChild(self.playerLevel)
	end		
	if playerLevel then
		self.playerLevel:setString(playerLevel)
	end
	
end

function MainPlayerHead:UpdateName()
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
	local propertyTable = entityObject:getPT()
	local playerName = PropertyDictionary:get_name(propertyTable) 
	if self.playerName==nil then
		self.playerName = createLabelWithStringFontSizeColorAndDimension("","Arial",16*self.scale,ccc3(255,255,255))	
		self.rootNode:addChild(self.playerName)		
	end
	if playerName then
		self.playerName:setString(playerName)
	end			
end

function MainPlayerHead:showInteractionView()	
	GlobalEventSystem:Fire(GameEvent.EventOpenPlayerInteractionView,self.playerId)
end

function MainPlayerHead:hideInteractionView()
	local manager =UIManager.Instance
	manager:hideUI("PlayerInteractionView")	
	--self.rootNode:removeFromParentAndCleanup(true)
end

function MainPlayerHead:UpdateHead()
	--头像
	local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
	local propertyTable = entityObject:getPT()
	local PlayerProfession = PropertyDictionary:get_professionId(propertyTable)
	local PlayerSex = PropertyDictionary:get_gender(propertyTable)
	local HeadImageName
	local Offset 	
	for i,v in pairs(ProfessionGender_Table_otherPlayer) do
		local profession = v.tProfession
		local gender = v.tGender
		if profession==PlayerProfession and PlayerSex==gender then
			HeadImageName = v.tImage
			Offset = v.tOffset
		end
	end		
	if HeadImageName then
		if self.PlayerHead then
			self.PlayerHead:removeFromParentAndCleanup(true)
		end
		self.PlayerHead = createButtonWithFramename(RES(HeadImageName))
		if self.PlayerHead then
			self.PlayerHead:setTouchAreaDelta(85,0,0,0)		
			self.PlayerHead:setScaleDef(0.38)
			self.rootNode:addChild(self.PlayerHead)
			VisibleRect:relativePosition(self.PlayerHead,self.playerHeadframehead,LAYOUT_CENTER,Offset)
			local PlayerHeadfunc = function ()--按钮					
				self:CountTime()
				local entityObject = GameWorld.Instance:getEntityManager():getEntityObject(self.playerType,self.playerId)
				if entityObject == nil then
					UIManager.Instance:showSystemTips(Config.Words[9011])			
					return
				end
				self.selectEntityObject = entityObject
				self:showInteractionView()
				local teamMgr = GameWorld.Instance:getEntityManager():getHero():getTeamMgr()
				teamMgr:requestPlayerTeamStatus(self.playerId)
			end
			self.PlayerHead:addTargetWithActionForControlEvents(PlayerHeadfunc,CCControlEventTouchDown)
		end
	end
end

function MainPlayerHead:CountTime()
	self.rootNode:stopAction(self.sequence)
	local TimeFunc = function ()
		self:hideInteractionView()
	end		
	local ccfunc = CCCallFunc:create(TimeFunc)
	local delay = CCDelayTime:create(60)
	self.sequence = CCSequence:createWithTwoActions(delay,ccfunc)
	self.rootNode:runAction(self.sequence)	
end

function MainPlayerHead:getPlayId()
	return self.playerId
end