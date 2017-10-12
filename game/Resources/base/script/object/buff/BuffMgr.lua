require("common.baseclass")
require("actionEvent.ActionEventDef")
require("ui.UIManager")
require ("object.skillShow.player.TextPlayer")

BuffMgr = BuffMgr or BaseClass()

BuffAction = {
AddBuff = 1,  --���buff
SubBuff = 2, --����buff
}

function BuffMgr:__init()
	self.buffArray = {}   --buff	
end

function BuffMgr:__delete()
	
end

function BuffMgr:clear()
	if self.buffArray then
		for _,v in pairs(self.buffArray) do
			if v then
				v:DeleteMe()
			end
		end
		self.buffArray = {}	
	end
end

--����buff�б�
function BuffMgr:requestBuffList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Buff_List)
	simulator:sendTcpActionEventInLua(writer)
end

--����ħѪʱʣ������
function BuffMgr:requestMoxueshiAmount()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_MoXueShi_Amount)
	simulator:sendTcpActionEventInLua(writer)
end

function BuffMgr:attachBuff(buffObject)
	if buffObject then 
		self:addBuff(buffObject)
		self:handlerBuffTip(buffObject)
		local isPositiveBuff = PropertyDictionary:get_isPositiveBuff(buffObject:getStaticData())			
		if isPositiveBuff == 2 then  --ħ����
			GlobalEventSystem:Fire(GameEvent.EventAddBuffEffect2Player, buffObject)  --��ӵ�Ӣ������
		else			
			GlobalEventSystem:Fire(GameEvent.EventRefreshBuff, buffObject, BuffAction.AddBuff)
		end				
	end
end

function BuffMgr:detachBuff(buffObject)
	if buffObject then 
		local isPositiveBuff = PropertyDictionary:get_isPositiveBuff(buffObject:getStaticData())
		self:subBuff(buffObject)	
		if isPositiveBuff == 2 then  --ħ����
			GlobalEventSystem:Fire(GameEvent.EventDeleteEffect, buffObject)	
		else
			GlobalEventSystem:Fire(GameEvent.EventRefreshBuff, buffObject, BuffAction.SubBuff)
		end	
	end	
end


function BuffMgr:addBuff(buffObject)
	if buffObject then 
		local pt = buffObject:getPT()
		local buffRefId = PropertyDictionary:get_buffRefId(pt)
		local index = pt["index"]
		if buffRefId and index then
			local code = buffRefId .. index  --���Ψһȷ����buff������˵��buff��ID
			if self.buffArray[code] then
				self.buffArray[code]:DeleteMe()
			end
			self.buffArray[code] = buffObject
		end
	end
end	

function BuffMgr:subBuff(buffObject)
	if buffObject then 
		local pt = buffObject:getPT()
		local buffRefId = PropertyDictionary:get_buffRefId(pt)
		local index = pt["index"]
		for key, value in pairs(self.buffArray) do
			if value ~= nil then
				local pt = value:getPT()
				local objectRefId = PropertyDictionary:get_buffRefId(pt)			
				if (index==pt["index"]) and (buffRefId==objectRefId) then
					local code = buffRefId .. index
					self.buffArray[code] = nil
					break
				end
			end
		end
		self:checkPoisonBuffExist()
	end
end	

function BuffMgr:getBuff()
	return self.buffArray
end	

--��ʱ�����ж�Ⱦɫ����ʧ��BUG
function BuffMgr:checkPoisonBuffExist()
	if  table.size(self.buffArray) > 0 then
		for _, value in pairs(self.buffArray) do
			local pt = value:getPT()
			local buffRefId = PropertyDictionary:get_buffRefId(pt)						
			if string.find(buffRefId, "buff_state_10") or  string.find(buffRefId, "buff_state_5")  then
				return
			else
				--���Ӣ�����ϻ����ж�״̬  ������ж�״̬
				if G_getHero():getState():isState(CharacterFightState.Poison) then
					G_getHero():getState():removeComboState(CharacterFightState.Poison)
				end
			end
		end	
	else
		if G_getHero():getState():isState(CharacterFightState.Poison) then
			G_getHero():getState():removeComboState(CharacterFightState.Poison)
		end	
	end
end

-- �ͷ���չ���ܻᵼ��buffҲ�����仯, Ҫ���buff�Ƿ�����չ���ܵ��µ�
function BuffMgr:checkBuffExist(buffRefId, targetId)
	for _, value in pairs(self.buffArray) do
		local pt = value:getPT()
		local tmpRefId = PropertyDictionary:get_buffRefId(pt)
		local tmpTargetId = pt["target"]
		
		--��չ��buff��������������ͨbuff���ֺ��������ʾ
		if string.find(tmpRefId, buffRefId) ~= nil and targetId == tmpTargetId then
			return true
		end
	end		
	return false
end

function BuffMgr:handlerBuffTip(buffObject)
	if buffObject == nil then
		return
	end
	-- Ʈ��
	local pt = buffObject:getPT()	
	local attackerId = pt["caster"]
	local attackerType = pt["casterType"]	
	local targetId = pt["target"]
	local targetType = pt["targetType"]			

	local staticData = buffObject:getStaticData()
	local isPositiveBuff = staticData["isPositiveBuff"]
	local style = TextStyle.TextStyleBuff
	if isPositiveBuff == 0 then
		style = TextStyle.TextStyleDebuff
	end
	local text = staticData["name"]		
	
	local textPlayer = AnimateFactory:getTextPlayer(targetId, targetType, style, text)
	if textPlayer then
		textPlayer:setAttackData(attackerId, attackerType)
		local template = SkillTemplate.New()
		template:addTextPlayer(textPlayer)
		
		template:showSkill()
		template:DeleteMe()
		template = nil
	end
end	

function BuffMgr:getBuffObject(buffRefId, targetId)
	for _, value in pairs(self.buffArray) do
		local pt = value:getPT()
		local tmpRefId = PropertyDictionary:get_buffRefId(pt)
		local tmpTargetId = pt["target"]
		if string.find(tmpRefId, buffRefId) ~= nil and targetId == tmpTargetId then
			return value
		end
	end		
end

function BuffMgr:getBuffObjectByKey(refId, index)
	for _, value in pairs(self.buffArray) do
		local pt = value:getPT()
		local tmpRefId = PropertyDictionary:get_buffRefId(pt)
		local idx = value["index"]
		if tmpRefId == buffRefId and index == idx then
			return value
		end
	end				
end

--����ħѪ������
function BuffMgr:setMoxueshiAmount(obj)
	if obj then
		self.moxueshiObj = obj
	end
end

function BuffMgr:getMoxueshiAmount()
	return self.moxueshiObj
end

--
function BuffMgr:setBuffEffectObj(obj)
	if obj then
		self.effectObj = obj
	end
end

function BuffMgr:getBuffEffectObj()
	return self.effectObj
end
