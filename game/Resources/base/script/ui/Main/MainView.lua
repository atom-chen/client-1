require ("object.entity.EntityObject")
require("common.baseclass")
require("ui.UIManager")
require("ui.Main.MainView.MainHeroHead")
require("ui.Main.MainView.MainPlayerHead")
require("ui.Main.MainView.MainBossHead")
require("ui.Main.MainView.MainMap")
require("ui.Main.MainView.MainQuest")
require("ui.Main.MainView.MainJoyRocker")
require("ui.Main.MainView.MainAttackSkill")
require("ui.Main.MainView.MainMenu")
require("ui.Main.MainView.MainExp")
require("ui.Main.MainView.MainChat")
require("ui.Main.MainView.MainChatBtn")
require("ui.Main.MainView.MainActivity")
require("ui.buff.BuffView")
require("ui.Main.MainView.MainTeam")
require("ui.Main.MainMarquee")
require("ui.Main.MainView.MainOtherMenu")
require("ui.activity.MiningInfoView")
require("ui.activity.MonstorInvasionView")
require("ui.activity.UnionInstanceQuestView")
require("ui.Main.MainView.MainPKHit")
require("ui.Main.MainView.MainPingView")
require("ui.newGuidelines.NewGuidelinesView")

MainView = MainView or BaseClass(BaseUI)

DownloadState = {
None = 1,
Prepare = 2,
Downloading =3,
Finish = 4
}

ViewState = {
FunctionView = 1,
FightView = 2,
AutoFightView = 3
}

local visibleSize = CCDirector:sharedDirector():getVisibleSize()

MainView = MainView or BaseClass(BaseUI)

function MainView:__init()
	self.viewName = "MainView"
	self.scale = VisibleRect:SFGetScale()
	self.hero = GameWorld.Instance:getEntityManager():getHero()
	self.MainBossHeadId = nil
	self.ifShowMarquee = false
	self.rootNode:setContentSize(visibleSize)	
	self:createQuestNode()
	self:registerScriptTouchHandler()
	self:ShowQuest()--任务
	self:addMonstorInvasionView() --怪物入侵
	--self:ShowPlayerHead()--人物头像
	--self:ShowBossHead()--Boss头像
	--self:ShowTeammateHead()--组队

	local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	--frameCache:addSpriteFramesWithFile("ui/ui_game/ui_game_main_divideLoad.plist")		
	--frameCache:addSpriteFramesWithFile("loginUi/login_common_bg1.plist")
	
	self:ShowMap()--地图
	self:ShowJoyRocker()--摇杆
	self:ShowAttackSkill()--攻击技能
	self:ShowMainMenu()--主菜单
	self:ShowChat()--聊天
	self:ShowExp()--经验
	self:ShowChatBtn()--聊天按钮
	self:showOtherMenu()--其他菜单
	self:ShowActivities()--活动	
	self:showBuff()   --buff
	self:ShowHeroHead()--英雄头像	
	self:showPKHit()--PK受击
	self:showPingView()--显示ping值
	self:addMiningInfoNode() --挖矿面板
	self:showMainTeam()  --组队
	self:showUnhaveSelectPickUp()
	self:addUnionInfoNode()

	self.downloadIcon = nil	-- 下载扩展包的ICON
	self.downloadState = 0
	
	self.viewState = ViewState.FightView
	
	--显示欢迎界面
	local newGuidelinesMgr = GameWorld.Instance:getNewGuidelinesMgr()
	newGuidelinesMgr:showWelcomeView()
end

function MainView:showMainTeam()
	self.MainTeam = MainTeam.New()
	self.rootNode:addChild(self.MainTeam:getRootNode(), 2)
	VisibleRect:relativePosition(self.MainTeam:getRootNode(), self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(20, -40))
end

