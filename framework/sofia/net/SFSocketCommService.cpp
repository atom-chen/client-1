#include "cocos2d.h"
#include "EngineMacros.h"
#include "utils/SFExecutionThreadService.h"
#include "curl/curl.h"
#include "SFSocketCommService.h"
#include "sofia/utils/StateBlock.h"
#include "sofia/utils/CommonUtility.h"
#include "script_support/CCScriptSupport.h"
#include "../../zpack/zpack.h"
namespace cocos2d {
SFSocketCommService::SFSocketCommService()
	:nRecvSize_(0),isConnected_(false), readyDisConnect(false),readyConnect(0),curl_(0),m_luaHandler(0)
{
	
}

SFSocketCommService::~SFSocketCommService()
{
	{
		SFSemaphoreLockGuard temp(sendQueueLock_);
		while(!sendActionRequestQueue_.empty())
		{
			StateBlock* message = sendActionRequestQueue_.front();
			message->Release();
			sendActionRequestQueue_.pop();
		}
	}

	{
		SFSemaphoreLockGuard temp(recvQueueLock_);
		while(!recvActionRequestQueue_.empty())
		{
			StateBlock* message = recvActionRequestQueue_.front();
			message->Release();
			recvActionRequestQueue_.pop();
		}
	}
}

bool SFSocketCommService::initWithListener(SFCommunicationListener *communicationListener)
{
	return true;
}

SFSocketCommService* SFSocketCommService::socketCommServiceWithListener(SFCommunicationListener *communicationListener)
{
	SFSocketCommService *service = new SFSocketCommService();
	if (service != NULL && service->initWithListener(communicationListener))
	{
		//service->autorelease();
		return service;
	}
	else 
	{
		delete service;
		service = NULL;
		return NULL;
	}
}

bool SFSocketCommService::isConnected()
{
	return isConnected_;
}

bool SFSocketCommService::doRun()
{
	bool bHandle = false;
	{//断开链接
		SFSemaphoreLockGuard temp(readyDisConnectLock_);
		if (readyDisConnect)
		{
			_disconnect();
			readyDisConnect = false;
			bHandle = true;
		}
	}

	{//建立链接
		SFSemaphoreLockGuard temp(readyConnectLock_);
		if (readyConnect)
		{
			_connect();
			readyConnect = false;
			bHandle = true;
		}
	}
	
	if (isConnected_)
	{
		bHandle |= sendActionRequest();
		bHandle |= receiveActionMessage();
	}

	return bHandle;
}

void SFSocketCommService::addTcpActionRequest( const char* pDataBuffer, const unsigned int& nDataSize )
{
	//SFByteBuffer *actionRequest = new SFByteBuffer();
	//actionRequest->append(pDataBuffer, nDataSize);
	StateBlock* sb = StateBlock::GetFreeBlock(nDataSize);
	::memcpy(sb->GetWtPtr(), pDataBuffer, nDataSize);
	sb->PushWtPtr(nDataSize);
	sb->SetState(NORMAL);
	addTcpActionRequest(sb);
}

void SFSocketCommService::addTcpActionRequest(StateBlock* actionRequest)
{
	sendQueueLock_.lock();
	sendActionRequestQueue_.push(actionRequest);
	sendQueueLock_.unlock();
}

bool SFSocketCommService::sendActionRequest()
{
	bool bHandle = false;
	//std::queue<StateBlock*> *waitSendQueue = new std::queue<StateBlock*>();
	sendQueueLock_.lock();
	bHandle = !sendActionRequestQueue_.empty() || !sendActionRequestQueue_.empty();
	while(!sendActionRequestQueue_.empty())
	{
		StateBlock* message = sendActionRequestQueue_.front();
		bool ret = sendData((const char*)message->GetRdPtr(), (const unsigned int)message->GetDataSize());
		if(!ret)
			CCLOG("SFSocketCommService::sendActionRequest is error for sendData");
		sendActionRequestQueue_.pop();
		message->Release();
		//waitSendQueue->push(message);
		//sendActionRequestQueue_.pop();		
	}
	sendQueueLock_.unlock();
	
// 	while(!waitSendQueue->empty())
// 	{
// 		StateBlock *actionRequest = waitSendQueue->front();
// 		// FIXME: bug to hxy, message not sent but message be delete.
// 		sendData((const char*)actionRequest->GetRdPtr(), (const unsigned int)actionRequest->GetDataSize());
// 		waitSendQueue->pop();
// 		actionRequest->Release();
// 	}
// 
// 	delete waitSendQueue;

	return bHandle;
}

bool SFSocketCommService::receiveActionMessage()
{
	int iRet = waitOnSocket(true, 100);
	if (iRet == NETWORK_BROKE)
	{
		SFSemaphoreLockGuard temp(recvQueueLock_);
		StateBlock* sb = StateBlock::GetFreeBlock(1);
		sb->SetState(CONNECT_CLOSING);
		sb->SetErrorCode(iRet);
		recvActionRequestQueue_.push(sb);
		isConnected_ = false;
		//CCLOGERROR("ERROR - socket error");
		//communicationListener_->handleError(iRet, "network error.");
		//if (m_luaHandler != 0)
		//{
		//	CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//	engine->executeControlEvent(m_luaHandler,CONNECT_CLOSING);
		//}
		return false;
	}
	else if (iRet == NETWORK_NOT_READY)
	{
		return false;
	}
	
// 	NetPacketHeader* pHead = (NetPacketHeader*) (curl_);
// 	unsigned short nPacketSize = NET2HOST_16(pHead->wDataSize);
// 	unsigned short step = sizeof(pHead->wDataSize) + nPacketSize;//一个包长度
	size_t len;
	CURLcode res = curl_easy_recv(curl_, cbRecvBuffer_ + nRecvSize_, sizeof(cbRecvBuffer_) - nRecvSize_, &len);
	nRecvSize_ += len;
	if (res != CURLE_OK)
	{
		const char* errorString = curl_easy_strerror(res);
		unsigned long errorLen = strlen(errorString);
		SFSemaphoreLockGuard temp(recvQueueLock_);
		StateBlock* sb = StateBlock::GetFreeBlock(errorLen + 1);
		strcpy(sb->GetWtPtr(), errorString);
		sb->PushWtPtr(errorLen + 1);
		sb->SetState(CONNECT_CLOSING);
		sb->SetErrorCode(res);
		recvActionRequestQueue_.push(sb);
		isConnected_ = false;
		//CCLOGERROR("ERROR - socket error");
		//communicationListener_->handleError(res, "network error.");
		//if (m_luaHandler != 0)
		//{
		//	CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//	engine->executeControlEvent(m_luaHandler,CONNECT_CLOSING);
		//}
		return false;
	}
	//服务器发送过来数据：长度+Op+Data；
	//NetPacketHeader::wDataSize指示的长度是Op+Data
	//所以在内存复制的时候，需要先跳过长度（unsigned short，2个字节）
	//while(nRecvSize_ > sizeof(NetPacketHeader))
	while(nRecvSize_ > 4)
	{
		NetPacketHeader* pHead = (NetPacketHeader*) (cbRecvBuffer_);
		unsigned short nPacketSize = NET2HOST_16(pHead->wDataSize);
		//short op = NET2HOST_16(pHead->wOpcode);
		//char zipFlag = NET2HOST_16(pHead->wZipFlag);
		unsigned short step = sizeof(pHead->wDataSize) + nPacketSize;//一个包长度 date+长度（标识，协议op，协议内容）

		if (nRecvSize_ < step)
		{
			break;
		}
		//if zlib, unzip
		unsigned char *deflated = NULL;
		if(pHead->wZipFlag)
		{
			SFSemaphoreLockGuard temp(recvQueueLock_);
			//int size = sizeof(NetZipPacketHeader);
			//NetZipPacketHeader zipData;
			//memcpy(&zipData, &cbRecvBuffer_[3],sizeof(NetZipPacketHeader));
			short op;
			memcpy(&op, &cbRecvBuffer_[3], sizeof(op));
			//op = NET2HOST_16(op);
			short zipDataSizeBefore, zipDataSizeAfter;
			memcpy(&zipDataSizeBefore, &cbRecvBuffer_[5], sizeof(zipDataSizeBefore));
			memcpy(&zipDataSizeAfter, &cbRecvBuffer_[7], sizeof(zipDataSizeAfter));
			zipDataSizeBefore = NET2HOST_16(zipDataSizeBefore);
			zipDataSizeAfter = NET2HOST_16(zipDataSizeAfter);

			unsigned char *deflated = NULL;

			unsigned int out = 0;
			zp::uncompressMemoryWithHint((unsigned char*)(cbRecvBuffer_+ 9), nPacketSize-7, &deflated,&out,NET_PACKET_DATA_SIZE);
			

 			if(out)
			{
				std::vector<unsigned char> dstBuffer(out);
				//dstBuffer
				//CCLOG("SFSocketCommService::receiveActionMessage op:%d,size1:%d, size2:%d", NET2HOST_16(op),nPacketSize,out);
				memcpy(&dstBuffer[0],deflated,out);
				CC_BREAK_IF(!deflated);

 				StateBlock* sb = StateBlock::GetFreeBlock(out+2);

				*(short*)sb->GetWtPtr() = op;
				sb->PushWtPtr(sizeof(short));

 				memcpy(sb->GetWtPtr(), &dstBuffer[0], out);//忽略第一个unsigned short
 				sb->PushWtPtr(out);
 				sb->SetState(NORMAL);
				//CCLOG("SFSocketCommService::receiveActionMessage op:%d", NET2HOST_16(op));
// 				if(NET2HOST_16(op) == 808)
// 					int i =0;
				//CCLOG("===zip=== op:%d,size1:%d, size2:%d", NET2HOST_16(op),nPacketSize-7,out);
 				recvActionRequestQueue_.push(sb);
 			}
			//else
			//	CCLOG("----SFSocketCommService::receiveActionMessage the out is 0.error op:%d",NET2HOST_16(op));
			CC_SAFE_DELETE_ARRAY(deflated);
		}
		else
		{
			SFSemaphoreLockGuard temp(recvQueueLock_);
			StateBlock* sb = StateBlock::GetFreeBlock(nPacketSize-1);
			short op;
			memcpy(&op, &cbRecvBuffer_[3], sizeof(op));
			memcpy(sb->GetWtPtr(), cbRecvBuffer_+sizeof(pHead->wDataSize)+sizeof(pHead->wZipFlag), nPacketSize-sizeof(pHead->wZipFlag));//忽略第一个unsigned short
			sb->PushWtPtr(nPacketSize-1);
			sb->SetState(NORMAL);
// 			if(NET2HOST_16(op) == 808)
// 				int i =0;
			//CCLOG("===unzip=== op:%d,size1:%d",NET2HOST_16(op),nPacketSize);
			recvActionRequestQueue_.push(sb);
		}
		//CC_SAFE_DELETE_ARRAY(deflated);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		MoveMemory(cbRecvBuffer_, cbRecvBuffer_+step, nRecvSize_ - step);
#else
		memmove(cbRecvBuffer_, cbRecvBuffer_+step, nRecvSize_ - step);
#endif
		nRecvSize_ -= step;
	}
	return true;
}

void SFSocketCommService::getRecvPack(std::queue<StateBlock*>& out)
{
	SFSemaphoreLockGuard temp(recvQueueLock_);
	while (recvActionRequestQueue_.empty() == false)
	{
		StateBlock* sb = recvActionRequestQueue_.front();
		out.push(sb);
		recvActionRequestQueue_.pop();
	}
}

void SFSocketCommService::_connect()
{
	CURLcode curlCode = CURLE_OK;

	curl_ = curl_easy_init();

	if (curl_ == NULL)
	{

	}

	curlCode = curl_easy_setopt(curl_, CURLOPT_URL, socketAddress_.c_str());
	curlCode = curl_easy_setopt(curl_, CURLOPT_PORT, port_);
	curlCode = curl_easy_setopt(curl_, CURLOPT_CONNECT_ONLY,1L);
	curlCode = curl_easy_setopt(curl_, CURLOPT_NOSIGNAL, 1L);

	curlCode = curl_easy_perform(curl_);

	if (curlCode != CURLE_OK)
	{
		const char* errorString = curl_easy_strerror(curlCode);
		unsigned long errorLen = strlen(errorString);
		SFSemaphoreLockGuard temp(recvQueueLock_);
		StateBlock* sb = StateBlock::GetFreeBlock(errorLen + 1);
		strcpy(sb->GetWtPtr(), errorString);
		sb->PushWtPtr(errorLen + 1);
		sb->SetState(CONNECT_CLOSING);
		sb->SetErrorCode(curlCode);
		recvActionRequestQueue_.push(sb);
		CCLOGERROR("libcurl error(%d):%s \n", curlCode,  errorString);
		//if (m_luaHandler != 0)
		//{
		//	CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		//	engine->executeControlEvent(m_luaHandler,curlCode);
		//}
	}
	else
	{
		SFSemaphoreLockGuard temp(recvQueueLock_);
		StateBlock* sb = StateBlock::GetFreeBlock(1);
		sb->SetState(CONNECT_ETABLISHING);
		sb->SetErrorCode(0);
		recvActionRequestQueue_.push(sb);

		isConnected_ = true;//建立成功
	}

	//connectionListener_->handleConnected();
	nRecvSize_ = 0;
}

void SFSocketCommService::_disconnect()
{
	curl_easy_cleanup(curl_);
	curl_ = NULL;
	isConnected_ = false;
}

void SFSocketCommService::connect(const char *ipAddress, int port)
{
	this->socketAddress_ = std::string(ipAddress);
	this->port_ = port;


	SFSemaphoreLockGuard temp(readyConnectLock_);
	readyConnect = true;

}

void SFSocketCommService::disconnect()
{
	SFSemaphoreLockGuard temp(readyDisConnectLock_);
	readyDisConnect = true;
}

int SFSocketCommService::waitOnSocket(bool for_recv, long timeoutMs)
{
	curl_socket_t sockfd;
	CURLcode res = curl_easy_getinfo(curl_, CURLINFO_LASTSOCKET, &sockfd);

	if ( CURLE_OK != res || sockfd == - 1 )
	{
		//CCLOG("ERROR - get socket info error : %s", curl_easy_strerror(res));
		return NETWORK_BROKE;
	}

	struct timeval tv;
	tv.tv_sec = timeoutMs / 1000;
	tv.tv_usec= (timeoutMs % 1000) * 1000;

	fd_set infd, outfd, errfd;
	FD_ZERO(&infd);
	FD_ZERO(&outfd);
	FD_ZERO(&errfd);

	FD_SET(sockfd, &errfd); /* always check for error */

	if ( for_recv )
	{
		FD_SET(sockfd, &infd);
	}
	else
	{
		FD_SET(sockfd, &outfd);
	}

	/* select() returns the number of signalled sockets or -1 */
	int resSelect = ::select(sockfd + 1, &infd, &outfd, &errfd, &tv);
	if ( resSelect < 0 )
	{
		return NETWORK_BROKE;
	}
	else
	{
		resSelect = NETWORK_NOT_READY;
		if ( for_recv )
		{
			if ( FD_ISSET(sockfd, &infd) ) 
			{
//				CCLOG("socket ready for read");
				resSelect = NETWORK_OK;
			}
			FD_CLR(sockfd, &infd);
		}
		else
		{
			if ( FD_ISSET(sockfd, &outfd) )
			{
//				CCLOG("socket ready for send");
				resSelect = NETWORK_OK;
			}
			FD_CLR(sockfd, &outfd);
		}
	}
	return resSelect;
}

bool SFSocketCommService::sendData( const char* pDataBuffer, const unsigned int& nDataSize )
{
	uint16  len = *(( uint16*)pDataBuffer);
	len = HOST2NET_16(len);
	*( ( uint16*)pDataBuffer ) = len;

	size_t size = 0;
	CURLcode res = curl_easy_send(curl_, pDataBuffer, nDataSize, &size);

	if (res != CURLE_OK || size != nDataSize)
	{
		return false;
	}
	else
	{
		return true;
	}
}
}





