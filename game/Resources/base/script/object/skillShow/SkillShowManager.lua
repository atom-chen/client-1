--[[
�����ܱ��ݵ��߼�
]]
require"data.skill.skill"
require("common.baseclass")
require("object.skillShow.player.TextPlayer")
require("object.skillShow.player.CharacterAnimatePlayer")
require("object.skillShow.player.CharacterActionPlayer")
require("object.skillShow.player.MapAnimatePlayer")
require("object.skillShow.player.BulletAnimatePlayer")
require("object.skillShow.player.CharacterAlphaPlayer")
require("object.skillShow.player.CharacterPositionPlayer")
require("object.skillShow.player.BulletAnimatePlayer")
require("object.skillShow.player.CharacterActionFlyPlayer")
require("object.skillShow.player.CharacterActionHitBack")
require("object.skillShow.player.DeathPlayer")
require("object.skillShow.player.SoundPlayer")
require("object.skillShow.template.SkillTemplate")
require("object.skillShow.template.TemplateFactory")
require("object.skillShow.MapEffectPresenter")
require("object.skillShow.CharacterEffectPresenter")
require("object.skillShow.AnimateFactory")
require("utils.PropertyDictionary")
require("config.animate")
require("config.MonsterSoundConfig")
require("object.actionPlayer.MoveActionPlayer")
require("object.actionPlayer.SkillShowPlayer")

SkillShowManager = SkillShowManager or BaseClass()

E_SkillEffectType =
{
Miss = 0,
HP = 1,
Hit = 2,
Dead = 3,
Fortune = 4
}

local isDisplayEffect = true
local mapEffectPresenter = nil
local characterEffectPresenter = nil

function SkillShowManager:getDisplayEffect()
	return isDisplayEffect
end

-- �Ƿ���ʾ���е���Ч
function SkillShowManager:setDisplayEffect(isShow)
	isDisplayEffect = isShow
end

-- ��ȡ������Ч��չʾ��
function SkillShowManager:getMapEffectPresenter()
	if mapEffectPresenter == nil then
		mapEffectPresenter = MapEffectPresenter.New()
	end
	
	return mapEffectPresenter
end

-- ��ȡ��ɫЧ����չʾ��
function SkillShowManager:getCharacterEffectPresenter()
	if characterEffectPresenter == nil then
		characterEffectPresenter = CharacterEffectPresenter.New()
	end
	
	return characterEffectPresenter
end

function SkillShowManager:handleSkillUse(skillEffect)
	if skillEffect then
		local hero = GameWorld.Instance:getEntityManager():getHero()
		
		local adjustTarget = false
		local adjustCaster = false
		
		if skillEffect["targetType"] and skillEffect["targetType"] == EntityType.EntityType_Player 
			and skillEffect["attackType"] and skillEffect["attackType"] == EntityType.EntityType_Player then
			-- ֻ�����֮��PK����λ�ò���
			adjustTarget = self:adjustPlayerPos(skillEffect["targetX"], skillEffect["targetY"], 
			skillEffect["targetType"], skillEffect["targetId"], skillEffect)
			adjustCaster = self:adjustPlayerPos(skillEffect["attackX"], skillEffect["attackY"], 
			skillEffect["attackType"], skillEffect["attackerId"], skillEffect)
		elseif skillEffect["targetType"] and skillEffect["targetType"] == EntityType.EntityType_Monster  then
			-- ���һ�¹����λ��, �����ʵ��λ����� >= 2��AOI����, ǿ�ƾ���һ�¹����λ��
			self:adjustMonsterPos(skillEffect["targetX"], skillEffect["targetY"], skillEffect["targetType"] and skillEffect["targetId"])
		elseif skillEffect["attackType"] and skillEffect["attackType"] == EntityType.EntityType_Monster then
			-- ���һ�¹����λ��, �����ʵ��λ����� >= 2��AOI����, ǿ�ƾ���һ�¹����λ��
			self:adjustMonsterPos(skillEffect["targetX"], skillEffect["targetY"], skillEffect["attackType"] and skillEffect["attackerId"])
		end			
		
		if not adjustTarget and not adjustCaster then
			-- ˢ��cd
			if hero:getId() == skillEffect["attackerId"] then
				hero:getSkillMgr():handleUseSkill(skillEffect["skillRefId"])
			end
			
			if hero:getId() == skillEffect["attackerId"] and SkillShowManager:isSkillPrePlay(skillEffect["skillRefId"]) then
				-- �Լ��ļ���
				SkillShowManager:handleHeroSkillUse(skillEffect)
			else
				SkillShowManager:handleSingleSkillUse(skillEffect)
			end
		end
	end
