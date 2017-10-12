--Juchao@2014
LayoutNode = LayoutNode or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function LayoutNode:__init()
	self.grids 	= {}
	self.cellSize 	= CCSizeMake(60, 60)
	self.hSpacing 	= 0
	self.vSpacing 	= 0
	self.column 	= 5
	self.bTouchEnabled = false	
end

function LayoutNode:__delete()
	if self.touchLayer then
		self.touchLayer:release()
		self.touchLayer = nil
	end
	self.rootNode:release()
	self:clear()	
end	

--ʹ���������ʼ��
function LayoutNode:initWithBatchPvr(pvr)
	self.batchPvr = pvr
	self.rootNode = SFSpriteBatchNode:create(pvr)
	self.rootNode:retain()
end

--������ʼ������ʹ��������
function LayoutNode:init()
	self.batchPvr = nil
	self.rootNode = CCNode:create()
	self.rootNode:retain()
end

--�����Ƿ�ɼ�
function LayoutNode:setVisible(bShow)
	self.rootNode:setVisible(bShow)
end

--�Ƿ�ɼ�
function LayoutNode:isVisible()
	return self.rootNode:isVisible()
end

--�Ƿ�Ϊ��
function LayoutNode:isEmpty()
	return table.isEmpty(self.grids)
end

--���ø��Ӵ�С
function LayoutNode:setCellSize(size)
	self.cellSize = size
end

--��ʾ����
function LayoutNode:setGrids(grids, bReload)
	if type(grids) == "table" then	
		self.grids = grids		
		if bReload then
			self:reload()
		end
	end
end	

function LayoutNode:reload()
	self.rootNode:removeAllChildrenWithCleanup(true)	
	self:setTouchEnabled(self.bTouchEnabled)
	self.rootNode:setContentSize(self:getContentSize())
	local size = table.size(self.grids)
	if size > 0 then 
		for k, v in pairs(self.grids) do			
			self:addGrid(k, v)			
		end
	end
end

function LayoutNode:getContentSize()
	local size = table.size(self.grids)
	if size <= 0 then
		return CCSizeMake(0, 0)
	end
	
	local row
	local column
	if self.column > 0 then
		row = math.ceil(size / self.column)	
		column = self.column
	else
		row = 1
		column = size
	end
	return CCSizeMake(column * self.cellSize.width + (column - 1) * self.hSpacing, row * self.cellSize.height + (row - 1) * self.vSpacing)
end
	
--����һ��node��ָ������
function LayoutNode:addGrid(index, grid)
	if type(grid) == "table" then
		local row, column = self:getPosition(index)		
		if row and column then
			if not self.batchPvr then
				self.rootNode:addChild(grid:getRootNode())
				VisibleRect:relativePosition(grid:getRootNode(), self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,
							ccp((column - 1) * self.cellSize.width + column * self.hSpacing, -((row - 1) * self.cellSize.height + row * self.vSpacing)))							
			else
				grid:setParent(self.rootNode)
				grid:relativePosition(self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_LEFT_INSIDE,
							ccp((column - 1) * self.cellSize.width + column * self.hSpacing, -((row - 1) * self.cellSize.height + row * self.vSpacing)))
			end
		end
	end
end	

--��ȡ��/��
function LayoutNode:getPosition(index)
	local row 
	local column
	if self.column > 0 then
		row 	= math.ceil(index / self.column)	--�� -
		column	= math.ceil(index % self.column)	--�� |
		if column == 0 then
			column = self.column
		end
	else
		column = index 
		row = 1
	end
		return row, column               
end

function LayoutNode:setColumn(column)
	self.column = column
end

--��ȡĳһ������
function LayoutNode:getGridAtIndex(index)
	return self.grids[index]
end

--��ȡ���и���
function LayoutNode:getGrids()
	return self.grids
end

--���ü�϶
function LayoutNode:setSpacing(hSpacing, vSpacing)
	if type(hSpacing) == "number" and type(vSpacing) == "number" then	
		self.hSpacing = hSpacing
		self.vSpacing = vSpacing
	end
end

--�����Ƿ�֧�ִ���
function LayoutNode:setTouchEnabled(bTouch)
	if bTouch and (not self.touchLayer) then	
		self.touchLayer = CCLayer:create()
		self.touchLayer:retain()
		self.touchLayer:setTouchEnabled(true)	
		--��������¼�
		local function ccTouchHandler(eventType, x,y)
			if self.touchLayer and self.bTouchEnabled and self.touchFunc  then
				if eventType == "began" then
					local point = self.rootNode:convertToNodeSpace(ccp(x, y))
					for k, v in pairs(self.grids) do
						if v:getRootNode():boundingBox():containsPoint(point) then	
							self.touchFunc(k)			
							return 1	
						end
					end
					return 0
				else
					return 1
				end
			else
				return 0
			end
		end
		self.touchLayer:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)		
	end
	if self.touchLayer and (not self.touchLayer:getParent()) then
		self.rootNode:addChild(self.touchLayer)
		VisibleRect:relativePosition(self.touchLayer, self.rootNode, LAYOUT_CENTER)
	end
	self.bTouchEnabled = bTouch
end

function LayoutNode:isTouchEnabled()
	return self.bTouchEnabled
end

function LayoutNode:setTouchNotify(func)
	self.touchFunc = func
end

--��ȡ��϶
function LayoutNode:getSpacing()
	return self.hSpacing, self.vSpacing
end

function LayoutNode:getRootNode()
	return self.rootNode
end

function LayoutNode:clear()
	self.rootNode:removeAllChildrenWithCleanup(true)
	self.grids = {}
	self:setTouchEnabled(self.bTouchEnabled)
end