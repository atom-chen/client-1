--[[
������ʵ�����Ļ���
]]--

require("common.BaseObj")
gildKey = "gild"
-- Entity Type ����
EntityType = {
EntityType_Monster 	= 1,
EntityType_Player	= 2,			--heroҲ��player����
EntityType_NPC		= 3,			--����,���,�ɼ��NPC���������MapItem�Ǳ�����ˣ������������ѱ���ɼ��ﶨΪNPC���ͣ�����ֻ�ܰ���������
EntityType_Loot	= 4,				--��ͼ����
EntityType_Effect 	= 5,			--��ͼ��Ч������������ħ���������ͼ��Ч
EntityType_Pluck = 6,
EntityType_Safe_Region = 7,
EntityType_PlayerAvatar = 8 --�������
}

--monster Type
EntityMonsterType = {
EntityMonster_Normal = 1,
EntityMonster_Elite = 2,
EntityMonster_Boss = 3
}

EntityAction = {
eEntityAction_Idle=1,--վ��
eEntityAction_Run=0,		--�ܲ�����
eEntityAction_Attack=2,	--����
eEntityAction_RideIdle=4,	--��ɫ�����ﶯ��
eEntityAction_RideRun=5,--��ɫ�������ƶ�
eEntityAction_Hit = 3,	--�ܻ�����
eEntityAction_Skill1=6,--��ʦ�͵�ʿ�ļ��ܶ���1
eEntityAction_Skill2=7,--��ʦ�͵�ʿ�ļ��ܶ���2
eEntityAction_Skill3=8,  --սʿ���еļ��ܶ���
eEntityAction_Monster_Idle= 9,
eEntityAction_Npc_Idle = 10,
}

EntityParts = {
eEntityPart_Mount = 0,--����
eEntityPart_Body = 1,		-- ����
eEntityPart_Cloth = 2,		--�·�
eEntityPart_Weapon = 3,--����
eEntityPart_Wing = 4, --���
eEntityPart_Max = 5,
}

EntityObject = EntityObject or BaseClass(BaseObj)

function EntityObject:__init()
	self.type = EntityType.EntityType_Monster	-- ����
	self.moduleId = 1010						-- ģ��id
	self.table = {}
	self.title = nil
	self.refId = ""
	self.headSelectEffect = nil		-- ͷ����ѡ����Ч
	self.bEnterMap = false	-- �Ƿ��Ѿ�enterMap
	self.mapLayer = eRenderLayer_Sprite
	self:createModule()
	self.x = 0
	self.y = 0
end

function EntityObject:__delete()
	if self.renderSprite then
		self.renderSprite:release()
		self.renderSprite = nil
	end
	
	if self.hpBar then	
		SFMapService:instance():getShareMap():leaveMap(self.hpBar)
		self.hpBar:release()
		self.hpBar = nil
	end
	
	if self.hpBarBg then
		SFMapService:instance():getShareMap():leaveMap(self.hpBarBg)
		self.hpBarBg:release()
		self.hpBarBg = nil
	end
	
	if self.table then
		for k,v in pairs(self.table) do
			self.table[k] = nil
		end
	end
	
	self.table = nil
	self = nil
end

function EntityObject:isEnterMap()
	return self.bEnterMap
end

function EntityObject:setShader(shader)
	if self.renderSprite and self.bEnterMap and shader then
		self.renderSprite:setShaderProgram(shader)
		return true
	end
	
	return false
end

function EntityObject:forceSetShader(shader)
	if self.renderSprite then
		self.renderSprite:setShaderProgram(shader)
		return true
	end
	
	return false
end

function EntityObject:createModule()
	self.renderSprite = RpgSprite:create()		-- object��ʵ��ģ��
	self.renderSprite = tolua.cast(self.renderSprite,"RpgSprite")
	self.renderSprite:retain()
end

--entity ͷ������
function EntityObject:getUperPosition(size)
	local uperPosition = 0
	if self.renderSprite then
		uperPosition = -110
	end
	
	if self.hasMount then
		uperPosition = uperPosition-45
	end
	local point = ccp(19,uperPosition)
	return point
end

function EntityObject:getEntityType()
	return self.type
end

function EntityObject:setEntityType(entityType)
	self.type = entityType
end

function EntityObject:setModuleId(id)
	self.moduleId = id
end

function EntityObject:getModuleId()
	return self.moduleId
end

