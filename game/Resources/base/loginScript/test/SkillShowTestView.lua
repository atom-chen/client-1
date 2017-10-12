require("common.baseclass")
require("test.TestData")

SkillShowTestView = SkillShowTestView or BaseClass(LoginBaseUI)

local const_scale = VisibleRect:SFGetScale()
local const_targetId = "lining"
local const_size = VisibleRect:getScaleSize(CCSizeMake(150, 408))
local const_cellSize = CCSizeMake(150, 102)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function SkillShowTestView:__init()
	self.rootNode = CCNode:create()
	self.rootNode:setContentSize(visibleSize)
	self.rootNode:retain()	
	
	self.curSkill = {refId = "skill_zs_3", index = -1} --当前选中的技能refId
--[[		
	self:initTableView()	
	self:buildSkillList()
	self:initProfessionIdChoiceBar()
	self:initSkillUseBtn()
	self:createPlayer()	
		--]]
	UIManager.Instance:hideAllUI()
	local function showMe()
		local parent = UIManager.Instance:getDialogRootNode()
		if (parent) then
			parent:addChild(self.rootNode)
			VisibleRect:relativePosition(self.rootNode, parent, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE)
		end
	end
	showMe()
end			

function SkillShowTestView:createPlayer()
	local entityManager = GameWorld.Instance:getEntityManager()	
	
	for i=1,5 do
		local monster1 = entityManager:createEntityObject(EntityType.EntityType_Monster, "testMonster_3_"..tostring(i))
		local xx, yy =	G_getHero():getCellXY()	
		PropertyDictionary:set_level(monster1:getPT(), 1)
		monster1:setRefId("monster_23")
		monster1:setCellXY(xx+i*3, yy+2)
		monster1:setModuleId(3003)
		monster1:enterMap(xx+i*3, yy+2)
		monster1:getRenderSprite():setScale(0.8)
	end
	
	for i=1,5 do
		local monster1 = entityManager:createEntityObject(EntityType.EntityType_Monster, "testMonster_5_"..tostring(i))
		local xx, yy =	G_getHero():getCellXY()	
		PropertyDictionary:set_level(monster1:getPT(), 1)
		monster1:setRefId("monster_23")
		monster1:setCellXY(xx+i*5, yy+12)
		monster1:setModuleId(3003)
		monster1:enterMap(xx+i*5, yy+12)
	end
end

function SkillShowTestView:__delete()
	self.rootNode:release()
	
	for k, vg in pairs(self.skillViewList) do
		vg.node:release()
	end
end

function SkillShowTestView:getRootNode()
	return self.rootNode
end

--[[
技能协议：
skillRefId		string		//技能引用编号
attackerType	String			//"Monster", "Player"
atktackerId		String			//出手id
targetType		String			//"Monster", "Player"
targetId		String			//目标id
effectCount  	int				//效果列表
[
	{ 
		who					byte			//0:attacker		1:target
		effectType	byte	//0:miss 1:hp 2:暴击 3：死 4:幸运
		effectParams	//根据effectType来解析的参数
		{
				NONE		// 这几项没有: 					0:miss 1:死亡 4:幸运
				int	 		// 这几项是一个int:				1， hp 2,暴击
		}
	}
	{ ...}
]
--]]

function SkillShowTestView:useSkill()
	local skillEffect = {}
	skillEffect["effects"] = {}
	skillEffect["skillRefId"] = self.curSkill.refId
	skillEffect["attackType"] = EntityType.EntityType_Player
	skillEffect["attackerId"] = G_getHero():getId()
	skillEffect["targetType"] = EntityType.EntityType_Monster
	skillEffect["targetId"]   = const_targetId

	local effectCount = 1
	
	local effect = {}
	for i=1, effectCount do 
		
		effect[i] = {}
		effect[i]["owner"] = 1
		
		if self.curSkill.refId == "skill_zs_5" then
			effect[i]["effectType"] = E_SkillEffectType.Transport			
			effect[i]["targetType"] = EntityType.EntityType_Player
			effect[i]["targetId"]   = G_getHero():getId()
		else
			effect[i]["effectType"] = 2
			effect[i]["targetType"] = EntityType.EntityType_Monster
			effect[i]["targetId"]   = const_targetId
		end
		
		local effectObject = self:createSkillEffect(effect[i])
		skillEffect["effects"][i] = effectObject
	end
		
	SkillShowManager:showSkillAnimate(skillEffect)		
end

