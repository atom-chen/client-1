--[[
��ս����Ϊ��entityObject
]]--
require ("object.entity.CharacterObject")
require ("object.entity.GameState")
require ("object.entity.CharacterState")
require ("object.entity.FightStateEffect")
require("object.skillShow.player.MapAnimatePlayer")
require("object.skillShow.SkillShowManager")
require("object.mainHeroState.HeroStateDef")

FightCharacterObject = FightCharacterObject or BaseClass(CharacterObject)
local const_scale = VisibleRect:SFGetScale()

function FightCharacterObject:__init()
	self.move = SpriteMove:create()
	self.move:retain()
	self.moving = false
	
	--�����ɫ���ϵ���Ч
	self.effectList = {}
	
	--�������ϵ���ЧID�ļ���
	self.effectCountList = {}
	
	-- ��ɫ״̬
	self.state = GameState.New()
	
	-- �ܻ�, ����, ���˵�ccAction
	self.ccAction = nil
	
	--ccAction�Ļص�
	self.ccActionCallback = nil
	
	-- renderSprite action�л��Ļص�
	self.actionCallback = nil
	
	-- ��ɫ��״̬�л��Ļص��б�
	self.stateChangeCallbackList = {}
	
	self.targetX = 0
	self.targetY = 0
	self.moveLenght = 0
	self.showingPathPoint = {}
	self:initStateFun()
	self.stateTable = {}
	-- ������������͹�����move��moveStop, targetX��targetYֻ�ǵ�ǰ�ƶ���Ŀ���, ��moveTarget���ܻ᲻ͬ
	self.moveTargetX = 0
	self.moveTargetY = 0
	
	self.currentTargetX = 0
	self.currentTargetY = 0
end

function FightCharacterObject:__delete()
	if self.move then
		self.move:release()
		self.move = nil
	end
	
	if self.actionCallback then
		self:actionCallbackFunc(actionId, CharacterMovement.Cancel)
	end
	
	-- ����Ƿ���ccation
	self:exitBeHit()
	self:exitHitFly()
	
	self:clearEffect()
	
	if self.state then
		self.state:DeleteMe()
		self.state = nil
	end
	
	self.moving = false
end

function FightCharacterObject:clearEffect()
	for k,v in pairs(self.effectList) do
		if self.renderSprite then
			self.renderSprite:removeChild(v, true)
		end
		v:release()
		self.effectList[k] = nil
	end
end

function FightCharacterObject:initStateFun()
	-- תΪ����
	function idle_enter_fun()
		-- �ɷ�״̬�л��¼�
		self:nofityStateChange(CharacterState.CharacterStateIdle, true)
		return self:enterStateIdle()
	end
	
	function idle_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateIdle, false)
	end
	
	-- תΪ�ƶ�
	function move_enter_fun(cellX, cellY)
		self:nofityStateChange(CharacterState.CharacterStateMove, true)
		return self:enterStateMove(cellX, cellY)
	end
	
	function move_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateMove, false)
		self:exitStateMove(newState)
	end
	
	-- תΪ���ܹ���
	function userSkill_enter_fun(actionId, callback)
		self:nofityStateChange(CharacterState.CharacterStateUseSkill, true)
		return self:enterStateUseSkill(actionId, callback)
	end
	
	function userSkill_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateUseSkill, false)
		self.state:setIsLock(false)
	end
	
	-- תΪ�ܻ�״̬
	function beHit_enter_fun(callback)
		self:nofityStateChange(CharacterState.CharacterStateHit, true)
		return self:enterBeHit(callback)
	end
	
	function beHit_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateHit, false)
		return self:exitBeHit()
	end
	
	-- ����״̬
	function hitFly_enter_fun(cellX, cellY, callback)
		self:nofityStateChange(CharacterState.CharacterStateHitFly, true)
		return self:enterHitFly(cellX, cellY, callback)
	end
	
	function hitFly_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateHitFly, false)
		return self:exitHitFly()
	end
	
	-- ����
	function hitBack_enter_fun(cellX, cellY, callback)
		self:nofityStateChange(CharacterState.CharacterStateHitBack, true)
		return self:enterHitBack(cellX, cellY, callback)
	end
	
	function hitBack_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateHitBack, false)
		return self:exitHitBack()
	end
	
	-- ���״̬�Ļص�
	function combo_state_fun(state, bEnter)
		self:comboStateCallback(state, bEnter)
	end
	
	-- ����״̬
	function death_enter_fun(effectId)
		self:nofityStateChange(CharacterState.CharacterStateDead, true)
		return self:enterDeath(effectId)
	end
	
	function death_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateDead, false)
		return self:exitDeath()
	end
	
	function willDeath_enter_func()
		self:nofityStateChange(CharacterState.CharacterStateWillDead, true)
		return self:enterWillDeath()
	end
	
	function willDeath_exit_func(newState)
		self:nofityStateChange(CharacterState.CharacterStateWillDead, false)
	end
	
	-- ����״̬�Ļص�
	self.state:setStateCallback(CharacterState.CharacterStateIdle, idle_enter_fun, idle_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateMove, move_enter_fun, move_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateUseSkill, userSkill_enter_fun, userSkill_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateHit, beHit_enter_fun, beHit_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateHitFly, hitFly_enter_fun, hitFly_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateHitBack, hitBack_enter_fun, hitBack_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateDead, death_enter_fun, death_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateWillDead, willDeath_enter_func, willDeath_exit_func)
	self.state:setComboStateCallback(combo_state_fun)
