require"data.scene.scene"
require("data.npc.npc")	
require"data.monster.monster"
require("data.item.propsItem")

QuestRecommendHandup = "QuestRecommendHandup"

QuestState =
{
eUnvisiableQuestState = 1, --任务不可见
eVisiableQuestState = 2, --任务仅可见
eAcceptableQuestState = 3,--任务可接
eAcceptedQuestState = 4,--任务已接，但未完成
eSubmittableQuestState = 5,--任务已经可提交。但还没提交
eCompletedQuestState = 6,--任务已经完成。已经提交领取奖励
}

QuestType =
{
eQuestTypeNone = 0,			--无类型
eQuestTypeMain = 1,			--主线
eQuestTypeDaily = 2,		--日常
eQuestTypeInstance = 3,		--副本
eQuestTypeStrengthen = 4,	--变强
}

--任务的动作类型
QuestOrderType =
{
eOrderNone = 0,--无类型
eOrderTypeKill = 1,--去哪个场景，杀什么怪，杀多少只。
eOrderTypeLoot = 2,--去哪个场景，杀什么怪物，抢什么东西，抢多少个？
eOrderTypeTalk = 3,--去哪个场景，跟谁对话。
eOrderTypeCollection = 4,--去哪个场景，什么目标(NPC),跟TA要什么东西，要多少个？PS：采集物属于NPC，采集其实是跟NPC对话，得到东西。
eOrderTypeTime = 9,--survivalOrder存活多长时间,winOrder在多长时间内，杀死所有怪通关,winbossOrder在多长时间内，杀死Boss
}

GameInstancerewardType = {
immediate = 1,
leave = 0,
}

DailyQuestSubType =
{
eDailyQuest = 1,	--日常任务
eGoldQuest = 2,		--金币任务
eMeritQuest = 3,	--功勋任务
}

QuestOrderEventType = {
eNone = 0,--无类型
eTransferInstanceEvent = 1,--进入副本类型(接受即传入副本)   
eMeritEvent = 2,--提升爵位类型 
eMountEvent = 3,--坐骑升级类型
ePassInstanceEvent = 4,--通关副本类型
eEnterInstanceEvent = 5,--进入副本类型（进入过副本即完成）
eWingEvent = 6,--翅膀升级类型
eShopEvent = 7,--商店购买类型
eBuffEvent = 8,--检测buff类型
eArenaEvent = 9,--竞技场任务类型
eWarehouseEvent = 10,--仓库任务类型
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
	local sStr = string.match(findStr,"{.-}")--找出第一个要替换的字符串
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
		sStr = string.match(findStr,"{.-}")	--找出下一个要替换的字符串
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
		local sStr = string.match(findStr,"{.-}")--找出第一个要替换的字符串
		while sStr do
			local changString = function (oldstr,changStr)	
				local orderString = DailyQusetChangString(questId,qType,index,randomType,changStr,bOverOrder)			
				return string.gsub(oldstr,changStr,orderString)
			end
			
			findStr =  changString(findStr,sStr)
			sStr = string.match(findStr,"{.-}")	--找出下一个要替换的字符串
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

--获取英雄职业性别
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

--通过场景id和npcid获取该npc坐标
function G_getNPCPosByOrderRefidAndSceneRefid(orderRefid,sceneRefid)
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()					
	local orderPosX,orderPosY = AutoPathMgr:findNpcXY(orderRefid,sceneRefid)
	if orderPosX and orderPosY then
		local orderPos = ccp(orderPosX,orderPosY)
		return orderPos
	end
end

--通过场景id和monsterid获取该monster坐标
function G_getMonsterPosByOrderRefidAndSceneRefid(orderRefid,sceneRefid)
	local AutoPathMgr = GameWorld.Instance:getAutoPathManager()					
	local orderPosX,orderPosY = AutoPathMgr:findMonsterXY(orderRefid,sceneRefid)
	if orderPosX and orderPosY then
		local orderPos = ccp(orderPosX,orderPosY)
		return orderPos		
	end
end