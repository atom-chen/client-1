// @brief: data deflate
// @author: typ77
// @data: [9/5/2013 typ77]

//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 

#ifndef _SF_Bitset_h__
#define _SF_Bitset_h__
#include "sofia/SofiaMacro.h"
#include "ccTypes.h"
#include <vector>

	class Bitset
	{
	public:
		Bitset(size_t totalSize = 1024);
		~Bitset();
	
		bool Test(size_t index) const;
		
		void Reset();
		
		void Reserve(size_t capacity);
		
		void Set(size_t index, bool bSet = true);

		size_t GetSlotsNum() const { return m_totalSize;}
		size_t GetDataLen() const;
		const unsigned char* GetDataPtr() const;

		void Inverse();

		void SetFrom(size_t start_index, size_t count, bool bSet = true);

		bool FindMultiZero(size_t expect_num, size_t& out_start_index) const;
	private:
		void CalcIndexSavePosAndOffset(size_t index, size_t& outSavePos, size_t& outOffset) const;
	protected:
		std::vector<unsigned int> m_dataContainer;
		size_t m_totalSize;

	};


#endif // DreamBitset_h__
