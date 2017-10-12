require ("ui.UIManager")

MainOtherMenu = MainOtherMenu or BaseClass()

MainOtherType = 
{
	LeaveActivity = 1,
	LeaveInstance = 2,
	Mail = 3, 
	Instance = 4, 
	WorldBoss = 5,	
	Stronger = 6,
}

local const_btnSpacing = 15
local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()

local const_attackerNodeSpacing = 0 --每个攻击图标的间隔
local const_attackerNodeSize = CCSizeMake(118, 115) --每个攻击图标的大小
local const_attackerSelectedTag = 12580	--攻击选中图标的tag
local const_maxAttackerNodeCount = 3 --允许同时显示的最大攻击图标数量
local const_heroHeadConfig =
{
	[tostring(ModeType.ePlayerProfessionWarior)..tostring(ModeType.eGenderMale)] = {icon = "main_headManWarior.png", offset= ccp(0, 8)},
	[tostring(ModeType.ePlayerProfessionWarior)..tostring(ModeType.eGenderFemale)] = {icon = "main_headFemanWarior.png", offset= ccp(5, 13)},
	[tostring(ModeType.ePlayerProfessionMagic)..tostring(ModeType.eGenderMale)] = {icon = "main_headManMagic.png", offset= ccp(3, 3)},
	[tostring(ModeType.ePlayerProfessionMagic)..tostring(ModeType.eGenderFemale)] = {icon = "main_headFemanMagic.png", offset= ccp(0, 10)},
	[tostring(ModeType.ePlayerProfessionWarlock)..tostring(ModeType.eGenderMale)] = {icon = "main_headManDaoshi.png", offset= ccp(0, 19)},
	[tostring(ModeType.ePlayerProfessionWarlock)..tostring(ModeType.eGenderFemale)] = {icon = "main_headFemanDaoshi.png", offset= ccp(0, 19)},
}

--Juchao@20140724: 重构代码
--如何添加一个按钮：
--1. initData函数里，增加一项数据到self.btnList
--2. 根据需求设置rejectOther的值
--3. 在showByCondition函数里，对你的按钮进行条件显示
function MainOtherMenu:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(CCSizeMake(const_visibleSize.width, 200))
		
	self.menuNode = CCNode:create()	--显示按钮		
	self.menuNode:setContentSize(CCSizeMake(const_visibleSize.width, 80))
	self.rootNode:addChild(self.menuNode)
	VisibleRect:relativePosition(self.menuNode, self.rootNode, LAYOUT_TOP_INSIDE + LAYOUT_RIGHT_INSIDE)
	
	self.wingNode = CCNode:create()	--显示翅膀	
	self.wingNode:setContentSize(CCSizeMake(80,80))
	self.rootNode:addChild(self.wingNode)
	VisibleRect:relativePosition(self.wingNode,self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(-20, 23))
	
	self.attackerNode = CCNode:create()	--显示攻击者	
	self.attackerNode:setContentSize(CCSizeMake(const_visibleSize.width, const_attackerNodeSize.height))
	self.rootNode:addChild(self.attackerNode)

	self:initData()	--初始化数据
	self:initBtns()	--创建按钮
	self:showByCondition() --根据显示条件，显示各个按钮
	self:updateBtnPositon()--更新各个按钮的位置
	self:initWingBtn()
--	self:testAttackers()
end

function MainOtherMenu:initWingBtn()
	self.wingFadeSprite = createSpriteWithFrameName(RES("ride_fade_sprite.png"))
	self.wingNode:addChild(self.wingFadeSprite)
	VisibleRect:relativePosition(self.wingFadeSprite, self.wingNode, LAYOUT_CENTER)
	self.wingFadeSprite:setScale(1.2)
	self.wingFadeSprite:setVisible(false)
		
	self.wingBtn = createButtonWithFramename(RES("common_circle_bg.png"))
	local item = createSpriteWithFrameName(RES("main_wing.png"))
	self.wingBtn:addChild(item)
	VisibleRect:relativePosition(item, self.wingBtn, LAYOUT_CENTER,ccp(2,2))
	self.wingNode:addChild(self.wingBtn)
	VisibleRect:relativePosition(self.wingBtn, self.wingNode, LAYOUT_CENTER)
	
	local wingBtnFun = function ()
		self:clickWingBtn()
	end
	self.wingBtn:addTargetWithActionForControlEvents(wingBtnFun, CCControlEventTouchDown)
	self.wingBtn:setVisible(false)
	
	self:updateWingBtn(true)
