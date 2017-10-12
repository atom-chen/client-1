#include "BackgroundDownloadTask.h"
#include "cocos2d.h"
#include "sofia/utils/md5.h"

// ----------------------------------------------------------------------------
// SECTION: class CBackgroundDownLoadTask
// ---------------------------------------------------------------------------- 
int getProgressValue( const char* flag, double dt, double dn, double ult, double uln )
{
	CBackgroundDownLoadTask* bgTask = CBackgroundDownLoadTask::instance();
	bgTask->speedDelegate(dn, dt);
	return 0;
}

FILE* CBackgroundDownLoadTask::m_downWriter = NULL;
SFDownloadDelegateProtocl* CBackgroundDownLoadTask::m_downloadDelegate = NULL;
CBackgroundDownLoadTask* CBackgroundDownLoadTask::sm_pInstance=NULL;
int CBackgroundDownLoadTask::m_offsetWrite = 0;
CBackgroundDownLoadTask::CBackgroundDownLoadTask( void )
	: m_downloading(false)
	,m_currentSpeed(0)
{
	m_handle = curl_easy_init();
	m_multiHandle = curl_multi_init();
}

CBackgroundDownLoadTask::~CBackgroundDownLoadTask( void )
{
	CC_SAFE_RELEASE(m_downloadDelegate);
	curl_multi_cleanup(m_multiHandle);
	curl_easy_cleanup(m_handle);
	this->closeDownWriter();
}

bool CBackgroundDownLoadTask::doRun()
{
	if ( !isRunning() )
	{
		return false;
	}

	if ( !this->busy() )
	{
		if(m_urlList.empty())
		{
			if(m_downloadDelegate)
				m_downloadDelegate->onComplete();
			shutDown();
			//this->state_ = TERMINATED;
			return false;
		}
		this->start();
	}
	else
	{
		this->multiDownloading();
	}
	return true;
}

void CBackgroundDownLoadTask::addDownloadUrl( SFDownload::PackageInfoMap& infoMap )
{
	if(!this->isRunning())
		m_urlList.swap(infoMap);
}
//sd/lyzt/update
void CBackgroundDownLoadTask::setStoragePath( const char* storagePath )
{
	m_storage = storagePath;
}

const char* CBackgroundDownLoadTask::getStoragePath()
{
	return m_storage.c_str();
}

void CBackgroundDownLoadTask::start()
{
	m_downloading = true;
	SFDownload::PackageInfoMap::iterator iter = m_urlList.begin();
	std::string url = iter->first;
	if ( checkFileAlreadyDownload(url.c_str()) == false)
	{
		m_downloading = false;
		m_urlList.erase(iter);
		return;
	}
	else{
		this->startDownload(url.c_str());
	}
		
}

bool CBackgroundDownLoadTask::checkFileAlreadyDownload(const char* file)
{
	const char* pos = strrchr(file,'/');
	if(NULL==pos)
	{
		// cclog file error
		return false;
	}
	std::string filePath = m_storage + pos;
	m_filename = ++pos;
	SFDownload::PackageInfoMap::iterator iter = m_urlList.begin();
	FILE *fp = fopen(filePath.c_str(), "a+b");
	if ( fp )
	{
		fseek(fp, 0, SEEK_END);
		int len = ftell(fp);
		
		// 1.检查包大小，并且MD5正确。
		if ( len == int(iter->second.size))
		{
			fclose(fp);
			//if(iter->second.md5 == szmd5)//如果MD5相等。通知成功
			if(this->checkMD5(filePath.c_str(), iter->second.md5.c_str()))
			{
				if(m_downloadDelegate)
				{
					m_downloadDelegate->onSuccess(m_filename.c_str(), iter->second.size);
					m_downloadDelegate->resetProgress();
				}
				return false;
			}
			else
			{
				//如果删除不成功。错误返回。
				if (remove(filePath.c_str()) != 0)
				{
					//if(m_downloadDelegate)
					// error
					return false;
				}
			}
			//重新创建文件，开始读取
			fp = fopen(filePath.c_str(), "a+b");
			if(fp)
			{
				fseek(fp, 0, SEEK_END);
				len = ftell(fp);
			}

		}
		//赋值，然后通知下载包的大小。
		this->closeDownWriter();
		m_downWriter = fp;
		m_offsetWrite = len;
		if(m_downloadDelegate)
		{
            CCLOG("onWriteData::checkFileAlreadyDownload");
            CCLOG("onWriteData::checkFileAlreadyDownload m_offsetWrite %d %d %s",m_offsetWrite,iter->second.size,m_filename.c_str());
            
			m_downloadDelegate->onFilesize(m_filename.c_str(), iter->second.size);
			m_downloadDelegate->addProgress(m_offsetWrite);
		}
		return true;
	}
	else
	{
		//cclog
	}
	return false;
}

