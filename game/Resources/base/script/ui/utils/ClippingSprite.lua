-- 可根据需要的形状，剪切精灵
--Juchao@20140317:
--[[
用法(显示一张图的圆圈部分)：
local clipper = ClippingSprite.New()
clipper():getRootNode():addChild(child)
clipper():drawCircle()
--]]
ClippingSprite = ClippingSprite or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()

function ClippingSprite:__init()
	self.rootNode = CCClippingNode:create()
	self.rootNode:retain()
	
	self.drawNode = CCDrawNode:create()
	self.rootNode:setStencil(self.drawNode)		
    self.rootNode:setPosition(ccp(const_visibleSize.width / 2, const_visibleSize.height / 2))	
end		

function ClippingSprite:__delete()
	self.rootNode:release()	
end	

function ClippingSprite:clear()
	self.drawNode:clear()
end

function ClippingSprite:getRootNode()
	return self.rootNode
end

function ClippingSprite:getDrawNode()
	return self.drawNode
end

function ClippingSprite:clear()
	self.drawNode:clear()
end

function ClippingSprite:moveDrawNodeTo(pos)
	self.drawNode:setPosition(pos)
end

function ClippingSprite:isInverted()
	return self.rootNode:isInverted()
end

--设置是否显示剪切部分之外的部分。默认为false，即显示剪切的部分
function ClippingSprite:setInverted(bInverted)
	self.rootNode:setInverted(bInverted)
end		

--画一个圆
function ClippingSprite:drawCircle(radius)
	local green 	= ccc4f(0, 1, 0, 1)	
	local nCount	= 100;				--圆形其实可以看做正多边形,用正100边型来模拟圆形
	local coef 		= 2 * ((3.14159265358979323846)/nCount);--计算每两个相邻顶点与中心的夹角

	local arr = CCPointArray:create(100)
	for i = 1, 100 do
		local rads = i * coef;--弧度
		arr:addControlPoint(ccp(radius * math.cos(rads), radius * math.sin(rads)))
	end		
	self.drawNode:setContentSize(CCSizeMake(radius * 2, radius * 2))
	self.drawNode:drawPolygonWithArray(arr, green, 0, green) --绘制这个多边形)
end

--画一个多边形
--pointArray: CCPointArray类型，放置该多边形的各个定点
--fillColor: ccColor4F类型，填充的颜色
--borderWidth: float类型，边缘的宽度
--borderColor: ccColor4F类型，边缘的宽度
function ClippingSprite:drawPolygon(pointArray, fillColor, borderWidth, borderColor)
	self.drawNode:drawPolygonWithArray(pointArray, fillColor, borderWidth, borderColor) --绘制这个多边形
end