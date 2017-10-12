--人物头像界面
require("common.baseclass")
require"data.monster.monster"
MainBossHead = MainBossHead or BaseClass()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_scale = VisibleRect:SFGetScale()

local bossHpColor = {
	const_green = 0,
	const_yello = 1,
	const_blue = 2,
	const_red = 3,
	const_changeBloodVessel = 3	 
}	

OffsetYType = {
	Up = 1,
	Down = 2,
}	

function MainBossHead:__init(bShow, entityId)
	self.rootNode = CCNode:create()
	--self.rootNode:setContentSize(visibleSize)
	G_setScale(self.rootNode)
	self.rootNode:retain()
		
	self.scale = VisibleRect:SFGetScale()		
	self.entityObject = GameWorld.Instance:getEntityManager():getEntityObject(EntityType.EntityType_Monster, entityId)
	self.monsterRefId = self.entityObject.refId
	self.monsterRefMaxBlood = self:MaxBlood()
	self.monsterRefName = GameWorld.Instance:getEntityManager():getMonsterName(self.monsterRefId)	
	self.monsterRefMaxBloodVessel = self:MaxBloodVessel()
	self.lastPercent = nil
	self.lastVesselNum = nil
	
	local focusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	self.bossId = entityId
	self.ownerId = focusManager:getBossOwner(entityId)
	
	self:IsShowView(bShow, self.monsterRefId)
	self:bossOwnerChange(self.bossId, self.ownerId)
end

function MainBossHead:__delete()
	if self.rootNode then
		self.rootNode:release()
		self.rootNode = nil
	end		
end

function MainBossHead:getRootNode()
	return self.rootNode
end

function MainBossHead:IsShowView(bShow, monsterRefId)
	self:initHp()
	--HP	
	self:UpdateHP()		
end

function MainBossHead:initHp()
	--BossHp墨底
	self.bossHeadframeBg = createSpriteWithFrameName(RES("main_BOSSheadframeBg.png"))	
	self.rootNode:addChild(self.bossHeadframeBg)	
	self.rootNode:setContentSize(self.bossHeadframeBg:getContentSize())
	
	--BossHp黑底血条
	self.hpBottom = createScale9SpriteWithFrameNameAndSize(RES("main_BOSSHpBg.png"), CCSizeMake(360, 21))	
	--self.hpBottom:setScaleX(120)
	self.bossHeadframeBg:addChild(self.hpBottom, -1)
	
	--Boss血条
	local bossHpImage = {
	[1] = {name = "main_BOSSHp.png"},
	[2] = {name = "main_BOSSHp_blue.png"},
	[3] = {name = "main_BOSSHp_yellow.png"},
	[4] = {name = "main_BOSSHp_green.png"},	
	}		
	
	local bossHpSprite = {}
	local size = table.size(bossHpImage)
	for i=1,size do
		local sprite = createSpriteWithFrameName(RES(bossHpImage[i].name))
		table.insert(bossHpSprite, sprite)
	end	
	
	local scaleX = 120
	self.bossHpBars = {}
	for i, v in pairs(bossHpSprite) do
		local bossHpBar = CCProgressTimer:create(bossHpSprite[i])
		bossHpBar:setType(kCCProgressTimerTypeBar)
		bossHpBar:setMidpoint(CCPointMake(1, 0))
		bossHpBar:setBarChangeRate(CCPointMake(1, 0))
		bossHpBar:setScaleX(scaleX)		
		self.hpBottom:addChild(bossHpBar)
		VisibleRect:relativePosition(bossHpBar, self.hpBottom, LAYOUT_CENTER, ccp(0, 0))		
		table.insert(self.bossHpBars, bossHpBar)
	end		
	
	self.bossHpBarsWithOpacity = {}
	for i, v in pairs(bossHpSprite) do
		bossHpSprite[i]:setOpacity(130)
		local bossHpBar = CCProgressTimer:create(bossHpSprite[i])
		bossHpBar:setType(kCCProgressTimerTypeBar)
		bossHpBar:setMidpoint(CCPointMake(1, 0))
		bossHpBar:setBarChangeRate(CCPointMake(1, 0))
		bossHpBar:setScaleX(scaleX)		
		bossHpBar:setPercentage(100)
		self.hpBottom:addChild(bossHpBar)
		VisibleRect:relativePosition(bossHpBar, self.hpBottom, LAYOUT_CENTER, ccp(0, 0))		
		table.insert(self.bossHpBarsWithOpacity, bossHpBar)
	end				
		
	--bossNameLabel
	local nameLabel = CCLabelTTF:create(self.monsterRefName, "Arial", 18)
	self.hpBottom:addChild(nameLabel)
	nameLabel:setZOrder(10)
	G_setScale(nameLabel)
	--surplusBloodVesselLabel
