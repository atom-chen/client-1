require("common.baseclass")
ShowSelectRole = ShowSelectRole or BaseClass()
local LEFTDIR = 1
local RIGHTDIR = 2
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local viewSize = CCSizeMake(visibleSize.width,500)
local G_setScale = 0.8
local G_RoleOffsetX = 330
local G_RoleMoveY = 100
function ShowSelectRole:__init(parent)
	self.selectRoleView = parent
	
	self.rootNode = CCLayer:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(viewSize)
	self.scale = VisibleRect:SFGetScale()
	self.point =  ccp(0,0)
	self.dir = nil
	self.Click = nil --1为显示在中间，2为显示在左边，3为显示在右边
	self.isPlayAction = false
	self.heroModelList = {}
	self.heroPosX = {}
	self.heroPosY = {}	
	
	self:initData()
	--self:initBackGround()
	self:initScrollView()
end

function ShowSelectRole:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end
end

function ShowSelectRole:selectRole()
	self:changeBtnState()
end

function ShowSelectRole:getRootNode()
	return self.rootNode
end

function ShowSelectRole:getClickHeroIndex()
	if self.Click then
		return self.Click
	end
end

function ShowSelectRole:initData()
	local offset = 0
	self.HeroOffsetPos_Table =
	{	
	[1] ={tOffset = ccp(0+offset,0-30)},
	[2] ={tOffset = ccp(-G_RoleOffsetX+offset,-G_RoleMoveY)},
	[3] ={tOffset = ccp(G_RoleOffsetX+offset,-G_RoleMoveY)}
	}
	
	self.ProfessionGender_Table =
	{
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale , tImage = "role_modelManWarior.png",tProfessionImg = "role_fontWarior.png"},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanWarior.png",tProfessionImg = "role_fontWarior.png"},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale , tImage = "role_modelManMagic.png",tProfessionImg = "role_fontMagic.png"},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanMagic.png",tProfessionImg = "role_fontMagic.png"},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale , tImage = "role_modelManDaoshi.png",tProfessionImg = "role_fontDaoshi.png"},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale , tImage = "role_modelFemanDaoshi.png",tProfessionImg = "role_fontDaoshi.png"}
	}
end

function ShowSelectRole:initBackGround()
	--背景图
	local bg = createScale9SpriteWithFrameNameAndSize(RES("login_squares_formBg2.png"),self.rootNode:getContentSize())
	self.rootNode:addChild(bg)
	VisibleRect:relativePosition(bg,self.rootNode,LAYOUT_CENTER,ccp(0,0))	
end

function ShowSelectRole:initScrollView()
	self.scrollNode = CCLayer:create()
	self.scrollNode:setContentSize(viewSize)
	self.rootNode:addChild(self.scrollNode)
	VisibleRect:relativePosition(self.scrollNode,self.rootNode, LAYOUT_CENTER,ccp(0,0))	
	
	self:showScrollView()
	self:ScriptTouchHandler(self.scrollNode)
	self.scrollNode:setTouchEnabled(true)
end


function ShowSelectRole:ScriptTouchHandler(node)
	local function ccTouchHandler(eventType, x,y)
		local responseOffsetX = G_RoleOffsetX*0.6
		local clickOffsetX = 10
		if eventType == "began" then
			if self.point.x ~= 0 and self.point.y ~= 0 then
				local fdfd = 0
			end
			self.point.x = x
			self.point.y = y
		elseif eventType == "moved" then
			if  self.point.x~=0 and self.point.y ~= 0 then
				if x < self.point.x-responseOffsetX then
					self.dir = LEFTDIR
					elseif	x > self.point.x+responseOffsetX then
					self.dir = RIGHTDIR
				else
					self.dir = nil
				end
				if not self.isPlayAction then
				self:runMove(x,y)
				end
			end
		elseif eventType == "ended" then
			if self.dir ~= nil then
				self:runAsCicle(self.dir)
				self.dir = nil
			else
				if x<=self.point.x+clickOffsetX and x>=self.point.x-clickOffsetX and  y<=self.point.y+clickOffsetX and y>=self.point.y-clickOffsetX then
					self:ClickDown(x,y)
				else
					self:runBack()
				end
			end
		else
			self:runBack()
		end
		return self:touchHander(node, eventType, x, y)
	end
	node:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.Control, true)
end

