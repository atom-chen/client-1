SkillUtils  = SkillUtils or BaseClass()

function SkillUtils:__init()
	SkillUtils.Instance = self
end

function SkillUtils:getSkillSoltPos(index)
	if self.SoltPos == nil then 	
		local radium = 220
		local perDeg = math.deg(math.asin(40/radium))
		local totalDegree =  perDeg *2 *4
		local spaceDegree  = (90-totalDegree)/3	
		local offsetY = math.sin(math.rad(perDeg))*radium
		local offsetX = math.sin(math.rad(perDeg))*radium
		self.SoltPos = {
		[1] = ccp(-math.cos(math.rad(perDeg))*radium+offsetX, math.sin(math.rad(perDeg))*radium-offsetY),
		[2] = ccp(-math.cos(math.rad(perDeg*3+spaceDegree))*radium+offsetX, math.sin(math.rad(perDeg*3+spaceDegree))*radium-offsetY),
		[3] = ccp(-math.cos(math.rad(perDeg*5+spaceDegree*2))*radium+offsetX, math.sin(math.rad(perDeg*5+spaceDegree*2))*radium-offsetY),
		[4] = ccp(-math.sin(math.rad(perDeg))*radium+offsetX, radium-offsetY),	
		}		
	end		
	local tmp = ccp(self.SoltPos[index].x, self.SoltPos[index].y)
	return tmp
end

function SkillUtils:createArrowNode(parent, page, bigSize, posNode)
	local gray = createSpriteWithFrameName(RES("skill_arrow_red.png"))
	local red = createSpriteWithFrameName(RES("skill_arrow_red.png"))
	parent:addChild(gray)
	parent:addChild(red)
	if page == 1 then 
		gray:setFlipY(true)	
		gray:setRotation(80)	
		UIControl:SpriteSetGray(gray)
		--red:setRotation(5)	
		if bigSize then 
			VisibleRect:relativePosition(red, posNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-105, 20))			
			VisibleRect:relativePosition(gray, posNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-15, 110))
		else
			VisibleRect:relativePosition(red, parent, LAYOUT_CENTER, ccp(-16, -59))			
			VisibleRect:relativePosition(gray, parent, LAYOUT_CENTER, ccp(58, 25))		
		end
	else
		red:setFlipY(true)	
		red:setRotation(80)	
		UIControl:SpriteSetGray(gray)
		--gray:setRotation(5)		
		if bigSize then 
			VisibleRect:relativePosition(red, posNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-15, 110))			
			VisibleRect:relativePosition(gray, posNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-105, 20))			
		else
			VisibleRect:relativePosition(gray, parent, LAYOUT_CENTER, ccp(-16, -59))			
			VisibleRect:relativePosition(red, parent, LAYOUT_CENTER, ccp(58, 25))
		end			
	end		
end

 