end	

function SkillShowManager:adjustMonsterPos(targetAttackX, targetAttackY, targetType, targetId, skillEffect)
	if targetType ~= EntityType.EntityType_Monster or not targetAttackX or not targetAttackY or not targetType or not targetId then
		return
	end
	
	local targetObj = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
	if not targetObj then
		return
	end
	
	local targetX, targetY = targetObj:getCellXY()
	local maxDistance = const_aoiCellSize*2
 	if math.abs(targetX-targetAttackX) > maxDistance or math.abs(targetY-targetAttackY) > maxDistance then
		-- ������볬��2��AOI���ӣ�ֱ�Ӹı�object��λ��
		targetObj:setCellXY(targetAttackX, targetAttackY)
	end
end

function SkillShowManager:adjustPlayerPos(targetAttackX, targetAttackY, targetType, targetId, skillEffect)
	-- ��Ӣ���Լ�������, playerObject����Ĳ�����
	local hero = GameWorld.Instance:getEntityManager():getHero()
	if targetType ~= EntityType.EntityType_Player or (hero and hero:getId() == targetId) then
		return false
	end
	
	if targetType and targetId and targetAttackX and targetAttackY and skillEffect then
		local ret = false
		local targetObj = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
		if targetObj and not targetObj:getState():isState(CharacterState.CharacterStateMove) 
			and  not targetObj:getState():isState(CharacterState.CharacterStateRideMove) then
			local targetX, targetY = targetObj:getCellXY()
			if math.abs(targetX-targetAttackX) > const_aoiCellSize or math.abs(targetY-targetAttackY) > const_aoiCellSize then
				-- ������볬��2��AOI���ӣ�ֱ�Ӹı�object��λ��
				targetObj:setCellXY(targetAttackX, targetAttackY)
			elseif targetX ~= targetAttackX or targetY ~= targetAttackY then
				-- ��1��AOI�ڣ����ٱ����ƶ��͹���
				ret = true
				
				-- �ȼ����ƶ�
				local moveAction = MoveActionPlayer.New()
				moveAction:setCharacter(targetId, targetType)
				moveAction:setCellXY(targetAttackX, targetAttackY)
				moveAction:setMoveSpeedPer(1.2)
				
				-- �󹥻�
				local skillShowAction = SkillShowPlayer.New()
				skillShowAction:setSkillShowData(skillEffect)
				
				ActionPlayerMgr.Instance:addPlayer(targetId, moveAction)
				ActionPlayerMgr.Instance:addPlayer(targetId, skillShowAction)
			end
		end
		
		return ret
	else
		return false
	end
end

