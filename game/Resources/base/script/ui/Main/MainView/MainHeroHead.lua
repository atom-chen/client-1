--[[
人物头像界面
--]]
require("common.baseclass")
require("ui.Main.MainView.MainHeroState")
require("utils.GameUtil")
MainHeroHead = MainHeroHead or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_hpSize = CCSizeMake(155,22)
local g_mpSize = CCSizeMake(130,22)

ProfessionGender_Table =
{
[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "main_headManWarior.png", tOffset = ccp(-81,0)},
[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "main_headFemanWarior.png", tOffset = ccp(-74,6)},
[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "main_headManMagic.png", tOffset = ccp(-79,-2)},
[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "main_headFemanMagic.png", tOffset = ccp(-80,3)},
[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "main_headManDaoshi.png", tOffset = ccp(-80,10)},
[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "main_headFemanDaoshi.png", tOffset = ccp(-81,11)}
}

function MainHeroHead:__init(role)
	self.heroStateIcon = 
	{
		[E_HeroPKState.statePeace] = {icon = "main_peace.png" },
		[E_HeroPKState.stateQueue] = {icon = "main_together.png" },
		[E_HeroPKState.stateFaction] = {icon = "main_sociaty.png"},
		[E_HeroPKState.stateGoodOrEvil] = {icon = "main_goodAndEvil.png"},
		[E_HeroPKState.stateWhole] = {icon = "main_whole.png"},
	
	}	
	self.currentVipLevel = 0
	self.stateId = 0
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)	
	self.scale = VisibleRect:SFGetScale()
	if role then
		self.hero = role
	else
		self.hero = GameWorld.Instance:getEntityManager():getHero()
	end
	self.questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()

	self:saveUpdateData()
	self:showView()
	self:initHeroNearby()
end

function MainHeroHead:__delete()

end

function MainHeroHead:getRootNode()
	return self.rootNode
end

function MainHeroHead:saveUpdateData()
	self.level = 0
end

function MainHeroHead:showView()
	--HPbottom
	self.hpBottom = createScale9SpriteWithFrameNameAndSize(RES("main_commonbottom.png"),g_hpSize)	
	self.rootNode:addChild(self.hpBottom)	
	--MPbottom
	self.mpBottom = createScale9SpriteWithFrameNameAndSize(RES("main_commonbottom.png"),g_mpSize)	
	self.rootNode:addChild(self.mpBottom)
	
	--HP
	self:UpdateHP()
	
	--MP
	self:UpdateMP()
	
	
	--英雄面板
	self.heroHeadFrame = createScale9SpriteWithFrameName(RES("main_heroheadframe.png"))
	G_setScale(self.heroHeadFrame)
	self.rootNode:addChild(self.heroHeadFrame)
	
	--人物名称
	local nameValue = PropertyDictionary:get_name(self.hero:getPT())
	self.heroName = createLabelWithStringFontSizeColorAndDimension(nameValue,"Arial",FSIZE("Size3")*self.scale,ccc3(255,255,255))
	
	self.rootNode:addChild(self.heroName)
	
	--等级
	self:UpdateLevel()
	
	--人物头像	
	local HeadName,headOffset = self:getHeadName(self.hero:getPT())
	if not HeadName  or not headOffset then	
		HeadName = "main_headManWarior.png"
		headOffset = ccp(-83,3)		
	end
	
	self.heroHead = createButtonWithFramename(RES(HeadName))
	self.heroHead:setTouchAreaDelta(50, 0, 30, 0)
	local size =  self.heroHead:getContentSize()	
	--self.heroHead:setScaleDef(0.9)
	--G_setScale(heroHead)	
	self.rootNode:addChild(self.heroHead)
	local heroHeadfunc = function ()--按钮
		self:clickHeadBtn()
	end
	self.heroHead:addTargetWithActionForControlEvents(heroHeadfunc,CCControlEventTouchDown)
	
	--人物状态
	self:initHeroState()
	--Vip
	self.heroVip = createButtonWithFramename(RES("main_vipgrey.png"))
	self.heroVip:setTouchAreaDelta(0, 130, 10, 50)
	local vipMgr = GameWorld.Instance:getVipManager()
	local vipLevel = vipMgr:getVipLevel()
	self:setVipIcon(vipLevel)
	G_setScale(self.heroVip )
	self.rootNode:addChild(self.heroVip )
	local heroVipfunc = function ()--Vip按钮
		GlobalEventSystem:Fire(GameEvent.EventVipViewOpen)	
	end
	self.heroVip :addTargetWithActionForControlEvents(heroVipfunc,CCControlEventTouchDown)

	self:updateAllPosition()
	VisibleRect:relativePosition(self.heroHeadFrame,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(-5,15))
	VisibleRect:relativePosition(self.hpBottom,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(133,-48))
	VisibleRect:relativePosition(self.mpBottom,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(130,-73))
	VisibleRect:relativePosition(self.HP,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(133,-49))
	VisibleRect:relativePosition(self.MP,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(137,-72))
	VisibleRect:relativePosition(self.heroName,self.heroHeadFrame,LAYOUT_TOP_INSIDE + LAYOUT_CENTER,ccp(77,-23))
	if self.level < 10 then
		VisibleRect:relativePosition(self.heroLevel ,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X,ccp(-20,32))
	else
		VisibleRect:relativePosition(self.heroLevel ,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X,ccp(-21,32))
	end
		
	VisibleRect:relativePosition(self.heroHead,self.heroHeadFrame,LAYOUT_CENTER,headOffset)
	
	VisibleRect:relativePosition(self.heroStatusBtn,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(185, 10))	
	VisibleRect:relativePosition(self.heroVip ,self.heroHeadFrame,LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(122,-19))
	VisibleRect:relativePosition(self.HPvalueLb,self.hpBottom,LAYOUT_CENTER)	
	VisibleRect:relativePosition(self.MPvalueLb,self.mpBottom,LAYOUT_CENTER)
	VisibleRect:relativePosition(self.hpthumb,self.hpBottom,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(self.hpthumbPosX,9))	
	VisibleRect:relativePosition(self.mpthumb,self.mpBottom,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(7+self.mpthumbPosX,10))	


