#include "cocos2d.h"
//#include "EngineMacros.h"
#include "net/Network.h"
#include "net/NetSystem.h"
#include <algorithm>
#include "sofia/utils/StateBlock.h"

namespace cocos2d {

	NetSystem::NetSystem()
	{

	}

	NetSystem::~NetSystem()
	{
		while(!this->m_add_list.empty())
		{
			Network* work = this->m_add_list.back();
			delete work;
			 this->m_add_list.pop_back();
		}

		while(!this->m_remove_list.empty())
		{
			Network* work = this->m_remove_list.back();
			delete work;
			this->m_remove_list.pop_back();
		}

		while(!this->m_network_list.empty())
		{
			Network* work = this->m_network_list.back();
			delete work;
			this->m_network_list.pop_back();
		}
		
		Close();
	}

	Network* NetSystem::CreateNetwork()
	{
		Network* net = new Network();
		//this->m_network_list.push_back(net);
		this->m_add_list.push_back(net);
		return net;
	}

	void NetSystem::RemoveNetwork(Network* net)
	{
		if(net == NULL) return;
		NetworkListType::iterator itr = std::find(this->m_network_list.begin(), this->m_network_list.end(), net);
		if (itr != this->m_network_list.end())
		{
			this->m_network_list.erase(itr);
		}
		itr = std::find(this->m_add_list.begin(), this->m_add_list.end(), net);
		if (itr != this->m_add_list.end())
		{
			this->m_add_list.erase(itr);
		}
		this->m_remove_list.push_back((Network*)net);
		//delete net;
	}

	bool NetSystem::Tick()
	{
		if (this->m_add_list.empty() == false)
		{
			for (NetworkListType::iterator itr = this->m_add_list.begin(); itr != this->m_add_list.end(); ++itr)
			{
				Network* net = *itr;
				this->m_network_list.push_back(net);
			}
			this->m_add_list.clear();
		}
		for (NetworkListType::iterator itr = this->m_network_list.begin(); itr != this->m_network_list.end(); ++itr)
		{
			Network* net = *itr;
			net->Tick();
		}
		for (NetworkListType::iterator itr = this->m_remove_list.begin(); itr != this->m_remove_list.end(); ++itr)
		{
			Network* net = *itr;
			delete net;
		}
		this->m_remove_list.clear();
		return true;
	}

	bool NetSystem::Run()
	{
		StateBlockManager::Init();
		//return sq::NetReactor::Instance().Run();
		return true;
	}

	bool NetSystem::Close()
	{
		StateBlockManager::End();
		//sq::NetReactor::Instance().Close();
		return true;
	}

	const char* NetSystem::GetAddressByName(const char* url)
	{
		return "";
	}

}

