require("ui.utils.NavigationMapView")
MainMap = MainMap or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local MountBtState = {
MountUp = 1,
MountDown = 2,
MountCD = 3,
}


function MainMap:__init()
	self.rootNode = CCLayer:create()	
	
	self.heroMoveEvent = nil
	self.mountStateEvent = nil
	
	self.scale = VisibleRect:SFGetScale()
	self.hero = GameWorld.Instance:getEntityManager():getHero()	
	self:showView()	
	self:showNavigationMap()
end

function MainMap:__delete()
	
	if self.heroMoveEvent then
		GlobalEventSystem:UnBind(self.heroMoveEvent)
		self.heroMoveEvent = nil
	end
	
	if self.mountStateEvent then
		GlobalEventSystem:UnBind(self.mountStateEvent)
		self.mountStateEvent = nil
	end
	
	if self.navigationMapView then
		self.navigationMapView:DeleteMe()
		self.navigationMapView = nil
	end
end


function MainMap:getRootNode()
	return self.rootNode
end

function MainMap:showView()
	--地图背景 
	self.mapBg = createSpriteWithFrameName(RES("main_mapbg.png"))				
	self.rootNode:addChild(self.mapBg)
	--地图框
	self.BT_MapView = createSpriteWithFrameName(RES("main_mapIcon.png"))
	G_setScale(self.BT_MapView)
	self.rootNode:addChild(self.BT_MapView)
	self.rootNode:setContentSize(self.BT_MapView:getContentSize())	
	
	self.mapTop = createButtonWithFramename(RES("main_mapHightlight.png"))
	self.mapTop:setOpacity(0)
	self.rootNode:addChild(self.mapTop)
	--self.mapTop:setScaleDef(1.1)	
	local BT_Mapfunc = function ()
		GlobalEventSystem:Fire(GameEvent.EventSmallMapOpen)
	end
	self.mapTop:addTargetWithActionForControlEvents(BT_Mapfunc,CCControlEventTouchUpInside)
	
	--地图名称
	local mapMgr =  GameWorld.Instance:getMapManager()
	local currentMapRefId = mapMgr:getCurrentMapRefId()
	local mapNameword = mapMgr:getMapName(currentMapRefId)		

	--人物位置
	local HeroPosX,HeroPosY = self.hero:getCellXY()
	local HeroPosValue = "("..tostring(HeroPosX)..","..tostring(HeroPosY)..")"
	local HeroPosition = "        "..mapNameword.." "..HeroPosValue
	local HeroPos = createLabelWithStringFontSizeColorAndDimension(HeroPosition,"Arial",16,ccc3(255,255,255))	
	self.BT_MapView:addChild(HeroPos)	
	local update_hero_position = function ()
		currentMapRefId = mapMgr:getCurrentMapRefId()
		mapNameword = mapMgr:getMapName(currentMapRefId)
		
		HeroPosX,HeroPosY = self.hero:getCellXY()
		HeroPosValue = "("..tostring(HeroPosX)..","..tostring(HeroPosY)..")"
		HeroPosition = "        "..mapNameword.." "..HeroPosValue
		HeroPos:setString(HeroPosition)	
		VisibleRect:relativePosition(HeroPos,self.BT_MapView,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(40,-11))	
	end
	self.heroMoveEvent = GlobalEventSystem:Bind(GameEvent.EventHeroMovement,update_hero_position)
	
	--上下马控件
	local mountMgr = GameWorld.Instance:getMountManager()
		
	self.mount = createButtonWithFramename(RES("main_mapbtnBg.png"))
	
	local mountText = createSpriteWithFrameName(RES("main_mapRide.png"))
	self.mount:addChild(mountText)
	VisibleRect:relativePosition(mountText, self.mount, LAYOUT_CENTER)
	
	self.effectSprite = createSpriteWithFrameName(RES("mount_tipsEffect.png"))
	self.mount:addChild(self.effectSprite, -2)
	self.effectSprite:setScale(0.9)
	VisibleRect:relativePosition(self.effectSprite, self.mount, LAYOUT_CENTER, ccp(1.5, 0))	
	self:runScaleAction()
	self.effectSprite:setVisible(false)
	--[[local state = mountMgr:getMountState()	
	if state == 0 then
		self.effectSprite:setVisible(false)
	else
		self.effectSprite:setVisible(true)
	end--]]
	
	self.rootNode:addChild(self.mount,1)
						
	--[[self.mountDown = createButtonWithFramename(RES("main_mapbtnBg.png"))
	self.rootNode:addChild(self.mountDown,1)	
	local mountDownHighLight = createSpriteWithFrameName(RES("main_mapSelectHighLight.png"))
	self.mountDown:addChild(mountDownHighLight)
	VisibleRect:relativePosition(mountDownHighLight,self.mountDown,LAYOUT_CENTER)--]]

				
	local onMount = function()	
		local state = mountMgr:getMountState()	
		if state == 1 then
			local state = mountMgr:getMountState()			
			mountMgr:requestMountRide(state)
			--self:setMountCD(5)
		else
			local mountCD = mountMgr:getMountCD()
			if mountCD > 0 then
				local msg = {}
				table.insert(msg,{word = Config.Words[1055], color = Config.FontColor["ColorWhite1"]})
				UIManager.Instance:showSystemTips(msg)			
			else						
				local heroObj = GameWorld.Instance:getEntityManager():getHero()
				if(heroObj:canMountUp()) then				
					mountMgr:requestMountRide(state)						
				else
					--无法改变状态
				end				
			end
		end						
	end
	self.mount:addTargetWithActionForControlEvents(onMount, CCControlEventTouchDown)


	--[[local onMountDown = function()	
		local state = mountMgr:getMountState()			
		mountMgr:requestMountRide(state)
		self:setMountCD(5)					
	end--]]
		
	local onSwitchMountState = function(state)			
		if state == 1 then
			self.effectSprite:setVisible(true)
			--self.mountDown:setVisible(true)
		elseif state == 0 then
			self.effectSprite:setVisible(false)
			--self.mountDown:setVisible(false)
		else	
		end		
	end
	self.mountStateEvent = GlobalEventSystem:Bind(GameEvent.EventSwitchMountState, onSwitchMountState)
			
	local sprite = createSpriteWithFrameName(RES("main_mapRide.png"))	
	sprite:setColor(ccc3(125,125,125))		
	sprite:setScale(0.2)
	self.progressTimer = CCProgressTimer:create(sprite)
	self.progressTimer:setType(kCCProgressTimerTypeRadial)
	self.progressTimer:setReverseDirection(true)
	self.progressTimer:setPercentage(100)	
	self.rootNode:addChild(self.progressTimer,2)		
	self.progressTimer:setVisible(false)	


	VisibleRect:relativePosition(self.mount,self.rootNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-57,-114))
	VisibleRect:relativePosition(self.progressTimer,self.mount,LAYOUT_CENTER)
	--VisibleRect:relativePosition(self.mountDown,self.rootNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-59,-116))	

	
	VisibleRect:relativePosition(self.BT_MapView,self.rootNode,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(7,-2))
	VisibleRect:relativePosition(self.mapBg,self.BT_MapView,LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE,ccp(-38,-13.5))	
	VisibleRect:relativePosition(self.mapTop, self.mapBg, LAYOUT_CENTER,ccp(3,3))
	VisibleRect:relativePosition(HeroPos,self.BT_MapView,LAYOUT_TOP_INSIDE+LAYOUT_LEFT_INSIDE,ccp(40,-11))
	
	--排行榜
	self.rankBtn = createButtonWithFramename(RES("main_mapbtnBg.png"))
	local textRank = createSpriteWithFrameName(RES("main_mapRank.png"))
	--textRank:setScale(0.8)
	self.rankBtn:addChild(textRank)
	VisibleRect:relativePosition(textRank, self.rankBtn, LAYOUT_CENTER)
	--self.rankBtn:setTitleString(textRank)
	
	--G_setScale(self.rankBtn)
	self.rootNode:addChild(self.rankBtn)
	local rankBtnfunc = function ()
		local hero = GameWorld.Instance:getEntityManager():getHero()
		local level = PropertyDictionary:get_level(hero:getPT())
		if level<30 then
			UIManager.Instance:showSystemTips(Config.Words[16121])
		else
			GlobalEventSystem:Fire(GameEvent.EventOpenRankListView,1)
		end 			
	end
	self.rankBtn:addTargetWithActionForControlEvents(rankBtnfunc,CCControlEventTouchDown)
	VisibleRect:relativePosition(self.rankBtn,self.rootNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-3,-89))		
