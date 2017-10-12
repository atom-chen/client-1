#include "map/sap/SAP.h"

////#include "Math/DreamMathHelper.h"

////#include "boost/dynamic_bitset.hpp"

#include <algorithm>

////#include "Math/DreamMath.h"

	ArraySAP::ArraySAP()
		:mCreatesDbFlags(65536)
		, m_pCommonListner(0)
	{
	}

	ArraySAP::~ArraySAP()
	{
	}


	unsigned int ArraySAP::AddObject(void* object, const kmAABB& box, unsigned short groupFlag, unsigned short collisionFlag)
	{
		SAPBox* Box = RequestNewBox();
		// Initialize box
		Box->mObject	= object;
		Box->mCollisionFlag = collisionFlag;
		Box->mGroupFlag = groupFlag;

		CreateData CD;
		CD.mHandle = Box->mBoxIndex;
		CD.mBox = box;

		mCreatesDbFlags.Set(CD.mHandle);
		mCreateDataMap.insert(std::make_pair(CD.mHandle,CD));

		return Box->mBoxIndex;
	}

	bool ArraySAP::RemoveObject(unsigned int handle)
	{
		if(mCreatesDbFlags.Test(handle))
		{
			mCreateDataMap.erase(handle);
			mCreatesDbFlags.Set(handle, false);
			FreeBox(&mBoxList[handle]);
		}
		else
		{
			mRemoveList.push_back(handle);
		}
		return true;
	}

	bool ArraySAP::UpdateObject(unsigned int handle, const kmAABB& box_)
	{
		if(mCreatesDbFlags.Test(handle))
		{
			CreateDataMap::iterator iCreate = mCreateDataMap.find(handle);
			CreateData& tmpCreateData = iCreate->second;
			tmpCreateData.mBox = box_;
			return true;
		}
		else
		{
			SAPBox* Object = &mBoxList[handle];
			const void* UserObject = Object->mObject;

			kmAABB tmpBox = box_;
			if(fabs(tmpBox.max.x - tmpBox.min.x) <= 1e-6f)
			{
				tmpBox.max.x = tmpBox.min.x + 0.001f;
			}

			if(fabs(tmpBox.max.y - tmpBox.min.y) <= 1e-6f)
			{
				tmpBox.max.y = tmpBox.min.y + 0.001f;
			}

			if(fabs(tmpBox.max.z - tmpBox.min.z) <= 1e-6f)
			{
				tmpBox.max.z = tmpBox.min.z + 0.001f;
			}

			InnerAABB box;
#ifdef USE_INTEGERS
			box.mMinX = EncodeFloat(tmpBox.min.x);
			box.mMinY = EncodeFloat(tmpBox.min.y);
			box.mMinZ = EncodeFloat(tmpBox.min.z);
			box.mMaxX = EncodeFloat(tmpBox.max.x);
			box.mMaxY = EncodeFloat(tmpBox.max.y);
			box.mMaxZ = EncodeFloat(tmpBox.max.z);
#else
			box.mMinX = tmpBox.min.x;
			box.mMinY = tmpBox.min.y;
			box.mMinZ = tmpBox.min.z;
			box.mMaxX = tmpBox.max.x;
			box.mMaxY = tmpBox.max.y;
			box.mMaxZ = tmpBox.max.z;
#endif

			for(unsigned int Axis=0;Axis<3;Axis++)
			{
				//Update min
				ChangeEndPointValue(*Object,box,Axis,false,box.GetMin(Axis));

				//Update max
				ChangeEndPointValue(*Object,box,Axis,true,box.GetMax(Axis));
			}
			return true;
		}

			
	}

		
	void ArraySAP::BoxPruningBetweenTwoSet( const BPMinPosInfoList& boxCircleSet, const BPMinPosInfoList& boxBeenDetectSet )
	{
		for (size_t i=0,j=0; i< boxCircleSet.size(); i++)
		{
			for (;j< boxBeenDetectSet.size();j++)
			{
				if(boxBeenDetectSet[j].minPos >= boxCircleSet[i].minPos)
				{
					size_t boxIndex0 = boxCircleSet[i].boxIndex;
					ValType maxPosVal = GetBoxEndPointValue(mBoxList[boxIndex0],0,true);
					for (size_t k=j;k<boxBeenDetectSet.size();k++)
					{
						if(boxBeenDetectSet[k].minPos <= maxPosVal)
						{
							size_t boxIndex1 = boxBeenDetectSet[k].boxIndex;

							SAPBox& box0 = mBoxList[boxIndex0];
							SAPBox& box1 = mBoxList[boxIndex1];
							if(box0.CanCollideWith(box1))
							{
								if(box0.mBoxIndex!=box1.mBoxIndex)
								{
									if(Intersect(box0,box1,1) 
										&& Intersect(mBoxList[boxIndex0],mBoxList[boxIndex1],2))
									{
										AddPair(box0.mObject, box1.mObject,box0.mBoxIndex,box1.mBoxIndex);
									}
								}
							}
						}
						else
						{
							break;
						}
					}
					break;
				}
			}
		}
	}

	void ArraySAP::BoxPruningForBatchCreate(CreateDataMap& batchDataMap)
	{
		BPMinPosInfoList newBoxPosInfoList(batchDataMap.size());
		BPMinPosInfoList oldBoxPosInfoList(mBoxList.size()-mFreeBoxIdList.size()-batchDataMap.size());

		size_t newBoxCount = 0, oldBoxCount = 0;
		//now only test for X axis for simple
			
		const SAPEndPoint* pEndPoint = &mEndPointArrays[0][0];
		////Prefetch(pEndPoint);
		for(size_t i=0;i<mEndPointArrays[0].size();i++)
		{
			if(!pEndPoint->flagMax)
			{
				//new box
				if(mCreatesDbFlags.Test(pEndPoint->ownerIndex))
				{
					BPMinPosInfo& minPosInfo = newBoxPosInfoList[newBoxCount++];
					minPosInfo.boxIndex = pEndPoint->ownerIndex;
					minPosInfo.minPos = pEndPoint->mValue;
				}
				else	//old box
				{
					BPMinPosInfo& minPosInfo = oldBoxPosInfoList[oldBoxCount++];
					minPosInfo.boxIndex = pEndPoint->ownerIndex;
					minPosInfo.minPos = pEndPoint->mValue;
				}
			}
			pEndPoint++;
		}

		//Test intersect between new boxs
		BoxPruningBetweenTwoSet(newBoxPosInfoList,newBoxPosInfoList);

		if(!oldBoxPosInfoList.empty())
		{
			//Test intersect between old boxs and new boxs(two pass? why two pass)
			//pass one
			BoxPruningBetweenTwoSet(newBoxPosInfoList,oldBoxPosInfoList);

			//pass two
			BoxPruningBetweenTwoSet(oldBoxPosInfoList,newBoxPosInfoList);

			//ToDo:Is there need to keep a temp data notify already handled boxes?
		}
			

	}
		
	void ArraySAP::BatchCreate()
	{
		if(mCreateDataMap.empty())
		{
			return;
		}

		unsigned int NbBatched = mCreateDataMap.size();
		////const CreateData* Batched = (const CreateData*)(&mCreateDataList[0]);

		//put the endpoing to right pos in the end point map
		for(unsigned int Axis=0;Axis<3;Axis++)
		{
			SAPEndPointArray tmpArray(NbBatched*2);
			int tmpCount =0;
			for (CreateDataMap::iterator iCreate =mCreateDataMap.begin();iCreate!=mCreateDataMap.end();iCreate++)
			{
				CreateData& tmpCreateData = iCreate->second;
				unsigned int BoxIndex = tmpCreateData.mHandle;

				kmScalar* min_ptr = &(tmpCreateData.mBox.min.x);
				kmScalar* max_ptr = &(tmpCreateData.mBox.max.x);

				float MinValue = min_ptr[Axis];
				float MaxValue = max_ptr[Axis];

				if(fabs(MaxValue - MinValue) <= 1e-6f)
				{
					MaxValue = MinValue + 0.001f;		//to keep min always smaller than max value
				}

				SAPEndPoint& minPoint = tmpArray[tmpCount*2];
				SAPEndPoint& maxPoint = tmpArray[tmpCount*2+1];
#ifdef USE_INTEGERS
				minPoint.mValue = EncodeFloat(MinValue);
#else
				minPoint.mValue = MinValue;
#endif
				minPoint.ownerIndex = BoxIndex;
				minPoint.flagMax = 0;

#ifdef USE_INTEGERS
				maxPoint.mValue = EncodeFloat(MaxValue);
#else
				maxPoint.mValue = MaxValue;
#endif

				maxPoint.ownerIndex = BoxIndex;
				maxPoint.flagMax = 1;
				tmpCount++;
			}
			InsertEndPointToArrayBatch(tmpArray,Axis);
		}

		BoxPruningForBatchCreate(mCreateDataMap);

		mCreateDataMap.clear();
		mCreatesDbFlags.Reset();
	}

	void ArraySAP::BatchRemove()
	{
		if(mRemoveList.empty())
		{
			return;
		}

		//删除所有关联的Pair
		Bitset db(65536);	
		for (size_t i=0;i<mRemoveList.size();i++)
		{
			db.Set(mRemoveList[i]);
		}

		const PairList& pairList = mPairManager.FindAssociatePairs(db);
		for (size_t i=0;i<pairList.size();i++)
		{
			Pair* pPair = pairList[i];
			//it set new and delte in one frame, do not need report
			if(!pPair->IsNew())
			{
				if(m_pCommonListner)
				{
					m_pCommonListner->OnPairDelete(pPair->object0,pPair->object1,pPair->userData);
				}
			}
				
			mOperatePairSet.erase(mPairManager.GetPairKey(pPair));
			mPairManager.RemovePair(pPair->id0,pPair->id1);
		}

		IDSet tmpEndPointIndexSet[3];
		for (size_t i=0;i<mRemoveList.size();i++)
		{
			SAPBox& box = mBoxList[mRemoveList[i]];
				
			for (unsigned int Axis = 0; Axis < 3; Axis++)
			{
				tmpEndPointIndexSet[Axis].insert(box.mMin[Axis]);
				tmpEndPointIndexSet[Axis].insert(box.mMax[Axis]);	
			}

			FreeBox(&box);
		}

		for (unsigned int axis=0;axis<3;axis++)
		{
			unsigned int tmpMinIndex = *(tmpEndPointIndexSet[axis].begin());
			for(IDSet::reverse_iterator rIter= tmpEndPointIndexSet[axis].rbegin();rIter!=tmpEndPointIndexSet[axis].rend();rIter++)
			{
				unsigned int nowIndex = *rIter;
				mEndPointArrays[axis].erase(mEndPointArrays[axis].begin()+nowIndex);
			}
			UpdateIndexForEndPointArray(axis,tmpMinIndex);
		}

		mRemoveList.clear();
	}


	unsigned int ArraySAP::DumpPairs()
	{
		//先删除需要删除的,再进行后续处理
		BatchRemove();

		BatchCreate();
		IDList removeList;
		for (IDSet::iterator iKey = mOperatePairSet.begin();iKey!=mOperatePairSet.end();iKey++)
		{
			unsigned int tmpKey = *iKey;
			Pair* pPair = mPairManager.FindPair(tmpKey);
			if(pPair->IsRemoved())
			{
				if(!pPair->IsNew())
				{
					if(m_pCommonListner)
					{
						m_pCommonListner->OnPairDelete(pPair->object0,pPair->object1,pPair->userData);
					}
				}
				removeList.push_back(tmpKey);
			}
			else
			{
				pPair->ClearInArray();
				// Add => already there... Might want to create user data, though
				if(pPair->IsNew())
				{
					if(m_pCommonListner)
					{
						pPair->userData = m_pCommonListner->OnPairCreate(pPair->object0,pPair->object1);
					}
					pPair->ClearNew();
				}
			}
		}

		for(size_t i=0;i<removeList.size();i++)
		{
			mPairManager.RemovePair(removeList[i]);
		}

		mOperatePairSet.clear();


		return mPairManager.GetPairsSize();
	}

	void ArraySAP::InsertEndPointToArray( const SAPEndPoint& endPoint,unsigned int axis )
	{
		SAPEndPointArray& tmpArray = mEndPointArrays[axis];
			
		SAPEndPointArrayIter inserIter = std::lower_bound(tmpArray.begin(),tmpArray.end(),endPoint);
		size_t retIndex = inserIter - tmpArray.begin();
		tmpArray.insert(inserIter,endPoint);

		UpdateIndexForEndPointArray(axis,retIndex);
	}

	void ArraySAP::InsertEndPointToArrayBatch( const SAPEndPointArray& insertArray,unsigned int axis )
	{
		SAPEndPointArray& tmpArray = mEndPointArrays[axis];
		size_t minIndex = tmpArray.size()+insertArray.size();

		for (size_t i=0;i<insertArray.size();i++)
		{
			SAPEndPointArrayIter insertIter = std::lower_bound(tmpArray.begin(),tmpArray.end(),insertArray[i]);
			size_t tmpIndex = insertIter - tmpArray.begin();
			if(minIndex>tmpIndex)
			{
				minIndex = tmpIndex;
			}
			tmpArray.insert(insertIter,insertArray[i]);
		}

		UpdateIndexForEndPointArray(axis,minIndex);
	}

	void ArraySAP::UpdateIndexForEndPointArray( unsigned int axis, unsigned int fromIndex )
	{
		if(fromIndex>=mEndPointArrays[axis].size())
		{
			return;
		}

		SAPEndPoint* pEndPoint = &(mEndPointArrays[axis][fromIndex]);
		Prefetch(pEndPoint);
		for (size_t i=fromIndex;i<mEndPointArrays[axis].size();i++)
		{
			//update box index
			SAPBox& tmpBox = mBoxList[pEndPoint->ownerIndex];
			if(pEndPoint->flagMax)
			{
				tmpBox.mMax[axis] = i;
			}
			else
			{
				tmpBox.mMin[axis] = i;
			}
			pEndPoint++;
		}
	}

	unsigned int ArraySAP::GetPropIndexFromEndPointArray( unsigned int axis, ValType val , unsigned int currentIndex)
	{
		SAPEndPoint tmpPoint;
		tmpPoint.mValue = val;

		SAPEndPointArray& tmpArray = mEndPointArrays[axis];
		SAPEndPointArrayIter insertIter = std::lower_bound(tmpArray.begin(),tmpArray.end(),tmpPoint);
		unsigned int tmpIndex = (unsigned int)(insertIter-mEndPointArrays[axis].begin());
		//we real get from this function is a update index,not a insert index,
		//so need to sub one when index is after the current index(current node will be take out)
		if(tmpIndex>currentIndex)	
		{
			tmpIndex--;
		}
		return tmpIndex;
	}

	void ArraySAP::ShiftOneItemInEndPointArray( unsigned int axis,unsigned int srcIndex,unsigned int dstIndex )
	{
		if(srcIndex==dstIndex)
		{
			return;
		}

		SAPEndPointArray& tmpArray = mEndPointArrays[axis];

		////Prefetch(pSrcEndPoint);
		SAPEndPoint savePoint = tmpArray[srcIndex];

		bool bSrcMax = srcIndex>dstIndex;

		if(bSrcMax)
		{
			for(int i=srcIndex;i>=(int)dstIndex;i--)
			{
				if(i==dstIndex)
				{
					tmpArray[i] = savePoint;
				}
				else
				{
					tmpArray[i] = tmpArray[i-1];
				}
				SAPBox& tmpBox = mBoxList[tmpArray[i].ownerIndex];
				tmpBox.mMin[axis+tmpArray[i].flagMax*3] = i;

			}
		}
		else
		{
			for(int i=srcIndex;i<=(int)dstIndex;i++)
			{
				if(i==dstIndex)
				{
					tmpArray[i] = savePoint;
				}
				else
				{
					tmpArray[i] = tmpArray[i+1];
				}
				SAPBox& tmpBox = mBoxList[tmpArray[i].ownerIndex];
				tmpBox.mMin[axis+tmpArray[i].flagMax*3] = i;
			}
		}
			
	}

	void ArraySAP::ChangeEndPointValue(SAPBox& srcBox, InnerAABB& updateBox, unsigned int axis, bool bMaxEndPoint , ValType newValue)
	{
		const unsigned int axis1 = (1  << axis) & 3;
		const unsigned int axis2 = (1  << axis1) & 3;
		SAPEndPointArray& tmpArray = mEndPointArrays[axis];

		SAPEndPoint* pOperPoint = GetBoxEndPoint(srcBox,axis,bMaxEndPoint);
		ValType oldValue = pOperPoint->mValue;

#ifdef USE_INTEGERS
		if(newValue==oldValue)
		{
			return;
		}
#else
		if(fabs(newValue - oldValue) < 1e-6f)
		{
			return;
		}
#endif

		bool bCheckMax = !bMaxEndPoint;
		unsigned int offsetFromMin = bMaxEndPoint?3:0;

		unsigned int srcIndex = srcBox.mMin[axis+offsetFromMin];
		unsigned int dstIndex = GetPropIndexFromEndPointArray(axis,newValue,srcIndex);
		pOperPoint->mValue = newValue;

		if(srcIndex==dstIndex)
		{
			return;
		}

		bool bMoveLeft = newValue<oldValue;
		bool bAddPair = (bCheckMax && bMoveLeft) || (!bCheckMax && !bMoveLeft);

		ShiftOneItemInEndPointArray(axis,srcIndex,dstIndex);
		//begin handle in updated info
		if(bMoveLeft)
		{
			for (int i=srcIndex;i>(int)dstIndex;i--)
			{
				SAPEndPoint* pTestPoint = &mEndPointArrays[axis][i];
				SAPBox& dstBox = mBoxList[pTestPoint->ownerIndex];
				if(&dstBox != &srcBox)
				{
					bool bNeedCheck = (bCheckMax && pTestPoint->flagMax) || (!bCheckMax && !pTestPoint->flagMax);
					bNeedCheck = bNeedCheck && srcBox.CanCollideWith(dstBox);
					if(bNeedCheck)
					{
						if(bAddPair)
						{
							if(Intersect2D(srcBox,dstBox,axis1,axis2)
								&& Intersect1D_Min(updateBox,dstBox,axis))
							{
								AddPair(srcBox.mObject, dstBox.mObject,srcBox.mBoxIndex,dstBox.mBoxIndex);
							}
						}
						else
						{
							if(Intersect2D(srcBox,dstBox,axis1,axis2))
							{
								RemovePair(srcBox.mObject,dstBox.mObject,srcBox.mBoxIndex,dstBox.mBoxIndex);
							}
						}
					}
				}
			}
		}
		else
		{
			for (int i=srcIndex;i<(int)dstIndex;i++)
			{
				SAPEndPoint* pTestPoint = &mEndPointArrays[axis][i];
				SAPBox& dstBox = mBoxList[pTestPoint->ownerIndex];
				if(&dstBox != &srcBox)
				{
					bool bNeedCheck = (bCheckMax && pTestPoint->flagMax) || (!bCheckMax && !pTestPoint->flagMax);
					bNeedCheck = bNeedCheck && srcBox.CanCollideWith(dstBox);
					if(bNeedCheck)
					{
						if(bAddPair)
						{
							if(Intersect2D(srcBox,dstBox,axis1,axis2)
								&& Intersect1D_Min(updateBox,dstBox,axis))
							{
								AddPair(srcBox.mObject, dstBox.mObject,srcBox.mBoxIndex,dstBox.mBoxIndex);
							}
						}
						else
						{
							if(Intersect2D(srcBox,dstBox,axis1,axis2))
							{
								RemovePair(srcBox.mObject,dstBox.mObject,srcBox.mBoxIndex,dstBox.mBoxIndex);
							}
						}
					}
				}
			}
		}
	}

	SAPEndPoint* ArraySAP::GetBoxEndPoint( SAPBox& srcBox, unsigned int axis,bool bMaxEndPoint )
	{
		if(bMaxEndPoint)
		{
			return &(mEndPointArrays[axis][srcBox.mMax[axis]]);
		}
		else
		{
			return &(mEndPointArrays[axis][srcBox.mMin[axis]]);
		}
	}

	ValType ArraySAP::GetBoxEndPointValue( SAPBox& srcBox, unsigned int axis,bool bMaxEndPoint )
	{
		return GetBoxEndPoint(srcBox,axis,bMaxEndPoint)->mValue;
	}

	bool ArraySAP::Intersect(SAPBox& a, SAPBox& b, unsigned int axis )
	{
		return !((GetBoxEndPointValue(b,axis,true)<GetBoxEndPointValue(a,axis,false))
			||(GetBoxEndPointValue(a,axis,true)<GetBoxEndPointValue(b,axis,false)));
	}

	bool ArraySAP::IntersectValType( ValType aMin, ValType aMax, ValType bMin, ValType bMax )
	{
		return !((bMax<aMin)||(aMax<bMin));
	}

	bool ArraySAP::Intersect2D( SAPBox& a, SAPBox& b, unsigned int axis1, unsigned int axis2 )
	{
		return Intersect(a,b,axis1) && Intersect(a,b,axis2);
	}

	bool ArraySAP::Intersect1D_Min( InnerAABB& a, SAPBox& b, unsigned int axis )
	{
		return (GetBoxEndPointValue(b,axis,true) >= a.GetMin(axis));
	}

	unsigned int ArraySAP::QueryObjectsByAABB( const kmAABB& queryBox, SAPQueryListner* pQueryListner, unsigned short collisionFlag /*= 0xffff*/ )
	{
		unsigned int objectCount = 0;
		kmAABB tmpBox = queryBox;
		if(fabs(tmpBox.max.x - tmpBox.min.x) <= 1e-6f)
		{
			tmpBox.max.x = tmpBox.min.x + 0.001f;
		}

		if(fabs(tmpBox.max.y - tmpBox.min.y) <= 1e-6f)
		{
			tmpBox.max.y = tmpBox.min.y + 0.001f;
		}

		if(fabs(tmpBox.max.z - tmpBox.min.z) <= 1e-6f)
		{
			tmpBox.max.z = tmpBox.min.z + 0.001f;
		}

		InnerAABB box;
#ifdef USE_INTEGERS
		box.mMinX = EncodeFloat(tmpBox.min.x);
		box.mMinY = EncodeFloat(tmpBox.min.y);
		box.mMinZ = EncodeFloat(tmpBox.min.z);
		box.mMaxX = EncodeFloat(tmpBox.max.x);
		box.mMaxY = EncodeFloat(tmpBox.max.y);
		box.mMaxZ = EncodeFloat(tmpBox.max.z);
#else
		box.mMinX = tmpBox.min.x;
		box.mMinY = tmpBox.min.y;
		box.mMinZ = tmpBox.min.z;
		box.mMaxX = tmpBox.max.x;
		box.mMaxY = tmpBox.max.y;
		box.mMaxZ = tmpBox.max.z;
#endif


		ValType queryMinVal = box.GetMin(0);
		ValType queryMaxVal = box.GetMax(0);

		SAPEndPointArray& tmpArray = mEndPointArrays[0];
		SAPEndPoint tmpMinPoint;
		tmpMinPoint.mValue = queryMinVal;
		SAPEndPointArrayIter findIter = std::lower_bound(tmpArray.begin(),tmpArray.end(),tmpMinPoint);
		for (SAPEndPointArrayIter iEndPoint = findIter;iEndPoint!=tmpArray.end();iEndPoint++)
		{
			SAPEndPoint& tmpEndPoint = *iEndPoint;
			if(tmpEndPoint.mValue > queryMaxVal)
			{
				break;
			}
			else
			{
				if(!tmpEndPoint.flagMax)
				{
					SAPBox& tmpBox = mBoxList[tmpEndPoint.ownerIndex];
					if((tmpBox.mGroupFlag & collisionFlag)
						&& IntersectValType(box.GetMin(1),box.GetMax(1),GetBoxEndPointValue(tmpBox,1,false),GetBoxEndPointValue(tmpBox,1,true))
						&& IntersectValType(box.GetMin(2),box.GetMax(2),GetBoxEndPointValue(tmpBox,2,false),GetBoxEndPointValue(tmpBox,2,true)))
					{
						objectCount++;
						if(pQueryListner)
						{
							pQueryListner->OnQueryObject(tmpBox.mObject);
						}
					}
				}
			}
		}

		//query the endpoint before findIter
		for (SAPEndPointArrayIter iEndPoint = tmpArray.begin(); iEndPoint != findIter; iEndPoint++)
		{
			SAPEndPoint& tmpEndPoint = *iEndPoint;
			if(!tmpEndPoint.flagMax)
			{
				SAPBox& tmpBox = mBoxList[tmpEndPoint.ownerIndex];
				ValType tmpMaxVal = GetBoxEndPointValue(tmpBox,0,true);
				if(tmpMaxVal>=queryMinVal)
				{
					if((tmpBox.mGroupFlag & collisionFlag)
						&& IntersectValType(box.GetMin(1),box.GetMax(1),GetBoxEndPointValue(tmpBox,1,false),GetBoxEndPointValue(tmpBox,1,true))
						&& IntersectValType(box.GetMin(2),box.GetMax(2),GetBoxEndPointValue(tmpBox,2,false),GetBoxEndPointValue(tmpBox,2,true)))
					{
						objectCount++;
						if(pQueryListner)
						{
							pQueryListner->OnQueryObject(tmpBox.mObject);
						}
					}
				}
			}
		}

		return objectCount;
	}

	void ArraySAP::SetCommonListner( SAPCommonListner* pListner )
	{
		m_pCommonListner = pListner;
	}

	PairList ArraySAP::QueryObjectAssociatePairs( unsigned int handle )
	{
		Bitset db(65536);
		db.Set(handle);
		return mPairManager.FindAssociatePairs(db);
	}
