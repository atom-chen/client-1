--[[
标准的技能播放的过程
1. 人物攻击动作，可能附带攻击特效
2. 子弹的飞行(可选)
3. 在目标播放受击的动作和效果
4. 效果飘字
5. 持续效果(可选)

受击的动作和效果是在1开始固定时间后或者2完成时开始表演
]]--

require "common.baseclass"
require "object.skillShow.player.SequenceAnimate"
require "object.skillShow.player.SpawnAnimate"
require "object.skillShow.player.DelayPlayer"

SkillTemplate = SkillTemplate or BaseClass()

function SkillTemplate:__init()
	self.attackPlayer = nil		-- 施法者的效果
	self.bulletPlayer = nil		-- 飞行子弹的效果
	self.targetPlayer = nil		-- 技能本身的效果
	self.hitPlayer = nil		-- 击中的效果
	self.textPlayer = nil		-- 飘字效果
	self.deathPlayer = nil		-- 死亡效果
	self.attacker = ""
	self.skillRefId = ""
	
	self.fillDataPlayer = {} -- 需要填充数据的player
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
	-- 提交动画播放
	local sequenceAnimate = SequenceAnimate.New()
	
	local spawnHit = nil
	if self.bulletPlayer ~= nil then
		-- 如果有攻击动画和子弹的动画， 受击效果在子弹动画播放完成后播放, 子弹在攻击动作开始后150ms开始播放
		-- 如果还有技能动画, 受击在技能动画后播放
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
		-- 如果没有子弹，受击效果统一在300ms后表演
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
		-- 只有受击特效
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