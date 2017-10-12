#include <vector>
#include "SFSimulator.h"
#include "sofia/utils/MessageFactory.h"
#include "network/HttpRequest.h"
#include "network/HttpResponse.h"
#include "network/HttpClient.h"
#include "script_support/CCScriptSupport.h"
#include "utils/SFPriorityNotificationCenter.h"
USING_NS_CC;
USING_NS_CC_EXT;

//////////////////////////////////////////////////////////////////////////


static SFGameSimulator *sharedGameSimulator_static = NULL;


SFGameSimulator::SFGameSimulator( void ):m_pNetSystem(0),m_pTcpNetWork(0),gamePresenter_(0),m_pTcpListener(0),
	m_pCommunicationListener(0), m_pHttpListener(0), m_nHandler(0)
{

}

SFGameSimulator::~SFGameSimulator( void )
{
	CC_SAFE_DELETE(m_pNetSystem);
	CCHttpClient::destroyInstance();
}


SFGameSimulator* SFGameSimulator::sharedGameSimulator()
{
	if (sharedGameSimulator_static == NULL)
	{
		sharedGameSimulator_static = new SFGameSimulator();
		sharedGameSimulator_static->init();
	}

	return sharedGameSimulator_static;
}

void SFGameSimulator::purgeGameSimulator()
{
	CC_SAFE_DELETE(gamePresenter_);
	CC_SAFE_DELETE(sharedGameSimulator_static);
	PurgeMsgEvent;
}

bool SFGameSimulator::init()
{
	m_pNetSystem = new NetSystem;
	m_pNetSystem->Run();

	gamePresenter_ = SFGamePresenter::gamePresenter();
	gamePresenter_->retain(); 

	CCHttpClient::getInstance()->setTimeoutForConnect(15);
	CCHttpClient::getInstance()->setTimeoutForRead(15);

	return true;
}

void SFGameSimulator::enableTcpCommService()
{
	if(m_pTcpNetWork == NULL)
	{
		m_pTcpNetWork = m_pNetSystem->CreateNetwork();
		m_pTcpNetWork->SubscribeEvent(Network::ConnectEvent,  new SubscriberSlot(&SFGameSimulator::onTcpConnect, this) );
		m_pTcpNetWork->SubscribeEvent(Network::RecvEvent,  new SubscriberSlot(&SFGameSimulator::onTcpRecv, this) );
		m_pTcpNetWork->SubscribeEvent(Network::CloseEvent,  new SubscriberSlot(&SFGameSimulator::onTcpClose, this) );
	}
}

CCScene* SFGameSimulator::getPresenterScene()
{
	return gamePresenter_->scene();
}


SFGamePresenter* SFGameSimulator::getGamePresenter()
{
	return gamePresenter_;
}

bool SFGameSimulator::onTcpConnect(const cocos2d::EventArgs& arg)
{
	CCLOG("connected");
 	NetConnectEvent* connectEvent = (NetConnectEvent*)&arg;
	if (m_pTcpListener)
	{
		MFNetConnectEvent event;
		event.errorCode = connectEvent->code;
		event.success = connectEvent->code == 0;
		m_pTcpListener->handleConnected(&event);
	}

	if (0 != m_nHandler)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(m_nHandler, connectEvent->code);
	}

	return true;
}

bool SFGameSimulator::onTcpRecv(const cocos2d::EventArgs& arg)
{
	//引擎事件
	NetRecvEvent* recvEvent = (NetRecvEvent*)&arg;
	iBinaryReader * pReader = recvEvent->reader;
	short opCode = pReader->ReadShort();
	//CCLOG("TCP Recv id:%d",opCode);
	SFPriorityNotificationCenter* notificationCenter  = SFPriorityNotificationCenter::sharedPriorityNotificationCenter();
	notificationCenter->postNotification(opCode,pReader);
	if (0 != m_nHandler)
	{
		
		//CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(m_nHandler, opCode);
	}else{
		//获取网络事件
		ActionEventBase* event = GetMsgEvent(ActionEventBase, opCode);
		if (event == NULL)
		{
			//CCLOG("error:onTcpRecv msgId:%d not exsit", opCode);
			return true;
		}
		//CCLOG("RecvTcpActionEvent msgId:%d", event->actionEventId, recvEvent->msgLen);
		event->unpackFromBuffer(pReader);
		onRecvGameEvent(event);
	}
	//游戏事件
	return true;
}

bool SFGameSimulator::onTcpClose(const cocos2d::EventArgs& arg)
{
	NetCloseEvent* closeEvent = (NetCloseEvent*)&arg;
	if (m_pTcpListener)
	{
		MFNetCloseEvent event;
		event.errorCode = closeEvent->code;
		m_pTcpListener->handleDisconnected(&event);
	}
	if (0 != m_nHandler)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeControlEvent(m_nHandler, closeEvent->code);
	}
// 	std::cout << "bool GameScene::OnClose(const cocos2d::EventArgs& arg)" << std::endl;
	return true;
}

void SFGameSimulator::tick()
{
	m_pNetSystem->Tick();
}