function MainView:__delete()
	if self.testMem then
		self.testMem:DeleteMe()
		self.testMem = nil
	end
	if self.buff then
		self.buff:DeleteMe()
		self.buff = nil
	end

	if self.MainHeroHead then
		self.MainHeroHead:DeleteMe()
		self.MainHeroHead = nil
	end

	if self.MainPlayerHead then
		self.MainPlayerHead:DeleteMe()
		self.MainPlayerHead = nil
	end

	if self.MainBossHead then
		self.MainBossHead:DeleteMe()
		self.MainBossHead = nil
	end

		
	if self.MainMap then
		self.MainMap:DeleteMe()
		self.MainMap = nil
	end
	
	
	if self.MainQuest then
		self.MainQuest:DeleteMe()
		self.MainQuest = nil
	end

	if self.MainJoyRocker then
		self.MainJoyRocker:DeleteMe()
		self.MainJoyRocker = nil
	end

	if self.MainAttackSkill then
		self.MainAttackSkill:DeleteMe()
		self.MainAttackSkill = nil
	end

	if self.MainMenu then
		self.MainMenu:DeleteMe()
		self.MainMenu = nil
	end

	if self.MainExp then
		self.MainExp:DeleteMe()
		self.MainExp = nil
	end

	if self.mainChat then
		self.mainChat:DeleteMe()
		self.mainChat = nil
	end

	if self.MainotherMenu then
		self.MainotherMenu:DeleteMe()
		self.MainotherMenu = nil
	end
	
	if self.mainActivities then
		self.mainActivities:DeleteMe()
		self.mainActivities = nil
	end
		
	if self.mainChatBtn then
		self.mainChatBtn:DeleteMe()
		self.mainChatBtn = nil
	end

	if self.marquee then	
		self.marquee:DeleteMe()
		self.marquee = nil
	end

	if self.MiningInfoView then
		self.MiningInfoView:DeleteMe()
		self.MiningInfoView = nil
	end

	if self.monstorInvasionView then
		self.monstorInvasionView:DeleteMe()
		self.monstorInvasionView = nil
	end
	
	if self.UnionInstanceView then
		self.UnionInstanceView:DeleteMe()
		self.UnionInstanceView = nil
	end
	
	if self.mainPKHit then
		self.mainPKHit:DeleteMe()
		self.mainPKHit = nil
	end
	
	
	if self.pingView then
		self.pingView:DeleteMe()
		self.pingView = nil
	end		
	
	if self.MainTeam then
		self.MainTeam:DeleteMe()
		self.MainTeam = nil
	end
	if self.scheId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheId)
		self.scheId = nil
	end	
	
end

function MainView:registerScriptTouchHandler()
	local function ccTouchHandler(eventType, x,y)
		GlobalEventSystem:Fire(GameEvent.EventMainViewClick)  --buff界面需要此事件来销毁buff的tips界面
		return self:touchHandler(eventType, x, y)
	end
	self.rootNode:registerScriptTouchHandler(ccTouchHandler, false, -55, true)
end

function MainView:touchHandler(eventType, x, y)
	if(eventType == "began") then
		if self.MainHeroHead then
			local posX,posY = self.MainHeroHead:getStateTablePos()
			if posX and posY and (x < posX or x > posX + 312 or y < posY or y > posY + 300) then
				self.MainHeroHead:showHeroStateView(false)
			end
		end
		--[[if self.MainPlayerHead then
			local playInteractionView = self.MainPlayerHead:getPlayerInteractionView()
			local node = playInteractionView:getRootNode()
			if node:isVisible() and node:getParent() then	
				local parent = node:getParent()
				local point = parent:convertToNodeSpace(ccp(x,y))
				local rect = node:boundingBox()
				if not rect:containsPoint(point) then		
					GlobalEventSystem:Fire(GameEvent.EventClosePlayerInteractionView)
				end	
			end	
		end--]]
	end
end

--切换主界面
function MainView:eventMoveView()
	self:MoveView()
end

--更新人物属性接口
function MainView:eventMainHeroPorpertyUpdate(pt)
	self:UpdateHeroPorpertyDate(pt)
end

--更新Boss属性接口
function MainView:eventMainBOSSPorpertyUpdate(pt)
	self:UpdateBOSSPorpertyDate(pt)
end

--是否显示Boss信息
function MainView:eventIsShowBossView(bShow, entityId)
	self:ShowBossHead(bShow, entityId)
end

function MainView:eventHandupConfig(config)
	self:handupConfig(config)
end

function MainView:enterAutoFightView(state)
	if state==ViewState.FunctionView then
		self:changeMainViewStateToFunctionView()
	elseif state==ViewState.FightView then
		self:changeMainViewStateToFightView()
	elseif state==ViewState.AutoFightView then
		self:changeMainViewStateToAutoFightView()
	end
end

function MainView:enterShowPKHitView()
	if self.mainPKHit then
		self.mainPKHit:playActions()
	end
end

-- 更新下载扩展包的按钮的状态
function MainView:setDownloadState(state)
	if state >= DownloadState.None and state <= DownloadState.Finish then
		self.downloadState = state
		function clickDownload()
			if self.downloadState == DownloadState.Prepare then
				-- 提示是否要开始下载扩展包
				local downloadfunc = function ()
					ResManager.Instance:downloadExtend(true,DownloadKey.extendAndPatch)
					self:setDownloadState(DownloadState.Downloading)
				end
				ResManager.Instance:showDownloadMessage(Config.Words[341],downloadfunc)	
			elseif self.downloadState == DownloadState.Downloading then
				-- 提示正在下载
				--UIManager.Instance:showSystemTips(Config.Words[342])
				GlobalEventSystem:Fire(GameEvent.EventSubPackageLoadViewOpen)
			elseif self.downloadState == DownloadState.Finish then
				-- 提示下载已经完成
				--UIManager.Instance:showSystemTips(Config.Words[343])
				GlobalEventSystem:Fire(GameEvent.EventSubPackageLoadViewOpen)
			end
		end
		
		if self.downloadIcon == nil and self.downloadState ~= DownloadState.None then
			self.downloadIcon = createButtonWithFramename(RES("main_bag.png"))
			self:addChild(self.downloadIcon)
			local size = self.downloadIcon:getContentSize()
			VisibleRect:relativePosition(self.downloadIcon, self.rootNode, LAYOUT_RIGHT_INSIDE+LAYOUT_CENTER, ccp(-size.width-20-20,15))
			self.downloadIcon:addTargetWithActionForControlEvents(clickDownload,CCControlEventTouchDown)
		elseif self.downloadIcon and self.downloadState == DownloadState.None then
			self.downloadIcon:removeFromParentAndCleanup(true)
			self.downloadIcon = nil
		end
		
		if self.downloadIcon then
			self.downloadIcon:setVisible(true)
			self.downloadIcon:removeChildByTag(99, true)
			
			local textState = "main_text_download.png"
			if self.downloadState == DownloadState.Downloading then
				textState = "main_text_downloading.png"
			elseif self.downloadState == DownloadState.Finish then
				textState = "main_text_downloaded.png"
			end
						
			local textSprite = createSpriteWithFrameName(RES(textState))
			if textSprite then
				self.downloadIcon:addChild(textSprite, 0, 99)
				VisibleRect:relativePosition(textSprite, self.downloadIcon, LAYOUT_CENTER)
			end
		end
	end
