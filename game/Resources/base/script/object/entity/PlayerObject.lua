require("object.entity.FightCharacterObject")
require("object.castleWar.CastleWarDef")

PlayerObject = PlayerObject or BaseClass(FightCharacterObject)
local const_scale = VisibleRect:SFGetScale()

local mofadunPos = {
up = 0,
down = 1,
}

ModeType =
{
eGenderMale = 1,
eGenderFemale = 2,

eModelMale_0 = 1000,
eModelMale_1= 1006,
eModelMale_2 = 1008,
eModelMale_3 = 1010,

eModelFemale_0 = 1001,
eModelFemale_1 = 1007,
eModelFemale_2 = 1009,
eModelFemale_3 = 1011,

ePlayerProfessionWarior = 1,
ePlayerProfessionMagic = 2,
ePlayerProfessionWarlock = 3,
}

MountModeOffSet = {
["5002"] = 20,
["5003"] = 25,
["5004"] = 20,
["5005"] = 10,
}

PlayerInfoPos = {
	-- 底部
	titleName	= 1,
	gildName	= 2,
	-- 头顶
	hpBars		= 1,
	unionIcon	= 2,
	monstorInvasionTitle	= 3,
}

function PlayerObject:__init()
	self.type = EntityType.EntityType_Player	-- 类型
	self.hasMount = false
	self.mountModelId = nil
	self.tipMsgLable = nil
	self.moduleId = 1000
	self.mountOffset = 0
	self.renderSprite:setAngle(Dir_D)
	self.graveImage = nil	-- 死亡后的墓碑图片
	self.loaded = false	
	self.titleTable = {}
	self.bottomTable = {}
	self:initPlayerState()
	self.titleSize = CCSizeMake(0,0)
	self.hasinitTitle = false
	self.showTitle = true
end

function PlayerObject:__delete()
	if self.graveImage then
		self.graveImage:release()
		self.graveImage = nil
	end
	self:clearTitle()	
	self:removePluckingAnimation()
end

function PlayerObject:initPlayerState()
	-- 坐骑待机
	function rideIdle_enter_fun()
		self:nofityStateChange(CharacterState.CharacterStateRideIdle, true)
		return self:enterRideIdle()
	end
	
	function rideIdle_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateRideIdle, false)
		return self:exitRideIdle(newState)
	end
	
	-- 坐骑移动
	function rideMove_enter_fun(cellX, cellY)
		self:nofityStateChange(CharacterState.CharacterStateRideMove, true)
		return self:enterRideMove(cellX, cellY)
	end
	
	function rideMove_exit_fun(newState)
		self:nofityStateChange(CharacterState.CharacterStateRideMove, false)
		return self:exitRideMove(newState)
	end
	
	-- 设置状态的回调
	self.state:setStateCallback(CharacterState.CharacterStateRideIdle, rideIdle_enter_fun, rideIdle_exit_fun)
	self.state:setStateCallback(CharacterState.CharacterStateRideMove, rideMove_enter_fun, rideMove_exit_fun)
end

function PlayerObject:enterMap()
	self.hasMount = false
	if not self.state:isState(CharacterState.CharacterStateDead) then
		self.state.actionState = CharacterState.CharacterStateNone
	end
	
	--todo 临时代码要删除的
	if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		local loadCallBack = function (node,layer)
			self:loadModule()
			self.bEnterMap = true
			sfmap:enterMap(self.renderSprite,layer)
			if self.renderSprite then									
				self.renderSprite:setVisible(true)
			end
			self:onEnterMap()
		end
		
		if sfmap then
			sfmap:enterMapAsyn(self.renderSprite,loadCallBack, self.mapLayer)
		end
	end
	self:addShadow()
	
end

function PlayerObject:onEnterMap()
	self:initTitle()		
	
	self.state:updateComboStateList(self.stateTable)
	self:updateSpeed()
	if self.targetX > 0 and self.targetY > 0 then
		local targetX = self.targetX
		local targetY = self.targetY
		self.targetX = nil
		self.targetY = nil
		self:moveTo(targetX, targetY)
	end

	self.renderSprite:setAlpha(255)
	local currentHP = PropertyDictionary:get_HP(self.table)
	if currentHP == 0 then
		self:DoDeath()
	end

	self:setMofaDunPosition()

end

function PlayerObject:initTitle()
	--self:createInfoNode()
	self:updateMonstorInvasionTitle(self.table)
	self:initHPBars()	
	self:updateGildName(self.table,false)	
	self:updateTitleName(self.table)	
	self:updateKnightTitle(self.table)	
	self:updateTitle()
	self.hasinitTitle = true

end

function PlayerObject:createInfoNode()
	if self.title == nil then
		self.title = CCNode:create()
		self.title:setScaleY(-1)
		self.renderSprite:addChild(self.title,999)
		local point = self:getUperPosition(0)
		VisibleRect:relativePosition(self.title,self.renderSprite,LAYOUT_CENTER_X+LAYOUT_TOP_OUTSIDE,ccp(0,point.y-3))		
	end
		