end	

function MainMap:hideRideControl()	--改为禁用
	self.mount:setVisible(false)	
		
	self.mountBtn = createButtonWithFramename(RES("main_mapbtnBg.png"))
	self.rootNode:addChild(self.mountBtn)
	VisibleRect:relativePosition(self.mountBtn,self.rootNode,LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE,ccp(-57,-114))
	
	local mountIcon = createSpriteWithFrameName(RES("main_mapRide.png"))
	self.mountBtn:addChild(mountIcon)
	VisibleRect:relativePosition(mountIcon, self.mountBtn, LAYOUT_CENTER)
	UIControl:SpriteSetGray(self.mountBtn)
	UIControl:SpriteSetGray(mountIcon)

	local showTips = function ()
		--GlobalEventSystem:Fire(GameEvent.EventClickMountButtonCallBack)
		UIManager.Instance:showSystemTips(Config.Words[7005])
	end
	self.mountBtn:setZoomOnTouchDown(false)
	self.mountBtn:addTargetWithActionForControlEvents(showTips, CCControlEventTouchDown)
	--self.mountDown:setVisible(false)	
end

function MainMap:showRideControl()
	self.mount:setVisible(true)	
	if self.mountBtn then
		self.mountBtn:setVisible(false)
	end
end	

function MainMap:UpdateRideState(state)
	if(state == 0) then	
		local mountMgr = GameWorld.Instance:getMountManager()
		local mountCD = mountMgr:getMountCD()
		if mountCD > 0 then				
			self:showCD()
			self:setMountBtState(MountBtState.MountCD)			
		else			
			self:setMountBtState(MountBtState.MountDown)
		end		
	elseif(state == 1) then
		self.progressTimer:setPercentage(0)
		self.progressTimer:stopAllActions()		
		self:setMountBtState(MountBtState.MountUp)
	end				
