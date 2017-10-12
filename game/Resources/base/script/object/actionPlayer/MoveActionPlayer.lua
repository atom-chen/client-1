require("common.baseclass")
require("object.actionPlayer.BaseActionPlayer")

MoveActionPlayer = MoveActionPlayer or BaseClass(BaseActionPlayer)

function MoveActionPlayer:__init()
	self.des = "MoveActionPlayer"
	self.characterId = ""
	self.characterType = ""
	self.moveSpeedPer = 1	-- �ƶ��ٶȵı���ֵ�� 1�Ǳ���ԭ�����ٶ�
end

function MoveActionPlayer:__delete()
	self:unbind()
	self.hasHandled = false
end

function MoveActionPlayer:setCharacter(characterId, characterType)
	if characterId and characterType then
		self.characterId = characterId
		self.characterType = characterType
	end
end

function MoveActionPlayer:setMoveSpeedPer(per)
	if per and per > 0 then
		self.moveSpeedPer = per
	end
end

--�ڲ��ź�Ž��а󶨡��ڲ���ǰ���а󶨣��ᵼ�¿��ܻ�δ���ž��յ���Ϣ��
function MoveActionPlayer:bindEvent()
	if self.hasBinded == true then
		return
	end
	self.hasBinded = true
	
	self.hasHandled = false
	local onHeroStop = function(ret)
		if self.hasHandled == true then
			return
		end
		--		print("MoveActionPlayer:onHeroStop >>")
		self.hasHandled = true			--��������Ϣ�ص���unbind��Ϣ��
		self:setMaxPlayingDuration(0)	--����һ֡ʱ��ֹͣ
	end
	self.moveEvent = GlobalEventSystem:Bind(GameEvent.EVENT_HERO_STOP, onHeroStop) --��Ӣ��ֹͣ
	self:setMaxPlayingDuration(5)
end

function MoveActionPlayer:unbind()
	if self.moveEvent then
		GlobalEventSystem:UnBind(self.moveEvent)
		self.moveEvent = nil
	end
end

function MoveActionPlayer:setCellXY(x, y)
	self.cellX = x
	self.cellY = y
end

function MoveActionPlayer:getCellXY()
	return self.cellX, self.cellY
end

--��д
function MoveActionPlayer:doPlay()
	local ret = false
	while true do
		if G_getHero():getId() == self.characterId then
			self:bindEvent()
		end
		
		local characterObject = GameWorld.Instance:getEntityManager():getEntityObject(self.characterType, self.characterId)
		if not characterObject then
			break
		end
		
		local orginalSpeed = PropertyDictionary:get_moveSpeed(characterObject:getPT())
		if G_getHero():getId() ~= self.characterId then	
			PropertyDictionary:set_moveSpeed(characterObject:getPT(), orginalSpeed*self.moveSpeedPer)			
			
			characterObject:updateSpeed()	
			characterObject:moveStop()
			
			-- �����ƶ�״̬���˳�
			local function funcStateCallback(stateName, bEnter)
				if (stateName == CharacterState.CharacterStateMove or stateName == CharacterState.CharacterStateRideMove) and bEnter == false then
					PropertyDictionary:set_moveSpeed(characterObject:getPT(), orginalSpeed)
					characterObject:updateSpeed()
					self.playingDuration = 0
					self.hasHandled = true
					self:stop(E_ActionStopReason.Fail)
					characterObject:removeStateChangeCallback(funcStateCallback)
				end
			end
			
			characterObject:addStateChangeCallback(funcStateCallback)
		end
		
		local cellX, cellY = characterObject:getCellXY()
		if characterObject:moveTo(self.cellX, self.cellY) == true then
			ret = true
		else
			PropertyDictionary:set_moveSpeed(characterObject:getPT(), orginalSpeed)
			characterObject:updateSpeed()
		end
		break
	end
	if ret ~= true then
		self:unbind()
		self.playingDuration = 0
		self.hasHandled = true
		self:stop(E_ActionStopReason.Fail)
		--print("MoveActionPlayer:doPlay fail. x="..self.cellX.." y="..self.cellY)
	end
end