end

function MainView:changeDownLoadButtonState(show)
	if self.downloadIcon then
		self.downloadIcon:setVisible(show)
	end
end

function MainView:create()
	return MainView.New()
end

function MainView:getRootNode()
	return self.rootNode
end

function MainView:showBuff()
	self.buff = BuffView.New()
	self.rootNode:addChild(self.buff:getRootNode(), 2)
	VisibleRect:relativePosition(self.buff:getRootNode(), self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_TOP_INSIDE, ccp(15, -140))
end

function MainView:getBuffView()
	return self.buff
end	

function MainView:ShowHeroHead()
	self.MainHeroHead = MainHeroHead.New()
	self.rootNode:addChild(self.MainHeroHead:getRootNode(),3)
end

function MainView:updateHeroState()
	if self.MainHeroHead then
		self.MainHeroHead:updateHeroState()
	end
end

function MainView:setNearbySelectVisible(bShow)
	if self.MainHeroHead then
		self.MainHeroHead:setNearbySelectVisible(bShow)
	end
end

function MainView:getHeroHeadView()
	return self.MainHeroHead
end

function MainView:getBossView()
	return self.MainBossHead
end

function MainView:ShowPlayerHead(selectEntityObject, bShow)
	if self.MainPlayerHead then	
		local playerId = self.MainPlayerHead:getPlayId()	
		self.rootNode:removeChild(self.MainPlayerHead:getRootNode(),true)
		self.MainPlayerHead:DeleteMe()
		if not selectEntityObject then
			return
		end
		local id = selectEntityObject:getId()
		if playerId and playerId == selectEntityObject:getId() then
			return
		end
	end		
	if not selectEntityObject then
		return
	end
	self.MainPlayerHead = MainPlayerHead.New()
	self.MainPlayerHead:onEnter(selectEntityObject)
	self.rootNode:addChild(self.MainPlayerHead:getRootNode())
end

function MainView:ShowBossHead(bShow, entityId)
	if bShow then	
		if not self.MainBossHead and bShow then
			self.MainBossHead = MainBossHead.New(bShow, entityId)
			self.rootNode:addChild(self.MainBossHead:getRootNode())
			if self.viewState == ViewState.AutoFightView then
				local offsetY = self.MainBossHead:getOffsetY(OffsetYType.Up)
				VisibleRect:relativePosition(self.MainBossHead:getRootNode(), self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0, offsetY))
			else
				VisibleRect:relativePosition(self.MainBossHead:getRootNode(), self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE)
			end
			
			self.MainBossHeadId = entityId
		elseif self.MainBossHead and bShow and self.MainBossHeadId ~= entityId then
			if self.MainBossHead:getRootNode() then
				self.MainBossHead:getRootNode():removeFromParentAndCleanup(true)
				self.MainBossHead:DeleteMe()
				self.MainBossHeadId = nil
				self.MainBossHead = nil
			end
			self.MainBossHead = MainBossHead.New(bShow, entityId)
			self.rootNode:addChild(self.MainBossHead:getRootNode())
			if self.viewState == ViewState.AutoFightView then
				local offsetY = self.MainBossHead:getOffsetY(OffsetYType.Down)
				VisibleRect:relativePosition(self.MainBossHead:getRootNode(), self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(0, offsetY))
			else
				VisibleRect:relativePosition(self.MainBossHead:getRootNode(), self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE)
			end
			self.MainBossHeadId = entityId
		end
	end
	
	if bShow == false then
		if self.MainBossHead and self.MainBossHead:getRootNode() then
			self.MainBossHead:getRootNode():removeFromParentAndCleanup(true)
			self.MainBossHead:DeleteMe()
			self.MainBossHeadId = nil
			self.MainBossHead = nil
		end
	end
	
end

function MainView:bossOwnerChange(bossId, ownerId)
	if self.MainBossHead then
		self.MainBossHead:bossOwnerChange(bossId, ownerId)
	end
end

