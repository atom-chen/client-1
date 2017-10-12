#include "map/sap/SAPPairManager.h"


	PairManager::PairManager(unsigned int capacity)
	{

	}

	PairManager::~PairManager()
	{
		for (PairHashMap::iterator iPair = mPairHashMap.begin(); iPair != mPairHashMap.end();iPair++)
		{
			if (iPair->second != 0)
			{
				delete iPair->second;
				iPair->second = NULL;
			}
		}

		mPairHashMap.clear();
	}

	Pair* PairManager::AddPair( unsigned short id0, unsigned short id1, const void* object0, const void* object1 )
	{
		AjustRightPairsOrder(id0,id1,object0,object1);
		unsigned int tmpKey = GetKey(id0,id1);
		Pair* pPair = FindPair(id0,id1);
		if(pPair)
		{
			return pPair;
		}
			
		pPair = new Pair();
		pPair->id0 = id0;
		pPair->id1 = id1;
		pPair->object0 = object0;
		pPair->object1 = object1;
		pPair->lastCreate = 1;
		mPairHashMap.insert(std::make_pair(tmpKey,pPair));
			
		return pPair;
	}

	bool PairManager::RemovePair( unsigned short id0, unsigned short id1 )
	{
		AjustRightPairsOrder(id0,id1);
		unsigned int tmpKey = GetKey(id0,id1);

		return RemovePair(tmpKey);
	}

	bool PairManager::RemovePair( unsigned int keyVal )
	{
		PairHashMap::iterator iPair = mPairHashMap.find(keyVal);
		if(iPair != mPairHashMap.end())
		{
			delete iPair->second;
			iPair->second = NULL;
			mPairHashMap.erase(iPair);			
			return true;
		}
		else
		{
			return false;
		}
	}

	Pair* PairManager::FindPair( unsigned short id0, unsigned short id1 )
	{
		AjustRightPairsOrder(id0,id1);
		unsigned int tmpVal = GetKey(id0,id1);

		return FindPair(tmpVal);
	}

	Pair* PairManager::FindPair( unsigned int keyVal )
	{
		PairHashMap::iterator iPair = mPairHashMap.find(keyVal);
		if(iPair!=mPairHashMap.end())
		{
			return iPair->second;
		}
		else
		{
			return NULL;
		}
	}

	void PairManager::AjustRightPairsOrder( unsigned short& id0, unsigned short& id1, const void*& object0,const void*& object1 ) const
	{
		if(id0>id1)
		{
			std::swap(id0,id1);
			std::swap(object0,object1);
		}
	}

	void PairManager::AjustRightPairsOrder( unsigned short& id0, unsigned short& id1 ) const
	{
		if(id0>id1)
		{
			std::swap(id0,id1);
		}
	}

	unsigned int PairManager::GetKey( unsigned short id0,unsigned short id1 ) const
	{
		unsigned int tmpVal = id0;
		tmpVal = (tmpVal<<16)|id1;
		return tmpVal;
	}

	bool PairManager::RemovePairs( const Bitset& dbRemoveObjects )
	{
		for (PairHashMap::iterator iPair = mPairHashMap.begin(); iPair != mPairHashMap.end();)
		{
			Pair* pPair = iPair->second;
			if(dbRemoveObjects.Test(pPair->id0) || dbRemoveObjects.Test(pPair->id1))
			{
				mPairHashMap.erase(iPair++);
			}
			else
			{
				iPair++;
			}
		}
		return true;
	}

	PairList& PairManager::FindAssociatePairs( const Bitset& db_test_object )
	{
		static PairList pairList;
		pairList.clear();
		for (PairHashMap::iterator iPair = mPairHashMap.begin(); iPair != mPairHashMap.end();iPair++)
		{
			Pair* pPair = iPair->second;
			if(db_test_object.Test(pPair->id0) || db_test_object.Test(pPair->id1))
			{
				pairList.push_back(pPair);
			}
		}
		return pairList;
	}

