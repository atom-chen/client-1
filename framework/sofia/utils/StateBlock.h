#ifndef _SQ_NET_BLOCK_H_
#define _SQ_NET_BLOCK_H_
#include "cocos2d.h"
//#include "EngineMacros.h"
#include <vector>
//#define _USE_MUTEX_
namespace cocos2d {
class SFSemaphoreLock;


	class StateBlock;

	class StateBlockManager
	{
	public:
		StateBlockManager();
		~StateBlockManager();

		StateBlock* GetFreeBlock(size_t size);
		StateBlock* GetBlock(char* buf, size_t size, bool owned);
		void ReleaseBlock(StateBlock* block);
		static void Init();
		static void End();
	private:
		enum
		{
			NumOfBlockGroups	=	5
		};
		std::vector<StateBlock*> m_blockGroups[NumOfBlockGroups];

		SFSemaphoreLock* m_mutex;
		static const size_t m_blockGroupsLimit[NumOfBlockGroups];
		static StateBlockManager* instance;
		friend class StateBlock;
	};

	class StateBlock
	{
	public:
		static StateBlock* GetFreeBlock(size_t size);
		static StateBlock* GetBlock(char* buf, size_t size, bool owned);
		void ZeroBuf();
		void Init(size_t size);
		void InitEx(char* buf, size_t size, bool owned);

		bool Alloc(size_t size);
		bool Realloc(size_t size);
		void Release();

		char* GetRdPtr() const { return this->m_rdPtr; }
		void PushRdPtr(size_t bytes) { this->m_rdPtr += bytes; }
		void ResetRdPtr() { this->m_rdPtr = this->m_buffer; }

		char* GetWtPtr() const { return this->m_wtPtr; }
		void PushWtPtr(size_t bytes) { this->m_wtPtr += bytes; }
		void ResetWtPtr() { this->m_wtPtr = this->m_buffer; }

		int GetErrorCode() const { return this->m_errorCode; }
		void SetErrorCode(int ec) { this->m_errorCode = ec; }

		size_t GetSize() const { return this->m_size; }
		size_t GetDataSize() const { return this->m_wtPtr - this->m_rdPtr; }


		StateBlock* Duplicate();

		int GetState() const { return this->m_state; }
		void SetState(int state) { this->m_state = state; }

	private:
		friend class StateBlockManager;
		StateBlock();
		~StateBlock();
		char* m_buffer;
		size_t m_size;

		char* m_rdPtr;
		char* m_wtPtr;

		int m_state;
		int m_errorCode;

		bool m_needCollect;


		StateBlock(const StateBlock&) {}
		StateBlock& operator = (const StateBlock&) { return *this; }


	};

}
#endif