require("object.entity.PlayerObject")
require("object.actionPlayer.MoveToTargetActionPlayer")
require("object.actionPlayer.CollectActionPlayer")
require("object.skillShow.SkillShowManager")
require("object.activity.MonstorInvasionMgr")
require("object.handup.HandupMgr")
require("object.castleWar.CastleWarMgr")
require("object.friend.FriendMgr")
require("object.skill.SkillMgr")	
require("object.worldBoss.WorldBossMgr")
require("object.resourceDownload.ResDownloadMgr")
require("object.Recharge.RechargeMgr")
require("object.bag.BagMgr")
require("object.quest.QuestMgr")
require("object.equip.EquipMgr")
require("object.debug.DebugMgr")
require("object.chat.ChatMgr")
require("object.knight.KnightMgr")
require("object.wing.WingMgr")
require("object.achievement.AchievementMgr")
require("object.forging.ForgingMgr")
require("object.strengthenQuest.StrengthenQuestMgr")
require("object.mail.MailMgr")
require("object.faction.FactionMgr")
require("object.mainActivity.MainActivityMgr")
require("object.team.TeamMgr")
require("object.actionPlayer.PickupActionPlayer")
require("object.actionPlayer.UseSkillActionPlayer")
require("object.actionPlayer.CollectActionPlayer")
require("object.entity.EntityFocusManager")
require("object.entity.PKHitManager")
require("object.auction.AuctionMgr")
require("data.item.equipItem")
require("object.quest.QuestLogicMgr")
require("object.quest.QuestNPCStateMgr")

HeroObject = HeroObject or BaseClass(PlayerObject)

CannotUseSkillReason = {
stateError = 1,
cannotUseNow = 2,
targetError = 3,
}

function HeroObject:__init()
	self.type = EntityType.EntityType_Player	-- 类型	
	--创建 背包管理实例BagMgr
	self.bagMgr = nil
	self.skillMgr = nil
	self.rechargeMgr = nil
	--创建 任务管理实例QuestMgr
	self.questMgr = nil	
	-- 创建 好友管理实例friendMgr
	self.friendMgr = nil	
	self.equipMgr = nil
	self.debugMgr = nil
	--聊天管理实例
	self.chatMgr = ChatMgr.New()
	--翅膀管理实例
	self.wingMgr = nil
	self.knightMgr = nil
	self.achievementMgr = nil
	
	self.forgingMgr = nil
	self.movePathes = nil
	self.targetPoints  = {}
	--变强任务入口管理实例
	self.strengthenQuest = nil
	--邮件管理实例
	self.mailMgr = nil
	self.handupMgr = nil
	self.teamMgr = nil
	self.factionMgr = nil
	self.mainMgr = nil
	self.heroStateMgr = nil
	
	--沙巴克攻城管理
	self.castleWarMgr = nil
	self.objectMgr = {}
	--怪物入侵
	self.monstorInvasionMgr = nil
	self.PKHitMgr = nil
	self.hasTips = false
	-- 挂机的设置
	self.entityFocusManager = EntityFocusManager.New()
	table.insert(self.objectMgr,self.entityFocusManager)
		
	self.movingTouseSkillActionIdId = nil	
	self.useSkillActionId = nil
	self.questLogicMgr = nil
	self.questNPCStateMgr = nil
	
	self:setPKStateID(E_HeroPKState.statePeace)
	self:InitSafeAreaTips()
						
end

function HeroObject:__delete()

end 

function HeroObject:clear()
	for i,v in pairs(self.objectMgr) do
		if v and v.clear then
			v:clear()
		end
	end 
	self:leaveMap()
	self.renderSprite:clear()	
	self.stateId = E_HeroPKState.statePeace 
	
	--Juchao@20140808: 断线重练之后，需要清理英雄所有组合状态
	local statelist = {}
	self.state:updateComboStateList(statelist)
	self:forceSetShader(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))	
end

function HeroObject:getEntityFocusManager()
	return self.entityFocusManager	
end

function HeroObject:getCastleWarMgr()
	if self.castleWarMgr == nil then	
		self.castleWarMgr = CastleWarMgr.New()
		table.insert(self.objectMgr,self.castleWarMgr)
	end
	return self.castleWarMgr
end


function HeroObject:getHandupMgr()
	if self.handupMgr == nil then
		
		self.handupMgr = HandupMgr.New()
		table.insert(self.objectMgr,self.handupMgr)
	end
	return self.handupMgr
end

function HeroObject:getMonstorInvasionMgr()
	if self.monstorInvasionMgr == nil then 
		
		self.monstorInvasionMgr = MonstorInvasionMgr.New()
		table.insert(self.objectMgr,self.monstorInvasionMgr)
	end
	return self.monstorInvasionMgr
end

function HeroObject:getFriendMgr()
	if self.friendMgr == nil then

		self.friendMgr = FriendMgr.New()
		table.insert(self.objectMgr,self.friendMgr)
	end
	return self.friendMgr
end
	
function HeroObject:getSkillMgr()
	if self.skillMgr == nil then	
		self.skillMgr = GameWorld.Instance:getSkillMgr()
		table.insert(self.objectMgr,self.skillMgr)
	end
	return self.skillMgr
end

function HeroObject:getWorldBossMgr()
	if self.worldBossMgr == nil then	
		self.worldBossMgr = GameWorld.Instance:getWorldBossMgr()
		table.insert(self.objectMgr,self.worldBossMgr)
	end
	return self.worldBossMgr
end

function HeroObject:getAuctionMgr()
	if self.auctionMgr == nil then	
		self.auctionMgr = AuctionMgr.New()
		table.insert(self.objectMgr, self.auctionMgr)
	end
	return self.auctionMgr
