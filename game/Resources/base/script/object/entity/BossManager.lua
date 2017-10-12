--[[
管理boss的归属权和相关数据
]]

BossManager = BossManager or BaseClass()

function BossManager:__init()
	self.ownerList = {}
end

function BossManager:__delete()
	self.ownerList = nil
end

-- 请求怪物归属权
function BossManager:requestBossOwner(monsterId)
	local simulator = SFGameSimulator:sharedGameSimulator()
	local writer = simulator:getBinaryWriter(ActionEvents.C2G_Monster_OwnerTransfer)
	StreamDataAdapter:WriteStr(writer, monsterId)
	simulator:sendTcpActionEventInLua(writer)	
end

function BossManager:setBossOwner(bossId, ownerId)
	self.ownerList[bossId] = ownerId
end

function BossManager:getBossOwner(bossId)
	return self.ownerList[bossId]
end