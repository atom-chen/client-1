#include "package/SFPackageManager.h"
#include "platform/CCFileUtils.h"
#include "SFGameHelper.h"
#include "package/SFPackageUpdateMgr.h"
#include "script_support/CCScriptSupport.h"
USING_NS_CC;
SFPackageManager::SFPackageManager()
	: m_mergeing(false)
{
	cocos2d::CCFileUtils::sharedFileUtils()->setFileLoader(this);
}

SFPackageManager::~SFPackageManager()
{
	this->releaseLoadPackage();
}

SFPackageManager* SFPackageManager::Instance()
{
	static SFPackageManager* instance = NULL;
	if (!instance)
		instance = new SFPackageManager();
	
	return instance;
}

bool SFPackageManager::isFileExist( const std::string& strFilePath )
{
	bool bRet = false;
	if(strFilePath.size())
	{
		for (PackageList::iterator iter = m_packageList.begin(); iter != m_packageList.end(); ++iter)
		{
			if((*iter)->hasFile(strFilePath.c_str()))
			{	
				bRet = true;
				break;
			}
		}
	}
	return bRet;
}

long SFPackageManager::getFileLength( const char* filePath )
{
	long ret = 0;
	for (PackageList::iterator iter = m_packageList.begin(); iter != m_packageList.end(); ++iter)
	{
		zp::IReadFile* readFile =  (*iter)->openFile(filePath);
		if (readFile)
		{
			ret = readFile->size();
			(*iter)->closeFile(readFile);
			break;
		}
	}
	return ret;
}

unsigned char* SFPackageManager::getFileData( const char* filePath, long* length )
{
	unsigned char* pBuffer = NULL;
	for (PackageList::iterator iter = m_packageList.begin(); iter != m_packageList.end(); ++iter)
	{
		zp::IReadFile* readFile =  (*iter)->openFile(filePath);
		if(readFile)
		{
			*length = readFile->size();
			pBuffer = new unsigned char[readFile->size()+1];
			memset(pBuffer, 0, readFile->size()+1);
			readFile->read(pBuffer, readFile->size());
			(*iter)->closeFile(readFile);
			return pBuffer;
		}
	}
	return pBuffer;
}

void SFPackageManager::setResourcePath( const char* path )
{
	m_resourcePath = path;
}

SFPackageVersion SFPackageManager::addPackageName( const char* name )
{
	SFPackageVersion version;
	memset(&version,0,sizeof(SFPackageVersion));
	//android / pc / ios app
	//1.读取SD卡/硬盘/doc是否有。不存在返回false
	// SD卡路/硬盘路径 + 相对路径 + 资源包名字
	std::string path = SFGameHelper::getExtStoragePath() + m_resourcePath + name;
	//SFGameHelper::getExtStoragePath();
	//这里应该处理掉是SD卡的路径全称
	zp::IPackage* package = zp::open(path.c_str(),0);
	if(package)
	{
		version.mainVersion = package->getMainVersion();
		version.subVersion = package->getSubVersion();
		m_packageList.push_back(package);
		m_packageNameList.push_back(path);
	}
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	//app zpk
	std::string appPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(name);
	zp::IPackage* packageApp = zp::open(appPath.c_str(), zp::OPEN_READONLY);
	if(packageApp)
	{
		m_packageList.push_back(packageApp);
        if (!package) {
            version.mainVersion = packageApp->getMainVersion();
            version.subVersion = packageApp->getSubVersion();
            m_packageNameList.push_back(path);
        }
	}
	//自己获取doc和app路径
#else// (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#endif
	return version;
}

void SFPackageManager::releaseLoadPackage()
{
	for (PackageList::iterator iter = m_packageList.begin(); iter != m_packageList.end(); ++iter)
	{
		zp::close(*iter);
	}
	m_packageList.clear();
	m_packageNameList.clear();
}

void SFPackageManager::setPackageDelegateProtocl( SFPackgePatchDelegate* delegate )
{
	SFPackageUpdateMgr::instance()->setDelegate(delegate);
}

void SFPackageManager::mergePackage( const char* patchPackage )
{
	std::string path = SFGameHelper::getExtStoragePath() + patchPackage;
	SFPackageUpdateMgr::instance()->addPatch(path.c_str());
}

void SFPackageManager::startMerge()
{
	for (std::list<std::string>::iterator iter = m_packageNameList.begin(); iter != m_packageNameList.end(); ++iter)
	{
		SFPackageUpdateMgr::instance()->addBasePackage((*iter).c_str());
	}
 	releaseLoadPackage();
	m_mergeing = true;
	SFPackageUpdateMgr::instance()->startUpdate();
}

std::string SFPackageManager::getFileStringContent(const char* filePath)
{
	std::string ret;
	if (filePath)
	{
		unsigned long fileSize = 0;
		unsigned char* pBuff = CCFileUtils::sharedFileUtils()->getFileData(filePath, "r", &fileSize);
		if (pBuff && fileSize > 0)
		{
			char strContent[128] = {0};
			memcpy(strContent, pBuff, sizeof(char)*fileSize);
			//sprintf(strContent, "%s", (char*)pBuff);
			ret = strContent;
			delete []pBuff;
		}
	}

	return ret;
}

void SFPackageManager::completePackage()
{
	m_mergeing = false;
	SFPackageUpdateMgr::instance()->fini();
}

void SFPackgePatchLuaDelegate::onPatchProgress( int current, int total )
{
	m_current = current;
	m_total = total;
}

void SFPackgePatchLuaDelegate::onPatchError( int errorCode )
{
	if (m_handler != 0)
	{
		m_error = errorCode;
	}
}

void SFPackgePatchLuaDelegate::onSuccess()
{
	if (m_handler != 0)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executePatchCallBack(m_handler,eOnSuccess,0,0,0);
	}
}

SFPackgePatchLuaDelegate::SFPackgePatchLuaDelegate()
	:m_handler(0)
{
	m_current = 0;
	m_total = 0;
	m_error = -1;
	CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(SFPackgePatchLuaDelegate::sendPatchDelegate),this,1,false);
}

SFPackgePatchLuaDelegate::~SFPackgePatchLuaDelegate()
{
	
}

void SFPackgePatchLuaDelegate::sendPatchDelegate( float dt )
{
	if (m_handler)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executePatchCallBack(m_handler,eOnPatchProgress,0,m_current,m_total);
		if (m_error != -1)
		{
			engine->executePatchCallBack(m_handler,eOnError,m_error,0,0);
			m_error = -1;
		}
	}
}

void SFPackgePatchLuaDelegate::stop()
{
	CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(SFPackgePatchLuaDelegate::sendPatchDelegate),this);
	m_handler = 0;
}
