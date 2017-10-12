require("actionEvent.LoginActionEventDef")
require("common.ActionEventHandler")
require("ui.UIManager")
require("object.entity.LoginRoleObject")
require("data.LoginCode")
require("gameevent.LoginGameEvent")
LoginActionHandler = LoginActionHandler or BaseClass(ActionEventHandler)
g_lastErrorInfo = --Juchao@20140702:记录上次错误信息
{
	time = -1,
	timeStr = "",
	id = -1,	
}
function LoginActionHandler:__init()
	local simulator = SFGameSimulator:sharedGameSimulator()
	
	local characterGetFunction = function (reader)
		-- 如果在游戏的场景就不处理了
		if SceneManager.Instance:isInLoginScene() then
			reader = tolua.cast(reader,"iBinaryReader")
			self:onCharacterGet(reader)
		end
	end
	
	local loginResultFunc = function (reader)
		reader = tolua.cast(reader,"iBinaryReader")
		self:onLoginResult(reader)
	end
	
	local characterLoginFunc = function (reader)
		-- 如果在游戏的场景就不处理了
		if SceneManager.Instance:isInLoginScene() or LoginWorld.Instance:getLoginManager():isReconnect() then
			reader = tolua.cast(reader,"iBinaryReader")
			self:onCharacterLogin(reader)
		end
	end
	
	local characterDeleteFunc = function (reader)
		-- 如果在游戏的场景就不处理了
		if SceneManager.Instance:isInLoginScene()  then
			reader = tolua.cast(reader,"iBinaryReader")
			self:onCharacterDelete(reader)
		end	
	end
		
	self:Bind(ActionEvents.G2C_Result, loginResultFunc)
	self:Bind(ActionEvents.G2C_Charactor_Get,characterGetFunction)
	self:Bind(ActionEvents.G2C_Charactor_Login,characterLoginFunc)
	self:Bind(ActionEvents.G2C_Character_Delete,characterDeleteFunc)
end

function LoginActionHandler:onAuthResult(errCode)
	if errCode >= 0 then
		-- 验证成功
		LoginWorld.Instance:getLoginManager():handleUseAuthSuccess()
	else
		CCLuaLog("loginAuthResult errCode:"..errCode)
	end
end

-- 角色获取的错误返回
function LoginActionHandler:onCharactorGetResult(errCode)
	-- 转换成无符号的int值
	local code = 0xFFFFFFFF + errCode + 1
	if code == 0x80000008 then
		--没有角色
		self:onEnterSelectRoleView()--选择角色
	elseif code == 0x80000195 then  --非法的复活请求
		GlobalEventSystem:Fire(GameEvent.EventHeroUnusualRevieve)	
	else
		CCLuaLog("loginCharactorGetResult errCode:"..errCode)
	end
end

function LoginActionHandler:onCharactorLoginResult(errCode)
	-- 转换成无符号的int值
	local code = 0xFFFFFFFF + errCode + 1
	if code == 0x80000008 then
		--没有角色
		GlobalEventSystem:Fire(GameEvent.EVENT_SELECT_ROLE_UI)--选择角色
		UIManager.Instance:hideLoadingSence()
	else
		CCLuaLog("loginCharactorGetResult errCode:"..errCode)
	end
end

function LoginActionHandler:saveErrorInfo(id)
	if type(id) == "number" then
		g_lastErrorInfo.time = os.time()
		g_lastErrorInfo.timeStr = os.date()
		g_lastErrorInfo.id = id
	end
end

