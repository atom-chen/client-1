--��Ҫ��ǿ��cell����

BaseStrongerCell = BaseStrongerCell or BaseClass()

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local g_count = 0

function BaseStrongerCell:__init(size, refId)
	self.size = size
	self.refId = refId
	self.rootNode = CCNode:create()	
	self.rootNode:retain()
	self.rootNode:setContentSize(self.size)		
	
	--��¼cell��name
	self.cellName = "BaseStrongerCell"
	
	--��¼��cell�Ƿ�ready: ����Ҫ�������Ƿ��롣
	self.bIsReady = false
	
	--��¼cell��id
	self.cellId = g_count
	
	--ȫ�ֵ�cell����
	g_count = g_count + 1
	
	local function scriptHandler(eventType)  
		if eventType == "enter" then
			self:onEnter()
		elseif eventType == "exit" then
			self:onExit()
		end
    end  
    self.rootNode:registerScriptHandler(scriptHandler)
	
	self:initUI()		
end

function BaseStrongerCell:__delete()
	self.readyNotifyFunc = nil
	self.rootNode:removeFromParentAndCleanup(true)
	self.rootNode:release()
end

function BaseStrongerCell:getRefId()
	return self.refId
end

--�麯���������ʱ���ⲿ����
function BaseStrongerCell:onClick()
--	print("BaseStrongerCell:onClick id="..self.cellId)
end

function BaseStrongerCell:onEnter()
--	print("BaseStrongerCell:onEnter id="..self.cellId)
end

function BaseStrongerCell:onExit()
--	print("BaseStrongerCell:onExit id="..self.cellId)
end

function BaseStrongerCell:initUI()
	local line = createScale9SpriteWithFrameNameAndSize(RES("bag_detailed_property_line.png"), CCSizeMake(self.size.width - 20, 2))
	self.rootNode:addChild(line)
	VisibleRect:relativePosition(line, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)
end	

function BaseStrongerCell:isReady()
	return self.bIsReady
end

function BaseStrongerCell:setReady(bReady)
	self.bIsReady = bReady
	if type(self.readyNotifyFunc) == "function" then
		self.readyNotifyFunc(self.refId, bReady)
	end
--	print("BaseStrongerCell:setReady "..self.refId.." "..tostring(bReady))
end

function BaseStrongerCell:setReadyNotify(func)
	self.readyNotifyFunc = func
end

--�Ƿ����Ƽ���
function BaseStrongerCell:isRecommended()
	return false	
end

function BaseStrongerCell:getRootNode()
	return self.rootNode
end