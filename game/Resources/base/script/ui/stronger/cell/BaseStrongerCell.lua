--我要变强的cell基类

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
	
	--记录cell的name
	self.cellName = "BaseStrongerCell"
	
	--记录该cell是否ready: 所需要的数据是否到齐。
	self.bIsReady = false
	
	--记录cell的id
	self.cellId = g_count
	
	--全局的cell计数
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

--虚函数，被点击时由外部调用
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

--是否是推荐的
function BaseStrongerCell:isRecommended()
	return false	
end

function BaseStrongerCell:getRootNode()
	return self.rootNode
end