end

function HeroObject:getResDownloadMgr()
	if self.resDownloadMgr == nil then	
		self.resDownloadMgr = GameWorld.Instance:getResDownloadMgr()
		table.insert(self.objectMgr,self.resDownloadMgr)
	end
	return self.resDownloadMgr
end

function HeroObject:getRechargeMgr()
	if self.rechargeMgr == nil then	
		self.rechargeMgr = GameWorld.Instance:getRechargeMgr()
		table.insert(self.objectMgr,self.rechargeMgr)
	end
	return self.rechargeMgr
end	

function HeroObject:getBagMgr()
	if self.bagMgr == nil then	
		self.bagMgr = BagMgr.New()
		table.insert(self.objectMgr,self.bagMgr)
	end
	
	return self.bagMgr
end

function HeroObject:getQuestMgr()
	if self.questMgr == nil then	
		self.questMgr = QuestMgr.New()
		table.insert(self.objectMgr,self.questMgr)
	end
	return self.questMgr
end

function HeroObject:getEquipMgr()
	if self.equipMgr == nil then	
		self.equipMgr = EquipMgr.New()
		table.insert(self.objectMgr,self.equipMgr)
	end
	
	return self.equipMgr
end

function HeroObject:getDebugMgr()
	if self.debugMgr == nil then	
		self.debugMgr = DebugMgr.New()
		table.insert(self.objectMgr,self.debugMgr)
	end
	return self.debugMgr
end

function HeroObject:getChatMgr()
	if self.chatMgr == nil then	
		self.chatMgr = ChatMgr.New()
		table.insert(self.objectMgr,self.chatMgr)
	end
	return self.chatMgr
end

function HeroObject:getKnightMgr()
	if self.knightMgr == nil then	
		self.knightMgr = KnightMgr.New()
		table.insert(self.objectMgr,self.knightMgr)
	end
	return self.knightMgr
end

function HeroObject:getWingMgr()
	if self.wingMgr == nil then	
		self.wingMgr = WingMgr.New()
		table.insert(self.objectMgr,self.wingMgr)
	end
	return self.wingMgr
end

function HeroObject:getAchievementMgr()
	if self.achievementMgr == nil then	
		self.achievementMgr = AchievementMgr.New()
		table.insert(self.objectMgr,self.achievementMgr)
	end
	return self.achievementMgr
end

function HeroObject:getForgingMgr()
	if self.forgingMgr == nil then	
		self.forgingMgr = ForgingMgr.New()
		table.insert(self.objectMgr,self.forgingMgr)
	end
	return self.forgingMgr
end

function HeroObject:getStrengthenQuestMgr()
	if self.strengthenQuest == nil then	
		self.strengthenQuest = StrengthenQuestMgr.New()
		table.insert(self.objectMgr,self.strengthenQuest)
	end
	return self.strengthenQuest
end

function HeroObject:getMailMgr()
	if self.mailMgr == nil then	
		self.mailMgr = MailMgr.New()
		table.insert(self.objectMgr,self.mailMgr)
	end
	return self.mailMgr
end

function HeroObject:getFactionMgr()
	if self.factionMgr == nil then	
		self.factionMgr = FactionMgr.New()
		table.insert(self.objectMgr,self.factionMgr)
	end
	return self.factionMgr
end

function HeroObject:getMainMgr()
	if self.mainMgr == nil then	
		self.mainMgr = MainActivityMgr.New()
		table.insert(self.objectMgr,self.mainMgr)
	end
	return self.mainMgr
end

function HeroObject:getTeamMgr()
	if self.teamMgr == nil then
		
		self.teamMgr = TeamMgr.New()
		table.insert(self.objectMgr,self.teamMgr)
	end
	return self.teamMgr

end

function HeroObject:getPKHitMgr()
	if self.PKHitMgr == nil then	
		self.PKHitMgr = PKHitManager.New()
		table.insert(self.objectMgr,self.PKHitMgr)
	end
	return self.PKHitMgr
end

function HeroObject:getQuestLogicMgr()
	if self.questLogicMgr == nil then	
		self.questLogicMgr = QuestLogicMgr.New()
		table.insert(self.objectMgr,self.questLogicMgr)
	end
	return self.questLogicMgr
end

function HeroObject:getQuestNPCStateMgr()
	if self.questNPCStateMgr == nil then	
		self.questNPCStateMgr = QuestNPCStateMgr.New()
		table.insert(self.objectMgr,self.questNPCStateMgr)
	end
	return self.questNPCStateMgr
end

-- 强制停止移动
function HeroObject:forceStop()
	if self.move and self.move.ClearPath then
		self.move:ClearPath()
	end
	
	self:clearShowingPath()
	self.moving = false
	if not self.state:isState(CharacterState.CharacterStateDead) then
		if self:isRided() then
			self.state:forceChangeState(CharacterState.CharacterStateRideIdle)
		else
			self.state:forceChangeState(CharacterState.CharacterStateIdle)
		end
	end
	if self.movingTouseSkillActionIdId then
		ActionPlayerMgr.Instance:removePlayerById(self.movingTouseSkillActionIdId)
		self.movingTouseSkillActionIdId = nil
	end
	GlobalEventSystem:Fire(GameEvent.EventClearHeroActiveState, E_HeroActiveState.AutoFindRoad) 	
end

