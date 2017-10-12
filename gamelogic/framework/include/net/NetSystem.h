#ifndef _GAMEENGINE_NET_SYSTEM_H_
#define _GAMEENGINE_NET_SYSTEM_H_
//#include "core/net/INetSystem.h"

#include <vector>

namespace cocos2d {
	class Network;

	class NetSystem /*: public itf::iNetSystem*/
	{
	public:
		NetSystem();
		virtual ~NetSystem();

	public:
		//static NetSystem* instance;
		virtual Network* CreateNetwork();
		virtual void RemoveNetwork(Network* net);
		virtual bool Tick();
		virtual bool Run();
		virtual bool Close();

		virtual const char* GetAddressByName(const char* url);						//获得输入url的ip地址
	private:
		typedef std::vector<Network*> NetworkListType;
		NetworkListType m_network_list;
		NetworkListType m_add_list;
		NetworkListType m_remove_list;
	};

}

#endif