-- �����Լ��ļ��ܵķ���, �Լ��ŵļ����Ѿ���ǰ���˼��ܱ��ݣ�ֻ��Ҫ�����ܻ���Ʈ��
function SkillShowManager:handleHeroSkillUse(skillUserInfo)
	if type(skillUserInfo) ~= "table" then
		CCLuaLog("handleHeroSkillUse with error skillUserInfo")
		return
	end
	
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	local skillRefId = skillUserInfo["skillRefId"]
	local skillObject = skillMgr:getSkillObjectByRefId(skillRefId)
	
	if skillObject == nil then
		CCLuaLog("can't get skill of id:"..skillRefId)
		self:performDeath(skillUserInfo["effects"])
		return
	end
	
	if skillRefId == "skill_fs_2" then
		local template = TemplateFactory:createSkillFs2(skillUserInfo, false)
		template:showSkill()		
	else
		local attacker = GameWorld.Instance:getEntityManager():getEntityObject(skillUserInfo["attackType"], skillUserInfo["attackerId"])
		local existPlayer = GameWorld.Instance:getAnimatePlayManager():getPlayer(skillUserInfo["attackerId"], skillRefId)
		
		local template = SkillTemplate.New()
		if not self:processSkillEffect(template, attacker, skillUserInfo) then
			self:performDeath(skillUserInfo["effects"])
			template:DeleteMe()
			template = nil
			return
		end
		
		-- ������ҵļ��ܵĶ����Ѿ����ų�ȥ�ˣ����ﲻ��SkillTemplate���ύ
		local spawnGroup = SpawnAnimate.New()
		if template:getHitPlayer() then
			spawnGroup:addPlayerList(template:getHitPlayer())
		end
		
		if template:getTextPlayer() then
			spawnGroup:addPlayerList(template:getTextPlayer())
		end
		
		if template:getDeathPlayer() then
			spawnGroup:addPlayerList(template:getDeathPlayer())
		end
		
		if existPlayer and existPlayer:getState() ~= AnimatePlayerState.AnimatePlayerStateFinish then
			-- �����ǰ���ܵĲ��Ż��ڽ����У����һ�²��ŵ�ʱ��, ������֤�ڹ�����ʼ300msͳһ����
			local time = existPlayer:getTime()
			if time < 0.3 then
				local delayPlayer = DelayPlayer.New()
				delayPlayer:setDelayTime(0.3-time)
				local sequence = SequenceAnimate:New()
				sequence:addPlayer(delayPlayer)
				sequence:addPlayer(spawnGroup)
				GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", sequence)
			else
				GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", sequence)
			end
		else
			GameWorld.Instance:getAnimatePlayManager():addPlayer("", "", spawnGroup)
		end
		
		-- release object
		template:DeleteMe()
		template = nil
	end
end

function SkillShowManager:processSkillEffect(template, attackerObject, skillUserInfo)
	if template == nil then	
		CCLuaLog("processSkillEffect error, empty template")
		return false
	end
	
	if skillUserInfo == nil then
		CCLuaLog("processSkillEffect error, empty skillUserInfo")
		return false
	end
	
	if type(skillUserInfo) ~= "table" then
		CCLuaLog("processSkillEffect error, error skillUserInfo type:"..type(skillUserInfo))
		return false
	end
	
	if attackerObject == nil then
		CCLuaLog("processSkillEffect error, unexist attacker")
		return false
	end
	
	if skillUserInfo["effects"] == nil then
		return true
	end
		
	local skillRefId = skillUserInfo["skillRefId"]
	for k,v in pairs(skillUserInfo["effects"]) do
		local target = GameWorld.Instance:getEntityManager():getEntityObject(v:getEntityType(), v:getServerId())
		if target then
			local params = v:getEffectParam()
			local effectType = v:getType()
			if  effectType == 0 or effectType == 1 or effectType == 2 then
				-- �ܻ���Ʈ��
				local heroId = GameWorld.Instance:getEntityManager():getHero():getId() 						
				if heroId == target:getId() or heroId == attackerObject:getId() or (attackerObject:getEntityType() == EntityType.EntityType_Monster and attackerObject:getOwnerId() == heroId) then
					local textPlayer = self:createTextPlayer(v)
					if textPlayer then
						textPlayer:setAttackData(attackerObject:getId(), attackerObject:getEntityType())
						template:addTextPlayer(textPlayer)
					end			
				end			
			elseif 3 == v:getType() then
				local deathEffectId = Config.Animate.DefalutDeathEffect
				if Config.Animate[skillRefId] and Config.Animate[skillRefId]["death"] then
					deathEffectId = Config.Animate[skillRefId]["death"]
				end
				
				local attackCellX, attackCellY = attackerObject:getCellXY()
				if skillUserInfo["cellX"] and skillUserInfo["cellY"] then
					attackCellX = skillUserInfo["cellX"]
					attackCellY = skillUserInfo["cellY"]
				end
				
				local deathPlayer = self:createDeathPlayer(deathEffectId, v:getEntityType(), v:getServerId(), attackCellX, attackCellY)
				if deathPlayer then
					template:addDeathPlayer(deathPlayer)
				end
			elseif E_SkillEffectType.Sumon == v:getType() and params["targetList"] and not  string.match(skillRefId,"skill_fs_8") then
				-- �ٻ�
				for k,v in pairs(params["targetList"]) do
					local skillAniPlayer =  CharacterAnimatePlayer.New()
					skillAniPlayer:setPlayData(v, EntityType.EntityType_Monster, 7270)
					template:addAttackPlayer(skillAniPlayer)
				end
			end
		end
	end
	
	return true
