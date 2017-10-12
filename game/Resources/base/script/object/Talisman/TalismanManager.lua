require("common.baseclass")
require"object.Talisman.TalismanDef"
TalismanManager = TalismanManager or BaseClass()

function TalismanManager:__init()
	self.TalismanList = {}
	self.cittaLevel = 0	
end

function TalismanManager:clear()
	self:clearTalismanList()
end

function TalismanManager:requestGetAwardTalisman(ttype)
	if type(ttype) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_GetQuestReward)
		writer:WriteChar(ttype)
		simulator:sendTcpActionEventInLua(writer)
	end		
end	

--请求法宝列表
function TalismanManager:requestTalismanList()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_List)
	simulator:sendTcpActionEventInLua(writer)		
end

--法宝操作请求
function TalismanManager:requestActivateTalisman(ttype , index)
	if type(ttype) == "number" and type(index) == "number" then
		self.index = index
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_Active)
		writer:WriteChar(ttype)
		writer:WriteShort(index)
		simulator:sendTcpActionEventInLua(writer)	
	end	
end

--心法升级请求
function TalismanManager:requestCittaLevelUp()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Citta_LevelUp)
	simulator:sendTcpActionEventInLua(writer)
end

--被动法宝奖励领取请求
function TalismanManager:requestTalismanReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_Reward)
	simulator:sendTcpActionEventInLua(writer)
end

--被动法宝奖励数据请求
function TalismanManager:requestTalismanGetReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_GetReward)
	simulator:sendTcpActionEventInLua(writer)
end

function TalismanManager:requestTalismanStatistics()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Talisman_Statistics)
	simulator:sendTcpActionEventInLua(writer)	
end

function TalismanManager:clearTalismanList()
	if self.TalismanList then
		for _,v in pairs(self.TalismanList) do
			if v then
				v:DeleteMe()
			end
		end
		self.TalismanList = {}
	end
end

function TalismanManager:setCittaLevel(level)
	if type(level) == "number" then
		if level then
			self.cittaLevel = level
		end
	end
end

function TalismanManager:getCittaLevel()
	return self.cittaLevel
end

function TalismanManager:setCurTaliIndex(index)
	if type(index) == "number" then
		self.index = index	
	end
end

function TalismanManager:getTaliIndex()
	return self.index	
end

function TalismanManager:getTalismanList()
	return self.TalismanList
end

function TalismanManager:setTalismanList(list)
	if type(list) == "table" then	
		self.TalismanList = list
	end
end

function TalismanManager:getActiveTalisman()
	for k,v in pairs(self.TalismanList) do
		local index = v:getIndex()/2
		if math.ceil(index) == index then
			if v:getState() == 2 then
				return v
			end
		end
	end
end

function TalismanManager:getAwardList()
	return self.awardList
end

function TalismanManager:setAwardList(awardList)
	if type(awardList) == "table" then	
		self.awardList = awardList
	end
end

function TalismanManager:handleTalismSuipian(refId, count)

end