end

--[[
״̬�л���֪ͨ����غ���
]]
function FightCharacterObject:addStateChangeCallback(func)
	if func then
		table.insert(self.stateChangeCallbackList, func)
	end
end

function FightCharacterObject:removeStateChangeCallback(func)
	if func then
		for k,v in pairs(self.stateChangeCallbackList) do
			if v == func then
				self.stateChangeCallbackList[k] = nil
				break
			end
		end
	end
end

function FightCharacterObject:nofityStateChange(stateName, bEnter)
	if self.stateChangeCallbackList then
		for k,v in pairs(self.stateChangeCallbackList) do
			if v then
				v(stateName, bEnter)
			end
		end
	end
end

--[[
״̬���Ļص�����
]]
function FightCharacterObject:getState()
	return self.state
end

-- �л�idle״̬�Ļص�
function FightCharacterObject:enterStateIdle()
	-- �����idle����ҵ�actionId��ͬ
	if self.hasMount then
		self:mountDown()
	end
	if self.type == EntityType.EntityType_Monster then
		self:changeAction(EntityAction.eEntityAction_Monster_Idle, true)
	else
		self:changeAction(EntityAction.eEntityAction_Idle, true)
	end
	
	return true
end

-- �л��ƶ�״̬�Ļص�
function FightCharacterObject:enterStateMove(cellX, cellY)
	if cellX and cellY then
		local ret = self:fightCharacterMoveTo(cellX, cellY)
		if ret == true then
			self:changeAction(EntityAction.eEntityAction_Run,true)
		else
			debugPrint("FightCharacterObject enterStateMove, moveTo failed")
		end
		
		return ret
	else
		self:changeAction(EntityAction.eEntityAction_Run,true)
		return true
	end
end

function FightCharacterObject:exitStateMove(newState)
	-- �����״̬����RideMove, ��Ӧ��Ҫͣ���ƶ�
	if newState ~= CharacterState.CharacterStateRideMove then
		self:fightCharacterMoveStop()
	end
end

-- �л�����ʹ��״̬�Ļص�
function FightCharacterObject:enterStateUseSkill(actionId, callback)
	if self.hasMount then
		self:mountDown()
	end
	-- ������״̬������
	self.state:setIsLock(true)
	self:changeAction(actionId, false, callback)
	
	return true
end

-- �л�Ϊ�ܻ�״̬
function FightCharacterObject:enterBeHit(callback)
	if self.renderSprite == nil then
		return false
	end
	
	self.currentTargetX, self.currentTargetY = self:getCellXY()
	
	local finishCallback = function ()
		local hitBackCallback = self.ccActionCallback
		self.ccActionCallback = nil
		self:setCellXY(self.currentTargetX, self.currentTargetY)
		if self.state then
			self.state:setIsLock(false)
		end
		if self.ccAction then
			self.ccAction:release()
			self.ccAction = nil
		end
		if hitBackCallback then
			hitBackCallback()
		end
	end
	
	self.ccActionCallback = callback
	self:changeAction(EntityAction.eEntityAction_Hit, true)
	
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(0.05, ccp(-5, -5)))
	actionArray:addObject(CCMoveBy:create(0.1, ccp(10, 10)))
	actionArray:addObject(CCMoveBy:create(0.05, ccp(-5, -5)))
	actionArray:addObject(CCCallFunc:create(finishCallback))
	
	self.ccAction = CCSequence:create(actionArray)
	self.ccAction:retain()
	self:getRenderSprite():runAction(self.ccAction)
	
	return true