function ShowSelectRole:touchHander(node, eventType, x, y)
	if node:isVisible() and node:getParent() then
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

function ShowSelectRole:runMove(x,y)
	if self.point.x then
		local moveWidth = 300 --移动宽度
		local offsetX = x - self.point.x
		local offsetY =(offsetX /4)
		if offsetX < (moveWidth) and offsetX > (-moveWidth) then
			for i,v in pairs(self.heroModelList) do
				local PosX = self.HeroOffsetPos_Table[i].tOffset.x
				local PosY = self.HeroOffsetPos_Table[i].tOffset.y
				local posoffsetY = math.abs(offsetY)
				if i==1 then
					posoffsetY = -math.abs(offsetY)
				end
				if offsetX<0 then--往左移动
					if i==2 then
						posoffsetY = 0
					end
				elseif offsetX>0 then
					if i==3 then
						posoffsetY = 0
					end
				end
				VisibleRect:relativePosition(self.heroModelList[i],self.scrollNode, LAYOUT_CENTER,ccp(PosX+offsetX,PosY+posoffsetY))
			end
			
			
			local scaleBySmall = 1.0 - math.abs((offsetX/1500)) --变小
			local scaleByBig = G_setScale + math.abs((offsetX/1500))--变大
			if offsetX>0 then--往右移动
				self.heroModelList[1]:setScale(scaleBySmall)
				self.heroModelList[2]:setScale(scaleByBig)
			else--往左移动
				self.heroModelList[1]:setScale(scaleBySmall)
				self.heroModelList[3]:setScale(scaleByBig)
			end
			
		end
	end
end

function ShowSelectRole:runBack()
	local actionTime = 0.2
	local moveTo1 = CCMoveTo:create(actionTime,ccp(self.heroPosX[1],self.heroPosY[1]))--中间位置
	local moveTo2 =	CCMoveTo:create(actionTime,ccp(self.heroPosX[2],self.heroPosY[2]))--左边位置
	local moveTo3 = CCMoveTo:create(actionTime,ccp(self.heroPosX[3],self.heroPosY[3]))--右边位置
	
	self.heroModelList[1]:runAction(moveTo1)
	self.heroModelList[2]:runAction(moveTo2)
	self.heroModelList[3]:runAction(moveTo3)
	
	local scaleTo1 = CCScaleTo:create(0.1,1,1)--变大
	local scaleTo2 = CCScaleTo:create(actionTime,G_setScale,G_setScale)--变小
	local scaleTo3 = CCScaleTo:create(actionTime,G_setScale,G_setScale)--变小
	
	self.heroModelList[1]:runAction(scaleTo1)
	self.heroModelList[2]:runAction(scaleTo2)
	self.heroModelList[3]:runAction(scaleTo3)
end

function ShowSelectRole:runAsCicle(dir)
	if dir == LEFTDIR then
		self:runLeft()
	elseif dir == RIGHTDIR then
		self:runRight()
	end
	self:changeBtnState()
end

function ShowSelectRole:changeBtnState()
	local LoginManager = LoginWorld.Instance:getLoginManager()
	local heroObj = LoginManager:getLoginHeroObj(self.Click)
			
	if heroObj then
		self.selectRoleView:EventVisiableBtnfunc(true)		
	else
		self.selectRoleView:EventVisiableBtnfunc(false)	
	end
	
end		