function MainView:ShowMap()
	self.MainMap = MainMap.New()
	self.rootNode:addChild(self.MainMap:getRootNode())
	VisibleRect:relativePosition(self.MainMap:getRootNode(), self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE,ccp(-5,0))
end

function MainView:ShowQuest()
	self.MainQuest = MainQuest.New()	
	self.questNode:addChild(self.MainQuest:getRootNode())
	VisibleRect:relativePosition(self.MainQuest:getRootNode(), self.questNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
end

function MainView:getQuest()
	return self.MainQuest
end

function MainView:ShowJoyRocker()
	self.MainJoyRocker = MainJoyRocker.New()
	self.rootNode:addChild(self.MainJoyRocker:getRootNode())
	VisibleRect:relativePosition(self.MainJoyRocker:getRootNode(),self.rootNode,  LAYOUT_CENTER)
end

function MainView:ShowAttackSkill()
	self.MainAttackSkill = MainAttackSkill.New()
	self.rootNode:addChild(self.MainAttackSkill:getRootNode())
	VisibleRect:relativePosition(self.MainAttackSkill:getRootNode(),self.rootNode,  LAYOUT_CENTER)
end

function MainView:getAttackSkillView()
	return self.MainAttackSkill
end

function MainView:ShowMainMenu()
	self.MainMenu = MainMenu.New()
	self.rootNode:addChild(self.MainMenu:getRootNode())
	self.MainMenu:getRootNode():setVisible(false)
	VisibleRect:relativePosition(self.MainMenu:getRootNode(), self.rootNode,  LAYOUT_CENTER,ccp(0,-visibleSize.height/3))
	self.MainMenu:getRootNode():setVisible(false)
end

function MainView:ShowExp()
	self.MainExp = MainExp.New()
	self.rootNode:addChild(self.MainExp:getRootNode())
end

function MainView:ShowChat()
	self.mainChat = MainChat.New()
	self.rootNode:addChild(self.mainChat:getRootNode())
	VisibleRect:relativePosition(self.mainChat:getRootNode(), self.rootNode, LAYOUT_BOTTOM_INSIDE+LAYOUT_CENTER_X,ccp(-100,0))
end

function MainView:showOtherMenu()
	self.MainotherMenu = MainOtherMenu.New()
	self.rootNode:addChild(self.MainotherMenu:getRootNode())
	VisibleRect:relativePosition(self.MainotherMenu:getRootNode(), self:getMapView().rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_BOTTOM_OUTSIDE, ccp(0, 0))
end

function MainView:addAttacker(obj)
	if self.MainotherMenu then
		self.MainotherMenu:addAttacker(obj)
	end
end	

function MainView:removeAttacker(obj)
	if self.MainotherMenu then
		self.MainotherMenu:removeAttacker(obj)
	end
end

function MainView:clearAllAttackers()
	if self.MainotherMenu then
		self.MainotherMenu:clearAllAttackers()
	end	
end

function MainView:setMainOtherBtnVisible(typeBtn, bShow)
	if self.MainotherMenu then
		self.MainotherMenu:setBtnVisible(typeBtn,bShow)
	end
end

function MainView:showPKHit()
	self.mainPKHit = MainPKHit.New()
	self.rootNode:addChild(self.mainPKHit:getRootNode())
	VisibleRect:relativePosition(self.mainPKHit:getRootNode(), self.rootNode, LAYOUT_CENTER)
end




function MainView:getMainOtherMenu()
	return self.MainotherMenu
end

function MainView:getMainChatView()
	return self.mainChat
end

function MainView:getMainActivities()
	return self.mainActivities
end

function MainView:getMapView()
	return self.MainMap
end

function MainView:mountButtonCallBack()
	--[[if self.mainActivities then
		self.mainActivities:clickMountBtn()
	end--]]
end

function MainView:ShowActivities()
	self.mainActivities = MainActivity.New()
	local activityNode = self.mainActivities:getRootNode()
	local activityNodeWidth = activityNode:getContentSize().width
	self.rootNode:addChild(activityNode)
	VisibleRect:relativePosition(activityNode, self.rootNode,  LAYOUT_RIGHT_INSIDE+LAYOUT_TOP_INSIDE, ccp(activityNodeWidth-220,-40))
end

function MainView:ShowChatBtn()
	self.mainChatBtn = MainChatBtn.New()
	self.rootNode:addChild(self.mainChatBtn:getRootNode())	
	VisibleRect:relativePosition(self.mainChatBtn:getRootNode(),self.rootNode,  LAYOUT_CENTER,ccp(0,0))
end

function MainView:getChatBtn()
	return self.mainChatBtn
end

function MainView:UpdateHeroPorpertyDate(pt)
	--更新人物头像面板
	if self.MainHeroHead then
		self.MainHeroHead:Update(pt)
	end
	
	--更新经验
	if self.MainExp then
		self.MainExp:Update(pt)
	end
end

function MainView:UpdateBOSSPorpertyDate(pt)
	--更目标目标头像面板
	if self.MainBossHead then
		self.MainBossHead:UpdateHP(pt)
	end
end

function MainView:UpdatePlayerPropertyData()
	if self.MainPlayerHead then
		self.MainPlayerHead:Update()
	end
end

function MainView:onEventQuestshow(instance)
	if self.MainQuest then
		self.MainQuest:eventQuestshow(instance)
	end
end

function MainView:onEventQuestUpdate()
	if self.MainQuest then
		self.MainQuest:eventQuestUpdate()
	end
end

--禁用启用按钮点击（设置按钮为灰度图）
function MainView:onSetMenuBtnstatus(MenuBtn,bEnable)
	self.MainMenu:setMenuBtnstatus(MenuBtn,bEnable)
end

--禁用启用所有按钮点击（设置按钮为灰度图）
function MainView:onSetAllBtnStatus(bEnable)
	self.MainMenu:setAllBtnStatus(bEnable)
end

--禁用启用按钮点击（设置按钮为灰度图）
function MainView:onSetMenuBtnOpenOrclose(MenuBtn,bEnable)
	if self.MainMenu then
		self.MainMenu:setMenuBtnOpenOrclose(MenuBtn,bEnable, true)
	end
end

--邮件显示/隐藏
--[[function MainView:onSetMailBtnStatus(unReadMailNum)
	self.MainMail:setMailBtnStatus(unReadMailNum)
end--]]

--删除动画
--[[function MainView:onRemoveAnimateByBtnId(btnId)
	self.MainMenu:removeAnimateByBtnId(btnId)
end--]]
--停止动画
function MainView:onStopAction(btnId)
	self.MainMenu:stopMenuAction(btnId)
end

--[[function MainView:showLeaveInstanceButton(show)
	if show then
		if not self.leaveButtonFrame then
			local manager = GameWorld.Instance:getGameInstanceManager()
			
			self.leaveButtonFrame = createScale9SpriteWithFrameName(RES("common_circle_bg.png"))
			self.rootNode:addChild(self.leaveButtonFrame)
			VisibleRect:relativePosition(self.leaveButtonFrame,self.rootNode,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-22, 111))
			
			self.leaveButton =  createButton(createScale9SpriteWithFrameNameAndSize(RES("main_leave.png"),CCSizeMake(60,60)))	
			self.leaveButtonFrame:addChild(self.leaveButton)			
			VisibleRect:relativePosition(self.leaveButton,self.leaveButtonFrame,LAYOUT_CENTER)
			
			local leaveButtonText = createScale9SpriteWithFrameName(RES("main_instance_leave_word.png"))
			self.leaveButtonFrame:addChild(leaveButtonText)
			VisibleRect:relativePosition(leaveButtonText,self.leaveButtonFrame,LAYOUT_CENTER+LAYOUT_BOTTOM_OUTSIDE,ccp(0, 10))
			local exitFunction = function(arg,text,id)
				if id == 2 then
					GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
					manager:requestLeaveGameInstance()
					UIManager.Instance:showSystemTips(Config.Words[15011])
				end
			end
			local exitMsgBox = function()
				local msg = showMsgBox(Config.Words[15022],E_MSG_BT_ID.ID_CANCELAndOK)	
				msg:setNotify(exitFunction)
			end
			self.leaveButton:addTargetWithActionForControlEvents(exitMsgBox,CCControlEventTouchDown)
		end
	else
		if self.leaveButtonFrame then
			self.rootNode:removeChild(self.leaveButtonFrame,true)
			self.leaveButtonFrame = nil
		end
	end
end--]]

