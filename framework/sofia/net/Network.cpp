#include "stream/iStream.h"
#include "utils/SFExecutionThreadService.h"
#include "SFSocketCommService.h"
#include "sofia/utils/StateBlock.h"
#include "net/Network.h"
#include "stream/MemoryStream.h"
#include "stream/BinaryReaderNet.h"
#include "stream/BinaryWriterNet.h"

namespace cocos2d {

	const char* Network::ConnectEvent = "NetConnectEvent";
	const char* Network::CloseEvent = "NetCloseEvent";
	const char* Network::RecvEvent = "NetRecvEvent";

	Network::Network()
	{
		this->m_handler = 0;
		this->m_pack_memory = 0;
		this->m_pack_wirter = 0;
		this->m_encryptSeed = 25;
		this->m_decryptSeed = 25;

	}

	Network::~Network()
	{
		if (this->m_handler)
		{
			m_handler->shutDown();
			delete m_handler;
			this->m_handler = 0;
		}
		if (this->m_pack_wirter)
		{
			delete this->m_pack_wirter;
			this->m_pack_wirter = 0;
		}
		if (this->m_pack_memory)
		{
			delete this->m_pack_memory;
			this->m_pack_memory = 0;
		}
	}

	bool Network::Connect(const char* server, unsigned short port,int nHandler)
	{
		if (this->m_handler == 0)
		{
			this->m_handler = SFSocketCommService::socketCommServiceWithListener(0);
			this->m_handler->startUp();
		}
		this->m_handler->setLuaHandler(nHandler);
		this->m_handler->connect(server, port);

		return true;
	}

	bool Network::Disconnect()
	{
		if (this->m_handler)
			this->m_handler->disconnect();

		return true;
	}

	bool Network::IsConnect()
	{
		if (this->m_handler)
		{
			return this->m_handler->isConnected();
		}
		return false;
	}

	iBinaryWriter* Network::BeginPack()
	{
		if (this->m_pack_memory == 0)
		{
			this->m_pack_memory = new MemoryStream();
			this->m_pack_memory->SetAccessMode(cocos2d::iStream::ReadWriteAccess);
			this->m_pack_wirter = new BinaryWriterNet();
			this->m_pack_wirter->SetStream(this->m_pack_memory, false);
		}
		if (this->m_pack_memory->IsOpen() == false)
		{
			this->m_pack_memory->Open();
		}
		this->m_pack_memory->Seek(0, cocos2d::iStream::Begin);
		this->m_pack_wirter->Open();
		return this->m_pack_wirter;
	}

	bool Network::EndPack()
	{
		//Performance_M_C("Network::EndPack");
		//static unsigned char net_temp[0x10000];

		if (this->m_handler == 0 || this->m_handler->isConnected() == false)
		{
			if (this->m_pack_wirter)
			{
				this->m_pack_wirter->Close();
			}
			return false;
		}

		unsigned int len = this->m_pack_memory->GetPosition();
		unsigned char* buf = (unsigned char*)this->m_pack_memory->GetRawPointer();
		{
			StateBlock* nb = StateBlock::GetFreeBlock(len + 3);
			unsigned short size = len + 1;//服务器只算数据包大小
			*(unsigned short*)nb->GetWtPtr() = size;
			nb->PushWtPtr(sizeof(unsigned short));
			*(char*)nb->GetWtPtr() = (char)0;
			nb->PushWtPtr(sizeof(char));
			::memcpy(nb->GetWtPtr(), buf, len);
			nb->PushWtPtr(len);
			this->m_pack_wirter->Close();
			this->m_handler->addTcpActionRequest(nb);
		}

		return true;
	}

	bool Network::SendString1024(const char* txt)
	{
		if (this->m_pack_memory == 0)
		{
			this->m_pack_memory = new MemoryStream();
			this->m_pack_memory->SetAccessMode(iStream::ReadWriteAccess);
			this->m_pack_wirter = new BinaryWriter();
			this->m_pack_wirter->SetStream(this->m_pack_memory, false);
		}
		if (this->m_pack_memory->IsOpen() == false)
		{
			this->m_pack_memory->Open();
		}
		this->m_pack_memory->Seek(0, iStream::Begin);
		this->m_pack_wirter->Open();
		
		this->m_pack_wirter->WriteString(txt);

		unsigned int len = this->m_pack_memory->GetSize();
		unsigned char* buf = (unsigned char*)this->m_pack_memory->GetRawPointer();
		unsigned short* codeBuf = (unsigned short*)this->m_pack_memory->GetRawPointer();
		unsigned short code = *codeBuf;
		{
			StateBlock* nb = StateBlock::GetFreeBlock(len);
			unsigned short size = len;
			::memcpy(nb->GetWtPtr(), buf, len);
			nb->PushWtPtr(len);
			this->m_pack_wirter->Close();
			this->m_handler->addTcpActionRequest(nb);
		}

		return true;
	}

	bool Network::Tick()
	{
		if (this->m_handler == 0)
		{
			return false;
		}
		std::queue<StateBlock*> recvActionRequestQueue_;
		this->m_handler->getRecvPack(recvActionRequestQueue_);
		bool gotmsg = false;
		while (recvActionRequestQueue_.empty() == false)
		{
			StateBlock* nb = recvActionRequestQueue_.front();
			recvActionRequestQueue_.pop();
			if (nb == 0)
			{
				continue;
			}

			int s = nb->GetState();
			switch(s)
			{
			case SFSocketCommService::CONNECT_ETABLISHING:
				{
					NetConnectEvent e;
					e.code = nb->GetErrorCode();
					e.net = this;
					this->FireEvent(Network::ConnectEvent, e);
				}break;
			case SFSocketCommService::CONNECT_CLOSING:
				{
					NetCloseEvent e;
					e.code = nb->GetErrorCode();
					e.net = this;
					this->FireEvent(Network::CloseEvent, e);
				}break;
			case SFSocketCommService::NORMAL:
				{
					this->FireNetMsg(nb->GetRdPtr(), nb->GetDataSize());
				}break;
			}

			gotmsg = true;
			nb->Release();

		}

		return gotmsg;
	}

	void Network::FireNetMsg(char* buf, unsigned int len)
	{
		if (len > 65536)//error > 64K
		{
			return;
		}
		unsigned short* usBuf = (unsigned short*) buf;		
		unsigned short code = *usBuf;

		{
			MemoryStream ms;
			ms.SetAccessMode(iStream::ReadWriteAccess);
			ms.Open();
			ms.Write(buf, len);
			ms.Seek(0, iStream::Begin);
			BinaryReaderNet br;
			br.SetStream(&ms, false);
			br.Open();
			NetRecvEvent e;
			e.net = this;
			e.msgLen = len;
			e.reader = &br;
			this->FireEvent(Network::RecvEvent, e);
		}

	}
}