end


-- 设置按钮是否可见
-- Juchao@20140724: 设置一个btn是否可见。根据rejectOther字段，进行其他按钮的设置。
function MainOtherMenu:setBtnVisible(btnType, bShow)
	local btn = self:findBtnInfo(btnType)
	if not btn then
		return		
	end
	--print("set "..btnType.." "..tostring(bShow))
	if bShow then	--显示一个按钮
		if btn.rejectOther then	--如果该按钮与其他互斥，则隐藏所有其他按钮
			for k, v in pairs(self.btnList) do
				self:doSetBtnVisible(k, false)			
			end
			self:doSetBtnVisible(btnType, true)		
		else	--该按钮不互斥其他按钮，需要判断是否有与其他按钮互斥的按钮正在显示，如果有，则不能显示
			for k,v in pairs(self.btnList) do
				if v.btn and v.btn:isVisible() and v.rejectOther then
					bShow = false
					break
				end
			end
			self:doSetBtnVisible(btnType, bShow)	
		end
	else	--隐藏其他按钮
		
		if btn.rejectOther and (not self:hasShowingRejectOtherBtn()) then --如果该按钮与其他互斥，隐藏后需要根据开启条件显示其他按钮
			self:showByCondition()
		end		
		self:doSetBtnVisible(btnType, false)		
	end
	self:updateBtnPositon()
end	

function MainOtherMenu:__delete()
	self.rootNode:release()
end

function MainOtherMenu:getRootNode()
	return self.rootNode
end	

-------------------------以下为私有接口
function MainOtherMenu:initData()
	--Juchao@20140724: 按钮的配置
	--rejectOther: 为true时，显示该按钮时会隐藏其他的按钮。
	--PS：所有按钮默认为隐藏
	self.btnList = 
	{		
		{btnType = MainOtherType.LeaveActivity, icon = "main_leave.png",btn = nil,func = self.handlerLeaveActivityClick,btText = "main_instance_leave_word.png",rejectOther = true},	
		{btnType = MainOtherType.LeaveInstance, icon = "main_leave.png",btn = nil,func = self.handlerLeaveInstanceClick,btText = "main_instance_leave_word.png",rejectOther = true},			
		{btnType = MainOtherType.Mail, icon = "mail_titleimg.png",btn = nil,func = self.handlerMailClick,btText = "main_left_mail_word.png",rejectOther = false},	
		{btnType = MainOtherType.Instance, icon = "main_instance.png",btn = nil,func = self.handlerInstanceClick,btText = "main_instance_word.png",rejectOther = false},	
		{btnType = MainOtherType.WorldBoss, icon = "main_world_boss.png",btn = nil,func = self.handlerWorldBossClick,btText = "main_world_boss_label.png", rejectOther = false},
		{btnType = MainOtherType.Stronger, icon = "menu_1_icon.png",btn = nil,func = self.handleStrongerClick,btText = "word_window_strong.png", rejectOther = false},	
	}
	
	--存放攻击者，有序数组
	self.attackers = 
	{
--		{id = "", node = ""}
	}
end

function MainOtherMenu:hasShowingRejectOtherBtn()
	for k, v in pairs(self.btnList) do
		if v.rejectOther and v.btn:isVisible() then
			return true
		end
	end
	return false
end

function MainOtherMenu:showByCondition()
	local instanceManager = GameWorld.Instance:getGameInstanceManager()
	self:doSetBtnVisible(MainOtherType.Instance, instanceManager:isInstanceOpen())

	self:doSetBtnVisible(MainOtherType.WorldBoss, instanceManager:isWorldBossOpen())
	self:doSetBtnVisible(MainOtherType.Stronger, instanceManager:isWorldBossOpen())

	local mailMgr = GameWorld.Instance:getEntityManager():getHero():getMailMgr()
	self:doSetBtnVisible(MainOtherType.Mail, mailMgr:getMailUnreadNum() > 0)
	self:doSetBtnVisible(MainOtherType.Calendar, true)
end

function MainOtherMenu:initBtns()
	for k, v in ipairs(self.btnList) do 
		self:createMenuBtn(v)
	end		
end