end

function MainHeroHead:setVipEnabled(bEnable)
	self.heroVip:setEnabled(bEnable)
end

function MainHeroHead:setHeroHeadEnabled(bEnable)
	self.heroHead:setEnabled(bEnable)
end

--获取头像名
function MainHeroHead:getHeadName(heroPt)
	if heroPt then
		local professionId = PropertyDictionary:get_professionId(heroPt)
		local genderId = PropertyDictionary:get_gender(heroPt)
		local pTable = ProfessionGender_Table
		for i,v in pairs(pTable) do
			local profession = v.tProfession
			local gender = v.tGender
			if profession==professionId and genderId==gender  then
				return v.tImage,v.tOffset
			end
		end
	end
end

--更新人物属性数据
function MainHeroHead:Update(pt)
	self:UpdateHP(pt)
	self:UpdateMP(pt)
	self:UpdateLevel(pt)	
end

--更新人物面板Hp
function MainHeroHead:UpdateHP(pt)
	local heroHp = PropertyDictionary:get_HP(self.hero:getPT())
	local heroMaxHp = PropertyDictionary:get_maxHP(self.hero:getPT())
	
	local function getDate()
		if pt then
			if pt.HP then
				heroHp = pt.HP
			end
			if pt.maxHP then
				heroMaxHp = pt.maxHP
				PropertyDictionary:set_maxHP(self.hero:getPT(), heroMaxHp)
			end
		end
	end
	
	local function checkData()
		if heroHp==nil or heroHp<0 then
			heroHp = 0
		end
		if heroMaxHp==nil or heroMaxHp<1 then
			heroMaxHp = 1
		end
		if heroHp>heroMaxHp then
			heroHp = heroMaxHp
		end
	end
	
	local function show()
		if self.HP==nil then
			self.HPvalueLb = createLabelWithStringFontSizeColorAndDimension(string.format("%d/%d",heroHp,heroMaxHp),"Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite2"))
			self.rootNode:addChild(self.HPvalueLb,20)
			self.HP = createSpriteWithFrameName(RES("main_hp.png"))
			G_setScale(self.HP)
			local hpNewRect = self.HP:getTextureRect()
			self.hpRectWidth = 	hpNewRect.size.width
			local hpWidth = self.hpRectWidth*(heroHp/heroMaxHp)
			hpNewRect.size.width = hpWidth
			self.HP:setTextureRect(hpNewRect)
			self.rootNode:addChild(self.HP)
			
			--创建自动回血蓝点
			self:handupConfig()
		else
			if pt.HP then--有值才更新
				local hpNewRect = self.HP:getTextureRect()
				local hpWidth = self.hpRectWidth*(heroHp/heroMaxHp)
				hpNewRect.size.width = hpWidth
				self.HP:setTextureRect(hpNewRect)

				VisibleRect:relativePosition(self.HP,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(133,-49))
				
				hero = GameWorld.Instance:getEntityManager():getHero()
				hero:setHP(heroHp)
				self.HPvalueLb:setString(string.format("%d/%d",heroHp,heroMaxHp))
				--print("当前血："..heroHp.."最大血："..heroMaxHp)
			end
		end
		--progressBar实现
		--[[if self.HP==nil then		
			self.HP = createProgressBar(RES("main_hpbottom.png"),RES("main_hp.png"),CCSizeMake(137,21))
			local percentage = heroHp/heroMaxHp*100
			self.HP:setPercentage(percentage)			
			self.HP:setNumberVisible(false)
			self.rootNode:addChild(self.HP)
			
		else
			if pt.HP then--有值才更新
				self.hero:setHP(heroHp)
				local percentage = heroHp/heroMaxHp*100
				self.HP:setPercentage(percentage)
				
			end
		end--]]
		
		--progressTimer实现
	--[[	if self.HP == nil then	
			self.HPvalueLb = createLabelWithStringFontSizeColorAndDimension(string.format("%d/%d",heroHp,heroMaxHp),"Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite2"))	
			self.rootNode:addChild(self.HPvalueLb,20)				
			local headHPSprite = createSpriteWithFrameName(RES("main_hp.png"))									
			self.HP = CCProgressTimer:create(headHPSprite)	
			self.HP : setScaleX(45.7)				
			self.HP:setType(kCCProgressTimerTypeBar)			
			self.HP:setMidpoint(ccp(0,0))
			self.HP:setBarChangeRate(ccp(1,0))			
			self.rootNode:addChild(self.HP)
			local percentage = heroHp/heroMaxHp*100
			self.HP:setPercentage(percentage)				
		else
			if pt.HP then--有值才更新
				self.hero:setHP(heroHp)
				local percentage = heroHp/heroMaxHp*100
				self.HP:setPercentage(percentage)
				self.HPvalueLb:setString(string.format("%d/%d",heroHp,heroMaxHp))
			end		
		end--]]			
	end
	
	getDate()
	checkData()
	show()
