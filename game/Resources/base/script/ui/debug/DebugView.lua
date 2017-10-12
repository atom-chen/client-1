require("ui.UIManager")
require("common.BaseUI")
require("config.words")

DebugView = DebugView or BaseClass(BaseUI)
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local g_scale = VisibleRect:SFGetScale()
local const_size = CCSizeMake(960*0.6, 640*0.7)
function DebugView:__init()
	self.viewName = "DebugView"
	self:init(const_size)
	self:initDebug()
end
function DebugView:__delete()
	self.scrollNode:release()
end
function DebugView:create()
	return DebugView.New()
end

function DebugView:refreshView()
	local debugMgr = GameWorld.Instance:getEntityManager():getHero():getDebugMgr()
	local viewSize = CCSizeMake(const_size.width -100* g_scale , 350 * g_scale)
	local description = debugMgr:getResult()
    self.labelCommand:setString(description)
	self.labelCommand:setDimensions(CCSizeMake(viewSize.width,0))
	local size = CCSizeMake(self.labelCommand:getContentSize().width, self.labelCommand:getContentSize().height)
	if (self.labelCommand:getContentSize().height < viewSize.height) then
		size.height = viewSize.height
	end
	self.scrollNode :setContentSize(size)
	self.scrollCommand:setContainer(self.scrollNode )
	self.scrollCommand:setContentOffset(ccp(0,-viewSize.height-50),false)
end

function DebugView:onExit()
	
end


function DebugView:createScrollView(viewSize)
	local scrollView = createScrollViewWithSize(viewSize)
	scrollView:setDirection(2)
	return scrollView
end	


function DebugView:initDebug()
	local debugMgr = GameWorld.Instance:getEntityManager():getHero():getDebugMgr()
	local viewSize = CCSizeMake(const_size.width -100* g_scale , 350 * g_scale)
	self.scrollNode = CCNode:create()
	self.scrollNode:retain()
	self.labelCommand = createLabelWithStringFontSizeColorAndDimension(" ", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow5"),CCSizeMake(viewSize.width, 0))	
	
	local size = CCSizeMake(self.labelCommand:getContentSize().width, self.labelCommand:getContentSize().height)
	if (self.labelCommand:getContentSize().height < viewSize.height) then
		size.height = viewSize.height
	end
	self.scrollNode :setContentSize(size)
	self.scrollNode :addChild(self.labelCommand)
	VisibleRect:relativePosition(self.labelCommand, self.scrollNode , LAYOUT_CENTER_X + LAYOUT_TOP_INSIDE)	
	--滚动
	if (self.scrollCommand) then
		self.background:removeChild(self.scrollCommand, true)
	end
	self.scrollCommand = self:createScrollView(viewSize)
	self.rootNode:addChild(self.scrollCommand) 		
	VisibleRect:relativePosition(self.scrollCommand, self.rootNode, LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,-5))	
	self.scrollCommand:setContainer(self.scrollNode )

	--输入框
	local editCommand =  createEditBoxWithSizeAndBackground(VisibleRect:getScaleSize(CCSizeMake(const_size.width-150*g_scale,40*g_scale)),RES("editBox_bg.png"))
	self.background : addChild(editCommand)
	VisibleRect:relativePosition(editCommand,self.background,LAYOUT_CENTER+LAYOUT_BOTTOM_INSIDE+LAYOUT_LEFT_INSIDE,ccp(10,10))
	--发送
	local sendBtn = createButtonWithFramename(RES("btn_1_select.png"), RES("btn_1_select.png"))
	local sendBtnLabel = createLabelWithStringFontSizeColorAndDimension("Send", "Arial", FSIZE("Size3")*g_scale, FCOLOR("ColorYellow7"))
	sendBtn : addChild(sendBtnLabel)
	VisibleRect:relativePosition(sendBtnLabel,sendBtn,LAYOUT_CENTER)
	self.background : addChild(sendBtn)
	VisibleRect:relativePosition(sendBtn,editCommand,LAYOUT_CENTER+LAYOUT_RIGHT_OUTSIDE,ccp(5,0))
	local sendFunction = function()
		local command = editCommand:getText()
		--todo 测试代码
		local splitCommand = string.split(command," ")
		if splitCommand[1] == "find" then
			local autoPath = GameWorld.Instance:getAutoPathManager()	
			local mapManager =  GameWorld.Instance:getMapManager()
			local currentMapRefId = mapManager:getCurrentMapRefId()
			autoPath:startFindTargetPaths(splitCommand[2],currentMapRefId)
		elseif splitCommand[1] == "act" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local actionId =   tonumber(splitCommand[2]) 
			hero:changeAction(actionId, true)
		elseif splitCommand[1] == "findE" then
			local autoPath = GameWorld.Instance:getAutoPathManager()	
			autoPath:find(splitCommand[2],splitCommand[3])
		elseif splitCommand[1] == "change" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local partId = tonumber(splitCommand[2])
			local moduleId =   tonumber(splitCommand[3]) 
			hero:changePart(partId, moduleId)				
		elseif splitCommand[1] == "flyTo" then
			local gameMapManager = GameWorld.Instance:getMapManager()
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local x = tonumber(splitCommand[2])
			local y = tonumber(splitCommand[3])			
			hero:setCellXY(x,y)
			local mapX, mapY = hero:getMapXY()
			local centerY = hero:getCenterY()
			gameMapManager:setViewCenter(mapX, centerY)
		elseif splitCommand[1] == "switchTo" then
			local gameMapManager = GameWorld.Instance:getMapManager()				
			local transferOutId = tonumber(splitCommand[2])						
			gameMapManager:requestSceneSwitch(transferOutId)
		elseif splitCommand[1] == "usage" then
