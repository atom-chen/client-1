--[[
人物攻击界面
--]]
require ("object.handup.API.HandupCommonAPI")

MainAttackSkill = MainAttackSkill or BaseClass()

local distant = 20
local UPDIR = 1
local DOWNDIR = 2
local CD_Sprite_Z_Order = 100


local PAGE1 = 1
local PAGE2 = 2
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local frameSize = CCEGLView:sharedOpenGLView():getFrameSize()
local const_scale = VisibleRect:SFGetScale()
--local touchArea = CCSizeMake(300 * const_scale, 250 * const_scale)
local touchArea = CCSizeMake(300 * const_scale, 320 * const_scale)

local totalSkillCount = 8
local attackIndex = totalSkillCount+1 --攻击按钮的索引时9， 其他的技能索引为1-8
local tag = 100

function MainAttackSkill:__init()
	--{"attackLayer", "progressTimer", "switchSkillLabel", "bEnable", "heightLightSprite", "refId"}
	self.quickSkill = {}
	self.cdProgressTimer = {}
	self.proTimerAction = {}
	self.curShowPage = PAGE1	
	
	self.rootNode = CCLayer:create()
	self.rootNode:setContentSize(visibleSize)
	
	self.scale = VisibleRect:SFGetScale()
	self.isShow = true
	self.pressBtnIndex = nil
	
	--self.batchNode = nil
	
	self:initNode()
	self:initQuickSkill()	
	self:showView()
	self:bindCDReady()
end	

function MainAttackSkill:__delete()
	if self.quickSkill then 
		for k, v in pairs(self.quickSkill) do 
			v.heightLightSprite:release()
		end
		self.quickSkill = nil
	end
	for k, v in pairs(self.cdProgressTimer) do
		v:release()
	end
	for k, v in pairs(self.proTimerAction) do
		v:release()
	end
	
	if self.handupEvent then
		GlobalEventSystem:UnBind(self.handupEvent)
		self.handupEvent = nil
	end
	self:unbindCDReady()
end

function MainAttackSkill:setPressBtn(btnIndex)
	if btnIndex then
--		print("set "..btnIndex)
		G_getHero():getSkillMgr():setAutoUseSkill(true)
	elseif self.pressBtnIndex then
--		print("clear "..self.pressBtnIndex)
		G_getHero():getSkillMgr():setAutoUseSkill(false)
	end
	self.pressBtnIndex = btnIndex
end	

function MainAttackSkill:bindCDReady()
	self:unbindCDReady()
	local onEventAutoUseSkillCDReady = function(skillRefId)					
		if self.pressBtnIndex then
--			print("auto use skill")
			if not G_getHero():isMovingToUseSkill() then		
				self:useSkillByIndex(self.pressBtnIndex, true)
			end
			G_getHero():getSkillMgr():resetAutoUseSkillCD()
		end
	end
	self.CDReadyEvent = GlobalEventSystem:Bind(GameEvent.EventAutoUseSkillCDReady, onEventAutoUseSkillCDReady)
end

function MainAttackSkill:unbindCDReady()
	if self.CDReadyEvent then
		GlobalEventSystem:UnBind(self.CDReadyEvent)
		self.CDReadyEvent = nil
	end
end

function MainAttackSkill:initQuickSkill()
	self.touchPoint =  ccp(0,0)
	for i = 1, attackIndex do
		self.quickSkill[i] = {}
		self.quickSkill[i].heightLightSprite = createSpriteWithFrameName(RES("skill_heightlight_frame.png"))
		self.quickSkill[i].heightLightSprite:retain()	
		
		--local btnIcon = createSpriteWithFrameName(RES(self.btnList[i].icon))
--[[		if self.batchNode == nil then
			self.batchNode = CCSpriteBatchNode:createWithTexture(self.quickSkill[i].heightLightSprite:getTexture())
			self.rootNode:addChild(self.batchNode,1)
		end--]]
		--self.batchNode:addChild(self.quickSkill[i].heightLightSprite, 1)
	end
end

