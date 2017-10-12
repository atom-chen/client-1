require("common.baseclass")

MainPingView = MainPingView or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local size = CCSizeMake(110,32)
local colorSize = CCSizeMake(20,32)


local levelColor = 
{
	[1] = ccc4f(0, 1, 0, 1),
	[2] = ccc4f(1, 1, 0, 1),
	[3] = ccc4f(1, 0, 0, 1)
}
function MainPingView:__init()
	self.rootNode = CCLayer:create()	
	self.rootNode:retain()
	self.rootNode:setContentSize(size)
	self.currentLevel = 1	
	self:initView()
		
end	

function MainPingView:__delete()
	if self.rootNode then
		self.rootNode:removeFromParentAndCleanup(true)
		self.rootNode:release()
		self.rootNode = nil
	end
end


function MainPingView:initView()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("talisman_bg.png"),size)	
	
	if self.bg then
		self.rootNode:addChild(self.bg)
		VisibleRect:relativePosition(self.bg,self.rootNode,LAYOUT_CENTER)
		self.colorNode = CCNode:create()
		self.colorNode:setContentSize(colorSize)
		self.rootNode:addChild(self.colorNode)
		VisibleRect:relativePosition(self.colorNode,self.rootNode,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(10,0))		
		self:updatePingColor(self.currentLevel)
		self.pingLable = createLabelWithStringFontSizeColorAndDimension("ping:0","Arial",FSIZE("Size2"),FCOLOR("ColorWhite1"),CCSizeMake(0,0))
		if self.pingLable then
			self.rootNode:addChild(self.pingLable)
			VisibleRect:relativePosition(self.pingLable,self.colorNode,LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER,ccp(10,0))	
		end
	end		
end

function MainPingView:getRootNode()
	return self.rootNode
end

function MainPingView:getSquare(color,width,height)
	local drawNode = CCDrawNode:create()
	local arr = CCPointArray:create(4)
	
	arr:addControlPoint(ccp(0,0))
	arr:addControlPoint(ccp(0,height))
	arr:addControlPoint(ccp(width,height))
	arr:addControlPoint(ccp(width,0))
		
	drawNode:setContentSize(CCSizeMake(width,height))
	drawNode:drawPolygonWithArray(arr, color, 0, color)
	return drawNode
end


function MainPingView:updatePingColor(level)
	local color = levelColor[level]
	if color then
		if self.colorNode then
			self.colorNode:removeAllChildrenWithCleanup(true)
			local colorSquare = self:getSquare(color,20,14)
			self.colorNode:addChild(colorSquare)
			VisibleRect:relativePosition(colorSquare,self.colorNode,LAYOUT_CENTER)
			self.currentLevel = level
		end
	end
end

function MainPingView:updatePing(level)
	if self.rootNode then
		local lag = GameWorld.Instance:getTimeManager():getLag()
		if lag > 999 then
			lag = 999
		end
		local lagStr = string.format("ping:%.0f",lag)
		if self.pingLable then
			self.pingLable:setString(lagStr)
		end
		if self.currentLevel ~= level then
			self:updatePingColor(level)
		end	
	end
		
end



