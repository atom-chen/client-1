/********************************************************************
 created:	2014/01/24
 created:	24:1:2014   11:57
 filename: 	E:\client\trunk\gamelogic\SFLoginManager.h
 file path:	E:\client\trunk\gamelogic
 file base:	SFLoginManager
 file ext:	h
 author:		Liu Rui
 
 purpose:	处于分平台登录逻辑的管理类
 *********************************************************************/

#ifndef SFLoginManager_h__
#define SFLoginManager_h__
#include "cocos2d.h"
#include <string>

class SFLoginManager
{
public:
	static SFLoginManager* getInstance();
	~SFLoginManager();
    
	// 请求登录, 执行自动登录逻辑或者调用第三方SDK
	void requestLogin();
    
	// 设置通知回调
	void setLuaCallback(int handler);
    
	// 登录结果回调
	void onLoginResult(int errCode, const char* data);
	//等待界面
	void showWaitView(int time);
	void hideWaitView();
	//获取服务器列表
	void requestServerList();
	//桥接成功
	void bridgeAuthSuccess(const char* response);
	//登陆成功后把对应数据传给sdk(玩家ID、玩家名、等级、服务器id、服务器名称）
	void submitExtendData(const char* extendData);
	//成功获取服务器列表
	void getServerListSuccess(char* data);
	//设置桥接认证数据
	//void setLuaBirdgeAuthData(const char* authDada);
	void gotoBridgeAuth();
	std::string getAuthData();
	//lua回调
	void setLuaRequestServerListCB(int handler);
	void setLuaBridgeAuthCB(int handler);
	void setLuaWaitViewCB(int handler);
	
	//充值
	void openPay(char* dataJson, int handler);
	void openPayWithCustomAmount(char* dataJson);
	void executePayCallback(int handler, int state);  //state=1成功， state=0 失败
    
	//获取url
	std::string getBridgeUrl();
	std::string getLoginSettingUrl();
	int getQDCode1();
	int getQDCode2();
	std::string getUUid();
	std::string getGameKey();
	std::string getPlatform();
	std::string getQDKey();
	std::string getSuffix();
    std::string getAppKey();
    std::string getClientKey();
    void setPlayerId(const char* playerId);
    void setPlayerName(const char* playerName);
    const char* getPlayerId();
    void setServerId(const char* serverId);
    const char* getServerId();
	bool needShowUserCenter();
	bool needShowCustomTopupView();
	void showUserCenter();
	void logout();
	void setLogOutHandler(int handler);
	void excuteLogOutCallBack(bool needShowLogin = true);
    void initPaymentObserver();
private:
	SFLoginManager();
    std::string m_playerId;
    std::string m_serverId;
	int m_handler;	// lua的通知回调
	int m_requestServerListHandler;
	int m_bridgeAuthHandler;
	int m_waitViewHandler;
	static SFLoginManager* _instance;
	std::string m_gameKey;
	std::string m_uuId;
	std::string m_loginSettingUrl;
	std::string m_bridgeUrl;
	std::string m_platform;
	std::string m_qKey;
	std::string m_suffix;
    cocos2d::CCDictionary* m_config;
    bool m_needShowLogin;
	int m_logoutHandler;
};


#endif // SFLoginManager_h__