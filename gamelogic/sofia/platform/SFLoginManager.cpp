#include "include/platform/SFLoginManager.h"
#include "script_support/CCScriptSupport.h"
//#include "../game/Classes/Java_com_gardenia_shell_GardeniaLogin.h"

SFLoginManager* SFLoginManager::_instance=NULL;

SFLoginManager::SFLoginManager()
{
	m_config = cocos2d::CCDictionary::createWithContentsOfFile("sdkConfig.plist");
	CC_SAFE_RETAIN(m_config);
	m_logoutHandler = 0;
}

SFLoginManager::~SFLoginManager()
{
	CC_SAFE_RELEASE_NULL(m_config);
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
	//cocos2d::CCLog(data);
	//getSrvListSuccess(data);  //jni
}

void SFLoginManager::gotoBridgeAuth()
{
	//cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	//engine->executeLoginCB(m_bridgeAuthHandler, "", 0, 0);
}

std::string SFLoginManager::getAuthData()
{
	return "";
}


std::string SFLoginManager::getBridgeUrl()
{
	if (m_config) {
		return m_config->valueForKey("AuthUrl")->getCString();
	}
	return "";
}

std::string SFLoginManager::getLoginSettingUrl()
{
	if (m_config) {
	return m_config->valueForKey("LoginSettingUrl")->getCString();
	}
	return "";
}

int SFLoginManager::getQDCode1()
{
	if (m_config) {
	return m_config->valueForKey("QD_Code1")->intValue();
	}
	return 5;
}

int SFLoginManager::getQDCode2()
{
	if (m_config) {
		return m_config->valueForKey("QD_Code2")->intValue();
	}
	return 5;
}

void SFLoginManager::showWaitView(int sec)
{

}

void SFLoginManager::hideWaitView()
{

}

std::string SFLoginManager::getUUid()
{
	return "zzzz";
}

std::string SFLoginManager::getGameKey()
{
	if (m_config) {
	return m_config->valueForKey("Game_Key")->getCString();
	}
	return "";
}
std::string SFLoginManager::getPlatform()
{
	if (m_config) {
		return m_config->valueForKey("Platform")->getCString();
	}
	return "";
}
std::string SFLoginManager::getQDKey()
{
	if (m_config) {
		return m_config->valueForKey("QD_Key")->getCString();
	}
	return "";
}
std::string SFLoginManager::getSuffix()
{
	if (m_config) {
		return m_config->valueForKey("Suffix")->getCString();
	}
	return "";
}

void SFLoginManager::bridgeAuthSuccess(const char* response)
{

}

//充值
void SFLoginManager::openPay(char* dataJson, int handler)
{

}

void SFLoginManager::executePayCallback(int handler, int state)
{

}

std::string SFLoginManager::getAppKey()
{
	return "";
}
std::string SFLoginManager::getClientKey()
{
	return "";
}

void SFLoginManager::setPlayerId(const char* playerId)
{
	m_playerId = std::string(playerId);
}

const char* SFLoginManager::getPlayerId()
{
	return m_playerId.c_str();
}

void SFLoginManager::setServerId(const char* serverId)
{
	m_serverId = std::string(serverId);
}

const char* SFLoginManager::getServerId()
{
	return m_serverId.c_str();
}


void SFLoginManager::submitExtendData(const char* extendData)
{

}

bool SFLoginManager::needShowUserCenter()
{
	return true;
}

void SFLoginManager::showUserCenter()
{

}

void SFLoginManager::logout()
{

}

void SFLoginManager::openPayWithCustomAmount( char* dataJson )
{

}

bool SFLoginManager::needShowCustomTopupView()
{
	return false;
}

void SFLoginManager::setLogOutHandler( int handler )
{
	m_logoutHandler = handler;
}

void SFLoginManager::excuteLogOutCallBack(bool needShowLogin)
{
	if (m_logoutHandler > 0)
	{
		cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeControlEvent(m_logoutHandler,0);
	}
}

void SFLoginManager::setPlayerName(const char* playerName)
{

}

void SFLoginManager::initPaymentObserver()
{

}