--怪物入侵退出按钮
--[[function MainView:showLeaveMonstorInvasionButton(show)
	if show then
		if not self.leaveMonstorIvasionBtnFrame then
			self.leaveMonstorIvasionBtnFrame = createScale9SpriteWithFrameName(RES("common_circle_bg.png"))
			self.rootNode:addChild(self.leaveMonstorIvasionBtnFrame)
			VisibleRect:relativePosition(self.leaveMonstorIvasionBtnFrame,self.rootNode,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-22, 111))
			self.leaveMonstorIvasionBtn = createButton(createScale9SpriteWithFrameNameAndSize(RES("main_leave.png"),CCSizeMake(60,60)))
			self.leaveMonstorIvasionBtnFrame:addChild(self.leaveMonstorIvasionBtn)
			VisibleRect:relativePosition(self.leaveMonstorIvasionBtn,self.leaveMonstorIvasionBtnFrame,LAYOUT_CENTER)
			local exitFunction = function()			
				if GameWorld.Instance:getMapManager():isInSafeArea(G_getHero():getCellXY()) then 
					local monstorInvasionMgr = G_getHero():getMonstorInvasionMgr()
					monstorInvasionMgr:requestExitMonstorInvasionActivity()
				else
					self.monstorInvasionView:showExitDlg()
				end
			end
			self.leaveMonstorIvasionBtn:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
		end
	else
		if self.leaveMonstorIvasionBtnFrame then
			self.rootNode:removeChild(self.leaveMonstorIvasionBtnFrame,true)
			self.leaveMonstorIvasionBtnFrame = nil
		end
	end
end--]]

