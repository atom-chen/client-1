--[[
���ܱ��ݵĹ���
]]
require "common.baseclass"
require "object.skillShow.player.CharacterActionPlayer"
require "object.skillShow.template.SkillTemplate"

TemplateFactory = TemplateFactory or BaseClass()

local heroFaceMask = {}
heroFaceMask["0,-1"] = 0
heroFaceMask["-1,-1"] = 7
heroFaceMask["-1,0"] = 6
heroFaceMask["-1,1"] = 5
heroFaceMask["0,1"] = 4
heroFaceMask["1,1"] = 3
heroFaceMask["1,0"] = 2
heroFaceMask["1,-1"] = 1

--[[�����ӵ��ĵ�����ͨ�ܻ�
casterId: 		ʩ���ߵ�simId
casterType:		ʩ���ߵ�����
targetId: 		Ŀ���simId
targetType::	Ŀ�������
]]
function TemplateFactory:createCharacterTemplate(casterId, casterType, casterAction, targetId, targetType, targetAction)
	local template = SkillTemplate.New()
	
	-- �����ߵĶ���
	local attackPlayer = CharacterActionPlayer.New()
	attackPlayer:setPlayAction(casterId, casterType, casterAction, 0)
	template:addAttackPlayer(attackPlayer)
	
	-- �������ߵĶ���
	local targetPlayer = CharacterActionPlayer.New()
	targetPlayer:setPlayAction(targetId, targetType, targetAction, 0)
	template:addTargetPlayer(targetPlayer)
	
	return template
end

--[[�����ӵ��ĸ�����ͨ�ܻ�
casterId: 		ʩ���ߵ�simId
casterEffectId: ʩ�������ϱ��ݵĶ���ID�� ���Ϊ0�ͺ������ѡ��
targetGridId: 	Ŀ����ӵ�simId
targetEffectId: Ŀ����ӵı��ݵĶ���ID�� ���Ϊ0�ͺ������ѡ��
]]
function TemplateFactory:createGridTemplate(casterId, casterType, targetGridId, targetEffectId)
	
end

--[[���ӵ��ĵ�����ͨ����
casterId: 		ʩ���ߵ�simId
casterEffectId: ʩ�������ϱ��ݵĶ���ID�� ���Ϊ0�ͺ������ѡ��
targetId: 		Ŀ���simId
targetEffectId: Ŀ�����ϵı��ݵĶ���ID�� ���Ϊ0�ͺ������ѡ��
bulletModelId:	�ӵ���ģ��id
]]
function TemplateFactory:createCharacterBulletTemplate(casterId, casterEffectId, targetId, targetEffectId, bulletEffectId)
	
end

function TemplateFactory:faceToTarget(character, targetCellX, targetCellY)
	if not character or not targetCellX or not targetCellY then
		return
	end
end

function TemplateFactory:getFaceDir(startX, startY, endX, endY)
	if not startX or not startY or not endX or not endY then
		return 4
	end
	
	local dx = endX - startX
	local dy = endY - startY
	local dxFlag = dx
	if dxFlag ~= 0 then
		dxFlag = dx / math.abs(dx)
	end
	
	local dyFlag = dy
	if dyFlag ~= 0 then
		dyFlag = dy / math.abs(dy)
	end
	
	local key = dxFlag..","..dyFlag
	return heroFaceMask[key]
end

function TemplateFactory:adjustPosition(character, posX, posY)
	if not character or not posX or not posY then
		return
	end
	
	local targetX, targetY = character:getCellXY()
	local maxDistance = const_aoiCellSize*2
	--local maxDistance = 0
 	if math.abs(targetX-posX) > maxDistance or math.abs(targetY-posY) > maxDistance then
		-- ������볬��2��AOI���ӣ�ֱ�Ӹı�object��λ��
		character:setCellXY(posX, posY)
	end
end

