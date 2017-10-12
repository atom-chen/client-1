require"data.scene.scene"
require("data.npc.npc")	
require"data.monster.monster"
require("data.item.propsItem")

QuestRecommendHandup = "QuestRecommendHandup"

QuestState =
{
eUnvisiableQuestState = 1, --���񲻿ɼ�
eVisiableQuestState = 2, --������ɼ�
eAcceptableQuestState = 3,--����ɽ�
eAcceptedQuestState = 4,--�����ѽӣ���δ���
eSubmittableQuestState = 5,--�����Ѿ����ύ������û�ύ
eCompletedQuestState = 6,--�����Ѿ���ɡ��Ѿ��ύ��ȡ����
}

QuestType =
{
eQuestTypeNone = 0,			--������
eQuestTypeMain = 1,			--����
eQuestTypeDaily = 2,		--�ճ�
eQuestTypeInstance = 3,		--����
eQuestTypeStrengthen = 4,	--��ǿ
}

--����Ķ�������
QuestOrderType =
{
eOrderNone = 0,--������
eOrderTypeKill = 1,--ȥ�ĸ�������ɱʲô�֣�ɱ����ֻ��
eOrderTypeLoot = 2,--ȥ�ĸ�������ɱʲô�����ʲô�����������ٸ���
eOrderTypeTalk = 3,--ȥ�ĸ���������˭�Ի���
eOrderTypeCollection = 4,--ȥ�ĸ�������ʲôĿ��(NPC),��TAҪʲô������Ҫ���ٸ���PS���ɼ�������NPC���ɼ���ʵ�Ǹ�NPC�Ի����õ�������
eOrderTypeTime = 9,--survivalOrder���೤ʱ��,winOrder�ڶ೤ʱ���ڣ�ɱ�����й�ͨ��,winbossOrder�ڶ೤ʱ���ڣ�ɱ��Boss
}

GameInstancerewardType = {
immediate = 1,
leave = 0,
}

DailyQuestSubType =
{
eDailyQuest = 1,	--�ճ�����
eGoldQuest = 2,		--�������
eMeritQuest = 3,	--��ѫ����
}

QuestOrderEventType = {
eNone = 0,--������
eTransferInstanceEvent = 1,--���븱������(���ܼ����븱��)   
eMeritEvent = 2,--������λ���� 
eMountEvent = 3,--������������
ePassInstanceEvent = 4,--ͨ�ظ�������
eEnterInstanceEvent = 5,--���븱�����ͣ��������������ɣ�
eWingEvent = 6,--�����������
eShopEvent = 7,--�̵깺������
eBuffEvent = 8,--���buff����
eArenaEvent = 9,--��������������
eWarehouseEvent = 10,--�ֿ���������
}
	
QuestFontColor = {	
order = "ColorGreen1"
}

ProfessionGenderTable =
	{
	[1] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderMale ,tIndex = 1},
	[2] ={tProfession = ModeType.ePlayerProfessionWarior,tGender = ModeType.eGenderFemale ,tIndex = 2},
	[3] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderMale ,tIndex = 3},
	[4] ={tProfession = ModeType.ePlayerProfessionMagic,tGender = ModeType.eGenderFemale ,tIndex = 4},
	[5] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderMale ,tIndex = 5},
	[6] ={tProfession = ModeType.ePlayerProfessionWarlock,tGender = ModeType.eGenderFemale ,tIndex = 6},
	}

function G_getQuestMgr()
	return  G_getHero():getQuestMgr()
end	
	
function G_getQuestLogicMgr()
	return  G_getHero():getQuestLogicMgr()
end	

function G_getQuestNPCStateMgr()
	return  G_getHero():getQuestNPCStateMgr()
end	

function G_QusetChangString (findStr)
	local sStr = string.match(findStr,"{.-}")--�ҳ���һ��Ҫ�滻���ַ���
	while sStr do
		local changString = function (oldstr,changStr)
			local orderString = ""
			local strScene = string.match(changStr,"S")
			if strScene ~= nil then
				local shead = string.match(changStr,"_.-}")
				local orderStr = string.sub(shead,2,-2)
				orderString = G_QusetChangStringScnce(orderStr,FSIZE("Size2"))
			end
			strNpc = string.match(changStr,"N")
			if strNpc ~= nil then
				local shead = string.match(changStr,"_.-}")
				local orderStr = string.sub(shead,2,-2)
				orderString = G_QusetChangStringNpc(orderStr)
			end
			return string.gsub(oldstr,changStr,orderString)
		end
		
		findStr =  changString(findStr,sStr)
		sStr = string.match(findStr,"{.-}")	--�ҳ���һ��Ҫ�滻���ַ���
	end
	
	return findStr
end

function G_QusetChangStringScnce(changStr,size)
	if not changStr then
		return "",0
	end
	
	local str,strSize
		
	if GameData.Scene[changStr]==nil then
		str = string.wrapRich(changStr,Config.FontColor[QuestFontColor.order],size)
		strSize = string.len(changStr)
	else
		if GameData.Scene[changStr]["property"]["name"]~=nil then
			local word = GameData.Scene[changStr]["property"]["name"]
			str = string.wrapHyperLinkRich(word,Config.FontColor[QuestFontColor.order],size,changStr,"false")
			strSize = string.len(word)
		end
	end
	return str,strSize
