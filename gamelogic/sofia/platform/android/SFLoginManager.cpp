#include "include/platform/SFLoginManager.h"
#include "script_support/CCScriptSupport.h"
#include "android/com_morningglory_shell_GardeniaLogin.h"

SFLoginManager* SFLoginManager::_instance=NULL;

SFLoginManager::SFLoginManager()
{
	m_gameKey = "";
	m_uuId = "";
	m_loginSettingUrl = "";
	m_bridgeUrl = "";
	m_platform = "";
	m_qKey = "";
	m_suffix = "";
	m_needShowLogin = true;
}

SFLoginManager::~SFLoginManager()
{

}

SFLoginManager* SFLoginManager::getInstance()
{
	if (_instance==NULL)
	{
		_instance = new SFLoginManager();
	}
	return _instance;
}

void SFLoginManager::requestLogin()
{
	// 不同的平台要重写这个方法
}

void SFLoginManager::setLuaCallback( int handler )
{
	m_handler = handler;
}

void SFLoginManager::setLuaRequestServerListCB(int handler)
{
	m_requestServerListHandler = handler;
}

void SFLoginManager::setLuaBridgeAuthCB(int handler)
{
	m_bridgeAuthHandler = handler;
}

void SFLoginManager::setLuaWaitViewCB(int handler)
{
	m_waitViewHandler = handler;
}

void SFLoginManager::onLoginResult( int errCode, const char* data )
{

}

void SFLoginManager::requestServerList()
{
	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	engine->executeLoginCB(m_requestServerListHandler,NULL, 0, 0);
}

void SFLoginManager::getServerListSuccess(char* data)
{
	if (m_needShowLogin) {
		cocos2d::CCLog(data);
		jni_getSrvListSuccess(data);  //jni
	}
	m_needShowLogin = true;
}

// void SFLoginManager::setLuaBirdgeAuthData(const char* authDada)
// {
// 	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
// 	engine->executeLoginCB(m_bridgeAuthHandler, authDada, strlen(authDada), 0);
// }

void SFLoginManager::gotoBridgeAuth()
{
	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	engine->executeLoginCB(m_bridgeAuthHandler, "", 0, 0);
}

std::string SFLoginManager::getAuthData()
{
	return jni_getAuthData();
}

std::string SFLoginManager::getBridgeUrl()
{
	m_bridgeUrl = jni_getBridgeUrl();
	cocos2d::CCLog("SFLoginManager  getBridgeUrl = %s", m_bridgeUrl.c_str());
	return m_bridgeUrl;
}

std::string SFLoginManager::getLoginSettingUrl()
{
	m_loginSettingUrl = jni_getLoginSettingUrl();
	return m_loginSettingUrl;
}

int SFLoginManager::getQDCode1()
{
	return jni_getQDCode1();
}

int SFLoginManager::getQDCode2()
{
	return jni_getQDCode2();
}

void SFLoginManager::showWaitView(int sec)
{
	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	engine->executeLoginCB(m_waitViewHandler, "show", strlen("show"), sec);
}

void SFLoginManager::hideWaitView()
{
	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	engine->executeLoginCB(m_waitViewHandler, "hide", strlen("hide"), 0);
}

std::string SFLoginManager::getUUid()
{
	m_uuId = jni_getUUid();
	return m_uuId;
}

std::string SFLoginManager::getGameKey()
{
	m_gameKey = jni_getGameKey();
	return m_gameKey;
}

std::string SFLoginManager::getPlatform()
{
	m_platform = jni_getPlatform();
	return m_platform;
}

std::string SFLoginManager::getQDKey()
{
	m_qKey = jni_getQDKey();
	return m_qKey;
}

std::string SFLoginManager::getSuffix()
{
	m_suffix = jni_getSuffix();
	return m_suffix;
}

void SFLoginManager::openPay(char* dataJson, int handler)
{
	jni_openPay(dataJson, handler);
}

void SFLoginManager::executePayCallback(int handler, int state)
{
	if (handler != 0)
	{
		cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeLoginCB(handler, "pay", strlen("pay"), state);
	}
}

void SFLoginManager::bridgeAuthSuccess(const char* response)
{
	jni_bridgeAuthSuccess(response);
}

std::string SFLoginManager::getAppKey()
{
	return "";
}
std::string SFLoginManager::getClientKey()
{
	return "";
}

//下面四个方法，在android中没有用到
void SFLoginManager::setPlayerId(const char* playerId)
{

}
const char* SFLoginManager::getPlayerId()
{

}
void SFLoginManager::setServerId(const char* serverId)
{

}
const char* SFLoginManager::getServerId()
{

}

void SFLoginManager::submitExtendData(const char* extendData)
{
	jni_submitExtendData(extendData);
}

bool SFLoginManager::needShowUserCenter()
{
	return jni_needShowUserCenter();
}

void SFLoginManager::showUserCenter()
{
	jni_showUserCenter();
}

void SFLoginManager::logout()
{
	jni_logout();
}

bool SFLoginManager::needShowCustomTopupView()
{
	return jni_needShowCustomTopupView();
}

void SFLoginManager::openPayWithCustomAmount(char* dataJson)
{
	jni_openPay(dataJson, 0);
}

void SFLoginManager::setLogOutHandler(int handler)
{
	m_logoutHandler = handler;
}

void SFLoginManager::excuteLogOutCallBack(bool needShowLogin)
{
	m_needShowLogin = needShowLogin;
	if (m_logoutHandler != 0) {
		cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeControlEvent(m_logoutHandler, 0);
	}
}

 void SFLoginManager::setPlayerName(const char* playerName)
 {

 }

 void SFLoginManager::initPaymentObserver()
 {

 }