end

function FightCharacterObject:exitBeHit()
	if self.ccAction and self:getRenderSprite() then
		self:setCellXY(self.currentTargetX, self.currentTargetY)
		self:releaseMoveAction()
	end
end

function FightCharacterObject:showHitFly(destMapX, destMapY, time, callback)
	function finishCallback()
		local flyCallBack = self.ccActionCallback
		self.ccActionCallback = nil
		if self.state then
			self.state:setIsLock(false)
		end			
		
		if self.ccAction then
			self.ccAction:release()
			self.ccAction = nil
		end
		
		if flyCallBack then
			flyCallBack()
		end
	end
	
	self.ccActionCallback = callback
	self:changeAction(EntityAction.eEntityAction_Hit, false)
	if self.state then
		self.state:setIsLock(true)
	end	
	local flyTime = 0.5
	if time then
		flyTime = time
	end
	
	local srcMapX, srcMapY = self:getMapXY()
	
	-- ���x������ͬ, ��CCMoveTo, �����ͬ������һ������������
	local action = nil
	if srcMapX == destMapX then
		action = CCMoveTo:create(flyTime, ccp(destMapX, destMapY))
	else
		local angle = 0
		if srcMapX > destMapX then
			angle = 0.785
		else
			angle = 5.495
		end
		
		local ptSrc = ccp(srcMapX, srcMapY)
		local ptDest = ccp(destMapX, destMapY)
		local rotatePt = ccpRotateByAngle(ptDest, ptSrc, angle)
		rotatePt = ccpNormalize(ccpSub(rotatePt, ptSrc))
		local distance = ccpDistance(ptSrc, ptDest)
		rotatePt = ccpAdd(ccpMult(rotatePt, distance*0.707), ptSrc)
		
		local config = ccBezierConfig()
		config.endPosition = ptDest
		config.controlPoint_1 = rotatePt
		config.controlPoint_2 = rotatePt
		
		action = CCBezierTo:create(flyTime, config)
	end
	
	local actionArray = CCArray:create()
	actionArray:addObject(CCEaseExponentialOut:create(action))
	actionArray:addObject(CCCallFunc:create(finishCallback))
	
	self.ccAction = CCSequence:create(actionArray)
	self.ccAction:retain()	
			
	-- �ƶ�ģ��
	if self:getRenderSprite() then
		self:getRenderSprite():runAction(self.ccAction)
	end
	-- �ƶ���Ӱ
	if  self:getShadow() then
		self:getShadow():runAction(CCEaseExponentialOut:create(CCMoveTo:create(flyTime, ccp(destMapX, destMapY))))
	end
end

function FightCharacterObject:enterHitFly(cellX, cellY, callback)
	local destMapX, destMapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	self:showHitFly(destMapX, destMapY, 0.5, callback)
	return true
end

function FightCharacterObject:releaseMoveAction()
	if self.ccAction and self:getRenderSprite() then
		self:getRenderSprite():stopAction(self.ccAction)
		self:getShadow():stopAllActions()
		
		self.ccAction:release()
		self.ccAction = nil
		if self.state then
			self.state:setIsLock(false)
		end
	end
	
	if self.ccActionCallback then
		local callback = self.ccActionCallback
		self.ccActionCallback = nil
		callback()
	end
end

function FightCharacterObject:exitHitFly()
	local id = self:getId()
	if id then
		local x,y = self:getMapXY()
		self:setMapXY(x,y)	
	end	
	local textMgr = GameWorld.Instance:getTextManager()
	if textMgr:hasTitle(id) then
		self:setTitleVisible(true)
	end		
	self:releaseMoveAction()
end