function SkillShowTestView:createSkillEffect(skillEffect)
	local effect = SkillEffect.New()
	effect:setSkillRefId(skillEffect.skillRefId)
	local owner = skillEffect["owner"]
	if 	(0 == owner) then	--属于attacker
		effect:setOwner(skillEffect.attackType, skillEffect.attackerId)
	else	--属于target
		effect:setOwner(skillEffect.targetType, skillEffect.targetId)
	end
	
	local effectType = skillEffect["effectType"] --技能效果类型
	effect:setType(effectType)
	local effectParam	--技能效果参数
	if (effectType == E_SkillEffectType.Keeptime) then	--持续火墙
		effectParam = reader:ReadInt()
	elseif (effectType == E_SkillEffectType.Transport) then
		-- 瞬移
		local cellX, cellY = G_getHero():getCellXY()
		local direction = G_getHero():getAngle()
		
		if direction == 0 or direction == 1 or direction == 7 then
			cellY = cellY - 4
		end
		
		if direction == 4 or direction == 5 or direction == 3 then
			cellY = cellY + 4
		end
		
		if direction == 1 or direction == 2 or direction == 1 then
			cellX = cellX + 4
		end
		
		if direction == 5 or direction == 6 or direction == 7 then
			cellX = cellX - 4
		end
		
		effectParam = {}
		effectParam["x"] = cellX
		effectParam["y"] = cellY	
	elseif (effectType == E_SkillEffectType.HP or effectType == E_SkillEffectType.Criti or effectType == E_SkillEffectType.Addblood) then
		-- HP,暴击,加血
		effectParam = {}
		effectParam["HarmValue"] = 100
		effectParam["CurrentValue"] = 800
		effectParam["MaxValue"] = 900
	elseif effectType == E_SkillEffectType.Dead then
		-- 死亡
	end
	
	effect:setEffectParam(effectParam)
	return effect
end

function SkillShowTestView:initTableView()
	local dataHandler = function(eventType, tableView, index, data)
		return self:tableViewDataHandler(eventType, tableView, index, data)
	end
	
	local tableDelegate = function (tableView, cell, x, y)
		return self:tableViewDelegate(tableView, cell, x, y)
	end
	
	self.tabelView = createTableView(dataHandler, const_size)
	self.tabelView:setTableViewHandler(tableDelegate)
	self.tabelView:setClippingToBounds(true)
	self.rootNode:addChild(self.tabelView)
	VisibleRect:relativePosition(self.tabelView, self.rootNode, LAYOUT_CENTER_Y + LAYOUT_LEFT_INSIDE, ccp(0, 0))
	
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_bg1.png"), const_cellSize)
	local label = createLabelWithStringFontSizeColorAndDimension("选择技能", "Arial", FSIZE("Size5") * const_scale, FCOLOR("ColorWhite1"),CCSizeMake(20*const_scale,0))								
	
	self.rootNode:addChild(bg)
	self.rootNode:addChild(label)
	VisibleRect:relativePosition(bg, self.tabelView, LAYOUT_CENTER_X + LAYOUT_TOP_OUTSIDE, ccp(0, 0))
	VisibleRect:relativePosition(label, bg, LAYOUT_CENTER)
end
	
