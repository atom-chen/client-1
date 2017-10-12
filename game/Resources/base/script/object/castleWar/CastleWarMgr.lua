--沙巴克攻城管理器
require("common.baseclass")
require("data.castleWar.castleWar")

CastleWarMgr = CastleWarMgr or BaseClass()

local g_simulator = nil

function CastleWarMgr:__init()
	g_simulator = SFGameSimulator:sharedGameSimulator()	
	self.openServerTime = os.time()	--开服时间
	self:clear()
end	

function CastleWarMgr:__delete()

end

function CastleWarMgr:clear()
	self.isInCastleWarTime = false		--是否处在沙巴克攻城的时间段	
	self.castleWarFactionList = {} 		--保存申请攻城的公会队伍	
	self.castleWarSceneName = nil	
	self.castleWarBossUnionName = nil	--沙巴克攻城boss的所属公会名字
	self.bIsInCastleWar = false
end

function CastleWarMgr:setOpenServerTime(time)
	if type(time) == "number" then
		print("set open server time="..time)
		self.openServerTime = time
	end
end

function CastleWarMgr:getOpenServerTime()
	return self.openServerTime
end

--return the start and end time as string
function CastleWarMgr:getNextWarTime()
	local startTimeStr = ""
	local endTimeStr = ""
	local data = GameData.CastleWar.castleWar.activityData.castleWar_1.openAndEndTime
	local timePair = string.split(data, "|")
	if table.size(timePair) ~= 2 then
		return startTimeStr, endTimeStr
	end
	startTimeStr = timePair[1]
	endTimeStr = timePair[2]
	
	local curTime = os.time()	
	if type(self.openServerTime) ~= "number" or self.openServerTime > curTime or self.openServerTime <= 0 then
		CCLuaLog("CastleWarMgr:getNextWarTime warning. self.openServerTime="..tostring(self.openServerTime))
		return startTimeStr, endTimeStr
	end 
	
	local openServerDate = os.date("*t", self.openServerTime) 
	local openServerTime1 = os.time{year = openServerDate.year, month = openServerDate.month, day = openServerDate.day, hour = 0, min = 0, sec = 0}
	local curDate = os.date("*t", curTime)
	local curTime1 = os.time{year = curDate.year, month = curDate.month, day = curDate.day, hour = 0, min = 0, sec = 0}
	
	local firstIntervalDays = GameData.CastleWar.castleWar.activityData.castleWar_1.firstIntervalDays
	local rangeIntervalDays = GameData.CastleWar.castleWar.activityData.castleWar_1.rangeIntervalDays	
	if rangeIntervalDays == 0 then
		CCLuaLog("Fuck! CastleWarMgr:getNextWarTime rangeIntervalDays == 0")
		rangeIntervalDays = 3
	end
		
	local nextDay = 0
	local diff = (curTime1 - openServerTime1) / (60 * 60 * 24)
	if diff < 0 then
		nextDay = openServerDate.day + firstIntervalDays
	else			
		nextDay = openServerDate.day + firstIntervalDays + (math.floor(diff / rangeIntervalDays)) * rangeIntervalDays		
	end
	
	local startT = string.split(startTimeStr, ":")
	if table.size(startT) ~= 3 then
		return startTimeStr, endTimeStr
	end
	
	local startHour = tonumber(startT[1])
	local startMin = tonumber(startT[2])
	local startSec = tonumber(startT[3])
	if (not startHour) or (not startMin) or (not startSec) then
		return startTimeStr, endTimeStr
	end
	
	local endT = string.split(endTimeStr, ":")
	if table.size(endT) ~= 3 then
		return startTimeStr, endTimeStr
	end
	local endHour = tonumber(endT[1])
	local endMin = tonumber(endT[2])
	local endSec = tonumber(endT[3])
	if (not endHour) or (not endMin) or (not endSec) then
		return startTimeStr, endTimeStr
	end

	local startTime = os.time{year = openServerDate.year, month = openServerDate.month, day = nextDay, hour = startHour, min = startMin, sec = startSec}
	local endTime = os.time{year = openServerDate.year, month = openServerDate.month, day = nextDay, hour = endHour, min = endMin, sec = endSec}
	if curTime > endTime then
		startTime = startTime + rangeIntervalDays * (60 * 60 * 24)
		endTime = endTime + rangeIntervalDays * (60 * 60 * 24)
	end
	
	local date1 = os.date("*t", startTime)
	local date2 = os.date("*t", endTime)

	startTimeStr = string.format(Config.Words[18012], date1.month, date1.day, startTimeStr)
	endTimeStr = string.format(Config.Words[18012], date2.month, date2.day, endTimeStr)
	return startTimeStr, endTimeStr
