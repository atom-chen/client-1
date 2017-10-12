#include "map/sap/SAPBitset.h"
#include <string.h>


	Bitset::Bitset( size_t totalSize )
	{
		size_t tmpNums = totalSize / 32;
		if(totalSize % 32)
		{
			tmpNums++;
		}
		if(tmpNums<=0)
		{
			tmpNums=1;
		}
		m_dataContainer.resize(tmpNums,0);
		m_totalSize = totalSize;
	}

	Bitset::~Bitset()
	{

	}

	bool Bitset::Test( size_t index ) const
	{
		if(index < m_totalSize)
		{
			size_t savePos = 0 , offset = 0;
			CalcIndexSavePosAndOffset(index, savePos, offset);
			if((m_dataContainer[savePos] >> offset) & 0x1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}

	void Bitset::Reset()
	{
		memset(&m_dataContainer[0],0,4*m_dataContainer.size());
	}

	void Bitset::Reserve( size_t capacity )
	{
		size_t tmpNums = capacity / 32;
		if(capacity % 32)
		{
			tmpNums++;
		}
		if(tmpNums<=0)
		{
			tmpNums=1;
		}
		m_dataContainer.resize(tmpNums,0);
		m_totalSize = capacity;
	}

	void Bitset::Set( size_t index, bool bSet )
	{
		if(index < m_totalSize)
		{
			size_t savePos = 0 , offset = 0;
			CalcIndexSavePosAndOffset(index, savePos, offset);
			if(bSet)
			{
				m_dataContainer[savePos] |= (0x1U<<offset);
			}
			else
			{
				m_dataContainer[savePos] &= ~(0x1U<<offset);
			}
		}
	}

	void Bitset::SetFrom( size_t start_index, size_t count, bool bSet /*= true*/ )
	{
		size_t end_index = start_index + count;
		end_index = std::min<size_t>(end_index, m_totalSize);
		for (size_t i = start_index; i < end_index; ++i)
		{
			size_t save_pos = 0 , offset = 0;
			CalcIndexSavePosAndOffset(i, save_pos, offset);
			if(bSet)
			{
				m_dataContainer[save_pos] |= (0x1U<<offset);
			}
			else
			{
				m_dataContainer[save_pos] &= ~(0x1U<<offset);
			}
		}
	}

	size_t Bitset::GetDataLen() const
	{
		return m_dataContainer.size();
	}

	const unsigned char* Bitset::GetDataPtr() const
	{
		return (const unsigned char*)(&m_dataContainer[0]);
	}

	void Bitset::Inverse()
	{
		for (size_t i=0;i<m_dataContainer.size();i++)
		{
			m_dataContainer[i] = ~m_dataContainer[i];
		}
	}

	void Bitset::CalcIndexSavePosAndOffset( size_t index, size_t& outSavePos, size_t& outOffset ) const
	{
		outOffset = index % 32;
		outSavePos = index / 32;
	}

	bool Bitset::FindMultiZero( size_t expect_num, size_t& out_start_index ) const
	{
		for (size_t i = 0; i < m_totalSize; )
		{
			if(Test(i))
			{
				++i;
			}
			else
			{
				if(i + expect_num <= m_totalSize)
				{
					bool is_find = true;
					for (size_t j = i+1; j < i + expect_num; ++j)
					{
						if(Test(j))
						{
							is_find = false;
							i = j + 1;
							break;
						}
					}
					if(is_find)
					{
						out_start_index = i;
						return true;
					}
				}
				else
				{
					return false;
				}
			}
		}
		return false;
	}
