require("common.baseclass")
require("test.TestData")
require("test.SkillShowTestView")

TestEntry = TestEntry or BaseClass()

local const_scale = VisibleRect:SFGetScale()

function TestEntry:__init()
	self.rootNode = CCNode:create()
	self.rootNode:retain()
	
	TestEntry.Instance = self
	self:initTestBtn()
	
	require("test.TestMemAnalyzeMgr")
	self.testMem = TestMemAnalyzeMgr.New()	
end

function TestEntry:__delete()
	self.rootNode:release()
	if self.testMem then
		self.testMem:DeleteMe()
		self.testMem = nil
	end
end

function TestEntry:createSkillTestView()
	SkillShowTestView.New()
end

function TestEntry:getRootNode()
	return self.rootNode
end

function TestEntry:onOffLineClick()
	print("TestEntry:onOffLineClick self:offlineLogin()")
	if (self.delayId) then
		return
	end
	
	local function login()
		self:offlineLogin()
		self:createSkillTestView()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.delayId)
		self.delayId = nil
	end
	UIManager.Instance:showLoadingHUD(10)
	self.delayId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(login, 1, false)
end

-- 角色登陆
function TestEntry:offlineLogin()
	local simulator = SFGameSimulator:sharedGameSimulator()
	simulator:enableTcpCommService()
	ResManager.Instance:loadScript()
	require("GameWorld")
	require("test.TestData")
	require("utils.PropertyDictionaryReader")
	require("utils.PropertyDictionary")
	require("object.skillShow.SkillShowManager")
	require("object.skillShow.SkillEffect")
	if (not GameWorld) or (not GameWorld.Instance) then
		GameWorld.New()
		local gameMapManager = GameWorld.Instance:getMapManager()
		gameMapManager:loadConfig()
	end
	
	--删除登录资源
	LoginWorld.Instance:getLoginManager():deleteLoginRes()
	UIManager.Instance:clearSystemTips()
	--[[	local heroId = StreamDataAdapter:ReadStr(reader)
	local propertyLen = StreamDataAdapter:ReadShort(reader)
	local propertyTable = getPropertyTable(reader)--]]
	local heroId = const_testHeroId
	local propertyTable = const_testHeroPD
	
	-- 读取场景和位置信息	
	local sceneRefId = PropertyDictionary:get_sceneRefId(propertyTable)
	local cellX = PropertyDictionary:get_positionX(propertyTable)
	local cellY = PropertyDictionary:get_positionY(propertyTable)
	
	-- 加载地图
	local entityManager = GameWorld.Instance:getEntityManager()
	local gameMapManager = GameWorld.Instance:getMapManager()
	SceneManager:switchTo(SceneIdentify.GameScene)
	gameMapManager:loadMap(sceneRefId)
	
	-- 保存hero的数据	
	local hero = GameWorld.Instance:getEntityManager():createHero(heroId)
	hero:setPT(propertyTable)
	hero:setCellXY(cellX, cellY)

	-- 转动摄像头	
	local mapX, mapY = hero:getMapXY()
	local centerY = hero:getCenterY()
	gameMapManager:setViewCenter(mapX, centerY)
	
	-- enterMap
	hero:enterMap()
	GlobalEventSystem:Fire(GameEvent.EventHeroEnterGame)
	
	--重置配置文件
	local settingMgr = GameWorld.Instance:getSettingMgr()
	if settingMgr:getConfigCharacterId() ~= heroId then
		settingMgr:resetConfig(heroId)
		GameWorld.Instance:getHandupConfigMgr():resetConfig()
	end
	GameWorld.Instance:getFightTargetMgr() 	--目标管理需要在启动时就创建
	GameWorld.Instance:getHandupConfigMgr() --挂机配置管理需要在启动时就创建
	GameWorld.Instance:getPickUpMnanager() 	--挂机配置管理需要在启动时就创建
	
	-- 如果血量为0, 显示复活界面
	if PropertyDictionary:get_HP(hero:getPT()) == 0 then
		GlobalEventSystem:Fire(GameEvent.EventReviveViewShow, true)
		hero:DoDeath()
	end
	
	-- 加载常驻内存的UI资源
	--CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/kraft_dialogue.png")
	--CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/kraft_dungeon.png")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_common_other.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_common_line.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_other.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_tab.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_btn.plist")
	
	--GameWorld.Instance:getActivityManageMgr():createActivityManageList()--创建活动按钮列表数据
	GlobalEventSystem:Fire(GameEvent.EventHeroReady)-- 更新hero
	GlobalEventSystem:Fire(GameEvent.EVENT_MAIN_UI)--显示主界面	
	G_getQuestMgr():requestQuestList()--发送任务列表请求

	
	GameWorld.Instance:getDiscountSellMgr():requestGetDiscountSellList()--请求打折出售列表
	--GameWorld.Instance:getPayActivityManager():requestFirstPayList()--请求首充列表
	GameWorld.Instance:getPayActivityManager():requestCanReceiveActivityList()--请求那些是可以领取的奖励
	
		
	
	local player1 = entityManager:createEntityObject(EntityType.EntityType_Player, "testMonster_3_player1")	
	PropertyDictionary:set_level(player1:getPT(), 1)
	player1:setRefId("monster_23")
	player1:setPT(testData1)
	player1:setCellXY(cellX-12, cellY)
	player1:setModuleId(1042)
	player1:enterMap(cellX-12, cellY)	
	player1.renderSprite:setScale(1.11)
	
	
	local player2 = entityManager:createEntityObject(EntityType.EntityType_Player, "testMonster_3_player2")
	PropertyDictionary:set_level(player2:getPT(), 1)
	player2:setRefId("monster_23")
	player2:setPT(testData2)
	player2:setCellXY(cellX-20, cellY)
	player2:setModuleId(1042)
	player2:enterMap(cellX-20, cellY)
	player2.renderSprite:setScale(1.11)
	
	local player3 = entityManager:createEntityObject(EntityType.EntityType_Player, "testMonster_3_player3")
	PropertyDictionary:set_level(player3:getPT(), 1)
	player3:setRefId("monster_23")
	player3:setPT(testData3)
	player3:setCellXY(cellX-12, cellY+20)
	player3:setModuleId(1043)
	player3:enterMap(cellX-12, cellY+20)
	player3.renderSprite:setScale(1.25)
	local player4 = entityManager:createEntityObject(EntityType.EntityType_Player, "testMonster_3_player4")
	PropertyDictionary:set_level(player4:getPT(), 1)
	player4:setRefId("monster_23")
	player4:setPT(testData4)
	player4:setCellXY(cellX-20, cellY+20)
	player4:setModuleId(1043)
	player4:enterMap(cellX-20, cellY+20)
	player4.renderSprite:setScale(1.25)
	
	self.userTable = {}
	for j=1,10 do
		for i=1,15 do
			local monster1 = entityManager:createEntityObject(EntityType.EntityType_Player, "testMonster_3_"..tostring(j)..tostring(i))
			self.userTable[j+((i-1)*15)] = monster1
			PropertyDictionary:set_level(monster1:getPT(), 1)
			monster1:setRefId("monster_23")
			monster1:setPT(propertyTable)
			monster1:setCellXY(cellX+i*4, cellY+2+j*4)
			monster1:setModuleId(1030)
			monster1:enterMap(cellX+i*4, cellY+2+j*4)
			FightStateEffect:applyMofadun(monster1)
			--monster1:getRenderSprite():setScale(0.8)
		end
	end
	
	local function tick()
		local function testSkill(x1, y1, size1, size2)
			local skillEffect = {}
			skillEffect["skillRefId"] = "skill_fs_4"
			skillEffect["attackType"] = EntityType.EntityType_Player
			skillEffect["attackerId"] = const_testHeroId
			skillEffect["targetId"] = "testMonster_3_"..x1..y1
			skillEffect["targetType"] = EntityType.EntityType_Monster
			skillEffect["effects"]= {}
			
			for j=x1,x1+size1 do
				for i=y1,y1+size2 do
					local index = j*11+i
					skillEffect["effects"][index] = SkillEffect.New()
					skillEffect["effects"][index]:setOwner(EntityType.EntityType_Monster, "testMonster_3_"..tostring(j)..tostring(i))
					skillEffect["effects"][index]:setType(E_SkillEffectType.HP)
					effectParam = {}
					effectParam["HarmValue"] = 100
					effectParam["CurrentValue"] = 300
					effectParam["MaxValue"] = 400
					skillEffect["effects"][index]:setEffectParam(effectParam)
				end
			end
			
			SkillShowManager:handleSingleSkillUse(skillEffect)
			
			for k,v in ipairs(skillEffect["effects"]) do
				v:DeleteMe()
			end
		end
		
		--testSkill(2, 3, 5, 5)
		--testSkill(5, 5, 3, 3)
		--testSkill(4, 5, 2, 2)
		--testSkill(7, 1, 3, 8)
		--testSkill(5, 9, 1, 2)
		--testSkill(2, 8, 4, 3)
	end
	
	local schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