end

--更新MP
function MainHeroHead:UpdateMP(pt)
	local heroMP = PropertyDictionary:get_MP(self.hero:getPT())
	local heroMaxMP = PropertyDictionary:get_maxMP(self.hero:getPT())	
	
	local function getDate()
		if pt then
			if pt.MP then
				heroMP = pt.MP
			end
			if pt.maxMP then
				heroMaxMP = pt.maxMP
				PropertyDictionary:set_maxMP(self.hero:getPT(), heroMaxMP)
			end
		end
	end
	
	local function checkData()
		if heroMP==nil or heroMP<0 then
			heroMP = 0
		end
		if heroMaxMP==nil or heroMaxMP<1 then
			heroMaxMP = 1
		end
		if heroMP>heroMaxMP then
			heroMP = heroMaxMP
		end
	end
	
	local function show()
		if self.MP==nil then
			self.MPvalueLb = createLabelWithStringFontSizeColorAndDimension(string.format("%d/%d",heroMP,heroMaxMP),"Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite2"))
			self.rootNode:addChild(self.MPvalueLb,20)
							self.MP = createSpriteWithFrameName(RES("main_mp.png"))
			G_setScale(self.MP)
			local mpNewRect = self.MP:getTextureRect()
			self.mpRectWidth = mpNewRect.size.width
			local mpWidth = self.mpRectWidth*(heroMP/heroMaxMP)
			mpNewRect.size.width = mpWidth
			self.MP:setTextureRect(mpNewRect)
			self.rootNode:addChild(self.MP)
		else
			if pt.MP then
				local mpNewRect = self.MP:getTextureRect()
				local mpWidth = self.mpRectWidth*(heroMP/heroMaxMP)
				mpNewRect.size.width = mpWidth
				self.MP:setTextureRect(mpNewRect)
				VisibleRect:relativePosition(self.MP,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(137,-72))
				--print("当前蓝："..heroMP.."最大蓝："..heroMaxMP)
				self.MPvalueLb:setString(string.format("%d/%d",heroMP,heroMaxMP))
			end
			
		end
		--progressBar实现
		--[[if self.MP==nil then		
			self.MP = createProgressBar(RES("main_mpbottom.png"),RES("main_mp.png"),CCSizeMake(119,12))
			local percentage = heroMP/heroMaxMP*100
			self.MP:setPercentage(percentage)			
			self.MP:setNumberVisible(false)
			self.rootNode:addChild(self.MP)
		else
			if pt.MP then--有值才更新
				local percentage = heroMP/heroMaxMP*100
				self.MP:setPercentage(percentage)
			end
		end--]]
		--progressTimer实现
	--[[	if self.MP == nil then		
			self.MPvalueLb = createLabelWithStringFontSizeColorAndDimension(string.format("%d/%d",heroMP,heroMaxMP),"Arial", FSIZE("Size1") * const_scale, FCOLOR("ColorWhite2"))	
			self.rootNode:addChild(self.MPvalueLb,20)
			local headMPSprite = createSpriteWithFrameName(RES("main_mp.png"))									
			self.MP = CCProgressTimer:create(headMPSprite)	
			self.MP : setScaleX(39.7)				
			self.MP:setType(kCCProgressTimerTypeBar)			
			self.MP:setMidpoint(ccp(0,0))
			self.MP:setBarChangeRate(ccp(1,0))			
			self.rootNode:addChild(self.MP)					
			local percentage = heroMP/heroMaxMP*100
			self.MP:setPercentage(percentage)			
		else
			if pt.MP then--有值才更新		
				local percentage = heroMP/heroMaxMP*100
				self.MP:setPercentage(percentage)	
				self.MPvalueLb:setString(string.format("%d/%d",heroMP,heroMaxMP))			
			end		
		end--]]
	end
	
	getDate()
	checkData()
	show()