-- 账号验证
function LoginActionHandler:onLoginResult(reader)
	local msgId = StreamDataAdapter:ReadShort(reader)
	local errCode = StreamDataAdapter:ReadInt(reader)
	
	local printCode = 0xFFFFFFFF + errCode + 1
	
	-- 包速过快
	--[[if printCode == 0x8000000F then 
		local msg = showMsgBox(Config.LoginWords[351])	
		local errorFunc = function(arg,text,id)				
			UIManager.Instance:hideDialog(msg:getRootNode())
			--os.exit(0)			
		end			
		msg:setNotify(errorFunc)
	end]]
	self:saveErrorInfo(printCode)
	--Juchao@20140308: 将错误码fire出去，供相关系统使用
	GlobalEventSystem:Fire(GameEvent.EventErrorCode, msgId, printCode)
	
	if msgId == ActionEvents.C2G_User_Auth then
		self:onAuthResult(errCode)
	elseif msgId == ActionEvents.C2G_Charactor_Get then
		self:onCharactorGetResult(errCode)
	elseif msgId == ActionEvents.C2G_Charactor_Login  then
		self:onCharactorLoginResult(errCode)
	elseif msgId == ActionEvents.C2G_Mail_Pickup then
		UIManager.Instance:hideLoadingHUD()
		if errCode >=0 then	--成功
			GlobalEventSystem:Fire(GameEvent.EventMailPickupSuccess)
			UIManager.Instance:showSystemTips(Config.LoginWords[8011])
		else
			local code = 0xFFFFFFFF + errCode + 1
			if code == 0x80000548 then
				--背包已满
				UIManager.Instance:showSystemTips(Config.LoginWords[8013])
			else	--Juchao@20140607: 这是谁添加的 翅膀更新成功的提示？太暴力了吧！
--[[				local msg = {[1] = {word = Config.Words[719], color = Config.FontColor["ColorRed1"]}}
				UIManager.Instance:showSystemTips(msg,E_TipsType.emphasize)	--]]			
			end
		end
	elseif(msgId > 1100 and msgId < 1199 ) then
		self:onMountResult(msgId,errCode)
	elseif (msgId == ActionEvents.C2G_UseSkill) and 
		(printCode == 0x80000137 or printCode == 0x80000134 or printCode == 0x80000132) then
	-- 如果服务器返回技能不存在, 不在攻击距离内, 目标为空等错误, 切换攻击目标
		GameWorld.Instance:getEntityManager():getHero():switchTarget()
	elseif msgId == ActionEvents.C2G_Advanced_GetReward  then
		if errCode >=0 then
			UIManager.Instance:showSystemTips(Config.LoginWords[13409])
			GlobalEventSystem:Fire(GameEvent.EventGetAwardSuccess)--更新法宝翅膀
		end
	elseif msgId == ActionEvents.C2G_Get_LevelUpAward then  --升级奖励	
		if errCode >=0 then
			UIManager.Instance:showSystemTips(Config.LoginWords[13409])
			GlobalEventSystem:Fire(GameEvent.EventGetQuickUpLevelAwardSuccess)
		end			
	elseif msgId == ActionEvents.C2G_AssembleFactionActionEvent and errCode < 0 then
		local code = 0xFFFFFFFF + errCode + 1
		if code  then	
			UIManager.Instance:showSystemTips(GameData.Code[code])			
		end
	elseif msgId == ActionEvents.C2G_OA_TotalRechargeGiftReceiveEvent then
		local payMgr = GameWorld.Instance:getPayActivityManager()
		if errCode >= 0 then --充值礼包领取成功
			local index = payMgr:getPayReceiveIndex()
			GlobalEventSystem:Fire(GameEvent.EventReceivePayGiftBag, index)
		end
	elseif msgId == ActionEvents.C2G_OA_FirstRechargeGiftReceive then
		local payMgr = GameWorld.Instance:getPayActivityManager()
		if errCode >= 0 then --首充领取成功
			GlobalEventSystem:Fire(GameEvent.EventHaveReceiveFirstPayGiftBag)		
		end
	elseif msgId == ActionEvents.C2G_OA_EveryRechargeGiftReceiveEvent then
		local payMgr = GameWorld.Instance:getPayActivityManager()
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventReceiveEveryDayPayBag)
		end
	elseif msgId == ActionEvents.C2G_OA_WeekConsumeGiftReceiveEvent then
		local payMgr = GameWorld.Instance:getPayActivityManager()
		if errCode >= 0 then
			local index = payMgr:getEveryWeekConsumeReceiveIndex()
			GlobalEventSystem:Fire(GameEvent.EventReceiveEveryWeekPayGiftBag, index)
		end
	elseif msgId == ActionEvents.C2G_Player_LeaveWorld then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventBackToSelectRoleView)
		end
	elseif msgId == ActionEvents.C2G_GMMail_Send then 
		if errCode == 0 then 	
			GlobalEventSystem:Fire(GameEvent.EventSendGmMailSucc)
		end
	elseif msgId == ActionEvents.C2G_SevenLogin_HadReceive then
		if errCode == 0 then
			GlobalEventSystem:Fire(GameEvent.EventReceiveAward)						
		end
	elseif msgId == ActionEvents.C2G_SetPutdownSkill then
		if errCode == 0 then 
			--快捷技能设置成功			
			GlobalEventSystem:Fire(GameEvent.EventUpdateQuickSkillViewSuccess)			
		end
	elseif msgId == ActionEvents.C2G_Chat_Current_Scene then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, true)
		else
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, false)
		end
	elseif msgId == ActionEvents.C2G_Chat_World then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, true)
		else
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, false)
		end
	elseif msgId == ActionEvents.C2G_Chat_Bugle then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, true)
		else
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, false)
		end	
	elseif tonumber(msgId) == ActionEvents.C2G_Chat_Society then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, true)
		else
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, false)
		end
	elseif tonumber(msgId) == ActionEvents.C2G_Chat_Private then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, true)
		else
			GlobalEventSystem:Fire(GameEvent.EventResetMessage, false)
		end
	elseif tonumber(msgId) == ActionEvents.C2G_Talisman_Active then
		GameWorld.Instance:getTalismanManager():requestTalismanList()
	--[[elseif tonumber(msgId) == ActionEvents.C2G_Achievement_GetReward then
		if errCode >= 0 then
			print("C2G_Achievement_GetReward ok")
		else
			print("C2G_Achievement_GetReward not ok")
		end	--]]		
	elseif tonumber(msgId) == ActionEvents.C2G_Achievement_GetAllReward then
		if errCode >= 0 then
			GlobalEventSystem:Fire(GameEvent.EventResetButtonState)
		else
			--print("C2G_Achievement_GetAllReward not ok")
		end	
	else
		self:onCommonResult(msgId, errCode)
	end