function FightCharacterObject:enterHitBack(cellX, cellY, callback)
	
	function finishCallback()
		local hitBackCallback = self.ccActionCallback
		self.ccActionCallback = nil
		if self.state then
			self.state:setIsLock(false)
		end
		if self.ccAction then
			self.ccAction:release()
			self.ccAction = nil
		end
		
		if hitBackCallback then
			hitBackCallback()
		end						
				
	end
	
	local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	local flyTime = 0.5		
	if self:getRenderSprite() then
		self.ccActionCallback = callback
		self:changeAction(EntityAction.eEntityAction_Hit, true)
		self.state:setIsLock(true)
		
		local actionArray = CCArray:create()
		actionArray:addObject(CCMoveTo:create(flyTime, ccp(mapX, mapY)))
		actionArray:addObject(CCCallFunc:create(finishCallback))
		
		self.ccAction = CCSequence:create(actionArray)
		self.ccAction:retain()
		
		-- �ƶ�ģ��
		self:getRenderSprite():runAction(self.ccAction)
	end
	
	if self:getShadow() then
		-- �ƶ���Ӱ
		self:getShadow():runAction(CCMoveTo:create(flyTime, ccp(mapX, mapY)))
	end
end

function FightCharacterObject:exitHitBack()
	self:releaseMoveAction()	
end

function FightCharacterObject:tick(time)
	if self.moving and self.move then
		local x = 0
		local y = 0
		local characterDir = 0
		local shouldstop = self.move:Tick(x, y, characterDir)
		moveToX = self.move:getX()
		moveToY = self.move:getY()
		characterDir = self.move:getDir()
		self.renderSprite:setAngle(characterDir)
		if shouldstop then
			self.moving = false
			self.move:ClearPath()
			self:moveStop()
			if self.faceToHero then
				self:faceToHero()
			end
		end
		self:setMapXY(moveToX,moveToY)
	end
end

function FightCharacterObject:DoAoiMove(cellX, cellY)
	self.moveTargetX = cellX
	self.moveTargetY = cellY
	
	self:moveTo(cellX, cellY)
end

function FightCharacterObject:moveTo(x, y,notUpdate,speed)
	if notUpdate == false then
		self:updateSpeed()
	end
	
	if speed then
		self.move:SetSpeed(speed)
	end
	
	if self.bEnterMap == false then
		self.targetX = x
		self.targetY = y
	else
		if self:needMove(cellX, cellY) then
			if self.state:isState(CharacterState.CharacterStateMove) then
				-- ��������ƶ���action, �ٸı�һ��
				if self.renderSprite:getActionId() ~= EntityAction.eEntityAction_Run then
					self:changeAction(EntityAction.eEntityAction_Run, true)
				end
				return self:fightCharacterMoveTo(x,y)
			else
				return self.state:changeState(CharacterState.CharacterStateMove, x, y)
			end
		else
			return false
		end
	end
end

function FightCharacterObject:fightCharacterMoveTo(cellX, cellY)
	if self:needMove(cellX, cellY) then
		self.targetX = cellX
		self.targetY = cellY
		
		local mapXX,mapYY = GameWorld.Instance:getMapManager():cellToMap(self.targetX, self.targetY)
		local currentX = self.renderSprite:getPositionX()
		local currentY = self.renderSprite:getPositionY()
		local angle = self:getAngle()
		if not angle then
			angle = 0
		end
		self.moving = self.move:CreatePath(currentX, currentY, angle, mapXX, mapYY)
		
		if not self.moving then
			--print("self.moving false")
		end
		
		return self.moving
	else
		--	print("fightCharacterMoveTo failed")
		return false
	end
end

function FightCharacterObject:clearTargetXY()
	self.targetX = 0
	self.targetY = 0
end

function FightCharacterObject:needMove(cellX, cellY)
	return not (cellX == self.targetX and cellY == self.targetY)
	--return not ((cellX == self.targetX and cellY == self.targetY) or (heroCellX == cellX and heroCellY == cellY))
end

function FightCharacterObject:fightCharacterMoveStop()
	if self.moving == true then
		self.move:ClearPath()
		self.moving = false
	end
	--Juchao@20140418: ������Ӧ��ǿ������target����Ϊ�Լ�����
	-- ��target����Ϊ���Լ�������һ��
	local cellX, cellY = self:getCellXY()
	self.targetX = cellX
	self.targetY = cellY
end

function FightCharacterObject:moveStop()
	self:fightCharacterMoveStop()
	if self.state:isState(CharacterState.CharacterStateMove) then
		self.state:changeState(CharacterState.CharacterStateIdle)
	end
end

