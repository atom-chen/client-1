require("common.BaseObj")
require("object.vip.VipDef")
GameInstanceObject = GameInstanceObject or BaseClass(BaseObj)

function GameInstanceObject:__init()
		self.countInDay = -1
		self.countInWeek = -1
		self.index = nil
end

function GameInstanceObject:__delete()
	
end

function GameInstanceObject:setIndex(index)
	self.index = index
end

function GameInstanceObject:getIndex()
	return self.index
end

function GameInstanceObject:setCountInDay(count)
	self.countInDay = count
end

function GameInstanceObject:setCountInWeek(count)
	self.countInWeek  = count
end

function GameInstanceObject:getCountInDay()
	return self.countInDay
end

function GameInstanceObject:getCountInWeek()
	return self.countInWeek
end

function GameInstanceObject:getBossIconRef()
	local bossIconRef = "ins_boss"
	local num
	return bossIconRef
end

function GameInstanceObject:getCountShowingWord()
	local instanceData = GameData[self.refId]
	local maxCount = 0
	if instanceData then
		local data = instanceData[self.refId]
		if data then
			local configData = data["configData"]
			if configData then
				local instance = configData["game_instance"]
				if instance then
					local iConfigData = instance["configData"]
					if iConfigData then
						local iData = iConfigData[self.refId]
						if iData then
							local property = iData["property"]
							if property then
								maxCount = property["timesADay"]
							end
						end
					end
				end
			end
		end
	end
	local vipLevel = GameWorld.Instance:getVipManager():getVipLevel()
	local vipCount = G_GetVipDescriptionByTimesADay(vipLevel)	
	
	local str = ""
	if vipCount~=0 then

		local numstr = string.wrapRich(self.countInDay.."/"..maxCount.."+"..vipCount,Config.FontColor["ColorRed1"],FSIZE("Size3"))
		local wordstr = string.wrapHyperLinkRich("("..Config.Words[1510]..")",Config.FontColor["ColorRed1"],FSIZE("Size3"),"data","true")	
		str = numstr.." "..wordstr
	else
		local numstr = string.wrapRich(self.countInDay.."/"..maxCount.."+",Config.FontColor["ColorRed1"],FSIZE("Size3"))
		local wordstr = string.wrapHyperLinkRich(Config.Words[1511]	,Config.FontColor["ColorRed1"],FSIZE("Size3"),"data","true")	
		str = numstr..wordstr
	end		
	return str
end

function GameInstanceObject:getInstanceName()
	local instanceData = GameData[self.refId]
	local name = nil
	if instanceData then
		local data = instanceData[self.refId]
		if data then
			name = data["name"]
		end
	end		
	return name
end

function GameInstanceObject:getInstanceDescription()
	local instanceData = GameData[self.refId]
	local introduce = nil
	if instanceData then
		local data = instanceData[self.refId]
		if data then
			introduce = data["introduce"]
		end
	end		
	return introduce
end

function GameInstanceObject:setOpenLevel()
	local instanceData = GameData[self.refId]	
	if instanceData then
		local data = instanceData[self.refId]
		if data then
			local configData = data["configData"]
			if configData then
				local instance = configData["game_instance"]
				if instance then
					local iConfigData = instance["configData"]
					if iConfigData then
						local iData = iConfigData[self.refId]
						if iData then
							local property = iData["property"]
							if property then
								self.level=property["level"]
							end
						end
					end
				end
			end
		end
	end		
end

function GameInstanceObject:getOpenLevel()
	return self.level
end

function GameInstanceObject:setLevelState(levelState)
	self.levelState = levelState
end

function GameInstanceObject:getLevelState()
	return self.levelState
end

function GameInstanceObject:getSuggestlevel()
	local instanceData = GameData[self.refId]
	if instanceData then
		local data = instanceData[self.refId]
		if data then
			return data["suggestlevel"]
		end
	end
end