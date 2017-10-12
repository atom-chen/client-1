#include "cocos2d.h"
#include "download/SFDownload.h"
#include "BackgroundDownloadTask.h"
#include "include/utils/SFStringUtil.h"
//获取所有文件的长度
void* checkPackageSize(void* data)
{
	pthread_detach(pthread_self());
	SFDownload* self = (SFDownload*)data;

	CURL* handle_(curl_easy_init());

	SFDownload::PackageInfoMap::iterator iter = self->m_packageUrlList.begin();
	unsigned int size = 0;
	for ( ; iter != self->m_packageUrlList.end(); ++iter)
	{
// 		if(iter->second.size)
// 			continue;
		//对all files get size
		curl_easy_setopt(handle_, CURLOPT_URL, iter->first.c_str());
		curl_easy_setopt(handle_, CURLOPT_NOBODY, 1);
		curl_easy_setopt(handle_, CURLOPT_HEADER, 0);
		curl_easy_setopt(handle_, CURLOPT_NOSIGNAL, 1L);
		if (self->m_connectionTimeout) curl_easy_setopt(handle_, CURLOPT_CONNECTTIMEOUT, self->m_connectionTimeout);
		CURLcode res = curl_easy_perform(handle_);
		
		if (res == 0)
		{
			int response_code = 0;
			res = curl_easy_getinfo(handle_, CURLINFO_RESPONSE_CODE, &response_code);
			if ( (res == CURLE_OK) && response_code == 200)
			{
				double length = 0;
				res = curl_easy_getinfo(handle_, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &length);
				size += length;
				iter->second.size = length;
			}
		}
	}
	if(self->m_delegate)
		self->m_delegate->onAllFilesSize(size);
	curl_easy_cleanup(handle_);
	if(size)
		self->prepare();
	//pthread_exit(self->m_tid);
	return NULL;
}


SFDownload::SFDownload()
	: m_connectionTimeout(1)
	, m_download(false)
	, m_delegate(NULL)
	, m_tid(NULL)
	, m_curl(NULL)
{
	
}

SFDownload::~SFDownload()
{
	if (m_delegate)
	{
		m_delegate->stop();
	}
	//CCLog("~~SFDownload");
	CC_SAFE_RELEASE(m_delegate);
	CBackgroundDownLoadTask::instance()->fini();
	CC_SAFE_DELETE(m_tid);
}

void SFDownload::setConnectionTimeout( unsigned int timeout )
{
	m_connectionTimeout = timeout;
}

unsigned int SFDownload::getConnectionTimeout()
{
	return m_connectionTimeout;
}

void SFDownload::setStoragePath( const char* storagePath )
{
	m_storagePath = storagePath;
}

const char* SFDownload::getStoragePath()
{
	return m_storagePath.c_str();
}

bool SFDownload::addPackageUrl( const char* url, const char* md5)
{
	if(m_download) return false;
	SFPackageInfo info;
	info.md5 = md5;
	SFStringUtil::toLowerCase(info.md5);
	m_packageUrlList[url] = info;
	return true;
}

void SFDownload::startDownload()
{
	this->stopDownLoad();
	m_download = true;
	// 1.检查服务器此下载list的文件大小。
	if (m_delegate)
	{
		m_delegate->start();
	}
	if(!m_tid)
	{
		m_tid = new pthread_t();
		pthread_create(&(*m_tid), NULL, checkPackageSize, this);
	}
}


void SFDownload::stopDownLoad()
{
	m_threadLock.lock();
	m_download = false;
	CBackgroundDownLoadTask* bgTask = CBackgroundDownLoadTask::instance();
	if(bgTask->isRunning())
	{
		bgTask->shutDown();
	}
	m_threadLock.unlock();
}

void SFDownload::setDelegate( SFDownloadDelegateProtocl* delegate )
{
	if (m_delegate)
	{
		m_delegate->stop();
	}
	CC_SAFE_RELEASE(m_delegate);
	m_delegate = delegate;
	CC_SAFE_RETAIN(m_delegate);
}

//需要锁来确保线程安全
void SFDownload::prepare()
{
	m_threadLock.lock();
	if (this->m_tid)
	{
		CC_SAFE_DELETE(m_tid);
		//还要检查是否停止 m_download
		CBackgroundDownLoadTask* bgTask = CBackgroundDownLoadTask::instance();
		if(m_download && !bgTask->isRunning())
		{
            //CCLog(m_storagePath.c_str());
			bgTask->setStoragePath(m_storagePath.c_str());
			bgTask->addDownloadUrl(m_packageUrlList);
			bgTask->setDelegate(m_delegate);
			bgTask->startUp();
			//CCLOG("bgTask->startUp()");
		}
	}
	m_threadLock.unlock();
}