--[[	local bloodVesselLabelBg = createSpriteWithFrameName(RES(""))
	self.bossHeadframeBg:addChild(self.bloodVesselLabel)--]]	
	self.bloodVesselLabel = CCLabelTTF:create("x ", "Arial", 18)
	self.bossHeadframeBg:addChild(self.bloodVesselLabel)
	self.bloodVesselLabel:setAnchorPoint(ccp(0, 0.5))
	G_setScale(self.bossVesselLabel)
	
	--设置相关位置
	VisibleRect:relativePosition(self.bossHeadframeBg, self.rootNode, LAYOUT_TOP_INSIDE+LAYOUT_RIGHT_INSIDE, ccp(-110, -138))	
	VisibleRect:relativePosition(self.hpBottom, self.bossHeadframeBg, LAYOUT_CENTER, ccp(6, 0))		
	VisibleRect:relativePosition(nameLabel, self.hpBottom, LAYOUT_CENTER, ccp(0, 0))
	--VisibleRect:relativePosition(self.bloodVesselLabelBg, self.bossHeadframeBg, LAYOUT_RIGHT_INSIDE, ccp(-25, 13))
	VisibleRect:relativePosition(self.bloodVesselLabel, self.bossHeadframeBg, LAYOUT_RIGHT_INSIDE, ccp(-25, 13))
end	

function MainBossHead:UpdateHP(pt)
	if pt then
		self.bossHp = pt
	else
		if self.entityObject then
			local objPt = self.entityObject:getPT()
			local monsterHp = PropertyDictionary:get_HP(objPt)
			if monsterHp then
				self.bossHp  = monsterHp
			end
		end
	end
				
	local function checkData()
		if self.bossHp == nil or self.bossHp < 0 then
			self.bossHp = 0
		end
		if self.monsterRefMaxBlood == nil or self.monsterRefMaxBlood < 1 then
			self.monsterRefMaxBlood = 1
		end
		if self.bossHp > self.monsterRefMaxBlood then
			self.bossHp = self.monsterRefMaxBlood
		end
	end		
	
	checkData()	
	self:ShowHpView()	
end	

--最大血管数
function MainBossHead:MaxBloodVessel()
	local maxBloodVessel = nil
	if self.monsterRefMaxBlood then
		if self.monsterRefMaxBlood > 9800000 then
			maxBloodVessel = 99
		else
			maxBloodVessel = 1 + math.floor(self.monsterRefMaxBlood/100000)
		end	
	end	
	
	if maxBloodVessel then
		return maxBloodVessel
	else
		return 1
	end			
end

--最大血量
function MainBossHead:MaxBlood()
	local pt = self.entityObject:getPT()
	local maxBlood = PropertyDictionary:get_maxHP(pt)
	return maxBlood
end

--name
function MainBossHead:BossName()
	local targetData = {}
			
	targetData = GameData.Monster[self.monsterRefId]
	if targetData then
		self.monsterRefName = PropertyDictionary:get_name(targetData.property)
	end
end

--除了第一管，其他血管的血量
function MainBossHead:EveryBloodVesselValue()
	self:MaxBloodVessel()
	local everyBloodValue = nil
	if self.monsterRefMaxBloodVessel then
		everyBloodValue = math.floor(self.monsterRefMaxBlood / self.monsterRefMaxBloodVessel)
	end
	
	return everyBloodValue
end	

--第一管血的血量
function MainBossHead:FirstBloodVesselValue()
	local everyBloodValue = self:EveryBloodVesselValue()
	local firstBloodValue = nil
	if everyBloodValue then
		firstBloodValue = self.monsterRefMaxBlood - everyBloodValue*(self.monsterRefMaxBloodVessel-1)
	end
	
	return firstBloodValue
end

--返回剩余血管数量
function MainBossHead:SurplusBloodVesselNum()
	local currentBloodVessel = nil
	local firstBloodValue = self:FirstBloodVesselValue()
	local everyBloodValue = self:EveryBloodVesselValue()	

	local deltaBlood = self.monsterRefMaxBlood - self.bossHp
	if deltaBlood < firstBloodValue then
		currentBloodVessel = self.monsterRefMaxBloodVessel								
	else
		currentBloodVessel = self.monsterRefMaxBloodVessel - math.ceil((deltaBlood - firstBloodValue)/everyBloodValue)
	end						
	
	return currentBloodVessel		
end

