require ("ui.utils.BaseActivityNode")

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(245, 192)

UnionInstanceQuestView = UnionInstanceQuestView or BaseClass(BaseActivityNode)

function UnionInstanceQuestView:__init()
	self.unionMgr = GameWorld.Instance:getUnionInstanceMgr()
	local title = createSpriteWithFrameName(RES("main_activityUnion_word.png"))
	self:setTitle(title)	
	self:setContent()
	self:setTouchHandler()
end	

function UnionInstanceQuestView:setContent()
	local isFinish = self.unionMgr:getIsFinish()
	local name = self.unionMgr:getMonsterName()
	if self.nameLabel then
		self.nameLabel:removeFromParentAndCleanup(true)
		self.nameLabel = nil
	end	
	
	if self.textLabel then
		self.textLabel:removeFromParentAndCleanup(true)
		self.textLabel = nil
	end		
	
	if not name then
		return
	else
		self.nameLabel = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorBlue1"))
	end
		
	if isFinish then
		self.textLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25408], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	else
		self.textLabel = createLabelWithStringFontSizeColorAndDimension(Config.Words[25409], "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))
	end
	self:addChild(self.textLabel)
	self:addChild(self.nameLabel)
	VisibleRect:relativePosition(self.textLabel, self:getContentNode(), LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(10, -10))
	VisibleRect:relativePosition(self.nameLabel, self.textLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)
end	

function UnionInstanceQuestView:updateView()
	local isFinish = self.unionMgr:getIsFinish()
	local text = nil
	if isFinish then
		text = Config.Words[25408]	
		self:createAnimate()	
	else
		text = Config.Words[25409]
	end
	self.textLabel:setString(text)
	VisibleRect:relativePosition(self.nameLabel, self.textLabel, LAYOUT_RIGHT_OUTSIDE+LAYOUT_CENTER_Y)
end	

function UnionInstanceQuestView:createAnimate()
	--Ö¡¶¯»­
	if self.framesprite then
		self.framesprite:removeFromParentAndCleanup(true)
		self.framesprite = nil
	end			
	local animate = createAnimate("questframe",6,0.175)
	self.framesprite = CCSprite:create()
	local forever = CCRepeatForever:create(animate)
	self.framesprite:runAction(forever)
	self.framesprite:setScaleX(1.1)
	self.framesprite:setScaleY(0.75)
	self:addChild(self.framesprite)
	VisibleRect:relativePosition(self.framesprite, self:getContentNode(), LAYOUT_CENTER, ccp(-10,50))						
end

function UnionInstanceQuestView:setTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		if eventType == "began" then
			return self:handleTouch(eventType, x, y, self.rootNode)
		end			
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false,UIPriority.View, true)
end

function UnionInstanceQuestView:handleTouch(eventType, x, y, node)
	if node:isVisible() and node:getParent() then	
		local parent = node:getParent()
		local point = parent:convertToNodeSpace(ccp(x,y))
		local rect = node:boundingBox()
		if rect:containsPoint(point) then	
			local isFinish = self.unionMgr:getIsFinish()
			if not isFinish then
				--[[local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
				local mapMgr = GameWorld.Instance:getMapManager()
				local sceneId = mapMgr:getCurrentMapRefId()
				local refId = self.unionMgr:getMonsterRefId()
				G_getQuestLogicMgr():AutoPathFindMonster(refId, sceneId)--]]
				G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
			else
				G_getHandupMgr():stop()
			end					
			return 1
		else
			return 0
		end
	else
		return 0
	end
end