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

-- �򿪺����б�
function FriendUIHandler:handleFriendListOpen()
	
	manager:registerUI("FriendView", FriendView.create)
	UIManager.Instance:showUI("FriendView")
	local friendMgr = GameWorld.Instance:getEntityManager():getHero():getFriendMgr()	
	friendMgr:requestFriendList(FriendType.eGoodFriend);		--���º���
	friendMgr:requestFriendList(FriendType.eBlackList);	--���º�����
end

function FriendUIHandler:handleFriendTipsOpen()
end

-- �򿪺�������
function FriendUIHandler:handleFriendDetailOpen()
	return true;
end

-- �򿪺������
function FriendUIHandler:handleFriendAddOpen()
end

-- �򿪺���ɾ��
function FriendUIHandler:handleFriendDeleteOpen()
end	

-- �򿪺�������
function FriendUIHandler:handleFriendRequestOpen()
end

-- �رպ�������
function FriendUIHandler:handleFriendRequestClose()
end	