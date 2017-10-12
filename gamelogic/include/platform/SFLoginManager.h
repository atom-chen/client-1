/********************************************************************
 created:	2014/01/24
 created:	24:1:2014   11:57
 filename: 	E:\client\trunk\gamelogic\SFLoginManager.h
 file path:	E:\client\trunk\gamelogic
 file base:	SFLoginManager
 file ext:	h
 author:		Liu Rui
 
 purpose:	���ڷ�ƽ̨��¼�߼��Ĺ�����
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
    
	// �����¼, ִ���Զ���¼�߼����ߵ��õ�����SDK
	void requestLogin();
    
	// ����֪ͨ�ص�
	void setLuaCallback(int handler);
    
	// ��¼����ص�
	void onLoginResult(int errCode, const char* data);
	//�ȴ�����
	void showWaitView(int time);
	void hideWaitView();
	//��ȡ�������б�
	void requestServerList();
	//�Žӳɹ�
	void bridgeAuthSuccess(const char* response);
	//��½�ɹ���Ѷ�Ӧ���ݴ���sdk(���ID����������ȼ���������id�����������ƣ�
	void submitExtendData(const char* extendData);
	//�ɹ���ȡ�������б�
	void getServerListSuccess(char* data);
	//�����Ž���֤����
	//void setLuaBirdgeAuthData(const char* authDada);
	void gotoBridgeAuth();
	std::string getAuthData();
	//lua�ص�
	void setLuaRequestServerListCB(int handler);
	void setLuaBridgeAuthCB(int handler);
	void setLuaWaitViewCB(int handler);
	
	//��ֵ
	void openPay(char* dataJson, int handler);
	void openPayWithCustomAmount(char* dataJson);
	void executePayCallback(int handler, int state);  //state=1�ɹ��� state=0 ʧ��
    
	//��ȡurl
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
	int m_handler;	// lua��֪ͨ�ص�
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