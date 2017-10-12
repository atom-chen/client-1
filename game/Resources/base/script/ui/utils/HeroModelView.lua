-- 显示英雄模型
require("common.baseclass")
require("object.bag.BagDef")
require("object.equip.EquipDef")
require("GameDef")
require("ui.UIManager")
require("common.BaseUI")
require("config.words")
require("GameDef")
require("ui.utils.BodyAreaView")
require("object.bag.ItemDetailArg")
require("ui.utils.WingSprite")
require ("data.item.equipItem")	
HeroModelView = HeroModelView or BaseClass()

local const_scale = VisibleRect:SFGetScale()
local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()

local const_nan_defaultCloth = "equip_1_2010"
local const_nv_defaultCloth = "equip_1_2020"

function HeroModelView:create()
	return HeroModelView.New()
end	

function HeroModelView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	self.rootNode:setContentSize(const_visibleSize)
	
	self.professionType = E_ProfessionType.eCommon
	self.bodyAreas = 	
	{	
		[E_BodyAreaId.eWeapon] 	= {view = nil, z = 10, refId = ""}, 
		[E_BodyAreaId.eCloth] 	= {view = nil, z = 30, refId = ""}, 									
	}	
	
	self.wing = {view = nil, z = 5}
	self.plistFileList = {}
	self.gender = 0
end		

function HeroModelView:__delete()
	self.rootNode:release()
	self:releasePList()
end

function HeroModelView:setGender(gender)
	self.gender = gender
end	

function HeroModelView:getGender()
	return PropertyDictionary:get_gender(G_getHero():getPT())	
end	

function HeroModelView:getModel(str)
	local image, plist = MODEL(str)
	if plist then
		self.plistFileList[plist] = 1
	end
	return image
end

function HeroModelView:releasePList()
	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	for k, v in pairs(self.plistFileList) do
		frameCache:removeSpriteFramesFromFile(k)
	end
end

function HeroModelView:setEquipList(list)
	if type(list) ~= "table" then
		return
	end
	
	for index, value in pairs(list) do
		for i, v in pairs(value) do
			self:addEquip(v) 						
		end
	end
	
	if self:hasEquip(E_BodyAreaId.eCloth) ~= true then
		self:addLuomo()
	end
end

function HeroModelView:addLuomo()
	if self:getGender() == 1 then 
		self:addEquipWithRefId(const_nan_defaultCloth, E_BodyAreaId.eCloth) 
	else
		self:addEquipWithRefId(const_nv_defaultCloth, E_BodyAreaId.eCloth) 		
	end
end

function HeroModelView:addEquipWithRefId(refId, bodyAreaId)
	local equip = self.bodyAreas[bodyAreaId]
	if equip == nil then
		return
	end

	local data = GameData.EquipItem[refId]
	if not data then
		return
	end						

	if equip.view and equip.refId == refId then
		return
	end		
	self:removeEquip(bodyAreaId)	
	equip.view = createSpriteWithFrameName(self:getModel(PropertyDictionary:get_roleModelId(data.property)))
	if not equip.view then
		CCLuaLog("HeroModelView create "..refId.." fail.")
		return
	end	
	
	if equip.view then
		equip.refId = refId
		self.rootNode:addChild(equip.view, equip.z)	
		self:layoutEquipPos(equip.view, bodyAreaId)
	end
end	

function HeroModelView:addEquip(equipObj)
	local bodyAreaId = equipObj:getBodyAreaId()
	local equip = self.bodyAreas[bodyAreaId]
	if equip == nil then
		return
	end
	
	local refId = equipObj:getRefId()
	local data = GameData.EquipItem[refId]
	if not data then
		return
	end

	if equip.view and equip.refId == refId then
		return
	end
	self:removeEquip(bodyAreaId)
	
	equip.view = createSpriteWithFrameName(self:getModel(PropertyDictionary:get_roleModelId(data.property)))
	if not equip.view then
		CCLuaLog("HeroModelView create "..refId.." fail.")
		return
	end	
	equip.refId = refId
	self.rootNode:addChild(equip.view, equip.z)	
	
	self:layoutEquipPos(equip.view, bodyAreaId)
end

function HeroModelView:layoutEquipPos(node, bodyAreaId)
		if bodyAreaId == E_BodyAreaId.eWeapon and self:getGender() == 2 then		--因为男女共用一套武器。所以女性穿戴武器后需要做一点偏移	
		VisibleRect:relativePosition(node, self.rootNode, LAYOUT_CENTER, ccp(13, 6))	
	else
		VisibleRect:relativePosition(node, self.rootNode, LAYOUT_CENTER)			
	end
end

function HeroModelView:removeAllEquip()
	for k, v in pairs(self.bodyAreas) do
		if v.view then
			self.rootNode:removeChild(v.view, true)
		end
		v.view = nil
		v.refId = ""
	end
end

function HeroModelView:hasEquip(bodyAreaId)
	local equip = self.bodyAreas[bodyAreaId]
	if equip == nil then
		return false
	end		
	if equip.view and equip.refId ~= "" then
		return true
	end
	return false
end

--模型里的准备只有衣服，武器，和裸模
function HeroModelView:removeEquip(bodyAreaId)
	local equip = self.bodyAreas[bodyAreaId]
	if equip then
		self.rootNode:removeChild(equip.view, true)
		equip.view = nil
		equip.refId = ""
	end
end

function HeroModelView:setWing(refId)
	if refId == nil then
		return
	end
	
	if self.wing.view ~= nil then
		if refId == self.wing.refId then
			return
		end
		self:removeWing()
	end
	
	local path = self:getModel("m_"..string.match(refId, "%a+_%d+"))	
	self.wing.view = WingSprite.New()
	self.wing.view:setIcon(path)
	self.wing.refId = refId
	self.rootNode:addChild(self.wing.view:getRootNode(), self.wing.z)	
	VisibleRect:relativePosition(self.wing.view:getRootNode(), self.rootNode, LAYOUT_CENTER)
end

function HeroModelView:removeWing()
	if self.wing.view ~= nil then
		self.rootNode:removeChild(self.wing.view:getRootNode(), true)
		self.wing.view:DeleteMe()
		self.wing.view = nil
		self.wing.refId = ""
	end 
end

function HeroModelView:getRootNode()
	return self.rootNode
end