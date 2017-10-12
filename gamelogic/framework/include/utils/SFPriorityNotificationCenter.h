#ifndef __SFPRIORITYNOTIFICATIONCENTER_H__
#define __SFPRIORITYNOTIFICATIONCENTER_H__

//#include "sofia/sofia.h"
#include "cocos2d.h"
using namespace cocos2d;

class SFPriorityNotificationObserver
{
public:
	SFPriorityNotificationObserver(CCObject *target, SEL_CallFuncO selector);
	SFPriorityNotificationObserver(int nScriptHandler);
	~SFPriorityNotificationObserver();

	// for c++
	void performSelector(CCObject *obj);
	
	// for lua
	void performSelector(iBinaryReader* reader);

	CCObject* getTarget();
	SEL_CallFuncO getSelector();
	int getScriptHandler();

private:
	CCObject* m_target;
	SEL_CallFuncO m_selector;
	int	m_nScriptHandler;		// script handler
};

class SFPriorityNotificationCenter 
{
public:
	SFPriorityNotificationCenter(void);
	virtual ~SFPriorityNotificationCenter(void);

public:
	static SFPriorityNotificationCenter* sharedPriorityNotificationCenter();
	static void purgePriorityNotificationCenter(void);

public:
	void addObserver(int messageId, CCObject *target, SEL_CallFuncO selector);
	void addObserver(int messageId, int nScriptHandler);

	void removeObserver(CCObject *target,int messageId);
	void removeObserver(int nScriptHandler, int messageId);

	// for c++
	void postNotification(int messageId, CCObject *object);

	// for lua
	void postNotification(int messageId, iBinaryReader* reader);

private:
	typedef std::list<SFPriorityNotificationObserver*> MsgList;
	typedef std::map<int, MsgList*> MsgListMap;
	 MsgListMap m_observerMap;
};


#define globalActionEventManager SFPriorityNotificationCenter::sharedPriorityNotificationCenter()


#endif