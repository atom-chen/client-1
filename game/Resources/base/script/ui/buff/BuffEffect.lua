
BuffEffect = BuffEffect or BaseClass()

local  BuffEffectType = {
	Hp = 1,
	Mp = 2,
	Die = 3,
	Position = 4,
}

function BuffEffect:__init()
	self.buff = {}   --�ӵ�Ӣ�����ϵ�buff
end

--���ﲻ����buff��Ч��
function BuffEffect:showEffectBuff(effectBuff)
	local pt = effectBuff:getPT()
	local caster = pt["caster"]
	local casterType = pt["casterType"]
	local targetId = pt["target"]
	local targetType = pt["targetType"]
	local effectType = pt["effectType"]

	if effectType == BuffEffectType.Mp then  --ħ��Ч�� ��Ʈ��
		return
	elseif effectType == BuffEffectType.Die then   --����
		local entity = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
		
		-- �����Լ�������Ч��
		if entity and targetId ~= GameWorld.Instance:getEntityManager():getHero():getId() then
			entity:DoDeath()
		end
		effectBuff:DeleteMe()
		return
	elseif  effectType == BuffEffectType.Hp then  --�˺�
		local template = SkillTemplate.New()
		local textPlayer = TextPlayer.New()
		
		local currentValue = pt["CurrentValue"]
		local maxValue = pt["MaxValue"]	
		local value = pt["value"]
		local pix = string.format("%d", value)
		--���ù���Ѫ������ʾѪ��
		local entity = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
		if entity then
			--local currentHp = PropertyDictionary:get_HP(entity:getPT())
			entity:setMaxHP(maxValue)
			entity:setHP(currentValue)
		end
		local textStyle = 0
		if value >= 0 then		
			textStyle = TextStyle.TextStyleHeal
		else
			textStyle = TextStyle.TextStyleHit
		end
		
		textPlayer:setPlayerData(targetId, targetType, textStyle, pix)
		textPlayer:setAttackData(caster , casterType)
		template:addTextPlayer(textPlayer)
		template:showSkill()
		template:DeleteMe()
		template = nil
		
		effectBuff:DeleteMe()
	elseif  effectType == BuffEffectType.Position then
		local target = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
		if target then
			local posX = pt["positionX"]
			local posY = pt["positionY"]				
			target:moveStop()	
			if targetId == G_getHero():getId() then --Ӣ���Լ���Ҫͬ����ͷ
				G_getHero():synHeroPosition(posX,posY)
			else
				target:setCellXY(posX,posY)
			end	
									
		end
	end
end

function BuffEffect:addBuffEffect2Player(buffObject)
	local buffTable = buffObject:getPT()
	local targetType = buffTable["targetType"]
	local targetId = buffTable["target"]
	local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
	if characterObject == nil then
		return
	end
	
	local pt = buffObject:getPT()
	local refId = PropertyDictionary:get_buffRefId(pt)
	local index = pt["index"]
	local code = refId..index
	
	local buffAni = PropertyDictionary:get_buffAni(buffObject:getStaticData()) --buff�Ķ���Id	
	if buffAni == 7160 then  --ħ�������⴦��		
		return
--[[	renderSprite = SFRenderSprite:createRenderSprite(7161, 0, "res/skill/")
		renderSprite:setScaleX(1)
		renderSprite:setScaleY(-1)
		--renderSprite:retain()
		characterObject:addEffect(renderSprite, index)
		renderSprite:playByIndexLua(0)	--]]	
	end	
	
	local renderSprite = SFRenderSprite:createRenderSprite(buffAni, 0, "res/skill/")
	renderSprite:setScaleX(1)
	renderSprite:setScaleY(-1)
	--renderSprite:retain()
	characterObject:addEffect(renderSprite, refId)
	renderSprite:playByIndexLua(0)
	
	self.buff[code] = renderSprite
end

function BuffEffect:deleteBuffEffect(buffObject)
	local buffTable = buffObject:getPT()
	local targetType = buffTable["targetType"]
	local targetId = buffTable["target"]
	local index = buffTable["index"]
	local buffRefId = PropertyDictionary:get_buffRefId(buffObject:getPT())
	
	if buffRefId and index then
		local code = buffRefId .. index
		local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(targetType, targetId)
		if characterObject then
			if self.buff[code] then
				characterObject:removeEffect(self.buff[code], buffRefId)
				self.buff[code] = nil
			end
		end
	end
	
end