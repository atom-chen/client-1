--ȫ�ֵ�GameEvent�Ķ���,����EventSystem��Bind��UnBind


GameEvent = {
EventErrorCode = "EventErrorCode",
EventUpdateHeroActiveState = "EventUpdateHeroActiveState",
EventClearHeroActiveState = "EventClearHeroActiveState",
EventSceneChanged = "EventSceneChanged",	 --�����л��¼�
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
--��½
EventSaveUserNameAndPwd = "EventSaveUserNameAndPwd",
EventBridgeAuth = "EventBridgeAuth", -- �Ž���֤
EventShowGetServerListHUD = "EventShowGetServerListHUD",
EventGetServerListState = "EventGetServerListState",
EventShowReConnectView = "EventShowReConnectView",
--ѡ���¼�
EventSelectServer = "EventSelectServer",
EventSaveLastTimeServer = "EventSaveLastTimeServer",
EventUpdateLastTimeServer = "EventUpdateLastTimeServer", 
EventUpdateHeroName = "EventUpdateHeroName",
--��Ϸ��ʼ���¼�
EventGameInit = "EventGameInit",

--��Ϸ��Դ�����¼�
EventResoursesUpdate = "EventResoursesUpdate",

--�����ڳ������¼�
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
----��Դ����
EventCloseInit = "EventCloseInit",
--------------------��¼ѡ���ɫ------------------------
EventRemoveRoleBtn	= "EventRemoveRoleBtn",
EventDeleteRole 	= "EventDeleteRole",
EventCreateRole  	= "EventCreateRole",
--------------------������------------------------
EventMoveMianView = "EventMoveMianView",
EventMainViewCreated = "EventMainViewCreated",

EventMainQuestUpdate = "EventMainQuestUpdate",--��������
EventMainHeroPorpertyUpdate = "EventMainHeroPorpertyUpdate",--������������
EventMainBOSSPorpertyUpdate = "EventMainBOSSPorpertyUpdate",--������������
EventMainSetQuestBtnEnable = "EventMainSetQuestBtnEnable",--��������ť����״̬
EventMainSetMenuBtnStatus = "EventMainSetMenuBtnStatus",--���ò˵���ť���á�����״̬
EventMainSetAllMenuBtnStatus = "EventMainSetAllMenuBtnStatus",--�������в˵���ť���á�����״̬
EventMainViewClick = "EventMainViewClick",   --������ĵ���¼� add by yejunhua
EventReviveViewShow = "EventReviveViewShow",	-- ��ʾ�������
EventReviveViewOpen = "EventReviveViewOpen", 	-- �򿪸������
EventSetSystemOpenStatus = "EventSetSystemOpenStatus",--���ò˵������Ƿ���
EventOpenRideControl = "EventOpenRideControl", --��������ؼ�
EventMainIsShowBossView = "EventMainIsShowBossView",--��ʾBossѪ��
EventChangeStateBtn = "EventChangeStateBtn",	--�ı�����pk��ť״̬
EventOpenActivityManageView = "EventOpenActivityManageView",
EventOpenNearByView = "EventOpenNearByView",
EventCloseNearByView = "EventCloseNearByView",
EventEnterAutoFightView = "EventEnterAutoFightView",
EventHeroUnusualRevieve = "EventHeroUnusualRevieve",-- ����Ƿ���������
EventShowPKHitView = "EventShowPKHitView",
--------------------�����¼�------------------------
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
EventRemoveCdSprite = "EventRemoveCdSprite",   --�Ƴ��������cdתȦ
---------------------------------------------------------

----------------------------����-----------------------------
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
EventUpdateWhisperView = "EventUpdateWhisperView",  --����˽�Ľ���
EventFreshPlayerOnline = "EventFreshPlayerOnline",
-----------------------------����----------------------------
EventTalismanViewOpen = "EventTalismanViewOpen",
EventUpdateTilismanView = "EventUpdateTilismanView",
EventRetTilismanView = "EventRetTilismanView",
---------------------------------------�̳�--------------------------
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
--------------------------�̵�------------------------------------------
EventOpenShop = "EventOpenShop",
EventOpenTransfer = "EventOpenTransfer",
EventUpdateShopCell = "EventUpdateShopCell",
EventUpdateShop = "EventUpdateShop",
EventBuyItemSucess = "EventBuyItemSucess",
------------------------����һ���--------------------------
EventOpenExchangeCodeView = "EventOpenExchangeCodeView",
EventResetEditeBox = "EventResetEditeBox",
-----------------����-------------------------------
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
EventOpenFactionInviteView = "EventOpenFactionInviteView",--��������
EventFactionInviteReply = "EventFactionInviteReply",
EventReplyJoinFaction = "EventReplyJoinFaction",
EventupdateFactionInviteView = "EventupdateFactionInviteView",
EventMemberUpdate = "EventMemberUpdate",
EventOfficeUpdate = "EventOfficeUpdate",
------------------����-------------------------------
EventMountWindowOpen = "EventMountWindowOpen",
EventMountUpdate = "EventMountUpdate",
EventMountBaoJi = "EventMountBaoJi",
EventStopMountAnimation = "EventStopMountAnimation",
EventSwitchMountState = "EventSwitchMountState",
EventIsOnMount = "EventIsOnMount",
-----------------debug-------------------------------
EventOpenDebugView = "EventOpenDebugView",
EventRefreshDebugView = "EventRefreshDebugView",

-----------------����-------------------------------
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
-----------------��λ-------------------------------
EventOpenKnightView = "EventOpenKnightView",
EventRefreshKnightInfo = "EventRefreshKnightInfo",
EventSalaryGot = "EventSalaryGot",
EventRewardReset = "EventRewardReset",
-----------------�ɾ�-------------------------------
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
-----------------���-------------------------------
EventOpenWingView = "EventOpenWingView",
EventGetNowWing = "EventGetNowWing",
EventUpdateWing = "EventUpdateWing",
EventWingBaoJi = "EventWingBaoJi",
EventWingUpGrade = "EventWingUpGrade",
EventReturnNowWing = "EventReturnNowWing",
EventUpdateGetWingBtn = "EventUpdateGetWingBtn",
EventOpenSubWingView = "EventOpenSubWingView",
-------------------����------------------------------
EventUpdateQuestLevel = "EventUpdateQuestLevel",
EventUpdateNPCQuestLevel = "EventUpdateNPCQuestLevel",
EventQuestUpMount = "EventQuestUpMount",
EventCloseQuestView = "EventCloseQuestView",
EventSetQuestVisible = "EventSetQuestVisible",
Event_SetFinishInstanceArrow = "Event_SetFinishInstanceArrow",
-----------------�ʼ�-------------------------------
EventOpenMailView = "EventOpenMailView",
EventMailPickupSuccess = "EventMailPickupSuccess",
EventMailRead = "EventMailRead",
EventAddMial = "EventAddMial",
EventMailBtnIsShow = "EventMailBtnIsShow",
EventReturnMailView = "EventReturnMailView",
EventOpenMailContentView = "EventOpenMailContentView",

--�һ�
EventHandupStateChanged = "EventHandupStateChanged",	--�򿪻�رչһ���������в���true/false
EventHandupConfigChanged = "EventHandupConfigChanged",
EventHeroMoveException = "EventHeroMoveException",

--����
EventTestSkill = "EventTestSkill",

EventPatch = "EventPatch",--����һ��patch·��list
------------------NPC--------------------------------
EventStartCollect = "EventStartCollect",
EventInteruptCollect = "EventInteruptCollect",
EventEndCollect = "EventEndCollect",
EventUpdateNpcInstanceView = "EventUpdateNpcInstanceView",

-----------------buff-------------------
EventRefreshBuff = "EventRefreshBuff",
EventMoXueShiAmount = "EventMoXueShiAmount",
----------------buff Ч��-------------------
EventBuffEffect = "EventBuffEffect",
EventAddBuffEffect2Player = "EventAddBuffEffect2Player",
EventDeleteEffect = "EventDeleteEffect",

--FightTargetMgr
EventBeAttacked	    = "EventBeAttacked",		--�ܵ���������������������obj�����߶���isNew �������Ƿ����µ�
EventAttackerRemoved = "EventAttackerRemoved",

--SettingView
EventHideSettingView = "EventHideSettingView",
EventShowSettingView = "EventShowSettingView",
EventOptionConfigChanged = "EventOptionConfigChanged",
EventPickUpConfigChanged = "EventPickUpConfigChanged",
EventBackToSelectRoleView = "EventBackToSelectRoleView",

-----------------��ҽ���-------------------------------
EventOpenPlayerInteractionView = "EventOpenPlayerInteractionView",
EventClosePlayerInteractionView = "EventClosePlayerInteractionView",
EventShowPlayerHead = "EventShowPlayerHead",
EventShowInteractionByTag = "EventShowInteractionByTag",	--��ҽ�����Ϣ
EventShowPKGuidView = "EventShowPKGuidView",
EventHideInteractionView = "EventHideInteractionView",
-------------------���-------------------------------
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
-------------------����ָ��-------------------------------
EventOpenWelcomeView = "EventOpenWelcomeView",
EventOnEnterView = "EventOnEnterView",
EventOnExitView = "EventOnExitView",
EventDoNewGuidelinesByIndex = "EventDoNewGuidelinesByIndex",
EventDoNewGuidelinesByCilck = "EventDoNewGuidelinesByCilck",
EventHideArrow = "EventHideArrow",
-------------------7��ǩ������-------------------------------
EventOpenSevenLoginView = "EventOpenSevenLoginView",
EventFreshSevenLoginView = "EventFreshSevenLoginView",
EventUpdateOnlineTime = "EventUpdateOnlineTime",
EventUpdateDailyOnlineTime = "EventUpdateDailyOnlineTime",
EventResetDailyOnlineTime = "EventResetDailyOnlineTime",
EventReceiveAward = "EventReceiveAward",
EventUpdateAwardItemView = "EventUpdateAwardItemView",
EventPopupSevenLoginView = "EventPopupSevenLoginView",
EventChangeSevenLoginIcon = "EventChangeSevenLoginIcon",

-------------------�ڱ�--------------------------------------
EventDigTreasureViewOpen = "EventDigTreasureViewOpen",
EventDigTreasureResult = "EventDigTreasureResult",
EventShowDigWareHouse = "EventShowDigWareHouse",
EventHouseUpdate = "EventHouseUpdate",
EventShowDigAwardList = "EventShowDigAwardList",
EventGiftCardUpdate = "EventGiftCardUpdate",
EventClearAllHouseItem = "EventClearAllHouseItem",
-------------------������ť----------------------------
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
---------------------ǩ��--------------------------------
EventSignViewOpen = "EventSignViewOpen",
EventSignViewUpdate = "EventSignViewUpdate",
EventSignViewSign = "EventSignViewSign",
EventSignViewAwardUpdate = "EventSignViewAwardUpdate",
-------------------���а�----------------------------
EventRequestVersionNum = "EventRequestVersionNum",
EventRequestNameList = "EventRequestNameList",
EventOpenRankListView = "EventOpenRankListView",
EventUpdateRankListView = "EventUpdateRankListView",
EventRequestOtherPeopleDetailInfo = "EventRequestOtherPeopleDetailInfo",
EventRequestOtherPeopleInfo = "EventRequestOtherPeopleInfo",
-------------------Vip�齱----------------------------
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
--------------------��ʱ���--------------------------
EventUpdateLimitRankNode = "EventUpdateLimitRankNode",
EventLimitRankNodeUpdate = "EventLimitRankNodeUpdate",
EventGetLimitRankAwardSuccess = "EventGetLimitRankAwardSuccess",
EventOpenQuickUpLevelView = "EventOpenQuickUpLevelView",
-------------------����------------------------------
EventPickUpConfigChange = "EventPickUpConfigChange",

------------------��ֵ���--------------------------
EventOpenPayGiftBag = "EventOpenPayGiftBag",
EventUpdateOpenPayGiftBag = "EventUpdateOpenPayGiftBag",
EventShowEffectInPayButton = "EventShowEffectInPayButton",
EventReceivePayGiftBag = "EventReceivePayGiftBag",

------------------�׳����--------------------------
EventOpenFirstPayGiftBag = "EventOpenFirstPayGiftBag",
EventUpdateFirstPayGiftBag = "EventUpdateFirstPayGiftBag",
EventHaveReceiveFirstPayGiftBag = "EventHaveReceiveFirstPayGiftBag",
EventShowEffectInFirstPayButton = "EventShowEffectInFirstPayButton",

------------------ÿ�ճ�ֵ���---------------------------
EventOpenEveryDayPayBag = "EventOpenEveryDayPayBag",
EventUpdateEveryDayPayBag = "EventUpdateEveryDayPayBag",
EventShowEffectInEveryDayPayButton = "EventShowEffectInEveryDayPayButton",
EventReceiveEveryDayPayBag = "EventReceiveEveryDayPayBag",

------------------ÿ�����ѽ���--------------------------
EventOpenEveryWeekPayGiftBag = "EventOpenEveryWeekPayGiftBag",
EventUpdateEveryWeekPayGiftBag = "EventUpdateEveryWeekPayGiftBag",
EventShowEffectInEveryWeekConsumeButton = "EventShowEffectInEveryWeekConsumeButton",
EventReceiveEveryWeekPayGiftBag = "EventReceiveEveryWeekPayGiftBag",

--------------------���ḱ��----------------------------
EventOpenUnionInstanceView = "EventOpenUnionInstanceView",
EventEnterUnionInstance = "EventEnterUnionInstance",
EventExitUnionInstance = "EventExitUnionInstance",
EventSetUnionInstanceVisible = "EventSetUnionInstanceVisible",
EventUpdateUnionInstanceView = "EventUpdateUnionInstanceView",

--------------------��ֵ-------------------------------
EventOpenRechargeView = "EventOpenRechargeView",
EventUpdateRechargeView= "EventUpdateRechargeView",
-------------------��������---------------------------
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
EventDownload = "EventDownload",--����һ��url��MD5��list
EventReceiveReward = "EventReceiveReward",
EventChallenge = "EventChallenge",
EventFighting = "EventFighting",
EventClearCDTime = "EventClearCDTime",
EventFightingOver = "EventFightingOver",
EventFightingResult = "EventFightingResult",
EventForceEndAreanAni = "EventForceEndAreanAni",

----------------------���۳���------------------------------
EventOpenDiscountSellView = "EventOpenDiscountSellView",
-----------------------�ڿ�-------------------------
EventLeaveActivityBtnState = "EventLeaveActivityBtnState",
EventSetMiningVisible = "EventSetMiningVisible",
EventRefreshMiningCount = "EventRefreshMiningCount",
EventStartTimer = "EventStartTimer",
EventStopTimer = "EventStopTimer",
EventRefreshNextMineralTime = "EventRefreshNextMineralTime",
---------------------������� --------------------------------
EventOpenFundView = "EventOpenFundView",
EventUpdateFundView = "EventUpdateFundView",
EventUpdateFundCell = "EventUpdateFundCell",
EventFundShowBuyBt = "EventFundShowBuyBt",

--------------------��������  �--------------------
EventEnterMonstorInvasion = "EventEnterMonstorInvasion", 
EventExitMonstorInvasion = "EventExitMonstorInvasion",
EventBossRefreshTime = "EventBossRefreshTime",
EventUpdateHeroTitle = "EventUpdateHeroTitle",
EventChangeMonsterBtnState = "EventChangeMonsterBtnState",
---------------------����BOSS��ӻ--------------------
EventOpenWorldBossActivityView = "EventOpenWorldBossActivityView",
---------------------���ѵع�-----------------------------
EventEnterBossTemple = "EventEnterBossTemple",
EventExitBossTemple = "EventExitBossTemple",
--ɳ�Ϳ˹���
EventCastleWarStateChanged = "EventCastleWarStateChanged",
EventCastleWarFactionList = "EventCastleWarFactionList",
EventCastleWarBossUnionName = "EventCastleWarBossUnionName",

--���߱���
EventOpenOffLineBag = "EventOpenOffLineBag",
EventUpdateOffLineBag = "EventUpdateOffLineBag",
EventDrawOffLineAIReward = "EventDrawOffLineAIReward",
EventGetOffLineAIReward = "EventGetOffLineAIReward",
EventSetOffLineAI = "EventSetOffLineAI",

--�������Ȩ
EventBossOwnerChange = "EventBossOwnerChange",

--�ְ�����
EventShowResDownloadView="EventShowResDownloadView",
EventShowResLogView="EventShowResLogView",

--����boss
EventShowWorldBossView="EventShowWorldBossView",
EventUpdateWorldBossView="EventUpdateWorldBossView", 

--�ְ�����
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

--�ֿ�
EventOpenWarehouseView = "EventOpenWarehouseView",
EventCloseWarehouseView = "EventCloseWarehouseView",
EventUpdateWarehouseItem = "EventUpdateWarehouseItem",
EventUpdateWarehouseView = "EventUpdateWarehouseView",

--��Ҫ��ǿ
EventOpenStrongerView = "EventOpenStrongerView",
EventCloseStrongerView = "EventCloseStrongerView",
EventShowStrongerOptionView = "EventShowStrongerOptionView",
--���ֱ���
EventPKProtection = "EventPKProtection",

-- ��ʾ��������
EventReconnect = "EventReconnect",

--���񴳹�
EventOpenWealthThroughView = "EventOpenWealthThroughView",
}