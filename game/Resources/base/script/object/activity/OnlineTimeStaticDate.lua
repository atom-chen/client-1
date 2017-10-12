require("data.activity.online")	
OnlineTimeStaticDate = OnlineTimeStaticDate or  BaseClass()

function OnlineTimeStaticDate:getTime(id)--获取时间

	local data = GameData.Online[id]
	if data then
		if data["property"] then		
			return data["property"]["onlineSecond"]		
		end
	end
end

function OnlineTimeStaticDate:getRewordLiset(refId)
	
	local data = GameData.Online[refId]
	if data then
		if data["onlineReward"] then
			--if data["onlineReward"]["AccumulateonlineReward"] then
				return data["onlineReward"]["AccumulateonlineReward"]
			--end
		end
	end
end

function OnlineTimeStaticDate:getOnlinePreRefId(refId)
	
	local data = GameData.Online[refId]
	if data then
		if data["property"] then		
			return data["property"]["onlinePreRefId"]		
		end
	end
end