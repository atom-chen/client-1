--公会列表界面
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.faction.FactionApplyTableView")
FactionApplyView = FactionApplyView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()

local labelWords = 
{	
	[1] = Config.Words[5501] ,
	[2] = Config.Words[5502] ,
	[3] = Config.Words[5503] ,
	[4] = Config.Words[5504] ,
	[5] = Config.Words[5505] 
}

function FactionApplyView:__init()
	self.viewName = "FactionApplyView"
	self:initFullScreen()
	local titleImage = createSpriteWithFrameName(RES("main_faction.png"))
	self:setFormImage(titleImage)
	local titleWord = createSpriteWithFrameName(RES("word_window_sociaty.png"))
	self:setFormTitle(titleWord,TitleAlign.Left)
	self.topLabel = {}
	self.tableSize = CCSizeMake(839*g_scale,72*5+10*g_scale)
	self:initBg()
	self:initTopLabel()
	self:initTableView()
	self:initBtn()
	self:initBtnEvent()
end

function FactionApplyView:onEnter()
	if self.tableView then
		self.tableView:onEnter()
	end
	self:refreshMyFactionButton()
end

function FactionApplyView:onExit()
	local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
	factionMgr:setApplyViewFlag(nil)
end

function FactionApplyView:__delete()
	self.topLabel = {}
	self.tableView : DeleteMe()
end

function FactionApplyView:create()
	return FactionApplyView.New()
end
function FactionApplyView:initBg()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), CCSizeMake(self:getContentNode():getContentSize().width,(72*5+61)*g_scale))	
	self : addChild(self.bg)	
	VisibleRect:relativePosition(self.bg,self:getContentNode(),LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(0,0))
end
function FactionApplyView:initTopLabel()
	
	self.topBg = createScale9SpriteWithFrameName(RES("rank_title_bg.png"))
	self.topBg : setContentSize(CCSizeMake(self:getContentNode():getContentSize().width,41*g_scale))
	self : addChild(self.topBg)
	VisibleRect:relativePosition(self.topBg,self.bg,LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0,-4))
	for i = 1,5 do	
		--self.topLabel[i] = createStyleTextLable(labelWords[i], "FactionApply")		
		self.topLabel[i] = createLabelWithStringFontSizeColorAndDimension(labelWords[i], "Arial",FSIZE("Size5"),FCOLOR("ColorYellow2"))		
		self.topBg : addChild(self.topLabel[i])
		
		if i == 5 then
			VisibleRect:relativePosition(self.topLabel[i],self.topBg,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-100,0))
		else
			if(self.topLabel[i-1] == nil) then
				VisibleRect:relativePosition(self.topLabel[i],self.topBg,LAYOUT_CENTER+LAYOUT_LEFT_INSIDE,ccp(30,0))
			else
				VisibleRect:relativePosition(self.topLabel[i],self.topLabel[i-1],LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(75,0))
			end
		end
		if i~= 5 then
			local line = createScale9SpriteWithFrameNameAndSize(RES("verticalDivideLine.png"),CCSizeMake(2,20))
			self.topBg : addChild(line)	
			VisibleRect:relativePosition(line,self.topLabel[i],LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE,ccp(35,0))
		end			
	end		
end

function FactionApplyView:initTableView()
	self.tableView = FactionApplyTableView.New()
	self.tableView : initTableView(self:getContentNode(),self.tableSize)
	local layoutP = ccp(10,0)
	self.tableView:setTablePosition(self.topBg,layoutP)
end

function FactionApplyView:initBtn()
	--创建公会按钮
	self.createBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local createBtnLb =  createSpriteWithFrameName(RES("word_button_createFaction.png"))
	self.createBtn : setTitleString(createBtnLb)
	self:addChild(self.createBtn)
	VisibleRect:relativePosition(self.createBtn,self:getContentNode(),LAYOUT_LEFT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(150,5))
	
	--我的工会按钮
	self.myFaction = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local myFactionText = createSpriteWithFrameName(RES("word_button_myUnion.png"))
	self.myFaction:setTitleString(myFactionText)
	self:addChild(self.myFaction)
	VisibleRect:relativePosition(self.myFaction, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-150, 5))
	--还没有公会
	self.myFactionDis = createButtonWithFramename(RES("btn_1_disable.png"))
	local myFactionTextDis = createSpriteWithFrameName(RES("word_button_myUnion.png"))
	self.myFactionDis:setTitleString(myFactionTextDis)
	self:addChild(self.myFactionDis)
	VisibleRect:relativePosition(self.myFactionDis, self:getContentNode(), LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-150, 5))
end

function FactionApplyView:initBtnEvent()
	--创建公会按钮功能
	local createFunction = function()
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		local factionInfo = factionMgr:getFactionInfo()
		if table.size(factionInfo)>0 then
			UIManager.Instance:showSystemTips(Config.Words[5553])
		else			
			factionMgr:setApplyViewFlag(nil)
			factionMgr:openCreateView()				
		end
	end
	self.createBtn:addTargetWithActionForControlEvents(createFunction,CCControlEventTouchDown)
	--我的公会按钮
	local myFactionFun = function ()
		--GlobalEventSystem:Fire(GameEvent.EventOpenInfoView)
		local factionMgr = GameWorld.Instance:getEntityManager():getHero():getFactionMgr()
		factionMgr:requestFactionList("2","1")
	end
	self.myFaction:addTargetWithActionForControlEvents(myFactionFun, CCControlEventTouchDown)
	
	local myFactionDisFun = function ()
		UIManager.Instance:showSystemTips(Config.Words[5573])
	end
	self.myFactionDis:addTargetWithActionForControlEvents(myFactionDisFun, CCControlEventTouchDown)	
end

function FactionApplyView:refreshMyFactionButton()
	local hero = G_getHero()
	local unionName = PropertyDictionary:get_unionName(hero:getPT())
	if unionName and unionName ~= "" then
		self.myFaction:setVisible(true)
		self.myFactionDis:setVisible(false)
	else
		self.myFaction:setVisible(false)
		self.myFactionDis:setVisible(true)
	end
end

function FactionApplyView:refreshApplyBtn()
	if self.tableView then
		self.tableView:refreshApplyBtn()
	end	
end
function FactionApplyView:refreshCancelApplyBtn()
	if self.tableView then
		self.tableView:refreshCancelApplyBtn()
	end	
end
function FactionApplyView:refreshApplyTableView()
	if self.tableView then
		self.tableView.factionApplyTable:reloadData()
		self.tableView.factionApplyTable:scroll2Cell(0,false)
	end
end