end

function PlayerObject:setInfoVisible(show)
	if self.hasinitTitle == false and show == true then
		self:initTitle()
	end
	self:updateTitle()
	self:setTitleVisible(show)
	self.showTitle = show
			
--[[	if self.bottom:isVisible() == false and show then
		self:updateBottom()
	end--]]
	
	--self:setBottomVisible(show)
end

function PlayerObject:setTitleVisible(show)
	if self.knightTitle then		
		self.knightTitle:setVisible(show)
	end
	
	if self.vipSprite then		
		self.vipSprite:setVisible(show)
	end

end

function PlayerObject:setNameVisible(show)
	if GameWorld.Instance:getTextManager():hasTitle(self:getId()) then
		GameWorld.Instance:getTextManager():setTiltleVisible(self:getId(),show)
		local gildId = self:getId()..gildKey
		GameWorld.Instance:getTextManager():setTiltleVisible(gildId,show)
	end		
end

function PlayerObject:setHpBarVisible(show)
	if self.hpBar then
		self.hpBar:setVisible(show)
	end
	
	if self.hpBarBg then
		self.hpBarBg:setVisible(show)
	end
end

function PlayerObject:initHPBars()
	self:initHPProgressBars()	
end

function PlayerObject:updateMonstorInvasionTitle(pt)
	if self.renderSprite then
		local index = PropertyDictionary:get_monsterInvasionFont(pt)
		self:setMonstorInvasionTitle(index)
	end
end

function PlayerObject:setMonstorInvasionTitle(index)
	local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
	if index == 0 or monstorInvasionMgr:isInActivity()==false then
		if self.monstorInvasionTitle then
			self.monstorInvasionTitle:removeFromParentAndCleanup(true)
			self.monstorInvasionTitle = nil
			self.titleTable[PlayerInfoPos.monstorInvasionTitle] = "close"
		end
	else
		if self.monstorInvasionTitle == nil then
			self.monstorInvasionTitle = createLabelWithStringFontSizeColorAndDimension("", "Arial", FSIZE("Size2"), FCOLOR("ColorWhite3"))
			self.monstorInvasionTitle:setScaleY(-1)			
			self.renderSprite:addChild(self.monstorInvasionTitle)
		end
		self.monstorInvasionTitle:setString(Config.Words[19505+index])
		self:updateTitle()
	end
end

function PlayerObject:updateTitleName(pt)
	local name = PropertyDictionary:get_name(pt)
	local id = self:getId()
	if not GameWorld.Instance:getTextManager():hasTitle(id) then	
		local x,y = self:getMapXY()
		local showName = PropertyDictionary:get_name(self:getPT())
		local size = GameWorld.Instance:getTextManager():addTitle(id,showName,FSIZE("Size3"),x,y)
		self.titleSize = size
	end
	--更新名字颜色
	self:updateNameColor()
	local vipLevel = PropertyDictionary:get_vipType(pt)
	if vipLevel > 0 and self.vipSprite == nil then
		self:updateVipIcon()		
	elseif self.vipLevel ~= vipLevel and pt.vipType then
		self:updateVipIcon()
	end		
end

function PlayerObject:updateVipIcon()
	local vipLevel = PropertyDictionary:get_vipType(self:getPT())
	if self.vipSprite then		
		SFMapService:instance():getShareMap():leaveMap(self.vipSprite)
		self.vipSprite:release()
		self.vipSprite = nil
	end
	if vipLevel > 0 then
		--创建
		self.vipSprite = createSpriteWithFrameName(RES("common_vip"..vipLevel..".png"))		
		self.vipSprite:setScaleY(-1)	
		self.vipSprite:retain()
		self.vipSprite:setVisible(self.showTitle)		
		SFMapService:instance():getShareMap():enterMap(self.vipSprite, eRenderLayer_Effect)
		local offset = self:getTitleOffset()
		local x,y = self:getMapXY()
		self.vipSprite:setVisible(self.showTitle)
		self.vipSprite:setPosition(x-self.titleSize.width/2-15,y-offset/2)	
		self.vipLevel = vipLevel
	end
end

