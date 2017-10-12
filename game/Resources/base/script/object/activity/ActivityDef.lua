require "data.activity.sign"
require "data.activity.rideReward"
require "data.activity.levelUpReward"
require "data.activity.limitTimeRank"
require "data.activity.fund"
require "data.activity.teamBoss"

E_activityType = {
onlineTime = 1,--在线时长
dailyOnlineTime = 2,--每日累计
}

E_mapActivityType = {
mining = 1,-- 挖矿
monsterInvasion = 2,--怪物入侵
bossTemple = 3, --付费地宫

}

E_sendSeverRewardType = {--发送给服务器消息参数定义
onlineTime = 3,
dailyOnlineTime = 4,
}

E_identity = {	--VIP身份
	none  = 0,-- 非VIP
	bronzeVip = 1,-- 青铜VIP
	silverVip = 2,-- 白银VIP
	goldVip = 3,--黄金VIP
}

function G_GetSignAwardListByRefId(refId)
	local SignData = GameData.Sign
	local itemlist = SignData[refId].signData.rewardField.itemReward.itemList
	local propertyList = SignData[refId].signData.rewardField.propertyReward
	return itemlist,propertyList
end

function G_getSignCountReq(refId)
	local SignData = GameData.Sign
	local signCon = 99
	if SignData[refId] then
		signCon = SignData[refId].property.signCount
	end
	return signCon
end

function G_GetLevelAwardTableByTypeAndIndex(ttyp,index)

	local rideAward = GameData.RideReward
	local levelUpAward = GameData.LevelUpReward
	local reward = {}
	local refId	
	if ttyp == 1 then
		refId = "rideReward_" .. index
		if  rideAward[refId] then
			reward =  rideAward[refId].rideReward.rideReward
		end			
	else
		refId = "levelUpReward_" ..  index
		if levelUpAward[refId] then
			reward =  levelUpAward[refId].levelUpReward.levelUpReward	
		end
	end
	return reward
end

function G_GetLevelAwardDescTableByTypeAndIndex(ttyp,index)
	local rideAward = GameData.RideReward	
	local levelUpAward = GameData.LevelUpReward
	local descStr = " "
	local refId	
	if ttyp == 1 then
		refId = "rideReward_" .. index
		if rideAward[refId] then
			descStr = PropertyDictionary:get_description(rideAward[refId].property)
		end	 			
	else
		refId = "levelUpReward_" ..  index
		if levelUpAward[refId] then
			descStr =  PropertyDictionary:get_description(levelUpAward[refId].property)
		end
	end
	return descStr
end

function G_GetLimitRankLastRank(ttyp)
	local limitRankTable  = GameData.LimitTimeRank	
	local index = 0
	for k,v in pairs(limitRankTable) do
		if v.rankType == ttyp then
			index = index + 1
		end 	
	end

	local refId = "limitTimeRank_" .. ttyp .. "_" ..index
	
	if  limitRankTable[refId] then
		local sectionDesc  = limitRankTable[refId].rankInterval
		local index = string.find(sectionDesc,"-")
		local subStr = string.sub(sectionDesc,index+1)
		local low = string.match(subStr,"%d+")
		return low
	else
		return ""
	end
	
end

function G_GetLimitRankSectionDescStr(refId)
	local limitRankTable  = GameData.LimitTimeRank
	if  limitRankTable[refId] then
		local sectionDesc  = limitRankTable[refId].rankInterval
		local low = string.match(sectionDesc,"%d+")
		local index = string.find(sectionDesc,"-")
		local subStr = string.sub(sectionDesc,index+1)
		local high = string.match(subStr,"%d+")	
		local str
		if low == high then
			str = low
		else
			str = low .. "-" .. high
		end
		return Config.Words[13604] .. str .. Config.Words[13605] 
	else
		return ""
	end
end

function G_GetLimitRankAwardTable(refId)
	local reward = {}
	if  GameData.LimitTimeRank[refId] then
		reward = GameData.LimitTimeRank[refId].rankReward.rankReward
	end
	return reward
end

function G_GetPayActivityList()
	return GameData.PayActivity
end 

--倒计时时间(秒)转换字符
function G_GetSecondsToDateString(secTime)
	if type(secTime)=="number" and secTime~=nil then
	
	end
	local day =  math.floor(secTime/60/60/24)
	local hour = math.floor(secTime/60/60%24)
	local min = math.floor(secTime/60%60)
	local sec = math.floor(secTime%60)	
	
	local function GetDateToString(date)
		local s_date = ""
		if date < 10 then
			s_date = "0"..tostring(date)
		else
			s_date = tostring(date)
		end			
		return s_date
	end

	local s_day = GetDateToString(day)
	local s_hour = GetDateToString(hour)	
	local s_min = GetDateToString(min)
	local s_sec = GetDateToString(sec)
	
	return s_sec,s_min,s_hour,s_day
end

function G_GetFundSize()
	return table.size(GameData.Fund)
end

function G_GetFundRewardList(fundType)
	return GameData.Fund[fundType].giftData.giftData
end

function G_getFundPrice(fundType)
	local refId = "fund_" .. fundType
	if GameData.Fund[refId] then
		local priceType =  GameData.Fund[refId].moneyType.moneyType
		local price = GameData.Fund[refId].buyPrice.buyPrice 
		local worthPrice = GameData.Fund[refId].originalCost.originalCost 
		return priceType , price ,worthPrice
	else
		return 2, 999999, 999999
	end
end

function G_getTeamBossActivitySceneListByType(ttype)
	local sceneList = {}
	for k,v in pairs(GameData.TeamBoss)do
		if v.activityData[1].type == ttype then
			table.insert(sceneList , v.sceneRefId)
		end
	end
	return sceneList
end

function G_getTeamBossActivityLinkListByType(ttype)
	local linkList = {}
	for k,v in pairs(GameData.TeamBoss)do
		if v.activityData[1].type == ttype and  v.activityData[1].BossRefId ~= "" then
			local linkObj = {}
			linkObj.transfer = v.activityData[1].transfer.transferIn
			linkObj.bossRefId = v.activityData[1].BossRefId
			table.insert(linkList,linkObj)
		end
	end 
	return linkList
end