end

-- ����޷�����һ�����ܵı��ݣ�Ҫ���⴦��������Ч
function SkillShowManager:performDeath(skillEffects)
	if not skillEffects then
		return
	end
	
	for k,v in pairs(skillEffects) do
		local effectType = v:getType()
		
		-- ����
		if effectType == 3 then
			local target = GameWorld.Instance:getEntityManager():getEntityObject(v:getEntityType(), v:getServerId())
			if target then
				target:DoDeath()
			end
		end
	end
end

-- ���ݼ���Ч������һ�������Ķ���
function SkillShowManager:createDeathPlayer(effectId, characterType, characterId, attackX, attackY)
	return AnimateFactory:getDeathPlayer(effectId, characterId, characterType, attackX, attackY)
end

-- ���ݼ���Ч������һ��Ʈ�ֶ���
function SkillShowManager:createTextPlayer(skillEffect)
	if not skillEffect then
		CCLuaLog("createTextPlayer with empty skillEffect")
		return nil
	end
	
	local characterId = skillEffect:getServerId()
	local characterType = skillEffect:getEntityType()
	local style = TextStyle.TextStyleMiss
	local text = ""
	
	local effectType = skillEffect:getType()
	if E_SkillEffectType.HP == effectType or E_SkillEffectType.Criti == effectType then
		--ƮѪ
		if effectType == E_SkillEffectType.HP then
			if (skillEffect:getEffectParam()).HarmValue < 0 then
				style = TextStyle.TextStyleHeal
				text = -(skillEffect:getEffectParam()).HarmValue
			else
				style = TextStyle.TextStyleHit
				text = (skillEffect:getEffectParam()).HarmValue
			end
			
		elseif effectType == E_SkillEffectType.Criti then
			style = TextStyle.TextStyleCriti
			text = (skillEffect:getEffectParam()).HarmValue
		end
	end
	
	return AnimateFactory:getTextPlayer(characterId, characterType, style, text)
end

function SkillShowManager:isSkillPrePlay(skillRefId)
	if Config.Animate[skillRefId] and Config.Animate[skillRefId]["PrePlay"] then
		return true
	else
		return false
	end
end

-- ����������һ��߹���ļ��ܷ���
function SkillShowManager:handleSingleSkillUse(skillUserInfo)
	SkillShowManager:showSkillAnimate(skillUserInfo)
end

-- ����һ���Խ�ɫ�ļ���
function SkillShowManager:showCharacterSkill(attackerId, attackType, targetId, targetType, skillRefId)
	if self:isSkillPrePlay(skillRefId) then
		local skillUserInfo = {}
		skillUserInfo["skillRefId"] = skillRefId
		skillUserInfo["attackType"] = attackType
		skillUserInfo["attackerId"] = attackerId
		skillUserInfo["targetType"] = targetType
		skillUserInfo["targetId"] = targetId
		SkillShowManager:showSkillAnimate(skillUserInfo)
	end
end

-- ����һ�����ӵļ���
function SkillShowManager:showMapSkill(attackerId, attackType, cellX, cellY, skillRefId)
	if self:isSkillPrePlay(skillRefId) then
		local skillUserInfo = {}
		skillUserInfo["skillRefId"] = skillRefId
		skillUserInfo["attackType"] = attackType
		skillUserInfo["attackerId"] = attackerId
		skillUserInfo["cellX"] = cellX
		skillUserInfo["cellY"] = cellY
		SkillShowManager:showSkillAnimate(skillUserInfo)
	end
end

-- ����һ��������
function SkillShowManager:showDirectionSkill(attackerId, attackType, skillRefId)
	if self:isSkillPrePlay(skillRefId) then
		local skillUserInfo = {}
		skillUserInfo["skillRefId"] = skillRefId
		skillUserInfo["attackType"] = attackType
		skillUserInfo["attackerId"] = attackerId
		SkillShowManager:showSkillAnimate(skillUserInfo)
	end
end

