User_Message_Begin 		= 100
User_Message_End 		= User_Message_Begin +49

Global_Message_Begin		= 150
Global_Message_End			= Global_Message_Begin + 49
 
Charactor_Message_Begin		= 200
Charactor_Message_End		= Charactor_Message_Begin+99

Scene_Message_Begin 		= 300
Scene_Message_End 			= Scene_Message_Begin + 99


SkillSystem_Message_Begin 	= 400
SkillSystem_Message_End 	= SkillSystem_Message_Begin +99

G2C_Player_Begin 		= 500
G2C_Player_End 			= G2C_Player_Begin + 99

QST_Message_Begin 		= 600				--任务系统的消息
QST_Message_End 		= QST_Message_Begin + 99

Chat_Message_Begin 		= 700			--聊天消息
Chat_Message_End 		= Chat_Message_Begin +99 

Bag_Message_Begin 		= 800				--物品消息开始
Bag_Message_End 		= Bag_Message_Begin + 99 

Equip_Message_Begin 	= 900			--装备消息
Equip_Message_End 		= Equip_Message_Begin + 99

Mount_Message_Begin 	= 1100			--坐骑消息
Mount_Message_End 		= Mount_Message_Begin + 99

Pluck_Message_Begin 	= 1300; 		--采集消息
Pluck_Message_End		= Pluck_Message_Begin + 99

Mail_Message_Begin      =1400			--邮件消息
Mail_Message_End 		= Mail_Message_Begin + 99

Buff_Message_Begin		= 1500         --buff消息
Buff_Message_End        = Buff_Message_Begin +99

Vip_Message_Begin		= 1700			--Vip
Vip_Message_End			= Vip_Message_Begin + 99

Sign_Message_Begin		=	1800
Sign_Message_End		=	Sign_Message_Begin + 99

Wing_Message_Begin = 2600			--翅膀消息
Wing_Message_End = Wing_Message_Begin +99

Knight_Message_Begin = 2300				--爵位消息
Knight_Message_End = Knight_Message_Begin + 99

Mall_Message_Begin 		= 1900			--商城消息
Mall_Message_End 		= Mall_Message_Begin+99;

Debug_Message_Begin 	= 2000;
Debug_Message_End 		= Debug_Message_Begin +99

Forge_Message_Begin 	= 2200
Forge_Message_End 		= Forge_Message_Begin + 99

Achievement_Message_Begin = 2400 
Achieve_Message_End = Achievement_Message_Begin+99

Game_Instance_Message_Begin = 2500  --副本消息起始

Talisman_Message_Begin	= 2700  --法宝消息起始值
Talisman_Message_End	= Talisman_Message_Begin + 99

Shop_Message_Begin		=		2800
Shop_Message_End		=		Shop_Message_Begin + 99

Union_Message_Begin 	= 		2900	--公会消息
Union_Message_End		=		Union_Message_Begin + 99
Pk_Message_Begin 		= 3000			--Pk消息
Pk_Message_End        = Pk_Message_Begin +99

Auction_Message_Begin	=	4000 

