/********************************************************************
	created:	2013/04/19
	created:	19:4:2013   14:36
	filename: 	E:\jiuxian\client_sulation\trunk\mf.game\Classes\game\Object\Resource\ResourceUpdateMgr.h
	file path:	E:\jiuxian\client_sulation\trunk\mf.game\Classes\game\Object\Resource
	file base:	ResourceUpdateMgr
	file ext:	h
	author:		Liu Rui
	
	purpose:	资源更新
*********************************************************************/

#ifndef __SFPackageUpdateMgr_h__
#define __SFPackageUpdateMgr_h__

#include "include/utils/SFExecutionThreadService.h"
#include "package/SFPackageManager.h"
#include <string>
#include <vector>
#include <map>
namespace zp
{
	class IPackage;
	class IReadFile;
};

class SFPackageUpdateMgr : public cocos2d::SFExecutionThreadService
{
public:
	SFPackageUpdateMgr();
	virtual ~SFPackageUpdateMgr();

	static SFPackageUpdateMgr* instance();
	static void fini();
public:
	// 添加一个基本包的包.可以设置多个
	bool addBasePackage(const char* packagePatch);
	// 添加一个增量更新包，需要路径。可以设置多个
	void addPatch(const char* patchPath);
	// 清理
	void clearAll();
	// 开始更新
	void startUpdate();
	// 设置delegate
	void setDelegate(SFPackgePatchDelegate* delegate);
private:
	typedef std::list<zp::IPackage*> ZPackVector;
	typedef std::map<std::string, zp::IPackage*> ZPackMap;

	ZPackMap		m_basePackage;
	ZPackVector		m_patchPackage;

	void closeFileIO();

	// 从zpk的文件名获取包名
	std::string getPackageNameFromFilePath(const char* filePath);
	// 从zpk的路径获取包名
	std::string getPackageNameFromPackPath(const char* packPath);

	bool performUpdate();
	virtual bool doRun();
	static bool compare(const zp::IPackage* a, const zp::IPackage* b);
private:
	int m_totalCount;
	int m_totalFinishCount;
	SFPackgePatchDelegate* m_mergeDelegate;
};

#endif // __ResourceUpdateMgr_h___h__