end

--更新等级
function MainHeroHead:UpdateLevel(pt)
	local bUpdate = false
	
	local function getDate()
		if pt then
			if pt.level and pt.level ~= self.level then
				bUpdate = true
				self.level = pt.level
				G_getQuestLogicMgr():checkUpdateLevelGetQuestList(self.level)--判断是否满足新任务的等级
			end
		else
			self.level = PropertyDictionary:get_level(self.hero:getPT())
		end
	end
	
	local function checkData()
		if self.level==nil then
			self.level = 0
		end
	end
	
	local function show()
		if self.heroLevel==nil then
			self.heroLevel = createLabelWithStringFontSizeColorAndDimension(self.level,"Arial",15*self.scale,ccc3(255,255,255))
			self.rootNode:addChild(self.heroLevel )
		else
			if bUpdate then
				self.heroLevel:setString(self.level)--更新等级
				if self.level < 10 then
					VisibleRect:relativePosition(self.heroLevel ,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X,ccp(-20,32))
				else
					VisibleRect:relativePosition(self.heroLevel ,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X,ccp(-21,32))
				end
			end
		end
	end
	
	getDate()
	checkData()
	show()
end

--人物状态
function MainHeroHead:initHeroState()
	if self.heroStatusBtn==nil then
		self.heroStatusBtn = createButtonWithFramename(RES("main_pk.png"))
		self.heroStatusBtn:setTouchAreaDelta(30, 8, 30, 30)
		local commonState = createSpriteWithFrameName(RES(self.heroStateIcon[E_HeroPKState.statePeace].icon))
		self.heroStatusBtn:setTitleString(commonState)
		self.rootNode:addChild(self.heroStatusBtn)					
		self.visibleFlag = true
		local stateChangeFunc = function()	
			self:newGuidelinesClickStatusBtn()
			-- 判断沙巴克相关的逻辑
			local activityMgr = GameWorld.Instance:getActivityManageMgr()
			local heroObj = GameWorld.Instance:getEntityManager():getHero()
			if not heroObj then
				return
			end
			
			local mapManager = GameWorld.Instance:getMapManager()
			local castleMgr = heroObj:getCastleWarMgr()
			if castleMgr:isInCastleWar() then	-- 在沙巴克攻城战中,  不能切换
				--Juchao@20140726: 再次确认是否为公会模式
				local pk = GameWorld.Instance:getEntityManager():getHero():getPKStateID()
				if (pk ~= E_HeroPKState.stateFaction) then
					HandupCommonAPI:switchPKMode(E_HeroPKState.stateFaction)
				end		
				UIManager.Instance:showSystemTips(Config.Words[18011])
			else
				self:showHeroStateView(self.visibleFlag)
			end
		end	
		self.heroStatusBtn:addTargetWithActionForControlEvents(stateChangeFunc,CCControlEventTouchDown)	
	end
	--VisibleRect:relativePosition(self.heroStatusBtn,self.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(43,-100))				
	VisibleRect:relativePosition(self.heroStatusBtn,self.heroHeadFrame,LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(185, 10))	
