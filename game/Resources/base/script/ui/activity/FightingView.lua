require("ui.UIManager")
require("common.BaseUI")
require("object.entity.PlayerObject")
require("ui.Main.MainView.MainHeroHead")

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
FightingView = FightingView or BaseClass(BaseUI)

function FightingView:__init()
	self.viewName = "FightingView"	
	
	local ArenaMgr = GameWorld.Instance:getArenaMgr()

	self.cycle = 0
	self.hero = nil
	self.otherRole	 = nil
	-- 初始化场景	
	self.scence = CCSprite:create("ui/ui_img/activity/arena_background.jpg")
	local scenceSize = self.scence:getContentSize()
	if scenceSize.width < visibleSize.width then
		self.scence:setScaleX(visibleSize.width/scenceSize.width)		
	end
	if scenceSize.height < visibleSize.height then
		self.scence:setScaleY(visibleSize.height/scenceSize.height)
	end
	--G_setBigScale(self.scence)
	self.rootNode:addChild(self.scence)
	VisibleRect:relativePosition(self.scence, self.rootNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
	self:initEndWindow()
end

function FightingView:__delete()
	self:destroyRole()
end

function FightingView:create()
	return FightingView.New()
end

function FightingView:initMapAndUI()
	-- 初始化头板UI
	self.heroHead = MainHeroHead.New(self.hero)
	self.heroHead:setVipEnabled(false)
	self.heroHead:setHeroHeadEnabled(false)
	self.rootNode:addChild(self.heroHead:getRootNode())		
	VisibleRect:relativePosition(self.heroHead:getRootNode(),self.rootNode,LAYOUT_CENTER)		
	
	self.otherRoleHead = MainHeroHead.New(self.otherRole)
	self.otherRoleHead:setVipEnabled(false)
	self.otherRoleHead:setHeroHeadEnabled(false)
	self.otherRoleHead:getRootNode():setScaleX(-1)
	self.rootNode:addChild(self.otherRoleHead:getRootNode())		
	VisibleRect:relativePosition(self.otherRoleHead:getRootNode(),self.rootNode,LAYOUT_CENTER)
	self:handleOverturn(self.otherRoleHead)
	
	-- 隐藏没用的UI
	self:hidePartView(self.heroHead)
	self:hidePartView(self.otherRoleHead)
	self.renderSpriteNode = CCNode:create()
	self.renderSpriteNode:addChild(self.hero:getRenderSprite())
	VisibleRect:relativePosition( self.hero:getRenderSprite(), self.renderSpriteNode,LAYOUT_CENTER,ccp(-275,0))
	self.renderSpriteNode:addChild(self.otherRole:getRenderSprite())
	VisibleRect:relativePosition( self.otherRole:getRenderSprite(), self.renderSpriteNode,LAYOUT_CENTER,ccp(275,0))
	
	
	self.rootNode:addChild(self.renderSpriteNode,0)
	VisibleRect:relativePosition( self.renderSpriteNode, self.rootNode,LAYOUT_CENTER)
end

function FightingView:createRole(fightArg)
	self.fightArg = fightArg
	-- 初始化英雄角色
	self.hero = PlayerObject.New()
	local playerPT = GameWorld.Instance:getEntityManager():getHero():getPT()
	local heroPt = {}
	for k,v in pairs(playerPT) do
		heroPt[k] = v
	end
	PropertyDictionary:set_mountModleId(heroPt, 0)
	self.hero:setPT(heroPt)	
	--self.hero:setId("")
	local maxHP = PropertyDictionary:get_maxHP(self.hero:getPT())
	PropertyDictionary:set_HP(self.hero:getPT(), maxHP)
	local maxMP = PropertyDictionary:get_maxMP(self.hero:getPT())
	PropertyDictionary:set_MP(self.hero:getPT(), maxMP)
	self.hero:loadModule(false)
	self.hero:getRenderSprite():setScale(-1)
	
	-- 初始化对手角色
	self.otherRole = PlayerObject.New()
	local otherRolePt = {}
	for k,v in pairs(fightArg.otherHeroPT) do
		otherRolePt[k] = v
	end
	PropertyDictionary:set_mountModleId(otherRolePt, 0)
	self.otherRole:setPT(otherRolePt)
	--self.otherRole:setId("")
	local maxHP = PropertyDictionary:get_maxHP(self.otherRole:getPT())
	PropertyDictionary:set_HP(self.otherRole:getPT(), maxHP)
	local maxMP = PropertyDictionary:get_maxMP(self.otherRole:getPT())
	PropertyDictionary:set_MP(self.otherRole:getPT(), maxMP)
	self.otherRole:loadModule(false)
	self.otherRole:getRenderSprite():setScaleY(-1)
end

function FightingView:destroyRole()
	if self.hero then
		self.hero:getRenderSprite():removeFromParentAndCleanup(true)
		self.hero:DeleteMe()
		self.hero = nil
	end
	if self.otherRole then
		self.otherRole:getRenderSprite():removeFromParentAndCleanup(true)
		self.otherRole:DeleteMe()
		self.otherRole = nil
	end
	if self.heroHead then
		self.heroHead:getRootNode():removeFromParentAndCleanup(true)
		self.heroHead = nil
	end
	if self.otherRoleHead then
		self.otherRoleHead:getRootNode():removeFromParentAndCleanup(true)
		self.otherRoleHead = nil
	end
end

function FightingView:playAnimate()
	local finishCallback = function()
		--self.layer:setVisible(true)
		self.initFightingEndWindow:setVisible(true)
	end
	
	local updateCallback = function(harmValue)
		
		if self.cycle == 0 then
			self:UpdateHP(self.heroHead,self.hero,harmValue)
			self.cycle = 1
		elseif self.cycle == 1 then
			self:UpdateHP(self.otherRoleHead,self.otherRole,harmValue)
			self.cycle = 0
		end
	end
	self.cycle = self.fightArg.fightingResult		
	
	local sequence
	if self.fightArg.fightingResult == 1 then
		GameWorld.Instance:getArenaSkillManager():generateTextData(self.hero,self.otherRole,self.fightArg.heroFighting,self.fightArg.otherHeroFighting)
		sequence =  GameWorld.Instance:getArenaSkillManager():createArenaAnimation(self.hero,self.otherRole, 2,self.rootNode,7,1,finishCallback,updateCallback) --mark
	elseif self.fightArg.fightingResult == 0 then
		GameWorld.Instance:getArenaSkillManager():generateTextData(self.otherRole,self.hero,self.fightArg.otherHeroFighting,self.fightArg.heroFighting)
		sequence =  GameWorld.Instance:getArenaSkillManager():createArenaAnimation(self.hero,self.otherRole, 2,self.rootNode,7,-1,finishCallback,updateCallback)
	end

	GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", sequence)
end

function FightingView:UpdateHP(headView,role,harmValue)
	local heroHp = PropertyDictionary:get_HP(role:getPT())-harmValue
	if heroHp < 0 then
		heroHp = 0
	end
	local heroMaxHp = PropertyDictionary:get_maxHP(role:getPT())

	if headView.HP then--有值才更新
		local hpNewRect = headView.HP:getTextureRect()
		local hpWidth = headView.hpRectWidth*(heroHp/heroMaxHp)
		hpNewRect.size.width = hpWidth
		headView.HP:setTextureRect(hpNewRect)
		VisibleRect:relativePosition(headView.HP,headView.heroHeadFrame,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(133,-49))
		headView.HPvalueLb:setString(string.format("%d/%d",heroHp,heroMaxHp))
		if headView == self.otherRoleHead then
			VisibleRect:relativePosition(headView.HPvalueLb,headView.hpBottom,LAYOUT_CENTER,ccp(-60,0))
		end
	end	
					
	PropertyDictionary:set_HP(role:getPT(),heroHp)
end

function FightingView:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return 0
		--return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, false)
