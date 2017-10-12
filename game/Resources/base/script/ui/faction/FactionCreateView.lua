--创建工会界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")

FactionCreateView = FactionCreateView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

function FactionCreateView:__init(node)
	self.viewName = "FactionCreateView"
	self:init(CCSizeMake(960*0.5,640*0.5))	
	self:initCreateView()
end
function FactionCreateView:create()
	return FactionCreateView.New()
end	

function FactionCreateView:initCreateView()
	
	
	local titleBg = createScale9SpriteWithFrameName(RES("common_formTitle1.png"))
	self.rootNode : addChild(titleBg)	
	VisibleRect:relativePosition(titleBg,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,0))
	local title = createSpriteWithFrameName(RES("word_tip_createFaction.png"))
	self.rootNode : addChild(title)	
	VisibleRect:relativePosition(title,self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-15))

	local factionNameBox =  createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(200,40)),RES("faction_editBoxBg.png"))
	local tips_1 = createLabelWithStringFontSizeColorAndDimension(Config.Words[5559],"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
	local tips_2 = createLabelWithStringFontSizeColorAndDimension(Config.Words[5560],"Arial", FSIZE("Size3"), FCOLOR("ColorYellow5"))
	self.rootNode : addChild(factionNameBox)
	VisibleRect:relativePosition(factionNameBox,title,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(30,-30))
	local factionNameLb = createSpriteWithFrameName(RES("word_tip_inputName.png"))
	self.rootNode : addChild(factionNameLb)
	self.rootNode : addChild(tips_1)
	self.rootNode : addChild(tips_2)	
	VisibleRect:relativePosition(factionNameLb,factionNameBox,LAYOUT_CENTER+LAYOUT_LEFT_OUTSIDE,ccp(-15,0))	
	VisibleRect:relativePosition(tips_1,factionNameLb,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-35))
	VisibleRect:relativePosition(tips_2,tips_1,LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_OUTSIDE,ccp(0,-20))
	--按钮
	local createBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))	
	local createBtnLb =  createSpriteWithFrameName(RES("word_button_createFaction.png"))
	createBtn : setTitleString(createBtnLb)
	self.rootNode : addChild(createBtn)	
	VisibleRect:relativePosition(createBtn,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,15))	
	--创建公会按钮功能
	local createFunction = function()
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()	
		local factionName = factionNameBox:getText()		
		local g_hero = GameWorld.Instance:getEntityManager():getHero()
		local curLevel = PropertyDictionary:get_level(g_hero:getPT())
		if curLevel < 10 then
			UIManager.Instance:showSystemTips(Config.Words[5509])
		elseif curLevel >= 10 then
			if factionName then
				factionMgr:requestCreateFaction(factionName) 		--请求创建公会
				UIManager.Instance:showLoadingHUD(10,self.rootNode)	
			end
		end
	end
	createBtn:addTargetWithActionForControlEvents(createFunction,CCControlEventTouchDown)
end