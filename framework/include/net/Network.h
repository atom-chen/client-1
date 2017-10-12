#ifndef _CORE_NETWORK_H_
#define _CORE_NETWORK_H_
#include "eventset/EventSet.h"
#include "eventset/EventArgs.h"

namespace cocos2d {
class SFSocketCommService;

	class MemoryStream;
	class BinaryWriter;
	class StateBlock;
	class Network;
	class iBinaryReader;
	class iBinaryWriter;


	class NetConnectEvent : public EventArgs
	{
	public:
		NetConnectEvent() {}
		~NetConnectEvent() {}
		bool IsOk() const { return (this->code == 0);}
		const char* GetErrorString() const { return "";}

	public:
		Network* net;
		unsigned int code;
	};

	class NetCloseEvent : public EventArgs
	{
	public:
		NetCloseEvent() {}
		~NetCloseEvent() {}

		Network* net;
		unsigned int code;
	};

	class NetRecvEvent : public EventArgs
	{
	public:
		NetRecvEvent() {}
		~NetRecvEvent() {}

		Network* net;
		iBinaryReader* reader;
		unsigned int msgLen;
	};

	class Network : public EventSet
	{
	public:
		static const char* ConnectEvent;
		static const char* CloseEvent;
		static const char* RecvEvent;

		Network();
		virtual ~Network();
	
	public:
		virtual bool Connect(const char* server, unsigned short port,int nHandler);
		virtual bool Disconnect();
		virtual bool IsConnect();
		virtual iBinaryWriter* BeginPack(); 
		virtual bool EndPack();
		virtual bool SendString1024(const char* txt);
		bool Tick();
		
	private:
		void FireNetMsg(char* buf, unsigned int len);
	private:
		BinaryWriter* m_pack_wirter;
		MemoryStream* m_pack_memory;
		SFSocketCommService* m_handler;
		int m_encryptSeed;
		int m_decryptSeed;
	};

}

#endif