local constMoveSpeedErrorValue = 1
--返回失败或成功
function HeroObject:moveTo(x, y)
	-- 和当前坐标不相同才进入下面的逻辑
	local speed = self.move:GetSpeed()
	local ptSpeed = PropertyDictionary:get_moveSpeed(self.table)
	local heroCellX, heroCellY = GameWorld.Instance:getMapManager():convertToAoiCell(self:getCellXY())	
	if  (speed - ptSpeed)  > constMoveSpeedErrorValue then	
			
		CCLuaLog("MoveSpeed Error")
		if not self.hasTips then 
			local function msgBoxCallback(arg, text, id)				
				self.hasTips = false				
			end
			local msgBox = showMsgBox(Config.Words[15038], E_MSG_BT_ID.ID_OK)
			msgBox:setNotify(msgBoxCallback)
			self.hasTips = true
		end
		return false
	end
	if x and y then
		local targetCellX, targetCellY = GameWorld.Instance:getMapManager():convertToAoiCell(x, y)
		if targetCellX ~= heroCellX or targetCellY ~= heroCellY then
			if self.state:isState(CharacterState.CharacterStateMove) or self.state:isState(CharacterState.CharacterStateRideMove) then
				return self:heroMoveTo(x,y)
			else
				if self.state:isState(CharacterState.CharacterStateRideIdle) then
					return self.state:changeState(CharacterState.CharacterStateRideMove, x, y)
				else
					return self.state:changeState(CharacterState.CharacterStateMove, x, y)
				end
			end
		else
			return false
		end
	else
		return false
	end
end

function HeroObject:heroMoveTo(x,y)
	-- 转换为AOI的格子
	local newTargetX, newTargetY = GameWorld.Instance:getMapManager():convertToAoiCell(x, y)
	
	if self:fightCharacterMoveTo(newTargetX,newTargetY) then
		self.movePathes = {}		
		local array = self.move:getMovePoints(0,0,0,0)
		self:createMovePath(array,self.movePathes)
		self:findPathTargetPoint(self.movePathes)
		--Juchao@20140521: 不需要手动删除这个状态。服务器会发打断采集的消息过来。
--		self:getState():removeComboState(CharacterState.CharacterStateCollect)
		GlobalEventSystem:Fire(GameEvent.EventHeroStartMove)
		return true
	else
		--print("not fightCharacterMoveTo")
		return false
	end
end

function HeroObject:enterStateUseSkill(actionId, callback)
	if self.moving then
		-- 如果正在移动，要停下
		self:moveStop()
		self:sysHeroLocation()
	end
	
	FightCharacterObject.enterStateUseSkill(self, actionId, callback)
end

function HeroObject:getMovePath()
	return self.movePathes
end

function HeroObject:getShowingMovePath()
	return self.showingPathPoint
end

function HeroObject:getMoveLength()
	return self.moveLenght
end

function HeroObject:enterStateMove(cellX, cellY)
	if self.hasMount then
		self:mountDown()
	end		
	if cellX and cellY then
		if self:heroMoveTo(cellX, cellY) then
			self:changeAction(EntityAction.eEntityAction_Run,true)			
			return true
		else
			self:DoIdle()
			return false
		end
	else
		self:changeAction(EntityAction.eEntityAction_Run,true)			
		return true
	end
end	

-- 切换为受击状态
function HeroObject:enterBeHit(callback)
	local state = PlayerObject.enterBeHit(self,callback)
	local soundMgr = GameWorld.Instance:getSoundMgr()
			
	if state == true and math.random() < 0.2 then --十分之一的几率播放
		if PropertyDictionary:get_gender(self:getPT()) == ModeType.eGenderFemale then	
			soundMgr:playEffect("music/womanbeat.mp3")								
		else		
			soundMgr:playEffect("music/manbeat.mp3")
		end
	end
	return state
end

function HeroObject:exitStateMove(newState)
	-- 如果新状态不是RideMove, 就应该要停下移动
	if newState ~= CharacterState.CharacterStateRideMove then
		self:fightCharacterMoveStop()
	end
end

function HeroObject:enterRideMove(cellX, cellY)
	if cellX and cellY then
		if self:heroMoveTo(cellX, cellY) then
			self:changeAction(EntityAction.eEntityAction_RideRun, true)
			return true
		else
			self.state:changeState(CharacterState.CharacterStateRideIdle)
			return false
		end
	else
		self:changeAction(EntityAction.eEntityAction_RideRun, true)
		return true
	end		
end

function HeroObject:exitRideMove(newState)
	-- 如果新状态不是移动,  就可以把移动停止了
	if newState ~= CharacterState.CharacterStateMove then
		self:fightCharacterMoveStop()
	end		
	return true
end

function HeroObject:moveStop()
	PlayerObject.moveStop(self)	
	local x,y = self:getCellXY()
	GlobalEventSystem:Fire(GameEvent.EVENT_HERO_STOP, true)
end

function HeroObject:findPathTargetPoint(pathes)
	self.targetPoints = {}
	for k,v in ipairs(pathes) do
		if (k-1) % 9 == 0 then
			table.insert(self.targetPoints,v)
		end
	end
end

function HeroObject:isRided()
	return self.hasMount
end

function HeroObject:updateSpeed()
	local speed = PropertyDictionary:get_moveSpeed(self.table)
	if speed ~= 0 then
		local oldSpeed = self.move:GetSpeed()
		if oldSpeed ~= speed then
--			print("speed="..speed)
			self.move:SetSpeed(speed)
			GlobalEventSystem:Fire(GameEvent.EventHeroSpeedUpdate)
		end
	end
end

function HeroObject:hasTargetPoints(cellX,cellY)
	if table.size(self.targetPoints) > 0 then
		for k,v in pairs(self.targetPoints) do
			if v.x == cellX and  v.y == cellY then
				return true
			end
		end
	else
		return false
	end
end

function HeroObject:printTable()
	local str = " "
	for k,v in pairs(self.movePathes) do
		str = str ..v.x.." "..v.y.." "
	end
	print(str)
