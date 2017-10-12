-- 背包界面（游戏主界面点击背包时进入）
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.friend.FriendTableView")

FriendView = FriendView or BaseClass(BaseUI) --FriendView继承与BaseUI
local const_size = CCSizeMake(480, 640)

--[[
只需在这里增加各种子界面, FriendView会创建并管理

name: 该界面的名字，如装备，属性
new:  该界面的创建函数
instance: 运行时的对象。指定为nil，运行时会赋值
]]
local FriendSubView = 
{
	GoodFriendView = {name = "好  友", new = FriendTableView.createGoodFriendList, instance = nil},
	BlackListView  = {name = "黑名单", new = FriendTableView.createBlackList, 		instance = nil},
}	

local g_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_currentView = FriendSubView.GoodFriendView
local g_hero = nil

function FriendView:create()	
	return FriendView.New()
end

function FriendView:__init()
	g_hero = GameWorld.Instance:getEntityManager():getHero()
	self.viewName = "FriendView"
	
	self:init(const_size, nil)				
	self:initBtn()
	self:initTitle()
	self:initTabViewAndFriendSubView()	
	self:showFriendSubView("GoodFriendView")
	self:showHeroInfo()
end			

function FriendView:showHeroInfo()
	if (g_hero == nil) then
		return
	end
	g_hero:getName()
	if (self.heroNode == nil) then
		self.heroHeadSprite = createSpriteWithFrameName(RES("main_head.png"))
		self.heroNameLabel = createLabelWithStringFontSizeColorAndDimension(g_hero:getName(), "Arial", 22, ccc3(255, 255,0))
		self.heroLevelLabel = createLabelWithStringFontSizeColorAndDimension(string.format("%d级", g_hero:getLevel()), "Arial", 25, ccc3(255, 255,0))
		self.heroProfessionLabel = createLabelWithStringFontSizeColorAndDimension(g_hero:getProfessionName(), "Arial", 25, ccc3(255, 255,0))		
		
		self.heroNode = CCNode:create()
		self.heroNode:setContentSize(CCSizeMake(400, self.heroHeadSprite:getContentSize().height))
		self.background:addChild(self.heroNode)
		VisibleRect:relativePosition(self.heroNode, self.background, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(30, -50))
		
		self.heroNode:addChild(self.heroHeadSprite)
		self.heroNode:addChild(self.heroNameLabel)
		self.heroNode:addChild(self.heroLevelLabel)
		self.heroNode:addChild(self.heroProfessionLabel)				
	else
		self.heroNameLabel:setString(g_hero:getName(), "Arial", 22, ccc3(255, 255,0))
		self.heroLevelLabel:setString(string.format("%d级", g_hero:getLevel()), "Arial", 22, ccc3(255, 255,0))
		self.heroProfessionLabel:setString(g_hero:getProfessionName(), "Arial", 25, ccc3(255, 255,0))
	end
	VisibleRect:relativePosition(self.heroHeadSprite, self.heroNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE)
	VisibleRect:relativePosition(self.heroNameLabel, self.heroNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(100, -25))
	VisibleRect:relativePosition(self.heroLevelLabel, self.heroNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(100, -70))
	VisibleRect:relativePosition(self.heroProfessionLabel, self.heroNode, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(180, -70))
end	

-- 显示添加好友，删除好友按钮
function FriendView:initBtn()
	if (self.addBtn == nil) then
		self.addBtn = createButtonWithFramename(RES("btn_2_normal.png"), RES("btn_2_select.png"))		
		self.addText = createLabelWithStringFontSizeColorAndDimension(Config.Words[4010],"Arial", 22, ccc3(255, 255,0))
		self.addBtn:addChild(self.addText)		
		VisibleRect:relativePosition(self.addText, self.addBtn, LAYOUT_CENTER)		
		self.background:addChild(self.addBtn)
		VisibleRect:relativePosition(self.addBtn, self.background, LAYOUT_LEFT_INSIDE, ccp(38, 58))	
		
		self.delBtn = createButtonWithFramename(RES("btn_2_normal.png"), RES("btn_2_select.png"))		
		self.delText = createLabelWithStringFontSizeColorAndDimension(Config.Words[4011],"Arial", 22, ccc3(255, 255,0))
		self.delBtn:addChild(self.delText)		
		VisibleRect:relativePosition(self.delText, self.delBtn, LAYOUT_CENTER)		
		self.background:addChild(self.delBtn)
		VisibleRect:relativePosition(self.delBtn, self.background, LAYOUT_RIGHT_INSIDE, ccp(-38, 58))	
	end
end	

function FriendView:initTitle()
	self:setTitleText("好  友")
end

-- 显示TabView
function FriendView:initTabViewAndFriendSubView()	
	local btnArray = CCArray:create()		
	for key,value in pairs(FriendSubView) do
		local function createBtn(key) 			
			self:createFriendSubView(key) --创建对应的子界面
			local btn = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))
			local text = createLabelWithStringFontSizeColorAndDimension(value.name,"Arial",20,ccc3(255,255,0))
			btn:addChild(text)
			VisibleRect:relativePosition(text, btn, LAYOUT_CENTER)
			btnArray:addObject(btn)
			local onTabPress = function()
				self:showFriendSubView(key)
			end	
			btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(key)
	end			
	self.tagView = createTabView(btnArray, 20, tab_horizontal)		
	self.background:addChild(self.tagView)		
	VisibleRect:relativePosition(self.tagView, self.background, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(39, 130))
end	

-- 创建子界面
function FriendView:createFriendSubView(key)
	local view = FriendSubView[key].new()  	-- 创建实例
	FriendSubView[key].instance = view 	  		-- 将实例保存在instance字段
	local node = view:getRootNode()	
	self.rootNode:addChild(node)			
	node:setVisible(false)
end

-- 显示子界面
function FriendView:showFriendSubView(key)
	if (g_currentView.instance ~= nil) then
		local oldNode = g_currentView.instance:getRootNode()
		oldNode:setVisible(false)
	end		
	local newNode = FriendSubView[key].instance:getRootNode()
	newNode:setVisible(true)
	g_currentView = FriendSubView[key]
	newNode:setPosition(ccp(0, 0))
	VisibleRect:relativePosition(newNode, self.tagView, LAYOUT_BOTTOM_OUTSIDE, ccp(20, -5))
end