function MainAttackSkill:initNode()
	self.contentNode = CCLayer:create()
	self.contentNode:setContentSize(touchArea)	
	
	self.rootNode:addChild(self.contentNode)
	VisibleRect:relativePosition(self.contentNode,self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	--node   用于旋转
	self.node = CCLayer:create()
	self.node:setContentSize(touchArea)
	self.contentNode:addChild(self.node)
	VisibleRect:relativePosition(self.node,self.contentNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	self.node:setAnchorPoint(ccp(1, 0))
	--node1 第一页	
	self.node1 = CCLayer:create()
	self.node1:setContentSize(touchArea)
	self.node:addChild(self.node1)
	VisibleRect:relativePosition(self.node1, self.node, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	--node2 第二页	
	self.node2 = CCLayer:create()
	self.node2:setContentSize(touchArea)
	self.node2:setVisible(false)
	self.node:addChild(self.node2)
	VisibleRect:relativePosition(self.node2, self.node, LAYOUT_BOTTOM_INSIDE+LAYOUT_RIGHT_INSIDE)
	
	self:registerContentNodeTouchHandler(self.contentNode)
	self.contentNode:setTouchEnabled(true)
end

--注册并处理self.contentNode的点击事件
function MainAttackSkill:registerContentNodeTouchHandler(node)
	local function ccTouchHandler(eventType, x, y)
		if eventType == "began" then			
			local index = self:touchInBtnIndex(x, y)
			if index then
				self:useSkillByIndex(index)					
				self:setPressBtn(index)			
				self:clickBtn(index)		
			else
				self:setPressBtn(nil)	
				if self:isTouchInHandup(x, y) then
					self.onHandupClick()
				end
			end
			if self:isTouchInContentNode(x, y) then
				self.touchPoint.x = x
				self.touchPoint.y = y				
				return 1
			else
				self.touchPoint = ccp(-1, -1)
				if index then
					return 1
				else
					return 0
				end
			end
		elseif eventType == "moved" then			
		elseif eventType == "cancelled" then
			self:setPressBtn(nil)
		elseif eventType == "ended" then
			if x < self.touchPoint.x - distant and y < self.touchPoint.y - distant then
				self:runAsCicle(DOWNDIR)
			elseif x > self.touchPoint.x+distant and y > self.touchPoint.y+distant then
				self:runAsCicle(UPDIR)
			end
			self.touchPoint = ccp(-1, -1)
			self:setPressBtn(nil)
			return 1
		end			
		return 0
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, true)
end

function MainAttackSkill:isTouchInHandup(x, y)
	local point = self.rootNode:convertToNodeSpace(ccp(x, y))
	return self.switchHandup:boundingBox():containsPoint(point)
end

function MainAttackSkill:isTouchInContentNode(x, y)
	local parent = self.contentNode:getParent()
	if not parent then
		return false
	end			
	local point = parent:convertToNodeSpace(ccp(x, y))
	local rect = self.contentNode:boundingBox()
	if not rect:containsPoint(point) then
		return false
	end
	
	local rightButtom = ccp(rect:getMaxX(), rect:getMinY())	
--	print(rightButtom.x.." "..rightButtom.y)	
	if ccpDistance(rightButtom, point) <= self.range then
		return true
	else
		return false
	end
end

function MainAttackSkill:touchInBtnIndex(x, y)
	for k, v in pairs(self.quickSkill) do
		local obj = v.attackLayer
		if obj then			
			local point
			if k == attackIndex then
				point = self.rootNode:convertToNodeSpace(ccp(x, y))
			elseif k <= totalSkillCount/2 then
				point = self.node1:convertToNodeSpace(ccp(x, y))
			else
				point = self.node2:convertToNodeSpace(ccp(x, y))
			end				
			local rect = obj:boundingBox()
			if rect:containsPoint(point) then			
--				print("touchInBtnIndex="..k)
				return k
			end
		end
	end
	return nil
end

function MainAttackSkill:removeByIndex(index)
	if self.quickSkill[index].refId then 
		--删除progresstimer			
		self:removeProgressTimer(self.quickSkill[index].refId)						
		--删除图标
		self.quickSkill[index].attackLayer:removeChildByTag(index, true)
		self.quickSkill[index].refId = nil			
		--开关技能
		if self.quickSkill[index].switchSkillLabel then
			self.quickSkill[index].switchSkillLabel:removeFromParentAndCleanup(true)
			self.quickSkill[index].switchSkillLabel = nil
		end
	end
end

function MainAttackSkill:updateAttackSkill()
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	local markTable = skillMgr:getMarkList()
	local preMarkTable = skillMgr:getPreMarkList()	
			
	for index=1, totalSkillCount do 		
		self:removeByIndex(index)  --暂时解决扩展技能导致的cd不正确问题
	end
	
	for refId, v in pairs(markTable) do	
		skillRefId = G_getHero():getEquipSkill(refId)
		local index = v.index
		self.quickSkill[index].refId = skillRefId
		local skillObject = skillMgr:getSkillObjectByRefId(skillRefId)			
		if skillObject then
			local iconId = PropertyDictionary:get_iconId(skillObject:getStaticData())
			if iconId ~= nil then
				local sprite = createSpriteWithFileName(ICON(iconId))
				sprite:setTag(index)
				if index > 0 and index < totalSkillCount+1 then													
					self.quickSkill[index].attackLayer:addChild(sprite)
					VisibleRect:relativePosition(sprite, self.quickSkill[index].attackLayer, LAYOUT_CENTER)	
					
					local proTimer = self:getProgressTimer(skillRefId)
					if proTimer and proTimer:getParent() ==nil then 
						proTimer:setVisible(false)
						self.quickSkill[index].attackLayer:addChild(proTimer, CD_Sprite_Z_Order)							
						VisibleRect:relativePosition(proTimer, self.quickSkill[index].attackLayer, LAYOUT_CENTER)							
					end																			
				end																
			end
			--快关技能显示	
			self:setSwitchSkill(index)
		end				
	end
			
	self:setSkillGray()	
end

function MainAttackSkill:setSwitchSkill(index)
	if self.quickSkill[index].switchSkillLabel then
		self.quickSkill[index].switchSkillLabel:removeFromParentAndCleanup(true)
		self.quickSkill[index].switchSkillLabel = nil
	end
	
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	local skillRefId = skillMgr:getQuickSkillRefIdByIndex(index)
	local skillObject = skillMgr:getSkillObjectByRefId(skillRefId)
	if PropertyDictionary:get_skillType(skillObject:getStaticData()) == SkillType.SwitchSkill then	
		local text = ""
		if skillObject:getSwitchStatus() then
			text = Config.Words[2001]
		else
			text = Config.Words[2000]
		end
		self.quickSkill[index].switchSkillLabel = createLabelWithStringFontSizeColorAndDimension(text, "Arial", 20, FCOLOR("ColorWhite2"))
		self.quickSkill[index].attackLayer:addChild(self.quickSkill[index].switchSkillLabel, CD_Sprite_Z_Order+1)
		VisibleRect:relativePosition(self.quickSkill[index].switchSkillLabel, self.quickSkill[index].attackLayer, LAYOUT_CENTER)
	end
end

function MainAttackSkill:getRootNode()
	return self.rootNode
end

function MainAttackSkill:addHandupBtn()	
	self.switchHandup = createSpriteWithFrameName(RES("main_mapHandup.png"))				

	local hightLight = createSpriteWithFrameName(RES("main_mapSelectHighLight.png"))
	self.switchHandup:addChild(hightLight)
	--self.batchNode:addChild(hightLight, 1)
	VisibleRect:relativePosition(hightLight, self.switchHandup, LAYOUT_CENTER, ccp(18,-19))
	self.rootNode:addChild(self.switchHandup, 1)
	--self.batchNode:addChild(self.switchHandup, 1)
	VisibleRect:relativePosition(self.switchHandup, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, ccp(0, 20))			
	
	local isHandup = false
	self.onHandupClick = function()
		if isHandup then
			GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
		else	--TODO: 需要根据当前状态，选择不同的挂机模式	
			local isInMiningMap = GameWorld.Instance:getMiningMgr():isInMiningMap()
			if isInMiningMap == true then	--在采矿界面时，采用挂机采集模式
				local canCollect = GameWorld.Instance:getMiningMgr():canCollect()
				if canCollect == true then
					G_getHandupMgr():start(E_AutoSelectTargetMode.Collect, {EntityType.EntityType_NPC}, {"npc_collect_4","npc_collect_5","npc_collect_6"}, nil, nil, E_SearchTargetMode.Random)
				else
					UIManager.Instance:showSystemTips(Config.Words[19012])
				end
			elseif G_getCastleWarMgr():isInCastleWar() then	--正在沙巴克攻城时，使用挂机沙巴克模式(打EntityType_Monster优先)
				G_getHandupMgr():start(E_AutoSelectTargetMode.CastleWar, {EntityType.EntityType_Monster, EntityType.EntityType_Player}, {}, nil, nil, E_SearchTargetMode.Random)
			elseif GameWorld.Instance:getGameInstanceManager():isInIns_PK() then
				UIManager.Instance:showSystemTips(Config.Words[476])
			else
				G_getHandupMgr():start(E_AutoSelectTargetMode.Normal, {EntityType.EntityType_Monster}, {}, nil, nil, E_SearchTargetMode.Random)
			end					
		end
	end
	
	local onSwitchHandupState = function(enable)
		isHandup = enable			
		hightLight:setVisible(enable)			
	end
	self.handupEvent = GlobalEventSystem:Bind(GameEvent.EventHandupStateChanged, onSwitchHandupState)
	onSwitchHandupState(false)		
end

function MainAttackSkill:showView()
	--普通攻击	
	self.mainAttackSprite = createSpriteWithFrameName(RES("main_attack.png"))
	local mainAttackSize = self.mainAttackSprite:getContentSize()
	self.mainAttackSprite:setTag(attackIndex)
	self.quickSkill[attackIndex].attackLayer = CCLayer:create()
	self.quickSkill[attackIndex].attackLayer:setTouchEnabled(true)
	self.quickSkill[attackIndex].attackLayer:setContentSize(CCSizeMake(mainAttackSize.width - 40, mainAttackSize.height - 40))
	self.quickSkill[attackIndex].attackLayer:addChild(self.mainAttackSprite)
	VisibleRect:relativePosition(self.mainAttackSprite, self.quickSkill[attackIndex].attackLayer, LAYOUT_CENTER)
			
	self.mainAttackSprite:addChild(self.quickSkill[attackIndex].heightLightSprite, CD_Sprite_Z_Order+1)
	VisibleRect:relativePosition(self.quickSkill[attackIndex].heightLightSprite,self.mainAttackSprite, LAYOUT_CENTER)
	
	local pugong_ProTimer = self:getProgressTimer(const_skill_pugong)
	self.quickSkill[attackIndex].attackLayer:addChild(pugong_ProTimer)
	VisibleRect:relativePosition(pugong_ProTimer, self.quickSkill[attackIndex].attackLayer, LAYOUT_CENTER)
			
	self.rootNode:addChild(self.quickSkill[attackIndex].attackLayer)
	VisibleRect:relativePosition(self.quickSkill[attackIndex].attackLayer, self.rootNode, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, CCPointMake(-44, 53))		
			
	--8个技能槽
	for i = 1, totalSkillCount do	
		self.quickSkill[i].attackLayer = createSpriteWithFrameName(RES("main_skillframe.png"))				
		--高亮
		self.quickSkill[i].attackLayer:addChild(self.quickSkill[i].heightLightSprite, CD_Sprite_Z_Order+1)
		VisibleRect:relativePosition(self.quickSkill[i].heightLightSprite, self.quickSkill[i].attackLayer, LAYOUT_CENTER)
		
		if i <= totalSkillCount/2 then
			self.node1:addChild(self.quickSkill[i].attackLayer)
		else
			self.node2:addChild(self.quickSkill[i].attackLayer)
		end
	end
	
	for i = 1, 4 do 
		local pos = SkillUtils.Instance:getSkillSoltPos(i)
		--local tmp
		pos.x = pos.x - 30
		pos.y = pos.y + 30 --主界面的技能槽要提高20
		VisibleRect:relativePosition(self.quickSkill[i].attackLayer, self.node1, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, pos)
		VisibleRect:relativePosition(self.quickSkill[i+4].attackLayer, self.node2, LAYOUT_BOTTOM_INSIDE + LAYOUT_RIGHT_INSIDE, pos)
	end		 

	SkillUtils.Instance:createArrowNode(self.node1, 1)
	SkillUtils.Instance:createArrowNode(self.node2, 2)	
		
	self.range = self:getRange()	
	self.node2:setAnchorPoint(ccp(1, 0))
	self.node2:setRotation(90)
	
	self:addHandupBtn()
end	

--根据按键index，使用对应的技能
--bIgnoreSwitchSkillL：为true，且index对应的技能为开关技能，则不使用
function MainAttackSkill:useSkillByIndex(index, bIgnoreSwitchSkill)
	self:runScaleAction(index)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local skillMgr = hero:getSkillMgr()
	local useSkillRefId
	
	if index == attackIndex then
		useSkillRefId = "skill_0"
	else
		useSkillRefId = skillMgr:getQuickSkillRefIdByIndex(index)	
	end
		
	local skillObject = skillMgr:getSkillObjectByRefId(useSkillRefId)		
	if skillObject then			
		if skillObject:isSwitchSkill() and 	bIgnoreSwitchSkill then
			return
		end					
		if PropertyDictionary:get_skillType(skillObject:getStaticData()) == 3 then
			local status = skillObject:getSwitchStatus()
			status = not status
			skillObject:setSwitchStatus(status)
			skillMgr:resetReplaceSkillSwitch(useSkillRefId,status)
			self:setSwitchSkill(index)   --设置开关技能	
		else
			local canUse, object, reason = hero:canUseSkill(useSkillRefId)
			if canUse then
				local rockMgr = GameWorld.Instance:getJoyRockerManager()				
				if rockMgr:isRocking() then
--					CCLuaLog("rockMgr:isRocking")
					--Juchao@20140508: 如果摇杆正在摇晃中，则原地使用技能，不根据技能的攻击范围和英雄与目标之间的距离而自动跑
					hero:useSkillWithCheck(useSkillRefId, false, false)
				else
					hero:useSkillWithCheck(useSkillRefId, true, false)
				end
			else
				if reason and reason == CannotUseSkillReason.targetError then
					local msg = {}
					table.insert(msg,{word = Config.Words[2027], color = Config.FontColor["ColorRed3"]})
					UIManager.Instance:showSystemTips(msg)
				end
				if PropertyDictionary:get_MP(hero:getPT()) < skillObject:getMp() then
					local msg = {}
					table.insert(msg,{word = Config.Words[2509], color = Config.FontColor["ColorRed1"]})
					UIManager.Instance:showSystemTips(msg)
				end				
			end
		end
	end			
end					

function MainAttackSkill:getRange()
	return touchArea.width + 50 * const_scale
end

function MainAttackSkill:createEffectAction(scale, index)
	local array = CCArray:create()
	--local fadeIn = CCFadeIn:create(0.1)
	local blink = CCBlink:create(0.6, 3)
	local scaleAction = nil	
	local fadeTo = CCFadeTo:create(0.2, 200)
	local fadeOut = CCFadeOut:create(0.08)
	local scaleBy = CCScaleBy:create(0.1, 1.15)
	
	local subArray = CCArray:create()
	subArray:addObject(fadeTo)
	subArray:addObject(blink)
	local changeSpeedeAction = nil
	if index==1 then
		scaleAction = CCScaleBy:create(0.6, scale)
		changeSpeedeAction = CCEaseInOut:create(scaleAction, 2)
	elseif index==2 then
		scaleAction = CCScaleBy:create(0.5, scale)
		array:addObject(CCDelayTime:create(0.1))
		changeSpeedeAction = CCEaseInOut:create(scaleAction,2.5)
	elseif index==3 then
		scaleAction = CCScaleBy:create(0.4, scale)
		array:addObject(CCDelayTime:create(0.2))
		changeSpeedeAction = CCEaseInOut:create(scaleAction, 3)
	end
	
	subArray:addObject(changeSpeedeAction)
	local spawn = CCSpawn:create(subArray)	
	--array:addObject(fadeIn)
	array:addObject(spawn)
	local spawn2 = CCSpawn:createWithTwoActions(fadeOut, scaleBy)
	--array:addObject(fadeOut)
	array:addObject(spawn2)
	local sequence = CCSequence:create(array)
	return sequence
end

function MainAttackSkill:runScaleAction(index)
	local size = 3
	local sequence = {}
	for i=1, size do
		sequence[i] = self:createEffectAction(2.0-0.25*i, i)
	end
	local node = nil
	if index>=1 and index <= 4 then
		node = self.node1
	elseif index>4 and index <= totalSkillCount then
		node = self.node2
	else
		node = self.rootNode
	end
	
	if not node:getChildByTag(index*tag+1) then
		for i=1, size do
			local sprite = createSpriteWithFrameName(RES("skill_useEffect.png"))
			node:addChild(sprite, -1, index*tag+i)
			if index == attackIndex then
				VisibleRect:relativePosition(sprite, self.quickSkill[index].attackLayer, LAYOUT_CENTER, ccp(1, 7))
			else
				VisibleRect:relativePosition(sprite, self.quickSkill[index].attackLayer, LAYOUT_CENTER, ccp(-1, 1))
			end				
			sprite:setOpacity(0)
		end							
	end
	
	if not (index >= 1 and index <= totalSkillCount) then	
		index = attackIndex
	end
	
	for i=1, size do
		local actionTarget = node:getChildByTag(index*tag+i)
		if actionTarget then
			actionTarget = tolua.cast(actionTarget, "CCSprite")
			actionTarget:stopAllActions()
			if index == attackIndex then
				actionTarget:setScale(1.4)
			else
				actionTarget:setScale(0.95)
			end				
			actionTarget:setOpacity(0)
			actionTarget:runAction(sequence[i])
		end	
	end			
end

function MainAttackSkill:registerTouchHandlerWithNode(node, argIndex, callBackFunc, bSwallows)
	local function ccTouchHandler(eventType, x, y)
		if node:isVisible() and node:getParent() then
			local parent = node:getParent()
			local point = parent:convertToNodeSpace(ccp(x,y))

			local rect = node:boundingBox()
			if rect:containsPoint(point) then
				if eventType == "began" then
					callBackFunc(argIndex)							
				end
				return 1
			else
				return 0
			end
		else
			return 0
		end
	end
	if bSwallows == nil then
		bSwallows = false
	end
	node:registerScriptTouchHandler(ccTouchHandler, false, UIPriority.Control, bSwallows)
end

function MainAttackSkill:runAsCicle(dir)
	if self.node:getActionByTag(UPDIR) or self.node:getActionByTag(DOWNDIR) then 
		return
	end		
	local actionArray = CCArray:create()	
	self.node1:setVisible(true)
	self.node2:setVisible(true)
	if dir == UPDIR then
		if self.curShowPage == PAGE2 then
			self.node:setRotation(-90)
			local rotateBy = CCRotateBy:create(0.3, 95)
			local bounce = CCEaseBounceInOut:create(rotateBy)
			local rotateBack = CCRotateBy:create(0.1, -5)
			local callbackFunc = function()
				self.node2:setVisible(false)
			end	
			actionArray:addObject(bounce)
			actionArray:addObject(rotateBack)
			actionArray:addObject(CCCallFuncN:create(callbackFunc))

			local actions = CCSequence:create(actionArray)
			actions:setTag(dir)
			self.node:runAction(actions)			
			self.curShowPage = PAGE1
		end
	else
		if self.curShowPage == PAGE1 then
			self.node:setRotation(0)
			local rotateBy = CCRotateBy:create(0.3, -95)
			local bounce = CCEaseBounceInOut:create(rotateBy)
			local rotateBack = CCRotateBy:create(0.1, 5)
			local bounce = CCEaseBounceOut:create(rotateBy)
			local callbackFunc = function()
				self.node1:setVisible(false)
			end	
			actionArray:addObject(bounce)
			actionArray:addObject(rotateBack)
			actionArray:addObject(CCCallFuncN:create(callbackFunc))
			local actions = CCSequence:create(actionArray)
			actions:setTag(dir)
			self.node:runAction(actions)			
			self.curShowPage = PAGE2
		end						
	end				
end

function MainAttackSkill:setViewHide()
	self.isAttackSkillShow = false
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(visibleSize.width/3,-visibleSize.height/3))
	local moveFunc = function ()	
		if self.isAttackSkillShow == false then				
			self.contentNode:setVisible(false)
		end	
		self.isShow = false
	end			
	local ccfunc = CCCallFunc:create(moveFunc)
	local sequence = CCSequence:createWithTwoActions(moveBy,ccfunc)
	self.rootNode:runAction(sequence)
	--self.contentNode:setVisible(false)

end

function MainAttackSkill:setViewShow()
	--self.rootNode:stopAllActions()
	self.isAttackSkillShow = true
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(-visibleSize.width/3,visibleSize.height/3))
	local moveFunc = function ()		
		self.isShow = true
	end	
	self.contentNode:setVisible(true)
	local ccfunc = CCCallFunc:create(moveFunc)
	local sequence = CCSequence:createWithTwoActions(moveBy,ccfunc)
	self.rootNode:runAction(sequence)
