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
	self.type = EntityType.EntityType_Player	-- ����	
	--���� ��������ʵ��BagMgr
	self.bagMgr = nil
	self.skillMgr = nil
	self.rechargeMgr = nil
	--���� �������ʵ��QuestMgr
	self.questMgr = nil	
	-- ���� ���ѹ���ʵ��friendMgr
	self.friendMgr = nil	
	self.equipMgr = nil
	self.debugMgr = nil
	--�������ʵ��
	self.chatMgr = ChatMgr.New()
	--������ʵ��
	self.wingMgr = nil
	self.knightMgr = nil
	self.achievementMgr = nil
	
	self.forgingMgr = nil
	self.movePathes = nil
	self.targetPoints  = {}
	--��ǿ������ڹ���ʵ��
	self.strengthenQuest = nil
	--�ʼ�����ʵ��
	self.mailMgr = nil
	self.handupMgr = nil
	self.teamMgr = nil
	self.factionMgr = nil
	self.mainMgr = nil
	self.heroStateMgr = nil
	
	--ɳ�Ϳ˹��ǹ���
	self.castleWarMgr = nil
	self.objectMgr = {}
	--��������
	self.monstorInvasionMgr = nil
	self.PKHitMgr = nil
	self.hasTips = false
	-- �һ�������
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
	
	--Juchao@20140808: ��������֮����Ҫ����Ӣ���������״̬
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

-- ǿ��ֹͣ�ƶ�
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
--����ʧ�ܻ�ɹ�
function HeroObject:moveTo(x, y)
	-- �͵�ǰ���겻��ͬ�Ž���������߼�
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
	-- ת��ΪAOI�ĸ���
	local newTargetX, newTargetY = GameWorld.Instance:getMapManager():convertToAoiCell(x, y)
	
	if self:fightCharacterMoveTo(newTargetX,newTargetY) then
		self.movePathes = {}		
		local array = self.move:getMovePoints(0,0,0,0)
		self:createMovePath(array,self.movePathes)
		self:findPathTargetPoint(self.movePathes)
		--Juchao@20140521: ����Ҫ�ֶ�ɾ�����״̬���������ᷢ��ϲɼ�����Ϣ������
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
		-- ��������ƶ���Ҫͣ��
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

-- �л�Ϊ�ܻ�״̬
function HeroObject:enterBeHit(callback)
	local state = PlayerObject.enterBeHit(self,callback)
	local soundMgr = GameWorld.Instance:getSoundMgr()
			
	if state == true and math.random() < 0.2 then --ʮ��֮һ�ļ��ʲ���
		if PropertyDictionary:get_gender(self:getPT()) == ModeType.eGenderFemale then	
			soundMgr:playEffect("music/womanbeat.mp3")								
		else		
			soundMgr:playEffect("music/manbeat.mp3")
		end
	end
	return state
end

function HeroObject:exitStateMove(newState)
	-- �����״̬����RideMove, ��Ӧ��Ҫͣ���ƶ�
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
	-- �����״̬�����ƶ�,  �Ϳ��԰��ƶ�ֹͣ��
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
	-- �ƶ�����ͷ
	local cellX,cellY = self:getCellXY()
	
	if self:hasTargetPoints(cellX,cellY) then
		
		if self.isprocessing ~= true then
			self:processPathPoint()
			self.isprocessing = false
		end
	end
	self:adjustPosition(time)
	self:handleFirstPoint(cellX,cellY)
	-- manager��tick
	if self.skillMgr then
		self.skillMgr:tick(time)
	end
	
	if self.bagMgr then
		self.bagMgr:update(time) 	--����CD
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

-- ����ģ��ID
function HeroObject:setMountModelId(mountModelId)
	self.mountModelId = mountModelId
end

function HeroObject:getMountModelId()
	return self.mountModelId
end

