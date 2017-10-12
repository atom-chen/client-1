#ifndef SFSERVICE_H
#define SFSERVICE_H

#include "cocos2d.h"
#include "utils/SFThread.h"

//using namespace cocos2d;
namespace cocos2d {
enum
{
	NEW,
	STARTING,
	RUNNING,
	STOPPING,
	TERMINATED,
	FAILED
};
typedef unsigned int SFServiceState;

class SFThread;

class SFExecutionThreadService : /*public CCObject, */public SFRunnable
{
protected:
	SFExecutionThreadService(void);
	virtual ~SFExecutionThreadService(void);

public:
	SFServiceState startUp();
	SFServiceState shutDown();

public:
	virtual void run();
	SFServiceState state();
	bool isRunning();

protected:
	virtual bool doRun() = 0;

protected:
	SFThread *thread_;
	SFSemaphoreLock threadLock_;
	SFServiceState state_;
};
}
#endif