function SkillShowTestView:initProfessionIdChoiceBar()
	local btnArray = CCArray:create()	
	for i = 1, 3 do
		local function createBtn(id)
			local btn = createButtonWithFramename(RES("btn_2_normal.png"), RES("btn_2_select.png"))						
			local label = createLabelWithStringFontSizeColorAndDimension(G_getProfessionNameById(id), "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))								
			btnArray:addObject(btn)
			local onTabPress = function()
				self:doSelecteProfession(id)
			end
			btn:addTargetWithActionForControlEvents(onTabPress, CCControlEventTouchDown)
			btn:addChild(label)
			VisibleRect:relativePosition(label, btn, LAYOUT_CENTER)
		end
		createBtn(i)
	end

	self.tagView = createTabView(btnArray, 15 * const_scale, tab_horizontal)
	self.rootNode:addChild(self.tagView)
	VisibleRect:relativePosition(self.tagView, self.rootNode, LAYOUT_CENTER_X + LAYOUT_BOTTOM_INSIDE, ccp(0, 20))			
		
	local curId = PropertyDictionary:get_professionId(G_getHero():getPT())
	if (curId >= 1 and curId <= 3 ) then
		self.tagView:setSelIndex(curId - 1)
	end
end	


function SkillShowTestView:initSkillUseBtn()
	local btn = createButtonWithFramename(RES("main_attack.png"), RES("main_attack.png"))
	
	local onClick = function()
		self:useSkill()
	end
	btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
	
	self.rootNode:addChild(btn)
	VisibleRect:relativePosition(btn, self.rootNode, LAYOUT_RIGHT_INSIDE + LAYOUT_BOTTOM_INSIDE, ccp(-80, 80))			
end	

function SkillShowTestView:doSelecteProfession(id)		
	if (self.curId == id) then
		return
	end
	
	self.curId = id
	local model
	if (id == 1) then
		model = 1006
	elseif (id == 2) then
		model = 1008
	else
		model = 1010
	end
	local hero = G_getHero()
	hero:mountDown()
	hero.renderSprite:load(model)
end

local kTableCellSizeForIndex 		= 0
local kCellSizeForTable 			= 1
local kTableCellAtIndex 			= 2
local kNumberOfCellsInTableView 	= 3

function SkillShowTestView:tableViewDataHandler(eventType, tableView, index, data)
	tableView = tolua.cast(tableView, "SFTableView")
	data = tolua.cast(data, "SFTableData")
	if eventType == kTableCellSizeForIndex then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kCellSizeForTable then
		data:setSize(const_cellSize)
		return 1
	elseif eventType == kTableCellAtIndex then		
		data:setCell(self:createCell(tableView, index))
		return 1
	elseif eventType == kNumberOfCellsInTableView then
		local count = table.size(self.skillViewList)
		data:setIndex(count)
		return 1
	end
end

function SkillShowTestView:buildSkillList()
	local list = Config.Animate
	self.skillViewList = {}	
	for refId, v in pairs(list) do
		local tmp = {}
		tmp.node, tmp.selected = self:createSkillView(refId)
		if (tmp.node) then
			tmp.refId 	= refId
			tmp.needAdded = true
			table.insert(self.skillViewList, tmp)
			tmp.node:retain()
		end
	end
	self.tabelView:reloadData()
	self.tabelView:scroll2Cell(0, false)
end	

function SkillShowTestView:createSkillView(refId)	
	require"data.skill.skill"	
	local icon = createSpriteWithFileName(ICON(refId))
	if (icon == nil) then
		return nil, nil
	end
	local data = GameData.Skill[refId]
	if (data) then
		data = data.property
	end
	local name = PropertyDictionary:get_name(data)
	name = createLabelWithStringFontSizeColorAndDimension(name, "Arial", FSIZE("Size4") * const_scale, FCOLOR("ColorWhite1"))
	
	local node = CCNode:create()
		
	local selected = createSpriteWithFrameName(RES("forging_selected.png"))
	selected:setRotation(180)
	selected:setVisible(false)
	
	local bg = createScale9SpriteWithFrameNameAndSize(RES("squares_formBg2.png"), const_cellSize)
			
	node:setContentSize(CCSizeMake(const_cellSize.width, const_cellSize.height + name:getContentSize().height))
	node:addChild(bg)
	node:addChild(selected)
	node:addChild(icon)
	node:addChild(name)	
	VisibleRect:relativePosition(bg, node, LAYOUT_CENTER)
	VisibleRect:relativePosition(selected, node, LAYOUT_CENTER_Y + LAYOUT_RIGHT_INSIDE)
	VisibleRect:relativePosition(icon, node, LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)
	VisibleRect:relativePosition(name, icon, LAYOUT_BOTTOM_OUTSIDE + LAYOUT_CENTER_X, ccp(0, 0))	
	return node, selected
end

function SkillShowTestView:tableViewDelegate(tableView, cell, x, y)
	tableView = tolua.cast(tableView, "SFTableView")
	cell = tolua.cast(cell,"SFTableViewCell")

	local index = cell:getIndex() + 1	
	local view = self.skillViewList[index]
	
	if (view) then
		local preView = self.skillViewList[self.curSkill.index]
		if (preView) then
			preView.selected:setVisible(false)
		end
		
		self.curSkill.refId = view.refId			
		self.curSkill.index = index	
		local curView = self.skillViewList[self.curSkill.index]
		if (curView) then
			curView.selected:setVisible(true)
		end
	end
end

function SkillShowTestView:createCell(tableView, indexx)
	local cell = tableView:dequeueCell(indexx)	
	local data = self.skillViewList[indexx + 1]
	if (cell == nil) then	
		cell = SFTableViewCell:create()
		cell:setContentSize(const_cellSize)
		cell:setIndex(indexx)			
		if (data and data.needAdded == true) then	
			local node = data.node	
			data.needAdded = false
			cell:addChild(node)
			VisibleRect:relativePosition(node, cell, LAYOUT_CENTER)						
		end
	else
		local data = self.skillViewList[indexx + 1]
		if (data) then	
			local node = data.node
			if (data.needAdded == true) then	
				cell:removeAllChildrenWithCleanup(true)		
				data.needAdded = false
				cell:addChild(node)
				VisibleRect:relativePosition(node, cell, LAYOUT_CENTER)						
			end
		end
	end
	return cell
end
