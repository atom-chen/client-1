SystemTips = SystemTips or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()


function SystemTips:__init(tipsType)
	self.tipsCount = 0	
	self.rootNode = CCLayer:create()		
	self.rootNode:setContentSize(visibleSize)	
	self.rootNode:retain()			
		
	local tipsInsert = function(tipsType)
		if self.rootNode then
			self:insertTips(tipsType)
		end
	end
	if self.systemTipsInsert == nil then
		self.systemTipsInsert = GlobalEventSystem:Bind(GameEvent.EventTipsInsert,tipsInsert)
	end	
end
	
function SystemTips:__delete()
	for i = 1, 6 do
		local lastTipsLb = self.rootNode:getChildByTag(i)
		if  lastTipsLb then
			lastTipsLb:stopAllActions()
			lastTipsLb:setVisible(false)
		end
	end
	self.rootNode:release()	
	self:bindRelease()
	self.rootNode = nil	
end	

function SystemTips:insertTips(tipsType)	
	local tipsMgr = LoginWorld.Instance:getTipsManager()		
	local currentTips = tipsMgr:getCurrentTips()
	
	if not currentTips then
		return
	end
	local msg  = currentTips.msg
	local fontsize  = currentTips.fontsize		
	local viewsize = currentTips.viewsize
	local duration = currentTips.duration

	local setTextContain = function(msgLabel)
		msgLabel:clearAll()
		self.latestLabel = msgLabel
		for k,v in pairs(msg) do	
			local text = string.wrapRich(v.word, v.color, fontsize)
			msgLabel:appendFormatText(text)
		end	
	end

	local msgLabel
	if tipsType == E_TipsType.emphasize then
		local textLable = createRichLabel(viewsize)
		setTextContain(textLable)	
		local textLableSize = textLable:getContentSize()
		msgLabel = createScale9SpriteWithFrameNameAndSize(RES("countDownBg.png"),CCSizeMake(textLableSize.width+10,textLableSize.height+10))		
		msgLabel:addChild(textLable)
		VisibleRect:relativePosition(textLable,msgLabel,LAYOUT_CENTER)	
	else
		msgLabel = createRichLabel(viewsize)
		setTextContain(msgLabel)
	end
	msgLabel:setAnchorPoint(ccp(0.5,0.5))
	msgLabel:setTag(1)	
	self:setTipsPosition()		
		
	self.tipsCount = self.tipsCount + 1
	self.rootNode:addChild(msgLabel)	
	
	local preLabel = self.rootNode:getChildByTag(2)
	if preLabel then 
		VisibleRect:relativePosition(msgLabel, preLabel, LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE)		
	else
		VisibleRect:relativePosition(msgLabel, self.rootNode, LAYOUT_CENTER,ccp(0,120))		
	end			
	
	self:setTipsEffect(msgLabel,duration)
end

function SystemTips:setTipsPosition()
	if self.tipsCount >= 6 then
		local lastTipsLb = self.rootNode:getChildByTag(6)
		self.tipsCount = self.tipsCount - 1
		if not lastTipsLb then
			return	
		else 
			self.rootNode:removeChildByTag(6,true)
			self:moveTipsPosition(5)			
			self.tipsCount = 5
		end
	else				
		self:moveTipsPosition(self.tipsCount)
	end	
end

function SystemTips:moveTipsPosition(count)
	local offsetY = 0	
	local prePos = {}	
	local preTips 	
	for i = 1, count do
		local lastTipsLb = self.rootNode:getChildByTag(i)
		if not lastTipsLb then
			return
		end													
			
		local size = lastTipsLb:getContentSize()				
		if i==1 then		
			local latestSize = self.latestLabel:getContentSize()																					
			VisibleRect:relativePosition(lastTipsLb, self.rootNode, LAYOUT_CENTER,ccp(0,120))																							
		else					
			VisibleRect:relativePosition(lastTipsLb, preTips, LAYOUT_TOP_OUTSIDE+LAYOUT_CENTER)									
		end
		preTips = lastTipsLb
		prePos.x, prePos.y = lastTipsLb:getPosition()												
		lastTipsLb:setTag(i+1)													
	end						
end

function SystemTips:setTipsEffect(target,duration)
	local delay = CCDelayTime:create(duration)		
	local function finishRunRightCallback()
		if not target then
			return
		end
		local tag = target:getTag()
		if not self.rootNode then
			return
		end
		local lastTipsLb = self.rootNode:getChildByTag(tag)
		if not lastTipsLb then
			return			
		else
			lastTipsLb:setVisible(false)
			self.rootNode:removeChildByTag(tag,true)
			lastTipsLb = nil
			self.tipsCount = self.tipsCount - 1			
		end						
	end
	local callbackAction = CCCallFunc:create(finishRunRightCallback)
	local spawnArray = CCArray:create()	
	spawnArray:addObject(delay)
	spawnArray:addObject(callbackAction)
	target:runAction(CCSequence:create(spawnArray))	
end


function SystemTips:getRootNode()
	return self.rootNode
end	
function SystemTips:bindRelease()
	if self.systemTipsInsert then
		GlobalEventSystem:UnBind(self.systemTipsInsert)
		self.systemTipsInsert = nil		
	end
	if self.gainTipsInsert then
		GlobalEventSystem:UnBind(self.gainTipsInsert)
		self.gainTipsInsert = nil		
	end
	if self.otherTipsInsert then
		GlobalEventSystem:UnBind(self.otherTipsInsert)
		self.otherTipsInsert = nil		
	end
end
