require("common.baseclass")

PopupMenu= PopupMenu or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

local def_gaps = 25
local def_fontSize = 20
--[[local def_item = {
{lable, id, callback, arg, disable}
}--]]
local heightPerItem = 30

function PopupMenu:__init ()
	self.rootNode = CCLayer:create()
	self.rootNode:setTouchEnabled(true)
	self.items = {}
	self.line = {}
	self:registerScriptTouchHandler()
end

function PopupMenu:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function PopupMenu:touchHandler(eventType, x, y)
	if self.rootNode:isVisible() and self.rootNode:getParent() then	
		local parent = self.rootNode:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))			
		
		local rect = self.rootNode:boundingBox()		
		if rect:containsPoint(point) then
			for i=table.size(self.items), 1, -1 do 
				if self.line[i-1] then 
					local posY = self.line[i-1]:getPositionY()
					point = self.rootNode:convertToNodeSpace(ccp(x,y))						
					if point.y <= posY then 					
						if self.items[i].disable==nil or self.items[i].disable==false then 
							self.items[i].callback(self.items[i].arg)
						end
						break
					end						
				end
				if i==1 then 				
					if self.items[i].disable==nil or self.items[i].disable==false then 
						self.items[i].callback(self.items[i].arg)
					end
				end
			end				
			self:removePopupMenu()
			return 1
		else
			self:removePopupMenu()
			return 0
		end
	else
		return 0
	end
end

function PopupMenu:initWithSize(size)
	self.rootNode:setContentSize(size)
	self.rootNode:retain()
	self.bg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_bg1.png"), size)
	self.rootNode:addChild(self.bg)
	VisibleRect:relativePosition(self.bg, self.rootNode, LAYOUT_CENTER)
end

function PopupMenu:__delete()
	self:removePopupMenu()
	self.rootNode:release()
end

function PopupMenu:removePopupMenu()
	self.rootNode:removeFromParentAndCleanup(true)
end

function PopupMenu:setItems(items)
	self.items = items
	self.label = {}
	for i,v in pairs(items) do	
		if v.disable == false or v.disable == nil then
			self.label[i] = createLabelWithStringFontSizeColorAndDimension(v.lable, "Arial", FSIZE("Size4"), FCOLOR("ColorOrange1"))			
		else
			self.label[i] = createLabelWithStringFontSizeColorAndDimension(v.lable, "Arial", FSIZE("Size4"), FCOLOR("ColorGray3"))		
		end			
		self.rootNode:addChild(self.label[i])
		if i==1 then 
			VisibleRect:relativePosition(self.label[i], self.bg, LAYOUT_CENTER_X+LAYOUT_TOP_INSIDE, ccp(0, -18))
		else
			VisibleRect:relativePosition(self.label[i], self.label[i-1], LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, -def_gaps))
		end
		--Ïß
		if i ~= table.size(self.items) then
			self.line[i] = createSpriteWithFrameName(RES("login_left_line.png"))
			self.rootNode:addChild(self.line[i])
			VisibleRect:relativePosition(self.line[i], self.label[i], LAYOUT_BOTTOM_OUTSIDE+LAYOUT_CENTER_X, ccp(-5, -def_gaps/2))			
		end			
	end		
end

function PopupMenu:create()
	return PopupBox.New()
end

function PopupMenu:getRootNode()
	return self.rootNode
end	