end

--技能的cd时间
--to do.here can be fastest
function MainAttackSkill:showSkillCD(index, time)
	local skillMgr = G_getHero():getSkillMgr()	
	local skillRefId = ""
	if index ~= attackIndex then
		local refId = skillMgr:getQuickSkillRefIdByIndex(index)
		skillRefId = G_getHero():getEquipSkill(refId)		
	else
		skillRefId = const_skill_pugong	
	end
	local proTimer = self:getProgressTimer(skillRefId)	
	if proTimer == nil then 
		return
	end					
	
	--如果正在cd直接返回
	--现在progressTimer里面只有一个action所以可以这样子判断	
	if proTimer:numberOfRunningActions() > 0 then 
		return
	end
	proTimer:setVisible(true)		
		
	local object = self.quickSkill[index].attackLayer:getChildByTag(index)
	if object ~= nil then
		object = tolua.cast(object,"CCSprite")
		object:setColor(ccc3(70, 70, 70))		
	end							
	
	local actions = self:getProTimerAction(skillRefId, time)			
	if actions then 	
		--proTimer:stopAction(actions)
		proTimer:runAction(actions)
	end
	
	self.quickSkill[index].heightLightSprite:setVisible(false)	
end

--对Progresstimer做缓存，如果存在直接返回
function MainAttackSkill:getProgressTimer(refId)
	if self.cdProgressTimer[refId]==nil then 		
		local sprite = self:getProgressTimerSprite(refId)
		if sprite then 
			--创建progressTimer
			local proTimer = CCProgressTimer:create(sprite)
			proTimer:retain()
			proTimer:setType(kCCProgressTimerTypeRadial)
			proTimer:setPercentage(100)
			self.cdProgressTimer[refId] = proTimer			
		end			
	end
	return self.cdProgressTimer[refId]