end
--附近
function MainHeroHead:initHeroNearby()
	if not self.nearbyBtn then
		self.nearbyBtn = createButtonWithFramename(RES("main_pk.png"))
		self.nearbyBtn:setTouchAreaDelta(8, 30, 30, 30)
		local text = createSpriteWithFrameName(RES("nearbyButtonWord.png"))
		self.nearbyBtn:setTitleString(text)
		self.rootNode:addChild(self.nearbyBtn)
		VisibleRect:relativePosition(self.nearbyBtn, self.heroStatusBtn, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(20, 0))
	end
	
	local openNearbyView = function ()
		local nearbyMgr = GameWorld.Instance:getNearbyMgr()
		if nearbyMgr:getNearByViewIsShowing() then
			GlobalEventSystem:Fire(GameEvent.EventCloseNearByView)
		else
			GlobalEventSystem:Fire(GameEvent.EventOpenNearByView)
		end			
	end
	self.nearbyBtn:addTargetWithActionForControlEvents(openNearbyView, CCControlEventTouchDown)
	if not self.nearbySelect then
		self.nearbySelect = createScale9SpriteWithFrameNameAndSize(RES("main_pk_lightframe.png"), CCSizeMake(63,34))
		self.nearbyBtn:addChild(self.nearbySelect,-1)
		VisibleRect:relativePosition(self.nearbySelect, self.nearbyBtn, LAYOUT_CENTER)
		self.nearbySelect:setVisible(false)
	end		
end

function MainHeroHead:showHeroNearby(bShow)
	if self.nearbyBtn then
		self.nearbyBtn:setVisible(bShow)
	end
end

function MainHeroHead:setNearbySelectVisible(bShow)
	self.nearbySelect:setVisible(bShow)
end

function MainHeroHead:showHeroStateView(bShow)
	if bShow then			
		self.heroStateView = MainHeroState.New()	
		self.stateNode = self.heroStateView:getRootNode()
		self.rootNode:addChild(self.stateNode,50)					
		VisibleRect:relativePosition(self.stateNode,self.heroStatusBtn,LAYOUT_BOTTOM_OUTSIDE+LAYOUT_LEFT_INSIDE,ccp(0,-5))		
		GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesChosePKByWhole()--引导选择全体模式
	elseif self.stateNode then	
		self.stateNode:removeFromParentAndCleanup(true)
		self.stateNode = nil
		if self.heroStateView then
			self.heroStateView:DeleteMe()
			self.heroStateView = nil
		end
	end
	self.visibleFlag = not bShow
end

function MainHeroHead:updateHeroState()
	local heroObj = GameWorld.Instance:getEntityManager():getHero()
	if heroObj then
		local stateId = heroObj:getPKStateID()
		if stateId and self.heroStatusBtn then
			local commonState = createSpriteWithFrameName(RES(self.heroStateIcon[stateId].icon))
			self.heroStatusBtn:setTitleString(commonState)
			self:showHeroStateView(false)
			if stateId~=E_HeroPKState.statePeace then
				--GlobalEventSystem:Fire(GameEvent.EventEnterAutoFightView,ViewState.AutoFightView)--进入自动战斗UI--暂时屏蔽
			end				
		end
		if self.stateId ~= stateId then
			self.stateId = stateId
			GameUtil:createFadeAction(self.heroStatusBtn, "common_fade.png", CCSizeMake(56, 30))
		end
	end
end

function MainHeroHead:handupConfig(config)
	if not config then
		config =  G_getHandupConfigMgr():readHandupConfig()		
	end
	if not self.hpthumb then
		self.hpthumb = createSpriteWithFrameName(RES("main_slider.png"))	
		--self.hpthumb:setRotation(180)
		self.hpthumb:setScale(0.8)	
		self.rootNode:addChild(self.hpthumb,19)
	end
	local hpthumbsize = self.hpthumb:getContentSize()	
	self.hpthumbPosX = config.HP_AutoAdd/100 * g_hpSize.width - (hpthumbsize.width/2)
	VisibleRect:relativePosition(self.hpthumb,self.hpBottom,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(self.hpthumbPosX,9))
	
	if not self.mpthumb then
		self.mpthumb = createSpriteWithFrameName(RES("main_slider.png"))
		self.mpthumb:setScale(0.8)	
		--self.mpthumb:setRotation(180)
		self.rootNode:addChild(self.mpthumb,19)
	end
	local mpthumbsize = self.mpthumb:getContentSize()	
	self.mpthumbPosX = config.MP_AutoAdd/100 * g_mpSize.width - (mpthumbsize.width/2)
	VisibleRect:relativePosition(self.mpthumb,self.mpBottom,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(7+self.mpthumbPosX,10))