function PlayerObject:updateGildName(pt,flag)
	local gildName = PropertyDictionary:get_unionName(pt)
	local tempid = self.id..gildKey
	if gildName == "" then				
		GameWorld.Instance:getTextManager():removeTilte(tempid)		
	else				
		local x,y = self:getMapXY()						
		if GameWorld.Instance:getTextManager():hasTitle(tempid) then
			GameWorld.Instance:getTextManager():removeTilte(tempid)		
		end
		GameWorld.Instance:getTextManager():addTitle(tempid,gildName,FSIZE("Size2"),x,y)			
	end
	
	if gildName ~= "" and PropertyDictionary:get_isKingCity(pt) == 1 then
		if self.unionIcon then		
			SFMapService:instance():getShareMap():leaveMap(self.unionIcon)
			self.unionIcon:release()
			self.unionIcon = nil
		end
		if not self.unionIcon then		
			self.unionIcon = createSpriteWithFrameName(RES("common_forging.png"))
			self.unionIcon:setScaleY(-1)	
			self.unionIcon:retain()
			self.unionIcon:setVisible(self.showTitle)
			local offset = self:getTitleOffset()
			local x,y = self:getMapXY()		
			SFMapService:instance():getShareMap():enterMap(self.unionIcon, eRenderLayer_Effect)
		end
	elseif self.unionIcon then
		SFMapService:instance():getShareMap():leaveMap(self.unionIcon)
		self.unionIcon:release()
		self.unionIcon = nil
	end
	if not flag then
		self:updateTitle()
	end			
end

--是的。就是显示头上那把看起来有点恶心的两把交叉其他的刀
function PlayerObject:showPKFlag(bShow)
	if not self.renderSprite then
		return
	end
	if bShow then
		if not self.pkFlagIcon then
			self.pkFlagIcon = createSpriteWithFrameName(RES("pk_head_icon.png"))
			self.renderSprite:addChild(self.pkFlagIcon)			
		end
		self:updateTitle()
	else
		if self.pkFlagIcon then
			self.renderSprite:removeChild(self.pkFlagIcon, true)
			self.pkFlagIcon = nil
		end
	end
end

function PlayerObject:updateKnightTitle(pt)
	local curKnight = PropertyDictionary:get_knight(pt)
	if curKnight ~= 0 then	
		if self.knightTitle then		
			SFMapService:instance():getShareMap():leaveMap(self.knightTitle)
			self.knightTitle:release()
			self.knightTitle = nil
		end
		local knightMgr = GameWorld.Instance:getEntityManager():getHero():getKnightMgr()
		self.knightTitle = knightMgr:getHeadIcon(curKnight)
		if self.knightTitle then
			self.knightTitle:setScaleY(-1)
			self.knightTitle:retain()
			self.knightTitle:setVisible(self.showTitle)			
			SFMapService:instance():getShareMap():enterMap(self.knightTitle, eRenderLayer_Effect)
			local offset = self:getTitleOffset()
			local x,y = self:getMapXY()
			local width = 0
			if self.titleSize and self.titleSize.width then
				width = self.titleSize.width
			end
			self.knightTitle:setPosition(x + width/2+15,y-offset/2)								
		end				
	end
end

function PlayerObject:updateTitle(adjust)
	
	local offset = self:getTitleOffset()
	local x,y = self:getMapXY()
	local offY = y-offset
	if self.hpBarBg then
		self.hpBarBg:setPosition(x,offY)
	end
	if self.hpBar then
		VisibleRect:relativePosition(self.hpBar,self.hpBarBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y)
	end
	
	if self.knightTitle then
		self.knightTitle:setPosition(x+self.titleSize.width/2+15,y-offset/2)
	end
	
	if self.vipSprite then
		self.vipSprite:setPosition(x-self.titleSize.width/2-15,y-offset/2)
	end
	
	if self.unionIcon then
		self.unionIcon:setPosition(x,y-offset-30)	
	end
	if self.pkFlagIcon then
		if self.unionIcon then	--如果有王城公会，则在王城图标坐标
			self.pkFlagIcon:setPosition(-40, -offset - 30)	
		else
			self.pkFlagIcon:setPosition(0, -offset - 30)	
		end
	end
	
	if self.monstorInvasionTitle then
		self.monstorInvasionTitle:setPosition(0,-offset-30)
	end
	if adjust ~= false then
		if self:getId() then
			local tempid = self.id..gildKey
			GameWorld.Instance:getTextManager():adjustPosition(tempid,0,-offset/2+20)
			GameWorld.Instance:getTextManager():adjustPosition(self:getId(),0,-offset/2)
		end
	end		
	
end


-- Player要处理坐骑
function PlayerObject:moveTo(x, y)
	if self.bEnterMap == false then
		self.targetX = x
		self.targetY = y
		return false
	end
	
	local cellX, cellY = self:getCellXY()
	if (self.targetX == x and self.targetY == y) then 
		return false
	elseif (cellX == x and cellY == y) and (self.state:isState(CharacterState.CharacterStateMove) or self.state:isState(CharacterState.CharacterStateRideMove)) then
		CCLuaLog("player move to:"..x.." ,"..y)
		self:moveStop()
		return false
	else
		if self.state:isState(CharacterState.CharacterStateMove) or self.state:isState(CharacterState.CharacterStateRideMove) then
			-- 如果不在移动的action, 再改变一次
			local actionId = self.renderSprite:getActionId()
			if actionId ~= EntityAction.eEntityAction_Run and actionId ~= EntityAction.eEntityAction_RideRun then
				if self.state:isState(CharacterState.CharacterStateMove) then
					self:changeAction(EntityAction.eEntityAction_Run, true)
				else
					self:changeAction(EntityAction.eEntityAction_RideRun, true)
				end
			end
			return self:fightCharacterMoveTo(x,y)
		else
			if self.state:isState(CharacterState.CharacterStateRideIdle) then
				return self.state:changeState(CharacterState.CharacterStateRideMove, x, y)
			else
				return self.state:changeState(CharacterState.CharacterStateMove, x, y)
			end
		end
	end
