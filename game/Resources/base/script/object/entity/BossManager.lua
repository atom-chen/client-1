--[[
����boss�Ĺ���Ȩ���������
]]

BossManager = BossManager or BaseClass()

function BossManager:__init()
	self.ownerList = {}
end

function BossManager:__delete()
	self.ownerList = nil
end

-- ����������Ȩ
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