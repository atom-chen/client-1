/********************************************************************
	created:	2013/10/21
	created:	21:10:2013   20:43
	filename: 	E:\Sophia\client\trunk\framework\proj.win32\SFResManager.h
	file path:	E:\Sophia\client\trunk\framework\proj.win32
	file base:	SFResManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	资源管理类
*********************************************************************/

#ifndef SFResManager_h__
#define SFResManager_h__

#include <vector>
#include <string>

#define StringVector std::vector<std::string>

class SFResManager
{
public:
	static SFResManager* Instance();
	~SFResManager();

	// 是否找到了资源
	bool IsFindResource();

	// 返回资源版本号，如果不存在返回0
	int getVersion();

	// 返回指定文件的版本号
	int getVersion(const char* fileName);

	// 资源包是否存在某个文件
	bool FindResFile(const char* fileName);

	// 补丁包升级
	bool addPath(StringVector& resFileVector);

private:
	SFResManager();
};


#endif // SFResManager_h__