void CBackgroundDownLoadTask::startDownload(const char* url)
{
	CURLcode res;
	curl_easy_reset(m_handle);

	// set url
	res = curl_easy_setopt(m_handle, CURLOPT_URL, url);
	res = curl_easy_setopt(m_handle, CURLOPT_HEADER, 0);
	res = curl_easy_setopt(m_handle, CURLOPT_NOSIGNAL, 1);
	char buffer[128] = "";
	sprintf(buffer, "%d-", m_offsetWrite);
	res = curl_easy_setopt(m_handle, CURLOPT_RANGE, buffer);
	//res = curl_easy_setopt(m_handle, CURLOPT_RESUME_FROM_LARGE, double(m_offsetWrite));
	// set handle write function
	res = curl_easy_setopt(m_handle, CURLOPT_WRITEFUNCTION, CBackgroundDownLoadTask::onWriteData);
	// set handle object
	res = curl_easy_setopt(m_handle, CURLOPT_WRITEDATA, this);
	res = curl_easy_setopt(m_handle, CURLOPT_FAILONERROR, 1);
	//curl_easy_setopt(m_handle,CURLINFO_SPEED_DOWNLOAD,1);
	curl_easy_setopt(m_handle, CURLOPT_PRIVATE, this);
	curl_easy_setopt(m_handle, CURLOPT_NOPROGRESS, 0);
	curl_easy_setopt(m_handle, CURLOPT_PROGRESSFUNCTION, getProgressValue);  //设置回调的进度函数
	curl_easy_setopt(m_handle, CURLOPT_PROGRESSDATA, url); 
	//res = curl_easy_perform(m_handle);

	CURLMcode code = curl_multi_add_handle(m_multiHandle, m_handle);
}

void CBackgroundDownLoadTask::onComplete( CURLMcode error )
{
	//this_type *op = reinterpret_cast<this_type*>(obj);
	SFDownload::PackageInfoMap::iterator iter = m_urlList.begin();
	this->closeDownWriter();
	if (error != CURLM_OK)
	{
		//CCLOG("CBackgroundDownLoadTask::onComplete is error %d", error);
		//m_downloadDelegate->onError();
	}
	else if(m_downloadDelegate){
		//如果MD5正确，通知成功返回/
		std::string filePath = m_storage + "/" + m_filename;
		if(this->checkMD5(filePath.c_str(), iter->second.md5.c_str()))
		{
			m_downloadDelegate->onSuccess(m_filename.c_str(), iter->second.size);
		}
		else
		{
			//反之，返回错误。onError
			m_downloadDelegate->onError(kNetwork);
		}
		m_downloadDelegate->resetProgress();
	}
	m_urlList.erase(iter);
	m_downloading = false;
}

bool CBackgroundDownLoadTask::multiDownloading()
{
	int result = multiPerform();

	if (result)
	{
		int size = -1;

		fd_set fr = { };
		fd_set fw = { };
		fd_set fe = { };

		CURLMcode e = curl_multi_fdset(m_multiHandle, &fr, &fw, &fe, &size);
		if (e != CURLE_OK)
		{
			return false;
		}

		long t = -1;
		timeval time = { 1, 0 };

		e = curl_multi_timeout(m_multiHandle, &t);
		if (e == CURLE_OK)
		{
			if (t >= 0)
			{
				time.tv_sec = t / 1000;

				if (time.tv_sec > 1)
					time.tv_sec = 1;
				else
					time.tv_usec = (t % 1000) * 1000;
			}
		}


		int res = select(size + 1, &fr, &fw, &fe, &time);
	}

	if (updateMulti())
		multiPerform();

	return true;
}

