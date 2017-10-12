#include "EngineMacros.h"
#include "utils/SFExecutionThreadService.h"
#include "curl/curl.h"


namespace cocos2d {
SFExecutionThreadService::SFExecutionThreadService(void)
{
	state_ = NEW;
	thread_ = NULL;
}


SFExecutionThreadService::~SFExecutionThreadService(void)
{
	CC_SAFE_DELETE(thread_);
}

SFServiceState SFExecutionThreadService::startUp()
{
	threadLock_.lock();
	state_ = RUNNING;
	threadLock_.unlock();
	if(!thread_)
		thread_ = new SFThread(this, true);
	return RUNNING;
}

SFServiceState SFExecutionThreadService::shutDown()
{
	threadLock_.lock();
	state_ = TERMINATED;
	threadLock_.unlock();

	if (thread_)
	{
		thread_->join();//等待线程结束
	}
	return TERMINATED;
}

void SFExecutionThreadService::run()
{
	while(true)
	{
		// FIXME: use Atomic ? see http://www.cnblogs.com/FrankTan/archive/2010/12/11/1903377.html
		threadLock_.lock();
		if (state_ != RUNNING)
		{
			threadLock_.unlock();
			break;
		}
		threadLock_.unlock();
// 		doRun();
// 		thread_->sleep(1);
		if (doRun() == false)
		{
			thread_->sleep(1);
		}
	}
}

bool SFExecutionThreadService::isRunning()
{
	bool bRet;

	threadLock_.lock();
	bRet = (state_ == RUNNING);
	threadLock_.unlock();

	return bRet;
}

SFServiceState SFExecutionThreadService::state()
{
	SFServiceState iRet;

	threadLock_.lock();
	iRet = state_;
	threadLock_.unlock();

	return iRet;
}
}