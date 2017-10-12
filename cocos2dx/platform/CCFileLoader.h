/********************************************************************
	created:	2013/10/22
	created:	22:10:2013   16:14
	filename: 	E:\Sophia\client\trunk\cocos2dx\platform\CCFileLoader.h
	file path:	E:\Sophia\client\trunk\cocos2dx\platform
	file base:	CCFileLoader
	file ext:	h
	author:		Liu Rui
	
	purpose:	
*********************************************************************/

#ifndef CCFileLoader_h__
#define CCFileLoader_h__

#include "platform/CCPlatformMacros.h"
#include <string>

NS_CC_BEGIN

class CCFileLoader
{
public:
	// 获取文件长度, filePath包含相对路径
	virtual long getFileLength(const char* filePathe) = 0;

	//获取文件数据
	virtual unsigned char* getFileData(const char* filePath, long* length)=0;

	virtual bool isFileExist(const std::string& strFilePath) = 0;
};

NS_CC_END

#endif // CCFileLoader_h__