--[[
Ұ����ײҪ���⴦��
]]
function TemplateFactory:createSkillZs5(skillData)
	if skillData == nil or string.find(skillData["skillRefId"], "skill_zs_5") == nil then
		return nil
	end
	
	local template = SkillTemplate.New()
	local casterObject = GameWorld.Instance:getEntityManager():getEntityObject(skillData["attackType"], skillData["attackerId"])
	if casterObject and skillData["effects"] then
		local target = nil
		local speed = 400
		
		local casterPt = ccp(casterObject:getMapXY())
		
		for k,v in pairs(skillData["effects"]) do
			if v:getType() == E_SkillEffectType.Transport then
				-- ֻ����˲��
				local params = v:getEffectParam()
				
				target = GameWorld.Instance:getEntityManager():getEntityObject(v:getEntityType(), v:getServerId())
				if target then
					local startCellX = params["startX"]
					local startCellY = params["startY"]
					local endCellX = params["endX"]
					local endCellY = params["endY"]
					self:adjustPosition(target, startCellX, startCellY)
					local originalPt = ccp(target:getMapXY())
					
					local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(endCellX, endCellY)
					local targetPt = ccp(mapX, mapY)
					
					if target and v:getServerId() == skillData["attackerId"] then
						-- �����ߵĶ���
						local casterSeq = SequenceAnimate.New()
						
						local spawnGroup = SpawnAnimate.New()
						if casterObject:getId() == G_getHero():getId() then
							local  soundPlayer = AnimateFactory:getSoundPlayer("skill_zs_5_1")
							spawnGroup:addPlayer(soundPlayer)
						end
						local flyPlayer = CharacterActionHitBackPlayer.New()
						flyPlayer:setActionId(EntityAction.eEntityAction_Idle)
						flyPlayer:setCharacter(v:getEntityType(), v:getServerId())
						flyPlayer:setTargetCell(endCellX, endCellY)
						flyPlayer:setTime(0.5)
						spawnGroup:addPlayer(flyPlayer)
						local casterCellX , casterCellY  = casterObject:getCellXY()
						
						local dir = -1
						if casterCellX ~= endCellX or casterCellY ~= endCellY then  --��ͬ����ת��
							dir = self:getFaceDir(casterCellX, casterCellY, endCellX, endCellY)
						else
							local targetObj =   GameWorld.Instance:getEntityManager():getEntityObject(  skillData["targetType"],skillData["targetId"])
							if targetObj then
								local targX ,targY = targetObj:getCellXY()
								dir = self:getFaceDir(casterCellX, casterCellY, targX, targY)
							end
						end
						
						if dir and dir ~= -1 then
							casterObject:getRenderSprite():setAngle(dir) 
						end
						
						-- ����ʩ���߱���
						local hideCharacter = CharacterAlphaPlayer.New()
						hideCharacter:setCharacter(v:getEntityType(), v:getServerId())
						hideCharacter:setAlpha(0)
						spawnGroup:addPlayer(hideCharacter)
						
						if SkillShowManager:getDisplayEffect() then
							local skillAniPlayer =  CharacterAnimatePlayer.New()
							skillAniPlayer:setPlayData(v:getServerId(), v:getEntityType(), 7040)
							skillAniPlayer:setDirection(casterObject:getAngle())
							spawnGroup:addPlayer(skillAniPlayer)
						end
						casterSeq:addPlayer(spawnGroup)
						
						-- ��ʾʩ����
						local showCharacter = CharacterAlphaPlayer.New()
						showCharacter:setCharacter(v:getEntityType(), v:getServerId())
						showCharacter:setAlpha(255)
						casterSeq:addPlayer(showCharacter)
						
						template:addAttackPlayer(casterSeq)
						
						local distance = ccpDistance(originalPt, targetPt)
						if distance > 0 then
							speed = distance/0.5
						end
					else
						-- �ܻ��ߵĶ���
						local distance = ccpDistance(originalPt, targetPt)
						
						local flyPlayer = CharacterActionFlyPlayer.New()
						flyPlayer:setActionId(EntityAction.eEntityAction_Hit)
						flyPlayer:setCharacter(v:getEntityType(), v:getServerId())
						flyPlayer:setTargetCell(endCellX, endCellY)
						flyPlayer:setTime(distance/speed)
						
						-- ������ҵ�����ľ��壬����һ���ӳ�
						local delayTime = ccpDistance(casterPt, originalPt)*0.2/speed
						
						local delayPlayer = DelayPlayer.New()
						delayPlayer:setDelayTime(delayTime)
						
						local sequence = SequenceAnimate.New()
						sequence:addPlayer(delayPlayer)
						sequence:addPlayer(flyPlayer)
						
						template:addAttackPlayer(sequence)
					end
				end
			end
		end
	end
	
	return template
end

