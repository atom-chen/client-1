require("common.baseclass")
require("test.TestData")
require("test.SkillShowTestView")

TestMemAnalyzeMgr = TestMemAnalyzeMgr or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function TestMemAnalyzeMgr:__init()
	self:initTimer()
		
	local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), CCSizeMake(const_visibleSize.width / 2, 40))		
	self.bg:retain()
	
	self.label = createLabelWithStringFontSizeColorAndDimension("Memory", "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorYellow1"))								
	self.bg:addChild(self.label)
	VisibleRect:relativePosition(self.label, self.bg, LAYOUT_CENTER)
	
	local parent =  UIManager.Instance:getDialogRootNode()
	parent:addChild(self.bg, 100000)
	VisibleRect:relativePosition(self.bg, parent, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X)	
end			

function TestMemAnalyzeMgr:__delete()
	if self.testSchId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.testSchId)
		self.testSchId = nil
	end
	self.bg:release()
end	

function TestMemAnalyzeMgr:initTimer()
	local onTimeout = function()
		local str = "CCObject Count="..self:getCCObjectCount()
		self.label:setString(str)
		VisibleRect:relativePosition(self.label, self.bg, LAYOUT_CENTER)
	end
	self.testSchId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)	
end

function TestMemAnalyzeMgr:getCCObjectCount()
	return 0
end