--[[function MainView:showLeaveActivityButton(show)
	if show then
		if not self.leaveActivityButtonFrame then	
			self.leaveActivityButtonFrame = createScale9SpriteWithFrameName(RES("common_circle_bg.png"))
			self.rootNode:addChild(self.leaveActivityButtonFrame)
			VisibleRect:relativePosition(self.leaveActivityButtonFrame,self.rootNode,LAYOUT_CENTER+LAYOUT_RIGHT_INSIDE,ccp(-22, 111))	
			self.leaveActivityButton = createButton(createScale9SpriteWithFrameNameAndSize(RES("main_leave.png"),CCSizeMake(60,60)))
			self.leaveActivityButtonFrame:addChild(self.leaveActivityButton)
			VisibleRect:relativePosition(self.leaveActivityButton,self.leaveActivityButtonFrame,LAYOUT_CENTER)
					
			local exitFunction = function()
				GameWorld.Instance:getEntityManager():getHero():getHandupMgr():stop()
				--请求离开活动
				--Todo 暂时只做离开挖矿场景
				local miningMgr = GameWorld.Instance:getMiningMgr()
				miningMgr:requestExitMining()
			end
			self.leaveActivityButton:addTargetWithActionForControlEvents(exitFunction,CCControlEventTouchDown)
		end
	else
		if self.leaveActivityButtonFrame then
			self.rootNode:removeChild(self.leaveActivityButtonFrame,true)
			self.leaveActivityButtonFrame = nil
		end
	end
end--]]

function MainView:showPlayerInteractionView()
	self.MainPlayerHead:showInteractionView()
end



function MainView:handupConfig(config)
	--更新人物头像回血蓝自动点
	if self.MainHeroHead then
		self.MainHeroHead:handupConfig(config)
	end
end

function MainView:setFactionInviteBtnStatus(isShow)
	self.MainTeam:setFactionBtnStatus(isShow)
end

function MainView:setTeamInviteBtnStatus(isShow)
	self.MainTeam:setTeamInviteBtnStatus(isShow)
end
--走马灯
function MainView:showMarquee()
	local tipsMgr = LoginWorld.Instance:getTipsManager()		
	if self.ifShowMarquee == false then
		self.marquee = MainMarquee.New()
		local marNode = self.marquee:getRootNode()
		self.rootNode:addChild(marNode)
		VisibleRect:relativePosition(self.marquee:getRootNode(),self.rootNode,LAYOUT_CENTER+LAYOUT_TOP_INSIDE,ccp(0,100))
		marNode:setTag(100)		
		local msg = tipsMgr:getSystemMarqueeMessage()
		local fontColor = tipsMgr:getSystemMarqueeFontColor()
		self.marquee:show(msg,nil,fontColor)
		self.ifShowMarquee = true
	elseif self.ifShowMarquee == true and self.marquee then
		local msg = tipsMgr:getSystemMarqueeMessage()
		self.marquee:insertMarqueeMessage(msg)
	end
end

function MainView:closeMarquee()
	if self.marquee and self.marquee.BGSprite then
		self.marquee.BGSprite : setVisible(false)
	end
	local marNode = self.rootNode:getChildByTag(100)
	if marNode then
		self.rootNode : removeChildByTag(100,true)
		self.marquee:DeleteMe()
		self.marquee = nil
		self.ifShowMarquee = false
	end
end

function MainView:setVipIcon(vipLevel)
	if self.MainHeroHead then
		self.MainHeroHead:setVipIcon(vipLevel)
	end
end

function MainView:getMainQuestNode(index)
	if self.MainQuest then
		return self.MainQuest:getCellNode(index)
	end
end
function MainView:setQuestVisible(bShow)
	if self.MainQuest then
		(self.MainQuest:getRootNode()):setVisible(bShow)
	end
end

function MainView:addMiningInfoNode()
	local viewSize = CCSizeMake(250*self.scale,180*self.scale)
	self.MiningInfoView = MiningInfoView.New(viewSize)
	--self.rootNode:addChild(self.MiningInfoView:getRootNode(), 1)
	--VisibleRect:relativePosition(self.MiningInfoView:getRootNode(),self.rootNode,LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(0,45))
	self.questNode:addChild(self.MiningInfoView:getRootNode(), 1)
	VisibleRect:relativePosition(self.MiningInfoView:getRootNode(),self.questNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(0,45))
end	

function MainView:setMiningInfoVisible(bShow)
	if self.MiningInfoView then
		(self.MiningInfoView:getRootNode()):setVisible(bShow)
	end
end

function MainView:refreshCount()
	if self.MiningInfoView then
		self.MiningInfoView:refreshCount()
	end
end

--公会副本
function MainView:addUnionInfoNode()
	if self.UnionInstanceView then
		self.UnionInstanceView:removeFromParentAndCleanup(true)
		self.UnionInstanceView = nil
	end
	local viewSize = CCSizeMake(200*self.scale,150*self.scale)
	self.UnionInstanceView = UnionInstanceQuestView.New(viewSize)
	self.questNode:addChild(self.UnionInstanceView:getRootNode(), 1)
	VisibleRect:relativePosition(self.UnionInstanceView:getRootNode(),self.questNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE,ccp(0,45))
	self.UnionInstanceView:getRootNode():setVisible(false)
