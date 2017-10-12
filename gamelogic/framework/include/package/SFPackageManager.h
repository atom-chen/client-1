/********************************************************************
	created:	2013/10/22
	created:	22:10:2013   16:36
	filename: 	E:\Sophia\client\trunk\framework\include\package\SFPackageManager.h
	file path:	E:\Sophia\client\trunk\framework\include\package
	file base:	SFPackageManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	资源包的升级、读取
*********************************************************************/

#ifndef SFPackageManager_h__
#define SFPackageManager_h__
#include "../../zpack/zpack.h"
#include "platform/CCFileLoader.h"
#include <vector>
#include <string>
#include <list>
#include "cocos2d.h"
// namespace cocos2d{
// class SFPackage;
// }

class SFPackgePatchDelegate :public cocos2d::CCObject
{
public:
	virtual void onPatchProgress(int current, int total){};
	virtual void onPatchError(int errorCode){};
	virtual void onSuccess(){};
	virtual void stop(){};
	//virtual void on
};

enum PatchEvent
{
	eOnPatchProgress,
	eOnError,
	eOnSuccess,
};

class SFPackgePatchLuaDelegate: public SFPackgePatchDelegate
{
public:
	SFPackgePatchLuaDelegate();
	virtual ~SFPackgePatchLuaDelegate();
	virtual void onPatchProgress(int current, int total);
	virtual void onPatchError(int errorCode);
	virtual void onSuccess();
	virtual void setLuaHandler(int nHandler){m_handler = nHandler;}
	virtual void sendPatchDelegate(float dt);
	virtual void stop();
private:
	int m_handler;
	int m_current;
	int m_total;
	int m_error;
};

struct SFPackageVersion
{
	int mainVersion;
	int subVersion;
	char format;	// 资源格式
};
// todo support multi zpks read/write
class SFPackageManager : public cocos2d::CCFileLoader
{
public:
	virtual ~SFPackageManager();
	static SFPackageManager* Instance();

	// 设置资源包读取文件夹。只需要设置相对路径
	void setResourcePath(const char* path);
	// 返回加载的包现在版本信息
	SFPackageVersion addPackageName(const char* name);
	// 释放已经加载的IO句柄
	void releaseLoadPackage();

	// 合包api
	// 合包回调 for lua
	//void setPackageCallback(int handle);
	void setPackageDelegateProtocl(SFPackgePatchDelegate* delegate);
	// 合包函数
	void mergePackage(const char* patchPackage);
	// 开始合包
	void startMerge();
	// 合包完成。通知可以读写文件
	void completePackage();
	//获取一个字符串为内容的文件
	std::string getFileStringContent(const char* filePath);
public:
	virtual bool canLoad(){return true;};
	// 文件是否存在, filePath包含相对路径
	virtual bool isFileExist(const std::string& strFilePath);
	// 获取文件长度, filePath包含相对路径
	virtual long getFileLength(const char* filePath);
	//获取文件数据
	virtual unsigned char* getFileData(const char* filePath, long* length);
private:
	SFPackageManager();
private:
	std::string m_resourcePath;
	std::list<std::string> m_packageNameList;
	typedef std::list<zp::IPackage*> PackageList;
	PackageList m_packageList;
	bool		m_mergeing;
};

#endif // SFPackageManager_h__
