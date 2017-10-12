-- �������ݹ�����
require("common.baseclass") 

FriendMgr = FriendMgr or BaseClass()
local g_hero = nil
local g_simulator = SFGameSimulator:sharedGameSimulator()

function FriendMgr:__init()
	g_hero = GameWorld.Instance:getEntityManager():getHero()
	self.friendList = {}
end

function FriendMgr:__delete()

end

function FriendMgr:clear()
	g_hero = nil
	self.friendList = {}	
	self.capacity = nil
	self.friendMap = {}
end

-- ע�� type ΪLua���ԵĹؼ���
function FriendMgr:requestFriendList(ftype)
	local writer = g_simulator:getBinaryWriter(ActionEvents_Friend.C2G_Friends_List)
	writer:WriteChar(ftype);
	g_simulator:sendTcpActionEventInLua(writer)
end

-- ���ú���������������ж��ٸ����ѣ�
function FriendMgr:setCapacity(capacity)
	self.capacity = capacity
end

-- ��ȡ����������
function FriendMgr:getCapacity()
	return self.capacity
end

function FriendMgr:setFriendMap(map, ftype)
	self.friendMap[ftype] = map
end

function FriendMgr:getFriendList(ftype)
	return self.friendMap[ftype]
end

function FriendMgr:resetFriend()
end

function FriendMgr:getFriendPlayer()
end

function FriendMgr:getMaxFriendPlayerCount()
end

function FriendMgr:getFriendPlayerCount()
end

function FriendMgr:getFriendPlayerIterator()
end

function FriendMgr:isInMyFriends()
end

function FriendMgr:getFindFriendPlayer()
end

function FriendMgr:getFriendNotifyIterator()
end

function FriendMgr:getFriendNotifyCount()
end

function FriendMgr:clearFriendNotifyList()
end	

function FriendMgr:requestSearchPlayer()
end

function FriendMgr:requestAddFriend()
end

function FriendMgr:requestAddFriend()
end

function FriendMgr:agreeAddFriend()
end

function FriendMgr:requestDeleteFriend()
end

function FriendMgr:requestDeleteFriend()
end

function FriendMgr:updateFindPlayer()
end

function FriendMgr:addFriendPlayer()
end

function FriendMgr:updateFriendListByDelete()
end

function FriendMgr:removeFriendPlayer()
end

function FriendMgr:clearFriendPlayerList()
end	

function FriendMgr:checkFriendPlayer()
end

function FriendMgr:checkAllFriendPlayer()
end

function FriendMgr:_getFriendList()
end

function FriendMgr:_getDeleteList()
end

function FriendMgr:addFriendNotify()
end

function FriendMgr:updateFriendNotifyList()
end

function FriendMgr:removeFriendNotify()
end

function FriendMgr:alertButtonOnClicked()
end

--[[
SortFun_Friend( FriendPlayer *f1, FriendPlayer *f2 )
{
	if (f1->isOnline > f2->isOnline)//����״̬
	{
		return true;
	}
	else if (f1->isOnline == f2->isOnline)
	{
		if (f1->intimacy > f2->intimacy)//���ܶ�
		{
			return true;
		}
		else if (f1->intimacy == f2->intimacy)
		{
			if (f1->level > f2->level)//�ȼ�
			{
				return true;
			}
			else if (f1->level == f2->level)
			{
				if (f1->lastLoginTime > f2->lastLoginTime)//����¼ʱ��
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}
--]]