function FightCharacterObject:createMovePath(array,theTable)
	local count = array:count()
	self.moveLenght = 0
	self.showingPathPoint = {}
	for i = 0 , count-1  do
		local point = array:objectAtIndex(i)
		point =  tolua.cast(point,"pathPoint")
		local data = {}
		local point = SFMap:coodMap2Cell(point:getX(), point:getY())
		data["x"] = point:getX()
		data["y"] = point:getY()
		table.insert(theTable,data)
		table.insert(self.showingPathPoint,data)
		if i>0 then
			local first = theTable[i]
			local distance = ccpDistance(ccp(first.x,first.y),ccp(data.x,data.y))
			self.moveLenght = self.moveLenght + distance
		end
	end
end

function FightCharacterObject:getMovePathes(fromX, fromY, toX, toY)
	return self.move:getMovePoints(fromX, fromY, toX, toY)
end

function FightCharacterObject:setStateTable(stateTable)
	self.stateTable = stateTable
end

function FightCharacterObject:onEnterMap(x,y)
	self.state:updateComboStateList(self.stateTable)
	self:updateSpeed()
	
	if self.targetX > 0 and self.targetY > 0 then
		local targetX = self.targetX
		local targetY = self.targetY
		self.targetX = 0
		self.targetY = 0
		
		if self:moveTo(targetX, targetY) == false then
			self:DoIdle()
		end
		
	else
		self:DoIdle()
		self.moveX = x--, self.moveY = self:getCellXY()
		self.moveY = y
	end
end

--Ѫ������
function FightCharacterObject:setHP(hp)
	PropertyDictionary:set_HP(self:getPT(), hp)	
	if (self.hpBar) then
		local maxHp = PropertyDictionary:get_maxHP(self:getPT())
		--print("��ǰѪ��"..hp.."���Ѫ��"..maxHp)
		self.hpBar:setScaleX(17*(hp/maxHp))
		self:compareHP()
	end
end

function FightCharacterObject:setMaxHP(maxHp)
	PropertyDictionary:set_maxHP(self:getPT(), maxHp)
	if (self.hpBar) then
		local hp = PropertyDictionary:get_HP(self:getPT())
		self.hpBar:setScaleX(17*(hp/maxHp))
		self:compareHP()
	end
end

function FightCharacterObject:compareHP()
	if self.hpBar then
		local currentHp = PropertyDictionary:get_HP(self:getPT())
		local currentMaxHp = PropertyDictionary:get_maxHP(self:getPT())
		if currentHp == 0 then
			self.hpBar:setVisible(false)
			self.hpBarBg:setVisible(false)
		else
			if self:getEntityType() == EntityType.EntityType_Monster then	
				if currentHp == currentMaxHp then				
					self.hpBar:setVisible(false)
					self.hpBarBg:setVisible(false)
				else					
					self.hpBar:setVisible(true)
					self.hpBarBg:setVisible(true)
				end
			else				
				self.hpBar:setVisible(true)
				self.hpBarBg:setVisible(true)
			end
			self:updateTitle()
		end
	end
end

function FightCharacterObject:initHPProgressBars()
	if (self.hpBar == nil) then		
			self.hpBar = createSpriteWithFrameName(RES("common_monsterHp.png"))--CCProgressTimer:create(createSpriteWithFrameName(RES("common_monsterHp.png")))
			self.hpBar:retain()							
			self.hpBarBg = createSpriteWithFrameName(RES("common_monsterHpButtom.png"))--CCProgressTimer:create(createSpriteWithFrameName(RES("common_monsterHpButtom.png")))
			self.hpBarBg:retain()						
			self.hpBar:setScaleX(17)
			local sfmap = SFMapService:instance():getShareMap()
			local maxHP = PropertyDictionary:get_maxHP(self.table)
			local currentHP = PropertyDictionary:get_HP(self.table)
			self.hpBar:setScaleX(17*(currentHP/maxHP))
			--self.hpBarBg:setScaleX(17)
			local x,y = self:getMapXY()
			local offset = self:getTitleOffset()
			
			self.hpBar:setZOrder(100)
			self.hpBarBg:setPosition(x,y-offset)
			self.hpBarBg:setZOrder(99)
			VisibleRect:relativePosition(self.hpBar,self.hpBarBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y)
			
			sfmap:enterMap(self.hpBarBg, eRenderLayer_Effect)
			sfmap:enterMap(self.hpBar, eRenderLayer_Effect)		

			self:compareHP()
		end