SFDownLoadDelegateLua::SFDownLoadDelegateLua()
	: m_handler(0)
{
	m_downloawdSpeed = 0;
	m_progressSum = 0;
	m_errorCode = 0;
	m_intValue = 0;
	pthread_mutex_init(&m_mutexLock, NULL);
   
}

SFDownLoadDelegateLua::~SFDownLoadDelegateLua()
{
	m_downloawdSpeed = 0;
	m_progressSum = 0;
	pthread_mutex_unlock(&m_mutexLock); pthread_mutex_destroy(&m_mutexLock);
	m_eventList.clear();
}


void SFDownLoadDelegateLua::start()
{
	 CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(SFDownLoadDelegateLua::sendLuaDelegate),this,0.3f, false);
}
void SFDownLoadDelegateLua::onError( ErrorCode errorCode )
{
	if (m_handler != 0)
	{
		SFDownloadData data;
		data.m_eventCode = kOnError;
		data.m_intValue = errorCode;
		data.m_strValue = "";
		pthread_mutex_lock(&m_mutexLock);
		m_eventList.push_back(data);
		pthread_mutex_unlock(&m_mutexLock);
		//CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//engine->executeDownloadCallBack(m_handler,kOnError,errorCode," ",0);
	}
}

void SFDownLoadDelegateLua::onSuccess( const char* filename, unsigned int size )
{
	if (m_handler != 0)
	{
		SFDownloadData data;
		data.m_eventCode = kOnSuccess;
		data.m_intValue = size;
		data.m_strValue = filename;
		pthread_mutex_lock(&m_mutexLock);
		m_eventList.push_back(data);
		pthread_mutex_unlock(&m_mutexLock);
		//engine->executeDownloadCallBack(m_handler,kOnSuccess,size,filename,0);
	}
}

void SFDownLoadDelegateLua::onFilesize( const char* filename, unsigned int size )
{
	if (m_handler != 0)
	{
		SFDownloadData data;
		data.m_eventCode = kOnFilesize;
		data.m_intValue = size;
		data.m_strValue = filename;
		pthread_mutex_lock(&m_mutexLock);
		m_eventList.push_back(data);
		pthread_mutex_unlock(&m_mutexLock);
		//CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//engine->executeDownloadCallBack(m_handler,kOnFilesize,size,filename,0);
	}
}

void SFDownLoadDelegateLua::onAllFilesSize( unsigned int size )
{
	if (m_handler != 0)
	{
		SFDownloadData data;
		data.m_eventCode = kOnAllFilesSize;
		data.m_intValue = size;
		data.m_strValue = " ";
		pthread_mutex_lock(&m_mutexLock);
		m_eventList.push_back(data);
		pthread_mutex_unlock(&m_mutexLock);
		//CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//engine->executeDownloadCallBack(m_handler,kOnAllFilesSize,size," ",0);
	}
}

void SFDownLoadDelegateLua::onComplete()
{
	if (m_handler != 0)
	{
		SFDownloadData data;
		data.m_eventCode = kOnComplete;
		data.m_intValue = 0;
		data.m_strValue = " ";
		pthread_mutex_lock(&m_mutexLock);
		m_eventList.push_back(data);
		pthread_mutex_unlock(&m_mutexLock);
		//CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//engine->executeDownloadCallBack(m_handler,kOnComplete,0,"",0);
	}
}

void SFDownLoadDelegateLua::sendLuaDelegate(float dt)
{
	if (m_handler != 0)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//CCLOG("=====================sendLuaDelegate: m_downloawdSpeed-%f", m_downloawdSpeed);
		engine->executeDownloadCallBack(m_handler,kOnDownloadSpeed,0,"",(float)m_downloawdSpeed);
		engine->executeDownloadCallBack(m_handler,kOnProgress,m_progressSum,"",0); 
		if (m_eventList.size() > 0)
		{
			pthread_mutex_lock(&m_mutexLock);
			SFDownloadData data = *m_eventList.begin();
			engine->executeDownloadCallBack(m_handler,data.m_eventCode,data.m_intValue,data.m_strValue,0);
			m_eventList.pop_front();
			pthread_mutex_unlock(&m_mutexLock);
		}
	}
}

void SFDownLoadDelegateLua::stop()
{
	CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(SFDownLoadDelegateLua::sendLuaDelegate),this);
}