end

-- 获取角色列表
function LoginActionHandler:onCharacterGet(reader)
	local LoginManager = LoginWorld.Instance:getLoginManager()
	LoginManager:removeLoginHeroList()
	local count = StreamDataAdapter:ReadChar(reader)
	for i=1,count do
		local characterId = StreamDataAdapter:ReadStr(reader)
		local name = StreamDataAdapter:ReadStr(reader)
		local level = StreamDataAdapter:ReadShort(reader) --int->short
		local gender = StreamDataAdapter:ReadChar(reader)
		local profession = StreamDataAdapter:ReadChar(reader)
		
		
		local loginRoleObject = LoginRoleObject.New()
		loginRoleObject:setCharacterId(characterId)
		loginRoleObject:setName(name)
		loginRoleObject:setProfession(profession)
		loginRoleObject:setGender(gender)
		loginRoleObject:setLevel(level)
		if level >=40 then
			ResManager.Instance:setNeedExtend(true)
		end
		LoginManager:setLoginHeroList(loginRoleObject)
	end
	
	self:onEnterSelectRoleView()--选择角色
	--TODO
	--通知sdk进入服务器
	local serverMgr = LoginWorld.Instance:getServerMgr()
	local server = serverMgr:getSelectServer()
	if server then 
		SFGameAnalyzer:logGameEvent(GameAnalyzeID.LoginServer, "serverId="..tostring(server:getServerId())) 
	end
end

--进入角色选择界面
function LoginActionHandler:onEnterSelectRoleView()
	GlobalEventSystem:Fire(GameEvent.EVENT_SELECT_ROLE_UI)--选择角色
	UIManager.Instance:hideLoadingHUD()
end

--删除角色
function LoginActionHandler:onCharacterDelete(reader)
	local LoginManager = LoginWorld.Instance:getLoginManager()
	local heroId = StreamDataAdapter:ReadStr(reader)
	LoginManager:removeLoginHero(heroId)
	GlobalEventSystem:Fire(GameEvent.EventDeleteRole,heroId)
end