end

function G_QusetChangStringNpc(changStr,size)
	if not changStr then
		return "",0
	end
	
	local str,strSize
	
	if GameData.Npc[changStr]==nil then
		str = string.wrapRich(changStr,Config.FontColor["ColorGreen1"],size)
		strSize = string.len(changStr)
	else
		local word = GameData.Npc[changStr]["property"]["name"]
		str = string.wrapHyperLinkRich(word,Config.FontColor[QuestFontColor.order],size,changStr,"false")
		strSize = string.len(word)
	end
	return str,strSize
end

function G_DailyQusetChangString(questId,qType,index,randomType,findStr,bOverOrder)
	if findStr then
		local sStr = string.match(findStr,"{.-}")--�ҳ���һ��Ҫ�滻���ַ���
		while sStr do
			local changString = function (oldstr,changStr)	
				local orderString = DailyQusetChangString(questId,qType,index,randomType,changStr,bOverOrder)			
				return string.gsub(oldstr,changStr,orderString)
			end
			
			findStr =  changString(findStr,sStr)
			sStr = string.match(findStr,"{.-}")	--�ҳ���һ��Ҫ�滻���ַ���
		end
		local orderStr = string.wrapRich(findStr,Config.FontColor["ColorBlack1"],FSIZE("Size3"))
		return orderStr
	else
		return " "
	end
end

function DailyQusetChangString(questId,qType,index,randomType,str,bOverOrder)
	local orderString = ""
	if randomType==1 then	
		if str=="{number}" then
			if bOverOrder then
				orderString = QuestRefObj:getStaticDailyQusetOverOrderFieldKillCount(qType,questId,index)
			else
				orderString = QuestRefObj:getStaticQusetOrderFieldKillCount(qType,questId,index)	
			end			
		elseif str=="{monster}" then
			local monsterRefId 
			if bOverOrder then
				monsterRefId = QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(qType,questId,index)
			else
				monsterRefId = QuestRefObj:getStaticQusetOrderFieldMonsterRefId(qType,questId,index)
			end
			
			orderString = PropertyDictionary:get_name(GameData.Monster[monsterRefId]["property"])
		end
	elseif randomType==2 or  randomType==4 then
	
		if str=="{number}" then
			if bOverOrder then
				orderString = QuestRefObj:getStaticQusetOrderFieldItemCount(qType,questId,index)
			else
				orderString = QuestRefObj:getStaticQusetOrderFieldItemCount(qType,questId,index)	
			end				
		elseif str=="{item}" then
			local itemRefId = QuestRefObj:getStaticQusetOrderFieldItemRefId(qType,questId,index)		
			orderString = PropertyDictionary:get_name( GameData.PropsItem[itemRefId]["property"])
		end	
	elseif randomType==3 then
		if str=="{scene}" then
			local sceneRefId
			if bOverOrder then
				sceneRefId  = QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(qType,questId,index)
			else
				sceneRefId  = QuestRefObj:getStaticQusetOrderFieldSceneRefId(qType,questId,index)
			end
					
			orderString = PropertyDictionary:get_name( GameData.Scene[sceneRefId]["property"])
		elseif str=="{NPC}" then

			local NPCRefId = QuestRefObj:getStaticQusetOrderFieldNPCRefId(qType,questId,index)	
			orderString	= PropertyDictionary:get_name( GameData.Npc[sceneRefId]["property"])
		end	
	end		
	return orderString
end

--��ȡӢ��ְҵ�Ա�
function G_getHeroProfessionGender()
	local heroPt = GameWorld.Instance:getEntityManager():getHero():getPT()
	local professionId = PropertyDictionary:get_professionId(heroPt)		
	local genderId = PropertyDictionary:get_gender(heroPt)
	for i,v in pairs(ProfessionGenderTable) do
		local tprofession  = v.tProfession
		local tgender  = v.tGender
		if tprofession == professionId and genderId ==tgender then
			return v.tIndex
		end
	end
end

--ͨ������id��npcid��ȡ��npc����
function G_getNPCPosByOrderRefidAndSceneRefid(orderRefid,sceneRefid)
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()					
	local orderPosX,orderPosY = AutoPathMgr:findNpcXY(orderRefid,sceneRefid)
	if orderPosX and orderPosY then
		local orderPos = ccp(orderPosX,orderPosY)
		return orderPos
	end
end

--ͨ������id��monsterid��ȡ��monster����
function G_getMonsterPosByOrderRefidAndSceneRefid(orderRefid,sceneRefid)
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()					
	local orderPosX,orderPosY = AutoPathMgr:findMonsterXY(orderRefid,sceneRefid)
	if orderPosX and orderPosY then
		local orderPos = ccp(orderPosX,orderPosY)
		return orderPos		
	end
end