end

function FightingView:initEndWindow()
	if self.initFightingEndWindow== nil then 
		self.initFightingEndWindow = createScale9SpriteWithFrameName(RES("squares_bg1.png"))
		self.initFightingEndWindow:setContentSize(CCSizeMake(400, 210))
		self:addChild(self.initFightingEndWindow,1)
		VisibleRect:relativePosition(self.initFightingEndWindow,self:getContentNode(),LAYOUT_CENTER)
	end	
	self.initFightingEndWindow:setVisible(false)
	local sureBtnFun = function()
		--self.layer:setVisible(false)
		self.initFightingEndWindow:setVisible(false)
		self:close()
		self:destroyRole()
		GlobalEventSystem:Fire(GameEvent.EventFightingOver)
	end
	
	local sureBtn = createButtonWithFramename(RES("btn_1_select.png"))		
	G_setScale(sureBtn)
	self.initFightingEndWindow:addChild(sureBtn)
	VisibleRect:relativePosition(sureBtn, self.initFightingEndWindow, LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE, ccp(0, 25))
	sureBtn:addTargetWithActionForControlEvents(sureBtnFun,CCControlEventTouchDown)
	local sureLable = createLabelWithStringFontSizeColorAndDimension(Config.Words[16036],"Arial",25,FCOLOR("ColorWhite1"),CCSizeMake(0,0))
	sureBtn:setTitleString(sureLable)
	VisibleRect:relativePosition(sureLable, sureBtn, LAYOUT_CENTER)
	
	self.endWinContentLable = createRichLabel(CCSizeMake(210,0))
	self.endWinContentLable:clearAll()
	self.initFightingEndWindow:addChild(self.endWinContentLable)
	VisibleRect:relativePosition(self.endWinContentLable,self.initFightingEndWindow, LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-90))