void SFGameSimulator::onRecvGameEvent( ActionEventBase *event )
{
	if (m_pCommunicationListener)
		m_pCommunicationListener->handleRecv(event);
}

void SFGameSimulator::setCommunicationListener( SFCommunicationListener *pListener )
{
	m_pCommunicationListener = pListener;
}

void SFGameSimulator::setTcpConnectionListener( SFTcpConnectionListener* connectListener )
{
	m_pTcpListener = connectListener;
}

void SFGameSimulator::setHttpResponseListener( SFHttpResponseListener* pListener )
{
	m_pHttpListener = pListener;
}

void SFGameSimulator::tcpConnect( std::string ip, int port,int nHandler )
{
	if (m_pTcpNetWork)
	{
		// lua 的回调统一在SFGameSimulator处理, 所有的消息都在SFSocketCommService封装成消息包
		m_pTcpNetWork->Connect(ip.c_str(), port,0);
		m_nHandler = nHandler;
	}
}

bool SFGameSimulator::isTcpConnect()
{
	if (m_pTcpNetWork)
	{
		return m_pTcpNetWork->IsConnect();
	}
	return false;
}

void SFGameSimulator::tcpDisConnect()
{
	if (m_pTcpNetWork)
	{
		m_pTcpNetWork->Disconnect();
	}
}

void SFGameSimulator::sendTcpActionEvent( ActionEventBase *event )
{
	if (m_pTcpNetWork)
	{
		//CCLOG("sendTcpActionEvent msgId:%d", event->actionEventId);
		iBinaryWriter *pWriter =m_pTcpNetWork->BeginPack();
		pWriter->WriteUShort(event->actionEventId);
		event->packToBuffer(pWriter);
		m_pTcpNetWork->EndPack();
	}
}

void SFGameSimulator::sendGetHttpRequest( const char* strUrl, const char* requestTag, const char* backupUrl )
{
	if (!strUrl || !requestTag)
		return;

	if (backupUrl && strlen(backupUrl) > 0)
	{
		// 以Tag作为key保存备用地址
		m_backupList.insert(std::pair<std::string, std::string>(requestTag, backupUrl));
	}

	CCHttpRequest* request = new CCHttpRequest();
	request->setUrl(strUrl);
	request->setRequestType(CCHttpRequest::kHttpGet);
	request->setTag(requestTag);
	request->setResponseCallback(this, callfuncND_selector(SFGameSimulator::onHttpRequestCompleted));
	CCHttpClient::getInstance()->send(request);
}

void SFGameSimulator::sendPostHttpReuqest( const char* strUrl, const char* strData, int dataLen, const char* requestTag, const char* backupUrl )
{
	if (!strUrl || !strData || dataLen <= 0 || !requestTag)
		return;

	if (backupUrl && strlen(backupUrl) > 0)
	{
		// 以Tag作为key保存备用地址
		m_backupList.insert(std::pair<std::string, std::string>(requestTag, backupUrl));
	}

	CCHttpRequest* request = new CCHttpRequest();
	request->setUrl(strUrl);
	request->setRequestType(CCHttpRequest::kHttpPost);
	request->setRequestData(strData, dataLen);
	request->setTag(requestTag);
	request->setResponseCallback(this, callfuncND_selector(SFGameSimulator::onHttpRequestCompleted));
	CCHttpClient::getInstance()->send(request);
}

void SFGameSimulator::onHttpRequestCompleted( cocos2d::CCNode *sender, void *data )
{
	CCHttpResponse* response = (CCHttpResponse*)data;
	if (response)
	{
		if (200 != response->getResponseCode())
		{
			CCHttpRequest* request = response->getHttpRequest();

			// 请求失败, 如果还有备用地址，用备用地址再请求一次
			std::map<std::string, std::string>::iterator iter = m_backupList.find(request->getTag());
			if (iter != m_backupList.end())
			{
				request->setUrl(iter->second.c_str());
				CCHttpClient::getInstance()->send(request);
				m_backupList.erase(iter);
				return;
			}
		}
		
		if (m_pHttpListener)
		{
			std::string ret;
			std::vector<char> *buffer = response->getResponseData();
			int size = buffer->size();

			for (int i = 0; i < size; ++i)
			{
				ret.push_back((*buffer)[i]);
			}

			m_pHttpListener->handleHttpResponse(response->getResponseCode(), response->getHttpRequest()->getTag(), ret.c_str());
		}

		//request的内存要自己释放，不能autoRelease
		response->getHttpRequest()->release();
	}
}

iBinaryWriter * SFGameSimulator::getBinaryWriter(int eventId)
{
	//CCLOG("Send tcp event:%d",eventId);
	iBinaryWriter* writer = m_pTcpNetWork->BeginPack();
	writer->WriteShort(eventId);
	return writer;
}

void SFGameSimulator::sendTcpActionEventInLua( iBinaryWriter * writer )
{
	m_pTcpNetWork->EndPack();
}

void SFGameSimulator::setTpcConnectionHandler( int nHandler )
{
	m_nHandler = nHandler;
}