end

function CastleWarMgr:updateCastleWarState()
	local is = self.bIsInCastleWar
	self.bIsInCastleWar = self:isInCastleWar()	
	if is ~= self.bIsInCastleWar then
		GlobalEventSystem:Fire(GameEvent.EventCastleWarStateChanged, self.bIsInCastleWar)
	end
end

function CastleWarMgr:isInCastleWar()
	return (self:isInCastleWarScene() and self:getIsInCastleWarTime())
end

--获取沙巴克攻城地图
function CastleWarMgr:getCastleWarScene()
	if not self.castleWarSceneName then
		local data = GameData.CastleWar["castleWar"].activityData.castleWar_1
		if not data then
			return nil
		end
		self.castleWarSceneName = data.castleData.transfer.warMap.targetScene
	end
	return self.castleWarSceneName
end

function CastleWarMgr:getDamolongchengRefId()
	return "S009"
end

function CastleWarMgr:setCastleWarBossUnionName(name)
	self.castleWarBossUnionName = name
end

function CastleWarMgr:getCastleWarBossUnionName()
	return self.castleWarBossUnionName
end

--测试用
function CastleWarMgr:setCastleWarScene(scene)
	self.castleWarSceneName = scene
end

--是否正在沙巴克攻城攻城场景里
function CastleWarMgr:isInCastleWarScene()
	return (GameWorld.Instance:getMapManager():getCurrentMapRefId() == self:getCastleWarScene())
end

--设置是否处于沙巴克攻城时间内
function CastleWarMgr:setIsInCastleWarTime(is)
	self.isInCastleWarTime = is
	self:updateCastleWarState()
end

--获取是否处于沙巴克攻城时间内
function CastleWarMgr:getIsInCastleWarTime()
	return self.isInCastleWarTime
end

function CastleWarMgr:checkCanApplyCastleWar()
	local unionOfficialId = PropertyDictionary:get_unionOfficialId(G_getHero():getPT())
	if unionOfficialId ~= 1 then
		local des = Config.Words[18007]
		return false, des
	else
		return true
	end
end	


--list: [1] = {name = "",}
function CastleWarMgr:setCastleWarFactionList(list)
	if type(list) ~= "table" then
		self.castleWarFactionList = list
	end
end

--请求加入沙巴克攻城
function CastleWarMgr:requestJoinWar()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_JoinWar)
	g_simulator:sendTcpActionEventInLua(writer)	
end

--请求领取王城礼包
function CastleWarMgr:requestGetGift()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_GetGift)
	g_simulator:sendTcpActionEventInLua(writer)		
end

--请求进入沙巴克副本
function CastleWarMgr:requestCastleWarInstance()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_Instance)
	g_simulator:sendTcpActionEventInLua(writer)		
end

--请求参加攻城战公会列表
function CastleWarMgr:requestCastleWarFactionList()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_FactionList)
	g_simulator:sendTcpActionEventInLua(writer)		
end

function CastleWarMgr:requestOpenServerTime()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_OpenServerTime)
	g_simulator:sendTcpActionEventInLua(writer)		
end
		
function CastleWarMgr:requestCastleWarTime()
	local writer = g_simulator:getBinaryWriter(ActionEvents.C2G_CastleWar_RequestTime)
	g_simulator:sendTcpActionEventInLua(writer)		
end

function CastleWarMgr:clear()
	self.castleWarFactionList = {}
	self.isInCastleWarTime = false
end