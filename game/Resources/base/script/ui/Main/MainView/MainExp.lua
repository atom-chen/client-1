require "data.character.characterLevelData"

MainExp = MainExp or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function MainExp:__init()
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)
	self.scale = VisibleRect:SFGetScale()
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	
	self.barLen = {}
	self.expcut = {}
	
	self:showView()
end

function MainExp:__delete()

end
	
function MainExp:getRootNode()
	return self.rootNode
end

function MainExp:showView()
	--经验背景
	local dfkdo = visibleSize.width
	local expVisibleSize = VisibleRect:getScaleSize(visibleSize)
	local dfksddo = expVisibleSize.width
	local exprect = CCRectMake(85,8,40,8)
	local expbackground = createScale9SpriteWithFrameName(RES("main_expFrame.png"),exprect)
	expbackground:setContentSize(CCSizeMake(dfkdo*self.scale,26))
	G_setScale(expbackground)
	self.rootNode:addChild(expbackground,20)
	VisibleRect:relativePosition(expbackground,self.rootNode,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE,ccp(0,-3))
	
	
	--经验槽
	self.ExpBarLen = (visibleSize.width - 112)/self.scale
	self.ExpbarDown = createScale9SpriteWithFrameNameAndSize(RES("main_expbarDown.png"),CCSizeMake(self.ExpBarLen,18))
	G_setScale(self.ExpbarDown)
	self.rootNode:addChild(self.ExpbarDown)
	VisibleRect:relativePosition(self.ExpbarDown ,expbackground,LAYOUT_CENTER,ccp(0,0))
	
	--经验
	self:UpdateExp()
	
	
	
	--经验icon
--[[	local expicon = createSpriteWithFrameName(RES("main_exp.png"))
	G_setScale(expicon)
	self.rootNode:addChild(expicon)
	VisibleRect:relativePosition(expicon,self.ExpbarDown,LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER,ccp(-5,0))--]]
end

--更新数据
function MainExp:Update(pt)
	self:UpdateExp(pt)
end

--更新经验
function MainExp:UpdateExp(pt)
	--经验
	local Experience = PropertyDictionary:get_exp(self.hero:getPT())
	--最大经验
	local MaxExperience = G_getMaxExp(self.hero:getPT())
	
	
	local function getDate()
		if pt then
			if pt.exp then
				Experience = pt.exp
			end
			if pt.maxExp then
				MaxExperience = pt.maxExp
			end
		end
	end
	
	local function checkData()
		if Experience==nil or Experience<0 then
			Experience = 1
		end
		if MaxExperience==nil or MaxExperience<1 then
			MaxExperience = 1
		end
	end
	
	local function show()
		local ExpLen = Experience * self.ExpBarLen /MaxExperience
		local expSize = CCSizeMake(ExpLen*self.scale,14)
		if self.exp==nil then
			self.exp = createScale9SpriteWithFrameName(RES("main_expbarUp.png"))
			self.saveExpSpriteSize = self.exp:getContentSize()
			self.exp:setContentSize(expSize)
			G_setScale(self.exp)
			self.rootNode:addChild(self.exp)
			VisibleRect:relativePosition(self.exp ,self.ExpbarDown,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(0,0))
			--经验分割线
			local ExpcutLen = 70
			for i=1, 9 do
				self.barLen[i] = i*(self.ExpBarLen/10)
				self.expcut[i] = createSpriteWithFrameName(RES("mian_expcut.png"))
				G_setScale(self.expcut[i])
				self.rootNode:addChild(self.expcut[i])
				VisibleRect:relativePosition(self.expcut[i],self.ExpbarDown,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(self.barLen[i],0))
			end
		else
			if pt.exp then
				G_setScale(self.exp)
				self.exp:setContentSize(expSize)				
				
				VisibleRect:relativePosition(self.exp ,self.ExpbarDown,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(0,0))
				for i=1,9 do
					VisibleRect:relativePosition(self.expcut[i],self.ExpbarDown,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(self.barLen[i],0))
				end					
			end				
		end	
				
		local expSpriteWidth = self.saveExpSpriteSize.width
		if ExpLen<expSpriteWidth then
			if ExpLen~=0 then
				local scale = ExpLen/expSpriteWidth
				self.exp:setScaleX(scale)
				self.exp:setVisible(true)
				VisibleRect:relativePosition(self.exp ,self.ExpbarDown,LAYOUT_LEFT_INSIDE + LAYOUT_CENTER,ccp(0,0))
			else
				self.exp:setVisible(false)
			end
		else
			self.exp:setVisible(true)
		end		
	end
	
	getDate()
	checkData()
	show()
end