end

function HeroObject:processPathPoint()
	self.isprocessing = true
	local simulator = SFGameSimulator:sharedGameSimulator()
	local size = table.size(self.targetPoints)
	local pathSize = table.size(self.movePathes)
	local realSize = pathSize
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Start_Move)
	if size ~= 1 then
		pathSize = 9
		realSize = 10
	end
	writer:WriteChar(realSize)
	for i = 1,pathSize do
		local data = self.movePathes[1]
		writer:WriteInt(data.x)
		writer:WriteInt(data.y)
		table.remove(self.movePathes,1)		
	end
	table.remove(self.targetPoints,1)
	if table.size(self.targetPoints) > 0 then
		local last = self.targetPoints[1]
		writer:WriteInt(last.x)
		writer:WriteInt(last.y)		
	end
	simulator:sendTcpActionEventInLua(writer)
end

function HeroObject:tick(time)
	-- 移动摄像头
	local cellX,cellY = self:getCellXY()
	
	if self:hasTargetPoints(cellX,cellY) then
		
		if self.isprocessing ~= true then
			self:processPathPoint()
			self.isprocessing = false
		end
	end
	self:adjustPosition(time)
	self:handleFirstPoint(cellX,cellY)
	-- manager的tick
	if self.skillMgr then
		self.skillMgr:tick(time)
	end
	
	if self.bagMgr then
		self.bagMgr:update(time) 	--更新CD
	end
end

function HeroObject:handleFirstPoint(cellX,cellY)
	if self.showingPathPoint then
		local firstPoint = self.showingPathPoint[1]
		if firstPoint then
			if firstPoint.x == cellX  and firstPoint.y == cellY then
				table.remove(self.showingPathPoint,1)
			end
		end
	end
end

function HeroObject:clearShowingPath()
	self.showingPathPoint = nil	
end

function HeroObject:adjustPosition(time)
	if self.moving then
		local x = 0
		local y = 0
		local characterDir = 0
		local shouldstop = self.move:Tick(x, y, characterDir)
		local moveToX = self.move:getX()
		local moveToY = self.move:getY()
		characterDir = self.move:getDir()
		if shouldstop then
			self.moving = false
			self:moveStop()
		end
		self.renderSprite:setAngle(characterDir)
		self:setMapXY(moveToX,moveToY)
		
		local centerY = self:getCenterY()
		SFMapService:instance():getShareMap():setViewCenter(moveToX, centerY)
		GlobalEventSystem:Fire(GameEvent.EventHeroMovement)
	end
end

function HeroObject:showIsAtSafeArea()
	if self.isAtSafeArea ~= nil then
		local x, y = G_getHero():getCellXY()
		local state = GameWorld.Instance:getMapManager():isInSafeArea(x, y)
		if self.isAtSafeArea ~= state then
			if 	state == false then
				UIManager.Instance:showSystemTips(Config.Words[856])
			else
				UIManager.Instance:showSystemTips(Config.Words[857])		
			end			
		end
		self.isAtSafeArea = state
	else
		local x, y = G_getHero():getCellXY()
		self.isAtSafeArea = GameWorld.Instance:getMapManager():isInSafeArea(x, y)
	end	
end

-- 坐骑模型ID
function HeroObject:setMountModelId(mountModelId)
	self.mountModelId = mountModelId
end

function HeroObject:getMountModelId()
	return self.mountModelId
end

-- 武器模型ID
function HeroObject:setWeaponId(weaponId)
	self.weaponId = weaponId
	--	CCLuaLog("HeroObject:setWeaponId:"..weaponId)
end

function HeroObject:getWeaponId()
	return self.weaponId
end

-- 衣服模型ID
function HeroObject:setClothId(clothId)
	self.clothId = clothId
end

function HeroObject:getClothId()
	return self.clothId
end

-- 翅膀模型ID
function HeroObject:setWingId(wingId)
	self.wingId = wingId
end

function HeroObject:getWingId()
	return self.wingId
end

-- 是否能够使用某个技能的统一API
function HeroObject:canUseSkill(skillRefId)
	--判断状态机
	if self.state:isState(CharacterState.CharacterStateUseSkill) or self.state:canChange(CharacterState.CharacterStateUseSkill) == false then
		return false, nil, CannotUseSkillReason.stateError
	end
	
	local canUse, skillObject = self.skillMgr:canUseSkill(skillRefId)
	if (not canUse) or (skillObject == nil) then
		return false, nil, CannotUseSkillReason.cannotUseNow
	end
					
	--非朝向技能&&目标类型为敌方的技能，需要有合法的战斗目标才能使用 
	if skillObject:needFightTarget() then
		if not self:getFightTargetWithSelect() then	--Juchao@20140724: 增加自动选目标
--		if not self:getFightTarget() then
			return false, nil, CannotUseSkillReason.targetError
		end
	end
	return true, skillObject
end	

