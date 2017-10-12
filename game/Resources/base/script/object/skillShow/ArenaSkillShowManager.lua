require("object.skillShow.player.CallbackPlayer")
require("object.skillShow.player.SpawnAnimate")
require("object.skillShow.player.MoveAnimationPlayer")	
require("object.skillShow.player.AttactAnimatePlayer")
require("object.skillShow.player.SequenceAnimate")
require("object.skillShow.player.ArenaBulletAnimatePlayer")	
require("object.skillShow.player.ArenaSkillAnimationPlayer")
require("object.skillShow.player.ArenaTextPlayer")
--[[
处理天梯技能表演的逻辑
]]
local animationTable = {
	[1] = {skillRef = "skill_zs_6"},
	[2] = {skillRef = "skill_fs_4"},
	[3] = {skillRef = "skill_ds_4"},

}
ArenaSkillShowManager = ArenaSkillShowManager or BaseClass()

function ArenaSkillShowManager:__init()
	self.textData = {}
	self.speedRate = 0.2
	self.animationSpeed = 1
	self.moveDistance = 250
end

function ArenaSkillShowManager:__delete()
	
end

function ArenaSkillShowManager:generateTextData(winer,loser,randomWiner,randomLoser)
	self.textData = {}
	local rate = {
		[1] = 0.35,
		[2] = 0.35,
		[3] = 0.3,
		[4] = 0.3,
	}
	local winerHp = PropertyDictionary:get_maxHP(winer:getPT())
	local winerFight = PropertyDictionary:get_fightValue(winer:getPT())	
	local loserHp = PropertyDictionary:get_maxHP(loser:getPT())
	local loserFight = PropertyDictionary:get_fightValue(loser:getPT())
	
	local flag = 1
	local hp = nil
	local winerSum = 0
	local loserSum = 0	
	local remainWinerHp = math.ceil(1+((randomWiner-randomLoser)/randomWiner)*winerHp)
	local winerTotalLost = winerHp - remainWinerHp 
	for i=1,4 do
		if flag > 0 then
			hp = math.ceil(rate[i]*loserHp) 
			loserSum = loserSum +  hp
		else
			hp = math.ceil(rate[i]*winerTotalLost)
			winerSum = winerSum + hp
		end					
		table.insert(self.textData,hp)
		flag = flag * -1
	end
	hp = math.ceil(0.33*loserHp)
	loserSum = loserSum +  hp
	table.insert(self.textData,hp)	
	
	hp = winerTotalLost - winerSum
	table.insert(self.textData,hp)
	
	hp = loserHp - loserSum
	table.insert(self.textData,hp)
	local a=1
end

function ArenaSkillShowManager:createArenaAnimation(first,second,speed,root,round,startFlag,finishCallback,updateCallback)

	self.animationSpeed = speed
	local x,y = first.renderSprite:getPosition()
	local x2,y2 = second.renderSprite:getPosition()	
	local distance = ccpDistance(ccp(x,y),ccp(x2,y2))-549
	local sequence = SequenceAnimate.New()
	
	local sequenceTable = {}
	
	self:createRunAnimateSequence(first,second,sequenceTable)
	
	local firstProfessionId = PropertyDictionary:get_professionId(first:getPT())
	local secondtProfessionId = PropertyDictionary:get_professionId(second:getPT())
	local dirFlag = startFlag
	local firstRender,secondRender
	for i=1,round do
		if dirFlag > 0 then
			firstRender = first
			secondRender = second
		else
			firstRender = second
			secondRender = first			
		end
		self:createFightAnimateSequence(firstRender,secondRender,distance*dirFlag,sequenceTable,root,updateCallback)
		dirFlag = dirFlag * -1
	end
	local finishAction = CallbackPlayer.New(finishCallback)
	table.insert(sequenceTable,finishAction)	
	sequence:addPlayerList(sequenceTable)	
	return sequence
end