end

--创建action
function MainAttackSkill:getProTimerAction(refId, time)
	if refId and time then 
		if self.proTimerAction[refId..time]==nil then
			local progressTimerCB = function ()		
				local proTimer = self:getProgressTimer(refId)
				proTimer:setVisible(false)
				local index = attackIndex
				for k, v in pairs(self.quickSkill) do 				
					if v.refId == refId then 
						index = k
						break
					end
				end					
				local object = self.quickSkill[index].attackLayer:getChildByTag(index)
				if object then 
					if refId==const_skill_pugong or self:isMpEnough(refId) then 
						object = tolua.cast(object,"CCSprite")
						object:setColor(ccc3(255, 255, 255))
					end
				end
				self.quickSkill[index].heightLightSprite:setVisible(true)		
			end
			local ccfunc = CCCallFuncN:create(progressTimerCB)
			local progressTo = CCProgressTo:create(time, 100)
			local sequence = CCSequence:createWithTwoActions(progressTo,ccfunc)			
			sequence:retain()
			self.proTimerAction[refId..time] = sequence			
		end
		return self.proTimerAction[refId..time]
	end
end

function MainAttackSkill:removeProgressTimer(refId)
	if refId then 	
		local proTimer = self.cdProgressTimer[refId]
		if proTimer and proTimer:getParent() then 
			proTimer:removeFromParentAndCleanup(true)
		end
	end