function SkillShowManager:showSkillAnimate(skillUserInfo)
	if type(skillUserInfo) == "table" then
		local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
		local skillRefId = skillUserInfo["skillRefId"]
		
		-- Ұ����ײ�Ϳ��ܻ𻷵Ķ�������Ҫ�����������ķ�������, ��ʱû��������������ͬһ����ϵ, ��������
		local template = nil
		if string.find(skillRefId, "skill_zs_5") ~= nil then
			template = TemplateFactory:createSkillZs5(skillUserInfo)
			local attackerId = skillUserInfo["attackerId"]
			local attackType = skillUserInfo["attackType"]
			local attackerObject = GameWorld.Instance:getEntityManager():getEntityObject(attackType,attackerId)
			self:processSkillEffect(template, attackerObject, skillUserInfo)
		elseif skillRefId == "skill_fs_2" then
			template = TemplateFactory:createSkillFs2(skillUserInfo, self:isSkillPrePlay(skillRefId))
		elseif skillRefId == "skill_fs_5" then	--˲���ƶ�
			template = TemplateFactory:createSkillFs5(skillUserInfo)
		else
			template = self:createTemplateShow(skillUserInfo)
		end
		
		if template then
			template:showSkill()
			
			-- release object
			template:DeleteMe()
			template = nil
		end
	end
end

function SkillShowManager:createTemplateShow(skillUserInfo)
	local skillRefId = skillUserInfo["skillRefId"]
	local skillMgr = GameWorld.Instance:getEntityManager():getHero():getSkillMgr()
	local skillRefData = GameData.Skill[skillRefId]
	local skillAimType = PropertyDictionary:get_skillAimType(skillRefData["property"])
	
	local attacker = GameWorld.Instance:getEntityManager():getEntityObject(skillUserInfo["attackType"], skillUserInfo["attackerId"])
	if attacker == nil then
		self:performDeath(skillUserInfo["effects"])
		return
	end
	
	local target = nil
	
	--�������ֻ�е�����Ͳ�ת��  @yejunhua
	if Simple_Dir_MonstorConfig[attacker:getModuleId()] == nil then
		-- ֻ�ж�Ŀ��ͶԸ��Ӽ��ܲ�Ҫת��
		if 1 == skillAimType then
			target =  GameWorld.Instance:getEntityManager():getEntityObject(skillUserInfo["targetType"], skillUserInfo["targetId"])
			if attacker and target and (attacker:getId() ~= target:getId()) then
				attacker:faceToCell(target:getCellXY())
			end
		elseif 2 == skillAimType and skillUserInfo["direction"] and attacker then
			attacker:setAngle(skillUserInfo["direction"])
		elseif skillUserInfo["cellX"] and skillUserInfo["cellY"] and attacker then
			attacker:faceToCell(skillUserInfo["cellX"], skillUserInfo["cellY"])
		end
	end
	
	local skillAnimateData = Config.Animate[skillRefId]
	
	-- �������ܱ��ݵ�ģ��
	local template = SkillTemplate.New()
	template:setUserInfo(skillUserInfo["attackerId"], skillRefId)
	
	if 1 == skillAimType then
		-- Ŀ��ĵ���characterObject
		self:checkCasterAni(template, attacker, skillRefId)
		self:checkBulletAni(template, attacker, target, skillRefId)
		self:checkSkillObjectAni(template, attacker:getAngle(), target, skillRefId,attacker)
	else
		self:checkCasterAni(template, attacker, skillRefId)
		
		if skillUserInfo["cellX"] and skillUserInfo["cellY"] then
			self:checkSkillMapAni(template, attacker:getAngle(), skillUserInfo["cellX"], skillUserInfo["cellY"], skillRefId)
		end
	end
	
	--��������Ч���б�
	if not self:processSkillEffect(template, attacker, skillUserInfo) then
		self:performDeath(skillUserInfo["effects"])
	end
	
	return template
end

