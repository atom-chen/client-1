#include "cocos2d.h"
#include "EngineMacros.h"

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <stdlib.h>
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <malloc/malloc.h>
#else
#include <malloc.h>
#endif
#include <memory.h>
#include "StateBlock.h"
//#include "base/utils/SFThread.h"
#include "utils/SFThread.h"
namespace cocos2d { 

	StateBlockManager* StateBlockManager::instance = 0;
	//__ImplementClass(sq::StateBlock, 'SNBK', Core::RefCounted);

	StateBlock::StateBlock()
		: m_buffer(0), m_size(0), m_rdPtr(0), m_wtPtr(0), m_needCollect(true)
	{
	}

	void StateBlock::Init(size_t size)
	{
		m_needCollect = true;
		m_size = size;
		this->Alloc(size);
	}

	void StateBlock::ZeroBuf()
	{
		if (this->m_buffer && this->m_size != 0)
		{
			::memset(this->m_buffer, 0, this->m_size);
		}
	}

	void StateBlock::InitEx(char* buf, size_t size, bool owned)
	{
		m_needCollect = true;
		m_size = size;
		if (owned)
		{
			m_buffer = buf;
			m_rdPtr = m_buffer;
			m_wtPtr = m_buffer + size;
		}
		else
		{
			this->Alloc(size);
			memcpy(this->m_buffer, buf, size);
			this->m_wtPtr += size;
		}
	}

	StateBlock::~StateBlock()
	{
		if (this->m_buffer != 0 && m_needCollect)
		{
			//::free(this->m_buffer);
			CC_SAFE_FREE(this->m_buffer);
			this->m_buffer = 0;
		}
	}

	StateBlock* StateBlock::GetFreeBlock(size_t size)
	{
		return StateBlockManager::instance->GetFreeBlock(size);
	}

	StateBlock* StateBlock::GetBlock(char* buf, size_t size, bool owned)
	{
		return StateBlockManager::instance->GetBlock(buf, size, owned);
	}

	void StateBlock::Release()
	{
		StateBlockManager::instance->ReleaseBlock(this);
	}

	bool StateBlock::Alloc(size_t size)
	{
		this->m_buffer = reinterpret_cast<char*>(malloc(size));//, "StateBlock"));//reinterpret_cast<char*>(::malloc(size));
		this->m_rdPtr = this->m_wtPtr = this->m_buffer;
		return this->m_buffer != 0;
	}

	bool StateBlock::Realloc(size_t size)
	{
		this->m_buffer = reinterpret_cast<char*>(realloc(this->m_buffer, size));//, "StateBlock"));//::realloc(this->m_buffer, size));
		this->m_rdPtr = this->m_wtPtr = this->m_buffer;
		return this->m_buffer != 0;
	}

	StateBlock* StateBlock::Duplicate()
	{
		StateBlock* nb = new StateBlock();
		nb->Init(this->m_size);
		::memcpy(nb->m_buffer, this->m_buffer, this->m_size);
		return nb;
	}

	const size_t StateBlockManager::m_blockGroupsLimit[] =
	{
		512,
		8 * 1024,
		16 * 1024,
		32 * 1024,
		64 * 1024
	};

	StateBlockManager::StateBlockManager()
	{
		this->m_mutex = new SFSemaphoreLock();
	}

	StateBlockManager::~StateBlockManager()
	{
		{
			SFSemaphoreLockGuard t(*this->m_mutex);
			for (int i = 0; i < NumOfBlockGroups; ++i)
			{
				for (std::vector<StateBlock*>::iterator itr = this->m_blockGroups[i].begin(); itr != this->m_blockGroups[i].end(); ++itr)
				{
					delete (*itr);
				}
			}
		}
		delete this->m_mutex;
	}

	void StateBlockManager::Init()
	{
		StateBlockManager::instance = new StateBlockManager();
	}

	void StateBlockManager::End()
	{
		delete (StateBlockManager::instance);
		StateBlockManager::instance = 0;
	}

	StateBlock* StateBlockManager::GetFreeBlock(size_t size)
	{
		if (size == 0)
		{
			size = 1;
		}

		SFSemaphoreLockGuard t(*this->m_mutex);

		int i = 0;
		for ( ; i < NumOfBlockGroups; ++i)
		{
			if (size < m_blockGroupsLimit[i])
			{
				break;
			}
		}

		if (i == NumOfBlockGroups)
		{
			StateBlock* b = new StateBlock();
			b->Init(size);
			b->ZeroBuf();
			return b;
		}

		if (this->m_blockGroups[i].empty())
		{
			StateBlock* b = new StateBlock();
			b->Init(this->m_blockGroupsLimit[i]);
			b->ZeroBuf();
			return b;
		}

		StateBlock* block = this->m_blockGroups[i].back();
		block->m_rdPtr = block->m_wtPtr = block->m_buffer;
		block->ZeroBuf();
		this->m_blockGroups[i].pop_back();
		return block;
	}

	StateBlock* StateBlockManager::GetBlock(char* buf, size_t size, bool owned)
	{
		if (size == 0)
		{
			return 0;
		}
		StateBlock* b = new StateBlock();
		b->InitEx(buf, size, owned);
		return b;
	}

	void StateBlockManager::ReleaseBlock(StateBlock* block)
	{
		if (block == 0 || block->m_size == 0)
		{
			return;
		}

		SFSemaphoreLockGuard t(*this->m_mutex);
		if (block->m_needCollect)
		{
			for (int i = 0; i < NumOfBlockGroups; ++i)
			{
				if (block->m_size == m_blockGroupsLimit[i])
				{
					block->m_rdPtr = block->m_wtPtr = block->m_buffer;
					block->m_state = 0;
					block->m_errorCode = 0;
					//block->m_handler = 0;
					this->m_blockGroups[i].push_back(block);
					return;
				}
			}		
		}
		delete block;
	}
	}