--skillRefId: 技能的refId
--bMove：如果攻击范围不对，是否移动到攻击范围内再使用
--bLater: 是否在下一帧再使用（放入行为队列里使用）
--返回值：1. 使用结果ret 2.使用技能的action
function HeroObject:useSkillWithCheck(skillRefId, bMove, bLater, bHandup)
	local canUse, skillObject = self:canUseSkill(skillRefId)
	if (not canUse) or (skillObject == nil) then
		return false
	end
	if self:isMovingToUseSkill() then
		return false
	end
		
	--检测是否为特殊技能，并做相应处理	
	if self:checkSpecialSkill(skillRefId) then
		return false
	end
	
	-- 普通可以被替换成其他技能
	if skillRefId == const_skill_pugong then
		skillRefId = self.skillMgr:checkReplaceSkill(skillRefId)
	end
		
	local target = nil
	--非朝向技能&&地方技能，需要有合法的战斗目标才可以使用(地狱雷光特殊处理)
	if skillObject:needFightTarget() 
	   or (bHandup and string.find(skillRefId, "skill_fs_10")) then	--Juchao@20140515: 如果是挂机状态，雷电风暴需要目标
		--获取一个合法的战斗目标			
		target = self:getFightTarget()
		if (target == nil) then
			return false
		end
		
		--不在攻击范围内，需要尝试移动
		local skillRange = PropertyDictionary:get_skillRange(skillObject:getStaticData())
		if not (skillRange > 0) then
			skillRange = 1
		end
		if (self:isInAttackRange(skillRange, target) ~= true) then	
			if bMove then			
				local moveAction = self:addMoveToTargetAction(target, skillRange )	
				if target:getEntityType() == EntityType.EntityType_Monster then
					moveAction:setMaxPlayCount(-1)	--如果是怪物，就会一直尝试追到
				end
				self.movingTouseSkillActionIdId = moveAction:getId()
				local onMoveFinished = function()
					self.movingTouseSkillActionIdId = nil
				end				
				moveAction:addStopNotify(onMoveFinished, nil)
				
				local useSkillAction = self:addUseSkillAction(skillRefId)	
				self.useSkillActionId = useSkillAction:getId()
				local onUseSkillFinished = function()
					self.useSkillActionId = nil
				end				
				useSkillAction:addStopNotify(onUseSkillFinished, nil)
				return true, useSkillAction
			else			
				return false
			end				
		end
	end
	--如果指定了下一帧再使用，则放入行为队列
	if bLater then
		return true, self:addUseSkillAction(skillRefId)
	else
		self:useSkill(skillRefId)
		return true, nil
	end			
end

function HeroObject:isMovingToUseSkill()
	return self.movingTouseSkillActionIdId ~= nil
end 

--删除上次的使用技能
function HeroObject:removeLastSkill()
	if self.movingTouseSkillActionIdId then
		ActionPlayerMgr.Instance:removePlayerById(self.movingTouseSkillActionIdId)
		self.movingTouseSkillActionIdId = nil
	end
	if self.useSkillActionId then
		ActionPlayerMgr.Instance:removePlayerById(self.useSkillActionId)
		self.useSkillActionId = nil
	end
end

--检测是否为特殊技能，并做相应处理
function HeroObject:checkSpecialSkill(skillRefId)
	-- 烈火剑法比较特殊，使用效果为：下一次任何技能将会替换为烈火剑法
	local bSpecialSkill = (string.find(skillRefId, "skill_zs_6")  ~= nil)		
	if bSpecialSkill then
		self.skillMgr:setReplaceSkill(skillRefId, 10)
		return true
	else
		return false
	end
end

--移动的动作
function HeroObject:addMoveToTargetAction(target, stopDistance)
	local action = MoveToTargetActionPlayer.New()
	action:setTargetInfo(target:getId(), target:getEntityType())
	action:setStopDistance(stopDistance)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--使用技能的动作
function HeroObject:addUseSkillAction(skillRefId)
	local action = UseSkillActionPlayer.New()
	action:setSkillRefId(skillRefId)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--采集的动作
function HeroObject:addCollectAction(npcId)
	
	local action = CollectActionPlayer.New()
	action:setNpcTarget(npcId)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--拾取的动作
function HeroObject:addPickupAction()
	local action = PickupActionPlayer.New()	
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--判断目标是否在攻击范围内
function HeroObject:isInAttackRange(skillRange, target)
	if skillRange and target then
		local distance = HandupCommonAPI:objAoiDistance(target, self)
		return skillRange >=  distance
	else
		return false
	end
end

--判断是否跟目标重叠，以大格子为准（80 * 80）
function HeroObject:isOverlap(target)
	local x1, y1 = GameWorld.Instance:getMapManager():convertToAoiCell(target:getCellXY())
	local x2, y2 = GameWorld.Instance:getMapManager():convertToAoiCell(self:getCellXY())
	if ((x1 == x2) and (y1 == y2)) then
		return true
	else
		return false
	end
end

function HeroObject:getOneCellAround()
	local x, y = self:getCellXY()
	local arounds ={ccp(const_aoiCellSize, const_aoiCellSize), ccp(const_aoiCellSize, -const_aoiCellSize), 
					ccp(-const_aoiCellSize, -const_aoiCellSize), ccp(-const_aoiCellSize, const_aoiCellSize), }
	local index = math.random(1, table.size(arounds))
	
	local sfmap = SFMapService:instance():getShareMap()
	local point = arounds[index]
	local retX = x + point.x
	local retY = y + point.y
	if (retX > 0) and (retY > 0) and (not sfmap:IsBlock(retX, retY)) then
		return retX, retY
	end
	arounds[index] = nil
	
	for k, v in pairs(arounds) do
		retX = x + v.x
		retY = y + v.y
		if (retX > 0) and (retY > 0) and (not sfmap:IsBlock(retX, retY)) then
			return retX, retY
		end
	end
	return nil
end

