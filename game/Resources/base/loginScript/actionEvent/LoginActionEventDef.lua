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

Vip_Message_Begin		= 1700			--Vip
Vip_Message_End			= Vip_Message_Begin + 99

Sign_Message_Begin		=	1800
Sign_Message_End		=	Sign_Message_Begin + 99

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

Auction_Message_Begin	=	4000 

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
C2G_Charactor_Get	   		= Charactor_Message_Begin+1,--��ȡ������ɫ
G2C_Charactor_Get			= Charactor_Message_Begin + 2,--��ȡ�Ѵ�����ɫ
C2G_Charactor_Reg	   		= Charactor_Message_Begin + 3,--������ɫ
C2G_Charactor_Login	  		= Charactor_Message_Begin + 5,--������Ϸ
G2C_Charactor_Login	  		= Charactor_Message_Begin + 6,--��ҵĽ�ɫ��Ϣ����
C2G_Character_Delete		= Charactor_Message_Begin + 7,--ɾ����ɫ
G2C_Character_Delete		= Charactor_Message_Begin + 8,--ɾ����ɫ

----------------------------��ɫ----------------------------
G2C_Player_Attribute = G2C_Player_Begin + 1 ,
C2G_Player_Revive = G2C_Player_Begin + 11,
C2G_OtherPlayer_EquipList = G2C_Player_Begin + 21,
G2C_OtherPlayer_EquipList =	G2C_Player_Begin + 22,
C2G_OtherPlayer_Attribute = G2C_Player_Begin + 23,
G2C_OtherPlayer_Attribute = G2C_Player_Begin + 24,

----------------------------�³���Э��----------------------------
C2G_Scene_Sync_Time			=Scene_Message_Begin +1, --ͬ��ʱ��
G2C_Scene_Sync_Time			=Scene_Message_Begin +2, --ʱ��ͬ������
C2G_Scene_Start_Move		=Scene_Message_Begin +3, --��ʼ�ƶ�
C2G_Scene_Stop_Move			=Scene_Message_Begin +5, --�����ƶ�
C2G_Scene_Switch			=Scene_Message_Begin +51,--�����л�  switchId=	int-- ���͵�ID
G2C_Scene_Switch			=Scene_Message_Begin +52,-- ֪ͨ�����л����ͻ����յ���Ϣ���л����� sceneId= string -- ����ID x=int -- ����x y=int --����y
C2G_Scene_Ready				=Scene_Message_Begin +53,--�л�������ɣ��ͻ���ready������˲ſ��Է���AOI��Ϣ��ȥ
C2G_Scene_Transfer          =Scene_Message_Begin + 55,  --����
G2C_Scene_Reset_Position	=Scene_Message_Begin +58,--���ÿͻ����������
G2C_Scene_Player_State		=Scene_Message_Begin +65,--���״̬
G2C_Scene_AOI				=Scene_Message_Begin +72,--����AOI��Ϣ
C2G_Npc_Transfer			=Scene_Message_Begin +73,--NPC��ת 
C2G_Scene_PickUp          	=Scene_Message_Begin+81,--ʰȡ����
G2C_Op_Replay				=Global_Message_Begin,--
G2C_Player_Get				=Charactor_Message_Begin + 49,--��ȡ�����ɫ
G2C_Game_Version			=Charactor_Message_Begin + 61,--����������汾


C2G_Scene_StarttoPluck	=	Scene_Message_Begin + 85,		-- ��ʼ�ɼ� charId	=	string	// �ɼ���ID
G2C_Scene_StarttoPluck	=	Scene_Message_Begin + 86,		-- ��ʼ�ɼ����� charId	=	string	// �ɼ���ID
G2C_Scene_InterruptPluck = 	Scene_Message_Begin + 88,		-- ��ϲɼ�
G2C_Scene_SuccesstoPluck = 	Scene_Message_Begin + 87,		-- �ɹ��ɼ� 
G2C_Scene_State_Change	=  Scene_Message_Begin + 90,		-- ״̬����

C2G_Scene_StartoPluck 		= Scene_Message_Begin + 91;  -- ��ʼ�ɼ�  	NpcRefId     	String
G2C_Scene_StartoPluck 		= Scene_Message_Begin + 92;  -- �ɼ���ʼ��Ӧ
G2C_Server_Connect			= Charactor_Message_Begin +98, --���������ӽ��
G2C_Charactor_Prop_Update 	= Charactor_Message_Begin +53,--
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
C2G_Chat_Bugle 				= Chat_Message_Begin +7,  --������Ϣ
G2C_Chat_Bugle 				= Chat_Message_Begin +58,

----------------------------����----------------------------
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
--[[
		count			int
		name		String
		list
--]]			
		
C2G_Store_LimitItemReq		= Shop_Message_Begin + 5,			-- �޹���Ʒ����	byte  0�̳�  1 �̵�
G2C_Store_LimitItemResp		= Shop_Message_Begin + 6,			-- �޹���Ʒ����
--[[
		count		int
		name		String
--]]
C2G_Shop_BuyItemReq			= Shop_Message_Begin + 7,			-- �����޹���Ʒ����
--[[
		int (�̳�Ϊ1�� �̵�Ϊ2)
		1 ��
				itemRefId		String
				count			int
		2��
				NpcRefId		String
				shopID			String
				itemRefId		String
				count			int
--]]
G2C_Shop_BuyItemResp		= Shop_Message_Begin + 8,			-- �����޹���Ʒ����--	Result	byte

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

-------------------------------����-----------------------------
C2G_Talisman_List    = Talisman_Message_Begin + 1,	    --�����б�����
G2C_Talisman_List    = Talisman_Message_Begin + 2,		--�����б���
--[[
   count{
	 index	     = short
	 state		 = byte
	 talisRefId	 = string
	 tailManLevel= byte	
	}
--]]
C2G_Talisman_Active    = Talisman_Message_Begin + 3,	--������������
	--  type           = byte			--1��ȡ 2 ���� 3���� 
    --  index	       = short			--���ӵ�λ��
G2C_Talisman_Active    = Talisman_Message_Begin + 4,	--���������
	--  type           = byte			--1��ȡ 2 ���� 3���� 
    --  index	       = short			--���ӵ�λ��
C2G_Talisman_GetQuestReward = Talisman_Message_Begin+7;   --������������ȡ
--	type	  byte  (1�����            2������)
G2C_Talisman_GetQuestReward = Talisman_Message_Begin+8;   --��ȡ��������������
--	type	  byte  (1�����            2������)
--	Result = int  �����Ƿ�ɹ�

	
-----------------------------�ʼ�-----------------------------
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
G2C_Vip_State = Vip_Message_Begin + 2,--string   playerId       byte  vip�ȼ�    int Vipʣ������
C2G_Vip_AwardList = Vip_Message_Begin + 3,
G2C_Vip_AwardList = Vip_Message_Begin + 4,   -- 0  0  0
C2G_Vip_GetAward = Vip_Message_Begin + 5,

--����Э��
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

