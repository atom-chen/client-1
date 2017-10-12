require "common.baseclass"
require "gameevent.GameEvent"
require "ui.UIManager"
require "ui.friend.FriendView"
require "object.friend.FriendDef"

FriendUIHandler = FriendUIHandler or BaseClass(GameEventHandler)
local g_simulator = SFGameSimulator:sharedGameSimulator()

function FriendUIHandler:__init()
	local manager = UIManager.Instance		
	
	
	local handleFriendListOpen = function()
		self:handleFriendListOpen()
	end
	local handleFriendTipsOpen = function()
		self:handleFriendTipsOpen()
	end
	local handleFriendDetailOpen = function()
		self:handleFriendDetailOpen()
	end
	local handleFriendAddOpen = function()
		self:handleFriendAddOpen()
	end
	local handleFriendDeleteOpen = function()
		self:handleFriendDeleteOpen()
	end
	local handleFriendRequestOpen = function()
		self:handleFriendRequestOpen()
	end
	local handleFriendRequestClose = function()
		self:handleFriendRequestClose()
	end
	
	self:Bind(GameEvent.EventFriendListViewOpen, 		handleFriendListOpen)
	self:Bind(GameEvent.EventFriendTipsViewOpen, 		handleFriendTipsOpen)
	self:Bind(GameEvent.EventFriendDetailViewOpen, 		handleFriendDetailOpen)
	self:Bind(GameEvent.EventFriendAddViewOpen, 		handleFriendAddOpen)
	self:Bind(GameEvent.EventFriendDeleteViewOpen, 		handleFriendDeleteOpen)
	self:Bind(GameEvent.EventFriendRequestViewOpen, 	handleFriendRequestOpen)
	self:Bind(GameEvent.EventFriendRequestViewClose, 	handleFriendRequestClose)		
end

-- 打开好友列表
function FriendUIHandler:handleFriendListOpen()
	
	manager:registerUI("FriendView", FriendView.create)
	UIManager.Instance:showUI("FriendView")
	local friendMgr = GameWorld.Instance:getEntityManager():getHero():getFriendMgr()	
	friendMgr:requestFriendList(FriendType.eGoodFriend);		--更新好友
	friendMgr:requestFriendList(FriendType.eBlackList);	--更新黑名单
end

function FriendUIHandler:handleFriendTipsOpen()
end

-- 打开好友详情
function FriendUIHandler:handleFriendDetailOpen()
	return true;
end

-- 打开好友添加
function FriendUIHandler:handleFriendAddOpen()
end

-- 打开好友删除
function FriendUIHandler:handleFriendDeleteOpen()
end	

-- 打开好友申请
function FriendUIHandler:handleFriendRequestOpen()
end

-- 关闭好友申请
function FriendUIHandler:handleFriendRequestClose()
end	