#ifndef __SF_DOWNLOAD_H__
#define __SF_DOWNLOAD_H__
// @brief: 
// @author: typ77
// @data: [2/12/2014 typ77]
//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 
#include <list>
#include <string>
#include <curl/curl.h>
#include <pthread.h>
#include "utils/SFExecutionThreadService.h"
USING_NS_CC;
class CBackgroundDownLoadTask;
enum ErrorCode
{
	// Error caused by creating a file to store downloaded data
	kCreateFile,
	/** Error caused by network
		-- network unavaivable
		-- timeout
		-- ...
		*/
	kNetwork,
	/** There is not a new version
		*/
	kNoNewVersion,
	/** Error caused in uncompressing stage
		-- can not open zip file
		-- can not read file global information
		-- can not read file information
		-- can not create a directory
		-- ...
		*/
	kUncompress,
};

struct SFDownloadData
{
	int m_eventCode;
	int m_intValue;
	const char* m_strValue;
};
class SFDownloadDelegateProtocl : public CCObject
{
public:
	virtual~SFDownloadDelegateProtocl(){};
	virtual void onError(ErrorCode errorCode){};
	virtual void onSuccess(const char* filename, unsigned int size) {};
	virtual void onComplete(){};
	virtual void onFilesize(const char* filename, unsigned int size){};
	virtual void onAllFilesSize(unsigned int size){};
	virtual void sendLuaDelegate(float dt){};
	void  setDownloadSpeed(double speed){m_downloawdSpeed = speed;};
	void resetProgress(){m_progressSum = 0;};
	void  addProgress(int progress){m_progressSum += progress;};
	virtual void stop(){};
	virtual void start(){};
protected:
	double m_downloawdSpeed;
	int m_progressSum;
	int m_errorCode;
	int m_intValue;
	std::string m_strValue;
};
enum DownLoadEvent
{
	kOnError,
	kOnProgress,
	kOnSuccess,
	kOnFilesize,
	kOnAllFilesSize,
	kOnDownloadSpeed,
	kOnComplete,
	kMax	// 仅仅作为标记用
};
// todo add lua
class SFDownLoadDelegateLua : public SFDownloadDelegateProtocl
{
public:
	SFDownLoadDelegateLua();
	virtual~SFDownLoadDelegateLua();
	virtual void onError(ErrorCode errorCode);
	virtual void onSuccess(const char* filename, unsigned int size);
	virtual void onFilesize(const char* filename, unsigned int size);
	virtual void onAllFilesSize(unsigned int size);
	virtual void onComplete();
	virtual void sendLuaDelegate(float dt);
	virtual void stop();
	virtual void start();
public:
	
	void setHandler(int nHnader){m_handler = nHnader;};
private:
	int m_handler;
	std::list<SFDownloadData> m_eventList;
	pthread_mutex_t m_mutexLock;
};


class SFDownload
{
public:
	struct SFPackageInfo 
	{
		unsigned int size;
		std::string  md5;
	};
	typedef std::map<std::string, SFPackageInfo> PackageInfoMap;
public:
	SFDownload();
	virtual ~SFDownload();

	// 信息回调：所有文件包大小，下载进度，下载完成通知，错误回调
	void setDelegate(SFDownloadDelegateProtocl* delegate);

	void setConnectionTimeout(unsigned int timeout);
	unsigned int getConnectionTimeout();

	void setStoragePath(const char* storagePath);
	const char* getStoragePath();
	// 添加下载url
	bool addPackageUrl(const char* url, const char* md5);
	// 开始下载。优先检查资源路径资源包是否存在。检查
	void startDownload();
	void stopDownLoad();
	//unsigned int getFileLength();
public:
	friend void* downloadAndPackage(void*);
	friend int	 progressFunc(void *, double, double, double, double);
	friend void* checkPackageSize(void *);
protected:

	void			prepare();
private:
	bool				m_download;
	unsigned int		m_connectionTimeout;
	pthread_t*			m_tid;
	CURL*				m_curl;
	std::string			m_storagePath;
	PackageInfoMap		m_packageUrlList;
	SFDownloadDelegateProtocl* m_delegate;

	cocos2d::SFSemaphoreLock m_threadLock;
};


#endif