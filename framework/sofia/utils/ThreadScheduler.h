/********************************************************************
文件名:ThreadScheduler.h
创建者:James Ou
创建时间:2013-7-23 16:45
功能描述:
*********************************************************************/

# ifndef __THREAD_SCHEDULER_H__
#define  __THREAD_SCHEDULER_H__

#include <pthread.h>
#include "cocos2d.h"
USING_NS_CC;
#include "utils/Singleton.h"



struct ThreadFun{
	ThreadFun();
	ThreadFun(CCObject *pTarget, SEL_CallFuncO fun, CCObject *data):m_threadTarget(pTarget), m_threadFun(fun), m_data(data){};
	CCObject		*m_threadTarget;
	SEL_CallFuncO	m_threadFun;
	CCObject			*m_data;
};

class ThreadScheduler : public cocos2d::Singleton<ThreadScheduler>, public CCObject{
public:
	ThreadScheduler();
	~ThreadScheduler();
public:
	/************************************************************************/
	/* 新开一个线程，但里面不能有CCObject的create、relase、retain的操作及UI的操作                                                                     */
	/************************************************************************/
	void runInNewThread(CCObject* pTarget, SEL_CallFuncO handler, CCObject* data);
	/************************************************************************/
	/* 调用回到主线程处理相关逻辑                                                                     */
	/************************************************************************/
	void runInMainThread(CCObject* pTarget, SEL_CallFuncO handler, CCObject* data);
private:	
	
	static void* doRun(void *data);
	
	void updateMainThread(float dt);

	typedef std::list<ThreadFun*> MainThreadFunList;
	MainThreadFunList m_runMainThreadList;
	MainThreadFunList m_removeThreadList;
//	static pthread_mutex_t mutex;
		
};

#define getThreadScheduler ThreadScheduler::getInstancePtr()

#endif //__THREAD_SCHEDULER_H__
