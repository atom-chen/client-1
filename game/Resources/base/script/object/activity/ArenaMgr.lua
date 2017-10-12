require("common.baseclass")
require("actionEvent.ActionEventDef")
require("object.activity.ArenaObject")
require("ui.UIManager")

ArenaMgr = ArenaMgr or BaseClass()

function ArenaMgr:__init()
	self.arenaObject = ArenaObject.New()
	self.openLevel = 35 --没有数据表，暂时写死开发等级
end

function ArenaMgr:clear()
	if self.arenaObject then
		self.arenaObject:DeleteMe()
		self.arenaObject = nil
	end	
end	

function ArenaMgr:getArenaObject()
	if self.arenaObject == nil then
		self.arenaObject = ArenaObject.New()
	end
	return self.arenaObject
end	

function ArenaMgr:requestCanReceive()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_CanReceive)
	simulator:sendTcpActionEventInLua(writer)
end

function ArenaMgr:requestShowArenaView()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_ShowArenaView)
	simulator:sendTcpActionEventInLua(writer)
end	

function ArenaMgr:requestReceiveReward()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_ReceiveReward)
	simulator:sendTcpActionEventInLua(writer)
end

function ArenaMgr:requestChallenge(rank)
	if type(rank) == "number" then
		local simulator = SFGameSimulator:sharedGameSimulator()
		local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_Challenge)
		StreamDataAdapter:WriteInt(writer, rank)
		simulator:sendTcpActionEventInLua(writer)
	end
end

function ArenaMgr:requestChallengeResult()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_Challenge_Award)
	simulator:sendTcpActionEventInLua(writer)
end

function ArenaMgr:requestSeeLadder()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Ladder_Select)
	simulator:sendTcpActionEventInLua(writer)
end

function ArenaMgr:requestClearCDTime()
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Arena_ClearCDTime)
	simulator:sendTcpActionEventInLua(writer)
end

function ArenaMgr:__delete()
	self.arenaObject:DeleteMe()
end

function ArenaMgr:getOpenLevel()
	return self.openLevel
end