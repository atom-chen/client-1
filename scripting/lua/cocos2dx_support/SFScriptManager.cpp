#include "SFScriptManager.h"
#include "CCLuaEngine.h"
#include "platform/CCFileUtils.h"
#include "platform/CCCommon.h"
#include "cocoa/CCString.h"
#include <string>

// 自定义的lua loader, 从zpk里面读取lua文件
extern "C"{
	int loader_zpk(lua_State *L)
	{
		int iRet = 0;
		const char *name = luaL_checkstring(L, 1);
		if (name && SFScriptManager::shareScriptManager()->isSearchZpk())
		{
			std::set<std::string> searchPath = SFScriptManager::shareScriptManager()->getSearchPath();
			std::set<std::string>::reverse_iterator iter = searchPath.rbegin();
			for (; iter != searchPath.rend(); ++iter)
			{
				std::string fileName = *iter + "/" + name;
				const char* pszSrc = ".";
				const char* pszDest = "/";

				std::string::size_type pos = 0;
				std::string::size_type srcLen = strlen(pszSrc);
				std::string::size_type desLen = strlen(pszDest);
				pos = fileName.find(pszSrc, pos); 
				while ((pos != std::string::npos))
				{
					fileName = fileName.replace(pos, srcLen, pszDest);
					pos = fileName.find(pszSrc, (pos+desLen));
				}

				fileName += ".lua";
                
				if (cocos2d::CCFileUtils::sharedFileUtils()->isFileExist(fileName.c_str()))
				{
					unsigned long fileSize = 0;
					unsigned char* pBuffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "r", &fileSize);
					if (pBuffer && fileSize > 0)
					{
						iRet = 1;
						if (luaL_loadbuffer(L, (const char*)pBuffer, fileSize, name) != 0)
						{
							luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
								lua_tostring(L, 1), name, lua_tostring(L, -1));
						}
					}

					delete[] pBuffer;
					break;
				}
			}
		}
		
		return iRet;
	}
}

SFScriptManager* SFScriptManager::shareScriptManager()
{
	static SFScriptManager* inst = new SFScriptManager;
	return inst;
}


cocos2d::CCScriptEngineProtocol* SFScriptManager::getScriptEngine()
{
	return cocos2d::CCLuaEngine::defaultEngine();
}

int SFScriptManager::excuteZpkLua( const char* name )
{
	bool iRet = 0;
	std::string path;
	
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//    if (!m_bSupportZpk)
//	{
//		// win32如果没有打包zpk, 有base和extent的目录
//		path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(name);
//	}
//	else
//	{
//		path = name;
//	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	if (!m_bSupportZpk)
	{
		// win32如果没有打包zpk, 有base和extent的目录
		std::string realPath = std::string("base/")+name;
		path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(realPath.c_str());
	} 
	else
	{
		path = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(name);
	}
#else
	path = name;
#endif 
	
	std::string strSearchPath = path.substr(0, path.find_last_of("/"));
	if (m_strSearchPathSet.find(strSearchPath) == m_strSearchPathSet.end())
	{
		m_strSearchPathSet.insert(strSearchPath);
	}

	if (!m_bSupportZpk)
	{
		cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		//cocos2d::CCString* pstrFileContent = cocos2d::CCString::createWithContentsOfFile(name);
		//if (pstrFileContent)
		//{
		//	pEngine->executeString(pstrFileContent->getCString());
		//}

		unsigned long fileSize = 0;
		unsigned char* pBuffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(name, "r", &fileSize);

		if (pBuffer && fileSize > 0)
		{
			iRet = doLuaBuffer(pBuffer, fileSize, name);
			//iRet = cocos2d::CCLuaEngine::defaultEngine()->executeString((const char*)pBuffer);
			delete[] pBuffer;
		}
#else
		pEngine->addSearchPath(strSearchPath.c_str());
		pEngine->executeScriptFile(path.c_str());
#endif
	}
	else
	{
		unsigned long fileSize = 0;
		unsigned char* pBuffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(name, "r", &fileSize);

		if (pBuffer && fileSize > 0)
		{
			iRet = doLuaBuffer(pBuffer, fileSize, name);
			//iRet = cocos2d::CCLuaEngine::defaultEngine()->executeString((const char*)pBuffer);
			delete[] pBuffer;
		}
	}

	return iRet;
}

bool SFScriptManager::isSearchZpk()
{
	return m_bSupportZpk;
}

void SFScriptManager::setZpkSupport( bool bSupport )
{
	m_bSupportZpk = bSupport;
}

SFScriptManager::SFScriptManager():m_bSupportZpk(false)
{

}

std::set<std::string> SFScriptManager::getSearchPath()
{
	return m_strSearchPathSet;
}

int SFScriptManager::loadLuaBuffer( unsigned char* pszBuffer, unsigned long fileSize, const char* pszName )
{
	if (!pszBuffer)
	{
		cocos2d::CCLog("Error!Try load empty buffer");
		return -1;
	}

	if (!pszName)
	{
		cocos2d::CCLog("Error!Try load buffer empty name");
		return -1;
	}

	int iRet = -1;
	cocos2d::CCLuaStack *stack = cocos2d::CCLuaEngine::defaultEngine()->getLuaStack();
	if (stack && stack->getLuaState())
	{
		lua_State* L = stack->getLuaState();
		iRet = luaL_loadbuffer(L, (const char*)pszBuffer, fileSize, pszName);
		if (iRet != 0)
		{
			luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
				lua_tostring(L, 1), pszName, lua_tostring(L, -1));
		}
	}
	else
	{
		cocos2d::CCLog("Error!Get empty CCLuaStack");
	}

	return iRet;
}

int SFScriptManager::doLuaBuffer( unsigned char* pszBuffer, unsigned long fileSize, const char* pszName )
{
	if (!pszBuffer)
	{
		cocos2d::CCLog("Error!Try do empty buffer");
		return -1;
	}

	if (!pszName)
	{
		cocos2d::CCLog("Error!Try do buffer empty name");
		return -1;
	}

	int iRet = -1;
	cocos2d::CCLuaStack *stack = cocos2d::CCLuaEngine::defaultEngine()->getLuaStack();
	if (stack && stack->getLuaState())
	{
		lua_State* L = stack->getLuaState();
		iRet = luaL_loadbuffer(L, (const char*)pszBuffer, fileSize, pszName);
		if (!iRet)
			iRet = lua_pcall(L, 0, 0, 0);

		if (iRet != 0)
		{
			luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
				lua_tostring(L, 1), pszName, lua_tostring(L, -1));
		}
	}
	else
	{
		cocos2d::CCLog("Error!Get empty CCLuaStack");
	}

	return iRet;
}


