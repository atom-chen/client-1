require ("actionEvent.ActionEventDef")
require ("common.ActionEventHandler")
require ("object.friend.FriendObject")

FriendActionHandler = FriendActionHandler or BaseClass(ActionEventHandler)
local g_simulator = SFGameSimulator:sharedGameSimulator()
local g_friendMgr = nil 

function FriendActionHandler:init()
	function handleG2C_Friend_List(reader)
		self:handleG2C_Friend_List(reader)
	end
	function handleG2C_Friend_Search(reader)
		self:handleG2C_Friend_Search(reader)
	end
	function handleG2C_Friend_Request(reader)
		self:handleG2C_Friend_Request(reader)
	end
	function handleG2C_Friend_Added(reader)
		self:handleG2C_Friend_Added(reader)
	end
	function handleG2C_Friend_Deleted(reader)
		self:handleG2C_Friend_Deleted(reader)
	end
	function handleG2C_Delete_Friend_Reply(reader)
		self:handleG2C_Delete_Friend_Reply(reader)
	end
	function handleG2C_Agree_Add_Friend_Reply(reader)
		self:handleG2C_Agree_Add_Friend_Reply(reader)
	end
	function handleG2C_Op_Replay(reader)
		self:handleG2C_Op_Replay(reader)
	end
	g_friendMgr = GameWorld.Instance:getEntityManager():getHero():getFriendMgr()	
	self:bind(ActionEvents_Friend.G2C_Friends_List,				handleG2C_Friend_List)
	self:bind(ActionEvents_Friend.G2C_Search_Player,			handleG2C_Friend_Search)
	self:bind(ActionEvents_Friend.G2C_Add_Friend,				handleG2C_Friend_Request)
	self:bind(ActionEvents_Friend.G2C_Added_Friend,				handleG2C_Friend_Added)
	self:bind(ActionEvents_Friend.G2C_Deleted_Friend,			handleG2C_Friend_Deleted)
	self:bind(ActionEvents_Friend.G2C_Delete_Friend_Reply,		handleG2C_Delete_Friend_Reply)
	self:bind(ActionEvents_Friend.G2C_Agree_Add_Friend_Reply,	handleG2C_Agree_Add_Friend_Reply)

	--È«¾Ö»Ø¸´
	self:bind(ActionEvents_Friend.G2C_Op_Replay, 				handleG2C_Op_Replay)
end

function FriendActionHandler:handleG2C_FriendList(reader)
	local friendType = reader:ReadChar()
	local capacity = reader:ReadShort()	
	local friendCount = reader:ReadShort();
	local friendMap = {}
	for i = 1, friendCount do
		local friend = FriendObject.New()
		friend:setId(reader:ReadLLong())
		friend:setName(StreamDataAdapter:ReadStr(reader))
		friend:setLevel(reader:ReadInt())
		friend:setProfession(StreamDataAdapter:ReadStr(reader))
		friend:setProfessionRank(reader:ReadChar())
		friend:setCamp(reader:ReadChar())
		friend:setFightPower(reader:ReadLLong())
		friend:setXianMeng(reader:ReadLLong())
		friend:setSpouseId(reader:ReadLLong())
		friend:setSpouseName(StreamDataAdapter:ReadStr(reader))
		friend:setIsOnline(reader:ReadChar())
		friend:setIntimacy(reader:ReadLLong())
		friend:setLastLoginTime(reader:ReadLLong())
		friend:setSex(reader:ReadChar())
		friend:setIsSelected(false)
		friendMap[friend:getId()] = friend
	end
	g_friendMgr:setFriendMap(friendMap, friendType)
	g_friendMgr:setCapacity(capacity)
	GlobalEventSystem:fire(GameEvent.EventFriendListUpdate)
end

function FriendActionHandler:handleG2C_FriendSearch()
end

function FriendActionHandler:handleG2C_FriendRequest()
end

function FriendActionHandler:handleG2CFriend_Added()
end

function FriendActionHandler:handleG2CFriend_Deleted()
end

function FriendActionHandler:handleG2C_DeleteFriendReply()
end

function FriendActionHandler:handleG2C_AgreeAddFriendReply()
end

function FriendActionHandler:handleG2C_OpReplay()
end
