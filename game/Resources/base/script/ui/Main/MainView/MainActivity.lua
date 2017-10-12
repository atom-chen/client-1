require ("object.activity.ActivityDef")
require("object.activity.ActivityObj")
require("object.activity.ActivityManageMgr")
require("ui.utils.ActivityIcon")
require("ui.utils.LayoutNode")
require("data.dataSave.dataSave")

MainActivity = MainActivity or BaseClass()

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

function MainActivity:__init()
	self.typeActivityIconMap = {}
	
	self.rootNode = CCNode:create()	
	self.rootNode:setContentSize(CCSizeMake(450,100))
	
--[[	self.mountNode = CCNode:create()	
	self.mountNode:setContentSize(CCSizeMake(100,100))
	self.rootNode:addChild(self.mountNode)
	VisibleRect:relativePosition(self.mountNode,self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,-5))--]]
	
	
	self.btnAllWidth = 0
	self.btnAllHeight = 0	
	self:createStaticBtn()		
	--self:initMountBtn()
	--self:initWingBtn()	
	self:initActivity()
end	

function MainActivity:__delete()
	if self.activityNotifyId then
		local activityManageMgr = GameWorld.Instance:getActivityManageMgr()
		activityManageMgr:removeActivityNotify(self.activityNotifyId)
	end
	for k, v in pairs(self.typeActivityIconMap) do
		v:DeleteMe()
	end		
	if self.activityArea then
		self.activityArea:DeleteMe()	
		self.activityArea = nil
	end
end

function MainActivity:getRootNode()
	return self.rootNode
end

function MainActivity:createStaticBtn()
	self.staticBtn = createButtonWithFramename(RES("main_activityAll.png"))		
	self.rootNode:addChild(self.staticBtn)
	
	local staticBtnfunc = function ()
		self:clickStaticBtn()
		GlobalEventSystem:Fire(GameEvent.EventOpenActivityManageView)
	end
	self.staticBtn:addTargetWithActionForControlEvents(staticBtnfunc, CCControlEventTouchDown)
				
	local btnSize = self.staticBtn:getContentSize()
	self.btnAllWidth = self.btnAllWidth + btnSize.width	
	self.btnAllHeight = self.btnAllHeight + btnSize.height	
	self.rootNode:setContentSize(CCSizeMake(self.btnAllWidth,self.btnAllHeight))
	
	VisibleRect:relativePosition(self.staticBtn,self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER,ccp(0,-10))
end			

function MainActivity:initActivity()
	self.activityArea = LayoutNode.New()
	self.activityArea:initWithBatchPvr("ui/ui_game/ui_game_mainView.pvr")
	self.activityArea:setCellSize(CCSizeMake(80, 80))	
	self.activityArea:setSpacing(-5, 10)
	self.activityArea:setColumn(-1)
	self.activityArea:setTouchEnabled(true)
	self.rootNode:addChild(self.activityArea:getRootNode())	
	
	local onActivityClick = function(index)
		local grid = self.activityArea:getGridAtIndex(index)
		if grid and grid:getData() then
			self:onActivityClick(grid:getData():getRefId())
		end
	end
	self.activityArea:setTouchNotify(onActivityClick)
	
	local onActivityNotify = function(refId, activityType, event, info)
		self:onActivityNotify(refId, activityType, event, info)
	end	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	self.activityNotifyId = activityManageMgr:addActivityNotify(onActivityNotify)	
	
	GameWorld.Instance:getNewGuidelinesMgr():requestFunStep()	
	self:updateActivity()
end