end

-- moveStop也要处理坐骑
function PlayerObject:moveStop()
	self:fightCharacterMoveStop()
	if self.state:isState(CharacterState.CharacterStateMove) then
		self.state:changeState(CharacterState.CharacterStateIdle)
	elseif self.state:isState(CharacterState.CharacterStateRideMove) then
		self.state:changeState(CharacterState.CharacterStateRideIdle)
	end
end

-- 进入坐骑的待机的状态
function PlayerObject:DoMountIdle()
	return self.state:changeState(CharacterState.CharacterStateRideIdle)
end

-- 进入坐骑的移动状态
function PlayerObject:DoMountMove()
	return self.state:changeState(CharacterState.CharacterStateRideMove)
end

-- 复活
function PlayerObject:DoRevive()
	-- 解锁状态
	self.renderSprite:setAlpha(255)
	self.renderSprite:setShaderProgram(CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor"))
	self.state:setIsLock(false)
	self.state:forceChangeState(CharacterState.CharacterStateIdle)
	self:setHP(PropertyDictionary:get_HP(self:getPT()))
end

-- 不要直接调用这个API
function PlayerObject:mountUp(modelId)
	self.hasMount = true
	self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,false)
	--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Mount,true)
	--local speed = PropertyDictionary:get_moveSpeed(self.table)
	if modelId == nil then
		modelId = PropertyDictionary:get_mountModleId(self.table)
	end		
	if modelId ~= 0  then
		self:changePart(EntityParts.eEntityPart_Mount,modelId,constDefaultMountId)
		if self.moving then
--			self:changeAction(EntityAction.eEntityAction_Run, false)
			--Juchao@20140704: EntityAction.eEntityAction_Run -> EntityAction.eEntityAction_RideRun。因为有马。
			self:changeAction(EntityAction.eEntityAction_RideRun, false)
		end
		if MountModeOffSet[tostring(modelId)] then
			self.mountOffset = MountModeOffSet[tostring(modelId)]
		else
			self.mountOffset = 0
		end	
		self.renderSprite:setRenderOffset(ccp(0,self.mountOffset))	
	end
	self:updateSpeed()
	self:updateTitle()
	--self:updateBottom()
	self:setShadowScale(2)
	--上下马改变魔法盾的位置
	self:setMofaDunPosition()
end

-- 不要直接调用这个API
function PlayerObject:mountDown()
	self.hasMount = false
	self.renderSprite:setRenderOffset(ccp(0 ,0))	
	self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Mount,false)
	self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,true)
	self:updateWeaponModule()
--[[	if self.moving then
		self:changeAction(EntityAction.eEntityAction_Run, true)
	else
		self:DoIdle()
	end--]]
	self:updateSpeed()
	self:updateTitle()	
	self:setShadowScale(1)

	--上下马改变魔法盾的位置
	self:setMofaDunPosition()
end

function PlayerObject:changePart(partId,moduleId,defaultId)
	local genderType = PropertyDictionary:get_gender(self.table)
	local x = 0
	local y = 0
	if partId == EntityParts.eEntityPart_Wing then
		y = 47		
	end
	if defaultId then
		if genderType == ModeType.eGenderFemale  and partId == EntityParts.eEntityPart_Weapon then
			self.renderSprite:changePartWithDefault(partId,moduleId,false,defaultId,x,y)
		else
			self.renderSprite:changePartWithDefault(partId,moduleId,true,defaultId,x,y)
		end
	else		
		CCLuaLog("PlayerObject:changePart the defaultid is nil")
	end
	
end

function PlayerObject:changeModel(modelId,defaultId)
	if defaultId then
		self.renderSprite:changeModelWithDefault(modelId,defaultId,true)		
	else
		self.renderSprite:changeModel(modelId)
	end
	
end

function PlayerObject:loadModule(flag)		
	self.renderSprite:load(constDefaultMaleId)	
	self:updateModule(flag)
end

function PlayerObject:updateWeaponModule()
	--CCLuaLog("PlayerObject:updateWeaponModule")
	local weaponId = PropertyDictionary:get_weaponModleId(self.table)	
	if weaponId ~= 0 and  not self.hasMount then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,true)
		self:changePart(EntityParts.eEntityPart_Weapon,weaponId,constDefaultWeaponId)
		if self.moving then
			self:changeAction(EntityAction.eEntityAction_Run, false)
		end
	else
		self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Weapon,false)
	end