-- ����ģ��ID
function HeroObject:setWeaponId(weaponId)
	self.weaponId = weaponId
	--	CCLuaLog("HeroObject:setWeaponId:"..weaponId)
end

function HeroObject:getWeaponId()
	return self.weaponId
end

-- �·�ģ��ID
function HeroObject:setClothId(clothId)
	self.clothId = clothId
end

function HeroObject:getClothId()
	return self.clothId
end

-- ���ģ��ID
function HeroObject:setWingId(wingId)
	self.wingId = wingId
end

function HeroObject:getWingId()
	return self.wingId
end

-- �Ƿ��ܹ�ʹ��ĳ�����ܵ�ͳһAPI
function HeroObject:canUseSkill(skillRefId)
	--�ж�״̬��
	if self.state:isState(CharacterState.CharacterStateUseSkill) or self.state:canChange(CharacterState.CharacterStateUseSkill) == false then
		return false, nil, CannotUseSkillReason.stateError
	end
	
	local canUse, skillObject = self.skillMgr:canUseSkill(skillRefId)
	if (not canUse) or (skillObject == nil) then
		return false, nil, CannotUseSkillReason.cannotUseNow
	end
					
	--�ǳ�����&&Ŀ������Ϊ�з��ļ��ܣ���Ҫ�кϷ���ս��Ŀ�����ʹ�� 
	if skillObject:needFightTarget() then
		if not self:getFightTargetWithSelect() then	--Juchao@20140724: �����Զ�ѡĿ��
--		if not self:getFightTarget() then
			return false, nil, CannotUseSkillReason.targetError
		end
	end
	return true, skillObject
end	

--skillRefId: ���ܵ�refId
--bMove�����������Χ���ԣ��Ƿ��ƶ���������Χ����ʹ��
--bLater: �Ƿ�����һ֡��ʹ�ã�������Ϊ������ʹ�ã�
--����ֵ��1. ʹ�ý��ret 2.ʹ�ü��ܵ�action
function HeroObject:useSkillWithCheck(skillRefId, bMove, bLater, bHandup)
	local canUse, skillObject = self:canUseSkill(skillRefId)
	if (not canUse) or (skillObject == nil) then
		return false
	end
	if self:isMovingToUseSkill() then
		return false
	end
		
	--����Ƿ�Ϊ���⼼�ܣ�������Ӧ����	
	if self:checkSpecialSkill(skillRefId) then
		return false
	end
	
	-- ��ͨ���Ա��滻����������
	if skillRefId == const_skill_pugong then
		skillRefId = self.skillMgr:checkReplaceSkill(skillRefId)
	end
		
	local target = nil
	--�ǳ�����&&�ط����ܣ���Ҫ�кϷ���ս��Ŀ��ſ���ʹ��(�����׹����⴦��)
	if skillObject:needFightTarget() 
	   or (bHandup and string.find(skillRefId, "skill_fs_10")) then	--Juchao@20140515: ����ǹһ�״̬���׵�籩��ҪĿ��
		--��ȡһ���Ϸ���ս��Ŀ��			
		target = self:getFightTarget()
		if (target == nil) then
			return false
		end
		
		--���ڹ�����Χ�ڣ���Ҫ�����ƶ�
		local skillRange = PropertyDictionary:get_skillRange(skillObject:getStaticData())
		if not (skillRange > 0) then
			skillRange = 1
		end
		if (self:isInAttackRange(skillRange, target) ~= true) then	
			if bMove then			
				local moveAction = self:addMoveToTargetAction(target, skillRange )	
				if target:getEntityType() == EntityType.EntityType_Monster then
					moveAction:setMaxPlayCount(-1)	--����ǹ���ͻ�һֱ����׷��
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
	--���ָ������һ֡��ʹ�ã��������Ϊ����
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

--ɾ���ϴε�ʹ�ü���
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

