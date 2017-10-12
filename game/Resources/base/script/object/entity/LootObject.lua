require("object.entity.EntityObject")
require("object.entity.EntityObject")
require ("data.item.equipItem")
require("data.item.propsItem")	
require("object.skillShow.player.CallbackPlayer")
require("object.skillShow.player.DelayPlayer")
require("object.skillShow.player.SequenceAnimate")
LootObject = LootObject or BaseClass(EntityObject)

function LootObject:__init()
	self.type = EntityType.EntityType_Loot
	self.refId = "gold"
	self.owner = 1 				--是否属于你	
	self.showSprite = nil 		--显示精灵
	self.protectTime = 0 		--保护时间
	self.nextPickupTime = 0 	--下一次可以被拾取的时间。每个物品在拾取后，都会在一定时间之后不能再拾取
	self.x = 0
	self.y = 0
end

function LootObject:__delete()
	if self.showSprite then
		self.showSprite:release()
		self.showSprite = nil
	end
	if self.label then
		self.label:release()
		self.label = nil
	end
	if self.effectSprite then
		self.effectSprite:release()
		self.effectSprite = nil
	end
end

function LootObject:createModule()
	self.renderSprite = nil
end

function LootObject:setOwner(owner)
	self.owner = owner
end

function LootObject:canBeCollect()
	local now = os.time()
	
	if not (self.owner == 1) then		
		if now < self.protectTime then
			return false
		end
	end		
	return (now >= self.nextPickupTime)
end

function LootObject:loadModule()
	
	if self.showSprite == nil then
		self.showSprite = createSpriteWithFrameName(RES(self:toSmallIcon(self.refId)))
		if self.showSprite then
			self.showSprite:setScaleY(-1)
			self.showSprite:retain()
			self.label = self:showingLabel()
			if self.label then
				self.label:setScaleY(-1)
				self.label:retain()		
			end				
						
		end
	end
end

function LootObject:toSmallIcon(refId)
	local temp = "small_gold.png"
	if refId ~= "gold" then
		local property = self:getItemProperty()
		if property then
			temp = PropertyDictionary:get_smallIconId(property)..".png"
		end
	end
	return temp
end

function LootObject:setRefId(refId)
	self.refId = refId
	self:getItemProperty()
end	

function LootObject:getItemProperty()
	if self.propertyTabel == nil then	
	
		local data = GameData.EquipItem[self.refId]
		if data == nil then		
			data = GameData.PropsItem[self.refId]			
		end
		if data then
			self.propertyTabel = data["property"]			
		end
	end
	return self.propertyTabel
end

function LootObject:isEquip()
	if self.propertyTabel then
		return PropertyDictionary:get_itemType(self.propertyTabel) == ItemType.eItemEquip
	end		
	return false
end

function LootObject:isGold()
	return (not self.propertyTabel)	--为空则为金币
end

function LootObject:getEquipLevel()
	if self.propertyTabel then
		return PropertyDictionary:get_equipLevel(self.propertyTabel)
	end
	return 0
end

function LootObject:getEquipQuality()
	if self.propertyTabel then
		return PropertyDictionary:get_quality(self.propertyTabel)
	end
	return 0
end

function LootObject:getProfessionId(refId)
	if self.propertyTabel then
		return PropertyDictionary:get_professionId(self.propertyTabel)
	end
	return 0
end

function LootObject:setProtectTime(saveTime)
	local now = os.time()	
	self.protectTime = now+saveTime
end	


function LootObject:clearNextPickupTime()
	self.nextPickupTime = 0
end

function LootObject:setNextPickupTime(time)
	self.nextPickupTime = time
end

function LootObject:enterMap()
	if self.refId ~= nil then
		local sfmap = SFMapService:instance():getShareMap()		
		if self.showSprite then
			if sfmap then
				sfmap:enterMap(self.showSprite, eRenderLayer_SpriteBackground)
				if self.label then
					sfmap:enterMap(self.label, eRenderLayer_Sprite)
				end				
				
				sfmap:enterMap(self.effectSprite, eRenderLayer_Sprite)								
			end				
			self:onEnterMap()
		end
	end
end