function MainOtherMenu:createMenuBtn(data)
	data.btn  = createButton(createScale9SpriteWithFrameName(RES("common_circle_bg.png")))
	self.menuNode:addChild(data.btn)
	data.btn:setVisible(not data.rejectOther)
	
	local btnIcon = createSpriteWithFrameName(RES(data.icon))		
	data.btn:addChild(btnIcon) 		
	VisibleRect:relativePosition(btnIcon, data.btn, LAYOUT_CENTER)
	local textLable = createSpriteWithFrameName(RES(data.btText))				
	data.btn:addChild(textLable) 
	VisibleRect:relativePosition(textLable, data.btn, LAYOUT_CENTER_X + LAYOUT_BOTTOM_OUTSIDE)
	
	local btnfunc = function ()
		self:removeAnimation(data.btnType)							
		data.func()
	end
	data.btn:addTargetWithActionForControlEvents(btnfunc, CCControlEventTouchDown)	
end

function MainOtherMenu:findBtnInfo(btnType)
	for k, v in pairs(self.btnList) do
		if v.btnType == btnType then
			return v
		end
	end
	return nil
end


function MainOtherMenu:doSetBtnVisible(btnType, bShow)
	local info = self:findBtnInfo(btnType)
	if info and info.btn then
		info.btn:setVisible(bShow)	
	end
end

--增加一个攻击者
function MainOtherMenu:addAttacker(obj)
	if (not obj) or (obj:getId() == G_getHero():getId()) or self:findAttacker(obj:getId()) then	--已经存在则不处理
		return	
	end

	local attacker = self:createAttacker(obj:getId(), PropertyDictionary:get_professionId(obj:getPT()), 
				PropertyDictionary:get_gender(obj:getPT()), PropertyDictionary:get_name(obj:getPT()))
	if not attacker then
		return
	end
	--新来的优先级最高，放在最后
	table.insert(self.attackers, 1, attacker)
	--更新位置
	self:updateAttackers()
end

function MainOtherMenu:testAttackers()
	local list = 
	{
		{id = "1", p = ModeType.ePlayerProfessionWarior, g = ModeType.eGenderMale, n = "AndyH"},
		{id = "2", p = ModeType.ePlayerProfessionWarior, g = ModeType.eGenderFemale, n = "AndyH"},
		{id = "3", p = ModeType.ePlayerProfessionMagic, g = ModeType.eGenderMale, n = "AndyH"},
		{id = "4", p = ModeType.ePlayerProfessionMagic, g = ModeType.eGenderFemale, n = "AndyH"},
		{id = "5", p = ModeType.ePlayerProfessionWarlock, g = ModeType.eGenderMale, n = "AndyH"},
		{id = "6", p = ModeType.ePlayerProfessionWarlock, g = ModeType.eGenderFemale, n = "AndyH"},
	}
	
	const_maxAttackerNodeCount = 10	
	for k, v in pairs(list) do
		local attacker = self:createAttacker(v.id, v.p, v.g, v.n)
		if  attacker then
			table.insert(self.attackers, 1, attacker)		
		end			
	end
	--更新位置
	self:updateAttackers()
end

function MainOtherMenu:findAttacker(id)
	for k, v in pairs(self.attackers) do 
		if v.id == id then
			return k, v
		end
	end
	return nil
end

function MainOtherMenu:createAttacker(id, profession, gender, name)
	local icon, offset = self:getHeroHead(profession, gender)
	if not icon then
		return nil
	end
	local btn = createButtonWithFramename(RES("pk_bg_normal.png"))	
	if not btn then
		return nil		
	end
	self.attackerNode:addChild(btn)	
	
	local head = createSpriteWithFrameName(RES(icon))
	head:setZOrder(10)
	btn:addChild(head)
	VisibleRect:relativePosition(head, btn, LAYOUT_TOP_INSIDE + LAYOUT_CENTER_X, offset)
	head:setScale(0.6)
	
	local label = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size3"), FCOLOR("ColorWhite1"))											
	btn:addChild(label)
	VisibleRect:relativePosition(label, btn, LAYOUT_BOTTOM_INSIDE + LAYOUT_CENTER_X)
	label:setZOrder(10)
	
	local array = CCArray:create()
	local smaller = CCScaleTo:create(0.3, 1)
	local bigger = CCScaleTo:create(0.3, 1.2)
	for i = 1, 2 do 
		array:addObject(bigger)
		array:addObject(smaller)
	end
	local seqAction = CCSequence:create(array)	
	btn:runAction(seqAction)
	
	local onClick = function()
		self:handleAttackerClicked(id)
	end
	btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	return {id = id, node = btn}
end

