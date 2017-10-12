require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("ui.auction.AuctionBuy")
require("ui.auction.AuctionSell")

AuctionView = AuctionView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = nil

AuctionSubViewType = 
{	
	Buy = 1,
	Sell = 2,
}

function AuctionView:__init()
	self.viewName = "AuctionView"
	self:initFullScreen()
	
	local forgeNode = createSpriteWithFrameName(RES("main_auction.png"))
	self:setFormImage(forgeNode)
	local titleNode = createSpriteWithFrameName(RES("word_auction.png"))
	self:setFormTitle(titleNode, TitleAlign.Left)
		
	self.subViews = 
	{	
		[AuctionSubViewType.Buy] 	= {name = Config.Words[25300], new = AuctionBuy.New, 	obj = nil, },
		[AuctionSubViewType.Sell] 	= {name = Config.Words[25301], new = AuctionSell.New, obj = nil,},		
	}

	self.curViewType = nil
	self:initTabAndSubView()
	self:showSubView(AuctionSubViewType.Buy)	
	self:showMoney()	
end

function AuctionView:__delete()
end

function AuctionView:getViewByName(name)
	if name == "buy" then
		return self.subViews[AuctionSubViewType.Buy].obj
	elseif name == "sell" then
		return self.subViews[AuctionSubViewType.Sell].obj
	end		
end

function AuctionView:create()
	return AuctionView.New()
end

function AuctionView:onEnter()
	if self.curViewType ~= AuctionSubViewType.Buy then
		self:showSubView(AuctionSubViewType.Buy)
	elseif self.subViews[self.curViewType] and self.subViews[self.curViewType].obj.onEnter then
		self.subViews[self.curViewType].obj:onEnter()
	end
end

function AuctionView:onExit()
	if self.subViews[self.curViewType] and self.subViews[self.curViewType].obj.onExit then
		self.subViews[self.curViewType].obj:onExit()
	end		
end

function AuctionView:initTabAndSubView()
	local btnArray = CCArray:create()		
	for k, v in ipairs(self.subViews) do
		local function createBtn(key) 							
			v.btn = createButtonWithFramename(RES("tab_1_normal.png"), RES("tab_1_select.png"))	
			v.label = createLabelWithStringFontSizeColorAndDimension(v.name, "Arial",FSIZE("Size4") * const_scale, FCOLOR("ColorWhite4"))						
			btnArray:addObject(v.btn)
			local onTabPress = function()				
				self:showSubView(key)
			end	
			v.btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
		end
		createBtn(k)
	end
	
	self.tagView = createTabView(btnArray, 15*const_scale, tab_horizontal)
	self:getContentNode():addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self:getContentNode(), LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,ccp(60, 0))	
	
	for key, value in pairs(self.subViews) do		
		self.tagView:addChild(value.label)	
		VisibleRect:relativePosition(value.label, value.btn, LAYOUT_CENTER, ccp(2, -3))
	end
end	

function AuctionView:createSubView(key)
	local view = self.subViews[key].new()  	-- 创建实例
	self.subViews[key].obj = view 	  		-- 将实例保存在obj字段
	view:getRootNode():setVisible(false)		
	self:getContentNode():addChild(view:getRootNode())	
end

function AuctionView:setSubViewVisible(key, bShow)
	local view = self.subViews[key]		
	if (view and view.obj) then
		view.obj:getRootNode():setVisible(bShow)		
	end
end	
	
function AuctionView:showSubView(key)
	if (self.curViewType == key) then
		return		
	end

	self:setSubViewVisible(self.curViewType, false)
	if self.curViewType then
		self.subViews[self.curViewType].label:setColor(FCOLOR("ColorWhite4"))
		if self.subViews[self.curViewType].obj.onExit then
			self.subViews[self.curViewType].obj:onExit()
		end
	end
	
	self.tagView:setSelIndex(key - 1)
	self.curViewType = key
	self.subViews[self.curViewType].label:setColor(FCOLOR("ColorWhite3"))
	local newView = self.subViews[self.curViewType]
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

function AuctionView:showMoney(pt)
	if (self.unbindedGoldLabel == nil) then
		local unbindedGoldIcon = createSpriteWithFrameName(RES("common_iocnWind.png"))						
		self:addChild(unbindedGoldIcon)
		VisibleRect:relativePosition(unbindedGoldIcon, self:getContentNode(), LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(30, 0))
		
		self.unbindedGoldBg = createScale9SpriteWithFrameNameAndSize(RES("editBox_bg.png"), VisibleRect:getScaleSize(CCSizeMake(110, 24)))	
		self:addChild(self.unbindedGoldBg)		
		VisibleRect:relativePosition(self.unbindedGoldBg, unbindedGoldIcon, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(12, 0))
						
		self.unbindedGoldLabel = createLabelWithStringFontSizeColorAndDimension("88", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))						
		self:addChild(self.unbindedGoldLabel)		
	end
	
	local unbindedGold 	= -1
	if pt then
		if pt["unbindedGold"] then
			unbindedGold = PropertyDictionary:get_unbindedGold(pt)
		end
	else
		unbindedGold = PropertyDictionary:get_unbindedGold(G_getHero():getPT())	
	end	
	
	if (unbindedGold >= 0) then
		self.unbindedGoldLabel:setString(tostring(unbindedGold))
		VisibleRect:relativePosition(self.unbindedGoldLabel, self.unbindedGoldBg, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y, ccp(5, 0))
	end		
end	