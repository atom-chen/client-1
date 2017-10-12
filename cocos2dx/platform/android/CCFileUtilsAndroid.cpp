/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "CCFileUtilsAndroid.h"
#include "support/zip_support/ZipUtils.h"
#include "platform/CCCommon.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"

using namespace std;

NS_CC_BEGIN

// TODO: IOS和android要做统一的处理
#include <semaphore.h>

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

SFSemaphoreLock gLock;

class LockHolder
{
public:
	explicit LockHolder(SFSemaphoreLock& lock_)
		:m_lock(lock_)
	{
		m_lock.lock();
	}

	~LockHolder()
	{
		m_lock.unlock();
	}
private:
	SFSemaphoreLock &m_lock;
};
// TODO-END

// record the zip on the resource path
static ZipFile *s_pZipFile = NULL;

CCFileUtils* CCFileUtils::sharedFileUtils()
{
    if (s_sharedFileUtils == NULL)
    {
        s_sharedFileUtils = new CCFileUtilsAndroid();
        s_sharedFileUtils->init();
        std::string resourcePath = getApkPath();
        s_pZipFile = new ZipFile(resourcePath, "assets/");
    }
    return s_sharedFileUtils;
}

CCFileUtilsAndroid::CCFileUtilsAndroid()
{
}

CCFileUtilsAndroid::~CCFileUtilsAndroid()
{
    CC_SAFE_DELETE(s_pZipFile);
	CC_SAFE_DELETE(m_lockPackage);
}

bool CCFileUtilsAndroid::init()
{
	m_lockPackage = new SFSemaphoreLock;
    m_strDefaultResRootPath = "assets/";
    return CCFileUtils::init();
}

bool CCFileUtilsAndroid::isFileExist(const std::string& strFilePath)
{
    if (0 == strFilePath.length())
    {
        return false;
    }

	if (strFilePath.find("zpk/") == 0)
	{
		// 指定了要从zpk读取, 不尝试去ZIP里面读取
		std::string strPath = strFilePath.substr(4, strFilePath.length()-4);
		//CCLog("filterPackTag:%s", strPath.c_str());
		return m_fileLoader && m_fileLoader->isFileExist(strPath);
	}
	else
	{
		if (m_fileLoader && 0 < m_fileLoader->isFileExist(strFilePath))
			return true;

		bool bFound = false;

		// Check whether file exists in apk.
		if (strFilePath[0] != '/')
		{
			std::string strPath = strFilePath;
			if (strPath.find(m_strDefaultResRootPath) != 0)
			{// Didn't find "assets/" at the beginning of the path, adding it.
				strPath.insert(0, m_strDefaultResRootPath);
			}

			if (s_pZipFile->fileExists(strPath))
			{
				bFound = true;
			} 
		}
		else
		{
			FILE *fp = fopen(strFilePath.c_str(), "r");
			if(fp)
			{
				bFound = true;
				fclose(fp);
			}
		}
		return bFound;
	}
}

bool CCFileUtilsAndroid::isAbsolutePath(const std::string& strPath)
{
    // On Android, there are two situations for full path.
    // 1) Files in APK, e.g. assets/path/path/file.png
    // 2) Files not in APK, e.g. /data/data/org.cocos2dx.hellocpp/cache/path/path/file.png, or /sdcard/path/path/file.png.
    // So these two situations need to be checked on Android.
    if (strPath[0] == '/' || strPath.find(m_strDefaultResRootPath) == 0)
    {
        return true;
    }
    return false;
}