int CBackgroundDownLoadTask::multiPerform()
{
	int result = 0;
	CURLMcode e = CURLM_OK;

	do
	{
		e = curl_multi_perform(m_multiHandle, &result);
		// about this
		// http://curl.haxx.se/libcurl/c/curl_multi_perform.html
	} while (e == CURLM_CALL_MULTI_PERFORM);

	if (e != CURLE_OK)
	{
		return result;
	}

	return result;
}

bool CBackgroundDownLoadTask::updateMulti()
{
	int count = 0;
	bool res = false;
	CURLMsg *msg = 0;

	while ((msg = curl_multi_info_read(m_multiHandle, &count)))
	{
		res = true;
		if (msg->msg == CURLMSG_DONE)
		{
			//update_handle(msg->easy_handle, msg->data.result);
			CURLMcode e = curl_multi_remove_handle(m_multiHandle, m_handle);
// 			if (e != CURLE_OK)
// 			{
// 				return false;
// 			}
			this->onComplete(e);
		}
		else
		{
			//cclog
		}
	}

	return res;
}

std::size_t CBackgroundDownLoadTask::onWriteData( const char *buffer, std::size_t size, std::size_t nmemb, void *obj )
{
	if(m_downloadDelegate)
    {
		m_downloadDelegate->addProgress(nmemb);
        //CCLOG("onWriteData::speedDelegate d %d",nmemb);
	}
    if(m_downWriter)
		fwrite(buffer, size, nmemb, m_downWriter);
	return nmemb;
}



void CBackgroundDownLoadTask::setDelegate( SFDownloadDelegateProtocl* delegate )
{
	CC_SAFE_RELEASE(m_downloadDelegate);
	m_downloadDelegate = delegate;
	CC_SAFE_RETAIN(m_downloadDelegate);
}

CBackgroundDownLoadTask* CBackgroundDownLoadTask::instance()
{
	if ( sm_pInstance == NULL )
	{
		sm_pInstance = new CBackgroundDownLoadTask;
	}
	return sm_pInstance;
}

void CBackgroundDownLoadTask::fini()
{
	if ( sm_pInstance )
	{
// 		if(sm_pInstance->isRunning())
// 		{
// 			CC_SAFE_RELEASE_NULL(m_downloadDelegate);
// 			sm_pInstance->shutDown();
// 		}
//		CCLOG("CBackgroundDownLoadTask::fini() %d",sm_pInstance->thread_->threadId_);
		delete sm_pInstance;
		sm_pInstance = NULL;
	}
	CC_SAFE_RELEASE_NULL(m_downloadDelegate);
}

bool CBackgroundDownLoadTask::speedDelegate(double dt, double dn)
{
    
	if(m_handle)
	{
		double speed;
		curl_easy_getinfo(m_handle, CURLINFO_SPEED_DOWNLOAD, &speed);
		m_currentSpeed = speed/1024;
        //CCLOG("CBackgroundDownLoadTask::speedDelegate dt:%f dn:%f %f kb/s",dt,dn,m_currentSpeed);
		if (m_downloadDelegate)
		{
			m_downloadDelegate->setDownloadSpeed(m_currentSpeed);
		}
		return true;
	}
	return false;
}

bool CBackgroundDownLoadTask::checkMD5( const char* filePatch, const char* md5 )
{
	bool ret = false;
	MD5_CTX CheckMD5_CTX;
	char szmd5[33] = {0};
	if(CheckMD5_CTX.GetFileMd5(szmd5, filePatch))
	{
		if (strcmp(szmd5, md5) == 0)
		{
			ret = true;
		}
	}
	return ret;
}

void CBackgroundDownLoadTask::closeDownWriter()
{
	if ( m_downWriter != NULL )
	{
		fclose(m_downWriter);
		m_downWriter = NULL;
	}
}


