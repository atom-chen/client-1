/********************************************************************
	created:	2013/10/15
	created:	15:10:2013   19:27
	filename: 	E:\client\trunk\scripting\lua\cocos2dx_support\SFScriptManager.h
	file path:	E:\client\trunk\scripting\lua\cocos2dx_support
	file base:	SFScriptManager
	file ext:	h
	author:		Liu Rui
	
	purpose:	
*********************************************************************/

#ifndef SFScriptManager_h__
#define SFScriptManager_h__

#include <string>
#include <set>

extern "C"{
	#include "lauxlib.h"
	extern int loader_zpk(lua_State *L);
};

namespace cocos2d{
	class CCScriptEngineProtocol;
};

class SFScriptManager
{
public:
	static SFScriptManager* shareScriptManager();
	cocos2d::CCScriptEngineProtocol* getScriptEngine();

	int excuteZpkLua(const char* name);
	void setZpkSupport(bool bSupport);
	bool isSearchZpk();
	std::set<std::string> getSearchPath();

private:
	SFScriptManager();
	~SFScriptManager(){}

private:
	bool m_bSupportZpk;

	std::set<std::string> m_strSearchPathSet;

	// 从内存加载lua脚本
	int loadLuaBuffer(unsigned char* pszBuffer, unsigned long fileSize, const char* pszName);

	// 从内存执行lua脚本
	int doLuaBuffer(unsigned char* pszBuffer, unsigned long fileSize, const char* pszName);
};

#endif // SFScriptManager_h__