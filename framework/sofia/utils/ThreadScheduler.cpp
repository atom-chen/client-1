/********************************************************************
文件名:ThreadScheduler.cpp
创建者:James Ou
创建时间:2013-7-23 17:11
功能描述:
*********************************************************************/

#include "ThreadScheduler.h"
#include "include/utils/SFTimeAxis.h"

static pthread_mutex_t mutex;

ThreadScheduler::ThreadScheduler()
{
	SFTimeAxis::getInstancePtr()->setTimer(this, schedule_selector(ThreadScheduler::updateMainThread), 400.0f, 0);
	pthread_mutex_init(&mutex, NULL);
}

ThreadScheduler::~ThreadScheduler()
{
	SFTimeAxis::getInstancePtr()->killTimer(this, schedule_selector(ThreadScheduler::updateMainThread));
}


void ThreadScheduler::runInNewThread(CCObject* pTarget, SEL_CallFuncO handler, CCObject* data)
{
	ThreadFun *threadFun = new ThreadFun(pTarget, handler, data);
//	pthread_mutex_init(&threadFun->mutex,NULL);
	pthread_t pidRun;
	pthread_create(&pidRun,NULL,doRun,threadFun);
}

void ThreadScheduler::runInMainThread(CCObject* pTarget, SEL_CallFuncO handler, CCObject* data)
{
	ThreadFun *threadFun = new ThreadFun(pTarget, handler, data);
	m_runMainThreadList.push_back(threadFun);
}

void* ThreadScheduler::doRun(void *data)
{
	ThreadFun *threadFun = (ThreadFun*)data;
	pthread_mutex_lock(&mutex);
	
	(threadFun->m_threadTarget->*threadFun->m_threadFun)((CCObject*)threadFun->m_data);

	delete threadFun;

	pthread_mutex_unlock(&mutex);

	return NULL;
}



void ThreadScheduler::updateMainThread( float dt )
{
	
	pthread_mutex_lock(&mutex);

	MainThreadFunList::iterator itr = m_removeThreadList.begin();
	while(itr != m_removeThreadList.end()){
		ThreadFun *threadFun = (*itr);				
		delete threadFun;
		itr++;
	}
	m_removeThreadList.clear();

	itr = m_runMainThreadList.begin();
	while(itr != m_runMainThreadList.end()){
		ThreadFun *threadFun = (*itr);
		(threadFun->m_threadTarget->*threadFun->m_threadFun)(threadFun->m_data);

		m_removeThreadList.push_back(threadFun);
		itr++;
	}
	m_runMainThreadList.clear();

	pthread_mutex_unlock(&mutex);
}

