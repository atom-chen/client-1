require "gameevent.GameEvent"
require "ui.Npc.NpcQuestView"
require "ui.Npc.NpcTalkView"
require "ui.Npc.NpcPickView"
require "ui.Npc.NpcTransView"
require "ui.Npc.NpcCastleWarView"
require "ui.Npc.NpcInstanceView"
require"data.npc.collect"
require("object.npc.NpcDef")
NpcUIHandler = NpcUIHandler or BaseClass(GameEventHandler)

local LinkList = {
	[1] = "EventOpenExchangeView",
	[2] = "EventGameInstanceViewOpen",
	[3] = "EventVipAwardViewOpen",
	[4] = "EventOpenWarehouseView",
}

function NpcUIHandler:__init()
	self.npcPickupView = nil
	self:handleNpcClick()
	
	local manager =UIManager.Instance
	local mgr = GameWorld.Instance:getNpcManager()
	local eventEnterNpcQuest = function (arg)	
		local view = manager:getViewByName("NpcQuestView")
		if view then
			manager:hideUI("NpcQuestView")
		end
		
		manager:registerUI("NpcQuestView",NpcQuestView.create)				
		manager:showUI("NpcQuestView", E_ShowOption.eLeft,arg)
	end
	
	local eventEnterNpcTalk = function (arg)
		
		manager:registerUI("NpcTalkView",NpcTalkView.create)	
		manager:showUI("NpcTalkView",E_ShowOption.eLeft,arg)
	end
	
	local eventStartCollect = function()	
		manager:registerUI("NpcPickView",		NpcPickView.create)
		self:hideNpcPickView("end")		
		local collectInfo = mgr:getCollectInfo()
		if collectInfo.serverId and collectInfo.refId then		
			self.npcPickupView = NpcPickView.New()
			self.npcPickupView:setNpc(collectInfo.refId, collectInfo.serverId)
			local gNode = UIManager.Instance:getGameRootNode()	
			local pluckNode = self.npcPickupView:getRootNode()
			gNode:addChild(pluckNode,E_GameRootNodeOder.PluckRootNode)
			VisibleRect:relativePosition(pluckNode,gNode,LAYOUT_CENTER)					
		end
	end		
	
	local  eventUpdateQuestLevel = function(questId)
		local view = manager:getViewByName("NpcQuestView")
		local bShow = manager:isShowing("NpcQuestView")
		if view and bShow then
			view:EventUpdateQuestLevel(questId)
		end
	end
	
	local eventInteruptAnimation = function()			
		self:hideNpcPickView("interupt")
	end
	
	local eventEndCollect = function()			
		self:hideNpcPickView("end")		
	end
	
	local eventOpenTransfer = function(arg)
		
		manager:registerUI("NpcTransView", NpcTransView.create)
		manager:showUI("NpcTransView",  E_ShowOption.eLeft, arg)
	end
	
	local onEventCastleWarFactionList = function(list)	
		manager:registerUI("NpcCastleWarView",	NpcCastleWarView.New)
		if UIManager.Instance:isShowing("NpcCastleWarView") then
			if not table.isEmpty(list) then
				local str = Config.Words[18004]	--本周参加攻城战的公会				
				for k, v in ipairs(list) do
					str = str.."\n"..tostring(k)..". "..v.name
				end
				btns = {{text = Config.Words[5543],	id = 0}}
				local msg = showMsgBox(str)
				msg:setBtns(btns)
			else
				UIManager.Instance:showSystemTips(Config.Words[21005])
			end
		end
	end
	
	local onEventCastleWarStateChanged = function(bStart)	
		if bStart then	
