--全局的GameEvent的定义,用于EventSystem的Bind和UnBind


GameEvent = {
EventErrorCode = "EventErrorCode",
EVENT_LOGIN_UI = "EVENT_LOGIN_UI",
EVENT_SELECT_ROLE_UI = "EVENT_SELECT_ROLE_UI",
EVENT_CREATE_ROLE_UI = "EVENT_CREATE_ROLE_UI",
EVENT_REGISTERACCOUNT_UI = "EVENT_REGISTERACCOUNT_UI",
EVENT_ACCOUNTSECURITY_UI = "EVENT_ACCOUNTSECURITY_UI",
EVENT_SELECTALLSERVER_UI = "EVENT_SELECTALLSERVER_UI",
EventOpenRoleView= "EventOpenRoleView",
EventHideRoleView= "EventHideRoleView",
EventHideAllUI = "EventHideAllUI",

--登陆
EventSaveUserNameAndPwd = "EventSaveUserNameAndPwd",
EventBridgeAuth = "EventBridgeAuth", -- 桥接认证
EventShowGetServerListHUD = "EventShowGetServerListHUD",--获取服务器列表过渡界面
EventGetServerListState = "EventGetServerListState",
EventUpdateHeroName = "EventUpdateHeroName",
--选服事件
EventSelectServer = "EventSelectServer",
EventSaveLastTimeServer = "EventSaveLastTimeServer",
EventUpdateLastTimeServer = "EventUpdateLastTimeServer", 

--游戏资源更新事件
EventDownload = "EventDownload",
EventResoursesUpdate = "EventResoursesUpdate",
EventPatch = "EventPatch",

--tips--
EventShowNextTipsNow = "EventShowNextTipsNow",
EventTipsInsert = "EventTipsInsert",
EventPickLootItem = "EventPickLootItem",
EventSystemTipsUpdate = "EventSystemTipsUpdate",
EventPeerIdNotExit = "EventPeerIdNotExit",
EventUpdateQuickSkillViewSuccess = "EventUpdateQuickSkillViewSuccess", 
-- Equip Event End========================================
----资源更新
EventCloseInit = "EventCloseInit",
--------------------登录选择角色------------------------
EventRemoveRoleBtn	= "EventRemoveRoleBtn",
EventDeleteRole 	= "EventDeleteRole",
EventCreateRole  	= "EventCreateRole",

-- 英雄进入游戏和退出游戏场景
EventHeroEnterGame      = "EventHeroEnterGame",
EventHeroLeaveGame		= "EventHeroLeaveGame",

-- 显示重连界面
EventReconnect = "EventReconnect"
}