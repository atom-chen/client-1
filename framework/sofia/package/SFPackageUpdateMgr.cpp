#include "package/SFPackageUpdateMgr.h"
#include "platform/CCFileUtils.h"
#include "utils/SFStringUtil.h"
#include <algorithm>
#include "ccMacros.h"
#include "SFGameHelper.h"
#ifdef _ANDROID
#include <sys/io.h>
#endif

using namespace cocos2d;
static SFPackageUpdateMgr*	s_packageUpdate = NULL;

SFPackageUpdateMgr::SFPackageUpdateMgr()
	: m_totalCount(0)
	, m_totalFinishCount(0)
	, m_mergeDelegate(NULL)
{
	
}

SFPackageUpdateMgr::~SFPackageUpdateMgr()
{
	CCLOG("~SFPackageUpdateMgr");
	CC_SAFE_RELEASE_NULL(m_mergeDelegate);
	this->closeFileIO();
}

void SFPackageUpdateMgr::addPatch( const char* patchPath )
{
	zp::IPackage* package = zp::open(patchPath,0);
	if (package)
	{
		m_patchPackage.push_back(package);
		m_totalCount += package->getFileCount();
		//排序
		m_patchPackage.sort(SFPackageUpdateMgr::compare);
	}
}
// 添加一个基本包。自动补全路径。如果包不存在，需要创建一个空包
bool SFPackageUpdateMgr::addBasePackage( const char* packagePatch )
{
	std::string finalName = this->getPackageNameFromPackPath(packagePatch);
	//std::string packagePatch = SFGameHelper::getExtStoragePath() + packageName;
	const char* pos = strrchr(finalName.c_str(),'/');
    #if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
       pos = strrchr(finalName.c_str(),'\\');
    #endif
	if(NULL==pos)
		return false;
	++pos;
	std::string path = pos;
	size_t startPos = path.find_last_of("."); 
	if(startPos != std::string::npos)
		path = path.erase(startPos);

	zp::IPackage* package = zp::open(packagePatch, 0);
	if(!package)
	{
		package = zp::create(packagePatch);
	}
	ZPackMap::iterator iter = m_basePackage.find(path);
	if (iter == m_basePackage.end())
	{
		m_basePackage[path] = package;
	}
	else
		return false;
	return true;
}

bool SFPackageUpdateMgr::performUpdate()
{
	bool bRet = false;	
	//如果补丁包不为空，合包
	//while (!m_patchPackage.empty())
	for (ZPackVector::iterator patchiter = m_patchPackage.begin(); patchiter!=m_patchPackage.end();++patchiter)
	{
		//ZPackVector::iterator patchiter = m_patchPackage.begin();
		zp::IPackage* patchPackage = (*patchiter);
        
		// check version
		// 1.如果base包是0，则可以直接添加
		// 2.如果base包的版本号，与patch包的升级版本号不对，返回错误。
        
		for (ZPackMap::iterator itr = m_basePackage.begin(); itr != m_basePackage.end(); ++itr)
		{
			if (itr->second->getOldSubVersion() != 0 && itr->second->getSubVersion() != patchPackage->getOldSubVersion())
			{
				if(itr->second->getSubVersion() >= patchPackage->getSubVersion())
                    continue;
                this->closeFileIO();
				if(m_mergeDelegate)
					m_mergeDelegate->onPatchError(0);
				//cclog error the version
				this->shutDown();
				//this->state_ = TERMINATED;
				return false;
			}
		}

		// 版本号正确
		// 取补丁包文件，添加到相应的基础包里面
		zp::u32 filecount = patchPackage->getFileCount();
		for (zp::u32 j = 0; j < filecount; ++j)
		{
			++m_totalFinishCount;
			if(m_mergeDelegate)
				m_mergeDelegate->onPatchProgress(m_totalFinishCount, m_totalCount);
			zp::Char fileName[512] = {0};
			zp::u32 fileSize, compressSize, flag;
			if(patchPackage->getFileInfo(j, fileName, sizeof(fileName)/sizeof(zp::Char), &fileSize, &compressSize, &flag))
			{
				if ((flag & zp::FILE_DELETE) != 0)
				{
					if(m_mergeDelegate)
						m_mergeDelegate->onPatchError(0);
					continue;
				}
				zp::IReadFile* file = patchPackage->openFile(fileName);
				if (file == NULL)
				{
					if(m_mergeDelegate)
						m_mergeDelegate->onPatchError(0);
					continue;
				}
				// 查找有没有对应的基础包
				std::string packageName = getPackageNameFromFilePath(fileName);
				//基础包
				ZPackMap::iterator baseIter = m_basePackage.find(packageName.c_str());
				//找不到基础包
				if (baseIter != m_basePackage.end() && baseIter->second->getSubVersion() < patchPackage->getSubVersion())
				{
					int len = packageName.length();
					std::vector<zp::u8> tempBuffer;
					tempBuffer.resize(file->size());
					file->read(&tempBuffer[0], file->size());
					zp::IWriteFile* writeFile = baseIter->second->createFile((fileName+len+1), fileSize, compressSize, 0, flag);
					if(writeFile->write(&tempBuffer[0], file->size()) == 0)
					{
						if(m_mergeDelegate)
							m_mergeDelegate->onPatchError(0);//error
					}
					baseIter->second->closeFile(writeFile);
				}
				else
				{
					if(m_mergeDelegate)
						m_mergeDelegate->onPatchError(0);
					//CCLOG("ERROR SFPackageUpdateMgr performUpdate"); FILENAME
				}
				patchPackage->closeFile(file);
			}
			else
			{
				if(m_mergeDelegate)
					m_mergeDelegate->onPatchError(0);
			}
		}
		//更新版本号
		for (ZPackMap::iterator itr = m_basePackage.begin(); itr != m_basePackage.end(); ++itr)
		{
            if (patchPackage->getSubVersion() > itr->second->getSubVersion()) {
                itr->second->setOldSubVersion(itr->second->getSubVersion());
                itr->second->setSubVersion(patchPackage->getSubVersion());
                itr->second->flush();
            }
		}
	}
	this->closeFileIO();
	if(m_mergeDelegate)
		m_mergeDelegate->onSuccess();
	
	this->shutDown();
	//this->state_ = TERMINATED;
	return bRet;
}

