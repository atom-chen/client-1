-- ÏÔÊ¾Ò»¸ö³á°ò
WingSprite = WingSprite or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function WingSprite:__init()
	self.viewName = "WingSprite"
	self.rootNode = CCNode:create()
	self.rootNode:retain()
end		

function WingSprite:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function WingSprite:getRootNode()
	return self.rootNode
end	

function WingSprite:setIcon(path)
	if self.path == path then
		return
	end
	self.path = path
	if self.rootNode and (type(path) == "string") then
		self.rootNode:removeAllChildrenWithCleanup(true)
		local sprite1 = createSpriteWithFrameName(path)
		local sprite2 = createSpriteWithFrameName(path)
		
		if sprite1 then
			self.rootNode:addChild(sprite1)
			local size = sprite1:getContentSize()
			self.rootNode:setContentSize(size)
			VisibleRect:relativePosition(sprite1, self.rootNode, LAYOUT_CENTER)			
		end
		
		if sprite2 then
			sprite2:setFlipX(true)
			self.rootNode:addChild(sprite2)
			VisibleRect:relativePosition(sprite2, self.rootNode, LAYOUT_CENTER)
		end	
	end
end		