end

function FightingView:forceFinishAni()
	if self.fightArg.fightingResult == 0 then
		self:UpdateHP(self.heroHead,self.hero,999999999)
	elseif self.fightArg.fightingResult == 1 then
		self:UpdateHP(self.otherRoleHead,self.otherRole,999999999)
	end	
	if self.initFightingEndWindow then
		self.initFightingEndWindow:setVisible(true)
	end
end

function FightingView:updateEndWindow(fightArg)
	-- 战斗结果
	if self.fightResult then
		self.fightResult:removeFromParentAndCleanup(true)
	end
	if self.fightArg.fightingResult == 0 then
		self.fightResult = createSpriteWithFrameName(RES("arenaYoulost.png"))
	elseif self.fightArg.fightingResult == 1 then
		self.fightResult = createSpriteWithFrameName(RES("arenaYouwin.png"))
	end
	self.initFightingEndWindow:addChild(self.fightResult)
	VisibleRect:relativePosition(self.fightResult,self.initFightingEndWindow,LAYOUT_TOP_INSIDE+LAYOUT_CENTER,ccp(0,-20))
	-- 奖励
	self.endWinContentLable:clearAll()
	self.endWinContentLable:appendFormatText(string.wrapHyperLinkRich(Config.Words[16008], Config.FontColor["ColorWhite1"], FSIZE("Size2"), nil, "false"))
	self.endWinContentLable:appendFormatText(string.wrapHyperLinkRich(fightArg.gold.."   ", Config.FontColor["ColorGreen1"], FSIZE("Size2"), nil, "false"))
	self.endWinContentLable:appendFormatText(string.wrapHyperLinkRich(Config.Words[16009], Config.FontColor["ColorWhite1"], FSIZE("Size2"), nil, "false"))
	self.endWinContentLable:appendFormatText(string.wrapHyperLinkRich(fightArg.exploit, Config.FontColor["ColorGreen1"], FSIZE("Size2"), nil, "false"))
end

--------------------------------------------------------------------------------------
function FightingView:hidePartView(headView)
	headView.heroStatusBtn:setVisible(false)
	headView.hpthumb:setVisible(false)
	headView.mpthumb:setVisible(false)
	headView.nearbyBtn:setVisible(false)
end

function FightingView:handleOverturn(headView)
	headView.HPvalueLb:setScaleX(-1)
	headView.MPvalueLb:setScaleX(-1)
	headView.heroLevel:setScaleX(-1)
	headView.heroName:setScaleX(-1)
	headView.heroVip:setScaleX(-1)
end