function LootObject:runFlushAnimate()
	self.effectSprite = SFRenderSprite:createRenderSprite(8012, 0, "res/scene/")	
	self.effectSprite:playByIndexLua(0)	
	self.effectSprite:setScaleY(-1)
	--.effectSprite:setScaleX(1)
	self.effectSprite:setAnimationSpeed(0.7)
	self.effectSprite:retain()
	if self.effectSprite then
		self.effectSprite:setPosition(self.x-35, self.y+80)---24.5
		SFMapService:instance():getShareMap():enterMap(self.effectSprite, eRenderLayer_Sprite)	
	end
	local finish = function ()
		self:removeFlush()
		self:DeleteMe()
	end
	local delay = CCDelayTime:create(0.3)
	local callback = CCCallFunc:create(finish)
	local Sequence = CCSequence:createWithTwoActions(delay,callback)
	self.effectSprite:runAction(Sequence)	
end

function LootObject:removeFlush()
	if self.effectSprite then
		SFMapService:instance():getShareMap():leaveMap(self.effectSprite)
	end	
end

function LootObject:leaveMap()
	
	if self.showSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.showSprite)
			if self.label then
				sfmap:leaveMap(self.label)	
			end												
		end				
	end
	self:runFlushAnimate()
end

function LootObject:forceLeaveMap()
	if self.showSprite ~= nil then
		local sfmap = SFMapService:instance():getShareMap()
		if sfmap then
			sfmap:leaveMap(self.showSprite)
			if self.label then
				sfmap:leaveMap(self.label)	
			end												
		end				
	end
	self:DeleteMe()		
end

function LootObject:setMapXY(mapX, mapY)
	if self.showSprite ~= nil then
		self.showSprite:setPosition(mapX, mapY)
		if self.label then
			self.label:setPosition(mapX, mapY-30)
		end	
		if self.effectSprite then
			self.effectSprite:setPosition(mapX-35, mapY)---24.5
		end		
		
	end
	self.x = mapX
	self.y = mapY
end

function LootObject:getMapXY()
	if self.showSprite then
		return self.showSprite:getPositionX(), self.showSprite:getPositionY()
	else
		print ("error: refId"..self.refId)	
	end		
end	

function LootObject:onEnterMap()
	local entityManager = GameWorld.Instance:getEntityManager()	
	if entityManager:willPerform(self:getId()) then
		self:performAnimate()
	end
end

function LootObject:performAnimate()
	if self.showSprite then		
		local gameMapManager = GameWorld.Instance:getMapManager()
		local x,y = self:getCellXY()		
		local tempX,tempY = x,y
		tempY = tempY - 7
		self:setCellXY(tempX,tempY)
		local mapX,mapY =  gameMapManager:cellToMap(x,y)
		local record = GameWorld.Instance:getEntityManager():getLootRecord()
		if not record[self:getId()] then
			local jumpTo = CCJumpTo:create(0.2,ccp(mapX,mapY),0,1)		
			self.showSprite:runAction(jumpTo)
			jumpTo  = CCJumpTo:create(0.2,ccp(mapX,mapY-30),0,1)
			if self.label then
				self.label:runAction(jumpTo)
			end											
			record[self:getId()] = 1
		else
			self.showSprite:setPosition(ccp(mapX,mapY))
			if self.label then
				self.label:setPosition(ccp(mapX,mapY-30))
			end												
		end
	end
end

function LootObject:getName()
	local property = self:getItemProperty()
	local name = 	Config.Words[1600]
	if property then
		name = PropertyDictionary:get_name(property)
	end	
	return name
end

function LootObject:showingLabel()
	if self.refId == "gold" then
		return nil
	end
	local name = self:getName()
	local color = self:getColor()				
	local label = SFLabelTex:create(name, "Arial", FSIZE("Size1"))	
	label:setColor(FCOLOR(color))
	return label
end

function LootObject:getColor()
	local qualityColorTable = {
		[1] = "ColorWhite2",
		[2] = "ColorBlue1",
		[3] = "ColorPurple1",
		[4] = "ColorYellow1",
	}
	local property = self:getItemProperty()
	local quality = 1
	if property then
		quality = PropertyDictionary:get_quality(property)
	end
	return qualityColorTable[quality]
end	

-- 是否超时
function LootObject:isTimeout()
	return os.time() - self.protectTime >= 35
end