end

function PlayerObject:updateArm()
	local armId = PropertyDictionary:get_armorModleId(self.table)
	local genderType = PropertyDictionary:get_gender(self.table)
	local defaultId = constDefaultMaleId
	if genderType ~= ModeType.eGenderMale then
		defaultId = constDefaultFemaleId
	end
	if armId ~= 0 then	
		self:changeModel(armId,defaultId,genderType)
	else
		self:changeModel(defaultId,defaultId,genderType)
	end
end

function PlayerObject:updateModule(flag)
	if self.renderSprite ~= nil then
		self:updateArm()
		self:updateWeaponModule()
		self:updateMountModule()
		self:updateWingModule()
		if flag == nil then
			self:updateTitleName(self.table)
			self:updateKnightTitle(self.table)
			self:updateGildName(self.table)
			self:updateMonstorInvasionTitle(self.table)		
			self:updateTitle()
		end
		
	end
end

--Juchao@20140519: 根据变化的属性进行调用对应的update函数
function PlayerObject:updateModuleByPd(newPd)
	if self.renderSprite == nil or (type(newPd) ~= "table") then
		return
	end		
	local oldWeapon = PropertyDictionary:getProperty(self:getPT(), "weaponModleId")
	local oldWing = PropertyDictionary:getProperty(self:getPT(), "wingModleId")
	local oldMount = PropertyDictionary:getProperty(self:getPT(), "mountModleId")
	local oldArm = PropertyDictionary:getProperty(self:getPT(), "armorModleId")
	local oldKnight = PropertyDictionary:getProperty(self:getPT(), "knight")
	local oldUnion = PropertyDictionary:getProperty(self:getPT(), "unionName")
	local oldIsKingCity  = PropertyDictionary:getProperty(self:getPT(), "isKingCity")
	local oldMonsterInvasionTitle = PropertyDictionary:getProperty(self:getPT(), "monsterInvasionFont")
	local oldName = PropertyDictionary:getProperty(self:getPT(), "name")
	local oldVipType = PropertyDictionary:getProperty(self:getPT(), "vipType") 
	local oldNameColor = PropertyDictionary:getProperty(self:getPT(), "nameColor")
	local oldPkMode = PropertyDictionary:getProperty(self:getPT(), "pkModel")
--	local oldPkValue = PropertyDictionary:getProperty(self:getPT(), "pkValue")
	
	local newWeapon = PropertyDictionary:getProperty(newPd, "weaponModleId")
	local newWing = PropertyDictionary:getProperty(newPd, "wingModleId")
	local newMount = PropertyDictionary:getProperty(newPd, "mountModleId")
	local newArm = PropertyDictionary:getProperty(newPd, "armorModleId")
	local newKnight = PropertyDictionary:getProperty(newPd, "knight")
	local newUnion = PropertyDictionary:getProperty(newPd, "unionName")
	local newIsKingCity  = PropertyDictionary:getProperty(newPd, "isKingCity")
	local newMonsterInvasionTitle = PropertyDictionary:getProperty(newPd, "monsterInvasionFont")
	local newName = PropertyDictionary:getProperty(newPd, "name")
	local newVipType = PropertyDictionary:getProperty(newPd, "vipType")
	local newNameColor = PropertyDictionary:getProperty(newPd, "nameColor")
	local newPkMode = PropertyDictionary:getProperty(newPd, "pkModel")	
--	local newPkValue = PropertyDictionary:getProperty(newPd, "pkValue")	
	self:updatePT(newPd)		--将新的PD合并到旧的PD当中
	if newArm and newArm ~= oldArm then
		self:updateArm()
	end
	if newWeapon and newWeapon ~= oldWeapon then
		self:updateWeaponModule()
	end
	if newMount and newMount ~= oldMount then
		self:updateMountModule()
	end
	if newWing and newWing ~= oldWing then
		self:updateWingModule()
	end
	if newKnight and newKnight ~= oldKnight then
		self:updateKnightTitle(self:getPT())
	end
	if (newUnion and newUnion ~= oldUnion) or (newIsKingCity and newIsKingCity ~= oldIsKingCity) then
		self:updateGildName(self:getPT())
	end
	if newMonsterInvasionTitle and newMonsterInvasionTitle ~= oldMonsterInvasionTitle then 
		self:updateMonstorInvasionTitle(self:getPT())
	end
	
	if not oldNameColor then
		oldNameColor = E_HeroNameColorType.White
	end
	if not newNameColor then
		newNameColor = E_HeroNameColorType.White
	end	
	
	if oldPkMode ~= newPkMode or newNameColor > oldNameColor then
		local nearbyMgr = GameWorld.Instance:getNearbyMgr()
		nearbyMgr:updateNearByPlayer()
	end
	if (newName and newName ~= oldName) 
		or (newVipType and newVipType ~= oldVipType)
		or (newNameColor and newNameColor ~= oldNameColor) then
		self:updateTitleName(self:getPT())
	end