end

function MainView:showUnionInstanceViewVisible(bShow)
	if self.UnionInstanceView then
		self.UnionInstanceView:getRootNode():setVisible(bShow)
	end
end

function MainView:getUnionInstanceView()
	return self.UnionInstanceView
end

--怪物入侵
function MainView:addMonstorInvasionView()
	if self.monstorInvasionView then
		self.monstorInvasionView:removeFromParentAndCleanup(true)
		self.monstorInvasionView = nil
	end
	local size = CCSizeMake(245, 175)
	self.monstorInvasionView = MonstorInvasionView.New(size)
	--self.rootNode:addChild(self.monstorInvasionView:getRootNode(), 1)
	--VisibleRect:relativePosition(self.monstorInvasionView:getRootNode(), self.rootNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(0, 45))
	self.questNode:addChild(self.monstorInvasionView:getRootNode(), 1)
	VisibleRect:relativePosition(self.monstorInvasionView:getRootNode(), self.questNode, LAYOUT_LEFT_INSIDE+LAYOUT_CENTER_Y, ccp(0, 45))	
end

function MainView:setMonstorInvasionViewVisible(bShow)
	if self.monstorInvasionView then
		self.monstorInvasionView:getRootNode():setVisible(bShow)
	end
end

function MainView:getMonstorInvasionView()
	return self.monstorInvasionView
end

function MainView:refreshMiningLeftTime()
	if self.MiningInfoView then
		self.MiningInfoView:refreshMiningLeftTime()
	end
end

function MainView:stopMiningTime()
	if self.MiningInfoView then
		self.MiningInfoView:stopMiningTime()
	end
end


--关闭所有拾取筛文本提示消息
function MainView:showUnhaveSelectPickUp()
	local settingMgr = GameWorld.Instance:getSettingMgr()
	local isSelectNull = settingMgr:isSelectNull()
	if isSelectNull then
		UIManager.Instance:showSystemTips(Config.Words[10512])				
	end
end

function MainView:UpdateTeammateHead()
	if self.MainQuest then
		self.MainQuest:UpdateTeammateHead()
	end
end

function MainView:showWorldBossAni()
	if self.MainotherMenu then 	
		local remove = function()	
			if self.scheId then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheId)
				self.scheId = nil
			end
			if 	self.MainotherMenu then		
				self.MainotherMenu:removeAnimation(MainOtherType.WorldBoss)
			end
		end			
		remove()		
		self.MainotherMenu:addAnimation(MainOtherType.WorldBoss)						
		self.scheId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(remove, 20, false)
	end
end

function MainView:setVisibleJoyRocker(bShow)
	self.MainJoyRocker:getRootNode():setVisible(bShow)
end

function MainView:createJoyRocker()
	return self.MainJoyRocker:createJoyRocker()
end	

function MainView:getHeroHeadNode()
	return self.MainHeroHead:getHeroHeadNode()
end

function MainView:getShowMenu()
	return self.MainMenu
end

function MainView:getMenuSkillNode()
	return self.MainMenu:getMenuNode(MainMenu_Btn.Btn_skill)
end

--[[--获取主界面node
function MainView:getNodeByIndex(index)
	local node = nil
	if index==1 then--任务追踪面板
		node = self:getMainQuestNode(0)
	elseif index == 36 then--左上角角色头像
		node = self:getHeroHeadNode()	
	elseif index == 7 then--主菜单技能按钮
		node = self:getMenuSkillNode()	  
	end
	
	return node
end--]]


--处点击事件
function MainView:doNewGuidelinesByClickIdex(index)
	if index==1 then--任务追踪面板	
		if self.MainQuest then
			self.MainQuest:doNewGuidelinesByClickMainQuest()
		end
	elseif index == 5 then
		self.mainActivities:doNewGuidelinesByClickNode()
	elseif index == 36 then--点击左上角角色头像
		self.MainHeroHead:doNewGuidelinesByClickNode()
	elseif index == 7 then--主菜单技能按钮
		--node = self:getHeroHeadNode()	
	end		
end

function MainView:getNavigationMap()
	if self.MainMap then
		return self.MainMap:getNavigationMap()
	end
end

function MainView:createQuestNode()
	if not self.questNode then
		self.questNode = CCNode:create()
		self.questNode:setContentSize(visibleSize)
		self.rootNode:addChild(self.questNode)
		VisibleRect:relativePosition(self.questNode, self.rootNode, LAYOUT_CENTER)
	end
end

function MainView:setQuestNodeVisible(bShow)
	if self.questNode then
		self.questNode:setVisible(bShow)
	end
end

function MainView:getMainPlayerHead()
	return self.MainPlayerHead
end