unsigned char* CCFileUtilsAndroid::getFileData(const char* pszFileName, const char* pszMode, unsigned long * pSize)
{    
    unsigned char * pData = 0;

    if ((! pszFileName) || (! pszMode) || 0 == strlen(pszFileName))
    {
        return 0;
    }

	// Add by Liu Rui 2014-2-24
	std::string strFileName = filterPackTag(pszFileName);
	pszFileName = strFileName.c_str();

  //  if (pszFileName[0] != '/')
  //  {
  //      CCLog("GETTING FILE RELATIVE DATA: %s", pszFileName);
  //      string fullPath = fullPathForFilename(pszFileName);

		//// 防止线程之间的冲突
		//gLock.lock();
  //      pData = s_pZipFile->getFileData(fullPath.c_str(), pSize);
		//gLock.unlock();
  //  }
  //  else
  //  {
  //  
  //  }

	do 
	{
		// read rrom other path than user set it
		//      CCLog("GETTING FILE ABSOLUTE DATA: %s", pszFileName);
		//if(!m_bOpenFile)
		//{
		//	for (std::vector<std::string>::iterator searchPathsIter = m_searchPathArray.begin();
		//		searchPathsIter != m_searchPathArray.end(); ++searchPathsIter)
		//	for (std::vector<std::string>::iterator resOrderIter = m_searchResolutionsOrderArray.begin();
		//		resOrderIter != m_searchResolutionsOrderArray.end(); ++resOrderIter)
		//	{
		//		std::string path = searchPathsIter->c_str();
		//		path += resOrderIter->c_str();
		//		path.erase(path.size()-1);
		//		path += ".zpk";

		//		CCLog("zpk path: %s", path.c_str());

		//		m_pack = zp::open((const zp::Char*)path.c_str(), zp::OPEN_READONLY);
		//		m_bOpenFile = true;
		//		if (m_pack)
		//			break;
		//	}
		//}
		//if(m_pack)
		//{
		//	LockHolder lock_(*m_lockPackage);
		//	zp::IReadFile* file = m_pack->openFile(pszFileName+1);
		//	if(file)
		//	{
		//		pData = new unsigned char[file->size()];
		//		*pSize = file->read((zp::u8*)pData, file->size());
		//		m_pack->closeFile(file);
		//	}
		//}

		if (m_fileLoader)
		{
			if (pszFileName[0] == '/')
			{
				pszFileName = pszFileName + 1;
			}
			pData = m_fileLoader->getFileData(pszFileName, (long*)pSize);
			//if (pData)
			//{
			//	CCLog("Get File Data From Zpk: %s", pszFileName);
			//}
		}

		if (pData == NULL)
		{
			if (pszFileName[0] == '/')
			{
				pszFileName = pszFileName + 1;
			}

			std::string strPath = pszFileName;
			if (strPath.find(m_strDefaultResRootPath) != 0)
			{// Didn't find "assets/" at the beginning of the path, adding it.
				strPath.insert(0, m_strDefaultResRootPath);
			}

			//string fullPath = fullPathForFilename(pszFileName);

			// 防止线程之间的冲突
			gLock.lock();
			pData = s_pZipFile->getFileData(strPath.c_str(), pSize);
			//if (pData)
			//{
			//	CCLog("GETTING FILE RELATIVE DATA: %s", strPath.c_str());
			//}
			gLock.unlock();
		}

		if(pData == NULL)
		{
			FILE *fp = fopen(pszFileName, pszMode);
			CC_BREAK_IF(!fp);

			unsigned long size;
			fseek(fp,0,SEEK_END);
			size = ftell(fp);
			fseek(fp,0,SEEK_SET);
			pData = new unsigned char[size];
			size = fread(pData,sizeof(unsigned char), size,fp);
			fclose(fp);

			if (pSize)
			{
				*pSize = size;
			}     
		}
	} while (0);    

    if (! pData)
    {
        std::string msg = "Get data from file(";
        msg.append(pszFileName).append(") failed!");
        CCLog(msg.c_str());
    }

    return pData;
}

string CCFileUtilsAndroid::getWritablePath()
{
    // Fix for Nexus 10 (Android 4.2 multi-user environment)
    // the path is retrieved through Java Context.getCacheDir() method
    string dir("");
    string tmp = getFileDirectoryJNI();

    if (tmp.length() > 0)
    {
        dir.append(tmp).append("/");

        return dir;
    }
    else
    {
        return "";
    }
}

std::string CCFileUtilsAndroid::filterPackTag( const char* pszText )
{
	std::string ret = pszText;

	std::size_t pos = ret.find("zpk/");
	if (pos == 0)
	{
		ret = ret.substr(3, ret.length()-3);
	}

	return ret;
}

void CCFileUtilsAndroid::setFileLoader( CCFileLoader* loader )
{
	m_fileLoader = loader;
	if (m_fileLoader)
	{
		// 这里要修改android的默认搜索路径的顺序, 保证读取文件的时候是先搜索zpk，再搜索assets
		m_searchPathArray.clear();
		m_searchPathArray.push_back("zpk/");

		// getFileData现在默认会先去尝试从zpk里面加载，再去搜索assets, 不需要再添加assets的搜索路径
		//m_searchPathArray.push_back(m_strDefaultResRootPath.c_str());
		CCLog("CCFileUtilsAndroid setFileLoader");
	}
	else
	{
		m_searchPathArray.clear();
		m_searchPathArray.push_back(m_strDefaultResRootPath.c_str());
	}
}

unsigned long CCFileUtilsAndroid::getFileLength( const char* filePath )
{
	unsigned long length = 0;

	if (filePath)
	{
		std::string strFileName = filterPackTag(filePath);
		if (m_fileLoader && m_fileLoader->isFileExist(strFileName.c_str()))
		{
			length = m_fileLoader->getFileLength(strFileName.c_str());
		}
		else
		{
			// 先找apk里面是否有相应的文件
			std::string strApkPath = strFileName;
			if (strApkPath.find(m_strDefaultResRootPath) != 0)
			{// Didn't find "assets/" at the beginning of the path, adding it.
				strApkPath.insert(0, m_strDefaultResRootPath);
			}

			// 防止线程之间的冲突
			gLock.lock();
			length = s_pZipFile->getFileLength(strApkPath.c_str());
			gLock.unlock();

			if (0 == length)
			{
				// 如果在apk也找不到文件, 就查找绝对路径下的文件
				std::string strFullPath = fullPathForFilename(strFileName.c_str());
				FILE *fp = fopen(strFullPath.c_str(), "r");
				if (fp)
				{
					fseek(fp,0,SEEK_END);
					length = ftell(fp);
					fclose(fp);
				}
			}
		}
	}

	return length;
}

NS_CC_END
