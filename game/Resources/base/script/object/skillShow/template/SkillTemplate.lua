--[[
��׼�ļ��ܲ��ŵĹ���
1. ���﹥�����������ܸ���������Ч
2. �ӵ��ķ���(��ѡ)
3. ��Ŀ�겥���ܻ��Ķ�����Ч��
4. Ч��Ʈ��
5. ����Ч��(��ѡ)

�ܻ��Ķ�����Ч������1��ʼ�̶�ʱ������2���ʱ��ʼ����
]]--

require "common.baseclass"
require "object.skillShow.player.SequenceAnimate"
require "object.skillShow.player.SpawnAnimate"
require "object.skillShow.player.DelayPlayer"

SkillTemplate = SkillTemplate or BaseClass()

function SkillTemplate:__init()
	self.attackPlayer = nil		-- ʩ���ߵ�Ч��
	self.bulletPlayer = nil		-- �����ӵ���Ч��
	self.targetPlayer = nil		-- ���ܱ����Ч��
	self.hitPlayer = nil		-- ���е�Ч��
	self.textPlayer = nil		-- Ʈ��Ч��
	self.deathPlayer = nil		-- ����Ч��
	self.attacker = ""
	self.skillRefId = ""
	
	self.fillDataPlayer = {} -- ��Ҫ������ݵ�player
end

function SkillTemplate:__delete()
	--[[if self.attackPlayer ~= nil then
		self.attackPlayer:DeleteMe()
	end
	
	if self.bulletPlayer ~= nil then
		self.bulletPlayer:DeleteMe()
	end
	
	if self.textPlayer ~= nil then
		self.targetPlayer:DeleteMe()
	end
	
	if self.targetPlayer ~= nil then
		self.textPlayer:DeleteMe()
	end]]
end

function SkillTemplate:setUserInfo(attacker, skillRefId)
	self.attacker = attacker
	self.skillRefId = skillRefId
end

function SkillTemplate:addFillDataPlayer(player)
	if player then
		table.insert(self.fillDataPlayer, player)
	end
end

function SkillTemplate:getHitPlayer()
	return self.hitPlayer
end

function SkillTemplate:getTextPlayer()
	return self.textPlayer
end

function SkillTemplate:getDeathPlayer()
	return self.deathPlayer
end

function SkillTemplate:addAttackPlayer(attackPlayer)
	if self.attackPlayer == nil then
		self.attackPlayer = {}
	end
	
	table.insert(self.attackPlayer, attackPlayer)
end

function SkillTemplate:addBulletPlayer(bulletPlayer)
	if self.bulletPlayer == nil then
		self.bulletPlayer = {}
	end
	
	table.insert(self.bulletPlayer, bulletPlayer)
end

function SkillTemplate:addTargetPlayer(targetPlayer)
	if self.targetPlayer == nil then
		self.targetPlayer = {}
	end
	
	table.insert(self.targetPlayer, targetPlayer)
end

function SkillTemplate:addHitPlayer(hitPlayer)
	if self.hitPlayer == nil then
		self.hitPlayer = {}
	end
	
	table.insert(self.hitPlayer, hitPlayer)
end

function SkillTemplate:addTextPlayer(textPlayer)
	if self.textPlayer == nil then
		self.textPlayer = {}
	end
	
	table.insert(self.textPlayer, textPlayer)
end

function SkillTemplate:addDeathPlayer(deathPlayer)
	if self.deathPlayer == nil then
		self.deathPlayer = {}
	end
	
	table.insert(self.deathPlayer, deathPlayer)
end

function SkillTemplate:showSkill()
	-- �ύ��������
	local sequenceAnimate = SequenceAnimate.New()
	
	local spawnHit = nil
	if self.bulletPlayer ~= nil then
		-- ����й����������ӵ��Ķ����� �ܻ�Ч�����ӵ�����������ɺ󲥷�, �ӵ��ڹ���������ʼ��150ms��ʼ����
		-- ������м��ܶ���, �ܻ��ڼ��ܶ����󲥷�
		local spawnAttack = SpawnAnimate:createWithList(self.attackPlayer)
		local spawnBullet = SpawnAnimate:createWithList(self.bulletPlayer)
		
		local delayPlayer = DelayPlayer.New()
		delayPlayer:setDelayTime(0.25)
			
		local bulletSequence = SequenceAnimate.New()
		bulletSequence:addPlayer(delayPlayer)
		bulletSequence:addPlayer(spawnBullet)
		
		spawnAttack:addPlayer(bulletSequence)
		sequenceAnimate:addPlayer(spawnAttack)
		
		if self.targetPlayer ~= nil then
			local spawnTarget = SpawnAnimate:createWithList(self.targetPlayer)
			sequenceAnimate:addPlayer(spawnTarget)
		end
		
		if self.hitPlayer ~= nil then
			spawnHit = SpawnAnimate:createWithList(self.hitPlayer)
			sequenceAnimate:addPlayer(spawnHit)
		end
	elseif self.bulletPlayer == nil then
		-- ���û���ӵ����ܻ�Ч��ͳһ��300ms�����
		local spawnPlayer = SpawnAnimate:createWithList(self.attackPlayer)
		
		if self.targetPlayer ~= nil then
			spawnPlayer:addPlayerList(self.targetPlayer)
		end
		
		if self.hitPlayer ~= nil then
			local delayPlayer = DelayPlayer.New()
			delayPlayer:setDelayTime(0.3)
			local hitSpwan = SpawnAnimate:createWithList(self.hitPlayer)
			local hitSequence = SequenceAnimate.New()
			hitSequence:addPlayer(delayPlayer)
			hitSequence:addPlayer(hitSpwan)
			spawnPlayer:addPlayer(hitSequence)
		end
		
		sequenceAnimate:addPlayer(spawnPlayer)
	elseif self.hitPlayer ~= nil then
		-- ֻ���ܻ���Ч
		spawnHit = SpawnAnimate:createWithList(self.hitPlayer)
		sequenceAnimate:addPlayer(spawnHit)
	end

	if self.textPlayer ~= nil then
		if spawnHit then
			spawnHit:addPlayerList(self.textPlayer)
		else
			spawnHit = SpawnAnimate:createWithList(self.textPlayer)
			sequenceAnimate:addPlayer(spawnHit)
		end
	end
	
	if self.deathPlayer ~= nil then
		if spawnHit then
			spawnHit:addPlayerList(self.deathPlayer)
		else
			spawnHit = SpawnAnimate:createWithList(self.deathPlayer)
			sequenceAnimate:addPlayer(spawnHit)
		end
	end
	
	GameWorld.Instance:getAnimatePlayManager():addPlayer(self.attacker, self.skillRefId, sequenceAnimate)
end