--			HandupCommonAPI:switchPKMode(E_HeroPKState.stateFaction)			
			--Juchao@20140730: 强制切换模式为公会模式。不再判断客户端当前是否为公会模式，防止客户端出错，让大家加班到2:36分。
			GameWorld.Instance:getEntityManager():getHero():changeHeroPKState(E_HeroPKState.stateFaction)
		end			
		self:updateEntityNameColor()
	end	
	
	local onEventSceneChanged = function(currentMap, oldMap)
		G_getCastleWarMgr():updateCastleWarState()
		if currentMap ~= oldMap then --Juchao@20140617: 进/出 沙巴克相关场景时，请求一次沙巴克活动时间，与服务器核对状态。
			if currentMap == G_getCastleWarMgr():getCastleWarScene() or currentMap == G_getCastleWarMgr():getDamolongchengRefId()
			   or oldMap == G_getCastleWarMgr():getCastleWarScene() or oldMap == G_getCastleWarMgr():getDamolongchengRefId() then
				G_getCastleWarMgr():requestCastleWarTime()
			end
		end
	end
	
	--沙巴克boss的所属公会发生变化，更新英雄和其他玩家的名字颜色
	local onEventCastleWarBossUnionName = function(castleWarBossUnionName, isRefresh)
		self:updateEntityNameColor()
		if isRefresh then		
			self:runCastleWarBossKilledAction()
		end
	end
	
	local onEventHeroEnterGame = function()
		G_getCastleWarMgr():requestCastleWarTime()
		G_getCastleWarMgr():requestOpenServerTime()
	end
	
	local onEventUpdateNpcInstanceView = function (refId)
		local view = UIManager.Instance:getViewByName("NpcInstanceView")
		if view and refId then
			local bagMgr = G_getBagMgr()
			local bagCount = bagMgr:getItemNumByRefId(refId)
			if bagCount then
				view:updateView(bagCount)
			end				
		end
	end
	
	local onItemUpdate = function (eventType, items)
		for k, item in pairs(items) do 
			local refId = item:getRefId()
			if refId == "item_zhenmoling_1" then
				local manager =UIManager.Instance
				if manager:isShowing("NpcInstanceView") then	
					GlobalEventSystem:Fire(GameEvent.EventUpdateNpcInstanceView, refId)				
				end	
				break			
			end
		end
	end

	self:Bind(GameEvent.EventOpenTransfer,eventOpenTransfer)
	self:Bind(GameEvent.EventInteruptCollect,eventInteruptAnimation)	
	self:Bind(GameEvent.EventEndCollect,eventEndCollect)	
	self:Bind(GameEvent.EVENT_NpcQuest_UI, eventEnterNpcQuest)
	self:Bind(GameEvent.EVENT_NpcTalk_UI, eventEnterNpcTalk,arg)
	self:Bind(GameEvent.EventStartCollect,eventStartCollect)
	self:Bind(GameEvent.EventUpdateNPCQuestLevel, eventUpdateQuestLevel)
	self:Bind(GameEvent.EventCastleWarFactionList, onEventCastleWarFactionList)
	self:Bind(GameEvent.EventCastleWarStateChanged, onEventCastleWarStateChanged)
	self:Bind(GameEvent.EventSceneChanged, onEventSceneChanged)
	self:Bind(GameEvent.EventCastleWarBossUnionName, onEventCastleWarBossUnionName)
	self:Bind(GameEvent.EventHeroEnterGame, onEventHeroEnterGame)
	self:Bind(GameEvent.EventUpdateNpcInstanceView, onEventUpdateNpcInstanceView)
	self:Bind(GameEvent.EventItemUpdate, onItemUpdate)
end

function NpcUIHandler:__delete()
	
end

function NpcUIHandler:runCastleWarBossKilledAction()
	local sprite = createSpriteWithFrameName(RES("common_bossKilled.png"))		
	UIManager.Instance:showDialog(sprite, E_DialogZOrder.Tips)
		
	local fadeOut = CCFadeOut:create(2)
	local scale = CCScaleTo:create(2, 1.5)
	local array1 = CCArray:create()
	array1:addObject(fadeOut)
	array1:addObject(scale)
	local spawn = CCSpawn:create(array1)

	local finishFunCallBack = function ()
		if sprite and sprite:getParent() then
			sprite:removeFromParentAndCleanup(true)
			sprite = nil
		end			
	end
	local finishFun = CCCallFunc:create(finishFunCallBack)
		
	local array2 = CCArray:create()		
	array2:addObject(spawn)
	array2:addObject(finishFun)
	
	local seqAction = CCSequence:create(array2)
	sprite:runAction(seqAction)
end

function NpcUIHandler:updateEntityNameColor()
	local playerList = GameWorld.Instance:getEntityManager():getEntityListByType(EntityType.EntityType_Player)
	for k, v in pairs(playerList) do
		v:updateNameColor()
	end
	local monsterList = GameWorld.Instance:getEntityManager():getEntityListByType(EntityType.EntityType_Monster)
	for k,v in pairs(monsterList) do
		v:updateNameColor()
	end
	G_getHero():updateNameColor()
end

function NpcUIHandler:hideNpcPickView(hideType)
	if self.npcPickupView then		
		if hideType == "interupt" then
			self:hidePickView()
		elseif hideType == "end" then
			self.npcPickupView:setProgress(100)
			if(self.schedulerId) then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
			end
			local hidePickView =  function()
				self:hidePickView()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
				self.schedulerId = nil
			end
			self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(hidePickView,5/60, false)
		end
	end
end
function NpcUIHandler:hidePickView()
	if self.npcPickupView then
		self.npcPickupView:interuptAnimation()	
		if self.npcPickupView:getRootNode() then
			self.npcPickupView:getRootNode():removeFromParentAndCleanup(true)
		end		
		self.npcPickupView:DeleteMe()
		self.npcPickupView = nil	
	end
end

--打开任务对话框
function NpcUIHandler:isHaveQuest(npcObjRefId)
	local hero = GameWorld.Instance:getEntityManager():getHero()
	local questMgr = hero:getQuestMgr()
	if  questMgr then
		local questObj = G_getQuestLogicMgr():IsHaveQuest(npcObjRefId)
		if questObj~=nil then
			local questLevel = PropertyDictionary:get_level(hero:getPT())			
			local questId = questObj:getQuestId()
			local isAchieveLevel = G_getQuestLogicMgr():IsAchieveLevel(questId)
			if isAchieveLevel then
				--questMgr:setNpcTalkViewInfo(npcObjRefId,questObj)
				local arglist = {npcRefId=npcObjRefId,questObj=questObj}
				GlobalEventSystem:Fire(GameEvent.EVENT_NpcQuest_UI,arglist)
			else
				UIManager.Instance:showSystemTips(Config.Words[3125])
			end
			
			return true			
		end
	end		
	return false
