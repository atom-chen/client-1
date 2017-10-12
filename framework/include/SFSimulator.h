#ifndef MFSIMULATOR_H
#define MFSIMULATOR_H

#include <map>
#include <string>
#include "net/NetSystem.h"
#include "net/Network.h"
#include "eventset/SubscriberSlot.h"
#include "stream/iStream.h"

#include "scene/SFGamePresenter.h"
#include "core/ActionEventBase.h"


class SFCommunicationListener
{
public:
	virtual void handleRecv(ActionEventBase* recvEvent) = 0;
};

class SFTcpConnectionListener
{
public:
	virtual void handleConnected(ActionEventBase *conEvent) = 0;
	virtual void handleDisconnected(ActionEventBase *closeEvent) = 0;
};

class SFHttpResponseListener
{
public:
	virtual void handleHttpResponse(int httpState, const char* requestTag, const char* responseData) = 0;
};

// 给lua用的网络连接事件定义
const int kTcpConnectSuccess = 1;
const int kTcpConnectFail = 2;

class SFGameSimulator : public CCObject
{
public:
	SFGameSimulator(void);
	~SFGameSimulator(void);

public:
	static SFGameSimulator* sharedGameSimulator();
	void purgeGameSimulator();

	CCScene* getPresenterScene();
	SFGamePresenter*     getGamePresenter();
	iBinaryWriter * getBinaryWriter(int eventId);
	void setCommunicationListener(SFCommunicationListener *pListener);
	void setHttpResponseListener(SFHttpResponseListener* pListener);
	void tick();

	// tcp network
public:
	void setTpcConnectionHandler(int nHandler);	// lua的回调

	void enableTcpCommService();//创建tcp服务
	void setTcpConnectionListener(SFTcpConnectionListener* connectListener);//设置监听
	void tcpConnect(std::string ip, int port,int nHandler=0);//链接服务器
	void tcpDisConnect();//断开链接
	bool isTcpConnect();//是否在链接
	
	bool onTcpConnect(const cocos2d::EventArgs& arg);
	bool onTcpRecv(const cocos2d::EventArgs& arg);
	bool onTcpClose(const cocos2d::EventArgs& arg);

public:
	void onRecvGameEvent(ActionEventBase *event);
	void sendTcpActionEvent(ActionEventBase *event);
	void sendTcpActionEventInLua(iBinaryWriter * writer);

	void sendGetHttpRequest(const char* strUrl, const char* requestTag, const char* backupUrl = NULL);
	void sendPostHttpReuqest(const char* strUrl, const char* strData, int dataLen, const char* requestTag, const char* backupUrl = NULL);

private:
	bool init();
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void *data);

private:
	
	NetSystem *m_pNetSystem;
	Network	 *m_pTcpNetWork;

	SFGamePresenter      *gamePresenter_;

	SFTcpConnectionListener *m_pTcpListener;
	SFCommunicationListener *m_pCommunicationListener;
	SFHttpResponseListener	*m_pHttpListener;
	int	m_nHandler;

	std::map<std::string, std::string> m_backupList;
};


#endif