-- ������е�ʩ����صĶ���, ��ӵ�template
function SkillShowManager:checkCasterAni(template, attacker, skillRefId)
	if attacker ~= nil and skillRefId ~= nil and template ~= nil then
		local casterAniData = Config.Animate[skillRefId]["caster"]
		if casterAniData then
			for k,v in pairs(casterAniData) do
				local player = nil
				if v["type"] == "characterAction" then
					-- ������չ������⣬�����ʱ����
					if skillRefId == "skill_0" and attacker:getEntityType() == EntityType.EntityType_Player and isDisplayEffect then
						local skillAniPlayer =  CharacterAnimatePlayer.New()
						skillAniPlayer:setPlayData(attacker:getId(), attacker:getEntityType(), 7023)
						skillAniPlayer:setDirection(attacker:getAngle())
						template:addAttackPlayer(skillAniPlayer)
					end
					-- ����ǹ��Ҫ���ù����DoShowAttackAction
					if attacker:getEntityType() == EntityType.EntityType_Monster and v["actionType"] == 1 then
						attacker:DoShowAttackAction(v["actionId"])
						if Config.Sound[attacker:getRefId()] then
							local soundData = Config.Sound[attacker:getRefId()]
							if soundData.attack then
								local soundMgr = GameWorld.Instance:getSoundMgr()
								soundMgr:playEffect(soundData.attack, false)		
							end
						end
					else	
						player = self:createCharacterActionEntry(v, attacker)						
						if v["actionType"] == 2 then
							template:addFillDataPlayer(player)
						end
					end
				elseif v["type"] == "characterAni" and isDisplayEffect then
					player = self:createCharacterAniEntry(v, attacker)
				elseif v["type"] == "mapAni" and isDisplayEffect then
					local cellX, cellY = attacker:getCellXY()
					local angle = attacker:getAngle()
					player = self:createMapAniEntry(v, angle, cellX, cellY)
					
					-- �����0, 1, 7�������ϵļ��ܣ���ͼ��ЧҪ���ؾ���㣬����ʩ���߱��Լ���ʩ����Ч�ڵ�
					if (angle == 0 or angle == 1 or angle == 7) and player:getMapLayer() == 2 then
						player:setMapLayer(eRenderLayer_Sprite)
					end
				elseif v["type"] == "sequence" then
					player = self:createCharacterSequence(v["animate"], attacker, template)
				elseif v["type"] == "sound" then
					if attacker:getId() == G_getHero():getId() then
						if skillRefId ~= "skill_zs_2" then
							player = self:createSoundPlayer(v)
						else
							if PropertyDictionary:get_gender(G_getHero():getPT()) == ModeType.eGenderFemale then
								player = AnimateFactory:getSoundPlayer("skill_zs_2_2")		
							else
								player = AnimateFactory:getSoundPlayer("skill_zs_2_1")		
							end
						end
					end
				end
				
				if player then
					template:addAttackPlayer(player)
				end
			end
		end
	end
end

-- ������е��ܻ���صĶ���, ��ӵ�template
function SkillShowManager:checkHitAni(template, target, skillRefId, effectData, attacker)
	if template and target and skillRefId then
		local casterAniData = Config.Animate[skillRefId]["hit"]
		if casterAniData == nil then
			return
		end
		
		for k,v in pairs(casterAniData) do
			local player = nil
			if v["type"] == "characterAction" then
				player = self:createCharacterActionEntry(v, target)
			elseif v["type"] == "characterAni" and isDisplayEffect then
				player = self:createCharacterAniEntry(v, target)
				player:setMaxTime(0.35)
				if v["actionType"] == 2 then
					local param = effectData:getEffectParam()
					player:setTargetCell(param["x"], param["y"])
				end
			elseif v["type"] == "sound" then
				if attacker:getId() == G_getHero():getId() then
					player = self:createSoundPlayer(v)	
				end
			end
			
			if player then
				template:addHitPlayer(player)
			end
		end
	end
end

-- ����������ɫ�����л�������
function SkillShowManager:createCharacterActionEntry(entryData, characterObject)
	if entryData["actionType"] == 1 then
		local player = CharacterActionPlayer.New()
		local actionId = entryData["actionId"]
		if self:isActionAttack(actionId) then
			player:setPlayAction(characterObject:getId(), characterObject:getEntityType(), ActionType.ActionTypeAttack, actionId)			
		elseif self:isActionBeHit(actionId) then
			player:setPlayAction(characterObject:getId(), characterObject:getEntityType(), ActionType.ActionTypeBeHit, actionId)
		else
			player:setPlayAction(characterObject:getId(), characterObject:getEntityType(), ActionType.ActionTypeNormal, actionId)
		end
		
		return player
	elseif entryData["actionType"] == 2 then
		local player = CharacterActionFlyPlayer.New()
		player:setCharacter(characterObject:getEntityType(), characterObject:getId())
		if entryData["time"] then
			player:setTime(entryData["time"])
		end
		return player
	end