function ArenaSkillShowManager:createRunAnimateSequence(firstRender,secondRender,sequenceTable)
	firstRender:changeAction(EntityAction.eEntityAction_Run,true)	
	secondRender:changeAction(EntityAction.eEntityAction_Run,true)
	local move1 = MoveAnimationPlayer.New()
	move1:setMaxTime(99)
	move1:init(firstRender.renderSprite,1.2,ccp(self.moveDistance,0))
	local move2 = MoveAnimationPlayer.New()
	move2:setMaxTime(99)
	move2:init(secondRender.renderSprite,1.2,ccp(-1*self.moveDistance,0))

	local runSpawn = SpawnAnimate.New()	
	runSpawn:addPlayer(move1)
	runSpawn:addPlayer(move2)
	table.insert(sequenceTable,runSpawn)
	
	local stopCallback = function()
		firstRender:changeAction(EntityAction.eEntityAction_Idle,true)	
		secondRender:changeAction(EntityAction.eEntityAction_Idle,true)
	end
	local stopAction = CallbackPlayer.New(stopCallback)
	table.insert(sequenceTable,stopAction)
end

function ArenaSkillShowManager:createFightAnimateSequence(attacter,defencer,distance,sequenceTable,root,updateCallback)
	
	local professionalId = PropertyDictionary:get_professionId(attacter:getPT()) 
	if not professionalId or professionalId == 0 then --如果职业ID获取失败  给默认值为1
		professionalId = 1
	end
	local skillRef = animationTable[tonumber(professionalId)].skillRef	
	
	local casterData = Config.Animate[skillRef]["caster"]
	local castSpawn = self:createAnimationGroupWithData(attacter.renderSprite,casterData,distance)
	
	if castSpawn then
		table.insert(sequenceTable,castSpawn)		
	end
	local skillData = Config.Animate[skillRef]["skill"]
	if skillData then
		local skillSpawn = self:createAnimationGroupWithData(defencer.renderSprite,skillData)
		table.insert(sequenceTable,skillSpawn)
	end
	--[[if professionalId~=E_ProfessionType.eDaoShi then 
		local bulletData = Config.Animate[skillRef]["bullet"]
		if bulletData then
			local bulletSpawn = self:createBulletAnimationGroupWithData(root,attacter.renderSprite,bulletData,distance,self.speedRate)
			table.insert(sequenceTable,bulletSpawn)
		end
	end--]]
	local hitSpawn =  self:createAnimationGroupWithData(defencer.renderSprite,Config.Animate[skillRef]["hit"])		
	table.insert(sequenceTable,hitSpawn)
	if #self.textData > 0 then
		local text = self.textData[1]	
		table.remove(self.textData,1)
		local textPlayer = self:createTextAnimate(defencer,text,distance,updateCallback)
		table.insert(sequenceTable,textPlayer)
	end		
end

function ArenaSkillShowManager:createTextAnimate(render,text,dir,updateCallback)
	local textPlayer = ArenaTextPlayer.New()
	textPlayer:setPlayerData(render,text,dir,updateCallback)
	return textPlayer
end

function ArenaSkillShowManager:createAnimationGroupWithData(render,data,distance)
	local spawn = SpawnAnimate.New()	
	local spawnTable = {}
	local dir = nil
	if distance then
		dir = 2
		if distance < 0 then
			dir = 6
		end
	end
	local animate = nil
	for k,v in pairs(data) do
		if v["type"] == "characterAction" then
			animate = AttactAnimatePlayer.New()
			animate:init(render,v.actionId)			
		elseif v["type"] == "characterAni" then
			animate = ArenaSkillAnimationPlayer.New(render)
			animate:setModleId(v.animateId)
			if dir and v.DirType ~= 0 then
				animate:setDir(dir)
			end							
		elseif v["type"] == "mapAni" then
			animate = ArenaSkillAnimationPlayer.New(render)
			animate:setModleId(v.animateId)		
		end
		animate:setAnimateSpeed(self.animationSpeed)
		table.insert(spawnTable,animate)
	end	
	spawn:addPlayerList(spawnTable)
	return spawn
end

function ArenaSkillShowManager:createBulletAnimationGroupWithData(root,attacter,data,distance,speed)
	local spawn = SpawnAnimate.New()	
	local spawnTable = {}
	for k,v in pairs(data) do
		if v["type"] == "bulletAni" then
			local x,y = attacter:getPosition()
			local attact1 = ArenaBulletAnimatePlayer.New(root,v.animateId, ccp(x-distance*self.moveDistance,y),distance,speed)			
			table.insert(spawnTable,attact1)					
		end
	end	
	spawn:addPlayerList(spawnTable)
	return spawn
end

function ArenaSkillShowManager:getSpeedRate(speed)
	local rate = 1
	if speed > 1 then
		rate = speed-1
	end
end