function EntityObject:getRenderSprite()
	return self.renderSprite
end

function EntityObject:loadModule()
	if self.renderSprite ~= nil then
		if type(self.moduleId) == "string" then
			self.renderSprite:load(tonumber(self.moduleId))
		else
			self.renderSprite:load(self.moduleId)
		end
	end
end

function EntityObject:enterMap()
	if self.renderSprite ~= nil and  (not self.bEnterMap) then
		local sfmap = SFMapService:instance():getShareMap()
		local loadCallBack = function (node,layer)
			self:loadModule()
			self.bEnterMap = true
			sfmap:enterMap(self.renderSprite,layer)
			self:onEnterMap()
		end
		
		if sfmap then
			sfmap:enterMapAsyn(self.renderSprite,loadCallBack, self.mapLayer)
		end
	end
end

function EntityObject:onEnterMap()
	
end

function EntityObject:onLeaveMap()
	if self.shadowSprite then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.shadowSprite)
		end
	end
	GameWorld.Instance:getTextManager():removeTilte(self:getId())
	local temp = self:getId()..gildKey
	GameWorld.Instance:getTextManager():removeTilte(temp)
end

function EntityObject:leaveMap()
	if self.renderSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		sfmap:leaveMap(self.renderSprite)
		self:onLeaveMap()
	end
	
	if self.hpBarBg then
		self.hpBarBg:stopAllActions()
	end
	
	if self.hpBar then
		self.hpBar:stopAllActions()
	end
end

function EntityObject:setMapXY(mapX, mapY)
	if self.renderSprite ~= nil then
		self.renderSprite:setPosition(mapX, mapY)
	end
	local offset = self:getTitleOffset()
	if self.shadowSprite then
		self.shadowSprite:setPosition(mapX, mapY)
	end
	if self.textPositionCallBack then
		self.textPositionCallBack(mapX,mapY)
	end
		
	GameWorld.Instance:getTextManager():updatePosition(self:getId(),mapX,mapY)
	if self.updateTitle then
		self:updateTitle(false)
	end		
end

function EntityObject:getMapXY()
	if self.renderSprite and self.renderSprite.getPositionX and self.renderSprite.getPositionY then
		return self.renderSprite:getPositionX(), self.renderSprite:getPositionY()
	else
		return self.targetX, self.targetY
	end
end

function EntityObject:setCellXY(cellX, cellY)
	self.x, self.y = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
	self:setMapXY(self.x, self.y)
end

function  EntityObject:getCellXY()
	local x,y = self:getMapXY()
	local sfPoint
	if x and y then
		sfPoint = SFMap:coodMap2Cell(x, y)
	end
	if not sfPoint then
		return 0,0
	end
	return sfPoint:getX(), sfPoint:getY()
end

function EntityObject:setAngle(angle)
	if self.renderSprite ~= nil and  self.renderSprite.setAngle then
		self.renderSprite:setAngle(angle)
	end
end

function EntityObject:getAngle()
	if self.renderSprite then
		return self.renderSprite:getAngle()
	else
		return 0
	end
end

function EntityObject:angle2IndexDirection(angle, dirnum)
	if dirnum <= 0 then
		return 0
	else
		local minOffset = 0x0fffffff
		local index = 0
		local langle = 360 / dirnum
		
		for i = 0, dirnum do
			local dir = i * langle
			local offset = angle - dir
			if offset < -180 or offset > 180 then
				offset = dir + 360 - angle
			elseif offset < 0 then
				offset = -offset
			end
			
			if offset < minOffset then
				minOffset = offset
				index = i
			end
		end
		
		return index
	end
end

function EntityObject:changeAction(actionId, bLoop,callBack)
	if self.renderSprite ~= nil then
		if callBack then
			self.renderSprite:changeActionCallback(actionId, 1, bLoop,callBack)
		else
			self.renderSprite:changeAction(actionId, 1, bLoop)
		end
		--self:updateTitle()
		--self.renderSprite:setAnimSpeed(1.2)
	end
end

function EntityObject:getCenterY()
	return self.renderSprite:getCenterPositionY()
end

function EntityObject:addChild(titleNode)
	if self.renderSprite ~= nil then
		self.renderSprite:addChild(titleNode)
	end
end

function EntityObject:removeChild(titleNode)
	if self.renderSprite ~= nil then
		self.renderSprite:removeChild(titleNode, true)
	end
end