end

--PlayerObject/MonsterObject����д�ú����������ɳ�Ϳ˹���ʱ��ɫ����
--����������ɫ�������ָ����ɫ�������ʵ�����ڵ���ɫ����������
function FightCharacterObject:updateNameColor()
	local color
	local titleNameColor = PropertyDictionary:get_nameColor(self:getPT())
	if titleNameColor == E_HeroNameColorType.White then
		color = FCOLOR("ColorWhite1")
	elseif titleNameColor == E_HeroNameColorType.Yellow then
		color = FCOLOR("ColorYellow1")
	elseif titleNameColor == E_HeroNameColorType.Red then
		color = FCOLOR("ColorRed2")
	elseif titleNameColor == E_HeroNameColorType.Gray then
		color = FCOLOR("ColorGray3")
	end
	GameWorld.Instance:getTextManager():updateColor(self.id,color)
end

function FightCharacterObject:addEffect(effectObject, effectId)
	if effectObject and effectId and self.renderSprite then
		-- һ��FightCharacterObject����, ͬһ����Чͬʱ��ಥ��2��
		if self.effectCountList[effectId] and self.effectCountList[effectId] >= SkillShowDef.MaxCharacterUniqueCount then
			return false
		elseif nil == self.effectCountList[effectId]  then
			self.effectCountList[effectId] = 1
		else
			self.effectCountList[effectId] = self.effectCountList[effectId] + 1
		end
		
		self.renderSprite:addChild(effectObject)
		effectObject:retain()
		table.insert(self.effectList, effectObject)
		return true
	else
		CCLuaLog("Warning!FightCharacterObject:addEffect with wrong params")
		return false
	end
end


--[[
�Ƴ�������Ч
]]
function FightCharacterObject:removeEffect(effectObject, effectId)
	if effectObject and effectId and self.renderSprite then
		if self.effectCountList[effectId] and self.effectCountList[effectId] > 0 then
			self.effectCountList[effectId] = self.effectCountList[effectId] - 1
		end
		
		for k,v in pairs(self.effectList) do
			if effectObject == v then
				self.renderSprite:removeChild(effectObject, true)
				effectObject:release()
				self.effectList[k] = nil
				break
			end
		end
	else
		CCLuaLog("Warning!FightCharacterObject:removeEffect with wrong params")
	end
end

function FightCharacterObject:canShowEffect(effectId)
	if effectId then
		if not self.effectCountList[effectId] then
			return true
		else
			return self.effectCountList[effectId] <= SkillShowDef.MaxCharacterUniqueCount
		end
	else
		return false
	end
end

--[[
��ɫת�������Ļص�
]]
function FightCharacterObject:actionCallbackFunc(actionId, movementType)
	if self and self.state then
		if movementType ~= 0 then
			if self.state:isState(CharacterState.CharacterStateUseSkill) then
				-- ������״̬���Խ���
				self.state:setIsLock(false)
			end
			-- ����������ⲿ��callback, ת������ص�
			if self.actionCallback then
				local callback = self.actionCallback
				
				-- ����գ���ֹactionCallback������changeAction���ٴλص��������
				self.actionCallback = nil
				callback(actionId, movementType)
			end
		end
	end
end

-- �ж��Ƿ����ת��Ϊĳ��״̬
function FightCharacterObject:canChange(state)
	return self.state:canChange(state)
end

-- ���Ź�������
function FightCharacterObject:DoShowAttackAction(actionId, callback)
	if self.state:canChange(CharacterState.CharacterStateUseSkill) == true then
		return self.state:changeState(CharacterState.CharacterStateUseSkill, actionId, callback)
	else
		return false
	end
end

-- ���Ż���
function FightCharacterObject:DoShowHitFly(cellX, cellY, callback)
	if self.state:canChange(CharacterState.CharacterStateHitFly) == true then
		return self.state:changeState(CharacterState.CharacterStateHitFly, cellX, cellY, callback)
	else
		return false
	end
end

function FightCharacterObject:DoShowHitBack(cellX, cellY, callback)
	if self.state:canChange(CharacterState.CharacterStateHitBack) == true then
		return self.state:changeState(CharacterState.CharacterStateHitBack, cellX, cellY, callback)
	else
		return false
	end
