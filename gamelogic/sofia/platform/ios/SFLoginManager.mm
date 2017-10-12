#include "include/platform/SFLoginManager.h"
#include "script_support/CCScriptSupport.h"
//#include "../game/Classes/Java_com_gardenia_shell_GardeniaLogin.h"
#include "IosSDKHelper.h"
#import <UIKit/UIKit.h>

SFLoginManager* SFLoginManager::_instance=NULL;

SFLoginManager::SFLoginManager()
{
    m_config = cocos2d::CCDictionary::createWithContentsOfFile("sdkConfig.plist");
    CC_SAFE_RETAIN(m_config);
    m_logoutHandler = 0;
    m_needShowLogin = true;
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
    [[IosSDKHelper sharedSKDHelper] login];
}


void SFLoginManager::bridgeAuthSuccess(const char* response)
{
    [[IosSDKHelper sharedSKDHelper] setLoginAuthData:[NSString stringWithUTF8String:response]];
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
	engine->executeLoginCB(m_requestServerListHandler, NULL, 0, 0);
}

void SFLoginManager::getServerListSuccess(char* data)
{
    [[IosSDKHelper sharedSKDHelper] setLoginData:[NSString stringWithUTF8String:data]];
    if (m_needShowLogin) {
        this->requestLogin();
    }
	m_needShowLogin = true;
}

//void SFLoginManager::setLuaBirdgeAuthData(const char* authDada)
//{
//	cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
//	engine->executeLoginCB(m_bridgeAuthHandler, authDada, (int)strlen(authDada), 0);
//}


void SFLoginManager::gotoBridgeAuth()
{
    cocos2d::CCScriptEngineProtocol* engine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
    engine->executeLoginCB(m_bridgeAuthHandler,"", 0, 0);
}

std::string SFLoginManager::getAuthData()
{
    return [[[IosSDKHelper sharedSKDHelper] getAuthData] UTF8String];
}

std::string SFLoginManager::getBridgeUrl()
{
	//std::string url = jni_getBridgeUrl();
	//return url.c_str();
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
    NSString *uuid = [[IosSDKHelper sharedSKDHelper] getUUID];
    if (uuid)
        return [uuid UTF8String];
    else
        return "";
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
	return "ios";
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

std::string SFLoginManager::getAppKey()
{
    if (m_config) {
        return m_config->valueForKey("QD_Property1")->getCString();
    }
    return "";
}

std::string SFLoginManager::getClientKey()
{
    if (m_config) {
        return m_config->valueForKey("QD_Property2")->getCString();
    }
    return "";
}

void SFLoginManager::setPlayerId(const char *playerId)
{
    m_playerId = std::string(playerId);
}

const char*  SFLoginManager::getPlayerId()
{
    return m_playerId.c_str();
}

void  SFLoginManager::setServerId(const char *serverId)
{
    m_serverId = std::string(serverId);
}

const char* SFLoginManager::getServerId()
{
    return m_serverId.c_str();
}

/*
 std::string infoText = "{playerId}|{playerName}|{eUrl}|{qd1}|{qd2}|{gameKey}";
 playerId 为auth data下面的identityId字段
 playername 为playername
 eUrl 为rechargeChannelJson
 
 NSString *usrname = (NSString*)CFURLCreateStringByAddingPercentEscapes(nil,
 (CFStringRef)openid, nil,
 (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
 NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 */
void SFLoginManager::openPay(char *dataJson, int handler)
{
    NSString* data = [NSString stringWithUTF8String:dataJson];
    NSLog(@"%s",dataJson);
    [[IosSDKHelper sharedSKDHelper] sendPaymentCheckWithJson:data withHandler:handler];
}

void SFLoginManager::executePayCallback(int handler, int state)
{
    
}

void SFLoginManager::submitExtendData(const char* extendData)
{
    [[IosSDKHelper sharedSKDHelper] submitExtendData:[NSString stringWithUTF8String:extendData]];
}

bool SFLoginManager::needShowUserCenter()
{
    if (m_config) {
        const cocos2d::CCString* needSHow = m_config->valueForKey("showUserCenter");
        if (needSHow) {
            return  needSHow->boolValue();
        }
    }
    return false;
}

bool SFLoginManager::needShowCustomTopupView()
{
    if (m_config) {
        const cocos2d::CCString* needSHow = m_config->valueForKey("showCustomTopupView");
        if (needSHow) {
            return  needSHow->boolValue();
        }
    }
    return false;
}

void SFLoginManager::showUserCenter()
{
    [[IosSDKHelper sharedSKDHelper] showUserCenter];
}

void SFLoginManager::logout()
{
    [[IosSDKHelper sharedSKDHelper] logout];
}

void SFLoginManager::openPayWithCustomAmount(char* dataJson)
{
    
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

void SFLoginManager::setPlayerName(const char *playerName)
{
    [[IosSDKHelper sharedSKDHelper] setPlayerName:[NSString stringWithUTF8String:playerName]];
}

void SFLoginManager::initPaymentObserver()
{
    [[IosSDKHelper sharedSKDHelper] initPaymentObserver];
}
