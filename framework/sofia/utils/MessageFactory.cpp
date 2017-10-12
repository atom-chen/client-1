#include "sofia.h"
#include "core/ActionEventBase.h"
#include "SFLog.h"
#include "MessageFactory.h"

void MessageFacotry::addMessage(int msgId,  ActionEventBase *actionBase )
{
	actionBase->actionEventId = msgId;
	std::pair<MsgHashMap::iterator,bool> ret = m_msgMap.insert( std::pair<int,ActionEventBase*>(msgId, actionBase) );
	if ( !ret.second )
	{
		CCLOG("WARNNING:MessageFacotry::addMessage msgId[%d] already exists,delete new insert actionBase[%d] now", msgId, actionBase);
		CC_SAFE_DELETE(actionBase);
	}
}

ActionEventBase * MessageFacotry::getMessage( int msgId )
{
	MsgHashMap::iterator iter = m_msgMap.find(msgId);
	if (m_msgMap.end() != iter)
	{
		return iter->second;
	}
	return 0;
}

void MessageFacotry::clearMessage()
{
	MsgHashMap::iterator iter = m_msgMap.begin();
	for (iter; iter != m_msgMap.end(); iter++)
	{
		delete iter->second;
	}
	m_msgMap.clear();
}

MessageFacotry::~MessageFacotry()
{
	this->clearMessage();
}