end

--刷新特定技能的CD时间
function MainAttackSkill:refreshSkillCD(skillRefId, time)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local skillMgr = hero:getSkillMgr()
	local markList = skillMgr:getMarkList()
	local refreshIndex = 0
	local orgRefId = skillMgr:getOrginalRefId(skillRefId)
	--刷特定技能cd	
	if skillRefId and (markList[skillRefId] or markList[orgRefId])then 
		local refreshRefId = skillRefId
		if markList[skillRefId]==nil then 
			refreshRefId = orgRefId
		end
		local skillObj = skillMgr:getSkillObjectByRefId(skillRefId)		
		if skillObj then 
			refreshIndex = markList[refreshRefId]["index"]					
			self:showSkillCD(refreshIndex, skillObj:getSkillCD())	
		end	
	end
	--刷公共cd
	local startCount = 1
	local endCount = totalSkillCount/2
	if self.curShowPage == PAGE2 then	
		startCount = totalSkillCount/2 +1
		endCount = totalSkillCount
	end
	for i=startCount, endCount do	
		if i~=refreshIndex then 
			self:showSkillCD(i, time)	
		end	
	end
	--普工cd
	self:showSkillCD(totalSkillCount+1, 0.6)  
end	

function MainAttackSkill:getProgressTimerSprite(refId)
	local skillMgr = G_getHero():getSkillMgr()
	local sprite = nil
	if refId == const_skill_pugong then 
		sprite = createSpriteWithFrameName(RES("main_attack.png"))
	else		
		local skillObject = skillMgr:getSkillObjectByRefId(refId)
		if skillObject then 
			local iconName = PropertyDictionary:get_iconId(skillObject:getStaticData())
			sprite = createSpriteWithFileName(ICON(iconName))
		end
	end
	return sprite	