end

-- ����������ɫ����������
function SkillShowManager:createCharacterAniEntry(entryData, characterObject)
	if entryData and characterObject then
		local player = AnimateFactory:getCharacterEffect(entryData["animateId"], characterObject:getId(), characterObject:getEntityType())
		if not player then
			return nil
		end
		
		-- �෽��Ҫ�ȼ��㹥���ߵķ���
		if entryData["DirType"] == 1 then
			player:setDirection(characterObject:getAngle())
		end
		
		-- ����Ҫ����
		if entryData["Align"] == "center" then
			local offset = ccp(0, 0)
			local sizeTarget = characterObject:getUperPosition()
			offset.y = offset.y + sizeTarget.y/2
			
			player:setOffset(offset)
		end
		
		if entryData["Scale"] and entryData["Scale"] > 0 then
			player:setScale(entryData["Scale"])
		end
		if entryData["animateId"] == 7360 then --���������⴦��
			player:setRotation(225)
		end	
		
		player:setAnimateSpeed(characterObject:getAttackAnimateSpeed())
		return player
	else
		return nil
	end
	
	return skillAniPlayer
end

-- �������������ڵ�ͼ�ϵ�����
function SkillShowManager:createMapAniEntry(entryData, direction, cellX, cellY)
	if entryData and cellX and cellY then
		local player = AnimateFactory:getMapEffect(entryData["animateId"], cellX, cellY)
		if not player then
			return nil
		end
		
		if entryData["MapLayer"] then
			player:setMapLayer(entryData["MapLayer"])
		end
		
		if entryData["Scale"] then
			player:setScale(entryData["Scale"])
		end
		
		local ptOffset = self:getOffset(direction, entryData)
		if ptOffset then
			player:setOffset(ptOffset)
		end
		
		local animateDir = direction
		if entryData["DirType"] == 0 then
			animateDir = 0
		end
		
		-- 7080ֻ��4����������Ҫ���⴦��һ��
		local rotation = 0
		if entryData["animateId"] == 7080 and animateDir == 4 then
			animateDir = 0
			rotation = 180
		end
		
		if entryData["animateId"] == 7080 then
			player:setRotation(rotation)
		elseif entryData["Rotate"] == 1 then
			--  ����ʩ���ߵķ�����ת�Լ�
			player:setRotation(90-direction*45)
		end
		
		player:setDirection(animateDir)
		return player
	else
		return nil
	end
end

-- ���������ӵ�����
function SkillShowManager:createBulletAniEntry(entryData, startPos, endPos , bIsSingleSprite)
	local bulletPlayer = AnimateFactory:getBulletPlayer(entryData["animateId"], startPos, endPos, entryData["Rotate"] == 1 , bIsSingleSprite)
	return bulletPlayer
end

-- ����һ�����ԵĶ�������
function SkillShowManager:createCharacterSequence(entryData, target, template)
	if entryData and target then
		local sequence = SequenceAnimate.New()
		for k,v in pairs(entryData) do
			local player = nil
			if v["type"] == "characterAction" then
				player = self:createCharacterActionEntry(v, target)
			elseif v["type"] == "characterAni" and isDisplayEffect then
				player = self:createCharacterAniEntry(v, target)
			elseif v["type"] == "characterAlpha" then
				player = CharacterAlphaPlayer.New()
				player:setCharacter(target:getEntityType(), target:getId())
				player:setAlpha(v["alpha"])
			elseif v["type"] == "delay" then
				player = DelayPlayer.New()
				player:setDelayTime(v["time"])
			elseif v["type"] == "characterPosition" then
				player = CharacterPositionPlayer.New()	
				template:addFillDataPlayer(player)
			end
			
			if player then
				sequence:addPlayer(player)
			end
		end
		
		return sequence
	end
end

function SkillShowManager:createSoundPlayer(entryData)
	local settingMgr = GameWorld.Instance:getSettingMgr()
	-- �������, ������
	if entryData and entryData["name"] and settingMgr:getVoiceValue() > 0 and not settingMgr:isVoiceOff() then
		return AnimateFactory:getSoundPlayer(entryData["name"])			
	end
	return nil