--[[
-- ���ܻ�
]]
function TemplateFactory:createSkillFs2(skillData, bShowCaster)
	if skillData == nil or skillData["skillRefId"] ~= "skill_fs_2" then
		return nil
	else
		local template = SkillTemplate.New()
		local casterObject = GameWorld.Instance:getEntityManager():getEntityObject(skillData["attackType"], skillData["attackerId"])
		
		if casterObject and casterObject:getId() == G_getHero():getId() then
			local  soundPlayer = AnimateFactory:getSoundPlayer("skill_fs_2_1")
			template:addAttackPlayer(soundPlayer)
		end
		
		if casterObject and bShowCaster then
			if SkillShowManager:getDisplayEffect() then
				local skillAniPlayer =  CharacterAnimatePlayer.New()
				skillAniPlayer:setPlayData(casterObject:getId(), casterObject:getEntityType(), 7070)
				template:addAttackPlayer(skillAniPlayer)
			end
			
			local actionPlayer = CharacterActionPlayer.New()
			actionPlayer:setPlayAction(casterObject:getId(), casterObject:getEntityType(), ActionType.ActionTypeAttack, 7)
			template:addAttackPlayer(actionPlayer)
			
		end
		
		if skillData and skillData["effects"] then
			for k,v in pairs(skillData["effects"]) do
				if v:getType() == E_SkillEffectType.Transport then
					-- ֻ����˲��			
					target = GameWorld.Instance:getEntityManager():getEntityObject(v:getEntityType(), v:getServerId())
					
					if target then
						-- �����ߵĶ���
						local params = v:getEffectParam()	
						local startCellX = params["startX"]
						local startCellY = params["startY"]
						local endCellX = params["endX"]
						local endCellY = params["endY"]
						
						self:adjustPosition(target, startCellX, startCellY)
						
						local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(endCellX, endCellY)
						local targetPt = ccp(mapX, mapY)
						
						local flyPlayer = CharacterActionHitBackPlayer.New()
						flyPlayer:setActionId(EntityAction.eEntityAction_Hit)
						flyPlayer:setCharacter(v:getEntityType(), v:getServerId())
						flyPlayer:setTargetCell(endCellX, endCellY)
						flyPlayer:setTime(0.5)
						
						template:addHitPlayer(flyPlayer)
					end
				end
			end
		end
		
		return template
	end
end
--[[
˲���ƶ�Ҫ���⴦��
]]

function TemplateFactory:createSkillFs5(skillData)
	if skillData == nil or skillData["skillRefId"] ~= "skill_fs_5" then
		return nil
	else
		local casterObject = GameWorld.Instance:getEntityManager():getEntityObject(skillData["attackType"], skillData["attackerId"])
		if not casterObject then
			return nil
		end
		local template = SkillTemplate.New()
		local casterSeq = SequenceAnimate.New()
		local spawnGroupBegin = SpawnAnimate.New()
		
		if casterObject:getId() == G_getHero():getId() then
			local  soundPlayer = AnimateFactory:getSoundPlayer("skill_fs_5_1")
			spawnGroupBegin:addPlayer(soundPlayer)
		end
		
		if SkillShowManager:getDisplayEffect() then
			local skillAniPlayer =  CharacterAnimatePlayer.New()
			skillAniPlayer:setPlayData(casterObject:getId(), casterObject:getEntityType(), 7100)
			skillAniPlayer:setDirection(0)
			spawnGroupBegin:addPlayer(skillAniPlayer)
		end
		
		-- ����ʩ���߱���
		local hideCharacter = CharacterAlphaPlayer.New()
		hideCharacter:setCharacter(casterObject:getEntityType(), casterObject:getId())
		hideCharacter:setAlpha(0)
		spawnGroupBegin:addPlayer(hideCharacter)
		
		casterSeq:addPlayer(spawnGroupBegin)
		
		local delayPlayer = DelayPlayer.New()
		delayPlayer:setDelayTime(0.1)
		casterSeq:addPlayer(delayPlayer)
		
		
		local spawnGroupEnd = SequenceAnimate.New()
		local effect = skillData["effects"]
		if effect then
			local params = effect[1].effectParam
			if params then
				local gameMapManager = GameWorld.Instance:getMapManager()
				local mapX ,mapY = gameMapManager:cellToMap(params["endX"],params["endY"])
				if mapX and  mapY then
					local posPlayer = CharacterPositionPlayer.New()
					posPlayer:setPosition(ccp(mapX, mapY))
					posPlayer:setCharacter(casterObject:getEntityType(), casterObject:getId())
					spawnGroupEnd:addPlayer(posPlayer)
				end
			end
		end
		-- ��ʾʩ����
		local showCharacter = CharacterAlphaPlayer.New()
		showCharacter:setCharacter(casterObject:getEntityType(), casterObject:getId())
		showCharacter:setAlpha(255)
		spawnGroupEnd:addPlayer(showCharacter)
		casterSeq:addPlayer(spawnGroupEnd)
		if casterObject:getId() == G_getHero():getId() then
			local  soundPlayer = AnimateFactory:getSoundPlayer("skill_fs_5_4")
			spawnGroupEnd:addPlayer(soundPlayer)
		end
		if SkillShowManager:getDisplayEffect() then
			local skillAniPlayer =  CharacterAnimatePlayer.New()
			skillAniPlayer:setPlayData(casterObject:getId(), casterObject:getEntityType(), 7101)
			skillAniPlayer:setDirection(0)
			spawnGroupEnd:addPlayer(skillAniPlayer)
		end
		
		
		template:addAttackPlayer(casterSeq)
		
		return template
	end
end