end
--[[

local MountBtState = {
MountUp = 1,
MountDown = 2,
MountCD = 3,
}
]]

--1马上    2 马下 3CD中
function MainMap:setMountBtState(state)
	if state == MountBtState.MountUp then
		self.effectSprite:setVisible(true)				
		self.mount:setVisible(true)
		self.progressTimer:setVisible(false)
	elseif state == MountBtState.MountDown then
		self.effectSprite:setVisible(false)	
		self.mount:setVisible(true)
		self.progressTimer:setVisible(false)
	elseif state == MountBtState.MountCD then
		self.effectSprite:setVisible(false)	
		self.mount:setVisible(true)
		self.progressTimer:setVisible(true)		
	end
end

function MainMap:showCD()
	local clearCD =  function(sender)	
		self:setMountCD(0)			
		self:setMountBtState(MountBtState.MountDown)
	end
	self.progressTimer:stopAllActions()
	local progressTo = CCProgressFromTo:create(5,100 ,0)
	local array = CCArray:create()	
	array:addObject(progressTo);
	array:addObject(CCCallFuncN:create(clearCD))	
	local sequence = CCSequence:create(array)	
	self.progressTimer:runAction(sequence)			
end

function MainMap:setMountCD(cd)
	local mountMgr = GameWorld.Instance:getMountManager()
	mountMgr:saveMountCD(cd)	
end	

function MainMap:runScaleAction()
	local scale = CCScaleTo:create(0.3, 0.85)
	local scaleBack = CCScaleTo:create(0.3, 0.9)
	local array = CCArray:create()
	array:addObject(scale)
	array:addObject(scaleBack)
	local seqAction = CCSequence:create(array)
	local foreverAction = CCRepeatForever:create(seqAction)
	if self.effectSprite then
		self.effectSprite:stopAllActions()
		self.effectSprite:runAction(foreverAction)
	end
end



--显示导航地图
function MainMap:showNavigationMap()

	if not self.navigationMapView then
		self.navigationMapView = NavigationMapView.New()
		self.mapBg:addChild(self.navigationMapView:getRootNode())
		VisibleRect:relativePosition(self.navigationMapView:getRootNode(), self.mapBg, LAYOUT_CENTER)			
	end	
end

function MainMap:getNavigationMap()
	return self.navigationMapView
end	

function MainMap:setViewHide()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,visibleSize.height/3))	
	self.rootNode:runAction(moveBy)
end

function MainMap:setViewShow()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,-visibleSize.height/3))	
	self.rootNode:runAction(moveBy)	
end

function MainMap:showEffectSprite(bShow)
	if self.effectSprite then
		self.effectSprite:setVisible(bShow)
	end
end