-- 获取装备附带的高级技能
-- 默认是全部装备列表
function HeroObject:getEquipSkill(skillRefId, updateEquipList)
	local ret = skillRefId	
	if skillRefId then
		local equipList = nil
		if updateEquipList then 	
			equipList = updateEquipList
		else	
			equipList =  self.equipMgr:getEquipList()				
		end
		if type(equipList) ~= "table" or table.size(equipList) < 1 then
			return ret
		end 
		
		for k,equip in pairs(equipList) do
			-- 同一种装备可能有不同的部位 
			for k,v in pairs(equip) do
				local equipRefId = v:getRefId()
				
				-- 确认有没有这个refId
				if GameData.EquipItem[equipRefId] then
					local equipSkillRef = PropertyDictionary:get_skillRefId(GameData.EquipItem[equipRefId]["property"])
					
					-- 如果equipSkillRef包含了skillRefId, 那skillRefId就需要被替换
					--local orginalSkillRef = string.sub(equipSkillRef, 1, -3)
					if string.find(equipSkillRef, skillRefId .. "_") then					
						ret = equipSkillRef						
						return ret
					end
				end
			end
		end
	end
	
	return ret
end

-- 使用技能, 类型判断在函数内完成
-- 不判断攻击范围，攻击行为队列是否满等条件。需要判断则使用useSkillWithCheck()函数
function HeroObject:useSkill(skillRefId)
	local skillObject = self.skillMgr:getSkillObjectByRefId(skillRefId)
	
	if (skillObject) then
		--  使用普通攻击要判断身上是否有开关技能
		if skillRefId == const_skill_pugong then
			-- 检查是否有技能要替换
			skillRefId = self.skillMgr:checkReplaceSkill(skillRefId)
		end
		
		skillRefId = self:getEquipSkill(skillRefId)
		
		-- 判断目标的类型
		local selectTarget = self:getFightTarget()
		local sendUseSkill = false
		
		local skillAimType = PropertyDictionary:get_skillAimType(skillObject:getStaticData())
		local targetType = PropertyDictionary:get_skillTargetType(skillObject:getStaticData())
		if 1 == targetType then
			-- 友方
			if 1 == skillAimType or 3 == skillAimType then
				-- 如果目标不是友方
				if not self:isFriend(selectTarget) then
					selectTarget = self
				end
			end
			
			sendUseSkill = true
		elseif 0 == targetType then
			--自己
			selectTarget = self
			sendUseSkill = true
		else	
			-- 敌方					
			if (1 == skillAimType or 3 == skillAimType) then
				--对目标的技能, 不能对自己释放				
				sendUseSkill = (selectTarget ~= nil and self:getId() ~= selectTarget:getId())
			elseif 2 == skillAimType then
				--朝向
				sendUseSkill = true
			end
			
			--判断目标是否为玩家并且前状态为非和平模式
			if selectTarget and selectTarget:getEntityType() == EntityType.EntityType_Player and self:getPKStateID()~=E_HeroPKState.statePeace then				
				--设置PK受击状态为PK
				self:getPKHitMgr():setPKHitStateToPK()
			end	
		end
		
		-- 自己的技能提前表演
		if sendUseSkill then
			local mgr = GameWorld.Instance:getMountManager()
			-- 如果在马上，要立刻下马
			if mgr:getMountState() == 1 then
				mgr:requestMountRide(1)
				self:mountDown()
			end
			
			if self.moving then
				self:moveStop()
				self:sysHeroLocation()
			end
			
			-- 如果怪物是空血的话，告诉服务器这个怪有问题
			if selectTarget and selectTarget:getEntityType() == EntityType.EntityType_Monster and PropertyDictionary:get_HP(selectTarget:getPT()) == 0 then
				self.entityFocusManager:sendMonsterError(selectTarget:getId())
			end				
			self:beforeUseSkill(skillRefId)
			self.skillMgr:requestUseSkill(skillRefId, self, selectTarget)
			
			if 1 == skillAimType then
				SkillShowManager:showCharacterSkill(self:getId(), EntityType.EntityType_Player, selectTarget:getId(), selectTarget:getEntityType(), skillRefId)
			elseif 2 == skillAimType then
				SkillShowManager:showDirectionSkill(self:getId(), EntityType.EntityType_Player, skillRefId)
			elseif 3 == skillAimType then
				if selectTarget then
					local cellX, cellY = selectTarget:getCellXY()
					SkillShowManager:showMapSkill(self:getId(), EntityType.EntityType_Player, cellX, cellY, skillRefId)
				end
			end
			
			--self.skillMgr:refreshSkillCD(skillRefId)
		end
	end
end

function HeroObject:beforeUseSkill(skillRefId)
	if string.find(skillRefId, "skill_zs_5") then
		GameWorld.Instance:getNpcManager():cancelCollect()
	end
end

--判断目标是否为友方
function HeroObject:isFriend(target)
	if not target then
		return false
	end
	if target:getEntityType() == EntityType.EntityType_Player then --TODO：是玩家时，需要根据PK模式，判断该玩家是否友方
		if self.stateId == nil or self.stateId == E_HeroPKState.statePeace then
			return true
		elseif self.stateId == E_HeroPKState.stateQueue then
			return false
		elseif self.stateId == E_HeroPKState.stateFaction then
			local myUnionName = PropertyDictionary:get_unionName(self:getPT())
			local targetUnionName = PropertyDictionary:get_unionName(target:getPT())
			if myUnionName ~= "" and targetUnionName ~= "" and myUnionName == targetUnionName then
				return true
			else
				return false
			end
		elseif self.stateId == E_HeroPKState.stateGoodOrEvil then
			local targetNameColor = PropertyDictionary:get_nameColor(target:getPT())
			if targetNameColor == 0 then
				return true
			else
				return false
			end
		elseif self.stateId == E_HeroPKState.stateWhole then
			return false
		end
		
	end
	if target:getEntityType() == EntityType.EntityType_Monster then
		if target:getId() == self:getPet() then
			return true
		end
	end
	return false
end

