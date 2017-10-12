// @brief: data deflate
// @author: typ77
// @data: [9/5/2013 typ77]

//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 

#ifndef _SF_SAPPairManager_h__
#define _SF_SAPPairManager_h__

//#include "ccTypes.h"
#include "sapBitset.h"

#include <map>


#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */
	struct Pair
	{
		unsigned short id0;
		unsigned short id1;
		const void*	object0;
		const void*	object1;
		//#ifdef PAIR_USER_DATA
		void*		userData;
		//#endif

		unsigned char flagRemoved:1;
		unsigned char flagInArray:1;
		unsigned char flagNew:1;
		unsigned char lastCreate:1;
		unsigned char flagReserved:4;

		const void*	GetObject0() const	{ return object0;}
		const void*	GetObject1() const	{ return object1;}
		bool		IsInArray()	 const	{ return flagInArray;}
		bool		IsRemoved()	 const	{ return flagRemoved;}
		bool		IsNew()		 const	{ return flagNew;}
	private:
		void		SetInArray()				{ flagInArray = 1;}
		void		SetRemoved()				{ flagRemoved = 1;}
		void		SetNew()					{ flagNew = 1;}
		void		ClearInArray()				{ flagInArray = 0;	}
		void		ClearRemoved()				{ flagRemoved = 0;	}
		void		ClearNew()					{ flagNew = 0;	}
		friend class ArraySAP;
	};
#pragma pack(pop)

	typedef std::vector<Pair*> PairList;

	class PairManager
	{
	public:
		PairManager(unsigned int capacity = 1024);
		~PairManager();

		Pair*	AddPair(unsigned short id0, unsigned short id1, const void* object0, const void* object1);
		bool	RemovePair	(unsigned short id0, unsigned short id1);
		bool	RemovePair(unsigned int keyVal);
		Pair*	FindPair(unsigned short id0, unsigned short id1);
		Pair*	FindPair(unsigned int keyVal);

		inline unsigned int GetPairKey(Pair* pPair)
		{
			return GetKey(pPair->id0, pPair->id1);
		}
			
		bool RemovePairs(const Bitset& dbRemoveObjects);

		PairList& FindAssociatePairs(const Bitset& dbRemoveObjects);

		size_t GetPairsSize() const {return mPairHashMap.size();}
	private: 
		void AjustRightPairsOrder(unsigned short& id0, unsigned short& id1, const void*& object0,const void*& object1) const;
		void AjustRightPairsOrder(unsigned short& id0, unsigned short& id1) const;
		unsigned int GetKey(unsigned short id0,unsigned short id1) const;
	private:
		typedef std::map<unsigned int,Pair*> PairHashMap;
		PairHashMap mPairHashMap;
	};

#endif // DreamSAPPairManager_h__