end

function TestEntry:setRenderLevel(level)
	local index = 1
	local allcount = 150
	print("level "..level)
	if level == "1" then	
		for j=1,10 do
			for i=1,15 do		
				local monster1 = self.userTable[j+((i-1)*15)]
				monster1:setVisible(true)
				monster1:setTitleVisible(true)
			end
		end
	elseif level == "2" then
		allcount = allcount * 0.8
		for j=1,10 do
			for i=1,15 do		
				local monster1 = self.userTable[j+((i-1)*15)]
				if index > allcount then
					monster1:setVisible(false)
				else 
					monster1:setVisible(true)
					monster1:setTitleVisible(true)
				end
				index = index + 1
			end
		end
	elseif level == "3" then
		allcount = allcount * 0.6
		for j=1,10 do
			for i=1,15 do		
				local monster1 = self.userTable[j+((i-1)*15)]
				monster1:setTitleVisible(false)
				if index > allcount then
					monster1:setVisible(false)
				else 
					monster1:setVisible(true)
				end
				
				index = index + 1
			end
		end
	elseif level == "4" then
		for j=1,10 do
			for i=1,15 do		
				local monster1 = self.userTable[j+((i-1)*15)]
				monster1:setVisible(false)
			end
		end
	end
end

function TestEntry:noMapLogin(reader)
	--删除登录资源
	
	local heroId = StreamDataAdapter:ReadStr(reader)
	local propertyLen = StreamDataAdapter:ReadShort(reader)
	local propertyTable = getPropertyTable(reader)
	
	-- 读取场景和位置信息
	local sceneRefId = PropertyDictionary:get_sceneRefId(propertyTable)
	local cellX = PropertyDictionary:get_positionX(propertyTable)
	local cellY = PropertyDictionary:get_positionY(propertyTable)
	
	SceneManager:switchTo(SceneIdentify.GameScene)
	-- 保存hero的数据	
	local hero = GameWorld.Instance:getEntityManager():createHero(heroId)
	hero:setPT(propertyTable)
	hero:setCellXY(cellX, cellY)
	
	-- enterMap
	hero:enterMap()
	GlobalEventSystem:Fire(GameEvent.EventHeroEnterGame)
	
	GlobalEventSystem:Fire(GameEvent.EventHeroReady)-- 更新hero
	G_getQuestMgr():requestQuestList()--发送任务列表请求
	
	GlobalEventSystem:Fire(GameEvent.EVENT_MAIN_UI)--显示主界面	