--返回当前和下一个要显示的血条,下一管血为nil当前为最后一管血
function MainBossHead:CurrentAndNextShowBloodVessel()
	local currentBloodVessel = self:SurplusBloodVesselNum()		
	local deltaBloodVessel = self.monsterRefMaxBloodVessel - currentBloodVessel
	local delta = deltaBloodVessel % bossHpColor.const_changeBloodVessel
	
	if currentBloodVessel == 1 then
		return bossHpColor.const_red
	end		
	
	if delta == 0 and currentBloodVessel > 2 then
		return bossHpColor.const_green, bossHpColor.const_yello
	elseif delta == 0 then
		return bossHpColor.const_green, bossHpColor.const_red
	end
	
	if delta == 1 and currentBloodVessel > 2 then
		return bossHpColor.const_yello, bossHpColor.const_blue
	elseif delta == 1 then
		return bossHpColor.const_yello, bossHpColor.const_red
	end
	
	if delta == 2 and currentBloodVessel > 2 then
		return bossHpColor.const_blue, bossHpColor.const_green
	elseif delta == 2 then
		return bossHpColor.const_blue, bossHpColor.const_red
	end
end

--当前血条要显示的血量的百分比,如90%返回90
function MainBossHead:CurrentBloodPercent()
	local currentBlood = self.bossHp	
	local everyBloodValue = self:EveryBloodVesselValue()
	local firstBloodValue = self:FirstBloodVesselValue()
	local deltaBlood = self.monsterRefMaxBlood - currentBlood
	local percent = nil
	
	if deltaBlood <= firstBloodValue then
		percent = deltaBlood / firstBloodValue
	else
		deltaBlood = deltaBlood - firstBloodValue
		local everyDeltaBlood = deltaBlood % (everyBloodValue + 1)
		percent = everyDeltaBlood/everyBloodValue
	end
	
	return (1 - percent)*100
end

--显示血条
function MainBossHead:ShowHpView()
	
	local first, second = self:CurrentAndNextShowBloodVessel()
	local bloodPercent = self:CurrentBloodPercent()	
	
	local currentBloodVessel = self:SurplusBloodVesselNum()
	local isAction = false
	local deltaRunTime = 0.1
	local lastVesselNumString = self.bloodVesselLabel:getString()
	local lastVesselNum = tonumber(string.sub(lastVesselNumString, 2))
	if lastVesselNum and lastVesselNum == currentBloodVessel then
		isAction = true
	end
	self.bloodVesselLabel:setString("x"..currentBloodVessel)
	
	for i, v in pairs(self.bossHpBars) do
		v:setVisible(false)
		v:setZOrder(0)
	end
	
	for i, v in pairs(self.bossHpBarsWithOpacity) do
		v:setVisible(false)
		v:setZOrder(0)
	end
		
	if first == bossHpColor.const_red then	
		self.bossHpBars[1]:setVisible(true)
		self.bossHpBars[1]:setZOrder(3)	
		self.bossHpBarsWithOpacity[1]:setVisible(true)
		self.bossHpBarsWithOpacity[1]:setZOrder(2)	
		self.bossHpBars[1]:setPercentage(bloodPercent)	
					
		if isAction then
						
			local lastPercent = self.bossHpBarsWithOpacity[1]:getPercentage()
			local Action = CCProgressFromTo:create(deltaRunTime*2, lastPercent, bloodPercent)
			self.bossHpBarsWithOpacity[1]:stopAllActions()
			self.bossHpBarsWithOpacity[1]:runAction(Action)			
		else				
			self.bossHpBarsWithOpacity[1]:setPercentage(bloodPercent)	
		end				
		return		
	end
	
	if first == bossHpColor.const_blue then	
		self.bossHpBars[2]:setVisible(true)
		self.bossHpBars[2]:setZOrder(3)	
		self.bossHpBars[2]:setPercentage(bloodPercent)
		self.bossHpBarsWithOpacity[2]:setVisible(true)
		self.bossHpBarsWithOpacity[2]:setZOrder(2)	
		if isAction then
			
			local lastPercent = self.bossHpBarsWithOpacity[2]:getPercentage()
			local Action = CCProgressFromTo:create(deltaRunTime*2, lastPercent, bloodPercent)
			self.bossHpBarsWithOpacity[2]:stopAllActions()
			self.bossHpBarsWithOpacity[2]:runAction(Action)
		else
			self.bossHpBarsWithOpacity[2]:setPercentage(bloodPercent)
		end											
		
		if second == bossHpColor.const_green then									
			self.bossHpBars[4]:setPercentage(100)
			self.bossHpBars[4]:retain()
			self.bossHpBars[4]:removeFromParentAndCleanup(false)
			self.hpBottom:addChild(self.bossHpBars[4])
			VisibleRect:relativePosition(self.bossHpBars[4], self.hpBottom, LAYOUT_CENTER, ccp(0, 0))
			self.bossHpBars[4]:setZOrder(0)
			self.bossHpBars[4]:setVisible(true)
			self.bossHpBars[4]:release()							
		else
			self.bossHpBars[1]:setVisible(true)		
			self.bossHpBars[1]:setPercentage(100)	
		end
		return
	end
	
	if first == bossHpColor.const_green then
		self.bossHpBars[4]:setVisible(true)
		self.bossHpBars[4]:setZOrder(3)
		self.bossHpBars[4]:setPercentage(bloodPercent)
		self.bossHpBarsWithOpacity[4]:setVisible(true)
		self.bossHpBarsWithOpacity[4]:setZOrder(2)				
		if isAction then
			local lastPercent = self.bossHpBarsWithOpacity[4]:getPercentage()
			local Action = CCProgressFromTo:create(deltaRunTime*2, lastPercent, bloodPercent)
			self.bossHpBarsWithOpacity[4]:stopAllActions()
			self.bossHpBarsWithOpacity[4]:runAction(Action)
		else
			self.bossHpBarsWithOpacity[4]:setPercentage(bloodPercent)
		end						
		
		if second == bossHpColor.const_yello then		
			self.bossHpBars[3]:setVisible(true)				
			self.bossHpBars[3]:setZOrder(2)
			self.bossHpBars[3]:setPercentage(100)
		else			
			self.bossHpBars[1]:setVisible(true)		
			self.bossHpBars[1]:setPercentage(100)
		end	
		return		
	end
	
	if first == bossHpColor.const_yello then
		self.bossHpBars[3]:setVisible(true)						
		self.bossHpBars[3]:setZOrder(3)	
		self.bossHpBars[3]:setPercentage(bloodPercent)
		self.bossHpBarsWithOpacity[3]:setVisible(true)						
		self.bossHpBarsWithOpacity[3]:setZOrder(3)	
		if isAction then
			local lastPercent = self.bossHpBarsWithOpacity[3]:getPercentage()
			local Action = CCProgressFromTo:create(deltaRunTime*2, lastPercent, bloodPercent)
			self.bossHpBarsWithOpacity[3]:stopAllActions()
			self.bossHpBarsWithOpacity[3]:runAction(Action)
		else
			self.bossHpBarsWithOpacity[3]:setPercentage(bloodPercent)
		end			
		
		if second == bossHpColor.const_blue then		
			self.bossHpBars[2]:setVisible(true)
			self.bossHpBars[2]:setZOrder(2)
			self.bossHpBars[2]:setPercentage(100)							
		else
			self.bossHpBars[1]:setVisible(true)
			self.bossHpBars[1]:setPercentage(100)
		end
		return
	end