-- 角色登陆成功
function LoginActionHandler:onCharacterLogin(reader)
	require("GameWorld")
	require("utils.PropertyDictionaryReader")
	require("utils.PropertyDictionary")
	
	LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.EnterGameFinish)
	if (not GameWorld) or (not GameWorld.Instance) then
		GameWorld.New()
		local gameMapManager = GameWorld.Instance:getMapManager()
		gameMapManager:loadConfig()			
	end
	GameWorld.Instance:getTimeManager():start()
	ResManager.Instance:requestCanGetReward()
	--删除登录资源
	LoginWorld.Instance:getLoginManager():deleteLoginRes()
	UIManager.Instance:clearSystemTips()	
	local heroId = StreamDataAdapter:ReadStr(reader)
	local propertyLen = StreamDataAdapter:ReadShort(reader)
	local propertyTable = getPropertyTable(reader)	
	
	-- 读取场景和位置信息
	local sceneRefId = PropertyDictionary:get_sceneRefId(propertyTable)
	local cellX = PropertyDictionary:get_positionX(propertyTable)
	local cellY = PropertyDictionary:get_positionY(propertyTable)
	
	-- 保存hero的数据
	local hero = GameWorld.Instance:getEntityManager():createHero(heroId)
	hero:setPT(propertyTable)
	hero:setCellXY(cellX, cellY)		
	
	-- 加载地图
	local entityManager = GameWorld.Instance:getEntityManager()
	local gameMapManager = GameWorld.Instance:getMapManager()
	
	if SceneManager.Instance:isInLoginScene() then
		SceneManager:switchTo(SceneIdentify.GameScene)
	end
	
	gameMapManager:loadMap(sceneRefId)
	
	if LoginWorld.Instance:getLoginManager():isReconnect() then
		-- 如果是断线重连进来的，要清楚所有的entity
		GameWorld.Instance:getEntityManager():clearServerEntity()
		
		if gameMapManager:getCurrentMapRefId() == sceneRefId then
			-- 如果场景ID相同,  loadMap不会发送场景ready消息, 要手动发送
			gameMapManager:sendSceneReady()
		end
	end
	
	if hero then
		hero:enterMap()
	end
	-- 转动摄像头
	local mapX, mapY = hero:getMapXY()
	local centerY = hero:getCenterY()
	gameMapManager:setViewCenter(0, 0)--TODO 应该要SFMap加个重置的接口
	gameMapManager:setViewCenter(mapX, centerY)

	-- enterMap
	--hero:enterMap()
	GlobalEventSystem:Fire(GameEvent.EventHeroEnterGame)
	--发送统计信息
	LoginWorld.Instance:getStatisticsMgr():requestStepStatistics(GameStep.EnterScene)
	
	--将角色名、id、等级、服务器id等信息发给sdk
	--local serverMgr = LoginWorld.Instance:getServerMgr()
	--local server = serverMgr:getSelectServer()
	SFLoginManager:getInstance():setPlayerName(PropertyDictionary:get_name(hero:getPT()))
	SFLoginManager:getInstance():initPaymentObserver()
--[[	if server then 
		local data = {}
		data.roleId = heroId
		data.roleName = PropertyDictionary:get_name(hero:getPT())
		data.roleLevel = PropertyDictionary:get_level(hero:getPT())
		data.zoneId = server:getServerId()
		data.zoneName = server:getServerName()
		local cjson = require "cjson.safe"		
		local extendData = cjson.encode(data)
		SFLoginManager:getInstance():submitExtendData(extendData)
	end
		--]]
	--重置配置文件
	local settingMgr = GameWorld.Instance:getSettingMgr()
	if settingMgr:getConfigCharacterId() ~= heroId then
		settingMgr:resetConfig(heroId)
		hero:getHandupMgr():getConfigMgr():resetConfig()
		--GameWorld.Instance:getHandupConfigMgr():resetConfig()
	end
	GameWorld.Instance:getFightTargetMgr() 	--目标管理需要在启动时就创建	
	GameWorld.Instance:getPickUpMnanager() 	--挂机配置管理需要在启动时就创建
	hero:getHandupMgr():getConfigMgr() 		
	
	hero:checkHeroDeathState()
	
	-- 加载常驻内存的UI资源
	--CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/kraft_dialogue.png")
	--CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/kraft_dungeon.png")
	
	CCTextureCache:sharedTextureCache():addImage("ui/ui_img/common/kraft_bg.pvr")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_common_other.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_common_line.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_other.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_tab.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/ui_common/ui_control_btn.plist")
		
	GlobalEventSystem:Fire(GameEvent.EVENT_MAIN_UI)--显示主界面
	GameWorld.Instance:getDiscountSellMgr():requestGetDiscountSellList()--请求打折出售列表
	GameWorld.Instance:getMonstorInvasionMgr():requestRemainingTime()--请求怪物入侵剩余时间
	
	
	--GameWorld.Instance:getPayActivityManager():requestFirstPayList()--请求首充列表
	GameWorld.Instance:getPayActivityManager():requestCanReceiveActivityList()--请求那些是可以领取的奖励