end	

function MainHeroHead:getStateTablePos()
	if self.stateNode then
		local posX,posY = self.stateNode:getPosition()
		return posX,posY		
	else
		return
	end	
end

function MainHeroHead:updateAllPosition()

end

function MainHeroHead:setVipIcon(vipLevel)
	if self.heroVip then
		if vipLevel == Vip_Level.NOTVIP then
			local vipgreySpr = createScale9SpriteWithFrameName(RES("main_vipgrey.png"))
			self.heroVip:setBackgroundSpriteForState(vipgreySpr,CCControlStateNormal)
		elseif vipLevel == Vip_Level.VIP_TONG then
			local vipcopperSpr = createScale9SpriteWithFrameName(RES("main_vipcopper.png"))
			self.heroVip:setBackgroundSpriteForState(vipcopperSpr,CCControlStateNormal)
		elseif vipLevel == Vip_Level.VIP_YING then
			local vipsliverSpr = createScale9SpriteWithFrameName(RES("main_vipsliver.png"))
			self.heroVip:setBackgroundSpriteForState(vipsliverSpr,CCControlStateNormal)
		elseif vipLevel == Vip_Level.VIP_JIN then
			local vipgoldSpr = createScale9SpriteWithFrameName(RES("main_vipgold.png"))
			self.heroVip:setBackgroundSpriteForState(vipgoldSpr,CCControlStateNormal)	
		end	
		
		if vipLevel~=self.currentVipLevel then
			self.currentVipLevel = vipLevel
			self:changeVipLevelEffect()
		end		
	end		
end

function MainHeroHead:clickHeadBtn()
	self:newGuidelinesClickHeadBtn()
	GlobalEventSystem:Fire(GameEvent.EventMoveMianView)	
end

function MainHeroHead:changeVipLevelEffect()
	local sprite = createSpriteWithFrameName(RES("common_VipEffext.png"))
	self.rootNode:addChild(sprite)
	VisibleRect:relativePosition(sprite, self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(105, -10))
	
	sprite:setOpacity(50)
	local array = CCArray:create()
	local fadeIn = CCFadeIn:create(0.5)
	local fadeOut = CCFadeOut:create(0.5)
	local removeSelf = function ()
		sprite:removeFromParentAndCleanup(true)
	end
	local removeFun = CCCallFunc:create(removeSelf)
	array:addObject(fadeIn)
	array:addObject(fadeOut)
	array:addObject(removeFun)
	local action = CCSequence:create(array)
	sprite:runAction(action)
end

function MainHeroHead:setViewHide()
	local moveBy = CCMoveBy:create(0.5,ccp(0,visibleSize.height/3))	
	self.rootNode:runAction(moveBy)
	
	if self.nearbyBtn then
		local moveBy = CCMoveBy:create(0.5,ccp(-50,-visibleSize.height/3+90))	
		self.nearbyBtn:runAction(moveBy)
	end
end

function MainHeroHead:setViewShow()
	local moveBy = CCMoveBy:create(0.5,ccp(0,-visibleSize.height/3))	
	self.rootNode:runAction(moveBy)	
	
	if self.nearbyBtn then
		local moveBy = CCMoveBy:create(0.5,ccp(50,visibleSize.height/3-90))	
		self.nearbyBtn:runAction(moveBy)
	end
end


----------------------------------------------------------------------
--新手指引
function MainHeroHead:newGuidelinesClickHeadBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainHeroHead","heroHead")
end

function MainHeroHead:newGuidelinesClickStatusBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainHeroHead","heroStatusBtn")
end

function MainHeroHead:getHeroHeadNode()
	return self.heroHead
end	

function MainHeroHead:getHeroStatusBtn()
	return self.heroStatusBtn
end

function MainHeroHead:getHeroStateViewNode(index)
	if self.heroStateView then
		local node = self.heroStateView:getCellNode(index)
		return node
	end
end
----------------------------------------------------------------------