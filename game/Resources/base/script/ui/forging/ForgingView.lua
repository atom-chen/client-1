require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.forging.StrengthenView")
require("ui.forging.WashView")
require("ui.forging.DecomposeView")


ForgingView = ForgingView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local g_bagMgr 		= nil
local g_hero	 	= nil
local g_equipMgr 	= nil
	


function ForgingView:__init()
	self.viewName = "ForgingView"
	self:initFullScreen()
	local forgeNode = createSpriteWithFrameName(RES("main_forge.png"))
	self:setFormImage(forgeNode)
	local titleNode = createSpriteWithFrameName(RES("word_window_forge.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
	
	g_hero = G_getHero()
	g_bagMgr = G_getBagMgr()
	g_equipMgr = G_getEquipMgr()
	
	self.subViews = 
	{	
		[ForgeSubViewType.Strengthen] = {name = Config.Words[550], new = StrengthenView.New,obj = nil, preload = false, openLevel = 50 , openFlag == false},
		[ForgeSubViewType.Wash] 		 = {name = Config.Words[551], new = WashView.New,		obj = nil, preload = false, openLevel = 50 , openFlag == false},
--		[ForgeSubViewType.Decompose]  = {name = Config.Words[552], new = DecomposeView.New,	obj = nil, preload = false},
	}

	self.curView = nil
	self.firstOnEnter = true	
	self:initTabAndSubView()
	self:checkOpenState()
	--self:showSubView(ForgeSubViewType.Strengthen)		
end

function ForgingView:__delete()
	for key,value in ipairs(self.subViews) do
		if (value.obj) then
			value.obj:DeleteMe()
		end
	end
end

function ForgingView:getNodeByName(name)
	if name == "DecomposeView" then
		if self.subViews[ForgeSubViewType.Decompose] then
			return self.subViews[ForgeSubViewType.Decompose].obj			
		end
	elseif name == "WashView" then
		return self.subViews[ForgeSubViewType.Wash].obj
	elseif name == "StrengthenView" then
		return self.subViews[ForgeSubViewType.Strengthen].obj
	end
end

function ForgingView:create()
	return ForgingView.New()
end

function ForgingView:onEnter()
	
	if not self.firstOnEnter then
		local curView = self.subViews[self.curView].obj
		if (curView and curView.onEnter) then
			curView:onEnter()
		end
	end
	self.firstOnEnter = false
	if self.subViews[ForgeSubViewType.Strengthen].openFlag == true then
		self:showSubView(ForgeSubViewType.Strengthen)
	elseif self.subViews[ForgeSubViewType.Wash].openFlag == true then
		self:showSubView(ForgeSubViewType.Wash)
	end
end

function ForgingView:onExit()
	if not self.curView then
		return
	end
	if self.curView ~= ForgeSubViewType.Strengthen then 
		local curView = self.subViews[self.curView].obj
		if (curView and curView.onExit) then
			curView:onExit()
		end
		
		--self:showSubView(ForgeSubViewType.Strengthen)
	end
end
--[[
E_OffsetView = 
{
eWidth = 6,
eHeight = 6
}--]]
function ForgingView:initTabAndSubView()
	local btnArray = CCArray:create()		
	for key,value in ipairs(self.subViews) do
		local function createBtn(key) 			
			if (value.preload == true) then
				self:createSubView(key) 		--创建对应的子界面
			end
			value.normalBtn = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))	
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial",FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"))	
			value.disableBtn = self:createLockBtn(value.name)	
			local onDisableBtnPress = function()
				local tips = string.format("%s%s%s%s",value.name,Config.Words[10217],value.openLevel,Config.Words[10218])
				UIManager.Instance:showSystemTips(tips)	
			end
			value.disableBtn:addTargetWithActionForControlEvents(onDisableBtnPress, CCControlEventTouchDown)				
			btnArray:addObject(value.normalBtn)
			local onTabPress = function()				
				self:showSubView(key)
			end	
			value.normalBtn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
			
		end
		createBtn(key)
	end
	
	self.tagView = createTabView(btnArray,15*const_scale,tab_horizontal)
	self:getContentNode():addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(60, 0))	
	
	for key, value in pairs(self.subViews) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.normalBtn, LAYOUT_CENTER, ccp(2, -3))
		self.tagView:addChild(value.disableBtn)	
		VisibleRect:relativePosition(value.disableBtn, value.normalBtn, LAYOUT_CENTER)
		value.normalBtn:setVisible(false)
	end
end	

function ForgingView:createLockBtn(name)
	local btn = createButtonWithFramename(RES("tab_1_normal.png"))
	local lock = createScale9SpriteWithFrameName(RES("bagBatch_iocnLock.png"))	
	btn:addChild(lock)
	VisibleRect:relativePosition(lock, btn, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10, -10))
	
	local label = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"))				
	btn:setTitleString(label)
	VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)
	return btn
end	

function ForgingView:createSubView(key)
	local view =  self.subViews[key].new()  	-- 创建实例
	self.subViews[key].obj = view 	  			-- 将实例保存在obj字段
	view:getRootNode():setVisible(false)		
	self:getContentNode():addChild(view:getRootNode())	
end
	
function ForgingView:showSubView(key)
	if (self.curView == key) then
		return
	end
	
	if (self.curView ~= nil) then
		local oldView = self.subViews[self.curView]		
		if (oldView.obj ~= nil) then
			local oldNode = oldView.obj:getRootNode()
			oldNode:setVisible(false)
		end
	end
	if self.curView then
		self.subViews[self.curView].label:setColor(FCOLOR("ColorWhite4"))
	end
	
	self.tagView:setSelIndex(key - 1)
	self.curView = key
	self.subViews[self.curView].label:setColor(FCOLOR("ColorWhite3"))
	local newView = self.subViews[self.curView]
	if (newView.obj == nil) then
		self:createSubView(key)		
	end
	if (newView.obj.onEnter) then
		newView.obj.onEnter(newView.obj)
	end
			
	local newNode = self.subViews[key].obj:getRootNode()			
	newNode:setVisible(true)
	VisibleRect:relativePosition(newNode, self.tagView, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -2))	
	VisibleRect:relativePosition(newNode, self:getContentNode(), LAYOUT_CENTER_X, ccp(0, 0))		
end
function ForgingView:openSubView(key)
	if self.subViews[key] then
		self.subViews[key].normalBtn:setVisible(true)
		self.subViews[key].label:setVisible(true)
		self.subViews[key].disableBtn:setVisible(false)
	end
end

function ForgingView:checkOpenState()
	for key,value in ipairs(self.subViews) do
		local openFlag = G_getForgingMgr():getOpenFlag(key)
		if openFlag == true then
			self:openSubView(key)
			value.openFlag = true
		end
	end
end