--����Ƿ�Ϊ���⼼�ܣ�������Ӧ����
function HeroObject:checkSpecialSkill(skillRefId)
	-- �һ𽣷��Ƚ����⣬ʹ��Ч��Ϊ����һ���κμ��ܽ����滻Ϊ�һ𽣷�
	local bSpecialSkill = (string.find(skillRefId, "skill_zs_6")  ~= nil)		
	if bSpecialSkill then
		self.skillMgr:setReplaceSkill(skillRefId, 10)
		return true
	else
		return false
	end
end

--�ƶ��Ķ���
function HeroObject:addMoveToTargetAction(target, stopDistance)
	local action = MoveToTargetActionPlayer.New()
	action:setTargetInfo(target:getId(), target:getEntityType())
	action:setStopDistance(stopDistance)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--ʹ�ü��ܵĶ���
function HeroObject:addUseSkillAction(skillRefId)
	local action = UseSkillActionPlayer.New()
	action:setSkillRefId(skillRefId)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--�ɼ��Ķ���
function HeroObject:addCollectAction(npcId)
	
	local action = CollectActionPlayer.New()
	action:setNpcTarget(npcId)
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--ʰȡ�Ķ���
function HeroObject:addPickupAction()
	local action = PickupActionPlayer.New()	
	ActionPlayerMgr.Instance:addPlayer(self:getId(), action)
	return action
end

--�ж�Ŀ���Ƿ��ڹ�����Χ��
function HeroObject:isInAttackRange(skillRange, target)
	if skillRange and target then
		local distance = HandupCommonAPI:objAoiDistance(target, self)
		return skillRange >=  distance
	else
		return false
	end
end

--�ж��Ƿ��Ŀ���ص����Դ����Ϊ׼��80 * 80��
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

-- ��ȡװ�������ĸ߼�����
-- Ĭ����ȫ��װ���б�
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
			-- ͬһ��װ�������в�ͬ�Ĳ�λ 
			for k,v in pairs(equip) do
				local equipRefId = v:getRefId()
				
				-- ȷ����û�����refId
				if GameData.EquipItem[equipRefId] then
					local equipSkillRef = PropertyDictionary:get_skillRefId(GameData.EquipItem[equipRefId]["property"])
					
					-- ���equipSkillRef������skillRefId, ��skillRefId����Ҫ���滻
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

-- ʹ�ü���, �����ж��ں��������
-- ���жϹ�����Χ��������Ϊ�����Ƿ�������������Ҫ�ж���ʹ��useSkillWithCheck()����
function HeroObject:useSkill(skillRefId)
	local skillObject = self.skillMgr:getSkillObjectByRefId(skillRefId)
	
	if (skillObject) then
		--  ʹ����ͨ����Ҫ�ж������Ƿ��п��ؼ���
		if skillRefId == const_skill_pugong then
			-- ����Ƿ��м���Ҫ�滻
			skillRefId = self.skillMgr:checkReplaceSkill(skillRefId)
		end
		
		skillRefId = self:getEquipSkill(skillRefId)
		
		-- �ж�Ŀ�������
		local selectTarget = self:getFightTarget()
		local sendUseSkill = false
		
		local skillAimType = PropertyDictionary:get_skillAimType(skillObject:getStaticData())
		local targetType = PropertyDictionary:get_skillTargetType(skillObject:getStaticData())
		if 1 == targetType then
			-- �ѷ�
			if 1 == skillAimType or 3 == skillAimType then
				-- ���Ŀ�겻���ѷ�
				if not self:isFriend(selectTarget) then
					selectTarget = self
				end
			end
			
			sendUseSkill = true
		elseif 0 == targetType then
			--�Լ�
			selectTarget = self
			sendUseSkill = true
		else	
			-- �з�					
			if (1 == skillAimType or 3 == skillAimType) then
				--��Ŀ��ļ���, ���ܶ��Լ��ͷ�				
				sendUseSkill = (selectTarget ~= nil and self:getId() ~= selectTarget:getId())
			elseif 2 == skillAimType then
				--����
				sendUseSkill = true
			end
			
			--�ж�Ŀ���Ƿ�Ϊ��Ҳ���ǰ״̬Ϊ�Ǻ�ƽģʽ
			if selectTarget and selectTarget:getEntityType() == EntityType.EntityType_Player and self:getPKStateID()~=E_HeroPKState.statePeace then				
				--����PK�ܻ�״̬ΪPK
				self:getPKHitMgr():setPKHitStateToPK()
			end	
		end
		
		-- �Լ��ļ�����ǰ����
		if sendUseSkill then
			local mgr = GameWorld.Instance:getMountManager()
			-- ��������ϣ�Ҫ��������
			if mgr:getMountState() == 1 then
				mgr:requestMountRide(1)
				self:mountDown()
			end
			
			if self.moving then
				self:moveStop()
				self:sysHeroLocation()
			end
			
			-- ��������ǿ�Ѫ�Ļ������߷����������������
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