--切换目标：在使用技能出错时，调用
--Juchao@20140526: 增加出错计数处理
function HeroObject:switchTarget()
	local targetMgr = G_getFightTargetMgr()
	targetMgr:addUseSkillErrorCount()	
	
	if targetMgr:getUseSkillErrorCount() > MAX_USE_SKILL_ERROR_COUNT then	
		local target = targetMgr:getMainTargetObj()		
		if target and target:getEntityType() ~= EntityType.EntityType_Player then
			targetMgr:addToTargetIgnoreList(target:getId())	--将当前目标放入忽略列表里
			if not G_getHandupMgr():isHandup() then
				targetMgr:autoSelectTarget({}, E_SelectTargetType.Closest) 		
			else
				local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
				entityFocusManager:clearFocus()				
			end
		end
		targetMgr:clearUseSkillErrorCount()
	end
end

function HeroObject:canMountUp()
	if self.state:isState(CharacterState.CharacterStateMove) then
		return self:canChange(CharacterState.CharacterStateRideMove)
	else
		return self:canChange(CharacterState.CharacterStateRideIdle)
	end
end

function HeroObject:enterStateIdle()
	if self.hasMount then
		self:mountDown()
	end			
	self:changeAction(EntityAction.eEntityAction_Idle, true)
	GlobalEventSystem:Fire(GameEvent.EventHeroEnterIdle)
	return true
end

function HeroObject:comboStateCallback(state, bEnter)
	if state == CharacterState.CharacterStateCollect then
		-- 采集单独处理
		if bEnter == true then
			self:createPluckingAnimation()
			GlobalEventSystem:Fire(GameEvent.EventStartCollect)
			--print("HeroObject:comboStateCallback start collect")
		else			
			self:removePluckingAnimation()
			GlobalEventSystem:Fire(GameEvent.EventEndCollect)
			--print("HeroObject:comboStateCallback end collect")
		end
	elseif state == CharacterFightState.Paresis then
		--麻痹单独处理
		if  bEnter == true then
			FightStateEffect:Instance():enterState(state, self)
			self:forceStop()		
			local simulator = SFGameSimulator:sharedGameSimulator()
			local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Stop_Move)
			local x, y = self:getCellXY()
			writer:WriteInt(x)
			writer:WriteInt(y)			
			simulator:sendTcpActionEventInLua(writer)
		elseif bEnter == false then
			FightStateEffect:Instance():exitState(state, self)
		end			
	elseif state == CharacterFightState.Mofadun then
		if bEnter == true then
			local callbackFunc = function()
				FightStateEffect:Instance():enterState(state, self)
			end	
			
			local array = CCArray:create()	
			array:addObject(CCDelayTime:create(0.15))	
			array:addObject(CCCallFuncN:create(callbackFunc))
			local action = CCSequence:create(array)	
			
			local aniSprite = self:getRenderSprite():getChildByTag(101)
			if aniSprite == nil then
				local sprite = CCSprite:create()
				sprite:setTag(101)
				self:getRenderSprite():addChild(sprite)					
				sprite:runAction(action)
			else
				aniSprite:runAction(action)
			end
		else
			FightStateEffect:Instance():exitState(state, self)
		end		
	else
		if state and bEnter == true then
			FightStateEffect:Instance():enterState(state, self)
		elseif state and bEnter == false then
			FightStateEffect:Instance():exitState(state, self)
		end
	end
end

-- 死亡状态
function HeroObject:enterDeath()
	local ret = PlayerObject.enterDeath(self)
	local soundMgr = GameWorld.Instance:getSoundMgr()
	
	if PropertyDictionary:get_gender(self:getPT()) == ModeType.eGenderFemale then	
		soundMgr:playEffect("music/womandie.mp3" , false)								
	else		
		soundMgr:playEffect("music/mandie.mp3" , false)								
	end	
	-- 中断挂机, 中断
	GameWorld.Instance:getAutoPathManager():cancel()
	self:getHandupMgr():stop()
	return ret
end

function HeroObject:onEnterMap()
	if self.hasinitTitle then
		local sfmap = SFMapService:instance():getShareMap()
		if self.hpBarBg then
			sfmap:enterMap(self.hpBarBg, eRenderLayer_Effect)
		end
		if self.hpBar then
			sfmap:enterMap(self.hpBar, eRenderLayer_Effect)
		end
		
	else
		self:initHPBars()
		self.hasinitTitle = true	
	end

	self:updateTitleName(self.table)
	self:updateGildName(self.table,false)	
	self:updateKnightTitle(self.table)			
	self:updateVipIcon()
	self:updateTitle()
	self:updateSpeed()	
	self.renderSprite:setAlpha(255)
	
	local id = self:getId()
	GameWorld.Instance:getTextManager():setTiltleVisible(id,true)
	self:setTitleVisible(true)
	if self.tipMsgLable then
		self.tipMsgLable:setVisible(false)
	end
end

function HeroObject:requestChangeHeroPKState(stateId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Pk_Model)
	StreamDataAdapter:WriteShort(writer,stateId)	
	simulator:sendTcpActionEventInLua(writer)		
end
function HeroObject:setPKStateID(stateId)
	self.stateId = stateId
end

function HeroObject:getPKStateID()
	return self.stateId
end	

function HeroObject:changeHeroPKState(stateId)
	local nearbyMgr = GameWorld.Instance:getNearbyMgr()
	nearbyMgr:updateNearByPlayer()
	self:requestChangeHeroPKState(stateId)
end

function HeroObject:setActiveState(state)
	self.activeState = state
end

function HeroObject:getActiveState()
	return self.activeState
end	

--获取目标。如果不存在则进行选择
function HeroObject:getFightTargetWithSelect()
	local target = self:getFightTarget()
	if target then
		return target
	else
		return G_getFightTargetMgr():autoSelectTarget({})
	end