end

function PlayerObject:updateWingModule()
	local wingId = PropertyDictionary:get_wingModleId(self.table)	
	if wingId ~= 0 then
		--self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,true)
		self:changePart(EntityParts.eEntityPart_Wing,wingId,constDefaultWing)
		local settingMgr = GameWorld.Instance:getSettingMgr()
		if settingMgr:isShowPlayerWing() == false then 
			self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,false)
		end
		if self.moving then
			self:changeAction(EntityAction.eEntityAction_Run, false)
		end
	else
		self.renderSprite:setVisiblePart(EntityParts.eEntityPart_Wing,false)
	end
end

function PlayerObject:updateMountModule()
	if not self.state:isState(CharacterState.CharacterStateDead) then
		local mountid = PropertyDictionary:get_mountModleId(self.table)
		if mountid ~= 0 then
			self:mountUp(mountid)
			if self.state:isState(CharacterState.CharacterStateMove) then
				self:DoMountMove()
			elseif not self.state:isState(CharacterState.CharacterStateRideMove) then
				self:DoMountIdle()
			end
		else
			self:mountDown()
			if self.state:isState(CharacterState.CharacterStateRideMove) then
				self:DoMove()
			elseif not self.state:isState(CharacterState.CharacterStateMove) then
				self:DoIdle()
			end
		end
		
	end
end



function PlayerObject:setAnimSpeed(speed)
	self.renderSprite:setAnimSpeed(speed)
end

function PlayerObject:GetMountModelId()
	return self.mountModelId
end

function PlayerObject:setMountModelId(id)
	self.mountModelId = id
end

function PlayerObject:GetWeaponId()
	return self.WeaponId
end

function PlayerObject:GetClothId()
	return self.ClothId
end

function PlayerObject:GetWingId()
	return self.WingId
end

function PlayerObject:enterRideMove(cellX, cellY)
	if self.hasMount == false then
		self:mountUp()
	end
	if cellX and cellY then
		if self:fightCharacterMoveTo(cellX, cellY) then
			self:changeAction(EntityAction.eEntityAction_RideRun, true)			
			return true
		else
			return false
		end
	else
		self:changeAction(EntityAction.eEntityAction_RideRun, true)	
		return true
	end
end

function PlayerObject:enterRideIdle()
	if self.hasMount == false then
		self:mountUp()
	end		
	self:changeAction(EntityAction.eEntityAction_RideIdle, true)
	
	return true
end

-- 退出坐骑状态的时候,  先不changeAction, 等切换状态的时候再切换为对应的actionId
function PlayerObject:exitRideIdle(newState)
	return true
end

function PlayerObject:exitRideMove(newState)
	-- 如果新状态不是移动,  就可以把移动停止了
	if newState ~= CharacterState.CharacterStateMove then
		self:fightCharacterMoveStop()
	end
	
	return true
end

function PlayerObject:enterHitFly(cellX, cellY, callback)
	local destMapX, destMapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	function finishCallback()
		self.state:setIsLock(false)
		
		if self.moveAction then
			self.moveAction:release()
			self.moveAction = nil
		end
		
		if callback then
			callback()
		end
		self:setMapXY(destMapX,destMapY)
		self:setAllTitleVisible(true)
	end
	if not self.hasMount then
		self:changeAction(EntityAction.eEntityAction_Hit, true)
	end
	self.state:setIsLock(true)
	self:setAllTitleVisible(false)
	local flyTime = 0.5
	
	
	local srcMapX, srcMapY = self:getMapXY()
	
	-- 如果x坐标相同, 用CCMoveTo, 如果不同，创建一个贝塞尔曲线
	local action = nil
	if srcMapX == destMapX then
		action = CCMoveTo:create(flyTime, ccp(destMapX, destMapY))
	else
		local angle = 0
		if srcMapX > destMapX then
			angle = 6.28/8
		else
			angle = 6.28*7/8
		end
		
		local ptSrc = ccp(srcMapX, srcMapY)
		local ptDest = ccp(destMapX, destMapY)
		local rotatePt = ccpRotateByAngle(ptDest, ptSrc, angle)
		rotatePt = ccpNormalize(ccpSub(rotatePt, ptSrc))
		local distance = ccpDistance(ptSrc, ptDest)
		rotatePt = ccpAdd(ccpMult(rotatePt, distance*0.707), ptSrc)
		
		local config = ccBezierConfig()
		config.endPosition = ptDest
		config.controlPoint_1 = rotatePt
		config.controlPoint_2 = rotatePt
		
		action = CCBezierTo:create(flyTime, config)
	end
	
	local actionArray = CCArray:create()
	actionArray:addObject(action)
	actionArray:addObject(CCCallFunc:create(finishCallback))
	
	self.moveAction = CCSequence:create(actionArray)
	self.moveAction:retain()
	
	-- 移动模型
	self:getRenderSprite():runAction(self.moveAction)
	
	-- 移动阴影
	self:getShadow():runAction(CCMoveTo:create(flyTime, ccp(destMapX, destMapY)))
	