end	

function MainAttackSkill:updateSwitchSkill(index)
	self:setSwitchSkill(index)
end	

function MainAttackSkill:setSkillGray()
	local skillMgr = GameWorld.Instance:getSkillMgr()
	local markTable = skillMgr:getMarkList()
	for refId, value in pairs(markTable) do			
		local object = self.quickSkill[value.index].attackLayer:getChildByTag(value.index)
		object = tolua.cast(object,"CCSprite")
		if object ~= nil then
			local refId = G_getHero():getEquipSkill(refId)
			local bMpEnough = self:isMpEnough(refId)
			if bMpEnough==false then  --不够蓝，禁用技能	
				object:setColor(ccc3(70, 70, 70))
			elseif self.cdProgressTimer[refId] and self.cdProgressTimer[refId]:isVisible()==false then				
				object:setColor(ccc3(255, 255, 255))			
			end
		end
	end		
end	

--是否足够魔法
function MainAttackSkill:isMpEnough(refId)
	local skillMgr = GameWorld.Instance:getSkillMgr()
	local skill = skillMgr:getSkillObjectByRefId(refId)
	local curLv = PropertyDictionary:get_level(skill:getPT())
	local lvProperty = skill:getSkillLevelPropertyTable(curLv)
	if lvProperty then 
		local needMp = PropertyDictionary:get_MP(lvProperty)
		local curHeroMp = PropertyDictionary:get_MP(G_getHero():getPT())
		if curHeroMp >= needMp then
			return true
		else
			return false
		end
	end
	return true
