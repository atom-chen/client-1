require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.setting.SubHandupView")
require("ui.setting.SubOptionView")
require("ui.setting.SubPickUpView")

SettingView = SettingView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size_no_scale = CCSizeMake(387 + E_OffsetView.eWidth*2,  550 + E_OffsetView.eHeight*2)	
local const_size = VisibleRect:getScaleSize(const_size_no_scale)
const_settingBgSize = VisibleRect:getScaleSize(CCSizeMake(387- 26, 550 - 73))
G_sliderSize = CCSizeMake(230,20)

local SubViewType = 
{	
	PickUp= 1,
	Handup = 2,
	Option = 3,
}

function SettingView:__init()
	self.viewName = "SettingView"
	--const_size = self:initHalfScreen()
	const_size = CCSizeMake(393+E_OffsetView.eWidth*2,  550+E_OffsetView.eHeight*2)
	self:init(const_size)		
	local setingNode = createSpriteWithFrameName(RES("main_setting.png"))
	self:setFormImage(setingNode)
	local titleNode = createSpriteWithFrameName(RES("word_window_setting.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
	self.subViews = 
	{
		[SubViewType.Option] = {name = Config.Words[10136], new = SubOptionView.New, obj = nil, preload = false},
		[SubViewType.Handup] = {name = Config.Words[10137], new = SubHandupView.New, obj = nil, preload = false},
		[SubViewType.PickUp] = {name = Config.Words[10155], new = SubPickUpView.New, obj = nil, preload = false}
	}

	self.curView = nil
	self:initTabAndSubView()
	self:initBg()
	self:showSubView(SubViewType.Option)
	self.tagView:setSelIndex(2)		
end

function SettingView:__delete()
	for key, value in ipairs(self.subViews) do
		if value.obj then
			value.obj:DeleteMe()
		end
	end
end

--[[function SettingView:getRootNode()
	return self.rootNode
end--]]

function SettingView:create()
	return SettingView.New()
end

function SettingView:onEnter()
	local curView = self.subViews[self.curView].obj
	if curView and curView.onEnter then
		curView:onEnter()
	end
end

function SettingView:onExit()
	local curView = self.subViews[self.curView].obj
	if curView and curView.onExit then
		curView:onExit()
	end
	self:saveConfig()			
end

function SettingView:initBg()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg2.png"), const_settingBgSize)
	self:addChild(self.bg)
	--VisibleRect:relativePosition(self.bg, self.tagView, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -5))
	VisibleRect:relativePosition(self.bg, self:getContentNode(), LAYOUT_CENTER, ccp(0, 7))
end

function SettingView:initTabAndSubView()
	local btnArray = CCArray:create()		
	for key,value in ipairs(self.subViews) do
		local function createBtn(key) 			
			if (value.preload == true) then
				self:createSubView(key) 		--创建对应的子界面
			end
			value.btn = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))	
			--value.btn:setRotation(90)									
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial",FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"),CCSizeMake(22*const_scale,0))						
			btnArray:addObject(value.btn)
			local onTabPress = function()				
				self:showSubView(key)
			end	
			value.btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(key)
	end
	
	self.tagView = createTabView(btnArray,10*const_scale,tab_vertical)
	self:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(E_OffsetView.eWidth-52, -15))	
	
	for key, value in pairs(self.subViews) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.btn, LAYOUT_CENTER, ccp(2, -3))
	end
end	

function SettingView:createSubView(key)
	local view =  self.subViews[key].new()  	-- 创建实例
	self.subViews[key].obj = view 	  			-- 将实例保存在obj字段
	view:getRootNode():setVisible(false)		
end

function SettingView:showSubView(key)
	if (self.curView == key) then
		return
	end
	
	if (self.curView ~= nil) then
		local oldView = self.subViews[self.curView]		
		if (oldView.obj ~= nil) then
			local oldNode = oldView.obj:getRootNode()
			self:getContentNode():removeChild(oldNode, false)
			oldNode:setVisible(false)
		end
	end
	self.subViews[key].label:setColor(FCOLOR("ColorWhite3"))
	self.curView = key
	local newView = self.subViews[self.curView]
	if (newView.obj == nil) then
		self:createSubView(key)		
	end
	if (newView.obj.onEnter) then
		newView.obj.onEnter(newView.obj)
	end
			
	local newNode = self.subViews[key].obj:getRootNode()			
	self:addChild(newNode)	
			
	newNode:setVisible(true)
	--VisibleRect:relativePosition(newNode, self.tagView, LAYOUT_BOTTOM_OUTSIDE, ccp(0, -2))	
	VisibleRect:relativePosition(newNode, self:getContentNode(), LAYOUT_CENTER, ccp(0, 0))		
end

function SettingView:updateHandupConfigUI()
	local view = self.subViews[SubViewType.Handup].obj
	if view then
		view:updateUI()
	end
end

function SettingView:updatePickUpView()
	local view = self.subViews[SubViewType.PickUp].obj
	if view then
		view:updateUI()
	end
end

function SettingView:updateOptionView()
	local view = self.subViews[SubViewType.Option].obj
	if view then
		view:updateUI()
	end
end

function SettingView:saveConfig()
	local view = self.subViews[SubViewType.Option].obj
	if view then
		view:onExit()
	end
	local view1 = self.subViews[SubViewType.PickUp].obj
	if view1 then
		view1:onExit()
	end
end


--新手引导
function SettingView:selHandupView()
	self:showSubView(SubViewType.Handup)
	self.tagView:setSelIndex(1)	
end

function SettingView:getFirstHandUpSkill()
	local handUpView = self.subViews[SubViewType.Handup].obj
	if handUpView and handUpView:getRootNode():isVisible() then
		return handUpView:getFirstHandUpSkill()
	end
end

function SettingView:getOKBtn()
	local handUpView = self.subViews[SubViewType.Handup].obj
	if handUpView and handUpView:getRootNode():isVisible() then
		return handUpView:getOKBtn()
	end
end	