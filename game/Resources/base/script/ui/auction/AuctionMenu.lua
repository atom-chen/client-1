AuctionMenu = AuctionMenu or BaseClass(BaseUI)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(310, 480)	
local const_spacing = 70
local const_btnHeight = 75
local const_topMargin = 38

function AuctionMenu:__init()	
	self.viewName = "AuctionMenu"
	self:init(const_size)			
	
	self.optionList = {}
	self:createView()
end

function AuctionMenu:__delete()
end	

function AuctionMenu:createView()
	local size = CCSizeMake(self:getContentNode():getContentSize().width, self:getContentNode():getContentSize().height)
	self.scrollView = createScrollViewWithSize(size)
	self.scrollView:setDirection(2) 
	self:addChild(self.scrollView)
	VisibleRect:relativePosition(self.scrollView, self:getContentNode(), LAYOUT_CENTER)
	
	self.scrollNode = CCNode:create()
	self.scrollNode:setContentSize(self:getContentNode():getContentSize())
	self.scrollView:setContainer(self.scrollNode)	
	
	local arrowUp = createSpriteWithFrameName(RES("login_knight_arrow.png"))
	arrowUp:setRotation(-90)
	self:addChild(arrowUp)
	
	local arrowDown = createSpriteWithFrameName(RES("login_knight_arrow.png"))
	arrowDown:setRotation(90)
	self:addChild(arrowDown)
	
	VisibleRect:relativePosition(arrowUp, self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, 0))
	VisibleRect:relativePosition(arrowDown, self:getContentNode(), LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 37))
end

function AuctionMenu:setOptionList(list, tag)
	self.tag = tag
	self.optionList = {}	
	
	self.scrollNode:removeAllChildrenWithCleanup(true)
	local preNode = nil
	
	local size = table.size(list)
	if size == 0 then
		return
	end
	local height = (size - 1) * const_spacing + size * const_btnHeight + const_topMargin
	self.scrollNode:setContentSize(CCSizeMake(self:getContentNode():getContentSize().width, height))
	
	for k, v in ipairs(list) do			
		local node = self:createOptionNode(self.tag, v.value, v.image)
		if node then
			local btn = createButtonWithFramename(RES("btn_1_select.png"))	
			btn:addChild(node)
			VisibleRect:relativePosition(node, btn, LAYOUT_CENTER)
			self.scrollNode:addChild(btn)		
					
			if preNode == nil then
				VisibleRect:relativePosition(btn, self.scrollNode, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE, ccp(0, -const_topMargin))	
			else
				VisibleRect:relativePosition(btn, preNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -const_spacing))	
			end
			preNode = btn	
			self.optionList[v.value] = btn
			
			local onClick = function ()						
				self:close()				
				GlobalEventSystem:Fire(GameEvent.EventAuctionSearchValueChanged, self.tag, v.value)				
			end
			btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
		end
	end
	self.scrollNode:retain()
	self.scrollView:setContainer(self.scrollNode)	
	self.scrollNode:release()
	self.scrollView:setContentOffset(ccp(0, -(height - self:getContentNode():getContentSize().height)), false)
end

function AuctionMenu:createOptionNode(ttype, value, image)
	local node
	if ttype == AuctionSearchBtnType.Level and image == "" then	
		local num = createAtlasNumber(Config.AtlasImg.AuctionNum, tostring(value))
		local level = createSpriteWithFrameName(RES("word_Level.png"))		
		node = CCNode:create()
		node:setContentSize(CCSizeMake(num:getContentSize().width + level:getContentSize().width, num:getContentSize().height + level:getContentSize().height))
		node:addChild(num)
		node:addChild(level)
		VisibleRect:relativePosition(num, node, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE)
		VisibleRect:relativePosition(level, num, LAYOUT_CENTER_Y + LAYOUT_RIGHT_OUTSIDE)
	elseif image ~= "" then
		node = createSpriteWithFrameName(RES(image))
	end
	return node
end

function AuctionMenu:setTitle(image)
	local titleTips = createSpriteWithFrameName(image)
	self:setFormTitle(titleTips, TitleAlign.Center)
end