end	

function HeroObject:getFightTarget()
	return  G_getFightTargetMgr():getMainTargetObj()
end

function HeroObject:DoDeath()
	local mapMgr = GameWorld.Instance:getMapManager()
	if mapMgr:getCurrentMapKind() == MapKind.instanceArea then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_Revive)
		writer:WriteChar(0)
		simulator:sendTcpActionEventInLua(writer)
	else
		GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, true)
	end
	G_getHandupMgr():stop()
	local statelist = {}
	self.state:updateComboStateList(statelist)
	self.state:forceChangeState(CharacterState.CharacterStateDead, nil)
	G_getQuestLogicMgr():killAllAutoFindPath()	
end

function HeroObject:requestReviveInfo()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Player_KillerInfo)	
	simulator:sendTcpActionEventInLua(writer)
end

-- 复活
function HeroObject:DoRevive()
	-- 解锁状态g
	GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, false)
	PlayerObject.DoRevive(self)
	
	self:getPKHitMgr():setPKHitStateToNormal()--设置PK受击状态为普通
end

--zhibang@20140322  进出安全区提示
function HeroObject:InitSafeAreaTips()
	local scheduleCallback = function()
		self:showIsAtSafeArea()
	end
		
	local funcStateCallback = function (stateName, bEnter)
		if ((stateName == CharacterState.CharacterStateMove)  or  ( stateName == CharacterState.CharacterStateRideMove))  and bEnter == true then
			if not self.isAtSafeAreaSchedule then
				self.isAtSafeAreaSchedule =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(scheduleCallback, 0.05, false)
			end
		else
			if self.isAtSafeAreaSchedule then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.isAtSafeAreaSchedule)
				self.isAtSafeAreaSchedule = nil
			end
		end
	end	
	self:addStateChangeCallback(funcStateCallback)	
end

function HeroObject:isMoving()
	return self.moving
end

function HeroObject:sysHeroLocation()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Scene_Stop_Move)
	local stopCellx,stopCelly = self:getCellXY()
	writer:WriteInt(stopCellx)
	writer:WriteInt(stopCelly)			
	simulator:sendTcpActionEventInLua(writer)
end

--根据血量纠正英雄的死亡状态
function HeroObject:checkHeroDeathState()
	-- 如果血量为0, 显示复活界面
	local hp = PropertyDictionary:get_HP(self:getPT())
	if hp <= 0 then
		GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, true)
		self:DoDeath()
	else
		local state = self:getState()		
		if state and  
		  (state:isState(CharacterState.CharacterStateDead) or state:isState(CharacterState.CharacterStateWillDead)) then
			CCLuaLog("hero hp > 0. force Revive")
			GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, false)
			self:DoRevive()
		end	
	end
end
--重写，防止设置菜单把hero也进行设置
function HeroObject:updateWingModule()
	local wingId = PropertyDictionary:get_wingModleId(self.table)	
	if wingId ~= 0 then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,true)
		self:changePart(EntityParts.eEntityPart_Wing,wingId,constDefaultWing)		
		if self.moving then
			--如果是在坐骑上 则需要调用坐骑移动
			if self:getState():isState(CharacterState.CharacterStateRideMove) then
				self:changeAction(EntityAction.eEntityAction_RideRun, false)
			else
				self:changeAction(EntityAction.eEntityAction_Run, false)			
			end
		end
	else
		self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,false)
	end
end

--添加接口  用来设置英雄位置且同步镜头
function HeroObject:synHeroPosition(cellX,cellY)
	self:setCellXY(cellX,cellY)
	local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	local centerY = self:getCenterY()
	SFMapService:instance():getShareMap():setViewCenter(mapX, centerY)
	GlobalEventSystem:Fire(GameEvent.EventHeroMovement)			
end


-- 暂时不用此接口 yuanfan@2014.6.6
--[[function HeroObject:twinkleTip(tipMsg, duration)
	if self.tipMsgLable == nil then
		self.tipMsgLable = createRichLabel(CCSizeMake(0,0))
		self.tipMsgLable:setScaleY(-1)
		self:getRenderSprite():addChild(self.tipMsgLable)
		VisibleRect:relativePosition(self.tipMsgLable, self:getRenderSprite(), LAYOUT_CENTER,ccp(0,-60))
	end

	local id = self:getId()
	self.tipMsgLable:stopAllActions()
	GameWorld.Instance:getTextManager():setTiltleVisible(id,false)
	self:setTitleVisible(false)
	
	self.tipMsgLable:clearAll()
	for k,v in pairs(tipMsg) do	
		local text = string.wrapRich(v.word, v.color, fontsize)
		self.tipMsgLable:appendFormatText(text)
	end		
	self.tipMsgLable:setVisible(true)
	
	local sequenceArray1 = CCArray:create()	
	sequenceArray1:addObject(CCFadeIn:create(0.5))
	sequenceArray1:addObject(CCFadeOut:create(0.5))	
	local action = CCSequence:create(sequenceArray1)
	local action1 = CCRepeatForever:create(action)
	
	local finishCallback = function()
		self.tipMsgLable:stopAllActions()
		GameWorld.Instance:getTextManager():setTiltleVisible(id,true)
		self:setTitleVisible(true)
		self.tipMsgLable:setVisible(false)
	end
	
	local sequenceArray2 = CCArray:create()
	sequenceArray2:addObject(CCDelayTime:create(duration))
	sequenceArray2:addObject(CCCallFunc:create(finishCallback))	
	local action2 = CCSequence:create(sequenceArray2)

	self.tipMsgLable:runAction(action1)
	self.tipMsgLable:runAction(action2)
end--]]