--�ж�Ŀ���Ƿ�Ϊ�ѷ�
function HeroObject:isFriend(target)
	if not target then
		return false
	end
	if target:getEntityType() == EntityType.EntityType_Player then --TODO�������ʱ����Ҫ����PKģʽ���жϸ�����Ƿ��ѷ�
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

--�л�Ŀ�꣺��ʹ�ü��ܳ���ʱ������
--Juchao@20140526: ���ӳ����������
function HeroObject:switchTarget()
	local targetMgr = G_getFightTargetMgr()
	targetMgr:addUseSkillErrorCount()	
	
	if targetMgr:getUseSkillErrorCount() > MAX_USE_SKILL_ERROR_COUNT then	
		local target = targetMgr:getMainTargetObj()		
		if target and target:getEntityType() ~= EntityType.EntityType_Player then
			targetMgr:addToTargetIgnoreList(target:getId())	--����ǰĿ���������б���
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
		-- �ɼ���������
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
		--��Ե�������
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

-- ����״̬
function HeroObject:enterDeath()
	local ret = PlayerObject.enterDeath(self)
	local soundMgr = GameWorld.Instance:getSoundMgr()
	
	if PropertyDictionary:get_gender(self:getPT()) == ModeType.eGenderFemale then	
		soundMgr:playEffect("music/womandie.mp3" , false)								
	else		
		soundMgr:playEffect("music/mandie.mp3" , false)								
	end	
	-- �жϹһ�, �ж�
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

--��ȡĿ�ꡣ��������������ѡ��
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

-- ����
function HeroObject:DoRevive()
	-- ����״̬g
	GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, false)
	PlayerObject.DoRevive(self)
	
	self:getPKHitMgr():setPKHitStateToNormal()--����PK�ܻ�״̬Ϊ��ͨ
end

--zhibang@20140322  ������ȫ����ʾ
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

--����Ѫ������Ӣ�۵�����״̬
function HeroObject:checkHeroDeathState()
	-- ���Ѫ��Ϊ0, ��ʾ�������
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
--��д����ֹ���ò˵���heroҲ��������
function HeroObject:updateWingModule()
	local wingId = PropertyDictionary:get_wingModleId(self.table)	
	if wingId ~= 0 then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,true)
		self:changePart(EntityParts.eEntityPart_Wing,wingId,constDefaultWing)		
		if self.moving then
			--������������� ����Ҫ���������ƶ�
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

--��ӽӿ�  ��������Ӣ��λ����ͬ����ͷ
function HeroObject:synHeroPosition(cellX,cellY)
	self:setCellXY(cellX,cellY)
	local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	local centerY = self:getCenterY()
	SFMapService:instance():getShareMap():setViewCenter(mapX, centerY)
	GlobalEventSystem:Fire(GameEvent.EventHeroMovement)			
end


-- ��ʱ���ô˽ӿ� yuanfan@2014.6.6
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

