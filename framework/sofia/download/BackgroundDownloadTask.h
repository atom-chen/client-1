#ifndef _BACKGROUND_DOWNLOAD_TASK_H_
#define _BACKGROUND_DOWNLOAD_TASK_H_

#include "utils/SFExecutionThreadService.h"
#include "download/SFDownload.h"
class SFDownload;
// ----------------------------------------------------------------------------
// class CBackgroundDownLoadTask
// - 后台下载队列
// ---------------------------------------------------------------------------- 
using namespace cocos2d;


class CBackgroundDownLoadTask : public SFExecutionThreadService
{
public:
	CBackgroundDownLoadTask(void);
	virtual ~CBackgroundDownLoadTask(void);

	static CBackgroundDownLoadTask* instance();
	static void fini(); // 释放资源
	void	addDownloadUrl(SFDownload::PackageInfoMap& infoMap);
	void	setStoragePath(const char* storagePath);
	const char* getStoragePath();
	void	setDelegate(SFDownloadDelegateProtocl* delegate);
protected:
	virtual bool doRun();

	void start();
	void startDownload(const char* url);
	//void onStartLoad();
	bool busy() { return m_downloading; }
	bool checkFileAlreadyDownload(const char* file);

	
	static std::size_t onWriteData(const char *buffer, std::size_t size, std::size_t nmemb, void *obj);
	friend int getProgressValue(const char* flag, double dt, double dn, double ult, double uln);
	void onComplete(CURLMcode error);

	bool multiDownloading();
	int multiPerform();
	bool updateMulti();
	bool speedDelegate(double dt, double dn);

	bool checkMD5(const char* filePatch, const char* md5);
	void closeDownWriter();

private:
	static CBackgroundDownLoadTask *sm_pInstance;
	std::string				m_storage;

	SFDownload::PackageInfoMap m_urlList;
	bool					m_downloading;
	static int						m_offsetWrite;
	static SFDownloadDelegateProtocl* m_downloadDelegate;

	static FILE*			m_downWriter;

	CURL*					m_handle;
	CURLM*					m_multiHandle;
	std::string				m_filename;
	double	                  m_currentSpeed;
};

#endif // _BACKGROUND_DOWNLOAD_TASK_H_