end

function TestEntry:onOpenUITest(bOpen)
	G_memAnalyzeFlag = bOpen
end

function TestEntry:initTestBtn()
	local testBtns =
	{
	{name = "单机", selectedName = "单机", callBack = self.onOffLineClick, isSelect = false},
	--		{name = Config.LoginWords[10141], selectedName = Config.LoginWords[10142], callBack = self.onOpenUITest, isSelect = false}
	}
	local preNode = nil
	local nodes = {}
	for k, v in pairs(testBtns) do
		local function createBtn()
			local btn = createButtonWithFramename(RES("btn_1_select.png"))
			local text = createLabelWithStringFontSizeColorAndDimension(v.name, "Arial", FSIZE("Size2") * const_scale, FCOLOR("ColorWhite1"))
			btn:addChild(text)
			local onClick = function()
				if v.isSelect == false then
					v.isSelect = true
					text:setString(v.selectedName)
				else
					v.isSelect = false
					text:setString(v.name)
				end
				v.callBack(self, v.isSelect)
				VisibleRect:relativePosition(text, btn, LAYOUT_CENTER)
			end
			VisibleRect:relativePosition(text, btn, LAYOUT_CENTER)
			btn:addTargetWithActionForControlEvents(onClick, CCControlEventTouchDown)
			table.insert(nodes, btn)
		end
		createBtn()
	end
	G_layoutContainerNode(self.rootNode , nodes, 10, E_DirectionMode.Vertical)
end