end

function PlayerObject:enterHitBack(cellX, cellY, callback)
	local mapX, mapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	function finishCallback()
		self.state:setIsLock(false)
		
		if self.moveAction then
			self.moveAction:release()
			self.moveAction = nil
		end
		
		if callback then
			callback()
		end
		self:setMapXY(mapX,mapY)
		self:setAllTitleVisible(true)
	end
	
	if not self.hasMount then
		self:changeAction(EntityAction.eEntityAction_Hit, true)
	end
	self:setAllTitleVisible(false)
	self.state:setIsLock(true)
	local flyTime = 0.5
	
	
	
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(flyTime, ccp(mapX, mapY)))
	actionArray:addObject(CCCallFunc:create(finishCallback))
	
	self.moveAction = CCSequence:create(actionArray)
	self.moveAction:retain()
	
	-- 移动模型
	self:getRenderSprite():runAction(self.moveAction)
	
	-- 移动阴影
	self:getShadow():runAction(CCMoveTo:create(flyTime, ccp(mapX, mapY)))
end


-- 设置自己为隐身
function PlayerObject:setIsInvisible(isInvisible)
	if isInvisible then
		self.renderSprite:setEnableOpacity(true)
		self.renderSprite:setAlpha(100)
	else
		self.renderSprite:setAlpha(255)
		self.renderSprite:setEnableOpacity(false)
	end
end

-- 死亡状态
function PlayerObject:enterDeath(effectId)
	-- 死亡自动下马
	self:mountDown()
	self:moveStop()
	self:compareHP()
	self:getRenderSprite():setRenderSpriteVisible(false)
	--显示名字
	if self.title then
		self.title:setVisible(true)
	end
	if self.graveImage == nil then
		self.graveImage = createSpriteWithFileName("ui/ui_img/common/gravestone.png")
		self.graveImage:retain()
		self.graveImage:setScaleY(-1)
		self:getRenderSprite():addChild(self.graveImage)
		local posX,posY = self.graveImage:getPosition()
		local newposition = ccp(posX, (posY-30))
		self.graveImage:setPosition(newposition)
	end
	
	-- 锁住状态
	self.state:updateComboStateList(nil)
	self.state:setIsLock(true)
	
	return true
end

function PlayerObject:exitDeath()
	self:getRenderSprite():setRenderSpriteVisible(true)
	
	if self.graveImage then
		self:getRenderSprite():removeChild(self.graveImage, true)
		self.graveImage:release()
		self.graveImage = nil
	end
	self:updateNameColor()
	return true
end

-- 动作播放速度相关的函数
function PlayerObject:getIdleAnimateSpeed()
	return 0.6
end

function PlayerObject:getAttackAnimateSpeed()
	local atkSpeed = PropertyDictionary:get_atkSpeed(self:getPT())
	
	local speedPer = 1-atkSpeed/1000
	local animateSpeed = 1.265
	if speedPer > 0 then
		animateSpeed = animateSpeed*(1 + speedPer)
	elseif speedPer < 0 then
		animateSpeed = animateSpeed/(1-speedPer)
	else
		animateSpeed = animateSpeed
	end
	
	return animateSpeed
end

function PlayerObject:getMoveAnimateSpeed()
	return 1.5
end

function PlayerObject:getRideMoveAnimateSpeed()
	return 1.7
end


--设置魔法盾的位置
function PlayerObject:setMofaDunPosition()
	local effect = self.renderSprite:getChildByTag(100)
	if effect then
		local x = effect:getPositionX()
		if  not self.hasMount then
			effect:setPosition(x, 0)
		else
			effect:setPosition(x, -50)
		end
	end
end

--采集动画
function PlayerObject:createPluckingAnimation()
	local animate = createAnimate("collectAnimation_", 3, 0.05, 1)
	self.animateSprite = CCSprite:create()
	if self.renderSprite then
		self.animateSprite:setScaleY(-1)
		self.renderSprite:addChild(self.animateSprite)
		self.animateSprite:runAction(CCRepeatForever:create(animate))
		
		local offset = self:getTitleOffset()
		local x,y = self:getMapXY()
			
		self.animateSprite:setPosition(self.titleSize.width/2+25,-offset)	
	end
end

function PlayerObject:removePluckingAnimation()
	if self.animateSprite then
		self.animateSprite:removeFromParentAndCleanup(true)
		self.animateSprite = nil
	end
end
-- 组合状态的回调
function PlayerObject:comboStateCallback(state, bEnter)
	if self.bEnterMap then			
		if state and bEnter == true then
			FightStateEffect:Instance():enterState(state, self)
		elseif state and bEnter == false then
			FightStateEffect:Instance():exitState(state, self)
		end	
		if state == CharacterState.CharacterStateCollect  then
			if bEnter then
				self:createPluckingAnimation()
			else
				self:removePluckingAnimation()
			end
		end
	end
