require("common.LoginBaseUI")

TestModelView = TestModelView or BaseClass(LoginBaseUI)

local const_visibleSize = CCDirector:sharedDirector():getVisibleSize()
local const_size_no_scale = CCSizeMake(480, 320)
local g_size
local const_scale = VisibleRect:SFGetScale()
local const_levelLimit = 80

local g_btns 

function TestModelView:create()
	return TestModelView.New()
end

function TestModelView:__init()
	g_btns  = 
	{
--		{name =  "检查资源", 	onClick = self.onCheck,	  		obj = nil},	
		{name =  "翅膀",   		onClick = self.onWingChanged, 	  obj = nil},
		{name =  "武器", 		onClick = self.onWeaponChanged,	  obj = nil},
		{name =  "衣服", 		onClick = self.onClothChanged,	  obj = nil},
		{name =  "记录当前", 		onClick = self.onMarkChanged,	  obj = nil},
		{name =  "输出记录", 	onClick = self.onOutput,	  obj = nil},
	}
	
	self.markList = {}
	
	self.weaponIndex = 0
	self.clothesIndex = 0
	self.wingIndex = 0
	self.gender = nil
	
	self.viewName = "TestModelView"
	g_size = self:initFullScreen()	
	self:initHeroModel()
	self:buildEquilList()
	self:initBtn()		
end				

function TestModelView:initHeroModel()
	self.heroModelView = HeroModelView.New()
	self.rootNode:addChild(self.heroModelView:getRootNode())
--	VisibleRect:relativePosition(self.heroModelView:getRootNode(), self.rootNode, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(15, 0))	
	VisibleRect:relativePosition(self.heroModelView:getRootNode(), self.rootNode, LAYOUT_CENTER)	
end

function TestModelView:buildEquilList()
	require ("data.item.equipItem")	
--[[	self.nanLuomo 	= "equip_0_2010"
	self.nvLuomo 	= "equip_0_2020"--]]
	self.weaponList = {}
	self.clothesList = {}
	self.wingList = {}
	self.allModels = {}
	
--[[	table.insert(self.allModels, self.nanLuomo)
	table.insert(self.allModels, self.nvLuomo)--]]
	for k, v in pairs(GameData.EquipItem)	do
		local bodyAreaId = PropertyDictionary:get_areaOfBody(v.property) 
		local level = PropertyDictionary:get_equipLevel(v.property)
		if level <= const_levelLimit then
			if bodyAreaId == E_BodyAreaId.eWeapon then
				table.insert(self.allModels, k)
				table.insert(self.weaponList, k)
			elseif bodyAreaId == E_BodyAreaId.eCloth then
				table.insert(self.clothesList, k)
				table.insert(self.allModels, k)
			end
		end
	end
	require"data.wing.wing"	
	for k, v in pairs(GameData.Wing) do
		local level = PropertyDictionary:get_wingLevel(v.property)
		if level <= math.floor(const_levelLimit/10) then
			table.insert(self.wingList, k)
			table.insert(self.allModels, k)
		end
	end
	
	self.wingSize = table.size(self.wingList)
	self.weaponSize = table.size(self.weaponList)
	self.clothesSize = table.size(self.clothesList)
	
	self.wingIndex = 1
	self.weaponIndex = 1
	self.clothesIndex = 1
	print("ModelView total model size="..table.size(self.allModels))
end

function TestModelView:getWeathen()
end

function TestModelView:onCheck()
	local ret = {}
	local ok = true
	
	for k, v in pairs(self.allModels) do 
		local sprite = createSpriteWithFileName(MODEL(v))
		if not sprite then
			table.insert(ret, v)
			ok = false
		end
	end
	
	if not ret then
		table.insert(ret, 1, "-------- File Missing --------")		
	else
		table.insert(ret, 1, "All File Completed")	
	end
	
	UIManager.Instance:showTextList(ret)
	for k, v in pairs(ret) do
		print(v)
	end
end

-- 显示功能按键
function TestModelView:initBtn()
	local preNode = nil
	for k, v in pairs(g_btns) do
		local btn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
		local text = createLabelWithStringFontSizeColorAndDimension(v.name, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
		self.rootNode:addChild(btn)
		btn:setTitleString(text)		
		local onClick = function()		
			v.onClick(self)
		end
		btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)	
		
		if preNode == nil then
			VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_TOP_INSIDE  + LAYOUT_RIGHT_INSIDE, ccp(0, -80))
		else
			VisibleRect:relativePosition(btn, preNode, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(0, -10))
		end
		preNode = btn
	end
end

function TestModelView:onWingChanged()
	self.wingIndex = self.wingIndex + 1
	if self.wingIndex > self.wingSize then
		self.wingIndex = 1
		UIManager.Instance:showSystemTips("已是最后一个翅膀", 2.5)
	end
	local refId = self.wingList[self.wingIndex]
	print(refId)
	self.heroModelView:setWing(refId)
end

function TestModelView:onWeaponChanged()
--[[	for k, v in pairs(self.weaponList) do
		self.heroModelView:addEquipWithRefId(v, E_BodyAreaId.eWeapon)
	end--]]
		
	self.weaponIndex = self.weaponIndex + 1
	if self.weaponIndex > self.weaponSize then
		UIManager.Instance:showSystemTips("已是最后一个武器", 2.5)
		self.weaponIndex = 1
	end
	local refId = self.weaponList[self.weaponIndex]
--	print(refId)
	local data = GameData.EquipItem[refId]
	self.heroModelView:addEquipWithRefId(refId, E_BodyAreaId.eWeapon)
end

function TestModelView:onClothChanged()
	self.clothesIndex= self.clothesIndex + 1
	if self.clothesIndex > self.clothesSize then
		UIManager.Instance:showSystemTips("已是最后一件武器", 2.5)
		self.clothesIndex = 1
	end		
	local refId = self.clothesList[self.clothesIndex]	
	local data = GameData.EquipItem[refId]
	
	self.heroModelView:addEquipWithRefId(refId, E_BodyAreaId.eCloth)
	
	local gender = PropertyDictionary:get_gender(data.property)			
	self.heroModelView:setGender(gender)
end

function TestModelView:onMarkChanged()
	local weapon 	= self.weaponList[self.weaponIndex]
	local cloth 	= self.clothesList[self.clothesIndex]
	local wing 		= self.wingList[self.wingIndex]	
	local str = "weapon="..weapon.." cloth="..cloth.." wing="..wing	
	table.insert(self.markList, str)	
end

function TestModelView:onOutput()
	UIManager.Instance:showTextList(self.markList)
	self.markList = {}
end

function TestModelView:onMarkChanged()
	local weapon 	= self.weaponList[self.weaponIndex]
	local cloth 	= self.clothesList[self.clothesIndex]
	local wing 		= self.wingList[self.wingIndex]	
	local str = "weapon="..weapon.." cloth="..cloth.." wing="..wing	
	table.insert(self.markList, str)	
end
		
function TestModelView:__delete()
	if self.scrollNode then
		self.scrollNode:release()
	end
end			
