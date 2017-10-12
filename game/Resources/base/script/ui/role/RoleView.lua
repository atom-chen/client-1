-- 角色的界面(游戏的主界面点击角色按键时进入)
require("ui.UIManager")
require("common.BaseUI")
require("GameDef")
require("ui.role.RoleSubPropertyView")
require("ui.role.RoleSubKnightView")
require("config.words")
RoleView = RoleView or BaseClass(BaseUI)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local RoleSubViewType = 
{
	Knight = 1,
	Role = 2
}

function RoleView:__init()
	self.roleSubView = 
	{	
		[RoleSubViewType.Knight] = 
		{ 
			name = Config.Words[3050],
			new = RoleSubKnightView.New,		
			instance = nil,
			check = self.checkKnight,		
			disableCallBack = self.onKnightDisableClick,	--当状态为禁用时的回调
		},
		[RoleSubViewType.Role] = 
		{ 
			name = Config.Words[3049],
			new = RoleSubPropertyView.New,		
--			new = RoleSubKnightView.New,		
			instance = nil,
			check = nil,
			disableCallBack = nil,
		},
	} 	
	
	self.viewName = "RoleView"
	self:init(CCSizeMake(418, 564))
	self:setFormImage(createSpriteWithFrameName(RES("main_role.png")))
	self:setFormTitle(createSpriteWithFrameName(RES("word_window_role.png")), TitleAlign.Left)	
	self:initTabView()
	self.currentView = {}
	self:showSubView(RoleSubViewType.Role)
end

function RoleView:__delete()
	for i,v in pairs(self.roleSubView) do
		if(v.instance) then
			v.instance:DeleteMe()
		end
	end
end

function RoleView:create()
	return RoleView.New()
end	

function RoleView:onEnter(arg)
	self.player = arg			--玩家table{playerObj,playerType(0：玩家自己、1：其他玩家)}	
	if(self.player.playerType ~= 0) then	--查看其他玩家信息，隐藏角色、爵位标签
		self.tagView:setVisible(false)	
		self:showSubView(RoleSubViewType.Role)	
	else		
		self.tagView:setVisible(true)
	end
	if self.currentView.instance and self.currentView.instance.onEnter then
		self.currentView.instance:onEnter(arg)
	end
	if self.roleSubView[RoleSubViewType.Knight].instance then
		self.roleSubView[RoleSubViewType.Knight].instance:onExit()
	end
end



function RoleView:getNodeByName(name)
	if name == "RoleSubPropertyView" then
		return self.roleSubView[RoleSubViewType.Role].instance
	elseif name == "RoleSubKnightView" then
		return self.roleSubView[RoleSubViewType.Knight].instance
	end
end

function RoleView:onExit()
	GlobalEventSystem:Fire(GameEvent.EVENT_HideDetailProperty)
	local show = UIManager.Instance:isShowing("BatchSellView")
	if not show then
		GlobalEventSystem:Fire(GameEvent.EventHideBag)
	end
	GlobalEventSystem:Fire(GameEvent.EventHideNormalItemDetailView)
	GlobalEventSystem:Fire(GameEvent.EventHideEquipItemDetailView)
	GlobalEventSystem:Fire(GameEvent.EventHidePutOnEquipItemDetailView)		
	self:showSubView(RoleSubViewType.Role)
end

function RoleView:createLockBtn(name)
	local btn = createButtonWithFramename(RES("tab_disable.png"))
	local lock = createScale9SpriteWithFrameName(RES("bagBatch_iocnLock.png"))	
	btn:addChild(lock)
	VisibleRect:relativePosition(lock, btn, LAYOUT_LEFT_INSIDE + LAYOUT_TOP_INSIDE, ccp(10, -10))
	
	local label = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"),CCSizeMake(22*const_scale,0))				
	btn:setTitleString(label)
	VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)
	return btn
end

function RoleView.checkKnight()
	local hero = G_getHero()
	local curLevel = PropertyDictionary:get_knight(hero:getPT())	
	return curLevel > 0
end

function RoleView.onKnightDisableClick()
	UIManager.Instance:showSystemTips(Config.Words[6012])
end

