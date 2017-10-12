--使用一个node作为参照物，管理其他'children'的布局。children实际是add到参照物的parent上面。
RelativeNode = RelativeNode or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function RelativeNode:__init(node)
	if not node then
		error("RelativeNode error: node must not be nil. RelativeNode will not work")
		return
	end
	self.children = {--[[ [x] = {obj = , z = , layout = , offset = } --]]}
	self.rootNode = node			
	self.rootNode:retain()
	self.parent = nil
	self.childMaxIndex = 0
end		

function RelativeNode:__delete()
	self.rootNode:removeFromParentAndCleanup(true)
	self.rootNode:release()
	for k, v in pairs(self.children) do
		v.node:removeFromParentAndCleanup(true)
		v.node:release()
	end
	self.children = {}
	if self.parent then
		self.parent:release()
		self.parent = nil
	end
	self.rootNode = nil
end	

function RelativeNode:setNotify(func)
	self.notifyFunc = func
end
	
function RelativeNode:getRootNode()
	return self.rootNode
end	

--layout: 相对于self.rootNode的布局
--offset: 相对于self.rootNode布局的偏移
function RelativeNode:addChild(node, z, layout, offset)
	if (not node) or (not z) or  (not layout) then
		error("RelativeNode addChild error: (not node) or (not z) or  (not layout)")
		return
	end
	node:retain()
	if not offset then
		offset = ccp(0, 0)
	end
	local data = {node = node, z = z, layout = layout, offset = offset}
	self.childMaxIndex = self.childMaxIndex + 1
	self.children[self.childMaxIndex] = data
	if self.rootNode:getParent() then
		self.rootNode:getParent():addChild(node)
		node:setZOrder(z)
		VisibleRect:relativePosition(node, self.rootNode, layout, offset)		
	end	
end

function RelativeNode:removeChild(node)
	if self.rootNode:getParent() then
		self.rootNode:getParent():removeChild(node, true)		
	end		
	for k, v in pairs(self.children) do
		if v.node == node then
			v.node:release()
			self.children[k] = nil
			break
		end
	end
end

function RelativeNode:setVisible(bShow)
	if self then
		self.rootNode:setVisible(bShow)
		self:setChildrenVisible(bShow)
	end		
end

function RelativeNode:setChildrenVisible(bShow)
	for k, v in pairs(self.children) do
		v.node:setVisible(bShow)
	end
end

function RelativeNode:dettachAllChild()
	if not self then
		return
	end
	
	local parent = self.rootNode:getParent()
	if parent then
		for k, v in pairs(self.children) do		
			v.node:removeFromParentAndCleanup(true)
		end	
	end
end

function RelativeNode:getChildren()
	return self.children
end

function RelativeNode:attachAllChild()
	local parent = self.rootNode:getParent()
	if parent then
		for k, v in pairs(self.children) do		
			if v.node:getParent() then
				v.node:removeFromParentAndCleanup(true)
			end
			parent:addChild(v.node)
			v.node:setZOrder(v.z)
			VisibleRect:relativePosition(v.node, self.rootNode, v.layout, v.offset)							
		end	
	end
end

function RelativeNode:setPosition(point)
	self.rootNode:setPosition(point)
	self:updateLayout()
end

function RelativeNode:relativePosition(target, layout, offset)
	VisibleRect:relativePosition(self.rootNode, target, layout, offset)
	self:updateLayout()
end

function RelativeNode:setParent(parent)
	self:removeParent()
	if parent then
		parent:retain()
		self.parent = parent
		self.parent:addChild(self.rootNode)
		self:attachAllChild()
	end
end

function RelativeNode:removeParent()
	self:dettachAllChild()
	self.rootNode:removeFromParentAndCleanup(true)	
	if self.parent then
		self.parent:release()
		self.parent = nil
	end
end

function RelativeNode:updateLayout()
	local parent = self.rootNode:getParent()
	if parent then
		for k, v in pairs(self.children) do				
			VisibleRect:relativePosition(v.node, self.rootNode, v.layout, v.offset)
		end	
	end
end