function EntityObject:faceToCell(cellX, cellY)
	if self.renderSprite then
		local targetMapX, targetMapY = GameWorld.Instance:getMapManager():cellToMap(cellX, cellY)
		local mapX, mapY = self:getMapXY()
		
		-- ��ͼ������ϵ��ԭ�������Ͻ�, ����Y��Ҫ��ת
		local angle = math.atan2( targetMapX - mapX, mapY - targetMapY)
		local dir = angle * (180 / 3.14159265359)
		if dir < 0 then
			dir = dir + 360
		end
		dir = dir % 360
		dir = self:angle2IndexDirection(dir,8)
		self.renderSprite:setAngle(dir)
		
		--[[
		local dirction = {
		[0] = "��",
		[1] = "����",
		[2] = "��",
		[3] = "����",
		[4] = "��",
		[5] = "����",
		[6] = "��",
		[7] = "����",
		}
		if self:getId() == GameWorld.Instance:getEntityManager():getHero():getPet() then
			if self.moving then
				print("self.moving true")
			end
		end
		print(dirction[dir])--]]
	end
	
end

function EntityObject:tick(time)
	
end

function EntityObject:updateTitle()
	if self.selected then
		local offset = self:getTitleOffset()
		local x,y = self:getMapXY()
		local offY = y-offset
		if self.hpBarBg then
			self.hpBarBg:setPosition(x,offY)
		end
		if self.hpBar then
			VisibleRect:relativePosition(self.hpBar,self.hpBarBg,LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y)
		end
	end
end

function EntityObject:updateSpeed()
	local speed = PropertyDictionary:get_moveSpeed(self.table)
	if speed > 0 and self.move then	--Juchao@20140523: ���Ӷ�self.move�Ŀ��ж�
		local oldSpeed = self.move:GetSpeed()
		if oldSpeed ~= speed then
			self.move:SetSpeed(speed)
		end
	end
end

local getHeadEffectAction = function ()
	local array = CCArray:create()
	array:addObject(CCMoveBy:create(0.5, ccp(0, 15)))
	array:addObject(CCMoveBy:create(0.5, ccp(0, -15)))
	return  CCRepeatForever:create(CCSequence:create(array))
end

-- ����ѡ����Ч
function EntityObject:setSelectEffect(visible)
	self:setHPEffect(visible)
end

-- ����Ѫ��ѡ����Ч
function EntityObject:setHPEffect(operate)
	if self.hpBarBg then
		if operate then
			self.hpBarBg:setVisible(true)
			self.hpBar:setVisible(true)
			local hpBarBgHeight = self.hpBarBg:getContentSize().height
			local hpBarHeight = self.hpBar:getContentSize().height
			local hpBarScaleY = (hpBarBgHeight*3-2)/hpBarHeight
			self.hpBarBg:setScaleY(3)
			self.hpBar:setScaleY(hpBarScaleY)
			
			local runSelectEffect = function (node)
				if node then
					node:stopAllActions()
					local array = CCArray:create()
					local fadeIn = CCFadeIn:create(0.5)
					local fadeOut = CCFadeOut:create(0.5)
					array:addObject(fadeIn)
					array:addObject(fadeOut)
					local action = CCSequence:create(array)
					node:runAction(CCRepeatForever:create(action))
				end
			end
			
			runSelectEffect(self.hpBarBg)
			runSelectEffect(self.hpBar)
		else
			self.hpBarBg:setVisible(false)
			self.hpBar:setVisible(false)
			self.hpBarBg:setScaleY(1)
			self.hpBar:setScaleY(1)
			
			self.hpBarBg:stopAllActions()
			self.hpBar:stopAllActions()
			
			self.hpBarBg:setOpacity(255)
			self.hpBar:setOpacity(255)	
		end
		self:updateTitle()
	end
end

function EntityObject:setVisible(show)
	if self.renderSprite then
		self.renderSprite:setVisible(show)
	end
end

function EntityObject:setTitleVisible(show)
	if self.title then
		self.title:setVisible(show)
	end
end

function EntityObject:setBottomVisible(show)
	if self.bottom then
		self.bottom:setVisible(show)
	end
end

function EntityObject:setSelFlag(selFlag)
	self.selFlag = selFlag
end

function EntityObject:getSelFlag()
	return self.selFlag
end

function EntityObject:getTitle()
	return self.title
end

function EntityObject:getTitleOffset()
	if self.hasMount then
		return 175
	end
	return 110
end