function MainOtherMenu:handleAttackerClicked(id)
	local index, attacker = self:findAttacker(id)
	if not index then
		return
	end
	for k, v in pairs(self.attackers) do
		v.node:removeChildByTag(const_attackerSelectedTag, true)
	end	
	local selectedIcon = createSpriteWithFrameName(RES("pk_bg_selected.png"))
	selectedIcon:setTag(const_attackerSelectedTag)
	selectedIcon:setZOrder(5)
	attacker.node:addChild(selectedIcon)
	VisibleRect:relativePosition(selectedIcon, attacker.node, LAYOUT_CENTER)
	--选中这个目标
	GlobalEventSystem:Fire(GameEvent.EVENT_ENTITY_TOUCH_OBJECT, EntityType.EntityType_Player, id)
end

function MainOtherMenu:removeAttacker(obj)
	if not obj then
		return
	end
	local index, attacker = self:findAttacker(obj:getId())
	if not index then
		return	
	end		
	self.attackerNode:removeChild(attacker.node, true)
	table.remove(self.attackers, index)
	self:updateAttackers()
end

function MainOtherMenu:clearAllAttackers()
	self.attackers = {}
	self.attackerNode:removeAllChildrenWithCleanup(true)
end
	
--更新位置&&删除超过最大值的
function MainOtherMenu:updateAttackers()
	local preNode
	local size = #self.attackers
	if size > const_maxAttackerNodeCount then
		size = const_maxAttackerNodeCount
	end
	local width = size * const_attackerNodeSize.width + const_attackerNodeSpacing * (size - 1)
	self.attackerNode:setContentSize(CCSizeMake(width, const_attackerNodeSize.height))	
	VisibleRect:relativePosition(self.attackerNode, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE)
	for k, v in ipairs(self.attackers) do
		if k <= const_maxAttackerNodeCount then		
			if not preNode then
				VisibleRect:relativePosition(v.node, self.attackerNode, LAYOUT_LEFT_INSIDE + LAYOUT_CENTER_Y)
			else
				VisibleRect:relativePosition(v.node, preNode, LAYOUT_RIGHT_OUTSIDE + LAYOUT_CENTER_Y, ccp(const_attackerNodeSpacing, 0))
			end
			preNode = v.node							
		else
			self.attackerNode:removeChild(v.node, true)
			self.attackers[k] = nil
		end
	end		
end

function MainOtherMenu:updateWingBtn(bShow)
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

function MainOtherMenu:clickWingBtn()
	GlobalEventSystem:Fire(GameEvent.EventOpenSubWingView)
end

function MainOtherMenu:wingFadeAciton()
	local array = CCArray:create()	
	array:addObject(CCFadeIn:create(0.5));	
	array:addObject(CCFadeOut:create(0.5));		
	local action = CCSequence:create(array)								
	local forever = CCRepeatForever:create(action)
	self.wingFadeSprite:runAction(forever)
end	

function MainOtherMenu:updateBtnPositon()
	local preNode
	for k, v in ipairs(self.btnList) do
		if v.btn:isVisible() then
			if not preNode then
				VisibleRect:relativePosition(v.btn, self.menuNode, LAYOUT_RIGHT_INSIDE + LAYOUT_CENTER_Y)
			else
				VisibleRect:relativePosition(v.btn, preNode, LAYOUT_LEFT_OUTSIDE + LAYOUT_CENTER_Y, ccp(-const_btnSpacing, 0))
			end
			preNode = v.btn
		end
	end
end

function MainOtherMenu:addAnimation(btnType)
	local info = self:findBtnInfo(btnType)
	if not info then
		return
	end								

	if btnType == MainOtherType.WorldBoss then 
		local animate = createAnimate("cycle",3,0.15)
		local forever = CCRepeatForever:create(animate)		
		
		if not info.framesprite then		
			info.framesprite = CCSprite:create()						
			info.framesprite:setScale(1.2)
			info.btn:addChild(info.framesprite)			
		else
			info.framesprite:stopAllActions()
			info.framesprite:setVisible(true)			
		end	
		info.framesprite:runAction(forever)
		VisibleRect:relativePosition(info.framesprite, info.btn, LAYOUT_CENTER)
	else--[[ btnType == MainOtherType.LeaveInstance then --]]
		local array = CCArray:create()
		local moveLeft = CCMoveBy:create(0.4, ccp(10,0))
		local moveRight = CCMoveBy:create(0.4, ccp(-10,0))
		array:addObject(moveLeft)
		array:addObject(moveRight)
		local seqAction = CCSequence:create(array)
		local forever = CCRepeatForever:create(seqAction)
		
		if not info.framesprite then
			info.framesprite = createSpriteWithFrameName(RES("newGuidelines_Arrow.png"))	
			self.menuNode:addChild(info.framesprite)				
		else
			info.framesprite:stopAllActions()
		end	
		VisibleRect:relativePosition(info.framesprite, info.btn, LAYOUT_LEFT_OUTSIDE+LAYOUT_CENTER)
		info.framesprite:setVisible(true)
		info.framesprite:runAction(forever)
	end				
