require("object.npc.NpcDef")
require("object.npc.TransObject")
require("ui.UIManager")

NpcPickView = NpcPickView or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local viewScale = VisibleRect:SFGetScale()
local viewSize = CCSizeMake(450*viewScale, 30*viewScale)
function NpcPickView:__init()
	self.viewName = "NpcPickView"
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)	
	self.rootNode:setContentSize(viewSize)
	self.rootNode:retain()
	--self:registerScriptTouchHandler()
	
	local processBg = createScale9SpriteWithFrameNameAndSize(RES("mountProgressBottom.png"),CCSizeMake(164,16))
	VisibleRect:relativePosition(processBg,self.rootNode,LAYOUT_CENTER,ccp(0,-150))
	self.rootNode:addChild(processBg)
	
	--◊Û”“¡Ω∂À
	local processLeftHand = createSpriteWithFrameName(RES("mountProgressTop.png"))
	local processRightHand  = createSpriteWithFrameName(RES("mountProgressTop.png"))
	processRightHand:setFlipX(true)
	self.rootNode:addChild(processLeftHand, 10)
	self.rootNode:addChild(processRightHand, 11)
	VisibleRect:relativePosition(processLeftHand, processBg, LAYOUT_CENTER_Y+LAYOUT_LEFT_OUTSIDE, ccp(3, 0))
	VisibleRect:relativePosition(processRightHand, processBg, LAYOUT_CENTER_Y+LAYOUT_RIGHT_OUTSIDE, ccp(-3, 0))
	
	self.processBar =  CCProgressTimer:create(createSpriteWithFrameName(RES("npc_collect.png")))
	self.processBar:setType(kCCProgressTimerTypeBar)	
	self.processBar:setMidpoint(ccp(0, 0.5))
	self.processBar:setBarChangeRate(ccp(1,0))		
	self.rootNode:setContentSize(viewSize)
	VisibleRect:relativePosition(self.processBar, processBg, LAYOUT_CENTER)
	self.rootNode:addChild(self.processBar)
	self.curProcess = 0;
	self.processBar:setPercentage(self.curProcess)	
	
	--≤£¡ß’÷
	local grassCover = createScale9SpriteWithFrameNameAndSize(RES("common_barTopLayer.png"), CCSizeMake(166,22))
	self.rootNode:addChild(grassCover, 1)
	VisibleRect:relativePosition(grassCover, processBg, LAYOUT_CENTER)
	
	local collectTextSprite =  createSpriteWithFrameName(RES("npc_collect_text.png"))
	VisibleRect:relativePosition(collectTextSprite,self.rootNode,LAYOUT_CENTER,ccp(0,-170))
	self.rootNode:addChild(collectTextSprite)
	self.processText = createLabelWithStringFontSizeColorAndDimension("","Arial",15*viewScale,FCOLOR("ColorWhite1"))	
	VisibleRect:relativePosition(self.processText,self.rootNode,LAYOUT_CENTER,ccp(0,-150))
	self.rootNode:addChild(self.processText)	
end

function NpcPickView:setNpc(refId, severId)
	local mgr = GameWorld.Instance:getNpcManager()
	local seconds = G_GetCollectSeconds(refId)
	local progressTo = CCProgressFromTo:create(seconds+0.1,0,100)
	self.processBar:runAction(progressTo)

	self:clearScheduler()
	local updateProcess =  function(dt)	
		if(self.curProcess < 100 ) then
			self:setProgress()	
		else
			self:clearScheduler()
			if self.rootNode then
				self.rootNode:setVisible(false)
			end
		end
	end
	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateProcess,0.01, false)	
end

function NpcPickView:clearScheduler()
	if self.schedulerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

function NpcPickView:onEnter()
	self.processBar:setPercentage(0)
	self:setProgress()
end

function NpcPickView:setProgress()
	local percente = math.ceil(self.processBar:getPercentage())
	self.curProcess  = percente	
	self.processText:setString(tostring(percente).."%")	
end


function NpcPickView:__delete()
	self:clearScheduler()
	self.curProcess = 0
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function NpcPickView:create()
	return NpcPickView.New()
end	

function NpcPickView:interuptAnimation()
	self:clearScheduler()
	--[[if(self.curProcess < 100) then
		UIManager.Instance:showSystemTips(Config.Words[10149])
	else
		UIManager.Instance:showSystemTips(Config.Words[10148])
	end	--]]
end

function NpcPickView:getRootNode()
	return self.rootNode
end

--[[function NpcPickView:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function NpcPickView:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then	
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = self.rootNode:boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			self.rootNode:setVisible(false)
			return 0
		end
	else
		self.rootNode:setVisible(false)
		return 0
	end
end--]]