end

-- �����ܻ�����
function FightCharacterObject:DoShowBeHit(callback)
	if self.state:canChange(CharacterState.CharacterStateHit) then
		return self.state:changeState(CharacterState.CharacterStateHit, callback)
	else
		return false
	end
end

-- תΪidle
function FightCharacterObject:DoIdle()
	local ret = self.state:changeState(CharacterState.CharacterStateIdle)
	return ret
end

-- תΪmove
function FightCharacterObject:DoMove()
	return self.state:changeState(CharacterState.CharacterStateMove)
end

-- Ԥ������״̬
function FightCharacterObject:DoWillDeath()
	--	return self.state:changeState(CharacterState.CharacterStateWillDead)
	return self.state:forceChangeState(CharacterState.CharacterStateWillDead)
end

-- ��������
function FightCharacterObject:DoDeath(effectId)
	local hpPt = {}
	hpPt["HP"] = 0
	if self.table then
		self:updatePT(hpPt)
	end		
	if self.state then
		self.state:forceChangeState(CharacterState.CharacterStateDead, effectId)
	end
end

-- ��ȡ���������ٶ�
function FightCharacterObject:getIdleAnimateSpeed()
	return 1
end

function FightCharacterObject:getAttackAnimateSpeed()
	return 1
end

function FightCharacterObject:getMoveAnimateSpeed()
	return 1
end

function FightCharacterObject:getRideMoveAnimateSpeed()
	return 1
end

-- ����״̬
function FightCharacterObject:enterDeath(effectId)
	-- ��ʾһ����������������
	self:clearEffect()
	
	-- �������е����״̬
	self.state:updateComboStateList(nil)
	
	--����Ҫ��Ҫ����
	if SkillShowManager:getDisplayEffect() then
		if effectId == nil then
			effectId = 8011
		end
		local deathPlayer =  MapAnimatePlayer.New()
		local cellX, cellY = self:getCellXY()
		deathPlayer:setPlayData(cellX, cellY, effectId)
		deathPlayer:setResPath("res/scene/")
		GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", deathPlayer)
	end
	
	return true
end

function FightCharacterObject:exitDeath()
	self:updateNameColor()
	return true
end

function FightCharacterObject:enterWillDeath()
	self:moveStop()
	
	return true
end

function FightCharacterObject:changeAction(actionId, bLoop,callBack)
	-- ���֮ǰ�Ѿ������˻ص����Ȼص�����
	if self.actionCallback then
		self:actionCallbackFunc(actionId, CharacterMovement.Cancel)
	end
	
	local callbackFunc = function (actionId, movementType)
		self:actionCallbackFunc(actionId, movementType)
		
		if movementType ~= 0 then
			self.actionCallback = nil
		end
	end
	
	self.actionCallback = callBack
	
	if self.renderSprite ~= nil then
		if callBack then
			self.renderSprite:changeActionCallback(actionId, 1, bLoop, callbackFunc)
		else
			self.renderSprite:changeAction(actionId, 1, bLoop)
		end
		
		-- ���ò�ͬ�����Ĳ����ٶ�
		if (actionId == EntityAction.eEntityAction_Attack or actionId == EntityAction.eEntityAction_Skill1
			or actionId == EntityAction.eEntityAction_Skill2 or actionId == EntityAction.eEntityAction_Skill3) then
			self.renderSprite:setAnimSpeed(self:getAttackAnimateSpeed())
		elseif actionId == EntityAction.eEntityAction_Run then
			self.renderSprite:setAnimSpeed(self:getMoveAnimateSpeed())
		elseif actionId ==  EntityAction.eEntityAction_RideRun then
			self.renderSprite:setAnimSpeed(self:getRideMoveAnimateSpeed())
		elseif actionId == EntityAction.eEntityAction_Idle or actionId == EntityAction.eEntityAction_RideIdle then
			self.renderSprite:setAnimSpeed(self:getIdleAnimateSpeed())
		end
		self:updateTitle()
	end
end

-- ���״̬�Ļص�
function FightCharacterObject:comboStateCallback(state, bEnter)
	if self.bEnterMap then
		if state and bEnter == true then
			FightStateEffect:Instance():enterState(state, self)
		elseif state and bEnter == false then
			FightStateEffect:Instance():exitState(state, self)
		end
	end
end