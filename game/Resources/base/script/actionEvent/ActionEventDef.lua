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

QST_Message_Begin 		= 600				--����ϵͳ����Ϣ
QST_Message_End 		= QST_Message_Begin + 99

Chat_Message_Begin 		= 700			--������Ϣ
Chat_Message_End 		= Chat_Message_Begin +99 

Bag_Message_Begin 		= 800				--��Ʒ��Ϣ��ʼ
Bag_Message_End 		= Bag_Message_Begin + 99 

Equip_Message_Begin 	= 900			--װ����Ϣ
Equip_Message_End 		= Equip_Message_Begin + 99

Mount_Message_Begin 	= 1100			--������Ϣ
Mount_Message_End 		= Mount_Message_Begin + 99

Pluck_Message_Begin 	= 1300; 		--�ɼ���Ϣ
Pluck_Message_End		= Pluck_Message_Begin + 99

Mail_Message_Begin      =1400			--�ʼ���Ϣ
Mail_Message_End 		= Mail_Message_Begin + 99

Buff_Message_Begin		= 1500         --buff��Ϣ
Buff_Message_End        = Buff_Message_Begin +99

Team_Message_Begin 		= 1600		   --�����Ϣ
Team_Message_End        = Buff_Message_Begin + 99
Monster_Message_Begin	= 1700		   --�������
Monster_Message_End 	= Monster_Message_Begin + 99

Friend_Message_Begin	= 1900			--�������
Friend_Message_End 	= Friend_Message_Begin + 99

Activity_Message_Begin		=	3300  --�
Activity_Message_End		=	Activity_Message_Begin + 99

Wing_Message_Begin = 2600			--�����Ϣ
Wing_Message_End = Wing_Message_Begin +99

Knight_Message_Begin = 2300				--��λ��Ϣ
Knight_Message_End = Knight_Message_Begin + 99

Mall_Message_Begin 		= 1900			--�̳���Ϣ
Mall_Message_End 		= Mall_Message_Begin+99;

Debug_Message_Begin 	= 2000;
Debug_Message_End 		= Debug_Message_Begin +99

Forge_Message_Begin 	= 2200
Forge_Message_End 		= Forge_Message_Begin + 99

Achievement_Message_Begin = 2400 
Achieve_Message_End = Achievement_Message_Begin+99

Game_Instance_Message_Begin = 2500  --������Ϣ��ʼ

Talisman_Message_Begin	= 2700  --������Ϣ��ʼֵ
Talisman_Message_End	= Talisman_Message_Begin + 99

Shop_Message_Begin		=		2800
Shop_Message_End		=		Shop_Message_Begin + 99

Union_Message_Begin 	= 		2900	--������Ϣ
Union_Message_End		=		Union_Message_Begin + 99
Pk_Message_Begin 		= 3000			--Pk��Ϣ
Pk_Message_End        = Pk_Message_Begin +99

Vip_Message_Begin		= 3200			--Vip
Vip_Message_End			= Vip_Message_Begin + 99

SortBoard_Message_Begin = 3400			--���а�
SortBoard_Message_End		= SortBoard_Message_Begin + 99

CastleWar_Message_Begin = 3600	
Scene_Activity_Message_Begin=3700   --��������

OffLineAISeting_Begin = 3800
OffLineAISeting_End			=	OffLineAISeting_Begin + 99

Boss_Message_Begin = 1800
Boss_Message_End = Boss_Message_Begin+99
ResDownload_Begin = 3900
ResDownload_End = ResDownload_Begin + 99

Auction_Message_Begin	=	4000 

UnionGameInstance_Message_Begin = 4100         --���ḱ��

QuickRecharge_Message_Begin = 4300 --��ֵ
UnionGameInstance_Message_End = UnionGameInstance_Message_Begin + 99

Mining_Message_Begin = 4400 --�ڿ�
Mining_Message_End = Mining_Message_Begin + 99