function ShowSelectRole:runLeft()
	if not self.isPlayAction then
		self.isPlayAction = true
		local actionTime = 0.2
		VisibleRect:relativePosition(self.heroModelList[2],self.scrollNode, LAYOUT_RIGHT_OUTSIDE,ccp(0,-G_RoleMoveY))
		
		--移动
		local moveByLeft = CCMoveBy:create(actionTime,ccp(-G_RoleOffsetX,0))--往左移动
		
		local moveTo1 = CCMoveTo:create(actionTime,ccp(self.heroPosX[1],self.heroPosY[1]))--中间位置
		local moveTo2 =	CCMoveTo:create(actionTime,ccp(self.heroPosX[2],self.heroPosY[2]))--左边位置
		local moveTo3 = CCMoveTo:create(actionTime,ccp(self.heroPosX[3],self.heroPosY[3]))--右边位置
		
		self.heroModelList[1]:runAction(moveTo2)
		self.heroModelList[2]:runAction(moveTo3)
		self.heroModelList[3]:runAction(moveTo1)
		
		--缩放
		local scaleBySmall = CCScaleTo:create(actionTime,G_setScale,G_setScale)--变小
		local scaleByBig = CCScaleTo:create(actionTime,1,1)--变大
		self.heroModelList[1]:runAction(scaleBySmall)
		self.heroModelList[3]:runAction(scaleByBig)
		self.heroModelList[2]:setScale(G_setScale)
		
		--渐变
		local fadeIn = CCFadeIn:create(0.3)
		--self.heroModelList[2]:runAction(fadeIn)
		
		local function finishRunLeftCallback()
			self.isPlayAction = false
		end
		local callbackAction = CCCallFunc:create(finishRunLeftCallback)
		local actionArray = CCArray:create()
		actionArray:addObject(fadeIn)
		actionArray:addObject(callbackAction)
		self.heroModelList[2]:runAction(CCSequence:create(actionArray))
		
		
		self.temtable = {}
		self.temtable[2] = self.heroModelList[1]
		self.temtable[3] = self.heroModelList[2]
		self.temtable[1] = self.heroModelList[3]
		for i,v in pairs(self.temtable) do
			self.heroModelList[i] = v
		end
		self.Click = self.Click-1
		if self.Click<1 then
			self.Click = 3
		elseif self.Click>3 then
			self.Click = 1
		end
	end
end

function ShowSelectRole:runRight()
	if not self.isPlayAction then
		self.isPlayAction = true
		local actionTime = 0.2
		VisibleRect:relativePosition(self.heroModelList[3],self.scrollNode, LAYOUT_LEFT_OUTSIDE,ccp(0,-G_RoleMoveY))
		--移动
		local moveByRight = CCMoveBy:create(actionTime,ccp(G_RoleOffsetX,0))--往右移动
		
		local moveTo1 = CCMoveTo:create(actionTime,ccp(self.heroPosX[1],self.heroPosY[1]))--中间位置
		local moveTo2 =	CCMoveTo:create(actionTime,ccp(self.heroPosX[2],self.heroPosY[2]))--左边位置
		local moveTo3 = CCMoveTo:create(actionTime,ccp(self.heroPosX[3],self.heroPosY[3]))--右边位置
		
		self.heroModelList[1]:runAction(moveTo3)
		self.heroModelList[2]:runAction(moveTo1)
		self.heroModelList[3]:runAction(moveTo2)
		
		--缩放
		local scaleByBig = CCScaleTo:create(actionTime,1,1)--变大
		local scaleBySmall = CCScaleTo:create(actionTime,G_setScale,G_setScale)--变小
		self.heroModelList[1]:runAction(scaleBySmall)
		self.heroModelList[2]:runAction(scaleByBig)
		self.heroModelList[3]:setScale(G_setScale)
		
		--渐变
		local fadeIn = CCFadeIn:create(0.3)
		--self.heroModelList[3]:runAction(fadeIn)
		
		local function finishRunRightCallback()
			self.isPlayAction = false
		end
		local callbackAction = CCCallFunc:create(finishRunRightCallback)
		local actionArray = CCArray:create()
		actionArray:addObject(fadeIn)
		actionArray:addObject(callbackAction)
		self.heroModelList[3]:runAction(CCSequence:create(actionArray))
		
		
		self.temtable = {}
		self.temtable[3] = self.heroModelList[1]
		self.temtable[1] = self.heroModelList[2]
		self.temtable[2] = self.heroModelList[3]
		for i,v in pairs(self.temtable) do
			self.heroModelList[i] = v
		end
		self.Click = self.Click+1
		if self.Click<1 then
			self.Click = 3
		elseif self.Click>3 then
			self.Click = 1
		end
	end
end

function ShowSelectRole:ClickDown(x,y)
	local clickIndex = 0
	for i,v in pairs(self.heroModelList) do
		local PosX,PosY = self.heroModelList[i]:getPosition()
		local modelSize = self.heroModelList[i]:getContentSize()
		local modelWidth = modelSize.width/3
		if x<(PosX+modelWidth/2) and x>(PosX-modelWidth/2) then
			clickIndex = i
		end
	end
	
	if clickIndex~=0 then
		if clickIndex==1 then
			local LoginManager = LoginWorld.Instance:getLoginManager()
			local herotag = self.heroModelList[clickIndex]:getTag()	
			local heroObj = LoginManager:getLoginHeroObj(herotag)
			if heroObj then						
				self.selectRoleView:EventEnterGame()
			else				
				GlobalEventSystem:Fire(GameEvent.EventCreateRole)
			end
			
		elseif clickIndex==2 then
			self:runRight()
		elseif clickIndex==3 then
			self:runLeft()
		end
		self:changeBtnState()
	end