function MainActivity:updateActivity()
	self.activityArea:clear()
	for k, v in pairs(self.typeActivityIconMap) do
		v:DeleteMe()
	end
	self.typeActivityIconMap = {}
	
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	local list = activityManageMgr:getTypeActivityMap()		
	local nodeList = {}		
	local has = false
	for k, v in pairs(list) do
		for kk, vv in ipairs(v) do		--按顺序遍历，因为list里面的活动是根据优先级进行排列的
			if not self.typeActivityIconMap[vv:getType()] then	
				if vv:canPush() then	--使能/开启/需要推送的活动																	
					local icon = self:createActivityIcon(vv)			
					table.insert(nodeList, icon)
					self.typeActivityIconMap[vv:getType()] = icon	
					self:updateActivityIconText(vv:getType())				
				elseif vv:isEnable() and vv:isActivated() then
					has = true
				end
			else
				if vv:isEnable() and vv:isActivated() then
					has = true
				end
			end
			
		end
	end
	self.activityArea:setGrids(nodeList)		
	self.activityArea:reload()
	self:layoutAcitivityArea()
	self:setAllActivityAnimation(has)
	
	self:guideActivityBtn()
end

function MainActivity:layoutAcitivityArea()
	VisibleRect:relativePosition(self.activityArea:getRootNode(), self.staticBtn, LAYOUT_LEFT_OUTSIDE + LAYOUT_CENTER_Y, ccp(8, 17))
end

function MainActivity:updateActivityIconText(activityType)
	local icon = self.typeActivityIconMap[activityType]
	if icon then
		local option = icon:getData():getCountDownOption()			
		if option == 1 then		--显示开始倒计时
			icon:setText(icon:getData():getRemainTimeStr(true), "ColorWhite3")
		elseif option == 2 then	--显示结束倒计时
			icon:setText(icon:getData():getRemainTimeStr(false), "ColorRed2")
		else 					--不需要显示倒计时
			icon:setText(" ")
		end
	end
end

function MainActivity:onActivityNotify(refId, activityType, event, info)
--	print("MainActivity activityNotifyId="..tostring(self.activityNotifyId))
	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
	if event == "time" then
		self:updateActivityIconText(activityType)
	elseif event == "active" or event == "enable" or event == "open" then	
		self:updateActivity()
	elseif event == "running" then		
	end
end

function MainActivity:createActivityIcon(obj)
	local activityIcon = ActivityIcon.New(createSpriteWithFrameName(RES("activityBox.png")))
	activityIcon:setData(obj)	
	activityIcon:setWordLayout(LAYOUT_CENTER_X+LAYOUT_BOTTOM_INSIDE, ccp(0, 12))
	activityIcon:setTextLayout(LAYOUT_CENTER_X+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 17))		
	return activityIcon
end

function MainActivity:onActivityClick(refId)
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck, "MainActivity", refId)	
	GlobalEventSystem:Fire(GameEvent.EventActivityClick, refId)	
--[[	local activityManageMgr = GameWorld.Instance:getActivityManageMgr()	
	activityManageMgr:setActivityState(refId, false)	--]]
end

function MainActivity:getAllSizeWithWidthHeight(size,inWidth,inHeight)
	local width,height
	
	width = inWidth + size.width
	if size.height > inHeight then
		height = size.height
	else
		height = inHeight
	end
	
	return width,height	
end

function MainActivity:setAllActivityAnimation(bShow)
	if not self.allActivityAni then
		local animate = createAnimate("activity",6,0.175)
		self.allActivityAni = CCSprite:create()
		local forever = CCRepeatForever:create(animate)		
		self.allActivityAni:runAction(forever)				
		self.staticBtn:addChild(self.allActivityAni, -1)
		VisibleRect:relativePosition(self.allActivityAni,self.staticBtn, LAYOUT_CENTER,ccp(-4,3))		
	end
	
	self.allActivityAni:setVisible(bShow)
