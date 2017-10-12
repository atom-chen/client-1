#ifndef SFSocketCommService_h
#define SFSocketCommService_h
#include "SFNetMessage.h"

#include <queue>
#include <string>

typedef void CURL;

namespace cocos2d {
	class StateBlock;

enum NetworkStatus
{
	NETWORK_BROKE = -2,
	NETWORK_OK = 0,
	NETWORK_NOT_READY,
	NETWORK_SEND_OK,
	NETWORK_DATA_RECV_AGAIN,
	NETWORK_DATA_READY,
	NETWORK_BUSY, 
	NETWORK_MAX
};
typedef enum NetworkStatus NetworkStatus; 

class SFCommunicationListener /*: public CCObject*/
{
public:
	virtual void handleBytesReceived(const unsigned short& nOpcode, const char* pDataBuffer, unsigned short nDataSize) = 0;

	virtual void handleError(const int nErrorCode, const std::string &errorStr) = 0;
};

class SFSocketCommService : public SFExecutionThreadService
{
public:
	SFSocketCommService();
	virtual ~SFSocketCommService();
	enum State
	{
		CONNECT_ETABLISHING,
		CONNECT_CLOSING,
		SEND,
		NORMAL
	};
public:
	bool initWithListener(SFCommunicationListener *communicationListener);
	static SFSocketCommService* socketCommServiceWithListener(SFCommunicationListener *communicationListener);

public:
	void connect(const char *ipAddress, int port);
	void disconnect();
	bool isConnected();

	void addTcpActionRequest(StateBlock* actionRequest);
	void addTcpActionRequest(const char* pDataBuffer, const unsigned int& nDataSize);
	void getRecvPack(std::queue<StateBlock*>& out);

protected:
	virtual bool doRun();
	
public:
	CC_SYNTHESIZE(std::string, socketAddress_, SocketAddress);
	CC_SYNTHESIZE(int, port_, Port);
	//std::string socketAddress_;
	void setLuaHandler(int nhandler){m_luaHandler = nhandler;};
private:
	int waitOnSocket(bool for_recv, long timeoutMs);
	bool sendData(const char* pDataBuffer, const unsigned int& nDataSize);
	bool sendActionRequest();
	bool receiveActionMessage();

	void _connect();
	void _disconnect();

private:
	

	CURL						*curl_;
	bool										readyConnect;
	SFSemaphoreLock				readyConnectLock_;

	bool										readyDisConnect;
	SFSemaphoreLock				readyDisConnectLock_;
	
	std::queue<StateBlock*> sendActionRequestQueue_;
	SFSemaphoreLock sendQueueLock_;
	std::queue<StateBlock*> recvActionRequestQueue_;
	SFSemaphoreLock recvQueueLock_;

	bool										isConnected_;
	char						cbRecvBuffer_[NET_PACKET_SIZE];

	size_t						nRecvSize_;
	int							m_luaHandler;
};
}
#endif