end

--mark
function ShowSelectRole:showScrollView()
	local LoginManager = LoginWorld.Instance:getLoginManager()
	
	for i=1,3 do
		--人物
		local heroObj = LoginManager:getLoginHeroObj(i)		
		local nameImage,professionImage = self:getModelSpriteName(heroObj)		
		local mode = self.heroModelList[i]
		if type(self.heroModelList) ~= "table" then
			self.heroModelList = {}
		end
		if mode~=nil then
			self.heroModelList[i]:removeFromParentAndCleanup(true)
		end
		self.heroModelList[i] = createSpriteWithFrameName(RES(nameImage))
		self.heroModelList[i]:setTag(i)	
				
		if i==1 then
			self.heroModelList[i]:setScale(self.scale)
			--self.heroModelList[i]:setOpacity(255)
			self.Click = i			
		else
			self.heroModelList[i]:setScale(self.scale*G_setScale)
			--self.heroModelList[i]:setOpacity(150)
		end
		
		self.scrollNode:addChild(self.heroModelList[i])
		VisibleRect:relativePosition(self.heroModelList[i],self.scrollNode, LAYOUT_CENTER,self.HeroOffsetPos_Table[i].tOffset)
		
		self.heroPosX[i],self.heroPosY[i] = self.heroModelList[i]:getPosition()
		
		
		if heroObj then
			--职业
			local professionBg = createSpriteWithFrameName(RES("role_fontBg.png"))
			self.heroModelList[i]:addChild(professionBg)
			VisibleRect:relativePosition(professionBg,self.heroModelList[i],LAYOUT_TOP_INSIDE + LAYOUT_CENTER,ccp(-120,10))
			
			local professionFront = createSpriteWithFrameName(RES(professionImage))
			professionBg:addChild(professionFront)
			VisibleRect:relativePosition(professionFront,professionBg,LAYOUT_CENTER,ccp(0,0))			
			
			--等级
			local levelValue = tostring(heroObj:getLevel())
			local heroLevel = createLabelWithStringFontSizeColorAndDimension(levelValue..Config.LoginWords[328],"Arial",FSIZE("Size5"),FCOLOR("ColorRed1"),CCSizeMake(80*self.scale,0))
			self.heroModelList[i]:addChild(heroLevel)
			VisibleRect:relativePosition(heroLevel,professionBg,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_OUTSIDE,ccp(20,0))
			
			--名称
			local nameValue = heroObj:getName()
			local heroName = createLabelWithStringFontSizeColorAndDimension(nameValue,"Arial",FSIZE("Size5"),FCOLOR("ColorGreen1"))
			self.heroModelList[i]:addChild(heroName)
			VisibleRect:relativePosition(heroName,heroLevel,LAYOUT_CENTER + LAYOUT_RIGHT_OUTSIDE,ccp(0,0))
		end
	end
end

function ShowSelectRole:RemoveRole()
	self.heroModelList[1]:removeAllChildrenWithCleanup(true)	
	local tempModel = createSpriteWithFrameName(RES("role_modelCreateRole.png"))
	local frame = tempModel:displayFrame()
	self.heroModelList[1]:setDisplayFrame(frame)	
	self:changeBtnState()		
end

function ShowSelectRole:getModelSpriteName(obj)
	local nameImage = "role_modelCreateRole.png"
	local professionImage = nil
	if obj then
		local profession = obj:getProfession()
		local gender = obj:getGender()
		for i,v in pairs(self.ProfessionGender_Table) do
			if v.tProfession == profession and v.tGender == gender  then
				nameImage = v.tImage
				professionImage = v.tProfessionImg
				return nameImage,professionImage
			end
		end
	end
	return nameImage, nil
end

function ShowSelectRole:getClickHeroId()
	if self.Click then
		local LoginManager = LoginWorld.Instance:getLoginManager()
		local heroObj = LoginManager:getLoginHeroObj(self.Click)
		if heroObj then
			return heroObj:getCharacterId()
		end
	end
end