end

-- boss归属权发生变化
function MainBossHead:bossOwnerChange(bossId, ownerId)
	local heroId = GameWorld.Instance:getEntityManager():getHero():getId()
	local entityFocusManager = GameWorld.Instance:getEntityManager():getHero():getEntityFocusManager()
	if (self.bossId == bossId and heroId == ownerId) then	
		self:setHpBarColor(ccc3(255, 255, 255))
	else
		self:setHpBarColor(ccc3(100, 100, 100))
	end	
end

function MainBossHead:setHpBarColor(color)
	if self.bossHpBars then
		self:setBarSpriteColor(self.bossHpBars,color)
	end

	if self.bossHpBarsWithOpacity then
		self:setBarSpriteColor(self.bossHpBarsWithOpacity,color)
	end
end

function MainBossHead:setBarSpriteColor(progressBar,color)
	for k,v in pairs(progressBar) do
		local sprite = v:getSprite()
		if sprite then
			sprite:setColor(color)
			v:setSprite(sprite)
			local percentage = v:getPercentage()
			if percentage then
				percentage = percentage -0.01
				v:setPercentage(percentage)
			end
		end
	end	
end

function MainBossHead:setViewHide()
	local offsetY = self:getOffsetY(OffsetYType.Up)	
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0, offsetY))	
	self.rootNode:runAction(moveBy)		
end

function MainBossHead:setViewShow()
	local offsetY = self:getOffsetY(OffsetYType.Down)	
	local moveBy = CCMoveBy:create(cont_UIMoveSpeed,ccp(0, offsetY))
	self.rootNode:runAction(moveBy)	
end

function MainBossHead:getOffsetY(moveType)
	local const_scaleY = VisibleRect:SFGetScaleY()
	if moveType == OffsetYType.Up then
		return (visibleSize.height/3)/const_scaleY - 92
	else
		return -(visibleSize.height/3)/const_scaleY + 92
	end		
end