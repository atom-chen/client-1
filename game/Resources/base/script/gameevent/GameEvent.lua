--全局的GameEvent的定义,用于EventSystem的Bind和UnBind


GameEvent = {
EventErrorCode = "EventErrorCode",
EventUpdateHeroActiveState = "EventUpdateHeroActiveState",
EventClearHeroActiveState = "EventClearHeroActiveState",
EventSceneChanged = "EventSceneChanged",	 --场景切换事件
EventMonsterAdded = "EventMonsterAdded",
EventEntityAdded = "EventEntityAdded",
EventEntityRemoved = "EventEntityRemoved",
EventHeroProChanged = "EventHeroProChanged",
EventHeroAngleChanged = "EventHeroAngleChanged",
EventHeroProMerged = "EventHeroProMerged",	
EventHeroEnterIdle = "EventHeroEnterIdle",
EventPlayerHeadUpdate = "EventPlayerHeadUpdate",
EventOtherPlayerProChanged = "EventOtherPlayerProChanged",
EventHeroLevelChanged = "EventHeroLevelChanged",
EVENT_LOGIN_UI = "EVENT_LOGIN_UI",
EVENT_SELECT_ROLE_UI = "EVENT_SELECT_ROLE_UI",
EVENT_CREATE_ROLE_UI = "EVENT_CREATE_ROLE_UI",
EVENT_REGISTERACCOUNT_UI = "EVENT_REGISTERACCOUNT_UI",
EVENT_ACCOUNTSECURITY_UI = "EVENT_ACCOUNTSECURITY_UI",
EVENT_SELECTALLSERVER_UI = "EVENT_SELECTALLSERVER_UI",
EVENT_Bag_UI = "EVENT_Bag_UI",
EVENT_Quest_UI ="EVENT_Quest_UI",
EVENT_NpcQuest_UI = "EVENT_NpcQuest_UI",
EVENT_NpcTalk_UI = "EVENT_NpcTalk_UI",
EVENT_MAIN_UI = "EVENT_MAIN_UI",
EVENT_HERO_STOP = "EVENT_HERO_STOP",
EventOpenRoleView= "EventOpenRoleView",
EventHideRoleView= "EventHideRoleView",
EVENT_ENTITY_TOUCH_OBJECT = "EVENT_ENTITY_TOUCH_OBJECT", -- entity type. entity id
Event_Entity_Get_Focus = "Event_Entity_Get_Focus",
Event_Entity_Lost_Focus = "Event_Entity_Lost_Focus",
EVENT_Main_Quest_UI = "EVENT_Main_Quest_UI",
EVENT_OpenDetailProperty = "EVENT_OpenDetailProperty",
EVENT_HideDetailProperty = "EVENT_HideDetailProperty",
EVENT_OpenMyDetailProperty = "EVENT_OpenMyDetailProperty",
EVENT_HideMyDetailProperty = "EVENT_HideMyDetailProperty",
EVENT_OpenHisDetailProperty = "EVENT_OpenHisDetailProperty",
EVENT_HideHisDetailProperty = "EVENT_HideHisDetailProperty",
EventHideAllUI = "EventHideAllUI",
EVENT_Main_StrengthenQuest_UI = "EVENT_Main_StrengthenQuest_UI",
EventTipsInsert = "EventTipsInsert",
EventSystemTipsUpdate = "EventSystemTipsUpdate",
EventNearByPlayerStateChange = "EventNearByPlayerStateChange",
--登陆
EventSaveUserNameAndPwd = "EventSaveUserNameAndPwd",
EventBridgeAuth = "EventBridgeAuth", -- 桥接认证
EventShowGetServerListHUD = "EventShowGetServerListHUD",
EventGetServerListState = "EventGetServerListState",
EventShowReConnectView = "EventShowReConnectView",
--选服事件
EventSelectServer = "EventSelectServer",
EventSaveLastTimeServer = "EventSaveLastTimeServer",
EventUpdateLastTimeServer = "EventUpdateLastTimeServer", 
EventUpdateHeroName = "EventUpdateHeroName",
--游戏初始化事件
EventGameInit = "EventGameInit",

--游戏资源更新事件
EventResoursesUpdate = "EventResoursesUpdate",

--主角在场景的事件
EventHeroEnterGame = "EventHeroEnterGame",
EventHeroLeaveGame = "EventHeroLeaveGame",
EventHeroEnterMap = "EventHeroEnterMap",
EventHeroLeaveMap = "EventHeroLeaveMap",
EventHeroStartMove = "EventHeroStartMove",
EventHeroMovement = "EventHeroMovement",
EventHeroMoveEnd = "EventHeroMoveEnd",
EventHeroSynPosition = "EventHeroSynPosition",
EventHeroSpeedUpdate= "EventHeroSpeedUpdate",
EventHeroHpChange = "EventHeroHpChange",
EventHeroMpChange = "EventHeroMpChange",
--GameInstance------
EventLeaveButtonStateChange = "EventLeaveButtonStateChange",
EventGameInstanceViewOpen = "EventGameInstanceViewOpen",
EventGameInstanceViewUpdate = "EventGameInstanceViewUpdate",
EventGameInstanceQuestViewOpen = "EventGameInstanceQuestViewOpen",
EventGameInstanceTitleRefresh = "EventGameInstanceTitleRefresh",
EventSetInstanceBtnVisible = "EventSetInstanceBtnVisible",
EventSetInstanceBtnAniamtion = "EventSetInstanceBtnAniamtion",
EventUpdateSceneMapViewTeammatePosition = "EventUpdateSceneMapViewTeammatePosition",
--SmallMap 
EventSmallMapOpen = "EventSmallMapOpen",
EventSmallMapNeedToUpdate = "EventSmallMapNeedToUpdate",
EventGameSceneReady = "EventGameSceneReady",
EventClearMovePath = "EventClearMovePath",
EventReleaseMap = "EventReleaseMap",
EventHideSmallMapView = "EventHideSmallMapView",
EventOpenWorldMapTipsView = "EventOpenWorldMapTipsView",
EventCloseWorldMapTipsView = "EventCloseWorldMapTipsView",
EventRemoveTeammate = "EventRemoveTeammate",
EventRemoveAllTeamate = "EventRemoveAllTeamate",
EventAddTeammate = "EventAddTeammate",
--EventClickMountButtonCallBack = "EventClickMountButtonCallBack",
-- Bag Event Start========================================
EventHideBag = "EventHideBag",
EventHideNormalItemDetailView= "EventHideNormalItemDetailView",
EventHideGiftItemDetailView= "EventHideGiftItemDetailView",
EventHideEquipItemDetailView= "EventHideEquipItemDetailView",
EventHidePutOnEquipItemDetailView= "EventHidePutOnEquipItemDetailView",

EventItemUpdate			= "EventItemUpdate",		
EventItemList			= "EventItemList",
EventBagCapacity		= "EventBagCapacity",
EventItemUnLockRemain	= "EventItemUnLockRemain", 
EventOpenEquipItemDetailView = "EventOpenEquipItemDetailView",
EventOpenPutOnEquipItemDetailView = "EventOpenPutOnEquipItemDetailView",
EventOpenNormalItemDetailView = "EventOpenNormalItemDetailView",
EventOpenGiftItemDetailView = "EventOpenGiftItemDetailView",
EventOpenBag			= "EventOpenBag",
EventShowItemInfo = "EventShowItemInfo",
EventOpenBatchSellView = "EventOpenBatchSellView",
EventHideBatchSellView = "EventHideBatchSellView",
EventOpenEquipDetailPropertyView = "EventOpenEquipDetailPropertyView",
EventCloseEquipDetailPropertyView = "EventCloseEquipDetailPropertyView",
-- Bag Event End========================================

--tips--
EventShowNextTipsNow = "EventShowNextTipsNow",
EventPickLootItem = "EventPickLootItem",
-------
-- Equip Event Start========================================
EventEquipList			= "EventEquipList",
EventEquipUpdate		= "EventEquipUpdate",
EventOtherPlayerEquipList = "EventOtherPlayerEquipList",
-- Equip Event End========================================
----资源更新
EventCloseInit = "EventCloseInit",
--------------------登录选择角色------------------------
EventRemoveRoleBtn	= "EventRemoveRoleBtn",
EventDeleteRole 	= "EventDeleteRole",
EventCreateRole  	= "EventCreateRole",
--------------------主界面------------------------
EventMoveMianView = "EventMoveMianView",
EventMainViewCreated = "EventMainViewCreated",

EventMainQuestUpdate = "EventMainQuestUpdate",--更新任务
EventMainHeroPorpertyUpdate = "EventMainHeroPorpertyUpdate",--更新人物属性
EventMainBOSSPorpertyUpdate = "EventMainBOSSPorpertyUpdate",--更新人物属性
EventMainSetQuestBtnEnable = "EventMainSetQuestBtnEnable",--设置任务按钮禁用状态
EventMainSetMenuBtnStatus = "EventMainSetMenuBtnStatus",--设置菜单按钮禁用、启用状态
EventMainSetAllMenuBtnStatus = "EventMainSetAllMenuBtnStatus",--设置所有菜单按钮禁用、启用状态
EventMainViewClick = "EventMainViewClick",   --主界面的点击事件 add by yejunhua
EventReviveViewShow = "EventReviveViewShow",	-- 显示复活界面
EventReviveViewOpen = "EventReviveViewOpen", 	-- 打开复活界面
EventSetSystemOpenStatus = "EventSetSystemOpenStatus",--设置菜单功能是否开启
EventOpenRideControl = "EventOpenRideControl", --启用坐骑控件
EventMainIsShowBossView = "EventMainIsShowBossView",--显示Boss血条
EventChangeStateBtn = "EventChangeStateBtn",	--改变人物pk按钮状态
EventOpenActivityManageView = "EventOpenActivityManageView",
EventOpenNearByView = "EventOpenNearByView",
EventCloseNearByView = "EventCloseNearByView",
EventEnterAutoFightView = "EventEnterAutoFightView",
EventHeroUnusualRevieve = "EventHeroUnusualRevieve",-- 处理非法复活请求
EventShowPKHitView = "EventShowPKHitView",
--------------------技能事件------------------------
EventOpenSkillView = "EventOpenSkillView",
EventRefreshView = "EventRefreshView",
EventUpdateQuickSkillViewSuccess = "EventUpdateQuickSkillViewSuccess", 
EventShowSkillDetailInfo = "EventShowSkillDetailInfo",
EventUpdateSwitchSkill = "EventUpdateSwitchSkill",
EventShowQuickView = "EventShowQuickView",
EventNewSkillLearned = "EventNewSkillLearned",
EventAutoUseSkillCDReady = "EventSkillCDReady",
EventRefeshSkillCD = "EventRefeshSkillCD",
EventUpdateExtendSkillRefId = "EventUpdateExtendSkillRefId",
EventRemoveCdSprite = "EventRemoveCdSprite",   --移除主界面的cd转圈
---------------------------------------------------------

----------------------------聊天-----------------------------
EventOpenChatView = "EventOpenChatView",
EventUpdateChatView = "EventUpdateChatView",
EventUpdateMainChatView = "EventUpdateMainChatView",
EventPeerIdNotExit = "EventPeerIdNotExit",
EventShowItem = "EventShowItem",
EventReadyWhisper = "EventReadyWhisper",
EventWhisperChat = "EventWhisperChat",
EventShowItemEquip = "EventShowItemEquip",
EventShowMarquee = "EventShowMarquee",
EventCloseMarquee = "EventCloseMarquee",
EventChangeChatObject = "EventChangeChatObject",
EventSendGmMailSucc = "EventSendGmMailSucc",
EventResetMessage = "EventResetMessage",
EventUpdateWhisperView = "EventUpdateWhisperView",  --更新私聊界面
EventFreshPlayerOnline = "EventFreshPlayerOnline",
-----------------------------法宝----------------------------
EventTalismanViewOpen = "EventTalismanViewOpen",
EventUpdateTilismanView = "EventUpdateTilismanView",
EventRetTilismanView = "EventRetTilismanView",
---------------------------------------商城--------------------------
EventOpenMallView = "EventOpenMallView",
EventCloseMallView = "EventCloseMallView",
EventPageInfoUpdate	= "EventPageInfoUpdate",
EventPageItemUpdate = "EventPageItemUpdate",
EventReponseItemList = "EventReponseItemList",
EventPanicInfoUpdate = "EventPanicInfoUpdate",
EventReponsePageInfo = "EventReponsePageInfo",
EventUpdateMall =  "EventUpdateMall",
EventUpdateCell = "EventUpdateCell",
EventBuyItem = "EventBuyItem",
EventBuyReult = "EventBuyReult",
--------------------------商店------------------------------------------
EventOpenShop = "EventOpenShop",
EventOpenTransfer = "EventOpenTransfer",
EventUpdateShopCell = "EventUpdateShopCell",
EventUpdateShop = "EventUpdateShop",
EventBuyItemSucess = "EventBuyItemSucess",
------------------------礼包兑换码--------------------------
EventOpenExchangeCodeView = "EventOpenExchangeCodeView",
EventResetEditeBox = "EventResetEditeBox",
-----------------公会-------------------------------
EventOpenFactionApplyView = "EventOpenFactionApplyView",
EventOpenCreateView = "EventOpenCreateView",
EventOpenInfoView = "EventOpenInfoView",
EventOpenPlayerInfoView = "EventOpenPlayerInfoView",
EventOpenApplyInfoView = "EventOpenApplyInfoView",
EventOpenListView = "EventOpenListView",
EventRefreshApplyBtn = "EventRefreshApplyBtn",
EventRefreshCancelBtn = "EventRefreshCancelBtn",
EventOfficeChanged = "EventOfficeChanged",
EventRefreshApplyList = "EventRefreshApplyList",
EventClosePlayerInfoView = "EventClosePlayerInfoView",
EventRefreshApplyTableView = "EventRefreshApplyTableView",
EventRefreshInfoTableView = "EventRefreshInfoTableView",
EventRefreshMemberList = "EventRefreshMemberList",
EventOpenFactionInviteView = "EventOpenFactionInviteView",--公会邀请
EventFactionInviteReply = "EventFactionInviteReply",
EventReplyJoinFaction = "EventReplyJoinFaction",
EventupdateFactionInviteView = "EventupdateFactionInviteView",
EventMemberUpdate = "EventMemberUpdate",
EventOfficeUpdate = "EventOfficeUpdate",
------------------坐骑-------------------------------
EventMountWindowOpen = "EventMountWindowOpen",
EventMountUpdate = "EventMountUpdate",
EventMountBaoJi = "EventMountBaoJi",
EventStopMountAnimation = "EventStopMountAnimation",
EventSwitchMountState = "EventSwitchMountState",
EventIsOnMount = "EventIsOnMount",
-----------------debug-------------------------------
EventOpenDebugView = "EventOpenDebugView",
EventRefreshDebugView = "EventRefreshDebugView",

-----------------锻造-------------------------------
EventStrengthenRet = "EventStrengthenRet",
EventOpenForgingView = "EventOpenForgingView",
EventDecomposeRet = "EventDecomposeRet",
EventOpenEquipShowView = "EventOpenEquipShowView",
EventOpenPutInEquipView = "EventPutInEquipView",
EventOpenStrengthenScrollPreview = "EventOpenStrengthenScrollPreview",
EventHideEquipShowView = "EventHideEquipShowView",
EventHidePutInEquipView = "EventHidePutInEquipView",
EventHideStrengthenScrollPreview = "EventHideStrengthenScrollPreview",
EventHideAllScrollStrengthenView = "EventHideAllScrollStrengthenView",
EventForgeSystemOpen = "EventForgeSystemOpen",
-----------------爵位-------------------------------
EventOpenKnightView = "EventOpenKnightView",
EventRefreshKnightInfo = "EventRefreshKnightInfo",
EventSalaryGot = "EventSalaryGot",
EventRewardReset = "EventRewardReset",
-----------------成就-------------------------------
EventOpenAchieveView = "EventOpenAchieveView",
EventOpenExchangeView = "EventOpenExchangeView",
EventRefreshNovice = "EventRefreshNovice",
EventRefreshKillSubs = "EventRefreshKillSubs",
EventRefreshKillBoss = "EventRefreshKillBoss",
EventRefreshMountUp = "EventRefreshMountUp",
EventRefreshKnightUp = "EventRefreshKnightUp",
EventRefreshHeartUp = "EventRefreshHeartUp",
EventRefreshGetMedal = "EventRefreshGetMedal",
EventCompletedListSet = "EventCompletedListSet",
EventRefreshCompleted = "EventRefreshCompleted",
EventOpenBtn = "EventOpenBtn",
EventCloseBtn = "EventCloseBtn",
EventSetSelIndex = "EventSetSelIndex",
EventRefreshBtn = "EventRefreshBtn",
EventCheckNewImage = "EventCheckNewImage",
EventCheckNewReward = "EventCheckNewReward",
EventResetButtonState = "EventResetButtonState",
EventSetButtonVisible = "EventSetButtonVisible",
-----------------翅膀-------------------------------
EventOpenWingView = "EventOpenWingView",
EventGetNowWing = "EventGetNowWing",
EventUpdateWing = "EventUpdateWing",
EventWingBaoJi = "EventWingBaoJi",
EventWingUpGrade = "EventWingUpGrade",
EventReturnNowWing = "EventReturnNowWing",
EventUpdateGetWingBtn = "EventUpdateGetWingBtn",
EventOpenSubWingView = "EventOpenSubWingView",
-------------------任务------------------------------
EventUpdateQuestLevel = "EventUpdateQuestLevel",
EventUpdateNPCQuestLevel = "EventUpdateNPCQuestLevel",
EventQuestUpMount = "EventQuestUpMount",
EventCloseQuestView = "EventCloseQuestView",
EventSetQuestVisible = "EventSetQuestVisible",
Event_SetFinishInstanceArrow = "Event_SetFinishInstanceArrow",
-----------------邮件-------------------------------
EventOpenMailView = "EventOpenMailView",
EventMailPickupSuccess = "EventMailPickupSuccess",
EventMailRead = "EventMailRead",
EventAddMial = "EventAddMial",
EventMailBtnIsShow = "EventMailBtnIsShow",
EventReturnMailView = "EventReturnMailView",
EventOpenMailContentView = "EventOpenMailContentView",

--挂机
EventHandupStateChanged = "EventHandupStateChanged",	--打开或关闭挂机，后面带有参数true/false
EventHandupConfigChanged = "EventHandupConfigChanged",
EventHeroMoveException = "EventHeroMoveException",

--测试
EventTestSkill = "EventTestSkill",

EventPatch = "EventPatch",--发送一个patch路径list
------------------NPC--------------------------------
EventStartCollect = "EventStartCollect",
EventInteruptCollect = "EventInteruptCollect",
EventEndCollect = "EventEndCollect",
EventUpdateNpcInstanceView = "EventUpdateNpcInstanceView",

-----------------buff-------------------
EventRefreshBuff = "EventRefreshBuff",
EventMoXueShiAmount = "EventMoXueShiAmount",
----------------buff 效果-------------------
EventBuffEffect = "EventBuffEffect",
EventAddBuffEffect2Player = "EventAddBuffEffect2Player",
EventDeleteEffect = "EventDeleteEffect",

--FightTargetMgr
EventBeAttacked	    = "EventBeAttacked",		--受到攻击，带有两个参数：obj攻击者对象，isNew 攻击者是否是新的
EventAttackerRemoved = "EventAttackerRemoved",

--SettingView
EventHideSettingView = "EventHideSettingView",
EventShowSettingView = "EventShowSettingView",
EventOptionConfigChanged = "EventOptionConfigChanged",
EventPickUpConfigChanged = "EventPickUpConfigChanged",
EventBackToSelectRoleView = "EventBackToSelectRoleView",

-----------------玩家交互-------------------------------
EventOpenPlayerInteractionView = "EventOpenPlayerInteractionView",
EventClosePlayerInteractionView = "EventClosePlayerInteractionView",
EventShowPlayerHead = "EventShowPlayerHead",
EventShowInteractionByTag = "EventShowInteractionByTag",	--玩家交互消息
EventShowPKGuidView = "EventShowPKGuidView",
EventHideInteractionView = "EventHideInteractionView",
-------------------组队-------------------------------
EventPlayerTeamStatus = "EventPlayerTeamStatus",
EventJoinTeamReturn = "EventJoinTeamReturn",
EventOpenTeamInviteView = "EventOpenTeamInviteView",
EventReplyJoinTeam = "EventReplyJoinTeam",
EventTeamAction = "EventTeamAction",
EventHandoverTeamAction = "EventHandoverTeamAction",
EventTeamLeaderQuitTeamAction = "EventTeamLeaderQuitTeamAction",
EventDisbandTeamAction = "EventDisbandTeamAction",
EventTeamLeaderKickedOutAction = "EventTeamLeaderKickedOutAction",
EventCreateTeam = "EventCreateTeam",
EventCreateTeamSuccess = "EventCreateTeamSuccess",
EventRequestJoinTeamReturn = "EventRequestJoinTeamReturn",
EventModifyTeamReturn = "EventModifyTeamReturn",
EventUpdateTeamListView = "EventUpdateTeamListView",
-------------------新手指引-------------------------------
EventOpenWelcomeView = "EventOpenWelcomeView",
EventOnEnterView = "EventOnEnterView",
EventOnExitView = "EventOnExitView",
EventDoNewGuidelinesByIndex = "EventDoNewGuidelinesByIndex",
EventDoNewGuidelinesByCilck = "EventDoNewGuidelinesByCilck",
EventHideArrow = "EventHideArrow",
-------------------7天签到奖励-------------------------------
EventOpenSevenLoginView = "EventOpenSevenLoginView",
EventFreshSevenLoginView = "EventFreshSevenLoginView",
EventUpdateOnlineTime = "EventUpdateOnlineTime",
EventUpdateDailyOnlineTime = "EventUpdateDailyOnlineTime",
EventResetDailyOnlineTime = "EventResetDailyOnlineTime",
EventReceiveAward = "EventReceiveAward",
EventUpdateAwardItemView = "EventUpdateAwardItemView",
EventPopupSevenLoginView = "EventPopupSevenLoginView",
EventChangeSevenLoginIcon = "EventChangeSevenLoginIcon",

-------------------挖宝--------------------------------------
EventDigTreasureViewOpen = "EventDigTreasureViewOpen",
EventDigTreasureResult = "EventDigTreasureResult",
EventShowDigWareHouse = "EventShowDigWareHouse",
EventHouseUpdate = "EventHouseUpdate",
EventShowDigAwardList = "EventShowDigAwardList",
EventGiftCardUpdate = "EventGiftCardUpdate",
EventClearAllHouseItem = "EventClearAllHouseItem",
-------------------弹出按钮----------------------------
EventSetFactionInviteBtnStatus = "EventSetFactionInviteBtnStatus",
EventSetTeamInviteBtnStatus = "EventSetTeamInviteBtnStatus",
---------------------Vip--------------------------------
EventVipViewOpen = "EventVipViewOpen",
EventVipAwardViewOpen = "EventVipAwardViewOpen",
UpdateAwardItem = "UpdateAwardItem",
EventUpdateVipAwardView = "EventUpdateVipAwardView",
EventVipLevelChanged = "EventVipLevelChanged",
EventShowVipEffect = "EventShowVipEffect",
EventUpdateActivityTipsView = "EventUpdateActivityTipsView",
---------------------签到--------------------------------
EventSignViewOpen = "EventSignViewOpen",
EventSignViewUpdate = "EventSignViewUpdate",
EventSignViewSign = "EventSignViewSign",
EventSignViewAwardUpdate = "EventSignViewAwardUpdate",
-------------------排行榜----------------------------
EventRequestVersionNum = "EventRequestVersionNum",
EventRequestNameList = "EventRequestNameList",
EventOpenRankListView = "EventOpenRankListView",
EventUpdateRankListView = "EventUpdateRankListView",
EventRequestOtherPeopleDetailInfo = "EventRequestOtherPeopleDetailInfo",
EventRequestOtherPeopleInfo = "EventRequestOtherPeopleInfo",
-------------------Vip抽奖----------------------------
EventVipLuckDrawOpen = "EventVipLuckDrawOpen",
EventShowVipMarquee = "EventShowVipMarquee",
EventVipLuckRefresh = "EventVipLuckRefresh",
EventVipLuckDrawOpenFailed = "EventVipLuckDrawOpenFailed",
--------------------RTW View---------------------------
EventRTWAwardViewUpdate = "EventRTWAwardViewUpdate",
EventGetAwardSuccess = "EventGetAwardSuccess",
EventShowVipReward = "EventShowVipReward",
EventOpenRTWLevelAwardView = "EventOpenRTWLevelAwardView", 
EventGetQuickUpLevelAwardSuccess = "EventGetQuickUpLevelAwardSuccess",
EventUpdateQuickUpLevelView = "EventUpdateQuickUpLevelView",
--------------------限时冲榜--------------------------
EventUpdateLimitRankNode = "EventUpdateLimitRankNode",
EventLimitRankNodeUpdate = "EventLimitRankNodeUpdate",
EventGetLimitRankAwardSuccess = "EventGetLimitRankAwardSuccess",
EventOpenQuickUpLevelView = "EventOpenQuickUpLevelView",
-------------------设置------------------------------
EventPickUpConfigChange = "EventPickUpConfigChange",

------------------充值礼包--------------------------
EventOpenPayGiftBag = "EventOpenPayGiftBag",
EventUpdateOpenPayGiftBag = "EventUpdateOpenPayGiftBag",
EventShowEffectInPayButton = "EventShowEffectInPayButton",
EventReceivePayGiftBag = "EventReceivePayGiftBag",

------------------首充礼包--------------------------
EventOpenFirstPayGiftBag = "EventOpenFirstPayGiftBag",
EventUpdateFirstPayGiftBag = "EventUpdateFirstPayGiftBag",
EventHaveReceiveFirstPayGiftBag = "EventHaveReceiveFirstPayGiftBag",
EventShowEffectInFirstPayButton = "EventShowEffectInFirstPayButton",

------------------每日充值礼包---------------------------
EventOpenEveryDayPayBag = "EventOpenEveryDayPayBag",
EventUpdateEveryDayPayBag = "EventUpdateEveryDayPayBag",
EventShowEffectInEveryDayPayButton = "EventShowEffectInEveryDayPayButton",
EventReceiveEveryDayPayBag = "EventReceiveEveryDayPayBag",

------------------每周消费奖励--------------------------
EventOpenEveryWeekPayGiftBag = "EventOpenEveryWeekPayGiftBag",
EventUpdateEveryWeekPayGiftBag = "EventUpdateEveryWeekPayGiftBag",
EventShowEffectInEveryWeekConsumeButton = "EventShowEffectInEveryWeekConsumeButton",
EventReceiveEveryWeekPayGiftBag = "EventReceiveEveryWeekPayGiftBag",

--------------------公会副本----------------------------
EventOpenUnionInstanceView = "EventOpenUnionInstanceView",
EventEnterUnionInstance = "EventEnterUnionInstance",
EventExitUnionInstance = "EventExitUnionInstance",
EventSetUnionInstanceVisible = "EventSetUnionInstanceVisible",
EventUpdateUnionInstanceView = "EventUpdateUnionInstanceView",

--------------------充值-------------------------------
EventOpenRechargeView = "EventOpenRechargeView",
EventUpdateRechargeView= "EventUpdateRechargeView",
-------------------天梯排名---------------------------
EventRequireCanReceive = "EventRequireCanReceive",
EventHandleCanReceive = "EventHandleCanReceive",
EventOpenArenaView = "EventOpenArenaView",
EventShowArenaView = "EventShowArenaView",
EventOpenLadderView = "EventOpenLadderView",
EventShowLadderView = "EventShowLadderView",
EventUpdateHeroInfoArea = "EventUpdateHeroInfoArea",
EventUpdatePrizeArea = "EventUpdatePrizeArea",
EventUpdateNoticeBoardArea = "EventUpdateNoticeBoardArea",
EventUpdateChallengeTargetArea = "EventUpdateChallengeTargetArea",
EventUpdateFightingRecordArea = "EventUpdateFightingRecordArea",
EventUpdateReceiveRewardTime = "EventUpdateReceiveRewardTime",
EventUpdateChallengeCDTime = "EventUpdateChallengeCDTime",
EventDownload = "EventDownload",--发送一个url和MD5的list
EventReceiveReward = "EventReceiveReward",
EventChallenge = "EventChallenge",
EventFighting = "EventFighting",
EventClearCDTime = "EventClearCDTime",
EventFightingOver = "EventFightingOver",
EventFightingResult = "EventFightingResult",
EventForceEndAreanAni = "EventForceEndAreanAni",

----------------------打折出售------------------------------
EventOpenDiscountSellView = "EventOpenDiscountSellView",
-----------------------挖矿-------------------------
EventLeaveActivityBtnState = "EventLeaveActivityBtnState",
EventSetMiningVisible = "EventSetMiningVisible",
EventRefreshMiningCount = "EventRefreshMiningCount",
EventStartTimer = "EventStartTimer",
EventStopTimer = "EventStopTimer",
EventRefreshNextMineralTime = "EventRefreshNextMineralTime",
---------------------遮天基金 --------------------------------
EventOpenFundView = "EventOpenFundView",
EventUpdateFundView = "EventUpdateFundView",
EventUpdateFundCell = "EventUpdateFundCell",
EventFundShowBuyBt = "EventFundShowBuyBt",

--------------------怪物入侵  活动--------------------
EventEnterMonstorInvasion = "EventEnterMonstorInvasion", 
EventExitMonstorInvasion = "EventExitMonstorInvasion",
EventBossRefreshTime = "EventBossRefreshTime",
EventUpdateHeroTitle = "EventUpdateHeroTitle",
EventChangeMonsterBtnState = "EventChangeMonsterBtnState",
---------------------世界BOSS组队活动--------------------
EventOpenWorldBossActivityView = "EventOpenWorldBossActivityView",
---------------------付费地宫-----------------------------
EventEnterBossTemple = "EventEnterBossTemple",
EventExitBossTemple = "EventExitBossTemple",
--沙巴克攻城
EventCastleWarStateChanged = "EventCastleWarStateChanged",
EventCastleWarFactionList = "EventCastleWarFactionList",
EventCastleWarBossUnionName = "EventCastleWarBossUnionName",

--离线背包
EventOpenOffLineBag = "EventOpenOffLineBag",
EventUpdateOffLineBag = "EventUpdateOffLineBag",
EventDrawOffLineAIReward = "EventDrawOffLineAIReward",
EventGetOffLineAIReward = "EventGetOffLineAIReward",
EventSetOffLineAI = "EventSetOffLineAI",

--怪物归属权
EventBossOwnerChange = "EventBossOwnerChange",

--分包下载
EventShowResDownloadView="EventShowResDownloadView",
EventShowResLogView="EventShowResLogView",

--世界boss
EventShowWorldBossView="EventShowWorldBossView",
EventUpdateWorldBossView="EventUpdateWorldBossView", 

--分包下载
EventSubPackageLoadViewOpen = "EventSubPackageLoadViewOpen",
EventCloseSubPackageView 	= "EventCloseSubPackageView",
EventActivityClick = "EventActivityClick",
EventSubPackageLoadViewUpdate = "EventSubPackageLoadViewUpdate",
EventSubPackageLoadViewReset = "EventSubPackageLoadViewReset",
EventChangeDownloadButtonState = "EventChangeDownloadButtonState",
EventSubPackageLoadViewSetList = "EventSubPackageLoadViewSetList",

EventOpenAuctionMenu = "EventOpenAuctionMenu",
EventOpenAuctionView = "EventOpenAuctionView",
EventAuctionBuyList = "EventAuctionBuyList",
EventAuctionBuyRet = "EventAuctionBuyRet",
EventAuctionSellList = "EventAuctionSellList",
EventAuctionSearchValueChanged = "EventAuctionSearchValueChanged",
EventAuctionDefaultPrice = "EventAuctionDefaultPrice",
EventAuctionBuyRet = "EventAuctionBuyRet",
EventOpenAuctionSell = "EventOpenAuctionSell", 
EventAuctionReSell = "EventAuctionReSell",

EventUpdatePing = "EventUpdatePing",

--仓库
EventOpenWarehouseView = "EventOpenWarehouseView",
EventCloseWarehouseView = "EventCloseWarehouseView",
EventUpdateWarehouseItem = "EventUpdateWarehouseItem",
EventUpdateWarehouseView = "EventUpdateWarehouseView",

--我要变强
EventOpenStrongerView = "EventOpenStrongerView",
EventCloseStrongerView = "EventCloseStrongerView",
EventShowStrongerOptionView = "EventShowStrongerOptionView",
--新手保护
EventPKProtection = "EventPKProtection",

-- 显示重连界面
EventReconnect = "EventReconnect",

--财神闯关
EventOpenWealthThroughView = "EventOpenWealthThroughView",
}