bool SFPackageUpdateMgr::compare( const zp::IPackage* a, const zp::IPackage* b )
{
	if (!a)
		return true;

	if (!b)
		return false;
	
	// mainVersion的变化的优先级最高
	if (a->getMainVersion() > b->getMainVersion())
		return true;

	if (a->getSubVersion() >= b->getSubVersion())
		return false;

	return true;
}

bool SFPackageUpdateMgr::doRun()
{
	return performUpdate();
}

void SFPackageUpdateMgr::startUpdate()
{
	if (!this->isRunning())
	{

		startUp();
	}
}

std::string SFPackageUpdateMgr::getPackageNameFromFilePath( const char* filePath )
{
	std::string ret;

	if (filePath)
	{
		ret = filePath;
		int pos = ret.find('\\');
		if (pos != -1)
		{
			ret = ret.substr(0, pos);
		}
		else
		{
			pos = ret.find('/');
			if (pos != -1)
			{
				ret = ret.substr(0, pos);
			}
		}
	}

	return ret;
}

std::string SFPackageUpdateMgr::getPackageNameFromPackPath( const char* packPath )
{
	std::string ret;

	if (packPath)
	{
		ret = packPath;
		int pos = ret.find_last_of('\\');
		if (pos != -1)
		{
			ret = ret.substr(pos, ret.length()-pos);
		}
		else
		{
			pos = ret.find_last_of('/');
			if (pos != -1)
			{
				ret = ret.substr(pos, ret.length()-pos);
			}
		}
	}

	return ret;
}

SFPackageUpdateMgr* SFPackageUpdateMgr::instance()
{
	if( s_packageUpdate == NULL)
	{
		s_packageUpdate = new SFPackageUpdateMgr();
	}
	return s_packageUpdate;
}

void SFPackageUpdateMgr::fini()
{
	if (s_packageUpdate)
	{
// 		if(s_packageUpdate->isRunning())
// 		{
// 			s_packageUpdate->shutDown();
// 		}
		CC_SAFE_DELETE(s_packageUpdate);
	}
}

void SFPackageUpdateMgr::closeFileIO()
{
	for (ZPackMap::iterator iter = m_basePackage.begin(); iter != m_basePackage.end(); ++iter)
	{
		zp::close(iter->second);
	}
	m_basePackage.clear();
	for (ZPackVector::iterator itr = m_patchPackage.begin(); itr != m_patchPackage.end(); ++itr)
	{
		zp::close((*itr));
	}
	m_patchPackage.clear();
}

void SFPackageUpdateMgr::clearAll()
{
	m_totalCount = 0;
	m_totalFinishCount = 0;
	this->closeFileIO();
}

void SFPackageUpdateMgr::setDelegate( SFPackgePatchDelegate* delegate )
{
	if (m_mergeDelegate)
	{
		m_mergeDelegate->stop();
	}
	CC_SAFE_RELEASE_NULL(m_mergeDelegate);
	m_mergeDelegate = delegate;
	CC_SAFE_RETAIN(m_mergeDelegate);
}