end

-- 错误信息的消息
function LoginActionHandler:onCommonResult(msgId, errCode)
	local code = errCode
	if code < 0 then
		code = 0xFFFFFFFF + errCode + 1
	end
	local function setHideLoading()
		UIManager.Instance:hideLoadingSence()
		UIManager.Instance:hideLoadingHUD()
	end
	CCLuaLog("msgId:"..msgId.."  errCode:"..code)
	if code == 0x80000004 then
		--昵称太短
		UIManager.Instance:showSystemTips(Config.LoginWords[310])
		setHideLoading()
	elseif code == 0x80000005 then
		--昵称太长
		UIManager.Instance:showSystemTips(Config.LoginWords[311])
		setHideLoading()
	elseif code == 0x80000006 then
		--昵称已经存在
		--UIManager.Instance:showSystemTips(Config.LoginWords[312])
		GlobalEventSystem:Fire(GameEvent.EventUpdateHeroName)	
		setHideLoading()
	elseif code == 0x8000000c then
		--昵称含非法字符
		UIManager.Instance:showSystemTips(Config.LoginWords[349])
		setHideLoading()
	elseif code == 0x80000007 then
		--已经创建角色
		UIManager.Instance:showSystemTips(Config.LoginWords[313])
		setHideLoading()
	elseif code == 0x80000388 then
		--玩家不在线或者不存在
		--UIManager.Instance:showSystemTips(Config.LoginWords[408])
		GlobalEventSystem:Fire(GameEvent.EventPeerIdNotExit) --刷新聊天编辑框
		setHideLoading()
	elseif code == 0x8000038a then
		--UIManager.Instance:showSystemTips(Config.LoginWords[409])
		setHideLoading()		
	elseif code == 0x80000641 then	
		--不能对自己操作
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000642 then
		--已组队
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000643 then	
		--加入队伍失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x8000064 then
		--踢出队伍失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000645 then	
		--离开队伍失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000646 then
		--转让队长失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000647 then	
		--解散队伍失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	elseif code == 0x80000648 then
		--邀请失败
		UIManager.Instance:showSystemTips(GameData.Code[code])
	end
end	

function LoginActionHandler:onMountResult(msgId,errCode)
	local code = errCode 
	if code < 0 then
		code = 0xFFFFFFFF + errCode + 1
	end		
	CCLuaLog("msgId:"..msgId.."  errCode:"..code)	
	local  mountMgr = GameWorld.Instance:getMountManager()
			
	if code == 0x8000044d then
		UIManager.Instance:showSystemTips(Config.LoginWords[1047])			
	elseif code == 0x8000044e then
		UIManager.Instance:showSystemTips(Config.LoginWords[1048])		
	elseif code == 0x8000044f then
		UIManager.Instance:showSystemTips(Config.LoginWords[1049])		
	elseif code == 0x80000450 then
		UIManager.Instance:showSystemTips(Config.LoginWords[1050])		
	elseif code == 0x80000451 then 
--		UIManager.Instance:showSystemTips(Config.LoginWords[1051])	
	elseif code == 0x80000452 then 
		UIManager.Instance:showSystemTips(Config.LoginWords[1052])	
	elseif code == 0x80000453 then
		UIManager.Instance:showSystemTips(Config.LoginWords[1053])	
	elseif code == 0x80000454 then
		UIManager.Instance:showSystemTips(Config.LoginWords[1054])
	elseif code == 0x80000455 then
		UIManager.Instance:showSystemTips(Config.LoginWords[1055])
	elseif code == 0x80000456 then
		UIManager.Instance:showSystemTips(Config.LoginWords[1058])			
	elseif code == 0 then  

	end
end