--			CCLuaLog("Memory usage "..collectgarbage("count"))
		elseif splitCommand[1] == "mountUp" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:mountUp()
		elseif splitCommand[1] == "mountDown" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:mountDown()
		elseif splitCommand[1] == "speed" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local speed = tonumber(splitCommand[2])
			PropertyDictionary:set_moveSpeed(hero.table,speed)
			hero:updateSpeed()
		elseif splitCommand[1] == "changeM" then
			local moduleId = tonumber(splitCommand[2])
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:mountDown()
			hero.renderSprite:load(moduleId)	
		elseif splitCommand[1] == "animSpeed" then
			local speed = tonumber(splitCommand[2])
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:setAnimSpeed(speed)
		elseif splitCommand[1] == "changeW" then
			local moduleId = tonumber(splitCommand[2])
			local hero = GameWorld.Instance:getEntityManager():getHero()
			hero:changePart(EntityParts.eEntityPart_Weapon,moduleId)
		elseif splitCommand[1] == "getList" then			
			local gameInstanceManager = GameWorld.Instance:getGameInstanceManager()
			gameInstanceManager:requestGameInstanceList()
		elseif splitCommand[1] == "toNext" then
			local refid = splitCommand[2]
			local gameInstanceManager = GameWorld.Instance:getGameInstanceManager()
			gameInstanceManager:requestEnterNextLayer(refid)
		elseif splitCommand[1] == "to" then
			local refid = splitCommand[2]
			local gameInstanceManager = GameWorld.Instance:getGameInstanceManager()
			gameInstanceManager:requesEnterGameInstance(refid)
		elseif splitCommand[1] == "leave" then
			local refid = splitCommand[2]
			local gameInstanceManager = GameWorld.Instance:getGameInstanceManager()
			gameInstanceManager:requestLeaveGameInstance(refid)
		elseif splitCommand[1] == "transfer" then			
			local refid = splitCommand[2]
			local xx = tonumber(splitCommand[3])
			local yy = tonumber(splitCommand[4])
			local gameMapManager = GameWorld.Instance:getMapManager()				
			gameMapManager:requestTransfer(refid, xx,yy,2)
		elseif splitCommand[1] == "model" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local moduleId = tonumber(splitCommand[2])
			hero:changeModel(moduleId)
		elseif splitCommand[1] == "att" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local time = tonumber(splitCommand[2])
			for i=0,time do			
				local action = UseSkillActionPlayer.New()
				action:setSkillRefId("skill_fs_1")
				action:setMaxPlayingDuration(1)
				local a = function (a)
				
				end
				action:addStopNotify(a,nil)
				ActionPlayerMgr.Instance:addPlayer(G_getHero():getId(), action)
			end
		elseif splitCommand[1] == "pick" then
				local manager = GameWorld.Instance:getPickUpMnanager()
				manager:pickUpRandomItem()
		elseif splitCommand[1] == "moveTo" then
				local hero = GameWorld.Instance:getEntityManager():getHero()
				local xx = tonumber(splitCommand[2])
				local yy = tonumber(splitCommand[3])
				hero:moveTo(xx,yy)
		elseif splitCommand[1] == "heroPos" then
			local x, y = G_getHero():getCellXY()
			local gameMapManager = GameWorld.Instance:getMapManager()
			local aoiX, aoiY = gameMapManager:convertToAoiCell(x, y)
			print(string.format("heroPos=(%d, %d) aoi=(%d, %d)", x, y, aoiX, aoiY))
		elseif splitCommand[1] == "IsBlock" then
			local xx = tonumber(splitCommand[2])
			local yy = tonumber(splitCommand[3])
			print(SpriteMove:IsBlock(xx,yy))
		elseif splitCommand[1] == "testMem" then
			local textureCache = CCTextureCache:sharedTextureCache()
			textureCache:dumpCachedTextureInfo()
		elseif splitCommand[1] == "disConnect" then
			local simulator = SFGameSimulator:sharedGameSimulator()
			simulator:tcpDisConnect()
		elseif splitCommand[1] == "addAllItem" then
			for k, v in pairs(GameData.PropsItem) do
				debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
			end
		elseif splitCommand[1] == "addAllEquip" then
			for k, v in pairs(GameData.EquipItem) do
				debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
			end
		elseif splitCommand[1] == "aoiCell" then
			local gameMapManager = GameWorld.Instance:getMapManager()
			local xx = tonumber(splitCommand[2])
			local yy = tonumber(splitCommand[3])	
			local aoiX,aoiY = gameMapManager:convertToAoiCell(xx,yy)
			print("Aoi"..aoiX.." "..aoiY)
		elseif splitCommand[1] == "holyEquip" then
			local commandTable = {
				"addItem equip_100_2110 1",
				"addItem equip_100_3100 1",
				"addItem equip_100_4100 1",
				"addItem equip_100_5100 1",
				"addItem equip_100_6100 1",
				"addItem equip_100_7100 1",
				"addItem equip_100_7100 1",
				"addItem equip_100_8100 1",
				"addItem equip_100_8100 1",
				"addItem equip_100_9002 1",
				"addItem equip_100_1100 1",	
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end
		elseif splitCommand[1] == "addMedal" then
			local commandTable = {
				"addItem item_goldMedal 99",
				"addItem item_silverMedal 99",
				"addItem item_copperMedal 99",
				"addItem item_ironMedal 99",				
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end
		elseif splitCommand[1] == "pk" then
			local commandTable = {
				"addExp 1000000000",
				"acceptQuest quest_33",
				"upvip 3",
				"addMoney 999999999 999999999 999999999",
				"addMerit 100000000",
				"addItem item_moveto_1 100",
				
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end			
		elseif splitCommand[1] == "holyMagicEquip" then
			local commandTable = {
				"addItem equip_60_2222 1",
				"addItem equip_100_3200 1",
				"addItem equip_100_4200 1",
				"addItem equip_100_5200 1",
				"addItem equip_100_6200 1",
				"addItem equip_100_7200 1",
				"addItem equip_100_7200 1",
				"addItem equip_100_8200 1",
				"addItem equip_100_8200 1",
				"addItem equip_100_9002 1",
				"addItem equip_100_1200 1",	
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end
		elseif splitCommand[1] == "holyItem" then
			local commandTable = {
				"addMerit 100000",
				"addItem item_zuoqiExp 2500",
				"addItem item_chibangExp 400",
				"addItem item_jinengExp 400",
				"addItem item_suipian_8 100",
				"addItem item_qianghuajuan_12 10",				
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end				
			for i = 1, 12 do
				debugMgr:requestDebugCommand("applyplayeratt  " .. i .. "  99999" )
			end	
		elseif 	splitCommand[1] == "zhanshi" then 
			--[[for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionWarior and PropertyDictionary:get_equipLevel(v.property) == 100 then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end--]]
			local commandTable = {		
				"addMerit 100000",
				"addExp 1000000000",
				"upvip 3",			
				"addItem equip_60_2110 1",	
				"addItem equip_100_9000 1",						
				"addMoney 999999999 999999999 999999999",
				"addItem item_suipian_1 1",			
				"addItem item_suipian_2 1",	
				"addItem item_suipian_3 20",	
				"addItem item_suipian_4 30",	
				"addItem item_suipian_5 40",	
				"addItem item_suipian_6 50",	
				"addItem item_suipian_7 60",	
				"addItem item_suipian_8 60",	
				"addItem item_suipian_9 60",	
				"addItem item_suipian_10 20",
				"addItem item_gonghuiling 20",
				"addItem item_gonghuiling 20",
				"addItem item_2exp 20",
				"addItem item_moveto_3 99",
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end	
		elseif 	splitCommand[1] == "fashi" then 
			--[[for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionMagic and PropertyDictionary:get_equipLevel(v.property) == 100 then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end--]]
			local commandTable = {
				"addMerit 100000",
				"addExp 1000000000",		
				"upvip 3",
				"addItem equip_60_2210 1",			
				"addItem equip_100_9000 1",			
				"addMoney 999999999 999999999 999999999",		
				"addItem item_suipian_1 1",			
				"addItem item_suipian_2 1",	
				"addItem item_suipian_3 20",	
				"addItem item_suipian_4 30",	
				"addItem item_suipian_5 40",	
				"addItem item_suipian_6 50",	
				"addItem item_suipian_7 60",	
				"addItem item_suipian_8 60",	
				"addItem item_suipian_9 60",	
				"addItem item_suipian_10 60",
				"addItem item_gonghuiling 20",
				"addItem item_2exp 20",
				"addItem item_moveto_3 99",
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end	
		elseif 	splitCommand[1] == "daoshi" then 
			--[[for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionWarlock and PropertyDictionary:get_equipLevel(v.property) == 100 then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end	--]]
			local commandTable = {		
				"addMerit 100000",
				"addExp 1000000000",
				"addMoney 999999999 999999999 999999999",					
				"upvip 3",
				"addItem equip_100_9000 1",		
				"addItem equip_60_2310 1",
				"addItem item_suipian_1 1",			
				"addItem item_suipian_2 1",	
				"addItem item_suipian_3 20",	
				"addItem item_suipian_4 30",	
				"addItem item_suipian_5 40",	
				"addItem item_suipian_6 50",	
				"addItem item_suipian_7 60",	
				"addItem item_suipian_8 60",	
				"addItem item_suipian_9 60",	
				"addItem item_suipian_10 60",
				"addItem item_gonghuiling 20",
				"addItem item_2exp 20",
				"addItem item_moveto_3 99",
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end	
		elseif 	splitCommand[1] == "yumao" then 
			debugMgr:requestDebugCommand("addItem item_chibangExp 99")
		elseif 	splitCommand[1] == "money" then 
			debugMgr:requestDebugCommand("addMoney 999999999 999999999 999999999")		
		elseif 	splitCommand[1] == "jinpai" then 
			debugMgr:requestDebugCommand("addItem item_goldMedal 99")	
		elseif 	splitCommand[1] == "yinpai" then 
			debugMgr:requestDebugCommand("addItem item_silverMedal 99")
		elseif 	splitCommand[1] == "tongpai" then 
			debugMgr:requestDebugCommand("addItem item_copperMedal 99")	
		elseif 	splitCommand[1] == "tiepai" then 
			debugMgr:requestDebugCommand("addItem item_ironMedal 99")												
		elseif 	splitCommand[1] == "zuoqi" then 
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
			debugMgr:requestDebugCommand("addItem item_zuoqiExp 99")
		elseif 	splitCommand[1] == "fabao" then 
			debugMgr:requestDebugCommand("addItem item_shenqiExp 2500")	
		elseif 	splitCommand[1] == "qianghuashi" then 
			debugMgr:requestDebugCommand("addItem item_qianghuashi 2500")
		elseif splitCommand[1] == "paihang" then									
			local commandTable = {		
				"sortboard 1",
				"sortboard 2",
				"sortboard 3",					
				"sortboard 4",
				"sortboard 5",	
				"sortboard 6",
				"sortboard 7",											
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end	
		elseif splitCommand[1] == "godlike" then												
			for i = 1, 12 do
				debugMgr:requestDebugCommand("applyplayeratt  " .. i .. "  99999" )
			end	
		elseif splitCommand[1] == "addDrugs" or splitCommand[1] == "addDrug" then			
			local commandTable = {
				"addItem item_drug_1 1",
				"addItem item_drug_2 1",
				"addItem item_drug_3 1",
				"addItem item_drug_4 1",
				"addItem item_drug_5 1",
				"addItem item_drug_6 1",
				"addItem item_drug_7 1",
				"addItem item_drug_8 1",
				"addItem item_drug_9 1",
			}
			for k,v in pairs(commandTable) do
				debugMgr:requestDebugCommand(v)
			end
		elseif splitCommand[1] == "safeArea" then	
			local x, y = G_getHero():getCellXY()
			if GameWorld.Instance:getMapManager():isInSafeArea(x, y) then
				print(string.format("(%d, %d) is in safe area", x, y))
			else
				print(string.format("(%d, %d) is not not in safe area", x, y))
			end
		elseif splitCommand[1] == "autoMove" then			
			local xx = tonumber(splitCommand[2])
			local yy = tonumber(splitCommand[3])
			local sceneId = splitCommand[4]
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:moveToWithCallBack(xx,yy,sceneId)			
		elseif splitCommand[1] == "addDaoshiEquip" then		
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionWarlock then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end	
		elseif splitCommand[1] == "addZhanshiEquip" then	
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionWarior then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end
		elseif splitCommand[1] == "addFashiEquip" then		
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionMagic then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end
		elseif splitCommand[1] == "unionName" then			
			print("unionName="..PropertyDictionary:get_unionName(G_getHero():getPT()))
		elseif splitCommand[1] == "war" and splitCommand[2] then			
			local second = splitCommand[2]
			if second == "1" then
				G_getCastleWarMgr():setIsInCastleWarTime(true)
			elseif second == "2" then
				G_getCastleWarMgr():setCastleWarScene(GameWorld.Instance:getMapManager():getCurrentMapRefId())
				G_getCastleWarMgr():setIsInCastleWarTime(true)
			else
				G_getCastleWarMgr():setIsInCastleWarTime(false)
			end
		elseif splitCommand[1] == "monsterInfo" then			
			local list = GameWorld.Instance:getEntityManager():getEntityListByType(EntityType.EntityType_Monster)
			for k, v in pairs(list) do
				if v:getPT() then
					print("id="..v:getId().." unionName="..PropertyDictionary:get_unionName(v:getPT()))
				end
			end
		elseif splitCommand[1] == "isKingCity" then			
			print("isKingCity="..PropertyDictionary:get_isKingCity(G_getHero():getPT()))
		elseif splitCommand[1] == "testModel" or splitCommand[1] == "TestModel" then	
			require("test.TestModelView")
			UIManager.Instance:registerUI("TestModelView", TestModelView.New)
			UIManager.Instance:showUI("TestModelView")
		elseif splitCommand[1] == "atac" then		
			local refId = splitCommand[2]
			local open = (splitCommand[3] == "1")
			local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
			activityManageMgr:setActivityState(refId, open)	
		elseif splitCommand[1] == "atopen" then		
			local refId = splitCommand[2]
			local open = (splitCommand[3] == "1")
			local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
			activityManageMgr:setActivityState(refId, open)	
		elseif splitCommand[1] == "attime" then		
			local refId = splitCommand[2]
			local startTime = tonumber(splitCommand[3]) + os.time()
			local endTime = tonumber(splitCommand[4]) + os.time()
			local activityManageMgr = GameWorld.Instance:getActivityManageMgr()		
			activityManageMgr:setStartEndTime(refId, startTime, endTime)
		elseif splitCommand[1] == "fashiE" then
			local level = tonumber(splitCommand[2]) 
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionMagic 
					and PropertyDictionary:get_equipLevel(v.property) == level then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end
		elseif splitCommand[1] == "fashiQ" then
			local quality = tonumber(splitCommand[2]) 
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == ModeType.ePlayerProfessionMagic 
					and PropertyDictionary:get_quality(v.property) == quality then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end
		elseif splitCommand[1] == "equip" then
			local quality = tonumber(splitCommand[2])
			local level = tonumber(splitCommand[3])
			local class = tonumber(splitCommand[4])  
			for k, v in pairs(GameData.EquipItem) do
				if PropertyDictionary:get_professionId(v.property) == class
					and PropertyDictionary:get_quality(v.property) == quality 
					and PropertyDictionary:get_equipLevel(v.property) == level then
					debugMgr:requestDebugCommand(string.format("addItem %s 1", k))
				end
			end
		elseif splitCommand[1] == "findM" then
			local entity = splitCommand[2]
			local scene = splitCommand[3]
			local autoPath = GameWorld.Instance:getAutoPathManager()
			autoPath:find(entity,scene)
		elseif splitCommand[1] == "w" then
			local hero = GameWorld.Instance:getEntityManager():getHero()
			local moduleId = tonumber(splitCommand[2])
			hero.table["weaponModleId"] = moduleId
			hero:updateWeaponModule()	
		elseif splitCommand[1] == "itemSellCheck" then
			require("data.item.propsItem")		
			for k,v in pairs(GameData.PropsItem) do
				if v.property.isCanSale ~= 0 and v.property.salePrice == nil then
					print("refId" ..v.refId)
				end
			end	
		elseif splitCommand[1] == "mount" then
			local mountMgr = GameWorld.Instance:getMountManager()	
			for k = 1 , 4 do
				debugMgr:requestDebugCommand("addItem item_zuoqiExp  4000")
				for i =1 ,40 do
					mountMgr:requestMountFeed("item_zuoqiExp",100)	
				end	
			end
		elseif splitCommand[1] == "wing" then
			local wingMgr = GameWorld.Instance:getEntityManager():getHero():getWingMgr()
			for k = 1 , 4 do
				debugMgr:requestDebugCommand("addItem item_chibangExp  4000")
				for i =1 ,40 do
					wingMgr:requestUpGradeWing("item_chibangExp",100)	
				end	
			end	
		elseif splitCommand[1] == "bagDebug" then
			local bag = UIManager.Instance:getViewByName("BagView")
			if bag then
				bag:debug()
			end
		elseif splitCommand[1] == "shoes" then	
			GameWorld.Instance:getMapManager():requestTransfer(gameMapManager:getCurrentMapRefId(), splitCommand[2], splitCommand[3],1)	
		else
			debugMgr:requestDebugCommand(command)
		end
		
	end
	sendBtn:addTargetWithActionForControlEvents(sendFunction,CCControlEventTouchDown)
	
end