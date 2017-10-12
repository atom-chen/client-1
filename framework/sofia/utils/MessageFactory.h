#ifndef __MESSAGEFACOTRY_H__
#define __MESSAGEFACOTRY_H__

#include "utils/Singleton.h"
#include <map>
 class ActionEventBase;

class MessageFacotry : public cocos2d::Singleton<MessageFacotry>
{
public:
	~MessageFacotry();
	void addMessage(int msgId, ActionEventBase *actionBase);
	ActionEventBase *getMessage(int msgId);

	void clearMessage();

	typedef std::map<int , ActionEventBase*>	MsgHashMap;
	MsgHashMap m_msgMap;
};
#define GetMsgEvent(T,id) ((T*)MessageFacotry::getInstancePtr()->getMessage(id))
#define PurgeMsgEvent	MessageFacotry::getInstancePtr()->releaseInstance()
#endif