function MainView:changeToFightView()
	if self.viewState == ViewState.AutoFightView then		
		VisibleRect:relativePosition( self.MainQuest:getViewNode(), self.rootNode, LAYOUT_CENTER_Y+LAYOUT_LEFT_INSIDE)
		self:changeMainViewStateToFightView()					
	end
end

function MainView:MoveView()
	if G_getCastleWarMgr():isInCastleWar() == true then--在公会战内
		if self.viewState == ViewState.FunctionView then
			self:changeMainViewStateToAutoFightView()	
		elseif self.viewState == ViewState.FightView then
			self:changeMainViewStateToFunctionView()		
		elseif self.viewState == ViewState.AutoFightView then
			self:changeMainViewStateToFightView()
		end
	else
		if self.viewState == ViewState.FunctionView then	
			self:changeMainViewStateToFightView()		
		elseif self.viewState == ViewState.FightView then
			self:changeMainViewStateToFunctionView()	
		elseif self.viewState == ViewState.AutoFightView then
			self:changeMainViewStateToFightView()			
		end
	end
end

function MainView:changeMainViewStateToFunctionView()
	if self.viewState == ViewState.FightView then
		if self.MainAttackSkill:getIsShow() == true then				
			self.MainMenu:setViewShow()
			self.MainAttackSkill:setViewHide()
			self.MainJoyRocker:setViewHide()
			self.mainChat:hideMyself()
			self.mainChatBtn:MoveChatBtn(true)
			self.viewState = ViewState.FunctionView
		end
	elseif self.viewState == ViewState.AutoFightView then
		if self.MainAttackSkill:getIsShow() == true then	
			--self.MainHeroHead:setViewShow()
			self.MainMap:setViewShow()
			if self.MainQuest then
				self.MainQuest:setViewHideOrShow(true)
			end	
			self.mainActivities:setViewShow()
			self.MainotherMenu:setViewShow()
						
			self.MainMenu:setViewShow()			
			self.MainAttackSkill:setViewHide()
			self.MainJoyRocker:setViewHide()
			self.mainChat:hideMyself()
			self.mainChatBtn:MoveChatBtn(true)
			self.viewState = ViewState.FunctionView
			
			if self.MainBossHead then
				self.MainBossHead:setViewShow()
			end
		end			
	end
end

function MainView:changeMainViewStateToFightView()
	if self.viewState == ViewState.FunctionView then
		if self.MainAttackSkill:getIsShow() == false then		
			self.viewState = ViewState.FightView
			self.MainAttackSkill:setViewShow()
			self.MainJoyRocker:setViewShow()
			self.mainChat:showMyself()
			
			self.MainMenu:setViewHide()
			self.mainChatBtn:MoveChatBtn(false)
		end
	elseif self.viewState == ViewState.AutoFightView then
		if self.MainAttackSkill:getIsShow() == true then
			self.viewState = ViewState.FightView
			self.MainMap:setViewShow()
			if self.MainQuest then
				self.MainQuest:setViewHideOrShow(true)
			end	
			if self.MainBossHead then
				self.MainBossHead:setViewShow()
			end
			self.mainActivities:setViewShow()
			self.MainotherMenu:setViewShow()
		end
	end
end

function MainView:changeMainViewStateToAutoFightView()		
	if self.viewState == ViewState.FunctionView then
		self.MainMenu:setViewHide()
		self.MainAttackSkill:setViewShow()
		self.MainJoyRocker:setViewShow()
		self.mainChat:showMyself()
		self.mainChatBtn:MoveChatBtn(false)	
		
		self.MainMap:setViewHide()
		if self.MainQuest then
			self.MainQuest:setViewHideOrShow(false)
		end	
		self.mainActivities:setViewHide()
		self.MainotherMenu:setViewHide()
		--self.MainHeroHead:setViewHide()
		if self.MainBossHead then
			self.MainBossHead:setViewHide()
		end
		self.viewState = ViewState.AutoFightView	
	elseif self.viewState == ViewState.FightView then																
		self.MainMap:setViewHide()
		if self.MainQuest then
			self.MainQuest:setViewHideOrShow(false)
		end	
		self.mainActivities:setViewHide()
		self.MainotherMenu:setViewHide()
		--self.MainHeroHead:setViewHide()
		if self.MainBossHead then
			self.MainBossHead:setViewHide()
		end
		self.viewState = ViewState.AutoFightView		
	end
end	

function MainView:setCanHandup(bCan)
	if self.MainAttackSkill then
		self.MainAttackSkill:setCanHandup(bCan)
	end
end

function MainView:showPingView()
	self.pingView = MainPingView.New()
	self.rootNode:addChild(self.pingView:getRootNode())
	VisibleRect:relativePosition(self.pingView:getRootNode(),self:getMapView().rootNode,LAYOUT_LEFT_OUTSIDE+LAYOUT_TOP_INSIDE,ccp(25,-10))
end

function MainView:updatePing(level)
	if self.pingView then
		self.pingView:updatePing(level)
	end
end

function MainView:refreshNextMineralTime()
	if self.MiningInfoView then
		self.MiningInfoView:refreshNextMineralTime()
	end
end