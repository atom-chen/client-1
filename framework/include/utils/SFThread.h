#ifndef SFTHREAD_H
#define SFTHREAD_H

#ifdef WIN32
#include "Windows.h"
#endif
namespace cocos2d {
class SFRunnable
{
public:
	virtual ~SFRunnable(){};

	virtual void run() = 0;
};

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

#include <pthread.h>
typedef DWORD ThreadID; 

class SFThread
{
public:
	ThreadID threadId_;
protected:
	SFRunnable *runnable_;

	HANDLE m_thread;

	

	inline static unsigned int s_pthreadRunFunc( void *runnable )
	{
		if(runnable != NULL)
		{
			SFRunnable * task = static_cast<SFRunnable *> (runnable);
			if(task == NULL)
			{
				CCLOGERROR("Type cast error:runnable is not a SFRunnable object");
			}
			else
			{
				task->run();
			}
		}	
		return 0;
	}

public:
	SFThread()
		: runnable_( NULL )
		, m_thread( NULL )
		, threadId_(0)
	{}

	inline SFThread( SFRunnable *runnable)
		: runnable_( runnable )
		, m_thread( NULL )
		, threadId_(0)
	{}

	inline SFThread( SFRunnable *runnable, bool bStart )
		: runnable_( runnable )
		, m_thread( NULL )
		, threadId_(0)
	{
		if (bStart)
		{
			start();
		}
	}

	inline ~SFThread()
	{
		CloseHandle( m_thread );
	}

	inline ThreadID getThreadId()
	{
		return threadId_;
	}

	inline SFRunnable * getRunnable()
	{
		return runnable_;
	}

	inline void setRunnable( SFRunnable *runnable )
	{
		runnable_ = runnable;
	}

	inline bool start()
	{
		if( runnable_ )
		{
			m_thread = CreateThread(
				NULL,              // default security attributes
				0,                 // use default stack size
				(LPTHREAD_START_ROUTINE)&s_pthreadRunFunc,     // thread function
				runnable_,       // argument to thread function
				0,                 // use default creation flags
				&threadId_);             // returns the thread identifier
			return true;
		}
		return false;
	}

	inline void join()
	{
		//CC_ASSERT2( m_thread != NULL , "join failed:haven't create a thread handle");
		WaitForSingleObject( m_thread, INFINITE );
	}

	inline void exit()
	{
		ExitThread( 0 );
	}

	inline static void sleep(unsigned int miliseconds)
	{
		::Sleep(miliseconds);
	}
};

class SFSemaphoreLock
{
public:
	SFSemaphoreLock()		{ InitializeCriticalSection(&sectionLock_); }

	~SFSemaphoreLock()		{ DeleteCriticalSection(&sectionLock_); }

	void lock()		{ EnterCriticalSection(&sectionLock_); }

	void unlock()	{ LeaveCriticalSection(&sectionLock_); }


private:
	CRITICAL_SECTION sectionLock_;
};

class SFMutexLock
{
public:
	SFMutexLock() {pthread_mutex_init(&mutexLock_, NULL);}

	~SFMutexLock() {pthread_mutex_unlock(&mutexLock_); pthread_mutex_destroy(&mutexLock_);}

	void lock() {pthread_mutex_lock(&mutexLock_);}

	void unlock() {pthread_mutex_lock(&mutexLock_);}

private:
	pthread_mutex_t mutexLock_;
};

class SFReadWriteMutexLock
{
public:
	SFReadWriteMutexLock() {pthread_rwlock_init(&rwLock_, NULL);}
	~SFReadWriteMutexLock() {pthread_rwlock_unlock(&rwLock_); pthread_rwlock_destroy(&rwLock_);}

	void readLock() {pthread_rwlock_rdlock(&rwLock_);}
	void readUnlock() {pthread_rwlock_unlock(&rwLock_);}

	void writeLock() {pthread_rwlock_wrlock(&rwLock_);}
	void writeUnlock() {pthread_rwlock_unlock(&rwLock_);}

private:
	pthread_rwlock_t rwLock_;
};

#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#include <pthread.h>
#include <unistd.h>	
#include <semaphore.h>

typedef pthread_t ThreadID;

class SFThread
{
public:
	inline SFThread()
		: runnable_( NULL )
	{}

	inline SFThread( SFRunnable* runnable )
		: runnable_( runnable )
	{}

	inline SFThread( SFRunnable* runnable, bool bStart )
		: runnable_( runnable )
	{
		if( bStart )
			start();
	}

protected:
	SFRunnable *runnable_;
	pthread_t threadId_;

	inline static void * s_pthreadRunFunc( void *runnable )
	{
		if(runnable != NULL)
		{
			SFRunnable * task = static_cast<SFRunnable *>(runnable);
			if(task == NULL)
			{
				// CCLOG("Type cast error:runnable is not a SFRunnable object");
			}
			else
			{
				task->run();
			}
		}	
		return 0;
	}
public:
	inline ThreadID getThreadId()
	{
		return threadId_;
	}

	inline SFRunnable* getRunnable()
	{
		return runnable_;
	}

	inline void setRunnable( SFRunnable* runnable )
	{
		runnable_ = runnable;
	}

	inline bool start()
	{
		if( runnable_ )
		{
			if( !pthread_create( &threadId_, NULL, &s_pthreadRunFunc, runnable_ ) )
				return true;
		}
		return false;
	}

	inline void join()
	{
		pthread_join( threadId_, NULL );
	}

	inline void exit()
	{
		pthread_exit( 0 );
	}

	inline static void sleep( unsigned int miliseconds )
	{
		usleep( miliseconds * 1000 );
	}
};

class SFSemaphoreLock
{
public:
	SFSemaphoreLock()		{ sem_init(&semaphoreLock_, 0, 1); }

	~SFSemaphoreLock()		{ sem_destroy(&semaphoreLock_); }

	void lock()		{ sem_wait(&semaphoreLock_); }

	void unlock()	{ sem_post(&semaphoreLock_); }

private:
	sem_t semaphoreLock_;
};

class SFMutexLock
{
public:
	SFMutexLock() {pthread_mutex_init(&mutexLock_, NULL);}

	~SFMutexLock() {pthread_mutex_unlock(&mutexLock_); pthread_mutex_destroy(&mutexLock_);}

	void lock() {pthread_mutex_lock(&mutexLock_);}

	void unlock() {pthread_mutex_lock(&mutexLock_);}

private:
	pthread_mutex_t mutexLock_;
};

class SFReadWriteMutexLock
{
public:
	SFReadWriteMutexLock() {pthread_rwlock_init(&rwLock_, NULL);}
	~SFReadWriteMutexLock() {pthread_rwlock_unlock(&rwLock_); pthread_rwlock_destroy(&rwLock_);}

	void readLock() {pthread_rwlock_rdlock(&rwLock_);}
	void readUnlock() {pthread_rwlock_unlock(&rwLock_);}

	void writeLock() {pthread_rwlock_wrlock(&rwLock_);}
	void writeUnlock() {pthread_rwlock_unlock(&rwLock_);}

private:
	pthread_rwlock_t rwLock_;
};
#endif

class SFSemaphoreLockGuard
{
public:
	SFSemaphoreLockGuard(SFSemaphoreLock& lock_) : l(lock_)  {this->l.lock();}
	~SFSemaphoreLockGuard(){this->l.unlock();}
	SFSemaphoreLock& l;
};

}
#endif