Warehouse_Message_Begin = 4500 --�ֿ�
Warehouse_Message_End = Warehouse_Message_Begin + 99
--[[
****************************************************************
*
*		��ϸ����   �ҵ��Լ���ģ�����   ���û��  �����Ϸ������Ϣ��
*
*****************************************************************
--]]
ActionEvents = {
G2C_Result				= 99,	--ͨ�õĽ���ظ���Ϣ
----------------------------��¼--------------------------
C2G_User_Auth  				= User_Message_Begin+1, --��֤��Ϸ��
G2C_User_Auth				= User_Message_Begin+2,
C2G_Charactor_Get	   		= Charactor_Message_Begin + 1,--��ȡ������ɫ
G2C_Charactor_Get			= Charactor_Message_Begin + 2,--��ȡ�Ѵ�����ɫ
C2G_Charactor_Reg	   		= Charactor_Message_Begin + 3,--������ɫ
C2G_Charactor_Login	  		= Charactor_Message_Begin + 5,--������Ϸ
G2C_Charactor_Login	  		= Charactor_Message_Begin + 6,--��ҵĽ�ɫ��Ϣ����
C2G_Character_Delete		= Charactor_Message_Begin + 7,--ɾ����ɫ
G2C_Character_Delete		= Charactor_Message_Begin + 8,--ɾ����ɫ
C2G_Character_Leave			= Charactor_Message_Begin + 9,--��ɫ�뿪

----------------------------��ɫ----------------------------
G2C_Player_Attribute = G2C_Player_Begin + 1 ,
C2G_Player_Revive = G2C_Player_Begin + 11,
G2C_Player_Revive = G2C_Player_Begin + 12,
C2G_Player_Heartbeat	=	G2C_Player_Begin + 13,--��������
G2C_Player_Heartbeat	=	G2C_Player_Begin + 14,--��������
C2G_Player_KillerInfo	=	515,	--��ȡ��ɱ����Ϣ (������������ʹ���Ϣ)
G2C_Player_KillerInfo	=	516,	--���ػ�ɱ����Ϣ 
C2G_OtherPlayer_EquipList = G2C_Player_Begin + 21,
G2C_OtherPlayer_EquipList =	G2C_Player_Begin + 22,
C2G_OtherPlayer_Attribute = G2C_Player_Begin + 23,
G2C_OtherPlayer_Attribute = G2C_Player_Begin + 24,
C2G_Player_LeaveWorld = G2C_Player_Begin+3, 
C2G_OtherPlayer_Simple_Attribute = G2C_Player_Begin + 25,
G2C_OtherPlayer_Simple_Attribute = G2C_Player_Begin + 26,

----------------------------�³���Э��----------------------------
C2G_Scene_Sync_Time =Scene_Message_Begin +1, --ͬ��ʱ��
G2C_Scene_Sync_Time =Scene_Message_Begin +2, --ʱ��ͬ������
C2G_Scene_Start_Move =Scene_Message_Begin +3, --��ʼ�ƶ�
C2G_Scene_Stop_Move =Scene_Message_Begin +5, --�����ƶ�
C2G_Scene_FindSprite =Scene_Message_Begin +21,--ȷ����ɫ�Ƿ����
G2C_Scene_FindSprite =Scene_Message_Begin +22,--
C2G_Scene_Switch =Scene_Message_Begin +51,--�����л� switchId= int-- ���͵�ID
G2C_Scene_Switch =Scene_Message_Begin +52,-- ֪ͨ�����л����ͻ����յ���Ϣ���л����� sceneId= string -- ����ID x=int -- ����x y=int --����y
C2G_Scene_Ready =Scene_Message_Begin +53,--�л�������ɣ��ͻ���ready������˲ſ��Է���AOI��Ϣ��ȥ
G2C_Scene_Ready =Scene_Message_Begin +54, --�л��������ȷ��
C2G_Scene_Transfer =Scene_Message_Begin +55, --����
G2C_Scene_Reset_Position =Scene_Message_Begin +58,--���ÿͻ����������
G2C_Scene_Player_State =Scene_Message_Begin +65,--���״̬
G2C_Scene_AOI =Scene_Message_Begin +72,--����AOI��Ϣ
C2G_Npc_Transfer =Scene_Message_Begin +73,--NPC��ת
G2C_Scene_LootInfo =Scene_Message_Begin +80,--֪ͨ��ҵ�����Ϣ
C2G_Scene_PickUp =Scene_Message_Begin+81,--ʰȡ����
G2C_Op_Replay =Global_Message_Begin,--
G2C_Player_Get =Charactor_Message_Begin + 49,--��ȡ�����ɫ
G2C_Game_Version =Charactor_Message_Begin + 61,--����������汾


C2G_Scene_StarttoPluck	=	Scene_Message_Begin + 85,		-- ��ʼ�ɼ� charId	=	string	// �ɼ���ID
G2C_Scene_StarttoPluck	=	Scene_Message_Begin + 86,		-- ��ʼ�ɼ����� charId	=	string	// �ɼ���ID
G2C_Scene_InterruptPluck = 	Scene_Message_Begin + 88,		-- ��ϲɼ�
G2C_Scene_SuccesstoPluck = 	Scene_Message_Begin + 87,		-- �ɹ��ɼ�
G2C_Scene_State_Change	=  Scene_Message_Begin + 90,		-- ״̬����

C2G_Scene_StartoPluck 		= Scene_Message_Begin + 91;  -- ��ʼ�ɼ�  	NpcRefId     	String
G2C_Scene_StartoPluck 		= Scene_Message_Begin + 92;  -- �ɼ���ʼ��Ӧ
G2C_Server_Connect			= Charactor_Message_Begin +98, --���������ӽ��
G2C_Charactor_Prop_Update 	= Charactor_Message_Begin +53,--
C2G_Use_TransferStone		= Scene_Message_Begin + 74,		--ʹ�ô���ʯ
G2C_Scene_FightPower_NotEnough = Scene_Message_Begin + 99,	--���볡��ս�����㷵��
----------------------------�����¼�----------------------------
C2G_GetLearnedSkillList		= SkillSystem_Message_Begin + 1,	--�����ȡ���м���
G2C_GetLearnedSkillList		= SkillSystem_Message_Begin + 2,
C2G_SetPutdownSkill 		= SkillSystem_Message_Begin + 3,   --����������¿�ݼ���
C2G_AddSkillExp				= SkillSystem_Message_Begin + 5,   --��Ӽ��ܳ����
G2C_AddskillExp 			= SkillSystem_Message_Begin + 6,
C2G_UseSkill					= SkillSystem_Message_Begin + 10, 	--ʹ�ü���
G2C_TriggerSingleTargetSkill 	= SkillSystem_Message_Begin + 12,	--������Ŀ�꼼��
G2C_TriggerMultiTargetSkill		= SkillSystem_Message_Begin + 14,	--������Ŀ�꼼��



----------------------------����----------------------------
C2G_Chat_World 				= Chat_Message_Begin +1,
G2C_Chat_World 				= Chat_Message_Begin +51,
C2G_Chat_Society			= Union_Message_Begin +24,
G2C_Chat_Society 			= Union_Message_Begin +25,
C2G_Chat_Private 			= Chat_Message_Begin +3,
G2C_Chat_Private 			= Chat_Message_Begin +53,
G2C_Announcement_World 		= Chat_Message_Begin +54,  --������Ϣ
C2G_Chat_Get_ReceiverId 	= Chat_Message_Begin +5,
G2C_Chat_Get_ReceiverId 	= Chat_Message_Begin +55,
C2G_Chat_Current_Scene 		= Chat_Message_Begin + 6,
G2C_Chat_Current_Scene 		= Chat_Message_Begin +56,
G2C_System_Prompt			= Chat_Message_Begin +57,
C2G_Chat_Bugle 				= Chat_Message_Begin +7,   --����
G2C_Chat_Bugle 				= Chat_Message_Begin +58,
--C2G_OnlineStateList 		= Chat_Message_Begin+9,
G2C_FreshOnlineState 		= Chat_Message_Begin+10,

C2G_GetPlayerList 			= Friend_Message_Begin+1,
G2C_GetPlayerList			= Friend_Message_Begin+2,
C2G_AddOnePlayer 			= Friend_Message_Begin+3,
G2C_AddOnePlayer			= Friend_Message_Begin+4,
C2G_DeleteOnePlayer 		= Friend_Message_Begin+5,
G2C_DeleteOnePlayer			= Friend_Message_Begin+6,
----------------------------����----------------------------
C2G_Bag_Capacity			= Bag_Message_Begin+1,
G2C_Bag_Capacity			= Bag_Message_Begin+2,
C2G_Item_List				= Bag_Message_Begin+3,
G2C_Item_List				= Bag_Message_Begin+4,
C2G_Item_Use				= Bag_Message_Begin+9,
C2G_Item_SoltUnLock			= Bag_Message_Begin+11,
G2C_Item_SoltUnLock			= Bag_Message_Begin+12,
C2G_Item_Sell				= Bag_Message_Begin+20,
C2G_Item_Batch_Sell			= Bag_Message_Begin+21,
G2C_Item_Update				= Bag_Message_Begin + 8,
C2G_Item_Drop				= Bag_Message_Begin + 13,
C2G_Item_Add				= Bag_Message_Begin + 14,
C2G_Item_Info			    = Bag_Message_Begin+6,      --����������Ʒչʾ
G2C_GetShowItem				= Bag_Message_Begin+56,
G2C_Bag_Error				= Bag_Message_Begin+99,

----------------------------װ��----------------------------
C2G_Equip_List			   	= Equip_Message_Begin+1,
G2C_Equip_List				= Equip_Message_Begin+2,
C2G_Equip_PutOn				= Equip_Message_Begin+3,
C2G_Equip_UnLoad			= Equip_Message_Begin+4,
G2C_Equip_Update 			= Equip_Message_Begin+5,
G2C_Equip_Info				= Equip_Message_Begin+6,

----------------------------������----------------------------
C2G_QST_GetQuestList		= QST_Message_Begin+1,	--��ȡ�����б�
G2C_QST_QuestAcceptedList	= QST_Message_Begin+2,
G2C_QST_QuestVisibleList	= QST_Message_Begin+3,	--�����ɽ�����
C2G_QST_QuestAccept			= QST_Message_Begin+4,	--���ա�ȡ�����ύ���������
C2G_QST_QuestSubmit			= QST_Message_Begin+5,
G2C_QST_StateUpdate 	    = QST_Message_Begin+6,
G2C_QST_QuestUpdate			= QST_Message_Begin+7,	--����Ľ��ȸ���
C2G_QST_QuestInstanceTrans  = QST_Message_Begin+8,
C2G_COM_ActionToSucceed		= QST_Message_Begin+9,	--ͨ��Э�飬һ���ͻ��˲��������ĳ���¼�

----------------------------�ճ�����----------------------------
C2G_QST_GetDailyQuestList		= QST_Message_Begin+51,	--��ȡ�����б�
G2C_QST_DailyQuestAcceptedList	= QST_Message_Begin+52,
G2C_QST_DailyQuestVisibleList	= QST_Message_Begin+53,	--�����ɽ�����
C2G_QST_DailyQuestAccept		= QST_Message_Begin+54,	--���ա�ȡ�����ύ���������
C2G_QST_DailyQuestSubmit		= QST_Message_Begin+55,
G2C_QST_DailyStateUpdate    	= QST_Message_Begin+56,
G2C_QST_DailyQuestUpdate		= QST_Message_Begin+57,	--����Ľ��ȸ���
C2G_QST_DailyStartLevel			= QST_Message_Begin+58; --���ǵȼ�����
G2C_QST_DailyStartLevel			= QST_Message_Begin+59;	--���ǵȼ�����

----------------------------�̳�----------------------------
C2G_Request_All_Page_Info 			= Mall_Message_Begin + 1; --��ȡҳ����Ϣ
G2C_Response_All_Page_Info 			= Mall_Message_Begin+50;
C2G_Request_Page_Info 				= Mall_Message_Begin + 2; -- ��ȡҳ������Ʒ��Ϣ
G2C_Response_Page_Info 				= Mall_Message_Begin+51;
C2G_Request_Buy 					= Mall_Message_Begin + 3; --��������
C2G_Request_PanicBuyingInfo 		= Mall_Message_Begin + 4; --�޹�ҳ������
G2C_Response_Page_PanicBuying_Info	= Mall_Message_Begin +52;

----------------------------�̵�----------------------------------------

C2G_Store_VersonReq			= Shop_Message_Begin + 1,			--����汾��
G2C_Store_VersonResp		= Shop_Message_Begin + 2,			-- �汾�ŷ��� 	int	�汾��
C2G_Store_ItemListReq		= Shop_Message_Begin + 3,			-- �����б�
G2C_Store_ItemListResp		= Shop_Message_Begin + 4,			-- �б���
C2G_Store_LimitItemReq		= Shop_Message_Begin + 5,			-- �޹���Ʒ����	byte  0�̳�  1 �̵�
G2C_Store_LimitItemResp		= Shop_Message_Begin + 6,			-- �޹���Ʒ����
C2G_Shop_BuyItemReq			= Shop_Message_Begin + 7,			-- �����޹���Ʒ����
G2C_Shop_BuyItemResp		= Shop_Message_Begin + 8,			-- �����޹���Ʒ����--	Result	byte
---------------------������ۿۻ---------------------
C2G_Discount_GetShopList	=	Shop_Message_Begin  + 9,		--������۳����б�
G2C_Discount_GetShopList	=	Shop_Message_Begin  + 10, 		--��ȡ���۳����б�
G2C_Discount_BeginOrEndNotify = Shop_Message_Begin  + 11, 		--��Ƿ���
---------------------����һ���-------------------------
C2G_ExchangeCode 			= 	Shop_Message_Begin 	+ 12,		--��������һ�
G2C_ExchangeCode 			=	Shop_Message_Begin	+ 13,		--�һ��������
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
----------------------------����-----------------------------
C2G_Mount_IsOnMount 		= Mount_Message_Begin + 1,
G2C_Mount_IsOnMount 		= Mount_Message_Begin + 51,
C2G_Mount_List 				= Mount_Message_Begin + 2,
G2C_Mount_List 				= Mount_Message_Begin + 52,
C2G_Mount_Feed 				= Mount_Message_Begin + 3,
G2C_Mount_Feed 				= Mount_Message_Begin + 53,
C2G_Mount_Action			= Mount_Message_Begin + 4,	  --   0,��������   1����������
G2C_Mount_Action 			= Mount_Message_Begin + 54,
G2C_Mount_MountQuestResp	= Mount_Message_Begin+5;   	  -- second  =  int  ʣ��ʱ�䣨�룩 �������񷵻�
C2G_Mount_GetMountQuestReward =	Mount_Message_Begin+6;    -- ������������ȡ
G2C_Mount_GetMountQuestReward = Mount_Message_Begin+7;    -- Result = int  �����Ƿ�ɹ�  ��ȡ��������������

-----------------------------���-----------------------------
C2G_Wing_RequestNowWing			= Wing_Message_Begin + 1,	--��ȡ��ǰ���, ���ص��ڳ��RefId������ʱ����
G2C_Wing_RequestNowWing			= Wing_Message_Begin + 2,	--���ص�ǰ���
C2G_Wing_WingLevelUp			= Wing_Message_Begin + 3,	--�����������
G2C_Wing_WingLevelUp 			= Wing_Message_Begin + 4,   --�����ɹ�����
C2G_Wing_GetWingQuestReward		= Wing_Message_Begin + 6;   --�����������ȡ
G2C_Wing_GetWingQuestReward 	= Wing_Message_Begin + 7;   --��ȡ�������������
C2G_SectionQuest_Begin          = Wing_Message_Begin + 50;	--��ǿ�����ͳһ��ڣ���򡢷�����������

-----------------------------����-----------------------------
C2G_Bag_Streng			        = Forge_Message_Begin+1,
C2G_Body_Streng                 = Forge_Message_Begin+2,
C2G_Bag_StrengScroll		    = Forge_Message_Begin+3,
C2G_Body_StrengScroll           = Forge_Message_Begin+4,
G2C_Streng_Ret                  = Forge_Message_Begin+5,
C2G_Bag_Wash                    = Forge_Message_Begin+6,
C2G_Body_Wash                   = Forge_Message_Begin+7,
C2G_Bag_Decompose               = Forge_Message_Begin+8,
G2C_Bag_Decompose               = Forge_Message_Begin+9,
G2C_ForgeOpen					= Forge_Message_Begin+10,

-----------------------------�ɾ�-----------------------------
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

-----------------------------����-----------------------------
C2G_Monster_OwnerTransfer = Monster_Message_Begin+1,
G2C_Monster_OwnerTransfer = Monster_Message_Begin+2,
C2G_Monster_ClearError = Monster_Message_Begin+3,

--------------------------------����---------------------------
-----��ѯ�����б�--------------------------------
C2G_GameInstanceList = Game_Instance_Message_Begin + 1,
G2C_GameInstanceList = Game_Instance_Message_Begin + 51,
-----���븱��--------------------------------
C2G_GameInstanceEnter = Game_Instance_Message_Begin + 2,
-----�뿪����--------------------------------
C2G_GameInstanceLeave = Game_Instance_Message_Begin + 3,
G2C_GameInstanceLeave = Game_Instance_Message_Begin + 53;
-----����������һ��--------------------------------
C2G_GameInstanceEnterNextLayer = Game_Instance_Message_Begin + 4,
-------�ѽӸ������񷵻أ�Ĭ��һ����ͽ�ȡ������ɣ�--------------
G2C_Instance_QuestAccepted = Game_Instance_Message_Begin + 5,
-------����Ľ��ȸ���-----------------------------------------
G2C_Instance_QuestUpdate = Game_Instance_Message_Begin + 6,
-------״̬����-----------------------------------------
G2C_Instance_QuestFinish = Game_Instance_Message_Begin + 7,
-------���񷢽�-----------------------------------------
G2C_Instance_QuestReward = Game_Instance_Message_Begin + 8,
G2C_Instance_Finished = Game_Instance_Message_Begin + 9,
C2G_Instance_GetQuestList =	Game_Instance_Message_Begin + 10,
-------���󸱱����񷢽�/�뿪-----------------------------------------
C2G_Reward_GameInstanceQuest	= Game_Instance_Message_Begin + 54,
C2G_Show_GameInstanceQuestReward = Game_Instance_Message_Begin + 55,

-------------------------------����-----------------------------
C2G_Talisman_List    		= Talisman_Message_Begin + 1,	--�����б�����
G2C_Talisman_List   	 	= Talisman_Message_Begin + 2,	--�����б���
C2G_Talisman_Active   		= Talisman_Message_Begin + 3,	--������������ --  type           = byte			--1��ȡ 2 ���� 3���� --  index	       = short			--���ӵ�λ��
G2C_Talisman_Active    		= Talisman_Message_Begin + 4,	--��������� --  type           = byte			--1��ȡ 2 ���� 3���� --  index	       = short			--���ӵ�λ��
C2G_Talisman_GetQuestReward = Talisman_Message_Begin + 7, 	--������������ȡ  --	type	  byte  (1�����            2������)
G2C_Talisman_GetQuestReward = Talisman_Message_Begin + 8, 	--��ȡ��������������  --type	  byte  (1�����            2������)	Result = int  �����Ƿ�ɹ�
C2G_Talisman_Statistics		= Talisman_Message_Begin + 9,	--���󷨱�ͳ������
G2C_Talisman_Statistics		= Talisman_Message_Begin + 10,	--����ͳ�����ݷ���
C2G_Citta_LevelUp       = Talisman_Message_Begin + 11,		--�ķ�����
G2C_Citta_LevelUp       = Talisman_Message_Begin + 12,		--�ķ�����
C2G_Talisman_Reward		= Talisman_Message_Begin + 13,		--����������ȡ
G2C_Talisman_Reward		= Talisman_Message_Begin + 14,		--����������ȡ
C2G_Talisman_GetReward		= Talisman_Message_Begin + 15,	--��ȡ����������������
G2C_Talisman_GetReward		= Talisman_Message_Begin + 16,

-----------------------------�ʼ�-----------------------------
C2G_Mail_List   = Mail_Message_Begin + 1,
G2C_Mail_List   = Mail_Message_Begin + 51,
C2G_Mail_Read   = Mail_Message_Begin + 2,
C2G_Mail_Pickup  = Mail_Message_Begin + 3,
G2C_Mail_Add    = Mail_Message_Begin + 4,
C2G_GMMail_Send = Mail_Message_Begin + 5,
C2G_Mail_Content = Mail_Message_Begin + 6,
G2C_Mail_Content = Mail_Message_Begin + 52,
G2C_Mail_Pickup  = Mail_Message_Begin + 8,
C2G_Mail_Pickup_LeftTime = Mail_Message_Begin + 7,
G2C_Mail_Pickup_LeftTime = Mail_Message_Begin + 53,

-----------------------------Buff--------------------------------
G2C_Attach_Buff 	= Buff_Message_Begin +1,
G2C_Effect_Buff     =  Buff_Message_Begin +2,
C2G_Buff_List       = Buff_Message_Begin + 4,
G2C_Buff_List       = Buff_Message_Begin + 5,
C2G_MoXueShi_Amount       = Buff_Message_Begin + 7,
G2C_MoXueShi_Amount = Buff_Message_Begin + 8,

--------------------------------NPC �ɼ�-------------------------
--C2G_Pluck_StartoClient = Pluck_Message_Begin + 1; 	--��ʼ�ɼ� 	NpcRefId     string
--G2C_Pluck_StartoClient = Pluck_Message_Begin + 2; 	--�ɼ���ʼ��Ӧ 	int	1 or 0 , 1Ϊ�ɹ������Կ�ʼ������ 0Ϊ����
G2C_Pluck_BeInteruupted = Pluck_Message_Begin + 3;	--�ɼ��ն���Ϣ
G2C_Pluck_End = Pluck_Message_Begin + 4;	--�ɼ������Ϣ


--------------------------------����----------------------------
C2G_Union_UnionList		=		Union_Message_Begin + 1,
G2C_Union_UnionList		=		Union_Message_Begin + 2,
C2G_Union_CreateUnion	=		Union_Message_Begin + 3,
G2C_Union_CreateUnion	=		Union_Message_Begin + 4,
C2G_Union_JoinUnion		=		Union_Message_Begin + 5,
G2C_Union_JoinUnion		=		Union_Message_Begin + 6,
C2G_Union_CancelJoin	=		Union_Message_Begin + 7,
G2C_Union_CancelJoin	=		Union_Message_Begin + 8,
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
C2G_AssembleFactionActionEvent  =		Union_Message_Begin + 22,
G2C_AssembleFactionActionEvent  =		Union_Message_Begin + 26,
C2G_JoinFactionActionEvent		= 		Union_Message_Begin + 23,
G2C_FactionInviteReplyActionEvent     =       Union_Message_Begin + 27,
G2C_Union_Update 		=		Union_Message_Begin + 28,
--------------------------------PK----------------------------
C2G_Pk_Model	= 	Pk_Message_Begin +1,
G2C_Pk_Model	= Pk_Message_Begin +2,
G2C_Name_Color	= Pk_Message_Begin +3,
C2G_Name_Color	= Pk_Message_Begin +4,
G2C_Rookie_Protection = Pk_Message_Begin + 6,
-----------------------------���------------------------------------
C2G_PlayerInfoActionEvent	 = 	Team_Message_Begin + 1,
G2C_PlayerInfoActionEvent 	 = 	Team_Message_Begin + 51,
C2G_AssembleTeamActionEvent	 =	Team_Message_Begin + 2,
G2C_AssembleTeamActionEvent  =  Team_Message_Begin + 52,
C2G_JoinTeamActionEvent		 = 	Team_Message_Begin + 3,
G2C_JoinTeamActionEvent		 = 	Team_Message_Begin + 53,
C2G_LeaveTeamActionEvent     =  Team_Message_Begin + 4,
G2C_LeaveTeamActionEvent     =  Team_Message_Begin + 54,
C2G_KickedOutTeamMemberActionEvent = Team_Message_Begin + 5,
G2C_KickedOutTeamMemberActionEvent = Team_Message_Begin + 55,
C2G_HandoverTeamLeaderActionEvent  = Team_Message_Begin + 6,
G2C_HandoverTeamLeaderActionEvent  = Team_Message_Begin + 56,
C2G_DisbandTeamActionEvent         = Team_Message_Begin + 7,
G2C_DisbandTeamActionEvent         = Team_Message_Begin + 57,
C2G_PlayerTeamSettingActionEvent   = Team_Message_Begin + 8,
G2C_PlayerTeamSettingActionEvent   = Team_Message_Begin + 58,

C2G_PlayerTeam_Create = Team_Message_Begin + 9,	
G2C_PlayerTeam_Create = Team_Message_Begin + 59,
C2G_PlayerTeam_JoinRequest = Team_Message_Begin + 10,
G2C_PlayerTeam_JoinRequest = Team_Message_Begin + 60,
C2G_PlayerTeam_InfomationEvent = Team_Message_Begin + 11,
G2C_PlayerTeam_InfomationEvent = Team_Message_Begin + 61,
C2G_JoinRequestReplyActionEvent = Team_Message_Begin + 12,
G2C_JoinRequestReplyActionEvent = Team_Message_Begin + 62,	
C2G_PlayerTeam_Modify = Team_Message_Begin + 13,
G2C_PlayerTeam_Modify = Team_Message_Begin + 63,
C2G_TeamMember_Detail = Team_Message_Begin + 14,
G2C_TeamMenber_Detail = Team_Message_Begin + 64,
--�㲥��Ϣ
G2C_Broadcast_TeamActionEvent	   			 =	Team_Message_Begin + 81,
G2C_Broadcast_HandoverTeamActionEvent		 =	Team_Message_Begin + 82,
G2C_Broadcast_TeamLeaderQuitTeamActionEvent	 =	Team_Message_Begin + 83,
G2C_Broadcast_DisbandTeamActionEvent		 =	Team_Message_Begin + 84,
G2C_Broadcast_TeamLeaderKickedOutActionEvent =	Team_Message_Begin + 85,
--��ӻ
G2C_PlayerTeamBoss_PreStart    	= Team_Message_Begin + 65,
G2C_PlayerTeamBoss_End		   	= Team_Message_Begin + 15,   
C2G_PlayerTeamBoss_RequestTime 	= Team_Message_Begin + 66,
G2C_PlayerTeamBoss_RequestTime 	= Team_Message_Begin + 67,
G2C_PlayerTeamBoss_Start  		= Team_Message_Begin + 68,
G2C_PlayerTeamBoss_Show	 		= Team_Message_Begin + 69,
-------------------------Vip----------------------------------
C2G_Vip_State = Vip_Message_Begin + 1,
G2C_Vip_State = Vip_Message_Begin + 2,--string   playerId       byte  vip�ȼ�    int Vipʣ������
C2G_Vip_AwardList = Vip_Message_Begin + 3,
G2C_Vip_AwardList = Vip_Message_Begin + 4,   -- 0  0  0
C2G_Vip_GetAward = Vip_Message_Begin + 5,
G2C_Vip_GetAward = Vip_Message_Begin + 6,
C2G_Vip_OpenLottery = Vip_Message_Begin + 7,
G2C_Vip_OpenLottery = Vip_Message_Begin + 8,
C2G_Vip_Lottery = Vip_Message_Begin + 9,
G2C_Vip_Lottery = Vip_Message_Begin + 10,
G2C_Vip_LotteryMsg = Vip_Message_Begin + 11,
G2C_Vip_SendWing = Vip_Message_Begin + 12,
C2C_Vip_GetWing = Vip_Message_Begin + 13,

------------------------ǩ��------------------------------------------------
C2G_Sign_SignList = Activity_Message_Begin + 1,
G2C_Sign_SignList = Activity_Message_Begin + 2,

C2G_Sign_SignIn = Activity_Message_Begin + 3,
G2C_Sign_SignIn = Activity_Message_Begin + 4,

C2G_Activity_GetAward = Activity_Message_Begin + 5,
G2C_Activity_GetAward = Activity_Message_Begin + 6,

G2C_Sign_AwardCanGet = Activity_Message_Begin + 7, --type =	byte // 2: ǩ�� 5:���� 6:����	refId= string	//�ﵽ����������refId
	

-------------------------����ʱ��-------------------------------
C2G_OT_ShowOnLineTimer	= 	Activity_Message_Begin  + 90, --��������ʱ��ʱ��
G2C_OT_ShowOnLineTimer	= 	Activity_Message_Begin  + 8, --��ʾ����ʱ��

-------------------------7���¼-------------------------------
C2G_SevenLogin_ReceiveState = Activity_Message_Begin + 9,
G2C_SevenLogin_ReceiveState = Activity_Message_Begin + 10,
C2G_SevenLogin_HaveReceive = Activity_Message_Begin + 47,
G2C_SevenLogin_HaveReceive = Activity_Message_Begin + 11,
C2G_SevenLogin_HadReceive = Activity_Message_Begin + 12,
C2G_SevenLogin_ReReceive = Activity_Message_Begin + 94,


-------------------------������������������-------------------------------
C2G_Advanced_List = Activity_Message_Begin + 15,
G2C_Advanced_List = Activity_Message_Begin + 16,
C2G_Advanced_GetReward  = Activity_Message_Begin + 17,
C2G_LevelUpAward_List = Activity_Message_Begin + 18,
G2C_LevelUpAward_List = Activity_Message_Begin + 19,
C2G_Get_LevelUpAward = Activity_Message_Begin + 20,
-------------------------�ڱ�-------------------------------
C2G_Digs_Type 		 = Activity_Message_Begin + 25,
C2G_Digs_List		 = Activity_Message_Begin + 26,
G2C_Digs_List		 = Activity_Message_Begin + 27,
G2C_Digs_Update		 = Activity_Message_Begin + 28,
C2G_Digs_Switch		 = Activity_Message_Begin + 29,
G2C_Digs_Result 	 = Activity_Message_Begin + 74,

------------------------���а�-------------------------------
C2G_SortBoard_GetSortBoardVersion = SortBoard_Message_Begin+1,
G2C_SortBoard_GetSortBoardVersion = SortBoard_Message_Begin+2,
C2G_SortBoard_GetSortBoardData = SortBoard_Message_Begin+3,
G2C_SortBoard_GetSortBoardData = SortBoard_Message_Begin+4,
C2G_SortBoard_GetTopPlayerData = SortBoard_Message_Begin+7,
G2C_SortBoard_GetTopPlayerData = SortBoard_Message_Begin+8,
C2G_SortBoard_PFS_GetBoardList = SortBoard_Message_Begin+9,
G2C_SortBoard_PFS_GetBoardList = SortBoard_Message_Begin + 10,

------------------------��ʱ���------------------------------
G2C_LimitTimeRank_TimeOver	=	Activity_Message_Begin + 30, -- openState	=	byte   sortboardType	=	byte
C2G_LimitTimeRank_List		=	Activity_Message_Begin + 31,
G2C_LimitTimeRank_List		=	Activity_Message_Begin + 32,
C2G_LimitTimeRank_GetReward	= Activity_Message_Begin + 33,
G2C_LimitTimeRank_GetReward	= Activity_Message_Begin + 34,
C2G_LimitTimeRank_Version	= Activity_Message_Begin + 35,
G2C_LimitTimeRank_Version	= Activity_Message_Begin + 36,
--------------------�׳����------------------------------
C2G_OA_FirstRechargeGiftReceive = Activity_Message_Begin + 37,
C2G_OA_FirstRechargeGiftList = Activity_Message_Begin + 38,
G2C_OA_FirstRechargeGiftList = Activity_Message_Begin + 39,

-------------------�ܳ�ֵ���----------------------------
C2G_OA_TotalRechargeGiftListEvent = Activity_Message_Begin + 40,
G2C_OA_TotalRechargeGiftListEvent = Activity_Message_Begin + 41,
C2G_OA_TotalRechargeGiftReceiveEvent = Activity_Message_Begin + 42,

--------------------ÿ�ճ�ֵ���------------------------------
C2G_OA_EveryRechargeGiftListEvent = Activity_Message_Begin + 44,
G2C_OA_EveryRechargeGiftListEvent = Activity_Message_Begin + 45,
C2G_OA_EveryRechargeGiftReceiveEvent = Activity_Message_Begin + 46,

--------------------(��Ϸ����)��ر��뿪��ͨ��Э�飬��Ϸ���Ҫ��------
G2C_OA_CanReceiveEvent = Activity_Message_Begin  + 60,
G2C_OA_ClosedActivityEvent = Activity_Message_Begin  + 61,
G2C_OA_OpenedActivityEvent = Activity_Message_Begin  + 62,
G2C_OA_OpeningActivityEvent = Activity_Message_Begin  + 63,
C2G_OA_CanReceiveEvent = Activity_Message_Begin  + 83,

--------------------�ܳ�ֵ�������-------------------------------
C2G_OA_WeekConsumeGiftListEvent = Activity_Message_Begin + 71,
G2C_OA_WeekConsumeGiftListEvent = Activity_Message_Begin + 72,
C2G_OA_WeekConsumeGiftReceiveEvent = Activity_Message_Begin + 73,

-------------------------��������-------------------------------
C2G_Arena_ShowArenaView					= Activity_Message_Begin + 48,
G2C_Arena_ShowArenaView					= Activity_Message_Begin + 49,
G2C_Arena_UpadateNotice					= Activity_Message_Begin + 50,
G2C_Arena_UpadateChallengeTarget		= Activity_Message_Begin + 51,
G2C_Arena_UpadateFightRecord			= Activity_Message_Begin + 52,
G2C_Arena_UpadateHeroInfo				= Activity_Message_Begin + 53,
C2G_Arena_ReceiveReward					= Activity_Message_Begin + 54,
G2C_Arena_UpdateReceiveRewardTime		= Activity_Message_Begin + 55,
C2G_Arena_Challenge						= Activity_Message_Begin + 56,
G2C_Arena_UpdateChallengeCDTime			= Activity_Message_Begin + 57,
C2G_Ladder_Select						= Activity_Message_Begin + 58,
G2C_Ladder_Select						= Activity_Message_Begin + 59,
C2G_Arena_Challenge_Award				= Activity_Message_Begin + 93,
--G2C_Arena_Challenge_Award				= Activity_Message_Begin + 94,
C2G_Arena_CanReceive					= Activity_Message_Begin + 97,
G2C_Arena_CanReceive					= Activity_Message_Begin + 98,
G2C_Arena_Challenge						= Activity_Message_Begin + 91,
C2G_Arena_ClearCDTime					= Activity_Message_Begin + 92,



------------------------�ڿ�-------------------------------------------
C2G_Mining_EnterEvent     =   Mining_Message_Begin + 1,
G2C_Mining_EnterEvent     =   Mining_Message_Begin  + 2,
C2G_Mining_ExitEvent      =   Mining_Message_Begin  + 3,
G2C_Mining_ExitEvent      =   Mining_Message_Begin  + 4,
G2C_Mining_FinishEvent    =   Mining_Message_Begin  + 5,
G2C_Mining_Update	=	Mining_Message_Begin  + 6,
G2C_Mining_Open     =   Mining_Message_Begin  + 7,
C2G_Mining_Open  	=	Mining_Message_Begin  + 8,
C2G_Mining_ContinuTime = Mining_Message_Begin + 9, --����ʣ��ʱ��
G2C_Mining_ContinuTime = Mining_Message_Begin + 10, --����ʣ��ʱ��
C2G_Mining_RemainRrfreshTime = Mining_Message_Begin + 11,
G2C_Mining_RemainRrfreshTime = Mining_Message_Begin + 12,

---------------------------������� ----------------------------------
C2G_Fund_ApplyVersionByType	= Activity_Message_Begin + 75,	--����������Ͱ汾��
G2C_Fund_ReturnVersion		= Activity_Message_Begin + 76,	--���ػ������Ͱ汾��
C2G_Fund_FundGetRewardList	= Activity_Message_Begin + 77,	--��������콱�б�
G2C_Fund_FundGetRewardList	= Activity_Message_Begin + 78,	--���ػ����콱�б�
C2G_Fund_BuyWhichFund		= Activity_Message_Begin + 79,	--�������ĸ�����
G2C_Fund_BuyWhichFund		= Activity_Message_Begin + 80,	--������
C2G_Fund_GetReward			= Activity_Message_Begin + 81,	--������ȡ������
G2C_Fund_GetReward			= Activity_Message_Begin + 82,	--��ȡ���
C2G_Fund_IsReceive			= Activity_Message_Begin + 86,  --�����Ƿ���콱
G2C_Fund_IsReceive			= Activity_Message_Begin + 87,  --�����Ƿ���콱����
-------------------------��Ƿ���콱---------------------------------
C2G_Activity_CanReceive = Activity_Message_Begin + 95,
G2C_Activity_CanReceive = Activity_Message_Begin + 96, 

--ɳ�Ϳ˹���
C2G_CastleWar_JoinWar = CastleWar_Message_Begin + 1,  			--����ɳ�Ϳ˹���
G2C_CastleWar_JoinWar = CastleWar_Message_Begin + 2,   			--ɳ�Ϳ˹��Ƿ���
C2G_CastleWar_GetGift = CastleWar_Message_Begin + 3,			--��ȡ�������
C2G_CastleWar_Instance = CastleWar_Message_Begin + 4,			--����������Ǹ���
C2G_CastleWar_FactionList = CastleWar_Message_Begin + 5,		--���󹥳ǹ����б�
G2C_CastleWar_FactionList = CastleWar_Message_Begin + 6,		--���ǹ����б���
G2C_CastleWar_Enter     = CastleWar_Message_Begin + 7,			--���ǿ�ʼ
G2C_CastleWar_Exit      = CastleWar_Message_Begin + 8,			--���ǽ���
G2C_CastleWar_MonsterRefresh = CastleWar_Message_Begin + 9,    	--����ˢ��                             
G2C_CastleWar_PreStart = CastleWar_Message_Begin + 10,          --�����вμӹ�������Ԥ��ʼ֪ͨ
G2C_CastleWar_End		= CastleWar_Message_Begin + 11,          --����ս����֪ͨ���ͻ����Ƴ�״̬ʹ�ã�.....���ض��󣺲�ս������������߳�Ա��
C2G_CastleWar_RequestTime = CastleWar_Message_Begin + 12,        --���󹥳�սʱ�����
G2C_CastleWar_RequestTime = CastleWar_Message_Begin + 13,        --����ս���ʱ�䷵��
G2C_CastleWar_Start = CastleWar_Message_Begin + 14,				 --�����вμӹ������ҿ�ʼ֪ͨ
C2G_CastleWar_OpenServerTime = CastleWar_Message_Begin + 15,	 --���뿪��ʱ��
G2C_CastleWar_OpenServerTime = CastleWar_Message_Begin + 16,	 --���ؿ���ʱ��

----------------------------�������� -------------------------
C2G_MonsterIntrusion_EnterMap = Scene_Activity_Message_Begin + 1,    --��������ͼ
C2G_MonsterIntrusion_LeaveMap = Scene_Activity_Message_Begin + 2,    --�����뿪��ͼ
G2C_MonsterIntrusion_ContinuTime = Scene_Activity_Message_Begin + 3, --����ʣ��ʱ��
G2C_MonsterIntrusion_EnterMap = Scene_Activity_Message_Begin + 4,  	 --��������
C2G_MonsterIntrusion_ContinuTime = Scene_Activity_Message_Begin + 5, --����ʣ��ʱ��
G2C_MonsterIntrusion_LeaveMap = Scene_Activity_Message_Begin + 6,     --�뿪�����
G2C_MonsterIntrusion_Font = Scene_Activity_Message_Begin + 7,       --ͷ����ʾ��Ϣ
G2C_MonsterIntrusion_BossTimeRefresh = Scene_Activity_Message_Begin + 8, --bossˢ��ʱ��
C2G_MonsterIntrusion_IsStart = Scene_Activity_Message_Begin + 9,      --���������Ƿ�ʼ
G2C_MonsterIntrusion_IsStart = Scene_Activity_Message_Begin + 10,     --���������Ƿ�ʼ����
-------------------------------------���ѵع�---------------------------------
C2G_BossTemple_Enter =  Scene_Activity_Message_Begin + 31,	
G2C_BossTemple_Enter =  Scene_Activity_Message_Begin + 32,	
C2G_BossTemple_Exit =  Scene_Activity_Message_Begin + 33,	
G2C_BossTemple_Exit =  Scene_Activity_Message_Begin + 34,	

------------------------------------�౶����-------------------------------
G2C_MultiTimesExp_PreStart    	= Scene_Activity_Message_Begin + 65,
G2C_MultiTimesExp_State  		= Scene_Activity_Message_Begin + 66,  
C2G_MultiTimesExp_RequestTime 	= Scene_Activity_Message_Begin + 67,
G2C_MultiTimesExp_RequestTime 	= Scene_Activity_Message_Begin + 68,


--���߱���
C2G_ViewOffLineAIReward = OffLineAISeting_Begin + 1,			--�鿴���߽���
G2C_ViewOffLineAIReward = OffLineAISeting_Begin + 50,
C2G_DrawOffLineAIReward = OffLineAISeting_Begin + 2,			--��ȡ���߽���
G2C_DrawOffLineAIReward = OffLineAISeting_Begin + 51,
C2G_OffLineAISeting = OffLineAISeting_Begin + 3,				--���߹һ�AI����


---����boss
C2G_Boss_List = Boss_Message_Begin + 1,			--�������ˢ���б�
G2C_Boss_List = Boss_Message_Begin + 2,
G2C_Boss_Refresh = Boss_Message_Begin + 3,

--��Դ������
C2G_resDownloadGetReward = ResDownload_Begin + 1,
C2G_resDownloadCanGetReward = ResDownload_Begin + 3,
G2C_resDownloadCanGetReward = ResDownload_Begin + 4,

--����Э��
C2G_Auction_BuyList = Auction_Message_Begin + 1,
G2C_Auction_BuyList = Auction_Message_Begin + 2,
C2G_Auction_Buy = Auction_Message_Begin + 3,
G2C_Auction_Buy = Auction_Message_Begin + 4,
C2G_Auction_SellList = Auction_Message_Begin + 5,
G2C_Auction_SellList = Auction_Message_Begin + 6,
C2G_Auction_DoSell = Auction_Message_Begin + 7,
G2C_Auction_DoSell = Auction_Message_Begin + 8,
C2G_Auction_CancelSell = Auction_Message_Begin + 9,
G2C_Auction_CancelSell = Auction_Message_Begin + 10,
C2G_Auction_DefaultPrice = Auction_Message_Begin + 11,
G2C_Auction_DefaultPrice = Auction_Message_Begin + 12,

--����ָ��Э��
C2G_FunStep_Request = Auction_Message_Begin + 201,
C2G_FunStep_Complete_Request  = Auction_Message_Begin + 202,
G2C_FunStepList_Response   = Auction_Message_Begin + 210,

--���ḱ��
C2G_UnionGameInstance_Apply	=	UnionGameInstance_Message_Begin + 1,
G2C_UnionGameInstance_Apply =   UnionGameInstance_Message_Begin + 2,	
C2G_UnionGameInstance_Enter =	UnionGameInstance_Message_Begin + 3,
G2C_UnionGameInstance_Enter =	UnionGameInstance_Message_Begin + 4,	
G2C_UnionGameInstance_Finish =  UnionGameInstance_Message_Begin + 5,

--��ֵ
C2G_QuickRecharge_List = QuickRecharge_Message_Begin + 1,
G2C_QuickRecharge_List = QuickRecharge_Message_Begin + 2,

--�ֿ�
C2G_WareHouse_Capacity = Warehouse_Message_Begin + 1,
G2C_WareHouse_Capacity = Warehouse_Message_Begin + 2,
C2G_WareHouse_Item_List = Warehouse_Message_Begin + 3,
G2C_WareHouse_Item_List = Warehouse_Message_Begin + 4,
C2G_WareHouse_Item_Update = Warehouse_Message_Begin + 5,
G2C_WareHouse_Item_Update = Warehouse_Message_Begin + 6,
C2G_WareHouse_Item_SoltUnLock = Warehouse_Message_Begin + 9,
G2C_WareHouse_Item_SoltUnLock = Warehouse_Message_Begin + 10,

}