end
--------------------------------------------------------------------------------------------------------------------------------
--[[function MainActivity:initWingBtn()
	self.wingFadeSprite = createSpriteWithFrameName(RES("ride_fade_sprite.png"))
	self.mountNode:addChild(self.wingFadeSprite)
	VisibleRect:relativePosition(self.wingFadeSprite, self.staticBtn, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-15+156, -140-85))
	self.wingFadeSprite:setScale(1.2)
	self.wingFadeSprite:setVisible(false)
		
	self.wingBtn = createButtonWithFramename(RES("common_circle_bg.png"))
	local item = createSpriteWithFrameName(RES("main_wing.png"))
	self.wingBtn:addChild(item)
	VisibleRect:relativePosition(item, self.wingBtn, LAYOUT_CENTER,ccp(2,2))
	self.mountNode:addChild(self.wingBtn)
	VisibleRect:relativePosition(self.wingBtn, self.staticBtn, LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_INSIDE,ccp(-35+156, -117-85))
	
	local wingBtnFun = function ()
		self:clickWingBtn()
	end
	self.wingBtn:addTargetWithActionForControlEvents(wingBtnFun, CCControlEventTouchDown)
	self.wingBtn:setVisible(false)
	
	self:updateWingBtn(true)
end--]]


--[[function MainActivity:clickWingBtn()
	GlobalEventSystem:Fire(GameEvent.EventOpenSubWingView)
end--]]

--[[function MainActivity:updateWingBtn(bShow)
	if bShow then
		if self.wingBtn and self.wingFadeSprite then
			self.wingFadeSprite:setVisible(bShow)
			self.wingBtn:setVisible(bShow)
			self:wingFadeAciton()
		end				
	else
		if self.wingBtn and self.wingFadeSprite then
			self.wingBtn:setVisible(false)
			self.wingFadeSprite:stopAllActions()
			self.wingFadeSprite:setVisible(false)			
		end			
	end
end

function MainActivity:wingFadeAciton()
	local array = CCArray:create()	
	array:addObject(CCFadeIn:create(0.5));	
	array:addObject(CCFadeOut:create(0.5));		
	local action = CCSequence:create(array)								
	local forever = CCRepeatForever:create(action)
	self.wingFadeSprite:runAction(forever)
end	--]]	

function MainActivity:doNewGuidelinesByClickNode()
	self:clickMountBtn()
end

function MainActivity:setViewHide()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,visibleSize.height/2))	
	self.rootNode:runAction(moveBy)
	
	--self.mountNode:setVisible(false)
end

function MainActivity:setViewShow()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0,-visibleSize.height/2))	
	self.rootNode:runAction(moveBy)	
	
	--self.mountNode:setVisible(true)
end

function MainActivity:isInMainActivity(refId)
	for k,v in pairs(self.typeActivityIconMap) do
		local data = v:getData()
		local id = data:getRefId()
		if id == refId then
			return true
		end
	end
	return false
end

------------------------------------
--新手指引
function MainActivity:getStaticBtn()
	return self.staticBtn
end

function MainActivity:clickStaticBtn()
	GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainActivity","staticBtn")
end

function MainActivity:getActivitiesBtn(refId)
	for k,v in pairs(self.typeActivityIconMap) do
		local data = v:getData()
		local id = data:getRefId()
		if id == refId then
			return v:getRootNode()
		end
	end
end

function MainActivity:guideActivityBtn() 
	for k,v in pairs(self.typeActivityIconMap) do
		local data = v:getData()
		local id = data:getRefId()
		if id then
			if GameData.DataSave[id] then
				local hadOperate = true
				if id == "activity_manage_16" then			-- vip抽奖特殊处理
					if PropertyDictionary:get_vipType(G_getHero():getPT()) > 0 then
						hadOperate = GameWorld.Instance:getNewGuidelinesMgr():hadOperate(id)
					end
				elseif id == "activity_manage_6" then
					if PropertyDictionary:get_level(G_getHero():getPT()) >= 40 then
						hadOperate = GameWorld.Instance:getNewGuidelinesMgr():hadOperate(id)
					end
				elseif id == "activity_manage_7" then
					if PropertyDictionary:get_level(G_getHero():getPT()) >= 40 then
						hadOperate = GameWorld.Instance:getNewGuidelinesMgr():hadOperate(id)
					end
				elseif id == "activity_manage_2" then
					hadOperate = true
				else
					hadOperate = GameWorld.Instance:getNewGuidelinesMgr():hadOperate(id)
				end
				
				if not hadOperate then
					GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesMainActivity(id)
				end
			end
		end
	end
end