end

--[[
template: 	���ܲ��ŵ�ģ��
direction:	ʩ���ߵķ���
target:		Ŀ��object
skillRefId:	����ID
]]
function SkillShowManager:checkSkillObjectAni(template, direction, target, skillRefId,attacker)
	if skillRefId ~= nil and template ~= nil and target ~= nil then
		local casterAniData = Config.Animate[skillRefId]["skill"]
		if casterAniData then
			for k,v in pairs(casterAniData) do
				local player = nil
				if v["type"] == "characterAction" then
					player = self:createCharacterActionEntry(v, target)
				elseif v["type"] == "characterAni" and isDisplayEffect then
					player = self:createCharacterAniEntry(v, target)
				elseif v["type"] == "mapAni" and isDisplayEffect then
					local cellX, cellY = target:getCellXY()
					player = self:createMapAniEntry(v, direction, cellX, cellY)
				elseif v["type"] == "sound" then
					if attacker:getId() == G_getHero():getId() then
						player = self:createSoundPlayer(v)						
					end		
				end
				
				if player then
					template:addTargetPlayer(player)
				end
			end
		end
	end
end

--[[
template: 	���ܲ��ŵ�ģ��
direction:	ʩ���ߵķ���
cellX:		Ŀ�����X
cellY:		Ŀ�����Y
skillRefId:	����ID
]]
function SkillShowManager:checkSkillMapAni(template, direction, cellX, cellY, skillRefId)
	local casterAniData = Config.Animate[skillRefId]["skill"]
	if casterAniData then
		for k,v in pairs(casterAniData) do
			if v["type"] == "mapAni" and isDisplayEffect then
				player = self:createMapAniEntry(v, direction, cellX, cellY)
			elseif v["type"] == "sound" then
				player = self:createSoundPlayer(v)	
			end
			
			if player then
				template:addAttackPlayer(player)
			end
		end
	end
end

-- �������кͷ����ӵ���صĶ�������
function SkillShowManager:checkBulletAni(template, attack, target, skillRefId)
	if attack ~= nil and target ~= nil and skillRefId ~= 0 and template ~= nil then
		local animateConfig = Config.Animate[skillRefId]["bullet"]
		
		if animateConfig == nil or not isDisplayEffect then
			return
		end
		
		local attackX, attackY = attack:getMapXY()
		local targetX, targetY = target:getMapXY()
		local size = attack:getUperPosition()
		for k,v in pairs(animateConfig) do
			if v["type"] == "bulletAni" then
				local startPos = ccp(attackX, attackY+size.y*0.7)
				local endPos = ccp(targetX, targetY+size.y*0.7)
				local bIsSingleSprite = false
				if v["isSingleSprite"] then
					bIsSingleSprite = true
				end
				local bulletPlayer = self:createBulletAniEntry(v, startPos, endPos,bIsSingleSprite)
				
				if bulletPlayer then
					template:addBulletPlayer(bulletPlayer)
				end
			end
		end
	end
end

-- ��ȡ������ƫ��
function SkillShowManager:getOffset(characterDir, animateData)
	if animateData and animateData["Offset"] then
		local isFlipX = false
		
		-- offset5����
		local offsetDir = characterDir
		if offsetDir > 4 then
			offsetDir = 8 - offsetDir
			isFlipX = true
		end
		
		local offset = animateData["Offset"][offsetDir]
		if not offset then
			offset = {0, 0}
		end
		local ptOffset = ccp(offset[1], offset[2])
		if isFlipX then
			ptOffset.x = -ptOffset.x
		end
		
		return ptOffset
	end
end

-- ����һ�� action�Ƿ��ǹ�������
function SkillShowManager:isActionAttack(actionId)
	return actionId == EntityAction.eEntityAction_Attack or actionId == EntityAction.eEntityAction_Skill1 or actionId == EntityAction.eEntityAction_Skill2 or actionId == EntityAction.eEntityAction_Skill3
end

-- ����һ�� action�Ƿ����ܻ�����
function SkillShowManager:isActionBeHit(actionId)
	return actionId == EntityAction.eEntityAction_Hit
end