end

function MainAttackSkill:getIsShow()
	return self.isShow
end

--创建自动装备技能的动画
function MainAttackSkill:showAutoSkillAmi(refId, index)
	local skillMgr = G_getHero():getSkillMgr()
	local skillObj = skillMgr:getSkillObjectByRefId(refId)
	if skillObj then 
		local icon = PropertyDictionary:get_iconId(skillObj:getStaticData())
		if icon then 
			local sprite = createSpriteWithFileName(ICON(icon))
			if sprite then 
				local amiNode = CCNode:create()	
				amiNode:setVisible(false)
				local actionArray = CCArray:create()
				local delayAction = nil
				if self:getIsShow()==false then 
					GlobalEventSystem:Fire(GameEvent.EventMoveMianView)
					delayAction = CCDelayTime:create(0.5)
				else
					delayAction = CCDelayTime:create(0)
				end
				actionArray:addObject(delayAction)
				
				local size = sprite:getContentSize()			
				amiNode:setContentSize(size)
				amiNode:addChild(sprite)
				VisibleRect:relativePosition(sprite, amiNode, LAYOUT_CENTER)
				
				--这里没有考虑添加到第二页的情况
				self:runAsCicle(UPDIR)		
				self.node1:addChild(amiNode)			
				
				local offsetX = visibleSize.width/2 - touchArea.width
				local offsetY = visibleSize.height/2 - touchArea.height
				VisibleRect:relativePosition(amiNode, self.node, LAYOUT_TOP_OUTSIDE+LAYOUT_LEFT_OUTSIDE, ccp(-offsetX, offsetY))
				local x, y = self.quickSkill[index].attackLayer:getPosition()	
				
				local px, py = amiNode:getPosition()
				local distance = ccpDistance(ccp(px, py), ccp(x, y))				
				
				local config = ccBezierConfig()
				config.endPosition = ccp(x+10, y+15)
				config.controlPoint_1 = ccp(px+distance*0.25,(py+15))
				config.controlPoint_2 = ccp(px+distance/2 ,(py+15))
					
				local show = function ()
					amiNode:setVisible(true)
				end
				local showaction = CCCallFuncN:create(show)
				--local moveto = CCMoveTo:create(1, ccp(x+10, y+15)) 			
				local easeOut = CCEaseOut:create(CCBezierTo:create(1, config), 4)			
				local deleteMyself = function ()
					if amiNode then 
						amiNode:removeFromParentAndCleanup(true)
						amiNode = nil
					end
				end
				local ccfunc = CCCallFuncN:create(deleteMyself)
				actionArray:addObject(showaction)
				actionArray:addObject(easeOut)
				actionArray:addObject(ccfunc)
				local sequence = CCSequence:create(actionArray)		
				amiNode:runAction(sequence)
			end
		end
	end		
end

function MainAttackSkill:setCanHandup(bCan)
	if self.switchHandup then
		if bCan then
			UIControl:SpriteSetColor(self.switchHandup)
		else
			UIControl:SpriteSetGray(self.switchHandup)
		end
	end
end

function MainAttackSkill:getAttackBtn()
	return	self.mainAttackSprite
end

function MainAttackSkill:clickBtn(index)
	if index==9 then
		GlobalEventSystem:Fire(GameEvent.EventDoNewGuidelinesByCilck,"MainAttackSkill","attackBtn")	
	end
end