--[[
****************************************************************
*
*		详细定义   找到自己的模块添加   如果没有  则在上方添加消息段
*
*****************************************************************
--]]
ActionEvents = {
G2C_Result				= 99,	--通用的结果回复消息
----------------------------登录--------------------------
C2G_User_Auth  				= User_Message_Begin+1, --验证游戏服
G2C_User_Auth				= User_Message_Begin+2,
C2G_Charactor_Get	   		= Charactor_Message_Begin+1,--获取创建角色
G2C_Charactor_Get			= Charactor_Message_Begin + 2,--获取已创建角色
C2G_Charactor_Reg	   		= Charactor_Message_Begin + 3,--创建角色
C2G_Charactor_Login	  		= Charactor_Message_Begin + 5,--进入游戏
G2C_Charactor_Login	  		= Charactor_Message_Begin + 6,--玩家的角色信息返回
C2G_Character_Delete		= Charactor_Message_Begin + 7,--删除角色
G2C_Character_Delete		= Charactor_Message_Begin + 8,--删除角色

----------------------------角色----------------------------
G2C_Player_Attribute = G2C_Player_Begin + 1 ,
C2G_Player_Revive = G2C_Player_Begin + 11,
C2G_OtherPlayer_EquipList = G2C_Player_Begin + 21,
G2C_OtherPlayer_EquipList =	G2C_Player_Begin + 22,
C2G_OtherPlayer_Attribute = G2C_Player_Begin + 23,
G2C_OtherPlayer_Attribute = G2C_Player_Begin + 24,

----------------------------新场景协议----------------------------
C2G_Scene_Sync_Time			=Scene_Message_Begin +1, --同步时间
G2C_Scene_Sync_Time			=Scene_Message_Begin +2, --时间同步返回
C2G_Scene_Start_Move		=Scene_Message_Begin +3, --开始移动
C2G_Scene_Stop_Move			=Scene_Message_Begin +5, --结束移动
C2G_Scene_Switch			=Scene_Message_Begin +51,--场景切换  switchId=	int-- 传送点ID
G2C_Scene_Switch			=Scene_Message_Begin +52,-- 通知场景切换，客户端收到消息后切换场景 sceneId= string -- 场景ID x=int -- 坐标x y=int --坐标y
C2G_Scene_Ready				=Scene_Message_Begin +53,--切换场景完成，客户端ready，服务端才可以发送AOI信息过去
C2G_Scene_Transfer          =Scene_Message_Begin + 55,  --传送
G2C_Scene_Reset_Position	=Scene_Message_Begin +58,--重置客户端玩家坐标
G2C_Scene_Player_State		=Scene_Message_Begin +65,--玩家状态
G2C_Scene_AOI				=Scene_Message_Begin +72,--场景AOI信息
C2G_Npc_Transfer			=Scene_Message_Begin +73,--NPC跳转 
C2G_Scene_PickUp          	=Scene_Message_Begin+81,--拾取掉落
G2C_Op_Replay				=Global_Message_Begin,--
G2C_Player_Get				=Charactor_Message_Begin + 49,--获取人物角色
G2C_Game_Version			=Charactor_Message_Begin + 61,--请求服务器版本


C2G_Scene_StarttoPluck	=	Scene_Message_Begin + 85,		-- 开始采集 charId	=	string	// 采集物ID
G2C_Scene_StarttoPluck	=	Scene_Message_Begin + 86,		-- 开始采集返回 charId	=	string	// 采集物ID
G2C_Scene_InterruptPluck = 	Scene_Message_Begin + 88,		-- 打断采集
G2C_Scene_SuccesstoPluck = 	Scene_Message_Begin + 87,		-- 成功采集 
G2C_Scene_State_Change	=  Scene_Message_Begin + 90,		-- 状态更新

C2G_Scene_StartoPluck 		= Scene_Message_Begin + 91;  -- 开始采集  	NpcRefId     	String
G2C_Scene_StartoPluck 		= Scene_Message_Begin + 92;  -- 采集开始响应
G2C_Server_Connect			= Charactor_Message_Begin +98, --服务器连接结果
G2C_Charactor_Prop_Update 	= Charactor_Message_Begin +53,--
----------------------------技能事件----------------------------
C2G_GetLearnedSkillList		= SkillSystem_Message_Begin + 1,	--请求获取所有技能
G2C_GetLearnedSkillList		= SkillSystem_Message_Begin + 2,	
C2G_SetPutdownSkill 		= SkillSystem_Message_Begin + 3,   --向服务器更新快捷技能
C2G_AddSkillExp				= SkillSystem_Message_Begin + 5,   --添加技能成熟度
G2C_AddskillExp 			= SkillSystem_Message_Begin + 6,
C2G_UseSkill					= SkillSystem_Message_Begin + 10, 	--使用技能
G2C_TriggerSingleTargetSkill 	= SkillSystem_Message_Begin + 12,	--触发单目标技能
G2C_TriggerMultiTargetSkill		= SkillSystem_Message_Begin + 14,	--触发多目标技能



----------------------------聊天----------------------------
C2G_Chat_World 				= Chat_Message_Begin +1,
G2C_Chat_World 				= Chat_Message_Begin +51,
C2G_Chat_Society			= Union_Message_Begin +24,
G2C_Chat_Society 			= Union_Message_Begin +25,
C2G_Chat_Private 			= Chat_Message_Begin +3,
G2C_Chat_Private 			= Chat_Message_Begin +53,
G2C_Announcement_World 		= Chat_Message_Begin +54,  --公告消息
C2G_Chat_Get_ReceiverId 	= Chat_Message_Begin +5,
G2C_Chat_Get_ReceiverId 	= Chat_Message_Begin +55,
C2G_Chat_Current_Scene 		= Chat_Message_Begin + 6,
G2C_Chat_Current_Scene 		= Chat_Message_Begin +56,
C2G_Chat_Bugle 				= Chat_Message_Begin +7,  --喇叭消息
G2C_Chat_Bugle 				= Chat_Message_Begin +58,

----------------------------背包----------------------------
C2G_Bag_Capacity			= Bag_Message_Begin+1,
G2C_Bag_Capacity			= Bag_Message_Begin+2,	
C2G_Item_List				= Bag_Message_Begin+3,	 
G2C_Item_List				= Bag_Message_Begin+4,	
C2G_Item_Use				= Bag_Message_Begin+9,
C2G_Item_SoltUnLock			= Bag_Message_Begin+11,
G2C_Item_SoltUnLock			= Bag_Message_Begin+12,
C2G_Item_Sell				= Bag_Message_Begin+20,		
G2C_Item_Update				= Bag_Message_Begin + 8,
C2G_Item_Drop				= Bag_Message_Begin + 13,
C2G_Item_Add				= Bag_Message_Begin + 14,
C2G_Item_Info			    = Bag_Message_Begin+6,      --用于聊天物品展示
G2C_GetShowItem				= Bag_Message_Begin+56,
G2C_Bag_Error				= Bag_Message_Begin+99,	

----------------------------装备----------------------------
C2G_Equip_List			   	= Equip_Message_Begin+1,			  
G2C_Equip_List				= Equip_Message_Begin+2,	
C2G_Equip_PutOn				= Equip_Message_Begin+3,	
C2G_Equip_UnLoad			= Equip_Message_Begin+4,	
G2C_Equip_Update 			= Equip_Message_Begin+5,
G2C_Equip_Info				= Equip_Message_Begin+6,

----------------------------主任务----------------------------
C2G_QST_GetQuestList		= QST_Message_Begin+1,	--获取任务列表
G2C_QST_QuestAcceptedList	= QST_Message_Begin+2,	
G2C_QST_QuestVisibleList	= QST_Message_Begin+3,	--新增可接任务	
C2G_QST_QuestAccept			= QST_Message_Begin+4,	--接收、取消、提交、完成任务
C2G_QST_QuestSubmit			= QST_Message_Begin+5,
G2C_QST_StateUpdate 	    = QST_Message_Begin+6,
G2C_QST_QuestUpdate			= QST_Message_Begin+7,	--任务的进度更新

----------------------------日常任务----------------------------
C2G_QST_GetDailyQuestList		= QST_Message_Begin+51,	--获取任务列表
G2C_QST_DailyQuestAcceptedList	= QST_Message_Begin+52,	
G2C_QST_DailyQuestVisibleList	= QST_Message_Begin+53,	--新增可接任务	
C2G_QST_DailyQuestAccept		= QST_Message_Begin+54,	--接收、取消、提交、完成任务
C2G_QST_DailyQuestSubmit		= QST_Message_Begin+55,
G2C_QST_DailyStateUpdate    	= QST_Message_Begin+56,
G2C_QST_DailyQuestUpdate		= QST_Message_Begin+57,	--任务的进度更新
C2G_QST_DailyStartLevel			= QST_Message_Begin+58; --星星等级更新
G2C_QST_DailyStartLevel			= QST_Message_Begin+59;	--星星等级更新

----------------------------商城----------------------------
C2G_Request_All_Page_Info 			= Mall_Message_Begin + 1; --获取页面信息
G2C_Response_All_Page_Info 			= Mall_Message_Begin+50;
C2G_Request_Page_Info 				= Mall_Message_Begin + 2; -- 获取页面内物品信息
G2C_Response_Page_Info 				= Mall_Message_Begin+51;
C2G_Request_Buy 					= Mall_Message_Begin + 3; --购买请求
C2G_Request_PanicBuyingInfo 		= Mall_Message_Begin + 4; --限购页面请求
G2C_Response_Page_PanicBuying_Info	= Mall_Message_Begin +52;

----------------------------商店----------------------------------------

C2G_Store_VersonReq			= Shop_Message_Begin + 1,			--请求版本号
G2C_Store_VersonResp		= Shop_Message_Begin + 2,			-- 版本号返回 	int	版本号	
C2G_Store_ItemListReq		= Shop_Message_Begin + 3,			-- 请求列表
G2C_Store_ItemListResp		= Shop_Message_Begin + 4,			-- 列表返回
--[[
		count			int
		name		String
		list
--]]			
		
C2G_Store_LimitItemReq		= Shop_Message_Begin + 5,			-- 限购物品请求	byte  0商城  1 商店
G2C_Store_LimitItemResp		= Shop_Message_Begin + 6,			-- 限购物品返回
--[[
		count		int
		name		String
--]]
C2G_Shop_BuyItemReq			= Shop_Message_Begin + 7,			-- 购买限购物品请求
--[[
		int (商城为1， 商店为2)
		1 ：
				itemRefId		String
				count			int
		2：
				NpcRefId		String
				shopID			String
				itemRefId		String
				count			int
--]]
G2C_Shop_BuyItemResp		= Shop_Message_Begin + 8,			-- 购买限购物品返回--	Result	byte

----------------------------DeBug----------------------------
C2G_Debug_Event				= Debug_Message_Begin + 1;
G2C_Debug_Event   			= Debug_Message_Begin + 2;
----------------------------Knight---------------------------
C2G_GetSalaryEvent	= Knight_Message_Begin + 1,
G2C_GetSalaryEvent	= Knight_Message_Begin + 2,
C2G_UpGradeEvent	= Knight_Message_Begin + 3,
G2C_UpGradeEvent	= Knight_Message_Begin + 4,
C2G_CanGetReward 	= Knight_Message_Begin + 5,
G2C_CanGetReward 	= Knight_Message_Begin + 6,
----------------------------坐骑-----------------------------
C2G_Mount_IsOnMount 		= Mount_Message_Begin + 1,
G2C_Mount_IsOnMount 		= Mount_Message_Begin + 51,
C2G_Mount_List 				= Mount_Message_Begin + 2,
G2C_Mount_List 				= Mount_Message_Begin + 52,
C2G_Mount_Feed 				= Mount_Message_Begin + 3,
G2C_Mount_Feed 				= Mount_Message_Begin + 53,
C2G_Mount_Action			= Mount_Message_Begin + 4,	  --   0,上马请求   1，下马请求
G2C_Mount_Action 			= Mount_Message_Begin + 54,
G2C_Mount_MountQuestResp	= Mount_Message_Begin+5;   	  -- second  =  int  剩余时间（秒） 坐骑任务返回
C2G_Mount_GetMountQuestReward =	Mount_Message_Begin+6;    -- 坐骑任务奖励领取
G2C_Mount_GetMountQuestReward = Mount_Message_Begin+7;    -- Result = int  返回是否成功  领取坐骑任务奖励返回

-----------------------------翅膀-----------------------------
C2G_Wing_RequestNowWing			= Wing_Message_Begin + 1,	--获取当前翅膀, 返回当期翅膀RefId（上线时请求）
G2C_Wing_RequestNowWing			= Wing_Message_Begin + 2,	--返回当前翅膀
C2G_Wing_WingLevelUp			= Wing_Message_Begin + 3,	--翅膀升级请求
G2C_Wing_WingLevelUp 			= Wing_Message_Begin + 4,   --升级成功返回
C2G_Wing_GetWingQuestReward		= Wing_Message_Begin + 6;   --翅膀任务奖励领取
G2C_Wing_GetWingQuestReward 	= Wing_Message_Begin + 7;   --领取翅膀任务奖励返回
C2G_SectionQuest_Begin          = Wing_Message_Begin + 50;	--变强任务的统一入口（翅膀、法宝···）

-----------------------------锻造-----------------------------
C2G_Bag_Streng			        = Forge_Message_Begin+1,
C2G_Body_Streng                 = Forge_Message_Begin+2,
C2G_Bag_StrengScroll		    = Forge_Message_Begin+3,
C2G_Body_StrengScroll           = Forge_Message_Begin+4,
G2C_Streng_Ret                  = Forge_Message_Begin+5,
C2G_Bag_Wash                    = Forge_Message_Begin+6,
C2G_Body_Wash                   = Forge_Message_Begin+7,
C2G_Bag_Decompose               = Forge_Message_Begin+8,  
G2C_Bag_Decompose               = Forge_Message_Begin+9,  

-----------------------------成就-----------------------------
C2G_Achievement_List			= Achievement_Message_Begin+1,
G2C_AchievementID_List  		= Achievement_Message_Begin+2,
C2G_Achievement_GetReward 		= Achievement_Message_Begin+3,
G2C_Achievement_GetReward  		= Achievement_Message_Begin+4,
G2C_Achievement_Get				= Achievement_Message_Begin+5,
C2G_Achievement_ExchangeMedal	= Achievement_Message_Begin+6,
G2C_Achievement_ExchangeMedal	= Achievement_Message_Begin+7,
C2G_Achievement_LevlUpMedal		= Achievement_Message_Begin+8,
G2C_Achievement_LevlUpMedal		= Achievement_Message_Begin+9,
C2G_Achievement_GetAllReward 	= Achievement_Message_Begin+10,

--------------------------------副本---------------------------
-----查询副本列表--------------------------------
C2G_GameInstanceList = Game_Instance_Message_Begin + 1,
G2C_GameInstanceList = Game_Instance_Message_Begin + 51,
-----进入副本--------------------------------
C2G_GameInstanceEnter = Game_Instance_Message_Begin + 2,
-----离开副本--------------------------------
C2G_GameInstanceLeave = Game_Instance_Message_Begin + 3,
G2C_GameInstanceLeave = Game_Instance_Message_Begin + 53;
-----副本进入下一层--------------------------------
C2G_GameInstanceEnterNextLayer = Game_Instance_Message_Begin + 4,
-------已接副本任务返回（默认一进入就接取任务完成）--------------
G2C_Instance_QuestAccepted = Game_Instance_Message_Begin + 5, 
-------任务的进度更新-----------------------------------------
G2C_Instance_QuestUpdate = Game_Instance_Message_Begin + 6, 
-------状态更新-----------------------------------------
G2C_Instance_QuestFinish = Game_Instance_Message_Begin + 7,
-------任务发奖-----------------------------------------
G2C_Instance_QuestReward = Game_Instance_Message_Begin + 8, 

-------------------------------法宝-----------------------------
C2G_Talisman_List    = Talisman_Message_Begin + 1,	    --法宝列表请求
G2C_Talisman_List    = Talisman_Message_Begin + 2,		--法宝列表返回
--[[
   count{
	 index	     = short
	 state		 = byte
	 talisRefId	 = string
	 tailManLevel= byte	
	}
--]]
C2G_Talisman_Active    = Talisman_Message_Begin + 3,	--法宝激活请求
	--  type           = byte			--1获取 2 激活 3进阶 
    --  index	       = short			--格子的位置
G2C_Talisman_Active    = Talisman_Message_Begin + 4,	--法宝激活返回
	--  type           = byte			--1获取 2 激活 3进阶 
    --  index	       = short			--格子的位置
C2G_Talisman_GetQuestReward = Talisman_Message_Begin+7;   --法宝任务奖励领取
--	type	  byte  (1：翅膀            2：坐骑)
G2C_Talisman_GetQuestReward = Talisman_Message_Begin+8;   --领取法宝任务奖励返回
--	type	  byte  (1：翅膀            2：坐骑)
--	Result = int  返回是否成功

	
-----------------------------邮件-----------------------------
C2G_Mail_List   = Mail_Message_Begin + 1,
G2C_Mail_List   = Mail_Message_Begin + 51,
C2G_Mail_Read   = Mail_Message_Begin + 2,
C2G_Mail_Pickup  = Mail_Message_Begin + 3,
G2C_Mail_Add    = Mail_Message_Begin + 4,

-----------------------------Buff--------------------------------
G2C_Attach_Buff 	= Buff_Message_Begin +1,
G2C_Effect_Buff     =  Buff_Message_Begin +2,
C2G_Buff_List       = Buff_Message_Begin + 4,
G2C_Buff_List       = Buff_Message_Begin + 5,

--------------------------------NPC 采集-------------------------
--C2G_Pluck_StartoClient = Pluck_Message_Begin + 1; 	--开始采集 	NpcRefId     string
--G2C_Pluck_StartoClient = Pluck_Message_Begin + 2; 	--采集开始响应 	int	1 or 0 , 1为成功，可以开始倒数。 0为错误
G2C_Pluck_BeInteruupted = Pluck_Message_Begin + 3;	--采集终端消息
G2C_Pluck_End = Pluck_Message_Begin + 4;	--采集完成消息


--------------------------------公会----------------------------
C2G_Union_UnionList		=		Union_Message_Begin + 1,
G2C_Union_UnionList		=		Union_Message_Begin + 2,
C2G_Union_CreateUnion	=		Union_Message_Begin + 3,
G2C_Union_CreateUnion	=		Union_Message_Begin + 4,
C2G_Union_JoinUnion		=		Union_Message_Begin + 5,
G2C_Union_JoinUnion		=		Union_Message_Begin + 6,
C2G_Union_CancelJoin			=		Union_Message_Begin + 7,
G2C_Union_CancelJoin			=		Union_Message_Begin + 8,
C2G_Union_Exit			=		Union_Message_Begin + 9,
G2C_Union_Exit			=		Union_Message_Begin + 10,
C2G_Union_ApplyList		=		Union_Message_Begin + 11,
G2C_Union_ApplyList		=		Union_Message_Begin + 12,
C2G_Union_HandleApply	=		Union_Message_Begin + 13,
G2C_Union_HandleApply	=		Union_Message_Begin + 14,
C2G_Union_KickOutMember			=		Union_Message_Begin + 15,
G2C_Union_KickOutMember			=		Union_Message_Begin + 16,
C2G_Union_UpgradeOffice			=		Union_Message_Begin + 17,
G2C_Union_UpgradeOffice			=		Union_Message_Begin + 18,
C2G_Union_EditNotice	=		Union_Message_Begin + 19,
G2C_Union_EditNotice	=		Union_Message_Begin + 20,
C2G_Union_AutoAgree 	=		Union_Message_Begin + 21,

--------------------------------PK----------------------------
C2G_Pk_Model	= 	Pk_Message_Begin +1,
G2C_Pk_Model	= Pk_Message_Begin +2,
G2C_Name_Color	= Pk_Message_Begin +3,
C2G_Name_Color	= Pk_Message_Begin +4,

-------------------------Vip----------------------------------
C2G_Vip_State = Vip_Message_Begin + 1,
G2C_Vip_State = Vip_Message_Begin + 2,--string   playerId       byte  vip等级    int Vip剩余天数
C2G_Vip_AwardList = Vip_Message_Begin + 3,
G2C_Vip_AwardList = Vip_Message_Begin + 4,   -- 0  0  0
C2G_Vip_GetAward = Vip_Message_Begin + 5,

--拍卖协议
C2G_Auction_BuyList = Auction_Message_Begin + 1,
G2c_Auction_BuyList = Auction_Message_Begin + 2,
C2G_Auction_Buy = Auction_Message_Begin + 3,
G2C_Auction_Buy = Auction_Message_Begin + 4,
C2G_Auction_SellList = Auction_Message_Begin + 5,
G2C_Auction_SellList = Auction_Message_Begin + 6,
C2G_Auction_DoSell = Auction_Message_Begin + 7,
G2C_Auction_DoSell = Auction_Message_Begin + 8,
C2G_Auction_CancelSell = Auction_Message_Begin + 9,
G2C_Auction_CancelSell = Auction_Message_Begin + 10,
}

