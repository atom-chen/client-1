require("data.quest.plotQuest")
require("data.quest.dailyQuest")
require("data.quest.sectionQuest")
require("data.vip.vip")
require("object.quest.QusetInstanceRefObj")
QuestRefObj = QuestRefObj or  BaseClass()

--------------------------------------------------------------------------------
function QuestRefObj:getStaticQuset(qType,questId)--获取静态数据-总表
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]
		end
	end
end
--------------------------------------------------------------------------------
function QuestRefObj:getStaticQusetProperty(qType,questId)--获取静态数据-属性
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			return GameData.PlotQuest[questId]["property"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["property"]
		end
	elseif qType==QuestType.eQuestTypeStrengthen then
		if GameData.SectionQuest[questId]~=nil then
			return GameData.SectionQuest[questId]["property"]
		end
	end
end

function QuestRefObj:getStaticQusetPropertyQuestName(qType,questId,ins)--获取静态数据-任务名称
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			return GameData.PlotQuest[questId]["property"]["name"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["property"]["name"]
		end
	elseif qType==QuestType.eQuestTypeInstance then
		 return QuestInstanceRefObj:getStaticQusetPropertyQuestName(ins,questId)
	elseif qType==QuestType.eQuestTypeStrengthen then
		if GameData.SectionQuest[questId]~=nil then
			return GameData.SectionQuest[questId]["property"]["name"]
		end
	end
	
end

function QuestRefObj:getStaticQusetNextQuest(qType,questId)
	local data = self:getStaticQusetProperty(qType,questId)
	if data then
		return data.nextQuestId
	end
end


function QuestRefObj:getStaticQusetPropertyQuestType(qType,questId)--获取静态数据-任务类型
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			return GameData.PlotQuest[questId]["property"]["questType"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["property"]["questType"]
		end
	end
end
--------------------------------------------------------------------------------
function QuestRefObj:getStaticQusetConditionField(qType,questId)--获取静态数据-条件
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["conditionField"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["questData"]["conditionField"]
		end
	end
end

function QuestRefObj:getStaticQusetConditionFieldAcceptLevel(qType,questId)--获取静态数据-条件
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["conditionField"][2]["acceptLevel"]--需修改
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["questData"]["conditionField"][1]["acceptLevel"]
		end
	end
end
--------------------------------------------------------------------------------
function QuestRefObj:getStaticQusetOrderField(qType,questId)--获取静态数据-目标
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["orderField"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["questData"]["orderField"]
		end
	end
end

function QuestRefObj:getStaticQusetOrderFieldType(qType,questId,index,ins)--获取静态数据-任务目标类型
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
			return GameData.PlotQuest[questId]["questData"]["orderField"][index]["orderType"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
			return GameData.DailyQuest[questId]["questData"]["orderField"][index]["orderType"]
		end
	elseif qType==QuestType.eQuestTypeInstance then
		return QuestInstanceRefObj:getStaticQusetOrderFieldType(ins,questId,index)
	end
end

function QuestRefObj:getStaticQusetOrderFieldSceneRefId(qType,questId,index)--获取静态数据-任务目标场景id
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				local scene = GameData.PlotQuest[questId]["questData"]["orderField"][index]["sceneRefId"]
				local newScene = G_getQuestLogicMgr():getDistributaryScene(scene)
				return newScene
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["sceneRefId"]
			end
		end
	end		
end

function QuestRefObj:getStaticDailyQusetOverOrderFieldSceneRefId(qType,questId,index)--获取静态数据-日常任务推荐环外目标场景id
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
	if data then
		if data["questData"] then
			if data["questData"]["overOrderField"] then
				if data["questData"]["overOrderField"][index] then
					return data["questData"]["overOrderField"][index]["sceneRefId"]
				end
			end
		end
	end
	end
end

function QuestRefObj:getStaticQusetOrderFieldNPCRefId(qType,questId,index)--获取静态数据-任务目标NPCid
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["NPCRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["NPCRefId"]
			end
		end
	end		
end


function QuestRefObj:getStaticQusetOrderFieldKillCount(qType,questId,index,ins)--获取静态数据-任务目标杀怪总数
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["killCount"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["killCount"]
			end
		end
	elseif qType==QuestType.eQuestTypeInstance then
		return QuestInstanceRefObj:getStaticQusetOrderFieldKillCount(ins,questId,index)
	end		
end

function QuestRefObj:getStaticDailyQusetOverOrderFieldKillCount(qType,questId,index)--获取静态数据-日常任务推荐环外杀怪总数
	if qType==QuestType.eQuestTypeDaily then	
		local data = GameData.DailyQuest[questId]
		if data then
			if data["questData"] then
				if data["questData"]["overOrderField"][index] then
					return data["questData"]["overOrderField"][index]["killCount"]
				end
			end
		end
	end
end

function QuestRefObj:getStaticQusetOrderFieldItemCount(qType,questId,index)--获取静态数据-任务目标物品总数
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["itemCount"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["itemCount"]
			end
		end
	end		
end

function QuestRefObj:getStaticQusetOrderFieldBuyItemName(qType,questId,index)--获取静态数据-任务购买物品名称
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["buyItem"]
			end
		end
	end		
end

function QuestRefObj:getStaticQusetOrderFieldBuyItemCount(qType,questId,index)--获取静态数据-任务购买物品总数
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["buyNum"]
			end
		end
	end		
end

function QuestRefObj:getStaticQusetOrderFieldMonsterRefId(qType,questId,index,ins)--获取静态数据-任务目标怪物id
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["monsterRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["monsterRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeInstance then
		return QuestInstanceRefObj:getStaticQusetOrderFieldMonsterRefId(ins,questId,index)
	end
end

function QuestRefObj:getStaticDailyQusetOverOrderFieldMonsterRefId(qType,questId,index)
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if data["questData"] then
				if data["questData"]["overOrderField"] then
					if data["questData"]["overOrderField"][index] then
						return data["questData"]["overOrderField"][index]["monsterRefId"]
					end
				end
			end
		end
	end
end

function QuestRefObj:getStaticQusetOrderFieldItemRefId(qType,questId,index)--获取静态数据-任务目标物品id
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.PlotQuest[questId]["questData"]["orderField"][index]["itemRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index]~=nil then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["itemRefId"]
			end
		end
	end
end	

function QuestRefObj:getStaticQusetOrderFieldItemNpcRefId(qType,questId,index)--获取静态数据-任务目标物品Npcid
	if qType==QuestType.eQuestTypeMain then
		local data =  GameData.PlotQuest[questId]
		if data~=nil then
			if data["questData"]["orderField"][index]~=nil then
				return data["questData"]["orderField"][index]["npcRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		local data =  GameData.DailyQuest[questId]
		if data then
			if data["questData"]["orderField"][index]~=nil then
				return data["questData"]["orderField"][index]["npcRefId"]
			end
		end
	end
end	

--------------------------------------------------------------------------------
function QuestRefObj:getStaticQusetRewardField(qType,questId)--获取静态数据-奖励
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["rewardField"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId]~=nil then
			return GameData.DailyQuest[questId]["questData"]["rewardField"]
		end
	elseif qType==QuestType.eQuestTypeStrengthen then	--变强任务
		if GameData.SectionQuest[questId]~=nil then
			return GameData.SectionQuest[questId]["questData"]["rewardField"]
		end
	end
end

function QuestRefObj:getStaticQusetRewardProperty(qType,questId,ins)--获取静态数据-属性奖励
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["rewardField"]["propertyReward"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			return GameData.DailyQuest[questId]["questData"]["rewardField"]["propertyReward"]
		end
	elseif qType==QuestType.eQuestTypeInstance then
		return QuestInstanceRefObj:getStaticQusetRewardProperty(ins,questId)
	end
end

function QuestRefObj:getStaticQusetItemReward(qType,questId,ins)--获取静态数据-道具奖励
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["rewardField"]["itemReward"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			return GameData.DailyQuest[questId]["questData"]["rewardField"]["itemReward"]
		end
	elseif qType==QuestType.eQuestTypeInstance then
		return QuestInstanceRefObj:getStaticQusetItemReward(ins,questId)
	end
end

function QuestRefObj:getStaticQusetRewardFieldExp(qType,questId,ins)--获取静态数据-经验奖励
	local data = self:getStaticQusetRewardProperty(qType,questId,ins)
	if data then
		return data.exp
	end
end	

function QuestRefObj:getStaticDailyQusetLastRewardProperty(qType,questId)--获取日常任务静态数据-最后环属性奖励
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if  data["questData"]["lastRewardField"] then
				return data["questData"]["lastRewardField"]["propertyReward"]
			end				
		end	
	end
end

function QuestRefObj:getStaticDailyQusetLastRewardItem(qType,questId)--获取日常任务静态数据-最后环道具奖励
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if  data["questData"]["lastRewardField"] then
				return data["questData"]["lastRewardField"]["itemReward"]
			end				
		end	
	end
end

function QuestRefObj:getStaticDailyQusetLastRewardShowItem(qType,questId)--获取日常任务静态数据-最后环道具提示奖励
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if  data["questData"]["lastRewardFieldShow"] then
				if data["questData"]["lastRewardFieldShow"]["itemReward"] then
					return data["questData"]["lastRewardFieldShow"]["itemReward"]["itemList"]
				end					
			end				
		end	
	end
end

function QuestRefObj:getStaticDailyQusetOverOrderRewardProperty(qType,questId)--获取日常任务静态数据-无限任务推荐环外的属性奖励
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if  data["questData"]["overOrderRewarField"] then
				return data["questData"]["overOrderRewarField"]["propertyReward"]
			end				
		end	
	end
end

function QuestRefObj:getStaticDailyQusetOverOrderRewardItem(qType,questId)--获取日常任务静态数据-无限任务推荐环外的道具奖励
	if qType==QuestType.eQuestTypeDaily then
		local data = GameData.DailyQuest[questId]
		if data then
			if  data["questData"]["overOrderRewarField"] then
				return data["questData"]["overOrderRewarField"]["itemReward"]
			end				
		end	
	end
end

--------------------------------------------------------------------------------

function QuestRefObj:getStaticQusetNpcField(qType,questId)--获取静态数据-NPC
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			return GameData.PlotQuest[questId]["questData"]["npcField"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			return GameData.DailyQuest[questId]["questData"]["npcField"]
		end
	end
end

function QuestRefObj:getStaticQusetNpcFieldAcceptNpc(qType,questId)--获取静态数据-NPC可接任务
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId] then
			return GameData.PlotQuest[questId]["questData"]["npcField"]["acceptNpc"]
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			return GameData.DailyQuest[questId]["questData"]["npcField"]["acceptNpc"]
		end
	end
end

function QuestRefObj:getStaticQusetNpcFieldNcRefId(qType,questId,state)--获取静态数据-任务NPCid
	if qType==QuestType.eQuestTypeMain then
		if GameData.PlotQuest[questId]~=nil then
			
			if GameData.PlotQuest[questId]["questData"]["npcField"][state]~=nil then
				return GameData.PlotQuest[questId]["questData"]["npcField"][state]["npcRefId"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["npcField"][state] then
				return GameData.DailyQuest[questId]["questData"]["npcField"][state]["npcRefId"]
			end
		end
	end
	
end

function QuestRefObj:getStaticQusetNpcFieldSceneRefId(qType,questId,state)--获取静态数据-任务Sceneid
	if GameData.PlotQuest[questId]~=nil then
		if GameData.PlotQuest[questId] then
			if GameData.PlotQuest[questId]["questData"]["npcField"] then
				if GameData.PlotQuest[questId]["questData"]["npcField"][state] then
					local scene = GameData.PlotQuest[questId]["questData"]["npcField"][state]["sceneRefId"]
					local newScene = G_getQuestLogicMgr():getDistributaryScene(scene)
					return newScene
				end
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["npcField"] then
				if GameData.DailyQuest[questId]["questData"]["npcField"][state] then
					return GameData.DailyQuest[questId]["questData"]["npcField"][state]["sceneRefId"]
				end
			end
		end
		
	end
	
end

function QuestRefObj:getStaticQusetNpcFieldTalkContent(qType,questId,state)--获取静态数据-任务talkContent
	if GameData.PlotQuest[questId]~=nil then
		if GameData.PlotQuest[questId]~=nil then
			if GameData.PlotQuest[questId]["questData"]["npcField"][state]~=nil then
				return GameData.PlotQuest[questId]["questData"]["npcField"][state]["talkContent"]
			end
		end
	elseif qType==QuestType.eQuestTypeDaily then
		if GameData.DailyQuest[questId] then
			if GameData.DailyQuest[questId]["questData"]["npcField"][state] then
				return GameData.DailyQuest[questId]["questData"]["npcField"][state]["talkContent"]
			end
		end
	elseif qType==QuestType.eQuestTypeStrengthen then
		if GameData.SectionQuest[questId] then
			if GameData.SectionQuest[questId]["questData"]["npcField"][state] then
				return GameData.SectionQuest[questId]["questData"]["npcField"][state]["talkContent"]
			end
		end
	end
end

--日常任务描述
function QuestRefObj:getStaticDailyQusetDescription(questId,index)
	if GameData.DailyQuest[questId] then
		if GameData.DailyQuest[questId]["description"] then
		return GameData.DailyQuest[questId]["description"][index]
		end		
	end
end

--主线任务描叙
function QuestRefObj:getStaticMainQusetDescription(questId)
	if GameData.PlotQuest[questId] then
		local pt =  GameData.PlotQuest[questId].property
		if pt then		
			return PropertyDictionary:get_description(pt)
		end		
	end
end


--日常任务获取最大环数
function QuestRefObj:getStaticDailyQusetMaxRing(questId)
	if GameData.DailyQuest[questId] then
		if GameData.DailyQuest[questId]["property"] then
			local maxRing =	GameData.DailyQuest[questId]["property"]["dailyProposeRing"]	
			--VIP额外日常环数		
			local vipLevel = GameWorld.Instance:getVipManager():getVipLevel()
			if vipLevel and maxRing and vipLevel > 0 then
				maxRing = maxRing + self:getStaticDailyExtraRing(vipLevel)	
			end 
			return maxRing
		end		
	end
end

--VIP额外日常环数
function QuestRefObj:getStaticDailyExtraRing(vipLevel)
	local refId = "vip_" .. vipLevel
	if GameData.Vip[refId] then
		if GameData.Vip[refId].property then
			return PropertyDictionary:get_dailyProposeRing(GameData.Vip[refId].property)
		end		
	end
	return 0
end



--日常任务获取任务重复类型
function QuestRefObj:getStaticDailyQusetRepeatType(questId)
	if GameData.DailyQuest[questId] then
		if GameData.DailyQuest[questId]["property"] then
			return GameData.DailyQuest[questId]["property"]["dailyQuestType"]
		end		
	end
end	

--日常任务获取任务目标类型
function QuestRefObj:getStaticDailyQusetOrderType(questId,index)
	if GameData.DailyQuest[questId] then
		if GameData.DailyQuest[questId]["questData"]["orderField"] then
			if GameData.DailyQuest[questId]["questData"]["orderField"][index] then
				return GameData.DailyQuest[questId]["questData"]["orderField"][index]["orderType"]
			end				
		end		
	end
end	

--日常任务获取任务附加类型
function QuestRefObj:getStaticDailyQusetSubType(questId)
	local data = GameData.DailyQuest[questId]
	if data then
		if data["dailyQuestSubType"] then
			return data["dailyQuestSubType"]["dailyQuestSubType"]
		end
	end
end

--获取附加目标Id
function QuestRefObj:getOrderEventId(questType,questId)
	local field = self:getStaticQusetOrderField(questType,questId)
	if field  and field[1] then
		return field[1].orderEventId
	end
	return nil
end

--获取附加目标Id
function QuestRefObj:getOrderBuyItem(questType,questId)
	local field = self:getStaticQusetOrderField(questType,questId)
	if field  and field[1] then
		return field[1].buyItem
	end
	return nil
end

--------------------------------------------------------------------------------
function QuestRefObj:getStaticQusetRelatedType(rewardTable)
	return  rewardTable["relatedType"]
end

function QuestRefObj:getStaticQusetProfessionItemList(itemReward,profession)
	local professionList =  itemReward["professionList"]
	if professionList then
		for i,v in pairs(professionList) do
			local index = v.proffessionRefId
			if profession == index then
				return  v.itemList
			end
		end			
	end		
end

function QuestRefObj:getStaticQusetItemList(itemReward)
	return  itemReward["itemList"]
end

function QuestRefObj:getStaticQusetItemListIsBinded(itemList)
	return  itemList["isBinded"]
end

function QuestRefObj:getStaticQusetItemListItemCount(itemList)
	return  itemList["itemCount"]
end

function QuestRefObj:getStaticQusetItemListItemRefId(itemList)
	return  itemList["itemRefId"]
end

function QuestRefObj:getNewGuidelinesByQuestId(questId)
	local list = GameData.NewGuidelines[questId]
	if list then
		return list.stepfirst
	end
end