end

function NpcUIHandler:handleNpcClick()
	local eventOpenNpcView = function(npcTpye, serverId)
		if npcTpye == EntityType.EntityType_NPC then	--点击NPC
			local npcObj =  GameWorld.Instance:getEntityManager():getEntityObject(npcTpye, serverId)
			local npcMgr = GameWorld.Instance:getNpcManager()				
			local npcObjRefId = npcObj:getRefId()
			npcMgr:saveTouchNpcRefId(npcObjRefId)
			
			if self:isHaveQuest(npcObjRefId) then	--判断是否存在任务		
				
			elseif self:isCollectNpc(npcObjRefId) then					--如果是采集npc，需要尝试采集
				local mgr = GameWorld.Instance:getNpcManager()
				if mgr:isCollecting() then
					if mgr:getCollectInfo().serverId ~= serverId then	
						mgr:cancelCollect()
						mgr:collect(serverId)
					end
				else
					mgr:collect(serverId)
				end
			else
				--打开NPC对话框
				self:openNpcTalkView(npcObjRefId)
				if npcObjRefId == "npc_14" then
					--if npcObj:hadArrow() then
						GameWorld.Instance:getNewGuidelinesMgr():doNewGuidelinesNpcTalk()
						npcObj:hideArrow()
					--end
				end						
			end	
		end
	end
	GlobalEventSystem:Bind(GameEvent.EVENT_ENTITY_TOUCH_OBJECT,eventOpenNpcView)
end

function NpcUIHandler:isCollectNpc(refId)
	
	return GameData.Collect[refId] ~= nil
end

--打开NPC对话框
function NpcUIHandler:openNpcTalkView(npcObjRefId)
--	npcObjRefId = "npc_10"
	
	local manager =UIManager.Instance
	local questMgr = GameWorld.Instance:getEntityManager():getHero():getQuestMgr()
	if  string.find(npcObjRefId,"npc_collect") ~= nil  then	
		
	elseif "npc_10" == npcObjRefId then		--王城争霸管理员特殊处理

		manager:registerUI("NpcCastleWarView",	NpcCastleWarView.New)
		UIManager.Instance:showUI("NpcCastleWarView", E_ShowOption.eLeft, npcObjRefId)
	elseif "npc_14" == npcObjRefId then		--镇魔塔使者特殊处理
		manager:registerUI("NpcInstanceView",	NpcInstanceView.New)
		UIManager.Instance:showUI("NpcInstanceView", E_ShowOption.eLeft, npcObjRefId)
	else
		questMgr:setNpcTalkViewInfo(npcObjRefId,nil)
		
		local record = G_GetRecordByRefId(npcObjRefId)
		local npcType = G_GetNpcJobTypeByRefId(npcObjRefId)				
		
		if(npcType==1)then
			--传送NPC
			GlobalEventSystem:Fire(GameEvent.EventOpenTransfer)							
		elseif(npcType==2)then	
			--功能链接
			local linkIndex = G_GetNpcFunctionType(npcObjRefId) --功能链接
			GlobalEventSystem:Fire(LinkList[linkIndex],npcObjRefId)
		elseif(npcType==3)then	
			--商店	
			local shopList = G_GetNpcShopList(npcObjRefId)	
			if table.size(shopList) == 1 then
				for k,v in pairs(G_GetNpcShopList(npcObjRefId))	do			
					shopId = v.shopID
				end
				GlobalEventSystem:Fire(GameEvent.EventOpenShop,shopId)	
			else
				GlobalEventSystem:Fire(GameEvent.EVENT_NpcTalk_UI,npcObjRefId)			
			end								
		elseif(npcType==4)then

		elseif(npcType==5)then
			--打开界面
			if GameData.Npc[npcObjRefId] and GameData.Npc[npcObjRefId].job then
				local viewName = GameData.Npc[npcObjRefId].job[1].viewName
				if viewName == "MountView" then
					if GameWorld.Instance:getMountManager():isMountSystemOpen() then
						GlobalEventSystem:Fire(GameEvent.EventMountWindowOpen)	
					else
						showMsgBox(Config.Words[25901],E_MSG_BT_ID.ID_OK)	
					end
				elseif viewName == "WindView" then 
					local wingRefId = G_getHero():getWingMgr():getWingRefId()
					if wingRefId then
						GlobalEventSystem:Fire(GameEvent.EventOpenWingView)		
					else
						showMsgBox(Config.Words[25903],E_MSG_BT_ID.ID_OK)	
					end
				end
			end
		elseif(npcType==6)then
			--仓库
		elseif(npcType==7)then
			--转职
		elseif(npcType==8)then	
			--结婚
		elseif(npcType==9)then
			--护送	
		else
			GlobalEventSystem:Fire(GameEvent.EVENT_NpcTalk_UI,npcObjRefId)
		end
	end
end