end


function PlayerObject:getHasMount()
	return self.hasMount
end

function PlayerObject:setType(PlayerType)
	self.type = PlayerType
end

function PlayerObject:getType()
	return self.type
end

--Juchao@20140311:重写该函数，加入对沙巴克攻城时颜色处理
function PlayerObject:updateNameColor()
	if G_getCastleWarMgr():isInCastleWar() then
		local color
		if PropertyDictionary:get_unionName(self:getPT()) == G_getCastleWarMgr():getCastleWarBossUnionName() then
			color = FCOLOR("ColorBlue2")
		else	--攻城公会显示红色
			color = FCOLOR("ColorRed1")
		end			
		GameWorld.Instance:getTextManager():updateColor(self.id,color)
	else
		FightCharacterObject.updateNameColor(self)
	end
end	


--是否在王城公会里面
function PlayerObject:isInKingCityFaction()
	return PropertyDictionary:get_isKingCity(self:getPT()) == 1
end

function PlayerObject:changeAction(actionId, bLoop,callBack)
	-- 如果之前已经设置了回调，先回调结束		
	if self.actionCallback then
		self:actionCallbackFunc(actionId, CharacterMovement.Cancel)
	end
	
	local callbackFunc = function (actionId, movementType)
		self:actionCallbackFunc(actionId, movementType)
		
		if movementType ~= 0 then
			self.actionCallback = nil
		end
	end
	
	self.actionCallback = callBack
	
	if self.renderSprite ~= nil then
		if callBack then
			self.renderSprite:changeActionCallback(actionId, 1, bLoop, callbackFunc)
		else
			self.renderSprite:changeAction(actionId, 1, bLoop)
		end
		
		-- 设置不同动作的播放速度
		if (actionId == EntityAction.eEntityAction_Attack or actionId == EntityAction.eEntityAction_Skill1
			or actionId == EntityAction.eEntityAction_Skill2 or actionId == EntityAction.eEntityAction_Skill3) then
			self.renderSprite:setAnimSpeed(self:getAttackAnimateSpeed())
		elseif actionId == EntityAction.eEntityAction_Run then
			self.renderSprite:setAnimSpeed(self:getMoveAnimateSpeed())
		elseif actionId ==  EntityAction.eEntityAction_RideRun then
			self.renderSprite:setAnimSpeed(self:getRideMoveAnimateSpeed())
		elseif actionId == EntityAction.eEntityAction_Idle or actionId == EntityAction.eEntityAction_RideIdle then
			self.renderSprite:setAnimSpeed(self:getIdleAnimateSpeed())
		end			
		
		--self:repositionWing(actionId)			
		self:updateTitle()
	end
end	

function PlayerObject:clearTitle()
	if self.knightTitle then		
		SFMapService:instance():getShareMap():leaveMap(self.knightTitle)
		self.knightTitle:release()
		self.knightTitle = nil
	end
	
	if self.vipSprite then		
		SFMapService:instance():getShareMap():leaveMap(self.vipSprite)
		self.vipSprite:release()	
		self.vipSprite = nil
	end
	
	if self.unionIcon then
		SFMapService:instance():getShareMap():leaveMap(self.unionIcon)
		self.unionIcon:release()
		self.unionIcon = nil
	end
end

function PlayerObject:setMapXY(mapX, mapY)
	if self.renderSprite ~= nil then
		self.renderSprite:setZOrder(mapY)
		self.renderSprite:setPositionX(mapX)
		self.renderSprite:setPositionY(mapY)
		--self.renderSprite:setPosition(mapX, mapY)
	end
	local offset = self:getTitleOffset()
	if self.shadowSprite then
		self.shadowSprite:setPosition(mapX, mapY)
	end
	if self.textPositionCallBack then
		self.textPositionCallBack(mapX,mapY)
	end
			
	GameWorld.Instance:getTextManager():updatePosition(self:getId(),mapX,mapY)
	local tempid = self.id..gildKey
	GameWorld.Instance:getTextManager():updatePosition(tempid,mapX,mapY)
	self:updateTitle(false)
end

function PlayerObject:setAllTitleVisible(show)
	
	if GameWorld.Instance:getEntityManager():isHero(self:getId()) then
		self:setTitleVisible(show)	
		self:setNameVisible(show)
	elseif GameWorld.Instance:getSettingMgr():isShowPlayerName() == true then
		self:setTitleVisible(show)
		self:setNameVisible(show)
	end
	self:setHpBarVisible(show)
end

--判断是否有宠物
function PlayerObject:hasPet()
	return (self.petId and self.petId ~= "")
end

function PlayerObject:setPet(id)
	self.petId = id	
end

function PlayerObject:getPet()
	return self.petId
end