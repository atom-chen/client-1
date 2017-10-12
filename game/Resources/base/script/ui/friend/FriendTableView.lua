-- 显示背包的详情
require("ui.UIManager")
require("common.BaseUI")
require("config.words")

FriendTableView = FriendTableView or BaseClass(BaseUI)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size = CCSizeMake(380, 380)

function FriendTableView:__init()
	self.viewName = "FriendTableView"
	self.rootNode:setContentSize(const_size)
	self.rootNode:setTouchEnabled(false)  --否则父node得不到触摸事件
	self:showCapacity(0, 0)
end		

function FriendTableView:setFriendMap()
end

function FriendTableView:createGoodFriendList()
	local instance = FriendTableView.New()
	instance:showTitle("我的好友")
	return instance
end

function FriendTableView:createBlackList()
	local instance = FriendTableView.New()
	instance:showTitle("我的黑名单")
	return instance
end

------------以下为私有方法-------------
function FriendTableView:showTitle(text)
	if (self.titleText == nil) then	
		self.titleText = createLabelWithStringFontSizeColorAndDimension(text, "Arial", 25, ccc3(255, 255,0))	
		self.rootNode:addChild(self.titleText)		
	else
		self.titleText:setString(text)
	end	
	VisibleRect:relativePosition(self.titleText, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(20, 0))
end

function FriendTableView:showCapacity(onlineCount, capacity)
	if (self.capacitText == nil) then	
		self.capacitText = createLabelWithStringFontSizeColorAndDimension(string.format("(%d/%d)", onlineCount, capacity), "Arial", 25, ccc3(255, 255,0))	
		self.rootNode:addChild(self.capacitText)		
	else
		self.capacitText:setString(string.format("(%d/%d)", onlineCount, capacity))
	end	
	VisibleRect:relativePosition(self.capacitText, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE, ccp(150, 0))
end
