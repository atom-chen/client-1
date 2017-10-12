MainChatBtn = MainChatBtn or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local scale = VisibleRect:SFGetScale()

local ICON_NORMAL = 1
local ICON_MESSAGE = 2

function MainChatBtn:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)		
	self:show()	
end

function MainChatBtn:__delete()

end

function MainChatBtn:show()
	self.Btn_char = createButtonWithFramename(RES("main_char.png"))	
	self.Btn_char:setScale(scale)		
	self.rootNode:addChild(self.Btn_char)
	VisibleRect:relativePosition(self.Btn_char, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER, CCPointMake(-220, 20))
	local Btn_charfunc = function ()
		self:replaceIcon(ICON_NORMAL)
		GlobalEventSystem:Fire(GameEvent.EventOpenChatView)
	end
	self.Btn_char:addTargetWithActionForControlEvents(Btn_charfunc,CCControlEventTouchDown)
end



function MainChatBtn:getRootNode()
	return self.rootNode
end	

function MainChatBtn:replaceIcon(id)
	if id == ICON_NORMAL then
		if self.iconMsg ~= nil then
		self.iconMsg:removeFromParentAndCleanup(true)
		self.iconMsg = nil
		end
	else 
		if self.iconMsg ~= nil then
		self.iconMsg:removeFromParentAndCleanup(true)
		self.iconMsg = nil
		end
		self.iconMsg = createSpriteWithFrameName(RES("main_char2.png"))
		self.Btn_char:addChild(self.iconMsg)
		VisibleRect:relativePosition(self.iconMsg, self.Btn_char, LAYOUT_CENTER)
	end
end

function MainChatBtn:MoveChatBtn(bshowMenu)
	if bshowMenu==true then
		VisibleRect:relativePosition(self.Btn_char, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_LEFT_INSIDE, CCPointMake(20, 20))				
	else
		VisibleRect:relativePosition(self.Btn_char, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER, CCPointMake(-220, 20))		
	end
end