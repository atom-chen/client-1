require("ui.utils.RelativeNode")
ActivityIcon = ActivityIcon or BaseClass(RelativeNode)


local const_scale = VisibleRect:SFGetScale()
local const_iconZ = 10
local const_effectZ = 8
local const_wordZ = 15
local const_textZ = 20


function ActivityIcon:__init()
	local function scriptHandler(eventType)  
		if self.rootNode then
			if eventType == "enter" then
				self:doShowEffect(self.effectFlag)
			elseif eventType == "exit" then
				self:doShowEffect(false)
			end
		end
    end  
  
    self.rootNode:registerScriptHandler(scriptHandler)
end		

function ActivityIcon:__delete()
	if self.forever then
		self.forever:release()
		self.forever = nil
	end
end	

--[[
--time: 倒计时发生变化
--active: 激活状态发生变化
--running: 是否处于活动时间状态发生变化
--]]
function ActivityIcon:setData(activityObj)
	local oldRefId 
	if self.data then
		oldRefId = self.data:getRefId()
	end
			
	self.data = activityObj
	local newRefId = self.data:getRefId()
	
	if newRefId ~= oldRefId then
		self:updateIcon(activityObj)
	end
	self:showEffect(self.data:isActivated())
	self:setText(" ", nil)
end	

function ActivityIcon:updateIcon(activityObj)
	if self.icon then
		self:removeChild(self.icon)
		self.icon = nil
	end
	if self.word then
		self:removeChild(self.word)
		self.word = nil
	end
	local icon = PropertyDictionary:get_iconId(activityObj:getData().property)	
	if not icon then
		return
	end
	local word = icon.."_word.png"
	if string.find(word,"teamBoss") then
		word = "teamBoss_word.png"
	end
	icon = icon..".png"	
	
	self.icon = createSpriteWithFrameName(RES(icon))
	self:addChild(self.icon, const_iconZ, LAYOUT_CENTER)	
	
	self.word = createSpriteWithFrameName(RES(word))	
	self:addChild(self.word, const_iconZ, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 0))	
end

function ActivityIcon:getData()
	return self.data
end		

function ActivityIcon:showEffect(bShow)
	self.effectFlag = bShow
	self:doShowEffect(bShow)
end

function ActivityIcon:doShowEffect(bShow)
	if (not self.framesprite) and bShow then
		self.framesprite = CCSprite:create()	
		self.framesprite:retain()			
		self:addChild(self.framesprite, const_effectZ, LAYOUT_CENTER, ccp(-5, 5))		
		local animate = createAnimate("activity", 6, 0.175)		
		self.forever = CCRepeatForever:create(animate)	
		self.forever:retain()
	end	
		
	if self.framesprite then	
		self.framesprite:setVisible(bShow)
		self.framesprite:stopAllActions()
		if bShow then
			self.framesprite:runAction(self.forever)
		else
			self.framesprite:stopAllActions()
		end
	VisibleRect:relativePosition(self.framesprite, self.rootNode, LAYOUT_CENTER, ccp(-5, 5))	
	end			
end				

function ActivityIcon:setWordLayout(layout, offset)
	if self.word then
		if self.word:getParent() then
			self.word:retain()
			self.word:removeFromParentAndCleanup(true)
			self:addChild(self.word, const_wordZ, layout, offset)
			self.word:release()
		else
			self:addChild(self.word, const_wordZ, layout, offset)
		end			
	end
end

function ActivityIcon:setTextLayout(layout, offset)
	if self.textLabel then
		if self.textLabel:getParent() then
			self.textLabel:retain()
			self.textLabel:removeFromParentAndCleanup(true)
			self:addChild(self.textLabel, const_textZ, layout, offset)
			self.textLabel:release()
		else
			self:addChild(self.textLabel, const_textZ, layout, offset)
		end			
	end
end

function ActivityIcon:setText(text, color)
	if not self.textLabel then	
		self.textLabel = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size2"), FCOLOR("ColorBrown2"))			
		self:addChild(self.textLabel, const_textZ, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE, ccp(0, 5))					
	end		
	if color and color ~= self.textColor then
		self.textLabel:setColor(FCOLOR(color))	
		self.textColor = color
	end
	if text and (text ~= self.textLabel:getString()) then
		if self.textLabel and self.textLabel.setString then
			self.textLabel:setString(text)	
		end
	end
end		