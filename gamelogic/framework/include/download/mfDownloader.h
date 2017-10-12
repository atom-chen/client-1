/********************************************************************
	created:	2013/04/16
	created:	16:4:2013   13:28
	filename: 	D:\youai\game_client\engine\include\download\mfDownloader.h
	file path:	D:\youai\game_client\engine\include\download
	file base:	mfDownloader
	file ext:	h
	author:		
	purpose:	文件下载模块接口（支持断点续传、文件分拆下载）
*********************************************************************/
#ifndef __MF_DOWNLOADER_H_
#define __MF_DOWNLOADER_H_

#include <string>
#include <list>
#include <vector>

class CBackgroundDownLoadTask;
class MFDownloader;

namespace cocos2d {
	class SFSemaphoreLock;
};

// ----------------------------------------------------------------------------
// class MFDLProgressListener
// 下载进度回调接口(这种方式直接设置cocos2dx里面的label会报错）
// ---------------------------------------------------------------------------- 
class MFDownloadListener
{
public:
	// 当前文件下载量的进度更新(totalBytes没有用）
	virtual void OnUpdateProgress(std::size_t dlBytes, std::size_t totalBytes) = 0;

	// 文件数量的下载进度
	//virtual void OnUpdateFileProgress(int dlNumber, int allNumber) = 0;

	// 当下载文件失败时
	virtual void OnDownLoadFailed(int errorCode, const char *errorStr, const char *fileName) = 0;

	virtual void onDownloadComplete(const char *fileName) = 0;
};

// ----------------------------------------------------------------------------
// class MFDownloader
// - 下载服务器的相对目录结构应该与本地的目录结构一致
// - MFDownloader根据remote base path解析出相对目录，并保存文件到这个目录
// ---------------------------------------------------------------------------- 
class MFDownloader
{
public:
	~MFDownloader();

	static MFDownloader &instance();
	static void fini(); // 释放资源

	void setListener(MFDownloadListener *listener) { m_progress_listener = listener;}

	void start(int numThreads=1 );	 // 开始下载
	void cancel();					 // 取消下载
	void tick();

	//const std::string &getRemoteBasePath() { return m_remoteBasePath; }
	//void setRemoteBasePath(const char *basePath); // 下载服务器的根目录
	const std::string &getWritePath() { return m_writePath; }
	void setWritePath(const char *writePath); // 保存到本地的根目录
	void addTaskFile(const char *filename); // 添加下载文件（全目录文件名称）

	bool isDownloading() { return m_downloading_; }
	bool empty();
	std::string pullURL();
	//std::size_t getDownloadedBytes() { return m_downloadedBytes; } 
	//std::size_t getDownloadTotalBytes() { return m_downloadTotalBytes; } 
	int responseCode() { return m_response_code; }
	// progress
	void onDownloadFileComplete(const char* filename);
	void onUpdateDownloadBytes(std::size_t nbytes, std::size_t nTotalbytes);
	void onDownloadFailed(int e, const char*errMsg, const char *filename, int response_code=0);

private:
	MFDownloader();
	void clear_bg_task();

	static MFDownloader *sm_pInstance;
	cocos2d::SFSemaphoreLock	*m_mutex;
	//cocos2d::SFSemaphoreLock	*m_mutex_progress;
	MFDownloadListener *m_progress_listener;
	std::string m_remoteBasePath;
	std::string m_writePath;
	int m_curDownloadFileNum;
	int m_allDownloadFileNum;
	std::size_t m_downloadedBytes;
	std::size_t m_downloadTotalBytes;
	std::size_t m_allDownloadedBytes;
	bool m_downloading_;
	int m_error_code;
	int m_response_code;
	std::string m_error_msg;
	std::string m_error_file_name;

	std::list<std::string>				m_downloadedFileList;
	std::list<std::string>				m_downloadURLList;
	std::list<CBackgroundDownLoadTask*> m_bgTaskList;

}; // class MFDownloader



#endif // __MF_DOWNLOADER_H_