end

function MainOtherMenu:removeAnimation(btnType)
	local info = self:findBtnInfo(btnType)
	if not info then
		return
	end
	if info.framesprite then 
		info.framesprite:setVisible(false)
		info.framesprite:stopAllActions()
	end
end

function MainOtherMenu:getHeroHead(profession, gender)
	local key = tostring(profession)..tostring(gender)
	local data = const_heroHeadConfig[key]
	if data then
		return data.icon, data.offset
	else
		return nil
	end
end

-- 点击按钮时所做的处理
function MainOtherMenu:handlerLeaveInstanceClick()
	local manager = GameWorld.Instance:getGameInstanceManager()
	manager:requestShowQuestReward()
	--[[local exitFunction = function(arg,text,id)
		if id == 2 then
			GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
			local manager = GameWorld.Instance:getGameInstanceManager()
			manager:requestLeaveGameInstance()
			local msg = {}
			table.insert(msg,{word = Config.Words[15011], color = Config.FontColor["ColorWhite1"]})
			UIManager.Instance:showSystemTips(msg)
		end
	end

	local msg = showMsgBox(Config.Words[15022],E_MSG_BT_ID.ID_CANCELAndOK)	
	msg:setNotify(exitFunction)	--]]	
end	

function MainOtherMenu:handlerMailClick()
	GlobalEventSystem:Fire(GameEvent.EventOpenMailView)	
end

function MainOtherMenu:handlerInstanceClick()
	GlobalEventSystem:Fire(GameEvent.EventGameInstanceViewOpen)
end

function MainOtherMenu:handlerWorldBossClick()
	GlobalEventSystem:Fire(GameEvent.EventShowWorldBossView)
end

function MainOtherMenu:handleStrongerClick()
	GlobalEventSystem:Fire(GameEvent.EventOpenStrongerView)
end

function MainOtherMenu:handlerLeaveActivityClick()
	local mapMgr = GameWorld.Instance:getMapManager()
	local sceneRefId = mapMgr:getCurrentMapRefId()
	local activityType = mapMgr:getMapActivityType(sceneRefId)
	if  activityType == E_mapActivityType.mining then
		GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
			--请求离开活动
			--Todo 暂时只做离开挖矿场景
		local miningMgr = GameWorld.Instance:getMiningMgr()
		miningMgr:requestExitMining()
	elseif activityType == E_mapActivityType.monsterInvasion then
		local monstorInvasionView = UIManager.Instance:getMainView():getMonstorInvasionView()
		if monstorInvasionView then 
			monstorInvasionView:showExitDlg()	
		end			
	elseif activityType == E_mapActivityType.bossTemple then
		local exitFunction = function(arg,text,id)
			if id == 2 then
				GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
				local manager = GameWorld.Instance:getBossTempleMgr()
				manager:requestExitBossTemple()
				local msg = {}
				table.insert(msg,{word = Config.Words[15011], color = Config.FontColor["ColorWhite1"]})
				UIManager.Instance:showSystemTips(msg)
			end
		end

		local msg = showMsgBox(Config.Words[25534],E_MSG_BT_ID.ID_CANCELAndOK)	
		msg:setNotify(exitFunction)			
	end	
end

function MainOtherMenu:handlerSubPackageLoadClick()
	GlobalEventSystem:Fire(GameEvent.EventSubPackageLoadViewOpen)
end

function MainOtherMenu:setViewHide()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(visibleSize.width/1.5, 0))	
	self.rootNode:runAction(moveBy)
end

function MainOtherMenu:setViewShow()
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(-visibleSize.width/1.5,0))	
	self.rootNode:runAction(moveBy)	
end

----------------------------------------------------------------------
--新手指引
function MainOtherMenu:getInstanceNode()
	if self.btnList[MainOtherType.Instance] then
		local btn = self.btnList[MainOtherType.Instance].btn
		return btn
	end	
end
----------------------------------------------------------------------