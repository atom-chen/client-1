-- 显示背包的详情
require("common.baseclass")

PageIndicateView = PageIndicateView or BaseClass()
local constSpacing = 15		--每个图标的间隔

function PageIndicateView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.pageIcons = {}
	self.index = 1
end				

function PageIndicateView:getRootNode()
	return self.rootNode
end

function PageIndicateView:__delete()
	self.rootNode:release()
end


-- 设置一共有多少页
function PageIndicateView:setPageCount(count, index)
	if (count < 1) then
		return
	end	
	self.rootNode:removeAllChildrenWithCleanup(true)
	self.pageIcons = {}	
	local preNode = nil --布局参照的layout
	for i = 1, count do
		local icon = self:createNormalIcon()
		self.pageIcons[i] = icon
		self.rootNode:addChild(icon)		
		if (i == 1) then
			VisibleRect:relativePosition(icon, self.rootNode, LAYOUT_LEFT_INSIDE + LAYOUT_BOTTOM_OUTSIDE, ccp(0, -40), false)
		else			
			VisibleRect:relativePosition(icon, preNode, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(constSpacing, 0), false)
		end
		preNode = icon
	end
	
	local width = count * self.pageIcons[1]:getContentSize().width + (count - 1) * constSpacing
	local height = self.pageIcons[1]:getContentSize().height
	self.rootNode:setContentSize(CCSizeMake(width, height))
	self:setIndex(index)
end	

-- 设置当前页数索引
function PageIndicateView:setIndex(index)
	if ((index < 1) or (index > (#self.pageIcons)) or (type(index) ~= "number")) then
		return
	end		
	if (self.pageIcons[self.index]) then
		self.pageIcons[self.index]:removeAllChildrenWithCleanup(true)
	end
	self.index = index
	local selectIcon = self:createSelectedIcon()
	self.pageIcons[self.index]:addChild(selectIcon)
	VisibleRect:relativePosition(selectIcon, self.pageIcons[self.index], LAYOUT_CENTER)	
end	

function PageIndicateView:getIndex()
	return self.index
end

function PageIndicateView:createNormalIcon()
	return createSpriteWithFrameName(RES("page_btn.png"))
end

function PageIndicateView:createSelectedIcon()
	return createSpriteWithFrameName(RES("page_btnBg.png"))
end








