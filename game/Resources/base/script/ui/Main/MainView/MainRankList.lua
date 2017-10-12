require("ui.UIManager")
require("common.BaseUI")

MainRankList = MainRankList or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

function MainRankList:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)	
	self.scale = VisibleRect:SFGetScale()
		
	self:showView()
end

function MainRankList:__delete()

end

function MainRankList:getRootNode()
	return self.rootNode
end

function MainRankList:showView()		
	self.rankListBtn = createButtonWithFramename(RES("main_questcontraction.png"),RES("main_questcontraction.png"))	
	self.rankListBtn:setScale(self.scale)	
	self.rootNode:addChild(self.rankListBtn)
	VisibleRect:relativePosition(self.rankListBtn,self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE, CCPointMake(-30, -60))

	local Btn_instancefunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventOpenRankListView,1) 
	end
	self.rankListBtn:addTargetWithActionForControlEvents(Btn_instancefunc,CCControlEventTouchDown)
end		