function RoleView:initTabView()
	local btnArray = CCArray:create()				
	for key, value in ipairs(self.roleSubView) do
		local function createBtn(key)	
			value.normalBtn = createButtonWithFramename(RES("tab_2_normal.png"), RES("tab_2_select.png"))			
			value.label = createLabelWithStringFontSizeColorAndDimension(value.name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"),CCSizeMake(22*const_scale,0))																			
			value.normalBtn:setTitleString(value.label)
			VisibleRect:relativePosition(value.label, value.normalBtn, LAYOUT_CENTER,ccp(0,0))
			btnArray:addObject(value.normalBtn)
			local onTabPress = function()
				self:showSubView(key)	
				if key==RoleSubViewType.Knight then
					self:clickKnightSubBtn()	
				end
					
			end	
			value.normalBtn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
			
			if value.check then
				value.disableBtn = self:createLockBtn(value.name)
				if value.check() then
					value.disableBtn:setVisible(false)
					value.normalBtn:setVisible(true)
				else
					value.disableBtn:setVisible(true)
					value.normalBtn:setVisible(false)
				end
				value.disableBtn:addTargetWithActionForControlEvents(value.disableCallBack, CCControlEventTouchDown)				
			end
		end
		createBtn(key)
	end
	self.tagView = createTabView(btnArray, 10 * const_scale, tab_vertical)
	self:addChild(self.tagView, 1)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(E_OffsetView.eWidth-60, -(7 + E_OffsetView.eHeight)))			
	
	for k, v in pairs(self.roleSubView) do
		if v.disableBtn then
			self.tagView:addChild(v.disableBtn)
			VisibleRect:relativePosition(v.disableBtn, v.normalBtn, LAYOUT_CENTER)
		end
	end
end

function RoleView:createSubView(keys)
	local view =  self.roleSubView[keys].new()	-- 创建实例	
	self.roleSubView[keys].instance = view 	  	-- 将实例保存在instance字段
	local node = view:getRootNode()
	node:setVisible(false)		
	self:addChild(node)
	VisibleRect:relativePosition(node, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -0))
end

function RoleView:showSubView(key)
	if (self.currentView.instance ~= nil) then
		local oldNode = self.currentView.instance:getRootNode()
		oldNode:setVisible(false)
		self.currentView.label:setColor(FCOLOR("ColorWhite4"))
	end
	if self.roleSubView[key].instance == nil then
		self:createSubView(key)
	end

	local newNode = self.roleSubView[key].instance:getRootNode()		
	self.roleSubView[key].label:setColor(FCOLOR("ColorWhite3"))
	newNode:setVisible(true)
	self.currentView = self.roleSubView[key]
	self.currentKey = key
	
	self.tagView:setSelIndex(key - 1)	
	VisibleRect:relativePosition(newNode, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, ccp(0, -0))
end

function RoleView:updateKnight(pt)
	if(self.roleSubView[RoleSubViewType.Knight].instance ~= nil) then
		if table.size(pt)<=0 then
			pt = GameWorld.Instance:getEntityManager():getHero():getPT()
		end
		self.roleSubView[RoleSubViewType.Knight].instance:refreshKnightInfo(pt)
	end
	if self.checkKnight() then		--开启爵位
		self.roleSubView[RoleSubViewType.Knight].disableBtn:setVisible(false)
		self.roleSubView[RoleSubViewType.Knight].normalBtn:setVisible(true)
	else
		self.roleSubView[RoleSubViewType.Knight].disableBtn:setVisible(true)
		self.roleSubView[RoleSubViewType.Knight].normalBtn:setVisible(false)
	end
end

function RoleView:setKnightSalary()
	if(self.roleSubView[RoleSubViewType.Knight].instance ~= nil) then
		self.roleSubView[RoleSubViewType.Knight].instance:setSalary()
	end
end

function RoleView:setSelIndex(index)
	self.tagView:setSelIndex(index)
end	

-----------------------------------------------------------
--新手指引

function RoleView:getKnightSubBtn()
	local btn = self.roleSubView[RoleSubViewType.Knight].normalBtn
	return btn
end

function RoleView:clickKnightSubBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"RoleView","knightSubBtn")
end

function RoleView:getUpgradeKnightBtn()
	local instance = self.roleSubView[RoleSubViewType.Knight].instance
	if instance then
		local btn = instance:getUpgradeKnightBtn()
		return btn
	end
end	

function RoleView:clickKnightSubBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"RoleView","upgradeKnightBtn")
end
-----------------------------------------------------------