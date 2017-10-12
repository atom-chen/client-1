
#include "include/utils/SFPriorityNotificationCenter.h"
#include "script_support/CCScriptSupport.h"
#include <assert.h>
#include "SFLog.h"

USING_NS_CC;

SFPriorityNotificationObserver::SFPriorityNotificationObserver(CCObject *target, SEL_CallFuncO selector):m_nScriptHandler(0),
	m_target(target), m_selector(selector)
{

}

SFPriorityNotificationObserver::SFPriorityNotificationObserver( int nScriptHandler ):m_nScriptHandler(nScriptHandler),
	m_target(NULL), m_selector(NULL)
{

}

SFPriorityNotificationObserver::~SFPriorityNotificationObserver()
{
}

void SFPriorityNotificationObserver::performSelector(CCObject *obj)
{
	if (m_target)
	{
		(m_target->*m_selector)(obj);
	}
}

void SFPriorityNotificationObserver::performSelector( iBinaryReader* reader )
{
	if (0 != m_nScriptHandler)
	{
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeFunctionWithObject(m_nScriptHandler, reader, 0);
	}
}

CCObject* SFPriorityNotificationObserver::getTarget()
{
	return m_target;
}

cocos2d::SEL_CallFuncO SFPriorityNotificationObserver::getSelector()
{
	return m_selector;
}

int SFPriorityNotificationObserver::getScriptHandler()
{
	return m_nScriptHandler;
}

static SFPriorityNotificationCenter *s_sharedPriorityNofificationCenter = NULL;

SFPriorityNotificationCenter::SFPriorityNotificationCenter(void)
{
}


SFPriorityNotificationCenter::~SFPriorityNotificationCenter(void)
{
	MsgListMap::iterator iter = m_observerMap.begin();
	while (iter != m_observerMap.end())
	{
		MsgList* pMsgList = (*iter).second;

		MsgList::iterator listIter = pMsgList->begin();
		while(listIter != pMsgList->end())
		{
			delete (*listIter);
            listIter++;
			//listIter = pMsgList->erase(listIter);
		}
        pMsgList->clear();

		assert(pMsgList->empty());

		delete pMsgList;
        iter++;
	}
    m_observerMap.clear();
	assert(m_observerMap.empty());
}

SFPriorityNotificationCenter* SFPriorityNotificationCenter::sharedPriorityNotificationCenter()
{
	if (!s_sharedPriorityNofificationCenter)
	{
		s_sharedPriorityNofificationCenter = new SFPriorityNotificationCenter();
	}
	return s_sharedPriorityNofificationCenter;
}

void SFPriorityNotificationCenter::purgePriorityNotificationCenter( void )
{
	delete s_sharedPriorityNofificationCenter;
	s_sharedPriorityNofificationCenter = NULL;
}


void SFPriorityNotificationCenter::addObserver( int messageId, CCObject *target, SEL_CallFuncO selector )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			SFPriorityNotificationObserver* observer = (*listIter);
			if (observer->getTarget() == target)//已经有该消息的处理类了
			{
				CCLOG("SFPriorityNotificationCenter::addObserver same msg: %d", messageId);
// 				std::string str = "SFPriorityNotificationCenter::addObserver same msg: %d";
// 				char buf[64];
// 				sprintf(buf, "SFPriorityNotificationCenter::addObserver same msg: %d", messageId);
// 				SFMsgBox(buf, "error");
				return;
			}
		}

		SFPriorityNotificationObserver* observer = new SFPriorityNotificationObserver(target, selector);
		pMsgList->push_back(observer);
	}
	else
	{//没有该类型消息
		MsgList* pMsgList = new MsgList;
		SFPriorityNotificationObserver* observer = new SFPriorityNotificationObserver(target, selector);
		pMsgList->push_back(observer);
		m_observerMap[messageId] = pMsgList;
	}

}

void SFPriorityNotificationCenter::addObserver( int messageId, int nScriptHandler )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			SFPriorityNotificationObserver* observer = (*listIter);
			if (observer->getScriptHandler() == nScriptHandler)//已经有该消息的处理类了
			{
				CCLOG("SFPriorityNotificationCenter::lua addObserver same msg: %d", messageId);
				// 				std::string str = "SFPriorityNotificationCenter::addObserver same msg: %d";
				// 				char buf[64];
				// 				sprintf(buf, "SFPriorityNotificationCenter::addObserver same msg: %d", messageId);
				// 				SFMsgBox(buf, "error");
				return;
			}
		}

		SFPriorityNotificationObserver* observer = new SFPriorityNotificationObserver(nScriptHandler);
		pMsgList->push_back(observer);
	}
	else
	{//没有该类型消息
		MsgList* pMsgList = new MsgList;
		SFPriorityNotificationObserver* observer = new SFPriorityNotificationObserver(nScriptHandler);
		pMsgList->push_back(observer);
		m_observerMap[messageId] = pMsgList;
	}
}


void SFPriorityNotificationCenter::postNotification( int messageId, CCObject *object )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			(*listIter)->performSelector(object);
		}
	}
}

void SFPriorityNotificationCenter::postNotification( int messageId, iBinaryReader* reader )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			(*listIter)->performSelector(reader);
		}
	}
}

void SFPriorityNotificationCenter::removeObserver( CCObject *target,int messageId )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			SFPriorityNotificationObserver* oberser = *listIter;
			if (oberser->getTarget() == target)
			{
				pMsgList->erase(listIter);
				delete oberser;
				break;
			}
		}

		if (pMsgList->empty())//如果该类型的消息队列为空，则从map删除该消息队列
		{
			m_observerMap.erase(iter);
			delete pMsgList;
		}
	}
}

void SFPriorityNotificationCenter::removeObserver( int nScriptHandler, int messageId )
{
	MsgListMap::iterator iter = m_observerMap.find(messageId);
	if (iter != m_observerMap.end() )
	{
		MsgList* pMsgList = (*iter).second;
		MsgList::iterator listIter = pMsgList->begin();
		for (;listIter != pMsgList->end(); listIter ++)
		{
			SFPriorityNotificationObserver* oberser = *listIter;
			if (oberser->getScriptHandler() == nScriptHandler)
			{
				pMsgList->erase(listIter);
				delete oberser;
				break;
			}
		}

		if (pMsgList->empty())//如果该类型的消息队列为空，则从map删除该消息队列
		{
			m_observerMap.erase(iter);
			delete pMsgList;
		}
	}
}
